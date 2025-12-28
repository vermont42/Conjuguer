# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This is an Xcode project. Use the following commands:

```bash
# Build the app
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 16' test

# Run a single test class
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:ConjuguerTests/VerbModelTests

# Run a single test method
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:ConjuguerTests/CompoundTenseTests/testCompoundTenses
```

## Architecture Overview

Conjuguer is an iOS app for learning French verb conjugations. It conjugates 6,314 verbs across all French tenses.

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
