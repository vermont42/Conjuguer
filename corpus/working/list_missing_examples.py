#!/usr/bin/env python3
"""Stage 5.2 — list the verb entries that still have no example, and why.

An entry is covered when its id or its bare infinitive is a key of literature_examples.json,
the fallback `ExampleData.example(for:)` uses. For each entry that is not, the record names the
reason its Stage 2–4 attempt failed and carries that attempt, so a Stage 5 checker does not
propose the same thing again:

    removed          Stage 4 dropped the flawed shipped example (the card's issues and note)
    en_quotation     the pick was an English-Wiktionary quotation under copyright, which
                     apply_verb_pass.py skipped (the sentence and its ref)
    pick_rejected    Josh rejected the pick, or left it for a check (the sentence and the note)
    pick_provenance  the pick carried a provenance warning, so it never reached approvals.json
                     (the sentence, its status and the detail)
    authored_refuted the skeptic refuted the authored sentence (the sentence and the reason)
    authored_rejected Josh rejected an authored sentence the skeptic let stand
    none_proposed    the Stage 2 checker returned no new_example (its notes)
    other            none of the above; listed so that nothing is hidden

Writes `corpus/working/verb_pass/stage5/verbs.json`, a list in rank order:
`[ { id, infinitive, rank, gloss, reason, prior } ]`, and prints the counts by reason and band.

`--retry id,id,…` (Stage 5b) writes verb_pass/stage5/retry.json instead: the named verbs, whose Stage 5
proposal the skeptic refuted, with that proposal and the skeptic's reason as their `prior`
(reason `stage5_refuted`, the original reason kept as `first_reason`, and any refuted attempt
before that as `earlier_attempts`, and a Stage 5c gloss proposal with the skeptic's verdict on it as
`gloss_attempt`). Stage 5c adds `--evidence`, which attaches each verb's CNRTL
dictionary text from fetch_cnrtl.py as `cnrtl`, and `--out retry_5c.json`.

Usage:  python3 corpus/working/list_missing_examples.py
        python3 corpus/working/list_missing_examples.py --retry acculer,transir,tonner
        python3 corpus/working/list_missing_examples.py --retry baiser --replace --evidence --hint "…" --out retry_baiser.json
"""
import collections
import json

import validate_verb_pass as validator
import verb_pass_lib as lib

STAGE5 = lib.OUT_DIR / "stage5"
CNRTL = STAGE5 / "cnrtl.json"
REASONS = ["removed", "en_quotation", "pick_rejected", "pick_provenance", "authored_refuted",
           "authored_rejected", "none_proposed", "other"]
BANDS = [(1, 1500), (1501, 3000), (3001, None)]


def stage2():
    """{verb id: (shard record, result record)}."""
    joined = {}
    for path in sorted(validator.SHARDS.glob("shard_*.json")):
        shard = lib.load_json(path)
        results = lib.load_json(validator.RESULTS / path.name)["results"]
        for verb, record in zip(shard["verbs"], results):
            joined[verb["id"]] = (verb, record)
    return joined


def skeptic():
    """{(verb id, task): verdict record}."""
    verdicts = {}
    for path in sorted(validator.SKEPTIC_SHARDS.glob("shard_*.json")):
        items = lib.load_json(path)["items"]
        results = lib.load_json(validator.SKEPTIC_RESULTS / path.name)["results"]
        for item, result in zip(items, results):
            verdicts[(item["id"], item["task"])] = result
    return verdicts


def sentence(new_example):
    return {key: new_example.get(key) for key in ("fr", "en", "token", "kind", "source", "line")}


def classify(identifier, verb, record, verdicts, approvals, applied):
    new_example = record.get("new_example") if record else None
    removed = {row["id"] for row in applied.get("examples_removed", [])}
    skipped = {line.split(":", 1)[0]: line.split(": ", 1)[1] for line in applied.get("skipped", [])}

    if identifier in removed:
        card = verdicts.get((identifier, "example")) or {}
        return "removed", {
            "removed_example": verb.get("example"),
            "checker_verdict": (record or {}).get("example", {}).get("verdict"),
            "checker_issues": (record or {}).get("example", {}).get("issues"),
            "skeptic_reason": card.get("reason"),
            "note": approvals.get(f"example|{identifier}", {}).get("note"),
        }
    if f"pick|{identifier}" in skipped:
        return "en_quotation", {**sentence(new_example), "why": skipped[f"pick|{identifier}"]}
    pick = approvals.get(f"pick|{identifier}")
    if pick and pick["decision"] in ("reject", "review"):
        return "pick_rejected", {**sentence(new_example), "decision": pick["decision"],
                                 "note": pick.get("note")}
    if new_example and new_example.get("kind") != "authored":
        status, detail, _ = validator.pick_status(new_example, verb)
        if pick is None:
            return "pick_provenance", {**sentence(new_example), "status": status, "detail": detail}
    if new_example and new_example.get("kind") == "authored":
        verdict = verdicts.get((identifier, "new_example")) or {}
        if verdict.get("verdict") == "refuted":
            return "authored_refuted", {**sentence(new_example), "skeptic_reason": verdict.get("reason")}
        entry = approvals.get(f"new_example|{identifier}")
        if entry and entry["decision"] == "reject":
            return "authored_rejected", {**sentence(new_example), "skeptic_reason": verdict.get("reason"),
                                         "note": entry.get("note")}
    if record and not new_example:
        return "none_proposed", {"checker_notes": record.get("notes") or []}
    return "other", {"new_example": new_example}


def band_of(rank):
    for low, high in BANDS:
        if rank >= low and (high is None or rank <= high):
            return f"{low}–{high or ''}"
    return "?"


def retry(identifiers, out="retry.json", with_evidence=False, replace=False, hint=None):
    """Stage 5b: a second attempt for verbs whose Stage 5 proposal the skeptic refuted.

    Writes verb_pass/stage5/retry.json in the shape of verbs.json, each `prior` now the refuted
    Stage 5 proposal and the skeptic's reason, so the shard builder can append them as one more
    Stage 5 shard (--append) and the report can let the newer attempt supersede the refuted one.
    """
    listed = {row["id"]: row for row in lib.load_json(STAGE5 / "verbs.json")}
    validator.use_pass_dir(STAGE5, example_only=True)
    attempts, earlier, glosses = {}, collections.defaultdict(list), {}
    for path in sorted(validator.SKEPTIC_SHARDS.glob("shard_*.json")):
        items = lib.load_json(path)["items"]
        results = lib.load_json(validator.SKEPTIC_RESULTS / path.name)["results"]
        for item, result in zip(items, results):
            if item["task"] == "gloss":
                glosses[item["id"]] = {"proposed": item["proposed"], "skeptic_verdict": result["verdict"],
                                       "skeptic_reason": result["reason"]}
                continue
            attempts[item["id"]] = (item, result)
            earlier[item["id"]].append({**sentence(item["proposed"]), "skeptic_reason": result["reason"]})
    cnrtl = lib.load_json(CNRTL) if CNRTL.exists() else {}
    rows = []
    for identifier in identifiers:
        if identifier not in listed:
            raise SystemExit(f"{identifier} is not in verbs.json")
        item, result = attempts[identifier]
        if result["verdict"] != "refuted" and not replace:
            raise SystemExit(f"{identifier}: its latest attempt is {result['verdict']}, not refuted "
                             "(pass --replace to replace it anyway)")
        row = dict(listed[identifier])
        row["reason"] = "stage5_refuted" if result["verdict"] == "refuted" else "stage5_replaced"
        row["prior"] = {**sentence(item["proposed"]), "skeptic_reason": result["reason"],
                        "first_reason": listed[identifier]["reason"]}
        if len(earlier[identifier]) > 1:
            row["prior"]["earlier_attempts"] = earlier[identifier][:-1]
        if identifier in glosses:
            row["prior"]["gloss_attempt"] = glosses[identifier]
        if with_evidence:
            if identifier not in cnrtl:
                raise SystemExit(f"{identifier}: no CNRTL evidence; run fetch_cnrtl.py --evidence first")
            row["cnrtl"] = cnrtl[identifier]
        if hint:
            row["prior"]["hint"] = hint
        rows.append(row)
    rows.sort(key=lambda row: (row["rank"], row["id"]))
    lib.write_json(STAGE5 / out, rows)
    print(f"  {len(rows)} verbs to try again")


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--retry", help="Stage 5b: comma-separated verb ids whose Stage 5 proposal was refuted")
    parser.add_argument("--out", default="retry.json", help="the retry file's name under verb_pass/stage5/")
    parser.add_argument("--evidence", action="store_true",
                        help="Stage 5c: attach each verb's CNRTL evidence from verb_pass/stage5/cnrtl.json")
    parser.add_argument("--replace", action="store_true",
                        help="retry a verb whose latest example stands, at Josh's request (reason stage5_replaced)")
    parser.add_argument("--hint", help="a reviewer's note for the checker and skeptic, stored as prior.hint")
    options = parser.parse_args()
    if options.retry:
        retry([part.strip() for part in options.retry.split(",") if part.strip()], options.out,
              options.evidence, options.replace, options.hint)
        return
    verbs = lib.load_verbs()
    examples = lib.load_examples()
    joined = stage2()
    verdicts = skeptic()
    approvals = lib.load_json(lib.OUT_DIR / "approvals.json")["items"]
    applied = lib.load_json(lib.OUT_DIR / "applied.json")

    rows = []
    for entry in sorted(verbs, key=lambda item: (item["rank"], item["id"])):
        if entry["id"] in examples or entry["infinitive"] in examples:
            continue
        verb, record = joined.get(entry["id"], (None, None))
        reason, prior = classify(entry["id"], verb or {}, record, verdicts, approvals, applied)
        rows.append({"id": entry["id"], "infinitive": entry["infinitive"], "rank": entry["rank"],
                     "gloss": entry["gloss"], "reason": reason, "prior": prior})

    lib.write_json(STAGE5 / "verbs.json", rows)
    infinitives = {row["infinitive"] for row in rows}
    print(f"  {len(rows)} entries ({len(infinitives)} infinitives) have no example")
    by_reason = collections.Counter(row["reason"] for row in rows)
    for reason in REASONS:
        if by_reason[reason]:
            names = ", ".join(row["id"] for row in rows if row["reason"] == reason)[:110]
            print(f"    {by_reason[reason]:4d}  {reason:18} {names}")
    by_band = collections.Counter(band_of(row["rank"]) for row in rows)
    print("  by rank: " + ", ".join(f"{band} {count}" for band, count in by_band.items()))


if __name__ == "__main__":
    main()
