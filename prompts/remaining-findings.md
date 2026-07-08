# Conjuguer — Remaining Code-Review Findings

_Snapshot: 2026-07-08._

This file tracks the findings from [`code-review-findings.md`](code-review-findings.md) that are **not yet
implemented**. Phases 1–6 of that review are done; every Tier-1/Tier-2 finding and most of Tier-3 is
implemented (see the phase summaries in the source doc). What remains are heavier refactors, content/product
calls, and repo-tooling cleanups — all deliberately deferred, none ship-blocking.

For fully-implemented items and the original ranking/rationale, see `code-review-findings.md`. Finding **#36**
(minigame Game Center submission) is closed as **won't-fix** — the score is local-only by design. Finding **#20**
(unlocalized tutor chips) was **implemented 2026-07-08** — a locale-switched `frenchSuggestions` array following
the sibling app Conjugar's pattern, verified in a French-locale sim launch — and is no longer listed below.

---

## Code findings

### #33 — Etymology truncation can cut inside `~…~` markup
- **Where:** `Conjuguer/Utils/WidgetSnapshotWriter.swift:149-165`
- **Severity:** Low · **Type:** bug
- **Problem:** an odd tilde count after truncation bolds the whole tail; separately, the
  `correctAnswer + "xx"` distractor fallback can surface fake options like `parlonsxx`.
- **Fix:** rebalance a dangling `~` after truncating; prefer real conjugated forms from other tenses as
  quiz distractors instead of the `xx` padding.
- **Why deferred:** low-risk and self-contained — a good next pick. `WidgetSnapshotWriterTests` already exists
  and would be the place to pin the fix.

### #34 — Live Activity `elapsedTime` is a frozen String; `isFinished` is dead
- **Where:** `Conjuguer/Models/QuizActivityAttributes.swift:20`, `Conjuguer/Utils/LiveActivityManager.swift:24/51`
- **Severity:** Low · **Type:** bug / polish
- **Problem:** the Dynamic Island / Lock Screen timer freezes between answers (it's a String pushed per
  update), and the final state is pushed then dismissed `.immediate`, so nobody sees the finished state. The
  `isFinished` flag is effectively dead.
- **Fix:** put the start `Date` in the `ContentState`/attributes and render `Text(_, style: .timer)` so the OS
  animates it; drop `isFinished` or render a lingering results state instead of dismissing immediately.
- **Why deferred:** touches the Live Activity update path (recently reworked in Phase 3, finding #13); worth
  doing carefully with a device check.

### #35 — Unconditional snapshot rewrite + `reloadAllTimelines()` on every foreground
- **Where:** `Conjuguer/App/ConjuguerApp.swift` (snapshot-write + widget-reload hooks)
- **Severity:** Low · **Type:** performance
- **Problem:** the app re-encodes the widget snapshot and calls `reloadAllTimelines()` on every foreground even
  when the bytes are identical, spending the limited widget reload budget for nothing.
- **Fix:** compare the newly-encoded `Data` to the existing file and skip both the write and the reload when
  unchanged.
- **Why deferred:** low-risk optimization; bundle it with #34 or #33 in a widget-polish pass.

### #37 — Minigame duplication
- **Where:** `Conjuguer/Models/Game/GameState.swift` vs `GameState+RobotBoss.swift` / `+Divers.swift` /
  `+Ghosts.swift` / `+Henyard.swift`
- **Severity:** Low · **Type:** simplification
- **Problem:** near-identical logic is copied across mechanics: projectile integrate-and-cull + homing fire
  (`updateEnemyBullets`/`updateRobotBullets`, `attemptEnemyFire`/`fireRobotBullet`), the dive-arc parabola+sine
  (`+Divers` vs `+RobotBoss`), and three collision shapes (shoot-one-entity, player-hit sweep, collect-caught).
- **Fix:** a `MovingProjectile` protocol + a shared `diveArc(...)` helper + three small generic collision
  helpers would remove ~150 lines.
- **Why deferred:** **largest and riskiest** item. The minigame has **no unit-test coverage**, so this refactor
  must be verified by driving the game manually in the simulator (all mechanics, collisions, and boss phases).

---

## Repo / tooling cleanup

### #43 (remaining sub-items) — Stale/dead repo files
The Phase-2 pass fixed the `README.md` verb count + 2.0-features + Secrets step, deleted `launchAnalytics.sh`,
and untracked `.claude/settings.local.json`. **Still open** are the corpus/tooling sub-items:
- `docs/literature-example-corpus.md` has three conflicting "current coverage" figures and an incomplete
  script table — reconcile to one source of truth.
- `merge_classical.py` writes only one of the two JSON copies the doc says must stay in sync.
- `scripts/take_screenshots.sh` and the corpus-workflow JS assume `cwd = repo root` / hardcode an absolute
  `REPO` path — make them cwd-independent.
- **Why deferred:** corpus-pipeline hygiene, outside the shipped app target. Read
  `docs/literature-example-corpus.md` (and the corpus policy in `CLAUDE.md`) before touching anything under
  `corpus/`.

---

## Closed as won't-fix

- **#36 — Minigame high score not submitted to Game Center** (`GameState.swift:764-777`): **by design.** The
  minigame high score is intentionally local-only (`Current.settings.gameHighScore`) and is not reported to
  Game Center. No code change.

---

## Suggested order if picked up

1. **#33** (self-contained, already has a test suite) →
2. **#35** + **#34** as one widget/Live-Activity polish pass →
3. **#43** corpus/tooling cleanup (independent of the app) →
4. **#37** last, with a full manual game playthrough as the verification gate.
