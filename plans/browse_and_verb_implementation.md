# Plan: Port the Browse and Verb Work from Konjugieren

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
app code, one build-time tool, localized strings, App Intents, and tests. **Written:** 2026-11-22,
by porting [`../Konjugieren/plans/browse_and_verb_implementation.md`](../../Konjugieren/plans/browse_and_verb_implementation.md)
(the **Konjugieren plan**), which built Josh's accepted ideas from
[`../Konjugieren/docs/browse_and_verb_ideas.md`](../../Konjugieren/docs/browse_and_verb_ideas.md) (the
**ideas document**) between 2026-11-12 and 2026-11-13. Conjuguer has no ideas document of its own.
The goal is the same as Konjugieren's: make the Verbs and Models tabs answer what people ask of
them. Conjuguer's Models tab plays the part of Konjugieren's Families tab.

**A companion plan follows this one.** [`pedagogy_implementation.md`](pedagogy_implementation.md)
ports Konjugieren's quiz work and builds on several pieces made here: the accent key row, the
conjugation map and `conjugations(matching:)`, key conjugations, the learner's verb record, quiz
scopes, frequency bands, the review card's due date, and collections. Build those pieces so that
plan can extend them rather than replace them, as the Konjugieren plan did.

## Status

Each session that finishes a phase fills in its row here, changes the **Status** line under the
phase's heading to match, and writes the phase's **How it differed** note. A finished phase that
Josh has not yet tried is "Awaiting Josh", with the Commit cell empty until it is committed.

| Phase | Status | Date | Commit | Ideas | Konjugieren phase |
|---:|---|---|---|---|---:|
| 0 | Done | 2026-11-22 | 33de461 | Groundwork | |
| 1 | Done | 2026-11-22 | 1046c7c | A1, A2, A3, A8 | 1 |
| 2 | Done | 2026-11-22 | 0827ddf | A4, C4 | 2 |
| 3 | Done | 2026-11-22 | 0827ddf | Signals | 3 |
| 4 | Done | 2026-11-22 | 7a532ac | A5 (the map) | 5 |
| 5 | Done | 2026-11-22 | 1fd6c58 | A5 (the search) | 6 |
| 6 | Done | 2026-11-22 | 1fd6c58 | B3, B5's tip | 7 |
| 7 | Done | 2026-11-22 | c9fbd7e | B4, A9 | 9 |
| 8 | Done | 2026-11-22 | aaf8b31 | B6 | 10 |
| 9 | Done | 2026-11-22 | 7ba1281 | C1, C2 | 11 |
| 10 | Done | 2026-11-22 | 2829650 | D1, D2 | 12 |
| 11 | Done | 2026-11-22 | e9a34b5 | D2's quiz scope, D3 | 13 |
| 12 | Done | 2026-11-22 | 9af3c40 | D5 | 14 |
| 13 | Done | 2026-11-22 | d4b8752 | D4 | 15 |
| 14 | Done | 2026-11-22 | 894ddba | D6 | 16 |
| Closing | Awaiting Josh | 2026-11-22 | | Audit, porting notes | Closing |

Konjugieren's Phase 4 (separable verbs) and Phase 8 (a Futur II article) have no Conjuguer
counterpart; see [Not Carried Over](#not-carried-over).

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
The numbering is a suggested order. Phases 6 to 8 depend on nothing after Phase 3 and may be taken
in any order. If a phase proves too large for one session, split it, say so in its row, and leave
the remainder marked "Partly done".

**Read Konjugieren first.** Every phase names the Konjugieren phase it ports. Before writing code,
read that phase's text and its **How it differed** note in the Konjugieren plan, and read the
Konjugieren source files the phase names (the repository is at `../Konjugieren`). Those notes
record iOS 26 traps that cost Konjugieren whole sessions: a keyboard toolbar that never appears for
a navigation-bar search field, an iPad search field that ignores programmatic focus, a `ShareLink`
that reports no tap, Spotlight that matches only titles in the simulator, and more. Port the
design, not the code: Conjuguer's architecture differs (a generic `BrowseStore`, verb pages pushed
by `navigationDestination(item:)` in the Verbs tab and presented as sheets from deeplinks and
model pages, `Current` as a `World`, and one `viewAppeared` signal for every screen).

**What this plan leaves to you.** The phases say what to build and what Josh decided. They do not
say how. Read the code, choose the implementation, and record in **How it differed** anything that
departs from the phase as written: a scope change, a decision Josh made during the session, a
dependency that turned out wrong, or a piece deferred to a later phase. A later session relies on
that note more than on the phase text above it. Read the notes of every phase this one depends on
before starting.

**Decisions carried over from Konjugieren** are marked **Carried over** in each phase. Josh made
them for German. This plan assumes they hold for French unless Josh revised them when he reviewed
the plan, which would show in the text. Where French makes a carried-over decision awkward, say
so and ask rather than follow it blindly.

**Ask Josh when a decision does not settle a question.** Phases list such questions under **Ask
Josh**. Do not guess at them. Ask before building the part that depends on the answer, and record
the answer and its date in **How it differed**.

**Subagents run on Sonnet.** No phase requires subagents. A session that launches one uses Sonnet
(`model: "sonnet"` on the Agent tool), as Josh decided for Konjugieren on 2026-11-15, and reads
the subagent's output itself before Josh does.

**Every phase finishes the same way.**

1. Build and run the tests with the `ios-build-verify` skill, as `CLAUDE.md` describes. New logic
   gets tests that follow `.claude/rules/swift_testing.md`. Read the run's test count, not only its
   exit status. Where anything is random, make the random source injectable and test proportions
   with a fixed seed.
2. For any visible change, launch the app and look at it, following the `verify-in-simulator`
   skill. Look on both the iPhone and the iPad, since Josh tries
   changes on an iPhone and leaves the iPad to the session. Split the languages and appearances
   across the two: on the iPhone, look in French and again in English; on the iPad, in English.
   Relaunch with `-AppleLanguages "(fr)"` or `"(en)"` to switch, and set the appearance with
   `xcrun simctl ui <udid> appearance dark` (or `light`).
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
   `.claude/rules/localization_catalog.md`. Strings that `Shared/` or the widget uses belong in the
   widget's catalog (`.claude/rules/widget_localization.md`).
4. Follow `docs/voiceover.md` (Phase 0 writes it) for anything tappable on
   the verb page or in the verb list.
5. Add analytics by the convention Phase 3 sets, once Phase 3 is done, and stage every new signal,
   parameter, or value in `docs/privacy_policy_pending.md` in
   English and French. Never send a verb or any typed text.
6. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, keep `docs/feature_architecture.md` true
   (Phase 0 creates it), add any new `.accessibilityIdentifier` to the `verify-in-simulator`
   skill's table, and run `python3 scripts/check_docs.py`.
7. Fill in the Status row and the phase's Status line, write **How it differed**, and append a
   journal entry to `docs/blog_notes.md`.
8. **Stop before git.** Do not run `git add`, `git commit`, or `git push` until Josh has tried the
   changes. Tell him what changed and how to try it: which screens to open, and what to type or
   tap. Once he says he has tried them, commit and push to `main`. Then, since a commit cannot
   contain its own hash, record the hash in the Status row with a one-line follow-up commit, and
   push that too. Josh made this rule for Konjugieren on 2026-11-12, and it holds here for every
   phase and the Closing.

**No release before 2027.** Josh cannot release Konjugieren, Conjuguer, or Conjugar from his
present MacBook until he replaces it in 2027 (decided 2026-11-10, recorded in Konjugieren's
`CLAUDE.md`). Every phase accumulates on `main`. Nothing here reaches a learner or produces a
number until a release ships, so no phase should wait on evidence from another. Every step that
must wait for release day (an App Store Connect step, a device check) goes in `docs/release.md`.
A privacy-policy line waits word for word in `docs/privacy_policy_pending.md`, and `release.md`
says only when to apply it. Phase 0 creates both. Conjugar splits them the same way
(2026-11-22).

**Conjuguer only.** Conjugar is getting its own port in parallel. Do not edit Konjugieren or
Conjugar from a session of this plan. If a phase finds a bug in Konjugieren's design that also
affects Conjuguer, note it in **How it differed** and tell Josh.

## Conjuguer Today

What a session should know before starting, **observed** in the code on 2026-11-22 unless marked.

**The verb list** (`VerbBrowseView`) filters 6,330 entries (6,326 distinct infinitives) with
`localizedStandardContains` on the infinitive, which ignores case and accents. It does not search
glosses, and there is no Search Scope setting. Results keep the list's order, Frequency (the
default) or Alphabetical, chosen by a segmented picker. An empty result shows
`ContentUnavailableView.search` and plays a sad trombone (`BrowseSearch`). The Models tab
(`ModelBrowseView`) shares `BrowseSearch` and matches the exemplar only.

**What search returns**, simulated on 2026-11-22 with a Python fold of `verbs.xml` and
`docs/frequencies.txt`, and with the `œ` case confirmed in Swift:

| Typed | Today | Wanted |
|---|---|---|
| etre | être first by frequency; under Alphabetical, être is not near the top (chronométrer, dépêtrer, détremper lead) | être first in either order |
| venir | venir first by frequency; 19th of 19 under Alphabetical (advenir leads) | venir first in either order |
| suis, fait, vais, ai | nothing, or the wrong verbs: ai lists 250 verbs led by faire; fait finds only enfaîter | être and suivre; faire; aller; avoir (Phase 5) |
| go, eat | 86 verbs containing "go" (négocier first); eat finds béatifier | aller; manger (Phase 1) |
| to go | nothing | aller |
| se souvenir, s'asseoir | nothing; 217 pronominal-only verbs are stored without "se" | souvenir, asseoir |
| manoeuvrer, oeuvrer | nothing; `localizedStandardContains` does not fold œ to oe | manœuvrer, œuvrer |
| pecher | pécher and pêcher, in list order | both, with the accent typed ranked first when it is typed |

**The verb page** (`VerbView`) shows the infinitive; an Overview card (gloss, a tappable model row
that opens the model in a sheet, reflexive and aspirated-h notes, the auxiliary, the rank, any
defectiveness); a dismissible color key (`hasSeenConjugationColorKey`); a card with the participe
passé, participe présent, and radical du futur; the eight simple tenses in morphological order
(présent, passé simple, imparfait, futur, conditionnel, subjonctif présent, subjonctif imparfait,
impératif); a "Show compound tenses" toggle, off by default, over nine compound tenses; the
etymology; and the example sentences. On an iPhone 17 Pro, aller's toggle sits about three screens
down, so the passé composé, the commonest past tense in speech, is three screens down and hidden.
Tense names are always French. Nothing on the page leads to another verb except the model row.

**The Models tab** sorts by irregularity, alphabetically, or by identifier. A model's page
(`ModelView`) lists its verbs as a comma-separated run of `conjuguer://verb/` links in the model's
own order.

**Outside the app.** Deeplinks `conjuguer://verb/<infinitif>` (and `verb/random`),
`model/<id>`, `info/<index>`, and `quiz/<anything>`, which starts a quiz. Two widgets (the verb
of the day, a daily quiz question), a Live Activity, Control Center controls for a random verb
and the quiz, and two App Intents (`OpenQuizIntent`, `OpenRandomVerbIntent`). No
`AppShortcutsProvider`, no `AppEntity`, no Spotlight, no Handoff, no quick action.
[`docs/wwdc2026_conjuguer_impact.md`](../docs/wwdc2026_conjuguer_impact.md) § 2.1 is the design
note for App Intents and Spotlight.

**The verb of the day** (`WidgetSnapshotWriter`) already draws from the 1,500 most frequent verbs
that have an example, stepping `(days × 127) % count` through them in rank order. The random verb
(`World.resolveDeeplinkEntity`) draws from all 6,330 entries.

**Analytics** send `viewAppeared` with `viewName` for every screen, quiz lifecycle signals, and a
few taps. The policy, [`docs/privacy_policy2.txt`](../docs/privacy_policy2.txt), says the app "does
not record your quiz answers, the verbs you look up, or any text you type". There is no
`docs/feature_architecture.md`, `docs/voiceover.md`, `docs/release.md`, or pending-lines file.

**Who uses it.** From the Konjugieren reports' usage snapshot (2026-11): Conjuguer's devices are
largely francophone (92 of 192 run in French, many in West Africa), with 86 in English. More than
half of its lifetime downloads were volume purchases by one Swiss institution, installed on Macs
each September in 2024 and 2025. So reverse lookup and gloss search matter less than in
Konjugieren, and keyboard use and collections matter more.

**Frequency data have holes.** `manœuvrer` and `écœurer` carry counts of zero in `verbs.xml`,
probably because the corpora spell them with "oe" (**inference**). Phase 12's bands and the
pedagogy plan's level bands read these ranks, so Phase 12 checks for zero counts among common
verbs.

## Decisions Already Made

**Decided for Conjuguer** by Josh on 2026-11-22, when he reviewed this plan:

- **No Search Scope setting.** Search always covers French infinitives and English glosses, with
  French ranked first (Phase 1). A francophone user loses nothing by it.
- **Key conjugations** are the il forms of the présent, the passé composé, and the futur simple,
  as in "venir: vient · est venu · viendra" (Phase 8). The page's personless card already shows
  both participles and the futur stem, so these add what a learner needs most. Phases 9 and 13,
  and the pedagogy plan's key-conjugations exercise, use the same set.
- **The compound-tense toggle stays, and is on by default** (Phase 6), so the compound tenses,
  the passé composé among them, show without a tap and a learner can still hide them.
- **Reverse lookup is built** (Phases 4 and 5), for the English-speaking learners and for the
  pedagogy plan's slip, diagnosis, and recognition phases, which need its matching function.

**Carried over from Konjugieren**, from Josh's verdicts on the ideas document and his answers on
2026-11-12 and 2026-11-13, and assumed to hold here:

- **Rejected there, and not ported:** A6 (sentence mode), A7 (verbs outside the corpus), B1
  (principal parts at the top), B5 (teasers near the top), B7 (missing sections), C3 (shortcut
  phrases in the app's other language), and every entry in "Smaller and Later Ideas".
- **The trombone stays** on a failed search, because it is funny.
- **The map** is generated at build time by a host tool that shares the Conjugator's sources, and
  regenerates only when an input is newer than the output.
- **Section order.** Simple tenses stay ahead of compound ones, and every section stays visible.
  Within each block, order by frequency of use. (Here, visible means the compound block's toggle
  is on by default.)
- **Signals.** All three lookup signals are built, with the policy lines staged for the release.
- **Quiz pieces.** Build minimal versions of what the quiz needs: a quiz over a given list of
  verbs, and a due date per verb, built so the pedagogy plan extends them.
- **No web domain for universal links.** Shared text carries the App Store link
  (`https://apps.apple.com/app/conjuguer/id1588624373`) and, where useful, a `conjuguer://` link.
- **Key conjugations appear with no label.** Never "principal parts" or "temps primitifs", in the
  interface or in code names. Wherever shown, they stand alone.
- **Only a full default quiz ranks** on the leaderboard (until the pedagogy plan re-scopes ranking
  by level).

## Phase 0: Groundwork

**Depends on:** nothing. **Status:** Done (2026-11-22).

Docs that later phases, and the pedagogy plan, write into. Konjugieren had each before its plans
began. No app code.

- **`docs/feature_architecture.md`**, modeled on Konjugieren's: sections for Search, Analytics
  (empty until Phase 3), Deeplinks (today's grammar, from `URLExtensions.swift` and
  `World.resolveDeeplinkEntity`), Quiz (today's two difficulties, the curated pools in
  `QuizVerbs`, scoring with its partial match and time bonus), and Widgets. Describe what is,
  briefly; phases extend it.
- **`docs/voiceover.md`**, adapted from Konjugieren's: how tappable text gets `onTapGesture` plus
  an `accessibilityAction`, how French text is marked for French pronunciation
  (`.frenchPronunciation()` here), and the quiz's manual announcements through `Utterer`.
- **`docs/privacy_policy_pending.md`**, with the introduction of Konjugieren's (English and French
  instead of English and German, and naming `docs/privacy_policy2.txt`).
- **`docs/release.md`**, a short list of what release day needs, starting with the pending
  privacy lines.
- **`CLAUDE.md`.** Done before Phase 0 began: at Josh's request on 2026-11-22, `CLAUDE.md` gained a
  "No Release Before 2027" section like Konjugieren's. It names `docs/release.md`, which this phase
  creates.
- List each new file in `docs/project_structure.md` and run `check_docs.py`.

**Done when** the four docs exist and `check_docs.py` passes.

**How it differed:**

Done 2026-11-22 as written: the four docs exist, each is listed in `docs/project_structure.md`, and
`check_docs.py` reports no problems. No app code changed, so there was nothing to build, test, or
look at in the simulator. Two departures, and several findings that later phases should read.

- **Analytics is not quite empty.** `feature_architecture.md` § Analytics states the two rules
  already in force (every screen reports `viewAppeared` with `viewName`; no signal carries a verb
  or typed text) and leaves the vocabulary to Phase 3.
- **Two privacy policies.** `docs/privacy_policy2.txt` (bilingual, effective 2026-06-30) and
  `privacyPolicy4.md` at the root both list the analytics. The pending file names
  `privacy_policy2.txt` as the plan says, and `release.md` asks that release day check which one the
  App Store listing serves.
- **The verb row's languages (Phases 1, 5, 10).** `BrowseRow` marks its title French and its
  subtitle English, but both tabs wrap it in a `Button`, which by Konjugieren's finding flattens the
  row so that one locale wins. Not tested here. `voiceover.md` gives the pattern to adopt, and asks
  the phase that rebuilds the row to test it with VoiceOver. `VerbView.metaRow` also reads its
  English label ("Auxiliary:") with a French voice.
- **Phase 8's check.** Nothing on the verb page speaks when tapped: cells have no tap action, and
  `Utterer` serves only the quiz's announcements. So the context menu replaces no existing tap.
- **Phase 1.** Search matches `infinitifWithPossibleExtraLetters`, so a doubled infinitive's extra
  letters are searchable ("France" finds haïr). Decide whether that should survive the new matcher.
- **Phase 3.** A deeplink needs exactly one path segment after the host (`conjuguer://quiz` alone
  is ignored), and nothing reads query items yet. `pathComponents` excludes the query, so a
  `?source=` item should not break the count, but Phase 3 should test it.
- **Phase 11.** Every completed quiz reports its score to Game Center today, Ridiculous included
  (at double points). A scoped quiz must be kept out explicitly.
- **Phase 12.** The writer stores an array of seven `WidgetSnapshot`s, not a bundle with a base
  date and page offset as Konjugieren's does, so Konjugieren's `displayedSnapshot` has no direct
  counterpart.
- **Version.** `MARKETING_VERSION` is 2.2, and `release_notes_2.3.txt` was begun and never shipped.
  `release.md` leaves the release's number open.

## Phase 1: Search Finds What People Type

**Ideas:** A1, A2, A3, A8. **Ports:** Konjugieren Phase 1 (`VerbSearch.swift`,
`GermanLetterKeyRow.swift`; not `SearchScope.swift`, since Conjuguer gets no setting). **Depends
on:** nothing. **Status:** Done (2026-11-22).

- **A1.** Keep the accent folding `localizedStandardContains` gives, and add the ligatures: œ and
  oe, æ and ae. Strip a leading "se " or "s'" (and "to " for English) before matching, so
  "se souvenir" and "s'asseoir" find their verbs. An unfolded match ranks ahead of a folded one,
  which matters for pairs that differ only by an accent: pécher and pêcher, tâcher and tacher,
  mâter and mater. Typing "pêcher" puts pêcher first; typing "pecher" shows both by frequency.
- **A2.** Search the English gloss (`translation`) as well as the infinitive. A whole-word gloss
  match ranks above a match inside a word, and a leading "to" is ignored. French matches rank
  above English ones in general, but take Konjugieren's final order as the starting point rather
  than "all French first": its Phase 1 found that strict language-first ranking let substrings
  (beatmen for "eat") beat whole-word glosses.
- **A3.** Rank the exact infinitive first, then infinitives that begin with the query, then the
  rest, each by frequency whatever the list's sort order, so venir leads under Alphabetical too.
- **A8.** Turn off autocapitalization and autocorrection in the search field, say in the
  placeholder what can be typed ("Infinitive or English meaning"), and add a row of French accent
  keys above the keyboard. Build the row as a component the quiz's answer field can adopt later
  (pedagogy Phase 1), with an `insert` closure, as Konjugieren's `GermanLetterKeyRow` did. Choose
  the keys from the letters French verbs use: é è ê à â ç î ï ô û ù ë œ is the full set, likely
  too many for one row on an iPhone. Propose a layout to Josh (see **Ask Josh**).

Notes for the session:

- One matching and ranking function (Konjugieren's `VerbSearch`) should serve the list and every
  later caller (Phase 5's reverse lookup, Phase 9's Spotlight and Look Up intent), so they cannot
  drift.
- Konjugieren found that `ToolbarItemGroup(placement: .keyboard)` never appeared for the navigation
  bar's search field on iOS 26.3. Its key row replaced the sort picker while the field was focused.
  Try the toolbar first here, since the simulator or OS may differ, and fall back the same way.
- The Models tab's search matches exemplars only. Whether a verb's infinitive should find its
  model there is an addition beyond Konjugieren; ask before building it.
- There is no Search Scope setting (Josh, 2026-11-22): gloss search is always on, and the
  ranking, not a setting, keeps French first.

**Carried over:** gloss search on; exact first; the key row reusable by the quiz.

**Ask Josh:** the accent keys and their layout, from a mockup or screenshot (one row of the
commonest, or two rows, or a long-press).

**Done when** every row of the table under [Conjuguer Today](#conjuguer-today) that this phase
addresses (etre, venir under Alphabetical, go, to go, eat, se souvenir, s'asseoir, manoeuvrer,
pecher) gives the wanted verb first, and tests pin each case.

**How it differed:**

Built 2026-11-22. Every row the phase addresses gives the wanted verb first, in tests
(`VerbSearchTests`, 21 tests; `ModelSearchTests`, 6) and in the simulator. The suite ran 310 tests
in 26 suites, all passing. New files: `VerbSearch.swift`, `ModelSearch.swift`,
`FrenchLetterKeyRow.swift`. `BrowseSearch` now takes a search closure instead of a predicate.

- **The ranking departs from Konjugieren's.** Its order put a literal infinitive substring above a
  folded prefix, and a prefix strictly above a whole-word gloss. Simulated on Conjuguer's data, that
  failed in French: "go" put gonfler, goûter, and a dozen other go- verbs ahead of aller, and an
  unaccented "eleve" put relever ahead of élever, "ecri" put décrire ahead of écrire, and "pre" put
  préparer behind every bare pre- verb. So prefix, folded prefix, and a whole English meaning (one
  comma-separated sense of the gloss, parenthetical dropped) share one tier, ranked by frequency:
  "go" finds aller (#6) first, "sort" still finds sortir ahead of trier. Within a tier, a folded
  match ranks below a literal one only when the query itself has an accent or ligature (pêch puts
  pêcher first; pre ranks préparer by frequency). The two exact tiers stay apart, so typed mater
  leads mâter and typed tacher leads tâcher, as the phase asked. Full order in
  `docs/feature_architecture.md` § Search. `MatchKind`'s cases are the vocabulary Phase 3 sends as
  `matchKind`; their `tier`, not their case order alone, decides rank.
- **The key row (Josh, 2026-11-22):** one row of eight, é è ê â î ô û ç. ï and œ are left out
  because search folds them; no French verb form uses à, ù, or ë. Each key is 41 by 46 points on an
  iPhone 17, a little under the 44-point width I quoted when offering the layout.
- **The keyboard toolbar did not appear** for the navigation bar's search field on the iOS 26.3
  simulator with the software keyboard shown, as in Konjugieren. The row replaces the sort picker
  while the field is focused, which on iPhone puts it just above the keyboard. On iPad the picker,
  and so the row, sits at the top under the search field. The search ignores the sort order, so
  the hidden picker costs nothing.
- **The Models tab finds a model by any of its verbs (Josh, 2026-11-22).** Exemplar matches come
  first, then models found through a member verb, which the row names as a French subtitle
  ("devenir" under venir). Glosses are not searched there. The Models tab also got the key row,
  folding, the new placeholder ("Model or verb"), and autocorrection off.
- **Extra letters are no longer searched**, as Phase 0 asked me to decide: "France" no longer finds
  haïr. The doubled entries' distinguishing words are glosses ("exit", "obtain") or regions, and a
  region is not what anyone types to find a verb.
- **"s'" alone** searches as "s", so typing "s'asseoir" never sounds the trombone at the
  apostrophe. A query of only spaces shows the whole list instead of failing.
- **Autocorrection** is off in code, but the simulator's software keyboard still showed
  predictions ("going", "good" for go). Not checked on a device.
- **VoiceOver** for the row's two languages is still untested (see `docs/voiceover.md`): this phase
  kept the row and its `Button`.
- **For Phase 2:** the iPad search is still `.automatic` and shows as a toolbar button, so the row
  is visible only after that button is tapped. **For Phase 5:** "ai" now lists aimer and aider
  first, and "fait" finds enfaîter; conjugations will change both. **For the Closing:** Konjugieren ranks a
  folded prefix below every literal substring and whole-word gloss. That may misrank German partial
  queries typed without umlauts too; I have not checked, and the Closing's note for Konjugieren
  should suggest testing the shared-tier rule there.

## Phase 2: When Search Finds Nothing, and Keyboard Lookup

**Ideas:** A4, C4. **Ports:** Konjugieren Phase 2 (`VerbSearch.closestVerb`,
`VerbSearchCommands.swift`, `VerbSearchArrowKeys.swift`, `URL.mailto`). **Depends on:** Phase 1.
**Status:** Done (2026-11-22).

- **A4.** Keep the sad trombone. Below the empty state, offer the single closest verb by fuzzy
  matching over the folded infinitives and say plainly that it is a guess. Add a line saying that
  if the learner believes the verb is real, the learner should email vermontcoder@gmail.com, as a
  `mailto:` link with the query filled in, copying the address to the clipboard where Mail is
  absent (the simulator), as Konjugieren does.
- **C4.** On iPad and Mac, Command-F focuses the search field, Return opens the first result, and
  the arrow keys move through results. **This matters more here than in Konjugieren:** the Swiss
  institution ran Conjuguer on Macs.

Konjugieren needed UIKit for the arrow keys (a focused text field consumes ↑ and ↓ ahead of every
SwiftUI mechanism), a top-level `CommandMenu` for Command-F (the system's Find item claims it
otherwise), and a search field that stays put on iPad (`.navigationBarDrawer(displayMode:
.always)`), because iPadOS 26 shrinks `.automatic` search into a button that ignores
`.searchFocused`. Josh judged that layout change for Konjugieren; show him the same here.

Phase 5 changes when the empty state appears, since a conjugation will then find its verb. Note
anything here that Phase 5 must revisit.

**Done when** a misspelling (venier, assoir, manjer) offers its verb as a guess, nonsense offers
none, the mail line works, and Command-F, Return, and the arrows work on the iPad simulator with
hardware key events sent by AXe (`axe key`, `axe key-combo`; key presses sent to Simulator.app
through computer use did not reach the device in Konjugieren).

**How it differed:**

Built 2026-11-22. Every "Done when" check passed in the simulator, and the suite ran 321 tests in
27 suites, all passing (`VerbSearchGuessTests`, 10 tests with 39 cases, and one new
`DeeplinkTests` test). New files: `FailedVerbSearchView.swift`, `VerbSearchCommands.swift`,
`VerbSearchArrowKeys.swift`. The design is Konjugieren's; what differs:

- **The guess** is `VerbSearch.closestVerb`, Konjugieren's rule (optimal string alignment distance
  over folded infinitives, at most one edit per three letters and never more than three, ties to the
  more frequent verb) with Conjuguer's query handling: "se " and "s'" are dropped and œ folds to oe
  before measuring, so "se souvnir" guesses souvenir and "s'assoir" asseoir. venier, assoir, and
  manjer give venir, asseoir, and manger (ahead of manier, also one edit away); xyzzyq gives
  nothing, and then only the mail line shows. Infinitives only, as in Konjugieren's Phase 2.
- **The empty state** replaced the overlay with `FailedVerbSearchView`, a scroll view holding
  `ContentUnavailableView.search` (kept, so its "Check the spelling" line still shows), the heading
  "A guess at the verb you meant:" ("Le verbe que vous cherchiez, peut-être :"), the guess as a card
  in the same `BrowseRow` the list uses, and the mail line. The card is used on iPhone too, where
  the list has plain rows, because the guess stands alone under a heading. The French strings use
  vous, as the catalog's other sentences do.
- **The mail line** reads "If you believe that “venier” is a French verb, please email
  vermontcoder@gmail.com." The subject is "Conjuguer: please add “venier”". The address lives once,
  as `URL.developerEmail`. The clipboard fallback, its four-second note, and its VoiceOver
  announcement are Konjugieren's, and the simulator showed them.
- **Both tabs got the fixed iPad search bar.** Konjugieren's only search was its verb list, so it
  changed one tab. Conjuguer's Models tab has a search field too, and it would have looked odd for
  the two tabs to differ, so `BrowseLayout.searchPlacement` serves both. This also settles Phase 1's
  note: the accent row now shows on iPad as soon as the field is focused, under the bar. **Josh
  should judge this layout change** (screenshots in the session's report). iPhone is unchanged.
- **Return and the arrows act only while the field holds a query**, as well as only on the iPad
  idiom. Konjugieren showed recents in the empty field; Conjuguer has none until Phase 10, and
  Return opening être from an empty field would surprise. Phase 10 should revisit this.
- **The highlight** is the card's own accent bar (`.card(accent: .customRed)`) in the iPad grid, and
  a 20% red row background in the compact list (an iPad in Split View).
- **Command-F** goes through `World.openVerbSearch()`, which clears a deeplinked verb, model, or
  article sheet, switches to the Verbs tab, and sets `verbSearchIsRequested`; `VerbBrowseView`
  pops a pushed verb page, waits 500 ms as Konjugieren found it must, and focuses the field with its
  text kept. Tested from the Verbs list, a pushed verb page, and the Quiz tab. **Not handled:** a
  verb sheet that a model page presents from its own state (`ModelView`'s `detailSheet`) stays open
  over the Models tab when Command-F switches away, and is still there on return. Not tested.
- **How it was tested.** On "Conjuguer iPad Pro 11", iOS 26.3, with AXe: `axe key-combo --modifiers
  227 --key 9` for Command-F, `axe key 81`/`82` for ↓/↑, `axe key 40` for Return. Stepped one press
  at a time and in quick pairs, every move landed where expected, and Return opened the highlighted
  verb (venger), the first result, and the guess (manjer → manger). One early run, sent before I
  had a reliable way to read the highlight, appeared to end on the first result after three ↓ and
  one ↑; I could not reproduce it. Not tried on a Mac or a real iPad. On the iPhone, the empty state
  was checked in English (light) and French (dark), including the mail tap and the guess tap.
- **VoiceOver.** The guess card is a `Button` around `BrowseRow`, so it shares the list rows'
  untested two-language flattening (`docs/voiceover.md`). The mail address is a link inside text,
  which VoiceOver reaches through the Links rotor.
- **For Phase 3.** No analytics yet. A page opened from the guess should send `source`
  `searchGuess`; an open by Return or an arrow is an ordinary search open, with `resultPosition`
  from `keyboardSelection`.
- **For Phase 5.** The empty state, and with it the guess, should appear only when the conjugation
  lookup also fails. `closestVerb` considers infinitives only; decide whether a misspelled
  conjugation (finnissons for finissons) should guess too, as Konjugieren's later did. `keyboardTargets`
  in `VerbBrowseView` assumes one row per verb, and `scrollToKeyboardSelection` scrolls by verb id;
  a conjugation row (suis under être and suivre) changes both.

## Phase 3: Lookup Signals

**Ideas:** the three signals in the ideas document's "What to Measure". **Ports:** Konjugieren
Phase 3 (`SearchReport.swift`, `VerbVisit.swift`, `Analytics.swift`). **Depends on:** Phase 1, so
the match kinds exist. **Status:** Done (2026-11-22).

- `finishSearch`, sent once per search, with banded `outcome`, `queryLength`, `resultCount`,
  `matchKind`, and `resultPosition`.
- A `source` parameter for the verb page's appearance.
- `leaveVerbView`, sent once per verb visit, with `deepestSection` and a banded `dwell`.

Conjuguer differs in two ways. Its one screen signal is `viewAppeared` with `viewName`, so decide
whether `source` rides on `viewAppeared` when `viewName` is `VerbView`, or whether the verb page
gets its own `viewVerbView` as in Konjugieren. Keep existing signal names, so TelemetryDeck's
history stays continuous, and give new signals Konjugieren's names, so the three apps can be read
side by side. Second, Conjuguer's verb pages open both pushed and as sheets (deeplinks, model
pages), and a visit must be defined for both.

Define the full vocabulary of `source` and `matchKind` values in one place now, including values
for surfaces later phases build (`related`, `recent`, `myVerbs`, `list`, `widget`, `spotlight`,
`shortcut`, `control`, `quickAction`, `lookup`, `deeplink`, `infoLink`, `modelPage`,
`reviewCard`, `searchGuess`, `resume`). Never send a verb or any typed text. Record the vocabulary
in `docs/feature_architecture.md` § Analytics, marking which values are sent today and which phase
will send the rest. Deeplinks carry `source` as a query item (`conjuguer://verb/aller?source=widget`),
since a widget or intent can pass the app only a URL; `hasExpectedNumberOfDeeplinkComponents`
counts path components, so check that a query item does not break today's parsing.

**The privacy policy.** Stage the lines in `docs/privacy_policy_pending.md`, in English and French,
and do not touch `docs/privacy_policy2.txt`. The policy's paragraph saying the app "does not record
… the verbs you look up" stays true, since nothing names a verb.

**The convention for later phases.** Each phase that adds a way to reach a verb page sets its
`source` value and stages its line. Phases 8, 10, and 11 add `tapShareVerb`, `tapStarVerb`, and
`tapTestVerb`. Phase 11 adds `source` to `quizStart`.

**Carried over:** all three signals; banded values only; lines staged, not deployed.

**Done when** the signals fire as designed in the simulator (log them temporarily, or read
`AnalyticsSpy`), tests pin the bands, the tracker's lifecycle, every report's parameters, and a
check that no parameter can echo the query.

**How it differed:**

Built 2026-11-22 on top of Phase 2's uncommitted changes. The suite ran 352 tests in 30 suites, all
passing (31 new: `AnalyticsTests`, `SearchReportTests`, `VerbVisitTests`, and five in
`DeeplinkTests`). New files: `SearchReport.swift`, `VerbVisit.swift`,
`Shared/OpenRandomVerbControlIntent.swift`. Every name, key, and value is in `Analytics.swift`, and
`docs/feature_architecture.md` § Analytics has the signal table, the full `source` and `matchKind`
vocabularies with the phase that will send each unsent value, and the convention. The design is
Konjugieren's; what differs:

- **`source` rides on `viewAppeared`.** The plan left the choice open. A separate `viewVerbView`
  would have split TelemetryDeck's series of verb pages in two, so the verb page still sends
  `viewAppeared` with `viewName` `VerbView`, now with `source`, and no longer through
  `.recordsAppearance`. One change in meaning: it now also fires, as `resume`, when the app returns
  from the background with a verb page showing, so that every one pairs with a `leaveVerbView`.
  The new signals take Konjugieren's names (`finishSearch`, `leaveVerbView`).
- **A visit is the same for a pushed page and a sheet**: `onAppear` to `onDisappear`, broken by the
  background. Beyond Konjugieren, the page's own model sheet also ends the visit, and closing it
  resumes it, because the reader is on the model page. A sheet that something else presents over a
  page (a deeplinked verb over a pushed one) does not; I left that rare case alone.
- **No `source` on `finishSearch`.** The plan's five parameters only. Konjugieren added `source` to
  it in its Phase 11, for searches that Control Center or a quick action opens; Conjuguer's Phase 9
  should do the same (noted in § Analytics). So `SearchTracker` is Konjugieren's without
  `fieldOpened(from:)`.
- **`matchKind`** names `VerbSearch.MatchKind`'s nine cases, including Conjuguer's `glossMeaning`,
  through an exhaustive switch, plus `guess` and `none`. `conjugation` and `foldedConjugation` are
  reserved for Phase 5, which may rename them; nothing sends them yet.
- **The vocabulary** is the plan's list plus `browse`, `search`, `tab`, and `verbPage`. No
  `handoff`, since no phase plans Handoff, and no `sharedLink`, which Phase 14 may add for its
  collection links. Sent today: `browse`, `search`, `searchGuess`, `modelPage`, `infoLink`,
  `widget`, `control`, `shortcut`, `deeplink`, `resume`.
- **The control needed its own intent**, as in Konjugieren: the Random Verb control and the
  Shortcuts app ran the same `OpenRandomVerbIntent`. The control now runs
  `OpenRandomVerbControlIntent` (`isDiscoverable = false`, the same title key), whose link names
  `control`; the original names `shortcut`. `release.md` asks for a device check that a control
  installed before the update still works.
- **Links name their source** with a `source` query item: the widgets
  (`WidgetDeeplink`), both random-verb intents, and Info articles' verb links. A query item does not
  change `pathComponents`, so today's parsing holds (tested, with a percent-encoded verb too).
  `World.verbSource` keeps it for the sheets that present `World.verb`. **Phase 9's grammar should
  keep this item.** The Models tab's search sends nothing; it is not a verb lookup.
- **Sections**: `simple` is the présent card, `compound` the passé composé card. With the compound
  toggle off by default, the etymology card comes on screen with the toggle, so `compound` is rarely
  the deepest section; I could not show it in a `leaveVerbView` in the simulator for that reason.
  Phase 6, which turns the toggle on, should check that a leave can report `compound`.
- **A quirk kept from Konjugieren.** Editing the text after an open begins a new search, so
  deleting a query letter by letter reports an abandoned search of its last letter or two (seen on
  the iPad). It inflates `abandoned` slightly at `queryLength` `1-2`.
- **How it was tested.** With `AnalyticsSpy` logging temporarily (removed), on the iPhone: a browse
  open, a leave at `example` after scrolling, `resume` after a tab switch and after the background,
  a search opened at position 2-5 (etre → étreindre, `foldedInfinitivePrefix`), a second open with
  no second `finishSearch`, `noResult` (xyzzyq), the guess (venier), `abandoned` on backgrounding
  (ven), a `?source=widget` link, the model sheet ending and resuming a visit, and `modelPage`. On
  the iPad: Command-F, ↓ ↓, Return (`opened`, position 2-5), and Return on a guess (manjer). Info
  links and the control were tested through their URLs in unit tests only. Nothing visible changed,
  so there were no language or appearance checks.
- **Privacy lines** for all three signals wait in `docs/privacy_policy_pending.md` in English and
  French, including a sentence for the paragraph after the list so that it stays true.
  `privacy_policy2.txt` is untouched.

## Phase 4: The Conjugation Map as a Build Product

**Ideas:** A5, first half. **Ports:** Konjugieren Phase 5 (`ConjugationMapTool/`,
`ToolWorld.swift`, `ConjugationMap.swift`, `ConjugationMatch.swift`). **Depends on:** nothing.
Josh confirmed on 2026-11-22 that reverse lookup is built. **Status:** Done.

- A macOS command-line target that compiles the Conjugator's sources and writes a compact
  conjugation-to-infinitive map for the app bundle.
- A Run Script build phase that regenerates the map only when `verbs.xml`, `verbModels.xml`,
  `defectGroups.xml`, or the tool is newer than the output. A build with no changed input must not
  run the tool. Judge this by file timestamps, not by the build log: Konjugieren found that an
  Xcode activity log carries forward records of earlier builds.
- A loader in the app, and `Verb.conjugations(matching:)`, which answers "which conjugations of
  this verb equal this text?". The pedagogy plan's slip and diagnosis phases call it on wrong
  answers, so it matches cells exactly.
- The tool replaces `CorpusFormsDumpTests` as the writer of `corpus/working/forms.json`, as
  Konjugieren's did, if its output for the 1,000 most frequent verbs matches the harness's. Update
  `docs/literature_example_corpus.md` and the harness's mentions accordingly.

French specifics:

- **Measure the map's size first.** Konjugieren's held 50,056 conjugations of 3,572 verbs (173 KB
  compressed). Conjuguer has 6,326 verbs and 20 tenses. Include the participe passé's agreed forms
  (allée, allés, allées), since texts use them, and every alternate that `Tense.alternateConjugationSeparator`
  ("/") separates (paie, paye). Leave out forms a verb's defect group lacks.
- **Homographs are common**: suis (être, suivre), vis (vivre, voir), fus, lis, tu (taire's
  participe passé), été (être's participe passé). Keep every verb under a key.
- **The Conjugator reads `Current.settings.pronounGender`** for participle agreement when no gender
  is passed. The tool passes one explicitly. Find what else the Conjugator and its model types
  reach (`L`, `Current`, `@MainActor` state) before writing code, and move presentation out of the
  core as Konjugieren did (`ConjugationLabels.swift`).
- **A new target needs `project.pbxproj` changes**, unlike adding a file. Konjugieren edited the
  project file directly and listed the borrowed app files in a membership exception. If the
  refactor looks large (a local Swift package, say), stop and ask Josh.

**Done when** a clean build produces the map, an unchanged rebuild skips the tool, a test compares
the bundled map with a fresh in-process build, and a test confirms that the map finds the verb of
at least 99% of the app's example sentences (`literature_examples.json`), with the measure stated
exactly.

**How it differed:**

Built 2026-11-22. Every "Done when" check passed. The suite ran 366 tests in 34 suites, all passing
(17 new, in `ConjugationMapTests` and `ConjugationMatchTests`; the three disabled
`CorpusFormsDumpTests` are gone). Nothing visible changed, so there was no simulator check. The
design is Konjugieren's; what differs:

- **The risks were small, and there is no `ToolWorld`.** The core compiles for macOS under the
  app's default MainActor isolation once its display members move, unchanged, to the app-only
  `ConjugationLabels.swift`: `PersonNumber`'s `pronoun`, `pronounWithGender`, `gender`, and
  `preamble`; `Tense`'s four pronoun accessors; `PronounGender.localizedGender`; and
  `VerbModel.description` and `verbsWithDeepLinks`. The Conjugator's own `conjugate` and
  `conjugatedString` now require the pronoun gender, and the app's overloads in the same file
  default it to the setting, so no call site changed and the tool cannot forget to choose one.
  Two calls inside the core, for the auxiliary and the nous stem, pass `.masculine`, which cannot
  matter there. After the move nothing in the core reaches `Current`, so the tool needs no
  stand-in World; `main.swift`'s header says what to do when a core file starts reaching the app.
  The parsers needed nothing, since `init(xmlString:)` already existed.
- **The target was added by editing `project.pbxproj`**, as in Konjugieren, with the same build
  settings. It borrows 24 app files through a membership exception on the `Conjuguer` folder
  (`EndingDisplay.swift` was the one surprise). CLAUDE.md's Project Layout now says so.
  An unsigned `xcodebuild archive` produced an archive holding only the app, with the map inside
  it, byte-identical to the Release tool's output. **Not tried:** Xcode's own interface, and an Apple Silicon Mac.
- **The build phase** ("Generate Conjugation Map", after Resources) declares the three XML files
  and the tool's executable. Measured by the map's timestamp in the built app: an unchanged
  rebuild skipped it (three times); touching `verbs.xml` ran it; a code edit to
  `ConjugationMap.swift` relinked the tool and ran it; deleting the tool, which relinked to
  identical bytes, ran it. **The tool's own timestamp misleads too.** Each switch between a test
  run and a build re-signs the tool, because its entitlements file differs between the two
  actions, and the map phase does not rerun for that, which is right, since a signature cannot
  change the map. Twice this looked like a missed regeneration until the build log showed only
  `CodeSign … replacing existing signature`.
- **The size, measured first:** 242,923 conjugations from 6,330 entries, 5.0 MB of text, 615,637
  bytes compressed, against Konjugieren's 50,056 and 173 KB. Beside the 8.5 MB of etymologies and
  18 MB of sounds it is small, so nothing was cut. Loading it took 1.2 seconds in a Debug build on
  this Intel Mac's simulator, so **Phase 5 must touch `ConjugationMap.bundled` from a background
  task** before the first search.
- **What goes in.** The infinitive, every simple tense and both participles, each `/` alternate
  on its own, and the participe passé's agreed forms for every verb, avoir verbs included, since
  "la lettre qu'il a écrite" agrees too. `agreedForms(ofParticiple:)` handles the four kinds that
  appending e, s, es gets wrong, found by listing every participle's ending: dû, crû, mû, and redû
  (due, dus), the 48 in -s (prise, pris), and absous and dissous (dissoute). Left out: the radical
  du futur, every cell a defect group strikes, and the compound tenses. Values are `Verb.verbs`
  keys, so "sortir exit" and "sortir obtain" stay apart (sors finds only the first).
- **The map is sorted by UTF-8 bytes, not by `sorted()`.** The first two builds of the same data
  wrote different bytes: `sorted()` had left 155 and 161 keys out of order (anathématiserai after
  anathématiserait), apparently because `precomposedStringWithCanonicalMapping` returns bridged
  strings whose comparison is not consistent. The test that compares the bundled map with a fresh
  build compares dictionaries, so it could not see this; the determinism check was a `cmp` of two
  tool runs.
- **The tool writes all three of the harness's dumps**, not only `forms.json`:
  `--forms-json`, `--forms-all-json`, and `--conjugations-json`, through
  `scripts/write_forms_json.sh`. Konjugieren derived its `forms.json` from the map; here the dumps
  keep the harness's own rules (the radical du futur and defective cells kept, one-letter forms
  dropped, only compound participles agreed), because the corpus index was tuned on them, so
  `FormsJSON.swift` ports the harness's code rather than reading the map. All three were
  byte-identical to a fresh harness run on the same data, and the harness is deleted. The copies
  in `corpus/working` had been stale since July and September (4,852 of `forms.json`'s keys
  differed from a fresh run), and the harness run left them current.
- **The 99% test** finds 6,320 of 6,328 example sentences (99.87%). A sentence counts when one of
  its words maps to its verb; a word is a run of letters and hyphens, lowercased, plus its
  hyphen-separated parts, so arc-boutait stays whole and souviens-toi yields souviens; an
  apostrophe ends a word. Of the eight misses, two are cells the verb's defect group strikes
  (Flaubert's "Une blessure béait", and "Elle les douait", for béer and douer, whose groups allow
  only the participles and a présent 3s), and six are spellings the Conjugator does not produce
  (étiquètes and markete, the 1990 spellings; emmaillottent, presurer, redîmé, and
  s'entrenuisaient).
- **`Verb.conjugations(matching:)`** returns `ConjugationMatch` values of a `Tense` and an
  `isAgreement` flag, in page order. It matches exactly, as the plan asks: case and spacing
  ignored, accents not, so Phase 5 folds before calling. Compound cells match agreed either way,
  the impératif of a reflexive verb matches both "souviens" and "souviens-toi", the participe
  passé matches agreed with `isAgreement` set, and defective cells and the infinitive never
  match. The radical du futur is a cell and matches. About 10 ms per verb in a Debug build.
- **For Phase 5.** The map's keys are not folded: build a folded index at load time for etait and
  manoeuvre. Short keys are many: a, ai, as, es, eu, vu, su, lu, bu, and dû are all present, and
  tu is taire's. The infinitive is in the map but is not a cell, and an agreed participle is a
  cell only with `isAgreement`, so name those in the row's own words.
- **Found for Josh, not fixed.** The béer and douer defect groups contradict the app's own
  example sentences, which use their imparfait. And the Conjugator agrees a participle in -s by
  appending s, so with the pronoun gender set to masculine or both, the verb page's plural
  compound cells read "nous nous sommes mépriss" for se méprendre, and likewise for s'éprendre
  and s'enquérir (found in `forms_all.json`). The map does not inherit either: it
  agrees participles itself.
- **Fixed after the phase, the same day, at Josh's request.** béer moved from defect group 3 to
  17 (présent, imparfait, participe présent), the Académie's 9th edition's "usité surtout à
  l'indicatif présent et imparfait, au participe présent et à l'infinitif présent". douer lost
  its group 6: the TLFi finds it rare outside the infinitive and the compound tenses "sauf chez
  les écrivains récents", and quotes Gide, Paulhan, and Mounier using finite forms, as the app's
  Proust example does. Group 3 is now unused. The participle fix uncovered a worse bug in the
  same lines: every compound tense of the sixteen mettre-family verbs read "j'ai misu", because
  the compound path appended the model's ending to a participle that a marked stem alteration
  (mIS*) had already completed. The compound tenses now build the participle as the participe
  passé does, and agree it through `Conjugator.agreed(participle:ending:)`, which the map's
  `agreedForms` now shares. The 99% test finds 6,322 of 6,328; the map holds 242,966
  conjugations. The regenerated corpus dumps changed only in those verbs' forms.

## Phase 5: Reverse Lookup in Search

**Ideas:** A5, second half. **Ports:** Konjugieren Phase 6 (`ConjugationIndex.swift`,
`VerbSearchResults.swift`, `MarkedConjugations` in `VerbView.swift`). **Depends on:** Phases 1
and 4. **Status:** Done (2026-11-22).

- A conjugation finds its verb. Each result row names the match, in the manner of
  "vais: Indicatif présent (je)" under aller. When a conjugation belongs to two verbs (suis), show
  both.
- A subject pronoun, elided or not, is dropped before lookup: "je vais", "j'ai", "il fait",
  "nous allons". So is a reflexive pronoun: "me lève", "je me souviens", "s'est assis".
- A compound conjugation is looked up by its participle and confirmed by
  `conjugations(matching:)`: "ai mangé", "est allée", "avions fini".
- Accents are folded through Phase 1's fold, so "etait" finds était and "a" (typed without its
  accent for à) does not crowd the results. Keep a literal match ahead of a folded one.
- Opening a result lands on the matching section of the verb page with the conjugation marked. A
  match in a compound tense turns the compound block on (or opens it, per Phase 6's decision).

Short forms are noisy in French: a, as, ai, es, eu, vu, su, lu, dû, bu are all conjugations. Decide
how a one- or two-letter query ranks conjugation matches against infinitive prefixes, and test the
results for each of those queries. The empty state from Phase 2 now appears only when this lookup
also fails; decide whether the guess considers conjugations too (Konjugieren's did).

**Done when** suis, vais, fait, ai, j'ai, ai mangé, est allée, me lève, etait, and vins (venir's
passé simple, and no verb's infinitive) each give the wanted rows, a result opens onto its marked
cell, and tests pin each case.

**How it differed:**

Built 2026-11-22. Every "Done when" query gives the wanted rows, in `VerbSearchConjugationTests`
and in the simulator, and results open onto their marked cells. The suite ran 393 tests in 35
suites, all passing (27 new test functions in one new suite). New files: `ConjugationIndex.swift`,
`ConjugationQuery.swift`, `MatchedConjugation.swift`, `VerbSearch+Conjugations.swift`.
`docs/feature_architecture.md` § Reverse Lookup has the whole design. What differs from
Konjugieren's, and what the phase left open:

- **The tier, decided by simulation.** Konjugieren ranks a conjugation above every infinitive
  prefix. Simulated on Conjuguer's map, that put réer (#2,963) ahead of réaliser (#29) for réa,
  enter ahead of entendre for ente, and conter ahead of contenir for conte, because French
  conjugations of rare verbs are often the first letters of common ones. So a conjugation, literal
  or folded, shares Phase 1's prefix tier and ranks there by frequency. The short forms then come
  out right on their own: a, ai, and as find avoir first; es être; eu avoir; vu voir; su savoir; lu
  lire; dû and du devoir; bu boire; va aller; pu pouvoir; tu taire; né naître; but ri lists risquer
  ahead of rire, and mû (mouvoir, #1,647) does not lead the mu- verbs. All are pinned.
- **Literal before folded.** Phase 1 ranks a folded match below a literal one in its tier only when
  the query carries an accent. A word typed that is literally a conjugation now does the same,
  since it spells its accents as meant: mate gives mater first and leaves mâter and matérialiser
  behind materner. crois gives croire, croiser, then croître.
- **More of the sentence is dropped than the phase named.** Besides subject pronouns (elided or
  not) and reflexive pronouns, `ConjugationQuery` drops que and qu', y and en, and ne with the word
  that completes it (pas, plus, jamais, rien, point, guère), so "que je sois", "il y a", and "je
  n'ai pas mangé" work. A hyphenated word sheds its pronouns too (lève-toi, vas-tu, a-t-il), while
  souviens-toi, whole, matches only souvenir's impératif. A query of pronouns alone ("j'", "nous")
  plays no trombone, since it is a conjugation still being typed; it does show the empty state.
- **Pronominal compounds.** Only 217 verbs are stored as pronominal, so "je me suis levé" would
  have found nothing: lever conjugates with avoir. When the query carried a reflexive pronoun and
  an avoir verb's compound cells reject it, the être auxiliary is tried as the verb's pronominal
  use, and the row keeps the pronoun ("me suis levé: Passé Composé (je)"). It marks lever's "ai
  levé", the cell for that tense and person. Without a reflexive pronoun, "est levé" is a passive
  and matches nothing. asseoir is one such verb too, so "s'est assis" takes this path.
- **The row's words.** A red French line under the gloss: "suis: Indicatif Présent (je, tu) ·
  Impératif (tu)". Tense names are `titleCaseName`, French in both languages, and the line is not
  localized. The third person follows the pronoun setting, except that a feminine agreement names
  elle or elles ("est allée: Passé Composé (elle)"); "il" beside "allée" read wrong. An agreed
  participle reads "allées: Participe Passé (accordé)", the plan's "row's own words", in French
  like the tense names. **For Josh:** the line uses an English colon ("allées: Participe"), not
  French spacing ("allées : Participe"), in both languages.
- **The compound block** turns on when a match is compound, since its toggle is still off by
  default. Phase 6 must keep the landing working when the learner has turned the toggle off; the
  `@State`'s initial value is where it happens today.
- **Landing.** `VerbConjugations.scrollID(for:)` reads the same specs that build the cards, so
  Phase 6's reorder moves the landing with the page if it keeps the specs as the one order. Marked
  cells get a highlighter yellow (`Color.markedConjugation`): the palette's blue and red already
  mean regular and irregular letters in the cells. In dark mode it reads olive; Josh may prefer
  another color.
- **The guess considers conjugations**, as Konjugieren's did, for a query that is one word once its
  pronouns are dropped: finnissons and "je finnissons" guess finir through finissons, and the card
  names and marks the cells. An infinitive wins a tie. `closestVerb` became `guess(for:in:)`.
  Measuring 230,000 folds took up to 9 s per keystroke in a Debug build at first. A letter-count
  floor, a bounded byte comparison, and measuring lengths nearest the query's first with a
  tightening limit brought it to at most 0.3 s.
- **The index** folds only the 107,000 keys that have accents, and keeps the folds as packed bytes
  for the guess: 1.0 s to build in a Debug build, after the map's 1.2 s load, down from 3.3 s in the
  first version. `VerbBrowseView` builds it from a detached task when the tab appears. A Debug
  search with reverse lookup takes about 50 ms.
- **Phase 2's notes, settled.** One row per verb still holds (suis is two rows, être and suivre),
  so `keyboardTargets` and the scroll by verb id needed no change. The empty state, and with it the
  guess, appears only when this lookup fails too.
- **Not done.** A folded word that spells two forms of one verb shows only the first in UTF-8
  order: eleve's row names élevé, not élève too. "vais manger" and other periphrases find nothing.
  Object pronouns other than y and en (le, la, l', lui) are not dropped.
- **Analytics.** `conjugation` and `foldedConjugation`, already in `SearchMatchKind`, are now sent.
  The staged privacy line's examples name "a conjugation" ("une forme conjuguée").
- **How it was tested.** On the iPhone, in English and light mode: the new placeholder ("Verb,
  conjugation, or English meaning", which fits), suis (both rows), and "je me suis levée" opened
  onto lever's marked "ai levé" with the compound block on. In French and dark mode: allées opened
  onto the marked allé in the personless card, and finnissons showed the guess with its line. On
  the iPad, in English: "etait allee", then Return, opened onto the marked "était allée". Not
  tried: VoiceOver, and the Models tab, which this phase leaves alone (`conjugations: nil`).

## Phase 6: The Verb Page's Sections

**Ideas:** B3 as Josh amended it, and the tip from B5's verdict. **Ports:** Konjugieren Phase 7
(`ConjugationTable.swift`, `scripts/count_conjugationgroups.py`,
`docs/conjugationgroup_frequency.md`, `KonjugierenTips.swift`). **Depends on:** nothing; Phase 5
for the landing order. **Status:** Done (2026-11-22).

- **Order by frequency within each block.** Keep simple tenses before compound ones. Within each
  block, order the tenses by how often they occur in Conjuguer's corpus (`corpus/originals/`:
  literature, government, technology, wikipedia, and classical), with the counting method and
  results in a doc (`docs/tense_frequency.md`) and a script that reproduces them. Count with the
  map's cells (Phase 4) so the count and the page agree on what a conjugation is. The corpus is
  written French, so the passé simple will count high in literature and low elsewhere. Weight the
  folders equally, report each folder, and show Josh the register differences. Josh accepted for
  Konjugieren that frequency varies by register.
- **The compound block.** Keep the "Show compound tenses" toggle and turn it on by default (Josh,
  2026-11-22). Today it is an `@State` that starts off on every page and is not stored. Ask Josh
  whether a learner who turns it off should find it off on the next page and after a relaunch.
  Phase 5's landing must still work when the learner has turned it off.
- **Second names.** Beside each heading, the name a textbook also uses: passé simple, also passé
  défini; futur antérieur; conditionnel présent; and so on. Konjugieren's headings switched between
  German and English, and its second names followed the heading's language. Conjuguer's headings
  are always French, so decide with Josh whether the second name is a French alternate, an English
  name ("passé composé, also present perfect"), or both. Draft the list in both languages and show
  it to Josh before committing it.
- **Article buttons.** An info button at the right of every tense heading opens that tense's Info
  article in a sheet, so closing it returns to the verb. Conjuguer already has an article for every
  tense (`Info.infos`, keyed by `stableKey`) and already opens the irregularities article from a
  model page's question-mark button, so match that button's style or ask.
- **The color key.** Konjugieren built a TipKit tip explaining its red letters. Conjuguer already
  has a dismissible color-key card. Keep it, or replace it with a tip that shows only on a page
  with red letters; ask Josh.
- **Scroll tip.** After the color key is dismissed, a TipKit tip encourages scrolling to the bottom
  for the etymology and the examples. Once dismissed, or once the learner reaches them, it never
  reappears. Obey `TipDisplay.tipsEnabled`.
- Change the order on the verb page only, not in Info or the quiz, unless Josh says otherwise. Put
  the order in one place (Konjugieren's `ConjugationTable`) that the page and Phase 5's landing
  both read.

**Carried over:** simple before compound; frequency order within a block; every section visible (the
toggle on by default); second names shown to Josh first; tips that never reappear.

**Ask Josh:** whether the toggle's state is remembered; where the participles and the radical du futur belong
(Konjugieren's participles ended up below the Imperativ after Josh tried the page); the second
names; the color key.

**Done when** the page shows the new order, the second names, and the buttons, the tips behave as
decided, and tests pin the order and the landing.

**How it differed:**

Built 2026-11-22, on top of Phase 5's uncommitted work, which Josh had not yet tried. The suite ran
401 tests in 36 suites, all passing (8 new in `TenseTableTests`). New files: `TenseTable.swift`,
`scripts/count_tenses.py`, and `docs/tense_frequency.md`, which has the method, the per-folder
tables, and the known errors. `docs/feature_architecture.md` § Verb Page has the design.

- **Josh's decisions (2026-11-22).** The toggle's choice is remembered, across pages and
  relaunches. The personless card goes between the blocks, above the toggle. Second names follow
  the app's language: English textbook names in English ("also simple past"), French school names
  in French ("aussi passé défini"), and none where French has no alternate (the participles, the
  radical du futur, the passé antérieur, the futur antérieur, the passé surcomposé). The color-key
  card stays, but shows only on a page with red letters. He chose these from the drafts and counts
  in one round of questions, without changes.
- **The count.** `count_tenses.py` reads `corpus/working/conjugations.json`, which
  `ConjugationMapTool` already wrote for the pipelines, so no new tool output was needed, unlike
  Konjugieren's `--cells-json`. French needed more context rules than German: a subject pronoun
  fixes a word's person, a word without one is third person, a determiner or preposition makes it
  a noun, an impératif must open a sentence that ends in a period or "!", and a subjonctif needs
  que in its clause. A word that stays ambiguous (il finit, présent or passé simple) is shared in
  the proportions the folder's unambiguous words show, which no German rule needed. Six rounds of
  reading samples fixed the worst errors: masculine plural participles counted as je/tu passé
  simple (définis, mis), Wikipedia headings and quoted noun phrases counted as orders, "parfois" and
  "trois" read as old spellings of parfaire and traire, and "n'a point" read as poindre's passé
  composé. The *Chanson de Roland* is skipped as Old French.
- **The order.** Balanced and pooled shares agree in both blocks. The simple block changed in two
  places: the imparfait now precedes the passé simple, and the impératif precedes the subjonctif
  imparfait. The compound block is passé composé, plus-que-parfait, conditionnel passé, subjonctif
  plus-que-parfait, subjonctif passé, passé antérieur, futur antérieur, passé surcomposé,
  impératif passé. Two pairs are close and turn on the novels: four folders of five put the futur
  antérieur ahead of the passé antérieur, and the subjonctif plus-que-parfait leads the subjonctif
  passé on literary "eût été". Equal weighting, as the plan said, decided both. The technology
  folder holds five compounds in 12,000 words and still counts as a fifth.
- **`TenseTable`** (`Models/TenseTable.swift`) is the one place the order lives, as Konjugieren's
  `ConjugationTable` is. `VerbConjugations` builds its cards from it, `scrollID(for:)` reads it, and
  `Verb.conjugations(matching:)` orders its matches by `TenseTable.allTenses`, so search's row lines
  follow the page: "fait: Indicatif Présent (il) · Participe Passé", where Phase 5 put the participle
  first. Scroll identifiers are now the cards' case names (`passéComposé`), not `simple-0`. The
  simple-tense specs and `personlessScrollID` are gone.
- **The personless card** gives each of its three cells a heading like a tense card's (name,
  second name, article button), since each has its own article. Its old heading, "P. Passé,
  P. Présent, R. Futur", went with the one-line layout, and so did its catalog key.
- **The article button** is the model page's red question-mark diamond, as the plan suggested,
  beside the heading rather than at the card's edge. Konjugieren's opens a sheet whose links to
  verbs close it and open the verb in the Verbs tab. Conjuguer's pushes a linked verb or article
  inside the sheet instead, because a verb page here may itself be a sheet (from a model page, a
  deeplink, or the Info tab), and a sheet presented from the Verbs tab behind it would fail. A verb
  page inside the article sheet pushes its own articles through an environment value
  (`tenseArticleOpener`) rather than stacking a sheet. Phase 7 may reuse the pattern for related
  verbs. The new signal `tapTenseArticle` carries no parameters; its policy line amends the
  in-app-actions bullet in `privacy_policy_pending.md`.
- **The compound block** is `@AppStorage("showsCompoundTenses")`, true by default. Phase 5's landing
  still opens the block on a page whose search matched a compound tense, through a per-page flag,
  without changing the stored choice; touching the toggle there stores the new one. Tested with the
  toggle off: "ai mangé" opened manger with the block showing and "ai mangé" marked.
  Phase 3 asked this phase to check that a leave can report `compound`. That landing puts the
  passé composé card fully on screen with the etymology several screens below, so by `VerbVisit`'s
  rules its leave reports `compound`. The signal itself was not observed, since the simulator's
  `AnalyticsSpy` records without logging.
- **Red letters.** Every compound tense shows red letters in avoir's or être's forms, so "a page
  with red letters" would have been every page. The key shows when the verb's own simple tenses or
  personless cells have them: aller and venir show it, parler and finir do not. **For Josh:** a
  learner who only ever opens regular verbs never sees the key, though the auxiliaries in their
  compound tenses are red.
- **The scroll tip** is Konjugieren's, keyed to the color key's stored dismissal rather than to a
  tip's status: a page that appears after the key was dismissed unlocks it, and reaching the
  etymology or the examples retires it. A learner who never meets an irregular verb never sees
  either. Verified on a fresh install: aller's key, dismissed, then venir's page with the tip.
- **Not done.** No tense-heading text is localized: the headings stay French in both languages,
  as before. Info, the quiz, and the model page keep their own tense orders.
- **How it was tested.** On the iPhone, in English and light mode: aller's headings and second
  names; the Futur Simple article in its sheet; its "parler" link pushed parler inside the sheet,
  and parler's Imparfait button pushed that article in turn; Done returned to aller. "allées"
  landed on the personless card between the blocks with allé marked. The toggle, turned off,
  stayed off on venir's page and after a relaunch. In French and dark mode: the French second
  names, none under the personless rows, and the tip's French text. On the iPad, in English:
  prendre's page in a sheet, with the personless card and toggle. Not tried: VoiceOver. A switch
  ignores AXe's instant tap on iOS 26; the `verify-in-simulator` skill now says to hold the touch.

## Phase 7: Ways Between Verbs

**Ideas:** B4, A9. **Ports:** Konjugieren Phase 9 (`RelatedVerbs.swift`,
`RelatedVerbsView.swift`). **Depends on:** nothing; Phase 3's `related` source applies if done.
**Status:** Done (2026-11-22).

- **B4.** The verb page leads to related verbs: the base verb and its derivatives (prendre,
  apprendre, comprendre, surprendre; venir, devenir, revenir, convenir), the other frequent verbs
  of its model, and the model's page. Some bases have many derivatives (mettre, tenir, venir), so
  the page shows a short list with a way to see all. Konjugieren placed a Related Verbs card at the
  bottom, below the example, after Josh chose from screenshots of a prototype. Propose a placement
  here with a screenshot before building.
- **Finding a base is harder in French.** German prefixes are explicit in Konjugieren's data;
  Conjuguer's are not. A suffix match alone fails: oublier ends in lier, and allier is not a+lier.
  Accept a base only when the remainder is a known verbal prefix (re-, ré-, r-, dé-, dés-, com-,
  con-, sur-, sous-, entre-, pré-, pro-, ad-, a-, ap-, at-, em-, en-, in-, im-, par-, per-,
  trans-, contre-, mé-, mal-, bien-, ...) and, ideally, when the verb shares the base's model.
  [`plans/etymology_affixes.json`](etymology_affixes.json), the etymology pipeline's affix library,
  and the etymologies themselves may help. Measure precision on the 300 most frequent verbs and
  show Josh the doubtful pairs.
- **A9.** On a model's page, a segmented control above the verbs list chooses Alphabetical, the
  default and today's behavior, or Frequency. Konjugieren's choice was not stored, so a page always
  opened Alphabetical. Consider making the list tappable rows or chips rather than a run of links,
  so frequency order is legible; ask Josh.

Navigation: the verb page is pushed in the Verbs tab and presented as a sheet elsewhere. Konjugieren
used an environment action that each stack injects (`VerbPagePush`). Work out the same for
Conjuguer's sheets, so a related verb opened inside a sheet does not stack a sheet on a sheet.

**Done when** prendre's, venir's, and a regular -er verb's pages show sensible relations, the full
list opens, a model page sorts both ways, and tests pin the base-finding on a list of known pairs
and known false pairs.

**How it differed:**

Built 2026-11-22 on top of Phases 5 and 6. The suite ran 412 tests in 37 suites, all passing (11
new in `RelatedVerbsTests`). New files: `Models/RelatedVerbs.swift`, `Views/RelatedVerbsView.swift`,
and `Views/VerbPageNavigation.swift`. `docs/feature_architecture.md` § Related Verbs has the design.

- **Josh's decisions (2026-11-22),** all four from one round of questions, each the recommended
  option: the card at the bottom of the page, below the examples (chosen from screenshots of
  venir's and parler's pages); the model row and a model page's verb links push as the chips do,
  so no sheet stacks on a sheet; the model page's list stays a run of links, reordered; and
  compounds formed in Latin whose meaning drifted (attendre on tendre, demander on mander, rester
  on ester) count as built on their base.
- **Finding a base.** The rule is a verbal prefix (as allomorphs: ap-, res-, d- for décrire) that
  leaves a verb which the verb's etymology names in `~tildes~`, the longer base winning. Measured in
  Python first, then ported. Of the 300 most frequent verbs, 65 have a base and all are right. The
  etymology test caught every suffix coincidence the plan feared (oublier, répondre, ajouter,
  atteindre, accorder) but let through 9 pairs across the whole list, removed as
  `VerbBase.falsePairs`: the etymology names the base to refute it (supplier "is tempting to
  connect with plier", épisser, délibérer, encastrer, débrailler, asservir, enrouer) or names it as
  something else (arriver's English ~river~, considérer's cognate ~sidérer~). I found them by
  flagging every pair whose mention fell outside the first paragraph or shared a sentence with a
  word of negation, 153 in all, and reading each. Six misses whose etymology names only the Latin
  verb (advenir's ~venīre~) are `VerbBase.knownPairs`. They were found among prefixed verbs that
  share an irregular model with an unmatched base. Regular -er verbs were not searched for misses.
- **allier is built on lier** (Latin alligare, ad + ligare), though the plan named it a false pair.
  By the standard Josh accepted it is a true one. oublier is the plan's real false pair, and the
  tests pin it.
- **"Ideally, when the verb shares the base's model"** was not used. Conjuguer splits near
  relatives into separate models (dire 5-8A, prédire 5-8B; voir 4-1A, prévoir 4-1B), and model 1-1
  holds 4,859 verbs, so the model test would have dropped good pairs and kept no bad one out.
- **The model relation** shows the most frequent verb of each other root in the model, not
  Konjugieren's root verb of each, so demander rather than mander speaks for its root. Its "All 29"
  chip opens the model page in frequency order rather than a second list. The row is hidden when
  the model holds only this verb's family (prendre's 5-2). The family row's "All 11" opens
  `RelatedVerbListView`, Frequency first, as in Konjugieren.
- **Navigation.** Every stack that shows a verb or model page now holds a `NavigationPath` and
  injects `VerbPagePush` through `verbPageNavigation(path:done:)`: the Verbs tab (whose
  `selectedVerb` became the path), the Models tab, every `.sheetDismissable()` sheet, and
  `TenseArticleSheet`, whose private `Route` enum went away. In a sheet each pushed page also gets
  Done. Phase 6 suggested reusing its article-sheet pattern; this generalizes it.
- **The model page's alphabetical order** now uses French collation. The old plain sort put
  écouter after the z's.
- **Analytics.** A verb opened from the card or its full list sends `source` `related`, now marked
  sent. The staged policy bullet's examples now name "another verb's page", in both languages.
  `RelatedVerbListView` sends `viewAppeared` with its own name. No new signal.
- **Seen, not fixed.** In English, VoiceOver's label for the verb page's model row ends in
  "Suivant", because the chevron sits inside the row's French locale. It predates this phase.
- **How it was tested.** On the iPhone, in English and light mode: venir pushed from a search,
  with advenir among its 18; tenir pushed from its chip; tenir's model row pushed the model page,
  whose Frequency order put venir, devenir, tenir first; convenir pushed from that list. In French
  and dark mode: mettre's card in a deeplink sheet ("Formés sur mettre", "Les 15"), the full list
  pushed inside the sheet, remettre pushed from it, and Terminé closed the sheet. In the Models
  tab, a model page's verb link pushed. On the iPad, in English: prendre's card in a sheet, and
  comprendre pushed inside it. Not tried: VoiceOver, and a verb link inside a tense article since
  `TenseArticleSheet` moved to a `NavigationPath`. The article sheet itself still opens.

## Phase 8: Copy and Share

**Ideas:** B6. **Ports:** Konjugieren Phase 10 (`KeyConjugations.swift`, `ShareSheet.swift`).
**Depends on:** nothing. **Status:** Done (2026-11-22).

- A long press on a conjugation opens a context menu with Copy (Konjugieren's choice: the
  platform's convention, it works with a right-click on a Mac, and it needs no toast). A tap still
  speaks it, if it does today; check.
- A share button on the verb page sends a short text: the verb, its gloss, its key conjugations
  with no label, and the App Store link.
- Build the key-conjugations function here: the il présent, il passé composé, and il futur simple
  (Josh, 2026-11-22), as in "vient · est venu · viendra", in that order, with il's agreement
  (est venu) whatever the pronoun-gender setting, since the forms stand without a pronoun. Phases 9 and 13,
  and the pedagogy plan's key-conjugations exercise, reuse it. Return mixed case, so red letters
  can show; lowercase for sharing.

Konjugieren found that `ShareLink` in the navigation bar reported no tap (so its signal could not
be sent) and that a `SharePreview` removed Copy from the sheet. It presents
`UIActivityViewController` from a plain button with `LPLinkMetadata`, anchored on iPad.

**Carried over:** App Store link only, no `conjuguer://` link in a verb's share text; a context
menu, not an instant copy; `tapShareVerb` with no parameters.

**Done when** the copied text and the shared text are right for aller, se souvenir (with its
reflexive pronoun as the page shows it), and a defective verb, and tests pin the key
conjugations.

**How it differed:**

Built 2026-11-22. The suite ran 421 tests in 38 suites, all passing (9 new in
`KeyConjugationsTests`, 25 cases with their arguments). New files: `Models/KeyConjugations.swift`
and `Utils/ShareSheet.swift`. `docs/feature_architecture.md` § Copy and Share has the design. No
question needed Josh.

- **A tap does not speak today, and still does not.** No cell on the verb page had a tap action,
  as `docs/voiceover.md` already said, so there was nothing to keep.
- **The key conjugations** are `Verb.keyConjugations()`, over `Verb.keyTenses`, which later phases
  should read rather than restate. A form the verb's defect group marks unused is left out, as
  Konjugieren leaves out a failed one: gésir gives only "gît", accroire nothing, and the share text
  then drops the line. falloir and the weather verbs keep all three, since their defects spare the
  il forms. The reflexive pronoun is elided as the cells elide it, through a test that
  `PersonNumber.preamble` now shares (`elides(before:hasAspiratedH:)`).
- **The share text cites a pronominal verb with its pronoun**, "se souvenir", though the page's
  heading shows "souvenir" over a Reflexive note. "souvenir, “remember”" would read as the noun.
  This is `Verb.citationInfinitif`. The French text says "du verbe aller", not "de aller", which
  would need an elision for every vowel-initial verb. Its gloss stays English, in guillemets.
- **What a long press copies** is the form as the cell shows it, lowercase, without the pronoun in
  the column beside it ("vais"; "souviens-toi" keeps its hyphenated pronoun, which is part of the
  form). The heading copies the bare infinitive. A struck-through, unused form still copies.
  `ShareSheet` and the copy modifier are Konjugieren's, nearly unchanged; the share button has an
  identifier, `verb_share_button`, which Konjugieren's lacks.
- **Analytics.** `tapShareVerb`, no parameters, staged in `docs/privacy_policy_pending.md` as a
  change to the same bullet Phase 6 changes. Copying sends nothing.
- **How it was tested.** On the iPhone, in English and light mode: aller from a deeplink sheet,
  where the share button sits beside Done; the sheet's header (aller, the Arc de Triomphe icon) and
  its Copy; the copied text read with `simctl pbpaste`; a long press on "vais" copying "vais", the
  lifted preview uncropped; se souvenir's text. In French and dark mode: être pushed in the Verbs
  tab (share button opposite the back button, sheet showing "Copier"), and gésir's text ("gît"
  alone, guillemets, "du verbe gésir"). On the iPad, in English: the popover appears over the
  button, with no arrow (iOS 26), placed by the bar-button search rather than the fallback. That
  `tapShareVerb` fired was inferred from the sheet appearing, since `AnalyticsSpy` does not log.
  Not tried: Messages, Mail, a device, VoiceOver, a Mac's right-click.

## Phase 9: Lookup from Outside the App

**Ideas:** C1, C2. **Ports:** Konjugieren Phase 11 (`LookUpVerbIntent.swift`,
`KonjugierenShortcuts.swift`, `VerbEntity.swift`, `VerbSpotlight.swift`, `VerbLookup.swift`,
`FindVerbControl.swift`, `QuickActions.swift`, `OpenVerbSearchIntent.swift`). **Depends on:**
Phase 5 for conjugation answers, Phase 8 for key conjugations. **Status:** Done (2026-11-22). Likely to
split: Conjuguer has none of the App Intents scaffolding Konjugieren had before its Phase 11.

- **The grammar first.** Write one deeplink grammar in `docs/feature_architecture.md` §
  Deeplinks: `conjuguer://<route>[/<target>][?items]`, text only in query items, `source` on any
  route to a page, a search, or a quiz. Add a `search` route with text as `q`; let `verb/` carry a
  `match` item that the page marks; address `info/` by stable key while still accepting a
  position. Reserve `list/<key>` for Phase 14. Keep every existing link working, including the
  `quiz/` route's behavior. Add `URL` builders so app code no longer interpolates links
  (`VerbModel.verbsWithDeepLinks` does today).
- **C1.** A "Look Up a Verb" App Intent that asks for a word, answers in the manner of
  "vais: Indicatif présent of aller", and opens the page; an `AppShortcutsProvider` with English
  phrases (the existing convention; C3 was rejected); a Control Center control that opens search
  (see `ConjuguerWidget/RandomVerbControl.swift` for the pattern); and a Home Screen quick action.
- **C2.** Index each verb for Spotlight with its gloss and its key conjugations, through
  `AppEntity` in a named index, as Konjugieren did. Konjugieren's Spotlight matched only titles in
  the simulator; record whether this was tested on a device.
- Mind the cold-launch race: `World.pendingDeeplink` replays a URL that arrives before
  `VerbData` loads. Every new entry point (intent, quick action, Spotlight) must go through it.

**Carried over:** shortcut phrases in English only; no web domain; the grammar written before the
routes.

**Done when** each entry point opens the right page or search from a cold launch and a warm one,
the grammar's round trips are tested, and the intent answers for aller, vais, and suis (two verbs:
open the search).

**How it differed:**

Built 2026-11-22 in one session, not split. The suite ran 459 tests in 40 suites, all passing, 38
more than Phase 8's 421 (two new suites, `VerbLookupTests` and `VerbSpotlightTests`, sixteen new
tests in `DeeplinkTests`, and five in `SearchReportTests`). New files: `Intents/` (`LookUpVerbIntent.swift`, `ConjuguerShortcuts.swift`,
`VerbEntity.swift`, `VerbSpotlight.swift`), `Models/VerbLookup.swift`, `App/QuickActions.swift`,
`Shared/OpenVerbSearchIntent.swift`, and `ConjuguerWidget/FindVerbControl.swift`.
`docs/feature_architecture.md` § Deeplinks has the grammar and § Lookup from Outside the App the
rest. No question needed Josh. What differs from Konjugieren, and from the phase as written:

- **The grammar** is Konjugieren's with Conjuguer's routes. `verb/` targets stay `Verb.verbs` keys,
  so each entry of a doubled infinitive keeps its own link. `info/` takes the stable key that
  `Info` already had for screenshots, and still takes a position. `list/` is reserved and not
  handled. The builders replaced every literal in app code (`InfoView`, `verbsWithDeepLinks`, the
  verb page's article sheet); `AnalyticsSource.ofDeeplink` became `URL.analyticsSource`.
  `verbSearchIsRequested` and `openVerbSearch()` became Konjugieren's `searchRequest` and
  `openSearch(text:source:)`, which Command-F uses with nil text.
- **`match` is read as search reads a query**, not by `Verb.conjugations(matching:)` alone, so a
  link can carry anything a search row matched: "ai mangé", or "me suis levé" on lever.
- **The App Intents scaffolding was missing**, as the phase warned, and was built small: one
  `AppShortcutsProvider` (Look Up a Verb, plus the two existing intents, Start Quiz and Random
  Verb), and a `VerbEntity` with a string query that exists for Spotlight. There is no Open Verb
  intent with a verb parameter, which Konjugieren had before its Phase 11; nothing asked for one.
  The phrases are English; the short titles are localized.
- **An intent can run before any window.** Conjuguer parses its verbs in the window's `.task`,
  where Konjugieren's are ready at once, so a background launch for Look Up a Verb would have
  found nothing. `VerbData.ensureLoaded()` now parses once however many callers ask, and the
  intent and the entity query await it.
- **Spotlight indexes only when the version changes.** Konjugieren reindexes at every launch.
  Here the key conjugations of 6,330 entries take seconds of the main actor, so
  `VerbSpotlight.indexVerbsIfNeeded()` compares the version, build, and a `format` constant with
  the last successful index. Conjuguer never had default-index entries, so Konjugieren's
  migration (and its deletion bug) did not apply. The entity's title is the citation form ("se
  souvenir"), and its identifier the dictionary key.
- **Analytics.** `finishSearch` gained `source`, as Phase 3 asked; `spotlight`, `lookup`,
  `quickAction`, and `tab` are now sent. Both staged policy bullets that change are in
  `privacy_policy_pending.md`'s new section, in both languages.
- **How it was tested, all in the simulator.** On the iPhone, in English and light mode: the
  `search` route with text warm (suis, from the Quiz tab) and the empty control link over an open
  verb sheet; a cold launch from `verb/manger?match=ai%20mangé`, which landed on the marked cell;
  Spotlight for aller, showing "va · est allé · ira" over "go", and its tap into the page; the
  quick action cold and warm (it lives in the App Library, since the icon is not on a Home Screen
  page); Look Up a Verb from the Shortcuts app for vais (aller, "vais" marked), suis (the search,
  two rows), and aller (its page), and the Random Verb shortcut. In French and dark mode: a
  `search` link for "j'ai mangé" and the quick action's title, "Chercher un verbe". On the iPad,
  in English: the `search` route and `verb/être?match=était`.
- **Not seen, as in Konjugieren.** Look Up a Verb's answer never showed before the app opened, and
  Spotlight matched only titles: vais, "to go", and souviens found nothing. **Tested in the
  simulator only**; `release.md` asks for a device check of both, of Siri, and of the control,
  whose link is tested but which was not added to Control Center.
- **Seen, not changed.** A `verb/` link leaves the search field's text in place behind the sheet,
  as before.

## Phase 10: Recents and My Verbs

**Ideas:** D1, D2 apart from its quiz scope. **Ports:** Konjugieren Phase 12 (`LearnerVerbs.swift`
in `Shared/`, `LearnerVerbStore.swift`, `SortOrder.swift`). **Depends on:** nothing. **Status:**
Done (2026-11-22).

- One on-device record of the learner's verbs: each verb opened, with dates and a count, and each
  verb starred. Keyed by `dictionaryKey`, so the doubled entries (haïr, ouïr, saillir, sortir)
  stay apart. Put it in the App Group's defaults (`WidgetConstants.sharedDefaults`) so the widget
  can read it, since Phase 12 needs that. Every field added later must be optional, so an older
  record still decodes; pin that with a test. iCloud sync stays out.
- **D1.** When the search field is focused and empty, show the last 20 or so verbs opened.
- **D2.** A star on the verb page, and a My Verbs list of starred verbs and recent lookups.
  Konjugieren made My Verbs a third segment of the verb list's sort picker (Alphabetical,
  Frequency, My Verbs), with Starred and Recent sections, Clear for the recents, and swipe to
  delete. Josh accepted that after trying it; offer the same here unless he says otherwise.
- An open is a verb page's arrival by any route, recorded where Phase 3 records arrival.

Konjugieren hit an iPad bug where a tap on a recent verb, with the search field focused and empty,
dropped the push because iPadOS was still dismissing the search (`ViewControllerTransitions`).
Test that case on the iPad.

**Carried over:** one record, in the App Group, extended later by the pedagogy plan; Clear and
swipe to delete; the star in the navigation bar; `tapStarVerb` carrying the state after the tap.

**Done when** opens and stars survive a relaunch, recents show in the empty focused field, My
Verbs lists both, and tests pin the record's coding and its migration from nothing.

**How it differed:**

Built 2026-11-22 in one session, as Konjugieren's design with Conjuguer's names. The suite ran 484
tests in 41 suites, all passing, 25 more than Phase 9's 459, all in the new `LearnerVerbsTests`.
New files: `Shared/LearnerVerbs.swift`, `Models/LearnerVerbStore.swift`, and
`Utils/ViewControllerTransitions.swift`; `VerbListMode` joined `VerbSort` in `Utils/VerbSort.swift`.
`docs/feature_architecture.md` § The Learner's Verbs describes it. No question needed Josh, and he
offered no change to Konjugieren's layout, so My Verbs is the third segment as there. What differs:

- **The record's field is `dictionaryKey`**, not Konjugieren's `infinitiv`, and its keys are
  `Verb.verbs` keys, so the two entries of haïr, ouïr, saillir, and sortir keep their own opens and
  stars (tested with haïr, and seen in the simulator as "haïr (Québec)" under Recent). **For Phase
  12 and the widget:** decode `WidgetConstants.sharedDefaults` at `LearnerVerbs.storageKey` with
  `LearnerVerbs(json:)`; a key names a verb entry, and its infinitive is the part before any space.
  Any field added later must be optional; `anEntryWithoutItsOptionalFieldsDecodes` pins it.
- **The store reaches the App Group** through a new `GetterSetterReal(userDefaults:)`, given
  `WidgetConstants.sharedDefaults`, falling back to the standard defaults if the group is missing.
  `World` gained `learnerVerbs`; the unit-test world gives it a `GetterSetterFake`.
- **The migration from nothing** is a store that starts empty with nothing stored, or with an
  unreadable record; both are tested. There was no earlier record to migrate.
- **An open** is recorded in `VerbView.beginVisit`, where `viewAppeared` goes out, whenever the
  source is not `resume`.
- **The picker.** `VerbListMode` (Frequency, Alphabetical, My Verbs, in Conjuguer's existing
  order). Only the sort order is persisted, as `Settings.verbSort` already was; My Verbs is not, so
  a relaunch returns to the list in its order, as Konjugieren's does. Search ignores the picker.
- **Konjugieren's iPad fixes were ported up front** rather than rediscovered: the recents and the
  accent row follow `searchIsEngaged`, which outlasts the field's focus by 0.7 seconds; a push
  from a recent verb waits for `ViewControllerTransitions.waitUntilIdle()`; an accent key tapped
  as the search ends waits, sets the letter, and refocuses. The accent row had followed the focus
  directly since Phase 2, so the same touch-down bug may have dropped an accent tapped on iPad with
  an empty field; it now works (`é` landed in the field in the simulator).
- **Recents and the keyboard.** The arrow keys and Return reach the recents, as in Konjugieren. A
  recent row is drawn with the source settled at draw time (`recent`), since the tap can end the
  focus before the action runs.
- **The star** sits before Share in the navigation bar (Test Me, in Phase 11, goes before it, as in
  Konjugieren). `tapStarVerb` carries `starred`, the state after the tap. Konjugieren's Clear and
  swipe to delete came with it, with the same alert for a starred verb.
- **French wording.** "Mes verbes", "Favoris" for Starred, "Récents", "Effacer", and "Ajouter à Mes
  verbes" / "Retirer de Mes verbes" for the star. Josh may prefer "Avec étoile" to "Favoris".
- **Analytics.** `recent` and `myVerbs` are now sent. The privacy lines are staged in
  `privacy_policy_pending.md`: the star in the in-app-actions bullet, "record" becoming "send" in
  the paragraph after the list, and a new paragraph saying the list stays on the device.
- **How it was tested.** On the iPhone, in English and light mode: My Verbs empty; aller, haïr
  (Québec), and être opened by link, être starred from its sheet; after a relaunch, être under
  Starred and haïr (Québec) and aller under Recent; a My Verbs row opening aller, which moved it to
  the top of Recent; a swipe deleting haïr; a swipe on être showing the alert, and Cancel keeping
  it; the empty focused field listing aller and être under Recent, and a recent row opening être.
  In French and dark mode: My Verbs (Favoris, Récents, Effacer, Mes verbes), and Effacer leaving
  only être. On the iPad, in English: the recents as a grid in the focused empty field, a real tap
  on a recent verb opening its page (the case that failed in Konjugieren), and `é` tapped into the
  empty focused field. AXe cannot see navigation-bar buttons on iOS 26, so the star was tapped by
  position and checked by screenshot. **Not tried:** VoiceOver, the Mac, a hardware keyboard's
  arrows through the recents, and the widget reading the record, which waits for Phase 12.

## Phase 11: A Quiz over Chosen Verbs

**Ideas:** D2's quiz scope, D3. **Ports:** Konjugieren Phase 13 (`QuizScope` in `Quiz.swift`,
`QuizSheet`). **Depends on:** Phase 10. **Status:** Done (2026-11-22).

- A minimal ability for the quiz to take a list of verbs and draw its questions from them.
  Conjuguer builds a quiz from fixed per-tense quotas over curated pools (`QuizVerbs`) at Regular,
  and from thirty fixed pairs at Ridiculous. A scoped quiz keeps Regular's tense mix and draws the
  verbs from the scope, skipping any cell the verb's defect group lacks.
- A My Verbs scope on the Quiz tab, with a picker above Start, a count of verbs, and Start
  disabled while the list is empty.
- **D3.** A "Test me on this verb" button on the verb page that asks three questions about the
  verb in view, in a sheet, so closing it returns to the page and leaves a quiz in the tab
  undisturbed. Three questions ask distinct cells, avoiding participles.
- `quizStart`, `quizQuit`, and `quizCompletion` gain `source` (`tab`, `myVerbs`, `verbPage`), so a
  three-question quiz cannot inflate the completion rate of the full quiz.

Keep the change small. The pedagogy plan reshapes the quiz (levels, ten questions, corrections);
this phase should give it something to build on, not compete with it.

**Carried over:** neither a scoped nor a three-question quiz posts to the leaderboard or shows its
button; Test Me starts no Live Activity and donates nothing to `ChangeDifficultyTip`; `QuizScope`
with constructors that later phases extend.

**Done when** Test Me asks three right questions about the verb in view, a My Verbs quiz draws
only from My Verbs, the default quiz is unchanged, and tests pin each scope.

**How it differed:**

Built 2026-11-22 in one session. The suite ran 498 tests in 42 suites, all passing, 14 more than
Phase 10's 484, all in the new `QuizScopeTests`. New files: `Models/QuizScope.swift` (`QuizScope`,
`QuizTenseSlot`, `Verb.hasCell(_:)` and `canBeQuizzed`) and `Utils/SeededRandomNumberGenerator.swift`.
`docs/feature_architecture.md` § Quiz Scopes describes it. No question needed Josh. What differs:

- **`QuizScope`** carries the verbs (nil for the default quiz), the question count, and the source,
  with `.allVerbs`, `.myVerbs(_:)`, and `.verbPage(_:)`. It has no reading index, which German needed
  for its two-reading verbs. A doubled French infinitive is two `Verb`s already. `isRanked` is
  `verbs == nil`. **For Phase 14:** add a constructor (source `list`); `questions(using:)` handles
  any list of verbs.
- **Regular's mix became `QuizTenseSlot`**, an enum of the eight tenses with their quotas. The
  default quiz's `buildQuiz` was left as it was, and a test pins that it asks exactly the slots'
  quotas. **For the pedagogy plan:** that is the seam where levels would swap the mix.
- **Defective verbs, which German lacks.** Each question asks a cell the verb's defect group allows.
  A tense no scoped verb has is dropped (a My Verbs quiz of falloir alone asks 27). Test Me's three
  questions are three different tenses, weighted by Regular's quotas and without the participe
  présent. A verb with fewer tenses gets more cells of those it has, then its participles. The six
  verbs used only in the infinitif (`dg="0"`) show no Test Me button.
- **A scoped quiz is scored and labeled Regular**, whatever the setting, since Ridiculous is a fixed
  list and a scoped quiz asks Regular's mix. The briefing card says Regular while My Verbs is chosen.
- **Unranked means more here than in Konjugieren.** Beyond Game Center, a scoped quiz sets no best
  score, donates nothing to `ChangeDifficultyTip`, and does not open the leaderboard when its results
  close, which Conjuguer's tab does after every quiz. A My Verbs quiz does start a Live Activity, as
  a full thirty questions.
- **No `tapTestVerb`.** Konjugieren sends one, and `feature_architecture.md` expected it. Here the
  sheet starts its quiz as it appears, so `quizStart` with `verbPage` is the same event, and one
  fewer privacy line is staged. `difficulty` on the three signals is now the quiz's own, fixed at
  its start; quit and completion used to read the setting at that moment.
- **A bug found and fixed:** the quiz graded answers without the verb's extra letters, so sortir
  (obtain), a finir-like entry, would have been graded as sortir (exit). The curated pools hold no
  doubled entry; a scoped quiz can. `aDoubledEntryIsGradedAsItself` pins it.
- **The start screen.** The picker went into the existing briefing card above Start, with a count
  line, and the best score shows only for All Verbs. Konjugieren's filled start screen (big yellow
  symbols, tiles, chips), which Josh asked for there after trying it, was not ported, since
  Conjuguer's card already fills the screen with a symbol and facts. **Josh should judge** whether
  he wants it here, and whether the unlabeled clipboard symbol is discoverable enough.
- **Analytics.** `source` on `quizStart`, `quizQuit`, and `quizCompletion` (`tab`, `myVerbs`,
  `verbPage`). The privacy line is staged as a change to the existing quiz lifecycle bullet.
- **How it was tested.** On the iPhone, in English and light mode: Test Me on venir's page (a
  deeplinked sheet) asked conditionnel présent, présent, and passé composé, and the results showed
  2 of 3 and 20 points; Done and Quit each closed the sheet onto the page. The Quiz tab counted two
  verbs in My Verbs (être, venir), and the first eight questions of a My Verbs quiz were all about
  them. In French and dark mode: the card ("Tous les verbes", "Mes verbes", "Questions sur 2 verbes
  de Mes verbes", "Commencer"). On the iPad, in English: Test Me as a form sheet on a pushed venir
  page, a tap outside it leaving it up mid-quiz, Quit closing it, and, after Clear emptied My Verbs,
  the note telling how to add verbs over a disabled Start. **Not tried:** VoiceOver, the Mac, Game
  Center signed in, a Live Activity on a device, and a completed My Verbs quiz in the simulator
  (the unit tests complete one).

## Phase 12: A Verb of the Day Worth Opening

**Ideas:** D5. **Ports:** Konjugieren Phase 14 (`VerbDraw.swift`, `FrequencyBand.swift`,
`WidgetSnapshotWriter.displayedSnapshot`). **Depends on:** Phase 10. **Status:** Done
(2026-11-22).

Conjuguer's widget already draws from frequent verbs, so this phase is smaller than Konjugieren's.

- Define frequency bands once on `Verb` (`FrequencyBand`: top 100, 300, 1,000), as the pedagogy
  plan's levels will read them. Before relying on the ranks, list the verbs whose counts are zero
  or estimates (`hp`) and check that no common verb sits outside the bands by accident of its
  counts (manœuvrer, écœurer). Fix the data if Josh agrees; `frequency/README.md` says how.
- Draw the widget's verb from the frequent band, favoring irregular and base verbs (the analogue of
  Konjugieren's "strong and base"), and from My Verbs once it has entries. Draw every random verb
  (the control, `verb/random`, the shortcut) from the same band instead of all 6,330 entries.
- The widget's choice stays stable through the day. Konjugieren found that the app rewrites the
  bundle at each activation and My Verbs changes in between, so the writer must keep the verb the
  widget already shows today.

**Carried over:** My Verbs supplies one draw in three, every third day for the widget (chance left
gaps of nineteen days in Konjugieren's simulation) and by chance for a random verb; a weight that
favors irregular and unprefixed verbs; the quiz widget's sampling left to the pedagogy plan.

**Ask Josh:** the band for the widget (Konjugieren used 1,000; Conjuguer uses 1,500 with an
example today), and whether "irregular" means a model with irregularity above 0%.

**Done when** ten days of the bundle match an independent reimplementation of the draw, a relaunch
keeps today's verb, and tests pin the bands and the draw.

**How it differed:**

Built 2026-11-22 in one session. The suite ran 518 tests in 44 suites, all passing, 20 more than
Phase 11's 498, in the new `FrequencyBandTests` and `VerbDrawTests` and a reworked
`WidgetSnapshotWriterTests`. New files: `Models/FrequencyBand.swift` and `Models/VerbDraw.swift`.
`docs/feature_architecture.md` § Choosing the Verb describes the draw.

- **Josh's answers (2026-11-22).** The band is the top 1,000, as in Konjugieren, not the widget's
  old 1,500. "Irregular" means the third group as schools teach it: models outside groups 1 and 2,
  plus aller (about 178 of the top 1,000), not irregularity above 0%, which would also have
  favored the spelling changes of manger and appeler (about 315). He agreed to both data fixes
  below.
- **The data check found two defects, both fixed in `frequency/build_counts.py`.** GLÀFF counts a
  verb spelled with œ only where the corpus kept the ligature, so manœuvrer and écœurer carried
  zeros (#6,290 and #6,271) and œuvrer 18 hits (#5,605). Lexique 4 lists them as manoeuvrer,
  écoeurer, and oeuvrer, which the script never looked up. Now an œ verb is looked up under `oe`,
  and its GLÀFF counts are quarantined, so it takes the Lexique 4 estimate: #1,858 to #1,876.
  œilletonner is in neither source and keeps its zeros. Second, convaincre, quarantined since
  2026-08-28 as a failed join, had its estimate clamped to rank 1,000's count and lost the tie on
  its defective Le Monde zero, which left it at #1001, one place outside the band. Quarantined
  rows are now exempt from the clamp, and convaincre ranks #490 (#271 in the subtitles).
  `docs/frequencies.txt` and `frequency/README.md` were regenerated and updated; 114 verbs now
  share a count of zero, not 116.
- **Not fixed, for Josh to judge:** lover ranks #835 on 19,144 FrWaC hits, which probably include
  the English word, and it came up as a random verb in the simulator. The subtitle-heavy verbs
  that rank just outside the band (attraper #1030, calmer #1045, virer #1046, baiser #1863) are
  honest register differences, not defects.
- **The weight** is Konjugieren's: 2 for an irregular verb, times 2 for a base verb, so aller,
  venir, and faire count 4, apprendre and parler 2, rappeler 1. A base verb is one
  `VerbBase.base(of:)` (Phase 7) finds no base for. That reads the etymology in the device's
  language, so the draw could in principle differ between a French and an English device. On
  2026-11-22 the two languages agreed on all 1,000 verbs (239 have a base), so it does not today.
- **The band is 1,001 entries**, since sortir's two entries share a rank. `Verb.verbs(in:)`
  returns entries; `FrequencyBandTests` pins that each band holds exactly its count of infinitives.
- **Keeping today's verb** is simpler than in Konjugieren, whose bundle pages with a Next button.
  Conjuguer's bundle is seven dated snapshots, so `writeSnapshots(now:)` reads the bundle on disk,
  takes the verb of today's snapshot (`displayedVerb(in:on:)`, by `verbKey`), and keeps it for
  today. The quiz widget's answered state, keyed by date and infinitive, survives with it.
- **No new signal.** `viewAppeared` for the verb page with `source` `widget` or `control` already
  counts these opens, so nothing is staged for the privacy policy and no string was added.
- **How it was tested.** `VerbDrawTests` pins ten days from 2026-11-22 to a Python
  reimplementation (in the session's scratchpad: SplitMix64, the model groups, and `VerbBase`'s
  rule read from `RelatedVerbs.swift`). In the iPhone simulator, in English: the old build's
  bundle showed baisser today; the new build kept baisser and wrote boire, distribuer, être,
  prévoir, vendre, and venir for the next six days, matching Python with My Verbs [venir, être]
  (seven days, the bundle's length). With the bundle deleted, today became venir, a My Verbs day,
  and a relaunch kept all seven. Unstarring venir reordered My Verbs to [être, venir], for which a
  fresh draw gives être today; after a trip to Settings and back, today stayed venir while
  11-25 and 11-28 moved to venir and être. Fourteen `verb/random?source=control` links opened
  connaître, commencer, lover, rire, appartenir, reprocher, reproduire (all ranked 26 to 835), and
  être from My Verbs. **Found, not fixed:** a link that arrives while a verb sheet is up is
  sometimes dropped or arrives late, for a fixed verb as well as `random`, so it predates this
  phase. **Not tried:** the iPad, French, and dark mode, since nothing in the app's interface
  changed; the widget's rendering on a Home Screen; and a device.

## Phase 13: The Review Card

**Ideas:** D4. **Ports:** Konjugieren Phase 15 (`ReviewSchedule.swift` in `Shared/`,
`ReviewCardView.swift`, `ReviewCardSuppression.swift`). **Depends on:** Phases 8 and 10.
**Status:** Done (2026-11-22).

When the app opens, one card above the verb list offers a verb looked up some days earlier, with
its key conjugations hidden until tapped. One tap reveals them, a second opens the page, and one
dismisses the card. Store a box and a due date per verb as an optional field of the learner's
record, on the ladder of 1, 3, 7, 14, and 30 days, so the pedagogy plan's practice record can take
it over.

**Carried over:** dismissing before revealing is no review, and the verb returns the next day; a
later lookup by any other route sends a verb back to the first box; a card may appear at each
launch and each return from the background; due dates fall at the start of a day; a Suppress
Review Card setting, off by default; `viewReviewCard` and `tapRevealReviewCard`, with no
parameters; the card hides while a search, the recents, or My Verbs shows.

**Done when** a seeded record offers the longest-overdue verb, reveal and dismissal move it as
decided, the setting hides it, and tests pin the schedule.

**How it differed:**

Built 2026-11-22 in one session, as Konjugieren's Phase 15 with Conjuguer's names. The suite ran
536 tests in 45 suites, all passing, 18 more than Phase 12's 518: 17 in the new
`ReviewScheduleTests` and one in `SettingsTests`. New files: `Shared/ReviewSchedule.swift`,
`Models/ReviewCardSuppression.swift`, and `Views/ReviewCardView.swift`. `docs/feature_architecture.md`
§ The Review Card describes it. No question needed Josh. What differs:

- **Ported from Konjugieren's commit 65d5eb6, not its current code.** Konjugieren's pedagogy
  Phase 11 later moved the schedule out of `LearnerVerbs` into a `PracticeRecord` and added
  `answered` and `new` to `ReviewSchedule`. This phase builds the browse version, `review` on
  `LearnerVerbs.Entry`, as the plan asks; the pedagogy plan should read Konjugieren's current
  `Shared/ReviewSchedule.swift` before extending it.
- **Keys are `Verb.dictionaryKey`s**, so haïr's two entries keep their own schedules (tested).
- **A verb with no key conjugations is passed over.** accroire and the five other verbs used only
  in the infinitif would show an empty card, so `LearnerVerbStore.verbDueForReview` takes the first
  due verb that has some. German has no such verbs.
- **An open from the card** keeps the schedule through `recordOpen(_:source:)`, which
  `VerbView.beginVisit` now calls with its source.
- **The card** follows Konjugieren's: "Looked up 3 days ago" ("yesterday" for one, "earlier" if the
  open has no date), the infinitive as the list shows it, the gloss, and the key conjugations under
  a redacted placeholder. It sits above the list, below the try-quiz tip, not inside the scroll, and
  hides while a search, the recents, or My Verbs shows. On iPad it stops at 560 points. A
  pronominal verb shows "souvenir" over "se souvient · s'est souvenu · se souviendra", as its list
  row does; **Josh may prefer** the citation form, "se souvenir", which the share text uses.
- **Strings.** The day count uses separate keys for yesterday and for several days, by the
  catalog's convention, not a plural variation. French: "Consulté hier", "Consulté il y a 3 jours",
  "Rappelez-vous ses conjugaisons, puis touchez pour vérifier.", and in Settings "Masquer la carte
  de révision" with Non and Oui for Off and On.
- **The setting** is a card of its own in Settings, after Pronoun Genders, since Conjuguer has no
  Search Scope card to share. It sends no signal.
- **Analytics.** `viewReviewCard` and `tapRevealReviewCard`, no parameters; `reviewCard` is now
  sent as a source. The privacy lines are staged, replacing Phase 10's in-app-actions bullet and
  its paragraph about the list on the device.
- **How it was tested.** On the iPhone, in English and light mode, with the App Group's plist
  seeded: venir (an old entry with no `review`, opened 4 days earlier), faire (box 1, overdue), and
  accroire (opened 20 days earlier). The card offered venir ("Looked up 4 days ago"), skipping
  accroire; a reveal showed "vient · est venu · viendra" in red and blue and wrote box 1, due at the
  start of 11-25; a tap opened venir's page, counted the open, and left the schedule. A trip to the
  Home Screen and back offered faire ("10 days ago"). Suppress Review Card On hid it at once and a
  relaunch showed none; Off brought it back; ✕ before revealing kept faire in box 1, due at the
  start of 11-23, and a relaunch showed no card. In French: souvenir, "Consulté hier", its
  reflexive key conjugations wrapping to two lines. On the iPad, in English: prendre's card at 560
  points beside the grid, revealed and opened. **Not seen:** dark mode, since the iPhone simulator
  ignored `simctl ui appearance dark` this session (its status bar also stayed frozen at 7:14);
  VoiceOver; a device. **For seeding:** write the container's plist with `plutil`, with the app
  terminated, and reboot the simulator if the app still reads the old record, since its
  preferences daemon caches the domain. `simctl spawn defaults write` writes a different file.

## Phase 14: Collections

**Ideas:** D6. **Ports:** Konjugieren Phase 16 (`VerbCollection.swift`, `VerbCollectionView.swift`).
**Depends on:** Phases 9 (the grammar), 10, and 11. **Status:** Done (2026-11-22).

Fixed lists as places to go, which the ideas document rated strongest for Conjuguer because of
schools. A list shows how many of its verbs have been opened ("3 of 100 looked up"), can be shared
as a `conjuguer://list/<key>` link with the App Store link, and can start an unranked quiz on
itself.

Candidates, by analogy with Konjugieren's top 100, modal verbs, verbs taking sein, and ablaut
groups: the 100 most frequent verbs; the verbs that take être without being pronominal (aller,
venir, naître, and their kin); verbs with an irregular futur stem; the pronominal-only verbs; and
**each model as a collection**, the counterpart of Konjugieren's ablaut groups. Konjugieren put
collections at the top of its Families tab and gave every ablaut group a bar ("3 of 70 looked
up", a progress bar, Quiz, and Share) inside its page. The Models tab is the natural home here, and
each model's page could carry the same bar.

**Ask Josh** before building: which collections, where they live, and how they relate to the
Models tab. Propose with a mockup or screenshot, as Konjugieren did.

**Done when** each collection opens from the tab and from its link, counts progress, starts its
quiz, and shares, and tests pin membership and the link.

**How it differed:**

Built 2026-11-22 in one session. The suite ran 553 tests in 46 suites, all passing, 17 more than
Phase 13's 536, all in the new `VerbCollectionTests`. New files: `Models/VerbCollection.swift`
(`VerbCollection`, `VerbCollectionDestination`, `QuizScope.collection(_:)`) and
`Views/VerbCollectionView.swift` (the page, `VerbCollectionBar`, and `VerbCollectionRow`).
`docs/feature_architecture.md` § Collections describes it.

- **Josh's answers (2026-11-22),** each the recommended option, to a proposal with ASCII mockups
  made before building: all four collections (the top 100, verbs taking être, irregular futur
  stems, pronominal verbs); a Collections section at the top of the Models tab, with collections
  hidden while the search field has text; all 99 models as collections, with the bar in each
  model page's verbs card, shared by the existing `model/<id>` link rather than a second
  `list/model-<id>`; and a collection page's verbs as rows with the gloss and a check, not a run
  of links.
- **The counts.** Top 100: 100 entries. sortir's two entries share rank 78, so the band holds 101,
  and the page showed "3/101" under a title promising a hundred; the collection keeps the first,
  sortir "exit". Être: 38. Irregular futur: 91, where a Python estimate from `conjugations.json`
  said 104. The Swift count is the right one: the extra 13 were hyphenated verbs whose hyphen the
  script stripped (entre-nuire, sous-entendre) and verbs whose defect group has no futur (quérir,
  ravoir, issir, choir). Pronominal: 217. Its members are what `verbs.xml` marks reflexive, which
  includes coucher and habiller, so the description says "verbs that Conjuguer conjugates with a
  reflexive pronoun" rather than claiming they are only pronominal.
- **"Irregular futur stem"** is a verb of the third group (`VerbDraw.isIrregular`, Phase 12's
  definition) or of envoyer's model whose radical du futur, lowercased, is not the infinitive less
  a final e. That leaves out the first group's spelling changes (appellerai, lèverai) and prévoir
  and pourvoir, whose futur is regular.
- **The quiz** runs in `QuizSheet`, which moved out of `VerbView` (it was `VerbQuizSheet`) into
  `QuizView.swift`, and shows the collection's title where the sheet said "Quiz". **Unlike
  Konjugieren, a collection's quiz starts no Live Activity**: the activity's tap opens the Quiz tab,
  not the sheet over the collection, so it would lead away from the quiz it tracks. Konjugieren's
  starts one; Josh may want that changed there too.
- **Analytics.** `viewCollection` (`collection`, `source`) for the four featured pages only;
  `tapShareCollection` (`collection`); `collection` on `quizStart`. **Every model sends
  `collection` `model`, never its identifier**, because a model of one verb (aller's 1-9) would
  name the verb, which the policy promises is not sent. Konjugieren sends `ablaut-<exemplar>`,
  which has the same exposure for its 18 single-verb groups; worth a look in its Closing. A
  model's page keeps its `viewAppeared` and sends no `viewCollection`. New sources: `sharedLink`;
  `tab` for a collection opened in the Models tab (Konjugieren's `family`); `list` for a verb opened
  from a featured page. The privacy lines are staged.
- **The `model/` route reads no `source`.** A shared model link carries `source=sharedLink`, so a
  later phase could count it, but nothing does today.
- **iPad.** The four cards first sat in the models' three-column grid, where titles wrapped to
  three lines and cards ran to uneven heights. They are now a 2×2 `Grid` of equal cards. On a
  collection's page the verb cards keep the verb list's grid, uneven heights included.
- **Small things.** `ShareSheet.present` gained `anchorRect`, as in Konjugieren. `BrowseRow`
  gained `isChecked`. `URL.modelDeeplink` takes an identifier and an optional `source`, and
  `URL.listDeeplink` joined the builders.
- **How it was tested.** On the iPhone, in English and light mode: the Models tab's Collections
  section; the top 100's page (être and faire checked); avoir opened from it, and "3 of 100" rising
  to "4 of 100" on return; the quiz sheet titled "100 Most Frequent Verbs" with "1 / 30", and Quit;
  the share sheet beside its button and its copied text; `model/6-7?source=sharedLink` opening
  venir's model with "2 of 29 looked up", Quiz, and Share. In French: `list/etre?source=sharedLink`
  opening "Verbes conjugués avec être" in a sheet ("Consultés : 1 sur 38"), aller pushed inside it
  with Terminé, and the Models tab then showing 5/100 and 2/38. On the iPad, in English: the 2×2
  cards, the Pronominal Verbs page as a grid, the share popover anchored to its button, and the
  copied text citing "se souvenir" and "s'efforcer". **Not seen:** dark mode, since the iPhone
  simulator again ignored `simctl ui appearance dark` (as in Phase 13); VoiceOver; a completed
  collection quiz in the simulator (the unit tests start and quit one); a device.

## Not Carried Over

- **Konjugieren Phase 4, separable verbs as a main clause writes them.** French has no separable
  verbs. The nearest relative, the reflexive pronoun, is already shown on the page.
- **Konjugieren Phase 8, a Futur II article.** Conjuguer already has an Info article for each of
  its twenty tenses.
- **Konjugieren's Search Scope setting and its migration.** Josh chose no setting for Conjuguer on
  2026-11-22, so gloss search is always on and there is nothing to migrate.

## Closing

**Status:** Awaiting Josh (2026-11-22).

- Run the full suite and `check_docs.py`.
- Audit the privacy staging: diff `Analytics.swift` against the commit before Phase 1, read every
  call site, and confirm that each new signal, parameter, and value has its lines in
  `docs/privacy_policy_pending.md` in English and French, and that none carries a verb or typed
  text.
- Confirm that `docs/feature_architecture.md` describes search, the signals, the deeplink grammar,
  the learner's record, and collections as built.
- Write, in [`pedagogy_implementation.md`](pedagogy_implementation.md)'s "What the Browse Plan
  Left" section, the names the pedagogy phases will meet, correcting the expected names written
  there now.
- Write a short note for Konjugieren and Conjugar: anything this port found that the other apps
  should change (a design flaw, a better solution). Put it in this section, not in their
  repositories.
- Mark this plan finished in its Status section.

**How it differed:**

Done 2026-11-22 in one session, which Josh asked for as "Phase 15": the plan has no Phase 15, and
the Closing was the only unfinished work. No app code changed.

- **The checks.** 553 tests in 46 suites passed, the count Phase 14 left, and `check_docs.py`
  found 0 problems after the Closing's edits.
- **The privacy audit.** `Analytics.swift` was diffed against `3ed3be8`, the commit before Phase 1,
  and every `signal` call site read. Nine signals (`finishSearch`, `leaveVerbView`,
  `tapTenseArticle`, `tapShareVerb`, `tapStarVerb`, `viewReviewCard`, `tapRevealReviewCard`,
  `viewCollection`, `tapShareCollection`) and ten parameter keys (`source`, `outcome`,
  `queryLength`, `resultCount`, `matchKind`, `resultPosition`, `deepestSection`, `dwell`,
  `starred`, `collection`) all have staged lines in both languages. Every value is an enum case or
  a band: `SearchReport` keeps the query's length, not the query; a link's `source` passes through
  `AnalyticsSource(rawValue:)`, so a crafted link can send only a value of the vocabulary; and
  `collection` says `model` for every model. **One gap, now staged:** two screens the plan added,
  `RelatedVerbListView` and `VerbCollectionView`, report themselves through the existing
  `viewAppeared`, and the policy's bullet on screens did not name them. A new section of
  `docs/privacy_policy_pending.md` adds "lists of related verbs" and "collections of verbs" to it.
  No signal carries a verb or typed text.
- **`feature_architecture.md`** describes search, the signals, the deeplink grammar, the learner's
  record, and collections as built. One row was narrower than the code: the source table said
  `deeplink` meant a `verb/` link with no `source`, while a `search` link and a `list/` link fall
  back to it too. The row now says so.
- **The pedagogy handoff.** "What the Browse Plan Leaves for This One" in
  `pedagogy_implementation.md` now gives the names as built, checked against the code. Its
  corrections: the accent row is `FrenchLetterKeyRow`, and only the two search fields show it;
  grading's lenient comparison already exists (`ConjugationResult.score`); key conjugations are
  always masculine and can be empty; `QuizSheet` lives in `QuizView.swift`; and the count of thirty
  gates less than the old list said, since ranking and the tip follow `isRanked` and the time
  bonus follows the score.

### For Konjugieren and Conjugar

What this port found that the other apps should look at. Konjugieren's points were checked against
its code on 2026-11-22; Conjugar's code was not read, so its column of each point is **inference**.

1. **Konjugieren's `collection` value names a verb.** Its `VerbCollection.key` for an ablaut group
   is `ablaut-<exemplar>`, and it sends that key on `viewCollection`, `tapShareCollection`, and
   `quizStart`. The exemplar is an infinitive, and a group of one verb names exactly the verb looked
   up, which its policy says is not sent. Conjuguer sends `model` for every model. Konjugieren could
   send `ablaut` alone, or the group's number, and restage its line. Conjugar, if it makes its
   models collections, should follow Conjuguer.
2. **A collection's quiz and the Live Activity.** Konjugieren's collection quiz starts a Live
   Activity whose tap opens the Quiz tab, away from the sheet that runs the quiz. Conjuguer starts
   none (`QuizScope.startsLiveActivity`). Josh may want the same in Konjugieren and Conjugar.
3. **Konjugieren's search tiers may misrank folded queries.** It ranks a literal infinitive
   substring above a folded prefix, and a prefix strictly above a whole-word gloss. In French that
   put gonfler ahead of aller for "go", and relever ahead of élever for "eleve". Conjuguer puts the
   prefix, the folded prefix, and a whole English meaning in one tier ranked by frequency, and ranks
   a conjugation in that tier too, since rare verbs' conjugations are often the first letters of
   common verbs (réer ahead of réaliser for "réa"). Worth testing in Konjugieren with umlauts left
   out, and worth adopting in Conjugar, whose gloss search and many short Spanish conjugations
   invite the same misranking.
4. **Spotlight's indexing cost.** Konjugieren reindexes every launch. With Conjuguer's 6,330
   entries the key conjugations took seconds of the main actor, so it indexes only when the version,
   build, or an entries `format` constant changes. Conjugar's 4,811 verbs are likely to need the
   same.
5. **An intent before any window.** Conjuguer parses its verbs in the window's `.task`, so an App
   Intent run in the background found no verbs until `VerbData.ensureLoaded()`. Conjugar should
   check where it parses before porting Look Up a Verb.
6. **A scoped quiz is unranked in more ways than Game Center.** Conjuguer's scoped quiz sets no best
   score, donates no tip, and does not open the leaderboard, which Conjuguer's tab does after every
   quiz. Konjugieren's current code already keeps a scoped quiz's score out of its bests. Conjugar
   should check all three when it adds scopes.
7. **Doubled infinitives.** A quiz over chosen verbs graded sortir (obtain) as sortir (exit),
   because grading ignored the extra letters; fixed here and pinned. German has no doubled entries,
   but Conjugar should check whether any of its entries share an infinitive.
8. **Small things.** Conjuguer's verb share button has an identifier (`verb_share_button`), which
   Konjugieren's lacks. Konjugieren's article sheet closes to open a linked verb in the Verbs tab;
   Conjuguer's pushes it inside the sheet, because a verb page here may itself be a sheet. Neither is
   a defect.

The plan is finished, apart from the two git steps.
