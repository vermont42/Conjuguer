# Game Center Setup

What Conjuguer's Game Center configuration is, where it lives, and how to change it. Written
2026-11-23, when each quiz level got its own leaderboard, and extended on 2026-11-24 with the
achievements. Adapted from Konjugieren's document of the
same name, whose steps this one follows and checks against what App Store Connect showed for
Conjuguer.

## Where the Configuration Lives

In **App Store Connect**, under **Apps** › Conjuguer › **Distribution** › **Game Center** (in the
sidebar, under Growth & Marketing). A link straight to
`…/apps/1588624373/distribution/gamecenter` loaded a blank page on 2026-11-23; open the app's
Distribution page and click **Game Center** in the sidebar instead.

Unlike Konjugieren, Conjuguer has no `GameCenterResources.gamekit` in the repo, Xcode's local copy
of the configuration, so App Store Connect is the only place it lives. Nothing here needs one. If
Josh later wants to test leaderboards in Xcode's Game Progress Manager before App Store Connect has
them, Konjugieren's `.gamekit` shows the shape.

## The Leaderboards

| Reference name | Leaderboard ID | English name | French name |
|---|---|---|---|
| Leaderboard | `software.racecondition.Conjuguer.Leaderboard` | Leaderboard | Classement |
| Beginner | `conjuguer.level.beginner` | Beginner | Débutant |
| Elementary | `conjuguer.level.elementary` | Elementary | Élémentaire |
| Intermediate | `conjuguer.level.intermediate` | Intermediate | Intermédiaire |
| Advanced | `conjuguer.level.advanced` | Advanced | Avancé |

`Leaderboard` is the original, live in the shipped app, and the app's Default leaderboard. It is
retired on `main`: nothing on `main` posts to it or opens it. The shipped app found it through
`loadDefaultLeaderboardIdentifier`; `main` names each level's board instead. The other four belong
to the levels, and the code takes their IDs from `QuizLevel.leaderboardID` in
`Conjuguer/Utils/GameCenter.swift`. `QuizLeaderboardTests.eachLevelHasItsOwnLeaderboard` pins
each ID literally.

**Leaderboard IDs are permanent.** App Store Connect will not edit one after creation, and a
leaderboard can no longer be deleted once it has been submitted for review. A level renamed later
keeps its ID. The `conjuguer.` prefix matches Konjugieren's `konjugieren.level.*` and keeps the
IDs apart from Conjugar's, should it get boards of its own.

Each level leaderboard has the same settings, as created on 2026-11-23 and read back from each
board's page:

| Setting | Value | Why |
|---|---|---|
| Type | Classic | Scores never reset. |
| Score Format | Integer | Scores are whole points. |
| Score Range | 0 to 100 | A ranked score is the first ten questions' points, at most 10 each, so Game Center rejects anything else. |
| Score Submission Type | Best Score | A player's best session stands. |
| Sort Order | High to Low | **The form defaults to Low to High.** Check it. |
| Hidden | No | |
| Score Format Suffix | None | The live `Leaderboard` has none either. |
| Image | None | Optional. The live `Leaderboard` uses `icon1024.png` in both languages; add the same to each if wanted. |
| Properties | None | The key and value shown ("difficulty", "normal") are placeholders. |

Each localization, English (U.S.) and French, as the live `Leaderboard` has, carries a description
of at most 120 characters:

- English: "The first ten questions of a quiz over all verbs at the Beginner level" (and so on per level)
- French: "Les dix premières questions d’un quiz sur tous les verbes au niveau Débutant" (and so on,
  with Élémentaire, Intermédiaire, and Avancé)

**What posts.** A default quiz over every verb posts the points of its first ten questions,
second-attempt half points included and re-asks not, to the leaderboard of the level it was
started at. Ten More posts nothing. A quiz over My Verbs, a collection, or one verb's page posts
nothing. Closing a default quiz's results opens that level's board. See
[`feature_architecture.md`](feature_architecture.md#grading-and-scoring).

**Ties.** Many players will tie at 100. Josh decided on 2026-11-23, as for Konjugieren, that
nothing breaks ties, which suits practice over examination and the hidden-by-default clock.

## Creating a Leaderboard

As App Store Connect presented it on 2026-11-23:

1. **Apps** › Conjuguer. The app opens on Distribution.
2. In the sidebar, under Growth & Marketing, click **Game Center**.
3. Click the **+** beside **Leaderboards (n)**.
4. **Add Leaderboard:** enter the Reference Name (up to 255 characters, internal only) and the
   Leaderboard ID (up to 100). Click **Next**.
5. **Choose Leaderboard Type:** Classic Leaderboard. Click **Next**.
6. **Choose Score Format:** set Score Format, Score Range, Score Submission Type, and Sort Order as
   in the table above. Click **Create**. The leaderboard opens with the status "Prepare for
   Submission".
7. Under **Leaderboard Localization**, click **Add Localization**. Choose the language (English
   (U.S.), then French, not French (Canada)), enter the Display Name (up to 30 characters) and the
   description, and click **Save**. Repeat with the **+** beside the heading for the second
   language. Leave both Score Format Suffix fields empty and Score Format (Optional) on
   "Choose...", so that the localization inherits Integer.
8. Do **not** click **Add for Review** until the release that uses the leaderboard is being
   submitted (below).

Leave **Leaderboard Sets** alone. Once an app has one set, App Store Connect requires every future
leaderboard to belong to a set, and four leaderboards gain nothing from one.

## Testing Before Release

Apple's docs say that a development-signed build sees leaderboards that are not yet live, marked
with a prerelease indicator. Konjugieren's try on 2026-11-14 found otherwise: its level boards were
invisible to a development build, probably because they had not been added to an app version
under test, and View Leaderboard showed "Cannot Connect". It also found that GameKit debug mode
(`enableGameKitDebugMode` in the scheme) hides every leaderboard; Conjuguer's shared scheme does
not set it. So the test waits for the 2027 version:

1. Create the new version in App Store Connect and add the four level leaderboards to it (each
   board's **Add for Review**, into the draft submission that holds the version). Do not submit.
2. Build to the iPhone from Xcode, signed in to Game Center in the iPhone's Settings.
3. Finish a ten-question quiz over all verbs at some level and close the results. That level's
   board should open with the score. Apple suggests a separate test account and removing test data
   when finished.

Expect two oddities of a development build, as Konjugieren saw: "Download the game to rank on this
leaderboard", and "This app is not available in the Games app".

## On Release Day

1. Submit the version with the four level leaderboards in the same submission. Apple says to submit
   Game Center components with the app version the first time they are added.
2. After the release is live, archive the old `Leaderboard`: on its page, **Archive Leaderboard** ›
   **Archive**. App Store Connect cannot delete a live leaderboard, and archiving removes it from
   Game Center's interface within about 24 hours. An older install that is never updated will
   then post to an archived board, which Game Center hides.
3. `Leaderboard` is the app's **Default** leaderboard, per the Game Center page's Default column.
   The app on `main` no longer reads the default, so this matters only for Game Center's own
   interface. Consider making Beginner the default.

[`release.md`](release.md) carries these steps.

## The Achievements

Nine achievements, approved by Josh on 2026-11-24, each for a mastery milestone rather than for
volume of play. An item counts once it is **mastered**, as the app's Mastery page counts it: in the
third box of the review ladder, a week or more from its next review. The code is
`Conjuguer/Models/Achievement.swift`; `AchievementTests.eachAchievementHasItsPermanentID` pins each
ID literally. **All nine exist in App Store Connect**, created by driving Chrome on 2026-11-24, as
Josh chose, and read back afterward: each in "Prepare for Submission", added to no version, with
its points, Hidden No, Achievable More Than Once No, and English (U.S.) and French localizations
carrying the image.

| # | Reference name | Achievement ID | Points | Milestone |
|---:|---|---|---:|---|
| 1 | Patterns Beginner | `conjuguer.achievement.patterns.beginner` | 10 | All 46 patterns that Beginner asks |
| 2 | Patterns Elementary | `conjuguer.achievement.patterns.elementary` | 25 | All 223 that Elementary asks |
| 3 | Patterns Intermediate | `conjuguer.achievement.patterns.intermediate` | 50 | All 368 that Intermediate asks |
| 4 | Patterns Advanced | `conjuguer.achievement.patterns.advanced` | 100 | All 901 that Advanced asks |
| 5 | Pillars | `conjuguer.achievement.verbs.pillars` | 25 | The three key conjugations of être, avoir, aller, faire, pouvoir, vouloir, devoir, and savoir |
| 6 | Ten Irregulars | `conjuguer.achievement.verbs.core10` | 25 | The three key conjugations of 10 of the 50 most frequent irregular verbs |
| 7 | Twenty-Five Irregulars | `conjuguer.achievement.verbs.core25` | 50 | The same, of 25 |
| 8 | Fifty Irregulars | `conjuguer.achievement.verbs.core50` | 100 | The same, of all 50 |
| 9 | House of Être | `conjuguer.achievement.etre` | 25 | The passé composé of the seventeen verbs of the maison d'être |

410 of Apple's 1,000 points, so there is room for more. Apple's limits, from its GameKit article
"Rewarding players with achievements" as Konjugieren read it on 2026-11-15: "a maximum of 100
achievements, 100 points per achievement, and 1000 points total for all achievements." A point
value cannot change once the achievement has been live, and the ID never can.

**What each counts.** A pattern achievement counts the patterns the Mastery page shows for its
level, those a verb of the level's band can be asked in the level's tenses, whatever level the
learner has chosen; a level's patterns include every lower level's. A verb counts toward the
irregular-verb achievements once its **three key conjugations** (présent, passé composé, futur)
are all mastered, whatever the level, so a Beginner who has met only the présent earns nothing; the
passé simple, which only Advanced asks, is not required. The 50 are the Mastery page's from
Elementary up (`Mastery.coreVerbs`), the same at every level above Beginner, and the eight pillars
are among them. The maison d'être counts twenty items: the passé composé key conjugation of aller,
venir, devenir, revenir, partir, sortir, naître, and mourir, and every person of the -er and -re
patterns with être, which arriver, entrer, monter, rester, tomber, retourner, passer, rentrer, and
descendre share. The -re pattern with être is first asked at Intermediate, whose band holds
descendre.

Each has the same settings: **Hidden** No (a learner should see what to aim for), **Achievable
More Than Once** No. **The form defaults Hidden to Yes**, so check it.

### Names and Descriptions

The pattern achievements build a Gothic arch, course by course to the keystone that locks it, la
clé de voûte. The verbs are columns and numbered shields, and the être verbs are the house French
schools draw for them. The French names come first, since most of Conjuguer's learners are
francophone; "formes" stands for patterns, as on the Mastery page, since "modèle" means a
conjugation model in the app.

| # | English name | Pre-earned description | Earned description |
|---:|---|---|---|
| 1 | First Stones | Master all 46 patterns that Beginner asks. A pattern is mastered once its next review is a week or more away. | Every pattern of Beginner, mastered. |
| 2 | The Walls | Master all 223 patterns that Elementary asks. A pattern is mastered once its next review is a week or more away. | Every pattern of Elementary, mastered. |
| 3 | The Vault | Master all 368 patterns that Intermediate asks. A pattern is mastered once its next review is a week or more away. | Every pattern of Intermediate, mastered. |
| 4 | The Keystone | Master all 901 patterns that Advanced asks. A pattern is mastered once its next review is a week or more away. | Every pattern of Advanced, mastered. |
| 5 | The Pillars | Master the three key conjugations, as in va · est allé · ira, of être, avoir, aller, faire, and the four modal verbs. | être, avoir, aller, faire, pouvoir, vouloir, devoir, and savoir, mastered. |
| 6 | Ten Irregulars | Master the three key conjugations, as in vient · est venu · viendra, of 10 of the 50 most used irregular verbs. | 10 of the 50 most used irregular verbs, mastered. |
| 7 | Twenty-Five Irregulars | Master the three key conjugations, as in vient · est venu · viendra, of 25 of the 50 most used irregular verbs. | 25 of the 50 most used irregular verbs, mastered. |
| 8 | Fifty Irregulars | Master the three key conjugations, as in vient · est venu · viendra, of all 50 of the most used irregular verbs. | All 50 of the most used irregular verbs, mastered. |
| 9 | The House of Être | Master the passé composé of the seventeen verbs of the maison d’être, in every person: je suis allé, elle est tombée. | The passé composé of the maison d’être, mastered. |

| # | French name | Description avant | Description après |
|---:|---|---|---|
| 1 | Premières pierres | Maîtrisez les 46 formes du niveau Débutant. Une forme est maîtrisée si sa révision est dans 7 jours ou plus. | Toutes les formes du niveau Débutant, maîtrisées. |
| 2 | Les murs | Maîtrisez les 223 formes du niveau Élémentaire. Une forme est maîtrisée si sa révision est dans 7 jours ou plus. | Toutes les formes du niveau Élémentaire, maîtrisées. |
| 3 | La voûte | Maîtrisez les 368 formes du niveau Intermédiaire. Une forme est maîtrisée si sa révision est dans 7 jours ou plus. | Toutes les formes du niveau Intermédiaire, maîtrisées. |
| 4 | La clé de voûte | Maîtrisez les 901 formes du niveau Avancé. Une forme est maîtrisée si sa révision est dans 7 jours ou plus. | Toutes les formes du niveau Avancé, maîtrisées. |
| 5 | Les piliers | Maîtrisez les conjugaisons clés (va · est allé · ira) d’être, avoir, aller, faire, pouvoir, vouloir, devoir et savoir. | être, avoir, aller, faire, pouvoir, vouloir, devoir et savoir, maîtrisés. |
| 6 | Dix irréguliers | Maîtrisez les trois conjugaisons clés (vient · est venu · viendra) de 10 des 50 verbes irréguliers les plus courants. | 10 des 50 verbes irréguliers les plus courants, maîtrisés. |
| 7 | Vingt-cinq irréguliers | Maîtrisez les trois conjugaisons clés (vient · est venu · viendra) de 25 des 50 verbes irréguliers les plus courants. | 25 des 50 verbes irréguliers les plus courants, maîtrisés. |
| 8 | Cinquante irréguliers | Maîtrisez les trois conjugaisons clés (vient · est venu · viendra) des 50 verbes irréguliers les plus courants. | Les 50 verbes irréguliers les plus courants, maîtrisés. |
| 9 | La maison d’être | Maîtrisez le passé composé des 17 verbes de la maison d’être, à toutes les personnes : je suis allé, elle est tombée. | Le passé composé de la maison d’être, maîtrisé. |

App Store Connect allows 30 characters for a name and 120 for each description, which is why the French
pattern descriptions say "7 jours" where the English says "a week". The French colon in row 9 takes
a narrow no-break space (U+202F), as the app's French does.

### The Artwork

Apple requires an image for each achievement, in each localization: "a `.jpeg`, `.jpg`, or `.png`
file that's 1024 x 1024 pixels, at least 72 ppi, and in the RGB color space" (as Konjugieren read
it on 2026-11-15). Game Center shows it in a circle, so each image is a round medallion with
everything important inside the middle 80%. The same image serves both languages, since none has
words; the irregular-verb shields carry only a numeral.

The drafts were made with the `gpt-image` skill on 2026-11-24, two per achievement, every prompt
giving the colors of `Conjuguer/Assets/Assets.xcassets` as hex values, as Josh decided for
Konjugieren. The prompts are in [`../plans/achievement_artwork.md`](../plans/achievement_artwork.md).
Josh left the choice to Claude, which took the first draft of each, since the first drafts of the
three shields share one arch and laurel and the first vault's plain piers match the keystone's.
The uploaded files are in `Images/achievements/`, named for their IDs (`patterns_beginner.jpg`,
`verbs_core10.jpg`, `etre.jpg`), JPEGs at quality 92, 1024 × 1024, RGB, 72 ppi, about 0.2 MB each,
the same image under both localizations.

### Creating an Achievement

As App Store Connect presented it on 2026-11-24:

1. **Apps** › Conjuguer › **Game Center** in the sidebar, as for a leaderboard. The page's own URL
   loads blank when opened directly; click through the sidebar.
2. Click **Add Achievement**, or the **+** beside **Achievements (n)** once one exists.
3. Enter the Reference Name (up to 255 characters) and the Achievement ID (up to 100) from the
   first table. Click **Create**. The achievement opens in "Prepare for Submission".
4. Enter the Point Value, set **Hidden** to No (the form defaults to Yes), leave Achievable More
   Than Once at No, and click **Save** at the top.
5. Under **Achievement Localization**, click **Add Localization**. Choose English (U.S.), enter
   the Display Name (up to 30 characters), the Earned and Pre-earned Descriptions (up to 120
   each), and choose the image. Click **Save**. Then the **+** beside the heading, and the same
   for French, not French (Canada). The image shows "Processing..." for a while afterward.
6. Do **not** click **Add for Review** until the release that reports it (below). Leave
   Properties and Game Activity empty.

Game Center lists the achievements in App Store Connect's order; **Edit Order** changes it. Keep
the table's order: the patterns by level, then the verbs, then the maison d'être.

### How the App Reports Them

`GameCenter.reportAchievements(in:)` computes each achievement's progress from the practice record
and passes it to `reportAchievementProgress(_:)` as a percentage, so Game Center shows an unearned
achievement's progress. It is called when the player signs in (the Quiz tab's first appearance),
when any quiz finishes or is quit, and when a review card is revealed, the moments an item can
reach the third box. It measures nothing while signed out. `GameCenterReal` holds what it is given
until Game Center has said what it already holds (`GKAchievement.loadAchievements`), then sends
only what has risen. The record can fall, a wrong answer sending an item back down the ladder, but
an achievement once earned stays earned. Game Center shows its own banner when one completes
(`showsCompletionBanner`).

The hub's **View Achievements**, below View Leaderboard at its foot, opens Game Center's
achievements (`GKAccessPoint.shared.trigger(state: .achievements)`). It appears only while signed
in. Conjuguer's Settings have no Game Center row, unlike Konjugieren's, so none was added there.

### Release Day and Testing

Add the nine achievements for review with the version, as for the level leaderboards. Apple says
achievements "must be approved before they are available to players", and that a development
build sees unreleased ones with a prerelease indicator. Given what Konjugieren found with its
leaderboards, expect them to be visible to a development build only once they are added to the
version under test. Then, on Josh's iPhone signed in to Game Center: finish a quiz, open **View
Achievements**, and check that the nine are listed with any progress. Earning one for real takes
at least three days of practice (a first right answer, then another when it is due).
