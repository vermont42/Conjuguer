# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Work journal (blog notes)

As you complete chunks of work in this repo, append a note to `docs/blog_notes.md`,
creating the file if it doesn't exist. Give each entry a `##` heading that includes the
date — `## <Title> (YYYY-MM-DD)` — with newest entries at the bottom. Write narrative
for a future reader (what was tried, what failed, why decisions changed), not a bare
changelog: Josh may eventually generate blog posts from these notes, and future Claude
sessions rely on them as dated project memory — when older docs conflict, the journal
shows which truth is current.

## Prose style

Generated prose, wherever it lands (release notes, App Store copy, journal entries, commit
messages, comments, replies to Josh), must never use an em dash to join two clauses that
each have a subject and a predicate. Start a new sentence instead; that is usually best.
Less often, a semicolon is appropriate. The rule is about clauses; an em dash around a
parenthetical aside or a list gloss that is not itself a clause is not what it forbids.

## Version Control

**Commit directly to `main`. Do not create branches.** This is a solo project and the default
"branch before committing" reflex does not apply here. If you find yourself proposing a feature
branch, don't.

## Build and Test Commands

This project uses the **`ios-build-verify` Claude Code skill** for building, testing,
and verifying the app. The build/test scripts pipe `xcodebuild` through `xcbeautify`
for concise output and tee raw output to `build.log` as a fallback. Per-project
configuration lives at `.claude/ios-build-verify.config.sh` (target sim: iPhone 17 /
iOS 26; scheme: `Conjuguer`) and is sourced by every script.

Scripts live under the skill's install path. Resolve it once, then invoke by name:

Resolve it under `~/.claude/plugins/marketplaces`, **not** `~/.claude` broadly: the plugin
cache (`~/.claude/plugins/cache/ios-build-verify/<version>/`) holds several versions at once
and is shared across Josh's apps, and `find`'s directory order is unspecified — so the broad
glob silently picks an arbitrary release. The marketplace clone has no version segment and
yields exactly one match.

```bash
export IBV_SCRIPTS=$(dirname "$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")

# Build the app
"$IBV_SCRIPTS/build_app.sh"

# Run all tests
"$IBV_SCRIPTS/run_tests.sh"

# Run a single suite or method (Swift Testing form: Target/Suite/method() — note trailing ())
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/VerbModelTests
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/CompoundTenseTests/testCompoundTenses
```

> **Testing an unpublished change to the skill itself.** `ios-build-verify` is developed
> locally at `~/Desktop/workspace/ios-build-verify` but consumed from GitHub, so the
> resolved copy is always the *published* one. To exercise local edits, point the variable
> at the dev repo — `export IBV_SCRIPTS=~/Desktop/workspace/ios-build-verify/skills/ios-build-verify/scripts`
> — and unset it to return to the published copy. `scripts/take_screenshots.sh` honors a
> pre-set `IBV_SCRIPTS` too, so one export covers both.

### Verifying the app (simulator-driven)

Launching, screenshotting, and driving the app in the simulator (accessibility identifiers,
iOS 26 control caveats, sweeping a quiz to completion) is documented in the
`verify-in-simulator` skill (`.claude/skills/verify-in-simulator/SKILL.md`). Load it before
any simulator-driven verification, and keep its identifier table current when you add an
`.accessibilityIdentifier`. Remember that `launch_app.sh` does **not** compile: run
`build_app.sh` first, or the screenshots show the previous binary.

**SourceKit vs. the build:** editing a view file often triggers SourceKit "Cannot find
X in scope" diagnostics for same-module symbols. If `build_app.sh` succeeds, the build
is authoritative — do not "fix" SourceKit-only diagnostics.

### Diagnostic fallback (raw xcodebuild)

Useful when `xcbeautify`'s lossy filter drops an early-stage error. Prefer the skill
scripts as the default path so future sessions exercise the skill.

```bash
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:ConjuguerTests/VerbModelTests
```

### Linting

SwiftLint runs as a **git pre-commit hook** (`.githooks/pre-commit`), not as an Xcode
build phase, so it gates commits without slowing every build. It lints only the staged
Swift files with `--strict`, honoring `.swiftlint.yml`; any violation blocks the commit
(drop `--strict` in the hook to make warnings non-blocking). Enable it once per clone:

```bash
git config core.hooksPath .githooks
```

If `swiftlint` isn't installed the hook prints a warning and lets the commit through.

#### Rules worth pre-empting while writing (so the hook doesn't bounce a commit)

- **`conditional_returns_on_newline`** — a `guard`/`if` that returns must put the `return`
  on its **own line**, never inline. The project keeps this rule on purpose: one-statement-
  per-line makes stepping through control flow in the debugger easier (you can breakpoint
  the `return` itself and see whether the branch was taken). Write:

  ```swift
  guard etymologies == nil else {
    return
  }
  ```

  not `guard etymologies == nil else { return }`. The same applies to `if x { return }`,
  `guard … else { return nil }`, `… else { continue }`, etc. — break the body onto its own
  line. (Seen in practice: an inline `guard … else { return }` passed the build but blocked
  the commit under `--strict`.)

## Comments

Code should be well-written and therefore self-explanatory. Explanatory and MARK
comments result in clutter and increased maintenance burden. Only use comments for the
following purposes:

* File headers
* TODOs
* Hacks or workarounds

When reviewing or writing code, do not add — and do not flag as missing — comments
outside those purposes. The one carve-out is **durable, non-obvious rationale**: a
comment that answers "why is the code like this?" and states a fact a future reader
can't recover from the code itself — a French phonological/conjugation rule that
explains why an expected value looks wrong, a Swift-concurrency isolation constraint, an
ordering guarantee, a deliberate silent-failure/degrade-not-crash path, a measured
cold-start cost, a magic-number/color-hex explanation, or an SE-number/radar workaround.
A comment that merely restates the identifier or narrates the next line is clutter —
delete it. When a comment is borderline, lean toward deletion.

## Testing (Swift Testing)

The unit tests use **Swift Testing** and live in `ConjuguerTests/`, a synced folder. Their
conventions and gotchas (the shared `T.testConjugation` helper, the generated
`VerbModelTests.swift` that must be regenerated rather than hand-edited, `@MainActor` suites,
explicit `import Foundation`, serialized suites) are in `.claude/rules/swift-testing.md`,
which loads when you work under `ConjuguerTests/`.

## Architecture Overview

Conjuguer is an iOS app for learning French verb conjugations. It conjugates 6,326 verbs across all French tenses.

### Project Layout (synchronized folders)

See [`docs/project-structure.md`](docs/project-structure.md) for the full annotated
directory tree.

**Cache maintenance:** When you add, remove, or rename a source file, update
`docs/project-structure.md` to match. It is a cache — future contexts rely on it to orient
without re-reading the tree, so staleness has a real cost. A *wrong* entry costs more than
a *missing* one, because it gets believed; prioritize fixing renames and repurposed files.

`scripts/check_docs.py` enforces this — run it after moving, renaming, or adding source
files, or after editing docs:

```bash
python3 scripts/check_docs.py
```

It asserts three things a machine can settle: every relative Markdown link resolves, every
source file appears in `docs/project-structure.md`, and every file that doc names still
exists. Counts are deliberately *not* checked — `docs/blog_notes.md` and `prompts/`
describe the tree as it was, and asserting against them would report history as breakage.

The project uses **Xcode synchronized folders** (`PBXFileSystemSynchronizedRootGroup`),
not classic groups: the two target folders `Conjuguer/` and `ConjuguerTests/` are each
synced as a root group, and Xcode mirrors their on-disk contents into the targets by file
type. Practical consequences:

- **Adding a source, test, or resource file requires no `project.pbxproj` edit and no Xcode
  step** — just create the file on disk under the appropriate folder and it is compiled or
  bundled automatically (`.swift` → Sources, asset/`.xml`/`.json`/`.mp3`/etc. → Resources).
  Likewise, deleting a file needs no project edit. This is why new test classes get their own
  files (e.g. `DeeplinkTests.swift`) rather than being appended to an existing file.
- **All test doubles live in the app target** (`TestApp.swift`, `GetterSetterFake.swift`,
  `GameCenterStub.swift`, `ReviewPrompterDummy.swift`, `AnalyticsSpy.swift`,
  `URLProtocolStub.swift`), referenced by `World.swift` for the
  simulator/unitTest configs, so the whole `Conjuguer/` tree compiles into one target.
- The only files inside the synced folders excluded from a target are the per-target
  `Info.plist`s (via `membershipExceptions`); `Conjuguer.entitlements` is wired through
  `CODE_SIGN_ENTITLEMENTS` and is not bundled. Don't add new files under a synced folder that
  should *not* ship — they'd be picked up automatically; exclude them with a membership
  exception or keep them outside the folder.

### Data Loading

Verb and model data is loaded from XML files at app startup via `VerbData.parse()`:
- `verbs.xml` - All 6,330 entries / 6,326 distinct infinitives. Frequency ships inline as raw
  corpus hit counts (`hi` FrWaC, `hn` Le Monde, `hl` Frantext, `hs` Lexique 4 subtitles, `hp`
  when `hi` is an estimate); `VerbParser.ranked(_:)` derives the 1..n rank once per parse, so
  adding a verb never renumbers the file. The pipeline that produced them lives in
  `frequency/` — read `frequency/README.md` before touching the counts.
- `verbModels.xml` - Conjugation pattern definitions
- `defectGroups.xml` - Defective verb groups

(The 2021 `frequencies.xml` export is gone: it was bundled but never parsed. `Verb.rankCount`,
which `VerbData.publish` sets from the parse, holds the number of distinct infinitives —
the denominator `VerbView` shows.)

### Analytics (TelemetryDeck)

Analytics run through the `Analytics` protocol (`Analytics/Analytics.swift`): events are the
`AnalyticsName` enum, parameters keyed by `ParameterKey`, sent via
`Current.analytics.signal(name:parameters:)` (with a no-parameter `signal(name:)` convenience).
`AnalyticsReal` wraps the TelemetryDeck SDK; `AnalyticsSpy` records signals for tests. The
TelemetryDeck app ID is **kept out of the working tree**: it lives in `Conjuguer/Secrets.xcconfig`
(gitignored; copy `Conjuguer/Secrets.example.xcconfig` to create it), is exposed to the app target
as the `TELEMETRY_DECK_APP_ID` build setting via the target's `baseConfigurationReference`, surfaced
through the `TelemetryDeckAppID` Info.plist key, and read in `ConjuguerApp.init()` →
`Current.analytics.initialize(appID:)`. (Caveat: the ID leaked into an early `prompts/analytics.md`
commit and is therefore in git history — since redacted from the working tree. A TelemetryDeck app
ID ships inside the app binary and is not a signing credential, so the practical risk is low; rotate
it in the TelemetryDeck dashboard if you want the historical value fully retired.) (There is no `Locale` abstraction; the one VoiceOver site
that needed region/language reads `Locale.current` directly.)

### Protocol-Based Abstractions

All external services have protocol abstractions with production and test implementations, named in the Fowler test-double convention — `…Real` for the production conformer, `…Fake`/`…Stub`/`…Spy`/`…Dummy` for the double:
- `GetterSetter` → `GetterSetterReal` / `GetterSetterFake`
- `GameCenter` → `GameCenterReal` / `GameCenterStub`
- `ReviewPrompter` → `ReviewPrompterReal` / `ReviewPrompterDummy`
- `Analytics` → `AnalyticsReal` (TelemetryDeck) / `AnalyticsSpy`

> **Convention — adding a new behavior protocol with real + test-double conformances.** Name the protocol a **plain role noun** — no `-able`/`-Protocol`/`-ing` suffix (`GetterSetter`, `GameCenter`, `ReviewPrompter`). Name the production conformer `<Protocol>Real` and the test double `<Protocol><Role>`, where `<Role>` is the [Fowler test-double type](https://martinfowler.com/bliki/TestDouble.html) that matches what the double actually *does*:
> - **`Fake`** — a working implementation with a production-unsuitable shortcut, e.g. an in-memory store (`GetterSetterFake`).
> - **`Stub`** — returns canned answers, no real logic (`GameCenterStub`).
> - **`Spy`** — a stub that *also records* how it was called, for assertions (`AnalyticsSpy`).
> - **`Mock`** — pre-programmed with expectations it verifies. **`Dummy`** — fills a slot but is never exercised for its behavior (`ReviewPrompterDummy`).
>
> Because the protocol and all its conformers share a prefix, they **sort together in Xcode's Project Navigator** — the point of the convention (and consistent with the `CatFancy-final` app). One type per file, filename = type name (synced folders bundle them automatically). **Check for a name collision** before settling on the protocol name: the bare noun must be free, so the production type takes `…Real` (the protocol `GameCenter` is only available because the former `GameCenter` class became `GameCenterReal`). Wire the real conformer into `World.device` and the double into `World.simulator` / `.unitTest`. Doubles that conform to a **system** protocol rather than an app one stay outside the scheme — `URLProtocolStub` (Foundation `URLProtocol`) and `TestApp` (SwiftUI `App`, whose real counterpart is `ConjuguerApp`).

### Literature-Example Corpus (`corpus/`)

`corpus/` holds a build-time data pipeline (**not part of the shipped app target**)
that builds literature example sentences for the app's usage-ranked verbs. Its
folder layout, gitignore policy, build scripts, reflex-attachment policy, corpus
tiers/licensing, and coverage status are documented in
[`docs/literature-example-corpus.md`](docs/literature-example-corpus.md). Read that
doc before touching anything under `corpus/`.

## Localization System

The app ships in **English (source) and French** and uses a two-part localization system.

### L.swift

Type-safe localization accessors (`Conjuguer/Models/L.swift`), organized by feature into
nested enums. Each accessor wraps a `String(localized:)` call keyed by a stable identifier.

Accessors that interpolate a runtime value take arguments and pass a `defaultValue` (the
English source) — e.g. `L.QuizView.score(_:)`, `L.VerbView.sourceWikipedia(_:)`.

### Localizable.xcstrings

The app's string catalog is `Conjuguer/Assets/Localizable.xcstrings`. How to edit it safely
(an ASCII `"` added through the Edit tool breaks the JSON), search it, write its rich-text
markup, and relocalize long texts is in `.claude/rules/localization-catalog.md`, which loads
when you work with any `.xcstrings` file or `L.swift`.

**Do not reflexively `git checkout` the catalog after a build.** The build never rewrites it
(`SWIFT_EMIT_LOC_STRINGS = NO`), so a modified catalog in the working tree is a real change.
Inspect the diff and keep or discard it deliberately.

### Adding New Localized Strings

1. Add the accessor to `L.swift` in the appropriate enum
2. Add the key and translations (`en` + `fr`) to `Localizable.xcstrings`
3. Use via `L.FeatureName.stringName` in code

### Naming Conventions

- Keys follow the pattern: `FeatureName.stringPurpose`
- Examples: `Settings.pronounGender`, `Navigation.verbs`, `Info.creditsHeading`

### Widget Localization (WidgetL)

The `ConjuguerWidget` extension has its own catalog, `ConjuguerWidget/Localizable.xcstrings`,
and its own accessor enum, `WidgetL` (`Shared/WidgetL.swift`). All `Widget.*` keys, including
those the `Shared/` intents use, live only in the widget catalog. The details, including why
AppIntent titles can't route through `WidgetL`, are in `.claude/rules/widget-localization.md`.
