# Reviewing the verb pass

How to decide which verb-pass changes ship. This is the step between Stage 3 and Stage 4 of
[`prompts/verb-pass-plan.md`](../prompts/verb-pass-plan.md). You record decisions in
`corpus/working/verb_pass/approvals.json`, and Stage 4 applies only what you accept.

You don't edit that file by hand. Rules settle most of it, and you judge the rest one card at a
time in a local review page.

## What is already settled

`approvals.json` holds 5,763 items. About three quarters are decided by rules in its `defaults`
block, or were decided in the late-edition triage:

| Items | How they're settled |
|---|---|
| 2,467 corpus and quotation picks | **Accepted by rule.** Code has already confirmed each sentence verbatim against its source, with a correct citation and an author who died before 1931. |
| 1,954 upheld authored sentences at rank 1,501 and below | **Accepted by rule.** This is the tail the plan meant to approve by category. |
| 70 late-edition quotations | **Decided by the triage:** 65 accept, 5 reject. They appear in the page so you can change your mind. |
| 5 doubtful quotations | **Held for review:** *traquer*, *grecquer*, *transiger*, *béer*, *morigéner*. No rule touches them, and Stage 4 skips them unless you decide them. |

A rule never applies to a `partly` item, and it never overrides a decision you make yourself.

## What is left for you: 1,347 items

| Group | Items | Why a person has to read it |
|---|---|---|
| Glosses | 816 | Users see the gloss most: in the quiz and read aloud by VoiceOver. Most of the skeptic's real disagreements are here. |
| Authored sentences marked `partly` | 285 | The skeptic found something to fix. 81 of them object only to the apostrophe (see below). |
| Upheld authored sentences in the top 1,500 | 86 | These are the common verbs, so they're worth a look. |
| Existing examples | 51 | The checker says a shipped example is flawed. |
| Flags | 34 | Auxiliary, pronominal, defective or aspirated-h changes. |
| Late-edition and held quotations | 75 | The 70 triaged and the 5 held, above. |

At about ten seconds an item, that's three to four hours. You can split it over as many sittings
as you like.

## Start

In a terminal, from the repository root:

```bash
cd ~/Desktop/workspace/Conjuguer
python3 corpus/working/build_review_page.py
open corpus/working/verb_pass/review.html
```

The first command rebuilds the page from the current `approvals.json`. Run it whenever you start
after a merge or a change to `defaults`. The page opens in your default browser. Always open it
in the same browser, because that's where your progress is kept (see *Saving*).

## Reading a card

Each card is one item, headed by the verb, with chips for the task, the rank, the skeptic's
verdict and severity, and your decision so far. Below that:

- **Current** is what the app ships today.
- **Proposed** (in blue) is what the Stage 2 checker (Sonnet 5) wants instead.
- **Checker** is the checker's own label and evidence.
- **Skeptic** is Opus 5's verdict and reason. `upheld` means the change is right. `partly`
  means something is wrong but the proposal isn't quite the fix, and the reason usually says
  what the fix should be. `error`, `hedge` and `nitpick` say how much it matters.
- **Checker notes**, and for an authored sentence the **Candidates** the checker passed over,
  appear when there are any.

## Deciding

| Key | Action | What Stage 4 does with it |
|---|---|---|
| **A** | Accept | Applies the change. On a `partly` item with no value of yours, that means the **checker's** proposal, unchanged. |
| **R** | Reject | Leaves the app as it is. |
| **E** | Edit the value, then **⌘↩** to save and accept | Applies your text instead of the proposal. **Esc** cancels. |
| **H** | Hold for review | Parks the item. Nothing applies it, and it stays in the undecided list. |
| **U** | Undo | Clears your decision on this card. |
| **J** / **→**, **K** / **←** | Next, previous | Accepting or rejecting moves on automatically. |

What an accept means depends on the task:

- **Gloss.** The proposed gloss (or your value) replaces the current one. If Proposed is `—`,
  the checker named a problem but offered no text, so an accept does nothing. Use **E** to write
  the gloss, or reject.
- **Authored sentence.** The French sentence and its English become the verb's example. Editing
  shows two boxes: French above, English below.
- **Existing example.** You agree the shipped example is flawed. If an English fix is proposed,
  it's applied. The French of a shipped example is never rewritten. If the example is being
  replaced instead, the replacement is the verb's own new-example item: a pick (already accepted
  by rule) or an authored sentence (its own card).
- **Flag.** The flag changes as proposed. For `dg` (defect group) the proposal is only "change
  the defect group". Accept it only with **E** and the group id, or reject it.
- **Pick.** The quotation or corpus sentence becomes the example. A pick can't be edited, because
  its French is a citation.

### How to judge

- **When the skeptic upheld it and you agree, accept.** Most upheld items are this.
- **On a `partly` item, the fix you want is usually the skeptic's, not the checker's.** Read the
  reason. If it names a better gloss or translation, press **E** and type it. Pressing **A**
  instead applies the checker's version, which the skeptic has just said isn't quite right.
- **Gloss house style** (decision 3 of the plan): no leading "to", commonest sense first, senses
  separated by commas (never semicolons), American spelling, the curly apostrophe `’`,
  parentheses only for register or region (as in "(informal)" or "(historical, racist)"), and a
  plain phrase rather than an obscure single word. Keep it short enough to hear aloud.
- **Examples keep the straight apostrophe `'`.** All 1,141 shipped examples use it. The curly
  apostrophe is the gloss style only. The skeptic got this wrong 81 times. Filter the verdict
  menu to **partly, apostrophe**, and for each card check whether the apostrophe is the reason's
  only complaint. If it is, press **A**. If the reason names another problem too, treat the card
  like any other `partly`.
- **When unsure, hold rather than guess.** Nothing held ships.

## A good order

Use the filters in the bar at the top. "Undecided or held" is the default state filter, so each
list shrinks as you work.

1. **Flags** (34) and **Existing examples** (51). They're short lists, and flags change
   conjugations, not just text.
2. **Glosses, ranks 1–1,500.** These are the common verbs, where a wrong gloss is seen most.
3. **Authored examples, verdict "partly, apostrophe".** These go fastest.
4. **Authored examples, ranks 1–1,500**, then the remaining `partly` authored sentences.
5. **The remaining glosses**, one rank band at a time.
6. **Picks.** Resolve the five held quotations if you can. The *traquer* note explains what
   would settle it. Otherwise leave them held.

"Go to verb" jumps to a verb by name, searching all items if the current filter hides it.

## Saving

- **Your progress is kept in the browser** (its localStorage for this file) and survives closing
  the tab. It is tied to this browser and this file's path. It is lost if you clear the
  browser's site data, and another browser won't see it.
- **Export at the end of every sitting.** Click **Export decisions**. The browser saves
  `verb-pass-decisions.json` to Downloads, holding every decision you've made so far. Then merge
  it:

  ```bash
  python3 corpus/working/build_review_page.py --merge ~/Downloads/verb-pass-decisions.json
  ```

  It prints how many decisions changed and the new totals. If the file names an item that isn't
  in `approvals.json`, it writes nothing and says so.
- If the browser saves the export as `verb-pass-decisions (1).json`, merge that file. The newest
  export always holds everything, so merging an older one after a newer one undoes work. Delete
  the old exports once merged.
- To move to another browser or machine, use **Import** with your latest export.

Merging is safe to repeat, and so is rebuilding the report (`build_report.py`). Neither resets a
decision you've made.

## Changing a rule

If you'd rather settle a group by rule after all (for example, accept every upheld gloss at rank
4,501 and below), edit that rule's `decision` in the `defaults` block at the top of
`approvals.json`. Each rule names a task (`gloss`, `example`, `new_example`, `flag`, `pick`) and a
rank band. Then rebuild the page, and the items the rule now covers drop out of it. A rule still
never touches a `partly` or held item.

## When you're done

The review is done when **Undecided or held** with all other filters cleared shows only items
you chose to hold. Export and merge one last time. Then start Stage 4 by pasting its prompt from
`prompts/verb-pass-plan.md` into a fresh session.
