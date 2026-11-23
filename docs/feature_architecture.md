# Feature Architecture

How Conjuguer's feature systems work, one section each. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md) (the
**browse plan**), modeled on Konjugieren's document of the same name. It starts by describing what
the app does today, briefly, and the phases of the browse plan and of
[`plans/pedagogy_implementation.md`](../plans/pedagogy_implementation.md) extend it as they build.
Keep it true: a section that describes code that has since changed misleads the next session more
than a missing section would.

## Search

The Verbs and Models tabs each show a list with a search field and a sort picker. Since Phase 1 of
the browse plan (2026-11-22), one function, `VerbSearch.matches`, matches and ranks verbs for both,
and later callers (reverse lookup, Spotlight, the Look Up intent) are to use it too.

### Architecture

| File | Purpose |
|------|---------|
| `VerbBrowseView.swift` | The Verbs tab: the list (a `List` on iPhone, a `LazyVGrid` of cards on iPad), the sort picker, the search field, and the verb count. `VerbBrowse.makeStore` builds the store |
| `ModelBrowseView.swift` | The Models tab, built the same way. `ModelBrowse.makeStore` builds the store |
| `BrowseStore.swift` | A generic `@Observable` store that holds a list presorted for each sort order and persists the chosen order through a closure |
| `BrowseSearch.swift` | `BrowseSearch.results(in:query:playSoundIfEmpty:search:)`: every item for a blank query, otherwise what the tab's search closure returns, with a sad trombone when that is nothing |
| `VerbSearch.swift` | The matching and ranking rule. `MatchKind` names each kind of match, for Phase 3's `matchKind` |
| `ModelSearch.swift` | Finds a model by its exemplar or by any of its verbs, through `VerbSearch` without glosses |
| `FailedVerbSearchView.swift` | The verb list's empty state: `ContentUnavailableView.search`, the guess, and the line asking the learner to email a missing verb |
| `VerbSearchCommands.swift`, `VerbSearchArrowKeys.swift` | Command-F, and the arrow keys through results, on iPad and Mac |
| `FrenchLetterKeyRow.swift` | é è ê â î ô û ç keys, with an `insert` closure so the quiz's answer field can adopt it |
| `BrowseRow.swift` | The row both tabs show: a French title, a subtitle (English gloss, or the French verb that found a model), and a badge |
| `VerbSort.swift`, `ModelSort.swift` | The sort orders: Frequency (the default) and Alphabetical for verbs; Irregularity, Alphabetical, and Identifier for models. `Settings` stores the choice. Search ignores them |

### Matching

- **The query.** Trimmed and lowercased. For the French side, a leading "se " or "s'" (or "s’")
  is dropped, since pronominal verbs are stored without it; a bare "s'" searches as "s". For the
  English side, a leading "to " is dropped. Extra letters (haïr's "France", sortir's "exit") are
  not searched.
- **Folding.** `VerbSearch.fold` lowercases, turns œ into oe and æ into ae, and strips diacritics,
  so etre finds être and manoeuvrer finds manœuvrer.
- **Kinds and tiers.** `MatchKind`, best first: exact infinitive; exact after folding; then one tier
  holding an infinitive prefix, a whole English meaning (one comma-separated sense of the gloss,
  its parenthetical note dropped, so "can (food)" means "can"), and a folded prefix; then a whole
  word of the gloss; then an infinitive substring, literal or folded; then a gloss substring.
- **Order within a tier** is by frequency rank, whatever the sort order, so venir leads under
  Alphabetical and "go" puts aller (#6) ahead of gonfler. A folded match ranks below a literal one
  in the same tier only when the query carries an accent or ligature: pêch puts pêcher before
  pécher, but pre ranks préparer by its frequency among the bare pre- verbs. The two exact tiers
  are always apart, so typed mater leads mâter, and pecher shows pêcher and pécher by frequency.
- **Models.** Every model whose exemplar matches comes first, ranked as the exemplars rank, then
  every other model that has a matching verb, ranked by its best verb, which the row shows as its
  subtitle (devenir under venir). Glosses are not searched there.
- **Field.** Autocapitalization and autocorrection are off. The placeholders are "Infinitive or
  English meaning" and "Model or verb". While a field is focused, `FrenchLetterKeyRow` replaces the
  sort picker (on iPhone it then sits just above the keyboard), because a
  `ToolbarItemGroup(placement: .keyboard)` never appears for the navigation bar's search field on
  iOS 26.3, as Konjugieren found too. A key appends its letter.
- **No result.** `BrowseSearch` plays `Sound.randomSadTrombone` when the text changes, not when
  the sort order changes, and not for a query of only spaces. The Models tab shows
  `ContentUnavailableView.search`. The Verbs tab shows `FailedVerbSearchView` (since Phase 2): the
  same view, then a guess, then "If you believe that “…” is a French verb, please email
  vermontcoder@gmail.com", whose address is a `mailto:` link (`URL.mailto`) with the subject and
  body filled in with the query in the learner's language. A device that cannot open the link,
  such as the simulator, copies the address to the clipboard instead and says so for four seconds.
- **The guess.** `VerbSearch.closestVerb` folds the query as search does (reflexive pronoun
  dropped, accents and ligatures folded) and measures optimal string alignment distance
  (Levenshtein plus a swap of two adjacent letters) to every folded infinitive. A guess must be
  within one edit per three letters, and never more than three; ties go to the more frequent verb.
  So venier finds venir, assoir asseoir, manjer manger (ahead of manier, also one edit away), and
  xyzzyq nothing, in which case only the mail line shows. Glosses and conjugations are not
  considered.
- **Keyboard (iPad and Mac).** The search field is a bar under the title that stays put
  (`.navigationBarDrawer(displayMode: .always)`, `BrowseLayout.searchPlacement`) on both tabs,
  because iPadOS 26 shrinks `.automatic` search into a toolbar button that ignores `.searchFocused`.
  iPhone keeps `.automatic`. **Command-F** is a top-level menu command (Verbs › Find a Verb) that
  calls `World.openVerbSearch()`: it closes any deeplinked page, switches to the Verbs tab, and sets
  `verbSearchIsRequested`, which `VerbBrowseView` answers by popping any pushed verb page (waiting
  500 ms for the pop, or the focus does not take) and focusing the field, keeping its text.
  **↑ and ↓** move a highlight through the results in reading order (a red accent bar on a card, a
  red tint on a list row), stopping at either end; the first ↓ lands on the first result. They need
  `VerbSearchArrowKeys`, a `UIKeyCommand` on the window's root view controller installed only while
  the verb field is focused, because a focused text field consumes them ahead of every SwiftUI
  mechanism. **Return** opens the highlighted result, else the first, else the guess. Return and the
  arrows act only on the iPad idiom (which a Mac running the iPad app also reports) and only while
  the field holds a query, so the iPhone keyboard's Search key behaves as before.
- **Cost.** One search over 6,330 verbs takes about 20 ms on the Intel simulator. `VerbSearch`
  caches each verb's folded keys after the first search.

The table in the browse plan's **Conjuguer Today** section lists what typical queries returned
before Phase 1. Conjugations (suis, vais) are not searched until Phase 5.

### Opening a Verb

A tap in the Verbs tab pushes `VerbView` through `navigationDestination(item: $selectedVerb)`. A
deeplink instead sets `Current.verb`, which the Verbs tab presents as a sheet (see
[Deeplinks](#deeplinks)). A model page presents a verb as a sheet of its own (`ModelView`'s
`detailSheet`), and so does the Info tab for a verb link in an article.

## Conjugation Map

Since Phase 4 of the browse plan (2026-11-22), the app bundle carries every one-word conjugation
of every verb, mapped to the verbs it belongs to, so that search can start from a conjugation:
vais finds aller, and suis finds être and suivre. Phase 5 builds the search on it. Nothing in the
interface reads it yet.

### Architecture

| File | Purpose |
|------|---------|
| `ConjugationMapTool/main.swift` | A macOS command-line target. It parses the three XML files and writes the map, and, when asked, the corpus pipelines' dumps |
| `ConjugationMapTool/FormsJSON.swift` | The three dumps in `corpus/working` (`forms.json`, `forms_all.json`, `conjugations.json`), ported byte for byte from the retired `CorpusFormsDumpTests` harness. `scripts/write_forms_json.sh` runs them |
| `Conjuguer/Models/ConjugationMap.swift` | The map's rules, its text format, `build()`, and `ConjugationMap.bundled`. Compiled by the app and by the tool |
| `Conjuguer/Models/ConjugationMatch.swift` | `Verb.conjugations(matching:)`, app only |
| `Conjuguer/Models/ConjugationLabels.swift` | The core's display members, which reach `Current.settings` or `L` and so stay out of the tool |

**The tool compiles the app's own conjugation core**: 24 files of `Conjuguer/Models` and
`Conjuguer/Utils`, listed in a membership exception on the `Conjuguer` folder in
`project.pbxproj`. The core takes the pronoun gender explicitly; the app's overloads in
`ConjugationLabels.swift` default it to the setting. A core file that starts reaching `Current`,
`L`, or SwiftUI breaks the tool's build, and the member belongs in `ConjugationLabels.swift`.

**The build phase.** The app target depends on the tool, so an iOS build builds it for the Mac
first (host architecture only, no dSYM, `SKIP_INSTALL`). The app's "Generate Conjugation Map"
Run Script phase, after Resources, declares `verbs.xml`, `verbModels.xml`, `defectGroups.xml`,
and the tool's executable as inputs and writes `ConjugationMap.lzfse` straight into the bundle, so
nothing generated is committed. The executable stands for the Conjugator's sources, because Xcode
relinks it exactly when one of them changes. Measured on 2026-11-22: an unchanged rebuild skipped
the phase; touching `verbs.xml` ran it; a code edit to `ConjugationMap.swift` relinked the tool
and ran it; deleting the tool, so that it relinked to identical bytes, ran it too. Judge this by
the map's timestamp, not by the build log, and not by the tool's timestamp either: each switch
between a test run and a build re-signs the tool (its entitlements differ between the two), which
leaves the map alone, rightly, since a new signature cannot change the map.

### The map

- **What a verb contributes**: its infinitive; every simple tense and both participles, each
  `/`-separated alternate on its own (paie, paye); and the participe passé's agreed forms for
  every verb, since a text agrees an avoir verb's participle with a preceding object
  (`ConjugationMap.agreedForms(ofParticiple:)`: allée, allés, allées; dû gives due, dus, dues;
  pris gives prise and pris; dissous gives dissoute). Left out: the radical du futur, which no
  text writes; every cell the verb's defect group lacks; and the compound tenses, whose words the
  map already holds. Entries for avoir and être would otherwise attach to every verb.
- **Keys** are lowercase and NFC. **Values** are keys of `Verb.verbs`, so a doubled infinitive's
  entries stay apart: sors is "sortir exit" only, and sortir is both. Homographs keep every verb
  (suis, vis, tu, été).
- **The format** is one line per conjugation, `suis⇥suivre⇥être`, sorted by UTF-8 bytes,
  compressed with LZFSE: 242,923 conjugations, 5.0 MB of text, 615,637 bytes in the bundle, built in
  about 3.5 seconds by the Release tool. (Konjugieren's holds 50,056 conjugations in 173 KB.)
  `sorted()` is not used, because it left 155 keys out of order, and two builds of the same
  data wrote different bytes.
- **Loading** `ConjugationMap.bundled` took 1.2 seconds in a Debug build on this Intel Mac's
  simulator, so Phase 5 should touch it from a background task before the first search. It is a
  `nonisolated static let`.

### Matching cells

`Verb.conjugations(matching:)` returns every cell whose conjugation equals a text, in the page's
order (the three personless cells, then `VerbConjugations.simpleSpecs` and `compoundSpecs`), each
a `ConjugationMatch` of a `Tense` and an `isAgreement` flag. Case and spacing are ignored, and
accents are not: "etait" matches nothing, so search must fold before it calls. A compound cell
matches with its participle agreed either way (est allé, est allée). An impératif matches as the
quiz asks for it (souviens) and as a reflexive verb's page shows it (souviens-toi). The participe
passé also matches agreed, with `isAgreement` set. Defective cells and the infinitive never
match. The radical du futur is a cell and does match (ir for aller). It needs no map and costs
about 10 ms per verb in a Debug build, so compute it for a row only when the row is shown.

## Analytics

Every signal is named in `AnalyticsName`, every parameter key in `ParameterKey`, and every
parameter value in an enum or a band, all in `Analytics/Analytics.swift`. `AnalyticsReal` sends
through TelemetryDeck, and `AnalyticsSpy` records in the simulator and under unit tests. Every
screen reports itself with one signal, `viewAppeared`, whose `viewName` is the view's type name
(`.recordsAppearance(as:)` in `Modifiers.swift`); the verb page reports through its visit instead
(below). **No signal may carry a verb or any typed text**, because the privacy policy says the app
"does not record your quiz answers, the verbs you look up, or any text you type". Counts and
durations go out in bands (`AnalyticsBand`), never as exact numbers. New signals and parameters
wait for the release in [`privacy_policy_pending.md`](privacy_policy_pending.md).

### Lookup signals

Built in Phase 3 of the browse plan (2026-11-22), ported from Konjugieren's Phase 3. Names match
Konjugieren's where the signal is new, so the apps can be read side by side; the verb page's
arrival keeps Conjuguer's `viewAppeared`, so that TelemetryDeck's history of verb pages stays one
series.

| Signal | Parameters | Sent |
|---|---|---|
| `viewAppeared` with `viewName` `VerbView` | `source` (below) | When a verb visit begins: the page arrives, or returns with `source` `resume` after another tab, its own model sheet, or the background |
| `leaveVerbView` | `deepestSection` (`header`, `simple`, `compound`, `etymology`, `example`), `dwell` (`0-5s`, `5-15s`, `15-60s`, `60s+`) | Exactly once for each verb page's `viewAppeared`: when the page leaves the screen, its model sheet opens, or the app goes to the background |
| `finishSearch` | `outcome` (`opened`, `abandoned`, `noResult`), `queryLength` (`1-2`, `3-5`, `6-9`, `10+`), `resultCount` (`0`, `1`, `2-10`, `11+`), `matchKind` (below), `resultPosition` (`1`, `2-5`, `6+`, `none`) | Once per verb search: when a result or the guess is opened (by tap, Return, or the arrow keys), the field is cleared, or the app goes to the background with text in the field |

**A visit** (`VerbVisit`) is one stretch of a verb page on screen, uncovered by its own model
sheet, with the app in the foreground. It is the same whether the page was pushed (Verbs tab) or
presented as a sheet (a deeplink, an Info link, a model page). A page that returns starts a new
visit whose `source` is `resume`, so every verb page's `viewAppeared` pairs with one
`leaveVerbView`, background time never counts as reading, and arrivals are the visits whose source
is not `resume`. A resumed visit starts from the deepest section already on screen. Before Phase 3,
`viewAppeared` for `VerbView` fired on each `onAppear` and never on a return from the background;
it now also fires on that return, as `resume`. A sheet that something else presents over a page
(a deeplink's verb over a pushed page, say) does not end the page's visit.

**Reaching a section** means a third of its first card on screen (`onScrollVisibilityChange`,
threshold 0.3): the présent card for `simple`, the passé composé card for `compound`, then the
etymology and example cards. The compound block shows only when its toggle is on, and it is off by
default until Phase 6, so `compound` is rare: the toggle sits just above the etymology card, which
comes on screen with it.

**A search** (`SearchTracker`, `SearchReport`) begins with the first non-blank letter and ends
once. Returning to the results and opening another verb without editing the text sends no second
`finishSearch`, though the page still reports `search`. Editing the text after an open begins a new
search, so deleting the query letter by letter reports an abandoned search of its last letters. An
abandoned search's `matchKind` is that of the top result it passed over. Opening the guess reports
`opened`, `resultCount` `0`, `matchKind` `guess`, and position `1`. `resultCount` counts rows, so a
doubled infinitive (haïr) counts twice. The Models tab's search sends nothing.

**`matchKind`** is `VerbSearch.MatchKind`'s case by name, through an exhaustive switch
(`analyticsValue` in `SearchReport.swift`), so a new kind cannot go unnamed: `exactInfinitive`,
`exactFoldedInfinitive`, `infinitivePrefix`, `glossMeaning`, `foldedInfinitivePrefix`,
`wholeWordGloss`, `infinitiveSubstring`, `foldedInfinitiveSubstring`, `glossSubstring`; plus
`guess` and `none`. `conjugation` and `foldedConjugation` are reserved for Phase 5's reverse lookup,
which may add or rename kinds when it builds them; it must stage their privacy lines.

### The `source` vocabulary

`AnalyticsSource` is one vocabulary for the verb page's `viewAppeared` and, from Phase 11, the
quiz signals. Values are Konjugieren's names wherever the surface is the same.

| Value | Sent today? | Meaning |
|---|---|---|
| `browse` | Yes | A row of the verb list with the search field blank |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess at the verb meant, shown when a search finds nothing |
| `modelPage` | Yes | A verb in a model page's list, in the Models tab or in a sheet over a verb page |
| `infoLink` | Yes | A verb linked from an Info article (`?source=infoLink`) |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget (`WidgetDeeplink`, `?source=widget`) |
| `control` | Yes | The Random Verb control in Control Center (`OpenRandomVerbControlIntent`) |
| `shortcut` | Yes | Open Random Verb run from the Shortcuts app (`OpenRandomVerbIntent`); Phase 9's shortcuts too |
| `deeplink` | Yes | A `conjuguer://verb/` link with no `source` item, or one outside this vocabulary |
| `resume` | Yes | The same page appearing again (above) |
| `related` | Phase 7 | A related verb on a verb page |
| `spotlight`, `lookup`, `quickAction` | Phase 9 | A Spotlight result; Look Up a Verb; the Home Screen quick action. Phase 9 should also add `source` to `finishSearch`, as Konjugieren's Phase 11 did, for searches these surfaces open |
| `recent`, `myVerbs` | Phase 10 | A recent verb in the empty focused field; a verb in My Verbs. For the quiz signals (Phase 11), `myVerbs` is a quiz over My Verbs |
| `tab`, `verbPage` | Phase 11 | The quiz signals only: a quiz begun from the Quiz tab; Test Me on a verb page |
| `reviewCard` | Phase 13 | The review card, opened after its conjugations are revealed |
| `list` | Phase 14 | A verb on a collection's page; for the quiz signals, a collection's quiz |

**How the source travels.** The verb list pushes a `VerbDestination` (verb and source) rather than
a bare `Verb`; Phase 5 can add the matched cell to it. A link carries `source` as a query item
(`conjuguer://verb/aller?source=widget`), because a widget or an intent can hand the app only a
URL. `World.resolveDeeplinkEntity` stores it in `World.verbSource` (`AnalyticsSource.ofDeeplink`),
falling back to `deeplink`, and the sheets that present `World.verb` pass it to `VerbView`. A model
page passes `modelPage` itself. **Phase 9's grammar should keep this query item.**

**The convention for later phases.** A phase that adds a way to reach a verb page passes its value
in `VerbDestination`, in a link's `source` item, or directly to `VerbView`, marks it sent in the
table above, and stages its privacy line. Phases 8, 10, and 11 add `tapShareVerb`, `tapStarVerb`
(with `starred`, the state after the tap), and `tapTestVerb`. Phase 11 adds `source` to `quizStart`,
`quizQuit`, and `quizCompletion`.

## Deeplinks

The app opens `conjuguer://` links from the widgets, the Control Center controls, Info articles,
and model pages. There is no web domain, so there are no universal links.

### Grammar Today

```
conjuguer://<host>/<target>
```

A link must have exactly one path segment after the host (`URL.hasExpectedNumberOfDeeplinkComponents`
counts two path components, "/" and the target), or it is ignored. Query items do not count as
path components. The only one read is `source` on a `verb/` link, which names the surface that sent
it (§ Analytics); every other query item is ignored.

| Host | Target | Opens |
|---|---|---|
| `verb` | A verb's `dictionaryKey`, percent-encoded (`aller`; `ha%C3%AFr%20France` for one of a doubled infinitive's entries), or `random`; optionally `?source=` | The verb page as a sheet over the Verbs tab. `random` draws from all 6,330 entries (`Verb.verbs.values.randomElement()`). An unknown verb opens the Verbs tab and nothing else |
| `model` | A model's identifier (`1-1`) | The model page as a sheet over the Models tab |
| `info` | A position in `Info.infos` (`info/0`) | The article as a sheet over the Info tab. An out-of-range position does nothing |
| `quiz` | Anything (`OpenQuizIntent` sends `quiz/start`) | The Quiz tab, starting a quiz unless one is in progress |

Phase 9 of the browse plan replaces this section with one written grammar (text in query items,
`source` on every route, a `search` route, `info/` by stable key) and builders in place of the
literals listed below.

### Architecture

| File | Purpose |
|------|---------|
| `URLExtensions.swift` | The scheme, the hosts, `isDeeplink`, and `hasExpectedNumberOfDeeplinkComponents` |
| `World.swift` | `handleURL(_:)` clears `verb`, `verbModel`, and `info`, resolves the link (`resolveDeeplinkEntity(from:)`), and selects the tab. `handleInAppURL(_:)` resolves without clearing or switching tabs, for links inside Info articles |
| `ConjuguerApp.swift` | Receives links through `.onOpenURL`, and on each activation drains a link that a control's intent left in the shared defaults (`WidgetConstants.pendingDeeplinkKey`) |
| `VerbBrowseView.swift`, `ModelBrowseView.swift`, `InfoBrowseView.swift` | Present `Current.verb`, `Current.verbModel`, and `Current.info` as sheets |
| `ModelView.swift` | Intercepts its own `verb/` links (the verbs list) through an `OpenURLAction` and presents the verb as a sheet |
| `InfoView.swift` | Turns an article's links into `info/` or `verb/` links and hands them to `handleInAppURL(_:)` |

**The cold-launch race.** A widget's link can arrive through `.onOpenURL` before `VerbData` has
finished parsing, when `Verb.verbs` is still empty. `handleURL` then stores the link in
`pendingDeeplink`, and `ConjuguerApp` replays it with `drainPendingDeeplink()` once the data has
loaded. Any new entry point must go through `handleURL` so that it inherits this.

**Links written as literals.** `VerbModel.verbsWithDeepLinks()` (a model page's verbs list),
`InfoView.handleInfoLink(_:)`, `WidgetDeeplink.verb(_:)`, `OpenQuizIntent`, `OpenRandomVerbIntent`,
and `OpenRandomVerbControlIntent` each build their link from strings. Since Phase 3 the Info, widget,
and random-verb links carry a `source` item.

## Quiz

A timed quiz of thirty questions. The learner types each conjugation.

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` quiz state: building the questions, the timer, scoring, the Live Activity, Game Center, the quiz signals, and VoiceOver announcements |
| `QuizVerbs.swift` | The curated verb pools the questions draw from |
| `QuizDifficulty.swift` | Regular or Ridiculous, chosen in Settings, and each one's score multiplier |
| `QuizQuestion.swift`, `QuizResult.swift`, `QuizState.swift` | A question (verb and tense), an answered question, and the quiz's lifecycle |
| `ConjugationResult.swift` | Grades an answer as a total, partial, or no match |
| `CyclingDeck.swift` | Deals a pool's elements in order and reshuffles when it runs out |
| `QuizView.swift`, `QuizResultsView.swift`, `QuizResultView.swift` | The quiz screen and the results sheet |
| `LiveActivityManager.swift` | Starts, updates, and ends the quiz's Live Activity |

### The Two Difficulties

**Regular** asks thirty questions by fixed quotas, each verb dealt from a `CyclingDeck` over a
`QuizVerbs` pool and each person from a deck of the six (the impératif from its three):

| Tense | Questions | Pools |
|---|---:|---|
| Indicatif présent | 7 | regular -er (2), regular -ir (2), regular -re, the big three (être, avoir, aller), présent stem changers |
| Passé composé | 6 | regular -er, -ir, -re, the big three, être auxiliaries, irregular participes passés |
| Subjonctif présent | 4 | regular -er, -ir, -re, the big three |
| Imparfait | 3 | the top thirty |
| Futur simple | 3 | regular futur stems (2), irregular futur stems |
| Conditionnel présent | 3 | regular futur stems (2), irregular futur stems |
| Impératif | 3 | the top thirty |
| Participe présent | 1 | the top thirty |

**Ridiculous** asks thirty fixed pairs of verb and tense (réaliser, choir, bruire, moudre, and so
on), with the person drawn from the deck. Either way the questions are shuffled.

A debug launch argument, `-CONJUGUER_QUIZ_FIXTURE screenshot`, replaces both with a fixed plan for
App Store screenshots and exports its answers (see
[`screenshot_playbook.md`](screenshot_playbook.md)).

### Grading and Scoring

`ConjugationResult.score(correctAnswers:proposedAnswer:)` compares lowercased text against each
alternate the conjugator separates with `Tense.alternateConjugationSeparator` ("/"):

- **Total match** (10 points): equal, or equal once circumflexes (â ê î ô û) are removed from
  both, so a missing circumflex costs nothing.
- **Partial match** (5 points): equal once every diacritic is folded away, so "etait" for "était"
  earns half.
- **No match** (0 points).

Each question's points are multiplied by the difficulty's `scoreModifier` (1 for Regular, 2 for
Ridiculous). A finished quiz scoring at least 150 earns a time bonus, from 450 points for two
minutes or less down by 50 a minute to nothing past ten. The best score is stored in `Settings`,
and every completed quiz, at either difficulty, reports its score to Game Center's leaderboard.
Quitting reports nothing.

### Signals

`quizStart` (`difficulty`), `quizQuit` (`difficulty`, `lastQuestionIndex`, `elapsedTime`), and
`quizCompletion` (`difficulty`, `score`, `elapsedTime`).

## Widgets

The `ConjuguerWidget` extension holds two widgets, two Control Center controls, and the quiz's Live
Activity (`ConjuguerWidgetBundle`). It bundles only `Shared/` and `ConjuguerWidget/`, with no
conjugator and no verb data, so it shows what the app last wrote.

### Architecture

| File | Purpose |
|------|---------|
| `WidgetSnapshotWriter.swift` (app) | Writes seven daily `WidgetSnapshot`s, today first, to the App Group container, and reports whether the bytes changed so that `ConjuguerApp` reloads timelines only then |
| `WidgetSnapshot.swift` (`Shared/`) | The serialized verb and quiz question for one day |
| `WidgetConstants.swift` (`Shared/`) | The App Group, the snapshot file, and the shared-defaults keys (the quiz widget's answer, the pending deeplink) |
| `SnapshotReader.swift` | Reads the snapshots in the widget |
| `VerbDuJourWidget.swift` | The verb of the day: small, medium, large, and the rectangular and inline accessory families. One timeline entry per cached day |
| `QuizWidget.swift`, `AnswerQuizIntent.swift` | The daily quiz question, small and medium, with buttons that grade the tapped answer in place |
| `QuickQuizControl.swift`, `RandomVerbControl.swift` | Control Center controls. Their intents (`OpenQuizIntent`, `OpenRandomVerbControlIntent` in `Shared/`) store `conjuguer://quiz/start` or `conjuguer://verb/random?source=control` in the shared defaults and open the app, which drains it on activation |
| `QuizLiveActivity.swift` | The quiz's Lock Screen and Dynamic Island presentation |
| `WidgetDeeplink.swift` | The verb widget's link to the verb's page |

### Choosing the Verb

`WidgetSnapshotWriter.eligibleVerbs()` takes the verbs ranked 1,500 or better
(`verbOfTheDayRankLimit`) that have an example sentence, in rank order. Each day's verb is the one
at `(days since 2025-01-01 × 127) % count`. The quiz question uses the same verb, with a person and
one of six tenses (présent, passé composé, futur simple, imparfait, subjonctif présent,
conditionnel présent) chosen from the day number, and three wrong answers drawn from the verb's own
other conjugations before any filler. A change of the pronoun-gender setting rewrites the
snapshots. Phase 12 of the browse plan changes the draw.
