# Conjuguer — Code Improvement Suggestions

A review of the `Conjuguer/` source tree (≈8,600 lines of Swift across 89 files) focused
on **duplication, inelegant code, and code smells**. Findings are ordered **most impactful
to least**. Each item has concrete `file:line` anchors and a sketch of the fix.

The codebase is in good shape overall — the `World` dependency-injection pattern, the
recent `VerbConjugations` extraction, the thoughtful `nonisolated` concurrency annotations,
and the existence of a test suite are all strengths. The items below are about paying down
specific, localized debt.

---

## 1. Collapse the conjugation `Result` / `fatalError` boilerplate (highest leverage)

`Conjugator.conjugate(...)` returns `Result<String, ConjugatorError>`, but **almost every
caller immediately unwraps it with the same `switch` and `fatalError`s on failure**, which
both defeats the purpose of the `Result` and copies the same 5 lines dozens of times.

Representative sites:
- `Conjugator.printConjugations` — ~10 copies (`Conjugator.swift:272-407`)
- `InputView.conjugate` — ~10 copies (`InputView.swift:140-260`)
- `Verb.personlessConjugations` — a nested pyramid of three `switch`es (`Verb.swift:76-98`)
- `VerbConjugations.rawConjugation` (`VerbConjugations.swift:123-130`)
- `Tense.conjugatedAuxilliary` (`Tense.swift:130-136`)
- `Conjugator.nousPrésentStem` (`Conjugator.swift:244-253`)

**Fix:** add one convenience that expresses the two real intents — "give me the string, and
trap only if this is a programmer error" vs. "give me the string or nil":

```swift
extension Conjugator {
  /// Returns the conjugation, or nil on data-driven failure (unknown verb, defective form…).
  static func conjugatedString(infinitif: String, tense: Tense, extraLetters: String? = nil) -> String? {
    guard case .success(let value) = conjugate(infinitif: infinitif, tense: tense, extraLetters: extraLetters) else {
      return nil
    }
    return value
  }
}
```

`VerbConjugations.rawConjugation` then becomes one line, `Verb.personlessConjugations`'
13-line pyramid becomes a `compactMap`, and the debug dumps (see #2) fold into loops. This
single helper removes well over 100 lines and stops scattering `fatalError` across the
conjugation surface.

---

## 2. De-duplicate the Quiz "cycling deck" machinery (~200 lines → ~30)

`Quiz.swift` maintains **13 parallel sets of**: a backing array, an index, a reset, a
shuffle, and a 6-line computed property that increments-with-wraparound and returns an
element. They are byte-for-byte identical except for the names.

- 13 array/index pairs: `Quiz.swift:29-54`
- `resetIndices()` resets all 13: `Quiz.swift:92-106`
- `randomizePersonNumbersAndVerbs()` shuffles all 13: `Quiz.swift:108-124`
- 13 near-identical computed getters: `Quiz.swift:209-311`

**Fix:** introduce a small value type and store the decks in a dictionary (or just as
fields), eliminating `resetIndices`, `randomizePersonNumbersAndVerbs`, and all 13 getters:

```swift
struct CyclingDeck<Element> {
  private let elements: [Element]
  private var index = 0
  init(_ elements: [Element], shuffled: Bool) {
    self.elements = shuffled ? elements.shuffled() : elements
  }
  mutating func next() -> Element {
    defer { index = (index + 1) % elements.count }
    return elements[index]
  }
}
```

`start()` rebuilds the decks instead of resetting + reshuffling 13 things by hand.

Two things this surfaces:
- **Latent off-by-one.** The current getters do `index += 1` *before* returning (e.g.
  `Quiz.swift:210-214`), so on the first lap element `[0]` of each deck is skipped and `[1]`
  is returned first. Harmless under shuffling, but it's an accidental behavior worth fixing
  in passing (the sketch above returns `[0]` first).
- **Dead deck.** `subjonctifPrésentStemChangerVerb` (`Quiz.swift:281-287`) and its backing
  array/index are never consumed by `buildQuiz()` — only `indicatifPrésentStemChangerVerb`
  is used (`Quiz.swift:141`). Drop it (see #3).

---

## 3. Delete dead code

Confirmed unreferenced (grepped the whole `Conjuguer/` tree):

| Symbol | Location | Notes |
|---|---|---|
| `Conjugator.printConjugations(infinitif:)` | `Conjugator.swift:256-409` | ~155 lines, never called. Also **ignores its `infinitif` parameter** and hardcodes `"alunir"` (`Conjugator.swift:257`), then shadows the param — a latent bug frozen in dead code. |
| `Verb.personlessConjugations` | `Verb.swift:76-98` | Never called; superseded by `VerbConjugations.personless`. |
| `Tense.tensesFor(shorthand:)` | `Tense.swift:240-244` | Stub that ignores its argument and always returns `[.indicatifPrésent(.firstSingular)]`. Referenced only by a TODO. |
| `Tense.allIndicatifPrésentTenses` | `Tense.swift:246-252` | Unused. |
| `String.replaceFirstOccurence` | `StringExtensions.swift:46-51` | Unused (and misspelled — "Occurence"). |
| `Quiz.subjonctifPrésentStemChangerVerb` (+ array/index) | `Quiz.swift:47-48, 281-287` | Computed but never turned into a question. |

That's ~200 lines removable with zero behavior change.

---

## 4. `Tense` has four identical 17-case switches

`pronounWithGender`, `pronoun`, `gender`, and `pronounDecorator` (`Tense.swift:168-202`)
each spell out the same giant list of every person-number-bearing case purely to pull out
the associated `PersonNumber`.

**Fix:** add one helper and make the four properties one-liners:

```swift
var personNumber: PersonNumber? {
  switch self {
  case .participePassé, .participePrésent, .radicalFutur:
    return nil
  case .indicatifPrésent(let pn), .passéSimple(let pn), .imparfait(let pn),
       .futurSimple(let pn), .conditionnelPrésent(let pn), .subjonctifPrésent(let pn),
       .subjonctifImparfait(let pn), .impératif(let pn), .passéComposé(let pn),
       .plusQueParfait(let pn), .passéAntérieur(let pn), .passéSurcomposé(let pn),
       .futurAntérieur(let pn), .conditionnelPassé(let pn), .subjonctifPassé(let pn),
       .subjonctifPlusQueParfait(let pn), .impératifPassé(let pn):
    return pn
  }
}

var pronoun: String { personNumber?.pronoun ?? L.QuizView.none }
var gender: String { personNumber?.gender ?? L.QuizView.none }
var pronounWithGender: String { personNumber?.pronounWithGender ?? L.QuizView.none }
var pronounDecorator: String { personNumber.map { " - \($0.pronounWithGender)" } ?? "" }
```

`conjugatedAuxilliary` (`Tense.swift:104`) can also key off this, and the same `personNumber`
projection would simplify the big `switch` in `VerbConjugations.conjugationParts`
(`VerbConjugations.swift:95-120`). ~70 lines → ~25.

---

## 5. The person-number ⇄ shorthand "codec" is triplicated across three files

The mapping between tense/person and the XML shorthands (`r1s`, `b3p`, `xA`, `pp`, `sf`…)
is implemented by hand in **both directions in three places**, with no single source of truth:

- decode, string → `Tense`: the ~90-line `switch` in `StemAlteration.init` (`StemAlteration.swift:47-150`)
- encode, `Tense` → string: `Tense.shortDisplayName` (`Tense.swift:139-166`)
- `PersonNumber.shortDisplayName` ⇄ `personNumberForShortDisplayName` (`PersonNumber.swift:144-159, 235-252`)
- the abandoned `Tense.tensesFor(shorthand:)` stub (#3) was meant to unify this — there's even
  a TODO admitting it: `StemAlteration.swift:45`.

Because the two directions are maintained separately, they can silently drift. **Fix:** define
the shorthand↔Tense correspondence once (a table, or finish `tensesFor` and derive
`shortDisplayName` from it), then have both `StemAlteration.init` and the display path consult
it. This is the most error-prone duplication in the project even though it's not the largest.

---

## 6. The two debug "conjugation dump" routines are the same code twice

`Conjugator.printConjugations` (dead — see #3) and `InputView.conjugate`
(`InputView.swift:130-270`) build the same labeled, multi-tense debug string with the same
repeated per-tense loops. Note that `VerbConjugations.simpleSpecs`
(`VerbConjugations.swift:38-47`) **already** encodes "tense builder + applicable person
numbers." The surviving debug dumper should iterate that spec list:

```swift
for spec in VerbConjugations.simpleSpecs {
  let forms = spec.personNumbers.compactMap {
    Conjugator.conjugatedString(infinitif: verb, tense: spec.builder($0), extraLetters: extraLetters)
  }
  output += " • \(spec.builder(spec.personNumbers[0]).titleCaseName): \(forms.joined(separator: " "))"
}
```

Delete `printConjugations` outright; reduce `InputView.conjugate` from ~140 lines to ~15.

---

## 7. `endings(stemAlterations:)` is duplicated across the tense-group enums

The "find alterations whose `charsToUse` ends in the irregular marker, then emit either the
marker or the normal ending per person" logic is copy-pasted:

- `IndicatifPrésentGroup.endings` (`IndicatifPresentGroup.swift:123-147`)
- `IndicatifPrésentGroup.impératifEndings` (`IndicatifPresentGroup.swift:198-220`)
- `SubjonctifPrésentGroup.endings` (`SubjonctifPresentGroup.swift:82-104`)

They differ only in which `Tense` case wraps the `PersonNumber`. Additionally, the plain
"loop `allCases`, append `ending + " "`" pattern recurs in `PasséSimpleGroup.endings`
and `subjonctifImparfaitEndings` (`PasseSimpleGroup.swift:114-120, 202-208`). A single free
function parameterized by a `(PersonNumber) -> Tense` builder and an
`(PersonNumber) -> String` ending-provider would absorb all of these.

---

## 8. `fatalError` is used as routine error handling (59 occurrences)

Many `fatalError`s sit on paths that depend on **data** (the XML files, and the user-editable
verb DB in `InputView`), not just on programmer invariants. Examples:
`composedConjugation` / `moveCircumflexIfNeeded` trap on an empty stem
(`Conjugator.swift:231, 252`); `VerbConjugations.rawConjugation` traps on any conjugation
failure (`VerbConjugations.swift:128`); both XML parsers `fatalError` on a missing attribute
(`VerbParser.swift:56`, `VerbModelParser.swift:50`, `StemAlteration.swift:149`).

For a shipping app this is "crash on malformed data." Reserve `fatalError` for genuine
invariants; for data-driven failures, surface a recoverable error (the `Result` machinery is
already there — see #1) or skip the offending entry during parse. At minimum, audit the 59
sites and downgrade the data-dependent ones.

---

## 9. `VerbModel` correctness smells

- **Mutation while iterating the dictionary.** `computeIrregularities()` and `sortVerbs()`
  loop `for model in models { models[model.value.id]?… = … }` (`VerbModel.swift:90-114`). It
  works only because they mutate values, not the dictionary's structure — fragile and a
  double-read. Iterate `models.keys` (snapshotted) or build a fresh dictionary.
- **Suspicious `futurStemsRecursive` loop** (`VerbModel.swift:210-214):
  ```swift
  stems.forEach {
    if $0.last == "e" { stems[0] = String(stems[0].dropLast()) }
  }
  ```
  It iterates *every* stem but only ever trims `stems[0]`, keyed off each element's last
  character. For the alternate-stem case (`stems.count > 1`) this almost certainly does the
  wrong thing. Worth a unit test for a multi-stem future (e.g. *payer*/*pouvoir*) and a fix to
  trim the matching element.
- **`maxIrregularityCount = 41`** is a magic constant embedded in the percentage math
  (`VerbModel.swift:104`) with no explanation — name and comment it.

---

## 10. `World.handleURL` and `handleInAppURL` are near-duplicates

The two methods (`World.swift:114-175`) differ only in (a) clearing the sibling entities and
(b) switching `selectedTab`. Extract the shared host→entity resolution into one private helper
and let each caller decide whether to also reset siblings/tab. (The intentional difference is
well documented at `World.swift:146-151` — keep that comment on the extracted seam.)

---

## 11. `Settings.init` repeats the same load-or-default block seven times

`Settings.swift:93-133` is seven copies of "if a saved string exists, parse it (falling back
to the default); otherwise write the default." A small generic helper collapses each to one
line:

```swift
private func load<T>(_ key: String, default def: T, parse: (String) -> T?) -> T {
  if let raw = getterSetter.get(key: key) { return parse(raw) ?? def }
  getterSetter.set(key: key, value: "\(def)")  // or a supplied encoder
  return def
}
```

(The encode side varies — some use `rawValue`, some `"\(value)"`, the date uses a formatter —
so pass an encoder closure too, or standardize on a tiny `SettingsCodable` protocol.)

---

## 12. Two parallel "color the irregular letters" implementations

The app has two independent renderers that color uppercase (irregular) letters red and the
rest blue/regular:

- the modern `AttributedString(mixedCaseString:)` (`ConjugationText.swift:15-76`), used by the
  current verb/model views, and
- the legacy `String.conjugatedString` + `String.attributedText` `NSAttributedString` path
  (`StringExtensions.swift:53-206`), still used to render the Info articles (`Info.swift:21`,
  `TextView.swift`).

`attributedText` in particular is a 100-line hand-rolled markup parser (custom `` ` ``, `~`,
`%`, `$` delimiters with manual index bookkeeping). Long-term, migrating the Info text to
`AttributedString` (and `AttributedString(markdown:)` where possible) would let you retire the
entire `NSAttributedString` path and keep a single coloring implementation. Larger effort, so
ranked lower, but it removes a whole category of fiddly code.

---

## 13. Smaller cleanups

- **`composedConjugation`** uses a manual `hasAppendedAtLeastOneConjugation` flag
  (`Conjugator.swift:208-223`) to interleave a separator — that's `map { … }.joined(separator:)`.
- **`moveCircumflexIfNeeded`** linear-scans a 10-tuple array and never `break`s after the match
  (`Conjugator.swift:235-239`); a `[Character: Character]` lookup is clearer and O(1). The same
  accent→bare-vowel tables are re-declared inline in `ConjugationResult.score`
  (`ConjugationResult.swift:22-35`) — lift the diacritic maps to one shared place.
- **`Tense.shorthandForNonCompoundTense`** (`Tense.swift:204-238`) hand-unrolls a 6-way
  `contains(...) && … && …` and joins with a manual counter; `Set.isSubset(of:)` plus
  `.joined(separator: ", ")` express it directly.
- **Naming/typos (public-ish surface):** `conjugatedAuxilliary` (double "l",
  `Tense.swift:104`), `replaceFirstOccurence` (missing "r"), and the `"inpat"` debug strings
  in `InputView` (`InputView.swift:77, 82`).
- **`AttributedString(markdown:)` swallowing errors** in `VerbModel.verbsWithDeepLinks`
  returns `""` on `catch` (`VerbModel.swift:77-79`) — fine, but log it so a malformed verb
  link isn't silently invisible.

---

### Suggested sequencing

1. **Quick wins first:** #3 (delete dead code) and #1 (the `conjugatedString` helper) unblock
   #2, #6, and #8 and are low-risk.
2. **Then the big concentrated refactors:** #2 (Quiz decks) and #4 (Tense `personNumber`).
3. **Then the cross-file consolidations:** #5 (shorthand codec), #7 (group endings), #9–#11.
4. **Leave #12** (NSAttributedString retirement) for a dedicated pass — it's the largest and
   touches the Info-rendering UI.

Each item is independently shippable, and the existing `ConjuguerTests` suite (plus the
`ios-build-verify` skill) should be run after each to confirm no conjugation regressions.
