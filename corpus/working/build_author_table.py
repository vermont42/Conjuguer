#!/usr/bin/env python3
"""Resolve the authors quoted by French Wiktionary to Wikidata death years.

The verb pass may reuse a Wiktionnaire quotation as an app example only when the quotation is
public domain, and the rule (decision 2 of prompts/verb-pass-plan.md) is the author's death
year, not the edition year the reference shows: usable iff the author died before 1931. An
unresolved author is not public domain.

Reads every `ref` on a French-Wiktionary example for the verbs the pass may need an example for
(no app example at all, plus the ones whose example is Claude-authored), parses the author's
name out of the reference, resolves the names against Wikidata's SPARQL endpoint in batches,
and writes `corpus/working/wiktionary/authors.json`:

    { "<name>": { "qid", "label", "death_year" | null, "status" } }

`authors_overrides.json` beside it, if present, is merged last and wins; it is where hand
corrections live (Dumas père versus fils being the obvious one).

Raw SPARQL answers are cached under `wikidata_cache/`, so a re-run costs nothing.

Usage:  python3 corpus/working/build_author_table.py [--batch 100] [--no-network]
"""
import argparse
import collections
import hashlib
import json
import pathlib
import re
import sys
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request

USER_AGENT = "Conjuguer-verb-pass/1.0 (https://github.com/vermont42/Conjuguer; vermontcoder@gmail.com)"
ENDPOINT = "https://query.wikidata.org/sparql"

REPO = pathlib.Path(__file__).resolve().parents[2]
VERBS_XML = REPO / "Conjuguer" / "Models" / "verbs.xml"
EXAMPLES = REPO / "corpus" / "json" / "literature_examples.json"
WIKTIONARY = REPO / "corpus" / "working" / "wiktionary"
FR_REFERENCE = WIKTIONARY / "wiktionary_fr_verbs.json"
OUT = WIKTIONARY / "authors.json"
OVERRIDES = WIKTIONARY / "authors_overrides.json"
CACHE = WIKTIONARY / "wikidata_cache"

PUBLIC_DOMAIN_BEFORE = 1931

# A reference whose "author" is one of these is not a person whose death year could make the
# quotation public domain: a periodical, an encyclopedia, an unattributed text. A translation is
# dropped whole, because the translator holds rights of their own that the original author's
# death year says nothing about.
NOT_A_PERSON = re.compile(
    r"^(journal|revue|magazine|site|le journal|wikipédia|wikipedia|wiktionnaire|auteur inconnu|anonyme|collectif)\b",
    re.IGNORECASE,
)
TRANSLATION = re.compile(r"\btrad(\.|uction|uit)", re.IGNORECASE)
LEADING_YEAR = re.compile(r"^\(?(1[0-9]{3}|20[0-9]{2})\)?\s*[,:—–-]?\s*")

# Wikidata occupations that make a label's holder the kind of person a literary quotation is
# attributed to. Used only to break a tie when one label matches several humans.
WRITER_OCCUPATIONS = {
    "Q36180",    # writer
    "Q482980",   # author
    "Q49757",    # poet
    "Q6625963",  # novelist
    "Q214917",   # playwright
    "Q11774202", # essayist
    "Q18814623", # autobiographer
    "Q15980158", # non-fiction writer
    "Q1930187",  # journalist
    "Q201788",   # historian
    "Q4964182",  # philosopher
    "Q333634",   # translator
    "Q1607826",  # editor
    "Q11774156", # screenwriter
}

# Match the label in French, in "mul", and in English. "mul" is not optional: Wikidata has been
# migrating labels that are spelled the same in every language to the multilingual "mul" label and
# DELETING the per-language ones, so a French-only lookup silently misses Victor Hugo (Q535),
# Jean-Paul Sartre (Q9364) and most other authors whose name needs no translation. Their items come
# back from SPARQL with no fr label at all, which reads as "no such person" rather than as an error.
LABEL_LANGUAGES = ("fr", "mul", "en")

QUERY = """SELECT ?name ?item ?death ?occupation ?sitelinks WHERE {
  VALUES ?name { %s }
  ?item rdfs:label ?name .
  ?item wdt:P31 wd:Q5 .
  OPTIONAL { ?item wdt:P570 ?death . }
  OPTIONAL { ?item wdt:P106 ?occupation . }
  OPTIONAL { ?item wikibase:sitelinks ?sitelinks . }
}"""

# How decisively the leading namesake must out-sitelink the runner-up before the batch treats the
# label as unambiguous. Victor Hugo the poet has two orders of magnitude more Wikipedias than the
# other humans who share his name; two genuinely confusable writers do not.
SITELINK_MINIMUM = 5
SITELINK_RATIO = 3

# Wikidata writes a name's apostrophe as U+2019 (Barbey d’Aurevilly); a Wiktionary reference
# uses either that or a straight U+0027, sometimes both for the same author. An exact-label match
# has to try both spellings or it loses the author entirely.
APOSTROPHES = ("'", "’")


def variants(name):
    """The name as written, plus the same name with the other apostrophe."""
    spellings = [name]
    for apostrophe in APOSTROPHES:
        for other in APOSTROPHES:
            swapped = name.replace(apostrophe, other)
            if swapped not in spellings:
                spellings.append(swapped)
    return spellings


# Carried in every batch. A batch that comes back without it did not really come back, whatever
# the HTTP status said, so it is retried rather than cached as a row of empty answers.
CANARY = "Honoré de Balzac"


def nfc(string):
    return unicodedata.normalize("NFC", string)


def target_verbs():
    """Verbs the pass may need an example for: none today, or a Claude-authored one."""
    xml = VERBS_XML.read_text(encoding="utf-8")
    app = {nfc(w) for w in re.findall(r'<verb in="([^"]+)"', xml)}
    examples = json.loads(EXAMPLES.read_text(encoding="utf-8"))
    # An example key may be a verb id carrying extra letters ("sortir (exit)").
    covered = {key.split(" (")[0] for key in examples}
    authored = {
        key.split(" (")[0] for key, value in examples.items()
        if (value.get("source") or "").startswith("Claude")
    }
    return (app - covered) | authored, len(app), len(covered), len(authored)


def author_of(reference):
    """The author's name in a Wiktionary reference, or None when it names no person."""
    text = LEADING_YEAR.sub("", reference.strip())
    name = text.split(",")[0].strip().strip("«»“”\"").strip()
    if not name or len(name) > 60:
        return None
    if NOT_A_PERSON.match(name) or TRANSLATION.search(reference):
        return None
    # A "name" with no letter, or written entirely in lowercase, is a title fragment.
    if not re.search(r"[^\W\d_]", name) or name == name.lower():
        return None
    return name


def collect_names(verbs):
    reference = json.loads(FR_REFERENCE.read_text(encoding="utf-8"))
    quotations = collections.Counter()
    dropped = collections.Counter()
    total = 0
    for verb in verbs:
        for entry in reference.get(verb, []):
            for sense in entry["senses"]:
                for example in sense["examples"]:
                    raw = (example.get("ref") or "").strip()
                    if not raw:
                        continue
                    total += 1
                    name = author_of(raw)
                    if name:
                        quotations[name] += 1
                    else:
                        dropped[raw.split(",")[0].strip()[:40]] += 1
    return quotations, dropped, total


def sparql(names, allow_network=True, session_delay=1.0):
    """One SPARQL batch, cached on disk by the exact query text."""
    batch = sorted({spelling for name in set(names) | {CANARY} for spelling in variants(name)})
    values = " ".join(
        '"%s"@%s' % (n.replace("\\", "\\\\").replace('"', '\\"'), language)
        for n in batch for language in LABEL_LANGUAGES
    )
    query = QUERY % values
    key = hashlib.sha256(query.encode("utf-8")).hexdigest()[:32]
    cached = CACHE / f"{key}.json"
    if cached.exists():
        return json.loads(cached.read_text(encoding="utf-8")), True
    if not allow_network:
        return {"results": {"bindings": []}}, True
    data = urllib.parse.urlencode({"query": query, "format": "json"}).encode("utf-8")
    request = urllib.request.Request(
        ENDPOINT,
        data=data,
        headers={"User-Agent": USER_AGENT, "Accept": "application/sparql-results+json"},
    )
    for attempt in range(4):
        try:
            with urllib.request.urlopen(request, timeout=180) as response:
                payload = json.loads(response.read().decode("utf-8"))
            answered = {row["name"]["value"] for row in payload["results"]["bindings"]}
            if CANARY not in answered:
                raise ValueError("the canary label did not come back")
            cached.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
            time.sleep(session_delay)
            return payload, False
        except (urllib.error.HTTPError, urllib.error.URLError, TimeoutError, ValueError) as error:
            wait = 5 * (attempt + 1)
            print(f"    {type(error).__name__} {error}; retrying in {wait}s", file=sys.stderr)
            time.sleep(wait)
    raise RuntimeError("Wikidata did not answer after four attempts")


def death_year(literal):
    match = re.match(r"^(-?\d{1,4})-", literal or "")
    return int(match.group(1)) if match else None


def resolve(names, batch_size, allow_network):
    """Name → {qid, label, death_year, status}. Splits a batch that the endpoint refuses."""
    candidates = collections.defaultdict(lambda: collections.defaultdict(
        lambda: {"death": set(), "occupations": set(), "sitelinks": 0}
    ))
    ordered = sorted(names)
    pending = [ordered[i:i + batch_size] for i in range(0, len(ordered), batch_size)]
    done = 0
    while pending:
        batch = pending.pop(0)
        try:
            payload, was_cached = sparql(batch, allow_network)
        except RuntimeError:
            if len(batch) == 1:
                print(f"    giving up on {batch[0]!r}", file=sys.stderr)
                done += 1
                continue
            half = len(batch) // 2
            pending[:0] = [batch[:half], batch[half:]]
            continue
        # A row comes back under whichever apostrophe spelling matched, so it is credited to
        # every queried name that spelling stands for.
        owners = collections.defaultdict(set)
        for name in batch:
            for spelling in variants(name):
                owners[spelling].add(name)
        for row in payload["results"]["bindings"]:
            spelling = row["name"]["value"]
            qid = row["item"]["value"].rsplit("/", 1)[-1]
            for name in owners.get(spelling, ()):
                record = candidates[name][qid]
                if "death" in row:
                    record["death"].add(death_year(row["death"]["value"]))
                if "occupation" in row:
                    record["occupations"].add(row["occupation"]["value"].rsplit("/", 1)[-1])
                if "sitelinks" in row:
                    record["sitelinks"] = max(record["sitelinks"], int(row["sitelinks"]["value"]))
        done += len(batch)
        print(f"  resolved {done}/{len(ordered)} names{' (cached)' if was_cached else ''}", end="\r")
    print()

    table = {}
    for name in ordered:
        matches = candidates.get(name)
        if not matches:
            table[name] = {"qid": None, "label": None, "death_year": None, "status": "no_match"}
            continue
        if len(matches) > 1:
            writers = {q: m for q, m in matches.items() if m["occupations"] & WRITER_OCCUPATIONS}
            if writers:
                matches = writers
        if len(matches) > 1:
            # Several humans still share the label. If they agree on the death year the
            # public-domain verdict is the same either way, so it is not really ambiguous.
            years = {next(iter(m["death"]), None) for m in matches.values()}
            if len(years) != 1 or None in years:
                ranked = sorted(matches.items(), key=lambda pair: -pair[1]["sitelinks"])
                leader, runner_up = ranked[0][1]["sitelinks"], ranked[1][1]["sitelinks"]
                if leader >= SITELINK_MINIMUM and leader >= SITELINK_RATIO * max(runner_up, 1):
                    matches = dict([ranked[0]])
                else:
                    table[name] = {
                        "qid": None, "label": None, "death_year": None,
                        "status": f"ambiguous ({len(matches)} humans)",
                    }
                    continue
        qid, record = sorted(matches.items())[0]
        year = next(iter(sorted(y for y in record["death"] if y is not None)), None) \
            if record["death"] else None
        table[name] = {
            "qid": qid,
            "label": name,
            "death_year": year,
            "status": "resolved" if year is not None else "no_death_date",
        }
    return table


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--batch", type=int, default=100, help="labels per SPARQL query")
    parser.add_argument("--no-network", action="store_true", help="use only the cache")
    args = parser.parse_args()

    CACHE.mkdir(parents=True, exist_ok=True)
    verbs, app_count, covered, authored = target_verbs()
    print(f"app verbs {app_count}, with an example {covered} ({authored} Claude-authored) "
          f"→ {len(verbs)} verbs the pass may need an example for")

    quotations, dropped, total = collect_names(verbs)
    print(f"references seen {total}; author names kept {len(quotations)}; "
          f"references dropped as non-person/translation {sum(dropped.values())}")
    print("  most quoted:", ", ".join(f"{n} ({c})" for n, c in quotations.most_common(8)))
    recurring = [n for n, c in quotations.items() if c >= 2]
    print(f"  names with two or more quotations: {len(recurring)}")

    table = resolve(set(quotations), args.batch, not args.no_network)

    if OVERRIDES.exists():
        # A leading underscore marks documentation inside the overrides file, not an author.
        overrides = {
            name: record for name, record in json.loads(OVERRIDES.read_text(encoding="utf-8")).items()
            if not name.startswith("_")
        }
        table.update(overrides)
        unquoted = sorted(set(overrides) - set(quotations))
        print(f"merged {len(overrides)} hand corrections from {OVERRIDES.name}")
        if unquoted:
            print(f"  (these override no quotation in this run: {unquoted})")

    with open(OUT, "w", encoding="utf-8") as out:
        json.dump(dict(sorted(table.items())), out, ensure_ascii=False, indent=1)
    print(f"wrote {OUT.relative_to(REPO)} ({len(table)} names)")

    status = collections.Counter(record["status"].split(" (")[0] for record in table.values())
    print("status:", dict(status))
    public_domain = {
        name for name, record in table.items()
        if record["death_year"] is not None and record["death_year"] < PUBLIC_DOMAIN_BEFORE
    }
    usable = sum(quotations[name] for name in public_domain)
    print(f"public-domain authors (died before {PUBLIC_DOMAIN_BEFORE}): {len(public_domain)}; "
          f"quotations they account for: {usable} of {sum(quotations.values())}")

    unresolved = sorted(
        ((quotations[n], n, table[n]["status"]) for n in quotations if table[n]["death_year"] is None),
        reverse=True,
    )
    heavy = [u for u in unresolved if u[0] >= 5]
    print(f"unresolved authors with five or more quotations: {len(heavy)}")
    for count, name, why in heavy[:40]:
        print(f"    {count:4d}  {name}  [{why}]")

    verbs_with_usable = 0
    reference = json.loads(FR_REFERENCE.read_text(encoding="utf-8"))
    for verb in verbs:
        for entry in reference.get(verb, []):
            found = False
            for sense in entry["senses"]:
                for example in sense["examples"]:
                    name = author_of((example.get("ref") or "").strip())
                    if name in public_domain:
                        found = True
                        break
                if found:
                    break
            if found:
                verbs_with_usable += 1
                break
    print(f"verbs with at least one public-domain quotation: {verbs_with_usable} "
          f"(the plan estimated 2,731 from edition years)")


if __name__ == "__main__":
    main()
