# Conjuguer — Remaining Code-Review Findings

_Snapshot: 2026-07-08._

**All findings from [`code-review-findings.md`](code-review-findings.md) are now resolved.** Phases 1–6, the
heaviest refactor (#37), and the final #43 corpus/tooling cleanup are all done; finding **#36** (minigame Game
Center submission) is closed as **won't-fix** (the score is local-only by design). Nothing remains open — see
`code-review-findings.md` for the full per-finding write-ups and phase summaries.

---

## Recently closed

### #43 — Stale/dead repo files — **done 2026-07-08**
The Phase-2 pass fixed the `README.md` verb count + 2.0-features + Secrets step, deleted `launchAnalytics.sh`,
and untracked `.claude/settings.local.json`. The remaining corpus/tooling sub-items landed 2026-07-08:
- **`docs/literature-example-corpus.md` coverage figures reconciled.** The doc now leads with a single
  source-of-truth statement (`literature_examples.json` = 982 ranked + 144 Chanson-only = **1126 entries, 100%**),
  and the in-narrative 974/951/963 percentages are explicitly demoted to historical pipeline waypoints. The script
  table now lists all eight tracked build scripts (previously missing the classical tier's
  `build_classical_index.py`, `mine_classical.workflow.js`, `merge_classical.py`).
- **`merge_classical.py` dual-write.** It now writes **both** the `corpus/json/` export and the bundled
  `Conjuguer/Models/literature_examples.json` copy (matching `build_chanson_examples.py`'s existing dual-write),
  so the two copies stay in sync.
- **cwd-independence.** `scripts/take_screenshots.sh` resolves the repo root from `${BASH_SOURCE}` and `cd`s there
  (so the relative-cwd `build_app.sh`, `-project`, and screenshot-output paths all work from any directory);
  `mine_examples.workflow.js` and `mine_classical.workflow.js` drop the hardcoded absolute `REPO` for a `'.'`
  default (subagents `Read` relative to the repo-root cwd), overridable via `args.repo`.

### #36 — Minigame high score not submitted to Game Center — **won't-fix**
`GameState.swift:764-777`: by design, the minigame high score is intentionally local-only
(`Current.settings.gameHighScore`) and is not reported to Game Center. No code change.
