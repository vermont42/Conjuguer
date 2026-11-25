![Conjuguer](Images/Splash.png "Conjuguer's Launch Screen")

Conjuguer
=========

**Conjuguer** is an iOS™ app for learning French verb conjugations. **Conjuguer** conjugates 6,326 verbs, regular and irregular, in _all_ French verb tenses, from the indicatif présent to the passé surcomposé. The app is localized throughout in English and French.

**Conjuguer** is two apps in one. The reference finds a verb from whatever a learner types, including a conjugation like _suis_, and shows every conjugation with its irregular letters in red, the verb's etymology, an example sentence, and the verbs related to it. The quiz is a practice hub: it grades the way a teacher would, says why a wrong answer is wrong, keeps a spaced-repetition record of what the learner knows, and offers five exercises beside the ordinary quiz.

**Conjuguer** is available for free download in the iOS App Store™. Tap the button below to install.

[![Install](apple.png)](https://apps.apple.com/us/app/conjuguer/id1588624373)

Alternatively, you can clone this repo and build **Conjuguer** yourself.

> The screenshots and features below are those of `main`. The App Store version, 2.2, predates the etymologies, the reference's new lookup features, and the quiz's practice hub, which arrive with the next release.

While developing **Conjuguer** in 2021, I learned about SwiftUI and how to mix it with UIKit. The app is now SwiftUI throughout, apart from a small UIKit shim that hosts Game Center's authentication UI.

### Screenshots

#### Looking Up Verbs

| Verb List | Search by Conjugation | Verb | Etymology | Example and Related Verbs |
| --- | --- | --- | --- | --- |
| <img src="Images/verb_list.png" width="190"> | <img src="Images/search.png" width="190"> | <img src="Images/verb.png" width="190"> | <img src="Images/etymology.png" width="190"> | <img src="Images/example.png" width="190"> |

| My Verbs | Collections | Collection | Model List | Model |
| --- | --- | --- | --- | --- |
| <img src="Images/my_verbs.png" width="190"> | <img src="Images/collections.png" width="190"> | <img src="Images/collection.png" width="190"> | <img src="Images/model_list.png" width="190"> | <img src="Images/model.png" width="190"> |

#### Practicing

| Practice Hub | From Your Practice | Exercises | One More Try |
| --- | --- | --- | --- |
| <img src="Images/practice_hub.png" width="190"> | <img src="Images/from_your_practice.png" width="190"> | <img src="Images/exercises.png" width="190"> | <img src="Images/one_more_try.png" width="190"> |

| Correction | Verb Essentials | Sentences | Name the Conjugation |
| --- | --- | --- | --- |
| <img src="Images/correction.png" width="190"> | <img src="Images/verb_essentials.png" width="190"> | <img src="Images/sentences.png" width="190"> | <img src="Images/name_the_conjugation.png" width="190"> |

| Which Fits Here? | Results | Daily Challenge | Mastery |
| --- | --- | --- | --- |
| <img src="Images/which_fits_here.png" width="190"> | <img src="Images/results.png" width="190"> | <img src="Images/daily_challenge.png" width="190"> | <img src="Images/mastery.png" width="190"> |

#### Reading and Playing

| Info | Verb History | Tense | Settings | Arcade Game |
| --- | --- | --- | --- | --- |
| <img src="Images/info_list.png" width="190"> | <img src="Images/history.png" width="190"> | <img src="Images/tense.png" width="190"> | <img src="Images/settings.png" width="190"> | <img src="Images/game.png" width="190"> |

### Looking Up Verbs

**Search finds what people type.** The search field takes an infinitive, an English meaning, or any conjugation, simple or compound. _suis_ finds both _être_ and _suivre_ and names the cells ("suis: Indicatif Présent (je, tu) · Impératif (tu)" under _suivre_). _j'ai mangé_, _que je sois_, and _je me souviens_ find _manger_, _être_, and _souvenir_. Accents are optional, so _etait_ finds _être_. When nothing matches, the app offers a guess. Opening a result lands on the matching rows of the verb page, tinted. Siri and Shortcuts ("Look Up a Verb"), Spotlight, a Control Center control, and a quick action on the app icon reach the same search from outside the app.

**The conjugation map is a build product.** Reverse lookup needs every conjugation of every verb. Rather than conjugating the whole corpus at launch, a macOS command-line target, `ConjugationMapTool`, compiles the app's own conjugator and writes the map as a bundled resource during the build, so the map can never disagree with the engine that generates it. The same tool writes the conjugation lists that the Python pipelines behind the example sentences read.

**The verb page** opens with the verb's meaning, model, auxiliary, and frequency rank, then gives every tense, ordered by how often French uses it, with irregular stems and endings in red so that the shape of an irregularity is visible at a glance. It ends with the etymology, an example sentence (for thousands of verbs, a quotation from Flaubert, Zola, Proust, Molière, or another writer, and, for 432 verbs, a second from the _Chanson de Roland_), and related verbs: those built on the verb (_devenir_ and _revenir_ on _venir_) and those that share its model. Every one of the 6,326 verbs has an etymology, in English and French. A long press copies a conjugation, a star adds the verb to My Verbs, Share sends the verb, its gloss, and its key conjugations as text, and Test Me asks three questions about the verb on the spot.

**Remembering what the learner looks up.** My Verbs lists starred and recently opened verbs. A review card on the verb list brings back an irregular verb whose key conjugations are due, hidden until tapped. Collections (the 100 most frequent verbs, the verbs taking _être_, the irregular futur stems, the pronominal verbs, and each of the 98 conjugation models) show how many of their verbs have been looked up, start a quiz on themselves, and share as a link.

**Models** are the conjugation patterns that the verbs inherit from, ranked by how irregular they are. A model's page shows its endings and stem alterations, its verbs, and a card for practicing it.

### The Quiz

**Grading accepts what is right.** Case, spacing, and a leading subject pronoun are ignored, so _j'ai parlé_ passes for _ai parlé_. The 1990 spelling rectifications count (_il connait_, _je cèderai_), as do the doublets that dictionaries list (_veuillons_). When a right answer was spelled another standard way, the quiz quietly shows the app's spelling beside the checkmark.

**The answer has a shape.** The text field sits inside the frame of the expected answer: the pronoun, elided as the answer requires (_j'_, _je m'_), the gender a compound tense's participle may agree with, and the person an impératif addresses. A row of accent keys (é è ê â î ô û ç) rides above the keyboard.

**Naming the error, without a language model.** [`AnswerDiagnosis`](Conjuguer/Models/AnswerDiagnosis.swift) asks whether a wrong answer is exactly what a known error would produce: the wrong auxiliary (_ai allé_), a participle that should or should not agree, a missing auxiliary, a spelling change left out (_mangons_, _commencait_), an irregular futur stem regularized (_venirai_), _vous faisez_, another person or tense of the right verb, or a regular or wrong-group form (_prendu_, _ils finent_). Each check builds the wrong conjugations its error would yield from the verb's own tables and compares, so a diagnosis is certain or absent, never a guess. A diagnosed error, or a slip of one letter or of accents alone, earns one more try at half points.

**A correction that stays.** A wrong answer stops the clock and holds the question on screen: both answers with the differing letters marked, the diagnosis, the verb's page and its model's page a tap away, and a note that the question will return three questions later.

**Levels and verb bands.** Four levels, Beginner through Advanced, each add the tenses that French courses teach next and widen the pool from the 100 most frequent verbs to 300, 1,000, and every verb. Rounds are ten questions, then ten more on request. Each level has its own personal best and Game Center leaderboard.

**A practice record with spaced repetition.** Every typed answer moves an item along a ladder of 1, 3, 7, 14, and 30 days. An irregular verb's items are its key conjugations (_vient · est venu · viendra_). A regular verb's are patterns its family shares, so _parlais_ and _chantais_ exercise the same -er imparfait. Review asks what is due, My Mistakes asks what was last missed, and Mastery shows what is secure at the learner's level. Up to three due items mix into every ordinary round.

**Five exercises** sit on the practice hub beside the ordinary quiz:

- **Verb Essentials** asks five irregular verbs' key conjugations, one blank at a time.
- **Conjugation Models** practices one model alone, then mixes it with the models the learner already knows.
- **Name the Conjugation** reverses the direction: given _fûmes_, name the infinitive, the tense, and the person. Every right reading is accepted, so _suis_ may be _être_ or _suivre_.
- **Sentences** blanks the verb in one of 750 short sentences covering the 300 most frequent verbs. A test checks each blank against the conjugator, so no sentence can teach a wrong conjugation.
- **Speed Round** gives sixty seconds of questions on items already mastered, for fluency.

**Which fits here?** From Elementary up, every ordinary round includes one of 66 sentence pairs that asks which a French speaker would use, and says why: after _si_, a hypothesis takes the imparfait, never the conditionnel.

**A daily habit.** The Daily Session asks ten questions, due items first, and builds a streak that survives one missed day if the learner does two sessions the next. An optional reminder says what is due. The Daily Challenge asks five questions, seeded by the date and level, the same for everyone, and shares its result as text. Custom quizzes choose tenses and verbs, and share with a class as a link or a QR code. The results screen offers an example sentence for each verb answered right, and Game Center keeps nine achievements for mastery milestones, never for volume of play.

**Privacy by construction.** The practice record lives on the device, in an App Group the widgets share, and is never sent. Analytics count what learners do, not what they answer: no signal carries an answer, a score, or the text of a search.

### Reading, Playing, and the Rest

- **Info** explains each French tense, when to use it, and how it is formed, illustrated with quotations from Proust, the _Chanson de Roland_, and others. Articles cover terminology, irregularity, and defectiveness, and _A History of the French Verb System_ runs some 4,000 words, from the formation of the Solar System onward.
- **Conjugation Tutor** answers French-conjugation questions on-device, powered by Apple's Foundation Models. Requires Apple Intelligence.
- **Widgets and controls**: a Verb of the Day and a daily quiz question that grades a tapped answer in place, on the Home Screen and Lock Screen; three Control Center controls (Quick Quiz, Random Verb, and Find a Verb); and a Live Activity during a quiz.
- **Retro arcade minigame**, reachable from Settings.
- **Alternate app icons**: Arc de Triomphe, rooster, croissant, or beret.
- **English and French** localization throughout, with VoiceOver labels that switch pronunciation between the two languages so that French forms are not read aloud as English.

### Under the Hood

**Data-driven conjugation.** [`verbs.xml`](Conjuguer/Models/verbs.xml) assigns each verb one of the 98 models in [`verbModels.xml`](Conjuguer/Models/verbModels.xml), which state their endings and stem alterations relative to a parent model. [`Conjugator.swift`](Conjuguer/Models/Conjugator.swift) applies them at runtime, and defective verbs come from their own groups in [`defectGroups.xml`](Conjuguer/Models/defectGroups.xml).

**Protocol-oriented dependency injection.** [`World.swift`](Conjuguer/Utils/World.swift) injects the app's services (settings, Game Center, analytics, the tutor's language model, the practice record, Live Activities, and the reminder scheduler) as protocols with Real, Fake, Spy, or Dummy implementations, so tests swap them without third-party frameworks.

**Testing.** A [Swift Testing](https://developer.apple.com/xcode/swift-testing/) suite of some 950 tests covers the conjugator, search, grading, diagnosis, the practice record, and the content files, among them every gap sentence and choice question.

**How it was built.** The browse and quiz work of late 2026 was ported from Konjugieren, Conjuguer's German sibling, in two plans of 14 and 24 phases, each built with [Claude Code](https://www.anthropic.com/claude-code) and committed before the next began. The plans live in [`plans/`](plans/) beside the code, so the reasoning behind each decision is in the repository.

### Building from Source

**Conjuguer** targets iOS 26 and builds with Swift 6. Open `Conjuguer.xcodeproj` in Xcode and build the
`Conjuguer` scheme.

Before your first build, create the gitignored `Conjuguer/Secrets.xcconfig` from its template. It holds
the analytics (TelemetryDeck) app ID, which is not checked in:

```bash
cp Conjuguer/Secrets.example.xcconfig Conjuguer/Secrets.xcconfig
```

Then fill in your own `TELEMETRY_DECK_APP_ID`, or leave the placeholder. The app builds and runs
either way; analytics simply go nowhere.

To run SwiftLint on each commit, enable the repo's pre-commit hook once per clone:

```bash
git config core.hooksPath .githooks
```

Further documentation lives in [`docs/`](docs), starting with the annotated directory tree in
[`docs/project_structure.md`](docs/project_structure.md) and the feature-by-feature guide in
[`docs/feature_architecture.md`](docs/feature_architecture.md).

### Verb frequency

Conjuguer ranks every verb by frequency of use. The counts behind those ranks are derived
from **GLÀFF 1.2.2** (Sajous, Hathout & Calderone; CLLE-ERSS, Université de Toulouse), a
lexicon built from Wiktionnaire and released under the [Creative Commons
Attribution-ShareAlike 3.0](http://creativecommons.org/licenses/by-sa/3.0/) licence, with
tie-breaks and a handful of compound-verb estimates from **Lexique 4.00** (New, Pallier,
Schalchli, Bourgin & Gimenes, 2026), released under CC BY-SA 4.0. From 2021 to 2026 the
rankings came from Lexical Computing's Sketch Engine, which covered the 981 most common
verbs.

> Franck Sajous, Nabil Hathout et Basilio Calderone (2013). *GLÀFF, un Gros Lexique À tout
> Faire du Français.* Actes de la 20e conférence sur le Traitement Automatique des Langues
> Naturelles (TALN 2013), Les Sables d'Olonne, France, pp. 285–298.
>
> Boris New, Christophe Pallier, Gauvain Schalchli, Jessica Bourgin & Manuel Gimenes (2026).
> *Lexique 4.* Behavior Research Methods.

The count attributes in [`Conjuguer/Models/verbs.xml`](Conjuguer/Models/verbs.xml) are
derived data under CC BY-SA 3.0. The app's own code is GPL, and the data file carries its
own notice. The pipeline that produced them, its provenance, and its re-download recipe are
in [`frequency/README.md`](frequency/README.md); the resulting order is
[`docs/frequencies.txt`](docs/frequencies.txt).

### License

**Conjuguer** is licensed under the GNU General Public License in order to discourage release of low-quality clones to the App Store™. Conjugar briefly suffered this indignity.
