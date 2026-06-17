#!/usr/bin/env python3
"""Generate a verb→Chanson-examples index from corpus/grokked/chanson.md.

Parses the per-laisse blocks, extracts the verb bracket on each original line,
resolves every gloss to a canonical Conjuguer verb key (the `in="..."` of
verbs.xml), and writes:
  - corpus/json/chanson_examples.json : { "<infinitif>": [ {laisse,line,of,tr,ofVerb?}, ... ] }
  - a coverage / unmatched report to stdout

An example is only attached to a modern verb when the line genuinely contains
THAT verb's own word — its ancestor form. Otherwise no example is emitted (the
app simply shows no Chanson section for that verb). Two kinds of bracket gloss
(see corpus/grokked/chanson_descendants.json):

  1. PAREN gloss `head (modern)` — `head` is the Old French verb in the line and
     `modern` is a hand-written meaning. We look `head` up in the audited
     descendants table:
       * if `head` has a verified modern French DESCENDANT that exists in
         verbs.xml  ->  attach the example to THAT descendant (a "reflex": the
         line literally contains that verb's own ancestor form).
         e.g. `oïr (entendre)` -> ouïr,  `eslire (choisir)` -> élire,
              `desclore (ouvrir)` -> déclore.
       * else (the Old French verb left no surviving descendant in the dict)
         ->  DROP it. The `modern` word is only a translation; the verb itself
         never appears in the poem, so it gets no Chanson example.
         e.g. `ferir (frapper)`: ferir->férir (reflex), but `frapper` gets nothing.
  2. BARE token `avoir`, `brandir`, … — already a modern lemma the annotator
     judged the line to contain directly. Resolve and attach as a reflex.

The descendants table is the merged result of a per-head English-Wiktionary
etymology audit (see corpus/working/audit_*.json), with a few manual overrides
for doublets whose modern sense diverged from the Roland usage. Regenerate the
table from those slices; this script only consumes it.

Resolution order for a single synonym token (paren `modern` or bare token):
  1. modern reflex in parens   `ocire (tuer)` -> "tuer"
  2. the bare token            `avoir`        -> "avoir"
  3. Old French head form      `seoir (asseoir)` also tries "seoir"
  4. reflexive stripped        `se coucher` -> "coucher", `s'en aller` -> "aller"
Slash alternatives (`estraire (descendre/être issu)`) try each part.
A token that resolves to nothing is reported as unmatched, never silently dropped.
"""
import json
import os
import re
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CHANSON = os.path.join(ROOT, "grokked", "chanson.md")
DESCENDANTS = os.path.join(ROOT, "grokked", "chanson_descendants.json")
VERBS_XML = os.path.join(os.path.dirname(ROOT), "Conjuguer", "Models", "verbs.xml")
# Two tracked copies: the corpus export and the copy bundled into the app target.
# The app loads `chanson_examples` from Conjuguer/Models, so both must stay in sync.
OUT_JSON = os.path.join(ROOT, "json", "chanson_examples.json")
BUNDLED_JSON = os.path.join(os.path.dirname(ROOT), "Conjuguer", "Models", "chanson_examples.json")

COMMENT_RE = re.compile(r"<!--.*?-->")
NUM_RE = re.compile(r"^(\d+)\.\s+(.*)$")
# the verb bracket is the LAST [...] at end of line (after stripping any comment)
TAIL_BRACKET_RE = re.compile(r"\[([^\[\]]*)\]\s*$")
PAREN_RE = re.compile(r"^(.*?)\s*\((.*)\)\s*$")


def load_verb_keys():
    xml = open(VERBS_XML, encoding="utf-8").read()
    return set(re.findall(r'in="([^"]+)"', xml))


def load_descendants():
    """head -> modern descendant verb key, only for heads whose descendant is
    a verified verbs.xml entry (the "reattach" set)."""
    table = {}
    for row in json.load(open(DESCENDANTS, encoding="utf-8")):
        if row.get("in_dict") and row.get("descendant"):
            table[row["head"]] = row["descendant"]
    return table


def split_top_commas(s):
    """Split on commas that are not inside parentheses."""
    out, depth, cur = [], 0, []
    for ch in s:
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth = max(0, depth - 1)
        if ch == "," and depth == 0:
            out.append("".join(cur))
            cur = []
        else:
            cur.append(ch)
    if cur:
        out.append("".join(cur))
    return [t.strip() for t in out if t.strip()]


def strip_reflexive(v):
    for pre in ("s'en ", "se ", "s'", "se'"):
        if v.startswith(pre):
            return v[len(pre):].strip()
    return v


def synonym_candidates(token):
    """Ordered resolution candidates for a single gloss/bare token."""
    cands = []
    m = PAREN_RE.match(token)
    if m:
        head, modern = m.group(1).strip(), m.group(2).strip()
        for part in re.split(r"\s*/\s*", modern):  # slash alternatives
            cands.append(part.strip())
        cands.append(head)
    else:
        cands.append(token.strip())
    # add reflexive-stripped variants
    cands += [strip_reflexive(c) for c in list(cands)]
    # dedupe, preserve order
    seen, ordered = set(), []
    for c in cands:
        if c and c not in seen:
            seen.add(c)
            ordered.append(c)
    return ordered


def resolve_synonym(token, keys):
    for c in synonym_candidates(token):
        if c in keys:
            return c
    return None


def head_of(token):
    """Old French head verb of a paren token, else None for a bare token."""
    m = PAREN_RE.match(token)
    if m:
        return m.group(1).strip()
    return None


def parse_blocks(text):
    """Yield (roman, original_lines, translation_lines) per laisse."""
    parts = re.split(r"^## Laisse\s+", text, flags=re.M)[1:]
    for part in parts:
        roman = part.split(" ", 1)[0]
        secs = re.split(r"\*\*Translation\*\*", part)
        orig = secs[0]
        trans = secs[1] if len(secs) > 1 else ""
        yield roman, orig, trans


def main():
    keys = load_verb_keys()
    descendants = load_descendants()
    text = open(CHANSON, encoding="utf-8").read()

    index = defaultdict(list)
    unmatched = Counter()
    occurrences = 0
    reattached = 0
    dropped_synonym = 0
    lines_with_verbs = 0

    for roman, orig, trans in parse_blocks(text):
        # build translation lookup: lineno -> text
        tr_by_num = {}
        for line in trans.splitlines():
            m = NUM_RE.match(line.strip())
            if m:
                tr_by_num[int(m.group(1))] = COMMENT_RE.sub("", m.group(2)).strip()

        for line in orig.splitlines():
            line = line.strip()
            m = NUM_RE.match(line)
            if not m:
                continue
            num = int(m.group(1))
            body = COMMENT_RE.sub("", m.group(2)).rstrip()
            bm = TAIL_BRACKET_RE.search(body)
            if not bm:
                continue
            of_text = body[: bm.start()].rstrip()
            tokens = split_top_commas(bm.group(1))
            if not tokens:
                continue
            lines_with_verbs += 1
            base = {
                "laisse": roman,
                "line": num,
                "of": of_text,
                "tr": tr_by_num.get(num, ""),
            }
            seen_keys = set()
            for tok in tokens:
                head = head_of(tok)
                if head is not None:
                    # PAREN gloss: keep only when the Old French verb has a
                    # verified modern descendant in the dict (a true reflex).
                    # Otherwise the verb itself never appears -> emit nothing.
                    if head in descendants:
                        key = descendants[head]
                        reattached += 1
                    else:
                        dropped_synonym += 1
                        continue
                else:
                    # BARE token: a modern lemma the line contains directly.
                    key = resolve_synonym(tok, keys)
                    if key is None:
                        unmatched[tok] += 1
                        continue
                if key in seen_keys:
                    continue
                seen_keys.add(key)
                index[key].append(dict(base))
                occurrences += 1

    # stable output: sort keys, examples already in document order
    out = {k: index[k] for k in sorted(index)}
    for path in (OUT_JSON, BUNDLED_JSON):
        json.dump(out, open(path, "w", encoding="utf-8"),
                  ensure_ascii=False, indent=1)

    # ---- report ----
    print(f"verbs.xml keys           : {len(keys)}")
    print(f"reattach descendants     : {len(descendants)} heads")
    print(f"original lines with verbs: {lines_with_verbs}")
    print(f"resolved verb occurrences: {occurrences}")
    print(f"  reattached (reflex)    : {reattached}")
    print(f"  dropped (synonym only) : {dropped_synonym}")
    print(f"distinct verbs w/ example: {len(out)}")
    print(f"  -> {100*len(out)/len(keys):.1f}% of the dictionary has >=1 example")
    print(f"unmatched gloss tokens   : {sum(unmatched.values())} "
          f"({len(unmatched)} distinct)")
    print(f"\nJSON written to {os.path.relpath(OUT_JSON, os.path.dirname(ROOT))}")

    counts = sorted(((len(v), k) for k, v in out.items()), reverse=True)
    print("\nTop 20 verbs by example count:")
    for c, k in counts[:20]:
        print(f"  {c:4d}  {k}")

    if unmatched:
        print("\nUnmatched gloss tokens (fix in verbs.xml or the bracket):")
        for tok, c in unmatched.most_common():
            print(f"  {c:4d}  {tok!r}")


if __name__ == "__main__":
    main()
