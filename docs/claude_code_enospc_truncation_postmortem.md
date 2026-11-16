# Postmortem: the false "temp filesystem is full (0MB free)" errors and silent Bash truncation

**Date resolved:** 2026-06-11
**Affected:** every Claude Code session on this machine since ~2026-05-29 (30+ sessions
across 9 projects: Conjuguer and its h1–h3/m1–m3 eval clones, Konjugieren, Eval,
CondoBot, BanyanSite, Safari, plus subagents)
**Environment:** Claude Code native macOS build (observed through 2.1.173), Intel Mac,
APFS with ~469 GB free, login shell `/bin/bash` (Apple's 3.2.57)
**Full technical evidence:** `~/Desktop/claude-code-bug-report.md` (machine-local)

## Summary

For two weeks, Bash tool calls in Claude Code intermittently failed with

> Command output was lost: the temp filesystem at `…/claude-501/<project>/<session>/tasks`
> is full (0MB free). The child process's stdout/stderr writes failed with ENOSPC.

or, worse, silently dropped the tail of a compound command while rendering as success.
The disk was never full. Two independent Claude Code bugs were compounding, and every
workaround adopted along the way (this repo's CLAUDE.md `rm -rf` advice, a
`CLAUDE_CODE_TMPDIR` override, per-project permission rules for temp-dir cleanup)
treated a symptom that had nothing to do with disk space.

## Root cause A: the ENOSPC banner is a broken measurement

When a Bash call ends with **empty stdout and a non-zero exit** (a lone no-match `grep`
suffices), the harness runs a statfs "is the temp filesystem full?" check to explain the
"lost" output. On macOS, the bundled Bun runtime's `fs.statfs` returns a field-shifted
struct — `bsize = 0`, with the real block size appearing in the `blocks` field
([oven-sh/bun#31133](https://github.com/oven-sh/bun/issues/31133), legacy
`statfs$INODE64` layout on darwin-x64). The harness computes free space as
`bavail × bsize = 0` and concludes, every single time, that the filesystem is full with
0 MB free. No ENOSPC errno is ever actually observed; the message is an inference from
arithmetic on garbage.

Minimal repro (100% deterministic before and after our fixes, since this one is
upstream's): ask Claude Code to run `sh -c 'exit 7'`.

## Root cause B: shadowed grep/find/rg killed the shell mid-command

The per-session shell snapshot — sourced before every Bash call — redefines `grep`,
`find`, and `rg` as functions that re-exec the Claude binary as embedded
ugrep/bfs/ripgrep. The function chooses between a bare `exec` and a subshell using
`[[ $BASHPID != $$ ]]`. **`$BASHPID` does not exist in bash 3.2** — and `/bin/bash` on
macOS has been frozen at 3.2.57 since 2007. With `$SHELL=/bin/bash`, the guard always
took the bare-`exec` branch, which **replaces the entire shell with the embedded tool**.
Everything after the `grep`/`find` in the command evaporated, and the call's exit code
became the embedded tool's exit code
([anthropics/claude-code#62642](https://github.com/anthropics/claude-code/issues/62642)).

The two bugs interlock: a killed shell usually leaves empty stdout and a non-zero exit,
which is exactly the trigger for Bug A's false banner. So the visible error said "disk
full" while the actual failure was "half your command never ran."

This also retroactively explained two older mysteries: the "intermittency" (a grep that
*matched* exited 0 and looked fine; censuses full of no-match greps died constantly),
and Konjugieren's long-line grep gotcha
([anthropics/claude-code#56751](https://github.com/anthropics/claude-code/issues/56751)),
whose symptoms vanished once `grep` was the real `/usr/bin/grep` again.

## How it was found

1. The error text in a session transcript pinpointed the harness's per-call capture dir
   and the exact wording of the check.
2. The native Claude Code build is a Bun single-file executable that embeds its
   JavaScript bundle as plain text, so `rg -a` against the binary, anchored on the error
   string, exposed the minified source of the check — revealing that "0MB free" was
   computed, not observed, and that the banner fires on the empty-stdout/non-zero-exit
   condition.
3. A standalone `bun -e 'statfsSync(…)'` on this machine returned `bsize: 0n`,
   confirming the measurement was garbage.
4. Live probes (`sh -c 'exit 7'`; `echo S1; grep <no-match> /etc/hosts; echo S2`;
   variants appending to real files) separated the two bugs: the banner reproduced with
   no tools involved, and the file-append probes proved the shell was being *killed* at
   shadowed-tool calls — the append after a no-match grep never executed.
5. GitHub's dedupe bot, of all things, supplied the final mechanism by matching our
   filed issue to #62642 (the `$BASHPID`/bash-3.2 analysis), which one local check
   (`BASHPID=[]` under `/bin/bash`) confirmed.

## Fixes deployed (defense in depth)

1. **Real ripgrep installed** (`brew install ripgrep`) — the snapshot's `rg` shadow has
   a runtime `command -v rg` guard, so this disabled it immediately, even for existing
   sessions.
2. **`--allowedTools Grep,Glob` added to the `claude` alias** in `~/.bash_profile` —
   flips the internal search-tools opt-in, so new sessions' snapshots contain no
   grep/find shadow functions at all.
3. **Global PreToolUse hook** (`~/.claude/hooks/neutralize-shadowed-tools.py`, wired in
   `~/.claude/settings.json`) — prefixes every Bash command with
   `unset -f grep find rg`, covering sessions launched without the alias (IDE, scripts).
4. **Login shell upgraded** to Homebrew bash 5.3 (`/usr/local/bin/bash`, registered in
   `/etc/shells`, set via `chsh`) — `$BASHPID` now exists, so even an unmitigated
   snapshot would take the safe subshell branch.
5. **Global `~/.claude/CLAUDE.md` note** telling every future session the banner is
   false and never to add `rm -rf` temp-dir cleanups.
6. **Cargo-cult removal:** this repo's CLAUDE.md section rewritten (its "the command
   body still runs even when output is lost" claim was wrong — the shell was dying);
   obsolete `rm -rf` permission rules deleted here, in Conjuguer.m3, and in Eval
   (including a leftover `.tmpcheck` TMPDIR experiment); Konjugieren's grep-gotchas doc
   marked resolved.
7. **Upstream:** filed
   [anthropics/claude-code#67623](https://github.com/anthropics/claude-code/issues/67623)
   with the combined analysis, then consolidated it as a duplicate into #62642 and
   [#65166](https://github.com/anthropics/claude-code/issues/65166), posting the
   confirmation evidence and workarounds on both.

## Verification (fresh session, new terminal)

- Snapshot contains zero shadow functions; hook prefix visible in the process wrapper.
- `grep` → `/usr/bin/grep`, `find` → `/usr/bin/find`, `rg` → `/usr/local/bin/rg`.
- `echo S1; grep <no-match> /etc/hosts; echo S2_alive` prints both lines, exits 0
  (previously: printed `S1`, exited 1, three-for-three).
- Bash tool runs under bash 5.3.15 with `$BASHPID` populated.
- Long-line grep matches (300/1,000/5,000 chars) render intact — Konjugieren's #56751
  gotcha no longer reproduces.

## Residual known issue

The false banner itself (Bug A) still appears for commands that genuinely produce no
stdout and exit non-zero, until Anthropic ships a guard or the fixed Bun lands
(merged upstream 2026-05-21, unreleased; tracked in #65166). It is cosmetic-but-
misleading; the global CLAUDE.md note instructs sessions to read it as a plain non-zero
exit and never chase disk space.

## Lessons

- **Distrust error messages that explain rather than observe.** The banner asserted an
  errno nobody had seen. The tell, in hindsight: it always said exactly "0MB" — a real
  near-full disk would have produced varying small numbers.
- **A workaround that doesn't work is evidence.** The `rm -rf` prefix rode along on the
  very call that failed; that should have falsified the disk theory immediately.
- **Correlate failures with content, not load.** "Parallel batches fail more" read as a
  concurrency bug; the real variable was how many no-match greps a batch contained.
- **Treat missing output as unknown, never as absence** — the one piece of the old
  guidance that survives, now for a reason we can name.
