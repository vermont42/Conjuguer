#!/usr/bin/env python3
"""Generate a verb→Chanson-examples index from corpus/chanson.md.

Parses the per-laisse blocks, extracts the verb bracket on each original line,
resolves every gloss to a canonical Conjuguer verb key (the `in="..."` of
verbs.xml), and writes:
  - corpus/chanson_examples.json : { "<infinitif>": [ {laisse,line,of,tr}, ... ] }
  - a coverage / unmatched report to stdout

Resolution order per gloss token:
  1. modern reflex in parens   `ocire (tuer)` -> "tuer"
  2. the bare token            `avoir`        -> "avoir"
  3. Old French head form      `seoir (asseoir)` also tries "seoir"
  4. reflexive stripped        `se coucher` -> "coucher", `s'en aller` -> "aller"
Slash alternatives (`estraire (descendre/être issu)`) try each part.
A token that resolves to nothing is reported as unmatched (fix in verbs.xml or
the bracket), never silently dropped.
"""
import json
import os
import re
from collections import Counter, defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CHANSON = os.path.join(HERE, "chanson.md")
VERBS_XML = os.path.join(ROOT, "Conjuguer", "Models", "verbs.xml")
OUT_JSON = os.path.join(HERE, "chanson_examples.json")

COMMENT_RE = re.compile(r"<!--.*?-->")
LAISSE_RE = re.compile(r"^## Laisse\s+([A-Z]+)\s+\(lines", re.M)
NUM_RE = re.compile(r"^(\d+)\.\s+(.*)$")
# the verb bracket is the LAST [...] at end of line (after stripping any comment)
TAIL_BRACKET_RE = re.compile(r"\[([^\[\]]*)\]\s*$")
PAREN_RE = re.compile(r"^(.*?)\s*\((.*)\)\s*$")


def load_verb_keys():
    xml = open(VERBS_XML, encoding="utf-8").read()
    return set(re.findall(r'in="([^"]+)"', xml))


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


def candidates(token):
    """Ordered resolution candidates for a single gloss token."""
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


def resolve(token, keys):
    for c in candidates(token):
        if c in keys:
            return c
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
    text = open(CHANSON, encoding="utf-8").read()

    index = defaultdict(list)
    unmatched = Counter()
    occurrences = 0
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
            example = {
                "laisse": roman,
                "line": num,
                "of": of_text,
                "tr": tr_by_num.get(num, ""),
            }
            seen_keys = set()
            for tok in tokens:
                key = resolve(tok, keys)
                if key is None:
                    unmatched[tok] += 1
                    continue
                if key in seen_keys:
                    continue
                seen_keys.add(key)
                index[key].append(example)
                occurrences += 1

    # stable output: sort keys, examples already in document order
    out = {k: index[k] for k in sorted(index)}
    json.dump(out, open(OUT_JSON, "w", encoding="utf-8"),
              ensure_ascii=False, indent=1)

    # ---- report ----
    print(f"verbs.xml keys           : {len(keys)}")
    print(f"original lines with verbs: {lines_with_verbs}")
    print(f"resolved verb occurrences: {occurrences}")
    print(f"distinct verbs w/ example: {len(out)}")
    print(f"  -> {100*len(out)/len(keys):.1f}% of the dictionary has >=1 example")
    print(f"unmatched gloss tokens   : {sum(unmatched.values())} "
          f"({len(unmatched)} distinct)")
    print(f"\nJSON written to {os.path.relpath(OUT_JSON, ROOT)}")

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
