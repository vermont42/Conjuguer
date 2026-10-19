---
paths:
  - "ConjuguerWidget/**"
  - "Shared/**"
---

# Widget Localization (WidgetL)

The `ConjuguerWidget` extension ships as its own `.appex` bundle with its **own** string
catalog, `ConjuguerWidget/Localizable.xcstrings` — separate from the app's
`Conjuguer/Assets/Localizable.xcstrings`. Widget user-facing strings (gallery
names/descriptions, Control Center labels, Live Activity title, quiz "Correct!"/"Incorrect")
route through `WidgetL` (`Shared/WidgetL.swift`), the widget's analogue to the app's `L`.
Its keys are namespaced under a flat `Widget.*` prefix (e.g. `Widget.verbOfTheDayName`),
grouped into enums for call-site clarity.

Unlike the app's `L` (whose accessors return `String` via `String(localized:)`), every
`WidgetL` accessor is a single style — a `static let` `LocalizedStringResource(key,
defaultValue:)`, with the English source carried inline as `defaultValue`:

```swift
enum WidgetL {
  enum VerbWidget {
    static let name = LocalizedStringResource("Widget.verbOfTheDayName", defaultValue: "Verb of the Day")
    static let description = LocalizedStringResource("Widget.verbOfTheDayDescription", defaultValue: "A daily French verb with its présent conjugations.")
  }
}
```

**Exception — AppIntent titles and `@Parameter(title:)` cannot route through `WidgetL`.**
`appintentsmetadataprocessor` parses source statically and requires a string literal or a
direct `LocalizedStringResource(...)` initializer call, not an accessor. So the intent
metadata keys (`Widget.intentOpenQuiz`, `Widget.intentOpenRandomVerb`,
`Widget.intentAnswerQuiz`, `Widget.paramQuestionID`, `Widget.paramSelectedAnswer`) are
written inline in `Shared/OpenQuizIntent.swift`, `Shared/OpenRandomVerbIntent.swift`, and
`ConjuguerWidget/AnswerQuizIntent.swift`.

`Shared/` compiles into **both** the app and widget targets, but **all `Widget.*` keys —
including the `Shared/` intents' — live only in the widget catalog**, not the app's. Add
new widget strings to `ConjuguerWidget/Localizable.xcstrings` and route them through
`WidgetL` (or inline, for AppIntent metadata).
