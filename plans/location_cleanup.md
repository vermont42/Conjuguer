# Plan: Sort Prompts, Plans, and Documents, and Rename to snake_case

**For:** a fresh Claude Code session in this repo. **Kind of work:** moving and renaming prose and
data files, repairing every reference to them, and a few documentation edits, one of them in
`scripts/check_docs.py`. No app behavior changes. **Written:** 2026-11-16 by the Konjugieren
session that did the same work there that day (Konjugieren commits `42ef201` and `bb22346`).

## Status

**Done, 2026-11-16, uncommitted.** 79 files renamed (69 in the three folders, plus three each in
`frequency/` and `.claude/rules/` and four in `Images/`, at Josh's request) and 74 others edited.
The map is `plans/location_cleanup_moves.json`. Josh chose to move and rename the six
blog-linked files. The post's ten links are retargeted in the Blog repo, uncommitted, and he
said not to push. `check_docs.py` reports 0 problems.

**How it differed.** The `.gitignore` line for the WWDC transcripts is a glob, which the tool
cannot rewrite, so the transcripts became untracked and committable until it was fixed by hand.
`build_report.py` builds its report path from segments, and its folder needed a hand edit when
Josh put the verb-pass reports beside their plan. The six agent definitions cite their plans
only in their descriptions, so the risk this plan describes for them did not exist. JSON files
in `docs/` and `plans/` are written as `name [.json]` in the structure doc, because the checker
treats any `.json` name there as a shipped data file.

## Stop Here First: a Published Post Links Into This Repo

Josh's ruling is that a link from a published blog post is the one thing that stops a rename.
This repo has that case, and the sorting below would break it.

`~/Desktop/workspace/Blog/_posts/2026-06-09-fable-and-opus.md` links, on lines 36, 38, 62, and
173, to these paths on GitHub:

- `prompts/` itself, the folder, twice
- `prompts/code-review-suggestions-union.md`
- `prompts/code-review-suggestions-Opus-high.md`
- `prompts/code-review-suggestions-Opus-max.md`
- `prompts/code-review-suggestions-Fable-high.md`
- `prompts/code-review-suggestions-Fable-max.md`
- `docs/model-eval-analysis.md`

By the rule, the five review files are Claude's output and belong in `docs/`, and all six files
would take snake_case names. Every one of those changes breaks a link in the post once pushed,
because GitHub does not redirect a renamed path. The folder link survives while `prompts/`
exists, but the post may describe the folder's contents in a way that stops being true.

**Before moving or renaming any of these six files, ask Josh which he wants:**

1. Leave the six exactly where and as they are, as recorded exceptions to the rule.
2. Move and rename them, and repair the post in the Blog repo in the same sitting. The Blog repo
   has its own `CLAUDE.md` and its own publishing step, and the links stay broken until he
   publishes.

Everything else in this plan can proceed while he decides. Re-run the search in step 1 yourself:
this list was measured once, by a session that had already been fooled once that day.

## What Josh Wants, and Why

Josh's own words, from the prompt that started this in Konjugieren
(`../Konjugieren/prompts/location_cleanup.md`):

> In my head canon, a prompt is something that I write to get Claude to do something, a plan is
> something that Claude writes to get another session to do something, and a document is an
> output from Claude that contains information and is not a plan. Example: research.

And the reason, which settles more borderline files than the definitions do:

> If only Claude worked on this project, everything could live in one big folder. But folders
> make finding files easier for me. I sometimes don't even remember filenames, just a vague sense
> that I wrote a prompt or you wrote a plan about some subject.

So **authorship decides the folder**, and when a file fits two folders, choose the one where he
would look first. Then two rules about names:

> In general, I try to live by DRY, including in filenames. File location now specifies file
> role: plan or prompt. I prefer snake_case over kebab-case.

The end state: `prompts/` holds what Josh wrote, `plans/` holds what Claude wrote to direct
another session, `docs/` holds Claude's informational output, every file and directory in the
three folders is snake_case, and no filename repeats the word its folder already says.

## Read First

1. `../Konjugieren/CLAUDE.md`, the sections **Prompts, Plans, and Documents** and **File Naming**.
   They are the finished form of the rule. You will add adapted copies here.
2. `../Konjugieren/docs/blog_notes.md`, the seven entries dated 2026-11-16, starting at "Prompts,
   plans, and documents, each in its own folder". They say what went wrong and why each ruling
   was made. The last one, "A search that could not fail", is the one not to skip.
3. The docstring of `../Konjugieren/scripts/rename_files.py`, the tool you will use.
4. This repo's `CLAUDE.md`, above all **Work journal**, **Prose style**, **Version Control**, and
   the paragraph on `scripts/check_docs.py`.

## Rulings Already Made

Josh ruled on these cases in Konjugieren. Apply them here without asking again.

| Case | Ruling |
|---|---|
| A plan, orchestrator plan, subagent brief, handoff, or resume prompt that Claude wrote | `plans/`, even though a brief is a "prompt" in the ordinary sense |
| A prompt Claude wrote for another tool (an image generator, Claude in Chrome) | `plans/` |
| A file Josh began that Claude has mostly written since, and that still has work to do | `plans/`. Majority authorship decides, not who began the file |
| Josh's prompt carrying a status line Claude added later | `prompts/`. It is still his prompt |
| Research, an audit, tiered recommendations, a findings report | `docs/`, even with "plan" in the name |
| A playbook or pipeline description: how something is done whenever it is done | `docs/` |
| A review sheet or audit that a plan's phase generated | Stays beside that plan in `plans/` |
| A file that drops "prompt" or "plan" and is left with too little to identify it | Name it for its subject (`example_prompt.md` became `example_authoring.md`) |
| The journal, `docs/blog_notes.md` | Retarget link targets only. Leave every word as written |
| A link to a renamed file in an old email | Not a reason to stop |
| A link to a renamed file in a **published blog post** | Stop and ask Josh before renaming |

Names that are not ours to choose stay as they are: Swift source files, anything a tool dictates
(`.claude/ios-build-verify.config.sh`, `.claude/agents/`, `.claude/skills/`, `.githooks/pre-commit`),
a downloaded file's publisher name, and the conventional capitals of `README.md`, `LICENSE`, and
`CLAUDE.md`.

## This Repo, As Measured on 2026-11-16

Measure again before relying on any number here.

- **Branch `main`, clean tree.** `plans/` exists and holds only this file.
- **`python3 scripts/check_docs.py` passes** with 0 problems. Keep it that way.
- **`prompts/`: 49 files, no subdirectories**, in a mix of kebab-case and snake_case, some with
  capitals (`verbHistory.md`, the `-Fable-` and `-Opus-` review files). This repo's structure doc
  calls the folder an "archive of the session prompts", so expect both Josh's prompts and
  Claude's plans in it. Subject pairs are a strong hint and are not proof: `verb_pass.md` beside
  `verb-pass-plan.md`, `alligator.md` beside `alligator_gemini_prompt.md`.
- **Not prose, inside `prompts/`:** `bayou-jazz-alligator.png`, `alligator_gemini_prompt.txt`,
  `etymology-affixes.json`, and `etymology-verbs.json`. The structure doc says the affixes file is
  live data that the etymology writers read, and that `etymology-tail-plan.md` holds a live wave
  ledger.
- **`docs/`: 39 files.** Its only subdirectory, `screenshots/`, is gitignored, as are three
  WWDC transcript files whose names are kebab-case. Rename those three on disk too and check
  their `.gitignore` lines. The tool does both when they are in the map.
- **Names with a version in them:** `release-notes-2.0.txt` through `2.3.txt`. Keep the dots:
  `release_notes_2.0.txt`.
- **Read by path, so a rename must reach the reader:**
  - **Six agent definitions in `.claude/agents/`** tell their agents to read
    `prompts/etymology-tail-plan.md` or `prompts/verb-pass-plan.md`. An agent that cannot find
    its brief does not fail loudly. It improvises. Verify these six by hand after the rename.
  - `scripts/take_screenshots.sh`, `scripts/verify_store_media.sh`, and
    `scripts/prep_screenshot_sim.sh` name `docs/screenshot-plan.md`,
    `docs/screenshot-playbook.md`, `docs/app-store-preview-videos.md`, and `docs/video_script.md`.
  - `scripts/check_docs.py` holds `INDEX = "docs/project-structure.md"` and names three more
    files in its docstring and comments.
  - `README.md` names `docs/project-structure.md` and `docs/frequencies.txt`.
- **The Xcode project references nothing** in `docs/` or `prompts/`.
- **`privacyPolicy4.md` at the repo root** is outside the three folders and is probably what the
  App Store listing points at. Leave it, and mention it to Josh.
- **`.githooks/pre-commit` runs SwiftLint with `--strict`** on staged Swift files. If a rename
  lengthens a comment in a Swift file past the line limit, Josh's commit is blocked. See step 8.

## The Work, in Order

### 0. Preflight

`git status` must be clean, so that the diff you hand Josh is only this work. Run
`python3 scripts/check_docs.py` and confirm it passes before you change anything.

### 1. Search for outside links before choosing any name

Run these **bare**: no `timeout`, which is not installed on this Mac, and no `2>/dev/null`.

```bash
grep -rnoE "github\.com/vermont42/Conjuguer/(blob|tree|raw)/[A-Za-z0-9_./-]+" ~/Desktop/workspace/Blog/_posts | sort -u
grep -rnoIE "(github\.com|raw\.githubusercontent\.com)/vermont42/Conjuguer/[A-Za-z0-9_./-]+" . --exclude-dir=.git --exclude-dir=corpus --exclude-dir=build | sort -u
```

The first must print the links listed at the top of this plan, along with several to Swift
files. **If it prints nothing, the search is broken, not clean.** That is the mistake
Konjugieren's session made: a wrapped search failed silently, its silence was reported as "no
links", and the push broke two links in a published post. Exclude `corpus/` from any search of
this repo. It is 1.5 GB, and a search that walks it runs for minutes.

Also ask yourself whether the shipped app or App Store Connect points at a file by URL. The
privacy policy is the likely case. `docs/privacy_policy2.txt` is already snake_case and should
not need to move.

### 2. Classify every file in `prompts/` and `docs/` by reading it

**Do not classify by filename.** Konjugieren's session guessed its `docs/` candidates from names
and was wrong in both directions: two files with "plan" in the name were not plans, and
`code-review.md` turned out to be five lines of Josh asking for a review.

Read the opening of every Markdown and text file. Authorship is usually obvious:

- **Josh's prompts** open in the first person with no heading, address Claude as "you", and run
  a few paragraphs. Typos are a fair sign.
- **Claude's plans** open with a title, name an audience ("a fresh session", "an orchestrator
  session"), carry a status line and a written date, and often run to hundreds of lines.
- **Claude's documents** report: findings, measurements, verdicts, recommendations.

The first commit that added a file helps when the text does not settle it:

```bash
git log --diff-filter=A --follow --format='%ad %s' --date=short -- <path> | tail -1
```

Build a table of every file: where it is, where it goes, its new name, and one line of reason.

**Files that are not prose.** Josh's prompt said: "Some files, for example Python scripts, are not
documents, plans, or prompts. Such files are outside the scope of this project, but please ask if
you see another type of file that should move." So do not sort the JSON and image files by
authorship. A data file or image that one plan or prompt reads travels with that file, so the
two stay in one folder. They still take snake_case names.

**Ask Josh once.** Gather the files you could not place, the non-prose questions, and the blog
question from the top of this plan into one batch, and ask before moving anything. Do not ask
about the obvious ones. He answers quickly and has been extending scope when asked.

### 3. Build the move map

Write the map as JSON, old path to new path, and save it as `plans/location_cleanup_moves.json`.
It is the record of what was renamed, and the Conjugar session may read it (step 7).

Naming rules:

- snake_case, lowercase: hyphens become underscores, and a camelCase or capitalized name is
  split and lowered (`Localization.md` became `localization.md` in Konjugieren, so `verbHistory.md`
  becomes `verb_history.md` and `Fable_max.md` becomes `fable_max.md`).
- Keep dots that belong to a version or a compound extension.
- Drop "prompt", "prompts", "plan", and "plans" as words in a name, in all three folders. If
  what remains no longer identifies the file among its neighbors, name it for its subject.
- Two files may share a name across folders. `prompts/verb_pass.md` and `plans/verb_pass.md` are
  fine and are what DRY asks for: one subject, and the folder says which is which. Two files may
  not share a name within a folder. The tool refuses that. Watch `alligator_gemini_prompt.md`
  and `alligator_gemini_prompt.txt`, which share a stem already.

### 4. Dry run, read the report, apply

```bash
python3 ../Konjugieren/scripts/rename_files.py plans/location_cleanup_moves.json --exclude plans/location_cleanup.md --verbose
python3 ../Konjugieren/scripts/rename_files.py plans/location_cleanup_moves.json --exclude plans/location_cleanup.md --apply
```

`--exclude` keeps the tool out of this plan, which names the old paths on purpose. It matters
only if the plan has been committed, since the tool edits tracked files only.

The tool repairs Markdown link targets, written-out paths, and bare filenames in every tracked
text file, `.claude/agents/` included, and gives `docs/blog_notes.md` link targets only. Read two
lists in its report before applying:

- **Skipped.** Paths whose prefix names a different file. Each is either correct to skip, such
  as a sibling repo's file, or a reference you must fix by hand. A GitHub URL in this list is an
  inbound link you missed in step 1.
- **Needs a human.** Relative mentions of a file that changes folder, and bare names that two
  renamed files share.

### 5. Fix what the tool cannot see

- **Names built at runtime.** Search the scripts and the agent definitions for the stem of each
  renamed data file. A format string such as `"%s-round%d.json"` matches no filename, and
  Konjugieren had one.
- **Generated and untracked files.** List what is on disk, not only what is tracked, and list
  inside ignored directories, which `git status --ignored` shows as one line.
- **Another repo's file with the same path.** "Konjugieren's `docs/screenshot-playbook.md`" has a
  prefix that looks like this repo's own, and all three apps have files of that name. Review the
  changed lines that mention a sibling:

  ```bash
  git diff HEAD -U0 | grep -E '^\+[^+]' | grep -iE 'Konjugieren|Conjugar'
  ```
- **`paths:` globs** in `.claude/rules/*.md`, if you renamed anything they name.

### 6. Update the documents that describe the layout

- **`CLAUDE.md`:**
  - Add the two sections from Konjugieren's `CLAUDE.md`, **Prompts, Plans, and Documents** and
    **File Naming**, adapted to this repo. Change the repo name in the search recipe, and point
    at `../Konjugieren/scripts/rename_files.py`.
  - The paragraph on `check_docs.py` says counts are not checked because "`docs/blog_notes.md`
    and `prompts/` describe the tree as it was". After the sorting, `plans/` holds most of that
    history. Say so.
- **`scripts/check_docs.py`:** `INDEX` becomes `docs/project_structure.md`, which the tool does.
  The docstring's **Scope** paragraph makes the same claim about `prompts/` as `CLAUDE.md`, and
  needs the same correction by hand. No code in the checker treats `prompts/` specially, so
  nothing else changes.
- **`docs/project_structure.md`** (its new name). Its `prompts/` header calls that folder an
  archive of session prompts and names two live data files by their old names. Rewrite the
  header, add a `plans/` tree, and give **every** file in `prompts/`, `plans/`, and `docs/` a
  one-line description by subject. Josh finds files by subject, so these lines are what the
  sorting is for. Compare each tree with `ls` when you finish. The checker's third check reads
  every `.json` name this document mentions and fails if the file is missing, so a JSON file you
  renamed must be renamed here as well. The tool does it. The checker confirms it.

### 7. Cross-repo references

**Edit only this repo.** The Conjugar session may be running at the same time.

- **This repo's references to Konjugieren, which was renamed today.** Fix these now:
  - `docs/verb-frequency-sources.md:75`: `Konjugieren/docs/dwds-permission-email.md` is now
    `dwds_permission_email.md`.
  - `prompts/glaff-frequency-ranking.md:43`: `Konjugieren/docs/verb-sources.md` is now
    `verb_sources.md`.
  - For any other, the full list of Konjugieren's renames is
    `git -C ../Konjugieren show -M --name-status 42ef201 | grep '^R'`.
- **This repo's references to Conjugar.** `prompts/verify-verb-history.md` names two files under
  `Conjugar.mig/docs/`, an old folder name for Conjugar. If
  `../Conjugar/plans/location_cleanup_moves.json` exists, update them from it. If it does not,
  list them in your report.
- **Other repos' references to this repo.** Do not edit them. Report them with their new paths.
  As of today, all are in Conjugar: `docs/conjugar-ui-issues.md` (twice, to
  `docs/conjuguer-ui-issues.md`), `docs/example-corpus-sources.md` and `prompts/example_uses.md`
  (to `docs/literature-example-corpus.md`), `docs/history_corrections.md` (to
  `prompts/verify-verb-history.md`), `docs/verb-frequency-sources.md` (to the file of the same
  name here), and `docs/video_script.md` (to `docs/app-store-preview-videos.md` and
  `docs/video_script.md`). `Conjugar/prompts/etym-starter.md` names
  `Conjuguer/prompts/etymology-pipline.md`, which is misspelled and was already dangling.

### 8. Verify

- `python3 scripts/check_docs.py` reports 0 problems.
- The six agent definitions in `.claude/agents/` name paths that exist. Read each one.
- Every changed `.py` passes `python3 -m py_compile`, and every changed `.sh` passes `bash -n`.
- Every path that a changed script names exists on disk.
- Every tracked JSON file you renamed or edited still loads.
- No kebab-case name is left in the three folders: `ls prompts plans docs | grep -- -`.
- Old names are gone outside the journal. Search for a sample of them.
- Swift files should change in comments only. Confirm it, and run
  `swiftlint lint --strict` on each changed Swift file, since the pre-commit hook will. If any
  line other than a comment changed, build and run the tests as `CLAUDE.md` describes.

### 9. Journal, then report

Append an entry to `docs/blog_notes.md`: narrative, dated, with no em dash joining two clauses.
Say what the classification found, what Josh ruled, and what differed from this plan.

Then tell Josh:

- the table of moves, with the files you placed on judgment marked;
- what happened to the six blog-linked files, and whether the post needs republishing;
- anything the Skipped list held that you could not resolve;
- the cross-repo references from step 7 that someone must fix elsewhere;
- **kebab-case names outside the three folders.** As of today: `frequency/verb-counts.json`,
  `frequency/editorial-counts.json`, `frequency/GLAFF-README.txt`, and the three files in
  `.claude/rules/`. `check_docs.py` globs `frequency/*.json`, and the app may read those files.
  In Konjugieren Josh extended the rename to `verbdata/` only when asked, so ask. Do not rename
  these unasked.

**Do not commit or push until Josh says to.** `CLAUDE.md` allows committing straight to `main`,
but this is a large diff that he will want to read, and he runs his own `/commit-and-push`.

## Mistakes Made in Konjugieren, So That You Make New Ones

1. **Classified by filename.** Wrong in both directions. Read the files.
2. **Reported "a few" files in a data folder** after a count that had filtered out JSON. The
   folder was mostly JSON, and the true number was 63. Count without filters before you describe
   a scope to Josh.
3. **Trusted an empty search.** Covered in step 1. A check must be seen to find something before
   its silence means anything.
4. **Listed ignored files and saw only a directory.** `git status --ignored` collapses an ignored
   directory to one line. Fourteen working files were inside it.
5. **Wrote an example link in the journal.** A sample Markdown link in backticks still parsed as
   a link in Konjugieren's checker. This repo's checker strips code spans first, which is kinder,
   but describe a link in words anyway.
