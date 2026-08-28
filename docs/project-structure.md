# Project Structure

Annotated directory tree for Conjuguer. This doc is a **cache**: it exists so a future
session can orient without re-reading the tree, which means staleness has a real cost.
When you add, remove, or rename a source file, update this file to match.

The two target folders (`Conjuguer/`, `ConjuguerTests/`) are Xcode **synchronized
folders**, so creating a file on disk is all it takes to compile or bundle it — there is
no `project.pbxproj` edit and no Xcode step, and nothing here needs registering anywhere
else. See CLAUDE.md, *Project Layout*.

```
Conjuguer/
├── Conjuguer.entitlements      # App Groups (widget sharing) + Game Center; wired via CODE_SIGN_ENTITLEMENTS, not bundled
├── Info.plist                  # App configuration (deeplink scheme, fonts, TelemetryDeckAppID key)
├── Secrets.example.xcconfig    # Template for the secrets config; copy to create the real one
├── Secrets.xcconfig            # TelemetryDeck app ID (gitignored; base configuration for the app target)
├── Analytics/
│   ├── Analytics.swift         # Analytics protocol, AnalyticsName event enum, ParameterKey enum
│   ├── AnalyticsReal.swift     # TelemetryDeck implementation; funnels calls onto a serial GCD queue because the SDK blocks with DispatchQueue.sync internally
│   └── AnalyticsSpy.swift      # Test spy recording signals for assertions
├── App/
│   ├── AppLauncher.swift       # Chooses TestApp vs ConjuguerApp based on the unit-test environment
│   ├── ConjuguerApp.swift      # Main entry point: verb-data load, onboarding cover, deeplinks, widget refresh, Tips.configure()
│   ├── TestApp.swift           # Minimal App for the unit-test environment
│   └── Preview Content/        # Preview-only asset catalog
├── Assets/
│   ├── Assets.xcassets/        # Colors (customBlue, customRed, …), app icons + their preview images, Adams/Compton/Splash images
│   ├── LaunchScreen.storyboard # Launch screen
│   ├── Localizable.xcstrings   # App-target string catalog (en/fr); see CLAUDE.md for the editing hazards
│   ├── PrivacyInfo.xcprivacy   # Privacy manifest for App Store submission
│   ├── Sounds/                 # MP3 effects for quiz and game (applause, buzz, chime, guns, ghost, robot, …)
│   └── WorkSans*.ttf           # Bundled Work Sans faces (regular, semibold, bold)
├── Models/
│   ├── AppIcon.swift           # Alternate app-icon enum (beret/croissant/rooster/arc de triomphe)
│   ├── Auxiliary.swift         # avoir/être auxiliary enum
│   ├── ChansonExample.swift    # Codable model for a Chanson de Roland example (laisse, line, old French, translation)
│   ├── chanson_examples.json   # Bundled Chanson de Roland examples keyed by infinitif
│   ├── ConditionnelPresent.swift  # Conditionnel présent endings
│   ├── ConjugationResult.swift # Answer scoring: total/partial/no match, plus its sound, score, icon, and color
│   ├── Conjugator.swift        # The conjugation engine: model lookup, stem alterations, simple and compound tenses
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── ConjuguerTips.swift     # TipKit tips (try the quiz, explore models, change difficulty, play game)
│   ├── CyclingDeck.swift       # Generic deck that deals elements in order and reshuffles on exhaustion
│   ├── DefectGroup.swift       # A group of defective verbs and the tenses/persons they lack
│   ├── DefectGroupParser.swift # XMLParser delegate for defectGroups.xml
│   ├── defectGroups.xml        # Defective-verb group definitions
│   ├── EndingDisplay.swift     # Builds $…$-marked ending strings (irregular chars uppercased) for model display
│   ├── Etymologies.json        # Bundled verb etymologies keyed by language and infinitif
│   ├── Etymology.swift         # Lazy-loading etymology lookup by infinitif
│   ├── Example.swift           # Codable model for a literature example sentence
│   ├── ExampleSource.swift     # Provenance enum for example sentences (Proust/Zola/Flaubert/La Fontaine/Molière/gov/Wikipedia/Claude) with per-source attribution
│   ├── FuturSimple.swift       # Futur simple endings
│   ├── ImageInfo.swift         # Image name + caption/credit for Info articles
│   ├── Imparfait.swift         # Imparfait endings
│   ├── IndicatifPresentGroup.swift    # Indicatif présent ending groups (e/extendedS/s/ï/r/…) and their XML mapping
│   ├── Info.swift              # Info article model, the static article list, and InfoCategory (about/concepts/tenses)
│   ├── L.swift                 # Type-safe localization accessors, nested by feature
│   ├── LanguageModelService.swift      # Protocol for the on-device tutor, plus TutorMessage and unavailability/error enums
│   ├── LanguageModelServiceDummy.swift # No-op double for tests
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation, incl. the ConjugationTool the model can call
│   ├── literature_examples.json # Bundled literature/government/Wikipedia example sentences keyed by infinitif
│   ├── PasseSimpleGroup.swift  # Passé simple stem/ending groups (bare/a/i/u/ï/…)
│   ├── PersonNumber.swift      # 1s…3p with localized pronouns and gendered third-person handling
│   ├── PronounGender.swift     # Setting enum: feminine/masculine/both
│   ├── Quiz.swift              # @Observable quiz state: question generation, timer, scoring, Live Activity, Game Center
│   ├── QuizDifficulty.swift    # Setting enum: regular vs ridiculous
│   ├── QuizQuestion.swift      # One quiz question (verb + tense)
│   ├── QuizResult.swift        # One answered question and its ConjugationResult, for the results sheet
│   ├── QuizState.swift         # Quiz lifecycle enum (not started / in progress / finished)
│   ├── QuizVerbs.swift         # Curated verb pools the quiz draws from (regular -er/-ir/-re, big three, stem changers, être auxiliaries, irregular participes, top thirty, futur stems)
│   ├── Sound.swift             # Sound-effect enum mapping cases to the bundled MP3s
│   ├── StemAlteration.swift    # A stem alteration: type, chars, the tenses it applies to, additive/inherited flags
│   ├── SubjonctifPresentGroup.swift   # Subjonctif présent ending groups
│   ├── Tense.swift             # All French tenses; associated PersonNumber where applicable
│   ├── TutorChatHistory.swift  # Persistence for the tutor's chat messages
│   ├── Verb.swift              # A verb: infinitif, translation, model reference, auxiliary, corpus counts, derived rank; static verbs dictionary
│   ├── VerbModel.swift         # A conjugation pattern: parent for inheritance, stem alterations, ending groups, participe endings
│   ├── VerbModelParser.swift   # XMLParser delegate for verbModels.xml
│   ├── verbModels.xml          # Conjugation pattern definitions
│   ├── VerbParser.swift        # XMLParser delegate for verbs.xml
│   ├── verbs.xml               # 6,332 entries / 6,328 distinct infinitives, with inline corpus hit counts (hi/hn/hl/hs/hp); VerbParser derives the ranks
│   ├── XMLDataParser.swift     # Shared XMLParser delegate base for the three parsers
│   └── Game/
│       ├── GameModels.swift            # Entity structs/enums (Bullet, Target, EnemyBullet, DropKind, …)
│       ├── GameState.swift             # @Observable core loop: player, targets, bullets, waves, lives, scoring
│       ├── GameState+Ball.swift        # Mechanic 2 — Le Ballon des Bleus (ricocheting ⚽)
│       ├── GameState+Divers.swift      # Mechanic 1 — La Patrouille de France (dive-bombers)
│       ├── GameState+Ghosts.swift      # Mechanic 3 — Le Fantôme de l'Opéra (drifting 👻 dropping a trail)
│       ├── GameState+Henyard.swift     # Mechanic 4 — La Basse-Cour (🐔 hen, distinct from the 🐓 rooster)
│       ├── GameState+RobotBoss.swift   # Mechanic 5 — the converter-robot mini-boss
│       └── GameState+Specials.swift    # Schedules the cyclic special mechanics (ball, ghost, henyard, …)
├── Utils/
│   ├── AudioSession.swift      # Configures AVAudioSession for playback mixed with other audio
│   ├── BrowseStore.swift       # @Observable generic store backing the verb and model browse views (items + sort)
│   ├── ChansonData.swift       # Lazy-loading Chanson de Roland example lookup
│   ├── ColorExtension.swift    # Named Color constants from the asset catalog
│   ├── ConjugationText.swift   # AttributedString(mixedCaseString:) — renders $…$ irregular-character coloring
│   ├── DoubleExtension.swift   # Percentage/decimal formatting for quiz scores
│   ├── ExampleData.swift       # Lazy-loading literature-example lookup by infinitif
│   ├── Fonts.swift             # Work Sans font constants scaled relative to text styles
│   ├── GameCenter.swift        # Protocol for Game Center authentication and score reporting
│   ├── GameCenterReal.swift    # GKLocalPlayer authentication and leaderboard submission
│   ├── GameCenterStub.swift    # Canned-answer double for tests and the simulator
│   ├── GetterSetter.swift      # Protocol for key-value storage
│   ├── GetterSetterCodable.swift  # Codable get/set convenience over the string-based protocol
│   ├── GetterSetterFake.swift  # In-memory dictionary implementation for tests
│   ├── GetterSetterReal.swift  # UserDefaults implementation
│   ├── GlyphWarmer.swift       # Pre-rasterizes glyphs off the main actor to avoid first-render hitches
│   ├── HapticPlayer.swift      # Cached UIImpactFeedbackGenerators by style
│   ├── IntExtension.swift      # Elapsed-seconds → h:mm:ss formatting
│   ├── KillSwitches.swift      # The three screenshot/preview kill switches: OnboardingDisplay.onboardingEnabled, TipDisplay.tipsEnabled, TutorDisplay.tutorUnavailableRowEnabled. All ordinarily true; flipped to false for an App Store sweep — see docs/screenshot-playbook.md and docs/video_script.md
│   ├── Layout.swift            # Spacing constants (8/16/24pt)
│   ├── LiveActivityManager.swift  # Creates, updates, and ends the quiz Live Activity
│   ├── Log.swift               # os.Logger factory with per-category loggers
│   ├── ModelSort.swift         # Sort order for the model browse view (irregularity/alphabetical/identifier)
│   ├── Modifiers.swift         # The app's ViewModifier vocabulary (headingLabel, funButton, card, screenBackground, …)
│   ├── PreviewSupport.swift    # DEBUG-only bootstrap so SwiftUI previews have parsed verb data
│   ├── RatingsFetcher.swift    # Fetches the App Store ratings count from the iTunes API
│   ├── ReviewPrompter.swift    # Protocol for review prompting
│   ├── ReviewPrompterDummy.swift  # No-op double
│   ├── ReviewPrompterReal.swift   # Prompts at an action-count modulo and a minimum interval
│   ├── Settings.swift          # @Observable user preferences persisted through GetterSetter
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerDummy.swift  # No-op double
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with per-sound debouncing
│   ├── StringExtensions.swift  # The rich-text markup parser: RichTextBlock / TextSegment from ` ~ $…$ ‡…‡
│   ├── URLExtensions.swift     # Deeplink URL helpers (conjuguer:// scheme)
│   ├── URLProtocolStub.swift   # URLProtocol subclass stubbing HTTP responses in tests
│   ├── URLSessionExtension.swift  # Stubbed URLSession factory used by the simulator/test worlds
│   ├── Util.swift              # French/English Locale constants
│   ├── Utterer.swift           # AVSpeechSynthesizer wrapper for French and English pronunciation
│   ├── VerbConjugations.swift  # Builds VerbView's conjugation tables: tense specs, sections, cells, defectivity
│   ├── VerbData.swift          # Startup XML parse (verbs, models, defect groups) with a loading/loaded state
│   ├── VerbSort.swift          # Sort order for the verb browse view (frequency/alphabetical)
│   ├── WidgetSnapshotWriter.swift # Writes the multi-day widget snapshot bundle to the shared container
│   └── World.swift             # @Observable DI container (Current) plus MainTab; device/simulator/unitTest configurations
└── Views/
    ├── BrowseLayout.swift      # Shared adaptive grid columns for the browse views
    ├── BrowseRow.swift         # Shared row/cell used by both browse views, with optional badge
    ├── BrowseSearch.swift      # Shared search filtering for the browse views
    ├── GameCenterAuthView.swift   # UIViewController shim + coordinator for presenting Game Center auth
    ├── GameView.swift          # The retro arcade minigame
    ├── InfoBrowseView.swift    # Info articles grouped by category; hosts the tutor entry and its unavailability cell
    ├── InfoView.swift          # A single Info article rendered through RichTextView
    ├── InputView.swift         # DEBUG-only conjugation scratchpad
    ├── LoadingView.swift       # Splash shown while verbs.xml parses
    ├── MainTabView.swift       # Root TabView with five tabs
    ├── ModelBrowseView.swift   # Searchable, sortable list/grid of verb models
    ├── ModelView.swift         # Model detail: endings, stem alterations, example verbs
    ├── OnboardingView.swift    # Multi-page welcome tour; auto-presented on first launch and re-showable from Settings
    ├── QuizResultsView.swift   # End-of-quiz sheet: score, per-question results, leaderboard
    ├── QuizResultView.swift    # One row of the results sheet
    ├── QuizView.swift          # Quiz gameplay: prompt, answer field, progress, feedback
    ├── RichTextView.swift      # Renders [RichTextBlock] with subheadings, emphasis, color-coding, links
    ├── SettingsView.swift      # Settings UI: pickers, app icon, ratings, onboarding re-show
    ├── TutorTestView.swift     # DEBUG-only batch harness for tutor queries
    ├── TutorView.swift         # Chat interface for the on-device tutor
    ├── VerbBrowseView.swift    # Searchable, sortable list/grid of all verbs (hosts the verb_browse_sort launch anchor)
    └── VerbView.swift          # Verb detail: full conjugation tables, etymology, example sentence

ConjuguerWidget/
├── AnswerQuizIntent.swift      # AppIntent for answering the quiz question inside the widget
├── Assets.xcassets/            # Widget-specific asset catalog
├── ConjuguerWidgetBundle.swift # Widget bundle combining the widgets, controls, and Live Activity
├── Info.plist                  # Widget extension configuration
├── Localizable.xcstrings       # Widget-target string catalog (en/fr); holds every Widget.* key, including Shared/'s intents
├── QuickQuizControl.swift      # Control Center button that opens the quiz
├── QuizLiveActivity.swift      # Live Activity showing quiz progress and score
├── QuizWidget.swift            # Timeline widget for the daily quiz question
├── RandomVerbControl.swift     # Control Center button that opens a random verb
├── SnapshotReader.swift        # Reads the snapshot bundle from the shared container into timeline entries
├── VerbDuJourWidget.swift      # Timeline widget for the verb of the day
├── WidgetDeeplink.swift        # Builds conjuguer:// URLs for widget taps
└── Views/
    ├── AccessoryWidgetView.swift   # Lock Screen accessory families
    ├── LargeWidgetView.swift       # Large family: verb plus full présent paradigm
    ├── MediumWidgetView.swift      # Medium family: verb plus selected conjugations
    ├── QuizWidgetView.swift        # Quiz question with tappable answer buttons
    ├── SmallWidgetView.swift       # Small family: verb and translation
    ├── WidgetConjugationText.swift # $…$ irregular-character coloring for widgets (its own dynamic light/dark colors)
    └── WidgetEtymologyText.swift   # ~emphasis~ rendering for widget etymology text

Shared/                         # Compiles into BOTH the app and widget targets
├── OpenQuizIntent.swift        # AppIntent opening the quiz (title written inline — appintentsmetadataprocessor can't read WidgetL accessors)
├── OpenRandomVerbIntent.swift  # AppIntent opening a random verb (same inline-title constraint)
├── QuizActivityAttributes.swift  # ActivityKit model for the quiz Live Activity
├── WidgetConstants.swift       # App-group ID, snapshot filename, storage keys
├── WidgetDateHelper.swift      # Pinned Gregorian calendar and day-key formatting shared by writer and reader
├── WidgetL.swift               # LocalizedStringResource accessors for widget strings (the widget's analogue to L)
└── WidgetSnapshot.swift        # Codable model for one day of serialized widget state

ConjuguerTests/
├── Info.plist                  # Test-bundle configuration (excluded from the target via membershipExceptions)
├── LocalizationTests.swift     # Asserts format-style strings substitute their runtime values
├── TestUtils.swift             # T.testConjugation shared assertion (threads #_sourceLocation) and T.generateVerbModelTests
└── Models/
    ├── AddedVerbsTests.swift           # Conjugations of the 13 verbs added and 6 misspellings renamed on 2026-08-28, plus dépourvoir's defect group 27
    ├── CompoundTenseTests.swift        # Compound tenses, incl. feminine/plural participe agreement
    ├── ConjugationResultTests.swift    # Parameterized scoring cases for ConjugationResult
    ├── CorpusFormsDumpTests.swift      # Harness: drives Conjugator over the verb set to emit corpus form→lemma JSON for the example pipeline
    ├── DeeplinkTests.swift             # conjuguer:// parsing and routing (serialized — mutates Current)
    ├── DefectGroupTests.swift          # Defect-group membership and tense suppression
    ├── DefectivityAuditTests.swift     # Per-family defectivity audit (traire, braire, férir, poindre, …)
    ├── FuturStemsTests.swift           # Futur stem derivation, incl. the trailing-e trim for -re verbs
    ├── GameCollisionTests.swift        # Characterization tests for the three collision shapes
    ├── GameDiveArcTests.swift          # Dive-bomber arc geometry (serialized)
    ├── GameMechanicsTests.swift        # Special-mechanic scheduling and lifecycle (serialized)
    ├── GameProjectileTests.swift       # Bullet and enemy-bullet behavior (serialized)
    ├── NousPrésentStemTests.swift      # The nous-présent stem that imparfait derives from
    ├── ParserTests.swift               # XML parsing of verbs, models, and defect groups
    ├── QuizTests.swift                 # Quiz question generation, scoring, and lifecycle (serialized — mutates Current)
    ├── RichTextTests.swift             # Rich-text markup parsing into blocks and segments
    ├── SettingsTests.swift             # Settings defaults, persistence, and malformed-value handling (serialized)
    ├── VerbModelTests.swift            # GENERATED by T.generateVerbModelTests() — one @Test per verb model, ~5,500 lines. Regenerate rather than hand-edit
    └── WidgetSnapshotWriterTests.swift # Snapshot-bundle generation, day paging, and change detection

docs/
├── app-store-preview-videos.md     # Final Cut Pro workflow for the App Store preview videos
├── authored-examples.md            # Claude-original example sentences (the AI-authored tail)
├── blog_notes.md                   # Work journal: dated narrative notes; the project's session memory
├── chanson-full-treatment-prompt.md  # Prompt for completing the full-treatment Chanson de Roland edition
├── classical-authored.md           # Classical-tier authored examples
├── classical-corpus-sources.md     # Provenance manifest for the classical corpus tier
├── claude-code-enospc-truncation-postmortem.md  # Postmortem on the false "temp filesystem is full" banner and silent Bash truncation
├── conjuguer-ui-issues.md          # Unified UI/design recommendation list
├── description.txt                 # App Store description copy
├── Fable_max.md                    # Verbs generated by Claude Fable 5 at max effort (model-eval artifact)
├── future-swiftui-fixes.md         # Deferred SwiftUI work (post-Phase-7)
├── government-corpus-licensing.md  # Licensing analysis for French/Swiss government documents
├── government-corpus-sources.md    # Provenance manifest for the government corpus tier
├── literature-example-corpus.md    # READ FIRST before touching corpus/: layout, gitignore policy, build scripts, tiers, coverage
├── model-eval-analysis.md          # Fable 5 vs. Opus 4.8 code-review eval analysis
├── parallel-feature-worktrees.md   # Building two features in parallel with git worktrees
├── privacy_policy2.txt             # Privacy policy text
├── project-structure.md            # This file — annotated directory tree
├── quiz-best-score-followup.md     # Follow-up spec: best score on the quiz briefing screen
├── release-notes-2.0.txt           # 2.0 release notes
├── release-notes-2.1.txt           # 2.1 release notes
├── screenshot-plan.md              # Screenshot capture spec: which views, languages, and devices
├── screenshot-playbook.md          # Screenshot workflow: prerequisites, kill switches, driver flags, workarounds, recovery
├── screenshots/                    # Captured screenshots produced by the driver
├── technology-corpus-sources.md    # Provenance manifest for the technology corpus tier
├── frequencies.txt                 # Generated: every distinct infinitive in rank order, one "<rank> <infinitive>" per line
├── verb-frequency-sources.md       # Research: frequency-of-use sources for all verbs (Sketch Engine prices/caps, GLÀFF, Lexique 4 coverage)
├── video_script.md                 # App Store preview script, bilingual captions, and pre-recording checklist
├── wikipedia-corpus-sources.md     # Provenance manifest for the Wikipedia corpus tier
├── wwdc2026-conjuguer-impact.md    # WWDC 2026 announcements and what they mean for Conjuguer
└── wwdc2026-*-transcript.txt       # Verbatim WWDC 2026 session transcripts (Apple copyrighted)

scripts/
├── prep_screenshot_sim.sh      # Prepares a simulator for a screenshot sweep (status bar, language, region)
├── take_screenshots.sh         # Drives ios-build-verify + axe/simctl through the App Store screenshot set; see docs/screenshot-playbook.md
└── verify_store_media.sh       # Validates exported screenshots/previews against App Store Connect's requirements

prompts/                        # Archive of the session prompts that produced features and investigations
                                # (historical records — their file paths reflect the tree as it was then)

corpus/                         # Literature-example pipeline; NOT part of any target. See docs/literature-example-corpus.md
├── originals/                  # Source texts by tier (classical, literature, government, technology, wikipedia)
├── json/                       # Built example files, copied into Conjuguer/Models/ to ship
├── working/                    # Index builders and their build products (build_corpus_index.py, build_classical_index.py, build_tail_index.py, build_literature_examples.py, build_chanson_examples.py)
└── grokked/                    # Intermediate per-source extraction output

frequency/                      # Verb-frequency pipeline; NOT part of any target. See frequency/README.md
├── build_counts.py             # GLÀFF + Lexique 4 → verb-counts.json + report.md, with the estimate tiers and gates
├── apply_counts.py             # verb-counts.json → the hi/hn/hl/hs/hp attributes of verbs.xml
├── generate_frequencies_txt.py # verbs.xml → docs/frequencies.txt, in VerbParser.ranked's exact order
├── verb-counts.json            # Per-infinitive measured counts and, where needed, frwac_estimate
├── editorial-counts.json       # The hand-assigned estimate tier: nine verbs, each with a reason
└── GLAFF-README.txt            # GLÀFF's own README; its licence asks that it accompany redistribution

Images/                         # README and App Store imagery
build/                          # Scratch DerivedData for out-of-tree builds (gitignored)
```
