#!/usr/bin/env python3
"""Apply the accepted verb-pass changes to the app's data.

Stage 4 of prompts/verb-pass-plan.md. Reads the Stage 2 shards and results, the Stage 3
skeptic items, corpus/working/added_glosses.json and corpus/working/verb_pass/approvals.json,
and applies every item whose effective decision is `accept`:

    gloss, gloss:added   the tn attribute of verbs.xml
    flag:re/ay/ah/dg     the re, ay, ah and dg attributes of verbs.xml
    example              the English of a shipped example, or its removal when the card has
                         neither an English fix nor an applied replacement
    new_example, pick    a new example in both copies of literature_examples.json

An item's own decision wins; a pending item takes the first `defaults` rule matching its task
and rank band, except a `partly` or `added` item, which no rule decides. A value Josh typed
replaces the checker's proposal.

Every change is written as a target value, never as a toggle, so a second run changes nothing.
verbs.xml is edited as text, one line per changed verb, with the attributes in the file's order
(in tn ay re mo hi hn hl hs hp dg ah ex), so `git diff` shows only the changed lines. The example
files are written with json.dump(indent=1), keys sorted, and no trailing newline, as before.
Example apostrophes stay straight, as in every shipped example; gloss apostrophes are curly, and
so are a citation's, to match the app's hard-coded titles (« L’Assommoir »).

A pick's French, source and line come from the matched candidate (validate_verb_pass.pick_status),
never from the result file. Quotations are attributed as `wiktionnaire|<author>|<title>|<year>`
(French Wiktionary) or `wiktionary|<author>|<title>|<year>` (English Wiktionary); an English
Wiktionary usage example, which no author wrote, is `wiktionary`. The year is dropped when it
postdates the author's death, since it is then a reprint's.

The English-Wiktionary candidates carried no author: build_candidates.py dropped each quotation's
`ref`. So a wiktionary_en pick is looked up again in the reference, and one whose source has a
`ref` ships only if it is listed in PUBLIC_DOMAIN_EN_QUOTATIONS below. The rest are left out.

Stage 5.6 (`--pass-dir corpus/working/verb_pass/stage5`) applies the Stage 5 approvals instead:
`new_example`, `pick` and `gloss` items only, each verb's latest attempt across the shards
(build_report.latest_attempts), into a second marked section of docs/authored-examples.md. A pick's
value `{fr, en}` replaces its translation, and its French must still match a candidate; a
`value.candidate` names a different candidate of the verb, found by its fields and re-checked with
pick_status. An example written for a proposed gloss is applied only with that gloss. A Stage 4 run
leaves alone any gloss or example that Stage 5 has accepted, so the later stage wins.

Usage:
    python3 corpus/working/apply_verb_pass.py --dry-run     # print what would change, write nothing
    python3 corpus/working/apply_verb_pass.py
    python3 corpus/working/apply_verb_pass.py --pass-dir corpus/working/verb_pass/stage5 [--dry-run]
"""
import argparse
import collections
import json
import re
import sys

import build_report
import build_review_page
import validate_verb_pass as validator
import verb_pass_lib as lib

AUTHORED_SOURCE = "Claude (Sonnet 5)"
AUTHORED_DOC = lib.REPO / "docs" / "authored-examples.md"
DOC_START = "<!-- verb-pass:start -->"
DOC_END = "<!-- verb-pass:end -->"
STAGE5_DOC_START = "<!-- verb-pass-stage5:start -->"
STAGE5_DOC_END = "<!-- verb-pass-stage5:end -->"
LOG = lib.OUT_DIR / "applied.json"
ATTRIBUTE_ORDER = ["in", "tn", "ay", "re", "mo", "hi", "hn", "hl", "hs", "hp", "dg", "ah", "ex"]
CLEAR_VALUES = {"none", "null", "-", ""}

# English-Wiktionary quotations whose author died before 1931 (decision 2), by verb, as
# (author, title, year). Read from each quotation's `ref` on 2026-10-01. The 1916 song quoted
# for claironner has no named lyricist, so it is not here; nor is anything later than 1902.
PUBLIC_DOMAIN_EN_QUOTATIONS = {
    "briguer": ("Pierre Corneille", "Horace", "1640"),
    "dégréer": ("Mercure de France", None, "1782"),
    "bâter": ("Miguel de Cervantes, trad. Louis Viardot", "L'Ingénieux Hidalgo Don Quichotte de la Manche", "1836"),
    "méprendre": ("Gustave Flaubert", "Madame Bovary", "1857"),
    "amonceler": ("Victor Hugo", "Les Misérables", "1862"),
    "ramoner": ("Jules Verne", "L'Île mystérieuse", "1874"),
    "fourmiller": ("Maurice Rollinat", "Dans les brandes", "1877"),
    "prêcher": ("René Boylesve", "Leçon d'amour", "1902"),
}


def straight(text):
    return (text or "").replace("’", "'").strip()


def curly(text):
    return (text or "").replace("'", "’").strip()


def effective(approvals, key, entry):
    decision = entry["decision"]
    if decision != "pending":
        return decision
    if entry.get("verdict") in ("partly", "added"):
        return "pending"
    return build_review_page.default_decision(approvals, build_review_page.task_of(key), entry["rank"]) or "pending"


def plain_title(title):
    title = (title or "").strip()
    if title.startswith("«") and title.endswith("»") and title.count("«") == 1:
        title = title[1:-1].strip()
    return title


def credited(author, translator):
    return f"{author}, trad. {translator}" if author and translator else author


def citation_source(prefix, author, title, year, death_year=None):
    year = (re.search(r"-?\d{3,4}", str(year or "")) or [None])[0]
    if year and isinstance(death_year, int) and int(year) > death_year:
        year = None
    fields = [author or "", plain_title(title), year or ""]
    if any("|" in field for field in fields):
        sys.exit(f"a citation field contains '|': {fields}")
    return "|".join([prefix] + [curly(field) for field in fields])


def english_reference(english, infinitive, text):
    target = validator.normalize(text)
    for entry in english.get(infinitive) or []:
        for sense in entry.get("senses") or []:
            for example in sense.get("examples") or []:
                normalized = validator.normalize(example.get("text"))
                if normalized == target or (len(target) > 20 and target in normalized):
                    return example
    return None


def pick_example(identifier, verb, chosen, english):
    """The example a pick ships as, or (None, reason)."""
    status, detail, candidate = validator.pick_status(chosen, verb)
    if status not in ("verbatim", "excerpt", "late_edition"):
        return None, f"provenance {status}: {detail}"
    french = chosen["fr"] if status == "excerpt" else candidate["text"]
    kind = chosen["kind"]
    if kind == "tier":
        source, line = candidate["source"], candidate["line"]
    elif kind == "wiktionnaire":
        source = citation_source("wiktionnaire", credited(candidate.get("author"), candidate.get("translator")),
                                 candidate.get("title"), candidate.get("year"), candidate.get("death_year"))
        line = None
    elif candidate.get("usage") is not None:
        source = "wiktionary" if candidate["usage"] else citation_source(
            "wiktionary", credited(candidate.get("author"), candidate.get("translator")),
            candidate.get("title"), candidate.get("year"), candidate.get("death_year"))
        line = None
    else:
        reference = english_reference(english, verb["infinitive"], candidate["text"])
        if reference is None:
            return None, "English-Wiktionary example not found in the reference"
        if reference.get("ref"):
            quotation = PUBLIC_DOMAIN_EN_QUOTATIONS.get(identifier)
            if quotation is None:
                return None, f"English-Wiktionary quotation, not public domain: {reference['ref'][:90]}"
            source = citation_source("wiktionary", *quotation)
        else:
            source = "wiktionary"
        line = None
    french = straight(french).strip('"“”')
    return {"fr": french, "en": straight(chosen["en"]), "source": source, "line": line,
            "token": straight(chosen.get("token"))}, None


def authored_example(proposed, entry, source=AUTHORED_SOURCE):
    value = entry.get("value") if isinstance(entry.get("value"), dict) else {}
    return {"fr": straight(value.get("fr") or proposed["fr"]), "en": straight(value.get("en") or proposed["en"]),
            "source": source, "line": None, "token": straight(proposed.get("token"))}


def token_in(example):
    words = validator.normalize(example["fr"])
    return all(part in words for part in validator.normalize(example["token"]).split())


def xml_escape(text):
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace('"', "&quot;")


def rewrite_line(line, changes):
    match = lib.VERB_RE.search(line)
    attributes = dict(re.findall(r'(\w+)="([^"]*)"', match.group(1)))
    for name, value in changes.items():
        if value is None:
            attributes.pop(name, None)
        else:
            attributes[name] = value
    unknown = set(attributes) - set(ATTRIBUTE_ORDER)
    if unknown:
        sys.exit(f"unknown attribute(s) {unknown} in {line.strip()}")
    body = " ".join(f'{name}="{attributes[name]}"' for name in ATTRIBUTE_ORDER if name in attributes)
    return line[:match.start()] + f"<verb {body} />" + line[match.end():]


def write_examples(examples):
    ordered = {key: examples[key] for key in sorted(examples)}
    for path in (lib.EXAMPLES_JSON, lib.EXAMPLES_COPY):
        with open(path, "w", encoding="utf-8") as out:
            json.dump(ordered, out, ensure_ascii=False, indent=1)


def authored_doc(rows):
    out = [DOC_START, "",
           f"## The verb pass ({len(rows):,} verbs, applied 2026-10-01)", "",
           "Stage 2 of the verb pass (`prompts/verb-pass-plan.md`) had Claude (Sonnet 5) write a sentence "
           "for each verb that no corpus sentence or public-domain quotation served, and Stage 3 had "
           "Claude (Opus 5) check each one for grammar, sense, translation and register, and for a "
           "qualifying candidate passed over. The rows below are the ones Josh accepted, in "
           "frequency-rank order. Each carries `\"source\": \"Claude (Sonnet 5)\"` and `\"line\": null`.",
           "", "| Rank | Verb | Form | French | English |", "|---|---|---|---|---|"]
    for row in rows:
        out.append(f"| {row['rank']} | {row['id']} | {build_report.md(row['token'])} | "
                   f"{build_report.md(row['fr'])} | {build_report.md(row['en'])} |")
    out += ["", DOC_END]
    return "\n".join(out)


def stage5_authored_doc(rows):
    out = [STAGE5_DOC_START, "",
           f"## Stage 5 of the verb pass ({len(rows):,} verbs, applied 2026-10-02)", "",
           "Stage 5 of the verb pass took the verbs that still had no example after Stage 4. Claude "
           "(Sonnet 5.5) wrote a sentence for each verb that no corpus sentence or public-domain quotation "
           "served, some of them with CNRTL dictionary evidence (Stages 5c–5e), and Claude (Opus 5.5) "
           "checked every one. The rows below are the ones Josh accepted, in frequency-rank order, with "
           "the corrections he approved for the skeptic's `partly` verdicts. Each carries "
           "`\"source\": \"Claude (Sonnet 5.5)\"` and `\"line\": null`.",
           "", "| Rank | Verb | Form | French | English |", "|---|---|---|---|---|"]
    for row in rows:
        out.append(f"| {row['rank']} | {row['id']} | {build_report.md(row['token'])} | "
                   f"{build_report.md(row['fr'])} | {build_report.md(row['en'])} |")
    out += ["", STAGE5_DOC_END]
    return "\n".join(out)


def update_authored_doc(rows, start=DOC_START, end=DOC_END, render=authored_doc):
    text = AUTHORED_DOC.read_text(encoding="utf-8")
    section = render(rows)
    if start in text:
        text = text[:text.index(start)] + section + text[text.index(end) + len(end):]
    else:
        text = text.rstrip("\n") + "\n\n" + section + "\n"
    AUTHORED_DOC.write_text(text, encoding="utf-8")


def stem_token(french, infinitive):
    """The first word of the French that starts with the verb's stem, for a sentence whose token is unknown."""
    stem = validator.normalize(infinitive)[:-2]
    for word in french.split():
        word = re.split(r"['’]", word.strip(".,;:!?«»\"“”'’"))[-1]
        if validator.normalize(word).startswith(stem):
            return word
    return None


def check_token(example, infinitive, identifier, log):
    if token_in(example):
        return
    token = stem_token(example["fr"], infinitive)
    if token:
        log["warnings"].append(f"{identifier}: token {example['token']!r} not in the French; used {token!r}")
        example["token"] = token
    elif token_in({**example, "token": infinitive}):
        log["warnings"].append(f"{identifier}: token {example['token']!r} not in the French; used the infinitive")
        example["token"] = infinitive
    else:
        log["warnings"].append(f"{identifier}: token {example['token']!r} not found in the French")


def stage5_accepted():
    """Stage 5's accepted verbs by kind ("gloss", "example"), which a Stage 4 run must leave alone."""
    path = validator.STAGE5 / "approvals.json"
    if not path.exists():
        return {"gloss": set(), "example": set()}
    approvals = lib.load_json(path)
    accepted = {"gloss": set(), "example": set()}
    for key, entry in approvals["items"].items():
        if effective(approvals, key, entry) == "accept":
            task, identifier = key.split("|", 1)
            accepted["gloss" if task == "gloss" else "example"].add(identifier)
    return accepted


def swapped_candidate(verb, proposed, value):
    """The pick a value.candidate names: the verb's candidate with those fields and the value's French."""
    wanted = value["candidate"]
    french = validator.squeeze(value.get("fr"))
    matches = [c for c in verb.get("candidates") or [] if all(c.get(k) == v for k, v in wanted.items())
               and (validator.normalize(c.get("text")) == validator.normalize(french)
                    or (len(french) > 20 and french in validator.squeeze(c.get("text"))))]
    if len(matches) != 1:
        return None, f"value.candidate {wanted} matches {len(matches)} candidates"
    candidate = matches[0]
    token = stem_token(french, verb["infinitive"]) or verb["infinitive"]
    return {"fr": french, "en": value.get("en") or proposed["en"], "kind": candidate["kind"],
            "source": candidate.get("source"), "line": candidate.get("line"), "token": token}, None


def main_stage5(options):
    validator.use_pass_dir(validator.STAGE5, example_only=True)
    log_path = validator.STAGE5 / "applied.json"
    approvals = lib.load_json(validator.STAGE5 / "approvals.json")
    latest_items, _ = build_report.latest_attempts(build_report.load_skeptic())
    latest = {(item["id"], item["task"] == "gloss"): item for item in latest_items}
    shard_verbs = {}
    for path in sorted(validator.SHARDS.glob("shard_*.json")):
        shard_verbs[int(path.stem.split("_")[1])] = {verb["id"]: verb for verb in lib.load_json(path)["verbs"]}
    live = {entry["id"]: entry for entry in lib.load_verbs()}
    examples = lib.load_examples()
    before = len(examples)
    english = lib.load_english()

    accepted = collections.defaultdict(dict)
    for key, entry in approvals["items"].items():
        if effective(approvals, key, entry) != "accept":
            continue
        task, identifier = key.split("|", 1)
        if task not in ("new_example", "pick", "gloss"):
            sys.exit(f"{key}: Stage 5 applies only new_example, pick and gloss items")
        if identifier not in live:
            sys.exit(f"{key}: {identifier} is not in verbs.xml")
        item = latest.get((identifier, task == "gloss"))
        if item is None or build_report.item_key(item) != key:
            sys.exit(f"{key}: not the verb's latest Stage 5 attempt")
        if item["skeptic"]["verdict"] not in ("upheld", "partly"):
            sys.exit(f"{key}: accepted, but the skeptic refuted it")
        accepted[task][identifier] = (entry, item)

    log = collections.defaultdict(list)
    attribute_changes = collections.defaultdict(dict)
    for identifier, (entry, item) in accepted["gloss"].items():
        value = curly(entry.get("value") or item["proposed"])
        if value != live[identifier]["gloss"]:
            attribute_changes[identifier]["tn"] = xml_escape(value)
            log["gloss"].append({"id": identifier, "rank": live[identifier]["rank"], "from": live[identifier]["gloss"],
                                 "to": value, "kind": item["skeptic"]["verdict"]})

    new_examples, authored_rows = {}, []
    for task in ("pick", "new_example"):
        for identifier, (entry, item) in accepted[task].items():
            if item.get("gloss_proposed") and identifier not in accepted["gloss"]:
                log["skipped"].append(f"{task}|{identifier}: written for a gloss that is not accepted")
                continue
            proposed = item["proposed"]
            if task == "new_example":
                example = authored_example(proposed, entry, straight(proposed["source"]))
                new_examples[identifier] = ("authored", example)
                authored_rows.append({"id": identifier, "rank": live[identifier]["rank"], **example})
                continue
            verb = shard_verbs[item["shard"]].get(identifier)
            if verb is None:
                sys.exit(f"pick|{identifier}: not in check shard {item['shard']}")
            value = entry.get("value") if isinstance(entry.get("value"), dict) else None
            chosen = dict(proposed)
            if value and value.get("candidate"):
                chosen, reason = swapped_candidate(verb, proposed, value)
                if chosen is None:
                    log["skipped"].append(f"pick|{identifier}: {reason}")
                    continue
            elif value:
                chosen.update({k: value[k] for k in ("fr", "en") if value.get(k)})
            example, reason = pick_example(identifier, verb, chosen, english)
            if example is None:
                log["skipped"].append(f"pick|{identifier}: {reason}")
                continue
            new_examples[identifier] = (chosen["kind"], example)

    previous = lib.load_json(log_path) if log_path.exists() else {}
    written_before = {row["id"] for row in previous.get("examples_added", [])}
    for identifier, (kind, example) in sorted(new_examples.items()):
        check_token(example, live[identifier]["infinitive"], identifier, log)
        current = examples.get(identifier)
        if current == example:
            continue
        if current is not None and identifier not in written_before:
            log["skipped"].append(f"{kind} {identifier}: the verb already has an example Stage 5 did not write")
            continue
        log["examples_added"].append({"id": identifier, "rank": live[identifier]["rank"], "kind": kind,
                                      "source": example["source"]})
        examples[identifier] = example

    lines = lib.VERBS_XML.read_text(encoding="utf-8").split("\n")
    for identifier, changes in attribute_changes.items():
        index = live[identifier]["line"] - 1
        lines[index] = rewrite_line(lines[index], changes)

    tally = collections.Counter(change["kind"] for change in log["examples_added"])
    print("accepted items: " + ", ".join(f"{task} {len(entries):,}" for task, entries in sorted(accepted.items())))
    print(f"glosses changed: {len(log['gloss']):,}")
    print(f"examples added: {len(log['examples_added']):,} (" +
          ", ".join(f"{kind} {count:,}" for kind, count in sorted(tally.items())) +
          f"); {len(examples):,} verbs with an example (was {before:,})")
    print(f"skipped: {len(log['skipped']):,}")
    for line in log["skipped"]:
        print(f"  {line}")
    print(f"warnings: {len(log['warnings']):,}")
    for line in log["warnings"]:
        print(f"  {line}")
    if options.dry_run:
        print("dry run: nothing written")
        return
    lib.VERBS_XML.write_text("\n".join(lines), encoding="utf-8")
    write_examples(examples)
    authored_rows.sort(key=lambda row: (row["rank"], row["id"]))
    update_authored_doc(authored_rows, STAGE5_DOC_START, STAGE5_DOC_END, stage5_authored_doc)
    if log["gloss"] or log["examples_added"]:
        lib.write_json(log_path, log)
    print(f"  wrote {lib.VERBS_XML.relative_to(lib.REPO)}, both literature_examples.json copies, "
          f"{AUTHORED_DOC.relative_to(lib.REPO)}")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--pass-dir", help="corpus/working/verb_pass/stage5 for Stage 5.6")
    options = parser.parse_args()
    if options.pass_dir:
        if (lib.REPO / options.pass_dir).resolve() != validator.STAGE5.resolve():
            sys.exit("--pass-dir supports only corpus/working/verb_pass/stage5")
        main_stage5(options)
        return

    later = stage5_accepted()
    approvals = lib.load_json(build_report.APPROVALS)
    stage2_verbs, records = build_report.load_stage2()
    items = {build_report.item_key(item): item for item in build_report.load_skeptic()}
    added = {entry["id"]: entry for entry in lib.load_json(build_report.ADDED)["items"]}
    live = {entry["id"]: entry for entry in lib.load_verbs()}
    examples = lib.load_examples()
    english = lib.load_english()

    accepted = collections.defaultdict(dict)
    for key, entry in approvals["items"].items():
        if effective(approvals, key, entry) == "accept":
            task, identifier = key.split("|", 1)
            if identifier not in live:
                sys.exit(f"{key}: {identifier} is not in verbs.xml")
            accepted[task][identifier] = entry

    log = collections.defaultdict(list)
    attribute_changes = collections.defaultdict(dict)

    for task in ("gloss", "gloss:added"):
        for identifier, entry in accepted[task].items():
            if identifier in later["gloss"]:
                log["superseded"].append(f"{task}|{identifier}")
                continue
            value = entry.get("value")
            if not value:
                value = (added[identifier]["proposed"] if task == "gloss:added"
                         else records[identifier]["gloss"].get("proposed"))
            if not value:
                log["skipped"].append(f"{task}|{identifier}: accepted, but no proposal and no value")
                continue
            value = curly(value)
            if value != live[identifier]["gloss"]:
                attribute_changes[identifier]["tn"] = xml_escape(value)
                log["gloss"].append({"id": identifier, "rank": live[identifier]["rank"], "from": live[identifier]["gloss"],
                                     "to": value, "kind": "added" if task == "gloss:added" or entry.get("verdict") == "added"
                                     else entry.get("verdict")})

    flag_targets = collections.defaultdict(dict)
    for task in [t for t in accepted if t.startswith("flag:")]:
        name = task.split(":", 1)[1]
        for identifier, entry in accepted[task].items():
            proposed = items[f"{task}|{identifier}"]["proposed"]
            if name == "dg":
                value = entry.get("value")
                if value is None:
                    log["skipped"].append(f"{task}|{identifier}: accepted without a group id")
                    continue
                proposed = None if str(value).strip().lower() in CLEAR_VALUES else str(value).strip()
            flag_targets[identifier][name] = proposed
    for identifier, targets in flag_targets.items():
        verb = live[identifier]
        reflexive = targets.get("re", verb["is_reflexive"])
        auxiliary = targets.get("ay", "être" if reflexive else verb["auxiliary"])
        if reflexive and auxiliary != "être":
            sys.exit(f"{identifier}: pronominal with avoir")
        changes = {"re": "t" if reflexive else None, "ay": "e" if auxiliary == "être" and not reflexive else None}
        if "ah" in targets:
            changes["ah"] = "t" if targets["ah"] else None
        if "dg" in targets:
            changes["dg"] = targets["dg"]
        before = {"re": verb["is_reflexive"], "ay": verb["auxiliary"], "ah": verb["aspirated_h"], "dg": verb["defect_group"]}
        after = {"re": reflexive, "ay": auxiliary, "ah": targets.get("ah", verb["aspirated_h"]),
                 "dg": targets.get("dg", verb["defect_group"])}
        if before != after:
            attribute_changes[identifier].update(changes)
            log["flags"].append({"id": identifier, "rank": verb["rank"],
                                 "changes": {k: [before[k], after[k]] for k in before if before[k] != after[k]}})

    new_examples, authored_rows = {}, []
    for identifier, entry in accepted["pick"].items():
        example, reason = pick_example(identifier, stage2_verbs[identifier], records[identifier]["new_example"], english)
        if example is None:
            log["skipped"].append(f"pick|{identifier}: {reason}")
            continue
        new_examples[identifier] = (records[identifier]["new_example"]["kind"], example)
    for identifier, entry in accepted["new_example"].items():
        example = authored_example(records[identifier]["new_example"], entry)
        new_examples[identifier] = ("authored", example)
        authored_rows.append({"id": identifier, "rank": live[identifier]["rank"], **example})

    for identifier, (kind, example) in sorted(new_examples.items()):
        if identifier in later["example"]:
            log["superseded"].append(f"{kind} {identifier}")
            continue
        check_token(example, live[identifier]["infinitive"], identifier, log)
        current = examples.get(identifier)
        shipped = stage2_verbs[identifier].get("example")
        if shipped is not None and identifier not in accepted["example"]:
            log["skipped"].append(f"{kind} {identifier}: replaces a shipped example whose card is not accepted")
            continue
        if current != example:
            log["examples_" + ("replaced" if shipped else "added")].append(
                {"id": identifier, "rank": live[identifier]["rank"], "kind": kind, "source": example["source"]})
            examples[identifier] = example

    for identifier, entry in accepted["example"].items():
        if identifier in later["example"]:
            log["superseded"].append(f"example|{identifier}")
            continue
        if identifier in new_examples and examples.get(identifier) == new_examples[identifier][1]:
            continue
        item = items[f"example|{identifier}"]
        current = examples.get(identifier)
        english_fix = entry.get("value") or (item["proposed"] or {}).get("proposed_en")
        if english_fix:
            if current is None:
                log["skipped"].append(f"example|{identifier}: English fix for an example that is gone")
            elif current["en"] != straight(english_fix):
                current["en"] = straight(english_fix)
                log["examples_translation"].append({"id": identifier, "rank": live[identifier]["rank"]})
        elif current is not None and current == item["current"]:
            del examples[identifier]
            log["examples_removed"].append({"id": identifier, "rank": live[identifier]["rank"]})

    lines = lib.VERBS_XML.read_text(encoding="utf-8").split("\n")
    for identifier, changes in attribute_changes.items():
        index = live[identifier]["line"] - 1
        lines[index] = rewrite_line(lines[index], changes)

    tally = collections.Counter()
    for change in log["gloss"]:
        tally[f"gloss ({change['kind']})"] += 1
    for change in log["examples_added"] + log["examples_replaced"]:
        tally[f"example {'added' if change in log['examples_added'] else 'replaced'} ({change['kind']})"] += 1
    print(f"accepted items: " + ", ".join(f"{task} {len(entries):,}" for task, entries in sorted(accepted.items())))
    print(f"glosses changed: {len(log['gloss']):,}  ·  verbs with flag changes: {len(log['flags']):,}")
    for label, count in sorted(tally.items()):
        print(f"  {label}: {count:,}")
    print(f"examples: {len(log['examples_added']):,} added, {len(log['examples_replaced']):,} replaced, "
          f"{len(log['examples_translation']):,} retranslated, {len(log['examples_removed']):,} removed; "
          f"{len(examples):,} verbs with an example (was {len(lib.load_examples()):,})")
    for change in log["flags"]:
        print(f"  flags {change['id']}: " + ", ".join(f"{k} {v[0]!r} → {v[1]!r}" for k, v in change["changes"].items()))
    print(f"skipped: {len(log['skipped']):,}")
    for line in log["skipped"]:
        print(f"  {line}")
    print(f"superseded by Stage 5: {len(log['superseded']):,}")
    print(f"warnings: {len(log['warnings']):,}")
    for line in log["warnings"]:
        print(f"  {line}")
    if options.dry_run:
        print("dry run: nothing written")
        return
    lib.VERBS_XML.write_text("\n".join(lines), encoding="utf-8")
    write_examples(examples)
    authored_rows.sort(key=lambda row: (row["rank"], row["id"]))
    update_authored_doc(authored_rows)
    if any(log[key] for key in log if key not in ("skipped", "warnings", "superseded")):
        lib.write_json(LOG, log)
    print(f"  wrote {lib.VERBS_XML.relative_to(lib.REPO)}, both literature_examples.json copies, "
          f"{AUTHORED_DOC.relative_to(lib.REPO)}")


if __name__ == "__main__":
    main()
