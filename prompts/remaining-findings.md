# Conjuguer — Remaining Code-Review Findings

_Snapshot: 2026-07-08._

This file tracks the findings from [`code-review-findings.md`](code-review-findings.md) that are **not yet
implemented**. Phases 1–6 of that review are done, as is the heaviest refactor (#37); every Tier-1/Tier-2 finding
and all of Tier-3 is implemented (see the phase summaries in the source doc). What remains is only the #43
corpus/tooling cleanup — outside the shipped app target, deliberately deferred, not ship-blocking.

For fully-implemented items and the original ranking/rationale, see `code-review-findings.md`. Finding **#36**
(minigame Game Center submission) is closed as **won't-fix** — the score is local-only by design. Finding **#20**
(unlocalized tutor chips) was **implemented 2026-07-08** — a locale-switched `frenchSuggestions` array following
the sibling app Conjugar's pattern, verified in a French-locale sim launch — and is no longer listed below.
The widget-polish trio **#33** (etymology tilde rebalance + real-form distractors), **#34** (Live Activity
`Text(_, style: .timer)` + lingering finished state), and **#35** (skip-unchanged snapshot write/reload) was
**implemented 2026-07-08** (test count 192 → 196) and is no longer listed below.
Finding **#37** (minigame duplication) was **implemented 2026-07-08** (device-verified; test count 196 → **217 in
19 suites**) — a characterize-then-extract micro-cycle that added `MovingProjectile`/`advanceAndCull` +
`homingVelocityTowardPlayer` (projectiles), `diveArc(...)` (dive-arc), and `GamePositioned` +
`firstBulletIndex`/`removeOverlappingPlayer`/`collectOverlappingPlayer` (three collision shapes), each backed by a
new characterization suite (`GameProjectileTests`/`GameDiveArcTests`/`GameCollisionTests`) so the minigame went from
zero unit coverage to a full projectile/dive/collision net. It is no longer listed below; see `code-review-findings.md`
for the full write-up.

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

The only work left is the **#43** corpus/tooling cleanup (independent of the shipped app target). Read
`docs/literature-example-corpus.md` and the corpus policy in `CLAUDE.md` before touching anything under `corpus/`.
