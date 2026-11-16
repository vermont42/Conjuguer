---
paths:
  - "ConjuguerTests/**"
---

# Testing (Swift Testing)

The unit tests use **Swift Testing** (`import Testing`): suites are `struct`s,
tests are `@Test func` methods, and assertions are `#expect(...)` / `Issue.record("…")`
(reach for `try #require(...)` when a later line depends on an unwrapped value). Tests live
in `ConjuguerTests/`, a synced folder — a new `*.swift` test file is compiled into the
target automatically, no `project.pbxproj` edit (see *Project Layout* in `CLAUDE.md`). Run them with
the `ios-build-verify` scripts documented under *Build and Test Commands*; the
`Target/Suite/method()` filter form (note the trailing `()`) is the Swift Testing spelling.

## Shared conjugation helper

`T.testConjugation(...)` in `TestUtils.swift` is the shared assertion for conjugation tests:
it conjugates and `#expect`s the result, recording an `Issue` on failure. It threads
`sourceLocation: SourceLocation = #_sourceLocation` so a failure points at the *calling*
test, not at the helper line. `VerbModelTests.swift` (one `@Test func` per model) is
**generated** by `T.generateVerbModelTests()`, which emits Swift Testing source — regenerate
it rather than hand-editing the 5,000-plus lines.

## Suites that touch `@MainActor` code need `@MainActor`

The app module defaults to `MainActor` isolation, so a suite that calls into app code — or
even just compares two app values inside `#expect` whose `Equatable` conformance is
main-actor-isolated (e.g. `RichTextBlock`, `TextSegment`, `ConjugationPart`) — must be
annotated `@MainActor`. Swift Testing runs tests off the main actor by default, and
**`@MainActor` does not propagate into nested `@Suite` structs** — annotate each one.
Symptom when it's missing:
`main actor-isolated conformance of '…' to 'Equatable' cannot be used in nonisolated context`.

## `import Foundation` explicitly

`import Testing` does **not** re-export Foundation transitively. A test file
that uses `URL`, `Date`, `JSONEncoder`, or Foundation string APIs (`replacingOccurrences`,
`.capitalized`, …) must `import Foundation` itself, or it fails with `cannot find 'URL' in
scope` / `property '…' is not available due to missing import of defining module 'Foundation'`.

## Serialize suites that share global state

Swift Testing runs suites and tests in parallel by default. Suites that mutate the global
`Current` (`DeeplinkTests`, `QuizTests`) or other shared static state (`SettingsTests`) are
marked `@Suite(.serialized)` so they don't race. There is no `setUp`; do per-test setup at
the top of each `@Test`. Note a parameterless `init()` used only for reset trips SwiftLint's
`unneeded_synthesized_initializer` on a struct with no stored properties, so use an explicit
helper (e.g. `resetCurrent()`) called from each test instead.

## Parameterized tests

When several tests differ only in input values, collapse them into one
`@Test(arguments: [...])` taking the tuple destructured across parameters —
`ConjugationResultTests` does this for its scoring cases, and a failure reports the offending
row. (Mind the `trailing_comma` lint rule: no comma after the last element of the arguments
array.)
