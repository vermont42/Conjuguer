#!/usr/bin/env python3
"""frequency/verb-counts.json -> the count attributes of Conjuguer/Models/verbs.xml.

Edits the XML as text, one substitution per `<verb …/>` tag, because the file is
hand-indented, carries a DOCTYPE, and keeps a fixed attribute order that a DOM round-trip
would destroy. Replaces the 2021 `fr` rank attribute with the stored counts the app now
ranks from; `frequency/README.md` documents what each one means.

Run from the repo root:  python3 frequency/apply_counts.py [--dry-run]
"""

import argparse
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERBS_XML = os.path.join(ROOT, "Conjuguer", "Models", "verbs.xml")
COUNTS = os.path.join(ROOT, "frequency", "verb-counts.json")

OLD_DTD = '    <!ATTLIST verb fr CDATA #IMPLIED>\n'
NEW_DTD = (
    '    <!ATTLIST verb hi CDATA #IMPLIED>\n'
    '    <!ATTLIST verb hn CDATA #IMPLIED>\n'
    '    <!ATTLIST verb hl CDATA #IMPLIED>\n'
    '    <!ATTLIST verb hs CDATA #IMPLIED>\n'
    '    <!ATTLIST verb hp (y) #IMPLIED>\n'
)


def attributes_for(row):
    estimate = row.get("frwac_estimate")
    hits = row["frwac"] if "frwac" in row else estimate["count"]
    parts = [f'hi="{hits}"']
    if "lm10" in row:
        parts.append(f'hn="{row["lm10"]}"')
    if "frantext" in row:
        parts.append(f'hl="{row["frantext"]}"')
    if "lexique4_per_million" in row:
        parts.append(f'hs="{round(row["lexique4_per_million"] * 1000)}"')
    if estimate:
        parts.append('hp="y"')
    return " ".join(parts)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="report only; write nothing")
    args = parser.parse_args()

    counts = json.load(open(COUNTS, encoding="utf-8"))
    text = open(VERBS_XML, encoding="utf-8").read()

    if OLD_DTD in text:
        text = text.replace(OLD_DTD, NEW_DTD)
    elif NEW_DTD not in text:
        sys.exit("verbs.xml's DOCTYPE matches neither the old `fr` form nor the new count form.")

    changed = 0
    missing = []

    def rewrite(match):
        nonlocal changed
        tag = match.group(0)
        infinitif = re.search(r'\bin="([^"]+)"', tag).group(1)
        row = counts.get(infinitif)
        if row is None:
            missing.append(infinitif)
            return tag
        stripped = re.sub(r'\s(?:fr|hi|hn|hl|hs|hp)="[^"]*"', "", tag)
        replaced = re.sub(r'(\bmo="[^"]*")', r"\1 " + attributes_for(row).replace("\\", "\\\\"), stripped, count=1)
        if replaced != tag:
            changed += 1
        return replaced

    text = re.sub(r"<verb [^>]*/>", rewrite, text)

    if missing:
        sys.exit(f"{len(missing)} infinitives have no row in verb-counts.json: {', '.join(sorted(set(missing)))}")

    print(f"{changed} verb tags rewritten.")
    if args.dry_run:
        print("--dry-run: nothing written.")
        return
    open(VERBS_XML, "w", encoding="utf-8").write(text)
    print(f"Wrote {VERBS_XML}.")


if __name__ == "__main__":
    main()
