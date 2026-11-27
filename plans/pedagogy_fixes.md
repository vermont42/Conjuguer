# Plan: Fix What the Pedagogy Review Found

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
quiz logic, grading, the practice record, a little authored French content, analytics, staged
privacy text, localized strings, tests, and prose. **Written:** 2026-11-27, in answer to
[`prompts/pedagogy_review.md`](../prompts/pedagogy_review.md). Josh answered its twenty-three
decisions the same day, and each answer is recorded under its decision.

This file is both the review and the plan. There is no separate review document, so the findings
are here in full: each has a label, its file and line, its evidence, how it was verified, and a
suggested fix. The phases at the end cite findings by label.

**Subject:** the code that [`plans/pedagogy_implementation.md`](pedagogy_implementation.md)
built from [`../Konjugieren/docs/pedagogy_research.md`](../../Konjugieren/docs/pedagogy_research.md),
in 24 phases and a Closing, from `5bd3650` (the commit before Phase 1) through `bd06478`.
**Reviewed at:** `945e5e9`, so the review covers the code as it stands on `main`, including what
[`verb_browse_fixes.md`](verb_browse_fixes.md) changed afterward. Nothing was fixed.
**Line numbers are those of `945e5e9` and will drift as phases land, so find code by the type
and function each finding names.**

## Status

Each session that finishes a phase fills in its row, then writes a **How it differed** note
under that phase's heading. **Every phase waits for Josh before git.** A finished phase is
"Awaiting Josh", with the Commit cell empty, until he has tried the change and said to commit.

| Phase | Status | Date | Commit | Findings | Decisions, all answered 2026-11-27 |
|---:|---|---|---|---|---|
| 1 | Not started | | | T1, T7 | None |
| 2 | Not started | | | L15, L18, F2 (the stripping), F3, F8, F10, C4, G4 | None. Josh reviews one new line |
| 3 | Not started | | | F4, F7, F9, F11, F12, F13, F2 (the frame) | D8, D9, D10. Josh reviews the new lines and the six verbs |
| 4 | Not started | | | L1, L2, F6 (the record), F19 | D1, D2, D6 |
| 5 | Not started | | | L3, L4, L5, L17, P6 | D3, D4, D5. Josh reviews two lines |
| 6 | Not started | | | F1, F5, F17, F18, F20, L9, L16 | D12, D13, D23. Josh approves the weights |
| 7 | Not started | | | F6 (the exercises), L11 | D7, D16 (d). Josh reviews the list of verbs |
| 8 | Not started | | | L6, L7, L8, T2, F14, F15 | D11 (a) to (c), D14, D15, D16 (a), (b). Josh reviews the items |
| 9 | Not started | | | F16, F21, L19 | D11 (d). Josh reviews the redrafts |
| 10 | Not started | | | L10, L12, L13, C5, C6, C7, T6 | D16 (c), D17. Josh reviews one line |
| 11 | Not started | | | C1, S2, I2, C10 (the hub's) | None |
| 12 | Not started | | | C2, C3, C9, L14, C10 (the link's) | D19, D20, D21 |
| 13 | Not started | | | P1, P2, P3, P5, C10 (a link's source) | D18 (a), (b), (d) |
| 14 | Not started | | | P4, P7, P8, G1, G2, G3 | D18 (c). Josh reads the staged text |
| 15 | Not started | | | I1, I3, I4, I5, I6 | D22. Josh reviews every line |
| 16 | Not started | | | S1, S3, S4, C8, C10 (the rest) | None |
| 17 | Not started | | | T3, T4, T5, T8, T9 | None |
| Closing | Not started | | | The audit | None |

## Verdict

The port is sound in its construction. The tree is green: `run_tests.sh` reports 1,077 tests in
100 suites passed, on Conjuguer's iPhone simulator with its language confirmed as English, and
`check_docs.py` reports 0 problems. No finding is a crash or a loss of data that a learner would
meet. The draw is deterministic and well tested, Decision 5 holds for what every signal
carries, every added string is in both languages with French punctuation, and the phase notes
are honest about what a session decided without Josh, which is what made most of the findings
below findable.

The findings are of two kinds. **The first kind came over from Konjugieren with the design**:
each feature was built to its phase, and a later phase changed what an earlier one meant. The
second attempt was built for a typing slip and then given to grammatical errors. The box of the
ladder was built to schedule reviews and then read as mastery, achievements, and the Speed
Round's entry. The re-ask was built before My Mistakes existed. **The second kind is French**:
places where a design that fits German was carried over and does not fit, or where correct
French is graded wrong. Nine things deserve attention before the 2027 release, in this order:

1. **My Mistakes is emptied by the quiz's own re-ask** ([L1](#l1)). A missed question returns
   three questions later with its answer just shown, and a right answer there takes the miss off
   the list.
2. **A real error, once repaired, counts as known** ([L2](#l2), [L15](#l15)). "ai allé", then
   "suis allée" after being told aller takes être, moves the item up the ladder. "a prit" for a
   pris and "j'ai finit" are called typing slips.
3. **The default quiz never asks the subjonctif of faire, pouvoir, savoir, vouloir, devoir,
   venir, or prendre** ([F1](#f1)), at any level, in 1,200 seeded rounds.
4. **Key conjugations are il forms, and French does not hang on them** ([F6](#f6)). After a
   miss on "vous faites", My Mistakes asks "il fait". "J'allais" and "allant" master "il va". A
   model whose mark is a second présent stem becomes "Known" without it.
5. **Mastery can be reached without typing** ([L3](#l3)), by two taps on the review card, **and
   is erased by opening a verb's page** ([L4](#l4)), the correction's own link included.
6. **Correct French is graded wrong**: "que je parle" ([F2](#f2)), "vous êtes allée"
   ([F7](#f7)), "elles se sont complu" ([F4](#f4)), "manoeuvre" ([F9](#f9)), and, in the choice
   questions, "Victor Hugo est né à Besançon en 1802" ([F14](#f14)). And **wrong French is
   graded right**: "j'absout" ([F3](#f3)), "je ai parlé" ([F11](#f11)).
7. **The quiz asks forms French lacks**: "il a sis" ([F5](#f5)) and "elles s'ont été bilées"
   ([F20](#f20)).
8. **A question count can name the verb** ([P1](#p1)): a five-question quiz from a model's page
   at Beginner is clore's, and no test would catch a signal that began to carry a verb or a
   score ([P5](#p5)).
9. **Some tests pass because of their seed or their order** ([T1](#t1), [T3](#t3),
   [T4](#t4)): one leaves overdue items in a record that the strongest suites then read, four
   would pass with their guarantee deleted, and eleven cannot fail for what their names claim.

The rest is edge cases, a hub that does not notice midnight, links that close a quiz in
silence, French wording, staged prose that the code has made untrue, and two files that have
grown past what one reader can hold. There are 81 findings: 21 on French, 19 on what the
learner is taught, 10 on correctness, 8 on privacy, 6 on interface text and VoiceOver, 4 on
gaps and docs, 4 on structure, and 9 on tests.

## Method

I read `Quiz.swift`, the grader (`ConjugationResult`, `AnswerSpelling`, `AnswerSlip`,
`StandardVariants`, `AnswerFrame`), the practice record (`PracticeRecord`, `ReviewSchedule`,
`PracticeStore`, `PracticeItemMapping`), the draw (`QuizDraw`, `QuizLevel`, `QuizDueItems`,
`QuizRecordSession`), the daily challenge, and the streak myself, with the plan's decisions and
the notes of the phases that built them. Eight Opus subagents each reviewed one slice
independently, with no view of my notes or of each other's: grading and the correction; the
quiz's core and levels; custom quizzes, shared sets, and the hub; the record and mastery; the
new kinds of question, including a read of the authored French; the Speed Round, the daily
session, achievements, and the challenge; analytics, privacy, localization, and VoiceOver; and
the tests as a body. I then ran or re-read the code behind every finding of theirs that I ranked
above Low. Each finding carries one of these labels:

| Label | Meaning |
|---|---|
| **Run** | Confirmed by running code: a temporary probe suite of 20 tests (since deleted), or Python over the bundled JSON and `verbs.xml`, mine or a reviewer's as the finding says. |
| **Read** | I traced it in the code myself. |
| **Reviewer** | A subagent reported it with file and line. I did not re-trace it. |
| **Suspected** | Plausible from the code, with the unchecked step named. |

What ran: the full suite as a baseline, and the probe suite, which graded some forty answers,
drew 1,200 seeded rounds, drove quizzes through a miss and its re-ask, a repaired diagnosis, and
an empty Return, moved items through the record with injected dates, and grouped every model by
the length of its quiz. Nineteen of its twenty suspicions held. The twentieth was a detail of a
reviewer's claim: "parle !" is not called a slip, it is graded wrong outright, which is worse.

Konjugieren's review, [`../Konjugieren/plans/pedagogy_fixes.md`](../../Konjugieren/plans/pedagogy_fixes.md),
was not opened until every finding of this one was written down. Three more Opus subagents then
checked each of its 62 findings against Conjuguer's code, and
[the comparison](#konjugierens-findings-checked-here) says which carried over. That pass added
ten findings this review had missed, each then run or read here: [L15](#l15), [L16](#l16),
[L17](#l17), [L18](#l18), [L19](#l19), [P3](#p3), [P4](#p4), [P6](#p6), the one-verb model's
count in [P1](#p1), and the recent lookups in [C9](#c9).

**Not covered:** the app was not launched. Every finding here comes from code and probes, so
layout, VoiceOver by ear, a real device, a real day passing, and a first launch were not
examined, and the findings that turn on them are marked Suspected. A reviewer read every one of
the 66 choice items, all 71 subjonctif sentences, the 56 compound, participle, and passé simple
sentences, and 140 others drawn at random. The other 480 or so sentences were checked by script
and not read for idiom. `GameCenterReal`'s threading was read only at its call sites.

## What Holds Up

So that a later session knows what was examined and found sound:

- **Grading.** Pronoun stripping never accepts another person's pronoun ("tu parle" for je is
  wrong). Whitespace of every kind collapses, and the typographic apostrophe is folded. The
  circumflex's exceptions hold: fut and fût, du and dû, cru and crû, and jeune are each still
  wrong for the other, and â is never touched, so parla is never taken for parlât. The list of
  -eler and -eter verbs that keep their traditional è is complete against `verbs.xml`. A slip is
  never another cell of the verb. The second attempt shows only its one line, and a question
  gets one second attempt at most.
- **Agreement with être** is the same in the frame, the grade, the diagnosis, the correction,
  the results, and VoiceOver, for je, tu, nous, and vous under each setting. [F7](#f7) and
  [F4](#f4) are about what French allows, not about these disagreeing.
- **Defective and impersonal verbs.** Unlike Konjugieren, Conjuguer's data marks the cells a
  verb lacks, and every draw reads it: pouvoir's impératif, falloir outside il, and the weather
  verbs' other persons are never asked, in any quiz, the challenge, or the widget.
  [F5](#f5) and [F20](#f20) are the two holes. (Devoir's impératif, "dois", is asked. Tables
  list it, and it is rare.)
- **The ladder.** A right answer climbs only when due, a wrong one restarts, and no item can
  climb twice in a day. Due dates are calendar days, so a change of the clocks is one day.
- **The re-ask's bookkeeping.** It is inserted once, scored 5, and left out of every count that
  must not include it, `questionReached` among them, so the Closing's privacy fix holds.
- **Rounds.** No draw loops forever, a scoped round never repeats a cell while others remain,
  and Ten More and the draw agree on what is askable. Konjugieren's "a round can ask the same
  question twice" did not carry over.
- **Ranking.** What posts is the first ten questions of a default quiz's first round, to the
  board of the level fixed at the start. Nothing else posts.
- **The streak**, through consecutive days, a missed day with one and with two sessions, two
  missed days, and a clock set back. Its day keys are floating dates, so a change of time zone
  does not move them.
- **The reminder.** Permission is asked only on turning it on, a refusal leaves it off, a done
  day gets none, and a tap opens the daily session.
- **Achievements** reward mastery and not volume or speed, none can be lost by reinstalling,
  and their IDs and points match the setup doc.
- **Analytics.** No signal sends typed text, an answer, a score, a count of right or wrong
  answers, a verb, or a model's id, and every signal, key, and value is staged in both
  languages.
- **Determinism inside a process.** No `Set` or `Dictionary` order reaches a seeded draw, and
  `SeededRandomNumberGenerator` is SplitMix64 with the standard constants.
- **Content, mechanically.** 750 sentences and 66 choice items with unique ids, every blank the
  conjugator's form for its cell with accents exact, every être compound gendered and agreeing
  with its visible subject, no elision error at a blank, and U+202F throughout.
- **Localization.** All 284 added keys are translated, with matching specifiers and consistent
  vouvoiement.

## Findings

Severity is my judgment: **High** is wrong behavior a learner would meet often or a promise
broken, **Medium** is wrong in a case a learner will meet sooner or later or a real hazard for
maintenance, and **Low** is an edge case or tidying. The label before it says how the finding was
verified ([Method](#method)).

## French Against What the Quiz Asks and Accepts

These are the places where a German design, or a rule written for the whole table, does not fit
French: forms the quiz asks that French lacks, forms it never asks though French turns on them,
correct French graded wrong, and wrong French graded right.

<a id="f1"></a>
### F1. The default quiz never asks the subjonctif présent of faire, pouvoir, savoir, vouloir, devoir, venir, or prendre (Run, High)

`QuizTenseSlot.verbPools` (`QuizLevel.swift:203-220`) gives the subjonctif présent four pools:

```swift
case .subjonctifPrésent:
  return [.regularEr, .regularIr, .regularRe, .bigThree]
```

`regularRe` is rendre's model and `bigThree` is être, avoir, and aller, so no pool admits any
other third-group verb. The indicatif présent has `.indicatifPrésentStemChanger` and the futur
has `.irregularRadicalFutur`. The subjonctif has nothing of the kind. Phase 5's note says "the
pools keep Regular's structure", and Phase 6 turned the curated lists into rules without adding
one.

The probe drew 600 seeded rounds at Intermediate and 600 at Advanced through
`QuizDraw.questions(level:count:asked:using:)`. Of 1,032 subjonctif présent questions, the only
irregular models asked were aller's (1-9), avoir's (4-10), rendre's (5-1A), and être's (5-26).
Fasse, puisse, sache, veuille, doive, vienne, prenne, dise, voie, mette, tienne, boive, and
reçoive were never asked. These are the forms a learner of the subjonctif most needs, and five of
them belong to the eight core verbs that T2.5 says should recur. The two core questions of a
round can never be a subjonctif of faire, pouvoir, vouloir, devoir, or savoir, since no pool of
the slot admits them (`admits(slots[$0], role: .core)` in `QuizDraw.questions`).

The passé simple and the subjonctif imparfait have a weaker form of the same gap: their pools
are `[.regularEr, .regularIr, .regularRe, .bigThree, .irregularParticipePassé]`, which stands in
for "an irregular passé simple stem" by the participle. A verb with a regular participle and an
irregular passé simple is outside every pool. The implementing session should list which verbs
that leaves out before deciding whether to add a trait.

**Fix.** Give `QuizVerbTraits` a `hasIrregularSubjonctifPrésent`, read from the conjugator's
capitals as the other three traits are, and add an `.irregularSubjonctifPrésent` pool to the
slot, weighted so that roughly a third of subjonctif questions take it. Check the passé simple
the same way. The daily challenge draws through the same pools, so its questions change on the
day this lands ([T2](#t2)).

<a id="f2"></a>
### F2. "que je parle" is graded wrong (Run, Medium)

`AnswerSpelling.candidates(for:tense:isReflexive:)` (`AnswerSpelling.swift:75-100`) strips a
subject pronoun of the asked person and a reflexive pronoun. It knows nothing of que. French
conjugation tables, Bescherelle's included, print every subjonctif with it ("que je parle",
"qu'il ait parlé"), and francophone learners, who are most of Conjuguer's users, type it from
habit. Search already strips it: `ConjugationQuery.swift:36` lists `"que", "qu'"` among the words
it drops.

The probe graded "que je parle" for parler's subjonctif présent, je: `.noMatch`, and not a slip,
so it goes straight to the held correction with "que je " struck through, is recorded as a miss,
and is re-asked. "qu'il parle" is the same. The frame shows `je ______` with no que
(`AnswerFrame.quizFrame`, `AnswerFrame.swift:54-75`), so nothing tells the learner to leave it
out. T1.3's aim was to stop marking correct German wrong for the words around the conjugation.
This is the French case of it.

**Fix.** For the four subjonctif tenses, strip a leading "que " or "qu'" before the subject
pronoun. Pin "que je parle", "qu'il parle", "que j'aie parlé", and "qu'elles se souviennent".
Whether the frame should show `que je ______` is [D8](#d8).

<a id="f3"></a>
### F3. "j'absout" and "tu dissout" are graded right (Run, Medium)

`StandardVariants.rectifiedSpelling` (`StandardVariants.swift:158-166`) writes the 1990
participles absout and dissout by rewriting any word that ends in "sous":

```swift
case "absoudre", "dissoudre":
  let words = conjugation.split(separator: " ").map { word in
    word.hasSuffix("sous") ? word.dropLast() + "t" : word
  }
```

It takes `tense` and does not look at it. The présent's je and tu and the impératif's tu are
also "absous" and "dissous", and "absout" is il's form. The probe graded "dissout" for
dissoudre's indicatif présent je, its tu, and its impératif tu, and "absout" for absoudre's:
all six `.totalMatch`, each shown as "Correct. Also spelled: dissous". The audit's own row
(`plans/pedagogy_phase1_variant_audit.md`, R5) says "Accept, in the participe passé and every
compound tense".

**Fix.** Apply the rewrite only when `tense == .participePassé || tense.isCompound`, and add the
six cells to `StandardVariantsTests.rejectsNonVariant`.

<a id="f4"></a>
### F4. Three pronominal verbs are expected with an agreement French does not make, and the diagnosis teaches it (Run, Medium)

`Conjugator.conjugate` agrees the participle of every verb that is reflexive or takes être
(`Conjugator.swift:189-191`):

```swift
if verb.isReflexive || verb.auxiliary == .être {
  let agreementEnding = pronounGender.participePasséEndingForPersonNumber(personNumber)
```

`verbs.xml` marks complaire, entre-nuire (and its spelling entrenuire), and arroger reflexive. In
se complaire and s'entre-nuire the pronoun is an indirect object (complaire à, nuire à), so the
participle never agrees: "elles se sont complu", "ils se sont entre-nui". The probe asked the
conjugator for the passé composé, elles, feminine: "sont complues", "sont entre-nuies", and
"sont arrogées". A learner who types the correct "elles se sont complu" is graded wrong and
told, by `AnswerDiagnoser.agreement` (`AnswerDiagnosis.swift:228-234`), that with être the
participle agrees with the subject. The grade, the frame's "(fém.)", the diagnosis, and the
correction agree with one another and are all wrong for these verbs. The verb page prints the
same forms, which is outside this review's scope but has the same cause.

S'arroger is a different case: its participle agrees only with a direct object placed before it
("les droits qu'elle s'est arrogés", but "elle s'est arrogé des droits"), and conjugation tables
print it invariable.

**Fix.** A small set of pronominal verbs whose participle does not agree with the subject, read
by the conjugator's agreement step and by `AnswerDiagnoser.agreement`. This plan's default puts
complaire, entre-nuire, entrenuire, and arroger in it, arroger because tables print it so. Josh
may overrule that. The file is one of the 25 that `ConjugationMapTool` compiles, so the set must
not reach `Current`.

<a id="f5"></a>
### F5. The quiz asks compound tenses of seoir, messeoir, and paître, which have none (Run, Medium)

`defectGroups.xml` marks the participe passé unused for groups 18 (seoir, messeoir) and 20
(paître), with the code `pp`. `DefectGroup.init` (`DefectGroup.swift:19`) turns `pp` into
`.participePassé` alone, so every compound tense still counts as a cell the verb has. The probe:

| Verb | `hasCell(.participePassé)` | A compound cell | The answer expected |
|---|---|---|---|
| seoir | false | `hasCell(.passéComposé(.thirdSingular))` is true | "a sis" |
| messeoir | false | the same | "a messis" |
| paître | false | `hasCell(.plusQueParfait(.firstSingular))` is true | "avais pu" |

`QuizVerbPool.irregularParticipePassé` admits all three, so the Advanced default quiz can draw
them for any of nine compound tenses, and Test Me on seoir's page asks "il a sis" whenever it
draws the passé composé. `QuizTests.noSeededQuizAsksADefectiveCell` cannot see this, since it
checks `verb.hasCell(question.tense)`, the predicate the draw itself uses ([T4](#t4)).

**Fix.** In `DefectGroup.init`, when the participe passé is unused, mark every compound tense
unused in every person. Only groups 18 and 20 change. Check that the verb page's strike-through
follows, since it reads the same group. Add a test that names seoir and paître.

<a id="f6"></a>
### F6. Key conjugations are the il forms, which in French do not carry the verb (Run, Medium)

Konjugieren's key conjugations are a strong verb's principal parts, and in German they do carry
the verb: the present's vowel change shows in the third person, and the Präteritum and the
participle give the rest. Conjuguer's are "vient · est venu · viendra" (`Verb.keyTenses`, from
`PracticeItem.Stem.keyTense`, `PracticeItemMapping.swift:125-136`). The il form of the présent
does not give a French verb's other présent stems: boit beside buvons and boivent, vient beside
venons and viennent, fait beside faites and font, plaint beside plaignons. The doc comment on
`Verb.keyConjugations()` (`KeyConjugations.swift:11`) says the three forms "let a learner rebuild
most of a verb", which is not true of these verbs. Three things follow from it.

- **My Mistakes and Review ask the il form, whatever was missed.** `PracticeItem.exercised(by:of:)`
  files every présent, imparfait, subjonctif présent, impératif, and participe présent cell of an
  irregular verb under one item, `key:faire:present`, and `QuizDraw.sessionQuestions`
  (`QuizRecordSession.swift:99-105`) asks an item's `tense`, which is `stem.keyTense`. The probe
  recorded a miss on "vous faites" and drew My Mistakes: one question, faire's il présent. A
  learner who cannot write faites, dites, sommes, or vont is asked fait, dit, est, and va, gets
  them right, and the mistake is cleared. Phase 11's note names the cost in one direction ("a
  slip in nous venions counts against vient"). It does not say that the mistake is never asked
  again.
- **A right answer on the il form raises the item for the whole stem.** "il boit" answered right
  when due moves `key:boire:present` up a box, and at the third box Mastery shows boire's présent
  as mastered, though buvons and boivent were never asked. The reverse also holds: the probe
  answered aller's "j'allais" right and, three days later, its participe présent "allant", and
  `key:aller:present`, which the page shows as "il va", was in box 2, mastered, with va, vais,
  and vont never written. "venu" answered twice does the same for "est venu", though a bare
  participle never asks the auxiliary. This is Konjugieren's L5 in its French form, where it is
  wider, because more French verbs have a présent the il form does not show.
- **Verb Essentials and a model's practice never reach the second stem.**
  `QuizDraw.verbEssentialsStep(verb:)` (`VerbEssentials.swift:72`) asks `Verb.keyTenses` and
  nothing else, and a third-group model is practiced through Verb Essentials
  (`ModelPractice.items`, `ModelPractice.swift:62`). So practicing plaindre's model alone (5-12,
  29 verbs) asks fifteen blanks shaped like plaint, a plaint, and plaindra, and the model becomes
  "Known" without the gn stem that defines it. Conduire's (5-9A), écrire's (5-7), connaître's
  (5-20), dire's (5-8A), boire's (5-17), croire's (5-18), devoir's (4-2A), and recevoir's (4-2B)
  are the same. T5.2's aim, practice a group's pattern alone before mixing, is not met for them.

Josh chose the three key conjugations on 2026-11-22 and "verb by verb" for the third group on
2026-11-23. Neither ruling is questioned here. What is new is what reads them.

**Fix.** See [D6](#d6) for the record and [D7](#d7) for the exercises. Correct the doc comment
either way.

<a id="f7"></a>
### F7. "vous êtes allée", said to one person, is graded wrong (Run, Low)

`PronounGender.participePasséEndingForPersonNumber` (`PronounGender.swift:15-41`) makes vous
always plural, and the frame shows `vous (fém.)` with no number (`AnswerFrame.swift:59-60`).
French uses vous for one person, and then the participle is singular: "Madame, vous êtes
allée". The probe graded "vous êtes allée" for aller's passé composé, vous, under the feminine
default: `.noMatch`. The learner is then told the participle agrees, "here feminine plural",
which the frame never said. Nous has no such reading.

**Fix.** See [D9](#d9).

<a id="f8"></a>
### F8. The 1990 futur of léguer's kind is called a typing slip (Run, Low)

`StandardVariants.withGraveInFuturStem` (`StandardVariants.swift:126-154`) looks for an é
followed by consonants and then "er". Its vowel set holds u, so in "léguerai" the scan stops on
the u of gu and never finds the "er". The rectified spellings je lèguerai, il délèguerait,
j'hypothèquerai, and nous dissèquerions are therefore not accepted. The probe graded "lèguerai":
`.noMatch`, and a slip, so the learner sees "Almost! Try once more." for a correct spelling.
Eleven verbs, all of model 1-5: alléguer, déféquer, déléguer, déshypothéquer, disséquer,
hypothéquer, léguer, reléguer, réséquer, ségréguer, subdéléguer (a reviewer's script over
`verbs.xml`).

**Fix.** Treat gu and qu as consonants in the scan, and add léguer and hypothéquer to
`StandardVariantsTests.acceptsVariant`.

<a id="f9"></a>
### F9. "manoeuvre" is graded wrong, and the quiz's keys lack œ and ï (Run, Low)

`FrenchLetterKeyRow.letters` (`FrenchLetterKeyRow.swift:13-15`) leaves out ï and œ "because
search folds them (hair finds haïr)". Phase 1 put the same row on the quiz's answer field, and
the quiz does not fold. Haïr needs ï in most of its cells (haïssons, haï), and œuvrer,
manœuvrer, and écœurer need œ. "oe" is the usual fallback on a computer keyboard. The probe
graded "manoeuvre" for manœuvrer: `.noMatch` and not a slip, since the ligature is two edits
away and `folding(.diacriticInsensitive)` does not split it.

**Fix.** See [D9](#d9) for whether "oe" is right. Either way, show ï and œ in the row where the
quiz shows it.

<a id="f10"></a>
### F10. Typing the frame's own "!" makes an impératif wrong (Run, Low)

The impératif's frame ends in `.punctuation("!")` (`AnswerFrame.swift:69`), and
`AnswerSpelling.normalized` keeps punctuation. The probe graded "va !" and "parle !": both
`.noMatch`, and neither a slip, so each goes to the correction as a miss and is re-asked.
`AnswerFrameTests` types the frame's pronoun and reflexive suffix into the blank and never its
punctuation. Konjugieren's L21 is the same defect, and its plan's default was to forgive the
frame's own word.

**Fix.** Strip a trailing "!" or "." and the spaces before it in `normalized`, and extend the
frame test to type the `.punctuation` segment. This plan's default is to forgive it, as
Konjugieren's does.

<a id="f11"></a>
### F11. Pronoun stripping accepts French that is wrong (Run, Low)

`AnswerSpelling.subjectPronouns` returns both "je " and "j'" whatever follows, a reflexive
pronoun is stripped when present and never required, and any third-person pronoun matches. The
probe: "je ai parlé", "j'parle", and "il est allée" are each `.totalMatch`. A reviewer traced
"je souviens" for je me souviens and "il se est souvenu" to the same result. Phase 1's note
accepts the third-person case on purpose. The others teach a wrong form silently to a learner who
took the trouble to type the pronoun, and no test pins either behavior.

**Fix.** See [D10](#d10). `PersonNumber.elides(before:hasAspiratedH:)` already decides elision
for the frame.

<a id="f12"></a>
### F12. A participe passé question calls "allée" a typing slip (Run, Low)

The participe passé's frame is a bare blank with no gender, and the default setting is feminine.
`Verb.conjugations(matching: "allée")` returns the participe passé with `isAgreement: true`
(`ConjugationMatch.swift:40-41`), so `AnswerSlip.isSlip` (`AnswerSlip.swift:43-45`) finds no
other cell and calls it a slip. The probe confirmed it: "Almost! Try once more." for a real form
of the asked cell, with nothing saying the masculine singular is wanted.

**Fix.** See [D9](#d9).

<a id="f13"></a>
### F13. "j'ai monté" is graded wrong, and the learner is told monter takes être (Run, Low)

`StandardVariants.avoirAlsoAccepted` is `["passer"]` (`StandardVariants.swift:199`), on the
ground that "the quiz gives no context to rule one out". Monter, descendre, sortir, rentrer, and
retourner take avoir with a direct object in the same way (j'ai monté les valises), and demeurer
takes it in its commonest sense (j'ai demeuré à Paris). The probe graded "j'ai monté" and "j'ai
demeuré": `.noMatch`. Demeurer is in `AnswerDiagnoser.eitherAuxiliary`
(`AnswerDiagnosis.swift:179-182`), so it gets no line. Monter is not, so the learner is told
"Monter takes être, not avoir, in its compound tenses", which is false as stated.

**Fix.** See [D9](#d9).

<a id="f14"></a>
### F14. Six choice items mark the passé composé wrong where French uses it, and their reason states a rule that does not hold (Run, Medium)

`choice_questions.json` has six items whose reason is `passéSimpleInWriting`: naître, devenir,
and prendre in the setting "Dans un livre d’histoire", and entrer, ouvrir, and répondre in "Dans
un récit écrit". For example:

```
right: Victor Hugo {naquit} à Besançon en 1802.
other: Victor Hugo {est né} à Besançon en 1802.
```

"Victor Hugo est né à Besançon en 1802" is how French reference writing states a birth, and
modern history and fiction are often written in the présent or the passé composé. The card rings
it red, and the reason (`Choice.reasonPasseSimpleInWriting`) generalizes: "A written narrative,
such as a tale, a novel, or a history book, tells its events in the passé simple." A francophone
sees correct French called wrong. Phase 19's note expected an objection to the history-book
items. I read the six items and the reason in both languages.

**Fix.** See [D11](#d11).

<a id="f15"></a>
### F15. Two choice items mark an ordinary polite request wrong (Run, Low)

`pouvoir.conditionnelPrésent.1` marks "Pouvez-vous m’indiquer la gare, s’il vous plaît ?" wrong
beside "Pourriez-vous…", and `savoir.conditionnelPrésent.1` does the same to "Savez-vous où se
trouve la poste ?". Both are polite French. Phase 19's reread replaced two items for this reason
and left these, and its note lists them for Josh to judge. The three vouloir items are sound,
since "je veux un café" is curt.

**Fix.** See [D11](#d11).

<a id="f16"></a>
### F16. Half of the subjonctif sentences can be answered with the indicatif (Run by a reviewer's script, Medium)

Of the 71 sentences in `gap_sentences.json` whose tense is the subjonctif présent, 35 have a
blank that is also the indicatif présent of the same person: "Il faut que tu {passes} par la
banque", "Il faut que les élèves {limitent} leur temps d’écran". A further 20 are nous and vous
forms that equal the imparfait. About 16 need a form that is the subjonctif's alone (sois,
aille, fasse, puisse, sache, vienne, finisse). A learner who knows only the présent gets the 35
right, so the sentence ties nothing to its trigger. The drafting brief
(`plans/gap_sentences.md` § Which cells) did not ask for a person or verb that tells the two
apart. `dire.passéSimple.1` ("Le roi {dit} : …") is the same in kind.

**Fix.** See [D11](#d11). Either way, `scripts/gap_sentences.py check` should warn when a
subjonctif blank equals the indicatif of its person.

<a id="f17"></a>
### F17. At Advanced, the tenses whose only new part is the auxiliary are more than a quarter of a round (Read, Medium)

`QuizTenseSlot.weight` (`QuizLevel.swift:123-132`) gives each compound tense but the passé
composé a weight of 1, "because only its auxiliary is new". T2.6 asked for exactly that
thinning. But French has eight such tenses at Advanced (plus-que-parfait, conditionnel passé,
futur antérieur, subjonctif passé, subjonctif plus-que-parfait, passé antérieur, passé
surcomposé, impératif passé), so as a class they weigh 8 of Advanced's 30: more than the présent
(3) and the imparfait (2) together. With the passé composé, 11 of 30 questions are an auxiliary
and a participle. Konjugieren's weights were set for a language with fewer of these, and Phase
5's note says they were taken over as they stood. Intermediate is unaffected (2 of 20).

**Fix.** See [D12](#d12).

<a id="f18"></a>
### F18. At Beginner, three verbs take about two fifths of the regular présent questions (Reviewer, Low)

The présent's pools are `[.regularEr, .regularEr, .regularIr, .regularIr, .regularRe, .bigThree,
.indicatifPrésentStemChanger]`. A reviewer's script over `verbs.xml` found that Beginner's band,
the 100 most frequent verbs, holds three second-group verbs the quiz can ask: agir, choisir, and
définir (sortir's "obtain" entry is excluded). Two of the pools open to a regular question are
theirs, so définir comes up about as often as a core verb.
`QuizDrawTests.noVerbOutsideTheCoreDominatesALevel` exempts Beginner, so nothing bounds it. The
share is the reviewer's arithmetic, not a run.

**Fix.** Weight a pool by what the band holds: one `regularIr` entry while the band has fewer
than, say, ten such verbs. Measure the share first, over seeds, and say in **How it differed**
what it was.

<a id="f19"></a>
### F19. A defective irregular verb's surviving cells are recorded under an item no session can ask (Run, Low)

`PracticeItem.exercised(by:of:)` maps any cell of an irregular verb to its stem's item without
checking that the stem's il form exists, and `PracticeItem.isAskable`
(`QuizRecordSession.swift:55-65`) requires `verb.hasCell(stem.keyTense)`. The probe: issir, which
is inside Elementary's band and in the irregular-participle pool, has only its participe passé,
issu. An answer to it is recorded as `key:issir:passe_compose`, which is not askable, since "il
est issu" is a cell the defect group removes. A miss there never reaches My Mistakes' count, and
the due item is never asked, though it still sets "The next review is in 3 days". A reviewer's
script found 13 such entries, among them choir, frire, parfaire, forclore, occire, stupéfaire,
éclore, and paître.

**Fix.** Let a key conjugation's question ask the first cell of the stem that the verb has when
the il form is missing, in `PracticeItem.tense` and `isAskable` alike. Add a sweep test: for
every verb and every cell a level can ask of it, the item `exercised(by:of:)` returns is askable
and its question maps back to it.

<a id="f20"></a>
### F20. A pronominal verb's passé surcomposé is asked, and the conjugator's form for it is wrong (Run, Low)

Phase 12's note records that at Advanced the quiz asked se biler's passé surcomposé with a wrong
form, and that this was "not fixed, since it predates this phase. … Josh should decide whether
the quiz stops asking it or the Conjugator learns a form." No later phase took it up, and no
decision is recorded. The probe: for se biler, se souvenir, and s'absenter,
`hasCell(.passéSurcomposé(.thirdPlural))` is true, the frame is `elles s' ______`, and the
answer expected is "ont été bilées", "ont été souvenues", "ont été absentées". "Elles s'ont été
bilées" is not French. A pronominal verb takes être, and its rare passé surcomposé is built on
"s'est eu".

**Fix.** See [D23](#d23).

<a id="f21"></a>
### F21. A few sentences are unidiomatic (Reviewer, Low)

From a reviewer's read of 140 random sentences, all 71 subjonctif sentences, and all 56
compound, participle, and passé simple sentences:

- `exercer.imparfait.1`, "Chaque matin, nous {exercions} nos doigts au piano." One says "nous
  nous exercions au piano".
- `situer.futurSimple.1`, "Demain, nous {situerons} cette histoire dans son époque." Odd as a
  plan for tomorrow.
- `vouloir.passéComposé.1`, "Elle {a voulu} acheter la robe rouge." with "She wanted to buy the
  red dress." The passé composé of vouloir reads as "she tried to". The English is the
  imparfait's sense.
- `sembler.conditionnelPrésent.1`, "Vu d’avion, le village {semblerait} minuscule." A conditionnel
  with no hypothesis.
- `diffuser.futurSimple.1`, "Vous {diffuserez} l’émission demain à vingt heures." An odd subject.
- Choice items `aller.imparfait.1` and `partir.passéComposé.1` have an "other" sentence that is
  acceptable French in some readings.

**Fix.** Redraft the five sentences, and give `aller.imparfait.1` a bounding cue such as "quand
j’étais petit". Josh reviews the redrafts, as he reviewed the originals.

## What the Learner Is Taught

These are the places where a built feature undercuts the aim its suggestion stated in
[`../Konjugieren/docs/pedagogy_research.md`](../../Konjugieren/docs/pedagogy_research.md).

<a id="l1"></a>
### L1. A right re-ask takes the miss out of My Mistakes (Run, High)

`PracticeRecord.recordAnswer` (`Shared/PracticeRecord.swift:143-149`) sets
`entry.lastAnswerWasRight = isCorrect` on every answer, and `missedItems()` (`:192-204`) keeps
only entries where it is false. `Quiz.finish` (`Quiz.swift:1010-1030`) inserts a re-ask of every
missed question `reaskGap` questions later, and `Quiz.process` records the re-ask's answer like
any other (`:906`, with no look at `question.isReask`). Phase 11's note says so: "a re-ask is
another answer".

The probe missed the first question of a Beginner quiz (voir's présent). `missedItems()` held
`key:voir:present`. It answered the rest right, the re-ask among them, and `missedItems()` was
empty, with the item in box 0. So a learner who finishes her rounds finds My Mistakes almost
always empty: only a miss whose re-ask is also missed, a quit before the re-ask, or a challenge
question stays. T3.2's aim was a later session on the learner's errors. Recall three questions
after the correction showed the answer is the evidence that aim least needs.
`QuizTests`' "a mistake leaving once answered right" involves no re-ask.

**Fix.** Tell `recordAnswer` what kind of answer it is. See [D1](#d1).

<a id="l2"></a>
### L2. A diagnosed error, once repaired, counts as right in the record (Run, High)

`Quiz.process` (`Quiz.swift:850-919`) gives one more attempt to a slip or to any diagnosed
error, and records only the final answer:

```swift
Current.practice.recordAnswer(verb: verb, tense: tense, isCorrect: conjugationResult != .noMatch, at: now())
```

`.secondAttemptMatch` is not `.noMatch`, so the repair counts as right. The comment above gives
Phase 11's reason, "A slip's right second attempt counts as right". Phase 4 had called a
diagnosable answer "a real error, which Phase 14 will name", and Phase 14 then sent every
diagnosis through the slip's second attempt.

The probe typed "ai allé" for aller's passé composé, was told "Aller takes être, not avoir, in
its compound tenses. Try once more.", and typed "suis allée". `key:aller:passe_compose` went to
box 1 with `lastAnswerWasRight == true`, and nothing reached My Mistakes. With the item due in
box 1, the same exchange would have made it mastered. The line states the answer. Every class of
diagnosis takes the same path: the wrong tense named, the regular form, the cedilla, the
agreement.

**Fix.** Record a repaired diagnosis as something other than right. See [D2](#d2). Correct the
comment either way.

<a id="l3"></a>
### L3. Revealing the review card twice masters a verb never typed (Run, Medium)

`ReviewCardModel.reveal()` (`ReviewCardModel.swift:77-86`) calls `practice.recordReview`, which
moves every due shown item up a box (`PracticeRecord.recordReview`,
`Shared/PracticeRecord.swift:167-169`), and then reports achievements. A reveal has no way to say
"I did not know it", so every reveal is a pass. `MasteryState.masteredBox` is 2
(`Mastery.swift:18`).

The probe looked venir up, revealed its card two days later and again four days after that, and
read the boxes of its three shown key conjugations: 2, 2, and 2. Venir is then "Mastered" on the
Mastery page, counts toward the irregular-verb achievements (`Achievement.progress(in:)`), and
is drawn by the Speed Round as "material already accurate", with no form typed. Five such verbs
open the Speed Round. `docs/feature_architecture.md` § Speed Round says "Nothing is mastered
sooner than three days after its first right answer", which is true only if a reveal is an
answer.

**Fix.** See [D3](#d3).

<a id="l4"></a>
### L4. Opening a verb's page erases what the quiz recorded about it (Run, Medium)

`PracticeStore.recordLookup` (`PracticeStore.swift:64-71`) reschedules for every source but one:

```swift
record.recordLookup(items, at: date, reschedules: source != .reviewCard, calendar: calendar)
```

and `recordLookup` puts each key conjugation back in the first box. The probe took venir's
présent to box 4 by answers, then recorded a lookup with the source `quizCorrection`: box 0.
That source is the link the held correction itself offers (`QuizCorrectionView.swift:96-101`),
so a learner who misses "il viendra" and taps through to venir's page loses the mastery of
vient and est venu too. The Verb of the Day widget, Spotlight, an article's link, Related Verbs,
and a model's page do the same, and none of them says "I forgot this". `MasteryView` avoids
linking its verbs for this very reason. Josh set the rule, and kept it for the widget on
2026-11-25, before anything read the box as mastery.

**Fix.** See [D4](#d4).

<a id="l5"></a>
### L5. "Mastered" is not what the page says it is (Read, Medium)

`MasteryState.init` (`Mastery.swift:18-26`) is `entry.schedule.box >= Self.masteredBox`. The
Mastery page's introduction (`Mastery.intro`) says "A form is mastered once its next review is a
week or more away", in French "dès que sa prochaine révision est à une semaine ou plus", and
`SpeedRound.locked` and `docs/feature_architecture.md` § Speed Round say the same. An item
promoted to the third box on the 1st is due on the 8th. On the 7th its next review is tomorrow,
and it still shows as mastered. If the learner stops practicing, it shows as mastered in March.
A dismissed card sets a third-box item due tomorrow and leaves it mastered. So the stated rule
is false most of the time, and mastery fades only on a wrong answer or a lookup ([L4](#l4)),
which the text does not mention.

**Fix.** See [D5](#d5). Keep `SpeedRound.masteredItems` and `Achievement` on whatever rule
results.

<a id="l6"></a>
### L6. A choice question shows the English of the right sentence before the choice (Run, Medium)

`ChoiceQuestionView.body` (`ChoiceQuestionView.swift:35-39`) draws `choice.question.english`
unconditionally, between the two sentences and the reason, and it is the translation of the
right sentence only. English marks several of the contrasts the items teach. A reviewer read all
66 items: about 27 have an English line that names the answer's tense, such as "I **was
working** when the phone rang" (imparfait against passé composé), "My father **used to take**
the bus", "If I **had** more time, I **would** travel", "I**'d like**", and "we**'ll** go". 23 of
them are among Elementary's 33, the level where the choice is asked most. An English-speaking
learner can answer by mapping English grammar onto the French. Konjugieren shows the English
too, and Josh ruled there on 2026-11-27 that it comes after the choice. German's contrasts are
less often written into English than French's are.

**Fix.** Show the English once `chosenIndex != nil`, beside the reason. See [D11](#d11).

<a id="l7"></a>
### L7. A quit challenge can be taken again with its answers seen (Read, Medium)

`Quiz.quit()` (`Quiz.swift:297-310`) records nothing about a challenge. `recordChallenge` is
called only from `completeRound()` (`:1115-1118`). `QuizView.challengeRow`
(`QuizView.swift:870-895`) offers Start whenever `challengeResult(for: key)` is nil, and
`DailyChallenge.questions(for:)` returns the same five from its cache. A wrong answer is held
with its correction, which shows the right form. So: start today's challenge, read the first
answer in the correction, quit, start again, and repeat to 50 / 50, then share it. Killing the
app keeps nothing either. `docs/feature_architecture.md` says "A quit challenge keeps nothing
and can be started again" without saying what that allows. The shared result is meant to be "the
same short set for everyone that day", taken once.

**Fix.** See [D14](#d14).

<a id="l8"></a>
### L8. Smaller holes in the daily challenge (Read for the first; Reviewer for the rest, Low)

- **A link opens any date.** `DailyChallenge.Key.init?(day:level:)`
  (`DailyChallenge.swift:40-46`) checks only that the day is a real date, so
  `conjuguer://quiz/challenge?date=<tomorrow>&level=elementary` starts tomorrow's challenge
  today, and with [L7](#l7) it can be rehearsed. Finished, it is stored under the future key and
  shows as done when the day comes.
- **Old results fall out.** `DailyChallengeResult.keptCount` is 12, the newest kept. A learner
  who plays all four levels fills it in three days, and a challenge older than that can be taken
  again from its link.
- **The widget shows the first answer.** The quiz widget asks the challenge's first question as
  a four-way choice with the right form among the options, shows the answer after a miss
  (`QuizWidgetView.swift:66`), and opens the challenge on a tap. Josh approved the widget asking
  the challenge's first question. That it then shows the answer was not stated to him.
- **A link to a challenge already taken shows nothing.** `QuizView.startRequestedChallenge`
  (`QuizView.swift:1168-1171`) returns when a result is kept, so the link lands on the hub with
  today's row at the learner's level, and nothing says the linked challenge was taken or what
  its result was.

**Fix.** See [D16](#d16). For the last, show the kept result.

<a id="l9"></a>
### L9. A ranked round holds a coin flip and the learner's own due items (Read, Low)

From Elementary up, one question of each default round is a choice of two sentences
(`QuizScope.mixesChoiceQuestions`), scored 10 like a typed answer (`Quiz.submitChoice`), and up
to three are the learner's own due items (`mixesDueItems`). Both are in the first round's ten,
which is what `firstRoundScore` posts to the level's leaderboard. So one tenth of a ranked score
is a guess, and no two learners' ranked rounds ask the same mix, though the doc comment on
`mixesChoiceQuestions` says the choice is asked "so that every ranked round of a level asks the
same mix". Josh ruled on both for Konjugieren on 2026-11-27.

**Fix.** See [D13](#d13).

<a id="l10"></a>
### L10. A miss on a round's last question is re-asked on the next screen (Read, Low)

`Quiz.reaskPosition(after:in:)` (`Quiz.swift:1063-1065`) is `min(index + 1 + reaskGap, count)`,
so a lone miss on question 10 returns at once, straight after the correction that showed its
answer, and a miss on question 9 has one question between. It scores 5 like any right re-ask.
T3.1's aim is retrieval a few questions later. The phase asked for a re-ask "before the
results", and `aMissReturnsThreeQuestionsOnOrAtTheRoundsEnd` pins it, so this is by design. With
[L1](#l1) fixed its only cost is the half points.

**Fix.** See [D16](#d16).

<a id="l11"></a>
### L11. In Name the Conjugation, a guessed person alone earns the second try (Reviewer, Low)

`RecognitionQuestion.grade(_:)` (`Recognition.swift:300`) counts the person right when any cell
of any verb that writes the prompt has it, and gives one more try when any part is right. For
"suis", an answer of aller, futur simple, je earns "Check the infinitive and the tense. Try once
more." and half points on a right second try, though only the person chip was right, one of six
and probably by chance.

**Fix.** See [D16](#d16).

<a id="l12"></a>
### L12. The reminder counts items its session will not ask, and one line opens on a reproach (Reviewer, Low)

`DailyReminderPlan.reminders` (`DailyReminder.swift:64`) counts every askable due item. The
session it opens asks at most ten, and only those within the level's tenses and band
(`QuizDraw.dueQuestions`). So an Elementary learner with 23 due items, 8 of them a passé simple
from an earlier spell at Advanced, is told "with 23 conjugations due for review" and is asked
ten, none of them a passé simple.

On a repair day the notification's body is the hub's line (`status.hubDetail`): "You missed
yesterday. Two sessions today keep your 3-day streak." On the hub the learner chose to look. As
a notification it is unsolicited and opens with what the learner failed to do. T6.3 asked for a
streak that can be repaired so that a lapse does not discourage.

**Fix.** Count what the session would ask. Give the notification a line of its own that opens
with the offer, such as "Two sessions today keep your 3-day streak going.", for Josh to review
in both languages.

<a id="l13"></a>
### L13. The Speed Round's minute counts timer ticks (Read, Low)

`Quiz.clockTicked()` (`Quiz.swift:266-280`) adds one second for each firing of a `Timer`, and
nothing in the quiz reads the scene's phase or a deadline. A suspended app fires no timers, so a
learner can leave mid-round, look a form up elsewhere, and come back to the same seconds.
Pulling down Notification Center leaves the app inactive, not suspended, and the clock runs on.
Nothing states which is intended. Josh ruled for Konjugieren on 2026-11-27 that the minute is a
minute.

**Fix.** See [D17](#d17).

<a id="l14"></a>
### L14. A set shared over a collection asks each student's own band, so a class is not asked the same verbs (Read, Medium)

`PracticeSet.init(sharing:level:myVerbs:)` (`PracticeSet.swift:27-34`) carries the sharer's
level only while a part is left to it:

```swift
self.level = shared.tenses.isEmpty || shared.verbSet == nil ? level : nil
```

and `QuizScope.prefersBandVerbs` (`QuizScope.swift:139-148`) is true for a practice set over a
collection, so the draw takes the collection's verbs inside `band(at: level)` first, where
`level` falls back to the opener's own. A teacher shares "imparfait, verbs taking être". A
student at Beginner, the default, is asked the collection's 100 most frequent verbs first. A
student at Advanced is asked the whole collection, rare verbs included, and for a set over
parler's model that is thousands of verbs. `docs/feature_architecture.md` § Practice Sets says
the opposite: "everyone who opens a set is asked the same tenses and verbs whatever their own
level", and so does the doc comment on `PracticeSet.level`. The browse fixes' Phase 11 gave a
collection's quiz its band-first draw, and the practice set took it on without a level to go
with it.

**Fix.** See [D19](#d19).

<a id="l15"></a>
### L15. The slip rule calls grammatical errors typing slips (Run, High)

`AnswerSlip.isSlip` (`AnswerSlip.swift:19-46`) calls an answer a slip when it is one edit from
an accepted spelling, or differs only in accents, and is not another cell of the verb. A
diagnosis is tried first (`Quiz.swift:869-875`), so a slip is whatever no diagnosis names.
Its own doc comment says a slip is "a typing slip or a dropped accent, not a grammatical error".
The probe typed thirteen wrong answers and printed what each got:

| Typed | For | What the learner is told |
|---|---|---|
| a prit | il a pris | Almost! |
| a mit | il a mis | Almost! |
| prenent | ils prennent | Almost! |
| veus, peus | je veux, je peux | Almost! |
| ai finit | j'ai fini | Almost! |
| ai dis | j'ai dit | Almost! |
| fûmes | nous fîmes (faire) | Almost! |
| connait | tu connais | Almost! |
| connaît | tu connais | "That is the conjugation for elle." |
| prendent | ils prennent | "That is the regular form, as rendre has it. Prendre is irregular here." |

Three kinds of error pass as typing.

- **The irregular letters themselves.** The conjugator writes pris as prIS, prennent as
  prenNent, and veux as vEUX. An error inside those capitals is the error the question exists to
  catch.
- **A participle's ending.** "j'ai finit" and "j'ai dis" are among the commonest written errors
  in French, and finir is regular, so no capital marks the letter.
- **A person error typed in a 1990 spelling.** `Verb.conjugations(matching:)` compares with the
  conjugator's own cells and does not know the spellings grading accepts. So "connaît" for tu
  connais is named as il's form, and the same error typed "connait", which Phase 1 invites, is a
  slip. Plait and parait are the same.

A slip's right second attempt then counts as right in the record ([L2](#l2)), so "a prit" and
then "a pris" raises prendre's passé composé. This is Konjugieren's L4 ("sung" for sang) in its
French form.

**Fix.** An edit that falls inside the letters the conjugator marks irregular for the asked cell
is not a slip, and the cell check takes the spellings grading takes: both are this plan's
defaults, as they were Konjugieren's. The participle's ending needs a line of its own, such as
"The participe passé of finir is fini. -it is the passé simple.", for Josh to review in both
languages.

<a id="l16"></a>
### L16. The mix is guaranteed for the questions drawn, not for the round (Read, Low)

`Quiz.mixedQuestions` draws `scope.questionCount - due.count - 1` questions when the round has
due items and a choice (`Quiz.swift:481`), and `QuizDraw.questions` makes half of what it draws
irregular, rounded up. Rounding up was chosen so that a draw of nine beside a choice still has
five. With three due items the draw is six, three of them irregular, so a round can hold three
irregular typed questions of nine if the due items are regular patterns. The due items also
stand outside the role counts, so a due rare derivative adds to the "one to three" that
`docs/feature_architecture.md` says no other question asks.

**Fix.** See [D13](#d13), which settles whether a default quiz's first round holds due items at
all. If any round keeps them, draw the full count and let due items take slots of matching role
and regularity.

<a id="l17"></a>
### L17. Dismissing the review card hides its items from today's Review (Read, Low)

`ReviewCardModel.dismiss()` (`ReviewCardModel.swift:90-98`) snoozes an unrevealed card's items,
and `ReviewSchedule.snoozed` sets them due tomorrow. They leave today's due items, and with them
today's Review, today's daily session, and the hub's count. A learner who waves the card away
and then opens Review is not asked prendre, which was due. Dismissing a card says "not now, not
here". It does not say "not today".

**Fix.** See [D3](#d3).

<a id="l18"></a>
### L18. The correction marks a spelling that grading accepts (Run, Low)

`AnswerDifference.nearest` (`AnswerDifference.swift:93-107`) aligns the answer with the
conjugator's own spellings and never with the `StandardVariants` that grading accepts. The probe
asked for the difference between "connaitrons" and elles connaîtront: it marks the i as well as
the s, and names î among the letters that differ. The learner is told that a spelling the quiz
accepts was part of the error. Passer's "ai" is marked the same way in "j'ai passées".

**Fix.** Align with the nearest accepted spelling, `StandardVariants` included.

<a id="l19"></a>
### L19. Small points in the sentences (Reviewer's script, Low)

- **English that spells the blank.** Four sentences have the answer in their English, as a
  cognate: `assurer.indicatifPrésent.1` ("I assure you…"), `imaginer.indicatifPrésent.1`,
  `inviter.subjonctifPrésent.1`, and `citer.subjonctifPrésent.1`.
- **The distribution.** 330 of the 750 ask a third person, and 335 ask the passé composé or the
  présent. Recorded so that a next batch leans the other way.

**Fix.** Redraft the four with [F16](#f16)'s and [F21](#f21)'s.

## Correctness

<a id="c1"></a>
### C1. The hub's rows for today are not recomputed when the day turns (Suspected, Medium)

`QuizView.challengeRow` (`QuizView.swift:870-895`) computes
`DailyChallenge.Key(date: .now, level: level)` and its result while the body runs, and its
button's closure captures both. `dailySessionRow` (`:854`) reads `streakStatus()` at `.now`,
`recordSessions` reads Review's askable count at `.now`, and `LastQuizResultRow.relativeDay`
does the same. Nothing invalidates the hub when the day changes: `rg` finds no
`significantTimeChange`, no `NSCalendarDayChanged`, and no `TimelineView` outside `GameView`, and
the scene-phase handlers in `ConjuguerApp` and `SceneRoot` change nothing the hub observes.

So a learner who finishes the session and the challenge in the evening and leaves the app on the
Quiz tab can find, next morning, "Done for today", yesterday's "Done today: 35 / 50", and a
challenge row whose tap shares yesterday's result instead of starting today's. If yesterday's
was not taken, the tap starts yesterday's challenge. Review can stay disabled though items came
due overnight. Any change to the record or the settings redraws the hub and repairs it. Two
reviewers reached this independently by reading. Neither saw it happen, since the simulator
takes its clock from the host. To confirm: finish both on the simulator at 23:57 host time,
press Home, reopen at 00:01, and read `quiz_daily_button` and `quiz_challenge_share_button`
with `describe_ui` before touching anything.

**Fix.** A day token on the hub, a `@State` refreshed when the scene becomes active and on
`NSCalendarDayChanged`, which every row that reads `.now` takes. Compute the challenge's key
inside the button's action.

<a id="c2"></a>
### C2. A link that arrives during a sheet's quiz ends it without a word, and without `quizQuit` (Read, Medium)

`QuizSheet`'s doc comment (`QuizView.swift:1488-1491`) says "the sheet closes only through Quit,
so every quiz started here ends with `quizQuit` or `quizCompletion`".
`interactiveDismissDisabled` stops a swipe and nothing else. `SceneRouter.show(_:)`
(`SceneRouter.swift:146-173`) opens with `clearDeeplinkTargets()`, which sets
`routedSheet = nil` whatever is on it, and neither `QuizSheet` nor `Quiz` has an `onDisappear`
or a `deinit`.

A student on question 6 of a teacher's set taps the daily reminder, the Quick Quiz control, a
widget, or a second set's link. The set's page and its quiz vanish with no confirmation. The
router guards the Quiz tab's quiz against `quiz/start` and does not guard a sheet's. The quiz
that was closed sends no `quizQuit` and reports no achievements, its `QuizAbandonment` entry
stays, so the next launch sends `quizAbandon` for a quiz the learner never left the app during,
and its one-second `Timer` keeps firing into a `weak self` for the life of the process. A
collection's quiz and Test Me, opened from a routed sheet, go the same way. The routing is the
browse fixes' (Phases 1 to 3), and the doc comment was true before it.

**Fix.** `QuizSheet` quits its quiz when it disappears while a question waits, so the signal is
sent, the entry cleared, and the timer stopped. What a link should do while a sheet's quiz is
under way is [D21](#d21).

<a id="c3"></a>
### C3. A practice set's link that arrives under another presentation may never show (Suspected, Medium)

`routedSheet` is presented from the `TabView` (`MainTabView.swift:40`). On a first launch the
onboarding is a `fullScreenCover` over `MainTabView` (`SceneRoot.swift:24-37`), and
`SceneRouter.drainPendingDeeplink()` runs right after the verbs load, which is while the cover
is first shown. This is the school channel's first contact: a student installs the app after
scanning the teacher's code, scans again, and the app launches into onboarding with the set
requested beneath it. SwiftUI either drops a sheet asked for while another is presented or
queues it. Phase 10 tried a cold launch on the iPad and not a first launch. The same question
holds for a set scanned while a quiz's results sheet is up. Not run, because erasing the app's
data on Conjuguer's simulator would also erase the practice record the phases' checks built
there. To confirm on a scratch simulator: delete the app, install it, and launch with
`xcrun simctl openurl <udid> 'conjuguer://quiz/set?tenses=imparfait'`, close onboarding, and
look for `practice_set_summary`.

**Fix.** While onboarding shows, keep the link pending and drain it from the cover's
`onDismiss`. For the results sheet, either present the routed sheet from the top of the
presentation stack or close the results first.

<a id="c4"></a>
### C4. An empty Return is graded as a wrong answer (Run, Low)

`QuizView.submit()` (`QuizView.swift:564-585`) passes the field to `quiz.process` without
looking at it, and `Quiz.process` does not either. On a hardware keyboard Return continues past
a held correction and refocuses the field, so a second Return, a double press or a key's repeat,
submits "" to the next question. The probe: `process(proposedAnswer: "")` holds a correction and
records a miss, which is then re-asked and, until [L1](#l1) is fixed, listed in My Mistakes.

**Fix.** `submit()` ignores a Return whose normalized input is empty and keeps the focus, as the
recognition path does for an incomplete answer.

<a id="c5"></a>
### C5. The streak's day keys and the reminder's dates are written in the device's calendar (Run by a reviewer's script, Low)

`PracticeStore` uses `Calendar.autoupdatingCurrent`, `DailyStreak.dayKey` writes year, month,
and day in whatever calendar that is, and `dayNumber(key:)` reads them back with
`calendar.date(from: DateComponents(year:month:day:))`, which drops `isLeapMonth`.
`WidgetDateHelper` forces a Gregorian calendar for exactly this reason, and says so in its
header. A reviewer's script round-tripped 1,500 days from 2026-01-01 in each calendar: the
Chinese calendar gave 29 bad days, all in its leap month of 2028, each keyed a month early, so
the streak reads as none for that month. The Hebrew, Japanese, Buddhist, Islamic, and Persian
calendars round-trip. `ReminderSchedulerReal.schedule` builds its trigger's components the same
way (`Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], …)`), so those
reminders probably match a date already past (Suspected).

**Fix.** Build the streak's keys and the trigger's components with a Gregorian calendar in the
current time zone, as `WidgetDateHelper.calendar` does, and keep the learner's calendar for
display.

<a id="c6"></a>
### C6. A daily session that ends after midnight counts for the day it ends (Read, Low)

`Quiz.completeRound()` calls `Current.practice.recordDailySession(at: now())`
(`Quiz.swift:1108-1109`), the moment of the last answer, though it holds `sessionStartDate`. A
learner with a ten-day streak who starts at 23:56 and finishes at 00:02 has no session on the
day she practiced, and the hub next day says two sessions are needed to keep the streak. On a
repair day the same timing puts the second session on the day after, and the repair fails.

**Fix.** Record the session on the day it began. That is this plan's default, as it was
Konjugieren's.

<a id="c7"></a>
### C7. Each reschedule of the reminders runs as its own unordered task (Suspected, Low)

`ReminderSchedulerReal.schedule(_:)` (`ReminderSchedulerReal.swift:47`) starts an unstructured
`Task` that awaits the pending requests, removes them, and then awaits an `add` for each new
one. Two such tasks interleave at every `await`. They are started close together when a daily
session finishes and the app then goes to the background, and when Settings turns the reminder
on and its time is then changed. One ordering leaves today's reminder scheduled on a day already
done. The reschedule on going to the background also removes every pending reminder before
adding fourteen, with no background task, so a suspension in between leaves none until the next
activation. A unit test cannot reach `UNUserNotificationCenter`.

**Fix.** Serialize the work, for example by awaiting the previous task or with an actor, replace
by identifier and not by removing everything first, and wrap the background call in
`beginBackgroundTask`.

<a id="c8"></a>
### C8. A record that fails to decode is replaced by an empty one at the next answer (Read, Low)

`PracticeStore.init` (`PracticeStore.swift:44`) reads
`getterSetter.get(…).flatMap(PracticeRecord.init(json:)) ?? PracticeRecord()`, and the next
`save()` overwrites `practiceRecord`. `PracticeRecord.Entry` carries a comment that a later
field must be optional. `ReviewSchedule` and `DailyStreak` carry none. A build that adds a
non-optional field to either, or one malformed entry, makes the learner's whole history vanish
at the first answer, with nothing said and nothing kept ([T9](#t9) is the missing test).

**Fix.** On a failure to decode, copy the raw string to a second key before anything saves, and
put the "must be optional" note on `ReviewSchedule` and `DailyStreak`.

<a id="c9"></a>
### C9. What a shared set does at its edges (Reviewer; the sizes Run by script, Low)

- **A received list has no cap.** `PracticeSet.init?(linked:level:)` keeps every verb a link
  names. Only `init(sharing:)` caps, and only My Verbs. A link with 200 verbs is accepted, Keep
  stores it, and Share then builds a link past what a QR code holds (2,331 bytes at version 40,
  level M). `QRCode.image` returns nil, and `PracticeSetQRView` (`PracticeSetView.swift:191`)
  shows a title and a caption with no code and no reason.
- **The cap's arithmetic is wrong in three places.** The comment on `maximumListCount`
  (`PracticeSet.swift:36-37`) and `docs/feature_architecture.md` § Practice Sets say an é takes
  nine bytes percent-encoded. It takes six (`%C3%A9`). The comment in `QRCode.swift:13-15` says a
  hundred-verb list "still fits well inside its capacity". The script found the worst hundred
  with every tense take 2,635 bytes, which does not fit, and the worst fifty take 1,565, about a
  version-33 code, which is dense for a projector. So fifty does not keep a code "coarse enough
  to scan from the back of a classroom" either.
- **Unknown verbs are dropped in silence.** A link whose verbs or model this version lacks loses
  that part and keeps its tenses, so it opens as a valid-looking set ("Verbs: Set by Your
  Level") over the opener's band. Only a link that loses everything gets "Practice Set Not
  Found", whose text ("may need a newer version") fits exactly this case.
- **Sharing My Verbs sends the first 50, recent lookups among them.**
  `LearnerVerbs.myVerbs` is the starred verbs and then up to twenty recent ones not starred
  (`Shared/LearnerVerbs.swift:92-95`). A teacher who stars twelve verbs for the week and looked
  up mourir for herself shares thirteen, and the menu says only "My Verbs". Past fifty, the
  oldest stars are dropped, and nothing tells the sharer.

**Fix.** Cap any list on the way in. Say in the QR view when a list is longer than its code
carries. Mark a set that lost verbs and say so above Start. See [D20](#d20) for the cap and for
what a shared My Verbs carries.

<a id="c10"></a>
### C10. Smaller defects (Reviewer, Low)

- **A `quiz/start` link discards results on screen.** `SceneRouter.show` starts a default quiz
  whenever `quizState != .inProgress`, which is also true while a round's results show, so the
  session's Ten More is lost. The daily and challenge requests check `shouldShowResults` too.
- **The Live Activity's timer, with the clock shown.** `Quiz.liveActivityState`
  (`Quiz.swift:362-377`) moves the start date only when a question advances, so on the Lock
  Screen the timer runs through a held correction and through time in the background, then
  jumps back at the next answer. `ContentState.correctCount` is sent and never shown.
- **"10 Questions" for a list that cannot fill ten.** With aller alone in My Verbs at Beginner,
  Start is enabled and the round asks nine, and the tile (`QuizView.sessionFacts`) says ten.
- **A Last Quiz row over a collection that no longer resolves** is titled "Practice Set"
  (`LastQuizResult.title`, `LastQuizResult.swift:114`).
- **A pattern no verb fits any more** is still counted as due or missed.
  `PracticeItem.isAskable` returns true for any pattern whose tense parses, without checking
  that `patternVerbs` finds a verb. Every stored pattern has one today. A renumbered model or a
  change to which cells the conjugator marks would orphan stored keys, and the row would then
  show a count and a play button that starts nothing.
- **`TryQuizTip` is retired at nine call sites** in `QuizView` and not on the path a sheet's
  quiz takes, so a student who practices only through a teacher's sets keeps seeing the Verbs
  tab's tip.
- **A link's `source` can be any value of the vocabulary.** `Deeplink.init?(url:)` accepts
  whatever `AnalyticsSource(rawValue:)` parses, so `conjuguer://quiz/start?source=review` starts
  a ranked default quiz that reports itself as Review, with a question count
  ([P3](#p3) is why that pairing matters).

**Fix.** As each line implies. For the tip, invalidate once inside `QuizView.start(scope:)`. For
the source, let each route accept only the sources it can carry and fall back to `deeplink`.

## Privacy

**Decision 5 holds for what each signal carries.** A reviewer listed every call to
`Current.analytics.signal` in the app, the widget, and `Shared/` (about thirty sites, and none in
the widget or `Shared/`) and traced every value of every parameter to where it is computed. No
signal carries typed text, an answer, a score, a count of right or wrong answers, a verb, or a
model's id. `questionReached` still excludes re-asks, so the Closing's fix holds. The Speed Round,
Review, My Mistakes, and mixed model practice omit both counts. Every signal, key, and value the
code sends is staged in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in
English and French with the same meaning, each section names its phase and date, and nothing
staged describes a signal the code no longer sends.

The Closing's audit judged values one by one. The findings below are what a value's existence,
or two values together, let one infer, and what the staged text gets wrong.

<a id="p1"></a>
### P1. A question count can name the model, and so the verb (Run, Medium)

`VerbCollection.analyticsValue` sends `model` for every model, "since some models hold a single
verb … and naming the model would name the verb looked up". Two counts partly undo that.

- **A model practiced alone.** `QuizScope.sendsQuestionCounts` (`QuizScope.swift:75`) is true
  for model practice alone, and a spelling-change model's round is its marked cells when those
  are fewer than ten. The probe grouped every model that offers practice alone by the length of
  its round: a round of 7 is manger's model (1-2B) and no other, and a round of 12 is one of two
  models. So `quizCompletion` with `source=modelAlone` and `questionCount=7` names the model. The
  Closing's note accepted the count on the ground that "a model is never named".
- **A one-verb model's own quiz.** A model's page offers a quiz over the model
  (`VerbCollectionBar`, source `list`), a round is as long as the model's unasked cells allow,
  and Ten More runs to the model's total. That total depends on the verb's defect group. The
  probe grouped every model by `askableCellCount(at:limit:)` at each level and kept the lengths
  that belong to one model of one verb. At Beginner, a round of 5 is clore's model (5-27) and no
  other. At Elementary, a first round of 3 is ouïr's and one of 6 is falloir's, and with Ten More
  the totals 11, 12, and 24 are échoir's, gésir's, and clore's. Ouïr's 3 is its own at every
  level above Beginner. So `quizStart {source: list, collection: model, level: beginner}`
  followed by `quizCompletion {questionCount: 5}` names clore. A custom quiz, a practice set, or
  My Verbs over such a verb alone sends the same count. This is the French form of
  Konjugieren's P1, whose key Conjuguer already withholds.

**Fix.** Send no question count, or a band, for model practice in either mode and for any scope
whose verbs are a list (`.collection`, `.myVerbs`, a custom quiz or practice set over chosen
verbs, Test Me). Stage the change. Pin it with a test that no count is unique to a one-verb
model at any level.

<a id="p2"></a>
### P2. Four `source` values exist only after the record says something about accuracy (Read, Low)

- `viewAppeared` with `source=quizCorrection` is sent only from the held correction's link
  (`QuizCorrectionView.swift:96-101`), which exists only after a wrong final answer. Each one is
  proof of a wrong answer.
- `quizStart` with `source=mistakes` can be sent only while an item is missed.
- `source=speedRound` needs five mastered items (`QuizView.swift:979`).
- `source=modelMixed` needs another model known (`ModelPractice.mixPartners`).

Josh ruled for Konjugieren on 2026-11-15 that `mistakes` and `quizCorrection` are surfaces and
stay, and on 2026-11-27 that the Speed Round's and the mixed ablaut practice's sources are
surfaces too. Conjuguer's plan carried Decision 5 over and never recorded those rulings, so the
Closing's "Decision 5 holds" rests on a ruling this repository does not have.

**Fix.** See [D18](#d18). If they stay, record the ruling here and say plainly in the staged
text that opening a verb from a quiz's correction follows a wrong answer.

<a id="p3"></a>
### P3. A second round of My Mistakes says that more than ten were missed (Read, Low)

Phase 12 withheld the question count from Review and My Mistakes because "a short session's
length would be a count of wrong answers". But `Quiz.completeRound()` sends `quizCompletion` at
every round (`Quiz.swift:1099-1119`), and `canContinue` offers Ten More only while the record
holds an item the session has not asked (`:149-152`). With fourteen missed items, the first round
asks ten and sends a completion, and the second asks four and sends another. Two completions
with `source=mistakes` in one session say more than ten were missed, and three say more than
twenty. The `duration` band on the same signals says roughly the same thing more coarsely: for a
record session, "3-15s" is one or two items and "2m+" about ten. The staged text gives the
withheld count's reason, which the round count undoes.

**Fix.** See [D18](#d18).

<a id="p4"></a>
### P4. The staged text says "but not which", and a featured collection is sent (Read, Low)

The lifecycle bullet's latest copy (`docs/privacy_policy_pending.md`, English and French, and
each earlier copy from Phase 9's) ends "for a custom quiz or a practice set, whether it chose
tenses, verbs, or both, but not which" ("mais pas lesquels"). `QuizScope.namedCollection`
returns the custom quiz's collection for `.custom` and `.practiceSet`
(`QuizScope.swift:202-203`), and the editor offers the verbs taking être, the irregular futurs,
and the pronominal verbs. A practice set over the first sends
`quizStart {source: sharedLink, customChoice: verbs, collection: etre}`, which says which. The
developer's note beside the bullet admits it. The bullet does not. "Not which" does hold for a
model, which is sent as `model`, and for a list.

**Fix.** Reword the bullet in both languages: one of the three fixed lists is named when it was
chosen, and a model and a list of verbs never are.

<a id="p5"></a>
### P5. Decision 5 is held by vigilance, not by construction (Read, Medium)

`Analytics.signal(name:parameters:)` takes `[String: String]`. A call site could pass
`["verb": verb.infinitif]` and compile, and `AnalyticsSpy` would record it without complaint.
About seventy assertions across eighteen suites check particular keys at today's call sites. No
test lists the keys a signal may carry or the values a key may take. The two checks that claim
"no score" look for keys that do not exist ([T4](#t4)). The only defense against a later
`parameters["answer"] = input` is a human audit, which the Closing did once.

**Fix.** Have the spy, or a wrapper around the protocol, assert that each key is a
`ParameterKey` and each value comes from a closed set for its key: an enum's cases, a band's
outputs, or digits for the two counts. Then drive one session of every `QuizScope.Kind` through
it in one test. Taking `[ParameterKey: String]` in the protocol would make the first half
structural.

<a id="p6"></a>
### P6. The analytics vocabulary decides what the app does (Read, Low)

`PracticeStore.recordLookup` reschedules when `source != .reviewCard` (`PracticeStore.swift:69`),
and `VerbVisitTracker.begin()` records an open unless `source == .resume`
(`VerbVisitTracker.swift:96`). `AnalyticsSource` is a reporting vocabulary. Splitting
`reviewCard` into two values for reporting, or reusing it for a new surface, would silently
change which lookups reset the schedule.

**Fix.** A value of the app's own for what an open means (a lookup that demotes, a lookup that
enters, a resumption), chosen where the page is opened, with the analytics source beside it.
[D4](#d4)'s answer replaces the first test in any case.

<a id="p7"></a>
### P7. The SDK sends parameters neither policy names (Reviewer, read in the SDK's source; older than the port, Medium)

`AnalyticsReal.initialize` uses `TelemetryDeck.Config(appID:)` with every default on. A reviewer
read TelemetryDeck 2.14.1 in the build's checkout: it adds to every signal the device's model,
the system version, the time zone, the orientation and screen size, the color scheme, language,
and region, accessibility settings (bold text, reduce motion, content size, and others), the
hour of the day and day of the week, and retention values, among them `totalSessionsCount`,
`distinctDaysUsed`, and `previousSessionSeconds`, exact. It also sends a session-started signal
of its own. `privacyPolicy4.md` names "App version, Unique installs, Device model, Country and
language". The pending policy names only the app's own signals.
`docs/feature_architecture.md` § Analytics says "Counts and durations go out in bands
(`AnalyticsBand`), never as exact numbers", which is untrue of these and also of
`lastQuestionIndex` and `questionCount`. None of it is accuracy, so Decision 5 is not touched.
The port did not introduce it. It is here because the port's staged text takes care to disclose
a streak's band while the SDK sends the exact count of days used.

**Fix.** See [D18](#d18).

<a id="p8"></a>
### P8. Smaller points in the staged text (Reviewer, Low)

- **The list of question counts is closed and incomplete.** The duration bullet lists "10, or 20
  or more if you asked for ten more; 15 a round in Verb Essentials; up to 15 a round in a model's
  practice alone; 5 in the daily challenge". Test Me sends 3, and a quiz over few verbs sends
  fewer than ten. [P1](#p1) changes this bullet anyway.
- **"Stays on your device"** leaves out that the App Group's defaults are in the device's
  backups, and `Settings.resetPracticeDescription` says the record "is never sent" though
  achievement percentages computed from it go to Game Center and outlive Reset Practice
  (`World.resetPractice()` does not reset achievements).
- **The French mixes spaces.** By a reviewer's count, the sections staged by Phases 10, 11, 18,
  and 20, the Closing, and the browse fixes use U+202F before `:` and `;` and inside « »
  (84 marks), and every other section uses a plain space (about 200). `docs/privacy_policy2.txt`
  uses plain spaces throughout. Spliced on release day, some bullets would let a colon wrap onto
  its own line.

**Fix.** Reword the first two in both languages ([D18](#d18) settles whether Reset Practice also
resets the achievements). Normalize the French to U+202F in one pass, and add a release-day
step to check it.

## Interface Text and VoiceOver

All 284 catalog keys the port added have English and French values in the translated state,
their format specifiers agree, and the French puts U+202F before every `: ; ! ?` and inside « »
(a reviewer's script). What follows is what reading the French found, and what VoiceOver does
with the new states. **Josh reviews every changed line in both languages before it ships**, as
he reviewed the originals.

<a id="i1"></a>
### I1. The held correction speaks its French in the interface's voice (Suspected, Medium)

`QuizCorrectionView.body` makes the correction one element
(`.accessibilityElement(children: .ignore)` with `.accessibilityLabel(spokenCorrection)`), which
discards the `.frenchPronunciation()` on its children. `docs/voiceover.md` says one element gets
one language. So with an English interface, "Incorrect. Your Answer: parle. Correct Answer:
parlé." is one English utterance, and the right form, at the moment the learner most needs to
hear it, comes in an English voice. The same holds for a choice question's two sentences
(`ChoiceQuestionView.optionButton`, a label of the sentence and its tense), its reason
(`spokenVerdict`), the Speed Round's miss line (`SpeedRoundMissLine`), and a diagnosis line
spoken by `Quiz.announceSecondAttempt`. The quiz's own announcements speak each French value in
`fr-FR`, so the correction is the one place that does not. English-speaking learners are a stated
audience (Decision 3). Not confirmed by ear: with an English interface and VoiceOver on, miss a
question and listen to the focused correction.

**Fix.** Split the correction into elements, each label in the interface's language and each
French value with `.frenchPronunciation()`, as `voiceover.md`'s "French Value Beside an
Interface Label" does. Or speak the French parts through `Utterer` with `frenchLocaleString`
when the correction appears, as `announcePublishedProperties` does for a Speed Round miss. Do
the same for the choice options and the reason.

<a id="i2"></a>
### I2. The results are announced without the score, and their marks have no label (Reviewer, Low)

When a ranked round ends, `Quiz.completeRound` speaks "Your best: 80" or the streak
(`announceRankedBest`, `announceDailyStreak`, `announceChallengeResult`) and never the score,
and focus stays where the answer field was. A custom quiz, Review, and Sentences end in silence.
In the results list each row's mark is an SF Symbol with no label (`QuizResultView`), so a right
second try (`checkmark.circle`) and a right first try (`checkmark.circle.fill`) sound alike.

**Fix.** Announce the score, or the right answers of the questions asked, before the best, the
streak, or the challenge line, or move focus to it. Give each mark a label from its
`ConjugationResult`.

<a id="i3"></a>
### I3. "et 1 autres" (Run, Low)

`L.PracticeSet.moreVerbs(_:)` has the French "et %lld autres" with no plural form
(`Localizable.xcstrings`, `PracticeSet.moreVerbs`). `PracticeSetView.verbChips` shows twelve
chips, so a shared list of thirteen verbs reads "et 1 autres".

**Fix.** A plural variation, or a singular key chosen by `count == 1` as the other count strings
do.

<a id="i4"></a>
### I4. Two diagnoses say the infinitive is spelled with ç or è (Reviewer, Low)

`Diagnosis.cedilla` is "Devant a et o, %@ s’écrit avec ç, pour que le c reste doux.", which gives
"Devant a et o, commencer s’écrit avec ç". `Diagnosis.graveForE` gives "acheter s’écrit avec è".
A francophone reads both literally, and both are false of the infinitive. "a et o" should be "a
ou o", as the English says.

**Fix.** "Devant a ou o, le c de %@ prend une cédille, pour rester doux." and "Devant un e muet,
le e de %@ prend un accent grave."

<a id="i5"></a>
### I5. "Série" names three things on the Quiz tab (Reviewer, Low)

`PracticeSet.title` is "Série d’exercices", `DailySession.streak*` is "Série : 3 jours", and
`ModelPractice.anotherRound` is "Encore une série". The Speed Round's round is "manche". Phase
22's note saw two of the three.

**Fix.** See [D22](#d22).

<a id="i6"></a>
### I6. Smaller French points (Reviewer, Low)

- `QuizView.gameCenterFailure`: "Game Center a subi un echec." lacks its accent (Run: the catalog
  line). "Game Center a échoué." is more idiomatic.
- `ModelPractice.singleVerb`: "Un seul verbe ne fait pas un modèle, si bien que celui-ci n’a pas
  d’exercice à lui." says one verb does not make a model, on a model's page, and then calls it
  one. The English contrasts pattern with model. Suggested: "Un seul verbe ne fait pas une
  régularité : ce modèle n’a donc pas d’exercice à lui."
- `VerbEssentials.startHint`, `VerbEssentials.fiveMoreHint`, and `ModelPractice.aloneEssentialsHint`
  drop "each": "trois conjugaisons de cinq verbes irréguliers" reads as three, where the English
  says fifteen. `VerbEssentials.description` has "trois conjugaisons chacun".
- `ModelPractice.mixedLocked` says a model is known "once you have answered half of its practice
  right". An item leaves the first box only on a right answer given when it is due, so a learner
  who has just answered a whole round right can still see Mixed closed with this text. Phase 16's
  note records exactly that on the simulator. Say that it can take a second day.
- `AnswerDiagnoser.otherGroup` (`AnswerDiagnosis.swift:450-458`): "That is how verbs like parler
  are conjugated, and ouvrir is not one." Ouvrir, offrir, couvrir, souffrir, cueillir, and
  assaillir are conjugated like parler in the présent, so a learner who has just written
  "j’ouvre" may read the line as false. Name the tense for these verbs.
- `CustomQuiz.description` "Dix questions sur votre choix" (selon), `CustomQuiz.everyVerb` "Les
  %@ verbes" (Tous les), `PracticeSet.kept` "Devenue mon quiz sur mesure", and
  `VerbEssentials.notYetAsked` "pas encore demandée", feminine with no feminine noun spoken.
- "Correct" is said three ways ("Correct.", "Bonne réponse.", "Correct !") and "Incorrect" two
  ("Incorrect.", "Faux.").
- Older than the port, and reached by its clock setting: with the clock shown, VoiceOver says
  "Écoulé : 0 secondes" at the first question and "1 secondes" a second later
  (`L.QuizView.elapsed(seconds:)`), and `QuizView.progressWithColon` is "Progrès", which means
  improvement. "Progression" is the word.

**Fix.** As listed. None misleads but the "each" hints and the Mixed line.

## Gaps and Docs

`python3 scripts/check_docs.py` reports 0 problems. Every identifier in the
`verify-in-simulator` skill's table exists in code, and the nine achievement IDs, the four
leaderboard IDs, and the points in `docs/game_center_setup.md` match `Achievement.swift` and
`QuizLevel.leaderboardID` one by one (410 points). The phase notes are honest: where this review
checked a note's claim against the code, the code did what the note said, with the exceptions
that the findings above name.

<a id="g1"></a>
### G1. Living docs and comments that the code contradicts (Read or Reviewer, as marked; Low)

In `docs/feature_architecture.md`:

- § Levels: no verb outside the core takes more than "one question in fifty". The test's cap is
  one in forty ([T5](#t5)). It also names `QuizDraw.questions(level:count:using:)`, whose
  signature is `questions(level:count:asked:using:)`, and that overload has no caller at all,
  tests included (Reviewer).
- § Quiz, and `docs/project_structure.md`: `CyclingDeck` "reshuffles when it runs out".
  `CyclingDeck.next()` wraps in the same order (Reviewer).
- § Practice Sets: "everyone who opens a set is asked the same tenses and verbs whatever their
  own level" ([L14](#l14), Read); "each é takes nine bytes" ([C9](#c9)); "Opening a set
  (`World.practiceSet` …)", which the browse fixes moved to `SceneRouter`; and a set's quiz
  signals listed without `collection` ([P4](#p4)).
- § The Practice Record: keys are built "so that the widget, which has no verb list, can read
  the record". The widget reads nothing of it, as `PracticeRecord`'s own comment says. "A slip's
  right second attempt counts as right" is true of every repaired diagnosis too ([L2](#l2)).
- § One More Try: "no compound answer falls under the limit" of four letters. "a eu", "a vu",
  "a lu", "a su", "a pu", "a bu", and "a dû" have three, so none can be a slip, while "ai vu" can
  (Reviewer).
- § Speed Round: "Nothing is mastered sooner than three days after its first right answer"
  ([L3](#l3)), the locked line's "a week or more away" ([L5](#l5)), and "across batches too"
  ([T9](#t9)).
- § Daily Challenge: the headline "the same on every device on the same date" needs the
  section's own caveat ([T2](#t2)).
- § Analytics: "never as exact numbers" ([P7](#p7)); the `tab` row's "For `finishSearch` only",
  which then lists quiz signals; and "the session's questions so far (10, 20, …)", where the
  code also sends 3, 5, 15, 30, and a short list's length.
- § Phrases à trous: the script checks "the person against the subject". It checks a pronoun
  subject only ([T9](#t9)).

Elsewhere:

- `docs/game_center_setup.md` § The Leaderboards: "Closing a default quiz's results opens that
  level's board." Phase 13 moved the leaderboard to the hub's foot (Reviewer).
- `Shared/ReviewSchedule.swift:14-15`: "an item missed late in the evening waits until the next
  morning rather than an hour". `dueDate` is the start of the next day, so a miss at 23:58 is
  due two minutes later (Read).
- `Quiz.swift:904-906`, the comment on what a second attempt counts as ([L2](#l2)).
- `QuizView.swift:1488-1491`, `QuizSheet`'s doc comment ([C2](#c2)).
- `KeyConjugations.swift:11` ([F6](#f6)), `FrenchLetterKeyRow.swift:13` ([F9](#f9)),
  `QRCode.swift:13-15` and `PracticeSet.swift:36-37` ([C9](#c9)).
- `PracticeSet.swift:117` ("from `World.handleURL`") and `Deeplink.swift:12` ("`World` looks them
  up"): the browse fixes moved routing to `SceneRouter` and left these.
- `AnswerSlip.swift`, "suis allé for suis allée is a slip": in the quiz it never is, since the
  agreement's diagnosis comes first.
- `docs/voiceover.md` § Pronunciation by Screen describes the one-element correction without
  the consequence its own rule predicts ([I1](#i1)).

**Fix.** Correct each with the phase that fixes its finding, and the rest in the docs phase.

<a id="g2"></a>
### G2. `docs/release.md` lacks the device checks the phases left undone (Reviewer, Low)

Phase 10's note leaves "whether the Camera app offers to open a `conjuguer://` QR code" waiting
on Josh's phone, and the plan's Tasks for Josh repeats it. Phase 22's note says a delivered
notification's tap was not tried. Phase 24's says two real devices and a real midnight were not.
`rg -i 'qr|camera' docs/release.md` finds nothing, and none of the others is there. The first
needs no release: a development build settles it.

**Fix.** Add them: the Camera's offer for a set's code; the same day's challenge on two devices;
a delivered reminder tapped with the app killed and in the background; the hub left open across
midnight ([C1](#c1)); a first launch from a set's link ([C3](#c3)); and a review of App Store
Connect's App Privacy answers against the staged signals.

<a id="g3"></a>
### G3. Comments the port added that the plan's own rule forbids (Reviewer, Low)

Of 2,567 comment lines added since `5bd3650`, 682 are file headers and 1,534 are doc comments,
and most state rationale and pass. The exceptions a reviewer found:

- `Recognition.swift:13`, "(Josh, 2026-11-23)", and `Shared/LearnerVerbs.swift:19`, "(Josh,
  2026-11-25)": attributions in code.
- `ConjuguerTests/Models/SceneRouterTests.swift:117`, "Before Phase 3, one closure and one
  host…": a phase number and change narration, from the browse fixes.
- `Shared/ReviewSchedule.swift:17`, "Konjugieren's pedagogy report proposed these numbers…": a
  citation that is not evidence for a workaround.
- About a dozen doc comments that restate their declaration, among them `QuizScope.collection`
  ("The collection of a collection's own quiz."), `RecognitionPart`, `VerbEssentialsRowLabel`,
  the `current` and `pending` cases in `VerbEssentials.swift`, and `SpotlightIndex`.

**Fix.** Delete or reword them.

<a id="g4"></a>
### G4. `StandardVariants`' tables are keyed by strings that nothing checks (Reviewer, Low)

`StandardVariants` keys its rules by infinitive. `StandardVariantsTests` reaches most of the
single-verb keys through rows that `#require` the verb. Not reached: "déclore" and "forclore" in
`doublet`, and 23 of the 26 infinitives of `traditionallyOpenE`. A misspelled or renamed key
there does not drop a variant. It does the opposite: the verb loses its exemption, and "il
achette" becomes an accepted spelling with no test failing. A reviewer's sweep found every key
in `verbs.xml` today.

**Fix.** One test that every infinitive named in `StandardVariants`, `AnswerDiagnoser.eitherAuxiliary`,
and [F4](#f4)'s new set is a verb.

## Smells, Duplication, and Elegance

<a id="s1"></a>
### S1. The quiz's modes are threaded through one typed path (Read, Medium)

`Quiz.swift` is 1,300 lines. About 300 of them are DEBUG fixtures (`:524-552`, `:578-840`) and
about 165 are VoiceOver announcements, so the session's own logic is some 800. The draw is one
exhaustive switch (`drawQuestions()`), and `QuizScope` has eleven exhaustive switches over its
kind, which the compiler walks a new mode through. That is better than Konjugieren's shape.
What remains:

- **The Speed Round inside `process`.** `!scope.isSpeedRound` gates the diagnosis and the second
  attempt, and `if scope.isSpeedRound` diverts the record and the advance, seven tests in all.
  Every change to the typed path, and [L1](#l1), [L2](#l2), and [L15](#l15) are three, must
  remember the Speed Round's exits.
- **Optional payloads with uneven guards.** `QuizQuestion` carries `recognition`, `sentence`,
  and `choice`, at most one set. `process` guards `choice == nil` and not `recognition`, so a
  recognition question sent to `process` would grade an infinitive as a conjugation and write
  the record, which `submitRecognition` promises never to do. No caller does it today.
- **What the compiler cannot see.** `QuizScope.sessionTitle` is an `if isX` chain.
  `QuizScope.questions(level:asked:using:)` reads `questionCount < Quiz.questionCount` to mean
  Test Me (`QuizScope.swift:373`), so any later short scope over a list would get Test Me's
  draw. "Mixed" is asked three ways (`scope.verbs != nil`, `guard let verbs`, and
  `verbSet.mixesVerbs`) that agree today because of how `QuizVerbSet` is written.
- **Smaller.** The key `"CONJUGUER_QUIZ_FIXTURE"` is a literal in seven places.
  `QuizRandomNumberGenerator.next()` force-unwraps `seeded!`, where `seeded?.next() ??
  system.next()` says the same. `liveActivityState(isFinished:)` computes a state and, as a side
  effect, moves `liveActivityStartDate`, from `Date.now` where the rest of the class uses its
  injected `now()`. `private extension Tense { var isImpératif }` repeats
  `QuizTenseSlot.isImpératif`, and `question(verb:tense:drawn:)` derives the persons again from a
  probe `tense(.secondSingular)` where the slot already has them.

**Fix.** Move the fixtures and the announcements to files of their own. Give a question one
payload enum in place of three optionals. Give the Speed Round its own submit path that shares
grading with `process`. Change no behavior.

<a id="s2"></a>
### S2. `QuizView` is the question, the hub, and the hub's rows (Read, Medium)

`QuizView.swift` is 1,501 lines and declares nine types and a private extension: the question to
about line 672, the hub to about 1,187, then the rows. Six of the types are private, so what
they decide has no test: `QuizRecordSession.hubDetail` (Review's "next due in n days" against
its empty line), `LastQuizResultRow`'s `subjectLine`, `resultLine`, and `relativeDay`, and the
logic of `speedRoundRow`, `challengeRow`, and `masteryRow`. The body does model work on every
render, each read at `.now`: the askable counts, `daysUntilNextDue()`, `streakStatus()`, the
challenge's key and result, a `Mastery`, `GapSentences.askable(at:)`, `SpeedRound.items(from:)`
(which sorts every key of the record), and a new `RelativeDateTimeFormatter`. [C1](#c1) is this
shape's bug. Two smaller copies: "why Start is disabled" is worked out in
`QuizView.customQuizNote` and again in `PracticeSetView.content(_:)`, in different orders, and
`LastQuizResultRow` repeats `QuizHubRowContent`'s layout.

**Fix.** A `QuizHubView` over a model that computes the rows from one injected date and
refreshes when the day changes, which is also [C1](#c1)'s fix. `CustomQuiz` returns a blocker,
and one place turns it into a line.

<a id="s3"></a>
### S3. One rule, written more than once (Reviewer, Low)

- **Stripping pronouns.** `AnswerSpelling` for grading and `ConjugationQuery` for search. They
  already disagree on que ([F2](#f2)).
- **Elision.** `PersonNumber.elides(before:hasAspiratedH:)` folds the letter and tests
  a, e, i, o, u, œ, æ. `Mastery.pronoun(_:before:hasAspiratedH:)` (`Mastery.swift:358`) has its
  own set, which adds y and lacks æ. Grading applies neither ([F11](#f11)).
- **What a level asks.** "The slot is asked, the verb is in the band, the cell exists" is
  written in `QuizDraw.dueQuestions`, `GapSentence.isAskable(at:)`, `ChoiceQuestion.isAskable(at:)`,
  `Mastery`, and `Verb.canBeQuizzed(at:)`. The reminder's count is a sixth place that should ask
  it and does not ([L12](#l12)).
- **Mastered.** `MasteryState.init` and `SpeedRound.masteredItems` each test the box. The Speed
  Round's lock counts mastered items of every level, and the hub's Mastery row counts the
  level's, so "3 of 5 mastered" can sit beside a Mastery row of 0.
- **Days.** `VerbDraw.dayNumber`, `DailyStreak.dayNumber`, and `PracticeRecord.daysBetween`.
- **SplitMix64.** `ConjuguerWidget/Views/QuizWidgetView.swift:99` keeps a private copy,
  `SeededRNG`, of `SeededRandomNumberGenerator`. Phase 24 moved FNV-1a to `Shared/` to end this
  kind of copy and left the generator in `Conjuguer/Utils/`.
- **The content checks.** `scripts/gap_sentences.py` and `scripts/choice_questions.py` each
  write the same loop and helper, and `GapSentenceTests` and `ChoiceQuestionTests` do too. They
  compare accents exactly, so the German plan's fold does not apply here.

**Fix.** One function for each rule, in the phase that touches it.

<a id="s4"></a>
### S4. The record is encoded and written whole after every answer (Suspected, Low)

`PracticeStore.save()` runs `JSONEncoder` over the whole record and writes it to the App
Group's defaults after every answer, lookup, reveal, and snooze, on the main actor, while the
quiz animates to its next question. The item space is about 2,200 (901 patterns at Advanced and
four stems for each of 327 irregular entries), so a long-used record approaches 350 KB. Today's
records are tens of kilobytes. Not measured.

**Fix.** Measure with a seeded 2,000-entry record first. If it shows, coalesce the save to the
end of the run loop's turn or to the scene's leaving the foreground.

## Tests

The prompt asked whether the tests that use `SeededRandomNumberGenerator` prove what they claim.
Mostly they do. `QuizDrawTests` draws 120 seeded rounds a level and asserts exact structural
counts, `QuizScopeTests` uses 200 seeds a test, and `QuizLevelTests` draws 600 rounds with a
tolerance that is about 2.7 standard deviations for the lightest tense, tight enough to fail on
any change of an integer weight. `VerbDrawTests` pins the verb of the day against a
reimplementation. The generator is SplitMix64 with the standard constants, no draw on a quiz
path is unseeded, and no `Set` or `Dictionary` order reaches a seeded draw. The findings below
are the exceptions.

<a id="t1"></a>
### T1. One test leaves overdue items in the shared practice record, so the strongest seeded suites depend on the order of suites (Read; the failures Suspected, Medium)

`QuizSessionTests.aQuitSendsTheQuestionReachedWithoutReasksAndTheDurationInABand` builds its
quiz with a clock at 1970 (`var clock = Date(timeIntervalSince1970: 1_000)`) and misses a
question. `Quiz.process` records the miss in `Current.practice` at that date, so it is due from
1970-01-02. `QuizSessionTests.makeQuiz` never swaps `Current.practice` for a fresh store, and
nothing in the suite restores it (`rg 'Current.practice' QuizSessionTests.swift` finds no line).
Every default quiz started afterward mixes in up to three overdue items
(`Quiz.mixedQuestions`), outside the irregular share and the role counts.

`QuizDrawTests.quizzes(at:)` and `QuizLevelTests.defaultQuizzes` build their rounds once and keep
them in a static. If they are first built while the leak is in place, every one of the 120
rounds a level carries the same due question: `halfOfEachQuizIsIrregular` expects exactly five
irregular questions and gets four, `noVerbOutsideTheCoreDominatesALevel` sees one verb in every
round, and `theDefaultQuizDrawsEachTenseAtItsWeight` gets one tense inflated. The suite is green
today (1,077 passing), so the scheduler happens to build those rounds first or after a suite
that restores the store. Swift Testing promises no such order. `QuizTests`' main suite,
`QuizScopeTests`, `AnswerDiagnosisTests.startedQuiz`, and three `VerbEssentialsSessionTests`
also answer into the shared store with `Date.now`, which falls due at the next midnight, so a
run that crosses midnight is exposed the same way.

To confirm: add `#expect(Current.practice.dueItems().isEmpty)` as that test's last line and run
`QuizSessionTests` alone. To see a victim fail, call the test's body at the top of
`QuizDrawTests.halfOfEachQuizIsIrregular`.

**Fix.** One scoping trait (a `SuiteTrait` and `TestTrait` with `provideScope`) that installs a
fresh `PracticeStore`, saves the quiz level, the pronoun gender, and the analytics double, and
restores them afterward, applied to every suite that starts a `Quiz`. It replaces the
`freshPractice()` and `restorePractice()` pairs that some suites have and others lack
([T7](#t7)).

<a id="t2"></a>
### T2. Nothing pins what the daily challenge draws (Read, Medium)

Phase 24's Done-when is "two devices on the same date get the same challenge … and tests pin the
seeding". `DailyChallengeTests.theSeedIsPinned` pins the seed text and its FNV-1a value.
`theSameKeyDrawsTheSameFive` and `QuizTests.aSeedRepeatsItsQuiz` draw twice in one process and
compare. Those two do catch a stray unseeded call. They cannot catch a reordering of how
`QuizDraw` consumes the generator, a change to SplitMix64, a toolchain change to the standard
library's `Int.random(in:using:)`, `shuffled(using:)`, and `randomElement(using:)`, or a change to
`verbs.xml` that moves a band's edge. Each of those silently changes every day's challenge, the
quiz widget's question, and its wrong answers.

`DailyChallenge.draw`'s own comment concedes the last three ("two devices agree while they run
the same build and the same verbs"). `VerbDraw` avoids the same dependency on purpose for the
verb of the day, and `VerbDrawTests.theFrequentDrawMatchesItsReimplementation` pins ten days.
The challenge has no such test, and its link carries no version: after the 2027 release, a
friend on another version who opens `quiz/challenge?date=…` gets other questions under the same
date, and the shared "35 / 50" compares two different tests. Nothing tells either of them.
[F1](#f1) changes the draw by design, so the question is live for this plan.

`ChallengeQuizTests.everyQuizAsksTheSameFiveWhateverTheSeedTheLevelAndTheRecord` proves less
than its name: it primes `DailyChallenge.questions(for:)`'s static cache and then starts two
quizzes that read it, so a draw that came to depend on the level or the record would still pass.

**Fix.** A golden test, commented as a tripwire: the five cells of one key a level, the widget's
wrong answers for one key, and the first outputs of `SeededRandomNumberGenerator` for two seeds.
Have the cache-bound test call the uncached `draw(for:)` under two settings and two records.
See [D15](#d15) for whether a link must mean the same five questions across versions.

<a id="t3"></a>
### T3. Four single-seed tests would pass with their guarantee deleted (Reviewer, Medium)

Each asserts on one seed something that is true by chance most of the time:

- `QuizSessionTests.tenMoreDrawsVerbsNotYetAsked` (seed 3, Advanced). The plan says it pins that
  "two rounds at Advanced share no verb outside the core". At Advanced the band is every verb, so
  two independent rounds share a non-core verb about one time in thirty. With `asked` ignored
  the test still passes. The property is at stake at Beginner, where it is not tested.
- `VerbEssentialsSessionTests.fiveMoreAsksNewVerbsAndNothingRanksOrIsSent` (seed 8): two rounds
  of five from about 35 verbs are disjoint by chance about 44% of the time.
- `SentenceSessionTests.aRightRoundScoresRecordsAndContinuesWithNewSentences` (seed 7) and
  `GapSentenceTests.aRoundTakesOneSentenceAVerbAndUnaskedOnesFirst` (seed 3): by chance about half
  to 85% of the time.
- `QuizDrawTests.aQuizAsksMostVerbsOnce` asks only that two thirds of a round's verbs be
  distinct, which a draw without `freshVerb` would also meet.

The shares are a reviewer's arithmetic from the sizes of the bands and of `gap_sentences.json`.
To confirm any one, make `QuizDraw.freshVerb` return its first draw and run the test.

**Fix.** Test where chance cannot pass: a pool small enough that the rule is forced (twelve
sentences, ten asked, and the next round must open with the two unasked), or many seeds at
Beginner compared with the same draws given `asked: []`.

<a id="t4"></a>
### T4. Eleven tests cannot fail for what their names claim (Run for the first; Read or Reviewer for the rest, Medium)

- `QuizTests.recordsTheAppsSpellingOfAVariant` takes seed 1's first Elementary question and
  falls back to the plain conjugation when it has no variant
  (`.first ?? Optional(conjugation)`). The probe: that question is fournir's "avons fourni",
  whose variants are empty. So the test types the app's own spelling and expects no shown
  spelling, and the quiz's path for a 1990 spelling is untested.
- `QuizTests.noSeededQuizAsksADefectiveCell` checks `verb.hasCell(question.tense)`, the
  predicate the draw itself uses, so it cannot see a cell that `hasCell` wrongly grants
  ([F5](#f5)).
- `PracticeItemTests.everyIrregularVerbsLookupMatchesItsKeyConjugations` compares two counts
  that are both `keyConjugationsByStem().map(…)`, equal by construction. The invariant that
  matters, that every cell a level asks maps to an item a session can ask back, has eight
  hand-picked cases and missed [F19](#f19).
- `QuizDrawTests.aScopedQuizIgnoresTheBandAndTheShare` uses parler and redonner, both regular,
  so no draw over them could ask an irregular verb whatever the share did.
- `QuizSessionTests.eachRoundsCompletionSendsItsQuestionCountAndNoScore` and the quit test
  assert that the parameters have no `"score"` and no `"elapsedTime"` key. `ParameterKey` has
  neither case and no code writes those strings, so the checks cannot fail ([P5](#p5)).
- `QuizRecordSessionTests.aVerbsKeyConjugationsSitTogetherInTheirOrder` compares the pattern
  slot's verb with itself (`questions[3].verb`) and never checks that the question exercises the
  pattern.
- `WidgetSnapshotWriterTests.testSnapshotWrongAnswersAreNeverSyntheticPadding` has a
  `guard … else { continue }` around its bundle, so it passes with no assertion if the bundle is
  empty.
- `CustomQuizTests.aQuizOverChosenTensesAsksOnlyThemAndPostsNothing` reads
  `signalNames.firstIndex(of: .quizStart) ?? 0`, which checks signal 0 when no start was sent.
- `AnswerDiagnosisTests.aSlipAfterADiagnosisGoesToTheCorrection` appends "q" to the first
  question's answer. If that answer has fewer than four letters it is no slip, and the test
  passes with the one-try limit removed (Suspected: assert the slip before the second
  `process`).
- `QuizPracticeTests.aDefaultRoundTakesAtMostThreeDueItems` records five due patterns and
  asserts that the round holds `>= QuizDraw.dueItemLimit` of them, which is "at least three".
  A round that mixed in all five would pass.
- `PracticeSetTests.theLongestVerbsAListCanHoldStillFitACode` sorts by UTF-8 length, where the
  link's size is the percent-encoded length. It tests a 1,427-byte link against a worst case of
  1,565 (a reviewer's script).

**Fix.** As each line implies. For the variant, start a quiz over connaître, type "connait", and
expect `shownSpelling`.

<a id="t5"></a>
### T5. One cap was fitted to its sample (Reviewer, Low)

`QuizDrawTests.noVerbOutsideTheCoreDominatesALevel` asserts `count * 40 <= questions.count`.
Phase 7's note records that définir was 19 of 896 non-core questions against the old cap of one
in fifty, so the cap became one in forty. That is 0.8 of a standard deviation above the observed
count, so any change that reorders how the generator is consumed re-samples the count and fails
the test about one time in five with no change in the true distribution.
`docs/feature_architecture.md` still says one in fifty.

**Fix.** Assert the share a verb's pool and bucket predict, within a few standard deviations, or
raise the sample from 120 rounds to 600.

<a id="t6"></a>
### T6. Two tests read the wall clock (Reviewer, Low)

- `QuizSessionTests.eachRoundsCompletionSendsItsQuestionCountAndNoScore` builds its quiz with
  the default `now` and expects the duration band "0-3s" after two rounds, 21 answers, and a
  second draw. Phase 6's and Phase 7's notes record the suite's time swinging from 129 to 228
  seconds on this Mac.
- `DailySessionQuizTests.finishingReschedulesTheReminderWhileItIsOn` finishes "at `.now`" with
  the real calendar and the default 18:00. Run after 18:00, today's reminder is left out because
  its time has passed, so the test passes with the done-day check deleted. Run across midnight,
  it fails.

**Fix.** Inject a fixed `now` and a calendar, as the quit test and the pure
`DailyReminderPlan` tests do.

<a id="t7"></a>
### T7. Shared state is restored unevenly, and six comments misstate what protects it (Reviewer, Low)

Eleven helpers set `Current.settings.quizLevel` and never restore it (`makeDeterministicQuiz`,
the `makeQuiz` and `started` helpers of the choice, sentence, recognition, Verb Essentials,
record, Speed Round, daily, and challenge suites, `QuizSessionTests.makeQuiz`, and
`AnswerDiagnosisTests.startedQuiz`), and those that restore it restore Elementary, where the
default is Beginner (`Settings.quizLevelDefault`). No test fails from it today, since each sets
the level it needs.

Six files open with "Nested in QuizTests so that its .serialized trait keeps these from racing
it over Current". Every one of these tests is synchronous and `@MainActor`, so no two
interleave, and nesting does not stop the top-level suites from leaving `Current` changed, which
is [T1](#t1). The answering helpers (`correctAnswer(for:)`, `answerAllCorrectly`) are written
four times, in `QuizTests`, `QuizSessionTests`, `QuizLeaderboardTests`, and `QuizScopeTests`,
and Phase 6's note records one copy once passing `extraLetters: nil` and failing on sortir.

**Fix.** [T1](#t1)'s trait, the helpers moved to `TestUtils.swift`, and the comments rewritten
to say what protects.

<a id="t8"></a>
### T8. What depends on the simulator's language and on today's data (Reviewer, Low)

The suite passes with the simulator in English, which this review confirmed before trusting the
run. By reading, these fail in French: `AnswerDiagnosisTests.theLinesReadInEnglish` (by design),
`DailyChallengeTests.aResultCountsItsOutcomes` and `theSharedTextIsTheApprovedOne`,
`QuizLevelTests.eachLevelHasAName`,
`GapSentenceTests.aCompoundTensesFrameMarksTheGenderBesideTheBlank`, and `LocalizationTests`.
Everything else compares `L.*` with `L.*`.

Six assertions hold today's counts with no comment saying so:
`MasteryTests.eachLevelShowsItsBandsPatterns` ([46, 223, 368, 901]),
`theVerbsAreTheBandsMostUsedIrregularVerbs`, `spellingChangeModelsShowOnlyTheirChangedCells`,
`ModelPracticeTests.aModelIsItsTenMostFrequentAskableVerbs`, and
`theListIsTheModelsPracticedAloneByUse`. A fix to `verbs.xml` breaks them without a bug.

The scheme's test action already sets the language to `en` and the region to `US`
(`Conjuguer.xcscheme:29-30`), so `run_tests.sh`, which builds the scheme, runs in English
whatever the simulator's language. Whether a raw `xcodebuild` honors the scheme's setting was
not tried.

**Fix.** Try it once with the simulator in French, and say in `CLAUDE.md` § Build and Test
Commands what was found, so that the Closing's warning about the simulator's language is either
retired or kept with its reason. Mark the counts as tripwires in a comment, as the browse fixes'
Phase 13 did for its own.

<a id="t9"></a>
### T9. What has no test (Reviewer, Low)

- **A record written in an earlier shape.** `PracticeRecord.Entry`'s comment warns that a field
  added without being optional empties every learner's record. The only test is an
  encode-then-decode round trip, which passes whatever the fields are. `QuizHubTests` does pin
  `LastQuizResult`'s stored JSON, so the pattern exists. Pin one literal each for
  `PracticeRecord`, `DailyStreak`, and `DailyChallengeResult`.
- **Grading under the masculine and "both" settings.** `ConjugationResultTests.gradesAnswer`
  builds every answer with `.feminine`.
- **The catalogs.** No test checks that every key has a translated French value, that French
  punctuation carries U+202F, or that specifiers agree. This review ran those checks by script,
  and they pass, apart from two accessors older than the port, `Info.purposeAndUseHeading` and
  `Info.purposeAndUseText` (`L.swift:762-768`), which have no catalog entry and no caller.
- **The content's elision and gender.** `scripts/gap_sentences.py check` sees only a pronoun
  subject, tests nothing about "je {a…}" against "j’{a…}", does not compare a `gender` key with
  the sentence's subject, and prints "0 problems" without checking forms when
  `corpus/working/conjugations.json` is absent. A reviewer's script over all 750 sentences and 66
  items found no such error today. `docs/feature_architecture.md` § Phrases à trous says the
  script checks "the person against the subject".
- **The Speed Round across batches.** `QuizDraw.speedRoundQuestions` keeps `lastVerbByItem`
  within one call, so a pattern can be asked of the same verb at the end of one batch and the
  start of the next. `aPatternAsksAnotherVerbOfTheBandEachTime` draws one batch.
  `docs/feature_architecture.md` § Speed Round says each item is asked once before any is asked
  again "across batches too", which holds only for "never twice running".
- **The hub's rows.** `QuizRecordSession.hubDetail` is private to the view file, and
  `QuizHubTests` tests only `LastQuizResult`.
- **What [L1](#l1) and [L2](#l2) turn on.** No test reads `missedItems()` after a right
  re-ask, and none reads the record's entry after a repaired diagnosis.
  `aRightReaskEarnsHalfPointsAndCountsApart` and `aRightRepairEarnsHalfPoints` check points.
- **The challenge's key around midnight and across a change of time zone**, the choice
  question's exclusion over more than one Ten More, `DailyChallenge.draw` when all twenty
  attempts repeat a verb, and a mixed model practice whose known models change between rounds.
- **The fixture default.** `Quiz.drawQuestions` and `SpeedRound.items(from:)` read
  `UserDefaults.standard`'s `CONJUGUER_QUIZ_FIXTURE` in DEBUG with no guard for unit tests. The
  test host reads the simulator's defaults, so a value left by a session's `defaults write`
  would swap a fixture into the suite's draws. Konjugieren's journal records that happening.
- **Whether every pattern can be drawn.** No test shows that each of the 901 Advanced patterns
  is reachable by some slot, pool, and band verb, which The Keystone achievement assumes.

## Konjugieren's Findings, Checked Here

Konjugieren's code got the same review, in
[`../Konjugieren/plans/pedagogy_fixes.md`](../../Konjugieren/plans/pedagogy_fixes.md), with 62
findings. Each was checked against Conjuguer's code after this review's own findings were
written. "Carried over" means the defect is here too, "French form" that its counterpart is,
and "Did not" that the port does it differently. Konjugieren was not changed.

### What the Learner Is Taught

| Theirs | Verdict | Here |
|---|---|---|
| L1, conjugations German lacks | Mostly did not: the data marks defective cells and every draw reads them | [F5](#f5), [F20](#f20) are the two holes |
| L2, a right re-ask and My Mistakes | Carried over | [L1](#l1) |
| L3, a repaired diagnosis counts as right | Carried over | [L2](#l2) |
| L4, grammatical errors called slips | French form. The digraph's minimum does not apply | [L15](#l15) |
| L5, an answer credits a key conjugation it never showed | Carried over, and wider in French | [F6](#f6) |
| L6, two reveals master a verb | Carried over | [L3](#l3) |
| L7, a page opened erases the record | Carried over | [L4](#l4) |
| L8, untrue diagnoses | The mechanism did not: no check here runs before the cell check and hides a real cell. French has untrue lines of its own | [F4](#f4), [F7](#f7), [F13](#f13) |
| L9, a round asks the same question twice | Did not: `AskedCell` and `freshVerb` keep a round's cells distinct | |
| L10, a custom quiz lifts the level's restrictions | Did not: a level restricts only tenses here | |
| L11, the mix holds for the draw, not the round | Partly: the choice question does not break it, due items do | [L16](#l16) |
| L12, a quit challenge retaken | Carried over | [L7](#l7) |
| L13, "the same on every device" | Carried over | [T2](#t2) |
| L14, the choice's coin flip and its English | Carried over, and the English tells more in French | [L6](#l6), [L9](#l9) |
| L15, the Speed Round's clock counts ticks | Carried over | [L13](#l13) |
| L16, due items in a ranked round | Carried over | [L9](#l9) |
| L17, the reminder's count | Carried over | [L12](#l12) |
| L18, small points in the sentences | French form | [L19](#l19), [F16](#f16), [F21](#f21) |
| L19, a dismissed card hides its items | Carried over | [L17](#l17) |
| L20, the correction marks an accepted digraph | French form: an accepted 1990 letter | [L18](#l18) |
| L21, the frame's own word is wrong | Partly: the "!" only | [F10](#f10) |

### Correctness and Privacy

| Theirs | Verdict | Here |
|---|---|---|
| C1, reminder reschedules unordered | Carried over | [C7](#c7) |
| C2, the store keeps its launch calendar | Did not: the store is autoupdating | [C5](#c5) is a different calendar defect |
| C3, a session across midnight | Carried over | [C6](#c6) |
| C4, the Swiss region in recognition | Does not apply, and no French counterpart was found | |
| C5, an undecodable record replaced | Carried over | [C8](#c8) |
| C6, the injected clock reaches only the streak | Did not: `Quiz` passes `now()` throughout, bar the Live Activity's display | [S1](#s1) |
| C7, smaller holes in the challenge | Carried over, all four | [L8](#l8), [C1](#c1) |
| C8, the cap and the QR code | Carried over, with a cap of 50 | [C9](#c9) |
| C9, a shared My Verbs carries recent lookups | Carried over | [C9](#c9) |
| P1, a one-verb group's quiz names its verb | The key did not: `model` is sent for every model. The count did | [P1](#p1) |
| P2, Share left open on a correction's link | Did not: no share signal here names a model | |
| P3, a second round of My Mistakes | Carried over | [P3](#p3) |
| P4, sources that follow accuracy | Carried over | [P2](#p2) |
| P5, P6, P10, staged paragraphs and a comment | Did not: the paragraphs here hold | |
| P7, "(not which)" | Partly: untrue of the three fixed lists | [P4](#p4) |
| P8, Decision 5 held by vigilance | Carried over | [P5](#p5) |
| P9, the analytics vocabulary decides behavior | Carried over, at two sites | [P6](#p6) |

### Docs, Structure, and Tests

| Theirs | Verdict | Here |
|---|---|---|
| G1, G2, G4, docs and comments the code qualifies | Partly | [G1](#g1), [L5](#l5) |
| G3, `release.md` lacks the Camera's QR check | Carried over | [G2](#g2) |
| G5, `StandardVariants` keyed by unchecked strings | Partly | [G4](#g4) |
| S1, every mode a parallel path | Partly, milder: one exhaustive switch for the draw | [S1](#s1) |
| S2, `QuizView` is three things | Partly: the cards already share one modifier | [S2](#s2) |
| S3, the kind and its fields can disagree | Partly: the cases carry their state | [S1](#s1) |
| S4, S5, one rule written several times | French form | [S3](#s3) |
| S6, S7, the exclusion keys and Reset Practice in a view | Did not | |
| S8, small things | Partly: the widget's generator | [S3](#s3) |
| T1, tests of a count the code no longer guarantees | Partly: a leaked due item breaks them, the choice does not | [T1](#t1) |
| T2, determinism tests | Partly: the challenge's draw is unpinned, the verb of the day's is pinned | [T2](#t2) |
| T3, T4, single-seed tests and tests that cannot fail | Partly, with different tests | [T3](#t3), [T4](#t4), [T6](#t6) |
| T5, T6, corpus-tied counts and shared state | Carried over | [T8](#t8), [T1](#t1), [T7](#t7) |
| T7, the suite depends on the simulator's language | Did not: the scheme's test action is already English | [T8](#t8) |
| T8, both content checks fold ß | Did not: accents are compared exactly. The duplicated loop did | [S3](#s3) |
| T9, what has no test | Carried over | [T9](#t9) |

### What Each Review Found That the Other Did Not

Of Konjugieren's 62 findings, 30 carried over whole or in a French form, 19 in part, and 13 not
at all. Ten of those that carried over were found here only through this comparison
([Method](#method)), which is the argument for making it.

This review found what Konjugieren's could not, because it is French: the subjonctif's missing
stems ([F1](#f1)), que ([F2](#f2)), the agreement cases ([F4](#f4), [F7](#f7), [F12](#f12)),
the auxiliaries ([F13](#f13)), the il form's weakness as a key ([F6](#f6)), the weight of
French's many compound tenses ([F17](#f17)), and the authored French ([F14](#f14) to
[F16](#f16)). It also found things that are not French and that Konjugieren's review does not
have: the hub across midnight ([C1](#c1)), a link during a sheet's quiz ([C2](#c2)) and under
onboarding ([C3](#c3)), the empty Return ([C4](#c4)), the streak's calendar ([C5](#c5)), a set
over a collection asking each student's band ([L14](#l14)), the mastered text against the rule
([L5](#l5)), a record session's duration ([P3](#p3)), the SDK's defaults ([P7](#p7)), the
correction's voice under VoiceOver ([I1](#i1)), and the record leaking between suites
([T1](#t1)). The Closing says which of those would carry over there.

## Decisions for Josh

Each was a question the code cannot settle. **Josh answered all twenty-three on 2026-11-27**,
and the answer follows each decision. The options are kept so that a later reader can see what
was weighed. Where he had ruled on the same question for Konjugieren that day, the option he
chose there is marked **(Konjugieren)**. Build to the answer. Where an answer leaves a list or a
line for Josh to review, the phase says so, and its session brings him that before building on
it. Where an answer does not settle a question that comes up, the session asks him, does not
guess, and records his answer and its date under the decision here and in the phase's **How it
differed**.

<a id="d1"></a>
**D1. When does a miss leave My Mistakes?** ([L1](#l1))

- (a) On a right answer that is neither a re-ask nor a repaired second attempt: in a later
  question on the same item, or in My Mistakes itself. **(Konjugieren)**
- (b) As now, on any right answer, the re-ask's included.

**Answered (Josh, 2026-11-27): (a).** A right re-ask and a right second attempt, a slip's included,
leave the miss on the list.

<a id="d2"></a>
**D2. What does a repaired diagnosis do to the record?** ([L2](#l2))

- (a) It counts as wrong: the item starts over and enters My Mistakes. The half points stay. A
  slip's repair still counts as right, once [L15](#l15) has made a slip mean a typing slip.
  **(Konjugieren)**
- (b) It counts as neither: the item keeps its box and its due date, and enters My Mistakes.
- (c) As now, it counts as right.

**Answered (Josh, 2026-11-27): (a).**

<a id="d3"></a>
**D3. How far can the review card raise an item, and what does dismissing it do?**
([L3](#l3), [L17](#l17))

- (a) A reveal raises an item no further than the second box, so that only a typed answer
  reaches mastery, and an item already there is rescheduled at its own box. A card dismissed
  unrevealed is hidden for the day, and its items stay due for Review and the daily session.
  **(Konjugieren)**
- (b) After the reveal the card asks "Knew them" or "Didn't", and only the first raises.
- (c) A reveal reschedules and never raises.
- (d) As now.

**Answered (Josh, 2026-11-27): (a).** This replaces the browse plan's rules that a revealed card
always moves an item up and that a dismissal snoozes it.

<a id="d4"></a>
**D4. When does opening a verb's page send its key conjugations back to the first box?**
([L4](#l4), [P6](#p6))

- (a) Only from search, the one route that says "I had to look this up". Every other route
  enters a verb's items if they are new and demotes nothing. The Mastery page's verbs can then
  link to their pages. **(Konjugieren)**
- (b) Never. A lookup only enters items that are not yet in the record.
- (c) From any route, but one box down.
- (d) As now.

**Answered (Josh, 2026-11-27): (a).** This replaces his earlier rulings, the widget's of 2026-11-25
included. Test Me's right answers can then raise an item.

<a id="d5"></a>
**D5. What does "mastered" mean?** ([L5](#l5))

- (a) What the code does: an item that has reached the third box, until a wrong answer. The
  text changes to say so, in both languages, for Josh to review.
- (b) What the text says: an item whose next review is a week or more away. An item that comes
  due falls back to "learning" until it is answered, on the Mastery page, in the Speed Round's
  pool, and for achievements not yet earned.
- (c) In between: mastered at the third box, and back to learning once it is overdue by more
  than its own interval.

**Answered (Josh, 2026-11-27): (a).** The Mastery page's introduction and the Speed Round's locked
line are rewritten in both languages for him to review, and they say that a lookup from search
starts a form over ([D4](#d4)).

<a id="d6"></a>
**D6. Which cell does an irregular verb's key conjugation ask back, and which answers raise it?**
([F6](#f6))

- (a) The record remembers the cell last missed for each key conjugation, as an optional field.
  Review and My Mistakes ask that cell, and the il form when there is none. A wrong answer on
  any cell of the stem still sends the item back. A right answer raises it only on a cell that
  shows what the il form shows or more: for the présent, a person of the présent or the
  impératif (not the imparfait, the subjonctif, or the participe présent), and for the passé
  composé, a cell with its auxiliary. This is Konjugieren's ruling with the missed cell added.
- (b) Split the présent: an irregular verb whose présent has more than one stem gets an item
  for each (the singular, nous and vous, ils), each asked and mastered on its own. The Mastery
  page, the achievements, and the stored keys change with it.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** The field is optional, so that a record written before it
still decodes.

<a id="d7"></a>
**D7. Should Verb Essentials reach a verb's second présent stem?** ([F6](#f6))

- (a) A fourth blank, the ils présent, for a verb whose présent has a stem the il form does not
  show (boivent, viennent, plaignent, font), in Verb Essentials and in a model's practice. The
  verb page's three key conjugations stay as Josh chose them on 2026-11-22.
- (b) The fourth blank in a model's practice only.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** Which verbs have "a stem the il form does not show" is read
from the data, and the session brings Josh the list of models it finds before building on it.

<a id="d8"></a>
**D8. Should the subjonctif's frame show que?** ([F2](#f2))

Stripping a typed "que" is not in question: this plan does it either way.

- (a) Yes: `que je ______`, `qu’il ______`, as French tables print it, with VoiceOver saying it.
- (b) No: the frame stays `je ______`, and a typed que is forgiven.

**Answered (Josh, 2026-11-27): (a).**

<a id="d9"></a>
**D9. Which of these should grade as right?** ([F7](#f7), [F9](#f9), [F12](#f12), [F13](#f13))

Each is correct French that the quiz marks wrong today. Any not chosen stays wrong, and is then
named by a line of its own where it now gets "Almost!" or a false line.

- (a) "vous êtes allée", a singular agreement with vous.
- (b) "allée", "allés", or "allées" for a participe passé question, with the masculine singular
  shown beside the checkmark.
- (c) "oe" for œ, with œ shown beside the checkmark.
- (d) Avoir for monter, descendre, sortir, rentrer, retourner, and demeurer, as for passer.

**Answered (Josh, 2026-11-27): all four.** For (d), the participle does not agree with avoir, as
for passer. The session checks each of the six against a dictionary and tells Josh if one of them
does not take avoir in standard use.

<a id="d10"></a>
**D10. How strict is grading with the pronouns a learner types?** ([F11](#f11))

- (a) A wrong elision or a dropped reflexive ("je ai parlé", "j’parle", "je souviens") earns one
  more try with a line that names it, for Josh to review in both languages. Under [D2](#d2) the
  repair then counts as [D2](#d2) says.
- (b) Wrong at once.
- (c) As now: accepted, since the quiz asks the verb and not the pronoun.

**Answered (Josh, 2026-11-27): (a).**

<a id="d11"></a>
**D11. Which changes to the authored content?** ([L6](#l6), [F14](#f14), [F15](#f15), [F16](#f16))

- (a) A choice question's English shows after the choice, with the reason. **(Konjugieren)**
- (b) The three history-book passé simple items go, the three story items get a frame that is
  already in the passé simple, and the reason is narrowed to a literary narrative.
- (c) "Pourriez-vous" and "Sauriez-vous" are replaced by items whose indicatif is plainly curt.
- (d) The 35 subjonctif sentences whose blank is also the indicatif are redrafted with a person
  or verb that tells the two apart, and the script warns of any new one.

Josh reviews every new or redrafted item before it ships, as he reviewed the originals.

**Answered (Josh, 2026-11-27): all four.**

<a id="d12"></a>
**D12. Should the auxiliary-only tenses be weighted as a class at Advanced?** ([F17](#f17))

- (a) Yes: together they weigh what one ordinary tense does or a little more (say 3 of the
  round's weights, against 8 of 30 now), shared among the eight.
- (b) Halve them: every other weight doubles, so the eight weigh 8 of 52.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** The session proposes the weights and shows what an Advanced
round then asks over many seeds, and Josh approves them before they ship.

<a id="d13"></a>
**D13. What does a default quiz's first round hold?** ([L9](#l9), [L16](#l16))

- (a) No due items in the first round, which is the ranked one. Ten More, the daily session,
  and Review ask them. The mix is a promise about the whole round of ten. The choice question
  stays and its ten points count. **(Konjugieren)**
- (b) As (a), and the choice question's points are left out of the posted score.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** This narrows his ruling of 2026-11-23 that a default round
mixes in up to three due items: the first round has none.

<a id="d14"></a>
**D14. When is a challenge taken?** ([L7](#l7))

- (a) From its first answer. Quitting it, or leaving the app during it, ends it with the
  unanswered questions counted wrong. **(Konjugieren)**
- (b) It may be taken again after a quit, and a result reached that way cannot be shared.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).**

<a id="d15"></a>
**D15. Must a challenge link mean the same five questions across versions of the app?**
([T2](#t2))

- (a) No: "the same within a version". The docs say so, the link carries a content version, and
  the app says when a friend's link comes from another one. A golden test makes any change to
  the draw deliberate. **(Konjugieren)**
- (b) Yes, by freezing a versioned list of verbs for each level, so that a change to `verbs.xml`
  leaves challenges alone.
- (c) Yes, by putting the five questions in the link.

**Answered (Josh, 2026-11-27): (a).**

<a id="d16"></a>
**D16. Which of these smaller rulings?** ([L8](#l8), [L10](#l10), [L11](#l11))

- (a) A challenge link opens only yesterday's, today's, or tomorrow's challenge by the device's
  date, and a result is kept for a week, not for the newest twelve.
- (b) The quiz widget asks a cell of the challenge's first verb other than the challenge's own,
  so that it never shows an answer the challenge then asks.
- (c) A miss in a round's last two questions is not re-asked in the round. The record already
  makes it due.
- (d) In Name the Conjugation, the person counts as a right part only together with a right
  tense.

**Answered (Josh, 2026-11-27): all four.** (c) changes Phase 7's "re-asked before the results": a
miss on question 9 or 10 waits for the record.

<a id="d17"></a>
**D17. Does leaving the app pause the Speed Round?** ([L13](#l13))

- (a) No. The minute is a minute, measured in time and not in ticks. **(Konjugieren)**
- (b) Yes, on purpose: the round pauses when the app is not active, and says so.

**Answered (Josh, 2026-11-27): (a).**

<a id="d18"></a>
**D18. Which privacy rulings?** ([P2](#p2), [P3](#p3), [P7](#p7), [P8](#p8))

- (a) `mistakes`, `quizCorrection`, `speedRound`, and `modelMixed` are surfaces, not accuracy,
  and stay. The ruling is recorded here and the staged text says what each implies.
  **(Konjugieren)**
- (b) A Review or My Mistakes session sends one `quizCompletion`, at its first round, and no
  `duration`. **(Konjugieren, for the first half)**
- (c) The policy names TelemetryDeck's default parameters. Not chosen means the session turns
  off those that `TelemetryDeck.Config` allows and brings Josh the list.
- (d) Reset Practice also resets the Game Center achievements. Not chosen means the Settings
  text and the policy say that achievements already earned stay.

**Answered (Josh, 2026-11-27): all four.** So the four sources stay, a record session sends one
completion and no duration, the policy names the SDK's defaults, and Reset Practice resets the
achievements too, which its alert must then say.

<a id="d19"></a>
**D19. Which verbs does a set shared over a collection ask?** ([L14](#l14))

- (a) The sharer's: the set always carries the sharer's level when its verbs are a collection,
  so every student is asked that band first.
- (b) The whole collection, with no band, for a set. A collection's own quiz keeps the
  learner's band.
- (c) As now, each student's own band, with the docs corrected.

**Answered (Josh, 2026-11-27): (a).**

<a id="d20"></a>
**D20. What does a shared list carry, and how long may it be?** ([C9](#c9))

- (a) A shared My Verbs carries the starred verbs alone. A QR code carries up to 30 verbs and a
  link up to 100, and the QR screen says so when the list is longer than its code carries.
  **(Konjugieren)**
- (b) The starred verbs alone, and the cap stays at 50 for both.
- (c) As now, with the menu saying how many verbs go and how many were left out.

**Answered (Josh, 2026-11-27): (a).**

<a id="d21"></a>
**D21. What does a link do while a sheet's quiz is under way?** ([C2](#c2))

Either way the sheet's quiz ends properly: `quizQuit` is sent, what was answered is kept, and
the timer stops.

- (a) The link waits: it opens when the quiz is quit or finished, as a `quiz/start` link is
  ignored while the tab's quiz runs.
- (b) The link replaces the quiz at once.
- (c) The app asks, with an alert, before closing the quiz.

**Answered (Josh, 2026-11-27): (a).**

<a id="d22"></a>
**D22. Which French word for which thing?** ([I5](#i5))

- (a) "Série" for the streak alone. A round of model practice and of Verb Essentials is a
  "manche", as the Speed Round's is. A practice set is a "fiche d’exercices".
- (b) "Série" for the streak and for the practice set ("série d’exercices"), and "manche" for a
  round.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).** He reviews each changed line.

<a id="d23"></a>
**D23. What of a pronominal verb's passé surcomposé?** ([F20](#f20))

- (a) The quiz stops asking it: the draw leaves pronominal verbs out of that tense. The verb
  page and the conjugator are left alone.
- (b) The conjugator learns the form, so that the page and the quiz are both right.
- (c) As now.

**Answered (Josh, 2026-11-27): (a).**

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies
are done. Each phase names its dependencies. Phase 1 comes first because every later phase adds
tests to suites it repairs. If a phase proves too large for one session, split it, say so in its
row, and leave the remainder "Partly done".

**Find code by name.** Every finding gives a type and a function with its line. The line is that
of `945e5e9` and will drift as phases land.

**A finding labelled Suspected or Reviewer is not yet a fact.** Confirm it in the code, or by
running something, before fixing it. If it turns out not to be real, say so under the finding
and in **How it differed**, and move on.

**Ask Josh rather than guess.** His answers of 2026-11-27 are under
[Decisions for Josh](#decisions-for-josh), and each phase restates the ones it builds. Where an
answer does not settle a question that comes up, ask him before building the part that depends
on it, and record his answer and its date in **How it differed** and under the decision.

**What this plan leaves to you.** The phases say what to fix and what must hold afterward. Each
finding suggests a fix, and a better one is welcome. Record in **How it differed** anything that
departs from the phase as written. A later session relies on that note more than on the phase
text.

**Every phase finishes the same way.**

1. Each fix gets a test that fails without it, following `.claude/rules/swift_testing.md`. Run
   the new test against the old code first and see it fail. Where a property is guaranteed by
   construction, test it over many seeds or on a pool small enough that chance cannot pass it
   ([T3](#t3) is what happens otherwise). Inject dates, and do not read the wall clock.
2. Build and run the suite with the `ios-build-verify` skill, as `CLAUDE.md` describes. **Read
   the run's test count, not only its exit status.** The baseline at `945e5e9` is 1,077 tests in
   100 suites, all passing, with Conjuguer's iPhone simulator in English.
3. Run `swiftlint lint --strict` on the Swift files you changed. The pre-commit hook does the
   same to staged files, and `CLAUDE.md` § Linting names the rule that bounces most commits.
4. For a change a learner can see, launch the app and look, following the `verify-in-simulator`
   skill: on the iPhone in French and in English, and on the iPad in English. **Use only
   Conjuguer's own simulators**, "Conjuguer iPhone 17"
   (`AD93C7DA-EB19-4969-9291-44B92B66C3D9`) and "Conjuguer iPad Pro 11"
   (`2BD23264-485B-458D-9B00-895F29CED397`), and name the UDID in every `simctl` command. Boot
   the iPad only for its check and shut it down after. Never restart CoreSimulator without
   asking Josh. Do not erase the app's data on these simulators: the practice record there is
   what earlier checks built. The quiz's `CONJUGUER_QUIZ_FIXTURE` default gives fixed questions.
   Remove the default afterward ([T9](#t9) says why). Say in **How it differed** what was tried
   on each device.
5. Localize any new or changed string in English and French, following
   `.claude/rules/localization_catalog.md`, French punctuation included. **Josh reviews every
   new or changed line a learner reads, in both languages, before it ships.** A new state needs
   a VoiceOver announcement a learner can act on ([`docs/voiceover.md`](../docs/voiceover.md)).
6. A change to a signal, a parameter, or a value is staged in
   [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages and
   reflected in [`docs/feature_architecture.md`](../docs/feature_architecture.md) § Analytics. No
   signal may carry an answer, a score, a count of right or wrong answers, or a verb.
7. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, correct any other doc the fix makes untrue ([G1](#g1) lists those already
   untrue), keep the `verify-in-simulator` skill's identifier table true, and run
   `python3 scripts/check_docs.py`. A task left for release time goes in
   [`docs/release.md`](../docs/release.md).
8. Under each finding fixed, in this file, add a line saying it was fixed on `main`, with the
   date and the phase, and how if not as suggested. Fill in the Status row with "Awaiting Josh",
   write **How it differed**, and append a journal entry to `docs/blog_notes.md`.
9. **Stop before git.** Do not run `git add`, `git commit`, or `git push`. Tell Josh what
   changed and how to try it: which screens to open, and what to type or tap. When he says he
   has tried it and to commit, commit and push to `main`, set the row to "Done", and record the
   hash in the Commit cell with a one-line follow-up commit, since a commit cannot contain its
   own hash. This holds for every phase and the Closing.

**A probe is not a test.** A temporary suite that prints what the code does is a good way to
confirm a finding. Delete it before the phase's final run.

**Subagents.** No phase needs them. A session that drafts sentences or choice items with
subagents (Phases 8 and 9) uses Sonnet for the drafting, as the pedagogy plan decided, runs the
machine check itself, and reads every draft before Josh does.

**No release before 2027.** Everything accumulates on `main`. Nothing here has reached a
learner, so no stored format needs a migration unless the code already promises one. A new
field of a stored record is optional all the same ([C8](#c8)).

**Conjuguer only.** Do not port a fix to Konjugieren or Conjugar. The Closing lists what would
carry over.

## Decisions Already Made

These bound the fixes. Each is Josh's, with its date, from the pedagogy plan and the browse
fixes.

- **Practice, not examination** (Decision 2). Where a choice between the two arises, choose
  practice.
- **No signal carries an answer, a score, a count of right or wrong answers, or a verb**
  (Decision 5).
- **Agreement with être stays required**, following the pronoun-gender setting, feminine by
  default (2026-11-22). [D9](#d9) adds two spellings of an agreement. It does not relax this.
- **The 1990 rectifications are accepted in the quiz only**, with the app's spelling shown
  beside the checkmark (2026-11-22).
- **A right second attempt and a right re-ask earn half points** (T1.6). No fix here changes
  points.
- **Re-ask once, not until correct** (T3.1).
- **Every class of diagnosis prompts a repair**, and one line serves the prompt and the
  correction. [D2](#d2) rules what the repair does to the record, not whether to prompt.
- **Levels are chosen, not earned** (T2.4).
- **The key conjugations are il's présent, passé composé, and futur** (2026-11-22), with a
  fourth item, the passé simple, that the card does not show (2026-11-23). The third group and
  aller are learned verb by verb, and the rest by pattern (2026-11-23).
- **A challenge is taken once**, and it asks no re-ask.
- **The Speed Round records nothing in the practice record**, and recognition and choice
  answers do not either.
- **Reset Practice keeps the challenge results** and clears the first opens (2026-11-25).
- **No "principal parts" and no "temps primitifs"**, in the interface or in a code name.

Josh's twenty-three answers of 2026-11-27 are under [Decisions for Josh](#decisions-for-josh).
Five of them replace an earlier ruling: [D3](#d3) the review card's, [D4](#d4) the lookup's,
[D13](#d13) the due items' place in a default quiz's first round, [D16](#d16) the re-ask before
the results, and [D18](#d18) what Reset Practice resets.

Defaults this plan chose without asking, because the review left one reasonable course. Josh
may overrule any of them:

- **[F2](#f2).** A typed "que" or "qu’" before a subjonctif is forgiven.
- **[F4](#f4).** The participles of se complaire, s’entre-nuire, and s’arroger do not agree
  with the subject, s’arroger's because tables print it so.
- **[F10](#f10).** The frame's own "!", typed into the blank, is forgiven.
- **[F18](#f18).** A pool is weighted by what the band holds.
- **[L15](#l15).** An edit inside the letters the conjugator marks irregular is not a slip, and
  the cell check takes the spellings grading takes.
- **[C6](#c6).** A daily session counts for the day it began.
- **[P1](#p1).** A scope whose verbs are a list, and a model's practice, send no question count.

## Phase 1: A Test World That Cleans Up After Itself

**Findings:** [T1](#t1), [T7](#t7). **Depends on:** nothing. **Decisions:** none.

- One scoping trait that installs a fresh `PracticeStore`, and saves and restores the quiz
  level, the pronoun gender, and the analytics double. Every suite that starts a `Quiz` takes
  it, and the `freshPractice()` and `restorePractice()` pairs go.
- The answering helpers move to `TestUtils.swift`, written once.
- The six "nested so that .serialized keeps these from racing" comments say what protects.
- A guard, in DEBUG, so that the unit-test world never reads `CONJUGUER_QUIZ_FIXTURE` from the
  simulator's defaults unless a test sets it ([T9](#t9)).

**Done when** `aQuitSendsTheQuestionReached…` ends with the shared record empty, the leak
reproduced first as [T1](#t1) describes; no suite sets the level without the trait; and the
suite passes when `QuizSessionTests` is run before `QuizDrawTests` and `QuizLevelTests` in one
process.

**Tell Josh he could try:** nothing on screen. The test count should not fall.

**How it differed:**

## Phase 2: A Slip Is a Typing Slip

**Findings:** [L15](#l15), [L18](#l18), [F2](#f2) (the stripping), [F3](#f3), [F8](#f8),
[F10](#f10), [C4](#c4), [G4](#g4), and from [S3](#s3) the pronoun stripping. **Depends on:**
Phase 1. **Decisions:** none. Josh reviews one new line.

- One function returns a cell's accepted spellings: the conjugator's alternates and their
  `StandardVariants`. Grading, `AnswerSlip`, `AnswerDifference.nearest`, and the diagnoser's
  cell check call it. `Verb.conjugations(matching:)` keeps its strict behavior for search.
- `AnswerSlip` refuses an edit that falls inside the letters the conjugator writes in capitals
  for the asked cell.
- A participle that ends as the passé simple does ("ai finit", "ai dis", "a prit") gets a line
  of its own. Bring Josh the line in both languages before building on it.
- A leading "que " or "qu’" is stripped for the four subjonctif tenses, by a rule that grading
  and `ConjugationQuery` share. A trailing "!" or "." is stripped.
- absout and dissout are variants in the participe passé and the compound tenses only.
- `withGraveInFuturStem` reads gu and qu as consonants.
- `QuizView.submit()` ignores an empty Return.
- One test that every infinitive named in `StandardVariants` and in the diagnoser's lists is a
  verb.

**Done when** tests pin, each failing on the old code: "a prit", "prenent", "veus", and "fûmes"
for fîmes are not slips, and "parlon" still is; "connait" for tu connais gets the line
"connaît" gets; "ai finit" gets its new line; "connaitrons" for connaîtront has only its s
marked; "que je parle", "qu’il parle", and "que j’aie parlé" are right; "va !" is right;
"dissout" for je dissous is wrong; "lèguerai" is right with "léguerai" shown; and an empty
Return changes nothing.

**Tell Josh he could try:** the `slips` and `diagnoses` fixtures on the iPhone, typing the
answers above.

**How it differed:**

## Phase 3: What Grading Accepts

**Findings:** [F4](#f4), [F7](#f7), [F9](#f9), [F11](#f11), [F12](#f12), [F13](#f13), and from
[F2](#f2) the frame. **Depends on:** Phase 2. **Decisions:** [D8](#d8) (a), [D9](#d9) all four,
[D10](#d10) (a).

- The subjonctif's frame shows `que je ______` and `qu’il ______`, eliding as the pronoun does,
  and VoiceOver says it.
- These grade as right, each with the app's own spelling shown beside the checkmark: a singular
  agreement with vous; an agreed participle for a participe passé question; "oe" for œ; and
  avoir, with an unagreed participle, for monter, descendre, sortir, rentrer, retourner, and
  demeurer. Check each of the six against a dictionary first and tell Josh of any that does not
  take avoir in standard use. The auxiliary's diagnosis stops firing for them.
- ï and œ join the key row where the quiz shows it.
- A wrong elision ("je ai", "j’parle", "j’hais") and a reflexive pronoun dropped after a typed
  subject ("je souviens") earn one more try with a line that names it.
  `PersonNumber.elides(before:hasAspiratedH:)` decides, and `Mastery.pronoun` uses it too
  ([S3](#s3)). Bring Josh the lines in both languages.
- A set of pronominal verbs whose participle does not agree with the subject: complaire,
  entre-nuire, entrenuire, and arroger. The conjugator and the agreement's diagnosis read it. It
  lives where `ConjugationMapTool` can compile it.
- Grading is tested under the masculine and "both" settings ([T9](#t9)).

**Done when** tests pin each acceptance and each new line, "elles se sont complu" is right and
"complues" is not expected anywhere, the verb page shows the same, and
`ConjugationMapTool` still builds.

**Tell Josh he could try:** a subjonctif question's frame in both languages; "vous êtes allée";
"manoeuvre"; "j’ai monté"; "je ai parlé".

**How it differed:**

## Phase 4: What an Answer Does to the Record

**Findings:** [L1](#l1), [L2](#l2), [F6](#f6) (the record), [F19](#f19), and from [T4](#t4) and
[T9](#t9) their tests. **Depends on:** Phase 2, since [D2](#d2) keeps a slip's repair right only
once a slip means a typing slip. **Decisions:** [D1](#d1) (a), [D2](#d2) (a), [D6](#d6) (a).

- `recordAnswer` is told what kind of answer it has: a first attempt, a repaired slip, a
  repaired diagnosis, or a re-ask.
- A right re-ask and any right second attempt leave the miss in My Mistakes. A later right
  answer on the item, or one in My Mistakes itself, clears it.
- A repaired diagnosis counts as wrong for the record: the item starts over and enters My
  Mistakes. The half points stay. A repaired slip still counts as right for the box.
- An entry of a key conjugation remembers the cell last missed, in an optional field. Review
  and My Mistakes ask that cell, and the il form when there is none. A right answer there
  clears the field.
- A right answer raises a key conjugation only on a cell that shows the stem: for the présent,
  a person of the présent or the impératif; for the passé composé, a cell with its auxiliary. A
  wrong answer on any cell of the stem still sends it back.
- When a verb lacks the il form of a stem, its item asks the first cell of the stem it has, and
  `isAskable` agrees.
- Correct the comment in `Quiz.process` and `docs/feature_architecture.md` § The Practice
  Record.

**Done when** tests pin, each failing on the old code: a miss, then a right re-ask, and the
item is still in `missedItems()`; "ai allé" then "suis allée" leaves the item in the first box
and in My Mistakes; a miss on "vous faites" makes My Mistakes ask "vous faites"; "j’allais" and
then "allant" do not raise "il va"; a record without the new field decodes; and a sweep finds
every cell a level asks mapping to an askable item whose question maps back.

**Tell Josh he could try:** miss a question, answer its re-ask right, finish, and look at My
Mistakes on the hub.

**How it differed:**

## Phase 5: Lookups, the Review Card, and What Mastered Means

**Findings:** [L3](#l3), [L4](#l4), [L5](#l5), [L17](#l17), [P6](#p6), and from [G1](#g1) the
schedule's comment and the Speed Round's lines. **Depends on:** Phase 4. **Decisions:**
[D3](#d3) (a), [D4](#d4) (a), [D5](#d5) (a).

- A page opened from search sends a verb's key conjugations back to the first box. Every other
  route enters items that are new and demotes nothing. What an open means is a value of the
  app's own, chosen where the page is opened, and not a test on `AnalyticsSource`.
- A reveal raises an item no further than the second box, and reschedules an item already
  there at its own box. A card dismissed unrevealed is hidden for the day, and its items stay
  due.
- The Mastery page's verbs link to their pages.
- `Mastery.intro` and `SpeedRound.locked` say what mastered means and that a lookup from search
  starts a form over, in both languages, for Josh to review.
- One test of "mastered" that `MasteryState`, `SpeedRound.masteredItems`, and `Achievement`
  share, and the Speed Round's lock counts what the Mastery row counts ([S3](#s3)).

**Done when** tests pin: a lookup with the correction's source leaves a box-4 item in box 4,
and one from search sends it to box 0; a lookup and two reveals leave a verb's items in box 1;
a dismissed card's items are still in today's due items; and the app's routes each map to the
kind of open they should.

**Tell Josh he could try:** tap through from a held correction to the verb's page and back,
then look at Mastery; dismiss the review card and open Review.

**How it differed:**

## Phase 6: The Draw

**Findings:** [F1](#f1), [F5](#f5), [F17](#f17), [F18](#f18), [F20](#f20), [L9](#l9),
[L16](#l16), and from [S3](#s3) "what a level asks". **Depends on:** Phase 1. **Decisions:**
[D12](#d12) (a), [D13](#d13) (a), [D23](#d23) (a). Josh approves the weights.

- A pool for irregular subjonctif présent stems, read from the conjugator's capitals. List the
  verbs the passé simple's pools leave out and bring Josh the list.
- A participe passé that is unused makes every compound tense unused. Pronominal verbs are left
  out of the passé surcomposé.
- The auxiliary-only tenses are weighted as a class at Advanced. Propose the weights, show what
  600 seeded Advanced rounds then ask, and have Josh approve them.
- A pool is weighted by what the band holds. Measure Beginner's share for agir, choisir, and
  définir before and after.
- A default quiz's first round holds no due items. Ten More, the daily session, and Review ask
  them. In a round that has them, the full count is drawn and due items take slots of matching
  role and regularity, so that the mix holds for the round.
- One `QuizLevel` function says whether a level asks a cell of a verb, and the due draw, the
  sentences, the choices, Mastery, and the reminder's count call it.
- The dead `QuizDraw.questions(level:count:asked:using:)` goes or gains a caller.
- Correct the comment on `mixesChoiceQuestions`.

**Done when** tests pin, over many seeds: an Intermediate round can ask fasse, puisse, and
vienne, and does so at about the weight chosen; seoir and paître are never asked a compound
tense, by a test that names them and does not call `hasCell`; no pronominal verb is asked the
passé surcomposé; the first round of a default quiz has no due item whatever the record holds;
a round with due items still has its irregular half; and the dominance test states the share
its pools predict ([T5](#t5)). The challenge's golden test, if Phase 8 has landed, is updated on
purpose.

**Tell Josh he could try:** several Intermediate and Advanced quizzes, watching for irregular
subjonctifs and for fewer compound tenses.

**How it differed:**

## Phase 7: Verb Essentials, a Model's Practice, and Name the Conjugation

**Findings:** [F6](#f6) (the exercises), [L11](#l11), and from [I6](#i6) the Mixed line.
**Depends on:** Phase 4. **Decisions:** [D7](#d7) (a), [D16](#d16) (d). Josh reviews the list
of verbs that get a fourth blank.

- A verb whose présent has a stem the il form does not show gets a fourth blank, the ils
  présent, in Verb Essentials and in a model's practice. Which verbs those are is read from the
  data. Bring Josh the list of models before building on it. The verb page's key conjugations
  stay three.
- What "Known" counts follows, so that plaindre's model is not known without plaignent.
- In Name the Conjugation, the person counts as a right part only together with a right tense.
- The Mixed line says that knowing a model can take a second day. Correct the doc comment on
  `Verb.keyConjugations()`.

**Done when** tests pin: a round of plaindre's model alone asks plaignent; a model answered
right in its three il forms alone is not known; an irregular verb with one présent stem, such as
ouvrir, still has three
blanks; a recognition answer with only
its person right goes to the correction.

**Tell Josh he could try:** Verb Essentials at Beginner, and plaindre's model from the Models
tab, in both languages and under VoiceOver's rotor order for the fourth row.

**How it differed:**

## Phase 8: The Daily Challenge and the Choice Question

**Findings:** [L6](#l6), [L7](#l7), [L8](#l8), [T2](#t2), [F14](#f14), [F15](#f15).
**Depends on:** Phase 6, since [F1](#f1) changes what the challenge draws. **Decisions:**
[D11](#d11) (a), (b), (c), [D14](#d14) (a), [D15](#d15) (a), [D16](#d16) (a), (b). Josh reviews
every new or changed item and the reason's new wording.

- A challenge is taken from its first answer. Quitting it, or leaving the app during it, stores
  its outcomes with the unanswered questions wrong.
- A link opens yesterday's, today's, or tomorrow's challenge by the device's date and nothing
  else. Results are kept for a week. A link to a challenge already taken shows its result.
- The link carries a content version, and the app says when a friend's link comes from another.
  The docs say "the same within a version".
- A golden test: the five cells of one key a level, the widget's wrong answers for one key, and
  the generator's first outputs for two seeds. The cache-bound test calls the uncached draw.
- The quiz widget asks a cell of the challenge's first verb other than the challenge's own.
- A choice question's English shows after the choice, with the reason.
- The three history-book items go and three replace them, the three story items get a frame
  already in the passé simple, the reason is narrowed, and "Pourriez-vous" and "Sauriez-vous"
  are replaced. `scripts/choice_questions.py check` passes, and Josh reviews the items.

**Done when** tests pin: a challenge quit after one answer has a result of five outcomes and
cannot be started again; a link for the day after tomorrow and one for last month start
nothing; the golden values; the widget's cell differs from the challenge's first for 40 days;
and the choice view shows no English before `chosenIndex`.

**Tell Josh he could try:** today's challenge quit after one question, then its row on the hub;
a choice question at Elementary; the widget beside the challenge.

**How it differed:**

## Phase 9: The Sentences

**Findings:** [F16](#f16), [F21](#f21), [L19](#l19), and from [T9](#t9) the content checks and
from [S3](#s3) the two scripts' shared loop. **Depends on:** nothing. **Decisions:**
[D11](#d11) (d). Josh reviews every redraft.

- `scripts/gap_sentences.py check` warns when a subjonctif blank equals the indicatif of its
  person and when a passé simple blank equals the présent, checks elision before the blank,
  compares a `gender` key with a visible subject, and says so when it skipped the form check
  for want of the corpus dump. The two scripts share one loop.
- The 35 subjonctif sentences are redrafted with a person or verb that tells the moods apart,
  with the five unidiomatic sentences and the four whose English spells the blank. Lean the
  redrafts away from the third person and the présent.
- `GapSentenceTests` gains the elision assertion.

**Done when** the check reports no warnings, `GapSentenceTests` passes with the count of
sentences unchanged or explained, and Josh has approved the redrafts.

**Tell Josh he could try:** Phrases à trous at Intermediate, and the review sheet of redrafts.

**How it differed:**

## Phase 10: Clocks, Calendars, and the Reminder

**Findings:** [L10](#l10), [L12](#l12), [L13](#l13), [C5](#c5), [C6](#c6), [C7](#c7),
[T6](#t6), and from [S3](#s3) the day helpers and from [C10](#c10) the Live Activity's timer.
**Depends on:** Phase 1. **Decisions:** [D16](#d16) (c), [D17](#d17) (a). Josh reviews the
notification's new line.

- The Speed Round's minute is measured against a deadline, so time away counts.
- A daily session counts for the day it began.
- The streak's keys and the reminder's dates are Gregorian in the current time zone. One day
  helper serves the streak, the record, and the verb of the day.
- Reschedules are serialized, replace by identifier, and finish under a background task.
- The reminder counts what its session would ask, and the repair day's notification opens with
  the offer, in a line Josh reviews in both languages.
- A miss in a round's last two questions is not re-asked in the round.
- The Live Activity's timer stops while a correction is held, and `correctCount` is shown or
  goes.
- The two wall-clock tests take a fixed `now` and calendar.

**Done when** tests pin: a Speed Round started, left for 90 seconds by the injected clock, and
resumed is over; a session begun at 23:56 and finished at 00:02 counts for the first day; the
streak's keys round-trip in the Chinese calendar through 2028's leap month; the reminder's
count for a learner with due items beyond the level; a miss on question 9 or 10 adds no
question; and both formerly wall-clock tests pass at any hour.

**Tell Josh he could try:** a Speed Round with a trip to the Home screen; the reminder turned
on, then its time changed twice quickly.

**How it differed:**

## Phase 11: The Hub

**Findings:** [C1](#c1), [S2](#s2), [I2](#i2), and from [C10](#c10) the tile, the Last Quiz
row's title, and the tip. **Depends on:** Phases 5 and 8, which change what rows show.
**Decisions:** none.

- A `QuizHubView` over a model that computes every row from one injected date and refreshes
  when the scene becomes active and when the day changes. The challenge's key is computed when
  its row is tapped.
- The rows' decisions are the model's, with tests: Review's and My Mistakes' lines, the Speed
  Round's lock, the challenge's start or share, the Last Quiz row's lines.
- `CustomQuiz` returns why Start is disabled, and one place words it.
- "10 Questions" shows what the list can ask. A Last Quiz row whose collection no longer
  resolves has a title that fits. `TryQuizTip` is retired in one place.
- At the results, VoiceOver hears the score before the best, the streak, or the challenge's
  line, and each row's mark has a label.

**Done when** the model's tests pin each row across a change of day, with the confirmation
[C1](#c1) describes tried on the simulator across a real midnight if a session is open then, or
left in `docs/release.md` if not; `QuizView.swift` holds the question alone; and the hub looks
as it did on both devices.

**Tell Josh he could try:** every row of the Quiz tab in both languages, and the results under
VoiceOver.

**How it differed:**

## Phase 12: Links, Sheets, and Shared Sets

**Findings:** [C2](#c2), [C3](#c3), [C9](#c9), [L14](#l14), and from [C10](#c10) the
`quiz/start` link. **Depends on:** nothing. **Decisions:** [D19](#d19) (a), [D20](#d20) (a),
[D21](#d21) (a).

- A sheet's quiz that disappears while a question waits quits: the signal is sent, the
  abandonment entry cleared, the timer stopped.
- A link that arrives while a sheet's quiz is under way waits and opens when the quiz is quit
  or finished. A `quiz/start` link does not discard results on screen.
- A link that arrives during onboarding is kept and opened when onboarding closes. Decide by
  trying it what a results sheet needs.
- A set over a collection always carries the sharer's level.
- A shared My Verbs carries the starred verbs alone. A QR code carries up to 30 verbs and a
  link up to 100, a received list is capped on the way in, and the QR screen says so when the
  list is longer than its code carries.
- A set that lost verbs or its model on the way in says so above Start.
- Correct the comments and the doc lines [C9](#c9) and [G1](#g1) name.

**Done when** tests pin: a routed sheet replaced mid-question sends `quizQuit`; a link sent
during a sheet's quiz is pending until it ends; a set over the verbs taking être asks a
Beginner and an Advanced opener the same band; a link of 200 verbs is cut to 100; the capacity
test sorts by encoded length and holds at 30; and the first-launch steps of [C3](#c3) show the
set on a scratch simulator.

**Tell Josh he could try:** a set's code scanned with the Camera, which also settles
[G2](#g2)'s first item; a set opened mid-quiz.

**How it differed:**

## Phase 13: Privacy in the Code

**Findings:** [P1](#p1), [P2](#p2), [P3](#p3), [P5](#p5), and from [C10](#c10) a link's source
and from [P8](#p8) Reset Practice. **Depends on:** Phase 5, which settles [P6](#p6).
**Decisions:** [D18](#d18) (a), (b), (d).

- No question count, on completion, quit, or abandonment, for a model's practice in either
  mode or for a scope whose verbs are a list.
- A Review or My Mistakes session sends one `quizCompletion`, at its first round, and no
  `duration`.
- Each link's route accepts only the sources it can carry and falls back to `deeplink`.
- Reset Practice resets the Game Center achievements too, and its alert and description say so
  in both languages.
- The spy asserts that every key is a `ParameterKey` and every value comes from its key's
  closed set, and one test drives a session of every `QuizScope.Kind` through it.
- The four sources stay, and the ruling is recorded in `docs/feature_architecture.md`
  § Analytics.

**Done when** tests pin: no count is sent for a one-verb model's quiz at any level; a
three-round My Mistakes sends one completion with no duration;
`quiz/start?source=review` reports `deeplink`; and adding an unknown key anywhere fails the
allow-list test. Every change is staged in both languages.

**Tell Josh he could try:** Reset Practice, and then Game Center's achievements.

**How it differed:**

## Phase 14: The Staged Policy and the Docs

**Findings:** [P4](#p4), [P7](#p7), [P8](#p8), [G1](#g1), [G2](#g2), [G3](#g3).
**Depends on:** Phase 13. **Decisions:** [D18](#d18) (c). Josh reads the staged text.

- The lifecycle bullet says which collections are named. The duration bullet's list of counts
  matches what Phase 13 left. The practice record's paragraph mentions backups.
- A new staged section names the SDK's default parameters, in both languages, from the SDK's
  source at the pinned version.
- The French is normalized to U+202F, in the pending file and in `docs/privacy_policy2.txt`,
  with a release-day step to check it.
- Every doc line and comment [G1](#g1) lists that no earlier phase corrected. The comments
  [G3](#g3) lists go.
- `docs/release.md` gains [G2](#g2)'s checks.

**Done when** a table in **How it differed** sets each signal, key, and value in
`Analytics.swift` at HEAD beside its staged line in each language, and `check_docs.py` reports
0 problems.

**Tell Josh he could try:** reading the staged sections that changed.

**How it differed:**

## Phase 15: Interface Text and VoiceOver

**Findings:** [I1](#i1), [I3](#i3), [I4](#i4), [I5](#i5), [I6](#i6). **Depends on:** nothing.
**Decisions:** [D22](#d22) (a). Josh reviews every line.

- The held correction, the choice's sentences and reason, the Speed Round's miss line, and a
  spoken diagnosis give their French in a French voice. Confirm [I1](#i1) by ear first.
- "Série" is the streak alone, a round is a "manche", and a practice set is a "fiche
  d’exercices", in the catalog, the docs, and the staged policy.
- The lines [I3](#i3), [I4](#i4), and [I6](#i6) name. A test loads the catalog and checks that
  every key has a translated French value, that French punctuation carries U+202F outside the
  listed exceptions, and that specifiers agree ([T9](#t9)). The two dead `Info.purposeAndUse*`
  accessors go.

**Done when** Josh has approved the lines, the catalog test passes, and `docs/voiceover.md`
describes the correction as built.

**Tell Josh he could try:** a missed question under VoiceOver with an English interface; the
Quiz tab in French.

**How it differed:**

## Phase 16: One Shape for a Quiz's Modes

**Findings:** [S1](#s1), [S3](#s3) (what is left), [S4](#s4), [C8](#c8), and from [C10](#c10)
the orphaned pattern. **Depends on:** Phases 2, 4, and 10, which edit the same paths.
**Decisions:** none. This phase changes no behavior.

- The fixtures and the announcements move out of `Quiz.swift`. The fixture's key is named once.
- A question carries one payload in place of three optionals, and the Speed Round has a submit
  path of its own that shares grading with the typed one.
- `QuizScope` says "Test Me" and "mixed" by its kind, not by a count or a nil.
- `SeededRandomNumberGenerator` moves to `Shared/` and the widget's copy goes.
- A record that fails to decode is copied aside before anything saves. `ReviewSchedule` and
  `DailyStreak` carry the "must be optional" note. A pattern no verb fits is not askable.
- Measure the save with a 2,000-entry record and coalesce it only if it shows.

**Done when** the suite passes with no test changed but for moved names, and
`Quiz.swift` holds the session alone.

**Tell Josh he could try:** a quiz of each kind, which should behave as before.

**How it differed:**

## Phase 17: Tests That Prove What They Claim

**Findings:** [T3](#t3), [T4](#t4), [T5](#t5), [T8](#t8), [T9](#t9), whatever of each the
earlier phases left. **Depends on:** every earlier phase. **Decisions:** none.

- Each single-seed test of [T3](#t3) is rebuilt on a pool that forces its rule or over many
  seeds.
- Each test of [T4](#t4) can fail for what its name claims. Show it failing once.
- The dominance test asserts a predicted share ([T5](#t5)).
- The corpus-tied counts carry a tripwire comment. The scheme's language is tried with the
  simulator in French, and `CLAUDE.md` says what was found ([T8](#t8)).
- [T9](#t9)'s list: a literal JSON of each stored record in today's shape, the Speed Round
  across batches, the challenge's key at midnight and across a time zone, the choice's exclusion
  over two rounds of Ten More, the twenty-attempt fallback, a mixed practice whose known models
  change, and whether every Advanced pattern can be drawn.

**Done when** each item is done or carries a line saying why not.

**Tell Josh he could try:** nothing on screen.

**How it differed:**

## Closing

- Run the full suite, `swiftlint`, and `check_docs.py`.
- Confirm that every finding in this file carries a line: fixed, found not to be real, or left
  with its reason.
- Re-read this plan's phase notes for anything a phase deferred, and either do it or list it in
  `docs/release.md` or as a `// TODO:`.
- Confirm that Phase 14's table agrees with `Analytics.swift` at HEAD.
- Write what would carry over to Konjugieren and Conjugar, as the earlier plans' Closings did.
  [The comparison](#konjugierens-findings-checked-here) lists what this review found that
  Konjugieren's did not, and several of those would apply there (the hub across midnight, a
  link during a sheet's quiz, the allow-list for signals). Neither sibling is to be changed.
- Mark this plan finished in its Status section.

**How it differed:**
