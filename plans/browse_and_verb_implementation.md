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
| 1 | Not started | | | A1, A2, A3, A8 | 1 |
| 2 | Not started | | | A4, C4 | 2 |
| 3 | Not started | | | Signals | 3 |
| 4 | Not started | | | A5 (the map) | 5 |
| 5 | Not started | | | A5 (the search) | 6 |
| 6 | Not started | | | B3, B5's tip | 7 |
| 7 | Not started | | | B4, A9 | 9 |
| 8 | Not started | | | B6 | 10 |
| 9 | Not started | | | C1, C2 | 11 |
| 10 | Not started | | | D1, D2 | 12 |
| 11 | Not started | | | D2's quiz scope, D3 | 13 |
| 12 | Not started | | | D5 | 14 |
| 13 | Not started | | | D4 | 15 |
| 14 | Not started | | | D6 | 16 |
| Closing | Not started | | | Audit, porting notes | Closing |

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
on:** nothing. **Status:** Not started.

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

## Phase 2: When Search Finds Nothing, and Keyboard Lookup

**Ideas:** A4, C4. **Ports:** Konjugieren Phase 2 (`VerbSearch.closestVerb`,
`VerbSearchCommands.swift`, `VerbSearchArrowKeys.swift`, `URL.mailto`). **Depends on:** Phase 1.
**Status:** Not started.

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

## Phase 3: Lookup Signals

**Ideas:** the three signals in the ideas document's "What to Measure". **Ports:** Konjugieren
Phase 3 (`SearchReport.swift`, `VerbVisit.swift`, `Analytics.swift`). **Depends on:** Phase 1, so
the match kinds exist. **Status:** Not started.

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

## Phase 4: The Conjugation Map as a Build Product

**Ideas:** A5, first half. **Ports:** Konjugieren Phase 5 (`ConjugationMapTool/`,
`ToolWorld.swift`, `ConjugationMap.swift`, `ConjugationMatch.swift`). **Depends on:** nothing.
Josh confirmed on 2026-11-22 that reverse lookup is built. **Status:** Not started.

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

## Phase 5: Reverse Lookup in Search

**Ideas:** A5, second half. **Ports:** Konjugieren Phase 6 (`ConjugationIndex.swift`,
`VerbSearchResults.swift`, `MarkedConjugations` in `VerbView.swift`). **Depends on:** Phases 1
and 4. **Status:** Not started.

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

## Phase 6: The Verb Page's Sections

**Ideas:** B3 as Josh amended it, and the tip from B5's verdict. **Ports:** Konjugieren Phase 7
(`ConjugationTable.swift`, `scripts/count_conjugationgroups.py`,
`docs/conjugationgroup_frequency.md`, `KonjugierenTips.swift`). **Depends on:** nothing; Phase 5
for the landing order. **Status:** Not started.

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

## Phase 7: Ways Between Verbs

**Ideas:** B4, A9. **Ports:** Konjugieren Phase 9 (`RelatedVerbs.swift`,
`RelatedVerbsView.swift`). **Depends on:** nothing; Phase 3's `related` source applies if done.
**Status:** Not started.

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

## Phase 8: Copy and Share

**Ideas:** B6. **Ports:** Konjugieren Phase 10 (`KeyConjugations.swift`, `ShareSheet.swift`).
**Depends on:** nothing. **Status:** Not started.

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

## Phase 9: Lookup from Outside the App

**Ideas:** C1, C2. **Ports:** Konjugieren Phase 11 (`LookUpVerbIntent.swift`,
`KonjugierenShortcuts.swift`, `VerbEntity.swift`, `VerbSpotlight.swift`, `VerbLookup.swift`,
`FindVerbControl.swift`, `QuickActions.swift`, `OpenVerbSearchIntent.swift`). **Depends on:**
Phase 5 for conjugation answers, Phase 8 for key conjugations. **Status:** Not started. Likely to
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

## Phase 10: Recents and My Verbs

**Ideas:** D1, D2 apart from its quiz scope. **Ports:** Konjugieren Phase 12 (`LearnerVerbs.swift`
in `Shared/`, `LearnerVerbStore.swift`, `SortOrder.swift`). **Depends on:** nothing. **Status:** Not
started.

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

## Phase 11: A Quiz over Chosen Verbs

**Ideas:** D2's quiz scope, D3. **Ports:** Konjugieren Phase 13 (`QuizScope` in `Quiz.swift`,
`QuizSheet`). **Depends on:** Phase 10. **Status:** Not started.

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

## Phase 12: A Verb of the Day Worth Opening

**Ideas:** D5. **Ports:** Konjugieren Phase 14 (`VerbDraw.swift`, `FrequencyBand.swift`,
`WidgetSnapshotWriter.displayedSnapshot`). **Depends on:** Phase 10. **Status:** Not started.

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

## Phase 13: The Review Card

**Ideas:** D4. **Ports:** Konjugieren Phase 15 (`ReviewSchedule.swift` in `Shared/`,
`ReviewCardView.swift`, `ReviewCardSuppression.swift`). **Depends on:** Phases 8 and 10.
**Status:** Not started.

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

## Phase 14: Collections

**Ideas:** D6. **Ports:** Konjugieren Phase 16 (`VerbCollection.swift`, `VerbCollectionView.swift`).
**Depends on:** Phases 9 (the grammar), 10, and 11. **Status:** Not started.

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

## Not Carried Over

- **Konjugieren Phase 4, separable verbs as a main clause writes them.** French has no separable
  verbs. The nearest relative, the reflexive pronoun, is already shown on the page.
- **Konjugieren Phase 8, a Futur II article.** Conjuguer already has an Info article for each of
  its twenty tenses.
- **Konjugieren's Search Scope setting and its migration.** Josh chose no setting for Conjuguer on
  2026-11-22, so gloss search is always on and there is nothing to migrate.

## Closing

**Status:** Not started.

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
