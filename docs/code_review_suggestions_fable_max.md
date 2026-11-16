# Conjuguer Code-Improvement Suggestions

Findings from a full read of the app and test targets (every Swift file in `Conjuguer/` and
`ConjuguerTests/`), focused on duplication, inelegant code, and code smells. Suggestions are
ordered from most impactful to least. File references use `path:line` against the current
working tree.

---

## 1. Likely bugs found along the way

These surfaced while hunting smells. Each is small, but they affect real behavior, so they
outrank any pure-style item.

### 1.1 The model-sort preference never survives a relaunch

`Settings` persists `modelSort` via string interpolation, but restores it via `rawValue`:

- Write (`Conjuguer/Utils/Settings.swift:29`): `getterSetter.set(key:, value: "\(modelSort)")`
  — interpolation of an enum yields the *case name*: `"alphabetical"`, `"identifier"`.
- Read (`Conjuguer/Utils/Settings.swift:100`): `ModelSort(rawValue: modelSortString)` — but
  `ModelSort`'s raw values are capitalized (`"Alphabetical"`, `"Identifier"`;
  `Conjuguer/Utils/ModelSort.swift:10-14`), so the lookup returns `nil` and falls back to
  `.irregularity`.

A user who picks Alphabetical or Identifier ordering in the Models tab gets Irregularity again
on every launch. `VerbSort` only escapes the same fate by luck (its implicit raw values equal
its case names). **Fix:** persist `modelSort.rawValue` (and `verbSort.rawValue` for
consistency); a regression test that round-trips every `Settings` property through a
`DictionaryGetterSetter` would have caught this and the inconsistency below.

### 1.2 Copy-paste error in `DefectGroup`: `h2p` marks the wrong impératif passé row

`Conjuguer/Models/DefectGroup.swift:63-65`:

```swift
case "h2p":
  defects[.impératif(.secondPlural)] = true
  defects[.impératifPassé(.firstPlural)] = true   // should be .secondPlural
```

The `h1p` case directly above sets `.impératifPassé(.firstPlural)`; `h2p` was copied without
updating the second line. Any defect group using `h2p` strikes through *nous* impératif passé
instead of *vous* in `VerbView`. (Section 2.4 proposes a refactor that makes this whole class
of error impossible.)

### 1.3 `ConjugationResult.score` leaks accent-stripping across alternate answers

`Conjuguer/Models/ConjugationResult.swift:15-41`: `proposedAnswerClean` is declared *outside*
the loop over alternate correct answers (`paye/paie`-style verbs) but is mutated *inside* it.
After iteration 1 strips circumflexes and graves/acutes from the proposed answer, iteration 2
performs its "exact match → `.totalMatch`" comparison against the already-stripped input. So
for a multi-stem verb, an answer with a wrong accent (e.g. `pàie` for `paie`) scores
`.totalMatch` instead of `.partialMatch`. **Fix:** reset the cleaned proposed answer at the
top of each loop iteration — or replace the three hand-rolled strip tables with
`folding(options: .diacriticInsensitive)` staged appropriately (see 3.4). This function has no
unit tests; it's the heart of quiz scoring and deserves a small table-driven test.

### 1.4 `sorted(by: >=)` violates `sorted`'s strict-weak-ordering contract

`Conjuguer/Views/ModelBrowseView.swift:123-125`:

```swift
irregularityModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
  lhs.irregularity >= rhs.irregularity
}
```

`sorted(by:)` requires a *strict* ordering; `>=` returns `true` for equal elements, which is
documented undefined behavior (the stdlib's debug sanity checks can even trap on it). Use `>`.
Equal-irregularity models currently land in dictionary-hash order anyway, so a secondary
tiebreaker (e.g. exemplar) would also make the list stable run-to-run.

### 1.5 `futurStemsRecursive` mutates the wrong stem and skips grandparent alterations

`Conjuguer/Models/VerbModel.swift:210-214`:

```swift
stems.forEach {
  if $0.last == "e" {
    stems[0] = String(stems[0].dropLast())   // always stems[0], even when $0 is stems[1]
  }
}
```

If only the *alternate* stem ends in `e`, the primary stem gets truncated; if both end in `e`,
the primary is truncated twice and the alternate never. Today's data apparently never produces
two `-e` stems (the golden tests pass), but the code is wrong as written; iterate indices
(`for i in stems.indices`) instead.

Also in the same function (`VerbModel.swift:188-193`): parent alterations are fetched with
`VerbModel.models[parentId]?.stemAlterations` — one level only — whereas every other consumer
walks the chain via `stemAlterationsRecursive`. A grandparent's inheritable `sf` (radical
futur) alteration is silently dropped. Reusing `stemAlterationsRecursive` here fixes the
inconsistency and deletes ten lines.

### 1.6 `ReviewPrompter` freezes `Date()` at construction

`Conjuguer/Utils/ReviewPrompter.swift:27-41`: the testability injection `now: Date = Date()`
captures the *launch* date in a struct that `World` constructs once and keeps forever. Every
`promptableActionHappened()` then compares the 180-day interval against launch time, and
records `lastReviewPromptDate = now` — i.e., the launch date, not the prompt date. Inject a
clock (`now: () -> Date = Date.init`) instead of a value.

Related smell: the same initializer defaults to `Settings(getterSetter: UserDefaultsGetterSetter())`,
creating a *second* live `Settings` instance alongside `Current.settings`. The two share
UserDefaults keys but not in-memory state. It's benign today only because nothing else reads
`promptActionCount`/`lastReviewPromptDate`; passing `Current.settings` (or having `World` wire
it) removes the trap.

### 1.7 Nondeterministic ordering in stem-alteration labels

`Tense.shorthandForNonCompoundTense` (`Conjuguer/Models/Tense.swift:204-238`) builds its
output by iterating a `Set<String>`, so ModelView's alteration rows can read `r1s, x3p` on one
launch and `x3p, r1s` on the next. Sort the shorthands (a tense-then-person order would read
best) before joining. While there: the six-element `hasAll` check is
`tup.0.allSatisfy(shorthands.contains)`, and the manual append loop is
`shorthands.sorted().joined(separator: ", ")`.

### 1.8 ModelView's endings grid ignores inherited alterations

`Conjuguer/Views/ModelView.swift:169-172` passes `model.stemAlterations` (local only) to
`endings(stemAlterations:)` / `impératifEndings(stemAlterations:)`, while conjugation itself
honors `stemAlterationsRecursive`. A child model that inherits its `*`-marked (irregular
ending) alterations from a parent shows ordinary endings in the grid where the conjugated
forms actually diverge. Pass `model.stemAlterationsRecursive`.

---

## 2. Major duplication

### 2.1 A ~140-line conjugation dump exists twice — and one copy is broken

`Conjugator.printConjugations` (`Conjuguer/Models/Conjugator.swift:256-409`) and
`InputView.conjugate` (`Conjuguer/Views/InputView.swift:130-270`) are near-identical: eleven
consecutive `for personNumber … switch result … fatalError` blocks each. Worse,
`printConjugations` is **never called** and ignores its `infinitif` parameter — line 257 hardcodes
`Verb.verbs["alunir"]` — so if it were ever called it would dump the wrong verb. (It also
carries the typo `conjugationFailedMesage`.)

**Suggestion:** delete `printConjugations` outright, and collapse `InputView.conjugate` into a
loop over `[(label, [Tense])]` specs — the same data-driven shape `VerbConjugations.simpleSpecs`
already models — reducing ~140 lines to ~25.

### 2.2 `Quiz`'s thirteen parallel array/index pairs

`Conjuguer/Models/Quiz.swift:29-54, 92-124, 209-311` hand-rolls the same "shuffled deck with a
wrapping cursor" thirteen times: thirteen `var xs` + `var xsIndex` pairs, eleven identical
cycling accessors, plus `resetIndices()` and `randomizePersonNumbersAndVerbs()` to maintain
them. A tiny generic type absorbs all of it:

```swift
struct CyclingDeck<Element> {
  private let items: [Element]
  private var index = 0
  init(_ items: [Element], shuffled: Bool) { self.items = shuffled ? items.shuffled() : items }
  mutating func next() -> Element { defer { index = (index + 1) % items.count }; return items[index] }
}
```

That converts ~200 lines into ~40, removes both maintenance methods, and eliminates the
current quirk where every accessor pre-increments and therefore starts each quiz at element 1,
never element 0. Bonus: the `subjonctifPrésentStemChangers` deck (lines 47-48, 102, 119,
281-287) is never used by `buildQuiz` — dead weight either way. The stored `gameCenter`
property (line 26) is also assigned but never read (`completeQuiz` uses `Current.gameCenter`);
either use the injected value or drop the parameter.

### 2.3 `Tense` re-matches all seventeen person-number cases five times

`pronounWithGender`, `pronoun`, `gender`, `pronounDecorator`, and `shortDisplayName`
(`Conjuguer/Models/Tense.swift:139-202`) each pattern-match the same seventeen
`case .x(let personNumber)` arms. One computed property collapses them:

```swift
var personNumber: PersonNumber? {
  switch self {
  case .participePassé, .participePrésent, .radicalFutur: return nil
  case .indicatifPrésent(let pn), .passéSimple(let pn), /* … all 17 … */: return pn
  }
}
```

Then `pronoun` is `personNumber?.pronoun ?? L.QuizView.none`, etc. Roughly 60 lines saved, and
the next tense added (or the next property needing a person number) touches one switch, not six.

### 2.4 The tense-shorthand language is parsed by hand in three places

The `"r1s"/"bA"/"pp"`-style codes are decoded by three independent switch statements:
`StemAlteration.init` (~100 cases, `Conjuguer/Models/StemAlteration.swift:43-151`) and
`DefectGroup.init`'s `doesntUse` and `usesOnly` branches
(`Conjuguer/Models/DefectGroup.swift:36-143`). `StemAlteration.swift:45` even carries a TODO
asking for exactly this refactor, and its target — `Tense.tensesFor(shorthand:)`
(`Tense.swift:240-244`) — exists as an unfinished stub that ignores its argument.

The grammar is regular: a tense letter (`r/b/x/i/q/h/f/c`), then a person-number short name
(`1s…3p`) or `A` for all. A single
`Tense.tenses(for shorthand: String) -> [Tense]` built from a `letter → (PersonNumber) -> Tense`
map plus `PersonNumber.personNumberForShortDisplayName` replaces all three switches (~250
lines → ~30), finishes the TODO, and removes the class of copy-paste defect behind bug 1.2.
`DefectGroup.setAllDefectsTo` (`DefectGroup.swift:161-185`) — a 100-plus-tense literal — then
becomes a loop over the same constructors, and `defects: [Tense: Bool]` simplifies to
`Set<Tense>`.

### 2.5 Four hand-rolled parent-chain walks in `VerbModel`

`participeEndingRecursive`, `passéSimpleGroupRecursive`, `indicatifPrésentGroupRecursive`, and
`subjonctifPrésentGroupRecursive` (`Conjuguer/Models/VerbModel.swift:136-174`) are the same
function with a different keypath. One generic helper expresses the rule once:

```swift
private func inherited<T>(_ keyPath: KeyPath<VerbModel, T?>, _ name: String) -> T {
  if let value = self[keyPath: keyPath] { return value }
  if let parentId { return VerbModel.model(id: parentId).inherited(keyPath, name) }
  fatalError(name + " and parentId are nil.")
}
```

### 2.6 Ending tables: identical twins and code-shaped data

- `Imparfait` and `ConditionnelPrésent` (`Conjuguer/Models/Imparfait.swift`,
  `ConditionnelPresent.swift`) are byte-for-byte the same table (`ais/ais/ait/ions/iez/aient`)
  — which is no accident: the conditional *is* future stem + imperfect endings. One should
  delegate to (or simply alias) the other.
- The group enums spell every six-ending table as a nested switch (~530 lines across
  `IndicatifPresentGroup.swift`, `PasseSimpleGroup.swift`, `SubjonctifPresentGroup.swift`).
  A `[PersonNumber: String]` (or a six-element array in `PersonNumber` order) per case makes
  each table one line and makes diffs reviewable. `IndicatifPrésentGroup.s` and `.r` differ
  only in third-singular (`"t"` vs `""`), which a data table makes obvious.
- The three "star the endings overridden by `*`-alterations" builders —
  `IndicatifPresentGroup.endings` (:123-147), `impératifEndings` (:198-220), and
  `SubjonctifPrésentGroup.endings` (:82-104) — are the same algorithm parameterized by tense
  constructor and person-number list; extract one helper.

### 2.7 `VerbBrowseView`/`ModelBrowseView` and their stores are structural twins

Both views (`Conjuguer/Views/VerbBrowseView.swift`, `ModelBrowseView.swift`) repeat the
picker-plus-list-plus-search-plus-`ContentUnavailableView`-plus-sad-trombone scaffold, and
both stores repeat "precompute one sorted array per sort case; `didSet` persists the choice
and swaps the published array." A generic `BrowseStore<Item, Sort>` (cached arrays keyed by a
`CaseIterable` sort) plus a shared `updateSearchResults` would halve both files. Lower urgency
than 2.1-2.6 because two instances may not justify the abstraction yet — but a third browse
screen should trigger it.

### 2.8 Four XML parsers share an unextracted scaffold

`VerbParser`, `VerbModelParser`, `DefectGroupParser`, and `FrequencyParser` repeat the same
bundle-URL/`XMLParser` constructor, `current*` accumulator fields, required-attribute
`fatalError` checks, and end-element reset dance. A small base class (bundle resource → parser
→ delegate) plus an attribute helper (`require("in", in: attributeDict)`) would shrink each
parser to its element-specific mapping. Note that `FrequencyParser` is dead anyway (section 4),
which reduces this to three.

### 2.9 `Settings` repeats a property/key/default/load-or-seed quartet seven times

`Conjuguer/Utils/Settings.swift` spends ~12 lines per setting on a `didSet` persister plus an
init block that loads-or-seeds. `@Observable` rules out a plain property wrapper, but two tiny
generic helpers (`load<T: RawRepresentable>(key:default:)` and a `persist(_:key:)` used in each
`didSet`) cut the file roughly in half and — more importantly — force a single serialization
path through `rawValue`, eliminating the `"\(enum)"`-vs-`.rawValue` divergence behind bug 1.1
and the `Int((bestScoreString as NSString).intValue)` idiom (prefer `Int(bestScoreString) ?? default`).

---

## 3. Code smells and inelegance

### 3.1 Structured data round-tripped through display strings

The ending-group `endings`/`impératifEndings`/`subjonctifImparfaitEndings` methods return
space-joined display strings, which `ModelView.endingSlots`
(`Conjuguer/Views/ModelView.swift:224-233`) then `split(separator: " ")`s back into tokens to
place in a grid. Strings-as-data is fragile (an ending containing a space, or `""` vs `"_"`
placeholder handling, breaks silently). Return `[PersonNumber: String]` and let views do their
own joining/starring.

### 3.2 `Result` handled via `default: fatalError` pyramids

`Verb.personlessConjugations` (`Conjuguer/Models/Verb.swift:76-98`) nests three switches to
combine three `Result`s (and is dead code anyway — section 4). The repeated
`switch result { case .success(let v): … default: fatalError }` shape across the codebase
(InputView, TestUtils, VerbConjugations, Quiz) is what `try Conjugator.conjugate(…).get()` or a
small throwing wrapper exists for. Where conjugation truly "cannot fail," one
`conjugateOrDie` helper states that intent once.

### 3.3 Settings reads bypass the `World` seam

`PersonNumber.pronoun/pronounWithGender/gender` and `Conjugator.conjugate` (compound-tense
branch, `Conjugator.swift:199`) read `Current.settings.pronounGender` directly from model-layer
code, while views consistently use `@Environment(World.self)`. The engine being
gender-dependent through a hidden global also forces `Quiz.process` and tests to mutate global
state (`CompoundTenseTests.swift:19`). Passing `PronounGender` (or a display-options value)
into the few call sites that need it would make `Conjugator` a pure function again. Related
inconsistency: `VerbStore`/`ModelStore` take `World` via initializer (`VerbBrowseView.swift:13`,
from `@State` capturing `Current`) while their host views also read it from the environment —
two access paths to the same object in one file.

### 3.4 Three different diacritic-handling implementations

- `Conjugator.moveCircumflexIfNeeded` — ten-tuple list (`Conjugator.swift:235`).
- `ConjugationResult.score` — two strip-tables (`ConjugationResult.swift:22, 29-32`).
- `PersonNumber.preamble` — the right way: `folding(options: .diacriticInsensitive, locale:)`
  (`PersonNumber.swift:172-174`).

Standardize on `folding` (scoring needs a circumflex-only stage; a single
`strippingAccents(except:)` helper covers both stages). Same theme: verb search uses
case/diacritic-*sensitive* `contains` (`VerbBrowseView.swift:107`, `ModelBrowseView.swift:96`)
— typing `etre` finds nothing. `localizedStandardContains(_:)` is the one-line fix and is
exactly what users without a French keyboard need in this app.

### 3.5 Hand-rolled markup parser with `Character`-indexed `NSRange`s

`String.attributedText` (`Conjuguer/Utils/StringExtensions.swift:103-206`) walks the string by
`Character` while building `NSRange`s, which count UTF-16 code units. Today's corpus is
precomposed-BMP French so the offsets happen to agree, but the first astral or decomposed
character in an Info article shifts every subsequent range (bold runs, links, conjugation
coloring). The modern fix is to build `AttributedString` directly with Swift ranges — the
codebase already does this style of construction in `etymologyAttributedString` (same file,
:33-44) and `ConjugationText.swift`. `conjugatedString`'s manual `NSString` scan (:53-95) and
the custom `` ` ``/`~`/`%`/`$` markup would both shrink dramatically.

### 3.6 Quiz modeling nits

- `questions: [(Verb, Tense)]` forces `question.0` / `question.1` reads
  (`Quiz.swift:19, 314-316`, `QuizView.swift:135-136`); a two-field `Question` struct names them.
- `numberCorrect` is a `Double` accumulating `1.0 * conjugationResult.percentCorrect`
  (`Quiz.swift:16, 325`) — the `1.0 *` is a no-op, and the name says "count" while the type
  says "fraction"; `score`-style naming or an `Int` half-credit count would read honestly.
- `bonusForElapsedTime`'s nine-arm switch (`Quiz.swift:400-423`) is
  `max(0, 450 - ((elapsedTime - 1) / 60) * 50)` if you prefer arithmetic to tables (the table
  is defensible; the duplication above it is not).
- `Quiz.buildQuiz`'s `.ridiculous` branch builds thirty questions via thirty repeated
  `questions.append((Verb.verbForInfinitif("…"), …))` lines (`Quiz.swift:171-201`); a literal
  array of `(infinitif, tenseBuilder)` pairs mapped once would compress it and make the quiz
  content reviewable at a glance.

### 3.7 Loops that re-implement `map`/`joined`

Several utility methods hand-roll collection transforms: `composedConjugation`'s
`hasAppendedAtLeastOneConjugation` flag (`Conjugator.swift:208-223`) is
`stems.map { … }.joined(separator: Tense.alternateConjugationSeparator)`;
`Tense.allIndicatifPrésentTenses` (`Tense.swift:246-252`) is
`PersonNumber.allCases.map(Tense.indicatifPrésent)`; `StemAlteration.alterationsFor`
(`StemAlteration.swift:176-184`) is `components.map(StemAlteration.init)`;
`Info.headingToIndex` (`Info.swift:64-72`) is `infos.firstIndex { … }`.

### 3.8 Audio session configured three times; errors swallowed

`SoundPlayer.init` sets the AV category, `SoundPlayer.setup()` sets it again with options, and
`Utterer.setup()` sets it a third time (`SoundPlayer.swift:20, 43`, `Utterer.swift:22`); both
`setup`s also play `.silence` for the same workaround. One audio-bootstrap function called from
`ConjuguerApp.init` states the intent once. The `catch {}` blocks in `SoundPlayer` are empty —
even a `print`, as `Utterer` does, beats silence when sounds stop working.

### 3.9 Assorted service-layer nits

- `RatingsFetcher.fetchRatingsDescription` (`RatingsFetcher.swift:30-70`): the exhortation
  `" Ajoutez la vôtre."` is hardcoded French while its three sibling strings are localized;
  `JSONSerialization` + casts would be a two-line `Codable` struct; the callback + manual
  `Task { @MainActor … }` hop is `async/await` on `URLSession` (the `Sendable` capture
  workaround at :33-37 then disappears); `NSString(format:)` → `String(format:)`.
- `GameCenter.authenticate` (`GameCenter.swift:24, 29-30`) keeps commented-out `print`s and an
  `"ERROR"` sentinel string for a missing leaderboard ID; make it optional and guard
  `reportScore`/`showLeaderboard` on it.
- `URL.isDeeplink` hardcodes `"conjuguer"` (`URLExtensions.swift:12`) two lines above
  `conjuguerUrlPrefix = "conjuguer://"`; derive one from the other.
- `Verb.id = UUID()` (`Verb.swift:14`) gives every parse a fresh identity; `infinitif` (or
  `infinitifWithPossibleExtraLetters`, the dictionary key) is the natural stable `id` and
  avoids identity churn in sheets/`ForEach`.

### 3.10 The view layer repeats its analytics hook

Every screen ends with
`.onAppear { world.analytics.recordViewAppeared("\(SomeView.self)") }` (nine occurrences). A
one-line modifier — `.recordsAppearance(as: Self.self)` reading `World` from the environment —
removes the copy-paste and guarantees consistent naming.

---

## 4. Dead code — safe deletions (~450 lines)

All verified unused by project-wide search; each is an independent, mechanical deletion.

| Dead code | Location | Notes |
|---|---|---|
| `Conjugator.printConjugations` | `Conjugator.swift:256-409` | Never called; hardcodes `"alunir"`; duplicates `InputView.conjugate` (see 2.1). |
| `FrequencyParser` (class body) | `Models/FrequencyParser.swift` | Never instantiated — frequencies now ship in `verbs.xml` (`fr` attribute). Only `maxFrequency` is referenced (`VerbView.swift:116`); move the constant and delete the parser (and `frequencies.xml` from the bundle if nothing else reads it). |
| `Verb.personlessConjugations` | `Verb.swift:76-98` | Superseded by `VerbConjugations.personless`. |
| `PersonNumber.pronounAndConjugation` | `PersonNumber.swift:165-167` | No callers. |
| `Tense.tensesFor(shorthand:)` | `Tense.swift:240-244` | Stub that ignores its argument — either finish it per 2.4 or delete. |
| `QuizState.finished` | `Models/QuizState.swift:11` | Never assigned or matched. |
| `VerbSort.displayName` | `Utils/VerbSort.swift:14-21` | Views use `L.displayNameForVerbSort`; this unlocalized copy drifts. |
| `UIFont.preferredFont(from:)` (whole file) | `Utils/UIFontExtension.swift` | No callers. |
| `displayFontFamilyNames()` | `Utils/Fonts.swift:23-30` | Debug helper, no callers. |
| `String.replaceFirstOccurence` | `Utils/StringExtensions.swift:46-51` | No callers (and misspelled). |
| `String.coloredString(color:)` | `Utils/StringExtensions.swift:97-101` | No callers. |
| `Quiz.gameCenter` stored property | `Quiz.swift:26, 56-57` | Assigned, never read (`completeQuiz` uses `Current.gameCenter`); drop it or actually use the injection (preferable for tests). |
| `QuizVerbs.subjonctifPrésentStemChangers` deck | `Quiz.swift:47-48, 102, 119, 281-287`; `QuizVerbs.swift:25` | Accessor never called from `buildQuiz`. |
| `AnalyticsLocale.defaultLanguageCode` | `Analytics/AnalyticsLocale.swift:14, 23-26` | Requirement + default impl, never used (the flag-emoji local is fun, but it's dead fun). |
| `ReviewPrompter.shared` | `ReviewPrompter.swift:11` | `World` constructs its own instance. |
| `Utterer.defaultLocaleString` | `Utterer.swift:15-16` | Duplicate of `englishLocaleString`; keep one. |

---

## 5. Test-coverage gaps worth closing

The generated `VerbModelTests` (5,530 lines) gives the conjugation engine superb golden
coverage, but the *surrounding* logic — where this review found its actual bugs — has none:

- `ConjugationResult.score` (bug 1.3) — a table-driven test over exact/circumflex/accent/junk
  inputs, including a `paye/paie` multi-form case.
- `Settings` round-trip through `DictionaryGetterSetter` for every property (bug 1.1).
- `DefectGroup` shorthand parsing (bug 1.2) — assert the tense set produced by each code.
- `Quiz` scoring/lifecycle (`process`, bonus thresholds, best-score persistence) — currently
  exercised only manually via the simulator flow documented in CLAUDE.md.

These four files are exactly the ones safe-to-refactor sections 2.2, 2.4, and 2.9 touch, so
tests-first pays twice.

---

## 6. Minor polish

- Typos in identifiers/messages: `conjugatedAuxilliary` (→ `conjugatedAuxiliary`,
  `Tense.swift:104`), `conjugationFailedMesage` (`Conjugator.swift:270`),
  `urlInitializationMessage`'s "initializaed" (`RatingsFetcher.swift:14`), "has already been
  inpat" (`InputView.swift:77, 82` — if "inpat" is a deliberate joke, carry on).
- `L.swift`'s `*WithColon` strings get assembled by interpolation at call sites
  (`"\(L.QuizView.scoreWithColon) \(quiz.score)"`); format-style localized strings with
  arguments survive word-order differences across languages better.
- `L.displayNameForVerbSort`/`ForModelSort` share the bare localization key `"alphabetical"`
  (`L.swift:604, 613`) while every other key is namespaced — works, but breaks the convention
  that makes the catalog navigable.
- `StemAlteration.alterationsFor` hardcodes its `"|"` separator locally
  (`StemAlteration.swift:177`) while the `","` separator is a named constant on
  `VerbModelParser`; name both, side by side.
- `IndicatifPrésentGroup`/`SubjonctifPrésentGroup` encode "uppercase = irregular ending" with
  opposite raw-string conventions (`"e"`/`"E"` mean *regular-for-er* in one and
  *irregular-for-ir* in the other; compare `IndicatifPresentGroup.swift:17-36` with
  `SubjonctifPresentGroup.swift:15-30`). A doc comment on each `groupForXmlString` mapping the
  letters would spare the next reader a test-fixture archaeology session.
- CLAUDE.md's architecture overview says both "6,320 verbs" and "6,314 verbs" two paragraphs
  apart; one of them is stale.

---

*Generated by a full-codebase review on 2026-06-09. Items 1.1-1.8 were verified by code
inspection only — none have been fixed in this pass, and each deserves a confirming test or
simulator check before/while fixing.*
