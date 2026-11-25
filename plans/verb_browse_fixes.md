# Plan: Fix What the Browse and Verb-Page Review Found

**For:** a series of fresh Claude Code sessions, one phase per session as a rule. **Kind of work:**
app code, the widget and shared intents, one build-time tool, one script, tests, and prose.
**Written:** 2026-11-25, from [`docs/verb_browse_review.md`](../docs/verb_browse_review.md) and
Josh's answers to thirteen questions the same day. Konjugieren's plan for its own review,
[`../Konjugieren/plans/verb_browse_fixes.md`](../../Konjugieren/plans/verb_browse_fixes.md), is the
model for this one's shape, and several of its decisions carry over.

The review is the specification. Each phase below names findings by the review's own labels (B1,
S3, D2, and so on). Read the finding there before touching code: it gives the file, the line, the
evidence, how sure it is, and a suggested fix. This plan adds only the order, the grouping, Josh's
decisions, and what counts as done. The review's line numbers are those of `88dbb96` and will
drift as phases land, so find code by name.

Five findings came from Konjugieren's review and have no label of their own here. They are named
below as they are in the review's section "Konjugieren's Findings, Checked Here": the guess on the
main thread (its F1), the Related Verbs card's missing page section (G6), the idle sort picker
(S8), the tool's unguarded inputs (S9), and the shared build directory (S10). To keep them apart
from this review's labels, this plan writes them **K-F1**, **K-G6**, **K-S8**, **K-S9**, and
**K-S10**.

## Status

Each session that finishes a phase fills in its row, then writes a **How it differed** note under
that phase's heading. A finished phase that waits for Josh is "Awaiting Josh", with the Commit cell
empty until it is committed.

| Phase | Status | Date | Commit | Findings | Waits for Josh |
|---:|---|---|---|---|---|
| 1 | Done | 2026-11-25 | `5543a98` | B4, S1 (the parser) | No |
| 2 | Awaiting Josh | 2026-11-25 | | B1, B2, B8, B28, S1 (the sheets) | Yes |
| 3 | Not started | | | Multiple windows | Yes |
| 4 | Not started | | | S2 | No |
| 5 | Not started | | | B3, B6, B18, B23, B24, B26, S3 (the search model), D5, T1 (the search), K-F1, K-S8 | Yes |
| 6 | Not started | | | B9, S3 (the rest), D4, D7, T1 (the card), the stale review card | Yes |
| 7 | Not started | | | B7, B13, B14, B15, B21, B22, B25 (the row), B30, G1, G2, G3, S10 | Yes |
| 8 | Not started | | | B16, B19, S12, the progress decision, the migration, T2 | Yes |
| 9 | Not started | | | B12, B27, B29, S4, S4a, S5, S6, D8, D9, T1 (the visit), K-G6 | Yes |
| 10 | Not started | | | B17, B25 (the labels), S8, S13, S14, D1, D2, D3, D6, T6 | Yes |
| 11 | Not started | | | B5, S7, the rare-verb draw | Yes |
| 12 | Not started | | | B10, B11, B20, S11, K-S9, K-S10 | No |
| 13 | Not started | | | S9, T3, T4, T5, what the others left | No |
| Closing | Not started | | | The audit, the workarounds list, the note for the other apps | No |

## How to Work This Plan

**Choosing a phase.** Take the lowest-numbered phase that is not done and whose dependencies are.
Phases 1 to 6 are a chain: each edits what the one before it leaves. Phases 9 and 10 depend on
Phase 4, because all three edit the verb page and the list pages. Phases 7, 8, 11, and 12 stand
alone and may be taken at any time. Phase 13 is shortest when taken last. If a phase proves too
large for one session, split it, say so in its row, and leave the remainder "Partly done".

**What this plan leaves to you.** The phases say what to fix and what Josh decided. The review
suggests a fix for each finding, and a better one is welcome. Record in **How it differed**
anything that departs from the phase as written, and read the notes of the phases yours depends
on before starting.

**A finding the review marks Suspected is not yet a fact** (B9, B10, B11, and the suspicions
inside S4 and B29). Josh's answer on 2026-11-25: confirm each before fixing it. If it turns out
not to be real, say so in **How it differed** and under the finding in the review, and move on.
Findings marked Traced that a phase can cheaply reproduce are worth reproducing too, since a test
that fails without the fix is the reproduction.

**Ask Josh when a decision here does not settle a question.** Do not guess. Record the answer and
its date in **How it differed**.

**Every phase finishes the same way.**

1. Each fix gets a test that fails without it, following `.claude/rules/swift_testing.md`. The
   review's Tests and Docs section names the missing ones; a test belongs to the phase that fixes
   its finding, and Phase 13 takes what is left.
2. Build and run the suite with the `ios-build-verify` skill, as `CLAUDE.md` describes. Read the
   run's test count, not only its exit status. The baseline at `88dbb96` is 951 tests in 90
   suites.
3. Run `swiftlint lint --strict` on the Swift files you changed. The pre-commit hook does the same
   to staged files and blocks the commit on any violation; `CLAUDE.md` § Linting lists the rule
   that bounces most commits.
4. For any visible change, launch the app and look at it, following the `verify-in-simulator`
   skill, on the iPhone and the iPad. **Use only Conjuguer's own simulators**, "Conjuguer iPhone
   17" (`AD93C7DA-EB19-4969-9291-44B92B66C3D9`) and "Conjuguer iPad Pro 11"
   (`2BD23264-485B-458D-9B00-895F29CED397`), and name the UDID in every `simctl` command, since
   Konjugieren's and Conjugar's sessions run beside this one. Boot the iPad only for its check and
   shut it down after. Never restart CoreSimulator without asking Josh.
5. Localize any new or changed string in English and French, following
   `.claude/rules/localization_catalog.md`, French punctuation included.
6. Update [`docs/project_structure.md`](../docs/project_structure.md) for new, renamed, or
   repurposed files, keep the `verify-in-simulator` skill's identifier table true, and run
   `python3 scripts/check_docs.py`.
7. Under each finding fixed, in `docs/verb_browse_review.md`, add a line saying it was fixed on
   `main`, with the date and this plan's phase. Correct any other doc the fix makes untrue;
   [`docs/feature_architecture.md`](../docs/feature_architecture.md) is the likely one, and T5
   lists the claims that are already false. A new or changed signal, parameter, or value is staged
   in [`docs/privacy_policy_pending.md`](../docs/privacy_policy_pending.md) in both languages.
8. Fill in the Status row, write **How it differed**, and append a journal entry to
   `docs/blog_notes.md`.
9. **Git.** Josh's rule, carried over from Konjugieren's plan (2026-11-25): a phase whose row says
   "Yes" under "Waits for Josh" changes what he can see or tap, so it stops before `git add`. Tell
   him what changed and how to try it: which screens, what to type or tap, on which device. Commit
   and push to `main` once he says he has tried it. A phase whose row says "No" commits and pushes
   to `main` once steps 2, 3, and 6 pass, and then tells him what he could try. Either way, record
   the hash in the Status row with a one-line follow-up commit, since a commit cannot contain its
   own hash.

**No release before 2027.** Everything accumulates on `main`. A step that needs a device or
release day goes in `docs/release.md`.

**Conjuguer only.** Do not port a fix to Konjugieren or Conjugar. The Closing lists what would
carry over.

**No phase needs subagents.** The review's prompt asked for Opus where it used them.

## Decisions Already Made

Josh's answers on 2026-11-25.

- **Scope.** Everything in the review. Every finding gets a phase here, or a line in the Closing's
  audit saying why it was left.
- **Routing (B1, B2, B4, B8, S1).** One routed sheet: a parsed `Deeplink` type, one `RoutedSheet`
  presented from one place, targets cleared only after a link resolves, and in-app links carried
  as values, not URLs.
- **Multiple windows.** A router that each scene owns, holding the selected tab, the routed sheet,
  and the search request. The arrow keys are kept per window. `Current` keeps the services.
- **A quiz with few cells to ask (B5).** A round is as long as the distinct cells allow, up to
  ten. Ten More is offered only while unasked cells remain. The Quiz button hides when fewer than
  three cells exist, which is Test Me's length.
- **What search understands.** All four: G1, G2, G3, and B13.
- **A collection's quiz** draws first from its verbs inside the learner's level band, and from the
  rest only when the band runs out.
- **Related verbs (S5).** A test that the base rule gives the same answer from the English and the
  French etymologies, for every verb. No build-time table.
- **The French colon (B25).** French punctuation wherever the text is French. The search row's
  line and the Look Up answer read "vais : Indicatif Présent (je)", with U+202F, in both interface
  languages, because the line is French in both. The model page's labels move into the catalog:
  "Parent:" in English and "Parent :" in French.
- **Suspected findings** are confirmed before they are fixed. B9 may clear the recents on
  Conjuguer's iPad simulator. B10 needs a device, so it goes to `docs/release.md` with its fix
  sketched.

Carried over from Josh's answers for Konjugieren the same day, each confirmed for Conjuguer:

- **Collection progress is separate from My Verbs.** A verb counts once it has ever been opened.
  Clear and the swipe forget only the recent history. Clear gets no confirmation.
- **A full forget lives in Reset Practice.** The existing button in Settings also forgets which
  verbs were ever opened, and its alert says so. Stars and recents stay.
- **`VerbBrowseView` is split in full:** a search model, then `MyVerbsList` and a host for the
  review card. Here the search model's iPad workaround is shared with the Models tab.
- **The migration from `LearnerVerbs`' per-verb schedule is deleted now.**
- **Git** as step 9 above says.

Defaults this plan chose without asking, because the review or Konjugieren's plan left one
reasonable course. Josh may overrule any of them:

- **K-S8.** The sort picker is disabled while the search field has text.
- **K-F1.** A failed search shows its empty state at once, and the guess arrives from off the main
  actor.
- **A lookup from the widget still sends a verb back to the first box.** That rule is the
  pedagogy plan's. This plan changes nothing there.
- **The model page's run of links stays a run of links** (Josh, 2026-11-22). Phase 10 caches it
  and shows a doubled entry as "haïr (France)", as every other screen does.

## Phase 1: A Link Is Parsed Once, and Resolved Before Anything Is Cleared

**Findings:** B4, and from S1 the parser, the builders, the repeated fallback, and the `search`
route. **Depends on:** nothing.

- A `Deeplink` enum with `init?(url:)` and `var url`, as S1 sketches: verb (a key or `random`,
  with source and match), search, model, list, info, and the quiz routes. It is the grammar's only
  parser, and the builders in `URLExtensions.swift` become its `url`. The source is not optional
  inside it: a link without one is `deeplink`.
- `World` resolves a `Deeplink` to a value before it clears anything, and clears and assigns only
  when the link resolves. An unknown `verb/`, `model/`, `list/`, or `info/` target, and an unknown
  host, change nothing: no sheet closes, no pending request is dropped, and no tab switches.
- The `search` route calls `openSearch(text:source:)`.
- `ModelView`'s `OpenURLAction` and the verb page's article sheet match on `Deeplink(url:)` for
  now. Phase 2 replaces their URLs with values.
- This phase keeps `World`'s properties as they are. Phase 2 changes what they are.

**Done when** one round-trip test covers a link of every route (`Deeplink(url: link.url) == link`),
including `list/` and `quiz/`, which `DeeplinkTests` lacks; tests set a verb, a model, and a
pending search first, send each kind of unknown link, and find all three untouched; and
`testVerbBuilderRoundTrips` uses a real key for its reflexive row, requires the verb, and checks
the marks a real `match` produces (T3).

**Tell Josh he could try:** with a verb's page open from a widget or link,
`xcrun simctl openurl <udid> "conjuguer://list/nonsense"` leaves the page up.

**How it differed:**

- **`Deeplink` lives in `Conjuguer/Utils/Deeplink.swift`**, not in `URLExtensions.swift`, which
  now holds only the App Store link and the mail builder. Its `url` is not optional (a scheme, a
  host, and a slash-led path always make a URL), so the `?.absoluteString ?? ""` at every caller
  went. It leaves out a `source` of `deeplink`, which the parser supplies when the item is missing,
  so the model page's verb links still carry no source.
- **The practice set's filter moved out of the parser.** `PracticeSet(url:)` dropped verbs this
  install lacks, which needs `Verb.verbs`, and a link that arrives on a cold launch must parse
  before the verbs load. So `Deeplink.practiceSet` holds the `CustomQuiz` as the link spells it,
  and `PracticeSet(linked:level:)` drops what cannot be asked when `World` resolves the link.
  `World.challengeKey(in:level:)` went the same way: the case holds the date and level, and
  `World` builds the key.
- **`World.pendingDeeplink` holds a `Deeplink`**, not a URL.
- **The search route and `openSearch` share one path** (`show(.search(…))`), rather than the
  route calling `openSearch` by name. The effect is what the phase asked: the three steps are
  written once.
- **`InfoView.openLink` takes a `Deeplink` already**, and `handleInAppURL(_:)` became
  `handleInApp(_:)`, which takes one. With the builders gone, building a URL there only to parse it
  back was the one thing left to write, so I wrote the value. Phase 2 still turns it into an
  article or a verb.
- **Callers moved to values**: `VerbLookup.destination` and `QuickAction.deeplink` are
  `Deeplink`s, and Spotlight's continuation hands `World.handle(_:)` a value. The article sheet's
  pushed verb takes the link's own source, which is `infoLink` as before.
- **S9's `URL.modelDeeplink(_: VerbModel)` went with the other builders**, so Phase 12 has one
  item less.
- **Behavior.** An unknown `verb/` or `model/` target no longer switches the tab;
  `docs/feature_architecture.md` § Deeplinks says so. A `quiz/start` link still clears what is
  open, as before.
- **Checks.** 954 tests in 90 suites (951 plus three). With `clearDeeplinkTargets()` put back
  before `resolve`, `testALinkThatNamesNothingChangesNothing` recorded 25 issues. On the iPhone
  simulator, lire's page opened by link stayed up through `list/nonsense`, `verb/nonsense`, and
  `model/nonsense`; `model/1-9` then replaced it, and the model page's aller link pushed aller's
  page.

## Phase 2: One Routed Sheet, and Articles That Push

**Findings:** B1, B2, B8, B28, and the rest of S1. From S4a, the article sheet's copy of
`SheetDismissable`. **Depends on:** Phase 1. **Waits for Josh.**

- One `RoutedSheet` value (a verb destination, a model, a collection destination, an article, a
  practice set) presented by one `.sheet(item:)`. `World.verb`, `verbSource`, and `verbMarks`
  become the `VerbDestination` that already bundles them. The verb sheets on `VerbBrowseView` and
  `InfoBrowseView`, the model and collection sheets on `ModelBrowseView`, and the article sheet on
  `InfoBrowseView` go.
- Each routed verb has its own identity, as `PracticeSetRequest` has, so a second link to the verb
  already showing presents a fresh page that scrolls to the new mark, opens the compound block if
  the mark needs it, and begins a new visit (B8).
- Every presented article gets a stack and pushes what its links lead to: one `ArticleSheet`,
  replacing the private `TenseArticleSheet`, used for a routed article, the model page's
  irregularities article, and a tense's article. `InfoView.openLink` takes a value (an article or
  a verb), so nothing builds a URL only to parse it back.
- An article link tapped inside an Info-tab article reaches the routed sheet today. Decide whether
  it should push in the tab's own stack instead, and say which in **How it differed**. Either way
  a verb link in the article it opens must work.
- The article opener is injected per stack by `verbPageNavigation`, as `verbPagePush` is, so a
  sheet presented from inside an article sheet does not inherit it (B28).

**Reproduce first,** as the review did: after one visit to the Info tab, one
`conjuguer://verb/boire` link logs "Presenting view controller … from detached view controller",
and the App Group plist's `learnerVerbs` shows `openCount` 2 for boire. Then
`conjuguer://info/passe_compose`, a tap on "être" in the article, and no verb page.

**Done when** both reproductions are gone (no assertion in the log, `openCount` 1, the verb page
pushed inside the article sheet), a test with `AnalyticsSpy` pins one `viewAppeared` per routed
verb, and the "dropped or late" link of the browse plan's Phase 12 has been tried ten times: a
venir link while aller's page is up.

**Tell Josh to try,** on the iPhone and the iPad, each after visiting the Info tab: a widget's
tap; two verb links in a row; a link to the verb already showing with another `match`; a `model/`
and a `list/` link while a verb page is up; in the Info tab, an article, a link in it to another
article, and a verb link in that one; a model page's red diamond and a verb link in its article;
a tense heading's diamond on a verb page, then a verb link, then that page's own diamond.

**How it differed:**

- **`RoutedSheet` is a struct holding a `Page` enum and a `UUID`**, not an enum, so every case gets
  its identity in one place. `World.routedSheet` replaces `verb`, `verbSource`, `verbMarks`,
  `verbModel`, `collection`, `info`, and `practiceSet`. `World.Destination` has one `.sheet(Page)`
  case beside the requests, and `Page.tab` says which tab lies beneath. `MainTabView` presents it,
  with a practice set still sized `.page`.
- **The Info tab's articles push in the tab's own stack**, the decision the phase left open. Its
  `NavigationStack` now takes `verbPageNavigation(pushesTenseArticles: true)`, so an article link
  pushes the article, a verb link pushes the verb page, and that page's tense diamond pushes its
  article too. I chose this because the learner is reading articles there, and Back returns along
  the thread.
- **`World.handleInApp(_:)` is gone.** Every `InfoView` is now inside a stack that pushes, so
  nothing needed it. Its three tests went with it. In their place, `anArticlesLinkNamesAnArticleOrAVerb`
  pins `InfoView.LinkTarget(url:)`, the value an article's link becomes.
- **`InfoView` has no `openLink`.** It reads `verbPagePush` and pushes the `Info` or the
  `VerbDestination` itself, since `verbPageNavigation` now registers `Info` on every stack. That
  meets "takes a value" without a closure that each owner would have had to write the same way.
  The model page's verb links and an article's links stay URLs inside their `AttributedString`s,
  since a `Text` link can be nothing else. Each is read back once, where it is tapped.
- **B28's back channel became a Boolean.** `tenseArticleOpener` is gone. Each stack sets
  `pushesTenseArticles` through `verbPageNavigation`, and a verb page pushes its article through
  the ordinary `verbPagePush` when the flag is on. A sheet's `SheetDismissable` and the Quiz tab's
  stack both set it off, which is what stops the leak. I did not run the review's long path (a
  verb page in an article sheet, Test Me, a correction's verb link). It is fixed by construction:
  `QuizView` builds its own stack through `verbPageNavigation`.
- **`ArticleSheet` is `InfoView` in `.sheetDismissable(pushesTenseArticles: true)`**, in a file of
  its own. The verb page's diamond, the model page's red diamond, and an `info/` link all use it.
- **The test of one `viewAppeared` per link hosts `MainTabView` in a window.**
  `RoutedSheetTests.aLinkedVerbIsPresentedOnce` builds a `World` of its own (so the suites that
  change `Current` cannot reach the window), loads the Info tab, sends a boire link, and expects
  one appearance and an `openCount` of 1. It then sends a second boire link with another match and
  expects a second appearance, which pins B8. With a second presenter put back in the Info tab, it
  recorded both bugs: two `widget` appearances, an `openCount` of 2, and then a `resume` where the
  second link's `lookup` should be. Replacing a sheet takes about two seconds on the simulator, so
  the test polls with a six-second limit rather than sleeping a fixed time. It costs about 13
  seconds of the run.
- **Reproduction.** I did not rerun the review's reproductions before changing the code. The
  reviewer had run both, and the hosted test reproduced B1 against the old shape. After the fix,
  on the iPhone simulator: the Info tab visited, then `verb/coudre`, gave one page, `openCount` 1,
  and no presentation warning in the log. `info/passe_compose` and a tap on être pushed être's
  page inside the article sheet, and its tense diamond pushed that tense's article there. Ten
  alternating venir and aller links each showed the right page. `verb/aller?match=vais` and then
  `?match=suis allé` gave a fresh page scrolled to the marked "suis allé". In the Info tab,
  Irregularities, then cacaber, then its diamond, all pushed in the tab. A model page's red diamond
  presented the article, whose alunir link pushed inside it. `list/` and `model/` links each
  replaced a verb page. A link that arrived while a tense article was up over a page in the Verbs
  tab closed the article and showed the linked page. On the iPad: the Info tab visited, then
  coudre's link, gave `openCount` 1, and être in a linked article pushed inside the sheet. Neither
  log held a presentation warning.
- **Checks.** 955 tests in 91 suites (954, less the three `handleInApp` tests, plus one for
  `LinkTarget` and three in `RoutedSheetTests`). SwiftLint is clean, and `check_docs.py` passes. No
  string, signal, or parameter changed, so neither catalog nor privacy staging was touched.
- **`VerbDrawTests` went from 162 seconds to 1.6** (Josh, 2026-11-25), outside the phase's
  findings. Each draw weighs every verb it is offered, and a weight reads the verb's etymology, so
  20,000 draws over the 1,000-verb band made 20 million reads. The proportion tests now draw from
  ten verbs of the band, four of weight 1, three of 2, and three of 4, or from two verbs beside My
  Verbs, and the band test makes 50 draws rather than 500. The app's single draws are untouched.
- **Docs.** `docs/feature_architecture.md`'s paragraph on the verb page's article, § Navigation, § How the source travels,
  and § Deeplinks' architecture table describe the routed sheet. Phase 1's line under B4 in the
  review notes that its test now starts from the verb page alone, since a model cannot be open
  beside it.

## Phase 3: A Router for Each Window

**Findings:** "Multiple windows" in the review's Seen Outside the Scope. **Depends on:** Phase 2.
**Waits for Josh.**

- **Look first.** On the iPad simulator, open two windows of the app and record what a verb link,
  a tab switch, Command-F, and the arrow keys do today. The review traced the shared state and
  did not run it.
- A router that each scene owns (`@State` in the scene's root, injected into the environment)
  holds the selected tab, the routed sheet, the search request, and the daily-session and
  challenge requests. Each scene's `onOpenURL`, Spotlight continuation, and quick action reach
  that scene's router. `Current` keeps the services, the settings, and the stores.
- The cold-launch path still works: a link that arrives before the verbs load is held and
  replayed once, in the scene it arrived in. The control's and shortcuts' mailbox is drained by
  one scene only.
- `VerbSearchArrowKeys` keeps a closure per window and installs on the window that holds the
  field, so two windows no longer cross their keys.
- `VerbSpotlight.indexVerbsIfNeeded` cannot run twice at once when two windows launch together.
- The App Intents that call `Current.handleURL` need a scene to deliver to. If none is easy to
  reach, they may keep a pending link that the first active scene takes, and the note says so.

**Done when** two windows side by side each keep their own tab and sheet, a link opens in one
window, and the arrow keys move the highlight in the window whose field is focused. Tests drive
two routers with two links and find them independent.

**Tell Josh to try,** on the iPad with two windows of the app: a link, a tab switch in one
window, Command-F, and the arrow keys in each field. If he has a Mac to try, the same there.

**How it differed:**

## Phase 4: Pages Push, and the Dead Sheets Go

**Findings:** S2. **Depends on:** Phase 2.

- One `VerbPageRoute` enum (verb, model, related list, collection) with one
  `navigationDestination`, in place of four destination structs erased to `any Hashable`.
- The push action in the environment is never nil. Previews get a stack with
  `verbPageNavigation`.
- Delete the unreachable fallbacks: `VerbView.DetailSheet`'s verb, model, and related-list cases
  and the switch in `open(_:)`; `ModelView.DetailSheet.verb`; and the `sheetVerb` state and sheet
  in `RelatedVerbListView` and `VerbCollectionView`.
- `VerbPageNavigation.page` writes its environment line once.

**Done when** the build has no optional push, a test or a compile-time switch makes an
unregistered route impossible, and every push the browse plan's phases tried still works: a
related chip, "All N" in both rows, a model row, a model page's verb link, a collection's row,
each inside a tab and inside a sheet.

**Tell Josh he could try:** those pushes, on either device. Nothing should look different.

**How it differed:**

## Phase 5: A Search Model That Both Tabs Share

**Findings:** B3, B6, B18 (the linger and the two requests), B23, B24, B26, D5, and from S3 the
search model. **K-F1** and **K-S8**. **Depends on:** Phase 3. **Waits for Josh.**

- Extract an `@Observable` search model from `VerbBrowseView`. It owns the text, the matches, the
  guess, the `SearchTracker`, and the keyboard selection, which is the selected verb's id, not a
  row index (B6). The view keeps focus and navigation.
- One list of matches is the only stored result. The rows shown, the count in the heading, and the
  match lines derive from it once per change, not once per body pass. `BrowseSearch` either earns
  its place or goes; its header is false today.
- A search that matches nothing shows the empty state at once. The guess is computed off the main
  actor and appears when ready, and a change to the text cancels a guess still in flight. The
  trombone still plays once per failed search (**K-F1**). **Measure before and after** with a
  temporary timing test: finnissons and xyzzyq, the time until the text change returns.
- An ended search reports from the matches the model already holds. With that, decide whether a
  query backspaced to nothing should report the query the learner passed over rather than its
  last letter, which the browse plan recorded as a quirk; the review's S3 suggests it.
- The iPad engagement workaround (the lingering focus, the letter that waits for the dismissal,
  the push that waits) becomes one piece that both tabs use, so the Models tab's accent row works
  in an empty field (B3). Its tasks are cancelled when superseded (B18). `searchFocusLostAt` is
  replaced by state that says what it means. A pending source survives the key's touch (B24).
- The `searchable` modifiers and the picker-or-key-row swap are written once (D5). A query of
  spaces behaves the same in both tabs (B23).
- The sort picker is disabled while the field has text (**K-S8**).
- The highlighted row and the guess card carry the selected trait (B26).

**Reproduce B3 first:** on the iPad simulator, focus the empty Models field and tap ê. The field
stays empty.

**Done when** the model's flow has tests: typing, clearing, a guess that arrives, a guess
cancelled by the next letter, opening a result, opening the guess, the report each sends, and the
selection following its verb when the rows change. On the iPad, ê lands in the empty Models field.

**Tell Josh to try:** on the iPhone, xyzzyq and finnissons typed quickly, then a cleared field;
on the iPad with a hardware keyboard, Command-F, the arrow keys through results and through
recents, Return on a result and on the guess, and an accent key first in each tab's empty field.

**How it differed:**

## Phase 6: Split the Verb List's View

**Findings:** B9, the rest of S3, D4, D7, and "the review card can act on a stale offer" from Seen
Outside the Scope. **Depends on:** Phase 5. **Waits for Josh.**

- Move out of `VerbBrowseView`, each into its own file: `MyVerbsList` with its alert, and a host
  for the review card's choice, reveal, snooze, and signal, with those rules somewhere a test can
  drive them (T1). One `ListContent` value (all, results, no results, recents, My Verbs) says what
  the list shows, and everything switches on it.
- **B9. Confirm first.** On the iPad simulator, with no recents (Clear them; Josh allowed it), a
  starred verb, and My Verbs chosen, focus the empty field and tap the row; then the same with a
  revealed review card. If the push is dropped, route both through the shared workaround. If it is
  not, record that.
- The review card drops an offer that no longer holds before it reveals or signals.
- The grid and list branches of both tabs build their rows once (D4).
- `VerbListMode` wraps `VerbSort` (D7).

**Done when** `VerbBrowseView` is the navigation stack, the list or grid, the picker or key row,
and the search request, and the card's rules have tests: a dismissal before the reveal snoozes,
one after it does nothing, a reveal applies once, and the card is chosen once per opening.

**Tell Josh to try:** My Verbs (swipe a recent verb, swipe a starred one and cancel, Clear), the
review card (reveal, open, dismiss, Suppress Review Card on and off), on both devices.

**How it differed:**

## Phase 7: What Search Understands, and How It Names a Match

**Findings:** B7, B13 (with G4), B14, B15, B21, B22, B25 (the row's line), B30, G1, G2, G3, S10.
From S9: `MatchKind`'s `Comparable`, `keysCache`, `ModelSearch.seenVerbs`. **Depends on:** nothing.
**Waits for Josh.**

- **G1.** ce, c', ça, and cela are subjects, and ce follows a hyphen: "c'est", "ce sont", "ça va",
  and "est-ce" find être and aller.
- **G2.** An inverted compound's auxiliary is looked up by its verb part: "as-tu mangé",
  "est-il allé".
- **G3 and S10.** One pronoun stripper serves the infinitive side and the conjugation side, so "y
  aller", "s'en aller", "me lever", and "ne pas manger" find their infinitives. "s'" alone still
  searches as s. The lowercase-and-NFC normalization is written once where the tool's sources
  allow.
- **B13.** A word that ends in a hyphen, or in a hyphen and the start of a pronoun, is still being
  typed: no trombone and no guess at "dis-", "dis-m", "lève-to".
- **B14.** A query that is only pronouns gets no guess.
- **B22.** A hyphenated impératif typed without accents keeps its pronoun in the confirmation.
- **B7.** A pronominal compound with nous or vous writes the pronoun twice. A test runs every
  sentence row's text back through `MarkedConjugations(text:on:)` and finds the same cells (T4).
- **B15.** `meanings(of:)` strips parentheticals before it splits. Pin desserrer and remercier.
- **B30.** Look Up a Verb's literal tier is the exact infinitive and the literal conjugation, and
  the folded kinds answer only when it is empty. Pin pêcher and one 1990-spelling pair.
- **B21.** Look Up a Verb says one line for a conjugation that both entries of a doubled
  infinitive share, or tells the entries apart.
- **B25.** The row's line and the Look Up answer put U+202F before the colon, in both languages.
- `MatchKind` loses its `Comparable`, and its comment says that `tier` decides rank. The folded
  infinitive and the gloss's meanings are stored on `Verb` when it is parsed, and `keysCache`
  goes. `Verb.swift` compiles into `ConjugationMapTool`, so build the tool.

**Done when** each case above has a test, `ConjugationMapTests`' comparison with a fresh build
passes, and `scripts/write_forms_json.sh` leaves `corpus/working/forms.json` byte-identical
(`git diff --stat` shows nothing), which proves that nothing the tool compiles changed its output.
`VerbSearchTests` and `VerbSearchConjugationTests` pass, with any expectation that changes
explained.

**Tell Josh to try:** c'est, est-ce, as-tu mangé, y aller, s'en aller, me lever, dis-moi typed
slowly with the sound on, nous alone, "nous nous sommes levés" opened onto lever's page, fire and
belt, and Look Up a Verb for pêcher and for haïssons.

**How it differed:**

## Phase 8: The Learner's Record and the Widget's Draw

**Findings:** B16, B19, S12, T2, the progress and full-forget decisions, the migration. From S9:
the record's comment about the widget, `SeededRandomNumberGenerator`'s header, the test-only
`generateSnapshot(date:myVerbs:)`. **Depends on:** nothing. **Waits for Josh.**

- **Progress.** `hasOpened` reads `firstOpened`. `clearRecents` and the swipe's `remove` forget
  `lastOpened` and the open count (and the star, for the swipe) and keep `firstOpened`. An entry
  with only `firstOpened` appears in neither Starred nor Recent. An entry written before this
  phase still decodes, and one with `lastOpened` but no `firstOpened` counts as opened. Tests pin
  each.
- **The full forget.** Reset Practice in Settings also forgets every `firstOpened`. Its
  description and its alert name the collections' progress, in both languages. Its button shows
  when the record of opens holds anything, as it does for the other things it erases.
- **B16.** Recent shows up to twenty unstarred verbs, by filtering before taking the limit.
  Remove the `limit` parameter that nothing passes.
- **B19.** `VerbDraw.verbOfTheDay` takes My Verbs in turn over a stable order. Test with a list
  that gains a verb, and one whose recents reorder, between My Verbs days: no verb repeats while
  another waits. The widget's stable-through-the-day rule still holds.
- **S12.** The store computes its recent and starred lists once per change of the record, not on
  every read.
- **The migration.** Delete `PracticeStore`'s migration of `LearnerVerbs.review`, its legacy
  type, its tests, and the paragraphs that describe them.
- **T2.** `writeSnapshots` takes its file and My Verbs as parameters, or yields a function from
  the old bundle to the new one, and tests cover a missing bundle, a corrupt one, one from another
  day, a second identical write that is skipped, and today's verb kept when My Verbs changes.
- Correct the comment in `Shared/LearnerVerbs.swift`: the widget reads the snapshots, not the
  record. Keep the rule that added fields must be optional, with its true reason, an app upgrade.
  Say in `SeededRandomNumberGenerator`'s header that it seeds every learner's verb of the day.
- Check the staged privacy paragraph about the list kept on the device against the new behavior.

**Tell Josh to try:** open a verb from the top 100's page, swipe it out of My Verbs, and find the
count unchanged; Clear, and find every collection's count unchanged; Reset Practice, read its
alert, and find the counts at zero with the stars still there.

**How it differed:**

## Phase 9: The Verb Page

**Findings:** B12, B27, B29, S4, S4a, S5, S6, D8, D9, **K-G6**. From T1, the visit's pairing. From
T5, the verb page's three false claims. Konjugieren's E2. **Depends on:** Phase 4. **Waits for
Josh.**

- **B12.** œ and æ are vowels to the elision test. Pin œuvrer's je cell and its key conjugations,
  and check the quiz's answer frame and Name the Conjugation, which call the same function.
- **S4.** The compound cards are cached with the simple ones, and a page reads the cache from
  `body`, so a change of the pronoun-gender setting reaches both blocks of an open page.
  **Confirm the suspicion first:** open a verb page, change the setting, return, tap the star, and
  see whether the blocks disagree. The star reads the record in a view of its own, so recording an
  open does not rebuild every page in the stack. **Measure** the passes per open before and after,
  as the review did, by counting one heading's string lookups in the log.
- **S4a.** The visit's begin-and-end rules move into a type with event methods that return what to
  signal and what to record, and tests pin the pairing, the resume after the background and after
  the page's own sheet, and no recorded open on a resume. The example card owns its chanson state.
  The tense cards and the example card move to their own files. A card's scroll target is its
  `TenseTable`.
- **S6.** `TenseTable.isCompound` derives from its tenses, and `Tense.article` does not scan the
  articles on every pass.
- **B27 and K-G6.** Every card of a block reports its block, and the Related Verbs card is a
  `VerbPageSection`. That adds a value to `deepestSection`: stage it in
  `docs/privacy_policy_pending.md` in both languages.
- **B29.** The Related Verbs card's titles mark the French verb French, per `docs/voiceover.md`,
  and the Overview and color-key headings carry the header trait.
- **S5.** A test runs the base rule over the English and the French etymologies for every verb
  and fails on any difference. `Etymology` needs a lookup by language for it.
- **D8.** One function decides which key conjugations a verb has, and the page and the practice
  schedule both read it.
- **D9.** One article button. **E2.** `conjugationParts` drops the case its `guard` already
  covers.
- Correct the three claims in `docs/feature_architecture.md`: which sheets end a visit, six
  French tenses without a second name, and what obeys `TipDisplay.tipsEnabled`. Decide whether the
  color key should obey it, and say which.

**Tell Josh to try:** œuvrer's page; "sois" from search, then leave at once (the visit should not
read as a bounce, which only the log shows); a verb page open across a change of pronoun gender;
the star on a page three deep in a related-verbs chain; Test Me and an article from a page, and
the page still there after each.

**How it differed:**

## Phase 10: Lists, Model Pages, and Collections

**Findings:** B17, B25 (the model page's labels), S8, S13, S14, D1, D2, D3, D6, T6. From S9:
`FlowLayout`'s home, `VerbCollection.isFeatured`, `ModelView`'s unused `world`. Konjugieren's S3,
declarations in files named for something else. **Depends on:** Phase 4. **Waits for Josh.**

- **D3 and B17.** One frequency comparator and one French alphabetical comparator on `Verb`, each
  with a tie-break, used everywhere a list is sorted. The alphabetical verb list and the Models
  tab's alphabetical order no longer swap doubled entries between launches.
- **D1.** `BrowseRow` has an initializer from a verb.
- **D2.** One sortable verb-list page serves a collection and a related-verbs list, with the iPad
  grid, the picker, and one alphabetical key.
- **D6.** One share button that hands its frame to the action. The quiz's three copies may adopt
  it here or be left for the pedagogy code's next visit; say which.
- **S13.** The model page's run of links is cached per model and order, and shows a doubled entry
  as "haïr (France)". A model's collection reads the model's own list of verbs.
- **S8.** Accessibility identifiers that name a verb or a model use the dictionary key or the
  model's id, so the two haïr rows differ. Update the `verify-in-simulator` table.
- **B25.** "Parent" and the participe passé label carry their colons in the catalog.
- **S14.** A view sends `viewCollection`; the collection only says what to send.
- `FlowLayout` moves to its own file and proposes the row's width to each child, so a chip wider
  than a row wraps. `VerbDestination` and `VerbListMode` move to files named for them. Delete
  `isFeatured` and `ModelView`'s `world`.
- **T6.** `docs/voiceover.md` gains rows for the collection page, its bar, and its row, each
  marked tested or untested.

**Tell Josh to try:** the alphabetical verb list around haïr after two relaunches; a collection's
page and "All N" from a Related Verbs card in both orders, on the iPad too; parler's model page
(how long it takes to appear, and haïr's model page for the parentheses); the model page in
French for "Parent :"; the chips on the Quiz tab, which share `FlowLayout`.

**How it differed:**

## Phase 11: A Quiz over Chosen Verbs

**Findings:** B5, S7, and "a collection's quiz draws uniformly" from Seen Outside the Scope.
**Depends on:** nothing. **Waits for Josh.**

This phase touches code the pedagogy plan wrote. Read
[`plans/pedagogy_implementation.md`](pedagogy_implementation.md) for the modes before changing how
they are told apart.

- **B5.** A round over chosen verbs is as long as its distinct cells allow, up to the question
  count, and no cell repeats within a session while an unasked one remains. Ten More carries what
  earlier rounds asked, and is offered only while unasked cells remain. The Quiz button on a
  collection's bar, and Start for My Verbs, need at least three cells at the learner's level.
  Test Me keeps its own rule. Correct `aDefectiveVerbIsAskedOnlyTheCellsItHas`, which pins the
  padding, and the doc's claims about falloir and férir.
- **The draw.** A collection's quiz draws from its verbs inside the level's band first, and from
  the rest when the band runs out. Decide whether a My Verbs quiz does the same, and say which;
  the learner chose those verbs, which argues against.
- **S7.** `QuizScope` gains a `kind`, and what is ranked, what starts a Live Activity, what
  continues, and which draw runs become switches over it. `showsVerbLink` reads the scope, not the
  analytics source. A test builds every scope the app can start and pins which is ranked and which
  starts a Live Activity. No behavior changes but B5's.

**Done when** falloir's model page at Beginner shows no Quiz button, aller's model page asks a
round with no repeated cell and Ten More continues without repeats until the cells run out, and a
quiz from parler's model page asks verbs of the level's band.

**Tell Josh to try:** those three; a My Verbs quiz of three verbs through Ten More; a My Verbs
list of only falloir; and the default quiz, a collection quiz, Test Me, and a daily session
started once each, to see that nothing else moved.

**How it differed:**

## Phase 12: Intents, Spotlight, and the Tool

**Findings:** B10, B11, B20, S11, **K-S9**, **K-S10**. From S9: `URL.modelDeeplink(_: VerbModel)`.
**Depends on:** nothing, though after Phase 1 the links have one builder to share.

- **S11.** The intents in `Shared/` share one `perform()`, each with a constant for its link, and
  `OpenQuizIntent` gets one. The widget's two links move where a test can pin them. `DeeplinkTests`
  pins all six, and the doc's sentence about that becomes true.
- **B10. A device question.** Write in `docs/release.md` a check that the Find a Verb control and
  the Random Verb shortcut open what they should on a warm launch as well as a cold one, and that
  no stale link fires on a later launch. Sketch the fix beside it (`OpenURLIntent` in place of the
  mailbox, or a timestamp on the stashed link). Build the fix now only if it can be tested without
  a device.
- **B11. Measure first.** Time a cold `conjuguer://search?q=vais` and a cold Look Up a Verb in a
  Release build. If the index costs more than a frame or two, warm it off the main actor before
  the intent, the entity query, and a requested search use it. If not, record the number and skip
  the change.
- **B20.** A reindex deletes the named index's entries first, so a verb that left `verbs.xml`
  leaves Spotlight too.
- **K-S9.** `ConjugationMapTool` rejects a flag it does not know. `ConjugationMap(compressed:)`
  throws on invalid UTF-8.
- **K-S10.** The build directory in `scripts/write_forms_json.sh` is named for Conjuguer.
- Delete the model-deeplink overload that only a test calls, or use it.

**Done when** the tests above pass, an unchanged rebuild still skips the map phase (by the map's
timestamp, as `docs/feature_architecture.md` § Conjugation Map describes), and
`scripts/write_forms_json.sh` runs from its new directory.

**Tell Josh he could try:** the Random Verb shortcut, the Find a Verb control if it is installed,
Look Up a Verb, and a verb found in Spotlight.

**How it differed:**

## Phase 13: Tests and Prose That Remain

**Findings:** T3, T4, T5, and S9, less whatever earlier phases already took. **Depends on:**
nothing, though it is shortest when taken last.

- **T3.** Repair or delete `aDayGivesTheSameVerbEveryTime`, and any other test the review names
  that an earlier phase did not reach. `testNoParameterValueEchoesTheQuery` holds by its types;
  keep it or say in a comment that it is a tripwire.
- **T4.** Where an exact assertion against the corpus is meant as a tripwire, say so in a comment.
  Where it is not, assert what the test is about.
- Pin the review schedule on a daylight-saving day in Europe/Paris, and consider
  `Calendar.autoupdatingCurrent` for the practice store.
- **T5.** Read `docs/feature_architecture.md` against the list in T5 and against each phase's
  **How it differed**, and correct what is still false.
- **S9.** Whatever of its list remains: comments that restate a callee, `BrowseSearch`'s header if
  the file survived Phase 5.

**How it differed:**

## Closing

- Run the full suite, `swiftlint lint --strict` over the app's sources, and `check_docs.py`.
- Confirm that every finding in `docs/verb_browse_review.md` carries a line: fixed, with date and
  phase; found not to be real; or left, with the reason. That includes the rows of its table of
  Konjugieren's findings marked "carried over", and the cost of a settled decision that this plan
  leaves alone, a lookup from the widget resetting a verb's schedule.
- **The timed workarounds.** List in one place, in `docs/feature_architecture.md` or a short doc
  of their own, each wait the app still makes: what it waits for, how long, and how to tell
  whether a new iOS has made it unnecessary.
- **For release day.** Confirm that `docs/release.md` holds the device checks this plan deferred:
  B10's, two windows on a real iPad or Mac, and VoiceOver on the verb row and the collection
  views.
- Write a short list of which fixes would carry over to Konjugieren and Conjugar. The review's
  last section names the findings Konjugieren's own review does not list. Do not read the
  siblings' code for it beyond what is needed to say whether a phase applies.
- Mark this plan finished in its Status section.

**How it differed:**
