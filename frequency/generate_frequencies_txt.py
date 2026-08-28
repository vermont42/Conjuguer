#!/usr/bin/env python3
"""Conjuguer/Models/verbs.xml -> docs/frequencies.txt, the ordered verb list.

The ordering is `VerbParser.ranked(_:)`'s, attribute for attribute, so "verb 400" names the
same verb to a script here as to the app. Ranks are over distinct infinitives, so the four
doubled entries (haïr, ouïr, saillir, sortir) occupy one rank each.

Run from the repo root:  python3 frequency/generate_frequencies_txt.py [--check]
"""

import argparse
import os
import re
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERBS_XML = os.path.join(ROOT, "Conjuguer", "Models", "verbs.xml")
OUT = os.path.join(ROOT, "docs", "frequencies.txt")


def french_key(word):
    """Mirrors `compare(_:locale: Util.french)`: accents are a secondary difference, and ICU
    expands the ligatures, so œilletonner sorts under `oe` rather than after every `z`."""
    expanded = word.replace("œ", "oe").replace("Œ", "OE").replace("æ", "ae").replace("Æ", "AE")
    stripped = "".join(c for c in unicodedata.normalize("NFD", expanded) if not unicodedata.combining(c))
    return (stripped.lower(), word)


def ordered_verbs():
    text = open(VERBS_XML, encoding="utf-8").read()
    verbs = {}
    for tag in re.findall(r"<verb [^>]*/>", text):
        infinitif = re.search(r'\bin="([^"]+)"', tag).group(1)

        def count(name):
            match = re.search(r'\b%s="(-?\d+)"' % name, tag)
            return int(match.group(1)) if match else None

        verbs[infinitif] = (
            count("hi"),
            count("hn"),
            count("hl"),
            count("hs"),
            'hp="y"' in tag,
        )

    # An absent count sorts below a measured zero, matching the parser's `nil`-below-`0` rule.
    def sort_key(infinitif):
        hits, newspaper, literature, subtitles, _ = verbs[infinitif]
        return (
            -(hits if hits is not None else -1),
            -(newspaper if newspaper is not None else -1),
            -(literature if literature is not None else -1),
            -(subtitles if subtitles is not None else -1),
            french_key(infinitif),
        )

    return sorted(verbs, key=sort_key), verbs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--check", action="store_true", help="compare without writing")
    args = parser.parse_args()

    ordered, verbs = ordered_verbs()
    provisional = sum(1 for infinitif in ordered if verbs[infinitif][4])
    rendered = "".join(f"{rank} {infinitif}\n" for rank, infinitif in enumerate(ordered, start=1))

    print(f"{len(ordered)} ranked infinitives; {provisional} rest on an estimated (hp) hit count.")

    if args.check:
        existing = open(OUT, encoding="utf-8").read() if os.path.exists(OUT) else ""
        if existing == rendered:
            print(f"{OUT} is up to date.")
            return
        sys.exit(f"{OUT} disagrees with verbs.xml; re-run without --check.")

    open(OUT, "w", encoding="utf-8").write(rendered)
    print(f"Wrote {OUT}.")


if __name__ == "__main__":
    main()
