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
| `verb_browse_sort` | Sort `Picker` in `VerbBrowseView` | Launch anchor (`FIRST_SCREEN_ID`). Three segments since browse Phase 10: Frequency, Alphabetical, My Verbs. |
| `input_quiz_conjugation` | Answer `TextField` in `QuizView` | Carries `.accessibilityValue(input)`, so `read_value`/`set_value`/`type_text --id` work with read-back. |
| `picker_settings_quizDifficulty` | Quiz-difficulty segmented `Picker` in `SettingsView` | 2 segments (Regular, Ridiculous). |
| `picker_settings_pronounGender` | Pronoun-gender segmented `Picker` in `SettingsView` | 3 segments (Feminine, Masculine, Both). |
| `verb_example` | Example card in `VerbView` (below etymology) | Wraps the FR sentence, EN translation, source attribution, and nested *Chanson de Roland* example. |
| `verb_browse_count` | "N VERBS" header above the verb collection | Hidden when the search yields nothing. |
| `verb_row_<infinitif>` | Row `Button` in `VerbBrowseView` (list and grid) | e.g. `verb_row_avoir`. |
| `model_row_<exemplar>` | Row `Button` in `ModelBrowseView` (list and grid) | e.g. `model_row_avoir`. |
| `french_letter_key_<letter>` | Accent key in `FrenchLetterKeyRow` (é è ê â î ô û ç) | Shown in place of the sort picker only while a search field is focused, e.g. `french_letter_key_ê`. `tap_id.sh` taps it and the field keeps focus. |
| `search_guess_intro` | "A guess at the verb you meant:" in `FailedVerbSearchView` | Present only when a failed verb search has a guess. |
| `search_guess_row` | The guess's row `Button` in `FailedVerbSearchView` | `tap_id.sh search_guess_row` opens the guessed verb. |
| `verb_request_link` | The "please email" line in `FailedVerbSearchView` | Its address is a `mailto:` link; tap the address by frame. The simulator has no Mail, so the tap copies the address and shows `address_copied_note`. |
| `address_copied_note` | The note under `verb_request_link` | Shows for four seconds after the address is copied. |
| `verb_related` | "Related Verbs" heading of the card at the bottom of `VerbView` | Scroll to the page's bottom first. |
| `related_<infinitif>` | A verb chip on the Related Verbs card | e.g. `related_tenir`. `tap_id.sh` taps it; the verb pushes onto the current stack. |
| `related_all_built_on` | The "All N" chip of the card's "Built on …" row | Pushes `RelatedVerbListView`. |
| `related_all_model` | The "All N" chip of the card's "Same model" row | Pushes the model page in frequency order. |
| `related_list_sort` | Frequency/Alphabetical `Picker` in `RelatedVerbListView` | 2 segments. |
| `related_list_<infinitif>` | Row `Button` in `RelatedVerbListView` | e.g. `related_list_remettre`. |
| `verb_share_button` | Share button in `VerbView`'s navigation bar | Opens the share sheet. Tap the sheet's Copy and read the text with `xcrun simctl pbpaste <udid>`. On the iPad it is a popover over the button. |
| `verb_star_button` | Star button in `VerbView`'s navigation bar (Phase 10) | AXe cannot see navigation-bar buttons on iOS 26; tap it by position, between Done (in a sheet) and Share, and confirm by screenshot (a filled star). |
| `verb_test_button` | Test Me (clipboard) button in `VerbView`'s navigation bar (Phase 11) | First in the bar, before the star; absent on the six verbs with only an infinitif. Invisible to AXe like the star: tap by position (≈ `250,100` in a sheet on the iPhone 17, ≈ `691,54` pushed on the iPad Pro 11) and confirm by the sheet's "1 / 3". The sheet's Quit is found by `tap_label.sh Quit`; its results' Done at ≈ `352,110` on the iPhone. |
| `quiz_start_button` | Start `Button` in the Quiz tab's briefing card | Starts the scope chosen in `quiz_scope_picker`. |
| `quiz_scope_picker` | All Verbs / My Verbs segmented `Picker` in the Quiz tab's briefing card (Phase 11) | 2 segments; tap by frame. Not stored across launches. |
| `quiz_my_verbs_note` | The line under `quiz_scope_picker` with My Verbs chosen | "Questions about N verbs in My Verbs", or how to add some; `quiz_start_button` is then disabled (`enabled: false` in `describe_ui`). |
| `recent_verbs_heading` | "Recent" heading over the recents in the empty focused search field | Present only when something has been opened. |
| `my_verbs_list` | The My Verbs `List` (third segment of `verb_browse_sort`) | Tap the picker's third segment by frame (`x + width*5/6`). Rows keep `verb_row_<infinitif>`. Swipe a row left with `axe swipe --duration 0.4` at its `describe_ui` frame to show Delete. |
| `my_verbs_starred_heading`, `my_verbs_recent_heading` | Section headings in My Verbs | |
| `my_verbs_clear_recent` | Clear button in My Verbs' Recent heading | Forgets every open, keeps the stars. |
| `my_verbs_empty` | My Verbs' empty state | |
| `model_verb_order` | Alphabetical/Frequency `Picker` above a model page's verbs | 2 segments; the verbs stay one `Text` of links, so tap a verb at its coordinates. |

An identifier on a container that is not itself one element (a card) is inherited by every element
inside it and overrides theirs, so put a card's identifier on its heading (as `verb_related` is).
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

**iPad (since browse Phase 2):** both search fields are fixed bars under the title, and the
hardware-keyboard path works through AXe: Command-F is `axe key-combo --modifiers 227 --key 9`,
↓ and ↑ are `axe key 81` and `axe key 82`, Return is `axe key 40`. Escape (`axe key 41`) cancels the
search and clears its text. Key presses sent to Simulator.app through computer use do not reach the
device (Konjugieren). `tap_label.sh` did not find the iPad's top tab buttons on 2026-11-22; tap them
by coordinate (Models ≈ `370,54`, Quiz ≈ `448,54` on the Conjuguer iPad Pro 11).

**A long press** (a conjugation's Copy menu, since browse Phase 8) is a held touch:
`axe touch -x <x> -y <y> --down --up --delay 1.2 --udid <udid>` at the cell's `describe_ui` frame
(the cell's label is the spoken line, e.g. `je vais`). Then tap Copy by coordinate and read
`simctl pbpaste`. A simulated rating prompt may cover a page at launch; tap Not Now first.

**Outside the app (since browse Phase 9).** Links: `xcrun simctl openurl <udid> "conjuguer://search?q=suis"`
(or `verb/aller?match=vais`); terminate the app first to try a cold launch, and allow about 15 seconds
for the Debug build to load. Spotlight: `axe button home`, tap the Home Screen's Search pill (≈
`201,718` on the iPhone 17), `axe type` the word, then tap the result at its `describe_ui` frame (the
row's label is "aller, va · est allé · ira, go"). The quick action: the icon sits in the App Library
(swipe left past the last page); hold it with `axe touch -x 70 -y 214 --down --up --delay 1.2`, then
tap Find a Verb (≈ `133,285`). Look Up a Verb: `xcrun simctl launch <udid> com.apple.shortcuts`, tap
its tile under Conjuguer (≈ `60,340`), `axe type` the word, and tap the prompt's Done at ≈
`288,239`; a tap lower down dismisses the prompt and may run the Random Verb tile instead. These
coordinates are from 2026-11-22; re-measure with `describe_ui` if one misses.

## iOS 26 control caveats specific to this app

- **Accented input (é, è, à, ç, …):** `axe type` rejects non-ASCII. The skill's
  `set_value.sh` / `type_text.sh` (v0.3.0+) auto-route non-ASCII through a
  `simctl pbcopy` + Cmd+V pasteboard fallback, so French conjugations enter
  correctly. The quiz field is reachable by id, so prefer `type_text.sh --id
  input_quiz_conjugation "<answer>"` (gives read-back); the field also auto-focuses
  after **Start**, so a bare `axe type` into the focused field also works for ASCII.
- **Switches** (the verb page's "Show Compound Tenses" toggle) ignore an instant tap: `tap_xy.sh`,
  `axe tap --label`, and a swipe across the knob all left it unchanged on 2026-11-22. A held touch
  flips it: `axe touch -x <x> -y <y> --down --up --delay 0.15 --udid <udid>`, aimed at the switch
  at the row's right edge. Read the result from the element's `AXValue` (`1` on, `0` off).
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
