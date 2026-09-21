#!/usr/bin/env python3
"""Validate Stage 2 result files of the verb pass against their shards and the contract.

A result file is valid when it parses, names its shard, and holds exactly the shard's verbs,
once each and in file order, every record carrying the six contract keys with verdicts drawn
from the fixed vocabularies. A short file is invalid even when it is well formed: the agent
reads a shard of up to 8,832 lines across several Read calls, and a short read fails silently.

Provenance problems (a chosen sentence that differs from every candidate, a quotation outside
the public domain, an authored sentence with the wrong source or a line number) do not make a
file invalid, because a re-run would not reliably fix them; they are listed as warnings for
Stage 3 to weigh.

Usage:
    python3 corpus/working/validate_verb_pass.py                 # summary, then the pending list
    python3 corpus/working/validate_verb_pass.py --pending       # only the pending shard numbers, comma-separated
    python3 corpus/working/validate_verb_pass.py --counts        # verdict counts by task over the valid files
    python3 corpus/working/validate_verb_pass.py --source "Claude (Sonnet 5)"
"""
import argparse
import collections
import json
import pathlib
import sys

HERE = pathlib.Path(__file__).resolve().parent
SHARDS = HERE / "verb_pass" / "shards"
RESULTS = HERE / "verb_pass" / "results"
GLOSS_VERDICTS = {"ok", "typo", "wrong_sense", "missing_primary_sense", "order", "style"}
EXAMPLE_VERDICTS = {"ok", "none", "verb_absent", "not_verbal", "wrong_sense",
                    "mistranslation", "wrong_form", "register"}
FLAG_VERDICTS = {"app_correct", "change", "unsure"}
CONFIDENCES = {"high", "medium", "low"}
EXAMPLE_KINDS = {"tier", "wiktionnaire", "wiktionary_en", "authored"}
PUBLIC_DOMAIN_BEFORE = 1931
RECORD_KEYS = {"id", "gloss", "example", "new_example", "flags", "notes"}
NEW_EXAMPLE_KEYS = {"fr", "en", "source", "line", "token", "kind"}


def normalize(text):
    return " ".join((text or "").replace("’", "'").split()).strip().lower()


def check_record(record, verb, source_label):
    errors, warnings = [], []
    identifier = verb["id"]
    absent = RECORD_KEYS - set(record)
    if absent:
        errors.append(f"{identifier}: missing key(s) {', '.join(sorted(absent))}")
        return errors, warnings
    gloss = record["gloss"] or {}
    if gloss.get("verdict") not in GLOSS_VERDICTS:
        errors.append(f"{identifier}: gloss verdict {gloss.get('verdict')!r}")
    if gloss.get("confidence") not in CONFIDENCES:
        errors.append(f"{identifier}: gloss confidence {gloss.get('confidence')!r}")
    if gloss.get("verdict") == "ok" and gloss.get("proposed"):
        warnings.append(f"{identifier}: gloss verdict ok with a proposal")
    example = record["example"] or {}
    if example.get("verdict") not in EXAMPLE_VERDICTS:
        errors.append(f"{identifier}: example verdict {example.get('verdict')!r}")
    if verb.get("example") is None and example.get("verdict") not in ("none", None):
        warnings.append(f"{identifier}: example verdict {example.get('verdict')!r} with no example")
    for flag in record["flags"] or []:
        if flag.get("verdict") not in FLAG_VERDICTS:
            errors.append(f"{identifier}: flag verdict {flag.get('verdict')!r}")
    if not isinstance(record["notes"], list):
        errors.append(f"{identifier}: notes is not a list")
    new_example = record["new_example"]
    if new_example:
        missing = NEW_EXAMPLE_KEYS - set(new_example)
        if missing:
            errors.append(f"{identifier}: new_example missing {', '.join(sorted(missing))}")
        kind = new_example.get("kind")
        if kind not in EXAMPLE_KINDS:
            errors.append(f"{identifier}: new_example kind {kind!r}")
        elif kind == "authored":
            if new_example.get("source") != source_label:
                warnings.append(f"{identifier}: authored source {new_example.get('source')!r}")
            if new_example.get("line") is not None:
                warnings.append(f"{identifier}: authored sentence carries a line")
        else:
            chosen = normalize(new_example.get("fr"))
            match = next((c for c in verb.get("candidates") or []
                          if c.get("kind") == kind and normalize(c.get("text")) == chosen), None)
            if match is None:
                warnings.append(f"{identifier}: {kind} sentence matches no candidate verbatim")
            elif kind == "wiktionnaire":
                death = match.get("death_year")
                if not isinstance(death, int) or death >= PUBLIC_DOMAIN_BEFORE:
                    warnings.append(f"{identifier}: quotation by {match.get('author')!r}, "
                                    f"death year {death!r}")
    return errors, warnings


def validate(number, source_label):
    name = f"shard_{number:03d}.json"
    shard = json.load(open(SHARDS / name, encoding="utf-8"))
    path = RESULTS / name
    if not path.exists():
        return ["file missing"], [], None
    try:
        payload = json.load(open(path, encoding="utf-8"))
    except (json.JSONDecodeError, UnicodeDecodeError) as error:
        return [f"unparseable: {error}"], [], None
    if payload.get("shard") != number:
        return [f"shard field {payload.get('shard')!r}"], [], None
    results = payload.get("results")
    if not isinstance(results, list):
        return ["no results list"], [], None
    expected = [verb["id"] for verb in shard["verbs"]]
    got = [record.get("id") for record in results if isinstance(record, dict)]
    if got != expected:
        missing = [i for i in expected if i not in got]
        unknown = [i for i in got if i not in expected]
        detail = f"{len(got)} of {len(expected)} entries"
        if missing:
            detail += f"; missing {', '.join(missing[:5])}{' …' if len(missing) > 5 else ''}"
        if unknown:
            detail += f"; unknown {', '.join(unknown[:5])}"
        if not missing and not unknown:
            detail += "; out of order or duplicated"
        return [detail], [], None
    errors, warnings = [], []
    for record, verb in zip(results, shard["verbs"]):
        record_errors, record_warnings = check_record(record, verb, source_label)
        errors += record_errors
        warnings += record_warnings
    return errors, warnings, results


def counts(all_results):
    tally = collections.defaultdict(collections.Counter)
    for record in all_results:
        tally["gloss"][record["gloss"]["verdict"]] += 1
        tally["example"][record["example"]["verdict"]] += 1
        tally["new_example"][(record["new_example"] or {}).get("kind", "null")] += 1
        for flag in record["flags"] or []:
            tally["flags"][f"{flag.get('flag')}:{flag.get('verdict')}"] += 1
        tally["notes"]["with notes" if record["notes"] else "without"] += 1
    return tally


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--pending", action="store_true")
    parser.add_argument("--counts", action="store_true")
    parser.add_argument("--warnings", action="store_true")
    parser.add_argument("--source", default="Claude (Sonnet 5)")
    options = parser.parse_args()
    numbers = sorted(int(p.stem.split("_")[1]) for p in SHARDS.glob("shard_*.json"))
    pending, valid_results, all_warnings, report = [], [], [], []
    for number in numbers:
        errors, warnings, results = validate(number, options.source)
        if errors:
            pending.append(number)
            if errors != ["file missing"]:
                report.append(f"shard {number:03d}: {errors[0]}"
                              f"{f' (+{len(errors) - 1} more)' if len(errors) > 1 else ''}")
        else:
            valid_results += results
            all_warnings += [f"shard {number:03d}: {w}" for w in warnings]
    if options.pending:
        print(",".join(map(str, pending)))
        return
    print(f"{len(numbers) - len(pending)} of {len(numbers)} shards valid, "
          f"{len(valid_results)} verbs; {len(pending)} pending; {len(all_warnings)} warning(s)")
    for line in report:
        print(line)
    if options.warnings:
        for line in all_warnings:
            print(line)
    if options.counts:
        for task, tally in counts(valid_results).items():
            print(f"{task}: " + ", ".join(f"{k} {v}" for k, v in tally.most_common()))
    if pending:
        print("pending:", ",".join(map(str, pending)))
    sys.exit(0)


if __name__ == "__main__":
    main()
