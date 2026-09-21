#!/usr/bin/env python3
"""Stage 1.5 — gather example candidates for every verb the pass may need one for.

Targets: the verbs with no example at all, plus the 84 whose example is Claude-authored (a real
quotation could replace those). Up to twelve candidates each, in this order of preference:

  1. tier          the app's own open corpus (literature, classical, government, technology,
                   wikipedia; `chanson-roland-oxford.txt` excluded, as the modern indexers do).
                   One pass per document, tokens looked up in the forms of conjugations.json,
                   the whole sentence recovered around the hit, ranked by how unambiguously
                   verbal the token is (`build_tail_index.verbalness`). At most five, spread
                   across tiers so one document cannot fill the slate. The sentence is
                   cleaned of the source's apparatus (`clean_tier_sentence`), and one that
                   is itself a Gutenberg footnote is dropped.
  2. wiktionnaire  French-Wiktionary quotations whose reference names an author who died before
                   1931 in authors.json, whose text is one complete sentence with no elision
                   ([…]) and no editorial parenthesis. At most five.
  3. wiktionary_en English-Wiktionary examples that already carry an English translation. At
                   most two.

Writes `corpus/working/verb_pass/candidates.json`:
`{ "<verb id>": [ { kind, source, line, token, text, english?, author?, title?, year? } ] }`.
A verb with no candidate gets `[]` and is counted.

Usage:  python3 corpus/working/build_candidates.py
"""
import collections
import re

import verb_pass_lib as L
from build_author_table import author_of
from build_corpus_index import TOKEN_RE, gutenberg_bounds, nfc, ordered_docs
from build_tail_index import verbalness

MAX_TIER = 5
MAX_WIKTIONNAIRE = 5
MAX_ENGLISH = 2
MAX_SENTENCE = 350
# Enough lines either way to hold any sentence under MAX_SENTENCE in a hard-wrapped
# Gutenberg text (about 70 characters a line). A sentence that reaches the edge of this window
# without meeting a blank line is longer than that, so it is dropped rather than cut.
CONTEXT_LINES = 8
SENTENCE_END = ".!?…"
AUTHORED_PREFIX = "Claude"
ELIDED = re.compile(r"\[[^\]]*\]|\(\s*…\s*\)|…\s*\]")
YEAR = re.compile(r"\b(1[0-9]{3}|20[0-9]{2})\b")
WIKI_HEADING = re.compile(r"={2,}[^=]*={2,}\s*|^[^=]*={2,}\s*|\s*={2,}[^=]*$")
BRACKET_NOTE = re.compile(r"\s?\[\d{1,4}\]")
FOOTNOTE_BODY = re.compile(r"^\[\d{1,4}\]")
# A report's footnote call fused to a year: "depuis début 202014." The year range is kept
# narrow on purpose, since a longer number starting 19xx is usually real (a patent number).
YEAR_NOTE = re.compile(r"\b(20[12][0-9])[0-9]{1,3}\b")
# A footnote call fused to a word: "à travers les Alpes37,". Four letters at least, so that
# units and formulas (m3, dm3, km2, CO2) keep their digits.
WORD_NOTE = re.compile(r"(?<=[a-zàâäçéèêëîïôöùûüœæ]{4})[0-9]{1,3}(?=[\s.,;:!?»)]|$)")
LEADING_STRAY = re.compile(r"^(?:[)\]»;,:]\s*)+")


def target_ids(verbs, examples):
    """Verb ids with no example, or with a Claude-authored one.

    `ExampleData.example(for:)` falls back from the id to the bare infinitif, so an entry is
    covered when either spelling is a key.
    """
    authored = {key for key, value in examples.items()
                if (value.get("source") or "").startswith(AUTHORED_PREFIX)}
    targets = []
    for entry in verbs:
        keys = {entry["id"], entry["infinitive"]}
        if not (keys & set(examples)) or (keys & authored):
            targets.append(entry["id"])
    return targets


def form_index(targets, conjugations):
    """{surface form: [verb id]} over the target verbs only."""
    index = collections.defaultdict(list)
    for verb_id in targets:
        forms = set()
        for key, value in conjugations[verb_id].items():
            if key.startswith("passéComposé"):
                continue  # two words, and its participle is already in the table
            forms.update(L.alternates(value))
        forms.add(verb_id.split(" (")[0].lower())
        for form in forms:
            if len(form) > 2:  # a one- or two-letter form collides with everything
                index[form].append(verb_id)
    return index


def clean_tier_sentence(sentence):
    """Strip wiki headings, footnote calls and stray leading punctuation; None for a footnote.

    The corpus files keep Wikipedia section headings inline (`=== Pays === Le Pakistan…`),
    Gutenberg footnote calls in brackets (`prétend[333]`), and report footnote calls fused to
    the preceding word or year. A checker handed those cleaned them up itself while keeping
    the citation, which the provenance rule forbids, so they are removed here instead. The
    cleaned text is the source sentence minus its apparatus, never a reworded one.
    """
    if FOOTNOTE_BODY.match(sentence):
        return None
    sentence = WIKI_HEADING.sub(" ", sentence)
    sentence = BRACKET_NOTE.sub("", sentence)
    sentence = YEAR_NOTE.sub(r"\1", sentence)
    sentence = WORD_NOTE.sub("", sentence)
    sentence = LEADING_STRAY.sub("", " ".join(sentence.split()))
    return sentence


def sentence_around(lines, line_number, token):
    """The sentence holding `token` on `lines[line_number]`, within its paragraph.

    The block runs out to a blank line, or CONTEXT_LINES away, whichever is nearer. A sentence
    whose start or end is only the edge of that window, not a blank line or the file's edge, is
    cut off mid-sentence: an earlier version kept those, and a checker handed one completed it.
    """
    low = line_number
    while low > 0 and line_number - low < CONTEXT_LINES and lines[low - 1].strip():
        low -= 1
    high = line_number + 1
    while high < len(lines) and high - line_number <= CONTEXT_LINES and lines[high].strip():
        high += 1
    open_start = low > 0 and bool(lines[low - 1].strip())
    open_end = high < len(lines) and bool(lines[high].strip())
    offsets, block = [], ""
    for index in range(low, high):
        offsets.append((index, len(block)))
        block += lines[index].strip() + " "
    start_of_line = dict(offsets)[line_number]
    position = block.lower().find(token, start_of_line)
    if position < 0:
        position = block.lower().find(token)
    if position < 0:
        return None

    start = None
    for index in range(position - 1, -1, -1):
        if block[index] in SENTENCE_END:
            start = index + 1
            break
    if start is None:
        if open_start:
            return None
        start = 0
    end = None
    for index in range(position + len(token), len(block)):
        if block[index] in SENTENCE_END:
            end = index + 1
            break
    if end is None:
        if open_end:
            return None
        end = len(block)
    sentence = clean_tier_sentence(" ".join(block[start:end].split()))
    if not sentence or token not in sentence.lower():
        return None
    if len(sentence) > MAX_SENTENCE or len(sentence) < 20:
        return None
    return sentence


def tier_candidates(targets, conjugations):
    """{verb id: [candidate]} from one pass over each corpus document."""
    index = form_index(targets, conjugations)
    found = collections.defaultdict(lambda: collections.defaultdict(list))
    for tier, _author, relative, absolute in ordered_docs():
        low, high = gutenberg_bounds(absolute)
        with open(absolute, encoding="utf-8", errors="replace") as handle:
            lines = [nfc(line) for line in handle]
        name = relative.rsplit("/", 1)[-1]
        for number, line in enumerate(lines, start=1):
            if not (low < number < high):
                continue
            for match in TOKEN_RE.finditer(line.lower()):
                token = match.group(0)
                for verb_id in index.get(token, ()):
                    if len(found[verb_id][tier]) >= MAX_TIER:
                        continue
                    sentence = sentence_around(lines, number - 1, token)
                    if not sentence:
                        continue
                    found[verb_id][tier].append({
                        "kind": "tier", "source": name, "line": number, "token": token,
                        "text": sentence,
                        "_rank": verbalness(token, verb_id.split(" (")[0]),
                    })

    candidates = {}
    for verb_id, by_tier in found.items():
        merged = []
        queues = [sorted(items, key=lambda item: -item["_rank"]) for items in by_tier.values()]
        while len(merged) < MAX_TIER and any(queues):
            for queue in queues:
                if queue and len(merged) < MAX_TIER:
                    merged.append(queue.pop(0))
        merged.sort(key=lambda item: -item["_rank"])
        for item in merged:
            del item["_rank"]
        candidates[verb_id] = merged
    return candidates


def quotation_candidates(verb, french, authors):
    """Public-domain French-Wiktionary quotations, complete sentences only."""
    out = []
    for entry in french.get(verb, []):
        for sense in entry.get("senses", []):
            for example in sense.get("examples", []):
                text = L.nfc((example.get("text") or "").strip())
                reference = (example.get("ref") or "").strip()
                if not text or not reference or ELIDED.search(text):
                    continue
                if not text[-1:] in SENTENCE_END or len(text) > MAX_SENTENCE:
                    continue
                name = author_of(reference)
                if not name or not L.is_public_domain(authors.get(name)):
                    continue
                fields = [field.strip() for field in reference.split(",")]
                years = YEAR.findall(reference)
                out.append({
                    "kind": "wiktionnaire", "source": "fr.wiktionary.org", "line": None,
                    "token": None, "text": text,
                    "author": name,
                    "title": fields[1] if len(fields) > 1 else None,
                    "year": years[-1] if years else None,
                    "reference": reference,
                    "death_year": authors.get(name, {}).get("death_year"),
                })
                if len(out) >= MAX_WIKTIONNAIRE:
                    return out
    return out


def english_candidates(verb, english):
    out = []
    for entry in english.get(verb, []):
        for sense in entry.get("senses", []):
            for example in sense.get("examples", []):
                text = L.nfc((example.get("text") or "").strip())
                translation = (example.get("english") or "").strip()
                if not text or not translation:
                    continue
                out.append({
                    "kind": "wiktionary_en", "source": "en.wiktionary.org", "line": None,
                    "token": None, "text": text, "english": translation,
                })
                if len(out) >= MAX_ENGLISH:
                    return out
    return out


def main():
    verbs = L.load_verbs()
    conjugations = L.load_conjugations()
    examples = L.load_examples()
    english = L.load_english()
    french = L.load_french()
    authors = L.load_authors()

    targets = target_ids(verbs, examples)
    print(f"  {len(targets):,} verb entries need a candidate list")
    tiers = tier_candidates(targets, conjugations)
    print(f"  tier pass done: {len(tiers):,} verbs have at least one corpus hit")

    candidates = {}
    counts = collections.Counter()
    for entry in verbs:
        if entry["id"] not in set(targets):
            continue
        found = list(tiers.get(entry["id"], []))
        found += quotation_candidates(entry["infinitive"], french, authors)
        found += english_candidates(entry["infinitive"], english)
        candidates[entry["id"]] = found
        for item in found:
            counts[item["kind"]] += 1
        if not found:
            counts["_none"] += 1

    L.write_json(L.OUT_DIR / "candidates.json", candidates)
    print(f"  candidates by kind: "
          + ", ".join(f"{kind} {count:,}" for kind, count in counts.most_common()
                      if not kind.startswith("_")))
    print(f"  verbs with no candidate at all: {counts['_none']:,}")
    with_quotation = sum(1 for items in candidates.values()
                         if any(item["kind"] == "wiktionnaire" for item in items))
    print(f"  verbs with a public-domain quotation: {with_quotation:,}")
    sizes = collections.Counter(len(items) for items in candidates.values())
    print("  candidate-count distribution: "
          + ", ".join(f"{size}:{count}" for size, count in sorted(sizes.items())))


if __name__ == "__main__":
    main()
