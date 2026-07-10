# Sweep low-value comments (declutter to CLAUDE.md's comment policy)

## Why this exists

Conjuguer's sibling apps ran comment sweeps that brought their trees into line with a
one-paragraph comment policy: *code is self-explanatory; comments are for file headers,
TODOs, and hacks/workarounds only.* Conjugar's sweep additionally stripped a dense
**provenance paper trail** (Fable-audit `item N` citations, `Phase N` build-plan
pointers, `audit §N` / `K#` / `C#` cross-app codes, "ported from …" sibling-app notes)
that its **rewritten** conjugation engine had accumulated. Konjugieren's sweep found no
such trail because its engine is original.

**Conjuguer is in Konjugieren's situation, not Conjugar's.** A full comment sweep
(July 2026, ~240 non-header comments in the app target, ~120 in the tests, ~30 in the
widget/Shared) found:

- **Zero** provenance citations (`item N`, `Phase N`, `audit §N`, book/taxonomy oracles).
- **Zero** sibling-app mentions in comments (no "Conjugar", "Konjugieren", "mirrors",
  "ported from").
- **Zero** change-narration comments ("previously", "used to", "per the audit").
- The handful of `finding #37` / `finding 33` / `Finding 9` / `#29` references that *do*
  appear are **attached to durable regression/why-this-guard rationale**, not a paper
  trail — they stay (see KEEP below).

So this is **not** a provenance strip. It is a **decluttering pass** that brings the
codebase into line with the comment policy now written in `CLAUDE.md` (`## Comments`):

> Code should be well-written and therefore self-explanatory. Explanatory and MARK
> comments result in clutter and increased maintenance burden. Only use comments for:
> file headers, TODOs, hacks or workarounds. … The one carve-out is durable, non-obvious
> rationale: a comment that answers "why is the code like this?" and states a fact a
> future reader can't recover from the code itself.

This is a **comment-only** sweep. Do not change any executable code, string literals, or
user-facing copy. **Exception:** the one generator edit called out under *Decision 1*
(none — Josh chose to keep the `// ID:` tags, so there is no generator edit). `git diff`
should show only comment lines (`//`, `///`, or inside `/* */`).

## The governing rule

For every comment that is **not** a file header, a `// TODO:`, or a `// HACK:` /
workaround note, apply this test:

1. **Delete it** if its content is already encoded in the code it sits above — a label
   restating the identifier, a step-comment narrating the next line, or a worked example
   whose facts are already in the test's expected value. This is the **aggressive lean
   Josh chose**: if reading the next line or two tells you the same thing, it is clutter.
2. **Keep it (trimmed if needed)** only when it carries **durable, non-obvious
   rationale** a future reader can't recover from the code itself — a French
   phonological/conjugation rule that explains why an expected value looks wrong, a
   Swift-concurrency isolation constraint, an ordering guarantee, a deliberate
   silent-failure/degrade-not-crash path, a measured cold-start cost, a
   magic-number/color-hex explanation, or an SE-number/radar workaround. These answer
   "why is the code like this?", not "what does this line do?".

When a comment is borderline after applying the rule, **lean toward deletion**. This is
judgment work, not a regex replace: read each comment against the code beneath it.

## Decisions on the four uncertain classes (asked & answered)

These were resolved by Josh before this plan was written; apply them verbatim.

1. **`// ID: 5-13` verb-model tags in `ConjuguerTests/…/VerbModelTests.swift` (~109, one
   per generated `@Test`) → KEEP.** They cross-reference the `VerbModel` catalog id, are
   emitted by `T.generateVerbModelTests()` (`// ID: \(model.id)`), and do not restate the
   test body. **Do not touch them and do not edit the generator.**
2. **Game-engine descriptive comments → DELETE ALL.** Strip **every** `///` helper
   doc-comment and **every** `// Mechanic N:` section/sprite/step label in the game files.
   Keep **only** hard rationale — magic-number explanations, workarounds, and
   degrade-not-crash / invulnerability-window / test-visibility notes (enumerated below).
3. **Per-case enum gloss comments → keep license + linguistic, cut pure labels.** Keep
   `ExampleSource`'s per-case license/copyright notes and the linguistic example-verb
   glosses (e.g. `case e(...) // parler (true) / couvrir (false)`) because the example
   verbs and license facts are **not** otherwise in the code; **delete** pure
   effect-restating labels (e.g. `case baguette // restores health`).
4. **Extended file-header prose → KEEP.** Several game files (`GameView`,
   `GameState+*.swift`) and a couple of widget files (`WidgetL`, `WidgetConjugationText`)
   carry multi-sentence design/rationale prose inside the header block. Leave it — headers
   are policy-protected and this prose is durable design rationale.

## MARK comments — delete all of them, unconditionally

Josh does not use `// MARK:` markers for navigation, and the policy names them as
clutter. Delete **every** `// MARK:` line in the swept files, regardless of what follows.
Known hits (30 total across 8 files — re-scan before starting, line numbers drift):

- `Conjuguer/Models/Tense.swift` — 1 (`- Tense-shorthand codec`)
- `Conjuguer/Models/Game/GameModels.swift` — 6 (`- Mechanic 1…5`, `- Shared projectile
  behavior`)
- `ConjuguerTests/Models/RichTextTests.swift` — 3 (`- Block splitting`, `- Inline
  segments`, `- Graceful handling of authoring errors`)
- `ConjuguerTests/Models/WidgetSnapshotWriterTests.swift` — 5 (`verbOfTheDay day-index
  hash`, `generateSnapshot / generateWrongAnswers …`, `date strings`,
  `truncateToSentenceBoundary`, `rebalanceTildes (finding 33)`)
- `ConjuguerTests/Models/GameCollisionTests.swift` — 3 (`Shape A/B/C …`)
- `ConjuguerTests/Models/GameMechanicsTests.swift` — 5 (`Mechanic 1…5 — …`)
- `ConjuguerTests/Models/GameProjectileTests.swift` — 5 (`Integrate-and-cull …`,
  `Homing fire …`)
- `ConjuguerTests/Models/GameDiveArcTests.swift` — 2 (`Mechanic 1 — dive-bomber arc`,
  `Mechanic 5 — robot minion swoop`)

Search: `// MARK:` across all four source roots (`Conjuguer/`, `ConjuguerTests/`,
`ConjuguerWidget/`, `Shared/`).

## Main body of work #1: the game engine (`Conjuguer/Models/Game/**`, `Views/GameView.swift`)

Per **Decision 2**, this is the most aggressive part of the sweep. In these files:

**DELETE — every `///` helper doc-comment.** They describe *what* a shared helper does
and *which mechanics share it*; the method name and body already carry that. Known
clusters (re-scan; lines drift): `GameState.swift:235-239, 381-383, 524-527, 541-543,
551-556, 564-567, 574-577, 591-593, 686, 866-867`; `GameModels.swift:258-262, 273-275,
288-290`; `GameState+RobotBoss.swift:45, 52`; `GameState+Specials.swift:40-41`.

**DELETE — every `// Mechanic N:` label and section/step label.** Sprite-group labels in
`GameView.swift` (176, 185, 187, 195, 214, 233, 244); property-group labels in
`GameState.swift` (44, 57, 71, 87, 101, 141); the update-loop trailing labels
(`GameState.swift:461-465` — `updateBall(dt:) // Mechanic 2`, etc.); the enum-case
mechanic tags `GameModels.swift:292-294` (`case ball // Mechanic 2`); and the next-line
narrations `GameState.swift:398, 796, 801`, `GameState+Henyard.swift:38`,
`GameState+Ghosts.swift:25`, plus the per-step narration inside the mechanic loops
(`GameState+Divers.swift:27,37,48,63`, `GameState+Ball.swift:79,98`,
`GameState+RobotBoss.swift:31,37,62,79,145`).

**KEEP — the hard rationale only** (magic numbers, degrade-not-crash, invulnerability
windows, test-visibility). Do NOT let the aggressive pass sweep these away:

- Magic numbers: `GameState.swift:112-113` (`3.7 ≈ 2.6/0.7`, 30 % slower swoop),
  `436-438` (clamp sim step so a hitch can't tunnel the ball), `441-444` (wrap `sineTime`
  at 4π), `394` (star density), `GameModels.swift:124` (`0=bleu/1=blanc/2=rouge`),
  `GlyphWarmer.swift:20` (`format.scale = 3` @3x), `GameState.swift:205-207` (warm emoji
  glyph cache off main, ~0.5 s each).
- Invulnerability / deliberate-behavior windows: `GameState.swift:63-64, 66-68`,
  `GameState+Ball.swift:110-113` (shield deliberately doesn't protect),
  `GameState+Henyard.swift:67-68,74,89-90,107` (chicks unshootable; ground = player row),
  `GameState.swift:489-490, 624-625`, `GameState+RobotBoss.swift:28-29,105-106,220`.
- Test-visibility rationale: `GameState.swift:172-174, 509-511, 793-794`,
  `GameState+RobotBoss.swift:174-177` — `internal` (not `private`) *because* extensions/
  tests in other files need it (finding #37 shared vector math). Keep these; the
  `finding #37` reference is legitimate why-it-exists rationale.
- The extended **file-header** design prose (`GameView.swift`, every `GameState+*.swift`
  header) — KEEP per **Decision 4**.

## Main body of work #2: the game tests (`ConjuguerTests/Models/Game*Tests.swift`)

The MARKs here are already covered above. For the rest, apply the **governing rule** (the
"delete all descriptive" decision was scoped to the engine's `///` docs and Mechanic-N
labels; test rationale that explains a non-obvious magic value is the "magic numbers"
rationale that Decision 2 explicitly keeps):

**DELETE — worked-example labels that recompute the expected value** (the analogue of
Konjugieren's deleted ablaut examples — the expected value already encodes the fact):
`GameProjectileTests.swift:45,48,49,71,72` (`// 500 - 310`, `// 100 + 200 * 0.5`, …), the
per-element bound labels `80-84, 110-114` (`// past top`, `// in bounds`), `130,131,139`,
and the narrating one-liners `GameDiveArcTests.swift:71,93,114,136,137`,
`GameMechanicsTests.swift:60,182,231,266`. Also `GameDiveArcTests.swift:37` (the `///`
that restates `expectedArcPosition`).

**KEEP — why-this-magic-value / target-selection / characterization rationale:** the
boundary-coord explanations (`GameProjectileTests.swift:54,77-78,108,128-129`), the
"why this `dt`" notes (`GameDiveArcTests.swift:57,62,64,91,105,107,132`,
`GameProjectileTests.swift:57,134`), target-selection and mechanic rules
(`GameMechanicsTests.swift:36,48,79,165-166,170,176-177,179,213,220,239,247`,
`GameCollisionTests.swift:53,66,110`), the golden-formula notes
(`GameProjectileTests.swift:142,148,168-169,178,186`), and the **characterization-test
header blocks** (`GameDiveArcTests.swift:5-16` sub-ULP interpolation note,
`GameCollisionTests.swift:5-19` shapes A/B/C, `GameProjectileTests.swift:5-14`,
`GameMechanicsTests.swift:5-9`) — these are file-header prose, KEEP.

## Inventory for the rest of the tree

Beyond the game files and the MARKs, the corpus is **overwhelmingly durable rationale
that stays.** The sweep still visits every file to catch a thin label, but expect few
edits. The app source alone holds ~150 KEEP-class comments explaining concurrency
isolation, measured cold-starts, French conjugation rules, and degrade-not-crash paths.

**KEEP (durable rationale — do not touch; representative, not exhaustive):**
- **Concurrency / actor-isolation:** `Analytics/AnalyticsReal.swift:12-25` (nonisolated
  `@unchecked Sendable`; TelemetryDeck's blocking `DispatchQueue.sync` funneled onto a
  serial queue), `SoundPlayerReal.swift:33-44,62-64`, `Utterer.swift:13-14,22-35`,
  `VerbData.swift:11-47`, `Log.swift:10-13`, `GlyphWarmer.swift:16-17`,
  `Quiz.swift:80-82` (`assumeIsolated` on the known main-actor timer callback),
  `L.swift:591-592` (nonisolated for the `Tip` protocol), `LiveActivityManager.swift:19-
  21,82` (serial tail for ActivityKit ordering), `LanguageModelServiceReal.swift:205-207,
  246-247`, `DefectGroup.swift:67-68`, `Tense.swift:203-205`.
- **Measured performance:** `SoundPlayerReal.swift:12-15,23-26,51-56,104-159` (cold-start
  ~1.5 s audio-stack prime; the `forums.developer.apple.com/thread/23160` workaround),
  `Utterer.swift:22-35,51` (same forum workaround), `GlyphWarmer.swift:8-20`,
  `HapticPlayer.swift:9-16`, `LanguageModelServiceReal.swift:35-37`.
- **French linguistics / conjugation:** `Conjugator.swift:44,180-182,226-237`,
  `PersonNumber.swift:23,124,140,165-166`, `StemAlteration.swift:15-17`,
  `Tense.swift:192-195,250-251`, `Etymology.swift:10-13`.
- **Degrade-not-crash / deliberate silent-failure:** `VerbConjugations.swift:121,133-134`,
  `Quiz.swift:404-405`, `Conjugator.swift:226-227`, `Verb.swift:81-82`,
  `World.swift:40-41,147-150,165` (cold-launch deeplink race → stash + replay),
  `ConjuguerApp.swift:39,73`, `TutorView.swift`-style empty-catch notes.
- **Magic numbers / cache-invalidation / ordering:** `VerbConjugations.swift:50-52`,
  `Settings.swift:62` (drop cached cells because they bake pronoun gender),
  `WidgetSnapshotWriter.swift:9-11,29-43,133-134,152-196,217-219` (day/gender keying;
  tense↔person decorrelation; drop-dangling-`~` so the bold parser doesn't run to the
  end), `RatingsFetcher.swift:37-41` (`// Not a bug.` defends a leading space),
  `StringExtensions.swift:64-65`, `Fonts.swift:13-16`, `PreviewSupport.swift:11-23`,
  `InfoBrowseView.swift:163-165`, `VerbView.swift:25,151` (`#29` gray-prefix issue ref),
  `Quiz.swift:31-36,100-102`, `AppIcon.swift:16-34`, `Info.swift:11-14`,
  `LanguageModelServiceReal.swift:13-15,334-335`, `SettingsView.swift:184-188`,
  `ConjugationText.swift:11-14`, `Tense.swift:229-230`.
- **Widget / Shared (durable):** `ConjuguerWidget/AnswerQuizIntent.swift:34-35`
  (stale-snapshot silent-skip race), `QuizWidget.swift:26-28`, `QuizLiveActivity.swift:99-
  101` (OS-animated `.timer`), `Views/QuizWidgetView.swift:89,98-101` (deterministic
  shuffle; hand-rolled FNV-1a for a process-independent seed), `VerbDuJourWidget.swift:24-
  26`, `Views/LargeWidgetView.swift:36-37` (defensive index guard vs. process crash),
  `Shared/OpenRandomVerbIntent.swift:13-15` & `OpenQuizIntent.swift:13-15` (AppIntents
  requires a literal, so no `WidgetL`), `Shared/QuizActivityAttributes.swift:20-25`,
  `Shared/WidgetDateHelper.swift:10-19` (fixed Gregorian calendar; locale-independent
  `yyyy-MM-dd`), `Shared/WidgetSnapshot.swift:10-12` & `WidgetConstants.swift:10-12`
  (producer/consumer arch note — the "app never runs the engine" fact is not encoded in
  the struct; keep it, trim any field-list restatement).
- **Test rationale (KEEP):** the suite-level why-this-suite blocks in
  `DefectivityAuditTests` (‑traire family loses passé simple / subjonctif imparfait),
  `NousPrésentStemTests` (internal-"ons" bug: `consommer → je commais`),
  `CorpusFormsDumpTests` (build-time tool, `.disabled` trait, ~47 s / 1.25 M conjugations,
  regeneration procedure), `QuizTests` (golden scores 750 / 1050 and what each exercises),
  `WidgetSnapshotWriterTests` (finding 33 / finding 2 regressions), `DeeplinkTests`
  (finding 9 `-1` guard; cold-launch pending-deeplink), and the per-case linguistic
  golden-value notes in `DefectivityAuditTests`/`NousPrésentStemTests`.
- **`// ID: 5-13` tags in `VerbModelTests.swift` (~109) — KEEP (Decision 1).**

**DELETE (thin labels / step-narration — same rule as the game files):**
- `LanguageModelServiceReal.swift:187` (`// French redirects` — data-block label; the
  borderline JSON-parse step-labels there, `// Bare-name fallbacks…`, `// Fallback:
  extract from first { to last }`, trim only if they merely restate the next line).
- `WidgetSnapshotWriter.swift:51` (restates the loop; duplicates the header note).
- `CorpusFormsDumpTests.swift:38-40,48,102-104` (`// Models/`, `// repo root`, the
  `[String: Set<String>]` label) — path-walk step labels. Keep `:36,55-56,67-70,82,95-99,
  148-149` (path-derivation and correctness rationale).
- `DefectivityAuditTests.swift:31` (`// Surviving tenses stay usable.` narrates the
  asserts). Keep the golden-value linguistic notes at `:26,39,48,55`.
- `WidgetSnapshotWriterTests.swift:119` (worked-example prefix restatement). Keep the
  finding-33 / determinism / dangling-`~` notes.

**Per-case enum glosses (Decision 3):**
- KEEP: `ExampleSource.swift:14-19` (per-case license/copyright), `IndicatifPresentGroup.
  swift:11-15` (`// parler (true) / couvrir (false)` linguistic examples),
  `PasseSimpleGroup.swift:11-15` (example verbs), and the trailing field-semantics glosses
  whose meaning is non-obvious from the field name.
- DELETE: `GameModels.swift:63-65` (`case baguette // restores health`) and any sibling
  gloss that merely restates the case's effect from its name.
- Apply the rule per case: a gloss naming an **example verb** or a **license** = keep; a
  gloss restating the case's **effect from its name** = delete.

## Do NOT touch (out of scope / false positives)

- **File headers**, including the extended multi-sentence design prose in the game and
  widget headers (`WidgetL.swift:5-13`, `WidgetConjugationText.swift:5-7`, every
  `GameState+*.swift` header) — KEEP per **Decision 4**.
- **The `// ID: 5-13` tags** in `VerbModelTests.swift` and the `T.generateVerbModelTests()`
  emit line — KEEP per **Decision 1**.
- **`//` inside string literals**, which look like comments to a naive scan but are code.
  Every `conjuguer://…` deeplink, `https://…` URL (`RatingsFetcher.swift:16,23`,
  `URLExtensions.swift:20` `"://"`), and the widget/intent deeplink fragments
  (`RandomVerbControl.swift:11`, `OpenRandomVerbIntent.swift:21`, `OpenQuizIntent.swift:21`,
  the `KonjugierenWidget/Views/*` analogues) — NOT comments. Skip every one. Verify each
  `//` is a real comment before editing.
- **`Conjuguer/Assets/Localizable.xcstrings`** and **`ConjuguerWidget/Localizable.xcstrings`**
  — no code comments live there.
- **`docs/**`, `prompts/**`, `CLAUDE.md`.**
- **The anomalous second file-header block mid-`TestUtils.swift` (~lines 38-43)** that
  reads `// VerbModelTests.swift / … Created by …` — it mislabels the file (TestUtils is
  one file). It's a header, so out of scope for this comment sweep; flag it to Josh
  separately rather than "fixing" it here.
- **No `// TODO:` / `// HACK:` / `// FIXME:` markers exist** anywhere in the tree — nothing
  to preserve in that class beyond the two Apple-forum workaround refs (already KEEP).

## Execution mechanics

- Work file-by-file. For each hit, read the code beneath the comment before deciding — the
  same phrasing can be delete-worthy in one spot and rationale in another.
- Editing engine/view files may spam SourceKit "Cannot find type X in scope" / "has no
  member" diagnostics for same-module symbols. These are **false positives** — comment
  edits cannot change symbol resolution. If `build_app.sh` succeeds, the build is
  authoritative (see `CLAUDE.md`).
- `git diff` sanity check when done: every changed line must be a comment. If a non-comment
  line changed, revert it.

## Validation

The change is comment-only and must compile identically. Use the `ios-build-verify` skill
(see `CLAUDE.md` for the `IBV_SCRIPTS` resolution):

- `"$IBV_SCRIPTS/build_app.sh"` — app + widget build green.
- `swiftlint` (the `.githooks/pre-commit` hook runs it `--strict` on staged files) — clean.
- `"$IBV_SCRIPTS/run_tests.sh"` — the test files are in scope, so a test-target build is
  worthwhile even though comment edits shouldn't affect behavior.

## Commit

One commit on `main`, e.g.:
`Declutter comments to CLAUDE.md's comment policy`

Body: note that this deletes every `// MARK:`, all game-engine `///` helper docs and
`// Mechanic N:` labels, worked-example test labels that recompute the expected value, and
other thin restate-the-code labels — keeping file headers (incl. extended design prose),
TODOs/workarounds, the `// ID:` catalog tags, per-case license/linguistic glosses, and the
dense body of durable rationale (concurrency isolation, measured cold-starts, French
conjugation rules, degrade-not-crash paths). Unlike Conjugar's sweep, there was no
provenance paper trail to strip; Conjuguer's `finding #`/`#29` references are legitimate
why-this-guard rationale and stay.
