# The second half of the *Chanson de Roland*: working plan (2026-10-02)

**Status:** not started. Written on 2026-10-02 after Josh noticed that *embroncher*'s single
*Chanson* example could not be the whole story. It wasn't: the verb occurs four times in the Oxford
text (verses 2019, 3505, 3645 and 3816 by the raw file's numbering), and the app shows only the first,
because `corpus/grokked/chanson.md` stops at verse 2033. The full treatment stopped at laisse CLI on
2026-06-05 (`corpus/working/chanson_progress.md`) and never resumed. Every verb's *Chanson* examples
come from the first half of the poem only, and the whole Baligant episode is missing.

This plan finishes the job: laisses CLII–CCXCI, about 1,970 lines, in the same per-laisse format,
then regenerates `chanson_examples.json` and updates everything downstream. Run it in a fresh
session. Paste:

```
Read @prompts/chanson-second-half-plan.md and complete the full treatment of the Chanson de Roland
from laisse CLII to the end: settle the line numbering (step 1), refresh the conventions (step 2),
grok the laisses in batches with a workflow and check each batch (step 3), audit the new Old French
heads (step 4), run the skeptic over every line the app will show (step 5), regenerate and apply
(step 6), and update the counts, credits and docs (step 7). A workflow is intended for steps 3 and
5; use the Workflow tool.
Mark completed steps with ✅ in this plan and add a correction note wherever the plan proved wrong
or incomplete. Do not commit; Josh commits.
```

## What already exists

| Path | What it is |
|---|---|
| `corpus/originals/literature/chanson-roland-oxford.txt` | The raw Old French (Orbis Latinus, Oxford Digby 23), `<number>\t<verse>` rows and `Laisse <roman>` headers, 291 laisses, rows numbered 1–4002. Its header explains lacunae and edition. |
| `corpus/grokked/chanson.md` | The hand-built edition: laisses I–CLI (lines 1–2033), each a block of numbered original lines with a verb bracket, then numbered translation lines. Irreplaceable; tracked. |
| `corpus/working/chanson_progress.md` | The ledger: last completed laisse, and the **numbering note** (read it). |
| `docs/chanson-full-treatment-prompt.md` | The June working prompt. Its conventions, the established verb-gloss table, the lacuna rules, the per-laisse subagent workflow and the consistency checker all still apply. **Its paths are stale** (it says `corpus/chanson.md`, `corpus/progress.md` and `corpus/chanson-roland-oxford.txt`; the files now live at the paths above), and it predates the numbering note. |
| `corpus/grokked/chanson_descendants.json` | 214 Old French heads → modern descendant, with `in_dict`. Drives which modern verb a `head (modern)` bracket attaches to. |
| `corpus/working/build_chanson_examples.py` | Parses `chanson.md`, resolves brackets, writes both copies of `chanson_examples.json` (`corpus/json/` and `Conjuguer/Models/`), and prints coverage and **unmatched tokens**. |
| `docs/literature-example-corpus.md` | The reflex-only attachment policy. Read its *Chanson* section before step 4. |

Today `chanson_examples.json` has 332 keys and 3,057 examples.

## 1. Settle the numbering first

The raw file's numbers are not all Bédier's, and the ledger says so: the folio marker `f.24rv` takes
row 1311, so from laisse CIII the raw number runs one ahead of Bédier, and `chanson.md` uses
**Bédier = raw − 1** from there. (That is why *embroncher*'s example says 2018 where the raw file says
2019. It is correct.) But the raw file's numbers run 1–4002 without a jump, the poem's last line,
"Ci falt la geste que Turoldus declinet", is Bédier 4002, and the raw file also numbers it 4002. So
somewhere between 2034 and 4002 the offset returns to zero, and nobody has found where. Candidates:
one of the three lacuna rows the raw file numbers (3146, 3390, 3494), a verse the extraction
wrongly joined to its neighbor ("verses wrapped across source lines were rejoined"), or a lacuna
that Bédier numbers and the raw file doesn't.

Find it before grokking anything. Compare the raw text against an independently numbered Bédier
text every hundred lines or so from 2034 to 4002, and bisect where the offset changes. Bibliotheca
Augustana and French Wikisource both carry numbered Oxford texts; fetch politely, one page at a
time, and cache what you fetch under the scratchpad. Write a small helper (in `corpus/working/`,
tracked) that emits the second half as `<bédier>\t<verse>` rows with laisse headers, lacunae marked,
so no subagent ever does offset arithmetic. Record the finding in `chanson_progress.md`'s numbering
note and in the raw file's header, which currently claims canonical numbering throughout.

**Acceptance:** the helper's output runs 2034–4002 gap-free (numbered lacunae included, as the
June prompt's rules say), and at least ten anchors spread across the range match the reference
edition.

## 2. Refresh the conventions

Fix the stale paths in `docs/chanson-full-treatment-prompt.md` (or replace its path references with
a pointer to this plan), and give it the numbering finding. The conventions themselves stay: one
bracket per line listing each lemma once, `head (modern)` for an obsolete or drifted reflex, bare
modern lemma otherwise, pronominals with their `se`, no bracket on a verbless line, lacuna lines as
the prompt specifies, a translation that is the model's own, and `<!-- uncertain: … -->` for doubt.
The established gloss table is the consistency anchor: subagents receive it whole, and the
orchestrator adds each batch's new mappings before the next batch starts.

**Model (decided 2026-10-02).** Every subagent in this plan, the grokking agents of step 3, the
head auditors of step 4 and the skeptics of step 5, runs on **Sonnet 5.5**, at Josh's choice. Pass
the model explicitly (`sonnet`, and confirm in the transcripts that it resolved to Sonnet 5.5, as
the verb pass did). The first half was translated by Claude (Opus 4.8), so the credits will name
both models.

One thing to settle with Josh before step 3, cheap to decide now and costly later:

- **Spelling variants in brackets.** The first half sometimes brackets a variant spelling as its own
  head (`embruncher`, where the modern verb is *embroncher*; `enbrunchet` and `enbrunket` will
  follow). The descendants table maps heads, so each new spelling needs a row or a bracket that uses
  an existing head. The recommendation is to bracket with the head the table already knows, and
  note the manuscript spelling only when it matters.

## 3. Grok the laisses (workflow)

140 laisses, CLII–CCXCI. The June prompt's per-laisse subagent pattern worked; run it as a workflow
in batches. A batch of about ten laisses (roughly 140 lines) per agent gives about fourteen agents.
Each agent receives the conventions, the full gloss table, its laisses' rows from the step 1 helper,
and an instruction to transcribe verbatim, never fetch, and return or write only the finished blocks.
Agents write their blocks to files under `corpus/working/chanson_batches/` (ignored) rather than
returning them, so a long result cannot be truncated.

After each batch, in code, not by eye:

- the June prompt's consistency checker, extended to the batch: original and translation numbers
  identical and gap-free against the helper's numbering;
- every original line identical to the helper's verse, character for character (the first half had
  silent normalization risks: editorial brackets `[S]erai`, `m(er)ercit`, dropped apostrophes
  `d or`; they must survive);
- every bracket token either in the gloss table, a bare `verbs.xml` key, or listed as new;
- no preamble lines, and a `---` rule between blocks.

Append passing batches to `chanson.md` in order, update the ledger after each, and add new mappings
to the gloss table. A failing batch reruns alone.

**Acceptance:** `chanson.md` runs 1–4002, 291 laisses, every original line has a translation line,
and the checker passes over the whole file.

## 4. Audit the new Old French heads

`build_chanson_examples.py` names the bare tokens it cannot resolve, but not the `head (modern)`
heads missing from `chanson_descendants.json`. It counts a missing head under "dropped (synonym
only)", the same bucket as a head the table says has no descendant, so a new head is dropped without
a trace. So:

1. Give the script a `--dry-run` (no JSON written) and a report of every head that has no row in
   the table at all, as distinct from a row with `in_dict: false`. Collect the new heads.
2. Audit each one as the June audit did: does the Old French head have a modern French descendant,
   and is that descendant in `verbs.xml`? Use the local English-Wiktionary extract under
   `corpus/working/wiktionary/` (its etymology text is offline and fast) before any live lookup. The
   June slices (`corpus/working/audit_out_*.json`, ignored) recorded `wiktionary_checked`, and some
   said `false`; the merged table dropped the field. This time keep the evidence in the row's `note`.
3. Add the rows to `chanson_descendants.json`, with `confidence` and a `note`, in the existing shape.
   Never add a verb to `verbs.xml` to give a head somewhere to attach; list candidates for Josh.

**Acceptance:** the script reports no unmatched token that is not either a deliberate drop (a
synonym-only gloss) or listed for Josh.

## 5. Skeptic over every line the app will show (workflow)

The app shows only lines whose bracket attaches to a verb, with their translation, under "Old French
— Chanson de Roland". Those lines are what a user reads, so every one of them in the new half gets a
skeptic: is the verb really in the line (and is the attached modern verb its reflex, not a synonym),
does the translation render the line faithfully, and is the line transcribed exactly? About 1,500
lines; shards of about 120, one Sonnet 5.5 agent each, verdicts `upheld`, `partly` (with the fix) or
`refuted`, written to files and validated in code as the verb pass did. Lines without an attachment
get no skeptic; their brackets and translations still sit in `chanson.md`, but the app never shows
them.

Fix `partly` lines in `chanson.md` directly, and for `refuted` either fix the bracket (often the
right answer is no attachment) or flag the line `<!-- uncertain -->` and drop its attachment. Show
Josh a sample of twenty cards (the habit from the verb pass) before the full skeptic run, and a
summary of the refutations after it.

## 6. Regenerate and apply

Run `build_chanson_examples.py` for real: it writes both JSON copies. Then:

- `cmp` the two copies;
- confirm *embroncher* has four examples (the acceptance case that started this) and that no first-half
  example changed (diff the old and new JSON, restricted to lines ≤ 2033);
- report the new totals: keys, examples, and verbs that gain their first *Chanson* example;
- build, run the suite (`CorpusFormsDumpTests` mentions Chanson-only verbs; check it), and in the
  simulator open *embroncher* and press the sword button through all four.

## 7. Counts, credits, docs

- **Credits** (`Info.creditsText`, both languages): the sentence "their English translations are
  original work by Claude (Opus 4.8)" must name both models and say which half each translated
  (Opus 4.8 for verses 1–2033, Sonnet 5.5 for 2034–4002).
  Grep the catalog for any *Chanson* count first. Catalog edits that touch an ASCII `"` go through
  Python, per CLAUDE.md.
- **`docs/literature-example-corpus.md`:** the *Chanson* section's counts and the statement of
  coverage; `docs/classical-authored.md` if any of its 63 archaic verbs now has more occurrences.
- **`chanson_progress.md`:** mark COMPLETE. **`docs/project-structure.md`:** the step 1 helper and any
  renamed file, then `python3 scripts/check_docs.py`.
- **Release notes** (`docs/release-notes-2.3.txt`, both languages): one short paragraph if Josh wants
  it, since the sword button now cycles through the whole poem.
- **Journal** (`docs/blog_notes.md`): the numbering hunt, the batch counts, the skeptic's refutation
  rate, and what the second half added.

## Out of scope

- **Re-auditing the first half.** Its brackets and translations stand, apart from heads the new
  audit touches.
- ***embroncher*'s gloss.** In all four Roland verses it means "bow, lower (the head or face)", or
  "droop" of a helmet; the app's gloss is "lay, set, position". That is a gloss question for a later
  gloss pass, not for this plan.
