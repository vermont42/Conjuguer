# Conjuguer Code-Review Suggestions

A review of the app target (~9,000 lines, excluding tests) for duplication, inelegant
code, and code smells. Suggestions are ordered from most impactful to least. Line
numbers reflect the code as of commit `32f8478`.

---

## 1. `Quiz` has thirteen copy-pasted array/index cycling pairs

**Files:** `Conjuguer/Models/Quiz.swift:29–54, 92–124, 209–311`

The quiz draws verbs from thirteen pools (`regularErs`, `regularIrs`, `bigThrees`,
`topThirties`, …). Each pool requires four hand-written pieces that are identical
except for the name:

- a stored array + a stored index (lines 29–54),
- a line in `resetIndices()` (lines 92–106),
- a line in `randomizePersonNumbersAndVerbs()` (lines 108–124),
- a ~7-line computed property that advances the index with wraparound (lines 209–311).

That is roughly 150 lines of boilerplate, and adding a fourteenth pool means touching
four places. A small generic type collapses all of it:

```swift
struct CyclingDeck<Element> {
  private var elements: [Element]
  private var index = 0

  init(_ elements: [Element]) { self.elements = elements }

  mutating func shuffle() { elements.shuffle() }
  mutating func reset() { index = 0 }

  mutating func next() -> Element {
    index = (index + 1) % elements.count
    return elements[index]
  }
}
```

`Quiz` then holds `private var regularErs = CyclingDeck(QuizVerbs.regularErs)` etc.,
and `resetIndices`/`randomize` become single loops over the decks (or disappear if the
decks live in an array). Incidental quirk worth fixing while there: every cycling
property increments **before** reading, so element 0 of each pool is skipped until the
first wraparound. Harmless today because the pools are shuffled, but surprising.

---

## 2. ~250 lines of duplicated debug-dump code, one copy dead and buggy

**Files:** `Conjuguer/Models/Conjugator.swift:256–409`, `Conjuguer/Views/InputView.swift:130–270`

`Conjugator.printConjugations(infinitif:)` and `InputView.conjugate(_:extraLetters:)`
are near line-for-line duplicates: nine consecutive copy-pasted blocks of
"loop person numbers → conjugate → append to output or `fatalError`", one block per
tense. On top of the duplication:

- `printConjugations` is **dead code** — nothing calls it.
- It has a real bug: it ignores its `infinitif` parameter and hardcodes
  `Verb.verbs["alunir"]` (`Conjugator.swift:257`), so if it were ever called it would
  print the wrong verb.

Recommendation: delete `printConjugations` outright, and rewrite `InputView.conjugate`
as a loop over labeled tense specs, mirroring the table-driven style that already
exists in `VerbConjugations.simpleSpecs`:

```swift
let specs: [(String, [Tense])] = [
  ("PRESENT", PersonNumber.allCases.map { .indicatifPrésent($0) }),
  ("IMPERFECT", PersonNumber.allCases.map { .imparfait($0) }),
  // …
]
```

Roughly 250 lines become 30.

---

## 3. Search is case- and diacritic-sensitive in both browse views

**Files:** `Conjuguer/Views/VerbBrowseView.swift:107`, `Conjuguer/Views/ModelBrowseView.swift` (`updateSearchResults`)

```swift
store.verbs.filter { $0.infinitifWithPossibleExtraLetters.contains(searchText.localizedLowercase) }
```

This is user-facing: `String.contains` is exact, so typing `Etre`, `etre`, or anything
with a stray capital finds nothing (only the search *text* is lowercased — and the
verbs happen to be lowercase, which is the only reason it mostly works). A user who
can't type accents can't find `répéter` by typing `repeter`. The standard fix is:

```swift
store.verbs.filter { $0.infinitifWithPossibleExtraLetters.localizedStandardContains(searchText) }
```

`localizedStandardContains` is case- and diacritic-insensitive, which is exactly the
"Finder-style" matching users expect — and it's particularly valuable in a French app
where the quiz itself treats dropped accents as "partial credit" rather than failure.
The same one-line change applies to `ModelBrowseView` (`$0.model.exemplar.contains(...)`).

---

## 4. Latent bug: `futurStemsRecursive` trims the wrong stem

**File:** `Conjuguer/Models/VerbModel.swift:210–214`

```swift
stems.forEach {
  if $0.last == "e" {
    stems[0] = String(stems[0].dropLast())
  }
}
```

The closure inspects each stem `$0` but always mutates `stems[0]`. With a single stem
this is correct (drops the final *e* of `-re` infinitifs). But if an additive
`radicalFutur` alteration has produced two stems:

- if only `stems[1]` ends in *e*, `stems[0]` is wrongly truncated and `stems[1]` keeps
  its *e*;
- if both end in *e*, `stems[0]` is truncated **twice** and `stems[1]` not at all.

No `-re` verb with an additive futur alteration currently exists in the data, which is
why tests pass — but the code as written can't ever do what it appears to intend.
Should be:

```swift
for i in stems.indices where stems[i].last == "e" {
  stems[i] = String(stems[i].dropLast())
}
```

---

## 5. `ReviewPrompter` creates a second, parallel `Settings` instance

**File:** `Conjuguer/Utils/ReviewPrompter.swift` (init)

```swift
init(settings: Settings = Settings(getterSetter: UserDefaultsGetterSetter()), ...)
```

The production `World.device`/`World.simulator` construct `ReviewPrompter()` with this
default, so at runtime there are **two live `Settings` objects** writing the same
UserDefaults keys. It works only because `ReviewPrompter` happens to touch keys
(`promptActionCount`, `lastReviewPromptDate`) that nothing else observes — but it
undermines the entire `World` dependency-injection design: `Current.settings` and the
prompter's settings can silently disagree (each caches values loaded at its own init
time), and `@Observable` change tracking on `Current.settings` won't fire for writes
made through the prompter's copy. Inject the shared instance instead — e.g. build
`ReviewPrompter(settings: settings)` inside the `World.device`/`simulator` factories.

---

## 6. Four near-identical 17-case switches in `Tense` just to extract the `PersonNumber`

**File:** `Conjuguer/Models/Tense.swift:168–202`

`pronounWithGender`, `pronoun`, `gender`, and `pronounDecorator` each repeat the same
giant pattern — seventeen `case .x(let personNumber)` arms — only to forward to a
`PersonNumber` property. One accessor removes all four switches:

```swift
var personNumber: PersonNumber? {
  switch self {
  case .participePassé, .participePrésent, .radicalFutur:
    return nil
  case .indicatifPrésent(let p), .passéSimple(let p), /* … all 17 … */ .impératifPassé(let p):
    return p
  }
}

@MainActor var pronoun: String {
  personNumber?.pronoun ?? L.QuizView.none
}
```

`VerbConjugations.conjugationParts` (lines 95–120) contains a fifth copy of the same
17-arm extraction and could also use it. Adding a future tense currently means
updating five switches; with the accessor, one.

While in this file: `conjugatedAuxilliary` (line 104) is misspelled — should be
`conjugatedAuxiliary` (the correct spelling is already used elsewhere, e.g.
`Verb.auxiliary`).

---

## 7. `Settings` repeats the same persistence boilerplate seven times

**File:** `Conjuguer/Utils/Settings.swift:16–134`

Every setting is four declarations (property + `didSet` + static key + static default)
plus an if/else load-or-seed block in `init` — the same shape seven times, ~120 lines.
The pattern can't be a property wrapper inside `@Observable` (wrappers conflict with
the macro), but a pair of small generic helpers removes most of it:

```swift
private func load<T: RawRepresentable>(_ key: String, default def: T) -> T
    where T.RawValue == String {
  if let raw = getterSetter.get(key: key), let value = T(rawValue: raw) {
    return value
  }
  getterSetter.set(key: key, value: def.rawValue)
  return def
}

private func persist<T: Equatable>(_ value: T, old: T, key: String, raw: String) { … }
```

`init` becomes seven one-liners, and each `didSet` a one-liner. Smaller smells fixed
for free along the way: `Int((bestScoreString as NSString).intValue)` should be
`Int(bestScoreString) ?? Settings.bestScoreDefault` (the `NSString.intValue` path
silently returns 0 for garbage), and the hand-rolled `DateFormatter` + format string
could be `ISO8601DateFormatter` or just storing `timeIntervalSince1970`.

---

## 8. `StemAlteration.init` has a 100-line switch its own TODO says to replace

**Files:** `Conjuguer/Models/StemAlteration.swift:43–151`, `Conjuguer/Models/Tense.swift:204–244`

The shorthand parser handles `r1s`, `r2s`, … `h2p` as ~45 explicit cases, with a TODO
at line 45 acknowledging it should be data-driven. Each shorthand is just
`<tense letter><person-number short name>`, and both halves already have lookup
functions (`PersonNumber.personNumberForShortDisplayName`,
`Tense.shortDisplayName` uses the same letters). A table closes the loop:

```swift
private static let tenseBuilders: [Character: (PersonNumber) -> Tense] = [
  "r": Tense.indicatifPrésent, "b": Tense.subjonctifPrésent, "x": Tense.passéSimple,
  "i": Tense.imparfait, "q": Tense.subjonctifImparfait, "h": Tense.impératif,
]
```

Parse: first character → builder; `"A"` suffix → all person numbers; otherwise
`personNumberForShortDisplayName(String(shorthand.dropFirst()))`. Related cleanups
that fall out of the same table:

- `Tense.tensesFor(shorthand:)` (Tense.swift:240) is an unfinished stub — it ignores
  its parameter and always returns `[.indicatifPrésent(.firstSingular)]`. Finish it
  with the table or delete it.
- `Tense.shorthandForNonCompoundTense` (Tense.swift:204–238) hardcodes the `rA`/`xA`/
  `bA`/`iA` six-element arrays and checks membership with six chained `contains`;
  with the table this becomes `Set(...).isSubset(of: shorthands)`, and the manual
  comma-joining loop at the bottom is just `shorthands.joined(separator: ", ")`.

---

## 9. Dead code sweep

Confirmed unreferenced by anything in the app or test targets:

| Symbol | Location | Notes |
|---|---|---|
| `Conjugator.printConjugations` | `Conjugator.swift:256–409` | Also buggy (see #2). |
| `Verb.personlessConjugations` | `Verb.swift:76–98` | Superseded by `VerbConjugations.personless`; also an example of the nested-switch pyramid that `Result` chaining avoids. |
| `Tense.tensesFor(shorthand:)` | `Tense.swift:240–244` | Unfinished stub (see #8). |
| `Tense.allIndicatifPrésentTenses` | `Tense.swift:246–252` | Unused. |
| `String.replaceFirstOccurence` | `StringExtensions.swift:46–51` | Unused, and misspelled (`Occurence`). |
| `VerbView.shouldShowVerbHeading` | `VerbView.swift:14–21` | Stored but never read in `body` — the heading is always shown. Three call sites pass `true` to no effect. Either honor it (as `InfoView.shouldShowInfoHeading` does) or remove the parameter. |

Deleting these removes ~250 lines and, more importantly, removes traps for future
readers (a caller of `printConjugations` would silently get *alunir*'s conjugations).

---

## 10. `VerbBrowseView`/`ModelBrowseView` duplicate the whole browse scaffold

**Files:** `Conjuguer/Views/VerbBrowseView.swift`, `Conjuguer/Views/ModelBrowseView.swift`

The two screens are structurally the same view: segmented sort `Picker` →
searchable `List` → `ContentUnavailableView` overlay → sad-trombone on empty search →
sheet for deep-linked detail. Likewise `VerbStore` and `ModelStore` are the same
class: pre-sorted arrays per sort order, a `didSet` that persists the sort and swaps
the active array. A generic `BrowseStore<Item, Sort>` (sort cases → precomputed
arrays) plus a shared `updateSearchResults` helper would halve both files and make
the third browse screen (Info) eligible to join the pattern later.

Smaller inconsistency in both: the stores are built with the global —
`@State private var store = VerbStore(world: Current)` — while the same view reads
`@Environment(World.self)`. Previews and tests that inject a different `World` into
the environment will still get `Current` inside the store. Initialize the store from
the environment world (e.g. in `.onAppear`/`task` or via `init`) so there's one source
of truth.

---

## 11. Ending tables are code instead of data; star-marker logic is triplicated

**Files:** `Conjuguer/Models/IndicatifPresentGroup.swift`, `PasseSimpleGroup.swift`, `SubjonctifPresentGroup.swift`

Two related issues:

- Every `…ForPersonNumber` method spells out a 6-case switch per group — ~400 lines of
  pure lookup tables across the three files. Since `PersonNumber` has a stable order,
  each group's endings can be a 6-element array (`["e", "es", "e", "ons", "ez",
  "ent"]`) indexed by `PersonNumber.allCases.firstIndex(of:)` (or a small ordinal
  property), with the `appliesTo…Verb ? uppercased : lowercased` flag applied once.
- `IndicatifPrésentGroup.endings(stemAlterations:)` (lines 123–147),
  `IndicatifPrésentGroup.impératifEndings(stemAlterations:)` (lines 198–220), and
  `SubjonctifPrésentGroup.endings(stemAlterations:)` are the same algorithm three
  times — scan alterations for a trailing `*`, then emit either `*` or the ending per
  person number. One helper parameterized by `(personNumbers, tenseBuilder,
  endingProvider)` covers all three.

Also in this family: `String(stem.last ?? Character(""))` as the irregular-marker
check (`Conjugator.swift:62, 181, 215`) is fragile — `Character("")` traps at runtime
if the stem is ever empty, and the intent is simply `stem.hasSuffix(Tense.irregularEndingMarker)`.

---

## 12. `Conjugator.conjugate` repeats the additive-alteration scan four times

**File:** `Conjuguer/Models/Conjugator.swift:45–53, 57–70, 93–108, 120–133`

Four arms of the first big switch contain the same loop: find the first additive
alteration applying to tense X, duplicate `stems[0]`, modify the copy, `break`. A
helper makes the variations (which tense to match, the participe special-casing)
explicit instead of buried in repetition:

```swift
func appendAdditiveStem(matching tense: Tense, to stems: inout [String], from alterations: [StemAlteration]?) {
  guard let alteration = alterations?.first(where: { $0.appliesTo.contains(tense) && $0.isAdditive }) else {
    return
  }
  var copy = stems[0]
  copy.modifyStem(alteration: alteration)
  stems.append(copy)
}
```

While here: `composedConjugation`'s manual `hasAppendedAtLeastOneConjugation` flag
(lines 208–223) is `map` + `joined(separator:)` in disguise.

---

## 13. Quiz questions as unlabeled tuples

**Files:** `Conjuguer/Models/Quiz.swift:19, 313–316`, `Conjuguer/Views/QuizView.swift:135–136`

`questions: [(Verb, Tense)]` forces `question.0` / `questions[i].1` reads at every use
site. A two-field struct (`struct QuizQuestion { let verb: Verb; let tense: Tense }`)
costs three lines and makes every access self-documenting. `QuizResult` already
exists as the answer-side struct, so the question side is the odd one out.

---

## 14. `VerbView` recomputes all conjugations on every view-struct init

**File:** `Conjuguer/Views/VerbView.swift:19–23`

```swift
init(verb: Verb, shouldShowVerbHeading: Bool = false) {
  ...
  conjugations = VerbConjugations(verb: verb)
}
```

`VerbConjugations(verb:)` conjugates ~50 forms and builds attributed strings. SwiftUI
re-initializes child view values whenever the parent's `body` re-evaluates, so this
work can run repeatedly while the verb hasn't changed (the file's own comments note
the precompute is intentional — but `init` doesn't cache it across re-inits). Storing
it as `@State` (computed once per identity) or memoizing inside `VerbConjugations`
keeps the precompute *and* makes it once-per-verb:

```swift
@State private var conjugations: VerbConjugations? // populated in .task/.onAppear keyed by verb
```

Low urgency — it's only noticeable when something above VerbView invalidates often —
but it's the kind of cost that silently grows.

---

## 15. Minor smells (grab bag)

- **Hardcoded French in `RatingsFetcher`** (`RatingsFetcher.swift`): `let exhortation
  = " Ajoutez la vôtre."` sits beside properly localized `L.RatingsFetcher.*` strings.
  Move it into the catalog.
- **Duplicate audio-session setup**: `SoundPlayer.setup()` and `Utterer.setup()` both
  set `.playback, .mixWithOthers` and both play `.silence`; `SoundPlayer.init`
  additionally sets a *different* category (`.playback` without options) with an
  empty `catch {}`. Consolidate session configuration in one place and log failures.
- **`Utterer.defaultLocaleString` duplicates `englishLocaleString`** — two constants,
  same value, both `"en-US"`.
- **`Verb.id = UUID()`** (`Verb.swift:14`): identity is regenerated every parse, and
  synthesized `Hashable` includes it, so two structurally identical verbs are never
  equal. `infinitifWithPossibleExtraLetters` is the natural stable id (it's already
  the dictionary key).
- **Valid-endings list duplicated**: `["er", "ir", "re", "ïr"]` appears in both
  `Verb.endingIsValid` (`Verb.swift:102`) and `InputView.add` (`InputView.swift:90`).
  The latter should call the former (or share a constant).
- **`Quiz.bonusForElapsedTime`** (`Quiz.swift:400–423`): the nine-bracket switch is
  the linear function `max(0, 450 - 50 * ((elapsedTime - 1) / 60))` for the 121+
  range with a 0–120 head; two lines replace twenty-four if the arithmetic intent is
  real (keep the switch if the brackets are tuned independently).
- **`ConjugationResult.score` accent tables** (`ConjugationResult.swift:22–35`)
  hand-roll diacritic folding; `folding(options: .diacriticInsensitive, locale:
  Util.french)` already exists in the codebase (`PersonNumber.preamble`) and handles
  the circumflex/grave/acute split via two folds — though the current two-tier
  partial-credit distinction would need the circumflex set kept explicit.
- **`InputView` typos** (`InputView.swift:77, 82`): "has already been inpat." /
  "Invalid model … inpat." — debug-only, but if intentional wordplay, a comment would
  spare the next reader a double take.

---

## Suggested first move

Items 1, 2, 6, and 9 are pure deletions/extractions with no behavior change and
high line-count payoff (~600 lines removed); they also de-risk items 4 and 8 by
shrinking the surface those fixes touch. Item 3 is the best user-visible
quick win — a two-line change that makes search work the way every French learner
will try to use it.
