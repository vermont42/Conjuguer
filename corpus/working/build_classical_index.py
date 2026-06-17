#!/usr/bin/env python3
"""Build a candidate index for the 144 Chanson-only verbs over the CLASSICAL tier.

The 144 targets are the verbs that have a *Chanson de Roland* example
(`corpus/json/chanson_examples.json`) but are NOT among the 982 usage-ranked verbs already covered
by `corpus/json/literature_examples.json`. They are archaic reflexes (`occire`, `quérir`, `gésir`,
…); the owner wants each honored with a modern example below the Chanson one.

This tool mirrors `build_tail_index.py` but:
  * targets the 144 (recomputed here, never hand-copied) instead of the uncovered ranked tail;
  * uses `forms_all.json` (all ~6,320 verbs) — `forms.json` only has the ranked 982, and these are
    *un*ranked, so they're absent from it;
  * normalizes verb ids — `forms_all.json` keys verbs by `infinitifWithPossibleExtraLetters`
    (`"haïr (France)"`), but the JSON corpora use the bare infinitive (`"haïr"`). We strip the
    trailing " (…)" before intersecting, else every regional/disambiguated verb is silently lost;
  * draws candidates from the **classical** tier (La Fontaine + Molière) — optionally with fallback
    tiers via --tiers — and ranks each verb's occurrences by how distinctively *verbal* the matched
    token is (infinitive/participle/gerund over a bare noun-homograph stem), the same defense
    against homographs that build_tail_index uses.

Writes per-shard files under `corpus/working/shards/` for `mine_examples.workflow.js`, plus
`corpus/working/classical_index.json` for inspection.
"""
import argparse
import json
import os
import re
import shutil
from collections import defaultdict

from build_corpus_index import (
    MAX_OCCURRENCES, TOKEN_RE, gutenberg_bounds, nfc, ordered_docs, snippet,
)
from build_tail_index import rank_candidates

HERE = os.path.dirname(os.path.abspath(__file__))
CORPUS = os.path.dirname(HERE)
FORMS_ALL_JSON = os.path.join(HERE, "forms_all.json")
CHANSON_JSON = os.path.join(CORPUS, "json", "chanson_examples.json")
LIT_JSON = os.path.join(CORPUS, "json", "literature_examples.json")
CLASSICAL_INDEX_JSON = os.path.join(HERE, "classical_index.json")
SHARDS_DIR = os.path.join(HERE, "shards")
SHARD_SIZE = 30
# Gather generously per doc so the rare verbal forms aren't capped out by a frequent homograph.
PER_DOC_CAP = 15

_BARE_RE = re.compile(r"\s*\(.*\)$")


def bare(vid):
    """Strip a trailing ' (France)' / ' (Québec)' disambiguator → bare infinitive."""
    return _BARE_RE.sub("", vid)


def targets():
    """The 144 = chanson keys not in literature_examples.json. Recomputed, never hand-copied."""
    ch = json.load(open(CHANSON_JSON, encoding="utf-8"))
    lit = json.load(open(LIT_JSON, encoding="utf-8"))
    return set(v for v in ch if v not in lit)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--tiers", default="classical",
        help="comma-separated tier priority (default: classical). e.g. "
             "'classical,government,technology,wikipedia' to let fallback tiers rescue stragglers.",
    )
    args = ap.parse_args()
    tiers = tuple(t.strip() for t in args.tiers.split(",") if t.strip())

    forms = json.load(open(FORMS_ALL_JSON, encoding="utf-8"))
    want = targets()

    raw = defaultdict(lambda: defaultdict(list))   # verb (bare) → {doc rel: [occurrence]}
    per_doc_seen = defaultdict(set)                # (verb, doc) → {line}

    docs = [d for d in ordered_docs() if d[0] in tiers]
    for _tier, _author, rel, abspath in docs:
        lo, hi = gutenberg_bounds(abspath)
        with open(abspath, encoding="utf-8", errors="replace") as handle:
            for lineno, raw_line in enumerate(handle, start=1):
                if lineno <= lo or lineno >= hi:
                    continue
                line = nfc(raw_line.rstrip("\n"))
                hits = {}
                for token in TOKEN_RE.findall(line.lower()):
                    if len(token) < 2:
                        continue
                    for vid in forms.get(token, ()):
                        b = bare(vid)
                        if b in want:
                            hits.setdefault(b, token)
                for verb, token in hits.items():
                    seen = per_doc_seen[(verb, rel)]
                    if lineno in seen or len(seen) >= PER_DOC_CAP:
                        continue
                    seen.add(lineno)
                    raw[verb][rel].append(
                        {"doc": rel, "line": lineno, "token": token, "text": snippet(line, token)}
                    )

    index = {v: rank_candidates(raw[v], v) for v in sorted(raw) if raw[v]}
    json.dump(index, open(CLASSICAL_INDEX_JSON, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    # shard for the workflow
    verbs = list(index)
    shutil.rmtree(SHARDS_DIR, ignore_errors=True)
    os.makedirs(SHARDS_DIR)
    shard_count = 0
    for shard_count, start in enumerate(range(0, len(verbs), SHARD_SIZE)):
        chunk = {v: index[v] for v in verbs[start:start + SHARD_SIZE]}
        path = os.path.join(SHARDS_DIR, f"shard_{shard_count:03d}.json")
        json.dump(chunk, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    total_shards = shard_count + 1 if verbs else 0

    absent = sorted(want - set(index))
    print(f"target verbs (Chanson-only) : {len(want)}")
    print(f"tiers searched              : {', '.join(tiers)}")
    print(f"  with >=1 candidate        : {len(index)}  (-> {total_shards} shards to mine)")
    print(f"  no token at all (author)  : {len(absent)}")
    print(f"\nclassical_index.json + {total_shards} shards written under corpus/working/")
    print(f"launch: Workflow(mine_examples.workflow.js, args {{shardCount: {total_shards}}})")
    if absent:
        print(f"\nno candidate (authoring residue):\n  " + ", ".join(absent))


if __name__ == "__main__":
    main()
