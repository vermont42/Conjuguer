# Feature Architecture

How Conjuguer's feature systems work, one section each. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md) (the
**browse plan**), modeled on Konjugieren's document of the same name. It starts by describing what
the app does today, briefly, and the phases of the browse plan and of
[`plans/pedagogy_implementation.md`](../plans/pedagogy_implementation.md) extend it as they build.
Keep it true: a section that describes code that has since changed misleads the next session more
than a missing section would.

## Search

The Verbs and Models tabs each show a list with a search field and a sort picker.

### Architecture

| File | Purpose |
|------|---------|
| `VerbBrowseView.swift` | The Verbs tab: the list (a `List` on iPhone, a `LazyVGrid` of cards on iPad), the sort picker, the search field, and the verb count. `VerbBrowse.makeStore` builds the store |
| `ModelBrowseView.swift` | The Models tab, built the same way. `ModelBrowse.makeStore` builds the store |
| `BrowseStore.swift` | A generic `@Observable` store that holds a list presorted for each sort order and persists the chosen order through a closure |
| `BrowseSearch.swift` | `BrowseSearch.results(in:query:playSoundIfEmpty:matches:)`: filters a list by a predicate that each tab supplies, and plays a sad trombone when a query finds nothing |
| `BrowseRow.swift` | The row both tabs show: a French title, an English subtitle, and a badge |
| `VerbSort.swift`, `ModelSort.swift` | The sort orders: Frequency (the default) and Alphabetical for verbs; Irregularity, Alphabetical, and Identifier for models. `Settings` stores the choice |

### Matching

- **Verbs** match when `infinitifWithPossibleExtraLetters` contains the query by
  `localizedStandardContains`, which ignores case and accents. Neither the English gloss
  (`translation`) nor conjugations are searched. A pronominal-only verb is stored without "se", so
  "se souvenir" finds nothing, and the fold does not turn œ into oe, so "manoeuvrer" finds nothing.
- **Models** match on `exemplarWithPossibleExtraLetters` the same way. A verb's infinitive does not
  find its model.
- **Order.** Results keep the list's order, so under Alphabetical the exact infinitive can be far
  down (venir is 19th of 19, after advenir). Nothing ranks an exact match first.
- **No result.** The list shows `ContentUnavailableView.search`, and `BrowseSearch` plays
  `Sound.randomSadTrombone`. It plays when the text changes, not when the sort order changes.

The table in the browse plan's **Conjuguer Today** section lists what typical queries return
today and what Phases 1 and 5 make them return.

### Opening a Verb

A tap in the Verbs tab pushes `VerbView` through `navigationDestination(item: $selectedVerb)`. A
deeplink instead sets `Current.verb`, which the Verbs tab presents as a sheet (see
[Deeplinks](#deeplinks)). A model page presents a verb as a sheet of its own (`ModelView`'s
`detailSheet`), and so does the Info tab for a verb link in an article.

## Analytics

Empty until Phase 3 of the browse plan writes it: the lookup signals, the vocabulary of `source`
and `matchKind` values, and the convention later phases follow.

Two facts hold already. Every signal is named in `AnalyticsName` and every parameter key in
`ParameterKey` (`Analytics/Analytics.swift`), and every screen reports itself with one signal,
`viewAppeared`, whose `viewName` parameter is the view's type name (`.recordsAppearance(as:)` in
`Modifiers.swift`). And **no signal may carry a verb or any typed text**, because the privacy
policy says the app "does not record your quiz answers, the verbs you look up, or any text you
type". New signals and parameters wait for the release in
[`privacy_policy_pending.md`](privacy_policy_pending.md).

## Deeplinks

The app opens `conjuguer://` links from the widgets, the Control Center controls, Info articles,
and model pages. There is no web domain, so there are no universal links.

### Grammar Today

```
conjuguer://<host>/<target>
```

A link must have exactly one path segment after the host (`URL.hasExpectedNumberOfDeeplinkComponents`
counts two path components, "/" and the target), or it is ignored. Query items are not read.

| Host | Target | Opens |
|---|---|---|
| `verb` | A verb's `dictionaryKey`, percent-encoded (`aller`; `ha%C3%AFr%20France` for one of a doubled infinitive's entries), or `random` | The verb page as a sheet over the Verbs tab. `random` draws from all 6,330 entries (`Verb.verbs.values.randomElement()`). An unknown verb opens the Verbs tab and nothing else |
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
`InfoView.handleInfoLink(_:)`, `WidgetDeeplink.verb(_:)`, `OpenQuizIntent`, and
`OpenRandomVerbIntent` each build their link from strings.

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
| `QuickQuizControl.swift`, `RandomVerbControl.swift` | Control Center controls. Their intents (`OpenQuizIntent`, `OpenRandomVerbIntent` in `Shared/`) store `conjuguer://quiz/start` or `conjuguer://verb/random` in the shared defaults and open the app, which drains it on activation |
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
