# Conjuguer — Code Improvement Suggestions

A review of the Conjuguer codebase (89 Swift files, ~8,600 LOC) for duplication,
inelegant code, and code smells. Findings are ordered **most impactful first**.
Each item cites concrete files/lines and a suggested fix. Line numbers reflect the
state of the tree at review time; treat them as starting points.

> Scope note: many of these are deliberate refactors, not bugs. Nothing here is a
> known crash in normal use. Tackle them opportunistically — the conjugation engine
> and the `*Group` files are the highest-leverage targets because they're the core
> domain and the most duplicated.

---

## 1. Quiz.swift — 13 hand-written verb-cycling properties (high impact, easy win)

`Quiz.swift` defines ~13 private computed properties (`regularErVerb`,
`regularIrVerb`, `regularReVerb`, `bigThreeVerb`,
`indicatifPrésentStemChangerVerb`, …, lines ~225–311) that are **byte-for-byte
identical except for the array/index names**:

```swift
private var regularErVerb: Verb {
  regularErsIndex += 1
  if regularErsIndex == regularErs.count {
    regularErsIndex = 0
  }
  return Verb.verbForInfinitif(regularErs[regularErsIndex])
}
```

Each is paired with two parallel stored properties (`private var regularErs = …`
and `private var regularErsIndex = 0`, lines ~29–54) and reset logic duplicated in
both `resetIndices()` and `resetPublishedProperties()` (lines ~92–136).

**Fix.** Introduce a small cyclic cursor and collapse all 13 into one helper:

```swift
private struct VerbCycle {
  let infinitifs: [String]
  private var index = 0
  mutating func next() -> Verb {
    index = (index + 1) % infinitifs.count
    return Verb.verbForInfinitif(infinitifs[index])
  }
}
```

Hold them in a `[VerbCategory: VerbCycle]` dictionary keyed by an enum. This removes
~150 lines, makes `resetIndices()` a one-liner (`cycles.values.forEach { $0.reset() }`),
and eliminates the "did I update both the array and its index?" footgun.

---

## 2. The `*Group` tense-ending files share one structure, copy-pasted

`IndicatifPresentGroup.swift`, `PasseSimpleGroup.swift`,
`SubjonctifPresentGroup.swift` (and the related `Imparfait`, `FuturSimple`,
`ConditionnelPresent`) each implement an `endingForPersonNumber(_:)` as a 6-case
switch returning string endings. The shape is identical across files; only the
ending strings differ.

**Fix.** Most of these are just an ordered 6-element table indexed by person/number.
Model `PersonNumber` with a stable ordinal (or an `allCases` index) and store the
endings as `["e", "es", "e", "ons", "ez", "ent"]`, looked up by position. Each group
becomes data, not control flow. This shrinks six files to near-trivial and makes
adding/auditing a paradigm a one-line table edit.

---

## 3. Conjugator.swift — one 195-line `conjugate()` and pervasive `fatalError`

`Conjugator.conjugate()` (lines ~11–206) is a single function with two large nested
switch statements (~lines 42–140 and 157–205). The file also reaches for
`fatalError()` in many places (e.g. the circumflex helper at line ~231, and ~12 sites
in `printConjugations()`), turning data/logic errors into crashes.

**Fix.**
- Extract per-tense logic into focused functions (one per tense family) or a
  dictionary dispatch keyed by `Tense`. The function is currently very hard to unit
  test in isolation.
- Replace `fatalError` with the existing `ConjugatorError` / `Result` channel that
  the engine already returns elsewhere — particularly the circumflex helper, which
  force-reads `stem.last`. The engine is the app's core; a malformed model should
  degrade, not crash.

---

## 4. The three Browse views are the same view three times

`VerbBrowseView`, `ModelBrowseView`, and `InfoBrowseView` share nearly the entire
scaffold: `NavigationStack` → `ZStack` → `Color.customBackground`, a segmented sort
`Picker`, `searchText`/`searchResults` state, a `.searchable` block, `onChange` →
`updateSearchResults()`, a `.sheet`, and an `onAppear` analytics call. The two
`updateSearchResults()` implementations (VerbBrowse ~103–113, ModelBrowse ~92–102)
are the same logic — empty-check, `localizedLowercase` filter, "sad trombone" sound
when empty — with different element types.

**Fix.** Extract a generic `BrowseView<Item, Row, Detail>` that takes the item list,
a sort picker config, a row builder, and a detail builder. The three concrete views
become ~15 lines each. Even a partial extraction (a shared search-filter helper and a
shared `.browseChrome()` modifier) removes most of the duplication.

---

## 5. InputView.swift — business logic living in the view

`InputView` (334 lines) embeds verb construction/validation (~64–116), conjugation
computation and string assembly across **seven near-identical per-tense blocks**
(~130–252, differing only by tense and label), and XML export (~272–327). It also
repeats the same `TextField` + `.textInputAutocapitalization(.never)` +
`.autocorrectionDisabled()` + `.padding()` four times (~21–51).

**Fix.**
- Move verb building, conjugation assembly, and XML export into a view model /
  service. The view should present, not compute.
- Replace the seven tense blocks with one helper `func conjugatedLine(_ label:
  String, tense: (PersonNumber) -> Tense) -> String` driven by a `[(label, tense)]`
  table.
- Extract a `labeledTextField(_:text:)` helper for the four input fields.

---

## 6. StemAlteration.swift — a 60+ case shorthand-decoding switch

`StemAlteration.init(xmlString:)` (lines ~47–150) decodes tense shorthand codes
(`r1s`, `r2s`, `b1s`, …) through a giant switch. There's an existing `// TODO` at
line ~45 acknowledging it. This is brittle and the single hardest place to add a new
tense.

**Fix.** Replace with a `[String: Tense]` (or `[String: (PersonNumber) -> Tense]`)
lookup table. The decoding becomes a dictionary read, the table is auditable at a
glance, and it's directly unit-testable.

---

## 7. L.swift — 618 lines of mechanical localization boilerplate

Every string is a 3-line computed property that restates its own key:

```swift
static var verbs: String { String(localized: "Navigation.verbs") }
```

repeated ~100 times. Additional issues: duplicated properties across the
browse-view enums (`sortOrder`/`searchPrompt` in both `VerbBrowseView` and
`ModelBrowseView`), and inconsistent keys — `displayNameForVerbSort` returns
`String(localized: "alphabetical")` (no prefix) next to `"VerbSort.frequency"`
(prefixed), at lines ~599–617.

**Fix.**
- Migrate to a **String Catalog (`.xcstrings`)**, which gives type-safe access,
  unused-key detection, and plurals without wrapper code — eliminating most of the
  file.
- Until then: normalize the inconsistent keys, fold the shared browse strings into a
  common enum, and move `displayNameForVerbSort`/`…ModelSort` onto the sort enums as
  `var displayName` so the switch lives with the type.

---

## 8. Settings.swift — repeated `didSet`-persist boilerplate, behind a thin protocol

Seven properties each repeat the same `didSet { if oldValue != … { getterSetter.set(…) } }`
pattern plus init-time loading (~lines 16–133). The backing `GetterSetter` protocol
and its two implementations (`DictionaryGetterSetter`, `UserDefaultsGetterSetter`)
are one-line wrappers over `dict[key]` / `UserDefaults.string(forKey:)` that add
little abstraction beyond "get/set a string".

**Fix.** A `@SettingsPersisted(key:default:)` property wrapper collapses each property
to a single line and centralizes the persistence rule. The `GetterSetter` seam can
stay (it's what enables the in-memory test config) but the per-property boilerplate
should not.

---

## 9. XML parsers share un-extracted boilerplate

`VerbParser`, `VerbModelParser`, `DefectGroupParser`, `FrequencyParser` each repeat:
the `Bundle.url(forResource:) → XMLParser(contentsOf:) → delegate = self` setup, a
pile of private "current element" state vars, mirror-image `reset()` methods, and
attribute extraction that `fatalError`s on a missing required key.

**Fix.**
- A `BaseXMLParser` (or a small `func makeParser(resource:) -> XMLParser?`) removes
  the setup triplication.
- A helper `attribute(_:required:)` centralizes the missing-attribute handling and
  lets you swap `fatalError` for a thrown error (these parse bundled resources, so
  failure today = launch crash with no diagnostics).
- None of the parsers are unit-tested — see item 12.

---

## 10. Tense.swift — four parallel switches that all extract the same `personNumber`

`pronounWithGender`, `pronoun`, `gender`, and `pronounDecorator` (lines ~168–202)
each switch over all ~17 tense cases to pull out the associated `PersonNumber`, then
transform it differently.

**Fix.** Add one `var personNumber: PersonNumber?` that does the extraction once; the
four properties become `personNumber?.pronoun ?? …`. Removes ~60 lines and one place
to forget a case when a tense is added.

---

## 11. VerbModel.swift — five identical "resolve up the parent chain" properties

`stemAlterationsRecursive`, `participeEndingRecursive`, `passéSimpleGroupRecursive`,
`indicatifPrésentGroupRecursive`, `subjonctifPrésentGroupRecursive` (lines ~116–174)
all follow "use local if present, else recurse into parent, else `fatalError`".

**Fix.** A single generic resolver parameterized by `KeyPath` collapses all five:

```swift
private func resolved<T>(_ keyPath: KeyPath<VerbModel, T?>) -> T { … }
```

Also routes the five `fatalError`s through one spot.

---

## 12. Test coverage gaps and generated-test smell

- **Quiz.swift has zero tests** despite being a stateful machine (start/in-progress/
  finished, timer, scoring, question generation, difficulty). Highest-value place to
  add coverage.
- **Parsers are untested** — a format change could silently corrupt the bundled data.
- **`VerbModelTests.swift` is ~5,500 lines of generated test functions**, produced by
  `TestUtils.generateVerbModelTests()` which `print`s Swift source. It's effectively
  un-maintainable by hand and bloats the repo. Consider parameterized / table-driven
  Swift Testing cases instead of 96 generated functions.
- **`CompoundTenseTests`** hand-rolls `personNumbersIndex` wrap-around in ~14 loops
  with hard-coded expected-string arrays — fragile if `PersonNumber.allCases` order
  changes. Extract a `testConjugations(verb:expectedByTense:)` helper.
- **`DeeplinkTests`** crams several scenarios into single test functions and hard-codes
  `"parler"` / `Info.infos[2]`; derive fixtures from the real data instead.

---

## 13. Smaller cleanups (low effort, low risk)

- **`AnalyticsLocale.swift:24`** — `let 🏴󠁧󠁢󠁥󠁮󠁧󠁿👅 = "en"` (flag+tongue emoji identifier).
  Rename to `englishCode`. It's ungreppable and a review hazard.
- **`RealAnalyticsLocale.swift:12–13`** — `none = "none"` and `NONE = "NONE"` used
  inconsistently as sentinels; collapse to one named constant.
- **`DoubleExtension.swift`** — builds a `NumberFormatter` on every call; hoist to a
  cached `static let`.
- **`IntExtension.swift`** — `NSString(format:)` for H:MM:SS; use Swift
  `String(format:)` / native arithmetic.
- **`SoundPlayer.swift:20,29`** — `catch {}` silently swallows audio-session errors;
  at least log them.
- **`StringExtensions.swift`** — the ~103-line `attributedText` delimiter parser
  (lines ~115–193) is a nested state machine that iterates the ranges twice and
  `fatalError`s on bridging/encoding edge cases; split into
  `parse → applyAttributes → stripSeparators` and prefer guards over `fatalError`.
- **`GameCenter.swift:19–41`** — nested completion handler with an escaping `Task`;
  convert to `async/await`.
- **`URLExtensions.swift`** — hard-coded `"conjuguer"` scheme and `pathComponents ==
  2` magic; pull into named constants.
- **`World.swift:13`** — `@MainActor var Current = World.chooseWorld()` is global
  mutable state read throughout the app. It's load-bearing (it's the DI seam) so this
  is a long-term note, not a quick fix: prefer injecting `World` via the SwiftUI
  environment so views don't reach for a global. Lower priority than the duplication
  items above.

---

## Suggested order of attack

1. **Quiz cycling properties (#1)** — biggest line reduction for least risk, no
   behavior change.
2. **`*Group` ending tables (#2)** and **Tense/VerbModel switch collapses (#10, #11)**
   — mechanical, well-covered by existing VerbModel tests.
3. **StemAlteration table (#6)** — removes the worst single switch; add a unit test
   while you're there.
4. **Browse view extraction (#4)** and **InputView de-business-logic-ing (#5)** —
   larger but high payoff for view maintainability.
5. **Conjugator decomposition + error handling (#3)** — do alongside adding Quiz and
   parser tests (#12) so you have a safety net.
6. **L.swift → String Catalog (#7)** and **Settings property wrapper (#8)** — nice
   modernizations once the core is stable.
7. **Item #13 grab-bag** — knock these out whenever you touch the file.
