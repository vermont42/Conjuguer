# Conjuguer — Code Review Findings

_Review date: 2026-07-07. Reviewed against the tree at commit `2011018`._

## How this review was done

The whole codebase was read (app, widget extension, `Shared/`, tests, corpus tooling,
repo hygiene, and the Xcode project file). The full test suite was built and run first:
**169 tests in 14 suites pass, and the build is clean — zero warnings, zero errors.**
Several of the highest-impact findings were then **confirmed at runtime** by launching the
app in the simulator and inspecting the accessibility tree (noted inline as _runtime-confirmed_).

**Overall the codebase is in good shape and unusually modern:** Swift 6 language mode with
`MainActor` default isolation, `@Observable` throughout, `NavigationStack`, the modern `Tab`
API, Liquid Glass button styles, `AppStore.requestReview`, `GKLeaderboard.submitScore`, and an
async launch path that parses 6,320 verbs off the main actor behind a loading gate. There is no
dead-API debt of note. The findings below are therefore mostly specific correctness bugs and
polish, not systemic problems.

The intentional `ModelBrowseView` / `VerbBrowseView` duplication is **excluded** per the review
brief.

Findings are ranked highest-impact first. Each has a location, an explanation, and a concrete fix.
A suggested implementation sequence is at the end.

---

## Tier 1 — Correctness bugs that ship to users

### 1. Imparfait and participe présent are wrong for ~35 verbs (core conjugation engine) — _runtime-confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: High** · **`Conjuguer/Models/Conjugator.swift:230`**

> Fixed: `nousPrésentStem` now strips only the trailing `-ons`/`-ONS` ending, per alternate
> form (the `asseoir → "asseYons/assOYons"` alternate case was caught in test and handled by
> splitting on `Tense.alternateConjugationSeparator`). Regression coverage: `NousPrésentStemTests`.

`nousPrésentStem` derives the imparfait / participe-présent stem by stripping the `-ons` ending
from the *nous* présent form, but it uses a **global** replacement:

```swift
return value.replacingOccurrences(of: ons, with: "")      // ons = "ons"
  .replacingOccurrences(of: ONS, with: "")                // ONS = "ONS"
  .replacingOccurrences(of: Tense.irregularEndingMarker, with: "")
```

`replacingOccurrences(of:with:)` removes **every** occurrence of `"ons"`, not just the trailing
ending. Any verb whose *nous* stem contains an internal `"ons"` is mangled. Runtime output from
the Verbs tab:

| Verb | App shows (imparfait 1s / participe présent) | Correct |
|---|---|---|
| consommer | `je commais` / `commant` | `je consommais` / `consommant` |
| conseiller | `je ceillais` | `je conseillais` |
| considérer | `je cidérais` | `je considérais` |

About **35 infinitives** contain `ons` in the stem (`consommer, conseiller, considérer,
consacrer, consoler, construire, reconsidérer, déconstruire, …`). Each shows a wrong imparfait
(6 person-numbers) **and** a wrong participe présent in its conjugation table. Passé simple and
compound tenses are unaffected (they don't route through this helper), and verbs whose only
`"ons"` is the ending (e.g. `ronronner → ronronnais`) are correct — runtime-confirmed.

**Fix:** strip only the *trailing* ending, not all occurrences. The nous form always ends in
`"ons"` or (for irregular-marked forms) `"ONS"`, so:

```swift
var stem = value.replacingOccurrences(of: Tense.irregularEndingMarker, with: "")
if stem.hasSuffix(ons) {
  stem = String(stem.dropLast(ons.count))
} else if stem.hasSuffix(ONS) {
  stem = String(stem.dropLast(ONS.count))
}
return stem
```

This preserves the currently-correct `maudire → maudissant` and `couvrir → couvrant` cases
(both runtime-verified) while fixing the 35 broken verbs. Add a `Conjugator`/`VerbModelTests`
case for `consommer` imparfait + participe présent so the regression is pinned.

### 2. Daily-quiz widget: person and tense are perfectly correlated — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: High** · **`Conjuguer/Utils/WidgetSnapshotWriter.swift:104-105`**

> Fixed: tense index is now `(seed / PersonNumber.allCases.count) % quizTenseFamilies.count`,
> decorrelating it from the person. Also corrected the "simple tenses" comment (passéComposé is compound).

```swift
let personNumber = PersonNumber.allCases[seed % PersonNumber.allCases.count]   // seed % 6
let makeTense    = quizTenseFamilies[seed % quizTenseFamilies.count]           // seed % 6
```

`PersonNumber` has exactly 6 cases and `quizTenseFamilies` has exactly 6 entries, so both indices
are `seed % 6` — always equal. The daily quiz permanently welds each person to one tense
(je→présent, tu→passé composé, il/elle→futur simple, nous→imparfait, vous→subjonctif présent,
ils/elles→conditionnel présent). Only **6 of 36** possible combinations ever appear.

**Fix:** decorrelate the two indices, e.g.
`let tenseIndex = (seed / PersonNumber.allCases.count) % quizTenseFamilies.count`.
(Minor: the comment on line 13 calls these "the simple tenses" but `passéComposé` is compound.)

### 3. Robot-minion dive-bomb deals per-frame damage — instant death — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: High** · **`Conjuguer/Models/Game/GameState+RobotBoss.swift:284-298`**

> Fixed: mirrored the ball's fix — added `minionInvulnerabilityDuration`/`minionInvulnerabilityTimer`,
> decremented in `updateRobotMinion`, gated `collideMinionWithPlayer` on it, set on hit, reset in `seedWorld`.

This is the un-fixed twin of the soccer-ball overdamage bug that commit `9bb4f3e` fixed with a
1-second invulnerability window. The diving minion has the same exposure with **no** guard:

```swift
private func collideMinionWithPlayer() {
  guard let minion = robotMinion, minion.isDiving else { return }
  guard Self.intersects(...) else { return }
  registerPlayerHit()          // -0.25 health, EVERY frame of overlap
  Current.soundPlayer.play(.playerHit, shouldDebounce: false)
}
```

The minion is neither retired nor made invulnerable, and its dive parabola
(`dip = 4·depth·t·(1-t)`, `depth = screenHeight·diveDepthFactor`) lingers at the player's row for
~20 frames. A player standing under one dive absorbs `~20 × 0.25` health and dies instantly.

**Fix:** mirror the ball's fix — after `registerPlayerHit()`, set a minion invulnerability timer or
retire/bounce the dive so one pass costs one hit.

### 4. Widget snapshot never rotates at midnight — stale "Verb of the Day" / frozen quiz — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: High** · **`ConjuguerWidget/VerbDuJourWidget.swift:24-29`, `QuizWidget.swift:25-28`**

> Fixed: the app now precomputes `WidgetSnapshotWriter.futureDayCount` (7) daily snapshots
> (`generateSnapshots` / `writeSnapshots`) into a new `widget-snapshots.json`; `SnapshotReader`
> gains `readAll()` + a date-selecting `read(for:)`, and both providers emit one timeline entry
> per day (each placed at that day's midnight via `WidgetDateHelper.date(fromDateString:)`) with a
> `.atEnd` reload policy — so the widget rotates the verb/quiz on its own without an app relaunch.

Both providers build a one-entry timeline with `.after(nextMidnight)`, but the reload just
re-reads `widget-snapshot.json`, which **only the app rewrites** (`ConjuguerApp.swift:71-74`, on
`.task` / scenePhase-active). After midnight the widget shows yesterday's verb, and because the
stored answer ID still matches the stale snapshot's `questionID`, an answered quiz widget shows
"Correct!/Incorrect" indefinitely. Tellingly, `WidgetSnapshot.dateString` is written but never
read by the widget — the staleness signal exists and is ignored.

**Fix:** have the app write N future daily snapshots (`generateSnapshot(date:)` is already
parameterized) and let providers select by date and emit multi-day timelines; at minimum compare
`dateString` to today and render an "open Conjuguer to refresh" state.

### 5. Quiz completion emits a spurious `.quizQuit` analytics event (and quit sound) — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: High** · **`Conjuguer/Models/Quiz.swift:420-438`**

> Fixed: extracted a private `teardown()` (invalidate timer, `endLiveActivity()`, `quizState = .notStarted`);
> `completeQuiz()` now calls `teardown()` directly, and the sad-trombone + `.quizQuit` signal stay in `quit()`.

`completeQuiz()` reuses `quit()` for teardown:

```swift
private func completeQuiz() {
  ...
  Current.analytics.signal(name: .quizCompletion, parameters: [...])
  quit()      // ← plays randomSadTrombone AND signals .quizQuit
}
```

So **every successful completion also logs `.quizQuit`** (with `lastQuestionIndex`/`elapsedTime`),
corrupting the quit-vs-complete funnel, and tries to play the sad-trombone quit sound over the
applause. The trombone is currently inaudible *only* because it collides with the applause under
the shared-clock debounce bug (finding 12) — fix that debounce and the trombone starts playing on
every win. The two bugs mask each other.

**Fix:** extract the pure teardown (invalidate timer, `endLiveActivity()`, `quizState = .notStarted`)
into a private `teardown()`; have `completeQuiz()` call `teardown()` directly, and keep the
sad-trombone + `.quizQuit` signal in `quit()` only.

### 6. Privacy policy still names AWS Pinpoint, not TelemetryDeck — _confirmed_
**Category:** docs · **Severity: High** · **`privacyPolicy4.md:4`, `privacyPolicy4.html:2`**

Four commits after analytics moved to TelemetryDeck, the published policy still reads
_"Conjuguer uses the Amazon Web Services™ analytics product, Pinpoint™"_. It also omits two
events the app now sends (`tapPlayGame`, `tapShowOnboarding`). A privacy policy that names the
wrong data processor is an App Store / compliance problem.

**Fix:** rewrite for TelemetryDeck (provider, data categories, anonymization), add the new events,
regenerate the HTML from the Markdown, and update the App Store Connect privacy URL if it points
here.

---

## Tier 2 — Correctness edge cases, security policy, concurrency

### 7. Committed TelemetryDeck app ID defeats the Secrets.xcconfig mechanism — _confirmed_
**Category:** secrets · **Severity: Medium** · **`prompts/analytics.md:1`**

This tracked file (committed in `c087414`) contains the dashboard URL whose UUID
(`E4B957F6-…-5CB1EB8DAB1D`) is **byte-identical** to `TELEMETRY_DECK_APP_ID` in the gitignored
`Conjuguer/Secrets.xcconfig` — runtime-verified equal. This contradicts CLAUDE.md's "the app ID is
never committed" and defeats the whole secret mechanism. Practical risk is low (TelemetryDeck app
IDs ship inside the app binary and aren't signing credentials), but the stated policy is violated
and the ID is now in public history. _Secrets handling is otherwise clean: `Secrets.xcconfig` is
gitignored, untracked, and has no git history; no AWS keys or Amplify config were ever committed._

**Fix:** redact the UUID from `prompts/analytics.md`; then either rotate the app ID or consciously
downgrade the policy language in CLAUDE.md.

### 8. Widget extension min-OS (26.2) exceeds the app's (26.0); Swift 5 vs 6 for shared code — _confirmed_
**Category:** build-config · **Severity: Medium** · **`Conjuguer.xcodeproj/project.pbxproj:578,616` (widget) vs `469,499` (app)**

The app installs on iOS 26.0/26.1, but the embedded widget appex has
`IPHONEOS_DEPLOYMENT_TARGET = 26.2` — so **widgets, Controls, and Live Activity UI (rendered by
this extension) silently disappear on 26.0–26.1 devices**, plus an Xcode embedding warning. The
widget is also `SWIFT_VERSION = 5.0` with no `SWIFT_DEFAULT_ACTOR_ISOLATION`, so every `Shared/*.swift`
file compiles under two different language modes and isolation defaults.

**Fix:** set the widget target to 26.0 and `SWIFT_VERSION = 6.0` (+ `MainActor` default) unless 26.2
is a deliberate API floor — in which case document why and raise the app to match.

### 9. Negative `info` deep-link index crashes the app — _confirmed reachable_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: Medium** · **`Conjuguer/Utils/World.swift:183-188`**

> Fixed: the guard now uses `Info.infos.indices.contains(infoIndex)`, rejecting negative indices.

```swift
guard let infoIndex = Int(url.pathComponents[1]), infoIndex < Info.infos.count else { return nil }
info = Info.infos[infoIndex]
```

There is no lower-bound check, so `conjuguer://info/-1` parses to `-1`, passes the guard
(`-1 < 30`), and traps on `Info.infos[-1]`. The `conjuguer://` scheme is registered in
`Info.plist`, so a crafted external URL reaches this. The verb/model hosts are safe (dictionary
lookups); only the array-indexed info host is exposed.

**Fix:** `guard let infoIndex = Int(...), Info.infos.indices.contains(infoIndex) else { return nil }`.
(The tests agent also flags that `quiz`/`model`/`random`/rejection branches are untested — see 24.)

### 10. `VerbConjugations` cache is never invalidated on a pronoun-gender change — _confirmed_
**Category:** bug · **Severity: Medium** · **`Conjuguer/Utils/VerbConjugations.swift:38-48`**

`memoized(for:)` keys the cache on infinitive only and is **write-only** (no clear anywhere). The
cached simple-tense cells bake in the pronoun (`il`/`elle`, `ils`/`elles`), which depends on
`Current.settings.pronounGender` at build time. After a user changes the pronoun-gender setting,
every previously-viewed verb keeps showing the old gender's pronouns until app relaunch — a silent
regression of the exact feature that setting controls.

**Fix:** clear `VerbConjugations.cache` when `pronounGender` changes (e.g. from the setting's
`didSet`, or observe it), or fold the gender into the cache key.

### 11. Widget "deterministic" answer shuffle uses a randomly-seeded `Hasher` — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: Medium** · **`ConjuguerWidget/Views/QuizWidgetView.swift:89-99`**

> Fixed: `shuffledAnswers` now seeds `SeededRNG` from a process-independent FNV-1a hash of the
> question ID's UTF-8 bytes instead of `Hasher`, so the button order is stable across reloads and
> extension-process recycling.

The comment says "deterministic shuffle keyed on the question ID so the layout is stable across
reloads," but the seed comes from `Hasher()`/`finalize()`, and Swift's `Hasher` is seeded randomly
per process launch. WidgetKit recycles the extension process between reloads, so the same
question's buttons can reorder between renders — defeating the intent and enabling a mid-aim mis-tap.

**Fix:** replace `Hasher` with a stable hash of `questionID`'s UTF-8 bytes (e.g. FNV-1a) feeding the
seeded RNG.

### 12. Debounced game sounds are almost never audible (shared, unconditionally-updated clock) — _confirmed_
**Category:** bug · **Severity: Medium** · **`Conjuguer/Utils/SoundPlayerReal.swift:145-160`**

`instantOfLastPlay` is a single timestamp shared across all sounds and updated on **every** play,
debounced or not. During active play the non-debounced SFX (`.pop` per shot, `.chomp` per kill,
`.playerHit`) keep it fresh, so any `shouldDebounce: true` sound — `.soccerKick` on bounce,
`.cluck` on egg-lay, `.robotWeapon` — almost always sees `now - last < 1.0s` and is dropped. The
debounce is meant to be per-sound.

**Fix:** key the last-play instant per `Sound` (`[Sound: TimeInterval]`), or only bump the clock on
debounced plays.

### 13. Live Activity update/end are unordered fire-and-forget Tasks; `staleDate` is always nil — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** concurrency / bug · **Severity: Medium** · **`Conjuguer/Utils/LiveActivityManager.swift:40-52,26,39,49`**

> Fixed: update/end/end-all now route through a private `enqueue(_:)` that chains each ActivityKit
> call onto a serial `activityChain` `Task` tail (`await previous?.value` first), so states apply in
> submission order and `end` can't race a pending `update`; `start`/`update` pass a rolling
> `staleDate: .now + 300`. The redundant `@MainActor` closure annotations are gone (the enqueued
> closures are `@MainActor`-isolated to legally capture the non-Sendable `Activity`).

`updateQuizActivity`/`endQuizActivity` each spawn a detached `Task { @MainActor in await activity.update/end(...) }`
and return. Unstructured tasks carry no ordering guarantee across suspension points, so two rapid
answers can apply states out of order, and `end` can race a pending `update`. Separately, every
`ActivityContent` uses `staleDate: nil`, so a force-quit mid-quiz leaves a frozen "in-progress"
activity on the Lock Screen for up to the ~8h system cap (cleaned only at next launch). Also, the
`@MainActor` annotations are redundant given the app's default isolation.

**Fix:** serialize the updates (chain a `Task` tail, or make the functions `async` and `await` them
from `Quiz`), and pass `staleDate: .now + 300` (refreshed each update).

### 14. Widget timeline "next midnight" math breaks on DST days — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: Medium** · **`ConjuguerWidget/VerbDuJourWidget.swift:27`, `QuizWidget.swift:26`**

> Fixed: the fragile `startOfDay + 86400` math is gone. Timeline entries are now placed at each
> day's true midnight via `WidgetDateHelper` (a shared `Calendar(identifier: .gregorian)` doing
> `startOfDay` / `date(byAdding: .day)`), and the multi-day timeline (#4) uses `.atEnd` rather than
> a hand-computed `.after(nextMidnight)`.

`Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)` is 01:00 next day on a
23-hour spring-forward day (an extra stale hour) and 23:00 the *same* day on a 25-hour fall-back
day — a `.after` date in the past, which WidgetKit treats as refresh-ASAP (reload churn against the
budget). A French-learning audience largely lives in DST-observing CET.

**Fix:** `calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))`, extracted into
one shared helper used by both providers.

### 15. `LanguageModelServiceReal` polls availability every 5 seconds forever — _confirmed_
**Category:** concurrency / performance · **Severity: Medium** · **`Conjuguer/Models/LanguageModelServiceReal.swift:28-41`**

`init()` spawns an unstructured, never-stored, never-cancelled `Task` looping
`while !Task.isCancelled { try? await Task.sleep(for: .seconds(5)); refreshAvailability() }`. The
service lives in `World` for the app's lifetime and nothing retains a handle to cancel it, so it
wakes the process every 5 seconds forever — even when the Info tab is never opened.

**Fix:** re-check availability on `scenePhase == .active` (the app already has that hook) or via
Observation of `SystemLanguageModel.availability`, instead of a fixed poll; if a poll is kept, store
the task and cancel it in `deinit`.

### 16. `LargeWidgetView` hard-indexes the paradigm and can crash the extension — _confirmed_ — ✅ **implemented 2026-07-08**
**Category:** bug · **Severity: Medium** · **`ConjuguerWidget/Views/LargeWidgetView.swift:39-40`**

> Fixed: the présent-paradigm `Grid` is now gated behind `snapshot.présentParadigm.count >= 6`, so a
> short/corrupt/old-format decoded snapshot renders without the row (rather than trapping on the
> fixed `[row]` / `[row + 3]` indexing).

`conjugationCell(snapshot.présentParadigm[row])` / `[row + 3]` for `row in 0..<3` assumes exactly 6
entries; a short/corrupt/old-format decoded snapshot crashes the widget process. `SmallWidgetView`
(`.first`/`.last`) and `MediumWidgetView` (`prefix`/`suffix`) are safe by construction.

**Fix:** guard `présentParadigm.count >= 6` and fall back to placeholder, or iterate pairs safely.

---

## Tier 3 — Polish, hygiene, localization

Grouped; each is Low unless noted.

- **17. `nonisolated(unsafe)` shared static `callCount`** (`LanguageModelServiceReal.swift:211`): mutated
  from a nonisolated async `call(arguments:)` and reset from `@MainActor` — unsynchronized cross-isolation
  state, safe only by today's temporal serialization. Use a `Mutex` (iOS 18+), or make it a per-session
  instance counter and delete `resetCallCount()`.
- **18. `DateFormatter` without `en_US_POSIX`** (`WidgetSnapshotWriter.swift:167-171`) — ✅ **implemented 2026-07-08**: `yyyy-MM-dd` under the
  user's calendar emits era years on Buddhist/Japanese calendars, flowing into `questionID`. Pin
  `formatter.locale = Locale(identifier: "en_US_POSIX")` (and `referenceDate` to a Gregorian calendar);
  hoist the formatter out of the per-call path. **Fixed:** `dateString(for:)` now delegates to
  `WidgetDateHelper`, which formats from a fixed `Calendar(identifier: .gregorian)` via
  `String(format: "%04d-%02d-%02d", …)` — locale-/calendar-independent and allocation-free (no
  `DateFormatter` at all); `WidgetSnapshotWriter.referenceDate` and the day-diff math also use that
  Gregorian calendar.
- **19. `LocalizationTests` not language-pinned** (`ConjuguerTests/LocalizationTests.swift:20-30`): assert English
  literals with no `-AppleLanguages (en)` in the scheme's `TestAction`, so they fail on a French sim/CI.
  Pin the language or assert against the key / `String(localized:locale:)`.
- **20. Unlocalized tutor suggestion chips** (`TutorView.swift:22-39`): 16 user-facing English strings bypass
  `L`/xcstrings in a bilingual app. Route through `L.Tutor` with `fr` translations, or comment that English
  prompts are a deliberate model-quality choice.
- **21. `print()` in production paths** (9 sites: `Settings.swift:124`, `VerbModel.swift:75`,
  `XMLDataParser.swift:33`, `StemAlteration.swift:22/29/55`, `DefectGroupParser.swift`, `AudioSession.swift:15`,
  `DefectGroup.swift`): unfilterable and lost in release. The repo already has an `os.Logger` precedent in
  `LanguageModelServiceReal`; route these through per-category `Logger`s.
- **22. `.onTapGesture` + `UIApplication.shared.open`** (`InfoBrowseView.swift:179-184`): the tutor-unavailable
  cell should be a `Button` calling the `\.openURL` environment action (already used in `SettingsView.swift`).
- **23. Opaque nav-bar appearance fights iOS 26 glass** (`Modifiers.swift:11-28`, _design call_):
  `configureWithOpaqueBackground()` app-wide is at odds with the app's own `.buttonStyle(.glass)`. Consider
  per-stack `.toolbarBackground(...)`; keep the branded Work Sans title fonts if desired, but as a deliberate
  choice.
- **24. Stringly-typed error sentinel** (`RatingsFetcher.swift:12,47` + `SettingsView.swift:156`):
  `fetchRatingsDescription()` returns `"Fetching failed."` and the caller string-compares it. Return `String?`
  and `if let`.
- **25. `elapsedTimeString` vs `Int.timeString` divergence** (`Quiz.swift:33-35`): the Live Activity's
  `String(format: "%d:%02d", ...)` shows `61:05` where the in-app `Int.timeString` shows `1:01:05` past an hour.
  Reuse `elapsedTime.timeString`.
- **26. Dead availability annotations** (`LanguageModelServiceReal.swift:17,206`): `@available(iOS 26, *)` and
  `#if canImport(FoundationModels)` can never exclude anything at a 26.0 floor. Delete them.
- **27. `fatalError` in user-runtime paths** (`Quiz.swift:386`, `VerbConjugations.swift:126`, `Conjugator.swift:226`,
  `Verb.swift:81`): unreachable with today's data, but a future data typo becomes a user crash mid-quiz. Degrade
  gracefully with `assertionFailure` for the debug signal; keep hard crashes for parse-time integrity only.
- **28. `restart()` leaves transient game fields unreset** (`GameState.swift:297-345`): `movingLeft`/`movingRight`,
  `sineTime`, `smokeCooldown`, `smokeColorCycle` survive a restart; a held arrow at game-over makes the ship drift
  on "Play Again." Reset them in `seedWorld`.
- **29. `sineTime` accumulates unbounded** (`GameState.swift:135,421`): never wrapped or reset; long sessions push
  `sin(sineTime * 47)` phase arguments into the hundreds of thousands (cosmetic drift). Wrap with
  `truncatingRemainder` and reset in `seedWorld`.
- **30. dt clamp permits a ~1s catch-up step** (`GameState.swift:407-419`): a 0.9s hitch is applied in full
  (ball moves ~810pt in one step, can tunnel intersection tests). Clamp to a max sim step, e.g.
  `min(rawDt, 1.0/30.0)`.
- **31. `HapticPlayer` allocates a fresh generator per hit** (`HapticPlayer.swift:9-11`): `UIImpactFeedbackGenerator(...)`
  per call with no `prepare()` — churn and weaker/late haptics. Cache one generator per style and `prepare()`.
- **32. `AnswerQuizIntent` scores without matching the question ID** (`AnswerQuizIntent.swift:33-36`): stores
  correctness under the tapped `questionID` without checking it equals `snapshot.quizQuestion.questionID`; if the
  snapshot rotated between render and tap, the stored record is wrong (hidden today by the provider's ID gate).
  Guard on ID equality before scoring.
- **33. Etymology truncation can cut inside `~…~` markup** (`WidgetSnapshotWriter.swift:149-165`): an odd tilde
  count bolds the whole tail; the `correctAnswer + "xx"` distractor fallback can surface fake options like
  `parlonsxx`. Rebalance a dangling tilde after truncation; prefer real forms from other tenses as distractors.
- **34. Live Activity `elapsedTime` is a frozen String; `isFinished` is dead** (`QuizActivityAttributes.swift:20`,
  `LiveActivityManager.swift:24/51`): the Dynamic Island timer freezes between answers, and the final state is
  pushed then dismissed `.immediate` so nobody sees it. Put the start `Date` in the attributes and render
  `Text(_, style: .timer)`; drop `isFinished` or render a lingering results state.
- **35. Unconditional snapshot rewrite + `reloadAllTimelines()` on every foreground**
  (`ConjuguerApp.swift:42-48,71-74`): spends widget reload budget even when the bytes are identical. Compare the
  newly encoded `Data` to the existing file and skip write+reload when unchanged.
- **36. Minigame high score is never submitted to Game Center** (`GameState.swift:764-777`): persists to
  `Current.settings.gameHighScore` but never calls `Current.gameCenter.reportScore(_:)` (only `Quiz` does). Flagging
  so the local-only choice is explicit.
- **37. Minigame duplication** (`GameState.swift` vs `+RobotBoss`/`+Divers`/`+Ghosts`/`+Henyard`): projectile
  integrate-and-cull + homing-fire (`updateEnemyBullets`/`updateRobotBullets`, `attemptEnemyFire`/`fireRobotBullet`),
  the dive-arc parabola+sine (`+Divers` vs `+RobotBoss`), and three collision shapes (shoot-one-entity, player-hit
  sweep, collect-caught) are near-identical. A `MovingProjectile` protocol + a `diveArc(...)` helper + three small
  generic collision helpers would remove ~150 lines.

---

## Tier 4 — Test suite and repo tooling

- **38. `CorpusFormsDumpTests` is a repo-writing build tool run on every test pass — Medium** — ✅ **implemented 2026-07-07** (`.disabled` trait on the `@Suite`; test execution 48.4s → 1.5s, `run_tests.sh` 71s → 21s)
  (`ConjuguerTests/Models/CorpusFormsDumpTests.swift:85,138`): both `@Test`s conjugate the whole dictionary
  (~1.25M conjugations) and `write(to:)` into `corpus/working/` on every `run_tests.sh` — non-hermetic and slow,
  with only trivial `#expect(!ranked.isEmpty)` assertions. (The output files are gitignored, so no repo diff, but
  the filesystem side effect and wasted work are real.) **Measured:** with parallel testing off, this one suite is
  **47.2s of the 48.4s total test-execution time (97.5%)** — `testDumpAllVerbForms()` 41.0s +
  `testDumpUsageRankedVerbForms()` 6.2s — while the **other 13 suites run in ~1.2s combined**. Excluding it drops
  test execution ~40× (48.4s → 1.2s) and total `run_tests.sh` wall clock from ~71s to ~24s (the rest being
  incremental build + sim boot). The 1.25M conjugations are inherent to what the tool does, so the fix is to **trim,
  not optimize**: move both methods behind an opt-in trait excluded from CI (`.disabled("run manually")` or a
  filtered `.tags(.tool)` in a test plan), or lift the logic into a standalone `swift` script outside the test target.
- **39. Quiz scoring is barely tested; the deterministic seam is unused** (`QuizTests.swift:14-44`): tests submit
  `"x"` ×30 and assert only counts and `score == 0`. The `.ridiculous` score multiplier, the elapsed-time bonus
  (`score >= 150`), and the `bestScore` write-back are untested, and the `Quiz(gameCenter:shouldShuffle:)` seam added
  for deterministic testing is never constructed. Add a `shouldShuffle: false` suite feeding known-correct answers.
- **40. `WidgetSnapshotWriter` is entirely untested** despite an injectable `date:` seam on every method. Cover the
  day-index hash, `generateWrongAnswers` (dedup + padding), and `truncateToSentenceBoundary` with fixed dates. (This
  suite would have caught findings 2 and 33.)
- **41. Deep-link tests miss most branches** (`DeeplinkTests.swift`): no coverage of `quiz`, `model`, `verb/random`,
  the out-of-range `info` index (finding 9), or the malformed-URL rejections. Add them.
- **42. `.githooks/pre-commit` correctness gaps** (`:30`): lints the working-tree file rather than the staged blob
  (false pass/block with `git add -p`); `--diff-filter=ACM` omits `R` (a renamed-and-modified `.swift` escapes);
  `git diff --name-only` C-quotes non-ASCII paths (plausible in a French project) so accented filenames are skipped.
  Use `--diff-filter=ACMR` and `-z`-terminated output with `read -d ''`.
- **43. Stale/dead repo files:** `README.md` says 6,314 verbs (actual 6,320), mentions no 2.0 features (quiz, game,
  tutor, widgets), ships pre-2.0 screenshots, and omits the mandatory `cp Secrets.example.xcconfig Secrets.xcconfig`
  build step; `launchAnalytics.sh` is a dead `amplify console analytics` one-liner; `.claude/settings.local.json` is
  tracked with machine-local paths and broad permission grants (`git rm --cached` + gitignore it); `docs/literature-example-corpus.md`
  has three conflicting "current coverage" figures and an incomplete script table; `merge_classical.py` writes only one
  of the two JSON copies the doc says must stay in sync; `scripts/take_screenshots.sh` and the corpus workflow JS assume
  cwd = repo root / hardcode an absolute `REPO` path.

---

## Suggested implementation sequence

**Phase 1 — ship-blocking correctness (do first, each is small and independently testable):** ✅ **complete 2026-07-08** (all 171 tests pass)
1. ✅ Fix `nousPrésentStem` trailing-strip (#1) and add a `consommer` regression test (`NousPrésentStemTests`).
2. ✅ Decorrelate the widget quiz person/tense (#2).
3. ✅ Add the robot-minion invulnerability window (#3).
4. ✅ Split `Quiz.completeQuiz()` teardown from `quit()` (#5).
5. ✅ Guard the negative `info` deep-link index (#9).

**Phase 2 — release hygiene / compliance (before the next App Store submission):** ✅ **complete 2026-07-08** (all 171 tests pass, app + widget build clean)
6. ✅ Rewrote the privacy policy for TelemetryDeck + regenerated HTML (#6): both `privacyPolicy4.md`/`.html` now name TelemetryDeck, add the `tapPlayGame`/`tapShowOnboarding` events + elapsed time, and describe TelemetryDeck's anonymization.
7. ✅ Redacted the committed app ID (#7): the UUID in `prompts/analytics.md` is now `<TELEMETRY_DECK_APP_ID>`, and CLAUDE.md's policy wording is reconciled (kept-out-of-working-tree, with a history-exposure caveat + rotate note).
8. ✅ Lowered the widget deployment target to 26.0 and aligned Swift version (#8): widget target now `IPHONEOS_DEPLOYMENT_TARGET = 26.0`, `SWIFT_VERSION = 6.0`, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`; the Swift-6 upgrade surfaced a real actor-isolation error in `AnswerQuizIntent.perform()`, fixed by marking it `@MainActor`.
9. ✅ Refreshed README (#43): 6,314 → 6,320 verbs, added a 2.0-features section (quiz, minigame, tutor, widgets, l10n) + a Secrets build step, noted the screenshots are pre-2.0; deleted `launchAnalytics.sh`; untracked `.claude/settings.local.json` (`git rm --cached` + gitignore). (Remaining #43 sub-items — corpus-doc coverage figures, `merge_classical.py`, screenshot-script cwd — are corpus/tooling cleanups deferred to a later pass.)

**Phase 3 — widget & Live Activity robustness:** ✅ **complete 2026-07-08** (all 171 tests pass, app + widget build clean)
10. ✅ Multi-day snapshot rotation (#4), FNV-1a shuffle seed (#11), DST-safe midnight helper (#14), `LargeWidgetView` bounds guard (#16), `en_US_POSIX`-equivalent date formatting (#18), serialized Live Activity updates + `staleDate` (#13). New `Shared/WidgetDateHelper.swift` consolidates the calendar/date-string/midnight logic across the app + widget; snapshots moved from a single `widget-snapshot.json` to a multi-day `widget-snapshots.json`.

**Phase 4 — correctness edges & concurrency polish:**
11. Invalidate the `VerbConjugations` cache on pronoun-gender change (#10), per-sound debounce clock (#12), replace the 5-second LMS poll (#15), `Mutex` the `callCount` (#17), reset transient game state in `seedWorld` (#28) and clamp the sim step (#30).

**Phase 5 — test coverage (lock in the above, then broaden):**
12. Take `CorpusFormsDumpTests` out of the default run (#38); add quiz-scoring (#39), `WidgetSnapshotWriter` (#40), and deep-link-branch (#41) suites; pin `LocalizationTests` language (#19); harden the pre-commit hook (#42).

**Phase 6 — readability & polish (opportunistic, low risk):**
13. `Logger` migration (#21), `Button`+`openURL` (#22), sentinel→`String?` (#24), dead-availability cleanup (#26), `fatalError`→`assertionFailure` in runtime paths (#27), minigame de-duplication (#37), and the remaining Tier-3 items as they're touched.
