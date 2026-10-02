#!/usr/bin/env python3
"""Stage 1.6 — assemble the shard files that are Stage 2's contract.

Every verb entry, ordered by frequency rank, cut into shards of 35 under
`corpus/working/verb_pass/shards/shard_NNN.json`. Each shard carries everything a checking
agent needs inline, so the agent runs in a single turn with no tools:

    { "shard": 12, "verbs": [ { id, infinitive, extraLetters, rank, gloss, model,
                                flags, example, wiktionary_en, wiktionnaire, candidates,
                                audits, gloss_provenance, author_needed } ] }

`wiktionnaire` senses keep their tags and drop their examples, which arrive as candidates.
`author_needed` is true when the verb needs an example and no candidate was found for it, so
the agent will have to write one.

`--only verbs.json --out <dir>` (both relative to the repository root) shards only the entries a list names, each carrying a `prior`
field from the list: Stage 5, which takes the verbs still without an example through the pass
again. The gloss is the live one in verbs.xml, as it is for every run, and the candidates are
whatever candidates.json holds now.

`--pilot` writes three shards under `verb_pass/pilot/` with the canaries the plan's pilot
section lists, plus `pilot_answer_key.json` recording what each canary's right answer is.

Usage:  python3 corpus/working/build_verb_pass_shards.py [--pilot]
        python3 corpus/working/build_verb_pass_shards.py --only corpus/working/verb_pass/stage5/verbs.json \
            --out corpus/working/verb_pass/stage5/shards
        python3 corpus/working/build_verb_pass_shards.py --only corpus/working/verb_pass/stage5/retry.json \
            --out corpus/working/verb_pass/stage5/shards --append
"""
import argparse
import collections
import json
import re
import shutil

import verb_pass_lib as L
from build_tail_index import verbalness

SHARD_SIZE = 35
MAX_EXAMPLES_PER_SENSE = 3
AUTHORED_PREFIX = "Claude"


def english_senses(entries):
    senses = []
    for entry in entries or []:
        for sense in entry.get("senses", []):
            examples = [
                {"text": example.get("text"), "english": example.get("english")}
                for example in sense.get("examples", [])[:MAX_EXAMPLES_PER_SENSE]
                if example.get("text")
            ]
            senses.append({
                "glosses": sense.get("glosses") or [],
                "tags": sense.get("tags") or [],
                "examples": examples,
            })
    return senses


def french_senses(entries):
    return [
        {"glosses": sense.get("glosses") or [], "tags": sense.get("tags") or []}
        for entry in entries or []
        for sense in entry.get("senses", [])
    ]


def build_records():
    verbs = L.load_verbs()
    english = L.load_english()
    french = L.load_french()
    examples = L.load_examples()
    lint = L.load_json(L.OUT_DIR / "gloss_lint.json")
    flags = L.load_json(L.OUT_DIR / "audit_flags.json")
    integrity = L.load_json(L.OUT_DIR / "example_integrity.json")
    candidates = L.load_json(L.OUT_DIR / "candidates.json")
    conjugation_rows = collections.defaultdict(list)
    with open(L.OUT_DIR / "audit_conjugations.jsonl", encoding="utf-8") as handle:
        for line in handle:
            row = json.loads(line)
            conjugation_rows[row["verb"]].append(
                {key: row[key] for key in ("tense_key", "app", "wiktionary", "kind")})

    records = []
    for entry in sorted(verbs, key=lambda item: (item["rank"], item["id"])):
        # `ExampleData.example(for:)` falls back from the id to the bare infinitif.
        example = examples.get(entry["id"]) or examples.get(entry["infinitive"])
        example_key = entry["id"] if entry["id"] in examples else entry["infinitive"]
        lint_record = lint.get(entry["id"], {})
        record = {
            "id": entry["id"],
            "infinitive": entry["infinitive"],
            "extraLetters": entry["extra_letters"],
            "rank": entry["rank"],
            "gloss": entry["gloss"],
            "model": entry["model"],
            "flags": {
                "re": entry["is_reflexive"],
                "ay": entry["auxiliary"],
                "dg": entry["defect_group"],
                "ah": entry["aspirated_h"],
            },
            "example": example,
            "wiktionary_en": english_senses(english.get(entry["infinitive"])),
            "wiktionnaire": french_senses(french.get(entry["infinitive"])),
            "candidates": candidates.get(entry["id"], []),
            "audits": {
                "gloss_lint": lint_record.get("lint", []),
                "flags": flags.get(entry["id"], []),
                "example_integrity": (integrity.get(example_key) or {}).get("failures", []),
                "conjugations": conjugation_rows.get(entry["id"], []),
            },
            "gloss_provenance": lint_record.get("gloss_provenance"),
            "author_needed": example is None and not candidates.get(entry["id"]),
        }
        records.append(record)
    return records


def write_shards(records, directory, size=SHARD_SIZE, append=False):
    first = 1
    if append and directory.exists():
        first += max((int(path.stem.split("_")[1]) for path in directory.glob("shard_*.json")), default=0)
    elif directory.exists():
        shutil.rmtree(directory)
    directory.mkdir(parents=True, exist_ok=True)
    written = []
    for number, start in enumerate(range(0, len(records), size), start=first):
        payload = {"shard": number, "verbs": records[start:start + size]}
        path = directory / f"shard_{number:03d}.json"
        with open(path, "w", encoding="utf-8") as out:
            json.dump(payload, out, ensure_ascii=False, indent=1)
        written.append(path)
    return written


# --- pilot ---------------------------------------------------------------------------------
# Five glosses broken in two ways the checker must tell apart: three swapped with another verb's
# (a wrong sense), two misspelled (a typo). Chosen across the frequency range, and all five are
# verbs whose gloss the real data has right.
GLOSS_SWAPS = {
    "manger": ("drink", "wrong_sense"),
    "écrire": ("read", "wrong_sense"),
    "dormir": ("run", "wrong_sense"),
    "acheter": ("puchase", "typo"),
    "chanter": ("sng", "typo"),
}
BROKEN_EXAMPLES = ["envisager", "représenter"]
HOMOGRAPH_TARGETS = 3
POST_1930_QUOTATIONS = 2


def homograph_candidates(records, wanted=HOMOGRAPH_TARGETS):
    """Verbs whose candidate list can be cut down to same-spelled nouns only.

    `verbalness` scores the colliding present-stem form 0 and every unmistakably verbal form
    higher, so a list filtered to score-0 candidates is exactly the trap: a plausible-looking
    sentence in which the word is a noun, never a verb. Only verbs that actually need an example
    qualify, since selecting one is the task the canary tests.
    """
    chosen = {}
    for record in records:
        if len(chosen) >= wanted:
            break
        if record["example"] is not None:
            continue
        nouns = [candidate for candidate in record["candidates"]
                 if candidate["kind"] == "tier"
                 and verbalness(candidate["token"], record["infinitive"]) == 0]
        if len(nouns) >= 2:
            chosen[record["id"]] = nouns
    return chosen


def post_1930_quotations(records, french, authors, wanted=POST_1930_QUOTATIONS):
    """Quotations by an author who died after 1930, attached to verbs that need an example."""
    from build_author_table import author_of
    picked, seen_authors = {}, set()
    for record in records:
        if len(picked) >= wanted:
            break
        if record["example"] is not None or record["id"] in picked:
            continue
        for entry in french.get(record["infinitive"], []):
            for sense in entry.get("senses", []):
                for example in sense.get("examples", []):
                    reference = (example.get("ref") or "").strip()
                    text = L.nfc((example.get("text") or "").strip())
                    name = author_of(reference) if reference else None
                    year = (authors.get(name or "") or {}).get("death_year")
                    if not text or not year or year < L.PUBLIC_DOMAIN_BEFORE:
                        continue
                    if len(text) > 300 or text[-1:] not in ".!?…" or name in seen_authors:
                        continue
                    seen_authors.add(name)
                    picked[record["id"]] = {
                        "kind": "wiktionnaire", "source": "fr.wiktionary.org", "line": None,
                        "token": None, "text": text, "author": name,
                        "title": reference.split(",")[1].strip() if "," in reference else None,
                        "year": (re.findall(r"\b(1[0-9]{3}|20[0-9]{2})\b", reference)
                                 or [None])[-1],
                        "reference": reference, "death_year": year,
                    }
                    break
                if record["id"] in picked:
                    break
            if record["id"] in picked:
                break
    return picked


# Three bands so the pilot exercises the whole file: the commonest verbs (which have examples and
# full Wiktionary entries), the middle (thinner entries, usually no example), and the tail (often
# no English entry at all). One shard each.
PILOT_BANDS = ((0, 35), (2000, 2035), (5000, 5035))


def build_pilot(records):
    french = L.load_french()
    authors = L.load_authors()
    by_id = {record["id"]: record for record in records}

    bands = [records[low:high] for low, high in PILOT_BANDS]
    forced = [by_id[verb] for verb in list(GLOSS_SWAPS) + BROKEN_EXAMPLES if verb in by_id]
    selection = list(forced)
    room = 3 * SHARD_SIZE - len(forced)
    per_band, remainder = divmod(room, len(bands))
    for position, band in enumerate(bands):
        taken = [record for record in band
                 if record["id"] not in {item["id"] for item in selection}]
        selection += taken[:per_band + (1 if position < remainder else 0)]
    selection = json.loads(json.dumps(selection))  # deep copy: the canaries mutate their records
    selection.sort(key=lambda record: record["rank"])
    index = {record["id"]: record for record in selection}

    answer_key = {}
    for verb, (gloss, verdict) in GLOSS_SWAPS.items():
        if verb not in index:
            continue
        answer_key[verb] = {"task": "gloss", "expected_verdict": verdict,
                            "planted": gloss, "real": by_id[verb]["gloss"]}
        index[verb]["gloss"] = gloss
        index[verb]["audits"]["gloss_lint"] = []
        index[verb]["gloss_provenance"] = {"class": "none_verbatim",
                                           "first_sense_is_en_first": False,
                                           "only_tagged_senses": False}
    for verb in BROKEN_EXAMPLES:
        if verb in index:
            answer_key[verb] = {"task": "example", "expected_verdict": "verb_absent",
                                "detail": "the sentence contains no form of the verb"}
    for verb, nouns in homograph_candidates(selection).items():
        # `author_needed` stays false: the record must look exactly like a verb whose list came
        # back full, or the canary announces itself and the checker never has to read the list.
        index[verb]["candidates"] = nouns
        answer_key[verb] = {"task": "example_selection", "expected_verdict": "reject_all",
                            "detail": "every candidate uses the same-spelled noun, not the verb",
                            "planted_tokens": sorted({noun["token"] for noun in nouns})}
    for verb, candidate in post_1930_quotations(selection, french, authors).items():
        if verb in answer_key:
            continue
        index[verb]["candidates"] = [candidate] + index[verb]["candidates"]
        answer_key[verb] = {"task": "example_selection", "expected_verdict": "reject_quotation",
                            "detail": f"{candidate['author']} died in {candidate['death_year']}, "
                                      f"so the quotation is not public domain",
                            "planted_text": candidate["text"],
                            "planted_author": candidate["author"],
                            "planted_death_year": candidate["death_year"]}

    directory = L.OUT_DIR / "pilot"
    written = write_shards(selection, directory)
    L.write_json(directory / "pilot_answer_key.json", answer_key)
    print(f"  pilot: {len(written)} shards, {len(selection)} verbs, {len(answer_key)} canaries "
          f"(ranks {selection[0]['rank']}–{selection[-1]['rank']})")
    for verb, record in sorted(answer_key.items(), key=lambda item: index[item[0]]["rank"]):
        print(f"    rank {index[verb]['rank']:>5}  {verb}: "
              f"{record['task']} → {record['expected_verdict']}")


def only(records, path):
    """The records `path` lists (list_missing_examples.py's verbs.json), each carrying its `prior`."""
    wanted = {row["id"]: row for row in L.load_json(path)}
    kept = []
    for record in records:
        row = wanted.get(record["id"])
        if row is not None:
            extra = {"cnrtl": row["cnrtl"]} if "cnrtl" in row else {}
            kept.append({**record, "prior": {"reason": row["reason"], **row["prior"]}, **extra})
    missing = set(wanted) - {record["id"] for record in kept}
    if missing:
        raise SystemExit(f"--only names verbs the app does not have: {sorted(missing)[:5]}")
    return kept


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--pilot", action="store_true", help="also write the three pilot shards")
    parser.add_argument("--only", help="a verbs.json from list_missing_examples.py: shard only these")
    parser.add_argument("--out", help="the shard directory (default verb_pass/shards)")
    parser.add_argument("--append", action="store_true",
                        help="number the new shards after the directory's last one and keep the rest "
                             "(Stage 5b: retry.json as one more Stage 5 shard)")
    arguments = parser.parse_args()

    records = build_records()
    if arguments.only:
        records = only(records, L.REPO / arguments.only)
    directory = L.REPO / arguments.out if arguments.out else L.OUT_DIR / "shards"
    if directory.resolve() == (L.OUT_DIR / "shards").resolve() and arguments.only:
        raise SystemExit("--only would overwrite the Stage 2 shards; pass --out")
    written = write_shards(records, directory, append=arguments.append)
    sizes = [path.stat().st_size for path in written]
    print(f"  {len(written)} shards of {SHARD_SIZE}, {len(records):,} verb entries")
    print(f"  shard size: {min(sizes):,} – {max(sizes):,} bytes, "
          f"{sum(sizes) // len(sizes):,} average, {sum(sizes):,} total")
    print(f"  verbs needing an authored example: "
          f"{sum(1 for record in records if record['author_needed']):,}")
    with_audit = sum(1 for record in records if any(record["audits"].values()))
    print(f"  verbs carrying at least one audit finding: {with_audit:,}")

    if arguments.pilot:
        build_pilot(records)


if __name__ == "__main__":
    main()
