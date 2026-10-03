#!/usr/bin/env python3
"""Emit the second half of the Oxford Roland with Bédier line numbers.

The second half starts at laisse CLII, verse 2035 (Bédier): the last verse of CLI is 2034.

Reads corpus/originals/literature/chanson-roland-oxford.txt and prints laisses
CLII–CCXCI as `<bédier>\t<verse>` rows under `Laisse <roman>` headers, so no
grokking agent ever does offset arithmetic.

Numbering. From verse 1824 to the end, the raw file's row numbers ARE Bédier's.
The first half drifts (the folio row `f.24rv` at raw 1311, Bédier's double number
"1388-9", a lacuna Bédier numbers near 1665, and the stray verse "(Morz est Turpin
le guerreier Charlun)" that Bédier leaves unnumbered at raw 1823), but those
offsets cancel before laisse CLII. This was established on 2026-10-02 by aligning
the raw text against the margin numbers of Bédier's own edition (French
Wikisource, "La Chanson de Roland/Joseph Bédier/La Chanson de Roland/Texte") and
Mortier's (Bibliotheca Augustana); see corpus/working/chanson_progress.md.

Lacunae. The three rows the raw file numbers (3146, 3390, 3494) are lines lost in
the Oxford manuscript that Bédier also numbers: they are emitted as
`<n>\t[lacuna — line lost in Oxford ms]`. Bédier also prints an unnumbered row of
dots after 2055, which the raw file lacks; it is emitted as a `# lacuna:` comment
row and takes no number.

Usage:
  chanson_source.py                    # CLII–CCXCI to stdout
  chanson_source.py --from CLXI --to CLXX
  chanson_source.py --check            # assert gap-free 2034–4002 and the anchors
"""
import argparse
import difflib
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(os.path.dirname(HERE), "originals", "literature", "chanson-roland-oxford.txt")

FIRST_LAISSE = "CLII"
FIRST_LINE = 2035
LAST_LINE = 4002
NUMBERED_LACUNA = "[lacuna — line lost in Oxford ms]"
UNNUMBERED_LACUNA_AFTER = {2055: "# lacuna: narrative gap, unnumbered (Bédier prints a row of dots here; the raw file has none)"}

# Bédier's printed margin numbers (Wikisource transcription of the 1922 edition). The raw text is
# Mortier's reading, so a verse can differ editorially (`[nuit]`, `(illi)`); anchors match fuzzily.
ANCHORS = {
    2035: "Ainz que Rollant se seit aperceüt,",
    2200: "Rollant s'en turnet, le camp vait recercer,",
    2355: "Ço sent Rollant que la mort le tresprent,",
    2400: "Ne voide tere ne alne ne plein pied",
    2600: "Li nostre deu i unt fait felonie,",
    2800: "En cest païs nus sunt tant aproeciez,",
    3000: "Plus de cent milie s'en adubent ensemble.",
    3150: "D'or est la bucle e de cristal listet,",
    3395: "Josqu'a la nuit n'en ert fins otriee. AOI.",
    3500: "A dous Franceis belement en avint.",
    3700: "Baivers e Saisnes, Loherencs e Frisuns;",
    3900: "Granz ies e forz e tis cors ben mollez;",
    3985: "La baptizent la reïne d'Espaigne:",
    4000: "«Deus,» dist li reis, «si penuse est ma vie!»",
}

ROMAN = {"I": 1, "V": 5, "X": 10, "L": 50, "C": 100}


def roman_value(s):
    total = 0
    for a, b in zip(s, s[1:] + " "):
        v = ROMAN[a]
        total += -v if b != " " and ROMAN.get(b, 0) > v else v
    return total


def read_second_half():
    """[(roman, [(number or None, verse)])] for laisses CLII onward."""
    laisses = []
    started = False
    for line in open(RAW, encoding="utf-8"):
        line = line.rstrip("\n")
        m = re.match(r"^Laisse ([IVXLC]+)$", line)
        if m:
            started = started or m.group(1) == FIRST_LAISSE
            if started:
                laisses.append((m.group(1), []))
            continue
        if not started or line.startswith("#") or "\t" not in line:
            continue
        num, verse = line.split("\t", 1)
        if "lacuna" in verse:
            if not num:
                sys.exit(f"unexpected unnumbered lacuna row in laisse {laisses[-1][0]}")
            verse = NUMBERED_LACUNA
        laisses[-1][1].append((int(num), verse))
    return laisses


def emit(laisses, lo, hi):
    out = []
    for roman, rows in laisses:
        if not lo <= roman_value(roman) <= hi:
            continue
        out.append(f"Laisse {roman}")
        for n, verse in rows:
            out.append(f"{n}\t{verse}")
            if n in UNNUMBERED_LACUNA_AFTER:
                out.append(UNNUMBERED_LACUNA_AFTER[n])
    return out


def squash(s):
    s = s.replace("’", "'").replace(" :", ":").replace(" ;", ";").replace(" !", "!").replace(" ?", "?")
    s = s.replace("« ", "«").replace(" »", "»")
    return re.sub(r"\s+", " ", s).strip()


def check(laisses):
    numbers = [n for _, rows in laisses for n, _ in rows]
    expected = list(range(FIRST_LINE, LAST_LINE + 1))
    ok = numbers == expected
    print(f"laisses {laisses[0][0]}–{laisses[-1][0]}: {len(laisses)}; rows {numbers[0]}–{numbers[-1]}: "
          f"{len(numbers)}; gap-free: {ok}")
    verses = {n: v for _, rows in laisses for n, v in rows}
    for n, want in ANCHORS.items():
        hit = difflib.SequenceMatcher(None, squash(verses[n]).lower(), squash(want).lower()).ratio() > 0.85
        ok &= hit
        print(f"  anchor {n}: {'ok ' if hit else 'BAD'} {verses[n]!r}")
    lacunae = [n for n, v in verses.items() if v == NUMBERED_LACUNA]
    print(f"numbered lacunae: {lacunae}")
    ok &= lacunae == [3146, 3390, 3494]
    print("PASS" if ok else "FAIL")
    return ok


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--from", dest="lo", default=FIRST_LAISSE)
    ap.add_argument("--to", dest="hi", default="CCXCI")
    ap.add_argument("--check", action="store_true")
    args = ap.parse_args()
    laisses = read_second_half()
    if args.check:
        sys.exit(0 if check(laisses) else 1)
    print("\n".join(emit(laisses, roman_value(args.lo), roman_value(args.hi))))


if __name__ == "__main__":
    main()
