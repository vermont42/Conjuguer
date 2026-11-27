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
| 2 | Done | 2026-11-25 | `d36f6d5` | B1, B2, B8, B28, S1 (the sheets) | Yes |
| 3 | Done | 2026-11-25 | `f2e962e` | Multiple windows | Yes |
| 4 | Done | 2026-11-25 | `8f31dfe` | S2 | No |
| 5 | Done | 2026-11-26 | `da22b7e` | B3, B6, B18, B23, B24, B26, S3 (the search model), D5, T1 (the search), K-F1, K-S8 | Yes |
| 6 | Done | 2026-11-26 | `cbb5b60` | B9, S3 (the rest), D4, D7, T1 (the card), the stale review card | Yes |
| 7 | Done | 2026-11-26 | `4ca2f5f` | B7, B13, B14, B15, B21, B22, B25 (the row), B30, G1, G2, G3, S10 | Yes |
| 8 | Done | 2026-11-26 | `f866c2a` | B16, B19, S12, the progress decision, the migration, T2 | Yes |
| 9 | Done | 2026-11-26 | `d5ae545` | B12, B27, B29, S4, S4a, S5, S6, D8, D9, T1 (the visit), K-G6 | Yes |
| 10 | Done | 2026-11-27 | `6d94bd6` | B17, B25 (the labels), S8, S13, S14, D1, D2, D3, D6, T6 | Yes |
| 11 | Done | 2026-11-27 | `4d535b0` | B5, S7, the rare-verb draw | Yes |
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

- **What two windows did before** (the look-first step, on the iPad simulator). A tab switch in
  one window showed in the other. One `verb/boire` link presented the page in both windows and
  recorded `openCount` 2, its two opens 1.3 seconds apart, which is B1 across windows. A
  `search?q=vais` link sent while one window was in front filled the other window's field and left
  the front one's empty. I did not try the arrow keys on the old build, since the windows are full
  screen there and only one field can be seen at a time. The trace is plain: the second window
  never got the keys, because the first still held them. Recorded in the review under "Multiple
  windows".
- **Opening a second window took a hook.** AXe's Command-N and swipes do nothing there, so
  `SceneRoot` has a DEBUG launch argument, `-CONJUGUER_SECOND_WINDOW YES`, that requests one. The
  windows were reached through Simulator's App Switcher with computer use. The procedure is in the
  `verify-in-simulator` skill.
- **`SceneRouter`** (`Conjuguer/Utils/SceneRouter.swift`) holds the tab, `routedSheet`, the
  search, daily-session, and challenge requests, `shouldNavigateToTutor` (onboarding's way to the
  tutor), and the cold launch's `pendingDeeplink`, with `MainTab` beside it. `World` keeps only the
  services, settings, and stores. The router reads `World` for the random draw, the quiz level,
  and the quiz, and takes it in its initializer, so a test can give it its own.
- **`SceneRoot`** (`Conjuguer/App/SceneRoot.swift`) is each window's content and owns its router
  as `@State`. `.onOpenURL`, Spotlight's continuation, the cold-launch replay, and the control's
  stashed link moved there from `ConjuguerApp`. The stashed link is taken on the window's
  activation and removed at once, so the first window to become active takes it. App-wide work
  (reminders, widget refreshes, the language model) moved to `Scene`-level `onChange`, which reads
  the app's phase and runs once however many windows are open.
- **Links with no window of their own** go through `SceneRouter.deliver(_:to:)`. SwiftUI names no
  scene to a view, so `SceneRoot` tells its router its window through a small UIKit view's
  `didMoveToWindow`. A quick action delivers to its scene's router, and waits for it on a launch.
  A reminder delivers to `response.targetScene`. `OpenLookupResultIntent` names no scene, so its
  link goes to the active window (the key one when several are active), or waits for the next
  window to become active. That is the plan's fallback for the intents, and it is the only path
  they have.
- **Command-F** reads the focused window's router through `@FocusedValue(\.sceneRouter)`, set by
  `.focusedSceneValue`, and is disabled when no window is focused.
- **The arrow keys** keep one installation per window, each with its own key commands and closure.
  A key finds its window through the view controller that received it. `VerbBrowseView` installs
  on its router's window.
- **Spotlight** indexing is guarded by `VerbSpotlight.isIndexing`. It has no test: the guard is
  three lines, and a test would have to run a real index into `CSSearchableIndex`.
- **Left as it was: the quiz.** `Current.quiz` is one for the whole app, so a quiz under way shows
  in both windows' Quiz tabs, and a `quiz/start` link in a second window finds it under way. The
  plan's list kept the services in `Current`, and the quiz's state is a service's state. A quiz per
  window would be its own change.
- **Tests.** `SceneRouterTests` (six): two routers kept apart; a cold launch's link replayed in
  its own window; a link waiting for its scene's router, and taken once; a link with no window
  going to the active window's router; one waiting for a window to become active; and the arrow
  keys per window. With the arrow keys' lookup changed back to a shared closure, the last recorded
  four issues. The test host has one scene, so no test can tell two scenes apart. That was checked
  on the simulator instead. The routing tests in `DeeplinkTests`, `VerbCollectionTests`,
  `PracticeSetTests`, and `RoutedSheetTests` each make a router, so `resetCurrent()` went.
  961 tests in 92 suites (955 plus six).
- **On the iPad simulator, after the fix**, with three windows restored: Models chosen in one
  window left another on Verbs; a `verb/suivre` link opened the page in the front window only, with
  `openCount` 1; a search link filled the front window's field; Command-F switched the front window
  from Models to Verbs with the field focused; and ↓ moved the highlight in each of two windows in
  turn. On the iPhone: a verb link, a search link, a cold launch by `verb/lire?match=lis` (marked),
  and the control's stashed link on a cold launch (a random verb, the key removed).
- **For release day,** `docs/release.md` gains a check of two windows side by side on a real iPad
  and on a Mac, including whether a link on the Mac opens a new window, which SwiftUI may do for
  an external event.

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

- **`VerbPageRoute` has five cases, not four.** Phase 2 registered `Info` as a fifth destination
  type, so an article is a route too: `.verb`, `.model(_, order:)`, `.relatedList(root:verbs:)`,
  `.collection`, and `.article`. `ModelDestination` and `RelatedVerbListDestination` became the
  cases' associated values and are gone. `VerbDestination` and `VerbCollectionDestination` stay,
  since `RoutedSheet` uses them too. The Info tab's `NavigationLink`s carry `.article` routes, and
  the tabs append routes to their own paths.
- **The guard is the compiler, not a test.** `verbPageNavigation` registers one
  `navigationDestination(for: VerbPageRoute.self)`, whose exhaustive switch gives every case a
  page, and `VerbPagePush` and `QuizCorrectionView.onOpen` take a route rather than
  `any Hashable`. No test was added: the phase deletes unreachable code and changes no behavior,
  so no test could fail before it and pass after. A tab's own `path.append` still takes any
  `Hashable`, since `NavigationPath` does, so a tab could in principle append a bare
  `VerbDestination`. None does now.
- **The push is never nil.** Its environment default asserts, naming the route, so a view shown
  outside a stack fails loudly in a debug build rather than dropping the tap. The previews of
  `VerbView`, `ModelView`, and `InfoView` sit in `PreviewStack` (in `PreviewSupport.swift`), a
  stack with `verbPageNavigation`.
- **`RelatedVerbsView` reads the push itself**, so `VerbView` no longer passes it an `open`
  closure. `RelatedVerbListView` takes `root` and `verbs`.
- **`ModelView`'s one remaining sheet**, the irregularities article, is a Boolean now, since its
  `DetailSheet` enum had only that case left. `VerbView.DetailSheet` keeps `.article` and `.quiz`,
  the two sheets a verb page still presents.
- **`page` writes its environment once**, through a small `navigationEnvironment` helper that the
  stack's root and every pushed page share, and the Done button is one `if let` in the toolbar.
- **Checks.** 961 tests in 92 suites, as after Phase 3. SwiftLint is clean on the changed files,
  and `check_docs.py` passes. No string, signal, or parameter changed. On the iPhone simulator, in
  the tabs: a collection's row and a verb row from it (Models), the verb page's model row, a model
  page's verb link, a related chip, a Verbs-tab row, a model row in the Models tab, and in the
  Info tab an article, a verb link in it, and that page's tense diamond, which pushed the tense's
  article in the tab. In sheets opened by link: "All 15" of mettre's built-on row and a verb from
  that list, the model row and a verb link on the model page, "All 4,859" of aimer's same-model
  row (the model page in frequency order), and a collection's row from `list/etre`. Over a held
  quiz correction: the model link and the verb link, each pushed and popped. Every pushed page in
  a sheet kept its Done button. The iPad was not booted, since nothing visible changed.
- **Also touched.** `docs/feature_architecture.md` § Related Verbs' Navigation describes the route
  enum, and the paragraph above it that still said a deeplink sets `Current.verb` now names the
  routed sheet.

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

- **Measured,** three runs each in a Debug build on the Conjuguer iPhone 17 simulator (Intel Mac),
  with the index and the verbs' keys warm. "Before" times the old path, the search and then the
  guess in line; "after" times `text`'s change returning, and then the guess arriving:

  | Query | Before, main thread | After, main thread | After, guess ready |
  |---|---:|---:|---:|
  | finnissons | 0.25–0.27 s | 0.08–0.09 s | 0.27–0.29 s |
  | xyzzyq | 0.17–0.19 s | 0.09–0.10 s | 0.16–0.19 s |

  What stays on the main thread is the ordinary search with reverse lookup, which the old path
  paid too. The temporary test was deleted.
- **`VerbSearchModel`** (`Conjuguer/Models/VerbSearchModel.swift`) owns the text, one list of
  `Result`s (a match and its position), `verbCount` (distinct infinitives, computed once per
  change; the whole list's heading reads `Verb.rankCount`), the guess and its task, the selected
  verb's id, and the `SearchTracker`. Opening a result, the guess, or what Return opens returns a
  `VerbDestination`; the view pushes it. The view creates it as `@State` with `Current`'s
  analytics and sound player, as Konjugieren's does.
- **The guess off the main actor** follows Konjugieren: a `@concurrent` function over `Sendable`
  `VerbSearch.GuessCandidate`s returns a `GuessFinding` (a verb id and a conjugation), and the
  model looks the verb and its cells up on the main actor. `ConjugationIndex.nearestFolds` stops
  when its task is cancelled. Look Up a Verb still guesses in line through the old signature.
  Conjuguer's edit distance was already bounded, so that half of Konjugieren's change had nothing
  to do here.
- **The trombone** (`FailedSearchSound`, shared with the Models tab) plays once as a search begins
  to fail. Before, it played on each failing keystroke, softened only by the player's debounce.
  It still waits out a query of only pronouns, and a pronoun followed by a failing word ("j'xq")
  now sounds, where a rule of "had it already failed" would have stayed silent.
- **The query passed over: decided yes.** A search cleared by deleting letter by letter reports the
  query from before the deletions began, with that query's results, which the model keeps aside
  while the learner deletes. Typing forward, or an open, forgets it. Only a clear uses it: leaving
  the foreground mid-deletion reports what is in the field. No value of `finishSearch` changed, so
  nothing was staged for the privacy policy; `docs/feature_architecture.md` § Search says what a
  cleared search's `queryLength` now measures.
- **`SearchEngagement`** (`Conjuguer/Utils/SearchEngagement.swift`) is the shared piece: `isEngaged`
  (the linger restarts at each loss of focus), `isLingering` (in place of `searchFocusLostAt`),
  `push(fieldIsEmpty:)` (a later push replaces one waiting), `insert` (letters tapped while the
  search is dismissed wait together, then go in and refocus the field), and
  `focus(afterPopping:)`, the 500 ms pop wait, where a second request waits for the same end. Its
  wait for the dismissal is injected, so a test can make it slow. The Models tab's rows and
  collections now push through it too, which they did not before.
- **B24** is fixed by closing the tracker's field when the engagement lets go rather than at the
  loss of focus, and by holding the linger until a waiting letter lands.
- **D5.** `browseSearchable` and `SortPickerOrKeyRow` are in `Conjuguer/Views/BrowseSearchField.swift`.
  `BrowseSearch.swift` is deleted. The Verbs tab's grid and list now share one `verbRows` builder,
  a start on D4, which Phase 6 finishes for the rest.
- **Return in an empty field does nothing on the iPad.** The field sends no submit while empty, so
  `openForReturn`'s branch for the recents is unreachable there, as the old code's was. The review's
  second B6 scenario (Return on a recent) could not be tried; I kept the branch, since a Mac may
  differ, and the doc says so.
- **B3 reproduced first** on the old build (stashed), on the iPad simulator: ê in the empty Models
  field left it empty and the row gone. After the fix it gave "ê", être first, and typing went on.
- **Checked on the iPad simulator:** ↓↓ through the recents highlighted boire; a tap opened it;
  Back and Command-F showed boire first, still highlighted (B6); Escape showed the whole list,
  "6,326 verbs", nothing highlighted; é first in the empty Verbs field, then "crire", ↓↓, and
  Return opened décrire; finnissons and Return opened the guess, finir; back from it, the picker
  showed disabled with "finnissons" in the field (K-S8); a query of two spaces in Models kept the
  collections (B23); a model row tapped from the focused blank field pushed. **On the iPhone:** a
  cold `search?q=finnissons` link showed the empty state with finir's guess and a greyed picker;
  the clear button showed the recents; xyzzyq typed fast showed the empty state and the mail line.
  The trombone could not be heard; `theTromboneSoundsOncePerFailedSearch` pins it.
- **Tests.** `VerbSearchModelTests` (28) and `SearchEngagementTests` (9). Both test types are
  new, so there was no old code to run them against. `aSecondLossOfFocusLingersAFullMoment` and
  `aSecondRequestDuringAPopWaitsForTheSameEnd` each pin a cancellation the old view lacked, and
  `theSelectionFollowsItsVerbWhenTheRowsMove` pins what a row index got wrong. 998 tests
  in 94 suites (961 plus 37). SwiftLint is clean on the changed files, and `check_docs.py` passes.
  No string changed.
- **Docs.** `docs/feature_architecture.md` § Search (the file table, the key row, no result, the
  guess, the keyboard, a search's report, where a search began, recents), `docs/voiceover.md`'s
  browse row, and `docs/project_structure.md`.

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

- **B9 is real, in both places.** On the iPad simulator, with one starred verb, no recents, and
  the empty field focused, a tap on the My Verbs row showed no page, and UIKit logged "…while an
  existing transition or presentation is occurring; the navigation stack will not be updated."
  That tap still recorded an open (`openCount` 1) of a page never shown. A revealed review card
  tapped the same way dropped its push with the same message. Both now push through the view's one
  `push`, which goes through `SearchEngagement.push`. After the fix, the My Verbs tap opened boire,
  and the card's tap opened aller in three of four tries within three seconds, with no dropped
  push logged. In one try the field stayed focused and the page arrived about ten seconds later; I
  could not make it happen again. No unit test can see a dropped push, so B9's test is the
  simulator's.
- **`VerbListContent`**, not `ListContent`, since the name stands alone in `Models/`. It is built
  from five facts (searching, failed, engaged, any recents, the mode) and says whether the card
  shows. `VerbBrowseView` computes it once per body and switches on it for the list, the rows, the
  heading, and the recents that Return and the arrows reach.
- **The card's rules are `ReviewCardModel`'s** (`Models/ReviewCardModel.swift`): the choice once per
  opening and again after the background, one signal per offer, one reveal, the snooze, and the
  stale offer. **`ReviewCardHost`** (`Views/ReviewCardHost.swift`) wraps the list in a `VStack` with
  the card above it, makes the model from the environment's `World` on its first appearance, and
  forwards the scene phase, the setting, and the record's changes. Wrapping the list, rather than
  sitting beside it, keeps the host on screen when no card shows, so its `onChange`s always run. The
  card's position on the iPad was the same to the point before and after.
- **The stale offer.** `PracticeStore.holds(_:at:)` asks whether each of the offer's items is still
  due. An unrevealed card that fails it is dropped when the record changes, when it appears, and
  before a reveal. A revealed card stays, since its own reveal rescheduled its items. An open from
  the card itself records a lookup that does not reschedule, so the card survives it.
- **A small change to Suppress Review Card.** Turning it On now drops the card rather than hiding
  it, so turning it Off again chooses afresh, where before a card kept under the setting came back
  as it was, revealed or not. The doc's sentence ("hides any card at once … turning it Off chooses
  one at once") was already true of the new behavior.
- **D4.** The Verbs tab's grid and list share one `ScrollViewReader` and scroll handler. The Models
  tab's two branches share `modelButton`, and its overlay and hidden scroll background are applied
  once. `VerbCollectionView` was the review's example of the split and is unchanged.
- **Taken early from Phase 10.** `VerbListMode` moved to its own file, which Phase 10 asked for.
  `BrowseRow(verb:detail:)` is a start on D1: the Verbs tab, My Verbs, and the failed search's guess
  use it, and `VerbCollectionView` and `RelatedVerbsView` are left for Phase 10.
- **Tests.** `ReviewCardModelTests` (10) and `VerbListContentTests` (2, one parameterized over seven
  rows). `LearnerVerbsTests`' list-mode test now pins the new cases. With the stale check turned
  off, two of the card tests recorded three issues. 1,010 tests in 96 suites (998 plus 12).
  SwiftLint is clean on the changed files, and `check_docs.py` passes. No string, signal, or
  parameter changed.
- **On the iPhone simulator:** the card revealed, opened extraire, kept its revealed state after
  Back, and was dismissed; Suppress Review Card On hid it, and Off offered a card again; in My
  Verbs a recent verb's swipe deleted it, a starred verb's swipe raised the alert and Cancel kept
  it, Clear left only the star, and the starred row opened its page. Both simulators' records were
  put back from copies taken first.
- **Docs.** `docs/feature_architecture.md` (the file table, the learner's verbs' table and its
  sentence on pushes, the review card's paragraph and table) and `docs/project_structure.md`.

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

- **Tests first.** The new and changed tests ran against the old code before any fix and recorded
  114 issues across `VerbSearchConjugationTests`, `VerbSearchTests`, `VerbLookupTests`, and
  `VerbSearchModelTests`; every finding of the phase had at least one. To compile them, the old
  `ConjugationQuery` briefly carried an `isStillBeingTyped` that only restated `isOnlyPronouns`.
- **One stripper (G3, S10).** `VerbSearch.frenchQuery` is now `ConjugationQuery`'s words joined,
  with the bare "s'" still searching as s. So the infinitive side drops subjects, que, y, en,
  reflexives, and negation too. A side effect worth knowing: "je me" searches as "me" and lists
  mener and mettre, and "il y a" lists the a- verbs under avoir, exactly as "me" and "a" typed
  alone do. Before, both found nothing on the infinitive side.
- **G1.** ce, c', ça, cela, and also **ca** (ça without its cedilla, which a learner without a
  French keyboard types) are subjects, and ce follows a hyphen. "cela suffit", "qu'est-ce", and
  "c'était" are pinned beside the plan's four.
- **G2** reads an auxiliary through `ConjugationQuery.verbPart(ofHyphenated:)`, so "a-t-elle fini"
  works as well as "as-tu mangé" and "est-il allé". The row names the auxiliary without its
  pronoun ("as mangé : Passé Composé (tu)"), which `MarkedConjugations` reads back.
- **B13 and B14** are one property, `ConjugationQuery.isStillBeingTyped`, which replaced
  `isOnlyPronouns`: only pronouns, or a last word that ends in a hyphen or in the start of a
  pronoun after one. `VerbSearch.guess` returns nil for it (so Look Up a Verb gives "nous" no
  guess either), and `VerbSearchModel` neither sounds the trombone nor starts a guess task. I
  considered searching "dis-" as dis, so that dire would show while the learner types. I left it
  out, because "entre-t" would then rank entrer ahead of entre-tuer. The empty state still shows
  for "dis-m", without a guess.
- **B22.** A hyphenated word's pronouns go back onto the verb's own spelling, so the confirmation
  is "débrouille-toi" rather than the typed "debrouille-toi". The whole-word lookup had failed
  because the folded spelling never reached the confirmation.
- **B7 and T4.** A pronominal compound with nous or vous writes the pronoun twice.
  `testARowsTextReadsBackAsTheSameCells` runs every sentence row (28 of them) back through
  `MarkedConjugations(text:on:)`. On the old code it failed for nous and vous, and for every query
  the old code could not find.
- **B30.** Literal answers are `[.exactInfinitive, .conjugation]` and the folded ones
  `[.exactFoldedInfinitive, .foldedConjugation]`. Pinned with pêcher, pécher, and two 1990 pairs,
  brûler/bruler and coûter/couter, and pecher still names both.
- **B21: told apart, not merged.** Every Look Up answer names a doubled infinitive with its extra
  letters ("haïr (France)", "haïr (Québec)"), the way the rest of the app names them.
- **B25.** `MatchedConjugation.line` puts U+202F before its colon. An infinitive's Look Up answer
  ("aller, “go”: va · est allé · ira") also typeset its colon in Swift, and its French heading uses
  guillemets, so the colon moved into the catalog as `Lookup.keyConjugations`, with U+202F in
  French. That is the one new string.
- **`VerbSearchKeys`** (`Conjuguer/Models/VerbSearchKeys.swift`) holds the lowercased and folded
  infinitive, its bytes for the guess, the lowercased gloss, and its meanings. `Verb.init` builds it,
  so a test's made-up verb carries its own keys and `keysCache` went. `fold` and `meanings(of:)`
  moved there from `VerbSearch`, because `Verb.swift` compiles into `ConjugationMapTool`. The
  tool's membership list grew to 25 files, and `CLAUDE.md` and `docs/feature_architecture.md` say
  so.
- **Normalization (S10).** `AnswerSpelling.normalized`, `ConjugationMatch`'s normalization, and
  `FormsJSON` call `ConjugationMap.key`. The subject pronouns stay listed in both
  `ConjugationQuery` and `AnswerSpelling`: grading accepts a person's own pronouns, and search
  drops ce and ça, which grading must not accept.
- **S9's search items.** `MatchKind` lost `Comparable` and its raw values, and its comment says
  `tier` alone ranks. `ModelSearch.seenVerbs` is `modelsFoundByAVerb`.
- **The tool's output.** `scripts/write_forms_json.sh` was run from a worktree at `HEAD` and from
  the working tree, each into the scratchpad. All three dumps came out byte-identical. The dumps
  in `corpus/working` are gitignored and dated 2026-11-22, and they already differed from `HEAD`'s
  output, so they were left alone rather than compared.
- **Checks.** 1,019 tests in 96 suites (1,010 plus 9), `ConjugationMapTests`' comparison with a
  fresh build included. SwiftLint is clean on the changed files, and `check_docs.py` passes. No
  signal or parameter changed. On the iPhone simulator, search links for c'est, "as-tu mangé",
  "nous nous sommes levés", "y aller", and dis-m showed être, manger, lever, aller, and the empty
  state without a guess. `verb/lever?match=nous nous sommes levés` opened lever with "avons levé"
  marked. On the iPad, "as-tu mangé" showed manger's card with the narrow space. The links recorded
  opens of lever on the iPhone simulator.

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

**How it differed:** In B19's mechanism and in two rules of the progress decision, each for a
reason the code gave, as in Konjugieren's Phase 3. No question for Josh came up. 1,035 tests in
96 suites (1,019 plus 16).

- **B19 is fixed with state, not a stable order.** The plan's own test fails against a stable
  order indexed by turn: when the list grows, `turn % count` lands anywhere, and the verb just
  shown can come again while the new one waits. No function of the day and today's list can know
  what earlier days showed. A My Verbs day now takes the verb whose last My Verbs day is longest
  ago (one never given first, the key breaking a tie). Those days travel in the snapshot file,
  which became `WidgetSnapshotBundle` (the snapshots and `myVerbsLastShown`). The widget's reader
  and the writer both still read the bare list of snapshots older builds wrote, so an upgrade
  neither blanks the widget nor changes the verb already shown. A rewrite keeps the days before
  today and plans the rest again. The bundle encodes with sorted keys: a dictionary in the file
  would otherwise encode in hash order, and the writer's "same bytes, no reload" check would fail
  at every activation.
- **An entry with a last open but no first open does not count as opened.** The plan asked for
  the opposite, as a guard for old records, but Reset Practice keeping Recent makes that shape
  meaningful: it is what the reset leaves for a recent verb, and counting it would undo the reset.
  No old entry has that shape. `recordOpen` has set both dates since the record began in
  `2829650`, and every other write cleared both, so `hasOpened` reads `firstOpened` alone. A test
  decodes a full entry from the earlier build and counts it opened.
- **Clear and the swipe keep `openCount`** with `firstOpened`, where the plan said they forget
  it, since both describe the verb's whole history and Konjugieren's record does the same. Reset
  Practice zeroes it. Nothing reads it yet.
- **Reset Practice moved into `World`.** `World.resetPractice()` and `World.hasPracticeToReset`
  replace the four calls and the condition in `SettingsView`, so a test reaches them. The button
  shows while any verb counts as opened; a star alone does not show it.
- **The migration took more with it:** `PracticeRecord.adopt`, which only it called, and the
  `migrateIfNeeded()` calls in `ConjuguerApp` and `World.rescheduleReminders`. The test that a
  reset "does not migrate again" became `aResetSurvivesARelaunch`. The `verify-in-simulator`
  skill's way of seeding a review card through an old `learnerVerbs` entry went too.
- **More false widget claims than the plan named.** `PracticeRecord.swift` and `World`'s comment
  on the shared defaults also said the widget reads a record. Both now say it does not.
- **S12 has no test that fails without it,** since it changes cost, not behavior.
  `theStoresListsFollowEachChange` pins that the cached lists follow every change.
- **The privacy paragraph had drifted.** The practice record's staged section had rewritten the
  paragraph about the list without the collections that the Collections section had added. A new
  section restores them and says where the full forget lives, in both languages, with Konjugieren's
  wording.
- **Tests.** Every behavior test was run against the old logic, put back temporarily: 13 failed,
  among them the growth and reorder tests and the B16 test. The writer's tests run through a
  temporary file. On the Conjuguer iPhone 17 the top 100 read 12 of 100, stayed 12 after parler
  was swiped out of My Verbs and after Clear, and read 0 after Reset Practice, with être still
  starred and the button hidden for having nothing left to erase. The iPad showed the new
  description and alert. The iPhone's record was restored afterward.

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

**How it differed:** In S4's suspicion, which did not reproduce, and in a few choices the phase left
open. No question for Josh came up. 1,049 tests in 98 suites (1,035 plus 14).

- **S4's suspicion is not real.** On the iPhone simulator, faire's page pushed in the Verbs tab and
  avoir's pushed from the top 100 in the Models tab each followed a change of pronoun gender in both
  blocks, on the return and after a tap on the star: each tab's stack built its pages afresh, so
  the simple block's stored cells were replaced too. The cost was real, and the fix went in as
  planned. `VerbConjugations` holds the compound cards beside the simple ones, cached by verb and
  gender, so `Settings` no longer clears the cache, and the page reads it from `body`. The star is
  `VerbStarButton`, a view of its own.
- **Measured** with a temporary log line in `body` and one where the cards are conjugated. A push
  of faire from the Verbs tab built the page 3 times before and 2 after. prendre's page in a link's
  sheet over it, 5 and 4, and faire's page beneath was rebuilt once before and not after. apprendre
  pushed from prendre's related chips, 2 and 1, with each page beneath rebuilt once before, and
  after only prendre's. The compound cards were conjugated on every pass before and once per page
  after. Recorded under S4 in the review.
- **S4a's tracker returns its effects**, as the plan asked, where Konjugieren's performs them:
  `VerbVisitTracker`'s events return `.signal(name, parameters:)` and `.recordOpen(source:)`, and
  `VerbView.perform` sends and records them. It is a class held in `@State`, since the page draws
  nothing from it, and it reconciles three conditions on each event, as Konjugieren's does. The
  pairing test sends every order of five of seven events (16,807 orders). With the sheet ignored,
  three of its tests failed. The pairing test still passed then, since ignoring an event breaks no
  pairing. With the old elision rule put back, the three B12 tests failed.
- **The personless card reports `simple`.** "Every card of a block" left it out, since it belongs
  to neither block, but a search for "allé" lands on it, and it was B27's bounce in another place.
  It closes the simple block, so it reports that.
- **`related` retires the scroll tip**, as the etymology and the examples do, since it lies below
  them. Staged in a new dated section of `docs/privacy_policy_pending.md`, which replaces the
  lookup signals' second bullet in both languages.
- **The color key now obeys `TipDisplay.tipsEnabled`.** The doc already said it did. It is a hint
  that goes once dismissed, like the tip, and a run for screenshots should show the page a
  returning learner sees. `KillSwitches.swift` says so.
- **B12.** Name the Conjugation calls `elides` only for a pronominal verb's reflexive pronoun, and
  no pronominal verb starts with a ligature, so nothing there changes. The quiz's frame gives
  "j'" (a new row in `AnswerFrameTests`). œuvrer's key conjugations carry no pronoun, so the test
  pins them as they are: œuvre, A œuvré (avoir's red letter), œuvrera.
- **S5.** `Etymology.texts(in:)` reads one language afresh and keeps nothing, and
  `VerbBase.base(of:etymology:)` is the rule without its cache. The test passes today.
- **S6** went no further than the plan: `Tense.table` and `TenseTable.tenses` stay as two
  exhaustive switches, which `testEveryCellBelongsToTheTableThatListsIt` checks against each other.
  `Tense.article` reads `Info.withStableKey`, which `Info.info(deeplinkTarget:)` now uses too.
- **The cells take the gender as a parameter.** `conjugationParts`, `cell`, and `sections` take the
  learner's setting, which an impersonal verb overrides inside, rather than reading `Current`.
- **D8** is `Verb.keyConjugationsByStem()`, which gives each stem with its bare form.
- **B29's titles** needed two catalog keys, `VerbView.builtOnLabel` and `VerbView.sameModelLabel`,
  which replaces `VerbView.sameModel`. `builtOn(_:)` stays as the related list's title. Not heard
  with VoiceOver; the tree shows "Built on " and "prendre" as two elements.
- **D9 fixed a typo on the way.** The model page's hint read "infomation" in English.
- **Seen in the simulator, iPhone:** œuvrer's cells read j'œuvre, j'œuvrais, j'œuvrai; "sois" from
  a search link, then Back at once, sent `leaveVerbView` with `simple`; Test Me from apprendre's
  sheet ended the visit (deepest `related`) and Quit resumed it; an article's diamond on aller's
  page ended the visit and Done resumed it, the page still there; the star filled on apprendre,
  three deep from prendre through comprendre. **iPad:** apprendre's Related Verbs card and
  œuvrer's cells. Both records were restored afterward, and a relaunch left the iPhone's byte for
  byte.

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
No question for Josh came up. 1,057 tests in 99 suites (1,049 plus 8).

- **The comparators live on the types.** `Verb.byFrequency` and `Verb.alphabetically` are in
  `Verb.swift`, and `VerbModel.alphabetically` and `byIrregularity` in `VerbModel.swift`, so the
  tool could use them; `VerbSort.areInIncreasingOrder` picks the verb comparator for a sort. The
  frequency tie-break is the id everywhere. `FrequencyBand` and `VerbCollection` used the
  dictionary key, which orders the four doubled infinitives the same way, so no list moved. The
  verb list's store, the search model's default, and Spotlight's suggestions read
  `Verb.verbsByFrequency` rather than sorting again.
- **"A model's verbs by frequency" is `VerbModel.entriesByFrequency`**, cached per model, in a new
  `VerbModel+Verbs.swift` beside the model page's links, which moved there from
  `ConjugationLabels.swift` (they reach neither `Current` nor `L`, the reason that file exists).
  The model's collection, the Related Verbs card's model row, and `ModelPractice` all read it.
- **The links' cache** holds one `AttributedString` per model and order. Not measured: the review's
  cost was traced, and a cached value cannot cost more than the sort and parse it replaces.
- **D2's page is `VerbListPage`**, generic over a header. `RelatedVerbListView` stays as a thin type
  in its own file, since its name is the `viewName` its `viewAppeared` sends, which the pending
  privacy text names. The page sorts its verbs by the picker's order on each pass, so it needs no
  input order. The related list gains the iPad grid; in a sheet the width is compact, so both pages
  show a list there, as the collection's did.
- **S8's identifiers**: `verb_row_`, `related_`, `collection_verb_`, and `related_list_verb_` take
  the dictionary key, and `model_row_` the model's id. The two sort pickers are
  `collection_sort` and `related_list_sort`, one rule from the page's prefix, so
  `collection_sort_order` became `collection_sort`. `model_row_être` became `model_row_5-26` in
  `scripts/take_screenshots.sh` and the screenshot playbook. Search's `best` is keyed by
  dictionary key too, the other half of S8.
- **B25's participe passé label** is "Participe Passé:" in English and "Participe Passé :" in
  French, following the decision's "Parent:"/"Parent :" for both labels, though the label's text is
  French in both languages, as the search row's line is. Josh may prefer the narrow space in both.
  The stem alterations' "r1p:" rows are the irregularity notation and keep their colon.
- **D6.** `ShareButton` serves the collection's bar and the challenge's Share Result. The custom
  quiz's Share is a `Menu` and the hub's challenge row a `QuizHubRow`, so they keep their own
  `onGeometryChange`; the zero check moved into `ShareSheet.present`, so none of the four checks.
- **`FlowLayout`** took Konjugieren's version, which proposes the row's width to each child, and
  kept Conjuguer's vertical centering, which the quiz's sentences need. No unit test: a `Layout`'s
  subviews cannot be built in a test. Name the Conjugation's chips looked as before.
- **Fails without the fix**: with the tie-break removed, the alphabetical case of the doubled-entry
  test and the shuffled-list test failed; with the links naming the key, the haïr link test failed;
  with `verb_row_` naming the infinitive, the identifier test failed.
- **Seen in the simulator, iPhone:** the top 100's page in both orders, its rows
  `collection_verb_<key>`; haïr's 2-3A page listing "haïr (France)", whose link pushed haïr's page;
  the "All" chip of mettre's built-on row in both orders; 2-3B's page in French reading
  "Parent : finir (2-1)" and "Participe Passé : ï"; search "hair" giving `verb_row_haïr France` and
  `verb_row_haïr Québec`;
  the Models tab's `model_row_<id>`; Name the Conjugation's chips. **iPad:** Verbs Taking Être pushed
  in the Models tab, three columns, and the share popover pointing at the bar's button.

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

- **The draw, decided.** A My Verbs quiz does not prefer the band: the learner chose those verbs,
  and so does a shared list a practice set carries. A custom quiz or a practice set over a
  collection does, since it asks the same verbs as the collection's own quiz
  (`QuizScope.prefersBandVerbs`). "The band runs out" is read by verb, not by cell: the deck puts
  the collection's band verbs first, so a round takes each once before any rare verb, and Ten
  More reaches the rare verbs once the band's verbs have all been asked. Reading it by cell would
  ask a band verb its seventh présent before any rare verb was asked.
- **The deck also puts verbs the session has not asked before those it has,** for every list,
  My Verbs included, so that Ten More moves on to new verbs, not only new cells. The plan did not
  ask for it. It follows from carrying `asked`, and it is what B5's "Ten More forgets the first
  ten" was about.
- **The three-cell floor applies to lists in a custom quiz and a practice set too.** The plan named
  only the collection bar's Quiz button and Start for My Verbs. Josh, asked on 2026-11-27 whether
  a custom quiz or practice set over a list should need three cells (falloir's model with the
  présent chosen asked a round of one), answered yes. `CustomQuiz.canBeAsked(at:myVerbs:)` counts
  cells of the chosen tenses, and a new line, `CustomQuiz.tooFewCells` ("These verbs have fewer
  than three conjugations in the tenses chosen."), tells too few from none under the custom quiz's
  summary and on a practice set's sheet.
- **A new string,** `QuizView.myVerbsTooFewCells`, under the picker when My Verbs has fewer than
  three cells at the level ("At this level, these verbs have fewer than three conjugations to ask.
  Add a verb, or choose another level."). Before, Start was enabled and the quiz asked "il faut"
  ten times. The Quiz button's hint names the round's length, ten or fewer.
- **S7's shape.** The stored flags and optional fields (`title`, `collection`, `custom`, `level`,
  `isPracticeSet`, `recordSession`, `isVerbEssentials`, `modelPractice`, `isRecognition`,
  `isSentences`, `isSpeedRound`, `isDaily`, `challenge`) became one `kind`. Those still read are
  computed from it, so most callers did not change. `title` and `level` come from the kind: a
  practice set carries its level and a challenge its key. A model's practice carries whether it
  is asked as Verb Essentials. `collection` now means only a collection's own quiz; the model a
  practice names for analytics is `namedCollection`, which `quizStart` already read.
  `LastQuizResult.Kind(scope:)` and `Quiz`'s draw are switches. `showsVerbLink` is new and
  `QuizView` reads it.
- **A test built a scope that can no longer exist,** the default quiz with a practice set's level
  (`QuizPracticeTests`), to show that such a scope mixes in no due items. It now builds a real
  practice set over the top 100.
- **Tests.** Eight new test functions in `QuizScopeTests`: Ten More through 10, 10, and 7 with no
  repeated cell; aller's model through every cell at Beginner and Elementary; the three-cell
  floor (falloir's 4-5C at Beginner, apparoir's 4-1D, férir's 2-4 from Elementary, ester's 1-10, a
  My Verbs of falloir alone); a model's quiz takes its band first (parler's and venir's at three
  levels); and four over every scope the app can start, which pin which is ranked, which starts a
  Live Activity, which prefers its band, and which hides the verb link. `CustomQuizTests` gained
  `aListNeedsThreeCells`. `aCollectionWithNothingToAskHidesItsQuiz` was folded into the floor's
  test. The suite: 1,065 tests in 99 suites, all passing.
- **Seen in the simulator** at Beginner, on the iPhone and the iPad: falloir's model page has no
  Quiz button, and aller's has one whose quiz reads "1 / 9". The levels were put back to
  Intermediate. On the iPhone, a practice set of falloir's model with the présent shows the
  too-few line, and with the impératif the none line. Not seen there: the My Verbs note, Ten
  More's sweep, and the band draw, which the tests cover.

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
