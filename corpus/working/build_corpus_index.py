#!/usr/bin/env python3
"""Build an inverted verb→occurrences index over the example corpus.

This is the cheap, deterministic *retrieval* half of the example-mining pipeline: it locates
candidate sentences for the ~981 usage-ranked verbs so that LLM subagents only do the expensive
*selection + translation* on a handful of pre-found lines, instead of reading whole documents.

Inputs:
  - corpus/working/forms.json  : { "<surface form>": ["<verb id>", ...] }, produced by the
    `CorpusFormsDumpTests` Swift tool driving the app's own Conjugator. Exact whole-token
    matching against this map handles irregular stems and avoids substring false positives.
  - corpus/originals/literature/*.txt and .../government/*.txt : the source texts.

Output:
  - corpus/working/corpus_index.json : { "<verb id>": [ {doc, line, token, text}, ... ] }
  - a coverage report to stdout (literature/government split, author balance, zero-coverage tail).

Design points (see CLAUDE.md corpus section):
  * ONE pass over each document (tokenize once, look every token up), not 981 passes.
  * Candidates are collected from ALL THREE novels independently, then merged round-robin with a
    per-verb ROTATING LEAD AUTHOR, so the first candidate (the one selectors reach for) is spread
    evenly across Flaubert / Proust / Zola instead of always coming from whichever is scanned
    first. Government documents are appended as fallback, after the literature candidates.
  * Up to MAX_OCCURRENCES distinct lines recorded per verb — generous candidates for the selector,
    while still bounding index size; the LLM step is where work is actually capped.
  * A token mapping to several verbs (homographs) is recorded under each; context disambiguates.
"""
import json
import os
import re
import unicodedata
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
CORPUS = os.path.dirname(HERE)
ROOT = os.path.dirname(CORPUS)
FORMS_JSON = os.path.join(HERE, "forms.json")
OUT_JSON = os.path.join(HERE, "corpus_index.json")
ORIGINALS = os.path.join(CORPUS, "originals")

# Final distinct lines kept per verb, and the per-document ceiling gathered before balancing.
MAX_OCCURRENCES = 5
PER_DOC_CAP = 4
# Stored context width (chars) centered on the matched token.
SNIPPET_WIDTH = 200
# Canonical novel order; rotated per verb so the lead candidate is evenly spread across authors.
LIT_AUTHORS = ["flaubert", "proust", "zola"]
# Old French — handled by the separate hand-built chanson pipeline; its forms don't match modern
# conjugations anyway. Excluded from this modern-prose index.
EXCLUDE = {"chanson-roland-oxford.txt"}

# Unicode-aware word tokens. `[^\W\d_]+` = runs of letters only, so apostrophes and hyphens act
# as separators: "j'ai" → ["j", "ai"], "va-t-il" → ["va", "t", "il"]. Accented letters are letters.
TOKEN_RE = re.compile(r"[^\W\d_]+", re.UNICODE)

# Project Gutenberg wraps each novel in an English header (title/license/"Release date:") and a
# trailing license. Those English words collide with short French verb forms ("use", "date",
# "love", "is"), so we index only the body BETWEEN the markers. Bounds are *physical* line numbers,
# so line references stay valid against the unmodified file on disk.
GUTENBERG_START = re.compile(r"\*\*\* START OF THE PROJECT GUTENBERG EBOOK")
GUTENBERG_END = re.compile(r"\*\*\* END OF THE PROJECT GUTENBERG EBOOK")


def nfc(text):
    return unicodedata.normalize("NFC", text)


def gutenberg_bounds(abspath):
    """(lo, hi) such that only lo < physical_line < hi is real body text. A file with no markers
    (e.g. government docs) yields (0, inf) — everything is indexed."""
    lo, hi = 0, float("inf")
    with open(abspath, encoding="utf-8", errors="replace") as handle:
        for n, line in enumerate(handle, start=1):
            if GUTENBERG_START.search(line):
                lo = n
            elif GUTENBERG_END.search(line):
                hi = n
                break
    return lo, hi


TIERS = ("literature", "government", "technology", "wikipedia")


def ordered_docs():
    """(tier, author, relpath, abspath) for every source .txt, in tier priority order. The
    'author' is the novelist for literature and the tier name otherwise (used for balancing)."""
    docs = []
    for tier in TIERS:
        tier_dir = os.path.join(ORIGINALS, tier)
        if not os.path.isdir(tier_dir):
            continue
        for name in sorted(os.listdir(tier_dir)):
            if not name.endswith(".txt") or name in EXCLUDE:
                continue
            author = name.split("-")[0] if tier == "literature" else tier
            rel = os.path.join("corpus", "originals", tier, name)
            docs.append((tier, author, rel, os.path.join(tier_dir, name)))
    return docs


def snippet(line, token):
    low = line.lower()
    i = low.find(token)
    if i < 0:
        return line.strip()[:SNIPPET_WIDTH]
    half = SNIPPET_WIDTH // 2
    start, end = max(0, i - half), min(len(line), i + len(token) + half)
    frag = line[start:end].strip()
    return ("…" if start > 0 else "") + frag + ("…" if end < len(line) else "")


def merge_balanced(by_author, gov, rank):
    """Round-robin the per-author candidate lists, leading with a verb-specific rotated author,
    then top up from government. `by_author` maps author → [occurrence]."""
    rotation = rank % len(LIT_AUTHORS)
    order = LIT_AUTHORS[rotation:] + LIT_AUTHORS[:rotation]
    queues = [list(by_author.get(author, [])) for author in order]
    out = []
    pos = 0
    while len(out) < MAX_OCCURRENCES and any(queues):
        queue = queues[pos % len(order)]
        if queue:
            out.append(queue.pop(0))
        pos += 1
    if len(out) < MAX_OCCURRENCES:
        out.extend(gov[: MAX_OCCURRENCES - len(out)])
    return out


def main():
    with open(FORMS_JSON, encoding="utf-8") as handle:
        forms = json.load(handle)
    # form → list of verb ids; forms are already lowercase+NFC from the Swift dumper.
    all_verbs = sorted({v for ids in forms.values() for v in ids})

    # verb → {author: [occurrence]} preserving document scan order (government keyed as one author).
    raw = defaultdict(lambda: defaultdict(list))
    per_doc_seen = defaultdict(set)  # (verb, doc) → {line} for distinct-line dedup + per-doc cap

    for _tier, author, rel, abspath in ordered_docs():
        lo, hi = gutenberg_bounds(abspath)
        with open(abspath, encoding="utf-8", errors="replace") as handle:
            for lineno, raw_line in enumerate(handle, start=1):
                if lineno <= lo or lineno >= hi:
                    continue
                line = nfc(raw_line.rstrip("\n"))
                low = line.lower()
                # Collect this line's matched verbs first, so one paragraph-line contributes at
                # most one occurrence per verb.
                hits = {}
                for token in TOKEN_RE.findall(low):
                    if len(token) < 2:
                        continue
                    for verb in forms.get(token, ()):
                        hits.setdefault(verb, token)
                for verb, token in hits.items():
                    seen = per_doc_seen[(verb, rel)]
                    if lineno in seen or len(seen) >= PER_DOC_CAP:
                        continue
                    seen.add(lineno)
                    raw[verb][author].append({
                        "doc": rel,
                        "line": lineno,
                        "token": token,
                        "text": snippet(line, token),
                    })

    index = {}
    for rank, verb in enumerate(all_verbs):
        by_author = raw.get(verb, {})
        if not by_author:
            continue
        lit = {a: occs for a, occs in by_author.items() if a in LIT_AUTHORS}
        gov = by_author.get("government", [])
        merged = merge_balanced(lit, gov, rank)
        if merged:
            index[verb] = merged

    out = {verb: index[verb] for verb in sorted(index)}
    with open(OUT_JSON, "w", encoding="utf-8") as handle:
        json.dump(out, handle, ensure_ascii=False, indent=1)

    # ---- coverage + balance report ----
    total = len(all_verbs)
    covered = len(out)
    zero = [v for v in all_verbs if v not in index]
    lit_only_authors = lambda occs: [o for o in occs if "government" not in o["doc"]]
    gov_rescued = sum(1 for occs in out.values() if not lit_only_authors(occs))

    lead = defaultdict(int)
    cand_by_author = defaultdict(int)
    for occs in out.values():
        first = occs[0]["doc"]
        lead[author_of(first)] += 1
        for o in occs:
            cand_by_author[author_of(o["doc"])] += 1

    print(f"forms.json forms          : {len(forms)}")
    print(f"usage-ranked verbs        : {total}")
    print(f"verbs with >=1 example    : {covered}  ({100 * covered / total:.1f}%)")
    print(f"  literature-only rescued by government: {gov_rescued}")
    print(f"total occurrences recorded: {sum(len(v) for v in out.values())}")
    print(f"zero-coverage verbs       : {len(zero)}  (-> technology tier / manual)")
    print(f"\nJSON written to {os.path.relpath(OUT_JSON, ROOT)}")

    print("\nLEAD candidate (what selectors reach for first) by source — should be an even mix:")
    for author in LIT_AUTHORS + ["government"]:
        print(f"  {lead.get(author, 0):4d}  {author}")
    print("\nAll candidates by source:")
    for author in LIT_AUTHORS + ["government"]:
        print(f"  {cand_by_author.get(author, 0):4d}  {author}")

    if zero:
        shown = ", ".join(zero[:40])
        print(f"\nZero-coverage verbs ({len(zero)}):\n  {shown}" + (" …" if len(zero) > 40 else ""))


def author_of(rel):
    name = os.path.basename(rel)
    if os.sep + "literature" + os.sep in rel:
        return name.split("-")[0]
    if os.sep + "technology" + os.sep in rel:
        return "technology"
    if os.sep + "wikipedia" + os.sep in rel:
        return "wikipedia"
    return "government"


if __name__ == "__main__":
    main()
