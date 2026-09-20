# Verb pass: working plan (2026-09-20)

**Status:** Stage A and Stage 0 both ran on 2026-09-20 and are complete; nothing is committed
yet. Josh approved the five decisions on 2026-09-20; they are recorded in the last section and
folded into the stages below. Apart from Stages A and 0, nothing has run yet except the
measurements. Every number here was computed on 2026-09-20 against
`Conjuguer/Models/verbs.xml` (6,330 entries, 6,326 distinct infinitives) and
`literature_examples.json` (1,141 entries covering 1,140 verbs). The journal entries of the
same date in `docs/blog_notes.md` record how each number was obtained and what was verified
in the app's own conjugator.

Order of work: **Stage A** (engine fixes, now) → **Stage 0** (reference data) → **Stage 1**
(deterministic audits) → **pilot** → **Stage 2** (subagent shards) → **Stage 3** (skeptic
pass and report) → **Stage 4** (apply).

**Progress** (implementers update this line): Stage A ✅ 2026-09-20 · Stage 0 ✅ 2026-09-20 ·
Stage 1 ☐ · Pilot ☐ · Stage 2 ☐ · Stage 3 ☐ · Stage 4 ☐

## How implementers keep this plan honest

This plan was written before any of it ran, so it will be wrong in places. The session
that runs a stage owns the plan's accuracy for that stage:

- **Mark what is done.** When a stage or a numbered step is complete, append ✅ and the
  date to its heading (`### A1. Three model definitions in verbModels.xml ✅ 2026-09-21`),
  tick it in the Progress line above, and update the **Status** paragraph at the top.
  Partial completion gets a note, not a checkmark.
- **Correct in place, visibly.** Where the plan proved wrong or incomplete (a file that
  was not where it said, a count that had moved, a step that needed a different order, a
  syntax gloss that misled), do not silently rewrite the text. Leave the original wording
  and add a note directly beneath it, starting `**Correction (YYYY-MM-DD):**`, saying what
  the plan said, what was true, and what was done instead. A paste-able prompt that needed
  a different instruction to work is corrected in place, with the same note.
- **Keep the split with the journal.** The plan carries checkmarks and corrections; the
  narrative of what was tried and why stays in `docs/blog_notes.md`, which CLAUDE.md
  requires anyway. A correction note may point at the journal entry rather than retell it.
- **Later stages read the corrections.** Before starting a stage, read every correction
  note in the stages before it; they are the most reliable sentences in the file.

## The design in one sentence

Deterministic code retrieves and checks against Wiktionary; subagents only judge, in a
single turn, with everything they need pasted into the prompt; a skeptic pass re-examines
every proposed change; Josh approves by frequency band.

## Why the brief changed shape

`prompts/verb_pass.md` asked subagents to check every gloss, verify every example, and write
an example for the 5,186 verbs that lack one. Two measurements moved the centre of gravity.

**Wiktionary covers nearly everything, as data, not as web pages.** kaikki.org publishes
machine-readable extracts of both Wiktionaries. Against the 6,326 infinitives:

| Source | Verbs covered | What it carries per verb |
|---|---|---|
| English Wiktionary (kaikki, dump of 2026-09-02) | 5,560 | English glosses with register/region/transitivity tags, a full conjugation table (5,527 verbs), the auxiliary, an example with translation (1,040 verbs) |
| French Wiktionary (kaikki `fr-extract`) | 6,321 | French definitions with tags, example sentences for 4,714 of the 5,186 verbs lacking one, most with an author/title/year reference; 2,731 of those verbs have a quotation dated 1925 or earlier |
| The app's open corpus tiers (literature, classical, government, technology, wikipedia) | 2,752 of the 5,186 have at least one token hit | full sentences, already licensed and attributed |

The five verbs French Wiktionary lacks: *blistériser*, *casse-croûter*, *enfoncer* (absent
from the extract itself, though the Wiktionnaire page exists), *enkyster*, *humoter*. The
English extract covers *enfoncer* and *enkyster*, so only three verbs have no reference at
all and need a subagent's unaided knowledge; the report should say so.

**Diffing conjugations against Wiktionary's tables finds engine data errors.** Using a stale
July dump of the app's forms, the diff flagged about 150 verbs; a throwaway test run through
`Conjugator.conjugatedString` on 2026-09-20 verified these (correct form in parentheses):

| Verb | App output | Cause |
|---|---|---|
| pouvoir (rank 10) | *ils pouvent* (peuvent) | model `4-6` alters the stem for `r3s` but not `r3p` |
| dire, redire | *vous dîtes* in the présent (dites) | model `5-8A` writes `ÎTES` with a circumflex |
| suivre, poursuivre, ensuivre | participe passé *suivis* (suivi) | model `5-5` has `ep="IS"` |
| rejeter | *je rejetle* (rejette) | on `1-3A` (appeler) instead of `1-3B` (jeter) |
| mener (rank 103) | *je mene*, *je menerai* (mène) | on `1-1` instead of `1-4` |
| changer (rank 93) | *nous changons*, *je changais*, *il changa* (changeons) | on `1-1` instead of `1-2B` |
| lécher, déféquer | *je léche*, *je déféque* (lèche, défèque) | on `1-1` instead of `1-5` |
| empaqueter | *j'empaquete* (empaquette) | on `1-1` instead of `1-3B` |
| assortir | *nous assortons*, *assorté* (assortissons, assorti) | on `1-1` instead of `2-1` |

The generated `VerbModelTests` pin *pouvent*, *dÎTES* and *suivIS*, which is why the suite
never objected: tests generated from the engine can only check the engine against itself.
*lécher* and *déféquer* escaped the August stem-alteration audit because its filter matches
an é exactly one consonant before the ending, and these have two.

The same extract gives the auxiliary. Twenty-two non-reflexive verbs that Wiktionary
conjugates with être take avoir in the app, among them *intervenir* (rank 194, *j'ai
intervenu* verified), *survenir*, *advenir*, *provenir*, *redevenir*, *obvenir*,
*bienvenir*, *retomber*, *redescendre*, *repartir*, *renaître*, *réapparaître*. A further
handful take either auxiliary depending on sense (*passer*, *apparaître*, *paraître*,
*disparaître*, *demeurer*, *remonter*); the app models one auxiliary per entry, and the
policy for those is in the decisions section. Wiktionary also treats 32 verbs as
pronominal-only that carry no `re` attribute (*s'effondrer*, *s'évaporer*, *s'attabler*,
*s'arroger*, *se lamenter*, *se prosterner*, *se recroqueviller*).

Two of the 1,141 shipped examples do not contain the verb at all: *envisager* and
*représenter* (the mining subagent recovered the sentence next to the one with the hit).
A three-line check found them.

**How the glosses were made** (Josh, 2026-09-20): from English Wiktionary where an entry
existed, copying some but not all of its senses; otherwise from a French definition (French
Wiktionary first, then the TLFi and Le Robert reached through Lexilogos) rendered into a
gloss, by Google Translate at least for the TLFi and Robert definitions, sometimes without
the definition being fully understood; otherwise from Linguee, a bilingual corpus that
yields contextual translations rather than dictionary senses. Where no one-word English
gloss existed, or where the only one was a word Josh did not know himself despite a large
vocabulary, he translated the definition instead, on purpose: *accoutrer* is "equip,
furnish with dress" rather than "accouter". A descriptive gloss is therefore often a choice,
not an artifact. Measured against today's
extracts, 4,581 glosses copy English-Wiktionary senses verbatim, 463 partly, 516 match no
English sense although an entry exists now, 763 have no English entry, and 3 have none at
all. Among the verbatim ones, 4,484 lead with the entry's first sense, and English
Wiktionary orders senses by history rather than by use, which is how *abouler* came to be
glossed by its dialectal sense alone; 47 glosses are built only from senses tagged
dialectal, dated, rare or slang while a plain sense exists (a noisy list, but a list). So
the gloss task is mostly sense selection and order for the verbatim majority, and
translation faithfulness for the rest.

## Stage A: fix the verified engine errors now ✅ 2026-09-20

Decision 1. A small, self-contained commit ahead of the pass, so that the pass verifies
against a correct engine and a fresh dump. Paste this into a clean session:

```
Read @prompts/verb-pass-plan.md, Stage A, and carry it out end to end: fix the model
definitions for pouvoir, dire and suivre in Conjuguer/Models/verbModels.xml, re-model
rejeter, mener, changer, lécher, déféquer, empaqueter and assortir in
Conjuguer/Models/verbs.xml, add ay="e" to the seventeen verbs listed, regenerate
VerbModelTests, pin the corrected forms in a new EngineAuditTests file, update the
regular/irregular counts everywhere they live, run the full suite with the ios-build-verify
skill, verify pouvoir and intervenir in the simulator, start docs/release-notes-2.3.txt,
and journal in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

### A1. Three model definitions in `verbModels.xml` ✅ 2026-09-20

| Model | Line (2026-09-20) | Change | Expected forms |
|---|---|---|---|
| `4-6` pouvoir | 53 | append `\|3,2,EU,r3p` to `p=`, the rule *vouloir* (`4-8`, line 55) already uses for *veulent* | *pEUvent* |
| `5-8A` dire | 71 | `1,1,ÎTES*,N,r2p` → `1,1,ITES*,N,r2p` | *dITES*, *redITES*; `5-8B` (*contredire*, *interdire*, *médire*, *prédire*, *dédire*, *confire*) is untouched |
| `5-5` suivre | 68 | `ep="IS"` → `ep="I"` | *suivI*, *poursuivI*, *ensuivI* |

The `p=` syntax is `charsFromEnd,count,replacement,tenses`, so `3,2,EU,r3p` on the stem
*pouv* removes *ou* and yields *pEUv* + *ent*. Confirm against `VerbModel.swift` before
editing rather than trusting this gloss of it.

**Correction (2026-09-20):** the gloss is right, and `StemAlteration.init(xmlString:)` is where
it lives rather than `VerbModel.swift`. All three edits landed as written and produce exactly
the expected forms. Two notes for later stages. The plan gave line numbers 53, 71 and 68; the
lines were 53, 71 and 68 as stated, but an implementer should match on the model id rather than
the line, since any insertion moves them. And `verbModels.xml` does not pass `xmllint --valid`:
its internal DTD never declared the `p`, `dg` or `sb` attributes, so every model carrying one is
reported invalid. That is pre-existing and untouched here. `verbs.xml` does pass, which is what
the Stage 4 acceptance criterion is about.

### A2. Seven re-modeled verbs in `verbs.xml` ✅ 2026-09-20 (eight, in the end)

Edit as text, one attribute per line, keeping the attribute order `in tn [ay] [re] mo …`
(see the emitter in `InputView.swift`); `git diff --stat` must show only these lines.

| Verb | `mo` today | `mo` after | Exemplar | Forms to expect |
|---|---|---|---|---|
| rejeter | `1-3A` | `1-3B` | jeter | *rejeTte* |
| mener | `1-1` | `1-4` | peser | *mÈne*, *mÈnerai* |
| changer | `1-1` | `1-2B` | manger | *changEons*, *changEais*, *changEa* |
| lécher | `1-1` | `1-5` | céder | *lÈche* |
| déféquer | `1-1` | `1-5` | céder | *défÈque* |
| empaqueter | `1-1` | `1-3B` | jeter | *empaqueTte* |
| assortir | `1-1` | `2-1` | finir | *assortissons*, *assorti* |

**Correction (2026-09-20):** there were eight, not seven. Widening
`StemAlterationAuditTests` (step A4) to admit an é before two consonants immediately turned up
**déshypothéquer**, sitting on `1-1` and giving *je déshypothéque*, beside a correctly modeled
`1-5` *hypothéquer*. It moved to `1-5` with the others. The consequence for the counts is in the
A4 note. The attribute-order rule held: every one of these lines needed only the `mo` value
swapped in place, and `git diff` shows one line per verb.
### A3. Seventeen auxiliaries in `verbs.xml` ✅ 2026-09-20

Add `ay="e"` (after `tn`) to: *advenir*, *apparaître*, *bienvenir*, *demeurer*,
*intervenir*, *obvenir*, *passer*, *provenir*, *réapparaître*, *redescendre*, *redevenir*,
*remonter*, *renaître*, *repartir*, *ressortir*, *retomber*, *survenir*. The policy behind
the list is decision 4; the verbs deliberately left on avoir are *paraître*,
*disparaître*, *repasser* and *ressusciter*, and *acharner* goes to the pronominal
adjudication in Stage 2 instead (its living form is *s'acharner*).

**Correction (2026-09-20):** as written, except that `ay` goes **after `tn`**, not after `in`.
The existing file spells it `<verb in="aller" tn="go" ay="e" mo="1-9" …>`, which matches the
`in tn [ay] [re] mo …` order the A2 note gives. None of the seventeen already carried an `ay`.

### A4. Tests, counts, notes ✅ 2026-09-20

- Regenerate `VerbModelTests.swift` the way `TestUtils.swift` documents (uncomment the
  `GenerateVerbModelTests` suite, run it, re-comment it). Its diff should touch exactly the
  models `4-6`, `5-8A` and `5-5`.
- Add `ConjuguerTests/Models/EngineAuditTests.swift` pinning every form in A1, A2 and A3
  through `T.testConjugation`, including *je suis intervenu*, *il est survenu*, *il est
  retombé* and *il est passé* in the passé composé. Mind `conditional_returns_on_newline`.
- Widen `StemAlterationAuditTests` so an é followed by two consonants (*léch-*, *déféqu-*)
  is examined too, and keep its `examined > 150` guard.
- Five verbs leave the regular models, so the split moves from 5,223 / 1,103 to
  **5,218 regular / 1,108 irregular**; `IrregularityMetricTests.testShippingSplitMatchesTheInfoText`
  will fail until `Info.irregularitiesText`, `Info.valuePropositionText` (both languages)
  and `docs/description.txt` say so. Recompute rather than trust these figures.
- Start `docs/release-notes-2.3.txt` with a paragraph in both languages naming the corrected
  forms, as the 2.2 notes did for *considérer*: a user who typed *peuvent* and was marked
  down deserves to know the app was wrong.
- Simulator: open *pouvoir* and *intervenir* in `VerbView` and screenshot both.
- Journal entry. Then regenerate the dump in Stage 0, since the audit must run against the
  corrected engine.

**Correction (2026-09-20):** four things the plan did not anticipate.

*The generated test file was not deterministic.* `T.generateVerbModelTests()` sorted the models
on `exemplar` alone, and *haïr* is the exemplar of both `2-3A` (France) and `2-3B` (Québec), so
the two `testHaïr…` functions traded places between runs and buried the real diff under 120
spurious lines. `TestUtils.swift` now breaks the tie on `id`. With that in place the regenerated
diff is exactly the four lines the plan predicted, touching only `4-6`, `5-8A` and `5-5`.
Regenerating means uncommenting the `GenerateVerbModelTests` suite, running
`run_tests.sh --only-testing ConjuguerTests/GenerateVerbModelTests`, and lifting the printed
source out of `build.log` between the `//  VerbModelTests.swift` header line and the
`✔ Test generateVerbModelTests` line. The emitted `firstPart` re-comments the generator, so the
written file is ready as-is; re-running the filter against a file whose generator is already
commented silently produces nothing, which is worth noticing before overwriting anything.

*The widened stem audit found an eighth verb.* See the A2 note for *déshypothéquer*. The widened
filter allows one **or two** consonants after the é and drops the mute *u* of a final *qu* or
*gu* first, which is what admits *déféqu-* (and *lég-*, *délég-*) as well as *léch-*. The number
of verbs examined rose from 176 to **224**, and the `examined > 150` guard is unchanged.

*The split moved further than the plan predicted.* Six verbs leave the regular models, not five:
*mener*, *changer*, *lécher*, *déféquer*, *empaqueter* and *déshypothéquer*. *assortir* moves
`1-1` → `2-1`, which is regular to regular, and *rejeter* moves `1-3A` → `1-3B`, irregular to
irregular, so neither counts. The shipping split is therefore **5,217 regular / 1,109 irregular**
of the same 6,326, not 5,218 / 1,108. `IrregularityMetricTests`, both Info texts in both
languages and `docs/description.txt` now say so. The French `Info.valuePropositionText` had been
writing the thousands separator as a period (*5.223*); it now uses the space the rest of the
French copy uses.

*The simulator could not be made to show a compound tense.* `pouvoir` and `intervenir` were both
opened in `VerbView` and screenshotted (`docs/screenshots/20260920-120555-pouvoir-peuvent.png`
shows *elles peuvent* with the *eu* in red;
`docs/screenshots/20260920-120624-intervenir-etre.png` shows *Auxiliary: être*). The passé
composé itself lives behind a **Show Compound Tenses** toggle, and five attempts to flip it
(`tap_label.sh`, `tap_xy.sh` on the switch, on the row, after settling) all reported a successful
tap while `AXValue` stayed `"0"`. Possibly the iOS 26 switch is another control the skill cannot
drive, like the segmented pickers. *je suis intervenu* is pinned in `EngineAuditTests` instead.
A future session that needs a compound tense on screen should budget for this.

## Stage 0: reference data ✅ 2026-09-20

Runs after Stage A, in a clean session; Python plus one Xcode test run, no subagents.
Paste:

```
Read @prompts/verb-pass-plan.md, Stage 0, and carry it out end to end: write
corpus/working/build_wiktionary_reference.py and run it to produce the two per-verb
reference files and their metadata, add the conjugation-dump test beside
CorpusFormsDumpTests and run it with the ios-build-verify skill, write and run
corpus/working/build_author_table.py against Wikidata, whitelist the two scripts in
.gitignore, check every acceptance criterion in 0.4, and journal in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

### 0.1 Wiktionary reference files ✅ 2026-09-20

`corpus/working/build_wiktionary_reference.py` (tracked: add it to the `.gitignore`
whitelist beside `build_corpus_index.py`) downloads both extracts into
`corpus/working/wiktionary/raw/` (ignored, re-fetchable; skip a download whose file is
present with the size the server's `Content-Length` reports), streams each file once with a
substring prefilter before `json.loads`, keeps verb entries whose NFC headword is one of the
app's infinitives, and writes:

- `corpus/working/wiktionary/wiktionary_en_verbs.json`: `{ "<infinitive>": [entry, …] }`,
  entry = `{ senses: [ { glosses, tags, examples: [ { text, english, ref } ] } ],
  forms: [ { form, tags } ], head_templates: [expansion…], etymology_text, sounds: [ipa…],
  categories: [name…] }`.
- `corpus/working/wiktionary/wiktionary_fr_verbs.json`: same keying, entry =
  `{ senses: [ { glosses, tags, examples: [ { text, ref } ] } ], n_forms, tags,
  head_templates, categories }`, keeping **every** example (the probe kept three; candidate
  retrieval wants the choice).
- `corpus/working/wiktionary/meta.json`: the URLs, each download's `Last-Modified`, the dump
  date the kaikki page states, and the coverage counts.

Sources: `https://kaikki.org/dictionary/French/kaikki.org-dictionary-French.jsonl` (551 MB;
kaikki marks it deprecated, so if it disappears use
`https://kaikki.org/dictionary/raw-wiktextract-data.jsonl.gz`, 2.7 GB, filtered on
`lang_code == "fr"`) and `https://kaikki.org/dictionary/downloads/fr/fr-extract.jsonl.gz`
(719 MB). Both are CC BY-SA content; `docs/wiktionary-quotation-sources.md` (Stage 4) says
what the app uses them for. The probe scripts under `corpus/working/wiktionary/probe_*.py`
show the working filters; delete them once the script supersedes them. The extracts already
there were produced by the probes on 2026-09-20 and can stay until the script overwrites
them.

*enfoncer* is absent from the French extract itself, not lost by the filter (checked against
the raw file on 2026-09-20); the English extract covers it. Record any such gap in
`meta.json`.

**Correction (2026-09-20):** the section is right and the coverage predictions were exact: 5,560
English, 6,321 French, the same three verbs with no reference at all. Four notes. The raw dumps
were **not** refetched: the probe session's copies were still on disk, and the script's HEAD
request found the server's Content-Length unchanged for both (577,617,820 and 718,568,529 bytes),
which is what the skip check is for. The French reference grew from the probe's 17.8 MB to
19.9 MB, because keeping every example rather than three roughly triples the quotation pool. The
plan's `meta.json` spec asked for "the coverage counts" without saying they differ by edition,
and the first run duly reported `verbs_with_translated_example: 0` and
`verbs_with_conjugation_forms: 0` for the French edition, which is a category error rather than a
finding; the counts are now computed per edition. And the dump dates are scraped from kaikki's
own page footers rather than hardcoded: enwiktionary 2026-09-02, frwiktionary 2026-09-01. The
three probe scripts were deleted, as the section says to do.

### 0.2 Conjugation dump ✅ 2026-09-20

A new `@Test` in the disabled `CorpusFormsDumpTests` suite, `testDumpAllConjugations`,
writing `corpus/working/conjugations.json` as `{ "<verb id>": { "<tense key>": "<form>" } }`:
verb id = `infinitifWithPossibleExtraLetters`; tense key = the `Tense` case name, a dot, and
the `PersonNumber` case name (`indicatifPrésent.firstSingular`, `participePassé`,
`impératif.secondPlural`); every simple tense, both participles, and
`passéComposé.firstSingular` in the masculine so the auxiliary is visible; the form exactly
as `Conjugator.conjugatedString` returns it, NFC, **not** lowercased, alternates left joined
by `/`; skip `radicalFutur`. Run it with the stale-compile recipe in
`prompts/mine-classical-tier.md` (delete the test intermediates, then
`run_tests.sh --only-testing ConjuguerTests/CorpusFormsDumpTests/testDumpAllConjugations`).
Regenerate after every model change. `forms_all.json` stays for the corpus indexers; it is
the wrong shape for auditing (inverted, lowercased so `dÎTES` collapses to *dîtes*, no
feminine or plural participles, single-character forms dropped, the bare futur stem
included as a form).

**Correction (2026-09-20):** written and run as specified; 6,330 verb ids × 48 tense keys →
303,840 forms in 4.3 seconds, and every Stage-A form reads back correctly. Two corrections to the
recipe. **The `--only-testing` filter must carry the trailing parentheses**:
`'ConjuguerTests/CorpusFormsDumpTests/testDumpAllConjugations()'`. The spelling this section
inherits from `prompts/mine-classical-tier.md` omits them, and without them the run reports
`Test run with 0 tests in 1 suite passed`, exits zero and writes nothing, which is
indistinguishable from success. CLAUDE.md has the right form; the older prompt does not. (The
`mine-classical-tier.md` recipe should be corrected too, by whoever next touches it.) Second,
deleting the test intermediates was not needed on this run, though it is harmless: adding a new
`@Test` to an existing file recompiled cleanly. Neither `Tense` nor `PersonNumber` carries its
case name at runtime, so the tense keys come from an explicit table in the test rather than from
reflection.

### 0.3 Author death-year table ✅ 2026-09-20

`corpus/working/build_author_table.py` (tracked, whitelisted) reads every `ref` in the
French reference for the verbs without an example plus the 84 whose example is
Claude-authored (a real quotation could replace those too), strips a leading year, takes
the text before the first comma as the author's name, and drops names that are plainly not
a person: `journal …`, `Wikipédia`, `auteur inconnu`, and anything containing `trad.`,
`traduction` or `traduit`, since a translation carries the translator's rights. That is
about 6,050 distinct names today, 1,248 of them with two or more quotations; Balzac alone
has 506. Resolve them on Wikidata's SPARQL endpoint in batches of 100 labels (French
`rdfs:label`, `wdt:P31 wd:Q5`, `wdt:P570` for the death date), prefer the match with a
writer occupation when a label matches several humans, and treat anything still ambiguous
as unresolved. Cache the raw answers so a re-run costs nothing. Write
`corpus/working/wiktionary/authors.json` as
`{ "<name>": { "qid", "label", "death_year" | null } }` and merge
`authors_overrides.json` last for hand corrections (Dumas père versus fils is the obvious
one). Under decision 2 a quotation is usable only when `death_year < 1931`.

**Correction (2026-09-20):** the design holds, but **matching the French `rdfs:label` is not
enough, and fails silently on the most famous authors.** Wikidata has been migrating labels that
are spelled identically in every language to the multilingual `mul` label and deleting the
per-language ones, so Victor Hugo (Q535) and Jean-Paul Sartre (Q9364) have 526 and 354 claims, a
P570 apiece, and **no French label at all**. A French-only query reports them as non-existent
people rather than erroring. The first full run therefore returned 3,196 no-matches including
Hugo, Sartre, Beauvoir, Nerval and Daudet. Balzac keeps his French label, which is why the probe
that informed this section looked fine. The query now matches `fr`, `mul` and `en`.

Three further changes the section did not anticipate. **Apostrophes:** Wikidata writes U+2019
while a reference uses either that or a straight U+0027, so *Jules Barbey d'Aurevilly* (13
quotations, died 1889) matched nothing; every name is now queried under both spellings, which
affects 263 names. **Namesakes:** the query also asks for `wikibase:sitelinks` and takes the
leader when it has at least five and at least three times the runner-up, which resolves Hugo
against his namesakes without touching genuinely confusable pairs. Dumas stays ambiguous among
four humans, as the section predicts, and is an override. **A canary:** every batch carries
Honoré de Balzac, and a response that comes back without him is retried rather than cached, since
the whole class of bug here presents as an empty answer rather than an error.

Counts from the real run: 19,339 references over 5,270 target verbs → 6,151 distinct author names
(1,593 references dropped as non-person or translation), of which 1,514 resolve to a death year,
1,490 are humans with no death date (alive, correctly unusable), 2,953 match no label and 194 stay
ambiguous. **640 authors died before 1931, accounting for 4,731 quotations, and 2,338 verbs have
at least one public-domain quotation** — against the plan's 2,731 estimate, which was computed
from edition years rather than death years and is therefore the looser rule. The estimate was
"about 6,050 distinct names, 1,248 with two or more quotations, Balzac 506"; the real figures are
6,151, 1,371 and 554, higher because 0.1 now keeps every example rather than three.

Two notes for Stage 1. `authors_overrides.json` holds five hand-checked corrections, each with its
reasoning in the file; for a joint attribution the death year is the **later** of the two, since
the quotation leaves copyright only when both authors have. And that file is the one Stage 0
artifact nothing can regenerate, so **Josh decided on 2026-09-20 to track it**, which widens 0.4's
fourth criterion by one file. Re-including it took three `.gitignore` lines rather than one, since
git never descends into a directory it has already excluded: `!corpus/working/wiktionary/`, then
`corpus/working/wiktionary/*`, then the negation for the file. Everything else under that
directory (the raw dumps, the reference JSON, `authors.json`, the Wikidata cache) stays ignored,
and `git add` of the whole directory picks up only the overrides file.

### 0.4 Acceptance criteria ✅ 2026-09-20

- The three JSON files and `meta.json` exist; English coverage is 5,560 give or take a few,
  French 6,321 give or take a few (the dumps move); `conjugations.json` has 6,330 verb ids.
- The dump proves Stage A landed: `pouvoir` gives `pEUvent` at
  `indicatifPrésent.thirdPlural`, `dire` gives `dITES` at `indicatifPrésent.secondPlural`,
  `suivre` gives `suivI` at `participePassé`, `mener` gives `mÈne`, `changer` gives
  `changEons`, and `intervenir`'s `passéComposé.firstSingular` begins with a form of être.
- `authors.json` resolves every author with five or more quotations, or the journal lists
  the unresolved ones; the count of usable quotations (author died before 1931) is reported
  against the 2,731-verb estimate.
- `git status` shows only the two scripts, the `.gitignore` whitelist lines, the test file,
  and the journal.

**Correction (2026-09-20):** all four met, with two amendments. Criterion 3's first clause is not
met and should not be: **169 authors with five or more quotations stay unresolved**, so the
journal lists them, which is the criterion's own alternative. 92 of the 169 are living authors
with no death date, which is the right answer rather than a gap; the rest are news organizations,
pen names, joint attributions and fuller name forms than any label uses, and leaving them
unresolved is the safe default because unresolved means not public domain. Criterion 4 also shows
`docs/project-structure.md` modified: CLAUDE.md requires the tree cache to name new source files,
and `scripts/check_docs.py` is clean. And it shows one more file than the criterion allows,
`corpus/working/wiktionary/authors_overrides.json`, which Josh decided to track; see the 0.3 note. While adding the whitelist lines I found that
`!corpus/working/mine_classical.workflow.js` had no trailing newline, so the next block's comment
was glued onto it and the pattern matched nothing (`git check-ignore --no-index` confirms the file
fell through to `corpus/working/*`). It survived only because it is already tracked. Fixed.

## Live lookups: which tool for which site

The extracts are the reference; a session consults a site live only for the three verbs
with no reference, for the skeptic's spot checks, and for single-verb confirmations of the
Stage A kind. A handful of lookups at a time, as a reader would make them, never a scraping
run: Le Robert's and Linguee's terms forbid bulk automated access. Send a descriptive
`User-Agent`, and record any blocked URL in the journal. Measured on 2026-09-20 with the
verb *abouler*:

| Site | Works with | Notes |
|---|---|---|
| English and French Wiktionary | `curl` on the MediaWiki API: `/w/api.php?action=parse&page=<word>&prop=wikitext&format=json` | Exact wikitext. WebFetch works on the page but summarizes it. |
| CNRTL: TLFi, Wiktionnaire, Académie 9e | `curl -H 'Accept: application/json' https://www.cnrtl.fr/api/word/<word>` | The portal page is a JavaScript app and comes back empty to `curl` and WebFetch alike. The JSON has a `header` (one-line description, IPA) and `content[]` entries with `id` `tlfi`, `wiktionnaire`, `academie9`, each holding the entry as HTML; strip the tags. `/api/search/<prefix>` autocompletes. |
| Le Robert (dictionnaire.lerobert.com) | `curl -A '<browser user agent>'` | Definition and a full conjugation table are in the HTML. WebFetch is refused with a 403. |
| Larousse (larousse.fr) | `curl` or WebFetch | Both return the entry. |
| WordReference | WebFetch, or `curl -A '<browser user agent>'` | Bare `curl` gets a 403. |
| Linguee | `curl` or WebFetch | A corpus, not a dictionary: a rare verb returns unrelated hits (*abouler* gave surnames). |
| Reverso Context | Chrome MCP only | 403 to `curl` and WebFetch, with or without a user agent. |
| Lexilogos | `curl` | A static portal; it only links onward. |
| Wikidata | `curl` on `https://query.wikidata.org/sparql?format=json&query=…` | Batch labels in one query (Stage 0.3); a descriptive `User-Agent` is Wikimedia policy. |

WebFetch answers a prompt about the page through a small model, so it is lossy and best
for "is the entry there" questions; for exact wording use `curl` and strip tags, or the API.
It also caches a URL for fifteen minutes.

The Chrome MCP is the fallback for Reverso and for any site that starts blocking. Invoke
the `claude-in-chrome` skill before touching any `mcp__claude-in-chrome__*` tool, call
`tabs_context_mcp` first, open a new tab rather than reusing one, and read with
`get_page_text`. It drives Josh's real Chrome, so Chrome must be open with the extension
installed and the site allowed in the extension's permissions; it is interactive and slow,
right for a few lookups and wrong for hundreds; and it must never trigger a dialog, which
would freeze the session.

## Stage 1: deterministic audits (Python, no model)

Runs after Stage 0, in a clean session, no subagents. Paste:

```
Read @prompts/verb-pass-plan.md, Stage 1, and carry it out end to end: write the five
audit scripts under corpus/working/ (whitelisted in .gitignore), run them against
conjugations.json, the two Wiktionary reference files and authors.json, write their
outputs under corpus/working/verb_pass/, build the shard files in the shape 1.6 fixes,
check the acceptance criteria in 1.7, and journal the counts in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

Outputs live under `corpus/working/verb_pass/` (ignored). Each script prints its counts and
writes JSON; none of them changes app data.

### 1.1 `audit_conjugations.py`

Diff `conjugations.json` against the English-Wiktionary forms per tense and person. Map
Wiktionary's tag sets to the app's tense keys (`first-person singular present indicative`
is `indicatifPrésent.firstSingular`, `past participle` is `participePassé`, and so on) and
ignore the systematic differences: rows tagged `multiword-construction`, `alternative`,
`obsolete`, `archaic`, `dated`, `rare`, `nonstandard` or a region; hyphenated reflexive
imperatives; 1990 spellings, which means accepting a Wiktionary form that equals the app's
form with è replaced by é in a futur or conditionnel stem, or with a circumflex dropped
from i or u. Compare the app's form with its uppercase markers lowercased. Write
`audit_conjugations.jsonl`, one line per disagreement: verb, tense key, app form,
Wiktionary form(s), and a `kind` guess (`missing_alteration`, `wrong_model`,
`defective_gap`, `wiktionary_alternative`, `unknown`).

### 1.2 `audit_flags.py`

For every covered verb compare the auxiliary (être rows not tagged reflexive) with `ay`,
pronominal-only (every sense tagged reflexive or pronominal, in either Wiktionary) with
`re`, defective (head template or sense tag) with `dg`, and aspirated h (the category) with
`ah`. Write `audit_flags.json` as `{ "<verb>": [ { flag, app, wiktionary, evidence } ] }`,
disagreements only. Expected today, roughly: 32 pronominal, 2 aspirated, 42 defective, and
an auxiliary list holding only the either-auxiliary verbs decision 4 left on avoir.

### 1.3 `lint_glosses.py`

Against the house style (decision 3): duplicate senses within a gloss; a straight
apostrophe; a semicolon; a leading "to"; British spellings (`-ise`, `-our`, `-re` where an
American form exists); words absent from `/usr/share/dict/words` after stripping
punctuation, minus a whitelist file for proper nouns and French words; glosses sharing no
content word with any English-Wiktionary gloss; a gloss identical to another verb's where
Wiktionary gives the two verbs different senses; and definition-like glosses (six or more
words, or containing *someone's*, *something's* or *oneself*), listed for the subagent to
tighten where a plain word exists and never to replace with a rare one, since a
descriptive gloss was often Josh's deliberate choice. Write `gloss_lint.json` as
`{ "<verb>": [ { rule, detail } ] }`.

It also classifies each gloss's provenance, since the glosses were built from English
Wiktionary where possible: split the gloss on commas outside parentheses, normalize
(lowercase, drop a leading "to", curly to straight apostrophe), and test each sense against
the current English senses and their comma-, semicolon- and "or"-separated parts. Per verb
write `gloss_provenance: { class: "all_verbatim" | "some_verbatim" | "none_verbatim" |
"no_en_entry" | "none", first_sense_is_en_first, only_tagged_senses }`. On 2026-09-20 the
classes counted 4,581 / 463 / 516 / 763 / 3;
`corpus/working/wiktionary/gloss_provenance_2026-09-20.json` holds that run.

### 1.4 `check_examples.py`

For each of the 1,141 entries: the French sentence contains a form of the verb according to
`conjugations.json` (lowercased, plus the participle with the agreement endings `e`, `s`,
`es`); the `token` is such a form and occurs in the sentence; `en` is non-empty; `source`
and `line` point at a line that contains the token where the tier is on disk; and a
sentence reused across verbs contains a form of each. Write `example_integrity.json`.

### 1.5 `build_candidates.py`

For every verb without an example, and for the 84 with a Claude-authored one, gather up to
twelve candidates in this order:

1. Open tiers (all five, `chanson-roland-oxford.txt` excluded): one pass over each `.txt`,
   tokens looked up in the forms of `conjugations.json`, the full sentence recovered by
   expanding from the hit to the nearest `.`, `!`, `?` or `…` on either side across at most
   two lines, capped at 350 characters, ranked by how distinctively verbal the token is (the
   `build_tail_index.py` ranking), at most five, spread across tiers.
2. French-Wiktionary quotations whose `ref` names an author with `death_year < 1931` in
   `authors.json`, whose text is a complete sentence with no `[…]` or `(…)`, at most five,
   with author, title and year parsed from the reference.
3. English-Wiktionary examples that carry an `english` translation, at most two.

Each candidate is `{ kind: "tier" | "wiktionnaire" | "wiktionary_en", source, line, token,
text, english?, author?, title?, year? }`. Write `candidates.json`; a verb with no candidate
gets `[]` and is counted.

### 1.6 `build_verb_pass_shards.py` and the shard contract

Order verbs by frequency rank, cut into shards of 35, and write
`corpus/working/verb_pass/shards/shard_NNN.json`. This file is the contract with Stage 2,
so its shape is fixed here:

```json
{
  "shard": 12,
  "verbs": [
    {
      "id": "abouler", "infinitive": "abouler", "extraLetters": null, "rank": 4213,
      "gloss": "roll along", "model": "1-1",
      "flags": { "re": false, "ay": "avoir", "dg": null, "ah": false },
      "example": null,
      "wiktionary_en": [ { "glosses": ["to hand over or give money or goods; to pay"], "tags": ["Europe", "slang", "transitive"], "examples": [ { "text": "Aboule le fric !", "english": "Hand over the cash!" } ] } ],
      "wiktionnaire": [ { "glosses": ["(Argot) Donner, apporter."], "tags": ["transitive"] } ],
      "candidates": [ { "kind": "wiktionnaire", "text": "…", "author": "Honoré de Balzac", "title": "Le Père Goriot", "year": "1835", "token": "aboulez" } ],
      "audits": { "gloss_lint": [ { "rule": "no_overlap", "detail": "…" } ], "flags": [], "example_integrity": [] },
      "gloss_provenance": { "class": "all_verbatim", "first_sense_is_en_first": true, "only_tagged_senses": true },
      "author_needed": false
    }
  ]
}
```

`example` carries the existing `{ fr, en, source, line, token }` when there is one.
`wiktionnaire` senses keep their tags but drop their examples, which arrive as candidates.
A `--pilot` option writes three shards under `verb_pass/pilot/` with the canaries the pilot
section lists, plus `pilot_answer_key.json`.

### 1.7 Acceptance criteria

- The five outputs and the shard files exist; the journal records every count: conjugation
  disagreements by `kind`, flag disagreements by flag, lint hits by rule, example-integrity
  failures, candidates by kind, verbs with none.
- `audit_conjugations.jsonl` no longer lists the Stage-A verbs; `example_integrity.json`
  lists *envisager* and *représenter*; `gloss_lint.json` lists *dissimuler* (duplicate) and
  *emboucher* (straight apostrophe).
- Roughly 180 shards, every verb in exactly one, every shard valid against the contract.

## Pilot before the full run

Runs after Stage 1, in a clean session, and writes the artifacts Stage 2 and Stage 3 reuse.
Paste:

```
Read @prompts/verb-pass-plan.md, the Stage 2 task list and the Pilot section, and carry
out the pilot end to end: finalize .claude/agents/verb-checker.md and
.claude/agents/verb-skeptic.md, write corpus/working/verb_pass.workflow.js with its output
schema, build the three pilot shards with their canaries, run the pilot as a workflow on
Sonnet 5 (a workflow is intended; use the Workflow tool), rerun the same shards on Haiku
4.5 and Opus 5, score all three runs with score_pilot.py against the answer key, confirm
the agent definition took effect, record the chosen model in decision 5 of this plan, and
journal in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

Deliverables:

- **Agent definitions.** `.claude/agents/verb-checker.md` (`model: sonnet`, `effort:
  medium`, `omitClaudeMd: true`, `tools: Write`) whose body holds the stable rules: the
  house style, the provenance policy (a corpus or quotation sentence is never rewritten; an
  authored sentence carries `Claude (<model>)` and `line: null`), the homograph rule, and
  the output rules. `.claude/agents/verb-skeptic.md` (`model: opus`, `effort: high`,
  otherwise the same) whose body says to refute by default and to cite the evidence that
  decides. Both must exist before the session that spawns them starts. Stubs exist today;
  replace their bodies.
- **The workflow.** `corpus/working/verb_pass.workflow.js` (tracked, whitelisted), modelled
  on `mine_examples.workflow.js`: `args` carries the mode (`check` or `skeptic`), the shard
  numbers to run, the model, and the results directory; `promptFor(n)` pastes the shard
  JSON inline with the Stage 2 task list; each agent **writes its own result file** to
  `corpus/working/verb_pass/results/shard_NNN.json` and returns through `schema` only
  `{ shard, verbs, changes_proposed, wrote_file, context_check }`. The full results cannot
  come back through the workflow's return value: 6,326 verdicts would be several megabytes
  in the orchestrator's context. `context_check` is true when the agent can see
  instructions about Xcode, SwiftLint or ios-build-verify; it must be false in every shard,
  or `omitClaudeMd` did not apply.
- **The result contract**, per verb, inside the result file: `{ id, gloss: { verdict,
  proposed, confidence, evidence }, example: { verdict, issues, proposed_en }, new_example:
  { fr, en, source, line, token, kind } | null, flags: [ { flag, verdict, reason } ],
  notes: [string] }`, with the vocabularies of the Stage 2 task list.
- **Canaries**, built by `build_verb_pass_shards.py --pilot`: five glosses swapped or
  misspelled, the two broken examples, three candidate lists that contain only same-spelled
  nouns, two quotations whose author died after 1930, and every canary's expected verdict
  in `pilot_answer_key.json`.
- **`score_pilot.py`**: precision and recall per task per model, plus the rate of
  unrequested changes to glosses the key marks correct.

Acceptance: both broken examples caught; at least four of the five gloss canaries caught
with at most one false alarm among the correct glosses; all three homograph lists rejected;
both post-1930 quotations rejected; `context_check` false everywhere; the structured
summary valid in every shard. If Sonnet 5 passes, it is the model; if only Opus 5 passes,
Opus 5 with a recomputed cost line. Either way, record it in decision 5.

## Stage 2: the full run

Paste:

```
Read @prompts/verb-pass-plan.md, Stage 2, and run the verb pass: compute the pending shard
list (shards with no valid result file), run corpus/working/verb_pass.workflow.js in check
mode over them in batches of 40 with the model decision 5 records (a workflow is intended;
use the Workflow tool), validate every result file against the contract, re-run shards
whose file is missing or invalid, summarize the counts, and journal in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

Mechanics: about 180 shards. The Workflow tool runs at most 16 agents at once, so a batch of
40 takes a few minutes of wall clock; between batches the orchestrator only recomputes the
pending list, which keeps its own context small. The Workflow size guideline defaults to
ten agents; the prompt above states the scale, and `/config` ("Dynamic workflow size") can
raise the guideline instead. A shard whose agent returns `null` or writes an invalid file is
re-queued; results are files, so nothing is lost to a crash.

### The per-verb task list

This is the contract the pilot turns into the agent definition's rules and the workflow's
prompt. The inputs are the shard entry of 1.6, all inline; each verb comes back as one
object in the result contract of the pilot section.

1. **Gloss verdict**: `ok`, `typo`, `wrong_sense`, `missing_primary_sense`, `order`, or
   `style`, with a proposed gloss when confident, a confidence level, and the Wiktionary
   sense it rests on. What to judge depends on the gloss's provenance class (1.3). A gloss
   that copies English-Wiktionary senses verbatim is judged on **selection and order**:
   whether the commonest sense is present and first, and whether a sense tagged dialectal,
   dated, rare or slang stands alone while a plain one exists; its wording is touched only
   for house style. A gloss that matches no English sense is treated as a translation of
   the French definition and judged on **faithfulness** to it (voice, transitivity, the
   pronominal sense: *apeurer* "be frightened" against the French *effrayer*), with a
   proposed rendering. The definition may have come from the TLFi or Le Robert rather than
   French Wiktionary, and Google Translate did the rendering, so the checker looks for its
   signature: a voice flip, a pronominal sense rendered plain, the wrong sense of a
   polysemous French word, and a definition carried over whole where a plain one- or
   two-word gloss exists. The TLFi, like English Wiktionary, orders senses historically, so an
   archaic first sense is a live risk there too. The three verbs with no reference at all
   are judged from knowledge,
   and the verdict says so. "Commonest" rests on the Wiktionary tags, on French
   Wiktionary's sense order, which tends to lead with current usage where English
   Wiktionary leads with the oldest, and on judgment; the verdict names the sense. An
   English sense added or reworded since the glosses were written is not by itself an
   error. The subagent normalizes to the approved house style rather than merely flagging:
   bare infinitive without "to", senses ordered commonest first, American spelling
   (*-ize*, as the file already has), the curly apostrophe (’), parentheses only for
   register or region, a multi-word phrase where no plain single word exists (an obscure
   one-word equivalent such as *accouter* or *anastomose* may follow the plain phrase but
   never replace it), and short enough to be read aloud (the quiz speaks the gloss under
   VoiceOver).
2. **Existing example verdict**: verb used verbally in a glossed sense, translation
   faithful, form correct, register fit for learners. Propose a fix only to the English;
   a corpus sentence is flagged, never rewritten, so provenance stays honest.
3. **Example selection or authoring**: take the first candidate that is a genuine verbal
   use in a glossed sense (not a same-spelled noun or adjective) and translate it. A
   Wiktionary quotation must be a complete, clean sentence; one truncated with `[…]` is
   skipped. Only when no candidate qualifies, write one, with
   `"source": "Claude (Sonnet 5)"` (or whichever model decision 5 records) and
   `"line": null`, following `docs/authored-examples.md`.
4. **Adjudicate the stage-1 flag conflicts** handed to it (auxiliary, pronominal, defective)
   with a one-line reason. The 32 pronominal candidates belong here; several have a
   legitimate transitive use (*épanouir*, *effondrer* in older prose), so the verdict names
   which sense the app should conjugate.
5. **Anything else**: a misspelled or non-existent infinitive, a duplicate of another entry,
   a gloss that is offensive or dated.

Acceptance: a valid result file for every shard; every verb appears once across them;
`context_check` false everywhere; the journal reports verdict counts by task.

## Stage 3: skeptic pass and report

Paste:

```
Read @prompts/verb-pass-plan.md, Stage 3, and carry it out: write build_skeptic_shards.py
and run it over the Stage 2 results, run verb_pass.workflow.js in skeptic mode on Opus 5
over the skeptic shards (a workflow is intended; use the Workflow tool), write
build_report.py and produce docs/verb-pass-report.md and approvals.json, and journal in
docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

- **`build_skeptic_shards.py`** gathers every proposed change from the results (a gloss
  verdict other than `ok`, an example verdict other than `ok`, every `new_example`, every
  flag verdict that would change the app, every note) into shards of 25 items, each item
  carrying the verb's Wiktionary senses, the current and proposed values, and the checker's
  evidence, under `corpus/working/verb_pass/skeptic/shards/`.
- **Skeptic mode** of the workflow uses `agentType: "verb-skeptic"`; each agent writes
  `skeptic/results/shard_NNN.json` with, per item, `{ id, task, verdict: "upheld" |
  "partly" | "refuted", severity: "error" | "hedge" | "nitpick", reason }`, and checks a
  quotation's public-domain claim against `authors.json` as well. The verb-history
  fact-check dismissed 104 of 188 first-pass findings; expect the same shape.
- **`build_report.py`** writes `docs/verb-pass-report.md`: counts first, then one section
  per task, items ordered by frequency rank, each with the verb, its rank, the current and
  proposed values, the checker's evidence and the skeptic's verdict; refuted items in a
  short appendix. It also writes `corpus/working/verb_pass/approvals.json` with every upheld
  item set to `"pending"`. Josh edits that file to `"accept"` or `"reject"`, by item or,
  through a `defaults` block, by task and rank band, so he reads the top 1,500 closely and
  approves the tail by category.

Acceptance: every proposed change has a skeptic verdict; the report opens with the counts by
task and verdict; the journal records the refutation rate.

## Stage 4: apply

Runs after Josh has edited `approvals.json`. Paste:

```
Read @prompts/verb-pass-plan.md, Stage 4, and apply the approved verb-pass changes: write
apply_verb_pass.py and run it against approvals.json, add the ExampleSource case and
strings for the Wiktionnaire quotation tier, write docs/wiktionary-quotation-sources.md,
update docs/authored-examples.md, the credits text, the Info texts, the App Store
description and every verb count, regenerate VerbModelTests if any model changed, build
and test with the ios-build-verify skill, verify one quotation-tier verb and one changed
gloss in the simulator, extend docs/release-notes-2.3.txt, and journal in
docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

- **`apply_verb_pass.py`** (tracked, whitelisted) reads the results, the skeptic verdicts
  and `approvals.json`, applies only accepted items, edits `verbs.xml` as text with the
  attribute order `in tn [ay] [re] mo …` so that `git diff` shows only the changed lines,
  writes both copies of `literature_examples.json` with `json.dump(indent=1)` and no
  trailing newline, appends authored rows to `docs/authored-examples.md`, and prints what
  it changed by task.
- **App code**: `ExampleSource` gains `.wiktionnaire(author:title:year:)`, parsed from
  `"wiktionnaire|<author>|<title>|<year>"`, with an attribution string in both languages
  through `L.VerbView` (*— Honoré de Balzac, « Le Père Goriot » (1835), via le
  Wiktionnaire*); the credits text gains the tier with its CC BY-SA attribution and stops
  saying "eighty-two". Catalog edits that add or remove an ASCII `"` go through Python, per
  CLAUDE.md.
- **Docs**: `docs/wiktionary-quotation-sources.md` (the extracts, their dates, the
  public-domain rule, the attribution); a row in the source table of
  `prompts/wire-examples-into-app.md`; the verb-with-example count in
  `Info.valuePropositionText` and `docs/description.txt`; `docs/project-structure.md` for
  any new source file. New, and Josh's to veto: the credits text also acknowledges
  Wiktionary as the main source of the glosses (CC BY-SA), which the app has not said so
  far.

Acceptance: `xmllint --valid` passes and the collation check reports only the pre-existing
`visionner > visibiliser` pair; `cmp` finds the two example copies identical; the full suite
passes; `scripts/check_docs.py` is clean; the simulator shows a quotation with its
attribution; the journal names the counts of glosses changed, examples added by kind, and
flags changed.

## Cost and time

Per verb the reference material is small: French-Wiktionary senses with one example average
about 900 characters, English-Wiktionary senses about 220. With app data and candidates,
roughly 600 input tokens per verb.

| Item | Tokens (approx.) | At API rates |
|---|---|---|
| Shard input, 6,326 verbs | 3.8M | Sonnet 5: $8 |
| Shard output incl. thinking | 2.5M | Sonnet 5: $25 |
| CLAUDE.md if not omitted, 180 shards × ~10K | 1.8M | Sonnet 5: $4 |
| Skeptic pass on ~1,000 changes | 1.5M in, 0.4M out | Opus 5: $18 |

About $50 to $60 all in; on a subscription it is plan usage instead. Wall clock: the
Workflow tool runs at most 16 agents at once, so 180 shards of a few minutes each finish in
under an hour. `omitClaudeMd` is worth having (a third of the input tokens, and it keeps
iOS build instructions out of a French-verb judge's context) but it is not the big lever;
single-turn, tool-free shards fed by deterministic retrieval are.

## Decisions (taken 2026-09-20)

1. **Engine fixes first.** Yes: Stage A runs ahead of the pass.
2. **Wiktionary-quotation tier.** Yes, public domain only. The rule is the author's death
   year, not the edition year the reference shows: **author died before 1931**, which
   satisfies both the French term (seventy years, with room for the wartime extensions) and
   the United States rule (published before 1931) without per-author exceptions. Death
   years come from Wikidata; an unresolved author is not public domain. This keeps Balzac,
   Hugo, Flaubert, Zola, Maupassant, Verne, Sue, Sand, Proust, Anatole France and Loti, and
   drops Colette, Gide, Valéry and Saint-Exupéry.
3. **Gloss house style.** Approved as written in Stage 2: bare infinitive, commonest sense
   first, American spelling, curly apostrophe, parentheses only for register or region, and
   a plain phrase over an obscure single word, which was Josh's 2021 practice and is kept
   on purpose.
4. **Verbs that take either auxiliary.** One auxiliary per entry, chosen by the sense the
   entry's gloss leads with, which is the precedent already in the file (*monter*,
   *descendre*, *sortir*, *rentrer* and *retourner* are être despite their transitive avoir
   uses). So être for *passer*, *remonter*, *redescendre*, *ressortir*, *repartir*,
   *apparaître*, *réapparaître* and *demeurer* (whose living sense is "remain"; the pass
   should reorder its gloss), and avoir stays for *paraître* and *disparaître* (avoir leads
   in modern usage), *repasser* (glossed "iron" first) and *ressusciter* (glossed
   transitively first). A second entry, as with *sortir*, only where the senses already
   split the gloss.
5. **Models.** Sonnet 5 for shards, Opus 5 for the skeptic pass, unless the pilot says
   otherwise. The pilot session records the measured choice here.
