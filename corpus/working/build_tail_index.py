#!/usr/bin/env python3
"""Build a candidate index for the UNCOVERED tail, drawn from government + technology.

The main `build_corpus_index.py` fills each verb's 5 candidate slots literature-first. For verbs
whose surface form equals a common noun (`signer`/`signe`, `placer`/`place`, `programmer`/
`programme`, …), literature supplies five *noun* uses and crowds out the genuine *verbal* uses
that exist in administrative/technical prose — so those verbs come back null even though the
government tier already contains them.

This tool targets exactly the uncovered verbs (ranked verbs with no entry in
`json/literature_examples.json`) and builds their candidates from the **government + technology**
tiers only — the prose registers where these verbs are actually used as verbs. It writes
per-shard files under `corpus/working/shards/` ready for `mine_examples.workflow.js`, plus
`corpus/working/tail_index.json` for inspection.

Reuses the tokenizer / Gutenberg gating / snippet helpers from build_corpus_index.py.
"""
import json
import os
import shutil
from collections import defaultdict

from build_corpus_index import (
    MAX_OCCURRENCES, TOKEN_RE, gutenberg_bounds, nfc, ordered_docs, snippet,
)

HERE = os.path.dirname(os.path.abspath(__file__))
FORMS_JSON = os.path.join(HERE, "forms.json")
PLACED_JSON = os.path.join(os.path.dirname(HERE), "json", "literature_examples.json")
TAIL_JSON = os.path.join(HERE, "tail_index.json")
SHARDS_DIR = os.path.join(HERE, "shards")
SHARD_SIZE = 30
TAIL_TIERS = ("government", "technology", "wikipedia")
# Gather generously per doc so the rare verbal forms aren't capped out by the frequent noun.
TAIL_PER_DOC_CAP = 15


def verbalness(token, verb):
    """Rank a matched token by how unambiguously it is a *conjugated* form rather than the
    same-spelled noun. The collision is almost always the present stem ("base", "programme",
    "liste"); the infinitive, participle, gerund and imperfect are unmistakably verbal."""
    if token == verb:                      # infinitive ("baser", "programmer")
        return 3
    if token.endswith("ant"):              # gerund, any group ("basant", "ciblant")
        return 2
    if verb.endswith("er"):
        if token.endswith(("é", "ée", "és", "ées")):                       # past participle
            return 2
        if token.endswith(("ait", "aient", "ais", "èrent", "era", "eront",
                            "erons", "erez", "erait", "eraient")):          # imparfait/PS/futur/cond
            return 2
        stem = verb[:-2]
        if token in (stem, stem + "e", stem + "es", stem + "s"):            # the colliding noun
            return 0
        return 1
    if token.endswith(("i", "ie", "is", "ies", "u", "ue", "us", "ues", "issant", "issait")):
        return 2                           # ir/re participles & inflections
    return 1


def rank_candidates(by_doc, verb):
    """Flatten a verb's occurrences across docs, put the most distinctively verbal first, and
    keep the first MAX_OCCURRENCES distinct lines."""
    occ = [o for occs in by_doc.values() for o in occs]
    occ.sort(key=lambda o: -verbalness(o["token"], verb))  # stable: preserves doc/line order in ties
    seen, chosen = set(), []
    for o in occ:
        key = (o["doc"], o["line"])
        if key in seen:
            continue
        seen.add(key)
        chosen.append(o)
        if len(chosen) >= MAX_OCCURRENCES:
            break
    return chosen


def main():
    forms = json.load(open(FORMS_JSON, encoding="utf-8"))
    ranked = sorted({v for ids in forms.values() for v in ids})
    placed = set(json.load(open(PLACED_JSON, encoding="utf-8")))
    uncovered = set(v for v in ranked if v not in placed)

    raw = defaultdict(lambda: defaultdict(list))   # verb → {doc rel: [occurrence]}
    per_doc_seen = defaultdict(set)                # (verb, doc) → {line}

    docs = [d for d in ordered_docs() if d[0] in TAIL_TIERS]
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
                    for verb in forms.get(token, ()):
                        if verb in uncovered:
                            hits.setdefault(verb, token)
                for verb, token in hits.items():
                    seen = per_doc_seen[(verb, rel)]
                    if lineno in seen or len(seen) >= TAIL_PER_DOC_CAP:
                        continue
                    seen.add(lineno)
                    raw[verb][rel].append(
                        {"doc": rel, "line": lineno, "token": token, "text": snippet(line, token)}
                    )

    tail = {v: rank_candidates(raw[v], v) for v in sorted(raw) if raw[v]}
    json.dump(tail, open(TAIL_JSON, "w", encoding="utf-8"), ensure_ascii=False, indent=1)

    # shard for the workflow
    verbs = list(tail)
    shutil.rmtree(SHARDS_DIR, ignore_errors=True)
    os.makedirs(SHARDS_DIR)
    shard_count = 0
    for shard_count, start in enumerate(range(0, len(verbs), SHARD_SIZE)):
        chunk = {v: tail[v] for v in verbs[start:start + SHARD_SIZE]}
        path = os.path.join(SHARDS_DIR, f"shard_{shard_count:03d}.json")
        json.dump(chunk, open(path, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    total_shards = shard_count + 1 if verbs else 0

    still_absent = sorted(uncovered - set(tail))
    print(f"uncovered verbs            : {len(uncovered)}")
    print(f"  with gov/tech candidates : {len(tail)}  (-> {total_shards} shards to re-mine)")
    print(f"  still absent (need more) : {len(still_absent)}")
    print(f"\ntail_index.json + {total_shards} shards written under corpus/working/")
    print(f"launch: Workflow(mine_examples.workflow.js, args {{shardCount: {total_shards}}})")
    if still_absent:
        print(f"\nstill absent from gov/tech:\n  " + ", ".join(still_absent))


if __name__ == "__main__":
    main()
