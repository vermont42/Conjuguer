![Conjuguer](Images/Splash.png "Conjuguer's Launch Screen")

Conjuguer
=========

**Conjuguer** is an iOS™ app for learning French verb conjugations. **Conjuguer** conjugates 6,320 verbs, regular and irregular, in _all_ French verb tenses.

**Conjuguer** is available for free download in the iOS App Store™. Tap the button below to install.

[![Install](apple.png)](https://apps.apple.com/us/app/conjuguer/id1588624373)

Alternatively, you can clone this repo and build **Conjuguer** yourself.

While developing **Conjuguer** in 2021, I learned about SwiftUI and how to mix it with UIKit. The app is now SwiftUI throughout, apart from a small UIKit shim that hosts Game Center's authentication UI.

### Features

- **Verb browser** — all 6,320 verbs, searchable and sortable by frequency of use or alphabetically, in a list or a grid.
- **Conjugation views** — every tense for a given verb, with irregular stems and endings picked out in red so that the shape of an irregularity is visible at a glance. Many verbs also carry an etymology and an example sentence drawn from French literature.
- **Verb models** — the conjugation patterns that the verbs inherit from, ranked by how irregular they are.
- **Tense reference** — an explanation of each French tense, when to use it, and how it is formed, illustrated with quotations from Proust, the _Chanson de Roland_, and others.
- **Conjugation quiz** — two difficulty levels, scoring that gives partial credit for a correct skeleton with a dropped accent, a Live Activity, and Game Center leaderboards.
- **AI tutor** — answers French-conjugation questions on-device, powered by Apple's Foundation Models. Requires Apple Intelligence.
- **Widgets and controls** — a "Verb of the Day" and a tappable daily quiz on the Home Screen and Lock Screen, plus two Control Center controls.
- **Retro arcade minigame**, reachable from Settings.
- **Alternate app icons** — Arc de Triomphe, rooster, croissant, or beret.
- **English and French** localization throughout, with VoiceOver labels that switch pronunciation between the two languages so that French forms are not read aloud as English.

### Screenshots

| Verb List | Verb | Verb-Model List | Verb Model | Quiz |
| --- | --- | --- | --- | --- |
| <img src="Images/verb-browse.png" width="190"> | <img src="Images/verb.png" width="190"> | <img src="Images/model-browse.png" width="190"> | <img src="Images/model.png" width="190"> | <img src="Images/quiz.png" width="190"> |

| Quiz Results | Tense List | Tense Description | Settings | Minigame |
| --- | --- | --- | --- | --- |
| <img src="Images/quiz-results.png" width="190"> | <img src="Images/tense-browse.png" width="190"> | <img src="Images/tense.png" width="190"> | <img src="Images/settings.png" width="190"> | <img src="Images/game.png" width="190"> |

### Building from Source

**Conjuguer** targets iOS 26 and builds with Swift 6. Open `Conjuguer.xcodeproj` in Xcode and build the
`Conjuguer` scheme.

Before your first build, create the gitignored `Conjuguer/Secrets.xcconfig` from its template. It holds
the analytics (TelemetryDeck) app ID, which is not checked in:

```bash
cp Conjuguer/Secrets.example.xcconfig Conjuguer/Secrets.xcconfig
```

Then fill in your own `TELEMETRY_DECK_APP_ID` (or leave the placeholder — the app builds and runs
either way; analytics simply go nowhere).

To run SwiftLint on each commit, enable the repo's pre-commit hook once per clone:

```bash
git config core.hooksPath .githooks
```

Further documentation lives in [`docs/`](docs), starting with the annotated directory tree in
[`docs/project-structure.md`](docs/project-structure.md).

### License

**Conjuguer** is licensed under the GNU General Public License in order to discourage release of low-quality clones to the App Store™. Conjugar briefly suffered this indignity.
