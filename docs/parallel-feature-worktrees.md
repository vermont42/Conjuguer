# Building Two Features in Parallel with Git Worktrees

This note captures the workflow for building the **conjugation tutor**
(`prompts/tutor.md`) and the **minigame** (`prompts/game.md`) at the same time,
each in its own git worktree driven by its own interactive Claude Code session.

## Background: sub-agents vs. interactive sessions

A **sub-agent** runs autonomously — it does its work and reports back to a parent
Claude, with no back-and-forth. That's wrong for collaborative feature work.

For **a Claude Code session in each worktree that you can interact with**, you open
**two separate Claude Code sessions in two terminals**, each `cd`'d into its own
worktree directory. Each is a full, independent Claude (its own context,
conversation, and permission state). You drive both directly, switching terminal
tabs between them. Neither is a "parent"; they're peers.

```
Terminal tab 1:  cd ~/Desktop/workspace/Conjuguer-tutor   → claude   (builds the tutor)
Terminal tab 2:  cd ~/Desktop/workspace/Conjuguer-game    → claude   (builds the game)
```

## The manual workflow (what you'd actually type)

**1. Create the worktrees** (run these from the main `Conjuguer` folder):

```bash
git worktree add ../Conjuguer-tutor -b feature/tutor
git worktree add ../Conjuguer-game  -b feature/game
```

This makes two sibling folders next to `Conjuguer/`, each on a fresh branch off
`main`.

**2. Open a Claude session in each.** New terminal tab per worktree:

```bash
cd ~/Desktop/workspace/Conjuguer-tutor && claude
# (another tab)
cd ~/Desktop/workspace/Conjuguer-game && claude
```

Hand each session its prompt (`prompts/tutor.md` and `prompts/game.md` — now
committed on `main`, so they appear automatically in each worktree).

**3. Work in parallel.** Each session edits files only in its own folder, builds
with its own `xcodebuild`, and commits to its own branch. They cannot collide on
source files. The one shared resource is the **iOS simulator** — two builds at once
is fine, but if both try to *launch* the app simultaneously they'll fight over the
same booted sim, so coordinate launches. (The game prompt says don't launch anyway,
so in practice only the tutor session launches.)

**4. Merge when done.** Back in the main checkout:

```bash
git checkout main
git merge feature/tutor
git merge feature/game        # resolve conflicts if any — unlikely, since the features touch different areas
```

**5. Clean up:**

```bash
git worktree remove ../Conjuguer-tutor
git worktree remove ../Conjuguer-game
```

## Wrinkles specific to this setup

- **Untracked build artifacts / config aren't shared.** Worktrees share git
  *history*, not your working-tree files. `build.log`, `.claude/` local settings,
  etc. exist per-folder. The `ios-build-verify` config is checked in
  (`.claude/ios-build-verify.config.sh`), so that travels fine.

- **The prompt files now propagate automatically.** They were committed to `main`
  (commit `0feaa29`), so `git worktree add` (which checks out `main`) carries them
  into each new worktree. No copying needed.

- **Session roles.** Keep the main `Conjuguer` checkout's session for coordination,
  merging, and questions; do the tutor and game work in their own worktree sessions
  so contexts stay clean.
