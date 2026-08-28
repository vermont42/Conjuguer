# frequency

The build-time pipeline that gives every one of Conjuguer's 6,326 distinct infinitives a
frequency-of-use ranking. The research behind the source choice — what a paid Sketch Engine
plan does and does not buy, how the candidate corpora compare on coverage, register, and
licence — is [`docs/verb-frequency-sources.md`](../docs/verb-frequency-sources.md).

This folder sits at the repo root deliberately: `Conjuguer/` is an Xcode *synchronized*
folder, so any file placed under it joins the app target. Nothing here ships.

## What the app ends up with

`Conjuguer/Models/verbs.xml` stores **counts**, not ranks, and `VerbParser.ranked(_:)`
derives the rank once per launch. A rank is a property of the corpus rather than of the
verb, so storing ranks would make adding one verb renumber every verb below it.

| Attribute | Meaning |
|---|---|
| `hi` | FrWaC lemma hits — the primary key. Measured from GLÀFF, or an estimate when flagged `hp` |
| `hn` | Le Monde (LM10) lemma hits, the first tie-breaker |
| `hl` | Frantext 20e lemma hits, the second tie-breaker |
| `hs` | Lexique 4 subtitle frequency × 1000 (thousandths per million), the third tie-breaker |
| `hp` | `y` when `hi` is an estimate rather than a measured GLÀFF count |

Every verb has `hi`; the rest appear only where a source measured them. A missing count
ranks *below* a measured zero, and the infinitive in French collation settles what is left.
`docs/frequencies.txt` renders the resulting order, one `<rank> <infinitive>` per line.

## Sources

Both are ignored by git — 206 MB between them, and both are re-downloadable. The SHA-256s
pin the snapshots the shipped counts came from.

### GLÀFF 1.2.2 — the primary source

Sajous, Hathout & Calderone, CLLE-ERSS, Université de Toulouse. 1.4 million inflected forms
extracted from Wiktionnaire, each carrying lemma frequency counts from three corpora: FrWaC
(web, ≈ 1.25 billion words), LM10 (ten years of *Le Monde*, ≈ 220 million), and Frantext 20e
(≈ 29 million). It lists 6,284 of the 6,326 infinitives, 6,283 of them with a usable FrWaC
count — see *Quarantined FrWaC counts* for the one exception.

| Fact | Value |
|---|---|
| Downloaded | 2026-08-28, from the CNRS mirror on Hugging Face |
| `glaff-1.2.2.txt` | 157,216,000 bytes, SHA-256 `e23a69b397a20e79cc59bbbe1918803a8b3d2df2494249c20538ebd0cfbf05c6` |
| `oldiesSubLexicon.txt` | 494,635 bytes, SHA-256 `00035c26e0310e83e30bdc542c5292831eb62dfd0e92d0743aaaf6da25acc927` |
| Licence | CC BY-SA 3.0. `GLAFF-README.txt` is tracked here because the licence asks that it accompany any redistribution, and `verbs.xml` redistributes derived counts |
| Citation | Sajous, Hathout & Calderone (2013), *GLÀFF, un Gros Lexique À tout Faire du Français*, TALN 2013 — the BibTeX is in `GLAFF-README.txt` |
| Homepage | `http://redac.univ-tlse2.fr/lexiques/glaff_en.html` (it refused connections on the research day and was back up on the build day; the Hugging Face mirror is the reliable download) |

`oldiesSubLexicon.txt` holds GLÀFF's obsolete, dated, and archaic entries. It carries **no**
frequency columns, so it contributes no counts — the pipeline reads it only to tell whether
a verb missing from the main lexicon is a Wiktionnaire archaism (`bienvenir`, `occire`)
rather than an oversight.

### Lexique 4.00 — tie-breaker and calibration

New, Pallier, Schalchli, Bourgin & Gimenes (2026). 316 million words of film and television
subtitles. It covers 5,630 of the infinitives, and matters for two jobs: breaking ties GLÀFF
leaves, and giving the hyphenated compounds GLÀFF excludes by design a count to calibrate
from.

| Fact | Value |
|---|---|
| Downloaded | 2026-08-28 from `lexique.org` |
| `Lexique400.zip` | 48,794,914 bytes, SHA-256 `8ed5a64373ae798f0485a2a35848c09286b6694c6859abeaab6806594c046993` |
| Licence | CC BY-SA 4.0 |

**One licence discrepancy, resolved.** The download page's licence *link* points at CC
BY-NC 4.0 while its *text* says BY-SA. The archive itself carries a `README-Lexique.txt`
saying CC BY-SA 4.0 and a CC BY-SA licence file, so the archive is authoritative and the
page's link is a slip. If it ever needs settling, one sentence to `boris.new@univ-smb.fr`
is cheap.

### Re-downloading

```bash
curl -sSLo frequency/glaff-1.2.2.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/resolve/main/data/glaff-1.2.2.txt"
curl -sSLo frequency/oldiesSubLexicon.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/resolve/main/data/oldiesSubLexicon.txt"
curl -sSLo frequency/GLAFF-README.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/raw/main/data/README.txt"
curl -sSLo frequency/Lexique400.zip "http://www.lexique.org/databases/Lexique400/Lexique400.zip"
unzip -q frequency/Lexique400.zip -d frequency/
shasum -a 256 frequency/glaff-1.2.2.txt frequency/oldiesSubLexicon.txt frequency/Lexique400.zip
```

## The scripts

| File | Role | Tracked |
|---|---|---|
| `build_counts.py` | Both lexicons → `verb-counts.json` + `report.md`; runs the estimate tiers and the gates | yes |
| `apply_counts.py` | `verb-counts.json` → the `hi`/`hn`/`hl`/`hs`/`hp` attributes of `verbs.xml` | yes |
| `generate_frequencies_txt.py` | `verbs.xml` → `docs/frequencies.txt`, in `VerbParser.ranked(_:)`'s exact order | yes |
| `verb-counts.json` | One row per distinct infinitive: measured counts and, where needed, `frwac_estimate` | yes |
| `editorial-counts.json` | The hand-assigned tier: seven verbs, each with a one-line reason | yes |
| `report.md` | The last build's report | no |

```bash
python3 frequency/build_counts.py             # --dry-run to report without writing
python3 frequency/apply_counts.py             # --dry-run likewise
python3 frequency/generate_frequencies_txt.py # --check to compare without writing
xmllint --noout --valid Conjuguer/Models/verbs.xml
```

`build_counts.py` refuses to write if any infinitive would end up without a count, if the
top three are not `être`/`avoir`/`faire`, if the calibration's R² falls below 0.6, or if an
estimate exceeds the clamp. Its Spearman-continuity section only works on the first run:
`apply_counts.py` removes the 2021 `fr` ranks it compares against.

## No verb goes without a count

Absence from GLÀFF is not evidence of rarity — it excludes hyphenated compounds *by design*,
and `sous-estimer` (11.5 per million in subtitles) is not a rare verb. So the 43 infinitives
GLÀFF does not measure get an **estimated** FrWaC-equivalent, stored in `hi` like any other
count and flagged `hp="y"`, through three tiers in order of preference:

1. **`lexique4-fit`** (26 verbs) — the verb is in Lexique 4, so convert its per-million
   figure with a least-squares fit of `log(frwac)` on `log(lexique4)` over the ≈ 5,600 verbs
   both sources count. The 2026-08-28 fit was `log(frwac) = 7.58 + 0.76·log(lex4)`, R² 0.69,
   typical error ±2.6× — a few hundred rank places mid-list.
2. **`base-ratio`** (10 verbs) — a compound in no source: the base verb's measured count
   times a prefix ratio, the median of `lexique4(prefix-X) / lexique4(X)` over the pairs
   Lexique 4 does have for that prefix.
3. **`editorial`** (7 verbs) — a rarity in no source: a hand-assigned count from
   `editorial-counts.json` with a stated reason. Zero is an acceptable entry; the point is
   that the number is chosen rather than missing.

**The clamp.** No estimate may exceed the measured count at rank 1,000 (13,773 hits on
2026-08-28), so an estimate can never place a verb in the top of the list.

**A measured zero stays zero** and is never estimated: a corpus that could have seen the
verb and did not is data. 116 verbs share a count of zero and take the last ranks in French
alphabetical order.

## Quarantined FrWaC counts

A few GLÀFF lemmas failed to join against FrWaC: every form, the infinitive included,
carries ~0 hits while Le Monde and Frantext count the verb in the hundreds. A
1.25-billion-word web corpus cannot contain zero occurrences of `convaincre`, so such a
count is a defect rather than a measurement. `build_counts.py` treats those rows as
unmeasured and routes them through the estimate tiers, which is why `convaincre` carries
`hp="y"`.

The thresholds (FrWaC below 2% of the larger of the other two counts, which must itself be
at least 200) sit deliberately far from any honest register difference. On 2026-08-28 they
caught exactly one verb. The register outliers the research flagged — `faillir` and
`étayer`, *inflated* in Le Monde by a lemmatizer collapsing `fallait` and `étais` onto them,
not depressed in FrWaC — stay measured, as they should.

## A spelling audit this pipeline provoked

The first build's editorial tier had nine verbs rather than seven, because `verbs.xml`
carried both `ahaner` and `ahanner`, and both `haubaner` and `haubanner` — the standard
spelling measured by GLÀFF, and a doubled-*n* duplicate with the same translation and the
same model that no corpus had ever heard of. The duplicates were deleted rather than
estimated. The unmeasured population went from 45 to 43 without a single count changing,
which is the shape a data-quality fix should have: the gap closed because the gap was an
error.

The lesson generalizes. A verb that every corpus misses is sometimes rare and sometimes
misspelled, and the editorial tier is where the difference shows up, because writing a
justification for a count forces the question. Read that file's reasons before trusting it.
