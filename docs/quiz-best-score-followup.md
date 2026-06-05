# Follow-up: surface the player's best score on the Quiz briefing screen

## Status

**Deferred** during the Batch B UI work (`conjuguer-ui-issues.md` → item **#3**, "Fill the
barren 'not started' quiz screen"). The briefing screen was built, but the *best score* part of
the recommendation was left out on purpose — see rationale below. Everything else in #3 shipped:
the `notStartedView()` builder in `QuizView.swift` now shows a glyph, the `readyHeading` headline,
the `tagline` one-liner, a `.card()` with the active difficulty + "30 questions", and the **Start**
CTA.

This document is the spec for a future session that wants to add the best-score readout.

## Why it was deferred

The recommendation's parenthetical — *"and the best score (Game Center is wired)"* — assumes the
score can be read locally. It can't, as the code stands:

- `Conjuguer/Utils/GameCenterable.swift` exposes only:
  ```swift
  var isAuthenticated: Bool { get set }
  func authenticate(onViewController: UIViewController, completion: ((Bool) -> Void)?)
  func reportScore(_ score: Int)
  func showLeaderboard()
  ```
  There is **no getter** for the local player's high score — the app *writes* scores
  (`reportScore` → `GKLeaderboard.submitScore`) and *shows* the leaderboard UI
  (`showLeaderboard` → `GKAccessPoint`), but never *reads* a score back.

So surfacing a best score needs a new async GameKit fetch threaded through the protocol and both
conforming types — more than the Batch B scope (a self-contained view-layer pass). It's a clean,
independent follow-up.

## What it touches

| File | Change |
|---|---|
| `Conjuguer/Utils/GameCenterable.swift` | Add an `async` best-score method to the protocol. |
| `Conjuguer/Utils/GameCenter.swift` | Implement it against `GKLeaderboard` (real GameKit). |
| `Conjuguer/Utils/TestGameCenter.swift` | Implement a stub returning a canned value (simulator / unit-test configs). |
| `Conjuguer/Views/QuizView.swift` | `notStartedView()`: add a `@State` best-score, load it in a `Task`, render it in the briefing `.card()`. |
| `Conjuguer/Models/L.swift` + `en.lproj`/`fr.lproj` `Localizable.strings` | A `QuizView.bestScoreWithColon` (or similar) label, plus a "no score yet" string. |

## Suggested implementation

### 1. Protocol method (`GameCenterable.swift`)

```swift
/// The local player's all-time best score on the default leaderboard, or nil if
/// unauthenticated / no score yet / the fetch fails.
func loadBestScore() async -> Int?
```

(Async, returns optional. Keep it failable-as-nil so the UI degrades silently — no error surface
on a briefing screen.)

### 2. Real implementation (`GameCenter.swift`)

`GameCenter` already loads `leaderboardIdentifier` during `authenticate(...)`
(`localPlayer.loadDefaultLeaderboardIdentifier`). Reuse it:

```swift
func loadBestScore() async -> Int? {
  guard isAuthenticated, !leaderboardIdentifier.isEmpty, leaderboardIdentifier != "ERROR" else {
    return nil
  }
  do {
    let leaderboards = try await GKLeaderboard.loadLeaderboards(IDs: [leaderboardIdentifier])
    guard let leaderboard = leaderboards.first else { return nil }
    let (localEntry, _) = try await leaderboard.loadEntries(for: [localPlayer], timeScope: .allTime)
    return localEntry?.score
  } catch {
    return nil
  }
}
```

Notes / gotchas:
- `loadDefaultLeaderboardIdentifier` resolves asynchronously *after* auth succeeds, so on a cold
  launch `leaderboardIdentifier` may still be `""` when the briefing first appears. Either (a)
  retry / re-load when `isAuthenticated` flips, or (b) load the default identifier inside
  `loadBestScore()` itself if it's empty. (b) is simpler and self-contained.
- This type carries one pre-existing Swift-6 concurrency warning already; keep the count from
  growing — mark the method/`@MainActor` boundaries to match the module's
  `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`.

### 3. Test double (`TestGameCenter.swift`)

```swift
var stubbedBestScore: Int? = 1234   // tweak per test / simulator demo

func loadBestScore() async -> Int? {
  isAuthenticated ? stubbedBestScore : nil
}
```

This keeps the simulator briefing populated (the simulator config uses `TestGameCenter`) and lets
any future unit test inject a value.

### 4. View wiring (`QuizView.swift`, `notStartedView()`)

```swift
@State private var bestScore: Int?
```

Add to the briefing `.card()` (below the "30 questions" line), only when a score exists:

```swift
if let bestScore {
  Text("\(L.QuizView.bestScoreWithColon) \(bestScore)")
    .smallLabel()
    .numericText()
}
```

Load it without blocking the screen — e.g. a `.task` on the not-started content (or fold into the
existing `.onAppear`):

```swift
.task(id: world.gameCenter.isAuthenticated) {
  bestScore = await world.gameCenter.loadBestScore()
}
```

Keying the `.task` on `isAuthenticated` re-runs the fetch once Game Center finishes authenticating
(the briefing's `onAppear` already kicks off `authenticate` when not yet authed), covering the
cold-launch race noted above.

### 5. Localized strings

Add to `L.QuizView` (mirror the existing `scoreWithColon` pattern) and both `Localizable.strings`:

- `QuizView.bestScoreWithColon` — en `"Best Score:"` / fr `"Meilleur score :"`

(If you also want an explicit "no score yet" affordance instead of hiding the row, add a
`QuizView.noScoreYet` string and render it in the `else` branch — optional.)

## Verification

Use the `ios-build-verify` skill on **iPhone 17 / iOS 26** (the Batch B target):

- `build_app.sh` then `run_tests.sh` — keep the suite green (99 tests at last Batch B run).
- `launch_app.sh` → `tap_tab.sh quiz` → `screenshot.sh quiz_best_score`. In the simulator the
  `TestGameCenter` stub makes the best-score row appear in the briefing card; confirm it renders
  with the Work Sans `smallLabel()` styling and doesn't break the centered layout.
- Real-device Game Center behavior (an actual leaderboard read) can't be exercised in the
  simulator — note that in the verification writeup and rely on the stub for the UI check.
- SourceKit will show spurious "Cannot find X in scope" diagnostics on the edited view file
  (same-module symbols); `build_app.sh` is authoritative.

## Scope guard

This is **optional polish**, not an open audit issue — item #3 is already marked `✅ DONE` in
`conjuguer-ui-issues.md` with this deferral called out. Do it as its own pass. If a best score
never materializes (e.g. product decides Game Center shouldn't be foregrounded on the briefing),
this doc can simply be closed without action.
