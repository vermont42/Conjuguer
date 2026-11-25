# Project Structure

Annotated directory tree for Conjuguer. This doc is a **cache**: it exists so a future
session can orient without re-reading the tree, which means staleness has a real cost.
When you add, remove, or rename a source file, update this file to match.

The two target folders (`Conjuguer/`, `ConjuguerTests/`) are Xcode **synchronized
folders**, so creating a file on disk is all it takes to compile or bundle it — there is
no `project.pbxproj` edit and no Xcode step, and nothing here needs registering anywhere
else. See CLAUDE.md, *Project Layout*.

Prose is sorted by who wrote it, because that is what Josh remembers when he looks for a file:
`prompts/` holds what he wrote, `plans/` what Claude wrote to direct another session, and
`docs/` Claude's output that informs. Every file in the three gets a line below, so that a file
can be found by subject. See CLAUDE.md, *Prompts, Plans, and Documents*. A JSON file in those
folders is written here as `name [.json]`, because `scripts/check_docs.py` treats any `.json`
filename in this document as a shipped data file and fails if `Conjuguer/Models/` or
`frequency/` lacks it.

```
Conjuguer/
├── Conjuguer.entitlements      # App Groups (widget sharing) + Game Center; wired via CODE_SIGN_ENTITLEMENTS, not bundled
├── Info.plist                  # App configuration (deeplink scheme, fonts, TelemetryDeckAppID key)
├── Secrets.example.xcconfig    # Template for the secrets config; copy to create the real one
├── Secrets.xcconfig            # TelemetryDeck app ID (gitignored; base configuration for the app target)
├── Analytics/
│   ├── Analytics.swift         # Analytics protocol, AnalyticsName and ParameterKey, and every parameter value: AnalyticsSource, SearchOutcome, SearchMatchKind, VerbPageSection, and the bands (AnalyticsBand)
│   ├── AnalyticsReal.swift     # TelemetryDeck implementation; funnels calls onto a serial GCD queue because the SDK blocks with DispatchQueue.sync internally
│   └── AnalyticsSpy.swift      # Test spy recording signals for assertions
├── App/
│   ├── AppLauncher.swift       # Chooses TestApp vs ConjuguerApp based on the unit-test environment
│   ├── ConjuguerApp.swift      # Main entry point: verb-data load, onboarding cover, deeplinks, Spotlight continuation and indexing, widget refresh, Tips.configure(), the Command-F menu
│   ├── QuickActions.swift      # The Home Screen quick action (Find a Verb), and the app and scene delegates that install and receive it
│   ├── TestApp.swift           # Minimal App for the unit-test environment
│   ├── VerbSearchCommands.swift   # Verbs › Find a Verb menu with Command-F, for iPad and Mac keyboards
│   └── Preview Content/        # Preview-only asset catalog
├── Intents/
│   ├── ConjuguerShortcuts.swift # AppShortcutsProvider: Look Up a Verb, Start Quiz, Random Verb, with English phrases
│   ├── LookUpVerbIntent.swift  # Look Up a Verb (asks for a word, answers, opens the page or search) and the hidden OpenLookupResultIntent it opens with
│   ├── VerbEntity.swift        # AppEntity and IndexedEntity for a verb entry, with its query
│   └── VerbSpotlight.swift     # The Spotlight entries (gloss, key conjugations, every conjugation) in the named index, indexed when the app's version changes
├── Assets/
│   ├── Assets.xcassets/        # Colors (customBlue, customRed, …), app icons + their preview images, Adams/Compton/Splash images
│   ├── LaunchScreen.storyboard # Launch screen
│   ├── Localizable.xcstrings   # App-target string catalog (en/fr); see CLAUDE.md for the editing hazards
│   ├── PrivacyInfo.xcprivacy   # Privacy manifest for App Store submission
│   ├── Sounds/                 # MP3 effects for quiz and game (applause, buzz, chime, guns, ghost, robot, …)
│   └── WorkSans*.ttf           # Bundled Work Sans faces (regular, semibold, bold, italic); the regular, semibold, and italic are registered in Info.plist
├── Models/
│   ├── Achievement.swift       # The nine Game Center achievements for mastery milestones: permanent IDs, points, each one's progress from the practice record (a level's patterns, the three key conjugations of the pillars or of 10, 25, or 50 irregular verbs, the maison d'être's passés composés), and GameCenter.reportAchievements(in:)
│   ├── AnswerDiagnosis.swift   # Why a wrong quiz answer is wrong, when the Conjugator can say so for certain (agreement, auxiliary, spelling change, futur stem, another cell, a regular form), as one templated line
│   ├── AnswerDifference.swift  # Where a wrong answer differs from the nearest right spelling, letter by letter, for the quiz's held correction
│   ├── AnswerFrame.swift       # The shape of a quiz answer: the pronoun before the blank, elided to the answer (j', je m'), the gender a compound tense agrees with, the impératif's (tu) and -toi, a sentence's words around its blank, and the prompt VoiceOver reads
│   ├── AnswerSlip.swift        # Whether a wrong answer is a slip that earns one more try: one edit or only accents off, four letters or more, and not another cell of the verb
│   ├── AnswerSpelling.swift    # How the quiz reads a typed answer: case, spacing, the curly apostrophe, and the subject and reflexive pronouns of the asked person
│   ├── AppIcon.swift           # Alternate app-icon enum (beret/croissant/rooster/arc de triomphe)
│   ├── Auxiliary.swift         # avoir/être auxiliary enum
│   ├── ChansonExample.swift    # Codable model for a Chanson de Roland example (laisse, line, old French, translation)
│   ├── chanson_examples.json   # Bundled Chanson de Roland examples keyed by infinitif
│   ├── ChoiceQuestion.swift    # Choice questions: a setting and one sentence in two tenses or moods, the reasons and the level each sets, the draw of a round's one, and the order shown
│   ├── choice_questions.json   # The 66 choice questions a default round draws from Elementary up (scripts/choice_questions.py merges, checks, and approves them)
│   ├── ConditionnelPresent.swift  # Conditionnel présent endings
│   ├── ConjugationLabels.swift # App-only display members of the conjugation core (pronouns, preamble, localized names, model verb links, the settings-gendered Conjugator overloads), kept apart so ConjugationMapTool can compile the core
│   ├── ConjugationIndex.swift  # The conjugation map indexed for search: by folded spelling (etait → était) and as packed folds for the guess; BoundedEditDistance
│   ├── ConjugationMap.swift    # Conjugation → verbs map: its rules, LZFSE text format, build(), and the bundled copy; compiled by the app and ConjugationMapTool
│   ├── ConjugationMatch.swift  # Verb.conjugations(matching:): the cells, in page order, whose conjugation equals a text
│   ├── ConjugationQuery.swift  # A search query as a conjugation's words: pronouns, elision, que, y, en, and negation dropped ("je ne sais pas" → sais)
│   ├── ConjugationResult.swift # Answer grading (ConjugationResult.grade): total or no match and the app's spelling of a variant (AnswerGrade); a right second attempt's result; each result's sound, score, icon, and color
│   ├── Conjugator.swift        # The conjugation engine: model lookup, stem alterations, simple and compound tenses; takes the pronoun gender explicitly (the app's defaulted overloads are in ConjugationLabels.swift)
│   ├── ConjugatorError.swift   # Error enum for conjugation failures
│   ├── ConjuguerTips.swift     # TipKit tips (try the quiz, explore models, choose a level, play game, scroll to the verb page's bottom)
│   ├── CyclingDeck.swift       # Generic deck that deals elements in order and reshuffles on exhaustion
│   ├── DailyReminder.swift     # The Daily Reminder setting, DailyReminderPlan (a worded notification a day for 14 days, none on a day already done), and World.rescheduleReminders
│   ├── DailyChallenge.swift    # The daily challenge: five questions a day per level, seeded by the date and level alone; its result, kept on the device, with the shared text; QuizScope.challenge; DailyChallengeRequest
│   ├── DailySession.swift      # QuizScope.daily, ten questions at the level with due items first; DailySessionRequest; the streak's hub line, results line, and Another Session
│   ├── DailyStreak.swift       # Finished daily sessions per calendar day and the streak computed from them: one missed day repaired by two sessions the day after
│   ├── DefectGroup.swift       # A group of defective verbs and the tenses/persons they lack
│   ├── DefectGroupParser.swift # XMLParser delegate for defectGroups.xml
│   ├── defectGroups.xml        # Defective-verb group definitions
│   ├── EndingDisplay.swift     # Builds $…$-marked ending strings (irregular chars uppercased) for model display
│   ├── Etymologies.json        # Bundled verb etymologies keyed by language and infinitif
│   ├── Etymology.swift         # Lazy-loading etymology lookup by infinitif
│   ├── Example.swift           # Codable model for a literature example sentence; its Gutenberg _underscore_ italics as styled or plain text
│   ├── ExampleSource.swift     # Provenance enum for example sentences (Proust/Zola/Flaubert/La Fontaine/Molière/gov/Wikipedia/Wiktionary/Claude) with per-source attribution
│   ├── FrequencyBand.swift     # The top 100, 300, and 1,000 verbs by rank (Verb.isIn, Verb.verbs(in:)); the verb of the day draws from the top 1,000, and the pedagogy levels will read all three
│   ├── FuturSimple.swift       # Futur simple endings
│   ├── GapSentence.swift       # Phrases à trous: a sentence with its conjugation in braces, its cell and fixed gender, its frame, which levels ask it, the draw of a round, and the scope
│   ├── gap_sentences.json      # The 750 Phrases à trous sentences for the 300 most frequent verbs (scripts/gap_sentences.py merges, checks, and approves them)
│   ├── ImageInfo.swift         # Image name + caption/credit for Info articles
│   ├── Imparfait.swift         # Imparfait endings
│   ├── IndicatifPresentGroup.swift    # Indicatif présent ending groups (e/extendedS/s/ï/r/…) and their XML mapping
│   ├── Info.swift              # Info article model, the static article list, and InfoCategory (about/concepts/tenses)
│   ├── KeyConjugations.swift   # Verb.keyConjugations() (the il présent, passé composé, and futur, unlabeled), citationInfinitif (se souvenir), and the share text
│   ├── L.swift                 # Type-safe localization accessors, nested by feature
│   ├── LastQuizResult.swift    # The last quiz's results for the Quiz tab, kept beside the practice record: a kind and a verb or collection key rather than a title, the level, the counts, the score, and the date
│   ├── LearnerVerbStore.swift  # @Observable Current.learnerVerbs: records opens and stars in LearnerVerbs, saves each change to the App Group's defaults, and answers in verbs (recent, starred, My Verbs)
│   ├── LanguageModelService.swift      # Protocol for the on-device tutor, plus TutorMessage and unavailability/error enums
│   ├── LanguageModelServiceDummy.swift # No-op double for tests
│   ├── LanguageModelServiceReal.swift  # FoundationModels implementation, incl. the ConjugationTool the model can call
│   ├── literature_examples.json # Bundled literature/government/Wikipedia example sentences keyed by infinitif
│   ├── Mastery.swift           # What the practice record has mastered at a level: the regular families' patterns by tense, the spelling-change models' own patterns, and the band's irregular verbs with their key conjugations
│   ├── ModelSearch.swift       # Finds a model by its exemplar or by any of its verbs, through VerbSearch
│   ├── ModelPractice.swift     # A model's practice, alone and mixed: what each model asks (Verb Essentials or its marked cells), when it is known, why a model has none, and the draws
│   ├── MatchedConjugation.swift # The conjugation a search result matched, its cells, the row's line ("vais: Indicatif Présent (je)"), and MarkedConjugations for the verb page
│   ├── PasseSimpleGroup.swift  # Passé simple stem/ending groups (bare/a/i/u/ï/…)
│   ├── PersonNumber.swift      # 1s…3p with localized pronouns and gendered third-person handling
│   ├── PronounGender.swift     # Setting enum: feminine/masculine/both
│   ├── Quiz.swift              # @Observable quiz state: question generation, rounds of ten and Ten More, re-asks, a round's held choice question, timer, scoring, Live Activity, Game Center
│   ├── QuizAbandonment.swift   # The quizzes in progress, kept so the next launch can send quizAbandon for one the app was left during
│   ├── QuizClock.swift         # Setting enum: the Quiz Clock, hide (default) or show
│   ├── CustomQuiz.swift        # The custom quiz: chosen tenses and a QuizVerbSet (a band, every verb, My Verbs, a collection or model), its stored form, QuizScope.custom
│   ├── QuizDraw.swift          # The verbs of an unlisted quiz (the default, or a custom quiz over a band) from a band: half irregular, two core verbs, one to three rare derivatives; QuizVerbPool (a tense's kinds of verb, read from the data) and QuizVerbTraits
│   ├── PracticeItemMapping.swift # Which practice item a question exercises: a regular family's pattern (parler's, finir's, rendre's, or a spelling-change model's where it marks the cell) or an irregular verb's key conjugation by stem; a lookup's items
│   ├── PracticeStore.swift     # @Observable Current.practice: records answers and lookups in the PracticeRecord, saves it to the App Group's defaults, migrates the review card's old per-verb schedules, offers the review card, keeps the last quiz's results and the Speed Round's best, and resets
│   ├── PracticeSet.swift       # A custom quiz shared as a quiz/set link or QR code: reading and writing the link, the level carried only when needed, My Verbs as a list of 50, its scope, summary, share text, and PracticeSetRequest
│   ├── QuizDueItems.swift      # Up to three due practice items mixed into a default round, within its level's tenses and band; QuizDraw.patternVerbs, the verbs that share a pattern
│   ├── QuizRecordSession.swift # Review and Practice My Mistakes: sessions drawn from the practice record beyond the level's tenses and band, a verb's key conjugations together, QuizScope.recordSession
│   ├── QuizScope.swift         # What a quiz asks about (every verb, My Verbs, one verb's page, a collection, a custom choice), its count and source; the level's mix over chosen verbs, Test Me's three tenses, Verb.hasCell, canBeQuizzed(at:)
│   ├── QuizLevel.swift         # Setting enum: the four quiz levels (Beginner to Advanced) and the tenses each asks; QuizTenseSlot, a tense's cells, weight, and verb pools; each level's frequency band
│   ├── QuizQuestion.swift      # One quiz question (verb + tense), whether it is a missed question asked again, the step it shares with questions shown on the same screen, a recognition prompt, a sentence, or a choice, and the gender its answer agrees in
│   ├── QuizResult.swift        # One answered question, its ConjugationResult, a slip's first attempt, whether it was a re-ask, its sentence, and its points, for the results sheet; which rows offer the verb's example
│   ├── QuizState.swift         # Quiz lifecycle enum (not started / in progress / finished)
│   ├── Recognition.swift       # Name the Conjugation: the scope, a prompt's every right cell (by the conjugation map, in both genders, a pronominal verb's prompt with its pronoun), the grade part by part, its repair lines, and the correction's answer lines
│   ├── RelatedVerbs.swift      # VerbBase (a verb's base and root: a verbal prefix plus a verb its etymology names, less false pairs), RelatedVerbs, and Verb.related for the verb page's card
│   ├── ReviewCardSuppression.swift  # The Suppress Review Card setting's Off and On
│   ├── SearchReport.swift      # SearchTracker (one verb search, first letter to its end) and SearchReport (finishSearch's banded parameters)
│   ├── Sound.swift             # Sound-effect enum mapping cases to the bundled MP3s
│   ├── SpeedRound.swift        # The Speed Round: mastered items, its constants and fixture, QuizScope.speedRound, the draw (each item in turn, a key conjugation's stem cells, a pattern's verbs), SpeedRoundMiss, and AnswerFrame.writtenOut
│   ├── StandardVariants.swift  # Spellings the quiz accepts beside the conjugator's: the 1990 rectifications (plait, étiquète, cèderai, absout) and dictionary doublets (veuillons, éclôt)
│   ├── StemAlteration.swift    # A stem alteration: type, chars, the tenses it applies to, additive/inherited flags
│   ├── SubjonctifPresentGroup.swift   # Subjonctif présent ending groups
│   ├── Tense.swift             # All French tenses; associated PersonNumber where applicable
│   ├── TenseTable.swift        # The verb page's cards in order (frequency within each block, docs/tense_frequency.md); each tense's card, article, and second name
│   ├── TutorChatHistory.swift  # Persistence for the tutor's chat messages
│   ├── Verb.swift              # A verb: infinitif, translation, model reference, auxiliary, corpus counts, derived rank; static verbs dictionary
│   ├── VerbModel.swift         # A conjugation pattern: parent for inheritance, stem alterations, ending groups, participe endings
│   ├── VerbModelParser.swift   # XMLParser delegate for verbModels.xml
│   ├── VerbCollection.swift    # The collections: the top 100, verbs taking être, irregular futur stems, pronominal verbs, and each model; membership, links, share text, and QuizScope.collection
│   ├── VerbDraw.swift          # The verb of the day and every random verb: the top 1,000 weighted toward irregular (third group, aller) and base verbs, with My Verbs every third day or one random draw in three
│   ├── VerbEssentials.swift    # Verb Essentials: the scope, which verbs it asks, its draw of five, the rows of a verb's step, and where a missed blank returns
│   ├── verbModels.xml          # Conjugation pattern definitions
│   ├── VerbParser.swift        # XMLParser delegate for verbs.xml
│   ├── verbs.xml               # 6,330 entries / 6,326 distinct infinitives, with inline corpus hit counts (hi/hn/hl/hs/hp); VerbParser derives the ranks
│   ├── VerbLookup.swift        # What Look Up a Verb says about a word and where it opens the app, read from the verb list's search
│   ├── VerbSearch+Conjugations.swift # Reverse lookup: a conjugation, one word or compound ("ai mangé", "me suis levé"), finds its verbs
│   ├── VerbSearch.swift        # The one matching and ranking rule for verb search: accent and ligature folding, "se" and "to" stripped, exact then prefix or English meaning then the rest, each by frequency; the guess, over infinitives and conjugations, when nothing matches
│   ├── VerbVisit.swift         # VerbDestination (a verb page to push, with its source) and VerbVisit (one stretch of a verb page on screen, for viewAppeared and leaveVerbView)
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
│   ├── ExampleData.swift       # Lazy-loading literature-example lookup by infinitif
│   ├── Fonts.swift             # Work Sans font constants scaled relative to text styles
│   ├── GameCenter.swift        # Protocol for Game Center authentication, score and achievement reporting, and the leaderboard and achievement views
│   ├── GameCenterReal.swift    # GKLocalPlayer authentication, leaderboard submission, achievement progress (held until Game Center's own is loaded, only what has risen), and the views
│   ├── GameCenterSpy.swift     # Records scores, achievement reports, and what was shown, for tests and the simulator
│   ├── GetterSetter.swift      # Protocol for key-value storage
│   ├── GetterSetterCodable.swift  # Codable get/set convenience over the string-based protocol
│   ├── GetterSetterFake.swift  # In-memory dictionary implementation for tests
│   ├── GetterSetterReal.swift  # UserDefaults implementation
│   ├── GlyphWarmer.swift       # Pre-rasterizes glyphs off the main actor to avoid first-render hitches
│   ├── HapticPlayer.swift      # Cached UIImpactFeedbackGenerators by style
│   ├── IntExtension.swift      # Elapsed-seconds → h:mm:ss formatting
│   ├── KillSwitches.swift      # The three screenshot/preview kill switches: OnboardingDisplay.onboardingEnabled, TipDisplay.tipsEnabled, TutorDisplay.tutorUnavailableRowEnabled. All ordinarily true; flipped to false for an App Store sweep — see docs/screenshot_playbook.md and docs/video_script.md
│   ├── Layout.swift            # Spacing constants (8/16/24pt)
│   ├── LiveActivities.swift    # LiveActivities protocol (Current.liveActivities) and the LiveActivity handle, an ID plus an optional ActivityKit Activity
│   ├── LiveActivitiesReal.swift  # ActivityKit implementation: the rolling staleDate, the serial activityChain, and the finished state's linger
│   ├── LiveActivitiesSpy.swift # Test spy under unit tests: counts starts, updates, and ends, and holds the active IDs and the last state, so tests request no real activities
│   ├── Log.swift               # os.Logger factory with per-category loggers
│   ├── ModelSort.swift         # Sort order for the model browse view (irregularity/alphabetical/identifier)
│   ├── Modifiers.swift         # The app's ViewModifier vocabulary (headingLabel, funButton, card, screenBackground, copyOnLongPress, …)
│   ├── PreviewSupport.swift    # DEBUG-only bootstrap so SwiftUI previews have parsed verb data
│   ├── RatingsFetcher.swift    # Fetches the App Store ratings count from the iTunes API
│   ├── ReviewPrompter.swift    # Protocol for review prompting
│   ├── ReviewPrompterDummy.swift  # No-op double
│   ├── ReviewPrompterReal.swift   # Prompts at an action-count modulo and a minimum interval
│   ├── ReminderNotificationDelegate.swift  # Opens a tapped reminder's quiz/daily link; a reminder due while the app is open shows nothing
│   ├── ReminderScheduler.swift # Protocol for the daily reminder's notifications (Current.reminderScheduler)
│   ├── ReminderSchedulerReal.swift  # UNUserNotificationCenter implementation: permission, and the reminders replaced as a set, each carrying its link
│   ├── ReminderSchedulerSpy.swift   # Test spy under unit tests: records each schedule and permission request
│   ├── Settings.swift          # @Observable user preferences persisted through GetterSetter
│   ├── SeededRandomNumberGenerator.swift  # SplitMix64, so tests can check random draws with a fixed seed
│   ├── QRCode.swift            # QR codes made on the device with Core Image, black on white, medium error correction
│   ├── ShareSheet.swift        # Presents UIActivityViewController with an LPLinkMetadata header, anchored on iPad to a bar button or a rect in the page (ShareLink reports no tap)
│   ├── SoundPlayer.swift       # Protocol for audio playback
│   ├── SoundPlayerDummy.swift  # No-op double
│   ├── SoundPlayerReal.swift   # AVAudioPlayer implementation with per-sound debouncing
│   ├── StringExtensions.swift  # The rich-text markup parser: RichTextBlock / TextSegment from ` ~ $…$ ‡…‡
│   ├── URLExtensions.swift     # The deeplink grammar's constants and builders (verbDeeplink, searchDeeplink, infoDeeplink, modelDeeplink), the developer address, a mailto: builder, and the App Store link (URL.appStore)
│   ├── URLProtocolStub.swift   # URLProtocol subclass stubbing HTTP responses in tests
│   ├── URLSessionExtension.swift  # Stubbed URLSession factory used by the simulator/test worlds
│   ├── Util.swift              # French/English Locale constants
│   ├── Utterer.swift           # AVSpeechSynthesizer wrapper for French and English pronunciation
│   ├── VerbConjugations.swift  # Builds VerbView's conjugation tables from TenseTable: sections, cells, red letters, defectivity
│   ├── VerbSearchArrowKeys.swift  # UIKeyCommand hack that lets ↑ and ↓ move through verb results while the search field is focused
│   ├── VerbData.swift          # Startup XML parse (verbs, models, defect groups) with a loading/loaded state
│   ├── VerbSort.swift          # Sort order for the verb browse view (frequency/alphabetical), and VerbListMode, the list picker's three segments (the two orders and My Verbs)
│   ├── ViewControllerTransitions.swift  # Hack: waits until no view controller is presenting or dismissing, so an iPad push from a tap that ends the search is not dropped
│   ├── WidgetSnapshotWriter.swift # Writes the multi-day widget snapshot bundle to the shared container, drawing each day's verb with VerbDraw and keeping the verb the widget already shows today
│   └── World.swift             # @Observable DI container (Current) plus MainTab; device/simulator/unitTest configurations; handleURL and the deeplink grammar's effects, openSearch(text:source:) for search links and Command-F
└── Views/
    ├── AnswerFrameView.swift   # Draws an AnswerFrame around the answer field, on one line or as a sentence wrapped word by word, keeping the field's identity, and the keyboard's focus, from one question to the next
    ├── BrowseLayout.swift      # Shared adaptive grid columns and search-field placement (a fixed bar on iPad and Mac) for the browse views
    ├── BrowseRow.swift         # Shared row/cell used by both browse views, with optional badge, a looked-up check, and a French or English subtitle
    ├── BrowseSearch.swift      # Shared search plumbing for the browse views: all items for a blank query, the trombone for none
    ├── ChoiceQuestionView.swift # A choice question's two sentences, each with its conjugation in bold and its tense, and once one is chosen, the marks, the reason, and Continue
    ├── CustomQuizView.swift    # The custom quiz's editor (tenses and a verb set, each tap kept at once), its list of models, pushed onto the Quiz tab, and the summary card the tab and a practice set share
    ├── FailedVerbSearchView.swift # The verb list's empty state: no results, a guess at the verb meant, and the email-us line
    ├── FrenchLetterKeyRow.swift   # é è ê â î ô û ç keys that replace the sort picker while a search field is focused, and sit above the keyboard for the quiz's answer field
    ├── GameCenterAuthView.swift   # UIViewController shim + coordinator for presenting Game Center auth
    ├── GameView.swift          # The retro arcade minigame
    ├── InfoBrowseView.swift    # Info articles grouped by category; hosts the tutor entry and its unavailability cell
    ├── InfoView.swift          # A single Info article rendered through RichTextView; an optional openLink keeps its links inside a verb page's article sheet
    ├── InputView.swift         # DEBUG-only conjugation scratchpad
    ├── LoadingView.swift       # Splash shown while verbs.xml parses
    ├── MainTabView.swift       # Root TabView with five tabs; presents a practice set's sheet over any tab
    ├── MasteryView.swift       # The hub's Mastery page: a legend, a card per tense for the regular families, a card per spelling-change model, and the irregular verbs
    ├── ModelBrowseView.swift   # Searchable, sortable list/grid of verb models, led by the featured collections
    ├── ModelPracticeCard.swift # A model's practice on its page and in the hub's list: Alone, Mixed with the known models, or why it has none
    ├── ModelPracticeListView.swift # The hub's Conjugation Models list: models with a practice, the most used first, each expanding onto its card
    ├── ModelView.swift         # Model detail: endings, stem alterations, and the verbs, alphabetically or by frequency, with the model's collection bar
    ├── OnboardingView.swift    # Multi-page welcome tour; auto-presented on first launch and re-showable from Settings
    ├── PracticeSetView.swift   # A shared practice set's sheet (its summary, verbs, Start, and Keep as My Custom Quiz, or Not Found) and the full-screen QR view
    ├── QuizCorrectionView.swift # A wrong answer held on its question: the two answers with their differing letters marked, links to the verb and its model, and Continue
    ├── QuizResultsView.swift   # End-of-quiz sheet: score, correct and second-try counts, per-question results, leaderboard
    ├── QuizResultView.swift    # One row of the results sheet, with a slip's first attempt, a sentence's completed sentence, and the verb's example sentence behind a button
    ├── QuizView.swift          # Quiz gameplay: prompt, answer field framed by its pronoun with the accent keys, progress, feedback and the app's spelling of a variant, the held correction and the pages it pushes; the All Verbs / My Verbs / Custom picker and the custom quiz's summary and its Share menu (a link or a QR code); QuizSheet, for Test Me on a verb page and a collection's quiz
    ├── RecognitionChoicesView.swift # Name the Conjugation's prompt and its tense and person chips
    ├── RelatedVerbsView.swift  # The verb page's Related Verbs card (built on the same root, same model), RelatedVerbListView, and FlowLayout
    ├── ReviewCardView.swift    # The review card above the verb list: an irregular verb looked up or practiced days ago, its key conjugations hidden until a tap, a second tap opening its page
    ├── RichTextView.swift      # Renders [RichTextBlock] with subheadings, emphasis, color-coding, links
    ├── SettingsView.swift      # Settings UI: pickers, app icon, ratings, onboarding re-show, Reset Practice
    ├── TutorTestView.swift     # DEBUG-only batch harness for tutor queries
    ├── TutorView.swift         # Chat interface for the on-device tutor
    ├── VerbBrowseView.swift    # Searchable, sortable list/grid of all verbs (hosts the verb_browse_sort launch anchor)
    ├── VerbCollectionView.swift # A featured collection's page, VerbCollectionBar (looked-up count, Quiz, Share) for it and every model page, and the Models tab's VerbCollectionRow
    ├── VerbEssentialsRowView.swift # A Verb Essentials row other than the answer field's: answered with its mark, given in a re-ask, or still to come; and the tense label above each row
    ├── VerbPageNavigation.swift # VerbPagePush and verbPageNavigation(path:done:): the pages a verb, model, or collection page pushes, in the Verbs and Models tabs and in every sheet
    └── VerbView.swift          # Verb detail: conjugation cards with second names and article buttons, the article sheet, the color key and scroll tip, etymology, example sentence, related verbs

ConjugationMapTool/                 # macOS command-line target; compiles the conjugation core from Conjuguer/ (membership exceptions in project.pbxproj)
├── FormsJSON.swift             # The corpus pipelines' three dumps (forms [.json], forms_all [.json], conjugations [.json]), ported byte-for-byte from the retired CorpusFormsDumpTests
└── main.swift                  # Parses the three XML files and writes the map (the app's Generate Conjugation Map build phase) and, on request, the dumps

ConjuguerWidget/
├── AnswerQuizIntent.swift      # AppIntent for answering the quiz question inside the widget
├── Assets.xcassets/            # Widget-specific asset catalog
├── ConjuguerWidgetBundle.swift # Widget bundle combining the widgets, controls, and Live Activity
├── FindVerbControl.swift       # Control Center button that opens the empty, focused verb search (runs OpenVerbSearchIntent)
├── Info.plist                  # Widget extension configuration
├── Localizable.xcstrings       # Widget-target string catalog (en/fr); holds every Widget.* key, including Shared/'s intents
├── QuickQuizControl.swift      # Control Center button that opens the quiz
├── QuizLiveActivity.swift      # Live Activity showing quiz progress and score
├── QuizWidget.swift            # Timeline widget for the daily quiz question
├── RandomVerbControl.swift     # Control Center button that opens a random verb (runs OpenRandomVerbControlIntent)
├── SnapshotReader.swift        # Reads the snapshot bundle from the shared container into timeline entries
├── VerbDuJourWidget.swift      # Timeline widget for the verb of the day
├── WidgetDeeplink.swift        # Builds conjuguer:// URLs for widget taps: the verb's page (source=widget) and the quiz widget's daily challenge (source=challengeWidget)
└── Views/
    ├── AccessoryWidgetView.swift   # Lock Screen accessory families
    ├── LargeWidgetView.swift       # Large family: verb plus full présent paradigm
    ├── MediumWidgetView.swift      # Medium family: verb plus selected conjugations
    ├── QuizWidgetView.swift        # Quiz question with tappable answer buttons
    ├── SmallWidgetView.swift       # Small family: verb and translation
    ├── WidgetConjugationText.swift # $…$ irregular-character coloring for widgets (its own dynamic light/dark colors)
    └── WidgetEtymologyText.swift   # ~emphasis~ rendering for widget etymology text

Shared/                         # Compiles into BOTH the app and widget targets
├── LearnerVerbs.swift          # The learner's verb record, keyed by Verb.dictionaryKey: opens (first, last, count) and stars, as JSON in the App Group's defaults so the widget can read it; every later field must be optional
├── OpenQuizIntent.swift        # AppIntent opening the quiz (title written inline — appintentsmetadataprocessor can't read WidgetL accessors)
├── OpenRandomVerbControlIntent.swift  # The Random Verb control's action: OpenRandomVerbIntent with source=control, hidden from Shortcuts
├── OpenRandomVerbIntent.swift  # AppIntent opening a random verb from Shortcuts, with source=shortcut (same inline-title constraint)
├── OpenVerbSearchIntent.swift  # The Find a Verb control's action: conjuguer://search?source=control, hidden from Shortcuts
├── QuizActivityAttributes.swift  # ActivityKit model for the quiz Live Activity
├── PracticeRecord.swift        # The practice record: PracticeItem (a pattern or a key conjugation, with permanent string keys) and a box, a due date, and the last answer per item, as JSON in the App Group's defaults; every later field must be optional
├── ReviewSchedule.swift        # The practice record's Leitner ladder (1, 3, 7, 14, 30 days): a box and a due date at the start of a day; a right answer climbs only when due, a wrong one starts over
├── WidgetConstants.swift       # App-group ID, snapshot filename, storage keys
├── WidgetDateHelper.swift      # Pinned Gregorian calendar and day-key formatting shared by writer and reader
├── WidgetL.swift               # LocalizedStringResource accessors for widget strings (the widget's analogue to L)
└── WidgetSnapshot.swift        # Codable model for one day of serialized widget state; WidgetQuizQuestion.stableSeed, the FNV-1a seed the widget's answer order and the daily challenge share

ConjuguerTests/
├── Info.plist                  # Test-bundle configuration (excluded from the target via membershipExceptions)
├── LocalizationTests.swift     # Asserts format-style strings substitute their runtime values
├── TestUtils.swift             # T.testConjugation shared assertion (threads #_sourceLocation) and T.generateVerbModelTests
└── Models/
    ├── AchievementTests.swift          # The achievements: each permanent ID, the points, the 50 irregular verbs and the pillars, the maison d'être's twenty items, an empty record, each level's patterns earning its own and the lower levels', one short, learning counting for nothing, all three key conjugations needed and the passé simple not, each step, nothing measured while signed out
    ├── AddedVerbsTests.swift           # Conjugations of the 13 verbs added and 6 misspellings renamed on 2026-08-28, plus dépourvoir's defect group 27
    ├── AnswerDiagnosisTests.swift      # Each diagnosis for real verbs, answers that get no line, the English lines, and the prompted second attempt in a quiz
    ├── AnswerDifferenceTests.swift     # The letters marked for a wrong accent, a missing, extra, or swapped letter, and a red letter; the pronouns dropped and the nearest alternate shown
    ├── AnswerFrameTests.swift          # The frame for each kind of question, one blank in every cell, the frame's words typed with the answer still right, and the spoken prompt
    ├── AnswerSlipTests.swift           # Slips that earn one more try (etes, suis allé, ai parle) and near misses that do not (parle for parlé, prit for prît, eut, viens for vient)
    ├── AnswerSpellingTests.swift       # Normalizing an answer, and the pronouns stripped (or kept) for each person, pronominal verbs, and the impératif
    ├── ChoiceQuestionTests.swift       # The machine check of every choice question (both sentences the Conjugator's, alike but for the braces, the reason's tenses, its level and band); the draw; drafts; nested in QuizTests, one choice a default round from Elementary, a held right or wrong choice, and a ranked round out of 100 with Ten More
    ├── AnalyticsTests.swift            # The bands, the section order, every match kind's analytics value, and the verb page's screen name
    ├── CompoundTenseTests.swift        # Compound tenses, incl. feminine/plural participe agreement
    ├── ConjugationMapTests.swift       # The bundled map equals a fresh build, finds the verb of 99% of example sentences, its entries (homographs, agreement, defects), and its format
    ├── ConjugationMatchTests.swift     # conjugations(matching:): single cells, shared spellings, compound agreement, alternates, defective cells, non-matches
    ├── ConjugationResultTests.swift    # Grading: pronouns, spacing, alternates, required accents and agreement, and the spelling shown for a variant
    ├── CustomQuizTests.swift           # The custom quiz: its stored form and keys, unknown keys dropped, a part left to the level, lists against bands, never ranked, the choice parameter, what cannot start, chosen tenses at any level, the setting's persistence; nested in QuizTests, sessions that ask only the choice and send custom
    ├── DailyChallengeTests.swift       # The seed pinned, day round trips and non-dates, the same key drawing the same five, days and levels differing, twenty balanced days per level, a result's points, the approved shared text, the widget asking the challenge's first question; nested in QuizTests, the same five whatever the seed, level, and record, a result kept once and unranked, no re-ask, a quit keeping nothing, the store's twelve, and the signals
    ├── DailySessionTests.swift         # The streak (a day counted once, the repair, two missed days, a 25-hour day, pruning), the bands, the store across a launch and a reset, the lines, the scope, the reminder plan; nested in QuizTests, a session's draw, the streak and its band, a quit not counting, a repair across days, the reminder rescheduled, and reminder as the source
    ├── DeeplinkTests.swift             # conjuguer:// parsing and routing: the search route, match, info keys, the builders' round trips, and the source query item (serialized — mutates Current)
    ├── DefectGroupTests.swift          # Defect-group membership and tense suppression
    ├── DefectivityAuditTests.swift     # Per-family defectivity audit (traire, braire, férir, poindre, pouvoir's impératif, …)
    ├── EngineAuditTests.swift          # Hand-written pins for the stage-A verb-pass fixes (peuvent, dites, suivi, the eight re-modeled verbs, the seventeen être auxiliaries), checked against Wiktionary rather than against the engine
    ├── ExampleSourceTests.swift        # Parsing of example `source` strings (incl. the Wiktionary citation forms), and that every shipped example's source is known
    ├── ImpersonalVerbTests.swift       # Impersonal verbs take il under any pronoun setting: which verbs are impersonal, the quiz frame, the verb page, and a quiz result; écoconcevoir conjugated like concevoir
    ├── IrregularityMetricTests.swift   # Keeps VerbModel.irregularity and the Info text in agreement: only 1-1/2-1/5-1A score 0%, and the shipped regular/irregular split matches the data
    ├── FrequencyBandTests.swift        # Each band holds its count of infinitives, the bands nest, and the œ verbs and convaincre rank as the 2026-11-22 data fix left them
    ├── FuturStemsTests.swift           # Futur stem derivation, incl. the trailing-e trim for -re verbs
    ├── GameCollisionTests.swift        # Characterization tests for the three collision shapes
    ├── GameDiveArcTests.swift          # Dive-bomber arc geometry (serialized)
    ├── GameMechanicsTests.swift        # Special-mechanic scheduling and lifecycle (serialized)
    ├── GameProjectileTests.swift       # Bullet and enemy-bullet behavior (serialized)
    ├── GapSentenceTests.swift          # The machine check of every Phrases à trous sentence against the Conjugator, agreement included; coverage of the top 300; frames, marks, and spoken prompts; the draw; drafts; the reward rows; nested in QuizTests, sessions (each level, a right round recorded with Ten More, a held correction and its re-ask, a sentence's gender over the setting)
    ├── KeyConjugationsTests.swift      # The key conjugations (reflexive, defective, il agreement), the citation infinitive, the share text, and what a long press copies
    ├── LearnerVerbsTests.swift         # The learner's record: opens, stars, recents, My Verbs, removal, Clear, JSON coding and an older record's decoding, the store's saving, the doubled entries, and the list modes
    ├── MasteryTests.swift              # Mastery: the state by box, each level's patterns and their agreement with every band verb asked, family rows, être rows, participles, spelling-change cells and examples, the band's irregular verbs, stems by level, the display following a seeded record, and where answers land
    ├── ModelSearchTests.swift          # Models found by exemplar or by member verb, exemplars first, each once
    ├── ModelPracticeTests.swift        # Model practice: each model's kind and absence, ten most frequent verbs, marked cells, known at half, partners of the same kind, the draws alone and mixed, the scopes, and sessions (known after a round, joining a mix, Another Round, signals)
    ├── NousPrésentStemTests.swift      # The nous-présent stem that imparfait derives from
    ├── ParserTests.swift               # XML parsing of verbs, models, and defect groups
    ├── QuizLiveActivityTests.swift     # The quiz's Live Activity through the spy: a tab quiz starts one that Quit or the last answer ends, each other answer updates it, a restart replaces it, and a sheet's quiz starts none
    ├── QuizDrawTests.swift             # The default quiz's verbs: each level's band, half irregular, the core verbs, rare and frequent derivatives, the pools' rules, sortir (obtain) left out, no verb dominating, scoped quizzes untouched
    ├── QuizLeaderboardTests.swift      # Leaderboards by level: each level's permanent ID, a ranked session reporting to the level it began at, second attempts counted and re-asks not, Ten More and scoped quizzes reporting nothing (nested in QuizTests to share its serialization)
    ├── QuizLevelTests.swift            # Quiz levels: each level's tenses, the weights, every cell in one slot, the default quiz's draw by level, pool, and weight, and the level on the quiz signals
    ├── QuizSessionTests.swift          # Rounds and re-asks: where a miss returns, once; a re-ask's half points; Ten More's continuation, clock, and fresh verbs; first-round ranking; the signals' question counts and duration bands; the abandonment record; the clock setting and the Live Activity's time (serialized — mutates Current)
    ├── PracticeSetTests.swift          # Practice sets: the pinned link, every tense, verb set, level, and list round-tripped, links that name nothing, what a link keeps, My Verbs as a capped list, the level carried only when needed, the scope, the share text, QR codes read back by Core Image; nested in DeeplinkTests, the quiz/set route; in QuizTests, a session at the set's level
    ├── QuizScopeTests.swift            # Quiz scopes: the default quiz at the learner's level, My Verbs drawing only its verbs at each level, defective verbs, Test Me's three tenses, unranked scoring, doubled entries graded as themselves, source on every quiz signal
    ├── QuizTests.swift                 # Quiz question generation, scoring, and lifecycle; seeded quizzes that never ask a defective cell; the recorded spelling of a variant; the held correction, its stopped clock, and Continue; a slip's one more try, its half points, and its running clock (serialized — mutates Current)
    ├── RecognitionTests.swift          # Name the Conjugation: the cells of fûmes, suis, vis, parle, fait, me souviens, souviens-toi, finissons, avions pris; the level's tenses; pronominal prompts; the infinitive's spellings; each part's grade and line; the correction's lines; the scope; nested in QuizTests, sessions (the draw at each level, nothing recorded, one more try, the held correction and re-ask)
    ├── RelatedVerbsTests.swift         # Base-finding on known and false pairs, nested roots, the card's two relations, doubled roots, and the model page's two orders
    ├── ReviewScheduleTests.swift       # The review ladder: starts, reviews, snoozes, a new item's first answer, a right answer climbing only when due, a wrong one starting over
    ├── PracticeItemTests.swift         # The practice items: pinned and unreadable keys, which verbs are patterns, spelling-change cells, compound tenses with être, every tense's stem, doubled entries, lookups, the shown stems, items asking their own cell back
    ├── PracticeRecordTests.swift       # The practice record: the ladder through answers, due order, lookups, the card's review, snooze, choice, and caption, patterns and passé simple never on the card, a relaunch, the migration, a reset that stays
    ├── QuizAchievementTests.swift      # Nested in QuizTests: achievements reported at the results and at a quit and not while signed out, and the per-level bests (new, not beaten, beaten, per level, none after Ten More or an unranked session, none for 0, Reset forgetting them)
    ├── QuizHubTests.swift              # The Quiz tab's last result: its stored form, each scope's kind, titles, collection keys, the store and Reset; nested in QuizTests, a finished, continued, quit, record-session, verb-page, and collection quiz
    ├── QuizPracticeTests.swift         # Nested in QuizTests: answers kept on quit, every scope writing, due items within the level and band, at most three a round, none in a scoped quiz
    ├── QuizRecordSessionTests.swift    # Review and My Mistakes: missed items, days to the next due item, beyond the level, a pattern no band verb has, key conjugations together, exclusions and the limit; nested in QuizTests, rounds, Ten More, empty records, and signals without counts
    ├── RichTextTests.swift             # Rich-text markup parsing into blocks and segments
    ├── SearchReportTests.swift         # The search tracker's lifecycle, each finishSearch report, and that no parameter can echo the query
    ├── SettingsTests.swift             # Settings defaults (Suppress Review Card off), persistence, the quiz difficulty's migration to a level, and malformed-value handling (serialized)
    ├── SpeedRoundTests.swift           # The Speed Round: mastered items, the draw in turn and never twice running, a pattern's verbs, a key conjugation's cells by level, the scope, the best across a launch and a reset, a miss written out; nested in QuizTests, a round that records nothing, moves on at a miss, ends at sixty ticks, and sends no counts
    ├── TenseTableTests.swift           # The verb page's order, each cell's card, articles, second names, and which pages show the color key
    ├── StandardVariantsTests.swift     # Each accepted variant row, and the spellings each row must not accept (vînmes, dû, croître, appeler, jeter, harcelle)
    ├── StemAlterationAuditTests.swift  # Audits every -er verb whose stem ends in é + consonant: the stem must open to è before a mute ending
    ├── VerbCollectionTests.swift       # Collections: stable keys, each one's membership and order, list and model links, share text, progress, and the unranked quiz with its collection parameter
    ├── VerbDrawTests.swift             # The draw: what counts as irregular, the weights, ten days pinned to a Python reimplementation, My Verbs in turn every third day, weighted and one-in-three proportions with fixed seeds
    ├── VerbEssentialsTests.swift       # Verb Essentials: a step's three cells, each blank's answer by gender, the frames of a pronominal verb, the fixture's diagnosed answers, which verbs it asks, the draw, the scope, re-ask placement, and sessions (each blank recorded, the rows, a re-ask's given rows, half points, Five More)
    ├── VerbLookupTests.swift           # Look Up a Verb's findings, answers, and destinations (aller, vais, suis, etait, go, venier)
    ├── VerbModelTests.swift            # GENERATED by T.generateVerbModelTests() — one @Test per verb model, ~5,500 lines. Regenerate rather than hand-edit
    ├── VerbSearchConjugationTests.swift # Reverse lookup: the plan's queries, short-query ranking, sentences, row lines, landing marks, the conjugation guess, bounded distance
    ├── VerbSearchGuessTests.swift      # The guess at the verb meant, edit distance, arrow-key selection, and the mailto: link
    ├── VerbSearchTests.swift           # Verb search: folding, reflexive and "to" stripping, tier ranking, literal-before-folded, order independence
    ├── VerbSpotlightTests.swift        # The Spotlight entries' description, alternate names, keywords, and identifiers
    ├── VerbVisitTests.swift            # A verb visit's deepest section, resume, and banded dwell
    └── WidgetSnapshotWriterTests.swift # Snapshot-bundle generation from the band, keeping today's verb through a rewrite, doubled entries, the quiz question, and truncation

docs/                               # Claude's output that informs: research, reports, playbooks, manifests, App Store copy
├── app_store_preview_videos.md     # Final Cut Pro workflow for the App Store preview videos
├── authored_examples.md            # Claude-original example sentences (the AI-authored tail)
├── blog_notes.md                   # Work journal: dated narrative notes; the project's session memory
├── classical_authored.md           # Classical-tier authored examples
├── classical_corpus_sources.md     # Provenance manifest for the classical corpus tier
├── claude_code_enospc_truncation_postmortem.md  # Postmortem on the false "temp filesystem is full" banner and silent Bash truncation
├── code_review_findings.md         # Whole-codebase review of 2026-07-07 (the answer to prompts/code_review.md), with the phases that fixed it
├── code_review_remaining_findings.md  # Closing snapshot of that review: every finding resolved or won't-fix
├── code_review_suggestions_fable_high.md  # Model eval: Fable 5 at high effort reviews the codebase
├── code_review_suggestions_fable_max.md   # Model eval: Fable 5 at max effort
├── code_review_suggestions_opus_high.md   # Model eval: Opus 4.8 at high effort
├── code_review_suggestions_opus_max.md    # Model eval: Opus 4.8 at max effort
├── code_review_suggestions_union.md       # Model eval: the four reviews merged, deduplicated, and verified (33 items)
├── conjuguer_ui_issues.md          # Unified UI/design recommendation list
├── description.txt                 # App Store description copy
├── etymology_pipeline.md           # The original etymology pipeline (first 1,001 verbs): procedure, subagent template, lessons; complete
├── etymology_verbs [.json]         # That pipeline's work list: the 981 most-used verbs, by rank
├── fable_max.md                    # Model-eval artifact: the 58 etymologies (ranks 886–981) written by Fable 5 at max effort
├── feature_architecture.md         # How each feature system works (search, analytics, deeplinks, quiz, widgets); the browse and pedagogy plans extend it
├── feature_request_context_usage_tool.md  # Draft Claude Code feature request: a model-callable context-usage tool
├── frequencies.txt                 # Generated: every distinct infinitive in rank order, one "<rank> <infinitive>" per line
├── game_center_setup.md            # The four level leaderboards in App Store Connect: IDs, settings, names, how they were made, release-day and testing steps
├── government_corpus_licensing.md  # Licensing analysis for French/Swiss government documents
├── government_corpus_sources.md    # Provenance manifest for the government corpus tier
├── literature_example_corpus.md    # READ FIRST before touching corpus/: layout, gitignore policy, build scripts, tiers, coverage
├── model_eval_analysis.md          # Fable 5 vs. Opus 4.8 code-review eval analysis
├── new_game_mechanics.md           # Five proposed minigame mechanics, each from Konjugieren's game and a 1980s arcade game
├── parallel_feature_worktrees.md   # Building two features in parallel with git worktrees
├── privacy_policy_pending.md       # Privacy-policy lines for signals built on main, waiting word for word for the release that ships them
├── privacy_policy2.txt             # Privacy policy text
├── project_structure.md            # This file — annotated directory tree
├── release.md                      # What the 2027 release must do: App Store Connect steps, release notes, the pending privacy lines
├── release_notes_2.0.txt           # 2.0 release notes
├── release_notes_2.1.txt           # 2.1 release notes
├── release_notes_2.2.txt           # 2.2 release notes
├── release_notes_2.3.txt           # 2.3 release notes
├── review_instructions.md          # How Josh reviews the verb pass: defaults, the review page, merging decisions into approvals
├── screenshot_playbook.md          # Screenshot workflow: prerequisites, kill switches, driver flags, workarounds, recovery
├── screenshots/                    # Captured screenshots produced by the driver (gitignored)
├── technology_corpus_sources.md    # Provenance manifest for the technology corpus tier
├── tense_frequency.md              # How often each tense occurs in corpus/originals, by folder: the method and counts behind the verb page's order
├── verb_browse_review.md           # Review of the browse plan's code (2026-11-25): bugs, smells, duplication, tests, Konjugieren's findings checked here; plans/verb_browse_fixes.md fixes it
├── verb_frequency_sources.md       # Research: frequency-of-use sources for all verbs (Sketch Engine prices/caps, GLÀFF, Lexique 4 coverage)
├── video_script.md                 # App Store preview script, bilingual captions, and pre-recording checklist
├── voiceover.md                    # VoiceOver: marking French and English, tappable rows, spoken conjugations, the quiz's announcements
├── wikipedia_corpus_sources.md     # Provenance manifest for the Wikipedia corpus tier
├── wiktionary_quotation_sources.md # Provenance manifest for the Wiktionary quotation tier: extracts, public-domain rule, attribution, authors
├── wwdc2026_conjuguer_impact.md    # WWDC 2026 announcements and what they mean for Conjuguer
└── wwdc2026_*.txt                  # Three verbatim WWDC 2026 session transcripts (Apple copyrighted, gitignored)

scripts/
├── choice_questions.py         # Merges drafted choice questions into choice_questions.json, pre-checks them, writes a review sheet, and approves them
├── count_tenses.py             # Counts each tense in corpus/originals from the map tool's cells; see docs/tense_frequency.md
├── gap_sentences.py            # Merges drafted Phrases à trous into gap_sentences.json, pre-checks them, writes a review sheet, and approves them
├── prep_screenshot_sim.sh      # Prepares a simulator for a screenshot sweep (status bar, language, region)
├── take_screenshots.sh         # Drives ios-build-verify + axe/simctl through the App Store screenshot set; see docs/screenshot_playbook.md
├── verify_store_media.sh       # Validates exported screenshots/previews against App Store Connect's requirements
└── write_forms_json.sh         # Builds ConjugationMapTool and writes corpus/working's forms [.json], forms_all [.json], and conjugations [.json]

plans/                              # What Claude wrote to get another session (or another tool) to do something; finished ones included
├── achievement_artwork.md          # gpt-image prompts for the nine Game Center achievements' medallions, in Conjuguer's palette
├── achievement_artwork_drafts/     # Its eighteen drafts, achievement_<n>-<draft>.png, and two contact sheets (gitignored)
├── alligator_gemini.md             # Gemini prompt for the bayou-jazz alligator, the model-eval blog post's hero image
├── alligator_gemini.txt            # The same prompt as plain text, ready to paste
├── app_icons_gemini.md             # Gemini prompts for the eight alternate app icons (Arc, rooster, croissant, béret; light and dark)
├── bayou_jazz_alligator.png        # The image the alligator prompt produced
├── browse_and_verb_implementation.md  # Port Konjugieren's browse and verb-page work (search, reverse lookup, related verbs, My Verbs, collections), in phases
├── chanson_full_treatment.md       # Working prompt for the full-treatment Chanson de Roland edition; its conventions still apply
├── chanson_second_half.md          # Finishing the Chanson's second half (laisses CLII–CCXCI); complete
├── choice_questions.md             # The review sheet of the 66 choice questions, right sentence first, with each reason as the app words it
├── etymology_affixes [.json]       # Live data: the affix library, build-time cards for verb-forming affixes that the etymology writers read (never shipped)
├── etymology_tail.md               # Etymologies for the last 5,325 verbs, in waves; its ledger is the current record, and its "One wave" adds a verb
├── fix_and_add_verbs.md            # Fix seven misspelled infinitives and add fifteen missing common verbs
├── fix_localization_catalog_warnings.md  # Two String Catalog fixes, for Conjuguer and Konjugieren
├── future_swiftui_fixes.md         # Deferred SwiftUI work the SwiftUI-issues pass left, for an implementing session
├── gap_sentences.md                # The brief the Sonnet drafters of the Phrases à trous sentences followed: format, cells, agreement, style
├── get_government_corpus.md        # Acquire the Swiss and French government corpus tier
├── glaff_frequency_ranking.md      # Rank every verb from GLÀFF: counts in verbs.xml, ranks at parse time, credits
├── location_cleanup.md             # This sorting into prompts/plans/docs and the snake_case rename (2026-11-16)
├── location_cleanup_moves [.json]  # Its map of every old path to its new one
├── mine_classical_tier.md          # Mine La Fontaine and Molière for the 144 Chanson-only verbs
├── pedagogy_implementation.md      # Port Konjugieren's quiz pedagogy (levels, corrections, practice record, modes), in phases; runs after the browse plan
├── pedagogy_phase1_variant_audit.md  # The optional standard conjugations (1990 rectifications, doublets) the quiz might accept, with sources and Josh's rulings
├── quiz_best_score_followup.md     # Best score on the quiz briefing screen; resolved by a different route
├── run_etymology_pipeline.md       # Paste-to-run prompt for one batch of the original etymology pipeline; superseded
├── run_etymology_select_verbs.md   # One-shot run of that pipeline for the four select verbs
├── screenshot.md                   # Screenshot capture spec: Josh's nine views, devices, languages, App Store slots, alpha channels
├── screenshot_driver_fixes.md      # Port six screenshot-driver fixes from Konjugieren, fix a seventh
├── sweep_comments.md               # Sweep low-value comments down to CLAUDE.md's comment policy
├── tutor_row_killswitch.md         # The tutor-row kill switch for screenshots; implemented, kept as rationale
├── verb_browse_fixes.md            # Fix what docs/verb_browse_review.md found, in thirteen phases and a closing, with Josh's decisions of 2026-11-25
├── verb_pass.md                    # The verb pass: Wiktionary-checked glosses, examples, and flags for every verb, in stages
├── verb_pass_report.md             # GENERATED by corpus/working/build_report.py: the Stage 3 verb-pass report
├── verb_pass_report_stage5.md      # GENERATED by build_report.py --pass-dir corpus/working/verb_pass/stage5: the Stage 5 report
├── verify_verb_history.md          # Fact-check "A History of the French Verb System", as Conjugar did its Spanish one
└── wire_examples_into_app.md       # Show the literature examples in VerbView and credit their sources

prompts/                            # What Josh wrote to get Claude to do something; paths in them reflect the tree as it was
├── alligator.md                    # Ask for a Gemini prompt: the bayou-jazz alligator hero image
├── analytics.md                    # Replace Amplify/AWS with TelemetryDeck
├── code_review.md                  # Thorough review of the whole codebase
├── etym_starter.md                 # The etymology feature and the pipeline to write its etymologies
├── game.md                         # The Arc de Triomphe minigame
├── game2.md                        # Minigame: audio, power-ups, health, enemy fire
├── index.md                        # A corpus index of verb forms, to make example mining faster
├── landscape.md                    # Make the minigame work in landscape
├── model_eval.md                   # The Fable vs. Opus code-review eval, and the ask for its analysis
├── onboarding.md                   # Adapt Konjugieren's first-launch onboarding
├── post.md                         # Turn the model eval into a blog post
├── rename_objects.md               # Rename the behavior protocols' conformers to Fowler's test-double names
├── tutor.md                        # The conjugation tutor
├── two_plans.md                    # Ask for Conjuguer ports of Konjugieren's browse and pedagogy plans
├── verb_browse_review.md           # Review the code the browse plan built, then ask Josh the open questions and plan the fixes (done 2026-11-25: docs/verb_browse_review.md and plans/verb_browse_fixes.md)
├── verb_browse_updates.md          # Browse views: bottom sort picker, shared row, no chevrons
├── verb_frequency.md               # Find frequency-of-use data for every verb (research)
├── verb_history.md                 # "A History of the French Verb System": the outline
├── verb_pass.md                    # Check every verb's gloss and example with subagents
└── wwdc2026.md                     # What WWDC 2026 means for Conjuguer

.claude/agents/                 # Subagent definitions with their whole briefs, run by the corpus pipelines' workflows
├── etymology-affix-writer.md   # Writes the affix library's cards (etymology tail, stage 1)
├── etymology-affix-skeptic.md  # Checks those cards against the writer's source notes
├── etymology-writer.md         # Writes a shard's English and French etymologies; the canonical etymology brief
├── etymology-skeptic.md        # Checks a shard's two-paragraph etymologies against its evidence
├── verb-checker.md             # Verb pass: checks a shard's glosses, examples and flags against Wiktionary
└── verb-skeptic.md             # Verb pass: tries to refute the checker's proposed changes

corpus/                         # Literature-example pipeline; NOT part of any target. See docs/literature_example_corpus.md
├── originals/                  # Source texts by tier (classical, literature, government, technology, wikipedia)
├── json/                       # Built example files, copied into Conjuguer/Models/ to ship
├── working/                    # Index builders and their build products (build_corpus_index.py, build_classical_index.py, build_tail_index.py, build_literature_examples.py, build_chanson_examples.py,
│                               # merge_classical.py, mine_examples.workflow.js, mine_classical.workflow.js), plus the verb pass's Stage 0 reference
│                               # builders (build_wiktionary_reference.py and build_author_table.py) and its Stage 1 audits — verb_pass_lib.py (shared
│                               # loader: verbs.xml with ranks, conjugations, both Wiktionary references, authors, defect groups), audit_conjugations.py,
│                               # audit_flags.py, lint_glosses.py (+ gloss_lint_whitelist.txt), check_examples.py, build_candidates.py and
│                               # build_verb_pass_shards.py, whose outputs land in the ignored working/verb_pass/ (see plans/verb_pass.md);
│                               # the pass itself runs through verb_pass.workflow.js (check and skeptic modes, one subagent per shard) and its pilot is
│                               # graded by score_pilot.py against the answer key that build_verb_pass_shards.py --pilot plants beside the pilot shards;
│                               # validate_verb_pass.py checks Stage 2's result files (and, with --skeptic, Stage 3's verdict files) against their shards
│                               # and prints the pending list; build_skeptic_shards.py gathers Stage 2's proposals into the skeptic's shards, and
│                               # build_report.py writes plans/verb_pass_report.md and the approvals file Stage 4 reads; build_review_page.py
│                               # writes a local keyboard-driven review page for that file and merges its exported decisions back;
│                               # the added_glosses JSON file holds gloss changes no checker raised (hand-added, or from the false-friend sweep);
│                               # apply_verb_pass.py (Stage 4) applies the accepted approvals to verbs.xml, both example JSON copies and
│                               # docs/authored_examples.md, and logs what it changed beside the approvals, in the ignored working/verb_pass/;
│                               # Stage 5 (the verbs still without an example): list_missing_examples.py lists them with their failed prior attempt,
│                               # and the shard, skeptic, validator, report and review-page scripts take --only/--stage5/--pass-dir to run the pass
│                               # again over working/verb_pass/stage5/ without touching Stage 2–4's files; fetch_cnrtl.py fetches CNRTL
│                               # dictionary entries (TLFi, Académie, Littré) for a few verbs as evidence for the Stage 5c retry;
│                               # apply_verb_pass.py --pass-dir applies Stage 5's approvals (examples and glosses) the same way;
│                               # chanson_source.py emits the Roland's second half (laisses CLII–CCXCI) as Bédier-numbered rows
│                               # for the grokking agents, and --check asserts that numbering (see plans/chanson_second_half.md);
│                               # build_chanson_examples.py --dry-run reports Old French heads missing from the grokked/ descendants table;
│                               # the etymology tail (plans/etymology_tail.md): build_etymology_evidence.py gathers each uncovered verb's
│                               # Wiktionary etymologies, parsed formation and base material into an evidence file in the ignored working/etymology/,
│                               # and etymology_wave.py builds the affix library (the etymology_affixes JSON file in plans/) and selects, validates, merges
│                               # and reports each wave, which etymology_wave.workflow.js runs through the etymology-writer and
│                               # etymology-skeptic agents in .claude/agents/
└── grokked/                    # Intermediate per-source extraction output

frequency/                      # Verb-frequency pipeline; NOT part of any target. See frequency/README.md
├── build_counts.py             # GLÀFF + Lexique 4 → verb_counts.json + report.md, with the estimate tiers and gates
├── apply_counts.py             # verb_counts.json → the hi/hn/hl/hs/hp attributes of verbs.xml
├── generate_frequencies_txt.py # verbs.xml → docs/frequencies.txt, in VerbParser.ranked's exact order
├── verb_counts.json            # Per-infinitive measured counts and, where needed, frwac_estimate
├── editorial_counts.json       # The hand-assigned estimate tier: nine verbs, each with a reason
└── glaff_readme.txt            # GLÀFF's own README; its licence asks that it accompany redistribution

Images/                         # README and App Store imagery
└── achievements/               # The nine Game Center achievements' medallions as uploaded to App Store Connect (JPEG, 1024 × 1024), named for their IDs
build/                          # Scratch DerivedData for out-of-tree builds (gitignored)
```
