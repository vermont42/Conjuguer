# Classical-corpus sources (provenance manifest)

Provenance for the **classical tier** of the French example corpus — 17th-century French
(La Fontaine's *Fables* + Molière's *Œuvres complètes*) mined to bridge the ~700-year gap between
the *Chanson de Roland* (~1100, Old French) and the 19th-century novels of the literature tier.

**Why this tier exists.** Separately from the modern-prose mining (which covers all 982
usage-ranked verbs), `corpus/json/chanson_examples.json` attaches an Old-French *Roland* example to
332 verbs. **144** of those are *not* among the ranked 982, so they had a Chanson example but no
modern one. They are archaic reflexes the poem genuinely contains (`occire`, `quérir`, `gésir`,
`ouïr`, `honnir`, …); the owner wants each honored with a modern example below the Chanson one.
Many never appear in the 19th-century novels, but a good number survive in the classical register —
hence this tier.

**Why this file is tracked.** The raw `.txt` files live under `corpus/originals/classical/`, which
is **gitignored** (re-fetchable from Project Gutenberg — see `CLAUDE.md` › *Literature-Example
Corpus*). This manifest is the durable record: it preserves attribution and lets anyone re-fetch.
Only the derived JSON (`corpus/json/literature_examples.json`) ships in the app.

**License gate.** All five works are **public domain**, distributed by **Project Gutenberg**. La
Fontaine (d. 1695) and Molière (d. 1673) are long out of copyright; the underlying editions are
19th-century Garnier/Hachette printings, themselves PD. Public domain ⇒ **courtesy attribution
only** — no CC/Etalab/share-alike obligations (unlike the wikipedia and government tiers). Standard
Project Gutenberg terms apply to the *ebook packaging* (the header/footer license boilerplate),
which the indexer already excludes from mining via the `*** START/END OF THE PROJECT GUTENBERG
EBOOK ***` markers, so line references point only at the PD body text.

**Why the classical register matters here — and the key risk it cleared.** These editions use
**modernized orthography** (post-1740 spelling: `être`, `connaître`, not `estre`/`congnoistre`), so
their word-forms match the app's generated conjugations. That was the central risk and it is clear —
a smoke test over the tier got a token hit for 99 of the 144 targets. La Fontaine's *Fables* is the
workhorse (most hits); Molière's four tomes add dialogue/comedy register. Pre-1635 authors (Villon,
Rabelais) were deliberately *not* used: their archaic spelling would not match the modern generated
forms without a normalization pass.

Cleaning: the files are used as downloaded from Gutenberg (UTF-8, French accents preserved); only
the Gutenberg header/footer is gated out at index time. The pre-1740 `-oit` imperfect spelling that
survives in a few La Fontaine lines (`étoit`, `avoit`) affects only ~2 of the 144 (common verbs
already covered elsewhere), so no orthographic normalization was applied.

Batch acquired: **2026-06-17** — 5 documents, ~3.0 MB total.

## Documents

| Filename | Title | Author | Gutenberg eBook | Release date | Source URL | License | Retrieved | Size |
|---|---|---|---|---|---|---|---|---|
| lafontaine-fables.txt | Fables de La Fontaine | Jean de La Fontaine | #56327 | 2018-01-07 | https://www.gutenberg.org/ebooks/56327 | Public domain (Project Gutenberg) | 2026-06-17 | 566 KB |
| moliere-oeuvres-t1.txt | Molière — Œuvres complètes, Tome 1 | Molière (Jean-Baptiste Poquelin) | #40086 | 2012-06-26 | https://www.gutenberg.org/ebooks/40086 | Public domain (Project Gutenberg) | 2026-06-17 | 614 KB |
| moliere-oeuvres-t2.txt | Molière — Œuvres complètes, Tome 2 | Molière (Jean-Baptiste Poquelin) | #43535 | 2013-08-22 | https://www.gutenberg.org/ebooks/43535 | Public domain (Project Gutenberg) | 2026-06-17 | 566 KB |
| moliere-oeuvres-t3.txt | Molière — Œuvres complètes, Tome 3 | Molière (Jean-Baptiste Poquelin) | #50173 | 2015-10-10 | https://www.gutenberg.org/ebooks/50173 | Public domain (Project Gutenberg) | 2026-06-17 | 637 KB |
| moliere-oeuvres-t4.txt | Molière — Œuvres complètes, Tome 4 | Molière (Jean-Baptiste Poquelin) | #57270 | 2018-06-04 | https://www.gutenberg.org/ebooks/57270 | Public domain (Project Gutenberg) | 2026-06-17 | 545 KB |

## Attribution string (for app Credits)

> Example sentences for archaic verbs are drawn from the public-domain works of **Jean de La
> Fontaine** (*Fables*) and **Molière** (*Œuvres complètes*), via **Project Gutenberg**.

Source prefixes introduced by this tier (used in `literature_examples.json` `source` fields and the
app's attribution taxonomy): `lafontaine-fables.txt`, `moliere-oeuvres-t1.txt … t4.txt`. Both
authors are public domain → courtesy credit, no license text required.

## Coverage contribution

See the coverage report appended at mine time and `docs/classical-authored.md` for the verbs that
had no genuine verbal use in the tier and were authored instead. The classical tier supplies modern
examples for the survivable archaic verbs; the genuinely-dead-in-modern-prose residue is
AI-authored (explicit `"source": "Claude (Opus 4.8)"`).
