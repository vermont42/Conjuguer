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
| 1 | Not started | | | T1.3, T1.4, T1.5, and two Conjuguer defects | 1 |
| 2 | Not started | | | T1.2 | 2 |
| 3 | Not started | | | T4.1, T4.4, T4.5 | 3 |
| 4 | Not started | | | T1.6 | 4 |
| 5 | Not started | | | T2.3, T2.6, T6.7, M1 | 5 |
| 6 | Not started | | | T2.1, T2.2, T2.5 | 6 |
| 7 | Not started | | | T2.7, T3.1, T6.5, M2, M3 | 7 |
| 8 | Not started | | | Decision 4 | 8 |
| 9 | Not started | | | T2.8 | 9 |
| 10 | Not started | | | T2.9, Decision 8 | 10 |
| 11 | Not started | | | T3.3 (the record), T3.4, T3.5, T6.4 | 11 |
| 12 | Not started | | | T3.2, T3.3 (the session) | 12 |
| 13 | Not started | | | T6.1, T6.6 (the leaderboard's place) | 13 |
| 14 | Not started | | | T4.2, T4.3 | 14 |
| 15 | Not started | | | T5.1 | 15 |
| 16 | Not started | | | T5.2 | 16 |
| 17 | Not started | | | T5.4 | 17 |
| 18 | Not started | | | T5.5 | 18 |
| 19 | Not started | | | T5.6 | 19 |
| 20 | Not started | | | T6.2 | 20 |
| 21 | Not started | | | T5.7 | 21 |
| 22 | Not started | | | T6.3 | 22 |
| 23 | Not started | | | T6.6 (personal bests and achievements) | 23 |
| 24 | Not started | | | T6.8 | 24 |
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

Expected names, from the browse plan as written. The browse plan's Closing corrects this list;
trust its notes over this section.

- **Matching.** The browse plan's search function folds accents, which is right for search and
  wrong for grading (it would accept parle for parlé). Grading needs its own comparison.
- **Edit distance**, if browse Phase 2's guess uses one (Konjugieren's `VerbSearch.editDistance`,
  optimal string alignment). Phase 4 needs it.
- **Which cell is this text?** `Verb.conjugations(matching:)` (browse Phase 4), exact cells only.
  Phases 4 and 14 call it first on a wrong answer.
- **The conjugation map** in the bundle (browse Phase 4). Phase 17 reads it.
- **Key conjugations** (browse Phase 8): the il présent, il passé composé, and il futur simple
  ("vient · est venu · viendra"), as Josh decided on 2026-11-22. Phases 11 and 15 use them.
- **The accent key row** (browse Phase 1), with an `insert` closure. Phase 1 puts it on the answer
  field.
- **Scopes.** `QuizScope` with `.allVerbs`, `.myVerbs`, `.verbPage`, and `.collection`, an
  `isRanked` rule, and a quiz sheet for Test Me and collections (browse Phases 11 and 14).
- **Bands and collections.** `FrequencyBand` and `Verb.isIn(_:)` (browse Phase 12); collections,
  including models if Josh chose them (browse Phase 14).
- **A due date per verb.** `ReviewSchedule` on the learner's record, driving the review card
  (browse Phase 13). Phase 11 folds it into the practice record.
- **Related verbs and bases** (browse Phase 7). Phase 6's "derivative verbs" reads them.
- **Thirty is wired in.** The question count gates the Live Activity, the tip donation, the time
  bonus, and ranking. Phases 5, 7, and 8 revisit each.

## Phase 1: Accept What Is Right, Ask What Exists

**Suggestions:** T1.3, T1.4, T1.5, and two Conjuguer defects. **Ports:** Konjugieren Phase 1
(`AnswerSpelling.swift`, `StandardVariants.swift`,
[`../Konjugieren/plans/pedagogy_phase1_variant_audit.md`](../../Konjugieren/plans/pedagogy_phase1_variant_audit.md)).
**Depends on:** browse Phase 1 for the key row. **Status:** Not started.

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

## Phase 2: The Shape of the Answer

**Suggestions:** T1.2. **Ports:** Konjugieren Phase 2 (`AnswerFrame.swift`,
`AnswerFrameView.swift`). **Depends on:** Phase 1. **Status:** Not started.

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

## Phase 3: A Correction That Stays

**Suggestions:** T4.1, T4.4, T4.5. **Ports:** Konjugieren Phase 3 (`QuizCorrectionView.swift`,
`AnswerDifference.swift`). **Depends on:** nothing; Phase 2 preferably. **Status:** Not started.

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

## Phase 4: One More Try

**Suggestions:** T1.6. **Ports:** Konjugieren Phase 4 (`AnswerSlip.swift`). **Depends on:**
Phase 3. **Status:** Not started.

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

## Phase 5: Levels

**Suggestions:** T2.3, T2.6, T6.7, M1. **Ports:** Konjugieren Phase 5 (`QuizLevel.swift`,
`QuizDraw.swift`). **Depends on:** Phase 1. **Status:** Not started.

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

## Phase 6: Which Verbs Are Asked

**Suggestions:** T2.1, T2.2, T2.5. **Ports:** Konjugieren Phase 6. **Depends on:** Phase 5.
**Status:** Not started.

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

## Phase 7: Ten Questions, Then Ten More

**Suggestions:** T2.7, T3.1, T6.5, M2, M3. **Ports:** Konjugieren Phase 7 (`QuizClock.swift`,
`QuizAbandonment.swift`). **Depends on:** Phases 3 and 5. **Status:** Not started.

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

## Phase 8: Leaderboards by Level

**Suggestions:** Decision 4. **Ports:** Konjugieren Phase 8
([`../Konjugieren/docs/game_center_setup.md`](../../Konjugieren/docs/game_center_setup.md)).
**Depends on:** Phases 5 and 7. **Status:** Not started.

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

## Phase 9: Choosing What to Practice

**Suggestions:** T2.8. **Ports:** Konjugieren Phase 9 (`CustomQuiz.swift`, `CustomQuizView.swift`).
**Depends on:** Phases 5 and 6. **Status:** Not started.

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

## Phase 10: Practice Sets to Share

**Suggestions:** T2.9, Decision 8. **Ports:** Konjugieren Phase 10 (`PracticeSet.swift`,
`PracticeSetView.swift`, `QRCode.swift`). **Depends on:** Phase 9 and browse Phase 9's grammar.
**Status:** Not started.

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

## Phase 11: The Practice Record

**Suggestions:** T3.3 (the record), T3.4, T3.5, T6.4. **Ports:** Konjugieren Phase 11
(`PracticeRecord.swift`, `PracticeItemMapping.swift`, `PracticeStore.swift`,
`QuizRecordSession.swift`). **Depends on:** Phase 7. **Status:** Not started.

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

## Phase 12: Review and My Mistakes

**Suggestions:** T3.2, T3.3 (the session). **Ports:** Konjugieren Phase 12 (`QuizDueItems.swift`).
**Depends on:** Phase 11. **Status:** Not started.

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

## Phase 13: The Practice Hub

**Suggestions:** T6.1, T6.6 (the leaderboard's place). **Ports:** Konjugieren Phase 13
(`LastQuizResult.swift`). **Depends on:** Phases 7, 8, 11, and 12. **Status:** Not started.

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

## Phase 14: Naming the Error

**Suggestions:** T4.2, T4.3. **Ports:** Konjugieren Phase 14 (`AnswerDiagnosis.swift`).
**Depends on:** Phases 3 and 4; Phase 2 for the frame. **Status:** Not started.

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

## Phase 15: Key Conjugations

**Suggestions:** T5.1. **Ports:** Konjugieren Phase 15 (`VerbEssentials.swift`,
`VerbEssentialsRowView.swift`). **Depends on:** Phases 2 and 11. **Status:** Not started.

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

## Phase 16: Models, One Then Mixed

**Suggestions:** T5.2. **Ports:** Konjugieren Phase 16 (`AblautPractice.swift`,
`AblautPracticeCard.swift`, `AblautPracticeListView.swift`). **Depends on:** Phases 11 and 15.
**Status:** Not started.

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

## Phase 17: Recognition

**Suggestions:** T5.4. **Ports:** Konjugieren Phase 17 (`Recognition.swift`,
`RecognitionChoicesView.swift`). **Depends on:** Phase 3 and browse Phase 4's map. **Status:** Not
started.

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

## Phase 18: Sentences with a Blank

**Suggestions:** T5.5. **Ports:** Konjugieren Phase 18 (`GapSentence.swift`,
[`../Konjugieren/plans/gap_sentences_batch_1.md`](../../Konjugieren/plans/gap_sentences_batch_1.md),
[`../Konjugieren/plans/gap_sentences_batch_2.md`](../../Konjugieren/plans/gap_sentences_batch_2.md)).
**Depends on:** Phases 2 and 3. **Status:** Not started.

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

## Phase 19: Which Tense Would a Speaker Use?

**Suggestions:** T5.6. **Ports:** Konjugieren Phase 19 (`ChoiceQuestion.swift`,
`ChoiceQuestionView.swift`, [`../Konjugieren/plans/choice_questions_batch_1.md`](../../Konjugieren/plans/choice_questions_batch_1.md)).
**Depends on:** Phase 18 for its content pipeline. **Status:** Not started.

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

## Phase 20: Mastery

**Suggestions:** T6.2. **Ports:** Konjugieren Phase 20 (`Mastery.swift`, `MasteryView.swift`).
**Depends on:** Phases 5, 11, and 13. **Status:** Not started.

Show mastery: the core verbs and patterns against the tenses of the current level, filling in as
items move up the ladder. The report warns that progress displays are unproven for persistence, so
keep it modest. Patterns fill together across their verbs, which is honest but should look
intended.

**Ask Josh** to choose between a grid and a display that separates patterns from irregular verbs,
from mockups, and where it lives in the hub.

**Done when** the display reflects the record under test and Josh has judged it on a device-sized
screen.

**How it differed:**

## Phase 21: Speed Round

**Suggestions:** T5.7. **Ports:** Konjugieren Phase 21 (`SpeedRound.swift`). **Depends on:**
Phases 11 and 20. **Status:** Not started.

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

## Phase 22: A Daily Session and a Streak

**Suggestions:** T6.3. **Ports:** Konjugieren Phase 22 (`DailySession.swift`, `DailyStreak.swift`,
`DailyReminder.swift`, `ReminderSchedulerReal.swift`). **Depends on:** Phases 11, 12, and 13.
**Status:** Not started.

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

## Phase 23: Personal Bests and Achievements

**Suggestions:** T6.6 (personal bests and achievements). **Ports:** Konjugieren Phase 23
(`Achievement.swift`). **Depends on:** Phases 8, 20, and 22. **Status:** Not started.

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

## Phase 24: The Daily Challenge

**Suggestions:** T6.8. **Ports:** Konjugieren Phase 24 (`DailyChallenge.swift`). **Depends on:**
Phases 5 and 22. **Status:** Not started.

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

## Tasks for Josh Outside the Code

- **Leaderboards and achievements** in App Store Connect, by the walkthrough Phases 8 and 23 write,
  then a score posted from a development build, and on release day the new boards submitted and the
  old one archived.
- **Checks on his phone** the simulator cannot make: the Camera app opening a `conjuguer://` QR code
  (Phase 10), and anything a phase marks "not tried on a device".

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
