#!/usr/bin/env python3
"""Gather the Stage 2 proposals the skeptic re-examines into shards of 25 items.

Stage 3 of prompts/verb-pass-plan.md. The scope Josh chose on 2026-09-21:

    gloss         every gloss verdict other than `ok`
    example       every existing-example verdict other than `ok` or `none`
    new_example   every AUTHORED new example (corpus and quotation picks are checked in code
                  by validate_verb_pass.py and build_report.py, not by the skeptic)
    flag          every flag verdict `change`

Items are ordered by frequency rank, then by task in the order above, and cut into shards of
25 under corpus/working/verb_pass/skeptic/shards/. The skeptic may open nothing but its shard,
so each item carries the evidence that decides it: both Wiktionaries' senses, the current and
proposed values, the checker's evidence and notes, the Stage 1 audits, and for an authored
sentence the app's conjugation rows for its token plus the verb's whole candidate list.

The current gloss is read from the live verbs.xml, not from the Stage 2 shard, because Josh
edited some glosses by hand after Stage 2 ran; a gloss item whose proposal already equals the
live gloss is dropped.

Build ONCE. Rebuilding while verdict files exist would reshuffle items under them, so the
script refuses when the shard directory is non-empty unless given --force.

Usage:
    python3 corpus/working/build_skeptic_shards.py
    python3 corpus/working/build_skeptic_shards.py --dry-run     # counts only, writes nothing
"""
import argparse
import re
import sys

import verb_pass_lib as lib

STAGE2_SHARDS = lib.OUT_DIR / "shards"
STAGE2_RESULTS = lib.OUT_DIR / "results"
SKEPTIC_SHARDS = lib.OUT_DIR / "skeptic" / "shards"
SHARD_SIZE = 25
TASK_ORDER = ["gloss", "example", "new_example", "flag"]
ELISION = re.compile(r"^(?:[jmtslnd]|qu|jusqu|lorsqu|puisqu)['’]", re.IGNORECASE)
AGREEMENT_ENDINGS = ("", "e", "s", "es")


def token_words(token):
    words = []
    for word in lib.nfc(token or "").split():
        word = ELISION.sub("", word.strip(".,;:!?«»“”\"()")).lower()
        if word:
            words.append(word)
    return words


def conjugation_rows(verb_id, infinitive, token, conjugations):
    """The app's rows whose form is a word of the token, plus the passé composé for the auxiliary."""
    table = conjugations.get(verb_id) or {}
    words = set(token_words(token))
    rows = []
    if lib.plain(infinitive) in words:
        rows.append({"tense_key": "infinitif", "app": infinitive})
    for key, form in table.items():
        alternates = lib.alternates(form)
        if key == "participePassé":
            alternates = [a + ending for a in alternates for ending in AGREEMENT_ENDINGS]
        if words & set(alternates):
            rows.append({"tense_key": key, "app": form})
    if not rows:
        rows.append({"tense_key": None, "app": None,
                     "note": f"no app form of {verb_id} matches any word of the token {token!r}"})
    if "passéComposé.firstSingular" in table and not any(
            r["tense_key"] == "passéComposé.firstSingular" for r in rows):
        rows.append({"tense_key": "passéComposé.firstSingular",
                     "app": table["passéComposé.firstSingular"], "note": "shows the auxiliary"})
    return rows


def flag_values(verb, live):
    return {
        "re": live["is_reflexive"],
        "ay": live["auxiliary"],
        "dg": live["defect_group"],
        "ah": live["aspirated_h"],
    }


def proposed_flag(flag, current):
    if flag in ("re", "ah"):
        return not current
    if flag == "ay":
        return "avoir" if current == "être" else "être"
    return "change the defect group (see evidence)" if current else "add a defect group (see evidence)"


def build_items(verb, record, live, conjugations, defect_groups):
    base = {
        "id": verb["id"],
        "infinitive": verb["infinitive"],
        "rank": verb["rank"],
        "gloss_current": live["gloss"],
        "gloss_provenance": verb.get("gloss_provenance"),
        "wiktionary_en": verb.get("wiktionary_en"),
        "wiktionnaire": verb.get("wiktionnaire"),
        "audits": verb.get("audits"),
        "checker_notes": record.get("notes") or [],
    }
    items = []
    gloss = record["gloss"]
    if gloss["verdict"] != "ok" and (gloss.get("proposed") or None) != live["gloss"]:
        items.append({**base, "task": "gloss",
                      "current": live["gloss"],
                      "proposed": gloss.get("proposed"),
                      "checker_verdict": gloss["verdict"],
                      "checker_confidence": gloss.get("confidence"),
                      "evidence": gloss.get("evidence")})
    example = record["example"]
    if example["verdict"] not in ("ok", "none"):
        items.append({**base, "task": "example",
                      "current": verb.get("example"),
                      "proposed": {"proposed_en": example.get("proposed_en"),
                                   "replacement": record.get("new_example")},
                      "checker_verdict": example["verdict"],
                      "evidence": example.get("issues")})
    new_example = record.get("new_example")
    if new_example and new_example.get("kind") == "authored":
        items.append({**base, "task": "new_example",
                      "current": verb.get("example"),
                      "proposed": new_example,
                      "gloss_proposed": gloss.get("proposed") if gloss["verdict"] != "ok" else None,
                      "evidence": None,
                      "candidates": verb.get("candidates") or [],
                      "conjugations": conjugation_rows(verb["id"], verb["infinitive"],
                                                       new_example.get("token"), conjugations)})
    for flag in record.get("flags") or []:
        if flag.get("verdict") != "change":
            continue
        name = flag.get("flag")
        current = flag_values(verb, live).get(name)
        item = {**base, "task": "flag",
                "flag": name,
                "current": current,
                "proposed": proposed_flag(name, current),
                "evidence": flag.get("reason"),
                "audit": [a for a in verb["audits"].get("flags") or [] if a.get("flag") == name]}
        if name == "dg":
            item["defect_group_description"] = (defect_groups.get(current) or (None, None))[1]
        items.append(item)
    return items


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--force", action="store_true")
    options = parser.parse_args()
    existing = list(SKEPTIC_SHARDS.glob("shard_*.json")) if SKEPTIC_SHARDS.exists() else []
    if existing and not (options.dry_run or options.force):
        print(f"{len(existing)} skeptic shards already exist under "
              f"{SKEPTIC_SHARDS.relative_to(lib.REPO)}; not rebuilding (use --force).")
        return

    live = {entry["id"]: entry for entry in lib.load_verbs()}
    conjugations = lib.load_conjugations()
    defect_groups = lib.load_defect_groups()
    items = []
    for path in sorted(STAGE2_SHARDS.glob("shard_*.json")):
        shard = lib.load_json(path)
        results = lib.load_json(STAGE2_RESULTS / path.name)["results"]
        if [r["id"] for r in results] != [v["id"] for v in shard["verbs"]]:
            sys.exit(f"{path.name}: result file does not match its shard; run validate_verb_pass.py")
        for verb, record in zip(shard["verbs"], results):
            items += build_items(verb, record, live[verb["id"]], conjugations, defect_groups)
    items.sort(key=lambda item: (item["rank"], item["id"], TASK_ORDER.index(item["task"])))

    tally = {task: sum(1 for i in items if i["task"] == task) for task in TASK_ORDER}
    shards = [items[i:i + SHARD_SIZE] for i in range(0, len(items), SHARD_SIZE)]
    print(f"{len(items)} items in {len(shards)} shards of {SHARD_SIZE}: " +
          ", ".join(f"{task} {count}" for task, count in tally.items()))
    unmatched = sum(1 for i in items if i["task"] == "new_example"
                    and i["conjugations"][0].get("tense_key") is None)
    print(f"authored sentences whose token matches no app form: {unmatched}")
    if options.dry_run:
        return
    for number, chunk in enumerate(shards, start=1):
        lib.write_json(SKEPTIC_SHARDS / f"shard_{number:03d}.json", {"shard": number, "items": chunk})


if __name__ == "__main__":
    main()
