---
name: verify-in-simulator
description: Launch, screenshot, and drive Conjuguer in the iOS simulator to verify a change beyond unit tests. Covers the ios-build-verify verify scripts, this app's accessibility identifiers, iOS 26 control caveats (accented input, segmented pickers), and sweeping a quiz to completion.
---

# Verifying Conjuguer in the simulator

Resolve `IBV_SCRIPTS` first, as described under *Build and Test Commands* in `CLAUDE.md`.

The skill can launch the app and inspect/drive the UI so changes can be verified
beyond unit tests:

```bash
"$IBV_SCRIPTS/build_app.sh"                  # COMPILE first — launch_app.sh does NOT build (see warning below)
"$IBV_SCRIPTS/launch_app.sh"                 # boot + install the last-built .app + launch + wait-for-render
"$IBV_SCRIPTS/screenshot.sh <context-slug>"  # capture a PNG under docs/screenshots/
"$IBV_SCRIPTS/describe_ui.sh"                # dump the accessibility tree
"$IBV_SCRIPTS/tap_tab.sh <verbs|models|quiz|info|settings>"  # tap a main tab
```

> **⚠️ `launch_app.sh` does NOT compile.** It resolves `BUILT_PRODUCTS_DIR` via
> `xcodebuild -showBuildSettings` (which doesn't build), then installs whatever `.app`
> already exists there and launches it. **After editing source, you MUST run
> `build_app.sh` (or `run_tests.sh`) first** — otherwise `launch_app.sh` reinstalls the
> *previous* binary and your screenshots show pre-edit UI. (`launch_app.sh` does terminate
> the running process before install, so a stale *process* isn't the issue — a stale
> *build* is.) A symptom: edit → `launch_app.sh` → screenshot is byte-identical to the
> last one across multiple different edits. Always `build_app.sh && launch_app.sh`.

The launch anchor is `verb_browse_sort` (the sort `Picker` in `VerbBrowseView`). Add
more `.accessibilityIdentifier`/`.accessibilityValue` modifiers on a migration-by-use
basis as verification flows need them. See the skill's `SKILL.md` for the full verify
surface (named-intent ops, annotation checks, iOS 26 control caveats).

## Accessibility identifiers added so far

| Identifier | Element | Notes |
|---|---|---|
| `verb_browse_sort` | Sort `Picker` in `VerbBrowseView` | Launch anchor (`FIRST_SCREEN_ID`). |
| `input_quiz_conjugation` | Answer `TextField` in `QuizView` | Carries `.accessibilityValue(input)`, so `read_value`/`set_value`/`type_text --id` work with read-back. |
| `picker_settings_quizDifficulty` | Quiz-difficulty segmented `Picker` in `SettingsView` | 2 segments (Regular, Ridiculous). |
| `picker_settings_pronounGender` | Pronoun-gender segmented `Picker` in `SettingsView` | 3 segments (Feminine, Masculine, Both). |
| `verb_example` | Example card in `VerbView` (below etymology) | Wraps the FR sentence, EN translation, source attribution, and nested *Chanson de Roland* example. |
| `verb_browse_count` | "N VERBS" header above the verb collection | Hidden when the search yields nothing. |
| `verb_row_<infinitif>` | Row `Button` in `VerbBrowseView` (list and grid) | e.g. `verb_row_avoir`. |
| `model_row_<exemplar>` | Row `Button` in `ModelBrowseView` (list and grid) | e.g. `model_row_avoir`. |

Put a row's identifier on the tappable `Button`, **not** on the row content inside its
label: SwiftUI merges the two elements and concatenates their identifiers, yielding
`verb_row_avoir-verb_row_avoir`, which `tap_id.sh` can't match.

Info headings and tab buttons are not yet annotated — drive them by `AXLabel` /
`tap_tab.sh` for now. The verb-search field is unannotated too; tap it at its
`describe_ui` frame (the lone `AXTextField` on the Verbs tab, `{{16, 70}, {315, 44}}` →
centre ≈ `173,92` on iPhone 17) before typing. Because verb names carry accents, drive it
with `type_text.sh --xy 173,92 "<verb>"` (pasteboard route) rather than `axe type`, which
rejects non-ASCII. Re-measure with `describe_ui.sh` rather than trusting this number. The field
moves: on a fresh launch it sits lower (frame y ≈ 169, so tap ≈ `201,191`), and once a search is
active it rises to the top (tap ≈ `173,70`, seen 2026-10-01). A tap at the old spot silently
misses, and the text goes nowhere.

## iOS 26 control caveats specific to this app

- **Accented input (é, è, à, ç, …):** `axe type` rejects non-ASCII. The skill's
  `set_value.sh` / `type_text.sh` (v0.3.0+) auto-route non-ASCII through a
  `simctl pbcopy` + Cmd+V pasteboard fallback, so French conjugations enter
  correctly. The quiz field is reachable by id, so prefer `type_text.sh --id
  input_quiz_conjugation "<answer>"` (gives read-back); the field also auto-focuses
  after **Start**, so a bare `axe type` into the focused field also works for ASCII.
- **Segmented pickers** render with empty AXTree children on iOS 26, so segments
  aren't individually addressable by id. The parent identifier locates the control's
  frame; `verify_segment.sh` then verifies a segment's label + selected state, but
  **requires `--segments N` explicitly** (it can't infer the count through the
  children-empty bug): `--segments 2` for `picker_settings_quizDifficulty`,
  `--segments 3` for `picker_settings_pronounGender`. To *drive* a selection, compute
  the segment center from the id'd frame (`x + width*(i+0.5)/N`, `y + height/2`) and
  `tap_xy.sh`.

## Completing a quiz (regular difficulty)

A regular-difficulty quiz is 30 questions; `Quiz.process(_:)` advances on every
submission regardless of correctness, so completion = submit an answer to all 30.
After **Start**, the answer field auto-focuses; type into `input_quiz_conjugation`
and send Return (`axe key 40`) per question. The `Progress: N / 30` label tracks
position; the run ends with a `QuizResultsView` sheet (label `Results`).

The field **stays focused across submissions** (`submitAnswer()` re-sets focus), so a
fast sweep is: tap it once (`tap_id.sh input_quiz_conjugation`), then loop
`axe type "<answer>"` + `axe key 40` — batch many pairs into one Bash call and
`screenshot.sh` between batches to check
progress. **Caveat:** if focus is lost (e.g. after a `describe_ui`/screenshot detour),
`axe type`/`axe key 40` silently no-op and the quiz won't advance — re-tap the field by
id before resuming. To exercise all three result-icon colors, mix outcomes: a correct
conjugation → green, a correct skeleton with a dropped accent (e.g. `detends` for
`détends`) → blue partial, junk (`x`) → red.
