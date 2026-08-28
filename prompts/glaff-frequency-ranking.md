# Rank every verb from GLÀFF: counts in `verbs.xml`, ranks at parse time, credits

Clean-session prompt. The ask is [`prompts/freq_prompt.md`](freq_prompt.md): all 6,320 verbs
should carry a frequency-of-use ranking, not just the 981 that a capped Sketch Engine export
covered in 2021. The research that answers it is
[`docs/verb-frequency-sources.md`](../docs/verb-frequency-sources.md) — read it first; it holds
the coverage numbers, the register comparison, the license analysis, and the reasons for every
decision below. This plan turns its recommendation into a data pipeline, an XML migration, app
changes, and credits.

```
Read @prompts/freq_prompt.md (the original ask), @docs/verb-frequency-sources.md (the research
and the decisions), and @prompts/glaff-frequency-ranking.md (this plan), then carry the plan out
end to end: build the frequency/ pipeline, migrate verbs.xml from fr= ranks to stored counts,
derive ranks at parse time the way Konjugieren does, adapt every consumer of Verb.frequency,
update Info.creditsText and Info.valuePropositionText in both languages, build, test, verify in
the simulator with the ios-build-verify skill, journal in docs/blog_notes.md, and commit to main.
```

## Decisions already made — don't re-litigate

From the research doc; each has its reasoning there.

1. **Source: GLÀFF 1.2.2** (Sajous, Hathout & Calderone; CLLE-ERSS, Université de Toulouse;
   CC BY-SA 3.0), mirrored by CNRS on Hugging Face. It covered 99.2% of the distinct
   infinitives when measured; only hyphenated compounds and a few rarities fall outside it.
2. **Primary key: the FrWaC lemma count** (web corpus, ≈ 1.25 billion words). It agrees with
   the existing 981 ranks at Spearman 0.924, so the top of the list barely moves. Web register
   over subtitle register was a deliberate choice for continuity; Lexique 4 is a tie-breaker,
   not the primary.
3. **Tie-breakers, in order,** among verbs with the *same* primary count: GLÀFF's LM10
   (Le Monde) lemma count, then its Frantext20e lemma count, then Lexique 4's `FreqLemme`
   (subtitles, per million), then the infinitive. They break ties; they never stand in for a
   missing primary count (decision 5 does that).
4. **Store counts, not ranks** — Konjugieren's design (`Konjugieren/Models/VerbParser.swift`
   `ranked(_:)`, `Verb.hits`): a rank is a property of the corpus, so storing it makes adding
   one verb renumber every verb below it. Ranks are derived once per launch in the parser.
5. **No verb goes without a primary count — estimate, flag, clamp.** GLÀFF omits hyphenated
   compounds *by design*, so "absent from GLÀFF" is not evidence of rarity: ranked by absence,
   *sous-estimer* (11.5 per million in subtitles) would fall below *bêcheveter*. So a verb GLÀFF
   lacks gets an **estimated FrWaC-equivalent** as its primary count, stored in `hi` like a
   measured one and marked `hp="y"` — Konjugieren's provisional-hits idea (`Verbs.xml`'s `hp`;
   `Konjugieren/docs/verb-sources.md` § *Provisional hit counts*). Three tiers, in order of
   preference:
   - *Calibrated* — the verb is in Lexique 4: convert its per-million to a FrWaC count with a
     log-log fit on the ≈ 5,600 verbs both sources list (measured 2026-08-28:
     `log(frwac) = 7.57 + 0.76·log(lex4)`, R² 0.69, typical error ±2.6× — a few hundred places
     mid-list). Covers 24 of the 33 hyphenated verbs, plus *occire*; puts *sous-estimer* ≈ #1,050,
     *sous-entendre* ≈ #1,700, *pique-niquer* and *sous-titrer* ≈ #2,200.
   - *Structural* — a compound in no source (*contre-manifester*, *entre-regarder*,
     *glisser-déposer*, *lock-outer*, *casse-croûter*, *copiloter*, …): the base verb's measured
     count × a prefix ratio taken from the `sous-`/`contre-`/`entre-` pairs Lexique 4 does have,
     the way Konjugieren scaled derivatives from their bases. About ten verbs; one conservative
     ratio (the median of the measured ones) is enough.
   - *Editorial* — a rarity in no source (*ahanner*, *anathémiser*, *bienvenir*, *blistériser*,
     *coupasser*, *dégober*, *haubanner*, *humoter*, *prompter*): a small hand-assigned count
     from `frequency/editorial-counts.json`, with a one-line reason each. Zero is an acceptable
     entry — it still yields a rank — but choose the number; don't leave the verb out.
   **Clamp:** no estimate may exceed the measured count at rank 1,000 (13,773 hits), so an
   estimate can never place a verb in the top of the list; Konjugieren clamps at its 900th verb
   for the same reason. A measured `0` stays `0` and is never estimated: that is data.
6. **Duplicate entries share a rank.** `haïr`, `ouïr`, `saillir`, and `sortir` each appear
   twice (distinguished by `ex=`); the counts belong to the infinitive, so both entries get the
   same rank and the next rank is not skipped (rank over distinct infinitives).
7. **Measured zeros rank last, alphabetically.** Roughly a hundred verbs are in GLÀFF with
   zero FrWaC hits and nothing in the tie-breakers; they take the final ranks in French
   alphabetical order. That is the only place the alphabet decides, and it is honest: every
   corpus that could have seen them did not.
8. **Credits keep Lexical Computing** as history and add GLÀFF and Lexique 4, with the personal
   note Josh asked for: he studied at the Université de Toulouse during his college years.

## Part A — the data pipeline (`frequency/` at the repo root)

Outside both synced target folders, so nothing here ships. Model it on `corpus/` and on
Konjugieren's `verbdata/` (`verbdata/README.md`, `apply_dwds_frequencies.py`,
`generate_frequencies_txt.py`).

```
frequency/
├── README.md              # provenance: URLs, download dates, SHA-256s, licenses, how to re-run
├── GLAFF-README.txt       # verbatim copy of GLÀFF's data/README.txt — its license asks that it
│                          #   accompany any redistribution, and verbs.xml redistributes derived data
├── build_counts.py        # GLÀFF + Lexique 4 (+ calibration, prefix ratios, editorial file) → verb-counts.json + a report
├── apply_counts.py        # verb-counts.json → verbs.xml attributes (text edit, dry-run flag)
├── generate_frequencies_txt.py   # verbs.xml → docs/frequencies.txt (rank + infinitive)
├── verb-counts.json       # TRACKED: one row per distinct infinitive, ~6,3xx rows, small
├── editorial-counts.json  # TRACKED, hand-maintained: the editorial tier — infinitive, count, one-line reason
├── glaff-1.2.2.txt        # ignored, 157 MB
├── oldiesSubLexicon.txt   # ignored (GLÀFF's obsolete-entries file; scan it too)
└── Lexique400.zip / Lexique4/   # ignored, 49 MB
```

`.gitignore`, mirroring the `corpus/` whitelist pattern already in the file:

```
frequency/*
!frequency/README.md
!frequency/GLAFF-README.txt
!frequency/*.py
!frequency/verb-counts.json
!frequency/editorial-counts.json
```

Downloads (from the research appendix):

```bash
curl -sSLo frequency/glaff-1.2.2.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/resolve/main/data/glaff-1.2.2.txt"
curl -sSLo frequency/oldiesSubLexicon.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/resolve/main/data/oldiesSubLexicon.txt"
curl -sSLo frequency/GLAFF-README.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/raw/main/data/README.txt"
curl -sSLo frequency/Lexique400.zip "http://www.lexique.org/databases/Lexique400/Lexique400.zip" && unzip -q frequency/Lexique400.zip -d frequency/
shasum -a 256 frequency/glaff-1.2.2.txt frequency/oldiesSubLexicon.txt frequency/Lexique400.zip   # into README.md
```

Record in `README.md` the Lexique 4 license discrepancy the research found (the zip's README and
licence file say CC BY-SA 4.0; the website's link points at BY-NC) and the resolution: the
archive is authoritative, and one sentence to `boris.new@univ-smb.fr` is cheap if it nags.

### `build_counts.py`

- **GLÀFF**: `|`-separated; keep lines whose tag (field 2) starts with `V`; lemma is field 3;
  the *lemma* absolute counts are field 8 (Frantext20e), field 12 (LM10), field 16 (FrWaC),
  1-based. Every inflected form repeats the lemma count, so take the max per lemma. Read
  `oldiesSubLexicon.txt` the same way.
- **Lexique 4**: `Lexique4/Lexique4.tsv`, tab-separated; columns `4_Lemme`, `5_Cgram`
  (keep values starting with `VER`), `12_FreqLemme` (per million; max per lemma).
- **Targets**: every distinct `in=` value in `Conjuguer/Models/verbs.xml`.
- **Output** `verb-counts.json`, sorted by infinitive, one row per distinct infinitive:

  ```json
  "abandonner": {"frwac": 64923, "lm10": 23280, "frantext": 4604, "lexique4_per_million": 33.12}
  ```

  Omit a key when the source lacks the verb; a measured zero is written as `0`. Do not round
  Lexique here; `apply_counts.py` converts.
- **Estimates** (decision 5), computed after the measured pass and written into the same rows
  as `"frwac_estimate": {"count": 12374, "method": "lexique4-fit" | "base-ratio" | "editorial",
  "basis": "…"}` — never into `"frwac"`, so a measured count and an estimate cannot be confused:
  1. Fit `log(frwac) = a + b·log(lex4)` by least squares over verbs with both values > 0; print
     `a`, `b`, R², and the residual quartiles. Apply it to every verb Lexique 4 lists and GLÀFF
     lacks.
  2. For compounds still without a count, split on the hyphen (or a known prefix), take the base
     verb's measured count, and multiply by the prefix ratio: the median of
     `lexique4(prefix-X) / lexique4(X)` over the pairs Lexique 4 has for that prefix, falling
     back to the median over all prefixes. Record the base and the ratio in `basis`.
  3. Read `editorial-counts.json` for the rest; refuse to run if any target verb still has
     neither a measured nor an estimated count — that is the "nothing blank" invariant.
  4. Clamp every estimate to the measured count at rank 1,000.
- **Report** to stdout and to `frequency/report.md` (ignored): verbs unmatched in GLÀFF
  (expect ≈ 44: all 33 hyphenated compounds, which GLÀFF excludes by design, plus rarities such
  as *ahanner*, *bienvenir*, *occire*; Lexique 4 covers 25 of the hyphenated ones, so ≈ 19 verbs
  have no source at all),
  verbs at zero in every source, the largest tie groups, the provisional population (how many
  per method, and the implied rank of every estimated verb — the calibrated ones should land
  between ≈ #1,050 and ≈ #5,100), the FrWaC top 30 (must match the research doc's list), and —
  using the `fr=` attributes still in the file — Spearman against the 2021 ranks (expect ≈ 0.92)
  plus the 20 biggest movers. The movers and the provisional table go in the journal.
- **Gates** (refuse to write on failure): every verbs.xml infinitive ends with a measured or
  estimated count; no lemma is matched to a tag that is not verbal; the FrWaC top three are
  `être`, `avoir`, `faire`; the calibration's R² is at least 0.6; no estimate exceeds the clamp.

### `apply_counts.py`

Edit `verbs.xml` **as text**, one regex per `<verb …/>` tag, the way Konjugieren's
`apply_dwds_frequencies.py` does and for the same reasons (DOCTYPE, hand indentation, fixed
attribute order). It:

- removes `fr="…"`;
- inserts, right after `mo="…"`, whichever of these the row has:

  | Attribute | Meaning | Value |
  |---|---|---|
  | `hi` | FrWaC lemma hits — measured, or a flagged estimate (the primary key; the name mirrors Konjugieren's `hi`) | integer |
  | `hn` | LM10 / Le Monde lemma hits (newspaper) | integer |
  | `hl` | Frantext20e lemma hits (literature) | integer |
  | `hs` | Lexique 4 subtitle frequency, `FreqLemme × 1000` rounded (thousandths per million) | integer |
  | `hp` | present (`hp="y"`) when `hi` is an estimate rather than a measured GLÀFF count — Konjugieren's flag, same spelling | `y` |

  For an estimated verb, `hi` gets `frwac_estimate.count` and `hp="y"` follows it. After the
  pipeline every verb has `hi`; `hn`/`hl`/`hs` appear only where measured.
- rewrites the DOCTYPE: drop `fr`, add `hi`, `hn`, `hl`, `hs` as `CDATA #IMPLIED` and
  `hp (y) #IMPLIED`;
- supports `--dry-run` and prints how many tags changed. This one migration touches every
  verb line; that is expected once. Afterward the diff discipline is Konjugieren's: only lines
  whose counts moved may change.

Validate: `xmllint --noout --valid Conjuguer/Models/verbs.xml`.

### `generate_frequencies_txt.py`

Writes `docs/frequencies.txt` (`<rank> <infinitive>`, one per line) using **exactly** the sort
in Part B so "verb 400" means the same verb to a script and to the app; `--check` compares
without writing, and it reports how many ranks rest on `hp` estimates, as Konjugieren's does.
Add the file to `docs/project-structure.md`. It is the ordered list future sessions will hand
to subagents ("etymologies for ranks 982–1,100").

## Part B — app changes

Grep `Verb(` across `Conjuguer/` and `ConjuguerTests/` before changing the initializer; the
call sites are `VerbParser`, `Verb.verbForInfinitif`'s placeholder, `InputView`, and tests.

- **`Models/Verb.swift`.** Add the stored counts (`hits`, `newspaperHits`, `literatureHits`,
  `subtitleFrequency`, all `Int?` — absent stays absent) plus `hitsAreProvisional: Bool` from
  `hp` (Konjugieren carries the same field; it changes no behavior), and make `frequency` a
  non-optional `Int` rank, filled by the parser. Add `withFrequency(_:)` as Konjugieren has. Replace the
  literal `static let maxFrequency = 981` with a `static var rankCount` the parser sets (the
  number of distinct infinitives — 6,328 — the denominator `VerbView` shows). The placeholder in
  `verbForInfinitif` uses `rankCount` as its rank.
- **`Models/VerbParser.swift`.** Parse the five attributes; after the XML pass, run
  `Self.ranked(_:)`: sort distinct infinitives by `hits` descending — measured or estimated,
  the parser does not care; after the pipeline no verb lacks one, and a `nil`, which can only
  mean a hand-added verb the pipeline has not seen, sorts below `0` so nothing crashes — then
  by `(newspaperHits, literatureHits, subtitleFrequency)` descending with `nil` below `0`, then
  by infinitive using `compare(_:locale: Util.french)`; assign rank `index + 1`; give every entry with that
  infinitive (the `ex=` duplicates) the same rank; set `Verb.rankCount`. A short comment
  stating the tie-break order and why duplicates share a rank is the kind of durable rationale
  CLAUDE.md allows. `VerbData.parse()` needs no change — ranking happens inside
  `VerbParser.parse(models:)`, off the main actor, like Konjugieren.
- **`Views/VerbBrowseView.swift`** (`VerbBrowse.makeStore`, ~line 184). The four-branch
  nil-handling sort collapses to `lhs.frequency < rhs.frequency`. Then look at the badge
  (`BrowseRow.Badge(text: "#\(…)")`): `#6328` is two characters wider than `#981` — screenshot
  the list and the grid on iPhone 17 and check the pill does not clip or wrap.
- **`Views/VerbView.swift`** (~line 121). `"\(frequency) / \(Verb.rankCount)"`; the `if let`
  goes away.
- **`Utils/WidgetSnapshotWriter.swift`** (`eligibleVerbs()`, ~line 93). Today the pool is
  "verbs with a rank" — the 981 that also have examples and etymologies. With every verb
  ranked, the same filter would put *abcéder* on someone's lock screen with no example. Make
  the pool "verbs with a literature example": `ExampleData.example(for: $0) != nil`, sorted by
  rank. `verbOfTheDay` indexes by `eligible.count`, so the verb shown on a given date changes
  once; say so in the journal. Update `WidgetSnapshotWriterTests` accordingly.
- **`ConjuguerTests/Models/CorpusFormsDumpTests.swift`** (~line 44). "Usage-ranked" here means
  the verbs the example corpus was mined for. Replace `frequency != nil` with a rank cutoff
  constant (1,000), fix the header comment that says "~981 usage-ranked", and keep the
  `.disabled` trait — it is a build tool.
- **`Views/InputView.swift`** (emitter, ~line 170; construction, ~line 83). Emit `hi`/`hn`/
  `hl`/`hs`, and `hp="y"` when provisional, instead of `fr`; construct with
  `frequency: Verb.rankCount`.
- **`ConjuguerTests/Models/ParserTests.swift`.** Add tests: counts and `hp` parse (`hitsAreProvisional` true, rank unaffected); a verb with more
  hits ranks first; ties fall through the tie-breakers in order; absent attributes rank after
  `0`; two entries for one infinitive share a rank and the next infinitive is not skipped;
  `rankCount` equals the number of distinct infinitives.
- **Delete `Conjuguer/Models/frequencies.xml`** (bundled, never parsed; the 2021 export is
  preserved in git history and described in the research doc). Then fix the caches:
  `docs/project-structure.md` lines 53 and 83; CLAUDE.md's *Data Loading* section (the `fr`
  sentence and the `frequencies.xml` parenthetical); `prompts/etymology-verbs.json`'s
  `description` (it names `frequencies.xml` as its origin — add that it is the 2021 ordering,
  superseded by `docs/frequencies.txt`); a line in `docs/literature-example-corpus.md` saying
  "usage-ranked" there means the 2021 set, now frozen as "the verbs with examples".

## Part C — localization and credits

All edits to `Conjuguer/Assets/Localizable.xcstrings` follow CLAUDE.md: Python on the raw file
for any change involving ASCII `"`; JSON validation after every edit; markup (`~`, `‡`, backtick
headings) preserved; French relocalized by the *Relocalization Workflow* rules.

### `Info.creditsText` — three paragraphs, alphabetical by surname like the rest

1. **Keep Adam Kilgarriff, in the past tense.** The paragraph today says Sketch Engine "is the
   source of Conjuguer's verb-frequency data." Make it history: Lexical Computing's Sketch
   Engine supplied the rankings of the 981 most common verbs from 2021 to 2026 — a true credit
   for five years of a feature.
2. **Add Lexique 4** after Xavier Nègre (Nègre < New): Boris New, Christophe Pallier, Gauvain
   Schalchli, Jessica Bourgin, and Manuel Gimenes created Lexique 4, a French lexical database
   (CC BY-SA 4.0) whose subtitle frequencies break ties in ~Conjuguer~'s rankings; URL
   ‡http://www.lexique.org‡.
3. **Add GLÀFF** after Okada & Oguriso and before the backtick heading: Franck Sajous, Nabil
   Hathout, and Basilio Calderone created GLÀFF, a lexicon built from Wiktionnaire at the
   CLLE-ERSS laboratory of the Université de Toulouse and released under CC BY-SA 3.0; its
   FrWaC, Le Monde, and Frantext frequency counts are the source of ~Conjuguer~'s verb-frequency
   rankings. Mirror Konjugieren's DWDS credit in one sentence: the ranking is computed once,
   during development, and compiled into the app. **Then the personal note Josh asked for**, in
   both languages: *Josh Adams, ~Conjuguer~'s developer, studied at the Université de Toulouse
   during his college years.* (FR: *Josh Adams, le développeur de ~Conjuguer~, a étudié à
   l'Université de Toulouse pendant ses années universitaires.*) Include the URL
   ‡https://huggingface.co/datasets/datasets-CNRS/GLAFF‡ or the Toulouse home page, whichever
   is up when you check.

Proper names, license names, and URLs stay untranslated in the French; the French text uses
guillemets and curly quotes, never ASCII `"`.

### `Info.valuePropositionText` (en + fr)

"~Conjuguer~ has frequency-of-use rankings for the top 981 French verbs, from être to ancrer"
becomes rankings for **all** verbs, from *être* to whatever `docs/frequencies.txt` puts last
(name it — the sentence's charm is the concrete pair). Same sentence in the French
("pour les 981 premiers verbes français, d'être à ancrer").

### `README.md`

Add a *Verb frequency* credit paragraph with the citation GLÀFF's README requests (the TALN
2013 BibTeX is in `frequency/GLAFF-README.txt`) and New et al. (2026) for Lexique 4, and state
that `verbs.xml`'s count attributes are derived data under CC BY-SA 3.0 — the app is GPL, the
data file carries its own notice.

## Part D — verification

1. **Sanity of the ranking** before touching Swift: the report's top 30 equals the research
   doc's FrWaC list (*être, avoir, faire, pouvoir, devoir, aller, voir, dire, mettre, permettre,
   …*); Spearman ≈ 0.92 against the old `fr=`; look at the 20 biggest movers and at the three
   suspects the research flagged (*ligner*, *ouvrer*, *téter*) — accept them or note them,
   but do not hand-edit measured counts. Then read the provisional table: the calibrated
   hyphenated verbs should sit in plausible company (*sous-estimer* around #1,000,
   *sous-entendre* around #1,700, *tire-bouchonner* deep in the tail), the structural
   estimates below their base verbs, and nothing estimated above the clamp.
2. Build and test with the skill:

   ```bash
   export IBV_SCRIPTS=$(dirname "$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
   "$IBV_SCRIPTS/build_app.sh" && "$IBV_SCRIPTS/run_tests.sh"
   ```

3. Simulator: `launch_app.sh`; `screenshot.sh verbs_ranked_top` (frequency sort is the
   default; *être* is `#1`); scroll to the bottom or search a tail verb (`abcéder`) and
   `screenshot.sh verbs_ranked_tail` — every row has a badge, and the pill fits `#6328`; open
   the tail verb's `VerbView` and confirm "Frequency: 6,3xx / 6,328"; switch to the grid; open
   Info → Credits and screenshot the GLÀFF paragraph (`RichTextView` must render the `‡` link
   and the `~` bold).
4. `WidgetSnapshotWriterTests` passes with the new pool; `ParserTests` covers the ranking rules.
5. `python3 scripts/check_docs.py` is clean; `docs/frequencies.txt --check` agrees with the app.

## Part E — journal and commit

- Append a dated `##` entry to `docs/blog_notes.md`: the decisions above in a sentence each,
  the report's numbers (measured / estimated per tier / measured-zero / ties), the calibration
  fit, the biggest movers and whether
  any surprised you, the widget-pool change, and what the credits now say. Link the research
  doc rather than repeating it.
- Commit directly to `main`, in whatever slices keep each commit buildable (pipeline + data
  migration; Swift; localization is a reasonable split). The SwiftLint pre-commit hook is
  `--strict`; `guard … else { return }` must break the `return` onto its own line.
- If a release-notes file is in progress (`docs/release-notes-2.x.txt`), add one line:
  frequency rankings for every verb.

## Done criteria

- `frequency/` exists with README, scripts, tracked `verb-counts.json`, and GLÀFF's README;
  large sources ignored; SHA-256s recorded.
- `verbs.xml` carries `hi` on **every** verb (with `hp="y"` on the estimated ones) and
  `hn`/`hl`/`hs` where measured, no `fr`; `xmllint --valid` passes; `frequencies.xml` is gone;
  `docs/frequencies.txt` exists, `--check` is clean, and it reports the provisional count.
- Every verb has a rank; ranks derive in `VerbParser.ranked`; duplicates share; `rankCount`
  replaces the 981 literal; the widget pool is example-backed; all tests pass.
- Credits (en + fr) carry Lexical Computing as history, Lexique 4, GLÀFF with the Toulouse
  note, and `valuePropositionText` no longer says 981.
- Journal entry written, caches updated, `check_docs.py` clean, committed to `main`.
