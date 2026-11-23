# Game Center Setup

What Conjuguer's Game Center configuration is, where it lives, and how to change it. Written
2026-11-23, when each quiz level got its own leaderboard. Adapted from Konjugieren's document of the
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
