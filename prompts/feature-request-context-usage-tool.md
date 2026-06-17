# Feature request: model-callable context-window usage tool

Draft for Claude Code's `/feedback` (aliases `/bug`, `/share`) or a GitHub issue at
https://github.com/anthropics/claude-code. Captured here for tracking.

---

**Title:** Expose a model-callable tool for current context-window usage (to enable smart fresh-session handoffs)

## Problem

The model has no reliable way to know its own context-window usage mid-conversation. Models can't
self-measure token consumption (tokenization variance, no internal accounting), so when deciding
whether to take on a large next task, the model is flying blind — it either guesses (badly) or relies
on the human to volunteer the number.

This matters most at a specific decision point: the model is about to propose a big, discrete task (a
multi-stage pipeline, a broad refactor, a fan-out job) and *should* weigh whether to do it inline vs.
hand it off to a fresh session. Right now it can't make that call on usage grounds because it can't
see usage.

## Key insight: the data already exists and already flows

The status line is already handed a JSON payload containing `context_window.used_percentage` and
`remaining_percentage`. So the harness already computes this per turn and pipes it to a shell script
for the *human*. This request is just: **expose the same struct to the model via a callable tool** —
not new plumbing.

## Proposed solution

A read-only tool the model can call on demand, e.g. `get_context_usage`, returning something like:

```json
{
  "used_tokens": 217090,
  "window_tokens": 1000000,
  "used_percentage": 21.7,
  "remaining_percentage": 78.3,
  "tokens_until_autocompact": 612910
}
```

The model consults it before proposing a large task and, if usage is high, offers a curated
fresh-session handoff prompt instead of plowing ahead.

## Design considerations

1. **Threshold must be relative, not absolute.** A naive "warn above 200k tokens" rule misfires
   across models — a 1M-window Opus session at 217k is only ~22% full, nowhere near the edge, while
   217k on a 200k-window model is over the limit. Trigger on `used_percentage` /
   `tokens_until_autocompact`, never a raw token count.

2. **Frame the payoff as "handoff vs. compact," not just "you're full."** Auto-compact already fires
   near the limit, but it produces a *lossy summary*. For a big discrete task, a curated fresh-session
   prompt preserves *intent and decisions* far better. The valuable model behavior is: *next task is
   large* **and** *context is heavy* → offer a clean handoff prompt as a higher-fidelity alternative
   to compaction. Note this needs two inputs: task size (only the model can judge) and usage (only a
   tool can supply).

3. **A pull tool is the right primitive.** Only the model knows when it's about to propose something
   big, so a purely proactive harness nudge can't see that intent coming. An optional
   threshold-crossing system-reminder could complement the tool, but the on-demand tool is the
   load-bearing piece. It should be cheap and idempotent so the model can call it without side
   effects, but guidance should discourage constant polling.

## Alternatives considered

- **Auto-compact alone** — compresses within a session but loses intent fidelity; doesn't help the
  model *decide* to hand off.
- **Human volunteers the number** — current state; fragile and the human often doesn't know either.
- **Model estimates usage** — unreliable by nature.

## Additional context

Came out of a real session where the human had to tell the model its approximate context size so it
would suggest writing a handoff prompt for a token-heavy follow-up task. The model produced a good
handoff prompt — but only because the human supplied the usage figure it couldn't see itself.
