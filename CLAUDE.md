# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This project uses the **`ios-build-verify` Claude Code skill** for building, testing,
and verifying the app. The build/test scripts pipe `xcodebuild` through `xcbeautify`
for concise output and tee raw output to `build.log` as a fallback. Per-project
configuration lives at `.claude/ios-build-verify.config.sh` (target sim: iPhone 17 /
iOS 26; scheme: `Conjuguer`) and is sourced by every script.

Scripts live under the skill's install path. Resolve it once, then invoke by name:

```bash
export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")

# Build the app
"$IBV_SCRIPTS/build_app.sh"

# Run all tests
"$IBV_SCRIPTS/run_tests.sh"

# Run a single suite or method (Swift Testing form: Target/Suite/method() — note trailing ())
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/VerbModelTests
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/CompoundTenseTests/testCompoundTenses
```

### Verifying the app (simulator-driven)

The skill can launch the app and inspect/drive the UI so changes can be verified
beyond unit tests:

```bash
"$IBV_SCRIPTS/launch_app.sh"                 # build first, then boot + install + launch + wait-for-render
"$IBV_SCRIPTS/screenshot.sh <context-slug>"  # capture a PNG under docs/screenshots/
"$IBV_SCRIPTS/describe_ui.sh"                # dump the accessibility tree
"$IBV_SCRIPTS/tap_tab.sh <verbs|models|quiz|info|settings>"  # tap a main tab
```

The launch anchor is `verb_browse_sort` (the sort `Picker` in `VerbBrowseView`). Add
more `.accessibilityIdentifier`/`.accessibilityValue` modifiers on a migration-by-use
basis as verification flows need them. See the skill's `SKILL.md` for the full verify
surface (named-intent ops, annotation checks, iOS 26 control caveats).

#### Accessibility identifiers added so far

| Identifier | Element | Notes |
|---|---|---|
| `verb_browse_sort` | Sort `Picker` in `VerbBrowseView` | Launch anchor (`FIRST_SCREEN_ID`). |
| `input_quiz_conjugation` | Answer `TextField` in `QuizView` | Carries `.accessibilityValue(input)`, so `read_value`/`set_value`/`type_text --id` work with read-back. |
| `picker_settings_quizDifficulty` | Quiz-difficulty segmented `Picker` in `SettingsView` | 2 segments (Regular, Ridiculous). |
| `picker_settings_pronounGender` | Pronoun-gender segmented `Picker` in `SettingsView` | 3 segments (Feminine, Masculine, Both). |

List rows (verbs, models, info headings) and tab buttons are not yet annotated —
drive them by `AXLabel` / `tap_tab.sh` for now.

#### iOS 26 control caveats specific to this app

- **Accented input (é, è, à, ç, …):** `axe type` rejects non-ASCII. The skill's
  `set_value.sh` / `type_text.sh` (v0.3.0+) auto-route non-ASCII through a
  `simctl pbcopy` + Cmd+V pasteboard fallback, so French conjugations enter
  correctly. The quiz field is reachable by id, so prefer `type_text.sh --id
  input_quiz_conjugation "<answer>"` (gives read-back); the field also auto-focuses
  after **Start**, so a bare `axe type` into the focused field also works for ASCII.
- **Segmented pickers** render with empty AXTree children on iOS 26, so segments
  aren't individually addressable by id. The parent identifier locates the control's
  frame; `verify_segment.sh` then verifies a segment's label + selected state, but
  **requires `--segments N` explicitly** (it can't infer the count through the
  children-empty bug): `--segments 2` for `picker_settings_quizDifficulty`,
  `--segments 3` for `picker_settings_pronounGender`. To *drive* a selection, compute
  the segment center from the id'd frame (`x + width*(i+0.5)/N`, `y + height/2`) and
  `tap_xy.sh`.

#### Completing a quiz (regular difficulty)

A regular-difficulty quiz is 30 questions; `Quiz.process(_:)` advances on every
submission regardless of correctness, so completion = submit an answer to all 30.
After **Start**, the answer field auto-focuses; type into `input_quiz_conjugation`
and send Return (`axe key 40`) per question. The `Progress: N / 30` label tracks
position; the run ends with a `QuizResultsView` sheet (label `Results`).

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

## Architecture Overview

Conjuguer is an iOS app for learning French verb conjugations. It conjugates 6,320 verbs across all French tenses.

### Core Domain Model

- **Verb** (`Models/Verb.swift`): Represents a French verb with properties like infinitif, translation, model reference, auxiliary (avoir/être), and frequency data. Stored in a static dictionary keyed by infinitif.

- **VerbModel** (`Models/VerbModel.swift`): Defines conjugation patterns. Models form a hierarchy via `parentId` for inheritance of conjugation rules. Each model specifies stem alterations, endings for different tense groups, and participe endings.

- **Conjugator** (`Models/Conjugator.swift`): The conjugation engine. Takes an infinitif and tense, retrieves the verb and its model, applies stem alterations, and returns the conjugated form. Handles both simple and compound tenses.

- **Tense** (`Models/Tense.swift`): Enum covering all French tenses (indicatif présent, passé composé, subjonctif, etc.). Uses associated values for person/number where applicable.

### Data Loading

Verb and model data is loaded from XML files at app startup in `AppLauncher.swift`:
- `verbs.xml` - All 6,314 verbs
- `verbModels.xml` - Conjugation pattern definitions
- `frequencies.xml` - Verb frequency-of-use data
- `defectGroups.xml` - Defective verb groups

### Dependency Injection

The `World` pattern (`Utils/World.swift`) provides dependency injection via a global `Current` variable. Three configurations exist:
- `device` - Production with real analytics (AWS Amplify/Pinpoint), GameKit, real URLSession
- `simulator` - Uses test analytics/GameCenter, stubbed URLSession
- `unitTest` - Uses in-memory settings (DictionaryGetterSetter), test doubles

### SwiftUI Structure

- **MainTabView**: Root view with 5 tabs (Verbs, Models, Quiz, Info, Settings)
- Uses `@Observable` macro (iOS 17+) for the World class
- Deep linking support via `onOpenURL` for verb/model/info navigation

### Key Utilities

- **Settings** (`Utils/Settings.swift`): User preferences via protocol-based storage (UserDefaults or Dictionary)
- **L** (`Models/L.swift`): Localization strings wrapper
- **SoundPlayer/Utterer**: Audio feedback for quiz interactions
