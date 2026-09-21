# Verb pass: working plan (2026-09-20)

**Status:** Stages A, 0, 1 and A2 all ran on 2026-09-20 and are complete; nothing is committed
yet. Stage A2 was written into this plan on 2026-09-20, after Stage 1's conjugation audit found
engine errors with no route through Stages 2–4. Josh took decision 6 on
2026-09-20: the rectified spelling, and A2 applied it. The pilot is next. Josh approved the five decisions on 2026-09-20; they are recorded in the last section and
folded into the stages below. Apart from Stages A and 0, nothing has run yet except the
measurements. Every number here was computed on 2026-09-20 against
`Conjuguer/Models/verbs.xml` (6,330 entries, 6,326 distinct infinitives) and
`literature_examples.json` (1,141 entries covering 1,140 verbs). The journal entries of the
same date in `docs/blog_notes.md` record how each number was obtained and what was verified
in the app's own conjugator.

Order of work: **Stage A** (engine fixes, now) → **Stage 0** (reference data) → **Stage 1**
(deterministic audits) → **Stage A2** (the engine errors Stage 1 found) → **pilot** → **Stage 2**
(subagent shards) → **Stage 3** (skeptic pass and report) → **Stage 4** (apply).

**Correction (2026-09-20):** Stage A2 is new, added after Stage 1 ran. Stage 1.1 found engine
errors Stage A missed, and the plan as written had nowhere to put them: the Stage 2 result
contract has no conjugation field, `build_skeptic_shards.py` has no task for one, `approvals.json`
has no band for one, and `apply_verb_pass.py` edits `verbs.xml` but never `verbModels.xml`. Rather
than thread a sixth task through four stages for 43 verbs, A2 fixes them the way Stage A did, for
the reason Stage A gives: the pass should verify against a correct engine. **A2 does not block the
pilot**: none of its 43 verbs is in a pilot shard, and the pilot measures the model, not the data.
It does block Stage 2's full run.

**Progress** (implementers update this line): Stage A ✅ 2026-09-20 · Stage 0 ✅ 2026-09-20 ·
Stage 1 ✅ 2026-09-20 · Stage A2 ✅ 2026-09-20 · Pilot ☐ · Stage 2 ☐ · Stage 3 ☐ · Stage 4 ☐

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

## Stage 1: deterministic audits (Python, no model) ✅ 2026-09-20

**Correction (2026-09-20):** seven files, not five. The five audits plus
`build_verb_pass_shards.py` all read the same five inputs, so the verb list with its ranks, the
conjugation dump, both Wiktionary references, `authors.json` and the defect groups are loaded once
in a new `corpus/working/verb_pass_lib.py`. There is also a hand-maintained
`corpus/working/gloss_lint_whitelist.txt` (see the 1.3 note). All eight are whitelisted in
`.gitignore`; everything under `corpus/working/verb_pass/` stays ignored.

**Correction (2026-09-20): nothing exports the frequency rank, and one of the plan's ranks is
stale.** `verb_pass_lib.load_verbs()` reproduces `VerbParser.ranked(_:)` — group by infinitif,
order on (hi, hn, hl, hs) with a missing count last, break ties on the infinitif under French
collation. *mener* 103, *changer* 93 and *intervenir* 194 all come back exactly as this plan
states them, which is the check that matters. **`pouvoir` is rank 4, not the rank 10 the Stage A
table gives**; that number predates the August GLÀFF reranking. Do not validate a ranking against
`corpus/working/forms.json`: it is a July file built on the 2021 ranks and disagrees by about
twenty verbs in each direction. Note also that `Verb.id` parenthesizes the extra letters
(`haïr (France)`), while `VerbParser`'s dictionary key does not (`haïr France`); `conjugations.json`
and the shards use the parenthesized spelling.

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

**Correction (2026-09-20):** ran as specified and found six engine errors Stage A missed, but the
`kind` vocabulary needed a sixth value and two of the "systematic differences" were not the ones
the section names. Result: **579 disagreements over 43 verbs**, and none of the Stage-A verbs.

*The find.* **vivre**, **survivre** and **revivre** conjugate the passé simple on the present stem
(*je vivis* for *je vécus*), twelve forms each, at ranks 41, 697 and 1203. **relever** (rank 152) is
on `1-1` and gives *je releve* for *je relève*, which is the *mener* bug again. **sevrer** produces
*je seère*, a broken alteration rather than a missing one. **jauger** and **gamberger** give
*je jaugais* for *je jaugeais*, the *changer* bug twice more. **parfumer** is modeled `5-1A` and
gives the imperative *parfums*. Then singletons: *résous* for *résolu* (résoudre), *faillu* for
*failli* (faillir), *bouille* for *bous* (bouillir), *luisit* for *luit* (luire, reluire),
*éclot* for *éclôt* (éclore, enclore, forclore, déclore), *échoyant* for *échéant* (échoir), and
*amuïr* losing its diaeresis throughout. **briqueter** on `1-1` matches neither spelling Wiktionary
offers.

*The sixth kind.* The app spells the -eler/-eter family the traditional way (*déchiquetterais*,
*ruissellerais*) and Wiktionary gives the grave-accent spelling the 1990 rectifications made the
recommendation for every such verb but *appeler*, *jeter* and their compounds. Both are current
French, and it is 252 of the 579 rows over twelve verbs, so labelling them `wrong_model` would
bury everything else. They get `eler_eter_doubling`. Which spelling the app should ship is a
decision for the pass.

*`defective_gap` had to be computed, not guessed.* `verb_pass_lib.load_defect_groups()` decodes
`defectGroups.xml` the way `DefectGroup.init` does (the `uo`/`du` shorthands, `rA`/`iA`/`pp`/`h2p`
and the rest); a row whose tense the verb's paradigm marks unused gets that kind. 72 rows.

*The reflexive rule in this section is not enough.* The plan says to ignore "hyphenated reflexive
imperatives". But wiktextract tags a table `reflexive` only when the verb *also* has a plain
conjugation; a verb it treats as pronominal-only conjugates its whole table with the pronoun
attached and no tag at all (*m'abstiendrais*). Stripping the pronoun from **every** row rather than
from the tagged ones removed 876 phantom disagreements, three fifths of the first run. Two smaller
things: wiktextract occasionally files a pronunciation as a form row (`/me.se.ɑ̃/` under
*messeoir*'s participe présent), so forms starting `/`, `\` or `[` are skipped; and the
space/hyphen exemption applies only to the impératif, or it silently swallows real disagreements.

### 1.2 `audit_flags.py`

For every covered verb compare the auxiliary (être rows not tagged reflexive) with `ay`,
pronominal-only (every sense tagged reflexive or pronominal, in either Wiktionary) with
`re`, defective (head template or sense tag) with `dg`, and aspirated h (the category) with
`ah`. Write `audit_flags.json` as `{ "<verb>": [ { flag, app, wiktionary, evidence } ] }`,
disagreements only. Expected today, roughly: 32 pronominal, 2 aspirated, 42 defective, and
an auxiliary list holding only the either-auxiliary verbs decision 4 left on avoir.

**Correction (2026-09-20):** **196 verbs** disagree — 149 pronominal, 45 defective, 3 aspirated h,
1 auxiliary. The pronominal estimate was right in the direction the plan meant it: **33** verbs
Wiktionary treats as pronominal-only carry no `re` (*s'effondrer*, *s'évaporer*, *s'attabler*,
*s'arroger*, *se lamenter*, *se prosterner*, *se recroqueviller*), against the predicted 32. The
other 116 run the opposite way and are the population Stage 2's task 4 adjudicates.

*Read every compound row, not the first.* A verb taking either auxiliary by sense carries **both**
rows in the English extract, avoir first. Reading the first row reported *monter*, *descendre*,
*partir*, *sortir*, *tomber*, *rentrer* and *retourner* as errors, which is decision 4 being
reported as fourteen bugs. Standing down when both rows appear leaves one genuine finding,
*débrayer* (être in Wiktionary, avoir in the app); the seventeen are already applied.

*The aspirated-h signal is not in the Stage 0 reference.* wiktextract files "French terms with
aspirated h" and "French terms with mute h" as **sense** categories, and
`build_wiktionary_reference.py` keeps only **entry**-level `categories`, which the English edition
leaves null for all but 22 of 5,560 entries (and those 22 are topical). `audit_flags.py` therefore
makes one pass over the raw English dump for the h-initial verbs and caches
`wiktionary/h_classes.json`; with the raw dump gone it reports the check unavailable rather than
finding nothing. Three disagreements, not two, and one is an internal inconsistency: *haïr (France)*
carries `ah="t"` and *haïr (Québec)* does not, though aspiration is a property of the word.

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

**Correction (2026-09-20):** **1,138 of 6,330 glosses** carry a hit — 665 definition-like, 284
duplicate-across-verbs, 254 no-overlap, 73 unknown words, 9 British spellings, and one each of
duplicate sense (*dissimuler*), straight apostrophe (*emboucher*), semicolon (*déglutir*) and,
twice, a leading "to". Three notes.

*The British-spelling rule cannot be generative.* Stripping `-our` to `-or` makes *four* into
*for*; stripping `-re` to `-er` makes *shore* into *shoer* and *where* into *wheer*. Twelve of the
first run's twenty-one hits were that. Those two are closed sets and are now tables. The `-ise`
rule survives, but must also require the `-ise` spelling not to be standard English, or it flags
*promise* and *exercise*.

*The whitelist exists for a reason the plan does not name.* `/usr/share/dict/words` on macOS is
Webster's 1934: no *blog*, no *email*, no *download*, no *privatize*, and no inflected forms at
all, so the rule first reported 674 distinct unknown tokens led by *one's*. With morphological
back-off, possessive stripping and `corpus/working/gloss_lint_whitelist.txt` (296 lines of modern
English and proper nouns, tracked) it reports 73, and those are worth reading: *someting*,
*stupify*, *jewelery*, *ornement*, *æquivocate*, and the French words *souffrir*, *tuteur*, *vous*.

*The provenance split does not reproduce exactly, and cannot.* The probe that produced
`gloss_provenance_2026-09-20.json` was deleted at the end of Stage 0, as 0.1 instructs, so its
matcher is gone. Reimplementing from this section's description gives **4,606 / 445 / 513 / 763 /
3** against the recorded 4,581 / 463 / 516 / 763 / 3 — within 25 in every class, differing on 296
verbs, all at a class boundary. The recovered rule the description omits is that a gloss sense
counts as copied when an English sense **starts with** it at a word boundary, not only when it
equals it (the record calls *abdiquer* "abdicate" verbatim against "to abdicate (one's powers)",
and *acculer* "corner" against "to corner someone"); without that the counts land 750 away. The
script computes the class rather than reading it from the recorded file, because the only thing it
decides is which of two adjacent judging instructions a borderline verb gets. 4,492 all-verbatim
glosses lead with the entry's first sense and 114 do not; 26 are built only from marginal senses
while a plain one exists, against the plan's 47.

### 1.4 `check_examples.py`

For each of the 1,141 entries: the French sentence contains a form of the verb according to
`conjugations.json` (lowercased, plus the participle with the agreement endings `e`, `s`,
`es`); the `token` is such a form and occurs in the sentence; `en` is non-empty; `source`
and `line` point at a line that contains the token where the tier is on disk; and a
sentence reused across verbs contains a form of each. Write `example_integrity.json`.

**Correction (2026-09-20):** **4 of 1,141 fail**, including the two the plan predicted. *envisager*
and *représenter* both carry the sentence next to the one with the hit; *repérer* fails from the
other side, since it shares *représenter*'s sentence; and *faillir*'s token *failli* is not a form
of the verb **according to the app**, which conjugates *faillu*. That last one is 1.1's finding
arriving through a second door.

The first run reported sixteen, and twelve were the check's fault. A mined token often carries the
reflexive pronoun (*s'adressait*, *s'isolèrent*), which is the right thing to highlight but not a
form of the verb, so it is stripped first. The corpus files use the typographic apostrophe and the
examples file sometimes the straight one, so both are normalized. And **`line` points at where the
sentence starts, not at the token**: the classical tier is hard-wrapped, so *déguerpir*'s recorded
Molière line 15751 begins a sentence whose *déguerpisse* lands on 15753. The check searches a small
window from the recorded line and counts the near misses separately (two). Finally, three example
keys are bare infinitives where the entries carry extra letters (*haïr*, *ouïr*, *saillir*); that is
not a defect, because `ExampleData.example(for:)` falls back from the id to the bare infinitif, and
the check resolves keys the same way.

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

**Correction (2026-09-20):** **5,271 entries** need a list, and they got **9,855 tier sentences,
3,771 public-domain quotations and 719 translated English examples**. 2,834 verbs have a corpus hit
(the plan estimated 2,752) and 2,102 have a usable quotation. That is below Stage 0.3's 2,338
because a *candidate* must also be one complete sentence with no elision, no editorial parenthesis
and under 350 characters, which Stage 0 was not counting. **1,776 verbs have no candidate at all**
and will need an authored sentence; that is the real size of the writing task. The script reuses
`build_corpus_index`'s tokenizer and Gutenberg gating, `build_tail_index.verbalness` for the
ranking, and `build_author_table.author_of` for the reference parsing, so the retrieval behaves the
way the mining pipeline already does.

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

**Correction (2026-09-20):** **181 shards**, 6,330 entries, each in exactly one, ranks monotonic
across files, 14.5 MB total at 80 KB a shard. Two additions to the contract as written. Each record
carries a fifth audit list, `audits.conjugations`, holding that verb's rows from 1.1; without it a
checker sees a wrong form in a candidate sentence with no idea the engine disputes it. And
`author_needed`, which the contract names but does not define, is set when the verb has no example
**and** no candidate was found, so it is exactly the 1,776 of 1.5.

*The pilot had to be restratified.* Built as described — canaries plus filler — it comes out as the
top 105 verbs by rank, because every canary this plan names is a common verb, and those nearly all
have an example already, so the pilot would barely exercise example selection. It now draws 35 from
each of three bands (ranks 1–35, 2000–2035, 5000–5035), one shard each, so a model meets a common
verb with a full English entry, a middle verb with a thin one, and a tail verb with no English
entry. The twelve canaries land as the pilot section asks: five broken glosses (*écrire*,
*acheter*, *manger*, *chanter*, *dormir* — three sense swaps, two misspellings), the two broken
examples, three candidate lists cut to same-spelled nouns (*pincer*, *neiger*, *doucher*, chosen by
filtering on `verbalness` scoring the colliding present-stem form zero), and two post-1930
quotations (*enthousiasmer*, *éprendre*). The homograph and quotation canaries attach only to verbs
that actually need an example, since selecting one is the task they test.

### 1.7 Acceptance criteria

- The five outputs and the shard files exist; the journal records every count: conjugation
  disagreements by `kind`, flag disagreements by flag, lint hits by rule, example-integrity
  failures, candidates by kind, verbs with none.
- `audit_conjugations.jsonl` no longer lists the Stage-A verbs; `example_integrity.json`
  lists *envisager* and *représenter*; `gloss_lint.json` lists *dissimuler* (duplicate) and
  *emboucher* (straight apostrophe).
- Roughly 180 shards, every verb in exactly one, every shard valid against the contract.

**Correction (2026-09-20): all three met.** The five outputs and 181 shard files exist and the
counts are in the journal. `audit_conjugations.jsonl` lists none of the Stage-A verbs;
`example_integrity.json` lists *envisager* and *représenter*; `gloss_lint.json` lists *dissimuler*
under `duplicate_sense` and *emboucher* under `straight_apostrophe`. A validator over all 181 shards
reports every one of the 6,330 entries in exactly one shard, ranks monotonic across files, the
fourteen contract keys on every record and no candidate of an unknown kind. `git status` shows the
eight new tracked files, the `.gitignore` whitelist block, `docs/project-structure.md` (CLAUDE.md
requires the tree cache to name new source files; `scripts/check_docs.py` is clean), the journal and
this plan.

## Stage A2: the engine errors Stage 1 found ✅ 2026-09-20

Runs after Stage 1, in a clean session, before Stage 2's full run. **Decision 6 was taken on
2026-09-20 (the rectified spelling), so A2 is unblocked.** Python plus the `ios-build-verify`
skill, no subagents. Every number below came from
`corpus/working/verb_pass/audit_conjugations.jsonl` on 2026-09-20; recompute rather than trust
them, and match on the model id rather than a line number. Paste:

```
Read @prompts/verb-pass-plan.md, Stage A2, and carry it out end to end: adjudicate the 43 verbs
in corpus/working/verb_pass/audit_conjugations.jsonl, fix the plain errors in A2.1 and A2.2,
record a verdict for every verb in A2.3 and A2.4, apply decision 6 to the twelve -eler/-eter
verbs, regenerate VerbModelTests, extend EngineAuditTests with every corrected form, update the
regular/irregular counts everywhere they live, run the full suite with the ios-build-verify
skill, regenerate conjugations.json and re-run all six Stage 1 scripts, extend
docs/release-notes-2.3.txt, and journal in docs/blog_notes.md.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan
proved wrong or incomplete. Do not commit; Josh commits.
```

The 43 verbs are not 43 decisions, and they account for exactly: **8** plain `mo` errors (A2.1),
**12** decision-6 edits (A2.1b), **6** verbs behind **4** model definition errors (A2.2), **8**
that need a judgement rather than a fix (A2.3), and **9** that are the app being right or are moot
by construction (A2.4). The work is the fourteen verbs in A2.1 and A2.2; the twelve are one-line
edits under a decision already taken.

**Correction (2026-09-20):** the arithmetic held exactly: 8 + 12 + 6 + 8 + 9 = 43, and every verb
landed in the bucket this section predicted. Four things it did not anticipate.

*A2.3 ended in four fixes, not four judgements.* The section calls those eight verbs "needs a
judgement, not a fix", and for four of them the judgement was that the app is wrong: *faillir*,
*échoir*, *seoir* and *messeoir* are corrected here. The other four — *luire*, *reluire*,
*sortir (obtain)* and *clamecer* — end as "the app is right", with the reasoning in the A2.3 note.

*A2 found a forty-fourth error, outside the audit.* While reading *seoir*'s forms the participe
présent turned out to append its ending **once** to a stem that can carry two alternates, so the
*asseoir* family printed `asseY/assOYant` where it should print `asseYant/assOYant`. Four verbs
(*asseoir*, *rasseoir*, *seoir*, *messeoir*), fixed in `Conjugator.swift`. 1.1 could not see it:
the audit splits an app form on `/` and accepts a match on **any** alternate, so *assoyant*
matched and the row never appeared. `NousPrésentStemTests` had pinned the broken string, which is
the generated-test trap again in a hand-written test.

*Three models were added, not two.* `1-4A` (sevrer), `4-9D` (seoir) and `5-13A` (résoudre). That
moves the model count from 95 to 98, which is a number the Info text carries in prose ("one of
ninety-two irregular-verb models") and which A2.5 did not list among the places the counts live.

*No verb needed a new model that A2.1 sent to an existing one.* *amuïr* went to `2-3B` as the
section's first guess; see the A2.1 note.

### A2.1 Plain data errors in `verbs.xml` ✅ 2026-09-20

The model is wrong for the verb. Same shape as A2 of Stage A: swap the `mo` value in place,
keeping the attribute order `in tn [ay] [re] mo …`, so `git diff` shows one line per verb.

| Verb | Rank | `mo` today | App output | Wiktionary | Likely `mo` |
|---|---|---|---|---|---|
| relever | 152 | `1-1` | *je releve*, *je releverai* | *relève*, *relèverai* | `1-4` (peser) — the *mener* fix again |
| parfumer | 1151 | `5-1A` | *je parfums*, *parfumu*, *il parfumit* | *parfume*, *parfumé*, *parfuma* | `1-1` — it is modeled as *rendre* |
| jauger | 2668 | `1-1` | *je jaugais*, *nous jaugons* | *jaugeais*, *jaugeons* | `1-2B` (manger) — the *changer* fix again |
| gamberger | 4219 | `1-1` | *je gambergais* | *gambergeais* | `1-2B` |
| débriefer | 4901 | `1-1` | *il débriefe* | *débrièfe* | `1-4` |
| déficeler | 5142 | `1-1` | *il déficele* | *déficèle* | `1-4` (decision 6) |
| briqueter | 5594 | `1-1` | *il briquete* | *briquette* or *briquète* | `1-4` (decision 6) |
| amuïr | 5380 | `2-1` | *nous amuissons*, *amui* | *amuïssons*, *amuï* | a haïr-like model: see below |

*déficeler* and *briqueter* are in A2.1 rather than under decision 6 because the app spells them
neither way: on `1-1` it neither doubles nor takes the grave. They needed a model whichever way
decision 6 went; decision 6 picked `1-4`.

*amuïr* loses its diaeresis in all 32 disagreeing forms. `2-1` (finir) is right for a thousand
other verbs, so this is a verb error and not a definition one. `2-3B` (haïr Québec) is the
likeliest target, because it is the variant that keeps the diaeresis throughout, where `2-3A`
(haïr France) drops it in the présent singular — *je hais*, which is why `haïr (France)` is
absent from the audit and `haïr (Québec)` is in it. Verify that `2-3B` yields *je m'amuïs* and
*nous amuïssons* before settling; a new sibling may be needed.

**Correction (2026-09-20):** all eight landed as written, one `mo` value swapped in place per
line, and every predicted `mo` was right. Two notes.

*`2-3B` took amuïr without a sibling.* It yields *je m'amuïs*, *nous amuïssons*, *amuï* and
*amuïssant* exactly, because the model is nothing but "regular -ir, with ï wherever the ending
begins with i". The one cost is cosmetic: `VerbView` now prints "Model: haïr (Québec)" for a verb
that has nothing to do with Québec. That wart is pre-existing rather than new, since the modern
*ouïr* entry already sits on `2-3B` beside *haïr*, and a one-verb `2-3C` seemed worse than joining it,
since the Models tab is a browsable list of named patterns and *amuïr* (rank 5380) is a poor name
for one.

*briqueter's `1-4` forms match the grave spelling, which is the one decision 6 chose.* On `1-1`
the app gave *il briquete*; it now gives *il briquète* and *je briquèterai*, which is one of the
two spellings Wiktionary offers and the one the twelve in A2.1b also take.

### A2.1b The twelve -eler / -eter verbs (decision 6) ✅ 2026-09-20

All twelve move `1-3A` or `1-3B` → **`1-4`**, one line each, same as A2.1. No model definition
changes: `1-4` already produces the rectified forms for every one of them.

| Verb | Rank | `mo` today | App output | After (`1-4`) |
|---|---|---|---|---|
| déchiqueter | 2600 | `1-3B` | *il déchiquette*, *je déchiquetterai* | *déchiquète*, *déchiquèterai* |
| ruisseler | 2913 | `1-3A` | *il ruisselle*, *je ruissellerai* | *ruissèle*, *ruissèlerai* |
| ensorceler | 3014 | `1-3A` | *il ensorcelle* | *ensorcèle*, *ensorcèlerai* |
| cacheter | 3071 | `1-3B` | *il cachette* | *cachète*, *cachèterai* |
| niveler | 3111 | `1-3A` | *il nivelle* | *nivèle*, *nivèlerai* |
| tacheter | 3153 | `1-3B` | *il tachette* | *tachète*, *tachèterai* |
| trompeter | 3533 | `1-3B` | *il trompette* | *trompète*, *trompèterai* |
| déniveler | 3653 | `1-3A` | *il dénivelle* | *dénivèle*, *dénivèlerai* |
| marketer | 5036 | `1-3B` | *il markette* | *markète*, *markèterai* |
| craqueter | 5433 | `1-3B` | *il craquette* | *craquète*, *craquèterai* |
| dépaqueter | 5991 | `1-3B` | *il dépaquette* | *dépaquète*, *dépaquèterai* |
| bêcheveter | 6241 | `1-3B` | *il bêchevette* | *bêchevète*, *bêchevèterai* |

After this, `1-3A` and `1-3B` should hold only *appeler*, *jeter* and their compounds. Check that
they do, and report any verb left behind that is not one: it is either a thirteenth member of
this class the English extract did not cover, or a verb the extract got wrong.

**Correction (2026-09-20): `1-3A` and `1-3B` do not end up holding only *appeler*, *jeter* and
their compounds, and should not.** They hold **104** verbs between them. After the twelve leave,
**92** remain, and the paragraph above is the one place this plan is wrong about the data rather
than about a count.

Checking every one of the 104 against the English extract's présent third singular sorts them
cleanly:

| What Wiktionary's table gives | Verbs | Which |
|---|---|---|
| the grave spelling **only** | 12 | exactly the twelve this section moves |
| **both** spellings | 48 | *atteler*, *ficeler*, *museler*, *épeler*, *étinceler*, *feuilleter*, *étiqueter*, … |
| the doubled spelling **only** | 6 | *appeler*, *rappeler*, *jeter*, *rejeter*, *projeter*, *interjeter* |
| no conjugation table at all | 38 | *canneler*, *javeler*, *piqueter*, *râteler*, … (37 absent from the extract; *pailleter* has an entry with no présent forms) |

So the six verbs Wiktionary spells **only** with the doubled consonant are precisely *appeler*,
*jeter* and their compounds, which is what the paragraph above was reaching for. But the model is
not reserved to them: 48 verbs sit on it where Wiktionary itself offers both spellings and
therefore agrees with the app today, and 38 more where the reference is silent. Moving those 92
would contradict the reference on 48 verbs to satisfy a sentence about what a model is named for,
and would be a change of 1,932 forms made on no evidence.

**Decision 6 was therefore applied to the twelve the audit names, plus *déficeler* and
*briqueter* from A2.1, and to no others.** The twelve are the verbs where the app and the
reference actually disagree; the other 92 are not a "thirteenth member of this class", they are
the ordinary middle of the family, where both spellings are live and the reference declines to
choose. If Josh wants the whole family rectified, that is a second decision with a different
justification, and it costs 92 more `mo` edits.

### A2.2 Definition errors in `verbModels.xml` ✅ 2026-09-20

The model is wrong for every verb that uses it, so the definition changes. Confirm each against
`StemAlteration.init(xmlString:)` before editing, as Stage A's A1 note says to. Four models,
covering six verbs; *amuïr* was here in the first draft of this stage and moved to A2.1, because
`2-1` is right for every other -ir verb.

| Model | Verbs | App output | Wiktionary | What looks wrong |
|---|---|---|---|---|
| `5-6` vivre | vivre (41), survivre (697), revivre (1203) | *je vivis*, *nous vivîmes* | *vécus*, *vécûmes* | the alteration `2,2,ÉC` is applied to `pp` only; the passé simple and subjonctif imparfait are built on *viv-* and need the same *véc-* stem. Twelve wrong forms per verb. |
| `1-4` peser | sevrer (1387) | *je seère*, *je seèrerai* | *sèvre*, *sèvrerai* | `2,1,È` replaces the character two from the end, which is the *v* of *sevr-*. A stem ending in a consonant cluster needs `3,1,È` (and `5,1,È` for `sf`). Either a sibling model or `sevrer` moves to it; check whether any other `1-4` verb has the cluster before choosing. |
| `5-13` absoudre | résoudre (398) | *résous* | *résolu* | `1,1,S*,pp` is right for *absous* and wrong for *résolu*. *absoudre* verifies correct today, so the fix is a model for *résoudre*, not an edit to `5-13`. |
| `3-2C` bouillir | bouillir (1293) | impératif *bouille* | *bous* | `2,2,ill,h2s` builds the imperative on the infinitive stem while `3,3,S*,r1s` gives the correct *bous* for the indicative. The imperative should follow the indicative. |

**Correction (2026-09-20):** all four diagnoses were right about the cause; two needed a change
the table did not name, and one was a deletion rather than an edit.

*`5-6` vivre needed the passé simple **group** changed as well as the stem.* The table names the
stem — *véc-* rather than *viv-* — but *vécus, vécut, vécûmes* are the **u** endings, and the
model carried `se="i"`. So the fix is `se="i"` → `se="u"` **and** widening the existing
alteration to `2,2,ÉC,xA,pp`. `xA` covers the subjonctif imparfait for free, because
`Conjugator` resolves that tense through `.passéSimple(personNumber)`. Changing only the stem
would have produced *vécis*.

*`3-2C` bouillir was a deletion.* `2,2,ill,h2s` does not merely build the impératif on the wrong
stem; it runs **after** `3,3,S*,r1s,r2s` has already produced the correct *bouS*, and puts the
*ill* back. (The impératif reaches an `r2s` rule because `Conjugator` applies an
`indicatifPrésent(personNumber)` alteration when conjugating the impératif for that person.)
Removing `|2,2,ill,h2s` is the entire fix.

*`1-4` sevrer got the sibling, and it is the only verb that needs one.* Of the 85 verbs that sit
on `1-4` after A2 (69 before, plus the 16 A2 moves in), *sevrer* is the **only** one whose présent
stem does not have its mutable *e* two characters from the end, and the only one whose infinitif
does not have it four from the end. So `1-4` is untouched and `1-4A` re-indexes its rule:
`3,1,È,<présent persons>|5,1,È,sf`, parent `1-1`.

*`5-13` résoudre used the `N` device, as `5-8A`/`5-8B` do for *dites*.* `1,1,S*,pp` becomes
`1,1,S*,N,pp`, so *absoudre* and *dissoudre* keep *absous* and *dissous* while the new
`5-13A` (`pa="5-13" ep="u" p="2,2,L,pp"`) builds *résolu* on the same *-sol-* stem the plural and
the passé simple already used. Marking the parent's rule uninherited is necessary rather than
tidy: alterations are applied in order to one stem, so a child rule alone would have run on the
string the parent rule had already produced.

### A2.3 Needs a judgement, not a fix ✅ 2026-09-20

Record a verdict and the source for each; several may end as "the app is right".

| Verb | Rank | App | Wiktionary | The question |
|---|---|---|---|---|
| faillir | 900 | participe passé *faillu* | *failli* | both exist; *failli* is the ordinary one and *faillu* archaic. Which does a learner want? |
| luire, reluire | 1342, 3880 | *il luisit* | *il luit* | *luisit* is given as rare or archaic by Le Robert. Same question. |
| seoir, messeoir | 1406, 5468 | *seyent/soient*, participe présent *sey/soyant* | *siéent*, *séant/seyant* | genuinely irregular and defective; the app's alternates may simply be wrong. |
| échoir | 2063 | *échoyant* | *échéant* | *échéant* is the living form (*le cas échéant*). |
| sortir (obtain) | 78 | *nous sortissons* (`2-1`) | *sortons* | the `ex="obtain"` entry is the legal or printing sense. Some references conjugate it like *finir*, most like *sortir*. Decide, and say so in the report: the English table covers only the common sense, so this is not straightforwardly a diff. |
| clamecer | 6152 | impératif *clamèce* | *clamece* | one non-defective row; `1-6A` (dépecer) may be the wrong model. |

**Correction (2026-09-20): four of the eight ended in a fix and four in "the app is right".**
The verdicts, with their sources.

**Fixed.**

- ***faillir*** (900): participe passé `ep="U"` → `ep="i"`, giving *failli*. *faillu* is archaic
  and *j'ai failli tomber* is the everyday sentence. `4-12` has exactly one user, so the change
  is confined to *faillir*, and the model keeps the archaic présent (*je faux*, *il faut*), which
  references do still give. Independent confirmation arrived from 1.4: *faillir*'s shipped example
  had been failing `check_examples` because its token *failli* was not a form of the verb
  **according to the app**, and that failure is gone.
- ***échoir*** (2063): `2,2,É,rr` added to `4-11B`, giving *échéant*. The participe présent is
  built from the *nous* stem rather than from the infinitif, so the é has to be restored after the
  fact; `4-11A` (*choir*) is untouched and still gives *choyant*.
- ***seoir*** (1406) and ***messeoir*** (5468): both left `4-9AB` for a new `4-9D`. They were not
  merely getting *asseyent* for *siéent*; they were inheriting *asseoir*'s **second paradigm** as a
  phantom alternate, so the app offered *sOIt*, *sOIent*, *sOIE* and *Soira* — forms of a verb they
  are not. `4-9D` gives *il sied*, *ils siéent*, *qu'il siée*, *il siéra* and *seyant*, verified in
  the simulator.

**The app is right.**

- ***luire*** (1342) and ***reluire*** (3880): Wiktionary's own table gives **both** paradigms for
  every person of the passé simple — *luis*/*luisis*, *luîmes*/*luisîmes*, *luirent*/*luisirent* —
  **except** the third singular, where only *luit* appears. A table that offers *luisis* and
  *luisirent* either side of it and omits *luisit* has a gap, not a verdict. No change.
- ***sortir (obtain)*** (78): the app is right and the disagreement is the extract conflating two
  verbs. The jurisprudence sense (*sortir son plein effet*) is a second-group verb, which is what
  the `ex="obtain"` entry's `2-1` and `dg="1"` encode: third person only, *sortissant*. The English
  table covers only the common sense, and seven of its 22 rows land on the third person, which is
  exactly where the two senses part company. No change; the report should say so.
- ***clamecer*** (6152): the app is right, and the reference here is not one. The same
  `fr-conj-auto` template gives *dépèce* for *dépecer* and *clamece* for *clamecer*, so the
  spelling comes from a page parameter nobody set rather than from a reading of French. *clamecer*
  rhymes with *dépecer* and takes its grave accent. `1-6A` stays. One thing to hand to a later
  stage: 20 of its 21 rows are `defective_gap`, and the one live row is the **impératif** second
  singular, on a defect group (`7`, whose only user is *clamecer*) that marks the **indicatif**
  second singular unused. Adding `hA` to `dg` 7 would close that, and is a defect-group question
  rather than a conjugation one, so A2 left it.

### A2.4 Probably not errors — record and move on ✅ 2026-09-20

- **éclore, enclore, déclore, forclore** (2122, 3317, 5499, 4897): the app gives *éclot*,
  Wiktionary *éclôt*. This is the **mirror** of decision 6: the app already has the 1990 rectified
  spelling and Wiktionary the traditional one. It surfaced only because 1.1's circumflex tolerance
  covers i and u, not o. **Decision 6 settles it: no change.** The app is already on the side
  decision 6 chose, and after A2 it is consistent with itself on both halves of the reform. Record
  that and move on. Consider widening 1.1's circumflex tolerance to o so this stops surfacing.
- **haïr (Québec)** (1209): *haïs* against the extract's *hais*. That is the whole point of the
  France/Québec split, and the English table is the France one. Not an error.
- **saillir (bulge)** (2646): the extract conflates the two *saillir* senses. Not an error.
- The nine `defective_gap` verbs — *sortir (obtain)*, *issir*, *faillir*, *seoir*, *gésir*,
  *bruire*, *saillir (bulge)*, *forclore*, *clamecer* — disagree on a tense the verb's own defect
  group marks unused, so the disagreement is moot by construction. Confirm the defect group is
  right rather than the form. *issir*, *gésir* and *bruire* appear here and nowhere else in A2,
  and that is their whole verdict.

**Correction (2026-09-20): recorded as written, and the circumflex tolerance was deliberately
not widened.** The verdicts:

- ***éclore*, *enclore*, *déclore*, *forclore***: no change, as decision 6 says. The app ships
  *éclot* and Wiktionary *éclôt*, which is the mirror of the -eler/-eter case, and after A2 the app
  is on the rectified side of both. Four rows survive the re-run and are expected.
- ***haïr (Québec)*** (1209), ***saillir (bulge)*** (2646): not errors, as written. Four and
  fifteen rows survive.
- ***issir***, ***gésir***, ***bruire***: defect-group rows only, and their defect groups
  (`6` "only participe passé", `17` "only indicatif présent, imparfait and participe présent",
  `4` "only participe présent, 3s and 3p") do describe those verbs. Nothing to do.

*The suggestion to widen 1.1's circumflex tolerance to o was considered and declined.* The
tolerance exists because the 1990 rectifications dropped the circumflex on **i** and **u**; ô is
not in that rule, and *éclot* is a separate, named rectification. A blanket "accept ô where the
app has o" would therefore stop being a 1990 rule and start being a licence to miss a real
circumflex error anywhere in the data. The four rows cost four lines in a file that is read once
per stage, and A2.6's second criterion already calls them expected. `audit_conjugations.py` is
unchanged.

### A2.5 Tests, counts, and re-running Stage 1 ✅ 2026-09-20

- Extend `ConjuguerTests/Models/EngineAuditTests.swift` with every form A2 corrects, the way
  Stage A did. Mind `conditional_returns_on_newline`.
- Regenerate `VerbModelTests.swift` by the recipe in Stage A's A4 correction note — uncomment
  `GenerateVerbModelTests`, run it with the **trailing parentheses** on the `--only-testing`
  filter, lift the source out of `build.log`. Its diff should touch only the models A2.2 changes.
- Recompute the regular/irregular split. Only three model ids count as regular (`1-1`, `2-1`,
  `5-1A`, per `IrregularityMetricTests.regularModelIds`), so most of A2's moves do not touch it:
  **decision 6's twelve move `1-3A`/`1-3B` → `1-4`, irregular to irregular, and change nothing**,
  and *parfumer* moves `5-1A` → `1-1`, regular to regular. The verbs that do move the split are
  the ones leaving `1-1` or `2-1`: *relever*, *débriefer*, *déficeler*, *briqueter*, *jauger*,
  *gamberger* and *amuïr*, each one regular to irregular. Stage A left the split at 5,217 / 1,109;
  recompute rather than trust that arithmetic, and
  `IrregularityMetricTests.testShippingSplitMatchesTheInfoText` will fail until
  `Info.irregularitiesText`, `Info.valuePropositionText` (both languages) and
  `docs/description.txt` agree.
- **Regenerate `corpus/working/conjugations.json`** — `testDumpAllConjugations`, trailing
  parentheses on the filter — and then **re-run all six Stage 1 scripts**, in the order
  `audit_conjugations`, `audit_flags`, `lint_glosses`, `check_examples`, `build_candidates`,
  `build_verb_pass_shards --pilot`. They take about thirty seconds together. Everything
  downstream derives from that dump: the tier candidates are found by looking tokens up in it, and
  `check_examples` tests its tokens against it. This is why A2 runs before Stage 2 and not after.
- Extend `docs/release-notes-2.3.txt` in both languages. *vivre* at rank 41 and *relever* at 152
  are wrong in the shipping app, which is the case the 2.2 notes made for *considérer*.
- Journal entry, and re-run `scripts/check_docs.py` if any file moved.

**Correction (2026-09-20):** every step ran; four things to correct.

*The regenerated `VerbModelTests` diff is 180 added lines and 6 changed ones, not "only the models
A2.2 changes".* The 180 are the three **new** models (`1-4A`, `4-9D`, `5-13A`), which the section
did not know would exist. The 6 changed lines are exactly `5-6` (two: the passé simple and the
subjonctif imparfait rows), `3-2C`, `4-11B`, `4-12` and `4-9AB` — the last of those being the
participe présent fix, not a model change. `absoudre`'s test is untouched, which is the check that
the `N` on `5-13` did what it was supposed to. The recipe in Stage A's A4 note worked verbatim,
trailing parentheses included.

*The split is 5,210 / 1,116, and the model count moved too.* Seven verbs leave the regular models
(*relever*, *débriefer*, *déficeler*, *briqueter*, *jauger*, *gamberger*, *amuïr*), exactly as this
section predicted, and *parfumer*'s `5-1A` → `1-1` is regular to regular, also as predicted. But
the section lists only the split as a number that lives in prose. `Info.irregularitiesText` also
says the irregular verbs are conjugated by "one of **ninety-two** irregular-verb models", and three
new models make it ninety-five, in both languages. While there, the French
`Info.valuePropositionText` still wrote the verb count as *6.326* with a period; Stage A's A4 note
fixed that separator for *5 223* and missed this one. Both are now the French space.

*`check_examples` dropped from 4 failures to 3.* *faillir*'s example stopped failing the moment
`ep` became `i`: its token *failli* is now a form of the verb according to the app. That is 1.1's
finding and 1.4's finding turning out to be the same finding, confirmed from the other side.

*The re-run moved the candidate counts by six sentences, in the right direction.* Tier candidates
9,855 → 9,849, verbs with at least one corpus hit 2,834 → 2,832, verbs with no candidate at all
1,776 → 1,777. The whole difference is *trompeter* (five hits) and *niveler* (one), whose only
corpus matches were the **nouns** *trompette* and *nivelle* that the traditional spelling made
look like verb forms. Losing them is the point: the tier pass matches corpus tokens against the
engine's own forms, so a wrong form mines wrong sentences, which is why A2 runs before Stage 2 and
not after. The shard contract revalidates: 181 shards, all 6,330 entries, one shard each, fourteen
keys per record, ranks monotonic, three candidate kinds.

### A2.6 Acceptance criteria ✅ 2026-09-20

- Every one of the 43 verbs has a verdict: fixed, decided under decision 6, or recorded in A2.3 or
  A2.4 with its reason.
- A re-run `audit_conjugations.jsonl` no longer lists any verb A2.1 or A2.2 fixed, and its
  remaining rows are only the kinds A2.3 and A2.4 account for.
- The full suite passes, `EngineAuditTests` pins every corrected form, and the `VerbModelTests`
  diff touches only the changed models.
- `conjugations.json` is regenerated and all six Stage 1 scripts re-run against it; the shard
  count and the per-shard contract still validate.
- `xmllint --valid` still passes on `verbs.xml`. (`verbModels.xml` does not and never has. Its
  internal DTD never declared `p`, `dg` or `sb`; see Stage A's A1 note.)

**Correction (2026-09-20): all five met.** All 43 verbs have a verdict (24 `mo` swaps, 5 model
definitions changed or added, 1 engine fix, 4 recorded as "the app is right", 9 recorded as moot).
The re-run `audit_conjugations.jsonl` lists **87 rows over 14 verbs**, down from 579 over 43, and
every one of the 14 is an A2.3 or A2.4 verb: *sortir (obtain)* 22, *clamecer* 21,
*saillir (bulge)* 15, *gésir* 12, *haïr (Québec)* 4, *issir* 3, *faillir* 3, and one row each for
*luire*, *reluire*, *éclore*, *enclore*, *déclore*, *forclore* and *bruire*. 70 of the 87 are
`defective_gap`. The full suite passes at 274 tests in 23 suites; `EngineAuditTests` grew from 9
test functions to 22 and pins every corrected form. `conjugations.json` was regenerated (6,330 verb ids) and
all six Stage 1 scripts re-ran against it. `xmllint --valid` passes on `verbs.xml` and
`verbModels.xml` is still merely well-formed, for the reason A1 gives.

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

**Correction (2026-09-20):** Stage 2 must run against shards built **after** Stage A2, because
A2 changes `conjugations.json` and every Stage 1 output derives from it. Check that the shard
files are newer than `conjugations.json` before computing the pending list. It is 181 shards, not
180.

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

## Decision 6 (added 2026-09-20 after Stage 1)

6. **The -eler / -eter spelling.** ✅ **Taken 2026-09-20: adopt the rectified spelling.** The
   twelve verbs move to **`1-4`** (peser), the model *mener* and *relever* use, and `1-3A`
   (appeler) and `1-3B` (jeter) keep only *appeler*, *jeter* and their compounds, which is what
   those two models are named for. The same answer settles *déficeler* and *briqueter* in A2.1
   and the mirror case in A2.4. The reasoning that led here is kept below.

   **Correction (2026-09-20, applied in A2.1b):** the decision was applied to the twelve, to
   *déficeler* and to *briqueter*, and the clause about what `1-3A` and `1-3B` are left holding is
   wrong. Those two models hold **104** verbs, not fourteen, and 92 remain after the twelve leave.
   English Wiktionary gives **both** spellings for 48 of the 92 and no table at all for 38; only
   six verbs in the whole family get the doubled spelling alone, and those six are indeed
   *appeler*, *jeter*, *rappeler*, *rejeter*, *projeter* and *interjeter*. So the decision as
   taken — move the verbs the reference spells only with the grave — is exactly what was applied,
   and rectifying the other 92 would contradict the reference on 48 of them. See the A2.1b note
   for the full table. Whether the whole family should be rectified is a separate decision that
   nothing in the audit forces.

   **`1-4` needs no change to take them.** Its alterations are
   `2,1,È,<présent persons>|4,1,È,sf`: replace one character two from the end of the present stem
   and four from the end of the futur stem. On all twelve, and on *déficeler* and *briqueter*,
   that reproduces exactly the forms English Wiktionary gives — *il déchiquète* /
   *je déchiquèterai*, *il ruissèle* / *je ruissèlerai*, *il markète* / *je markèterai*, and so
   on through *bêchevète*. Checked against `audit_conjugations.jsonl` on 2026-09-20 for all
   fourteen. So decision 6 costs fourteen one-line `mo` edits and no new model.

   Stage 1.1 found that the app spells twelve verbs the traditional way and English Wiktionary
   gives the grave-accent spelling: *déchiqueter*, *ruisseler*, *ensorceler*, *cacheter*,
   *niveler*, *tacheter*, *trompeter*, *déniveler*, *marketer*, *craqueter*, *dépaqueter*,
   *bêcheveter*. The app gives *il déchiquette*, *je déchiquetterai*; Wiktionary gives
   *il déchiquète*, *je déchiquèterai*. 252 of the audit's 579 rows are this one question, 21 per
   verb, and both spellings are current French.

   The background: traditional orthography doubles the consonant (*jette*, *appelle*,
   *déchiquette*), and the 1990 rectifications kept the doubling for *appeler*, *jeter* and their
   compounds while recommending the grave accent for every other verb of the family. The Académie
   endorses both. Wiktionary's tables lead with the rectified spelling.

   The three options, and what each costs:

   - **Keep the traditional spelling.** No data changes. The app keeps models `1-3A` (appeler) and
     `1-3B` (jeter) for the whole family and disagrees with Wiktionary on twelve verbs. A2 records
     the twelve as decided and moves on.
   - **Adopt the rectified spelling for the twelve.** The twelve move to `1-4` (peser) or a new
     sibling; `1-3A` and `1-3B` keep only *appeler*, *jeter* and their compounds, which is what
     those models are named for. Twelve one-line `mo` edits, a regenerated `VerbModelTests`, and a
     line in the release notes.
   - **Ship both, as the app already does for *haïr*.** The engine supports alternates joined by
     `/`, and *ouïr*, *saillir* and *sortir* already carry `ex` entries for split paradigms. This
     is the most faithful and by far the most work, and it doubles twelve rows of the quiz's
     answer space.

   Whatever is chosen applies to the mirror case in A2.4: *éclore*, *enclore*, *déclore* and
   *forclore*, where the app already has the 1990 spelling (*éclot*) and Wiktionary the
   traditional one (*éclôt*). Answering one and not the other leaves the app inconsistent with
   itself, which is worse than either answer.

   The recommendation, for what it is worth: **adopt the rectified spelling for the twelve**. It
   matches what `1-3A` and `1-3B` are named for, it agrees with the reference the whole pass is
   built on, and it leaves the app internally consistent with the *éclot* it already ships.
