# Plan: Port the Pedagogy Work from Konjugieren

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
quiz logic, new practice modes, a persistent practice record, localized strings, Game Center
configuration, a little authored French content, and tests. **Written:** 2026-11-22, by porting
[`../Konjugieren/plans/pedagogy_implementation.md`](../../Konjugieren/plans/pedagogy_implementation.md)
(the **Konjugieren plan**), which built Josh's accepted suggestions from
[`../Konjugieren/docs/pedagogy_research.md`](../../Konjugieren/docs/pedagogy_research.md) (the
**report**) between 2026-11-13 and 2026-11-15. The goal is the same as Konjugieren's: make the
quiz, and the app around it, teach. The report's research on retrieval, spacing, feedback, and
motivation is not specific to German, and its section
[Conjugar and Conjuguer](../../Konjugieren/docs/pedagogy_research.md#conjugar-and-conjuguer)
records what a survey of Conjuguer's quiz found.

**This plan runs after [`browse_and_verb_implementation.md`](browse_and_verb_implementation.md)**
(the **browse plan**) is finished. Several phases here extend pieces that plan builds. Read its
Status table and its **How it differed** notes before starting any phase here.

## Status

Each session that finishes a phase fills in its row here, changes the **Status** line under the
phase's heading to match, and writes the phase's **How it differed** note. A finished phase that
Josh has not yet tried is "Awaiting Josh", with the Commit cell empty until it is committed.

| Phase | Status | Date | Commit | Suggestions | Konjugieren phase |
|---:|---|---|---|---|---:|
| 1 | Done | 2026-11-22 | 0d82e5c | T1.3, T1.4, T1.5, and two Conjuguer defects | 1 |
| 2 | Done | 2026-11-22 | b4aa188 | T1.2 | 2 |
| 3 | Done | 2026-11-23 | bfe5c7f | T4.1, T4.4, T4.5 | 3 |
| 4 | Done | 2026-11-23 | 954eda0 | T1.6 | 4 |
| 5 | Done | 2026-11-23 | bc2c6e6 | T2.3, T2.6, T6.7, M1 | 5 |
| 6 | Done | 2026-11-23 | b26cb07 | T2.1, T2.2, T2.5 | 6 |
| 7 | Done | 2026-11-23 | 609b1b8 | T2.7, T3.1, T6.5, M2, M3 | 7 |
| 8 | Done | 2026-11-23 | 3f12ff1 | Decision 4 | 8 |
| 9 | Done | 2026-11-23 | b181958 | T2.8 | 9 |
| 10 | Done | 2026-11-23 | 33da4be | T2.9, Decision 8 | 10 |
| 11 | Done | 2026-11-23 | 915be1c | T3.3 (the record), T3.4, T3.5, T6.4 | 11 |
| 12 | Done | 2026-11-23 | 2bc523b | T3.2, T3.3 (the session) | 12 |
| 13 | Done | 2026-11-23 | 249f7b9 | T6.1, T6.6 (the leaderboard's place) | 13 |
| 14 | Done | 2026-11-23 | 9568bdd | T4.2, T4.3 | 14 |
| 15 | Done | 2026-11-23 | 3966644 | T5.1 | 15 |
| 16 | Done | 2026-11-23 | 94df8f9 | T5.2 | 16 |
| 17 | Done | 2026-11-23 | 4ffc7a3 | T5.4 | 17 |
| 18 | Done | 2026-11-23 | 5694ad4 | T5.5 | 18 |
| 19 | Done | 2026-11-24 | 3077bf4 | T5.6 | 19 |
| 20 | Done | 2026-11-24 | a809734 | T6.2 | 20 |
| 21 | Done | 2026-11-24 | 444391d | T5.7 | 21 |
| 22 | Done | 2026-11-24 | a5b2806 | T6.3 | 22 |
| 23 | Done | 2026-11-24 | 5bb1765 | T6.6 (personal bests and achievements) | 23 |
| 24 | Done | 2026-11-24 | 5651584 | T6.8 | 24 |
| Closing | Not started | | | Audit, porting notes | Closing |

The phases keep Konjugieren's numbers, so a session can read the Konjugieren phase of the same
number beside its own.

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
The numbering follows the report's order of leverage (correct grading, then what the quiz asks,
then memory, then feedback, then new directions, then motivation). It is a suggested order. If a
phase proves too large for one session, split it, say so in its row, and leave the remainder
marked "Partly done". Phases 18 and 19 need authored French content and are the likeliest to
split.

**Read Konjugieren first.** Before writing code, read the Konjugieren phase of the same number,
its **How it differed** note, and the Konjugieren source files this phase names (the repository is
at `../Konjugieren`). Those notes record decisions Josh made while trying the screens (layouts,
wording, colors), traps in SwiftUI focus and TextField bindings, and test fixtures worth copying.
Port the design, not the code: Conjuguer's quiz is a different class with different scoring,
pools, and views.

**What this plan leaves to you.** The phases say what to build and what Josh decided. They do not
say how. Read the code, choose the implementation, and record in **How it differed** anything that
departs from the phase as written. A later session relies on that note more than on the phase
text above it. Read the notes of every phase this one depends on before starting.

**Decisions carried over from Konjugieren** are marked **Carried over** in each phase. This plan
assumes they hold for French unless Josh revised them in review. Where French makes one awkward,
say so and ask.

**Ask Josh when a decision does not settle a question.** Phases list such questions under **Ask
Josh**. Ask before building the part that depends on the answer, and record the answer and its
date in **How it differed**.

**Subagents run on Sonnet.** A session may delegate work to subagents, such as drafting Phase 18's
sentences or Phase 19's items. Any subagent it launches uses Sonnet (`model: "sonnet"` on the
Agent tool), as Josh decided for Konjugieren on 2026-11-15. The session still runs the machine
check and reads the drafts itself before Josh reviews them.

**Comments and docs say how things are, not how they got there.** The browse plan's phases left
about 90 Swift comments and 140 doc references that a sweep on 2026-11-22 had to remove. Follow
`CLAUDE.md` § Comments: a comment earns its place only as a file header, a TODO, a hack or
workaround, or rationale the code cannot show. In particular:

- No doc comment that restates a name or signature, such as `/// A verb just looked up.` above
  `lookedUp(at:)`. Most new properties and helpers need no comment at all.
- No pointers to plans in code or in living docs: no phase numbers, no "Decision 5", no "the
  pedagogy plan's practice record". That history belongs in **How it differed** and in
  `docs/blog_notes.md`. Work this plan leaves for later is a `// TODO:`. In code, also no "as Josh
  chose on 2026-11-22". A living doc may keep such an attribution where it marks a choice as
  deliberate, so that no later session "fixes" it.
- No change narration, such as "used to", "no longer", or "which gave *j'ai misu*". A regression
  test's comment states the rule the test pins, not the bug it fixed, and is omitted when the
  test's name and expected values already state it.
- A Konjugieren citation stays only as the evidence for a workaround, as in "(Konjugieren, iPadOS
  26.3)".
- `docs/feature_architecture.md`, `docs/voiceover.md`, and the `verify-in-simulator` skill
  describe the app as built, with no "since Phase N". `docs/privacy_policy_pending.md` is the
  exception: its own rules ask each staged section to name its phase and date.

**Every phase finishes the same way.**

1. Build and run the tests with the `ios-build-verify` skill, as `CLAUDE.md` describes. New logic
   gets tests that follow `.claude/rules/swift_testing.md`. Read the run's test count, not only its
   exit status. Question generation is random, so make its random source injectable (Konjugieren's
   `SeededRNG`) and test proportions with a fixed seed rather than with luck. Run the suite in
   English (`-testLanguage en` on a raw `xcodebuild`, if a simulator's language is French), since
   Konjugieren's Closing found 27 failures that were only English expectations meeting German.
2. For any visible change, launch the app and look at it on both the iPhone and the iPad, and exercise the phase's new states, not just its first screen. Josh
   tries changes on an iPhone and leaves the iPad to the session, so the session's check is the
   only one the iPad gets. On the iPhone, look in French and again in English; on the iPad, in
   English; between them cover light and dark. Relaunch with `-AppleLanguages "(fr)"` or
   `"(en)"`, and set the appearance with `xcrun simctl ui <udid> appearance dark` (or `light`).
   Extend the quiz's `CONJUGUER_QUIZ_FIXTURE` launch default with a fixture per phase rather than
   tapping through random quizzes.
   **Use only Conjuguer's own simulators**, "Conjuguer iPhone 17"
   (`AD93C7DA-EB19-4969-9291-44B92B66C3D9`) and "Conjuguer iPad Pro 11"
   (`2BD23264-485B-458D-9B00-895F29CED397`), never the plain iPhone 17 or iPad Pro 11-inch (M5),
   which Konjugieren and other work use. Conjugar's sessions run in parallel on "Conjugar iPhone
   17" and "Conjugar iPad Pro 11" (2026-11-22). The config's `TARGET_SIM` defaults to the iPhone;
   for the iPad, prefix a script with `TARGET_SIM="Conjuguer iPad Pro 11"`. `tap_tab.sh` uses
   iPhone coordinates, so on the iPad tap by identifier or by `describe_ui` frames. Always name
   the UDID in `simctl` commands: with several simulators booted, `simctl openurl booted` reaches
   the wrong one. Boot the iPad only for its check and shut it down after (`xcrun simctl shutdown
   <udid>`), since this Intel Mac runs two projects' builds and simulators at once. If a
   simulator hangs, ask Josh before restarting CoreSimulator, which stops every simulator,
   Conjugar's included.
3. Localize every new string in English and French, following
   `.claude/rules/localization_catalog.md`. A new setting's description begins "This setting
   determines...". Strings used by `Shared/` code belong in the widget's catalog too.
4. Follow `docs/voiceover.md`. The quiz announces each question through
   `Utterer`; every new state (a hold on a wrong answer, a second attempt, a diagnosis) needs an
   announcement a learner who cannot see the screen can act on.
5. Add analytics by the browse plan's convention (`docs/feature_architecture.md` § Analytics), and
   stage every new signal, parameter, or value in
   `docs/privacy_policy_pending.md` in English and French.
   **No signal may carry an answer, a count of right or wrong answers, or which verb or item was
   asked** (Decision 5, below). That a mode was started, quit, or finished, and from where, is
   fine.
6. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, keep `docs/feature_architecture.md` § Quiz true, add new accessibility
   identifiers to the `verify-in-simulator` skill's table, and run `python3 scripts/check_docs.py`.
   Read every comment the phase's diff adds (`git diff -U0 | rg '^\+\s*//'`) against **Comments
   and docs** above, and delete or rewrite any that fail it.
7. Fill in the Status row and the phase's Status line, write **How it differed**, and append a
   journal entry to `docs/blog_notes.md`.
8. **Stop before git.** Do not run `git add`, `git commit`, or `git push` until Josh has tried the
   changes. Tell him what changed and how to try it. Once he says he has tried them, commit and
   push to `main`, then record the hash in the Status row with a one-line follow-up commit, and
   push that too. Josh made this rule for Konjugieren on 2026-11-12.

**No release before 2027.** Every phase accumulates on `main`. App Store Connect work (Phases 8 and
23) prepares for that release. Release-day tasks go in `docs/release.md`.

**Conjuguer only.** Do not edit Konjugieren or Conjugar from a session of this plan.

## Conjuguer's Quiz Today

**Observed** in the code on 2026-11-22. The browse plan will have changed some of this; its notes
say how.

- **Thirty typed questions**, built by `Quiz.buildQuiz` (`Conjuguer/Models/Quiz.swift`). Regular
  draws by fixed quotas from curated pools in `QuizVerbs`: 7 indicatif présent (regular -er, -ir,
  -re, être/avoir/aller, stem changers), 6 passé composé (including an être verb and an irregular
  participle), 4 subjonctif présent, 3 imparfait, 3 futur, 3 conditionnel, 3 impératif, and 1
  participe présent. Persons rotate through `CyclingDeck`s. Ridiculous is thirty fixed
  verb-and-tense pairs, the same on every run, with only the person varying.
- **Grading** (`ConjugationResult.score`) compares lowercased strings against each "/"-separated
  alternate. A dropped circumflex anywhere counts as fully right (so etes passes for êtes). Any
  other accent difference is a partial match worth 5 of 10 points (parle for parlé). Nothing trims
  whitespace or accepts a typed pronoun.
- **Feedback.** A partial match plays a chirp and shows a half-filled icon with no correction until
  the results sheet. A wrong answer shows "Last answer / Correct answer" on the next question's
  card while the clock runs.
- **Scoring.** 10 points a right answer, doubled at Ridiculous, plus a time bonus of up to 450
  points if the score reaches 150 (`Quiz.bonusForElapsedTime`). Speed outranks accuracy. The best
  score is kept in settings and shown on the briefing card.
- **Defective cells are asked.** Ridiculous asks falloir's subjonctif imparfait in every person,
  though falloir has only il; `topThirties` includes faillir, whose impératif the quiz can ask.
- **Gender.** Être-verb compound answers follow the pronoun-gender setting, feminine by default.
  The prompt shows the gender ("je (fém.)"), and suis allé is marked wrong where suis allée is
  expected.
- **Game Center.** One leaderboard, found with `loadDefaultLeaderboardIdentifier`. Dismissing the
  results sheet always opens the leaderboard (`QuizView`'s `onDismiss`).
- **Analytics.** `quizStart` sends `difficulty`; `quizQuit` sends `difficulty`, the raw
  `lastQuestionIndex`, and the raw `elapsedTime`; `quizCompletion` sends `difficulty`, the
  `score`, and the raw `elapsedTime`. The deployed policy discloses the score and the elapsed time.
- **Also:** a Live Activity, `ChangeDifficultyTip` after a completed quiz, `TryQuizTip` in the
  verb list, a daily quiz question in the widget (`WidgetSnapshotWriter.generateQuizQuestion`,
  seeded by the date), and an on-device tutor in the Info tab.

## Suggestion Index

The report's suggestions, with the IDs the Konjugieren plan gave them and Josh's verdicts there.
"Conjuguer" says what this plan does with each.

| ID | Suggestion | Verdict in Konjugieren | Conjuguer |
|---|---|---|---|
| T1.1 | Decide the separable-verb convention | Accept both | Not applicable |
| T1.2 | Show the shape of the expected answer | Yes | Phase 2 |
| T1.3 | Strip a leading pronoun before grading | Yes | Phase 1 |
| T1.4 | Accept alternative letter spellings; letter keys on the answer field | Yes | Phase 1 (keys; French has no digraph spellings to accept) |
| T1.5 | Audit optional variants and accept every standard one | Yes | Phase 1 (the 1990 rectifications among them) |
| T1.6 | A slip is "almost", with one more attempt | Yes, half points on the second | Phase 4, replacing the partial match |
| T2.1 | Draw from frequency bands | Yes | Phase 6 |
| T2.2 | Prefer base verbs | Yes, one to three derivatives per quiz | Phase 6 |
| T2.3 | Levels ordered by use, replacing the difficulties | Yes | Phase 5 |
| T2.4 | Weight a newly opened conjugationgroup | **No** | Not built |
| T2.5 | A fixed mix of strong and weak verbs; the core verbs recur | Yes | Phase 6 (irregular and regular) |
| T2.6 | Thin auxiliary-only conjugationgroups | Yes | Phase 5 (the compound tenses) |
| T2.7 | Ten questions, with an offer to continue | Reluctantly, yes | Phase 7 |
| T2.8 | Learner-chosen scope | Yes | Phase 9 |
| T2.9 | A scope shareable as a link or a QR code | Yes | Phase 10 |
| T3.1 | Re-ask a missed question | Re-ask once | Phase 7 |
| T3.2 | Practice my mistakes | Yes | Phase 12 |
| T3.3 | A box and a due date per item, and a Review session | Yes | Phases 11, 12 |
| T3.4 | A ladder of 1, 3, 7, 14, and 30 days | Yes | Phase 11 |
| T3.5 | Two kinds of item | Yes | Phase 11 |
| T4.1 | Stay on a missed question until Continue | Yes | Phase 3 |
| T4.2 | Diagnose the error in one templated line | Yes | Phase 14 |
| T4.3 | Prompt a repair before revealing a diagnosable error | Yes | Phase 14 |
| T4.4 | Mark where the answer differs | Yes | Phase 3 |
| T4.5 | Link the correction to the verb and its group | Yes | Phase 3 (the verb and its model) |
| T4.6 | A language model that words a diagnosis | Not at this time | Not built |
| T5.1 | A key-conjugations exercise | Yes | Phase 15 |
| T5.2 | Group practice, one group, then mixed | Yes | Phase 16 (models) |
| T5.3 | Test yourself on this verb | Yes | Built by browse Phase 11 |
| T5.4 | Recognition questions | Yes | Phase 17 |
| T5.5 | Sentence frames for the core verbs | Yes | Phase 18 |
| T5.6 | Choice questions between two conjugationgroups | Yes | Phase 19 (two tenses or moods) |
| T5.7 | A speed round over mastered items | Yes | Phase 21 |
| T6.1 | The Quiz tab as a practice hub | Yes | Phase 13 |
| T6.2 | Show mastery | Yes | Phase 20 |
| T6.3 | A daily session, a repairable streak, an optional reminder | Yes | Phase 22 |
| T6.4 | Keep partial work | Partial: the trombone stays | Phase 11 |
| T6.5 | Hide the clock by default | Yes, as a setting | Phase 7 |
| T6.6 | Leaderboard out of the main path; personal bests and achievements | Yes | Phases 13, 23 |
| T6.7 | Rename the levels | Yes | Phase 5 |
| T6.8 | A daily shared challenge | Yes | Phase 24 |
| T6.9 | Make the arcade game conjugate | Outside the project | Not built |
| M1 | Send the level with the quiz's start | Built | Phase 5 |
| M2 | Report the question reached by a quiz abandoned by leaving the app | Built | Phase 7 |
| M3 | Report the time from start to quit in bands | Built | Phase 7 |
| M4, M5 | Accuracy signals | **No** (Decision 5) | Not built; the existing score signal is dropped (Phase 7) |

## Decisions Already Made

**Decided for Conjuguer** by Josh on 2026-11-22, when he reviewed this plan:

- **The score leaves analytics.** `quizCompletion` stops sending `score`, so the three apps agree
  with Konjugieren's Decision 5, and the elapsed time on the quiz signals is sent in M3's bands
  rather than in seconds (Phase 7). The deployed policy's line about the score and elapsed time
  changes with the release; stage it.
- **Agreement with être stays required.** The quiz keeps expecting the agreement the
  pronoun-gender setting gives (feminine by default), because agreement is French to be learned.
  Phase 2's frame makes the expected gender plainer, and Phase 14 names a wrong agreement and
  offers one more try.
- **The 1990 rectifications are accepted in the quiz only.** A reformed spelling typed by the
  learner (connait, il plait, j'amoncèle, je cèderai) passes, with the traditional spelling the app
  shows appearing quietly beside the checkmark, as Konjugieren shows the umlaut spelling. The verb
  page keeps the traditional spellings. Phase 1's audit settles which patterns count.
- **The time bonus is retired** everywhere but the speed round (Phase 21). Every level scores 10 a
  right answer, and nothing else.

**Carried over from Konjugieren**, from the report's verdicts and Josh's answers to its "Decisions
for Josh", and assumed to hold here:

- **Practice, not examination** (Decision 2). Where a choice between the two arises, choose
  practice.
- **Serve both audiences** (Decision 3): francophone users, who are most of Conjuguer's, and
  English-speaking learners. English glosses stay, and every new string is in both languages.
- **The leaderboard is re-scoped by level** (Decision 4), in Phase 8.
- **No accuracy signals** (Decision 5). The practice record stays on the device and is sent
  nowhere. Conjuguer's existing score signal goes (decided above).
- **Schools are a channel** (Decision 8). Shareable practice sets are the step toward it, and the
  Swiss institution makes this stronger for Conjuguer than for Konjugieren.
- **Conjuguer's minimum OS stays at 26** (Decision 9).
- **The arcade game is left as play** (Decision 7, T6.9).
- **The sad trombone stays** on quitting (T6.4).
- **Levels are chosen, not earned.** What has been opened does not shape quizzes (T2.4's No).
- **The default quiz is the classic quiz, modified** by this plan (levels, bands, ten questions).
  Scopes are choices beside it.
- **Re-ask a missed question once**, not until correct (T3.1).
- **A right second attempt earns half points** (T1.6).
- **No "principal parts" label** anywhere, nor "temps primitifs", in the interface or in code.
- **Every level scores 10 a right answer**, and scores never compare across levels.

Konjugieren's Decision 6 (Konjugieren first) is done, and Decision 10 (its store category) does not
apply: Conjuguer is already listed under Reference.

## What the Browse Plan Leaves for This One

Corrected 2026-11-22 by the browse plan's Closing, against the code as built at the end of browse
Phase 14 (`894ddba`). These are the names a phase of this plan will meet.
[`docs/feature_architecture.md`](../docs/feature_architecture.md) describes each in its section,
and the browse plan's **How it differed** notes say why each is shaped as it is.

- **Matching.** Search folds accents (`VerbSearch.fold`), which is right for search and wrong for
  grading (it would accept parle for parlé). Grading has its own comparison,
  `ConjugationResult.score`, which ignores case, accepts any of a cell's alternate conjugations,
  counts an answer that lacks only circumflexes as right (`totalMatch`), and one that differs
  only in other accents as `partialMatch`. Do not route grading through
  `VerbSearch`.
- **Edit distance.** `VerbSearch.editDistance(_:_:)`, optimal string alignment over `[Character]`,
  as in Konjugieren. The guess measures many candidates at once through `BoundedEditDistance` in
  `ConjugationIndex.swift`, which works over bytes and gives up past a bound. Phase 4 needs the
  first.
- **Which cell is this text?** `Verb.conjugations(matching:)` in `Models/ConjugationMatch.swift`,
  returning `[ConjugationMatch]` (`tense`, `isAgreement`) in the verb page's order. Accents must
  match exactly; case and spacing do not. A compound cell matches with its participle agreed either
  way, an impératif matches with or without its pronoun (souviens, souviens-toi), and a cell the
  defect group lacks never matches. Phases 4 and 14 call it first on a wrong answer.
- **The conjugation map.** `ConjugationMap` (`Models/ConjugationMap.swift`), written at build time
  by the `ConjugationMapTool` target into `ConjugationMap.lzfse` and read through
  `ConjugationMap.bundled`. `ConjugationMap.key(_:)` normalizes a spelling, and
  `agreedForms(ofParticiple:)` gives allée, allés, allées. `ConjugationIndex` indexes it by folded
  spelling for search. Phase 17 reads it.
- **Key conjugations.** `Verb.keyConjugations()` (`Models/KeyConjugations.swift`) returns the il
  présent, passé composé, and futur simple (`Verb.keyTenses`), "vient · est venu · viendra", as
  Josh decided on 2026-11-22. They stand without a subject pronoun, so they are always masculine,
  whatever the pronoun-gender setting, and a reflexive verb keeps its pronoun (se souvient). A form
  the defect group marks unused is left out: gésir gives only gît, and accroire and the other verbs
  used only in the infinitif give none, so check for an empty array. Phases 11
  and 15 use them. Shown with no label, never "principal parts" or "temps primitifs".
- **The accent key row.** `FrenchLetterKeyRow` (`Views/FrenchLetterKeyRow.swift`), é è ê â î ô û
  ç, with an `insert: (String) -> Void` closure. Today the Verbs and Models tabs' search fields show
  it; the quiz's answer field does not. Phase 1 puts it there. Konjugieren's Closing found the same
  gap in its own quiz.
- **Scopes.** `QuizScope` (`Models/QuizScope.swift`): `.allVerbs`, `.myVerbs(_:)`,
  `.verbPage(_:)` (three questions), and `.collection(_:)` (defined in `VerbCollection.swift`).
  Each carries `verbs` (nil for the default quiz), `questionCount`, `source`, an optional `title`,
  and an optional `collection`. `isRanked` is `verbs == nil`, so only the default quiz posts to Game
  Center, sets the best score, and donates `ChangeDifficultyTip`; a scoped quiz is always Regular.
  `QuizSheet` (in `Views/QuizView.swift`) runs a scoped quiz over a verb page or a collection.
  A level is to be another constructor.
- **Bands and collections.** `FrequencyBand` (`.top100`, `.top300`, `.top1000`, by rank),
  `Verb.isIn(_:)`, and `Verb.verbs(in:)` in `Models/FrequencyBand.swift`. `VerbDraw.isIrregular`
  (`Models/VerbDraw.swift`) says what counts as irregular. `VerbCollection` has four featured cases
  (`top100`, `etre`, `irregularFutur`, `pronominal`) and `.model(_:)` for each of the 99 models,
  with `verbs`, `contains`, and `analyticsValue`, which says only `model` for any model so that a
  one-verb model never names its verb. Josh chose all 99 models as collections on 2026-11-22.
- **A due date per verb.** `ReviewSchedule` (`Shared/ReviewSchedule.swift`): a box and a due
  date on the ladder `intervals` = 1, 3, 7, 14, 30 days, with `lookedUp(at:calendar:)`,
  `reviewed(at:calendar:)`, `snoozed(at:calendar:)`, and `isDue(at:)`. It is the optional
  `review` field of `LearnerVerbs.Entry` (`Shared/LearnerVerbs.swift`), and
  `LearnerVerbStore` (`Current.learnerVerbs`) drives it through `recordOpen(_:source:)`,
  `recordReview(_:)`, `snoozeReview(_:)`, and `verbDueForReview(at:)`. Entries are keyed by
  `Verb.dictionaryKey`, so each entry of a doubled infinitive (haïr) keeps its own schedule.
  **Every field added to the record must be optional**, or older records decode as nothing.
  This is Konjugieren's browse version (its commit 65d5eb6), not its current one: Konjugieren's
  pedagogy Phase 11 moved the schedule into a `PracticeRecord` and added `answered` and `new`.
  Read its current `Shared/ReviewSchedule.swift` before Phase 11 folds this one in.
- **Related verbs and bases.** `RelatedVerbs` (`Models/RelatedVerbs.swift`), with
  `RelatedVerbs.base(of:)` for a prefixed verb's base. Phase 6's "derivative verbs" reads them.
- **The `source` vocabulary.** `AnalyticsSource` in `Analytics/Analytics.swift`. The quiz signals
  already send `tab`, `myVerbs`, `verbPage`, and `list` (a collection), and `quizStart` sends
  `collection`. A new quiz entry point adds its value there and stages its privacy line.
- **Thirty is wired in, though less than expected.** `Quiz.questionCount` is 30. The Live
  Activity starts only for a thirty-question quiz that is not a collection's
  (`QuizScope.startsLiveActivity`), and the collection bar's hint names the count. Ranking and the
  tip donation follow `isRanked`, not the count. The time bonus follows neither: it applies to any
  quiz whose score reaches 150. Phases 5, 7, and 8 revisit each.

## Phase 1: Accept What Is Right, Ask What Exists

**Suggestions:** T1.3, T1.4, T1.5, and two Conjuguer defects. **Ports:** Konjugieren Phase 1
(`AnswerSpelling.swift`, `StandardVariants.swift`,
[`../Konjugieren/plans/pedagogy_phase1_variant_audit.md`](../../Konjugieren/plans/pedagogy_phase1_variant_audit.md)).
**Depends on:** browse Phase 1 for the key row. **Status:** Done.

- **Trim and collapse.** Ignore leading and trailing whitespace and runs of spaces, which nothing
  does today. Compound answers have two or three words.
- **T1.3.** Strip a leading subject pronoun that matches the question's person before grading: je
  and elided j', tu, il, elle, or on for the third-person singular, nous, vous, ils or elles. For a
  pronominal verb, also strip a reflexive pronoun (me, m', te, t', se, s', nous, vous) if the
  verb's answer does not include it; decide with Phase 2 whether a reflexive answer includes it.
  "j'ai mangé" and "nous sommes allés" pass.
- **T1.4.** Show the browse plan's accent key row above the keyboard while the answer field is
  focused, inserting at the cursor. Konjugieren found that the toolbar placement works for an
  ordinary `TextField` (unlike the search field). French has no digraph spelling to accept, so the
  rest of T1.4 does not apply.
- **T1.5.** Audit optional standard conjugations and accept each Josh approves. Candidates: the
  doublets `verbModels.xml` may not already give as "/" alternates (je paie and je paye, je
  m'assieds and je m'assois); and the **1990 rectifications**, which Josh accepted
  for the quiz on 2026-11-22: no circumflex on i and u except where it distinguishes (connait, il plait, but
  nous vînmes, qu'il vînt, dû, crû); -eler and -eter verbs conjugated with è apart from appeler,
  jeter, and their derivatives (il étiquète, j'amoncèle); è in the futur and conditionnel of
  céder-type verbs (je cèderai); assoir. Check each pattern against an authority (the
  Académie's and the Conseil supérieur de la langue française's texts, the Bescherelle, or the
  TLFi) and give the source per row. Replace the blanket circumflex rule with the audited one; a
  dropped circumflex that no rule accepts becomes Phase 4's slip.
- **Stop asking cells that do not exist.** Filter every draw through the verb's defect group
  (`DefectGroup.isDefectiveForTense`), so falloir is asked only in the third-person singular and
  faillir never in the impératif. Konjugieren's report estimated about one Regular quiz in five
  asks such a cell.
- **Agreement stays required** (Josh, 2026-11-22). A learner who types suis allé where the setting
  asks for suis allée is still wrong. Until Phase 14 names the error, it is at least a one-letter
  slip under Phase 4.

**Carried over:** a variant typed by the learner passes, and the spelling the app shows appears
quietly beside the checkmark (Konjugieren's choice for its umlaut spellings, 2026-11-13).

**Ask Josh:** to rule on each row of the audit before any variant is accepted. Put the audit in
`plans/pedagogy_phase1_variant_audit.md`, beside this plan, as Konjugieren did. Variants become
accepted answers only, not new conjugations on the verb page, unless he says otherwise.

**Done when** " parle ", "je parle", "j'ai parlé", and the ruled variants pass; etes for êtes no
longer passes; no draw under a fixed seed asks a defective cell; the key row inserts into the
answer field; and tests pin each.

**How it differed:**

- **Grading moved into `ConjugationResult.grade(proposedAnswer:correctAnswers:verb:tense:)`**,
  which returns an `AnswerGrade` (the result and, for a variant, the app's spelling). It needs the
  verb and tense, which the old string-only `score` did not have. `AnswerSpelling` reads the answer
  first: case, whitespace runs, and the curly apostrophe, which the simulator's keyboard typed for
  j' in every trial. Without that, "j’ai parlé" would have failed.
- **Pronouns.** The third-person singular takes il, elle, or on, and the plural ils or elles,
  whatever the gender setting. Agreement is still graded on the participle, so "il est allée"
  passes where elle was asked; the pronoun is ignored rather than checked against the gender. The
  conjugator gives a pronominal verb's cells without the reflexive pronoun (souviens, suis
  souvenue), so Phase 2 inherits that: a reflexive answer does not include it, and the quiz strips
  it when typed, along with the impératif's -toi, -nous, and -vous.
- **The audit is its own file**, [`pedagogy_phase1_variant_audit.md`](pedagogy_phase1_variant_audit.md),
  with its method, sources per row, and Josh's rulings of 2026-11-22. It mined English Wiktionary
  (4,296 forms the conjugator lacks, across 308 verbs) and checked the 1990 rows against the
  *Journal officiel* text in the Académie's PDF, the doublets against Larousse. Josh accepted
  every recommended row. The official text settled three questions the plan left open: croître
  keeps every circumflex while accroître and redevoir lose theirs (accroit, redu), mû becomes mu,
  and of the asseoir family only surseoir's futur changes (sursoirai).
- **R2 runs both ways.** The verb page writes sixteen -eler and -eter verbs in the rectified
  spelling already (ruissèle, nivèle, cachète) and the rest traditionally (étiquette), which
  surfaced when ruisseler's test failed. Larousse lists both for each of the sixteen, so the quiz
  accepts the doubled consonant for them, and the è for the others. Twenty-six verbs whose
  traditional spelling has the è (acheter, geler, harceler, modeler) accept no doubled form. Josh
  chose to leave the sixteen pages as they are.
- **The dropped circumflex that no rule accepts** (etes for êtes, clot for clôt) is now a partial
  match, five points, through the existing diacritic fold. Phase 4 replaces the partial match.
- **Defective cells.** The default quiz asked falloir in every person (Ridiculous's subjonctif
  imparfait, and the irregular-participle and futur pools) and faillir in the impératif. A drawn
  person the verb lacks now gives way to the next one it has, and a verb without the whole tense
  gives way to the pool's next verb. `Quiz` takes a `seed`, and `QuizTests` checks a hundred seeded
  quizzes at each difficulty. Scoped quizzes already filtered through `Verb.hasCell`.
- **The key row** is a `ToolbarItem(placement: .keyboard)` and inserts at the cursor through a
  `TextSelection` binding, as Konjugieren's does. Verified on the iPhone 17 and the iPad Pro 11
  with the hardware keyboard, where iOS floats the toolbar at the bottom; insertion mid-word
  landed at the cursor. AXe cannot see the toolbar's keys, so the skill now gives their
  coordinates. The software keyboard's placement was not tried.
- **A new fixture**, `-CONJUGUER_QUIZ_FIXTURE grading`: ten questions, three times over, whose
  answers are listed in `docs/feature_architecture.md` § Quiz.
- **Verified** in French (light) and English on the iPhone, and in English and dark on the iPad.
  The iPhone simulator would not draw the app dark after `simctl ui appearance dark`, through
  relaunches, so dark was checked on the iPad only. VoiceOver's spoken "Correct. Also spelled:"
  was not heard; the label was read from the accessibility tree.
- **Analytics:** none added, so nothing is staged in `docs/privacy_policy_pending.md`.
- **Tests:** 557 to 568, with `AnswerSpellingTests`, `StandardVariantsTests`, a rewritten
  `ConjugationResultTests`, and four new `QuizTests`.

## Phase 2: The Shape of the Answer

**Suggestions:** T1.2. **Ports:** Konjugieren Phase 2 (`AnswerFrame.swift`,
`AnswerFrameView.swift`). **Depends on:** Phase 1. **Status:** Done.

Show the shape of the expected answer around the field, with the pronoun fixed outside it:
`nous ______`, `elles ______`. The frame settles the pronoun question. Build it as a component the
later question types reuse (Phase 15's several blanks, Phase 18's sentences).

French specifics:

- **Elision.** Whether to show `je` or `j'` depends on the answer's first letter, so a fixed `j'`
  tells the learner the answer begins with a vowel or a mute h. Konjugieren decided the frame may
  reveal what the answer's shape implies, since the quiz is practice. Show Josh both: a frame that
  elides, and one that shows `je` and accepts the elided pronoun typed into the field.
- **Pronominal verbs.** `je me ______` or `je m'______`, the same question, and `______-toi !` in
  the impératif.
- **The impératif** shows no pronoun; show the person as Konjugieren did (`(tu) ______ !`), since tu
  and vous take different answers.
- **Gender** in the frame. Agreement stays required (Josh, 2026-11-22), so the frame must make the
  expected gender plain for je, tu, nous, and vous, whose pronouns do not show it:
  `je (fém.) ______` or a clearer mark. Offer Josh more than one.
- **Participles** have no pronoun.

**Carried over:** inline rounded fields with the fixed words on the same line; Return submits; the
frame's pronoun is not graded, so a learner who types it is still right; VoiceOver reads the frame
as one prompt ("nous, blank").

**Ask Josh** to choose among two or three mockups before building, elision among them.

**Done when** every tense and person shows a frame, pronominal verbs and the impératif frame
correctly, VoiceOver reads it as one prompt, and tests pin the frame for each kind of question.

**How it differed:**

- **Josh chose on 2026-11-22**, from three mockups each: a frame that **elides** (`j'`, `je m'`,
  `tu t'`) over one that always shows `je` and `je me`, and over a neutral `j(e)`; the gender as
  **`(fém.)` or `(masc.)` after the pronoun**, in the caption font and gray, over a tinted badge
  and over a word on the tense line; and the gender **in compound tenses only**, over every tense.
  He accepted that eliding reveals the auxiliary for je in a compound tense (j' means avoir),
  since the quiz is practice. Showing the gender for every compound tense, avoir verbs included,
  keeps the mark from revealing anything.
- **The frame's pronoun follows the elision of the expected answer**, so `tu t'` appears for
  `tu t'es souvenue` as well as `je m'` for s'absenter. The test that first expected `tu te` was
  wrong, not the frame. It reuses `PersonNumber.preamble`, which now has a variant that takes the
  pronoun gender, so tests need not set `Current`.
- **The gender mark sits after all the pronouns**, `je me (fém.)` and `j' (fém.)`, rather than
  between je and me, so the pronouns read as one group before the field.
- **The impératif passé** shows its addressee and the gender: `(vous) (fém.) ______ !`. No quiz
  pool asks it today, but a scoped or later quiz might. A pronominal impératif passé gets no
  `-toi`.
- **The ask line now names only the tense.** The pronoun and gender moved into the frame, and
  `Tense.pronounWithGender`, which only the ask line read, is gone. VoiceOver's announcement
  still says the pronoun, and says the gender only in a compound tense, to match the frame.
- **One blank only.** `AnswerFrameView` takes the field as a view builder and draws the frame's
  words before and after it, outside the `ForEach`es, so the field keeps its identity and the
  keyboard its focus (the bug Konjugieren found by looking). Konjugieren's multi-blank and
  sentence machinery was not ported: Phase 15 and Phase 18 add blanks when they need them.
- **VoiceOver.** The field's label is `AnswerFrame.spokenPrompt` ("je, feminine, blank"; "elles
  se, plural, blank"; "tu, blank, toi"), with three new strings: blank ("à compléter"),
  singular, and plural. An elided pronoun is read whole. Read from the accessibility tree, not
  heard.
- **A new fixture**, `-CONJUGUER_QUIZ_FIXTURE frames`: fifteen questions, one per kind of frame,
  twice over, listed in `docs/feature_architecture.md` § Quiz.
- **Verified** on the iPhone 17 in French (all fifteen frames, light) and in English, and on the
  iPad Pro 11 in English and dark, with the hardware keyboard. Focus survived every change of
  frame, and the é key still inserted into the field. The software keyboard was not tried.
- **Analytics:** none added, so nothing is staged in `docs/privacy_policy_pending.md`.
- **Tests:** 568 to 571, with `AnswerFrameTests`: the frame for 23 kinds of question, one blank
  in every cell of eight verbs under each gender setting with the frame's words typed and still
  graded right, and the spoken prompt.

## Phase 3: A Correction That Stays

**Suggestions:** T4.1, T4.4, T4.5. **Ports:** Konjugieren Phase 3 (`QuizCorrectionView.swift`,
`AnswerDifference.swift`). **Depends on:** nothing; Phase 2 preferably. **Status:** Done.

Today `Quiz.process(proposedAnswer:)` advances before the view redraws, so the correction for
question n appears on question n + 1's card while the clock runs, and a partial match is never
corrected during the quiz. The report called this most needed in Conjuguer.

- **T4.1.** After a wrong or partly right answer, stay on the question: its prompt, the learner's
  answer, the correct answer, and a Continue button, which Return also triggers. Pause the clock
  while the correction shows. After a right answer, advance at once.
- **T4.4.** Mark where the learner's answer differs from the correct one, in a treatment visibly
  different from the red letters that mark irregularity, and readable by VoiceOver. A missing or
  wrong accent is a difference to mark.
- **T4.5.** Link the correction to the verb's page and to its model's page. Opening one pauses the
  clock and returns to the held question. In a quiz begun from a verb's own page, leave out the
  link back to it, and hide "Test me" and a collection's Quiz button on pages pushed over a held
  question.

Replace `previousIncorrectAnswer` and `previousCorrectAnswer` and the rows they feed. A wrong last
answer shows its correction before the results.

**Carried over:** the correction sits in the question's card under the answer field; Continue
capped in width on iPad; the nearest accepted spelling is the one shown; VoiceOver focus moves to
the correction, which names the differing letters when there are three or fewer.

**Ask Josh** to judge the layout on a device-sized screen before polishing.

**Done when** a wrong answer holds with the clock stopped, Continue advances, the difference is
marked, both links work and return, and tests pin the state machine.

**How it differed:**

- **The layout is built, not yet judged** (the Ask Josh above). The correction is a card under the
  answer field, its accent bar the result's color (red for wrong, blue for partly right): Your
  Answer and Correct Answer, each label over its answer, a row of two capsule links, and Continue,
  capped at 400 points and centered on the iPad. The field keeps the learner's answer and the
  keyboard, so Return continues. Konjugieren's "question's card" has no counterpart here, since
  Conjuguer's quiz draws no card around the question.
- **A partly right answer holds too**, as the phase asks, and is spoken "Partly right." It still
  scores five points until Phase 4 replaces the partial match.
- **Which right answer is shown.** `AnswerDifference.nearest` reads the answer through
  `AnswerSpelling.candidates`, so a typed subject or reflexive pronoun, or an impératif's -toi, is
  dropped, and compares each reading with each "/" alternate, the first winning a tie. The
  learner's answer is shown as grading reads it, lowercased with a straight apostrophe, rather
  than in the learner's capitals as in Konjugieren.
- **The marking** is Konjugieren's alignment, ported. Conjuguer draws regular letters blue and
  irregular ones red, so a marked letter of the right answer keeps its color over a green tint and
  a green underline, and a marked letter of the learner's answer is red, tinted, and struck
  through. The tints were strengthened (0.35 and 0.4) after the iPad's dark screenshots.
- **Navigation.** The Quiz tab's `QuizView` had no navigation stack. It now holds one, with
  `verbPageNavigation` and the root's bar hidden, in the tab and in `QuizSheet` alike. Pages pushed
  in the sheet get no Done, which would have closed the sheet without Quit. The model link reads
  "Model: venir (6-7)". A quiz restarted by a link while a pushed page shows pops the page.
- **The clock** stops through `Quiz.clockTicked()`, which the timer calls and tests call directly.
  The Live Activity's `Text(_, style: .timer)` cannot pause, so its start date moves later by the
  time the clock stood still each time the activity updates. During a hold the Lock Screen keeps
  counting and then jumps back at Continue. Not seen on a Lock Screen.
- **Smaller changes.** The feedback slot is empty after Continue, since the correction has been
  read, and shrank from 64 to 36 points without the two rows it held. A wrong last answer buzzes,
  and the applause waits for Continue.
- **VoiceOver.** `Quiz` does not announce a held answer; focus moves to the correction, which
  reads "Incorrect. Your Answer: parle. Correct Answer: parlé. Letters that differ: é." (the
  letters only when three or fewer), with the hint "Swipe right for the links, then Continue."
  Each link and Continue have hints, and a Magic Tap continues. Read from the accessibility tree,
  not heard.
- **Analytics:** one new `source` value, `quizCorrection`, on the verb page's `viewAppeared`.
  Unlike Konjugieren, whose wording already covered it, Conjuguer's staged bullet lists examples
  that did not suggest a quiz, so a new section of `docs/privacy_policy_pending.md` adds "a quiz's
  correction" to them in both languages.
- **Removed:** `Quiz.previousIncorrectAnswer`, `previousCorrectAnswer`, the rows they fed, and the
  string `QuizView.lastAnswer`.
- **A new fixture**, `-CONJUGUER_QUIZ_FIXTURE corrections`: eight questions, once, each with a
  wrong answer listed in `docs/feature_architecture.md` § Quiz that shows a kind of marking.
- **Verified** on the iPhone 17 in French (light) through all eight answers: each held with the
  clock stopped (the results said 0:38 for about two minutes of play), both links opened and Back
  returned to the held question with Return still continuing, the verb page scrolled to the asked
  cell and hid Test Me, the model page's collection bar hid its Quiz button, and the last answer
  held before the results. In English, Test Me's sheet showed no verb link, and its model page
  pushed with Back and no Done. On the iPad Pro 11 in English and dark, the hold, the verb link,
  Back, and Return behaved the same. Not tried: the software keyboard, which may cover Continue on
  a small phone, the iPhone in dark, and VoiceOver by ear.
- **Tests:** 571 to 587, with `AnswerDifferenceTests` and six new `QuizTests` for the state
  machine. The tests that answer "x" in a loop now continue after each.

## Phase 4: One More Try

**Suggestions:** T1.6. **Ports:** Konjugieren Phase 4 (`AnswerSlip.swift`). **Depends on:**
Phase 3. **Status:** Done.

Treat a slip as "almost" and allow one more attempt. A right second attempt earns half the points.
A wrong second attempt goes to Phase 3's correction. **This replaces the partial match**: half
credit is earned by fixing the slip, not by making it.

- A slip is one edit by optimal string alignment, or any number of missing or wrong accents,
  cedillas, and circumflexes (compared on bare letters), in an answer of four or more letters.
- **An answer that is itself another conjugation of the verb is not a slip.** Check
  `Verb.conjugations(matching:)` first: parle for parlé is the présent, not a slip; eut for eût is
  the passé simple, fut for fût likewise. Treat a match as a real error, which Phase 14 will name.
- A question gets at most one second attempt, whatever triggered it. Phase 14 shares the mechanism.
- The results and the progress show which answers were right on the second attempt.

**Carried over:** four letters or more; the first attempt stays in the field to edit; a second-try
count apart from the correct answers, with its own color; the wording, translated from Konjugieren's
"Almost! Try once more." and "Second Try:" (propose the French to Josh: "Presque ! Encore un
essai." and "Deuxième essai :").

**Done when** a dropped accent and a one-letter slip each prompt one more try, another cell does
not, half points are scored and shown, and tests pin each case, including parle/parlé and
eut/eût.

**How it differed:**

- **The wording is as proposed**: "Almost! Try once more." / "Presque ! Encore un essai.",
  "Second Try: 2" / "Deuxième essai : 2", and "First Try:" / "Premier essai :" on a results row,
  each French space a narrow no-break space (U+202F). The strings were first built without the
  space, to match their neighbors ("Correcte: 7 / 30"). Josh then chose, on 2026-11-23, the narrow
  space before every colon, semicolon, exclamation mark, and question mark, and inside guillemets,
  and a separate commit swept both catalogs to it before this phase was committed.
- **The partial match is gone.** `ConjugationResult.grade` returns a total or no match only, so
  etes for êtes is now wrong as graded. `.partialMatch` became `.secondAttemptMatch`, a question's
  result that `grade` never returns, worth 5 points times the difficulty's multiplier, with a
  hollow orange check (`Color.secondAttempt`, system orange, the color Konjugieren chose). Its
  chirp moved to the "almost" moment. `correctnessScore`, `percentCorrect`, the string
  `QuizView.partlyRight`, and `DoubleExtension.swift`, whose only use was formatting a score like
  7.5, went with it. `QuizCorrection` lost its `result`, since only a wrong answer holds now.
- **The rule** (`AnswerSlip.swift`): within one edit by optimal string alignment, or equal once
  every diacritic is folded away (`folding(.diacriticInsensitive)`, so cedillas too), against every
  "/" alternate and `StandardVariants` spelling, reading the answer through
  `AnswerSpelling.candidates`. Four letters are counted in the right spelling, letters only, as
  Konjugieren counts them: `ete` for été is not a slip, `vex` for veux is.
- **Another cell, but not the asked one.** `Verb.conjugations(matching:)` matches a compound cell
  with its participle agreed either way, so suis allé matches the asked passé composé itself. A
  match in the asked tense does not count as another cell, which keeps the agreement error a slip,
  as Phase 1 expected until Phase 14 names it. parle for the participe passé, prit for prît, finit
  for finît, and viens for il vient are real errors. eut and fut are under four letters anyway, so
  the four-letter pair prit/prît pins the rule that eut/eût illustrates.
- **ai parle for ai parlé is a slip**, although parle is a présent: the whole answer is no cell.
  Only a bare participe passé question meets "parle for parlé" as the plan means it.
- **The state** is `Quiz.firstAttempt`, set by a slip and cleared once the question is graded.
  Conjuguer records a result only when a question is graded, so a slip leaves `quizResults`
  untouched, and `QuizResult.firstAttempt` keeps the slip for the results. A row shows "First Try:"
  whether the second attempt was right or wrong, a small departure from Konjugieren, which shows it
  only on a right one. Phase 14 should set `firstAttempt` for a diagnosable error, so the one-try
  limit holds whatever triggered it.
- **"The progress."** Conjuguer has no dots. The feedback slot shows "Almost! Try once more." while
  the question waits, and the hollow orange check on the next question after a right second
  attempt; the results count second tries apart under "Correct", which counts first attempts only,
  as does the Live Activity.
- **The clock runs** through the second attempt, as in Konjugieren.
- **VoiceOver.** The slip is spoken through `Utterer` in the interface's language, and focus stays
  in the field. Not heard.
- **A new fixture**, `-CONJUGUER_QUIZ_FIXTURE slips`: twelve questions, their answers in
  `docs/feature_architecture.md` § Quiz. The corrections fixture's wrong answers are mostly slips
  now, so its note says to type each twice.
- **Analytics:** none added, so nothing is staged in `docs/privacy_policy_pending.md`.
- **Verified** on the iPhone 17 in French (light) through all twelve: seven slips asked for one
  more try with the answer still in the field and the keyboard back, a second achete reached the
  correction, and finirions, parle, prit, eut, and viens went straight to it. The results read 30,
  "Correcte: 0 / 12", "Deuxième essai: 6", with "Premier essai:" rows. In English, the same line
  and results. On the iPad Pro 11 in English and dark, the slip, the right second try, and its
  orange check. There `tap_id.sh` and `type_text.sh` failed to parse the accessibility tree, so the
  skill now says to tap by frame and paste. Not tried: the software keyboard and VoiceOver by ear.
- **Tests:** 587 to 593, with `AnswerSlipTests` (26 cases in three tests) and four new `QuizTests`
  replacing the partial match's one. `ConjugationResultTests` now expects no match for the five
  former partial matches.

## Phase 5: Levels

**Suggestions:** T2.3, T2.6, T6.7, M1. **Ports:** Konjugieren Phase 5 (`QuizLevel.swift`,
`QuizDraw.swift`). **Depends on:** Phase 1. **Status:** Done.

Replace Regular and Ridiculous with four levels ordered by use, each adding to the one before.
Konjugieren's ladder came from the report's study of German curricula. French needs its own: read
a CEFR progression for French (the Council of Europe's reference level descriptions for French, by
Beacco and others, or the DELF descriptors, and a current textbook series' scope and sequence), and
propose a ladder with sources. A draft to test against them (**inference**):

| Level | Roughly | Tenses added |
|---|---|---|
| 1 | A1 | Indicatif présent; impératif |
| 2 | A2 | Passé composé and the participe passé; imparfait; futur simple |
| 3 | B1 | Conditionnel présent; subjonctif présent; plus-que-parfait; conditionnel passé; futur antérieur |
| 4 | B2 and above | Passé simple; subjonctif passé, imparfait, and plus-que-parfait; passé antérieur; participe présent; the rest |

- Some cells may be restricted to certain verbs or persons (a level might ask the passé simple only
  in the third person, as texts use it). The draw must pick a verb and person that fit the cell.
- **T2.6.** Give fixed lower weights to tenses whose only new part is the auxiliary: every compound
  tense except the passé composé, which tests the auxiliary choice and the participle. Weights are
  fixed per level, never adjusted by what the learner has done.
- **T6.7.** The names must not tell a learner that part of the app is a joke. Ridiculous and its
  thirty fixed pairs go.
- Every level scores 10 a right answer. The difficulty multiplier goes, and so does the time bonus
  (Josh, 2026-11-22); Phase 21's speed round is where speed counts.
- Migrate the stored `quizDifficulty` setting to a new key. Revisit `ChangeDifficultyTip`, the
  briefing card, the results, the Live Activity's difficulty, the onboarding text that names the
  difficulties, `docs/description.txt`, and the `difficulty` parameter on the quiz signals.
- **M1.** `quizStart` already carries the difficulty; it now carries the level instead. Stage the
  changed policy line ("Quiz difficulty level (regular or ridiculous)").

**Carried over:** levels chosen, nothing unlocks; named with words, not numbers or CEFR labels; a
new install starts at Level 1; a stored Regular becomes Level 2 and Ridiculous Level 4; scoped
quizzes use the learner's level; level tiles with a gauge rather than a four-segment picker,
which truncated in Konjugieren.

**Ask Josh:** the ladder, with its sources; the weights; and the names. Konjugieren's German names
avoided a masculine noun (Anfänger). Candidates: Débutant, Élémentaire, Intermédiaire, Avancé
(Débutant is masculine); Découverte, Survie, Seuil, Avancé (the CEFR's own French names for A1 to
B2); or Initiation, Bases, Approfondissement, Maîtrise.

**Done when** each level draws only its own cells, restricted cells draw only their verbs and
persons, the thinned tenses appear at their weight under a fixed seed, settings migrate, the
level is sent, and tests pin each level's pool.

**How it differed:**

- **Josh chose the ladder on 2026-11-23**, the sourced one over the draft above. It moves the
  conditionnel présent to Elementary, the participe présent to Intermediate, and the futur
  antérieur and subjonctif passé to Advanced:

  | Level | Roughly | Tenses added |
  |---|---|---|
  | Beginner (Débutant) | A1 | Indicatif présent; impératif |
  | Elementary (Élémentaire) | A2 | Passé composé and the participe passé; imparfait; futur simple; conditionnel présent |
  | Intermediate (Intermédiaire) | B1 | Subjonctif présent; plus-que-parfait; conditionnel passé; participe présent |
  | Advanced (Avancé) | B2 and above | Futur antérieur; subjonctif passé; passé simple; subjonctif imparfait and plus-que-parfait; passé antérieur; passé surcomposé; impératif passé |

  The sources: the Université de Genève Maison des langues' "Éléments de grammaire A1–A2" and
  "B1–B2" (2025), whose A1–A2 volume covers the présent, impératif, passé composé, imparfait,
  futur simple, conditionnel présent, subjonctif présent, and gérondif, and whose B1–B2 volume adds
  the plus-que-parfait, futur antérieur, conditionnel passé, subjonctif passé, participe présent,
  and passé simple ("réservé à la langue écrite"); the Clermont-Ferrand CASNAV's B1 sheet after the
  Eaquals/CIEP 2015 inventory (the subjonctif at B1, the passé simple at B1 for recognition); and
  Antwerp's B2 inventory (the futur antérieur at B2). The Beacco référentiels themselves and the
  Lille CASNAV grid could not be fetched.
- **No restricted cells.** Josh chose, the same day, to ask every tense in every person, over
  asking the passé simple and passé antérieur only in il and ils and the subjonctif imparfait and
  plus-que-parfait only in il. So the "restricted cells" of **Done when** do not exist. Only the
  defect groups restrict, as before.
- **The weights are Konjugieren's**, as Josh chose: the présent and passé composé 3; the impératif,
  imparfait, futur simple, conditionnel présent, subjonctif présent, passé simple, and subjonctif
  imparfait 2; the other compound tenses and both participles 1. They total 30 at Advanced.
- **The names are Débutant, Élémentaire, Intermédiaire, and Avancé**, and Beginner, Elementary,
  Intermediate, and Advanced in English (Josh, 2026-11-23). The French adjectives agree with
  "niveau", which is how the results write them ("Niveau : Avancé").
- **How the draw works.** `QuizLevel.slots` lists each level's tenses as `QuizTenseSlot`s, which
  moved from `QuizScope.swift` to `QuizLevel.swift` and grew from eight tenses to all nineteen the
  quiz can ask, each with `cells`, `weight`, and `verbPools`. Each question draws a slot by weight,
  then, in the default quiz, one of the slot's curated pools (`QuizVerbPool`, a name for each
  `QuizVerbs` list), then that pool's next verb from its deck. The pools keep Regular's structure:
  an être verb or an irregular participle in every compound tense, irregular futur stems in the
  futur and conditionnel, and for the passé simple and subjonctif imparfait the irregular
  participles, whose verbs are mostly the ones with irregular passé simple stems. Phase 6 replaces
  or intersects these with the bands. Ridiculous's thirty fixed pairs are gone, and with them the
  test that falloir was asked only in il.
- **Quotas became weights.** Regular asked fixed counts (7, 6, 4, 3, 3, 3, 3, 1); every quiz now
  draws each question by weight, so a quiz's mix varies. A scoped quiz draws only from the level's
  tenses that some verb of the scope has, so a My Verbs quiz of only falloir asks thirty questions,
  not twenty-seven.
- **`shouldShuffle` is gone** from `Quiz.init`. With weighted draws an unshuffled quiz was no longer
  deterministic, so tests seed the quiz instead (`Quiz(gameCenter:seed:)`).
- **Test Me follows the level.** A verb with nothing to ask at the learner's level shows no Test Me
  button: choir, which has only its participe passé, at Beginner. A collection's Quiz button follows
  the same rule (`Verb.canBeQuizzed(at:)`). At Beginner, Test Me's three questions are two tenses
  and a third présent or impératif cell.
- **The setting** moved to the key `quizLevel`. Conjuguer's `Settings.load` writes the default when a
  key is missing, so `quizDifficulty` is never removed: the migration runs as `quizLevel`'s default,
  only when `quizLevel` is absent. Tried on real installs: the iPhone's stored Regular became
  Elementary, and the iPad's, set to Ridiculous for the test, became Advanced. A fresh install
  starts at Beginner (a test; no simulator was reset). Seeding a setting needed `defaults` by the
  plist's full path inside the simulator, since a `plutil` edit was overwritten by the preferences
  daemon's cache; the `verify-in-simulator` skill now says so.
- **Tiles, as Konjugieren built them.** A 16-point label shrank "Intermédiaire" below its
  neighbors on the iPhone, so the four labels use a new 13-point `levelTileFont`. The selected tile
  has a blue gauge and border and a red label, the colors of the App Icon tiles below it. The Quiz
  tab's briefing shows "Level: Advanced" with the level's gauge, for My Verbs too, since a scoped
  quiz now uses the level.
- **The tip.** `ChangeDifficultyTip` became `ChangeLevelTip`, "Choose Your Level" / "Choisissez
  votre niveau". Settings attaches its popover tips only while on screen, ported from Konjugieren
  before seeing the bug here; on the iPad, a quiz finished after visiting Settings showed no tip
  over its results.
- **Scoring.** Every level scores 10 a right answer and a right second attempt 5. The multiplier
  and the time bonus are gone. Until Phase 8 every level posts to the one leaderboard, and the best
  score is one number across levels. Nothing ships before Phase 8.
- **Text that named the difficulties.** The onboarding quiz page now names the levels; it still
  says "timed quizzes", which Phase 7's hidden clock should revisit, as should `Tips.tryQuizMessage`
  ("a timed quiz"). The README lists the levels. `docs/description.txt`, the App Store text, never
  named the difficulties, so it is unchanged.
- **The Live Activity** shows the level's name through `QuizActivityAttributes.level`. Not looked at.
- **Analytics.** `difficulty` became `level` (`beginner`, `elementary`, `intermediate`,
  `advanced`) on `quizQuit` and `quizCompletion`, and `quizStart` gained it (M1). Staged in
  `docs/privacy_policy_pending.md` as a changed bullet in both languages.
- **A new fixture**, `-CONJUGUER_QUIZ_FIXTURE levels`: eight questions, one in each tense only
  Advanced asks, with answers in `docs/feature_architecture.md` § Quiz.
- **Pouvoir has no impératif.** A Beginner quiz asked pouvoir's impératif, which `verbs.xml` gave no
  defect group, and Regular had asked it of the same pool. Josh agreed on 2026-11-23 that it is
  not used, so a new defect group 28 ("Impératif is not used.", `du="hA"`, which also strikes the
  impératif passé) now marks pouvoir. Its page shows both impératifs struck through, and the quiz
  passes over pouvoir for the impératif.
- **Verified** on the iPhone 17 in French (light): the tiles, the tip, "Niveau : Avancé" on the
  briefing, fourteen questions of an Advanced quiz spanning the présent to the passé surcomposé, the
  `levels` fixture's eight corrections, and its results. In English: the tiles at Beginner, a
  Beginner quiz of twelve présents and impératifs, and a right Advanced answer scoring 10. On the
  iPad Pro 11 in English and dark: the tiles at Advanced after the migration, and the fixture's
  results with no tip over them. Not tried: VoiceOver by ear (each tile reads its name, with the
  selected trait), the software keyboard, and the Live Activity.
- **Tests:** 593 to 602, counting `DefectivityAuditTests`' new pouvoir test. `QuizLevelTests` is new (nine tests: each level's tenses, the weights,
  every cell in one slot, the default quiz's draw by level, pool, and weight, and the level on the
  signals). `SettingsTests` pins the migration; `QuizTests` and `QuizScopeTests` moved from
  difficulties and quotas to levels, and five tests of Ridiculous and the quotas went.

## Phase 6: Which Verbs Are Asked

**Suggestions:** T2.1, T2.2, T2.5. **Ports:** Konjugieren Phase 6. **Depends on:** Phase 5.
**Status:** Done.

For the default quiz (not a scope, whose verbs are chosen):

- **T2.1.** Draw from the level's frequency band (`FrequencyBand`). Browse Phase 12 checked for
  verbs whose zero or estimated counts misplace them; read its note.
- **T2.2.** Prefer base verbs. Every quiz includes one to three derivative verbs (browse Phase 7's
  bases: revenir, reprendre, défaire) to practice prefix behavior.
- **T2.5.** Fix the share of irregular and regular verbs per session, and make sure the core verbs
  recur: être, avoir, aller, faire, and the modal-like pouvoir, vouloir, devoir, savoir.

Conjuguer's curated pools already do much of this by hand: regular -er, -ir, and -re verbs, the big
three, stem changers, être verbs, irregular participles, and futur stems. Keep their structure
where it serves a level (an être verb in the passé composé, an irregular futur stem in the futur),
and intersect each pool with the band. Konjugieren's report counted this the siblings' strength.

**Carried over:** the band follows the level (100, 300, 1,000, all); half of a default quiz's verbs
irregular; at least two questions per session on the core verbs.

**Ask Josh:** what "irregular" means for the share: a model whose irregularity is above 0%
(`VerbModel.irregularity`), or a narrower set.

**Done when** a default quiz under a fixed seed draws only from the band, contains one to three
derivatives, meets the share, includes the core verbs, leaves scoped quizzes alone, and tests pin
each.

**How it differed:**

- **Irregular means the third group plus aller** (Josh, 2026-11-23), `VerbDraw.isIrregular`, the
  rule he chose for the verb of the day. Rendre, attendre, and perdre count as irregular; the
  spelling changes of manger and appeler do not. Half a default quiz's questions, rounded down,
  ask an irregular verb, exactly.
- **The pools became rules, and `QuizVerbs.swift` is gone** (Josh, 2026-11-23). The phase said to
  intersect each curated pool with the band, but the lists held about 800 verbs, picked from web
  frequency in 2021, so Advanced would never have reached past them. Each `QuizVerbPool` now
  admits a verb by a rule read from the data and applied to the band: regular -er is the first
  group but aller, regular -ir the second group, regular -re rendre's model, an être auxiliary a
  verb whose data names être (not a pronominal one), and the stem changers, irregular futur stems,
  and irregular participles read the capitals with which the conjugator marks irregular letters
  (`QuizVerbTraits`, kept per model). The structure of each tense's pools is Phase 5's, with "the
  top thirty" become "any verb of the band". The new code is `Models/QuizDraw.swift`.
- **How the mix works.** Konjugieren's design, with pools added. Every question's tense is drawn by
  weight; then two questions take the core role, one to three the rare-derivative role (or, at
  Beginner and Elementary, one the derivative role); then exactly half are made irregular; and only
  then does each question take one of its tense's pools that holds a verb fitting its role and
  share, and a verb from it, preferring one not yet asked. A question asking a regular verb so
  never draws the big three, and one asking an irregular verb never draws regular -er. The person
  decks stay; the verb decks went.
- **Konjugieren's reading of T2.2 was carried over** without asking: a prefixed verb in the top 300
  draws as freely as a base verb (comprendre, revenir, devenir), and beyond it a prefixed verb is a
  rare derivative, one to three per quiz where the band reaches that far. A derivative is a verb
  `VerbBase.base(of:)` finds a base for: 19 of the top 100, 66 of the top 300, 239 of the top 1,000.
- **Sortir to obtain is left out of the default quiz** (Josh, 2026-11-23). The first Beginner quiz
  in the simulator asked "elles ___" of sortir (obtain), answer sortissent, a legal term that shares
  sortir's counts and so ranks #78. `QuizDraw.excludedEntries` drops it. The other doubled
  infinitives (saillir, haïr, ouïr) appear only at Advanced and stay.
- **A pool of oddities.** The first Advanced quiz asked fiche twice. The irregular-participle pool,
  crossed with a regular question, held only fiche (fichu), maudire, and féru, and was drawn as
  often as any other pool, so one verb took 39 of 1,014 non-core questions over 40 quizzes. The pool
  now admits only irregular verbs, and `noVerbOutsideTheCoreDominatesALevel` fails, as checked, if
  such a pool returns.
- **The placeholder check** was browse Phase 12's, which fixed the œ verbs and convaincre. Nothing
  new was found; lover (#835) is still there, as that note says.
- **The level's description** in Settings now names verbs: "This setting determines which tenses
  and verbs quizzes ask about…", with the bands, in both languages, and the README's quiz line
  says the levels draw on more verbs. `ChangeLevelTip` ("Each level adds tenses to the one before")
  and the onboarding page are still true and were left.
- **A test helper conjugated without extra letters.** `QuizTests.correctAnswer(for:)` passed
  `extraLetters: nil`, which the curated lists never exposed; sortir (exit) at Elementary failed it.
  It now passes the verb's.
- **Phase 7.** The rules are per draw, so a ten-question quiz gets five irregular questions, two
  core, and one to three rare derivatives. Phase 7 should decide whether Ten More draws a fresh mix
  of ten, as Konjugieren's note also asked.
- **No analytics and no privacy lines.** Nothing new is sent.
- **Verified** on the iPhone 17 by answering every question of a real quiz wrongly and reading the
  results. In English at Beginner: 30 verbs of the top 100 (aller, être, avoir, faire, prendre,
  comprendre, rester, attendre, définir, agir), all présent or impératif, and, before the fix,
  sortir (obtain). In French at Advanced: ranks 4 to 6,070, convivialiser and ébaudir beside
  pouvoir and aller, and fiche twice, before its fix. The Settings description in both languages.
  On the iPad Pro 11 in English and dark: the description, and an Intermediate quiz of verbs ranked
  1 to 961 (constituer, sauter, parvenir, licencier, nuire, naître). Not tried: VoiceOver, which
  this phase gave nothing new to say, and a scoped quiz on a device (a unit test covers it).
- **Tests:** 602 to 616. `QuizDrawTests` is new (14 tests: the bands, Advanced reaching past the
  top 1,000, the irregular half, the core verbs, rare and frequent derivatives, repeats, no verb
  dominating, the pools' rules, sortir, the core verbs' ranks, derivatives, and a scoped quiz left
  alone). `QuizLevelTests`' pool test now asks the pools' rules. The suite took 129 to 164 seconds
  across runs, with `VerbDrawTests` at about 80 of them before and after this phase.

## Phase 7: Ten Questions, Then Ten More

**Suggestions:** T2.7, T3.1, T6.5, M2, M3. **Ports:** Konjugieren Phase 7 (`QuizClock.swift`,
`QuizAbandonment.swift`). **Depends on:** Phases 3 and 5. **Status:** Done.

- **T2.7.** The default session is ten questions. Its results offer Ten More, which continues the
  same session and adds to its score.
- **T3.1.** Re-ask a missed question once, a few questions later. A question missed near the end is
  re-asked before the results. A right re-ask earns half points.
- **T6.5.** A setting, off by default, that shows the clock. With it off, neither the quiz nor its
  results show time. Conjuguer's identity has included speed (the time bonus); Phase 21 gives
  speed its own place.
- Revisit what thirty gated: the Live Activity, the tip donation, the time bonus, and ranking
  (Phase 8 settles ranking).
- **M2.** On the next launch after a quiz was abandoned by leaving the app, report the question
  reached, counting the round's questions only, never re-asks (Konjugieren's Closing found that
  counting re-asks leaked how many answers were wrong).
- **M3.** Report the time from start to quit in bands (0-3 s, 3-15 s, 15-40 s, 40 s-2 min, 2 min+),
  replacing `quizQuit`'s raw `elapsedTime`, and band `quizCompletion`'s elapsed time the same way.
  `quizQuit`'s `lastQuestionIndex` stays, counting the round's questions as M2 does.
- **Drop `score` from `quizCompletion`** (Josh, 2026-11-22), and stage the policy change: the
  deployed line "Your quiz score and the elapsed time when you complete or quit a quiz" and its
  French counterpart lose the score and name the bands.

**Carried over:** Ten More; re-ask once, beyond the ten; no thirty-question choice; no time on the
results with the clock hidden; both M2 and M3.

**Done when** the default quiz is ten questions and continues, a missed question returns once, the
clock hides by default, the Live Activity and tip follow the new length, the signals send bands,
and tests pin the re-ask placement and the continuation.

**How it differed:**

- **Nothing was asked of Josh.** The phase had no **Ask Josh**, and Konjugieren's four answers of
  2026-11-13 were carried over: (1) a default session posts its first round's score, re-asks not
  counted, to the one leaderboard and the best score, and Ten More's points are never posted
  (`Quiz.firstRoundScore`, a ceiling of 100), so that Phase 8 has only to change where the score
  goes; (2) My Verbs and collection quizzes become ten with Ten More, and Test Me keeps its three
  with none (`QuizScope.continues`); (3) the Live Activity starts with every round of a tab quiz,
  with a total that counts the session so far; (4) M3's bands are 0-3s, 3-15s, 15-40s, 40s-2m, and
  2m+. Also as Konjugieren decided in its session: Ten More has no limit, a re-ask may still earn a
  slip's second attempt, a right re-ask scores 5 on either attempt, and Test Me re-asks too.
- **Ten More draws a fresh mix of ten**, Phase 6's open question, so every round, the ranked first
  included, has five irregular questions, two core, and one to three rare derivatives. Unlike
  Konjugieren's, the draw is seeded with the session's verbs (`QuizDraw.questions(level:count:asked:using:)`),
  so a later round passes over a verb already asked while another fits; a test pins that two
  rounds at Advanced share no verb outside the core. A fixture is repeated by Ten More, which makes
  the continuation checkable in the simulator.
- **How it works.** `Quiz.questionCount` is a round's 10; `sessionQuestionCount` counts the
  session's questions without re-asks. A miss inserts `QuizQuestion.reasked` at
  `Quiz.reaskPosition(after:in:)`, three questions on or at the round's end, and a round ends when
  `currentQuestionIndex` passes the last question, re-asks included. Scores still accumulate as
  answers come; `QuizResult.points` gives a re-ask its 5, and the counts (`correctCount`,
  `secondAttemptCount`, `reaskCount`, `reaskCorrectCount`) are read from the results, re-asks
  apart. `continueSession()` appends the draw and restarts the timer, the Live Activity, and the
  abandonment record; it sends no `quizStart`. `QuizActivityAttributes.totalQuestions` moved into
  the content state, and its start date and elapsed time became optional.
- **What a learner sees.** The correction says "This question will come up again." / "Cette
  question reviendra."; a re-ask shows an "Asked Again" / "Question reposée" capsule above the verb,
  and its results row the same words; the results add "Asked Again: 1 / 2" / "Questions reposées :
  1 / 2" and a Ten More / "Encore dix" button, capped at 400 points and centered on an iPad; the
  briefing says "10 questions". The progress counts re-asks (1 / 11 after a miss), as Konjugieren's
  does. Josh has not judged any of the wording. Konjugieren's diamond dots and wrapping header were
  not needed: Conjuguer's results have no dot row, and their header is a column.
- **Found by looking:** the first question of a Ten More round showed the previous round's
  checkmark in its feedback slot. The slot, and the "also spelled" announcement, now read
  `Quiz.lastRoundResult`, which is empty at a round's start.
- **The clock** is a new setting, Quiz Clock / Chronomètre du quiz, Hide / Show (Masquer /
  Afficher), below Quiz Level. Hidden, the quiz, its results, VoiceOver's announcement, and the Live
  Activity show no time, and the Dynamic Island's center shows the level instead. The clock still
  counts while hidden.
- **Strings that said 30 or "timed"** changed: the briefing's "30 questions", the onboarding quiz
  page ("Take ten-question quizzes" / "Faites des quiz de dix questions"), and `TryQuizTip`'s
  message. The App Store description names no count and was not touched. `privacyPolicy4.md` still
  says that Conjuguer's quizzes have thirty verbs; the privacy section flags it for release day.
- **Analytics.** `quizCompletion` lost `score` and `elapsedTime` and gained `duration` and
  `questionCount`, sent at each round's results (10, 20, …). `quizQuit`'s `elapsedTime` became
  `duration`, wall-clock from the session's start, background included. `lastQuestionIndex` keeps
  its name and its zero-based meaning, now counting the session's questions without re-asks. The
  new `quizAbandon` (M2) carries `level`, `lastQuestionIndex`, and `source`, sent at launch by
  `QuizAbandonment.reportAndClear` for each quiz the last run left mid-question; it needed
  `GetterSetter.remove(key:)`. All staged in `docs/privacy_policy_pending.md`, in both languages.
- **Best score.** It is now the first round's score, at most 100, but a best kept from the
  thirty-question quiz (the iPhone simulator showed 30; a real install may hold hundreds) stands
  until Phase 8's leaderboards by level replace it. Phase 8 should decide what becomes of it.
- **Fixtures** were cut to a round: the screenshot fixture asks its first ten, the grading fixture
  its ten without repeats, and the frames fixture its fifteen. `scripts/take_screenshots.sh`
  answers as many questions as the fixture holds.
- **Two tests changed their samples, and one its claim.** Ten-question quizzes hold a third of the
  draws, so `QuizDrawTests` now draws 120 quizzes rather than 40, and the weight test 600 rather
  than 200, keeping the samples they were written for. `noVerbOutsideTheCoreDominatesALevel` then
  still failed at Elementary (définir 19 of 896 non-core questions, 2.1%, against a cap of one in
  fifty): the top 300 holds only a few regular -ir verbs, which sat at the cap at thirty questions
  too. Its cap is now one in forty, which the fiche pool Phase 6 removed (3.8%) would still fail.
- **Verified on the iPhone 17**, light. In French with the `corrections` fixture: "10 questions"
  on the briefing, a miss's correction with "Cette question reviendra." and the count at 1 / 9, the
  re-ask with its capsule at 5 / 9, a miss on the last question re-asked before the results, results
  of 70 (six right, two re-asks at 5) with "Questions reposées : 2 / 2" and no time, and Encore dix
  resuming at 11 / 18 with the score and the keyboard. In English: the Quiz Clock card set to Show,
  the clock in the status strip (0:21), results with "Time: 0:49" and "Asked Again" rows, and Ten
  More carrying the clock on (0:52). A real abandonment: the app terminated at 17 / 24 left
  `{"level":"advanced","source":"tab","lastQuestionIndex":8}` in its preferences, and the relaunch
  cleared it. The clock was set back to Hide. **On the iPad Pro 11** in English and dark: the
  correction line, the re-ask, results of 75 with no time, and Ten More with typing at once. Not
  tried: VoiceOver by ear, the software keyboard, the Live Activity itself, a Test Me sheet's
  results (unit-tested: no Ten More), and Game Center.
- **Tests:** 616 to 631. `QuizSessionTests` is new (15 tests: the re-ask's place and its once
  only, its half points, Ten More's continuation, clock, fresh verbs, and availability, first-round
  ranking, the completion and quit signals' counts and bands, the duration bands, the abandonment
  record and its report, the clock setting, and the Live Activity's time). `QuizTests`,
  `QuizScopeTests`, and `QuizLiveActivityTests` moved from thirty questions to rounds with re-asks.
  The suite took 228 seconds, about 9 more than before in the two draw suites; `VerbDrawTests`,
  untouched, swung from 85 to 175 seconds between runs.

## Phase 8: Leaderboards by Level

**Suggestions:** Decision 4. **Ports:** Konjugieren Phase 8
([`../Konjugieren/docs/game_center_setup.md`](../../Konjugieren/docs/game_center_setup.md)).
**Depends on:** Phases 5 and 7. **Status:** Done.

One leaderboard per level. `GameCenter.reportScore` takes the leaderboard; update `GameCenterReal`
(which finds today's board with `loadDefaultLeaderboardIdentifier`) and `GameCenterStub`. Scoped
quizzes stay unranked. Write `docs/game_center_setup.md`, a step-by-step walkthrough for creating
the boards in App Store Connect: IDs exactly as the code uses them, score format, sort order, and
English and French display names, from Apple's current documentation. New leaderboards ship with an
app version, so add the release-day step to `docs/release.md`.

**Carried over:** a ranked score is the first ten questions of a default session at a level,
counting second-attempt half points and not re-asks, so every ranked score has a ceiling of 100;
the old leaderboard is retired; raise with Josh whether anything should break the many ties at 100.

**Done when** a ranked session reports to its level's board, an unranked one reports nowhere, the
walkthrough exists, and tests pin which sessions rank.

**How it differed:**

- **Josh decided four things on 2026-11-23**, each the recommended option. Nothing breaks ties at
  100 (over folding the time into the score, or weekly recurring boards). The best score becomes
  one per level, the briefing showing the current level's, and the single best kept across levels
  is dropped, not migrated, since its level is unknown and it may come from the thirty-question
  quiz. Closing a default quiz's results still opens a leaderboard, now its level's; Phase 13
  replaces that with a control on the hub. And Claude was to create the boards in App Store
  Connect by driving Chrome, as in Konjugieren.
- **The four leaderboards exist in App Store Connect**, created by this session on 2026-11-23:
  `conjuguer.level.beginner`, `.elementary`, `.intermediate`, and `.advanced`, each Classic,
  Integer, 0 to 100, Best Score, High to Low, not hidden, with English (U.S.) and French
  localizations (Beginner / Débutant and so on, as the live board has English and French) and a
  description of the first ten questions at that level. Each is in "Prepare for Submission", added
  to no version. Their settings were read back on each board's page after creation. The live
  board's ID is `software.racecondition.Conjuguer.Leaderboard`, which the code never named, since
  `GameCenterReal` found it with `loadDefaultLeaderboardIdentifier`. The IDs follow the
  `conjuguer.level.*` pattern Konjugieren's document anticipated rather than the live board's
  reverse-DNS form. No image was added; the live board has one, `icon1024.png`.
- **The walkthrough, [`docs/game_center_setup.md`](../docs/game_center_setup.md)**, records what
  exists, as Konjugieren's does: the five boards, their settings and descriptions, the steps as App
  Store Connect showed them, testing (which waits for the 2027 version, after Konjugieren found
  its level boards invisible to a development build), and release day (submit the boards with the
  version, archive the old one, perhaps change the default). [`docs/release.md`](../docs/release.md)
  has a step before submitting and one on release day. Conjuguer has no
  `GameCenterResources.gamekit`, unlike Konjugieren, and its shared scheme has no GameKit debug
  mode to turn off.
- **The code.** `GameCenter.reportScore(_:level:)` and `showLeaderboard(level:)` replace the
  level-less pair, with `QuizLevel.leaderboardID` beside the protocol. `GameCenterReal` no longer
  loads the default leaderboard and logs a failed report to a new `Log.gameCenter`.
  `GameCenterStub` became `GameCenterSpy`, which records reports and shown boards, as Konjugieren's
  dummy became a spy; `CLAUDE.md`'s convention now names `URLProtocolStub` as its stub example.
  Unlike Konjugieren, the protocol kept Conjuguer's shape (a completion-handler `authenticate`, no
  `showLeaderboards()`), since nothing here shows the list of boards. `QuizScope.isRanked` did not
  change.
- **The best score.** `Settings` keeps `bestScores` per level under the keys `bestScore.<level>`,
  read through `bestScore(at:)` and raised only by `recordScore(_:at:)`, and removes the old
  `bestScore` key at launch. On the iPhone simulator, the first launch removed the 30 that Phase 7
  saw there.
- **Strings.** The onboarding quiz page's "compete on the Game Center leaderboard" became
  "compete with learners at your level on Game Center" / "affrontez les apprenants de votre niveau
  dans Game Center". Nothing else names the leaderboard; Conjuguer has no leaderboard button in
  Settings or the results, unlike Konjugieren.
- **No analytics and no privacy lines.** Nothing new is sent to the developer. The policy's
  section 6 already speaks of "quiz leaderboards" and "when you submit a score", which stays true.
- **Not verified with Game Center.** The simulator worlds use `GameCenterSpy`, and posting needs a
  signed-in device and, probably, a version that holds the boards (above). **Verified** on the
  iPhone 17: with `bestScore.elementary` seeded at 80 and an old `bestScore` of 450, the French
  briefing at Élémentaire showed "Meilleur score : 80" and the 450 was gone from the preferences;
  in English, Beginner showed no best score and Elementary showed 80. On the iPad Pro 11 in English
  and dark: Intermediate showed none, and Advanced, seeded at 95, "Best score: 95". The seeded
  scores were reset to 0 afterward. Not seen: the onboarding page's new sentence, and a best score
  recorded by a finished quiz on a device (unit-tested).
- **Tests:** 631 to 640. `QuizLeaderboardTests` is new (7 functions nested in `QuizTests`: each
  level's literal ID, distinct IDs, a ranked session reporting 100 to each level's board and
  setting its best, the level fixed at the quiz's start, a second attempt's half points counted
  and a re-ask's not (85 ranked of a score of 90), Ten More reporting nothing, and three scoped
  quizzes reporting nothing). `SettingsTests` gained two (each level keeps its own best; the old
  key is removed). The best-score assertions in `QuizTests`, `QuizSessionTests`, and
  `QuizScopeTests` moved to `bestScore(at:)`; since a best can only rise, they no longer reset it
  to 0 between tests.

## Phase 9: Choosing What to Practice

**Suggestions:** T2.8. **Ports:** Konjugieren Phase 9 (`CustomQuiz.swift`, `CustomQuizView.swift`).
**Depends on:** Phases 5 and 6. **Status:** Done.

Let the learner choose the scope: tenses, a verb set (a band, a collection, a model, My Verbs), or
both. Models are a natural scope here, the counterpart of Konjugieren's ablaut groups. A beginner
opening the tab should not meet a wall of options, so keep the custom choice one step away from
Start.

**Carried over:** a chosen scope is unranked; remembered between launches and offered beside the
default, which stays the default; any tense may be chosen, above the learner's level or not.

**Ask Josh** to judge the layout on a phone and an iPad before polishing.

**Done when** a learner can quiz over chosen tenses, a chosen verb set, or both; the default is
unchanged; and tests pin scope construction.

**How it differed:**

- **The layout**, ported from Konjugieren's. The Quiz tab's picker gained a third segment, Custom
  (Sur mesure). With it chosen, the briefing card shows a summary (Tenses, Verbs), a line saying
  what Start will do or why it cannot, and Choose or Change, which pushes `CustomQuizEditor` onto
  the tab's stack: "Set by Your Level" and the nineteen tenses the quiz can ask, in the order the
  levels add them, each with its second name, then "Set by Your Level" and the verb sets. Models
  is a further push, `CustomQuizModelList`, every model with verbs in identifier order with its
  count, as Konjugieren's ablaut groups were. The editor uses the app's cards on its background
  rather than Konjugieren's plain `List`, and is capped at 680 points wide on an iPad. The tab
  opens on All Verbs at every launch, so the default stays the default and Custom is one tap from
  Start. **Josh has not judged the layout**, which the phase asks for before polishing.
- **The verb sets:** the 100, 300, and 1,000 most frequent verbs, all 6,326, My Verbs (only while
  it has verbs or is the stored choice), verbs taking être, irregular futur stems, pronominal
  verbs, and any of the models. The top-100 collection is offered only as the band, which holds the
  same verbs under the same key.
- **Decided in the session, not asked,** each Konjugieren's in-session guess carried over, and each
  one Josh can overrule. (1) A part left unchosen is the level's: tenses alone ask the level's
  band, a verb set alone the level's tenses. (2) A band or every verb is mixed as the default quiz
  is (half irregular, two core verbs, rare derivatives); a collection, a model, or My Verbs is a
  list, asked as a My Verbs quiz is. (3) One verb set at a time. (4) The tip donation follows
  `isRanked`, as in Phase 7, so a custom quiz donates nothing to `ChangeLevelTip`, unlike
  Konjugieren's. Konjugieren's fallback for a restricted kind no verb fits (`relaxesRestrictions`)
  has no counterpart here, since Phase 5 left no restricted cells; instead Start is disabled, with
  "None of these verbs has any of the chosen tenses.", when no verb of a list has a chosen tense
  (falloir's model and the impératif), and with the My Verbs line when a kept My Verbs choice meets
  an empty list.
- **How it works.** `CustomQuiz` (chosen `QuizTenseSlot`s and an optional `QuizVerbSet`) in
  `Models/CustomQuiz.swift`, kept in `Settings.customQuiz` as `tenses=…&verbs=…`, with a tense's
  `Info.stableKey` as its key and `model-<id>` for a model, so that Phase 10 can put the same
  string in a link. `QuizScope` gained `custom`, `slots(at:)`, `band(at:)`, and `namedCollection`;
  `isRanked` now also requires `custom == nil`. `QuizDraw.questions` takes slots and a band, with
  the level form kept as a wrapper, and its candidate cache is keyed by band rather than level.
  The DEBUG fixtures apply only to the default quiz.
- **Analytics.** A new `source` value, `custom`, and a new `quizStart` parameter, `customChoice`
  (`tenses`, `verbs`, or `both`). A custom quiz over a featured collection or a model sends
  `collection` as a collection's quiz does, a model's as `model`. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **Strings.** The picker's VoiceOver label, "Verbs to Quiz" / "Verbes du quiz", became "What to
  Quiz" / "Contenu du quiz", as in Konjugieren. Seventeen `CustomQuiz.*` keys are new. Tense names
  stay French in both languages, as everywhere in the app.
- **Found by looking.** A chosen model vanished at relaunch, though its tenses stayed: `Settings`
  loads before `VerbData.parse()` fills `VerbModel.models`, so a key that checked the model's
  existence always failed. A `model-<id>` key is now accepted unchecked, and a model that names
  nothing holds no verbs, so its quiz cannot start (a test pins both). Konjugieren's ablaut keys
  may share the trap. The Choose button first matched Start in size and drew the eye from it, so
  it is a size smaller.
- **Verified on the iPhone 17**, in light (the simulator would not render dark that session,
  though `simctl ui` reported it). In English: the empty Custom segment with Start disabled, the
  editor's tenses and verb sets, the model list, the imparfait and futur simple over appeler's
  model kept across a relaunch, a quiz that opened with "vous ___" of ficeler in the imparfait,
  and the summary's VoiceOver label ("Tenses, Imparfait, Futur Simple, Verbs, appeler (1-3A)").
  In French: "Sur mesure" fits its segment beside "Tous les verbes", and the summary reads "Selon
  votre niveau : Avancé · Les 6,326 verbes" (the number follows the simulator's US region). **On
  the iPad Pro 11** in English and dark: the empty state, the editor at its capped width, the
  subjonctif présent over the pronominal verbs, and a quiz that asked "nous nous ___" of
  entredétruire. Not tried: VoiceOver by ear, the Live Activity, Ten More on a custom quiz
  (unit-tested), and the "nothing to ask" line (unit-tested).
- **Tests:** 640 to 658. `CustomQuizTests` is new (16 functions: the stored form pinned and round
  tripped, every tense and verb-set key, the top 100 read back as the band, My Verbs offered only
  when asked, unknown keys dropped, a model that names nothing, a part left to the level, every
  verb, lists asked as lists, never ranked, the choice parameter, a model named only as a model,
  what cannot start, chosen tenses at any level under forty seeds, and the setting's persistence),
  and two sessions nested in `QuizTests` (chosen tenses asked alone with `custom` and no score
  posted; a model's quiz asking only its verbs and continuing with Ten More).

## Phase 10: Practice Sets to Share

**Suggestions:** T2.9, Decision 8. **Ports:** Konjugieren Phase 10 (`PracticeSet.swift`,
`PracticeSetView.swift`, `QRCode.swift`). **Depends on:** Phase 9 and browse Phase 9's grammar.
**Status:** Done.

Make a chosen scope shareable as a `conjuguer://` link and as a QR code, so a teacher can hand a
class one practice set without accounts or a server. Conjuguer's largest source of downloads was
one Swiss school, which makes this the plan's most direct bet on schools.

- Encode the scope (level, tenses, verb set, length) in a link under the browse plan's grammar.
  Opening it shows the practice set with Start rather than starting a quiz unasked. Keep existing
  links working; today's `quiz/` route starts a quiz at once.
- Shared text carries the link and the App Store link (no web domain).
- Generate the QR code on the device, with a full-screen view a teacher can project.
- The school's devices were Macs running the iPad app. Find out, from Apple's documentation or a
  test if a Mac is at hand, whether a `conjuguer://` link opened on a Mac reaches the app, and say
  so in **How it differed**.
- Ask Josh to try a scanned code with his phone's Camera app.

**Done when** a shared link and a scanned code open the same practice set, an invalid link fails
gracefully, and tests pin encoding and decoding of every scope.

**How it differed:**

- **Konjugieren's three answers carried over, not asked again.** Josh decided them for
  Konjugieren on 2026-11-14, and nothing in French made one awkward. (1) Opening a set shows a sheet
  with Start, which runs the quiz in a sheet over it, and Keep as My Custom Quiz, which replaces the
  learner's custom quiz only when tapped. (2) A shared My Verbs carries its verbs. (3) **The length
  does not travel**, though this phase's text lists it: every set is ten questions, then Ten More,
  and a `length` item can be added later without breaking links.
- **The route.** `conjuguer://quiz/set?tenses=…&verbs=…&level=…&source=…`, the quiz route with a
  `set` target and the custom quiz's stored form as its query, built by
  `URL.practiceSetDeeplink`. `quiz/start` and every other target still open the Quiz tab and start
  a quiz, so existing links keep working.
- **Decided in the session, not asked,** each Konjugieren's in-session guess carried over, and each
  one Josh can overrule. (1) The level travels only while a part is left to the level; a set's quiz
  asks at that level through a new `QuizScope.level`, which wins in `slots(at:)`, `band(at:)`, and
  `Quiz.level` without touching the setting. A kept set uses the learner's level. (2) A list is a
  new `QuizVerbSet.list` of `Verb.verbs` keys, stored as `infinitives=` rather than in `verbs=`,
  so `haïr France` names one entry of a doubled infinitive. The editor lists a kept list only while
  it is the choice. (3) A link naming `verbs=myVerbs` drops that part. (4) The sheet shows over
  whatever tab is open, and a later link, or any other link, replaces or closes it. (5) The QR
  code's link says `source=qrCode` and the shared text's `sharedLink`. (6) Share lives only on the
  Custom segment, a menu of Share Link and Show QR Code beside Change, and only while Start is
  enabled. (7) The QR view draws dark modules on white in both appearances, keeps the screen awake,
  and shows the summary beneath the code.
- **Departed from Konjugieren.** (1) **A shared list holds 50 verbs, not 100.** A test of a hundred
  of the longest infinitives with every tense overflowed a QR code: each é takes nine bytes once
  percent-encoded, which German's few umlauts never pressed. Fifty of the longest fit, and the test
  now pins that. (2) A stored list keeps keys it cannot check, since `Settings` loads before
  `VerbData.parse()` fills `Verb.verbs` (Phase 9's model trap again); `PracticeSet(url:)`, which
  runs only once the verbs are loaded, drops unknown verbs and a model that names nothing.
  Konjugieren's `QuizVerbSet(infinitives:)` checks at decode and may lose a kept list at launch, if
  its verbs load after its settings. (3) A set's quiz starts no Live Activity
  (`QuizScope.isPracticeSet`), as a collection's sheet quiz does not, since a tap on the activity
  would open the Quiz tab. (4) Start is disabled, with the custom quiz's "nothing to ask" line,
  when no verb of a list has a chosen tense. (5) The summary labels its lines ("Tenses: …",
  "Verbs: …") in the share text and the QR caption.
- **Invalid links.** A `quiz/set` link that names nothing this version knows shows "Practice Set
  Not Found" ("Série d’exercices introuvable") with a line that the link may be cut short or need a
  newer app. Unknown keys, verbs, and levels are dropped and the rest kept.
- **Analytics.** `tapSharePracticeSet` (`method`, `link` or `qrCode`, and `customChoice`),
  `viewPracticeSet` (`source`, and `outcome`, `opened` or `invalid`), `tapKeepPracticeSet`, the new
  `method` parameter, and the `qrCode` source on the quiz signals. None names a tense or a verb.
  Staged in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **Strings.** Eighteen `PracticeSet.*` keys and `CustomQuiz.verbList`. "Practice set" is "série
  d’exercices", a common name in French-speaking schools for a sheet of exercises. Keep was first "Garder comme
  mon quiz sur mesure", which wrapped to two lines on the iPhone; it is now "En faire mon quiz sur
  mesure", and once kept, "Devenue mon quiz sur mesure".
- **Found by looking.** Share sat a few points taller and lower than Change, a Menu's label being
  taller than a NavigationLink's (Konjugieren saw the same); both labels now fill an HStack of fixed
  height. The QR view decodes to nothing if screenshotted mid-animation, so the skill's table says
  to wait.
- **A Mac.** Apple's pages on running iPhone and iPad apps on a Mac with Apple silicon
  ([running](https://developer.apple.com/documentation/apple-silicon/running-your-ios-apps-in-macos),
  [adapting](https://developer.apple.com/documentation/apple-silicon/adapting-ios-code-to-run-in-the-macos-environment))
  say nothing about custom URL schemes, and this Intel Mac cannot run the iPad app, so whether a
  `conjuguer://` link clicked in Mail or Messages on a school's Mac reaches the app is unknown. A
  Mac has no Camera app that scans codes, so on Macs the shared link, not the QR code, is the way
  in. Added to **Tasks for Josh Outside the Code**.
- **Tests:** 658 to 681. `PracticeSetTests` is new, 23 functions: the pinned link, every tense,
  verb set, level, and list round-tripped, a stored list keeping keys a link drops, `verbs=` over
  `infinitives=`, ten links that open nothing, a link keeping what it can read, My Verbs shared as a
  capped list, the level travelling only when needed, the scope, a set with nothing to ask, the
  share text, a generated code read back by Core Image's detector, fifty of the longest verbs still
  fitting a code, a kept list's persistence, and the editor's kept list; nested in `DeeplinkTests`,
  the `quiz/set` route without a tab switch or a quiz, its failure, and a later link replacing the
  set; nested in `QuizTests`, a session at the set's level under a different learner level, and the
  share signal.
- **Verified on the iPhone 17** in light, in English: a five-verb set opened by `simctl openurl`
  (haïr France among its chips), its quiz, Quit back to the set, Keep, the kept list on the Custom
  segment after a relaunch, Share's menu, the share sheet (Copy gave the expected text), the QR
  view, whose screenshot decodes to the exact link, and the invalid link. In French: a set at
  Débutant ("Selon le niveau : Débutant · Les 100 verbes les plus fréquents"), Keep, the QR view
  (decoding to a link carrying `level=advanced`, the learner's), and the "nothing to ask" state.
  **On the iPad Pro 11** in English and dark: a set opened by a link at a cold launch, its quiz in
  a form sheet over the set's page sheet, Keep, the share sheet as a popover anchored to Share, and
  the QR view, whose screenshot decodes. Not tried: VoiceOver by ear, Ten More on a set
  (its scope's `continues` is unit-tested), and the Camera app.
- **Waiting on Josh's phone:** whether the Camera app offers to open a `conjuguer://` QR code.
  Record the result here.

## Phase 11: The Practice Record

**Suggestions:** T3.3 (the record), T3.4, T3.5, T6.4. **Ports:** Konjugieren Phase 11
(`PracticeRecord.swift`, `PracticeItemMapping.swift`, `PracticeStore.swift`,
`QuizRecordSession.swift`). **Depends on:** Phase 7. **Status:** Done.

Give the quiz a memory: a small record per item, a box and a due date, moved up the ladder of 1, 3,
7, 14, and 30 days by a right answer and back to the start by a wrong one.

- **T3.5. Two kinds of item.** For an irregular verb, an item is one of its key conjugations (browse
  Phase 8). For a regular verb, an item is a pattern, a tense and person shared by every verb of the
  pattern. French has more than two conjugation types: regular -er (parler), regular -ir (finir),
  and many -er models with spelling changes (appeler, acheter, céder, manger, placer, payer). Decide
  with Josh which models count as patterns (Konjugieren's weak verbs) and which verbs are learned
  one by one (its strong verbs), document the mapping of every question to its item, and test it
  across tenses, être verbs, pronominal verbs, and defective verbs.
- **Reuse `ReviewSchedule`**, generalizing it, and store the record in the App Group, since Phases
  22 and 24 need it outside the app.
- **T6.4.** Record each answer as it is given, so a learner who quits after six questions has still
  practiced six. The trombone stays.
- Stage the privacy change: the policy's "does not record your quiz answers" becomes "does not
  send", with a sentence that the practice record stays on the device.

**Carried over:** one schedule, so the review card reads the practice record and browse Phase 13's
per-verb due date folds in with a migration, keeping that phase's rules unless the merge makes one
meaningless (then ask); a default session mixes in up to about three due items of its ten; a Reset
Practice control in Settings behind a confirmation; every scope writes to the record.

**Ask Josh:** which models are patterns.

**Done when** every answer updates its item, the ladder moves as specified, quitting keeps what was
answered, the record survives a relaunch, and tests pin the mapping and the schedule.

**How it differed:**

- **Asked of Josh (2026-11-23), before building.** (1) **Which models are patterns:** families,
  cell by cell. Three bases, parler's -er, finir's -ir, and rendre's -re; a spelling-change model
  (manger, appeler, céder, payer…) has patterns of its own only for the cells its change marks
  with capitals (nous mangeons, j'appelle, j'appellerai), and its other cells share parler's (je
  mange, j'appelais). Aller and the rest of the third group are learned verb by verb. (2) **The
  passé simple** has no key conjugation in Conjuguer (vient · est venu · viendra), so an irregular
  verb gets a **fourth item, il vint**, which quiz answers move and the subjonctif imparfait counts
  against, but which the card does not show and a lookup does not schedule. (3) **The review card
  offers irregular verbs only**, as in Konjugieren: a regular verb's lookup has nothing of its own
  to schedule, and the migration drops regular verbs' card schedules.
- **Found while building:** prendre's, battre's, and mettre's models are built on rendre's in
  `verbModels.xml`, so a parent-chain walk made them patterns. Rendre's family is named instead:
  rendre's, rompre's, and foutre's models. Every first-group model but aller's, ester's and fiche's
  included, and every second-group model, ouïr's and haïr's included, belongs to its group's
  family; the odd ones are families of one or two verbs, which behave as verb by verb would.
- **The mapping, decided in the session.** Marks are read from the Conjugator's capitals, as
  `QuizVerbTraits` reads them. A compound tense is judged by its participle alone, since the
  auxiliary's own capitals (sUIS) say nothing of the verb, and a compound tense conjugated with
  être, pronominal verbs included, is a pattern apart from avoir's (`takesÊtre`), since it asks the
  agreement. For an irregular verb, the impératif, imparfait, subjonctif présent, and participe
  présent count against the présent; the participe passé and every compound tense against the passé
  composé; the conditionnel against the futur. The cost: a slip in nous venions counts against
  vient, and a wrong auxiliary in a compound tense against est venu. Keys are
  `key:venir:present` and `pattern:1-2B:indicatif_present:fp`, built from `Verb.dictionaryKey`,
  `Tense.articleKey`, and `PersonNumber` raw values; tests pin them. `Verb.keyTenses` is now
  derived from the shown stems, so the card and the record cannot disagree.
- **The ladder, as Konjugieren's.** `ReviewSchedule.lookedUp` became `start`, and `new` and
  `answered(correctly:)` were added: a wrong answer starts over, a right one climbs only when due,
  a new item answered right enters the second box. A slip's right second attempt counts as right; a
  re-ask is another answer.
- **Where it lives.** `Shared/PracticeRecord.swift` (items and record), `Models/PracticeStore.swift`
  (`Current.practice`, JSON under `practiceRecord` in the App Group's defaults),
  `Models/PracticeItemMapping.swift`, and `Models/QuizDueItems.swift`. `LearnerVerbs` lost its
  `review` field and the store its review methods; `recordOpen` lost its `source`, and the verb page
  records the open and the lookup separately. There was no `QuizErrorHistory` to decide about.
- **Departed from Konjugieren: the migration waits for the verbs.** Conjuguer's world and settings
  load before `VerbData` (Phase 9's trap), and only the verbs say which are irregular, so the store
  reads the old `learnerVerbs` JSON at launch and migrates it in `migrateIfNeeded()`, which
  `ConjuguerApp` calls after the load and every store method calls first. The record is saved even
  when nothing migrates, since after the next save of `LearnerVerbs` an entry without `review`
  would otherwise read as looked up on its last open at a second migration.
- **Due items in a default round**, as Konjugieren's: up to three, the most overdue first, mixed
  at random among the drawn seven, in Ten More rounds too, only in the default quiz
  (`QuizScope.mixesDueItems`, which also excludes a practice set's level), and skipped when the
  level does not ask the tense or the verb is beyond the band. A pattern is asked of a band verb
  of the item's own model first, so a parler pattern needs no conjugating to find its verb; due
  questions sit outside Phase 6's irregular share, as in Konjugieren.
- **The card's caption** says "Practiced 3 days ago" ("Travaillé il y a 3 jours"), "yesterday", or
  "earlier" when a quiz answer came after the lookup. The Suppress Review Card description now says
  "an irregular verb you looked up or practiced" ("un verbe irrégulier consulté ou travaillé").
- **Reset Practice** ("Réinitialiser le suivi") is a Practice Record card ("Suivi des exercices")
  at the end of Settings, after the game, shown while the record holds anything, behind an alert
  ("Every review the app has scheduled will be forgotten. This cannot be undone."). Its
  description begins "This button erases", since it is a button, not a setting. Nine strings.
- **Analytics.** `tapResetPractice`, with no parameters. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages: "does
  not record your quiz answers" becomes "does not send", the list-on-the-device paragraph loses its
  review dates, and a new paragraph says the practice record stays on the device.
- **VoiceOver.** No new quiz state: recording is silent and a due item is an ordinary question.
  The card's caption is read as before; the alert is the system's.
- **Tests:** 681 to 705, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `PracticeItemTests` (13 functions: pinned and unreadable keys, which verbs are patterns and which
  are not, prendre, battre, and mettre among the latter, the bases' own verbs, spelling-change
  cells, compound tenses with être, every tense's stem, sortir's two entries, lookups, the shown
  stems, every irregular verb's lookup agreeing with its key conjugations, items asking their own
  cell back), `PracticeRecordTests` (16: the ladder through answers, due order, lookups, the
  card's review, snooze, choice, and caption, patterns and a passé simple never on the card,
  sortir, a relaunch, the migration, a reset that stays, a migration with nothing to move kept),
  `QuizPracticeTests` nested in `QuizTests` (6: answers kept on quit, every scope writing, due
  items within level and band, a default session mixing them in, at most three, none in a scoped
  quiz or a practice set), and `ReviewScheduleTests` rewritten for the ladder alone (6).
- **Verified on the iPhone 17**, light. The real install's old record migrated at the first
  launch: aller, avoir, être, faire, pouvoir, souvenir, and venir came across with their schedules,
  parler and accroire were dropped, and the card offered aller ("Looked up yesterday"). A default
  quiz opened with aller's two due key conjugations (passé composé, then présent, both "elle"); quit
  after ten answers, every one was in the record as given, re-asks included: aller's two, avoir's
  passé composé, and the patterns `1-1:participe_passe` (surmener), `1-1:plus_que_parfait:ss:etre`
  (rester), and `5-1A:subjonctif_present:fp` (tondre). In French: aller's card again, since its
  futur stayed due, captioned "Travaillé plus tôt"; a reveal moved only the futur, to box 1; the
  Practice Record card ("Suivi des exercices"), its alert, and a reset to an empty record, which a
  relaunch kept and did not re-migrate. In English: a seeded venir card, "Practiced 2 days ago".
  **On the iPad Pro 11** in English and dark: the install's migration (prendre, box 1, not yet due,
  so no card; parler dropped), a seeded venir card at its 560-point width, and the Practice Record
  card. Not tried: VoiceOver by ear, the widget (which reads nothing of the record yet), and a real
  day passing.
- **For Josh to judge:** "Travaillé" for "practiced" on the card; the caption's "earlier" when the
  last answer was today (Konjugieren's wording, which reads oddly for a card offered the same day a
  sibling key conjugation was answered); and where the Practice Record card sits in Settings.

## Phase 12: Review and My Mistakes

**Suggestions:** T3.2, T3.3 (the session). **Ports:** Konjugieren Phase 12 (`QuizDueItems.swift`).
**Depends on:** Phase 11. **Status:** Done.

- **Review.** A session of due items from the record: an irregular verb's item asks its key
  conjugation, and a pattern asks that tense and person of a verb of the pattern from the learner's
  band.
- **Practice my mistakes.** A session of the items whose most recent answer was wrong. An item
  leaves the list once answered right.
- Entry points on the Quiz tab, each with an empty state that says why it is empty. Phase 13 moves
  them into the hub.
- New `source` values for the quiz signals, which say only that a mode was begun; stage their
  lines.

**Carried over:** a Review session is ten due items, most overdue first, with Ten More.

**Done when** both sessions draw the right items under test, update the record, and show sensible
empty states.

**How it differed:**

- **Nothing was asked of Josh.** The phase lists no Ask Josh items. Konjugieren's in-session
  choices carried over where French did not make one awkward, and each is a guess he can overrule.
- **Where the entry points live.** A "From Your Practice" card ("D’après votre suivi") below the
  Quiz tab's briefing card, on every segment, with a row each for Review ("Réviser") and Practice
  My Mistakes ("Revoir mes erreurs"). A row with questions shows their count and a play symbol,
  and a tap starts the session at once. An empty row is not a button and says why: Review gives the
  days to the next due item ("Nothing is due today. The next review is tomorrow."), or, with nothing
  scheduled, that quiz answers and irregular verbs looked up come due a day or more later; My
  Mistakes says that a missed question waits there until answered right. Unlike Konjugieren's, the
  card sits above the fold on the iPhone 17, since Conjuguer's briefing card is shorter than
  Konjugieren's hero and tiles. The picker was not extended: a fourth and fifth segment would not
  fit "Tous les verbes" and "Sur mesure".
- **What each session asks**, as Konjugieren's. Review: the record's due items, most overdue first.
  My Mistakes: items whose last answer was wrong, most recently missed first
  (`PracticeRecord.missedItems()`); a lookup does not clear a mistake. A key conjugation asks its il
  form, the passé simple's included, of its verb. A pattern asks its cell of a verb from the
  level's band that shares it, through `QuizDraw.patternVerb`, now shared with Phase 11's due
  items. **Neither is held to the level's tenses or band**, so Review asks what Phase 11's default
  rounds leave waiting (a passé simple below Advanced, a rare verb looked up). A verb's due key
  conjugations sit together in stem order, vient · est venu · viendra · vint, at the place of the
  first drawn.
- **Departed from Konjugieren: a pattern no band verb has is asked of any verb.** Konjugieren's
  weak patterns are shared by every weak verb, so its band always has one. A French
  spelling-change model may have no verb in a Beginner's top 100, and skipping its pattern would
  leave a row counting a question that Start could not ask. Every verb is searched only then.
- **Rounds.** Ten items, then Ten More while an askable item remains that the session has not
  asked; fewer make a shorter round, whose results say "Correct: 1 / 3". Conjuguer's
  `sessionQuestionCount` already counted the questions asked, so Konjugieren's change to
  `Quiz.questionCount` had no counterpart. `canContinue` checks the record for a record session.
  The Live Activity starts as for any ten-question quiz from the tab.
- **The title.** While a session runs or shows its results, the Quiz tab's title row reads
  "Review" or "Practice My Mistakes" ("Réviser", "Revoir mes erreurs"). Conjuguer draws its own
  title row, so the name shows on the iPad too, which Konjugieren's navigation title could not.
- **Analytics.** New `source` values `review` and `mistakes`. **A record session sends no counts:**
  `quizCompletion` omits `questionCount`, and `quizQuit` and `quizAbandon` omit
  `lastQuestionIndex` (`QuizScope.sendsQuestionCounts`), since a short session's length would be a
  count of wrong answers. `QuizAbandonment.Entry.lastQuestionIndex` became optional, which still
  decodes stored entries. Never ranked, so no Game Center post, no best score, no leaderboard on
  closing the results, and no `ChangeLevelTip` donation. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **VoiceOver.** No new quiz state. Each row is one element, its title and its count or reason,
  and a startable row has a hint ("Starts a quiz of the questions due for review"). Thirteen
  `PracticeSession.*` strings.
- **Found by looking.** The card first carried its identifier on the card itself, which overrode
  the rows' (the skill's table warns of this); it is now on the heading, `quiz_record_sessions`.
  Also found, and **not fixed, since it predates this phase:** at Advanced the quiz asks a
  pronominal verb's passé surcomposé, and the Conjugator answers "elles se ont été bilées" (se
  biler). The passé surcomposé of a pronominal verb is hardly used, and the form is wrong as
  written. Josh should decide whether the quiz stops asking it or the Conjugator learns a form.
- **Tests:** 705 to 718, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `QuizRecordSessionTests` (7 functions: missed items most recent first with a lookup not clearing
  one, days to the next due item, a session beyond the level's tenses and band, a pattern no band
  verb has, a verb's key conjugations together, excluded and unaskable items with the limit, and
  never ranked) and six nested in `QuizTests` (twelve due items asked as ten then two, a short
  Review that does not continue, an empty record starting nothing, a mistake leaving once answered
  right, a mistake missed again not returning in Ten More, and signals without counts and no score
  posted).
- **Verified on the iPhone 17**, light. In English, from the real install's record: the card with 3
  due and 1 missed; a Review titled "Review" asking venir's présent then passé composé then futur;
  one right and two wrong, with re-asks; results of "Correct: 1 / 3" with no Ten More; the rows
  after ("Nothing is due today. The next review is tomorrow.", "2 questions missed"); a My Mistakes
  of venir's two, answered right, 2 / 2; and both empty states. In French: the card's strings, a
  default quiz quit after three misses, and "Revoir mes erreurs" asking a finir pattern of
  empuantir, an être passé surcomposé pattern of se biler (Advanced's band is every verb), and
  vaincre's futur, 0 / 3, no Ten More. **On the iPad Pro 11** in English and dark: the card at full
  width, a Review whose title shows above the question, a re-ask, and Quit, with the record kept
  across a relaunch. Not tried: VoiceOver by ear, Ten More from a real record of more than ten
  (unit-tested), the "nothing scheduled" line on screen (its string is in both catalogs), and a real
  day passing.

## Phase 13: The Practice Hub

**Suggestions:** T6.1, T6.6 (the leaderboard's place). **Ports:** Konjugieren Phase 13
(`LastQuizResult.swift`). **Depends on:** Phases 7, 8, 11, and 12. **Status:** Done.

Turn the Quiz tab into a practice hub: what a session is, how long it takes, the current level,
what is due for review, and the last result. Today's briefing card (a symbol, a paragraph, the
difficulty, "30 questions", the best score, and Start) is the base, with whatever browse Phase 11
added.

- Move the leaderboard out of the main path: a modest control on the hub. Today every dismissal of
  the results sheet opens the leaderboard.
- Rewrite the onboarding's quiz page and `TryQuizTip`'s text to describe practice rather than a
  timed test.
- The last result is kept on the device, under Phase 11's privacy change.

**Ask Josh** to judge the hub on a phone and an iPad, in light and dark, before polishing.

**Done when** the hub shows each item with real data, the onboarding page and tip are rewritten in
both languages, and the leaderboard is one tap away but not in the way.

**How it differed:**

- **Josh has not judged the hub yet**, which the phase asks for before polishing. Everything below
  was decided in the session, mostly by carrying Konjugieren's choices over, and each is a guess he
  can overrule.
- **The layout.** Conjuguer's briefing card stays a card, reordered so that what a session is comes
  before Start: the symbol, a rewritten line ("Practice French conjugation. A wrong answer shows
  its correction, and a missed question comes back later." / "Entraînez-vous à la conjugaison
  française. Une réponse fausse affiche sa correction, et une question manquée revient plus
  tard."), the picker, three tiles for All Verbs and My Verbs ("10 Questions", "2–3 Minutes", and
  the level), Custom's summary in their place, and Start. Konjugieren's tiles were ported in
  Conjuguer's blue; its big scope symbol and verb chips were not, as browse had decided. Then From
  Your Practice with a new **Last Quiz** row, and at the foot the best score and a small bordered
  **View Leaderboard**. On the iPhone 17, Review sits above the fold and My Mistakes is nearly
  whole, as before.
- **The minutes** are a fixed estimate, as in Konjugieren: no timing is kept, and showing the
  learner's times would undo the hidden clock. VoiceOver reads "Two to three minutes".
- **The level tile is a menu**, as in Konjugieren, writing the same setting as Settings and sending
  nothing. It also invalidates `ChangeLevelTip`, whose suggestion it carries out.
- **The best score moved to the foot**, beside the leaderboard, out of the briefing's facts, and
  now shows whatever the segment, since it is no longer part of what Start will do. Konjugieren's
  hub had dropped its best score; Conjuguer's briefing had one, and the foot keeps it.
- **The last result** (`LastQuizResult`, kept by `PracticeStore` as JSON under `lastQuizResult` in
  the App Group) is written at each round's results, so after Ten More it is the session so far,
  by every scope, Test Me's three questions included; a quit writes nothing. It keeps a kind and a
  verb's `dictionaryKey` or a collection's key, so it reads in the current language and tells
  sortir's two entries apart. Review and My Mistakes keep no level. "Practice My Mistakes · today",
  then "Correct: 0 / 3 · Score: 0"; the date is a `RelativeDateTimeFormatter` in the app's
  language. Reset Practice forgets it; the Practice Record card now shows while either exists
  (`hasAnythingToReset`), and its description and alert say so. `VerbCollection(key:)` is new, for
  a model's collection as well as the featured four.
- **The leaderboard (T6.6).** Closing a default quiz's results no longer opens it. The hub's button
  shows only while signed in to Game Center, opens the current level's board, and sends the new
  `tapViewLeaderboard` with `source` `tab` (Konjugieren already had the signal; Conjuguer had
  none). `GameCenter` is not observable, so the tab keeps its own `isSignedInToGameCenter`, set on
  appearing and from `authenticate`'s completion.
- **Onboarding and tip.** The quiz page is "Practice Conjugating" / "Entraînez-vous à conjuguer",
  with a clipboard symbol in place of the trophy and "Start Practicing" / "S’entraîner". Its body
  describes ten questions in two or three minutes, the correction that stays, the re-ask, and
  review from a record on the device, and no longer mentions points or Game Center. `TryQuizTip`
  keeps its title and says "Practice French verb conjugations ten questions at a time. What you
  miss comes back for review." The unused "10 questions" string is gone. Nineteen strings in all,
  nine of them new.
- **Analytics and privacy.** `tapViewLeaderboard` and the kept last result are staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **VoiceOver.** No new quiz state. Each tile is one element, the minutes with their spoken label,
  the level with a hint ("Changes the quiz level"); the Last Quiz row is one element; the
  leaderboard button has a hint.
- **Tests:** 718 to 734, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `QuizHubTests` (10 functions: the stored form pinned, a round trip, unreadable JSON, an absent
  level, each scope's kind, titles of a verb, a doubled verb, and collections, every collection
  found by its key, the store across a launch, a result alone giving Reset something to erase, and
  Reset forgetting it) and six nested in `QuizTests` (a finished quiz with its injected date, Ten
  More's session so far, a quit keeping nothing, My Mistakes keeping no level, a verb page naming
  its verb, a collection naming its key).
- **Verified on the iPhone 17**, light. In English: the hub, a real My Mistakes session of three
  wrong answers whose results closed onto the hub with "Practice My Mistakes · today, Correct:
  0 / 3 · Score: 0" and no leaderboard, the View Leaderboard button (the simulator's spy signs in),
  and the level menu, from which Intermediate was chosen. In French: the hub with "Intermédiaire"
  shrunk to fit its tile, "Dernier quiz", "Voir le classement", and the onboarding page, whose
  trophy then became a clipboard (rebuilt, not seen again on the iPhone). **On the iPad Pro 11**
  in English and dark: the hub at full width, before and after a My Mistakes session, with the Last
  Quiz row. Not tried: VoiceOver by ear, the real Game Center sheet, the best score at the foot
  (no level has one on these simulators), and Ten More's result on screen (unit-tested).
- **For Josh to judge:** the hub as a whole; the briefing's new line; "2–3 Minutes"; the best score
  at the foot; "S’entraîner" for "Start Practicing"; and whether the leaderboard button should show
  for every segment, as it does, or only for All Verbs.
- **Two older faults, fixed at Josh's request (2026-11-23).** The French results read "Correcte :
  0 / 3", an adjective agreeing with nothing, and each row's correct answer "Correcte : vaincra".
  They are now "Bonnes réponses : 0 / 3" and "Bonne réponse : vaincra", which the Last Quiz row
  shares. And a Review or My Mistakes session's results named the level, though the session asks by
  none: `QuizScope.asksByLevel` now hides that line (`results_level`), keeps the last result's
  level nil, and makes the session's Live Activity show its name ("Practice My Mistakes") where a
  quiz shows its level. Tests 734 to 736 (`onlyARecordSessionAsksByNoLevel`, and
  `aRecordSessionsLiveActivityNamesTheSession`, for which `LiveActivitiesSpy` now records
  `lastAttributes`). Seen on the iPhone 17 in French: a My Mistakes session's results with
  "Bonnes réponses : 0 / 3", no level, and "Bonne réponse :" on each row.

## Phase 14: Naming the Error

**Suggestions:** T4.2, T4.3. **Ports:** Konjugieren Phase 14 (`AnswerDiagnosis.swift`).
**Depends on:** Phases 3 and 4; Phase 2 for the frame. **Status:** Done.

Diagnose a wrong answer from the conjugator's own knowledge and say it in one templated line with
Phase 3's correction. No language model: the one careful study the report found (Song et al.
2023) shows explanations become reliable when a deterministic step establishes the facts first.
Candidate classes for French (**inference**, to be tested on real wrong answers):

- **Another cell of the same verb**, by `Verb.conjugations(matching:)`: "That is the imparfait. The
  passé simple was asked." Likely the commonest, and always right. Includes the wrong person
  (finissons for finissez).
- **The wrong auxiliary**: j'ai allé, il a tombé, and the reverse. Beware the passive: je suis
  mangé is good French (a passive présent), so word the line so it stays true when the learner
  typed a passive.
- **Agreement with être**: allé for allée (Josh kept agreement required on 2026-11-22). Check that
  this line wins over Phase 4's slip for the same answer.
- **A regular form of an irregular verb**: prendu for pris, vous faisez for faites, vous disez for
  dites, ils prendent for prennent, je voirai for verrai.
- **The futur stem**: the infinitive's stem where the verb's own is irregular (j'envoyerai for
  enverrai, j'acquérirai for acquerrai), or the reverse.
- **A spelling change missed**: nous mangons, nous commencons, j'appele, je céde (the e, the
  cedilla, the doubled consonant, the grave accent of the stem-alteration models). Phase 4 catches
  some of these as slips; decide which class wins.
- **The ending set of another conjugation**: ils finent for finissent, nous rendâmes for
  rendîmes, il prena for prit.
- **A spelling slip**, which Phase 4 already catches.

**T4.3.** For a diagnosable error, prompt a repair before revealing ("Check the auxiliary. Try once
more."), through Phase 4's single second attempt with half points.

A wrong diagnosis is worse than none. Say only what is certain, order the checks from most to least
certain, and stop at the first that applies. Tense names stay French in both languages, as
elsewhere in the app.

**Ask Josh** which classes prompt a repair and which reveal at once, and to review the templates in
both languages.

**Done when** each class is diagnosed for real verbs under test, an undiagnosable answer gets no
line, and the prompted second attempt shares Phase 4's mechanism.

**How it differed:**

- **Asked of Josh (2026-11-23), before building.** (1) **Every class prompts a repair**, over
  "rules only, another cell reveals at once" and over "no prompt", as in Konjugieren. (2) **The
  draft lines were approved as drafted**, in both languages, one line serving both the prompt (with
  "Try once more." / "Encore un essai." appended) and the correction. (3) **The être verbs that take
  avoir with a direct object** (descendre, entrer, monter, passer, redescendre, remonter, rentrer,
  ressortir, retourner, sortir, tomber; passer was later accepted with avoir, below) get "Without a direct object, monter takes être, not avoir."
  / "Sans complément d’objet direct, monter se conjugue avec être, et non avec avoir.", over no
  line and over aller's line, which would be false of j'ai passé un examen.
- **One approved line was reworded while building, for Josh to judge.** The other group's line
  was "Those are the endings of verbs like parler, and finir is not one." For ils finent, -ent is
  finir's ending too, and the check also matches an imparfait built on parler's nous stem, whose
  endings every verb shares. It now reads "That is how verbs like parler are conjugated, and finir
  is not one." / "C’est ainsi que se conjuguent les verbes comme parler, et finir n’en fait pas
  partie."
- **The classes, in the order checked** (`AnswerDiagnosis.swift`), each an exact construction:
  agreement with être (four agreement names: féminin, masculin, féminin pluriel, masculin
  pluriel); agreement with avoir (a class the phase did not list: ai parlée); the wrong auxiliary,
  with a line of its own for pronominal verbs and for the ten of the eleven above that are not passer; a missing auxiliary (not
  listed: allée alone); another entry of a doubled infinitive (not listed: sortir (obtain)'s
  sortissent for sortir (exit)); a spelling change missed; the futur stem; vous in -tes (not
  listed: vous faisez, vous disez); another cell, another person of the asked tense before another
  tense; the regular form of the infinitive's ending (prendu, ils prendent, a ouvri, ils allent);
  and another group's conjugation (ils finent, rendâmes, a metté).
- **Departed from Konjugieren: another cell comes before the regular forms**, not last. The rules
  about the asked cell (agreement, auxiliary) and the specific spelling, futur, and -tes rules come
  first, since they say more; but an answer that is a real form of the verb is named as that form
  before being called a regular conjugation, since a form the learner recalled is the nearer
  explanation (partit for il part is the passé simple, as well as finir's présent pattern).
- **Which wins over the slip:** every diagnosis, checked before `AnswerSlip`. So suis allé for
  suis allée now names the agreement, and nous mangons, j'appele, je céde, placa, and achete, which
  Phase 4 called slips, name their spelling change. The plan's "decide which class wins" is
  settled this way.
- **The spelling change is read, not listed.** The verb is conjugated with parler's model, and the
  difference between that and the right answer, after the common prefix and suffix, must be c→ç,
  an e inserted after g, a doubled l or t, e→è, é→è, or y→i. Anything else (envoyer's futur, whose
  parler form is envoyerai) gets no spelling line and falls through to the futur stem.
- **No auxiliary line where either is standard.** Demeurer (avoir for "live"), accourir,
  apparaître, réapparaître, disparaître, convenir, disconvenir, échapper, réchapper, expirer,
  déchoir, paraître, repartir, ressusciter, trépasser, and vieillir. Their wrong auxiliary gets no
  line, and may still be a slip.
- **Not built:** il prena for prit, which no exact construction produces; a regular form for -oir
  verbs, which have no regular model (their futur stem is caught: voirai, devoirai); and vous
  faisez in the impératif, since the approved line names the présent.
- **The Conjugator** gained `conjugate(verb:model:tense:pronounGender:)`, which the
  infinitive-keyed overload now calls, and `nousPrésentStem` became model-aware, so a hypothetical
  model's imparfait and participe présent are built on its own nous stem. It is still core code
  that `ConjugationMapTool` compiles, and reaches nothing new.
- **The mechanism.** `Quiz.firstAttemptDiagnosis` beside Phase 4's `firstAttempt`, and
  `Quiz.secondAttemptPrompt`, the line with "Try once more." or "Almost! Try once more.", in the
  same orange line, hand icon, chirp, and announcement. `QuizCorrection.diagnosis` holds the
  diagnosis of the final answer, so a repair wrong in an undiagnosable way gets no line. In the
  correction the line sits under the two answers with a lightbulb, and VoiceOver reads it after
  the differing letters. Elision needed second keys for the tense lines ("C’est le passé simple",
  "C’est l’imparfait"). Twenty-seven strings.
- **Fixtures.** A new `-CONJUGUER_QUIZ_FIXTURE diagnoses`: fifteen questions, one per kind, whose
  wrong answers are listed in `docs/feature_architecture.md` § Quiz. The slips and corrections
  fixtures' notes were rewritten, since most of their straight-to-the-correction answers are now
  diagnosed and earn a second try.
- **Analytics:** none added, so nothing is staged in `docs/privacy_policy_pending.md`. A diagnosis
  is a statement about an answer, which Decision 5 keeps on the device.
- **Tests:** 736 to 746, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `AnswerDiagnosisTests`, 10 functions: 41 diagnosed cases for real verbs (être, pronominal,
  doubled-entry, spelling-change, irregular-futur, and third-group verbs), the agreement under each
  gender setting, 10 answers that get no line (right answers, a variant, slips, nonsense, an empty
  answer, demeurer, accourir, il prena), the lines in English, and in a seeded quiz a diagnosed
  error waiting on its question, a right repair at half points, a wrong repair with its own (here
  no) diagnosis, a diagnosed final answer held with its line, a slip after a diagnosis going to the
  correction, and a slip still saying "Almost!".
- **Verified on the iPhone 17**, light. In French, all fifteen fixture kinds prompted, each line
  read from the accessibility tree and repaired, for 70 points after fourteen repairs; finent
  twice held its correction with the line, the re-ask notice, and the links, and the spoken
  correction read the line after "Lettres qui diffèrent : i, s, s." In English, suis allé twice
  held "With être, the participle agrees with the subject, here feminine." **On the iPad Pro 11**
  in English and dark: the agreement prompt on two lines at full width, a right repair for 5
  points, a wrong undiagnosable repair (x) with no line, and a venue twice holding "Venir takes
  être, not avoir, in its compound tenses." Not tried: VoiceOver by ear and the software keyboard.
- **Avoir accepted for passer (Josh, 2026-11-23), after he saw the phase's summary.** The quiz
  expected être for passer and graded j'ai passé wrong, though passer's commonest use takes avoir
  with an object. Its compound tenses now accept avoir with an unagreed participle as a
  `StandardVariants` variant (`avoirAlsoAccepted`), shown with the app's être spelling beside the
  checkmark; j'ai passée is the agreement with avoir. Passer is the only such verb: monter,
  sortir, and the other nine keep the line about the direct object. The grading fixture gained an
  eleventh question, passer's passé composé, seen right as `j'ai passé` on the iPhone 17 in French
  (11 / 11). Tests 746 to 747 (`passerIsRightWithAvoirAndShowsItsÊtreSpelling`, with four
  accepted and four rejected variants and two diagnosis cases).
- **For Josh to judge:** the fifteen lines in French on a device; the other group's reworded line;
  "C’est la forme pour nous" for the wrong person; the lightbulb line in the correction; and
  whether a diagnosis for parle as the participe passé, "That is the indicatif présent, for je and
  elle.", names too much.

## Phase 15: Key Conjugations

**Suggestions:** T5.1. **Ports:** Konjugieren Phase 15 (`VerbEssentials.swift`,
`VerbEssentialsRowView.swift`). **Depends on:** Phases 2 and 11. **Status:** Done.

An exercise for irregular verbs: given the infinitive, supply its key conjugations (il présent, il
passé composé, il futur simple: `il ___ · il ___ · il ___`), each in its own blank of Phase 2's frame, each graded alone, each
updating its own item in the record. Offer it on the Quiz tab over the irregular verbs of the
learner's band, and wherever Phase 16 needs it.

**Carried over:** no "principal parts" or "temps primitifs" label; Konjugieren named the exercise
Verb Essentials (Verb-Grundlagen in German).

**Ask Josh:** the French name (candidates: L'essentiel du verbe, Les incontournables, Verbe en
bref).

**Done when** the exercise asks, grades each blank, and records each item, with tests for an être
verb, a pronominal verb, and a verb with an irregular futur stem.

**How it differed:**

- **Asked of Josh (2026-11-23), before building.** The French name is **"L’essentiel du verbe"**,
  over "Les incontournables" and "Verbe en bref". Konjugieren's in-session decisions (one blank
  graded at a time with all three rows on screen, five verbs a round, an Exercises section of the
  hub, Five More Verbs) carried over unasked; each is a guess he can overrule.
- **The pronoun follows the setting, not the plan's `il ___`.** Every blank is an ordinary quiz
  question of the third-person singular, so with the feminine default it reads `elle [ ]` and
  expects est venue, as any quiz does since Josh kept agreement required on 2026-11-22. The verb
  page's key conjugations stay masculine, since they stand without a pronoun. Forcing il would have
  meant threading a gender through grading, frames, diagnoses, and corrections, for one exercise.
  For Josh to judge.
- **One blank, one question**, as in Konjugieren: a verb is three `QuizQuestion`s sharing a new
  `stepID`. One more try (Phase 4), the diagnosis (Phase 14), the held correction, and the
  practice record apply per blank unchanged; `PracticeItem.exercised` already maps the il présent,
  passé composé, and futur to the three stems. The frame (Phase 2) is reused as is, one per row,
  so a pronominal verb's rows read `elle se`, `elle s'`, `elle se`.
- **Which verbs.** "Irregular" became `Verb.isAskedByVerbEssentials`: learned verb by verb in the
  record (aller and the third group, not rendre's family, which `VerbDraw.isIrregular` counts but
  the record keeps as patterns, so a rendre blank would have moved a pattern item), with all three
  key conjugations (not gésir), and not sortir (obtain). From the level's band, all verbs at
  Advanced; the level's tenses do not apply, so a Beginner is asked passés composés and futurs, as
  Konjugieren's Elementary learner is asked Präteritum. A real Intermediate draw opened on
  extraire.
- **The screen.** `QuizView` draws the rows before the current one and those after it around the
  one field, as Konjugieren does, and the keyboard stayed up as the field moved down. Each row is
  the tense name in blue above its frame; an answered row shows the right conjugation in the app's
  red-letter style with its mark, a re-ask's given rows are gray, and a pending row is an empty
  outlined box. The question block hides its tense line. **Departed from Konjugieren:** the
  feedback slot shows only the one-more-try prompt, since the first simulator pass showed every
  row's mark twice, once on the row and once above the next field.
- **Re-asks**, ported: a missed blank returns after the next step as a step of its own, with its
  other rows given, and a second miss in the same verb joins it (`Quiz.reaskPlacement`, which
  replaced the bare `reaskPosition` call in `process`). A miss in a verb that follows a re-ask step
  returns after that re-ask step, not after the next fresh verb, as in Konjugieren.
- **The hub.** A new Exercises card ("Exercices") between From Your Practice and the foot, with
  one row whose detail is "Five irregular verbs, three conjugations each: prend · a pris ·
  prendra" (no-break spaces keep each form whole). Review's and My Mistakes' row became a shared
  `QuizHubRow`; their identifiers are unchanged. Start invalidates `TryQuizTip`, as the other rows
  do. `QuizScope.sessionTitle` names the session in the title row and the Live Activity.
- **Rounds and results.** Fifteen questions; the results offer "Five More Verbs" / "Encore cinq
  verbes", which draws verbs the session has not asked while the band lasts. Never ranked, no due
  items, no `ChangeLevelTip`. Unlike Review, it asks by level (the band), so the results and Last
  Quiz name the level ("Verb Essentials · Intermediate · today").
- **Analytics.** A new `source` value, `verbEssentials`. `quizCompletion` keeps its
  `questionCount`, 15 a round, since a round's length depends on no answer. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **VoiceOver.** The full announcement at a step's first blank; a later blank says only "Tense:"
  and its tense. The field's label begins with its row's tense, and each other row is one element
  ("indicatif présent, elle, singular, vient, right"). Not heard by ear.
- **Strings:** ten, `QuizView.exercises` and nine `VerbEssentials.*`.
- **A fixture**, `-CONJUGUER_QUIZ_FIXTURE essentials`, used only once Verb Essentials starts:
  venir, se souvenir, faire, prendre, and aller, with five wrong answers listed in
  `docs/feature_architecture.md` § Verb Essentials and pinned by a test as diagnosed.
- **Tests:** 747 to 764, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `VerbEssentialsTests`, 11 functions: a step's cells, each blank's answers by gender for venir,
  aller, se souvenir, faire, envoyer, and voir; a pronominal verb's frames; the fixture's diagnosed
  answers; which verbs are asked (13 cases); the draw over twenty seeds; asked verbs last; the
  scope; and three re-ask placements. Nested in `QuizTests`, 6: a round's five steps, each blank
  recorded alone, the rows, a re-ask's given rows, a diagnosed blank's half points, and Five More
  with the signals, the last result, and no score.
- **Verified on the iPhone 17**, light. In French, the fixture: the hub's Exercices card, venir's
  three rows, vient right, a venu prompting "Venir se conjugue avec être…", est venue on the second
  try at half points, a held futur correction with the futur row's field above it, se souvenir's
  `elle se` and `elle s'`, a re-ask step with its other rows given, and results of 135 with "Encore
  cinq verbes". In English, a real draw (extraire) holding a correction with the two rows still to
  come below it. **On the iPad Pro 11** in English and dark: the hub with the Exercices card, and
  venir's rows at full width with the auxiliary prompt. Not tried: VoiceOver by ear, the software
  keyboard, the Live Activity, and Five More on screen (unit-tested).
- **Seen, not changed.** On the iPad, text typed right after the row's tap did not reach the field,
  so the first blank went in empty. Konjugieren saw the same with a hardware keyboard.
- **For Josh to judge:** the name in the title row; elle rather than il; the description's example
  (prend · a pris · prendra rather than an être verb, so it reads the same under either gender);
  the gray given rows of a re-ask; and whether Beginner should be asked passé composé and futur.

## Phase 16: Models, One Then Mixed

**Suggestions:** T5.2. **Ports:** Konjugieren Phase 16 (`AblautPractice.swift`,
`AblautPracticeCard.swift`, `AblautPracticeListView.swift`). **Depends on:** Phases 11 and 15.
**Status:** Done.

Work through one model, then mix it with models already practiced, from the Models tab. Conjuguer's
models are its counterpart of Konjugieren's ablaut groups: verbs that share a pattern of stems and
endings. The support is Pan et al. (2019), where practicing a pattern alone before mixing it did
better over two weekly sessions; for conjugation models as such the report found no study, so treat
it as a bet.

**Carried over:** a model is "known" once at least half its items have moved past the first box;
a model with one verb offers no solo practice and joins mixes once its verb's items climb; the
practice uses Phase 15's exercise where the model's verbs are irregular. For a model that is a
pattern (Phase 11), decide with Josh what solo practice asks.

**Ask Josh** about the mix's composition once solo practice works.

**Done when** a learner can practice one model, then a mix, and tests pin which models count as
known and how the mix is drawn.

**How it differed:**

- **Asked of Josh (2026-11-23), before building: what a pattern model's practice asks.** The
  **marked cells**, over "marked cells, bases too" and "irregular models only": a spelling-change
  model (manger, lancer, appeler, jeter, peser, céder, protéger, employer, payer, envoyer,
  dépecer, maudire) asks the cells that the practice record keeps as its own patterns (nous
  mangeons, j'appelle, j'appellerai), each of one of its ten most frequent verbs, in rounds of up
  to ten, unasked cells first. Parler's, finir's, and rendre's models have none, since every quiz
  asks them, and neither does a model with fewer than five marked cells (rompre, foutre, férir,
  ester, haïr's Québec model, ouïr). Each says why on its page.
- **The mix's composition, the phase's Ask Josh (2026-11-23)**, asked once a venir round alone on
  the simulator had made venir known and a prendre mix had run: **three of five verbs, or six of
  ten questions, are the model's own**, as built and as Konjugieren chose, over two of five and
  over an even share. `QuizDraw.modelMixOwnVerbCount` and `modelMixOwnCellCount`.
- **Carried over from Konjugieren unasked**, each a guess Josh can overrule: a model is its **ten
  most frequent verbs** at every level (venir's 29 would otherwise be 87 items); a key conjugation
  or a marked cell counts once; Mixed opens once another model is known, whether or not this one
  is; partners take turns one model at a time, and a short side leaves the rest to the other;
  "Another Round" in place of a count; no level line; nothing ranked.
- **Decided in the session.** (1) **The two kinds never mix.** A Verb Essentials model mixes only
  with known Verb Essentials models (aller, être, pouvoir among them once known), and a
  spelling-change model only with known spelling-change models (sevrer, rapiécer, fiche, haïr's
  French model among them), since a step of three rows and a single question are different
  exercises. (2) **The marked cells are the simple tenses without the passé simple and the
  subjonctif imparfait**, as Verb Essentials asks no literary tense, so a Beginner is not asked
  nous mangeâmes; a compound tense repeats its participle. Lancer has 11 cells, manger 7, céder 9,
  appeler 21. (3) The test that every marked cell maps to its model's own pattern for every one of
  the model's ten verbs passed for all fifteen spelling-change models, so the marks are a model's,
  not a verb's.
- **Where it starts**, as Konjugieren: a **Practice This Model** card ("Travailler ce modèle") on
  each model's page, before Verbs Using This Model, and a **Conjugation Models** row ("Modèles de
  conjugaison") in the hub's Exercises, with a chevron, pushing `ModelPracticeListView`: the 55
  models with a practice alone, ordered by each model's most frequent verb (faire, devoir, voir,
  dire, mettre, prendre), each with the model's irregularity line and a seal when known, expanding
  onto the same card. `QuizHubRow`'s content became `QuizHubRowContent`, which the pushing row
  shares. `isBeneathQuiz` already meant "a quiz is in progress", so Konjugieren's fix had no
  counterpart.
- **Buttons and titles:** "Alone" / "Seul", "Mixed" / "Mélangé", "Mixed: venir (6-7)" /
  "Mélangé : venir (6-7)", "Another Round" / "Encore une série". Twenty-two `ModelPractice.*`
  strings.
- **The sessions** are `QuizScope.modelPractice(_:)` in a `QuizSheet`, with `collection` set to the
  model's, so `quizStart` sends `collection` `model`, and no Live Activity starts. The results and
  the hub's Last Quiz name the model and no level (`LastQuizResult.Kind.modelAlone`, `.modelMixed`,
  the model's id as subject). Never ranked, no due items, no `ChangeLevelTip`.
- **Analytics.** New `source` values `modelAlone` and `modelMixed`. **A mixed session sends no
  counts**, since its length depends on which models are known. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **VoiceOver.** No new quiz state. The card's heading is a header, Alone and Mixed have hints
  (Alone's says Verb Essentials' three conjugations or a spelling change's conjugations), a closed
  Mixed reads as dimmed with its reason after it, and a known model's row reads "venir, (6-7),
  Known, 48% Irregular". Not heard by ear.
- **Tests:** 764 to 784, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `ModelPracticeTests`, 16 functions: each model's kind and whether it is practiced alone (16
  cases), each absence (11), ten most frequent verbs, manger's seven cells, every marked cell its
  model's own for every verb and never literary or compound, the list's order, known at half for
  venir, aller, and manger, a wrong answer or a lookup not counting, partners of the same kind, a
  round alone of five verbs and its second round's new ones, a spelling-change round asking each
  cell once and its second round the rest, a mix of three and two one model at a time, a short
  side, a spelling-change mix of six and four, turns, and the scopes and last result. Nested in
  `QuizTests`, 4: venir alone becoming known and joining prendre's mix, a wrong manger round
  leaving it unknown, a right one making it known, and Another Round with the signals, the last
  result, and no score.
- **Verified on the iPhone 17**, light. In French: the hub's Modèles de conjugaison row, the list,
  venir's card with Mélangé open on aller (known from the install's record), two venir rounds alone
  typed by a script that reads each question from the accessibility tree (150 and "Encore une
  série", no level line), venir then Connu, and a prendre mix of comprendre, méprendre, prendre,
  contenir, and aller with a re-ask step whose other rows were given. In English: manger's page
  through `conjuguer://model/1-2B` with Mixed closed and its reason, a manger round of all seven
  cells in which changais earned Phase 14's "Before a or o, changer keeps an e after the g" and a
  repair (65, Another Round), the notes on parler's, aller's (with its Known seal), and rompre's
  pages, and the hub's "manger (1-2B) · today". **On the iPad Pro 11** in English and dark: the hub
  with the row, the list with prendre expanded, and a prendre round in its form sheet answering
  reprend. Not tried: VoiceOver by ear, the software keyboard, a model un-knowing on the device
  (unit-tested), Another Round on the device (unit-tested), and a real day passing.
- **Seen, not changed.** (1) After the first venir round of 15 right answers venir was not known:
  only 13 of its 30 items had climbed. venir's own passé composé and futur, answered earlier the
  same day by Phase 15's fixture, were not yet due, and the ladder moves an item only when due.
  A second round made it known. Konjugieren noted the same; the ladder is Josh's.
- **Two older faults, fixed at Josh's request (2026-11-23).** (1) **écoconcevoir was filed under
  voir's model (4-1A)** in `verbs.xml`, so voir's practice could ask "écoconcevoit". It is now
  concevoir's (4-2B): écoconçoit, écoconçu. (2) **An impersonal verb followed the pronoun
  setting** everywhere, so with the feminine default the quiz asked "elle faut" and the verb page
  showed it. `Verb.isImpersonal` (defect groups 2, 22, and 23, which keep only the third-person
  singular for apparoir, chaloir, the weather verbs, and falloir, and pleuvoir and repleuvoir by
  name, since poindre shares pleuvoir's group and takes a real subject) makes
  `Verb.pronounGender(for:)` masculine. The quiz's frame, grading, diagnosis, spoken question,
  and results rows (`QuizResult.pronounGender`), the verb page, the tutor's tables, the widget,
  and the search and Siri lines use it, and the setting-reading `preamble` overload is gone, so no
  caller can skip it. Pleuvoir's figurative plural takes ils too. Tests 784 to 789
  (`ImpersonalVerbTests`, 2 functions and 3 nested in `QuizTests`). Seen on the iPhone 17 in
  French with the feminine default: falloir's page reading "il faut", search for faut reading
  "Indicatif Présent (il)" for falloir and "(elle)" for faillir, and Test Me on falloir framing
  "il [ ]" and accepting "avait fallu".
- **For Josh to judge:** "Mélangé" and "Seul"; "Encore une série"; "Travailler ce modèle"; the
  card's place on a model's page, before its verbs; whether a spelling-change model should also
  ask its literary cells at Advanced; and whether parler, finir, and rendre should have a practice
  after all.

## Phase 17: Recognition

**Suggestions:** T5.4. **Ports:** Konjugieren Phase 17 (`Recognition.swift`,
`RecognitionChoicesView.swift`). **Depends on:** Phase 3 and browse Phase 4's map. **Status:**
Done.

Show a conjugation, such as fûmes, and ask for the infinitive (typed) and the tense and person
(chosen, since typing their names would test the metalanguage). This is the direction a reader
needs. The bundled map gives every conjugation's verbs and cells. Many conjugations belong to
several cells or verbs (suis, vis, parle); accept any that matches, or avoid ambiguous prompts;
decide and test. Draw from the learner's level and band.

The Konjugieren ideas document rated recognition lower for Conjuguer, since francophone users know
the infinitive; it serves the English-speaking learners and anyone reading the passé simple.

**Carried over:** a mode of its own on the hub; the default quiz stays production practice.

**Done when** recognition questions ask, accept every right reading, and record to the practice
record, with tests on ambiguous conjugations.

**How it differed:**

- **Asked of Josh (2026-11-23), before building**, each the recommended option. (1) The French
  name is **"Identifier la forme verbale"**, the worksheet's wording, over "Analyser la forme
  verbale" and "Reconnaître le verbe"; the English stays Konjugieren's "Name the Conjugation".
  (2) **Answers are not recorded** in the practice record, as Konjugieren decided, since
  recognizing fûmes is not evidence of producing it. That reverses this phase's "Done when", which
  was copied before Konjugieren's answer. (3) **A pronominal verb's prompt keeps its reflexive
  pronoun** as French writes it (me souviens, s'est souvenue, souviens-toi), over leaving such verbs
  out and over a bare souviens.
- **Carried over from Konjugieren unasked**, each a guess Josh can overrule: chips for the tense and
  the person, above the field; one person chosen, any right one accepted; one more try at half
  points when any part is right, with a line naming what to check, and the correction at once when
  nothing is; a part called wrong only when changing it can make the answer right; every right
  reading accepted and no prompt avoided; the default quiz's draw by level, ten a round with Ten
  More; never ranked; the prompt's irregular letters in red.
- **Decided in the session.** (1) **Both genders count**: a compound prompt is matched in either
  gender, so est allée and est allé both accept aller's il passé composé, and the drawn prompt
  follows the setting. (2) The person chips read **"il/elle" and "ils/elles"**, since a bare
  conjugation shows no gender. (3) The infinitive is accepted **with or without se**, and in its
  1990 rectification (connaitre), whose traditional spelling then shows beside the check. (4) A
  pronominal verb's **impératif passé is asked as its passé composé**, since no text writes it, and
  its participe présent reads se souvenant. (5) The tense chips are the level's `QuizTenseSlot`s in
  the verb page's order, named in French in both languages, as the quiz names tenses. (6) A verb's
  compound cells are conjugated only when the prompt ends in its participle, which made building a
  round two to three times faster.
- **How it is built.** `Recognition.swift` holds `RecognitionQuestion` (the prompt, its cells, the
  offered tenses, the grade, the answer lines), `RecognitionAnswer`, `RecognitionGrade`, and
  `QuizScope.recognition`. `QuizQuestion.recognition` marks the question; `Quiz.submitRecognition`
  shares a new `finish(_:correction:)` with `process`, which scores, re-asks, and holds the
  correction for both. `QuizCorrection` gained the answer and its grade, `QuizResult` the prompt,
  and `LastQuizResult.Kind` `recognition`. The answer frame is a bare blank.
- **Analytics.** A new `source` value, `recognition`; `quizCompletion` keeps its `questionCount`.
  Staged in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **Strings:** eighteen `Recognition.*`.
- **Tests:** 789 to 807, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `RecognitionTests`, 14 functions: the cells of nine prompts (fûmes, suis, vis, parle, fait, me
  souviens, souviens-toi, finissons, avions pris), each cell writing its prompt, the level's
  tenses, the page order, both genders, six pronominal prompts, nine spellings of an infinitive,
  ten grades, the six lines, the correction's lines, the rectified spelling, and the scope. Nested
  in `QuizTests`, 4: the draw at each level, a right round recording nothing with its signals, last
  result, and Ten More, one more try at half points, and a held correction with its re-ask.
- **Verified on the iPhone 17**, light. In French with the fixture: the hub's row, fûmes with
  Advanced's nineteen chips, "Vérifiez l'infinitif. Encore un essai." for îetre, être on the second
  try, suivre · impératif · tu for suis (right), aller · futur simple · ils/elles for vis (the
  correction at once, listing vivre's and voir's readings), a sweep to the results (15, the prompt
  heading each row). In English, a real Intermediate draw (cessons) with all eleven chips, the
  person row, and Check in sight. **On the iPad Pro 11** in English and dark: the fixture's fûmes
  with every chip on four rows, être · passé simple · nous right, and suis next with the chips
  cleared. Not tried: VoiceOver by ear, the software keyboard, the Live Activity.
- **Seen, not changed.** At Advanced on the iPhone with a hardware keyboard, the floating accent row
  covers the field's lower half and Check, as Konjugieren saw; Return checks. The chips were made
  compact after the first look, when they filled the screen.
- **For Josh to judge:** the name in the title row; the repair lines; "il/elle" on the chips; the
  red irregular letters in the prompt, which hint at irregularity; whether Advanced's nineteen
  chips are too many on a phone; and the gap between the prompt and the chips, which is the
  feedback slot waiting for a line.

## Phase 18: Sentences with a Blank

**Suggestions:** T5.5. **Ports:** Konjugieren Phase 18 (`GapSentence.swift`,
[`../Konjugieren/plans/gap_sentences_batch_1.md`](../../Konjugieren/plans/gap_sentences_batch_1.md),
[`../Konjugieren/plans/gap_sentences_batch_2.md`](../../Konjugieren/plans/gap_sentences_batch_2.md)).
**Depends on:** Phases 2 and 3. **Status:** Done.

Short authored sentences for the core verbs, with the verb blanked, so the conjugation is tied to a
meaning.

- **The content.** A JSON resource: for each sentence, the French with a marked blank, the verb,
  its cell, and an English translation. A machine check confirms each blank's answer is the
  conjugator's conjugation of that cell, agreement included, so no sentence can teach a wrong
  conjugation. Write the drafting brief as a plan file beside this one, as Konjugieren did.
- **The app.** A sentence prompt built on Phase 2's frame, the sentence replacing the pronoun.
- **The literary reward.** The results screen can show a question's verb's literary example
  (`literature_examples.json`); the quiz itself never pauses after a right answer.

**Carried over:** Claude drafts (subagents on Sonnet), the machine check confirms, and Josh reviews
the first batch (for Konjugieren's second batch he accepted Claude's full reread instead); the 300
most frequent verbs, at the levels' tenses; the reward on the results screen.

**Ask Josh** how many sentences per verb once a first batch shows how long review takes.

**Done when** the sentences exist for the agreed verbs and pass the check, sentence questions
appear where decided, and tests pin the check.

**How it differed:**

- **Asked of Josh (2026-11-23), before building**, each the recommended option but one.
  (1) Sentences are **a mode of their own**, a row in the hub's Exercises, over a sentence now and
  then in the default quiz and over both. (2) The French name is **"Phrases à trous"**, the
  classroom's name, over "Phrases" and "En contexte"; the English stays Konjugieren's
  "Sentences". (3) **All 300 verbs in this session, Claude's full reread in place of Josh's
  review**, over a first batch for him to review: the phase's Ask Josh (how many a verb) was
  answered with Konjugieren's final counts, raised by one for the top 25. (4) The literary reward
  offers **every example, labeled**, the 12 Claude-written ones among the top 300 included, over
  literary sources only, so that the results and the verb page agree.
- **Not split.** One session built the app, the machine check, the review script, the brief
  ([`gap_sentences.md`](gap_sentences.md)), and **750 sentences**: five for each of the 25 most
  frequent verbs (a présent or impératif, a passé composé, an imparfait, futur, or conditionnel,
  an Intermediate tense, and a passé simple in a short narrative), three for each of the next 75,
  and two for each of the next 200. Ten Sonnet subagents drafted ranges of 25 to 34 verbs in
  parallel, each from the brief and a sheet of its verbs (gloss, auxiliary, defects, and every
  simple-tense form from `corpus/working/conjugations.json`, the app's own Conjugator). Cells: 181
  passé composé, 154 présent, 95 futur, 80 imparfait, 71 subjonctif présent, 67 impératif, 63
  conditionnel présent, 25 passé simple, and a few of the rest.
- **The machine check passed 745 of 750 on its first run.** The five failures were être compounds
  with no `gender`: the brief had asked for `"f"` only, so four masculine ones were unmarked, and
  one feminine one had been missed. The check requires a gender wherever the answer would change
  with the learner's setting, so the brief now asks for `"m"` too, and the five were fixed by hand.
  The script's pre-check (simple tenses against the dump, and the subject pronoun before the braces
  against the person) found nothing wrong; its five flags are noun subjects with an object nous or
  vous ("Ce billet vous {permet}").
- **The reread changed 23.** One real error, an unelided "Je {annoncerai}"; one ungrammatical
  "Pars tôt pour que tu évites" (the same subject wants pour éviter); on mixed with nous or ils
  twice; unidiomatic French ("mes parents coupaient mes cheveux", "changeait de conversation", "Il
  me semblerait bon", "chez vous … à la maison", a compound split by "enfin"); odd claims (houses
  without windows); and English that drifted ("You will maybe win", "had meant" for an imparfait,
  "I planned for an umbrella"). Then all 750 were approved.
- **Decided in the session.** (1) **One blank, one pair of braces**, unlike Konjugieren's several:
  French separates no prefix, so only a negation, an adverb, or an inversion inside a compound tense
  would need two, and the brief forbids those, which keeps one field and its keyboard focus.
  (2) **The sentence fixes an être verb's agreement** (`gender`), since its subject shows it;
  elsewhere the setting applies and changes no answer. (3) **The gender mark** shows beside the
  field for je, tu, nous, and vous in every compound tense, as in the one-line frame, so it
  reveals no auxiliary. (4) **An impératif shows (tu), (nous), or (vous)**: the first look on the
  iPhone showed "{ } dîner chez nous samedi !", which takes viens or venez alike, and the English
  "Come" does not say which. (5) **Answers are recorded** in the practice record, as the quiz's
  are, since a sentence is production. (6) The tense shows above the sentence, as in Konjugieren.
  (7) **A debug build asks drafts**, marked "Draft" / "Brouillon", as Konjugieren did; none remain.
  (8) The JSON is `Conjuguer/Models/gap_sentences.json`, snake_case as the app's other data files.
- **How it is built.** `GapSentence.swift` (the sentence, its cell, gender, frame, levels, the
  round's draw, and `QuizScope.sentences`); `AnswerFrame.Segment.context` and `sentenceWords`,
  which `AnswerFrameView` lays out word by word in `FlowLayout` (now centering each row's items
  vertically, which leaves uniform chips as they were) with a 170-point compact field, the word
  that touches the blank kept beside it; `QuizQuestion.sentence` and `pronounGender`, which
  `Quiz.process` now grades in; `QuizResult.sentence` and `verbKey`;
  `QuizResult.firstRightOfEachVerb` for the reward; `LastQuizResult.Kind.sentences`.
- **The literary reward** is an "Example Use" / "Exemple d'utilisation" button (the verb page's
  string) on the first right row of each verb in every quiz's results, revealing the verb page's
  example with its attribution.
- **Analytics.** A new `source` value, `sentences`; `quizCompletion` keeps its `questionCount`. The
  reward's reveal sends nothing. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
- **Strings:** seven, six `Sentences.*` and `ResultsView.exampleHint`.
- **A fixture**, `-CONJUGUER_QUIZ_FIXTURE sentences`, used only once Phrases à trous starts: ten
  sentences, one per kind of frame, listed in `docs/feature_architecture.md` § Phrases à trous.
- **Tests:** 807 to 826, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `GapSentenceTests`, 15 functions: the file decodes whole; every sentence well formed (ids,
  braces, cell, apostrophe, narrow spaces); every blank the Conjugator's in its gender and accepted
  by the grade, and a gender wherever agreement varies; asked at some level; the top 300's counts;
  frames with the gender and addressee marks, touching words, and spoken prompts; cells that name
  nothing; each level's band and tenses; drafts; the draw; the scope; the fixture's ids; and the
  reward's rows. Nested in `QuizTests`, 4: a sentence's gender over the setting, a round at each
  level of ten verbs, a right round recorded with its signals, last result, and Ten More's unasked
  sentences, and a held correction with its sentence and re-ask.
- **Verified on the iPhone 17**, light. In French with the fixture: the hub's row, viens right,
  sommes allés drawing "Avec être, le participe s'accorde avec le sujet, ici au féminin pluriel.
  Encore un essai." with (fém.) beside the field, the right second try at half points, fait for fit
  drawing "C'est l'indicatif présent.", a held correction with "Ce soir-là, le roi fit venir son
  cuisinier.", the re-ask, and results of 90 whose first rows offered venir's and aller's examples
  (venir's opened). In English, a real Intermediate draw (servir: "Ce couteau [ ] à couper le
  pain."), the field's label read from the tree. **On the iPad Pro 11** in English and dark: the
  fixture's sentence on one line with (fem.), and écouter's "(tu) [ ] ! Tu entends la pluie ?".
  Not tried: VoiceOver by ear, the software keyboard, the Live Activity, a round answered whole
  from a real draw, and a release build.
- **Two older faults, fixed at Josh's request (2026-11-23).** (1) **A results row showed a gender
  for every je, tu, nous, and vous**, so an impératif read "Impératif - tu (fém.)", in every quiz.
  `Tense.pronounDecorator` now shows it only for a compound tense, as the answer frame does.
  (2) **Nine literature examples showed Project Gutenberg's italic underscores** (venir's
  "L'_Assommoir_ est venu", Tartuffe, ridiculus sum), on the verb page as in the reward. They are
  now italics: `Example.styledFrench` renders each span with `.emphasized`, which Work Sans Italic
  (3, below) sets, and `Example.plainFrench` drops the markup for the widget, whose example line is
  italic throughout. The data keeps the source's markup. (A first fix turned the spans into
  guillemets in the data; Josh chose italics once the font had them, and that change was undone.)
  Tests 826 to 829: `AnswerFrameTests.aResultsRowShowsTheGenderWhereTheFrameDoes`,
  `ExampleSourceTests.everyExamplesItalicsMarkupIsBalanced`, and
  `ExampleSourceTests.underscoresBecomeItalicSpans`. Seen on the iPhone 17 in French: venir's page
  reading "L'*Assommoir* est venu". (3) **The sentence lines in the correction
  and the results were set `.italic()`, which Work Sans could not show**, so they read upright. At
  Josh's choice the app now bundles and registers `WorkSans-Italic.ttf` (version 2.012, from the
  Work Sans repository's `fonts/ttf`, the same family and metrics as the bundled 2.009 faces, under
  the OFL the Info credits already cite), and `.italic()` on the body font takes it. Seen on the
  iPhone 17 in French: "Viens dîner chez nous samedi !" in italic in a held correction.
- **For Josh to judge:** "Phrases à trous"; the gray (tu) and (fém.) marks among the words; the
  English under the sentence, which helps but tells the meaning; the tense shown above the
  sentence; spécialiser's two sentences, the weakest, since the verb is mostly pronominal; and
  whether Beginner, whose top 100 have only présent and impératif sentences, has enough of them.

## Phase 19: Which Tense Would a Speaker Use?

**Suggestions:** T5.6. **Ports:** Konjugieren Phase 19 (`ChoiceQuestion.swift`,
`ChoiceQuestionView.swift`, [`../Konjugieren/plans/choice_questions_batch_1.md`](../../Konjugieren/plans/choice_questions_batch_1.md)).
**Depends on:** Phase 18 for its content pipeline. **Status:** Done.

A context and two tenses or moods, with the learner choosing the one a speaker would use, and a
one-line reason after the choice. French has classic contrasts, perhaps worth more than German's
(**inference**): passé composé or imparfait; subjonctif or indicatif (il faut que, je pense que
against je ne pense pas que, bien que, après que); passé simple or passé composé, by register; the
si clause (si j'avais, not si j'aurais); futur or conditionnel (je voudrais as politeness). Level
each item with Phase 5.

**Carried over:** Claude drafts and Josh reviews; choice questions appear occasionally in default
sessions from the second level up, rather than as a mode.

**Done when** the items exist and are reviewed, the choice and its reason appear as decided, and
tests pin the item data's integrity.

**How it differed:**

- **Asked of Josh (2026-11-24), before building.** (1) **All five contrasts**: the passé composé or
  the imparfait, si clauses, the conditionnel of politeness, the subjonctif or the indicatif, and
  (asked apart, the recommended option) the passé simple or the passé composé by register.
  (2) **About 60 items, Claude's full reread in place of Josh's review**, over 40 with Josh
  reviewing, which was recommended, and 40 reread, as he chose for Phrases à trous.
- **Carried over from Konjugieren unasked**, each Josh's choice there on 2026-11-15 and a guess he
  can overrule here: one choice a round in every default round from Elementary up, Ten More's
  included; two named sentences, the conjugation in bold, its tense beneath; the card held after
  every choice, right or wrong, with the reason and Continue; 10 points or none, with no second
  attempt and no re-ask; nothing recorded in the practice record; never first in a round; the
  session's unasked items first; no new signal.
- **The batch.** 66 items in `Conjuguer/Models/choice_questions.json`, eighteen reasons. Elementary
  33: the passé composé for a completed action (5); the imparfait for a description (4), a habit
  (4), or an action under way (4); si with the imparfait, not the conditionnel (5); the
  conditionnel after si with the imparfait (3) and the futur after si with the présent (3); the
  conditionnel of a polite request (5). Intermediate 24: the subjonctif after necessity (4), a wish
  (3), an emotion (2), a conjunction (4), and doubt (2); the indicatif after penser que, croire
  que, or être sûr que (3) and espérer que (2); si with the plus-que-parfait, not the conditionnel
  passé (4). Advanced 9: the passé simple in a story or a history book (6), the passé composé in
  speech (3). Claude drafted all 66 in the session, without subagents, since each item is a
  judgment of grammar rather than a sentence to vary; `scripts/choice_questions.py` merged them.
  The machine check caught two whose verbs lay outside their level's band (dormir at Elementary,
  pleuvoir at Intermediate), which became travailler and faire. **The reread changed five**: the
  other sentence "vous avez lu toujours", wrong in its word order as well as its tense, lost
  toujours; "Auriez-vous un moment" and "Est-ce que je pourrais essayer cette veste", whose
  indicatifs are polite too, became "Nous voudrions deux billets" and "Je voudrais parler au
  directeur", where "je veux" is curt; the anglicism "Devine quoi" became "Tu sais quoi ? On a
  gagné"; and one English line. Then all 66 were approved. The sheet is
  [`choice_questions.md`](choice_questions.md). The likeliest to draw a francophone's objection
  are the polite requests (Pourriez-vous over Pouvez-vous, Sauriez-vous over Savez-vous, both
  polite, the conditionnel softer) and the history-book passé simple, which much modern history
  writing replaces with the présent.
- **Decided in the session.** (1) **A reason fixes its level and both tenses**
  (`ChoiceReason.level`, `rightSlots`, `otherSlots`), in place of Konjugieren's level per item, and
  the check holds every item to them. (2) **Reasons are fixed strings**, the tenses named in
  French in both languages, since Conjuguer has no setting for tense names. (3) **Four settings**,
  shown in French with an English gloss in the verb's place: Dans une conversation, Pour demander
  poliment, Dans un récit écrit, Dans un livre d'histoire. Konjugieren's news report was left out,
  since French news writes the passé composé. (4) **The two sentences may differ only in their
  braces and an elision before them** ("Je {travaillais}", "J'{ai travaillé}"), which the check
  enforces. (5) **The prompt is "Laquelle convient ici ?"**, feminine for la phrase. (6) **The
  typed questions are drawn first and the choice after**: drawn first, the choice moved every
  seed's typed draw onto another stream, and at Elementary rester rose from 10 to 20 of the
  non-core questions in `QuizDrawTests`' 120 seeds, past the cap of one in forty. (7) **The
  irregular half now rounds up**: with nine typed questions and two irregular core verbs, rounding
  down left two irregular among the other six. A round of ten is unchanged. (8) The feedback slot
  shows a held choice's mark as it shows a held correction's.
- **How it is built.** `ChoiceQuestion.swift` (`ChoiceQuestion`, whose sentences read as
  `GapSentence`s, `ChoiceSetting`, `ChoiceReason`, `ChoicePrompt`, `ChoiceQuestions`, the draw, and
  `QuizQuestion(choice:)`); `QuizQuestion.choice`; `QuizScope.mixesChoiceQuestions`;
  `Quiz.submitChoice`, `heldChoice`, and `isHeld`, which the clock, the answer guards, Continue,
  and Magic Tap now read; `process` refuses a choice question; `ChoiceQuestionView`. Tests that
  type their way through a default round skip its choice through a `Quiz.skipChoice(rightly:)`
  helper in `TestUtils.swift`, and the draw tests measure the typed questions alone.
- **Analytics.** None new; nothing to stage.
- **Strings:** 24, all `Choice.*`: the prompt, five for the card and VoiceOver, and eighteen
  reasons.
- **A fixture**, `-CONJUGUER_QUIZ_FIXTURE choices`, used when the default quiz starts: ten items of
  ten reasons, the right sentence first and second by turns.
- **Tests:** 829 to 846, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `ChoiceQuestionTests`, 12 functions: the file decodes whole; every item well formed; the two
  sentences alike but for the braces; both the Conjugator's in the item's gender and the right one
  accepted; the reason's tenses; asked from the reason's level and not before; every reason and
  setting used and worded; either order; Beginner none and Advanced all; drafts; the draw; the
  fixture's ids. Nested in `QuizTests`, 5: one choice a round at each level from Elementary and
  never first, none in other quizzes, a right choice held with the clock stopped and nothing
  recorded, a wrong one held and not re-asked, and a ranked round out of 100 whose Ten More asks a
  new choice. Changed: `testQuizLifecycle` and the Live Activity's count (the choice is not
  re-asked), the draw and level tests (typed questions only), and `halfOfEachQuizIsIrregular`
  (rounded up).
- **Verified on the iPhone 17**, light. In French with the fixture: si j'aurais chosen wrongly (the
  right sentence ringed green, the chosen red, the reason, Continuer), the tree's labels and values
  ("Le bon choix", "Votre choix", the reason read as "Incorrect. Le bon choix : …"), voyais wrongly
  again, eight right, and results of 80 with each row's sentence. In English, a real Elementary
  draw: the choice came second, after a typed miss, with the keyboard gone; jouais right (the other
  sentence dimmed, "A past habit…"); after Continue the next field took typing at once; Return on a
  hardware keyboard continues. **On the iPad Pro 11** in English and dark: the fixture's first item,
  each sentence on one line, chosen rightly. Not tried: VoiceOver by ear, Ten More from the device
  (unit-tested), the Live Activity, a release build.
- **For Josh to judge:** the items, above all the polite requests; "Laquelle convient ici ?" and
  "Which fits here?"; the setting in the verb's large type; the tense names under the sentences,
  which Konjugieren shows too and which make the choice partly one of names; a results row's
  "je (fém.)" on an avoir verb's passé composé, which Phrases à trous rows show the same way; and
  the irregular half rounding up.

## Phase 20: Mastery

**Suggestions:** T6.2. **Ports:** Konjugieren Phase 20 (`Mastery.swift`, `MasteryView.swift`).
**Depends on:** Phases 5, 11, and 13. **Status:** Done.

Show mastery: the core verbs and patterns against the tenses of the current level, filling in as
items move up the ladder. The report warns that progress displays are unproven for persistence, so
keep it modest. Patterns fill together across their verbs, which is honest but should look
intended.

**Ask Josh** to choose between a grid and a display that separates patterns from irregular verbs,
from mockups, and where it lives in the hub.

**Done when** the display reflects the record under test and Josh has judged it on a device-sized
screen.

**How it differed:**

- **Asked of Josh (2026-11-24), before building**, from ASCII mockups at Elementary, each the
  recommended option. (1) **The split display** over a grid: the regular families by tense, then
  the spelling-change models, then the irregular verbs. A grid would have shown an irregular verb's
  présent, impératif, and imparfait as three cells always alike, since they are one item, and a
  family's cell would have hidden which person is shaky. (2) **A row in From Your Practice**, below
  My Mistakes, that pushes the page, over a row in Exercises and a card at the foot. (3) **The
  band's irregular verbs, up to 50**, over a fixed 50 and over 50 base verbs. Konjugieren's fixed
  50 fit inside its Beginner band; Conjuguer's top 100 holds only 36 irregular verbs, so a fixed 50
  would have listed 14 that a Beginner quiz never asks.
- **Departed from Konjugieren: French needs a third section.** The record keeps a spelling-change
  model's marked cells as patterns of its own (Phase 11), and they are about half of every level's
  patterns, so they get **Spelling Changes** ("Particularités orthographiques"), a card per model
  titled by its exemplar and its first changed form ("lancer · nous lançons"), with a line per
  tense marking only the changed persons. A compound tense's card adds an **être row** for a family
  whose band verbs take être, since those patterns are kept apart (`takesÊtre`).
- **Which patterns a level shows, decided in the session**: those a verb of the level's band can
  be asked in its tenses, so the page and the default quiz agree: 46 at Beginner, 223 at
  Elementary, 368 at Intermediate, 901 at Advanced. Measuring every band verb at every cell takes
  seconds at Advanced, so `Mastery` measures one verb of each model and auxiliary per cell (skipping
  a defective one) and caches the result per level; a test measures the first three levels the
  slow way and checks that the two agree, and the session ran it once at Advanced too, where it
  passed. Mastered means the third box (`MasteryState.masteredBox`), as in Konjugieren, and a verb
  counts once every stem its level asks is mastered: the présent at Beginner, the passé composé and
  futur from Elementary, the passé simple (vint, which the card never shows) at Advanced.
- **Carried over from Konjugieren unasked:** three states with three shapes (●, ◐, ○); the page
  only shows, since opening a verb page is a lookup that resets its key conjugations; one signal
  of having looked. Conjuguer reports screens through `viewAppeared` and `recordsAppearance`, so
  the page sends `viewName` `MasteryView` rather than a new `viewMastery`.
- **Names, proposed in the session:** "Mastery" / "Maîtrise"; the states "Mastered", "Learning",
  "Not yet practiced" / "Maîtrisé", "En cours", "Pas encore travaillé"; the hub's line "Mastered:
  10 of 368 patterns · 1 of 50 verbs" / "Maîtrisé : 10 sur 368 formes · 1 sur 50 verbes", where
  "formes" stands for patterns, since "modèle" already means a conjugation model in the app, and
  the noun follows the total so that a count of 0 or 1 needs no singular.
- **Built as** `Mastery.swift` (`MasteryState`, cells, pattern rows and tables, model cards, verb
  rows, the counts, `stems(askedAt:)`, `coreVerbs(at:)`, `patterns(at:)`, and the cached layout)
  and `MasteryView.swift` (`MasteryDestination`, the legend, and a view per card), with the row in
  `QuizView.recordSessions`. Sixteen `Mastery.*` strings.
- **Analytics.** No new signal; the page's `viewName` is staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages, with the
  practice-record paragraph saying the record shows what has been mastered.
- **VoiceOver.** Each mark its own element read as its state; in a regular card each pronoun its own
  French element above its mark; a family read as "-er verbs" or "-er verbs with être"; French
  marked French and conjugations lowercased; headers with their counts. Read from the accessibility
  tree, not heard.
- **Tests:** 846 to 860, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `MasteryTests`, 14 functions (20 cases): the state by box through a wrong answer, a lookup as
  learning, each level's pattern count (4), the patterns against every band verb asked (3 levels),
  the family rows and persons, the être row and participles, Beginner's spelling-change models with
  manger's cells and the examples "nous mangeons" and "j'appelle", the band's irregular verbs (4:
  36, 50, 50, 50, none skipped), the stems by level, venir's and falloir's key conjugations at
  Advanced, the display following a seeded record, a verb mastered by its level's stems, a pattern
  beyond the level not counted, and answers landing where the mapping sends them.
- **Verified on the iPhone 17**, light, at Intermediate, with mastered entries seeded into the real
  record's plist (the record restored afterward, byte for byte, and confirmed after a relaunch; the
  page wrote nothing while viewed). In English: the hub row ("Mastered: 10 of 368 patterns · 1 of
  50 verbs"), the legend and the Indicatif Présent card following the seed, the Passé Composé's
  -er (être) and -re (être) rows, the participles' single marks, lancer's card ("nous lançons", the
  ç red), and the verbs from être down, faire filled. In French: the hub row, the page's intro,
  legend, and cards, and "Particularités orthographiques" wrapping beside its count. **On the iPad
  Pro 11** in English and dark: the hub row ("7 of 368 patterns · 1 of 50 verbs", matching its
  seed) and the page at its 680-point width; its record restored the same way. Not tried: VoiceOver
  by ear, large text sizes, Beginner and Advanced on screen (unit-tested), a record built by real
  days of practice.
- **For Josh to judge:** the page on his phone, which the phase requires before it is done; the
  names, above all "formes" and "Maîtrise"; the pronoun over every mark in a regular card, which
  VoiceOver needs but which repeats; and two things the record's mapping puts on the page, which
  Phase 11 decided rather than this phase: lancer's imparfait and subjonctif présent show nous and
  vous (lancions, lanciez) as changed cells, because the Conjugator marks the c that returns there, and fiche's and maudire's compound tenses fill their own cards at Advanced, since their
  participles (fichu, maudit) are marked.
- **Josh asked for the commit** on 2026-11-24, which the phase's "judged it on a device-sized
  screen" required.

## Phase 21: Speed Round

**Suggestions:** T5.7. **Ports:** Konjugieren Phase 21 (`SpeedRound.swift`). **Depends on:**
Phases 11 and 20. **Status:** Done.

A speed round over items already mastered, the one place where the clock counts: Paul Nation's
fluency strand, speed for material already accurate. Conjuguer's old time bonus finds its home
here.

**Carried over:** sixty seconds, counting right answers; a personal best on the device, nothing
ranked; an item is mastered once its interval is seven days or longer (the third box); a miss does
not send an item down the ladder.

**Ask Josh** what the round offers when too few items qualify, once Phase 20 shows how quickly items
reach the third box.

**Done when** the round draws only mastered items, times as decided, and tests pin the drawing and
scoring.

**How it differed:**

- **Asked of Josh (2026-11-24), before building**, each the recommended option. (1) The phase's
  Ask Josh: the round **opens at 5 mastered items and repeats them** as a round needs, as in
  Konjugieren (over opening at any number, at 10, and over topping up with items still learning,
  which would break "only mastered"). Below 5 the hub's row is no button and says how many are
  mastered. He was told that nothing is mastered sooner than three days after its first right
  answer. (2) The French name, **"Contre-la-montre"**, the time trial, over "Partie éclair" and
  "Sprint". English is "Speed Round".
- **Carried over from Konjugieren unasked**, being Josh's answers there of 2026-11-15: a miss does
  not stop the round (no second attempt, even for a slip or a diagnosis; no correction; no
  re-ask; the clock runs on) and its right answer shows on the next question; a mastered key
  conjugation asks any cell of its stem the level asks, or its own il cell; a pattern asks a fresh
  verb of the band; the round records nothing, right or wrong. Also as Konjugieren decided in its
  session: a row at the foot of Exercises with a bolt; items not otherwise held to the level; one
  personal best, not one per level, kept by `PracticeStore` and forgotten by Reset Practice, whose
  description and alert now say so; a round with none right sets no best; results with "Right
  Answers in 60 Seconds", the count, "New personal best!" or "Your best: n", and Another Round
  ("Encore une manche"); the Last Quiz row without a score; no counts in the signals.
- **Departed from Konjugieren.** (1) **Which cells a key conjugation asks** is held to the cells the
  level's tense asks *of that verb*, by the tense's verb pools, since Conjuguer's slots carry pools
  where Konjugieren's carried verb restrictions: mastered vient asks il vient, every présent and
  impératif cell, the imparfait from Elementary, and the participe présent from Intermediate, but
  never qu'il vienne, because the default quiz asks the subjonctif présent only of regular verbs and
  être, avoir, and aller. (2) **A pattern avoids repeating its last verb** within a draw where it
  has more than one, and falls back to any verb when the band has none, as Review does. (3) **The
  miss line sits in the feedback slot**, under the new question's tense, where a right answer's
  check appears, rather than above the verb as in Konjugieren, and is written out with its pronoun
  or addressee (`AnswerFrame.writtenOut`): "venir · (tu) viens !", "aider · j'aide". (4) **The
  status row shows symbols**, a check with the count and a timer with the time, since "Bonnes
  réponses : 0" beside "Temps restant : 0:51" wrapped to two lines on the iPhone. VoiceOver reads
  the words. The bar above it is the minute, red with the digits in the last ten seconds.
  (5) **The results and the last result name no level** (`asksByLevel`), since the items are not
  the level's. Konjugieren's focus fix (a hub session taking the keyboard) was already in
  Conjuguer.
- **Built as** `Models/SpeedRound.swift` (`SpeedRound`, `QuizScope.speedRound`,
  `QuizDraw.speedRoundQuestions` and `speedRoundCells`, `SpeedRoundMiss`, `AnswerFrame.writtenOut`,
  and the DEBUG fixture), with `Quiz`'s `finishSpeedRoundAnswer`, `finishSpeedRound`, a batch drawn
  in `advance()` as the round reaches its last question, and `clockTicked()` ending the minute.
  `QuizDraw.patternVerbs` was split out of `patternVerb` so a round reads each pattern's verbs once.
  Sixteen `SpeedRound.*` strings.
- **Analytics.** A new `source` value, `speedRound`, with no `questionCount` or
  `lastQuestionIndex`. Staged in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md)
  in both languages: the lifecycle, progress, and duration bullets and the practice-record
  paragraph, which now names the best. The progress bullet also gains a model's mixed practice,
  which Phase 16 stopped sending but left out of that bullet.
- **VoiceOver.** After a miss, "Incorrect. The answer was:" and the answer in French, before the
  next question; the right answers and seconds left in place of the progress and score; "Ten
  seconds left."; and "Time is up. Right answers: n." with the best. All through `Utterer`, whose
  queue may still be reading the last question when the miss is announced. Read from the
  accessibility tree, not heard.
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE speedRound` opens the round whatever the record holds,
  on eight items. A round on it still writes the device's best and last result.
- **Tests:** 860 to 880, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `SpeedRoundTests`, 13 functions (16 cases): the third box as mastered, unaskable items left out,
  only mastered items at every level (4), each in turn and never twice running over 20 seeds,
  one item repeated, nothing from nothing, a pattern's band verbs changing, a spelling-change
  pattern's model, venir's and être's cells by level, falloir in il, the scope, the best across a
  launch and a reset, and misses written out. Nested in `QuizTests`, 7: nothing mastered starting
  nothing, a right answer counted and a miss moving on at once, a slip as a miss, the record
  untouched, every question a mastered item over 25 answers, sixty ticks ending the round with the
  unanswered question dropped and the best kept then not beaten, and no score posted or counts
  sent.
- **Verified on the iPhone 17**, light, with the fixture. In English: the open row, a round whose
  field had the keyboard at once (se coucher, "est couchée" right), a miss ("venir · venant"), time
  running out to results of 1 with "New personal best!", Another Round with the keyboard up, the
  locked row without the fixture ("So far: 0"), and the Last Quiz row without a score. In French:
  the row with "Record : 1", the title "Contre-la-montre", misses ("aider · j'aide", "faire · elle
  ferait"), the status row before and after its change to symbols, and results with "Votre record :
  1" and "Encore une manche". **On the iPad Pro 11**, in English and dark: the row, a round, the
  last eight seconds red, a miss ("suspendre · elles suspendaient"), and results of 0 with no best
  line. Not tried: VoiceOver by ear, the software keyboard, large text, a record mastered by real
  days. The iPhone simulator now holds a best of 1 and a Speed Round as its last result.
- **For Josh to judge:** the round on his phone; the name and "Encore une manche"; the miss line's
  place under the tense; the symbols in the status row; and whether the locked row's sentence is
  too long.
- **Josh asked for the commit** on 2026-11-24.

## Phase 22: A Daily Session and a Streak

**Suggestions:** T6.3. **Ports:** Konjugieren Phase 22 (`DailySession.swift`, `DailyStreak.swift`,
`DailyReminder.swift`, `ReminderSchedulerReal.swift`). **Depends on:** Phases 11, 12, and 13.
**Status:** Done.

A short daily session, a streak that can be repaired, and an optional reminder at a time the
learner picks. Ask for notification permission only when the learner turns the reminder on. The
reminder may say how many items are due.

**Carried over:** ten questions at the learner's level, due items first, then new draws; finishing
it extends the streak; one missed day is repaired by two sessions the next day; the widgets do not
show the streak; signals for the reminder turned on or off, a `source` for the app opened from the
reminder, and the streak's length in bands (1, 2-6, 7-29, 30+), all staged.

**Done when** the session, the streak with its repair, and the reminder work across days under a
controllable clock in tests, and the reminder fires on the simulator at the chosen time.

**How it differed:**

- **Nothing was asked of Josh.** The phase lists no Ask Josh items, and Konjugieren's in-session
  choices carried over where French did not make one awkward. Each is a guess he can overrule.
- **Carried over from Konjugieren unasked:** due items first, held to the level's tenses and band,
  most overdue first, up to all ten, so a due passé simple waits for Review below Advanced; **no
  choice question**, since a choice moves nothing in the record; **no Ten More**, a second
  session being one of its own, and **Another Session** in Ten More's place while a repair awaits
  its second session; never ranked, though it starts a Live Activity; a quit session not counting;
  the streak's length as days practiced, the bridged day not counted, one session on the day after a
  missed day showing as a repair in progress; only the last two runs stored; Reset Practice
  forgetting the streak, its description and alert now saying so; the row first in From Your
  Practice, a calendar or a flame, always a button; the reminder after the clock in Settings, Off
  by default, **18:00**, permission asked only on turning it on, a refusal leaving it Off with a red
  line and Open Settings; **one notification a day for 14 days**, each worded with what that day
  will have due or the repair it needs, none on a day already done; a tapped reminder starting a
  session unless a quiz is under way or showing results, and a reminder due while the app is open
  showing nothing; `tapDailyReminder` with `enabled` `true`, `false`, or `denied`; the streak band
  of a pending repair being the streak at stake; and `questionCount` sent, the session being ten.
- **Departed from Konjugieren.** (1) **The draw is the default quiz's**, not a function of its own:
  Conjuguer's default draw already mixed due items in, so `QuizScope.isDaily` raises
  `dueItemLimit` from three to ten and `QuizDraw.dueQuestions` takes the limit. The
  `-CONJUGUER_QUIZ_FIXTURE` fixtures therefore apply to the session too, so no fixture of its own
  was added; the repair was seeded into the App Group plist instead. (2) **The reminders wait for
  the verbs.** Conjuguer reschedules at every activation, and the first comes before the verbs load,
  when nothing counts as askable, so `rescheduleReminders` leaves the scheduled reminders alone
  until then and the launch task reschedules after the load. (3) **The setting is its own card**,
  Daily Reminder after Quiz Clock, since Conjuguer's Settings give each setting a card; Off and On
  are "Non" and "Oui" in French, as Suppress Review Card's are. (4) **The notification delegate has
  a file of its own** (`ReminderNotificationDelegate.swift`), and the protocol too, by the
  one-type-per-file convention. (5) **VoiceOver hears the streak line** through `Utterer` when a
  session finishes, since Conjuguer has no completion announcement to append it to.
- **Names, proposed in the session:** "Daily Session" / "Séance du jour"; a streak is a "série"
  ("Série : 3 jours"), though "série" also names a round of model practice ("Encore une série");
  "Another Session" / "Encore une séance"; "Daily Reminder" / "Rappel quotidien"; the notification's
  title "Time to Practice" / "C’est l’heure de conjuguer".
- **Built as** `Models/DailySession.swift` (`QuizScope.daily(source:)`, `DailySessionRequest`, the
  status's lines), `Models/DailyStreak.swift`, `Models/DailyReminder.swift` (the setting,
  `ScheduledReminder`, `DailyReminderPlan`, `World.rescheduleReminders`), and in `Utils/`
  `ReminderScheduler`, `ReminderSchedulerReal`, `ReminderSchedulerSpy`, and
  `ReminderNotificationDelegate`, with `World.reminderScheduler` and `dailySessionRequest`, the
  `quiz/daily` route (`URL.dailySessionDeeplink`), `Quiz.dailyStreakStatus`, and `.daily` in
  `LastQuizResult.Kind`. Twenty-six new strings, and the two Reset Practice lines changed.
- **Analytics.** `source` values `daily` and `reminder`, `streak` on a daily session's
  `quizCompletion` (`AnalyticsBand.streak`), and `tapDailyReminder` with `enabled`. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages: the
  lifecycle bullet, a new bullet for the reminder, and the practice-record paragraph, which names
  the streak and says the reminder is written and scheduled on the device. Also found:
  `docs/feature_architecture.md`'s table of `source` values lacked Phase 21's `speedRound`, now
  added beside `daily` and `reminder`, as Konjugieren's session found in its own table.
- **VoiceOver.** The row reads its title and line, with a hint; the results' streak line is spoken
  at the finish; Another Session has a hint. Read from the accessibility tree, not heard.
- **Tests:** 880 to 905, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `DailySessionTests`, 16 functions (22 cases) under a fixed Paris calendar: no streak, a streak
  through the next day and repairable the day after, a day counted once, two sessions repairing,
  one session starting anew, two missed days, a 25-hour day, pruning, the bands (7), the store
  across a launch and a reset, the lines, the scope, and the reminder plan (each day at the time,
  today's past, a done day skipped with the repair line after, what will be due). Seven nested in
  `QuizTests`, with `Quiz`'s injected `now`: due items first and nothing beyond the level, ten due
  items filling the session, the streak and its band with no score posted, a quit not counting, a
  repair across four days, the reminder rescheduled and cleared, and `reminder` as the source. Plus
  the setting in `SettingsTests` and the `quiz/daily` route in `DeeplinkTests`.
- **Verified on the iPhone 17**, light, at Intermediate. In French: the row with no streak; the
  reminder's link opened with `simctl openurl` from the Verbs tab, straight into "Séance du jour"
  with the field focused, its first questions the record's due items (falloir, venir); results with
  "Série : 1 jour" and no Ten More; the row's "Série : 1 jour. C’est fait pour aujourd’hui." and the
  Last Quiz row naming the session; a seeded streak of the 21st and 22nd reading "Vous avez manqué
  hier. Deux séances aujourd’hui sauvent votre série de 2 jours."; a first session ending "Encore
  une séance aujourd’hui, et votre série de 2 jours est sauvée." with Encore une séance, and the
  second, started from it with the field typing at once, ending "Série : 3 jours". In English:
  Settings' card, the system's request appearing only on tapping On, Allow, and the time picker at
  6:00 PM; and the reminder **fired on the simulator at the chosen time** (set two minutes ahead in
  the defaults, the app in the background), reading "Time to Practice. Your daily session is ready,
  with 4 conjugations due for review." **On the iPad Pro 11**, in English and dark: the row at full
  width, a session asking the four due items first and ending "Streak: 1 day", and the request
  refused, leaving Off with the line and Open Settings. That check found the line drawn in the
  label color rather than red, since `settingsLabel()` set its own color closer to the text; fixed
  and seen red. Both simulators' records and settings were restored afterward, the iPhone's checked
  across a relaunch, and the iPhone's remaining reminders cleared by a launch with the reminder off.
  **The iPhone simulator now allows Conjuguer's notifications and the iPad's refuses them.** Not
  tried: tapping the delivered notification (AXe's tap on the Lock Screen cell did not open it, as
  in Konjugieren), the time picker by tap, Open Settings, VoiceOver by ear, and a real day passing.
- **For Josh to judge:** the session and the reminder on his phone; the names, above all "Séance du
  jour" and "série", which also names a round of model practice; the row first in From Your
  Practice, which pushes My Mistakes lower on the iPhone; 18:00 as the default time; and the
  notification's title, "C’est l’heure de conjuguer".
- **Josh asked for the commit** on 2026-11-24.

## Phase 23: Personal Bests and Achievements

**Suggestions:** T6.6 (personal bests and achievements). **Ports:** Konjugieren Phase 23
(`Achievement.swift`). **Depends on:** Phases 8, 20, and 22. **Status:** Done.

Personal bests per level, kept on the device (replacing the single `bestScore`), and Game Center
achievements for mastery milestones, not volume of play. Propose a short list to Josh (every Level
1 pattern in a high box; the key conjugations of the 50 most frequent irregular verbs; every être
verb's passé composé). Extend `docs/game_center_setup.md` with the achievements' IDs, English and
French titles and descriptions, points, and artwork requirements, from Apple's current
documentation. `GameCenter` gains a way to report an achievement.

**Carried over:** artwork generated with the `gpt-image` skill, every prompt giving hex colors from
Conjuguer's palette (the color sets in `Conjuguer/Assets/Assets.xcassets`: `customBackground`,
`customSurface`, `customForeground`, `customBlue`, `customRed`, `customGreen`, `customGray`, and
`AccentColor`, light and dark values from each `Contents.json`); Josh picks among drafts.

**Ask Josh** to approve the list before any artwork is made.

**Done when** each achievement reports when its milestone is reached, under test with the stub, and
the walkthrough covers achievements.

**How it differed:**

- **Asked of Josh (2026-11-24), before building**, each the recommended option. (1) **Nine
  achievements**, Konjugieren's eight ported plus the phase's être-verb suggestion, 410 of Apple's
  1,000 points: Premières pierres, Les murs, La voûte, and La clé de voûte (First Stones, The
  Walls, The Vault, The Keystone) for every pattern of Beginner (46), Elementary (223),
  Intermediate (368), and Advanced (901), 10, 25, 50, and 100 points; Les piliers (The Pillars)
  for être, avoir, aller, faire, pouvoir, vouloir, devoir, and savoir, 25; Dix, Vingt-cinq, and
  Cinquante irréguliers (Ten, Twenty-Five, Fifty Irregulars), 25, 50, and 100; and La maison
  d'être (The House of Être), 25. Over Konjugieren's eight alone, and over six without the 10 and
  25 steps. (2) **Reset Practice forgets the per-level bests**, which live in `Settings` rather
  than the practice store, as it forgets the Speed Round's best and the streak. (3) **The
  achievements are to be created in App Store Connect by driving Chrome**, as Phase 8's
  leaderboards were, once Josh has picked the artwork, over a walkthrough alone and over adding a
  `GameCenterResources.gamekit`. (4) **The best shows on the results**, as in Konjugieren.
- **The personal bests were mostly there.** Phase 8 had already replaced the single `bestScore`
  with one per level and shown the level's on the hub's foot, so the phase's "replacing the single
  `bestScore`" was done. What it added: "New personal best!" with a star, or "Your best: n", under
  the score of a ranked session's first results (none after Ten More, for an unranked session, or
  for a 0), spoken through `Utterer`, since Conjuguer has no results announcement to append it to;
  and the reset. The Speed Round's `speedRoundPreviousBest` and `isNewSpeedRoundBest` became
  `previousBest` and `isNewBest`, shared by both, and the results' identifiers became
  `results_new_best` and `results_best`. The ranked line has keys of its own
  (`ResultsView.newBest`, `ResultsView.best`) with the Speed Round's words, as in Konjugieren.
  Konjugieren's hub line "Your best at this level" was not ported, the foot's "Best score: n"
  already saying it.
- **Decided in the session.** A verb counts when its présent, passé composé, and futur key
  conjugations are all mastered (`Achievement.isFullyMastered`), whatever the level; the passé
  simple, which only Advanced asks, is not required, so the verb achievements do not wait for
  Advanced. The 50 are `Mastery.coreVerbs(at: .elementary)`, the same at every level above
  Beginner (pinned by a test), and the eight pillars are `QuizDraw.coreInfinitifs`, all among
  them. The maison d'être is twenty items: eight irregular verbs' passé composé key conjugations
  and the six persons of each of the -er and -re patterns with être, which the nine regular verbs
  share. The -re pattern is first asked at Intermediate, whose band holds descendre. A pattern
  achievement counts `Mastery.patterns(at:)` rather than building a whole `Mastery`. None is
  hidden, and progress is sent as a percentage.
- **Departed from Konjugieren.** (1) **Nothing is measured while signed out.**
  `GameCenter.reportAchievements(in:)` is a protocol extension that returns at once unless
  `isAuthenticated`, rather than Konjugieren's `World.reportAchievements()` at every launch: a
  first measurement builds every level's pattern layout (about 0.15 seconds in the tests), and
  Conjuguer signs in only when the Quiz tab appears, which now reports too. So it is reported at
  sign-in, at every results and quit, and at a review card's reveal. The quiz reports through its
  own `gameCenter`, so a test's spy sees it. (2) **View Achievements sits below View Leaderboard**
  at the hub's foot, not beside it, and Settings gains no row, having no leaderboard row to sit
  under. (3) **The artwork has its own palette and theme**: Conjuguer's slate blue, rose red,
  mint white, and charcoal, no gold, and a French Gothic arch; the irregular verbs' numerals and
  the keystone in the app's irregular-letter red.
- **The artwork.** Eighteen drafts, two per achievement, made with `gpt-image`
  (`gpt-image-2.5-sunburst`, high, 1024 × 1024, opaque) for about $0.97, from the prompts in
  [`achievement_artwork.md`](achievement_artwork.md): a shared preamble giving the color sets' hex
  values and a round medallion with a slate-blue rim, then a motif each. Both drafts of every motif
  came out on palette and readable at Game Center's size. **Josh left the pick to Claude**
  (2026-11-24), which took the first draft of each: the three shields' first drafts share one arch
  and laurel, and the first vault's plain piers match the keystone's. They are JPEGs at quality 92,
  as Konjugieren's are, in `Images/achievements/`, outside the app target, since Conjuguer has no
  `.gamekit` for the build to copy.
- **Created in App Store Connect** by driving Chrome on 2026-11-24, as Josh chose: all nine, each
  with its points, Hidden No, and English (U.S.) and French localizations with the image, read
  back afterward, in "Prepare for Submission" and added to no version. The form allows **30
  characters for a name and 120 for each description**, which the descriptions as first written
  overran in French and in the pillars' English, so they were shortened before entry: the French
  pattern lines say "si sa révision est dans 7 jours ou plus", and the verb lines put the example
  in parentheses. The form also **defaults Hidden to Yes**. Both are now in the walkthrough.
- **Analytics.** `tapViewAchievements` with `source` `tab`. No signal for earning one. Staged in
  [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages: the taps
  bullet, section 6's paragraph and third-party line naming achievements and the percentages sent
  to Game Center while signed in, and the practice-record paragraph naming the bests.
- **The walkthrough** is [`docs/game_center_setup.md`](../docs/game_center_setup.md) § The
  Achievements: IDs, points, the English and French names and pre- and post-earned descriptions,
  what each counts, Apple's limits and image requirements (as Konjugieren's session read them from
  Apple's pages on 2026-11-15, nine days earlier, not read again), the steps, the reporting, and
  release-day testing. [`docs/release.md`](../docs/release.md) gains the step, and
  [`docs/description.txt`](../docs/description.txt) mentions achievements in both languages.
- **Strings:** four new (`QuizView.viewAchievements` "Voir les succès", Game Center's own French
  word; `QuizView.achievementsHint`; `ResultsView.newBest`; `ResultsView.best`), and Reset
  Practice's description and alert now name "your best scores" / "vos meilleurs scores".
- **VoiceOver.** The results' best line is spoken at the finish; View Achievements has a hint.
  Read from the accessibility tree, not heard.
- **Tests:** 905 to 930, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `AchievementTests`, 16 functions (29 cases): each ID (9), distinct IDs, the points, the 50 the
  same at Intermediate and Advanced, the pillars, the maison d'être's twenty items, an empty
  record, each level's patterns earning its own and the lower levels' (4), one pattern short,
  learning counting for nothing, all three key conjugations needed, the passé simple not needed,
  each step (3), the pillars, the maison d'être, and nothing measured while signed out.
  `QuizAchievementTests`, 10 nested in `QuizTests`: the results reporting every achievement with
  Beginner's patterns at 100, a quit reporting, nothing signed out, a first best then one not
  beaten then one beaten, each level its own, none after Ten More, none for a daily session or
  Test Me, none for 0, and the reset.
- **Verified on the iPhone 17**, light, with the screenshot fixture. In French at Intermediate,
  whose best was 100: results reading "Votre record : 100" under the score, and the hub's foot with
  View Achievements. In English at Beginner: "New personal best!" with the green star, the foot's
  "Best score: 100", View Leaderboard, and View Achievements, and Settings' Reset Practice
  description naming the best scores. **On the iPad Pro 11**, in English and dark at Intermediate:
  "New personal best!" and the foot with both buttons. A swipe given in pixels rather than points
  shrank the iPad's app into a window, which its green button restored; the skill's table now
  says so. Both simulators' bests and level were written back to what they held. The two fixture
  quizzes did write their answers into each simulator's practice record and last result. Not
  tried: anything signed in to real Game Center (the reports, the banner, the achievements view),
  the Reset Practice alert, VoiceOver by ear, and an achievement earned by real days.
- **Josh asked for the commit** on 2026-11-24.

## Phase 24: The Daily Challenge

**Suggestions:** T6.8. **Ports:** Konjugieren Phase 24 (`DailyChallenge.swift`). **Depends on:**
Phases 5 and 22. **Status:** Done.

A daily shared challenge built on the widget's daily question
(`WidgetSnapshotWriter.generateQuizQuestion`, seeded by the date): the same short set for everyone
that day, with a result the learner can share as text with the App Store link. Make the widget's
question follow the challenge. Analytics: a `source` for the challenge on the quiz signals, and a
signal for sharing a result, never the result itself.

**Carried over:** one challenge per level per day, five questions each; a shared result names the
level.

**Ask Josh** to approve the shared text, from a drafted example in both languages.

**Done when** two devices on the same date get the same challenge, the widget's question agrees with
it, sharing produces the agreed text, and tests pin the seeding.

**How it differed:**

- **Asked of Josh (2026-11-24), before building**, each the recommended option. (1) **The shared
  text** as Konjugieren's approved shape, with Conjuguer's own colors for the dots: 🟢 right, 🟠 right
  on the second try, 🔴 wrong, the colors of the results' marks (Conjuguer has no progress dots), over
  the dots without the points and over no challenge link:

  ```
  Conjuguer · Daily Challenge
  November 24, 2026 · Elementary
  🟢🟠🔴🟢🟢  35 / 50

  Take this challenge in Conjuguer:
  conjuguer://quiz/challenge?date=2026-11-24&level=elementary&source=challengeLink

  Get Conjuguer on the App Store:
  https://apps.apple.com/app/conjuguer/id1588624373
  ```

  In French, "Conjuguer · Défi du jour", "24 novembre 2026 · Élémentaire", "Relever ce défi dans
  Conjuguer :", and "Télécharger Conjuguer sur l’App Store :", the last as the practice set's text
  has it. (2) **Konjugieren's other three choices**: once a day per level, after which the row shows
  the result and shares it; the row under the Daily Session; and the quiz widget asking the
  challenge's first question, a tap beside its answers opening the challenge.
- **Carried over from Konjugieren unasked:** the key as the learner's calendar day and the level;
  the seed as FNV-1a of `challenge-<day>-<level>`, pinned by a test with the text; the default
  quiz's balanced draw, five questions, drawn again until no verb repeats, with nothing from the
  device in it (no due items, no My Verbs, no choice question); no re-ask, the correction still held
  and a slip still earning its second try at half points; answers moving the practice record; never
  ranked, continued, or given a Live Activity; a quit keeping nothing; the last 12 results kept, and
  Reset Practice keeping them; a link to a taken challenge opening the hub; a bad date asking for
  today's and an unknown level the learner's; the dots drawn as circles in the app and emoji only
  in the shared text; `source` `challenge`, `challengeLink`, and `challengeWidget`, and
  `tapShareChallenge` with `level`; the dots read as a sentence by VoiceOver.
- **Departed from Konjugieren.** (1) **The person is drawn too.** Conjuguer's `QuizDraw` returns a
  verb and a tense, and the quiz's own decks choose the person, so `DailyChallenge.draw(for:)`
  draws each question's person, among those the verb's defect group has, from the same seeded
  generator. (2) **The share text takes the dots and points as one argument**, since SwiftLint
  allows five parameters. (3) **The seed lives on `WidgetQuizQuestion`** in `Shared/`, and the quiz
  widget's answer order now uses it in place of its own private copy of FNV-1a. (4) **The widget's
  wrong answers** follow Konjugieren's three (same tense, same person, any), and a finite question is
  offered no impératif or participle, which would stand out among its options; the existing filler
  verbs stay as the last resort. Both the question and the answered views open the challenge, since
  the question is no longer about the verb of the day. (5) **No verb widget's Next to change**:
  Conjuguer's quiz widget never paged. (6) **The fixtures do not apply**: the challenge is drawn
  before `-CONJUGUER_QUIZ_FIXTURE` is read, since its questions are already fixed by the day, and
  a fixture would break the widget's agreement with it. (7) **VoiceOver hears the result** through
  `Utterer` at the finish, as Phase 22 did for the streak, and the taken row reads the sentence alone
  rather than after "Done today:", which in French gave two colons in a row.
- **The widget's question ID** is now the day, the level, and the verb's key
  (`2026-11-24-intermediate-contracter`), so the answer the widget stores lasts the day unless the
  level changes, and `ConjuguerApp` rewrites the snapshots when the level changes.
- **Built as** `Models/DailyChallenge.swift` (`DailyChallenge`, its `Key`, `Outcome`, and draw;
  `DailyChallengeResult` with the share text and signal; `QuizScope.challenge(_:source:)`;
  `DailyChallengeRequest`), with `PracticeStore.challengeResults`, `Quiz.challengeResult`,
  `.challenge` in `LastQuizResult.Kind`, `World.challengeRequest` and `challengeKey(in:level:)`,
  `URL.challengeDeeplink`, `WidgetDeeplink.challenge`, `WidgetSnapshotWriter.quizQuestion(on:level:fallbackVerb:)`,
  and `ChallengeDots` in `QuizResultsView.swift`. Eight new strings.
- **Analytics.** Staged in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md)
  in both languages: the lifecycle bullet, the duration bullet (5 in the challenge), a taps bullet,
  and a paragraph after the practice record's saying the results stay on the device, survive Reset
  Practice, and go only where the learner shares them.
- **Tests:** 930 to 951, all passing through `run_tests.sh` (the iPhone simulator is in English).
  `DailyChallengeTests`, 12 functions: the seed pinned, a day round trip, six days that are not
  dates, the same key drawing the same five (4 levels), days and levels differing, twenty balanced
  days per level (cells, band, the verb having the cell, no verb twice, two core verbs, three
  irregular; 4 levels), a result's points and spoken line, the approved English text in full, the
  French date, the widget asking the challenge's first question for ten days (4 levels), the
  snapshot carrying it, and FNV-1a. Six nested in `QuizTests`: the same five whatever the seed, the
  learner's level, and the record; a result kept once and unranked, a second finish keeping the
  first; no re-ask; a quit keeping nothing; the store's twelve across a launch and a reset; and the
  signals. Three in `DeeplinkTests`, and `WidgetSnapshotWriterTests`' question ID test rewritten.
- **Verified on the iPhone 17**, light, at Intermediate. In French: the hub's row under the
  Daily Session; the widget's bundle for today asking contracter, vous, futur simple (wrong answers
  contractera, contractiez, contracte), and `quiz/challenge?source=challengeWidget` opening the
  challenge on the same question; a challenge of one right, a slip (implantes, diagnosed as the
  présent for tu) and its right second try, a wrong answer whose correction promised no re-ask, and
  two right, ending 35 with the dots, the level, and Partager le résultat; Copy in the share sheet
  giving the approved French text with its narrow spaces; the hub's row taken, "Relevé
  aujourd’hui : 35 / 50" over the dots, and Last Quiz naming the Défi du jour; a link to the taken
  challenge opening the hub, and one to the 20th at Advanced starting that challenge (aller, passé
  antérieur), quit, which wrote nothing. In English: the taken row, Copy from the row giving the
  approved English text, and Settings' level change rewriting the widget's question (Beginner asks
  retrouver, impératif, vous) and back. **On the iPad Pro 11**, in English and dark: the row at
  full width, a challenge from it opening on contracter as the iPhone's did, one right and four
  wrong ending 10, and Share Result's popover anchored to the button. Both simulators' defaults
  were restored afterward and compared key by key with copies made before. Not tried: the widget
  on a home screen (the bundle it reads was checked instead), a tap on it, VoiceOver by ear, two
  real devices, and a real midnight.
- **Josh asked for the commit** on 2026-11-24.

## Tasks for Josh Outside the Code

- **Leaderboards and achievements** in App Store Connect, by the walkthrough Phases 8 and 23 write,
  then a score posted from a development build, and on release day the new boards submitted and the
  old one archived.
- **Checks on his phone** the simulator cannot make: the Camera app opening a `conjuguer://` QR code
  (Phase 10), and anything a phase marks "not tried on a device".
- **A check on a Mac with Apple silicon**, once he has one: whether a `conjuguer://quiz/set` link
  clicked in Mail or Messages opens the iPad app running on the Mac (Phase 10). Apple's
  documentation does not say.

## Not Built

- **T1.1**, separable verbs: French has none.
- **T2.4**, weighting a newly opened tense: Josh said no for Konjugieren.
- **T4.6**, a language model wording a diagnosis: not applicable at this time. The Info tab's tutor
  stays apart from the quiz.
- **T6.9**, the arcade game: outside this project.
- **M4 and M5**, accuracy signals: Decision 5.

## Closing

**Status:** Not started.

- Run the full suite and `check_docs.py`.
- Audit the privacy staging: diff `Analytics.swift` against the commit before Phase 1, read every
  call site, and confirm that each new signal, parameter, and value has its lines in
  `docs/privacy_policy_pending.md` in English and French, and that none carries an answer, a count
  of right or wrong answers, or a verb (Decision 5).
- Confirm that `docs/feature_architecture.md` § Quiz describes the quiz as built.
- Write a short note for Konjugieren and Conjugar: anything this port found that the other apps
  should change. Put it in this section, not in their repositories.
- Mark this plan finished in its Status section.

**How it differed:**
