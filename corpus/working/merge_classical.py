#!/usr/bin/env python3
"""Merge classical-tier mined examples + authored residue into literature_examples.json.

Usage:
  python3 merge_classical.py mined_classical.json [authored_classical.json]

Both inputs are arrays of { verb, fr, en, source, line, token }. `mined_classical.json` is the
workflow's `examples` array (entries with fr=null are skipped — they fall to authoring).
Entries are keyed into literature_examples.json by **bare infinitive** (the verb field).

Guardrails:
  * Only ADDS keys among the 144 Chanson-only targets — never touches the existing 982.
  * Refuses to overwrite an existing literature_examples.json key (prints a warning, skips).
  * Validates that every target ends up either mined or authored; reports the split.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
CORPUS = os.path.dirname(HERE)
LIT_JSON = os.path.join(CORPUS, "json", "literature_examples.json")
CHANSON_JSON = os.path.join(CORPUS, "json", "chanson_examples.json")


def targets():
    ch = json.load(open(CHANSON_JSON, encoding="utf-8"))
    lit = json.load(open(LIT_JSON, encoding="utf-8"))
    return set(v for v in ch if v not in lit)


def load_array(path):
    data = json.load(open(path, encoding="utf-8"))
    if isinstance(data, dict) and "examples" in data:
        data = data["examples"]
    return data


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)
    want = targets()
    lit = json.load(open(LIT_JSON, encoding="utf-8"))

    mined = load_array(sys.argv[1])
    authored = load_array(sys.argv[2]) if len(sys.argv) > 2 else []

    added_mined, added_authored, skipped = [], [], []

    def add(e, bucket):
        v = e["verb"]
        if v not in want:
            print(f"  ! {v} not in the 144 targets — skipping")
            return
        if v in lit:
            print(f"  ! {v} already in literature_examples.json — refusing to overwrite")
            return
        if not e.get("fr"):
            return
        lit[v] = {
            "fr": e["fr"],
            "en": e["en"],
            "source": e["source"],
            "line": e["line"],
            "token": e["token"],
        }
        bucket.append(v)

    for e in mined:
        add(e, added_mined)
    placed = set(added_mined)
    for e in authored:
        if e["verb"] in placed:
            continue
        add(e, added_authored)

    out = {k: lit[k] for k in sorted(lit)}
    json.dump(out, open(LIT_JSON, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    covered = set(added_mined) | set(added_authored)
    missing = sorted(want - covered - (set(lit) & want))
    # recompute against what is actually now in the file
    now_in = set(lit) & want
    print(f"targets (144)        : {len(want)}")
    print(f"  mined (classical)  : {len(added_mined)}")
    print(f"  authored           : {len(added_authored)}")
    print(f"  now in lit json    : {len(now_in)}")
    still = sorted(want - now_in)
    if still:
        print(f"  STILL MISSING ({len(still)}): {', '.join(still)}")
    else:
        print("  all 144 covered ✓")

    # author split
    laf = sum(1 for v in added_mined if lit[v]["source"] == "lafontaine-fables.txt")
    mol = len(added_mined) - laf
    print(f"\nclassical split: La Fontaine {laf}  |  Molière {mol}")


if __name__ == "__main__":
    main()
