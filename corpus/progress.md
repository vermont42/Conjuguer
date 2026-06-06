# Progress — Chanson de Roland full-treatment build

Last completed: laisse CLI / line 2033 (2026-06-05).

Done: laisses I–CLI (lines 1–2033), all in the per-laisse-block format (original +
verb brackets immediately followed by translation). This reaches the death of Oliver
and Roland's lament over him — roughly the midpoint of the poem.

Next: laisse CLII / line 2034 onward.

## Numbering note (IMPORTANT — read before continuing)
The raw source `corpus/chanson-roland-oxford.txt` has a defect: the folio marker
`f.24rv` occupies source row-number **1311**, so the source's printed numbers run **+1
ahead of canonical Bédier from laisse CIII onward** (confirmed: `La bataille est
merveilluse e cumune` = canonical 1320 but source 1321). Per the user's decision we use
**canonical Bédier numbering**: the folio row is dropped and from laisse CIII,
**canonical = source printed number − 1** (until any further source anomaly — the
header says the Baligant section has 3 lacunae occupying numbered slots, which may
re-align the offset; re-derive the offset there).

To process the next chunk: regenerate a canonical-numbered helper like
`corpus/_canon_CII_CLI.txt` (the script drops the folio row, applies the −1 offset, and
marks lacunae), or compute canonical = source−1 inline and watch for new anomalies.

The 3 narrative lacunae in I–CLI (CVIII after 1388, CXXVI after 1664, CXXXIV after
1775) are unnumbered — each carries a `<!-- lacuna -->` note and consumes no line
number. More lacunae lie ahead in the Baligant section.

Edition note: laisse I uses the UT-Austin Bédier text; laisses II+ are transcribed
verbatim from the orbilat raw source.

Consistency: full-file checker passes — 151 laisses, lines 1–2033, gap-free, every
original line has a matching translation line.
