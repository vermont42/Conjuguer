#!/usr/bin/env python3
"""Deterministic bookends for the literature example-mining pass (stage C).

The LLM middle — selecting the best candidate per verb and translating it — runs as the
`mine_examples.workflow.js` Workflow (one subagent per shard). This script handles the cheap
deterministic ends around it:

  shard   : split corpus/working/corpus_index.json into ~SHARD_SIZE-verb shard files under
            corpus/working/shards/, so each subagent reads only its slice (not the 1.1 MB whole).
  report  : print author balance / null counts over a finished examples JSON.

Usage:
  python3 build_literature_examples.py shard
  # ...run the workflow, write corpus/json/literature_examples.json from its result...
  python3 build_literature_examples.py report corpus/json/literature_examples.json
"""
import json
import os
import shutil
import sys
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
INDEX_JSON = os.path.join(HERE, "corpus_index.json")
SHARDS_DIR = os.path.join(HERE, "shards")
SHARD_SIZE = 30


def shard():
    with open(INDEX_JSON, encoding="utf-8") as handle:
        index = json.load(handle)
    verbs = list(index)  # already sorted + author-balanced by build_corpus_index.py
    if os.path.isdir(SHARDS_DIR):
        shutil.rmtree(SHARDS_DIR)
    os.makedirs(SHARDS_DIR)
    count = 0
    for count, start in enumerate(range(0, len(verbs), SHARD_SIZE)):
        chunk = {v: index[v] for v in verbs[start:start + SHARD_SIZE]}
        path = os.path.join(SHARDS_DIR, f"shard_{count:03d}.json")
        with open(path, "w", encoding="utf-8") as handle:
            json.dump(chunk, handle, ensure_ascii=False, indent=1)
    total = count + 1
    print(f"{len(verbs)} verbs -> {total} shards of <= {SHARD_SIZE} in {os.path.relpath(SHARDS_DIR)}")
    print(f"launch the workflow with args: {{ \"shardCount\": {total} }}")


def author_of(source):
    if not source:
        return "?"
    base = os.path.basename(source)
    return base.split("-")[0] if base.endswith(".txt") and "-" in base else base


def report(path):
    with open(path, encoding="utf-8") as handle:
        data = json.load(handle)
    # The finished export is keyed by verb → example; tolerate a raw array too.
    rows = list(data.values()) if isinstance(data, dict) else data
    by_author = defaultdict(int)
    nulls = 0
    for ex in rows:
        if ex.get("fr"):
            by_author[author_of(ex.get("source"))] += 1
        else:
            nulls += 1
    total = len(rows)
    placed = total - nulls
    print(f"examples            : {total}")
    print(f"  with a sentence   : {placed}")
    print(f"  null (no good use): {nulls}")
    print("\nplaced examples by source (the even-mix check):")
    for author, n in sorted(by_author.items(), key=lambda kv: -kv[1]):
        print(f"  {n:4d}  {author}")


def main():
    if len(sys.argv) >= 2 and sys.argv[1] == "shard":
        shard()
    elif len(sys.argv) >= 3 and sys.argv[1] == "report":
        report(sys.argv[2])
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
