# Screenshot Playbook

Captures App Store screenshots for Conjuguer via `scripts/take_screenshots.sh`. The driver carries the calibration values, per-view navigation, and the workarounds inline as comments; this playbook is the prose-and-procedure wrapper around it.

## Running it from a fresh Claude session

One thing you must do yourself first — it needs a click in System Settings and a session can't do it: grant **Accessibility permission to `/usr/bin/osascript`** (System Settings → Privacy & Security → Accessibility → add it). Without it the soft-keyboard Cmd+K toggle fails, so the `quiz_mid` shot comes out keyboard-less (the driver treats this as non-fatal and the run still completes). Then paste this to the session:

```
Create the 36 App Store screenshots for this release. Read docs/screenshot-playbook.md
and docs/screenshot-plan.md first, then drive scripts/take_screenshots.sh to produce all
36 (9 views × en/fr × iPhone 17 Pro Max + iPad Pro 13-inch (M4)).

Before running:
- Set TipDisplay.tipsEnabled = false in Conjuguer/Models/ConjuguerTips.swift, and
  restore it to true when all screenshots are captured.
- Confirm both simulators exist (see "Simulator Setup") and that jq + axe are on PATH.

After running:
- Visually review every captured PNG (Read each one). Re-run any bad cell with the
  --device/--lang/--view filters. Pay special attention to the two iPad Info scroll
  targets (the 200/400 values in scroll_until_top) — they were calibrated on iPhone only.
- Assemble docs/screenshots/latest/ and the numbered version_<N>/ upload bundle per the
  playbook (this is the next release, so use the next version_N).
```

Gotchas the session should keep in mind (also covered below): this machine may have **duplicate simulators** with those two names — `udid_for()` takes the first match by list order, so if a run targets the wrong device, prune dupes (`xcrun simctl delete unavailable`). The full sweep is ~30–45 min and the iPad's first boot can block ~70s — that's `bootstatus -b` working, not a hang.

## Scope

App Store screenshots only — 9 views × 2 languages × 2 devices = 36 PNGs. Not a general-purpose iOS screenshot framework. The capture spec lives in [`docs/screenshot-plan.md`](screenshot-plan.md).

## Prerequisites

- macOS with Xcode 26+ and the iOS 26.3+ simulator runtime installed.
- `axe` CLI on PATH (see `ios-build-verify` SKILL.md for installation).
- `ios-build-verify` skill installed; resolve its scripts directory once per session:
  ```bash
  export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
  ```
- macOS Accessibility permission granted to `osascript`. System Settings → Privacy & Security → Accessibility → add `/usr/bin/osascript`. The driver depends on this for the soft-keyboard Cmd+K toggle (workaround #6).
- Two simulators named `iPhone 17 Pro Max` and `iPad Pro 13-inch (M4)` (see "Simulator Setup"). The driver resolves their UDIDs by name at run time — no hardcoding.
- **Disable TipKit tips first (then restore).** Set `TipDisplay.tipsEnabled = false` in
  [`Conjuguer/Models/ConjuguerTips.swift`](../Conjuguer/Models/ConjuguerTips.swift) **before** running the driver, and restore it to `true` afterward. This is a compile-time master switch: when `false`, `ConjuguerApp` skips `Tips.configure()`, so every `TipView` (notably "Try the Quiz" on VerbBrowseView and "Explore Models" on ModelBrowseView) and `.popoverTip(_:)` stays hidden — no per-call-site changes needed. The driver builds once at start, so the flag must be flipped before you launch it. Leaving tips on means a tip card can land in the VerbBrowseView/ModelBrowseView screenshots.
- **Clean the iPad status bar (App Store polish).** The driver does *not* manage the status bar, so iPad shots ship with whatever the simulator's clock and **system language** produce — and the iPad status bar shows a *date* (e.g. a German `Freitag 26. Juni` if the sim's system language is German), which looks unprofessional on an EN/FR listing. iPhone shots are unaffected (the notch shows only the time). Set a clean status bar before the iPad sweep — see **"Clean Status Bar"** below. (Not needed for iPhone.)

## Quick Start

```bash
scripts/take_screenshots.sh  # all 36 (~30-45 min)
scripts/take_screenshots.sh --device "iPhone 17 Pro Max"  # 18 (one device)
scripts/take_screenshots.sh --lang fr  # 18 (French only)
scripts/take_screenshots.sh --view model_browse  # 4 (one view, both devices/langs)
scripts/take_screenshots.sh --device "iPhone 17 Pro Max" --lang fr --view quiz_results  # exactly 1 cell
```

The `--device` value is the device-class label (with parens). UDIDs are resolved by name in `udid_for()`; the driver does not use `_resolve_udid.sh`.

`VIEWS` are: `verb_browse verb_view model_browse model_view quiz_mid info_browse info_view quiz_results settings`.

## Outputs

The driver writes timestamped PNGs to `docs/screenshots/<timestamp>-<device>-<lang>-<view>.png` (gitignored). One file per cell per run; iterating with `--view` accumulates timestamped versions.

For App Store Connect upload, copy the latest version of each cell to `docs/screenshots/latest/`:

```bash
mkdir -p docs/screenshots/latest && \
for view in verb_browse verb_view model_browse model_view quiz_mid \
            info_browse info_view quiz_results settings; do
  for device in "iPhone-17-Pro-Max" "iPad-Pro-13-inch-(M4)"; do
    for lang in en fr; do
      latest=$(ls -t docs/screenshots/*"${device}-${lang}-${view}.png" 2>/dev/null | head -1)
      [[ -n "$latest" ]] && cp "$latest" "docs/screenshots/latest/$(basename "$latest")"
    done
  done
done
```

`ls -t` orders by modification time; the timestamp embedded in the filename matches mtime to the second, so the two ordering schemes agree.

### Per-Release Upload Bundles

App Store Connect's upload dialog takes one (device × locale) at a time and orders screenshots alphabetically by filename. The descriptive `latest/` names — useful as an archive — get in the way at upload time. For each release, project `latest/` into a numbered bundle:

```
docs/screenshots/version_<N>/
├── iPhone_English/{1..9}.png
├── iPhone_French/{1..9}.png
├── iPad_English/{1..9}.png
└── iPad_French/{1..9}.png
```

`<N>` increments per release (`version_3`, `version_4`, …). The row number is the `#` column in the "Per-View Navigation Recipes" table below (1 = VerbBrowseView … 9 = SettingsView). To regenerate after a re-shoot:

```bash
cd docs/screenshots && \
mkdir -p version_<N>/iPhone_English version_<N>/iPhone_French \
         version_<N>/iPad_English  version_<N>/iPad_French && \
for src in latest/*.png; do
  rest="${src##*/}"; base="${rest#????????-??????-}"; base="${base%.png}"
  [[ "$base" =~ ^(iPhone-17-Pro-Max|iPad-Pro-13-inch-\(M4\))-(en|fr)-(.+)$ ]] || continue
  case "${BASH_REMATCH[3]}" in
    verb_browse) n=1 ;; verb_view) n=2 ;; model_browse) n=3 ;; model_view) n=4 ;;
    quiz_mid) n=5 ;; info_browse) n=6 ;; info_view) n=7 ;; quiz_results) n=8 ;; settings) n=9 ;;
  esac
  case "${BASH_REMATCH[1]}" in iPhone-17-Pro-Max) d=iPhone ;; *) d=iPad ;; esac
  case "${BASH_REMATCH[2]}" in en) l=English ;; fr) l=French ;; esac
  cp "$src" "version_<N>/${d}_${l}/${n}.png"
done
```

`latest/` stays untouched as the timestamped archive; `version_<N>/` is a regenerable projection — re-running the snippet after a re-shoot produces the same 36 files. If the playbook table ever reorders, edit only the inner `case` block.

## Simulator Setup

The driver targets two simulators by name and resolves their UDIDs at run time (`udid_for()` matches the exact device name from `xcrun simctl list devices available`). You only need the two devices to exist with the default names. To (re)create either after `simctl erase` or `simctl delete unavailable`:

```bash
RUNTIME=$(xcrun simctl list runtimes | grep -i 'iOS 26.3' | tail -1 | awk -F'[()]' '{print $2}')

xcrun simctl create "iPhone 17 Pro Max" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max \
  "$RUNTIME"

xcrun simctl create "iPad Pro 13-inch (M4)" \
  com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4 \
  "$RUNTIME"
```

**No sim renaming needed.** Konjugieren's driver hardcoded UDIDs and renamed the iPad to dodge `_resolve_udid.sh`'s regex-special-char bug (parens in `TARGET_SIM`). Conjuguer's driver bypasses `_resolve_udid.sh` entirely and matches the device name as a Python string literal, so `iPad Pro 13-inch (M4)` works unchanged.

## Clean Status Bar

The driver itself never touches the status bar, so by default every shot carries the
simulator's live clock, battery, and signal state — and on **iPad** the status bar also
shows a **date**, rendered in the simulator's **system language** (independent of the
app's `-AppleLanguages` override). A sim whose system language is German thus stamps
`Freitag 26. Juni` onto otherwise-English/French iPad screenshots. iPhone shots are
unaffected — the notch shows only the time, no date.

Fixing this is two independent pieces:

1. **`simctl status_bar override`** — pins the time/battery/signal to clean values. This is
   per-device and **cleared on every shutdown/reboot**, but it **persists across
   `uninstall`/`install` and app relaunches**, so set it once and leave the device booted
   for the whole sweep. (`take_screenshots.sh` only boots when the device is *not* already
   booted and never reboots, so the override survives a full run.)

   ```bash
   UDID=$(xcrun simctl list devices available | \
     awk -F '[()]' '/iPad Pro 13-inch \(M4\) \(/{print $4; exit}')   # the iOS-26 one
   xcrun simctl status_bar "$UDID" override \
     --time "9:41" \
     --dataNetwork wifi --wifiMode active --wifiBars 3 \
     --cellularMode notSupported \
     --batteryState charged --batteryLevel 100
   ```

   Caveats learned the hard way:
   - **`--time` only accepts a plain clock string** like `"9:41"`. `"9:41 AM"` and even a
     well-formed ISO string (`2026-06-26T09:41:00`) are rejected as *"Invalid, non-ISO
     date/time string"* on this runtime. Use `"9:41"`; the system renders the AM/PM and the
     *date* itself from the real clock + system language (step 2), not from `--time`.
   - **`--cellularMode notSupported`** hides the cellular signal — correct for a Wi-Fi iPad
     (forcing `--cellularBars` instead paints a bogus "Carrier" onto a Wi-Fi-only device).
   - Verify with `xcrun simctl status_bar "$UDID" list`; reset with `… status_bar "$UDID" clear`.

2. **System language → fixes the iPad date's language.** `status_bar override` has **no
   date flag**; the date label follows the device's *system* language. Set it (and reboot,
   which is also when you must **re-apply the override** since reboot clears it):

   ```bash
   lang=en   # or fr
   case "$lang" in en) loc=en_US ;; fr) loc=fr_FR ;; esac
   xcrun simctl spawn "$UDID" defaults write -g AppleLanguages -array "$lang"
   xcrun simctl spawn "$UDID" defaults write -g AppleLocale -string "$loc"
   xcrun simctl shutdown "$UDID"; xcrun simctl boot "$UDID"
   xcrun simctl bootstatus "$UDID" -b >/dev/null
   # re-apply the status_bar override here (cleared by the reboot)
   ```

   Because the system language must match each screenshot's language to localize the date
   (English date on EN shots, French on FR), capture the iPad **one language at a time**:
   set system language → reboot → re-apply override → shoot all 9 views of that language →
   repeat for the other language. This is orthogonal to the per-cell reliability loop below,
   which also runs the iPad a language at a time.

> **Why not bake this into the driver?** The override is trivial to script, but the
> per-language *reboot* (needed for the date) doesn't fit the driver's one-boot-per-device
> loop (it shoots both languages in a single boot). Keeping the status-bar setup as an
> operator step above avoids restructuring the driver around reboots. iPhone needs none of
> this.

## iPad reliability — duplicate sims, render budget, per-cell fallback

Three iPad-specific failure modes surfaced in practice (none affect iPhone):

- **Wrong duplicate simulator / old iPadOS.** `udid_for()` returns the *first* name match
  in `simctl list` order, which is grouped by runtime ascending — so if the machine has
  `iPad Pro 13-inch (M4)` instances on iOS 18.x *and* 26.x, it picks an **18.x** one and
  the install dies with *"Requires a Newer Version of iPadOS … Have 18.0; need 26.0"*. Fix
  without deleting the user's other sims by **renaming the stale-OS duplicates out of the
  way** (reversible) so only the iOS-26 device matches the exact name:
  ```bash
  xcrun simctl rename <UDID-of-iOS18-iPad> "iPad Pro 13-inch (M4) iOS18-PARKED"
  # …re-run sweep…  then restore:
  xcrun simctl rename <UDID> "iPad Pro 13-inch (M4)"
  ```
  Confirm the survivor with the `udid_for` Python snippet (workaround #13) before running.
- **Render budget.** The iPad cold-parses 6,320 verbs in a regular-size-class grid on every
  launch; render time is variable and intermittently exceeds the original 20 s budget, so
  `wait_budget_for "iPad Pro 13-inch (M4)"` is now **45 s**. A *single* `wait_for_render`
  timeout still aborts the whole sweep (`set -e`), so generous headroom matters.
- **Per-cell fallback.** The *first* launch after a fresh `install` has never hung; only
  2nd+ relaunches within one driver run intermittently exceed even 45 s. The robust path is
  therefore to invoke the driver **one cell at a time** (`--lang L --view V`) with a small
  retry loop — every cell becomes a first-launch-after-install, and a transient miss costs
  one cell, not the run:
  ```bash
  for view in verb_browse verb_view model_browse model_view quiz_mid \
              info_browse info_view quiz_results settings; do
    for attempt in 1 2 3; do
      scripts/take_screenshots.sh --device "iPad Pro 13-inch (M4)" --lang en --view "$view" && break
    done
  done
  ```
  Keep the device booted across the loop so the status-bar override (above) persists.

## Workarounds

Compact reference. The driver's inline comments hold the full WHY for each — cross-references point at the relevant function.

1. **Bash 3.2 compatibility** (`take_screenshots.sh::appearance_for, tab_coords_for, wait_budget_for`)
   *Symptom:* macOS system bash lacks associative arrays. *Fix:* case-statement lookup functions instead of `declare -A`.

2. **Onboarding suppression** (`take_screenshots.sh::seed_defaults`, `ONBOARDING_LABELS`)
   *Symptom:* `OnboardingView` shows on a fresh install (gated on `Settings.hasSeenOnboarding`), opaquing the first screenshot. *Fix:* pre-seed `hasSeenOnboarding=true` via `simctl spawn defaults write` right after install. As a belt-and-suspenders fallback, `wait_for_render` also taps a localized Skip label (`Skip`/`Passer`) if onboarding still appears (see workaround #11).

3. **SwiftUI identifier propagation** (`take_screenshots.sh::tap_id_first`)
   *Symptom:* SwiftUI propagates `accessibilityIdentifier` to children; `axe tap --id` refuses to disambiguate. *Fix:* parse the first matching `AXFrame` from `describe-ui` and tap its center via coords.

4. **simctl subcommand naming** (`take_screenshots.sh::type_via_pasteboard`)
   *Symptom:* `xcrun simctl pasteboard set` is not a real subcommand. *Fix:* `xcrun simctl pbcopy <UDID>`.

5. **Unicode typing via pasteboard** (`take_screenshots.sh::type_via_pasteboard`)
   *Symptom:* `axe type` lacks HID-keycode mappings for French accents (é è à ç ô î û ë …). *Fix:* paste via `simctl pbcopy` + Cmd+V (`axe key-combo --modifiers 227 --key 25`). Conjugated quiz answers are full of accents, so every quiz answer routes through this.

6. **Soft keyboard suppression** (`take_screenshots.sh::ensure_soft_keyboard`)
   *Symptom:* Simulator forwards host hardware-keyboard events; the soft keyboard is suppressed by default. *Fix:* send Cmd+K via `osascript` (Simulator's "Toggle Software Keyboard"); idempotent — checks the AXTree for a "space" key first.

7. **StoreKit review-prompt suppression** (`take_screenshots.sh::seed_defaults`)
   *Symptom:* the StoreKit review modal (`ReviewPrompterReal`, used even in the simulator World config) opaques the AXTree mid-loop. It fires when `promptActionCount % 10 == 0` **and** ≥180 days since `lastReviewPromptDate`. *Fix:* pre-seed `lastReviewPromptDate` to now via `simctl spawn defaults write`, so the 180-day cooldown blocks every prompt this run. (Fallback: workaround #12.)

8. **Deep Info-list rows** (`take_screenshots.sh::scroll_until_top, nav_info_browse, nav_info_view`)
   *Symptom:* the Tenses section (and `info_row_indicatif_present` within it) sits below the About + Concepts sections, off-screen on launch — and a lazy list doesn't report off-screen rows' frames. A fixed-distance swipe is fragile across devices. *Fix:* `scroll_until_top` swipes in 200pt increments until the target row's frame top reaches a target y, then stops (robust to device + dynamic-type differences).

9. **`axe --id` typeMismatch on iPad** (`take_screenshots.sh::tap_id`)
   *Symptom:* `axe tap --id` / `--label` throw a Swift `typeMismatch` decoding error in some iPad screen states (e.g., QuizView pre-Start). *Fix:* route all `tap_id` calls through `tap_id_first` (describe-ui + coord-tap) — same path as workaround #3.

10. **Multi-sim window focus** (`take_screenshots.sh::ensure_soft_keyboard`)
    *Symptom:* with both sims booted, Cmd+K hits whichever Simulator window is frontmost. *Fix:* AXRaise the target sim's window by title-substring match before sending the keystroke.

11. **Localized onboarding labels** (`take_screenshots.sh::ONBOARDING_LABELS`)
    *Symptom:* the onboarding-Skip button label is localized (`Skip` / `Passer`). *Fix:* array of all known labels; the wait-for-render loop tries each (fallback to workaround #2's pre-seed).

12. **Lang-agnostic StoreKit dismiss** (`take_screenshots.sh::dismiss_review_prompt`)
    *Symptom:* if a review prompt slips past #7, its button labels are system-localized (`Not Now` / `Pas maintenant`), and the modal has both single-button and post-star-tap two-button states. *Fix:* vertical sweep of `describe-ui --point` at a known x-center, tap the bottommost `AXButton` found.

13. **Dynamic UDID resolution** (`take_screenshots.sh::udid_for`)
    *Symptom:* `_resolve_udid.sh`'s regex match breaks on the iPad's paren-bearing default name. *Fix:* resolve UDIDs by exact device name with a Python literal comparison, so no hardcoded UDIDs and no sim renaming.

14. **Status bar (time + iPad date language)** (operator step, not in the driver — see *Clean Status Bar*)
    *Symptom:* iPad shots carry the live clock and a system-language date (e.g. German `Freitag 26. Juni`). *Fix:* `simctl status_bar override --time "9:41" …` (persists across install, cleared on reboot) for the clock/battery/signal, plus a per-language **system-language change + reboot** to localize the iPad date. `--time` rejects `"9:41 AM"`/ISO strings — pass a bare `"9:41"`.

## Per-View Navigation Recipes

| # | View | Mode | Driver function | Notes |
|---|---|---|---|---|
| 1 | VerbBrowseView | dark | `nav_verb_browse` | Default landing; `wait_for_render verb_browse_sort`. Frequency sort is the default → être on top. |
| 2 | VerbView | light | `nav_verb_view` | `tap_id_first verb_row_avoir`. |
| 3 | ModelBrowseView | dark | `nav_model_browse` | `tap_tab models` → settle on `model_row_être`. Irregularity sort is the default → être model at/near top. |
| 4 | ModelView | light | `nav_model_view` | `tap_tab models` → `tap_id_first model_row_être`. |
| 5 | QuizView (mid) | dark | `nav_quiz_mid` | `tap_tab quiz` → `quiz_start_button` → `input_quiz_conjugation` → paste fixture answer 0 → `ensure_soft_keyboard`. Captured before submit (keyboard visible per spec). |
| 6 | InfoBrowseView | light | `nav_info_browse` | `tap_tab info` → settle on `info_row_dedication` → `scroll_until_top info_row_participe_passe` (Tenses header to top). |
| 7 | InfoView | dark | `nav_info_view` | `tap_tab info` → `scroll_until_top info_row_indicatif_present` → tap it. |
| 8 | QuizResultsView | light | `nav_quiz_results` | `tap_tab quiz` → `quiz_start_button` → 30× (paste + Return + sleep 0.3) → `dismiss_review_prompt` if needed → `verify_screen_loaded results_score`. |
| 9 | SettingsView | dark | `nav_settings` | `tap_tab settings`; Quiz Difficulty picker is first, so no scroll. |

Tab-bar coordinates live in `tab_coords_for()`. iPhone uses the bottom pill tab bar (y=899.3); iPad uses a top segmented tab bar (y=54). Tab order is `verbs models quiz info settings`.

### The quiz fixture

Screens 5 and 8 rely on a DEBUG-only deterministic quiz. When launched with `-CONJUGUER_QUIZ_FIXTURE screenshot`, `Quiz.buildQuiz()` builds a fixed 30-question plan via `generateScreenshotFixture()` and writes the correct answers to `Documents/screenshot_fixture_answers.json` via `exportFixtureAnswers()` (both `#if DEBUG`, in [`Conjuguer/Models/Quiz.swift`](../Conjuguer/Models/Quiz.swift)). The driver reads that JSON (`read_fixture_answers_path`) and types the answers. Each exported `answer` is the first of any slash-separated alternates, which `ConjugationResult.score` scores as a total match — so screen 8 shows a high score with all-green per-question rows.

The answer field auto-focuses after **Start** and re-focuses after each submission (`QuizView.submitAnswer()` / `start()`), so the 30-answer sweep is just paste + Return per question against `input_quiz_conjugation`.

## Recovery Guidance

### Don't Break These — Driver Anchor Dependencies

The driver depends on these app-side touchpoints. Renaming any one silently breaks the corresponding screen with no compile-time signal — the next sweep produces a wrong screenshot or `wait_for_render` times out.

| Touchpoint | Driver depends on | Source file |
|---|---|---|
| `verb_browse_sort` identifier | `wait_for_render` polls for it after every launch (render anchor) | `Conjuguer/Views/VerbBrowseView.swift` |
| `verb_row_<infinitif>` identifiers | `tap_id_first verb_row_avoir` for screen 2 | same file |
| `model_row_<exemplar>` identifiers | `model_row_être` settle (screen 3) + `tap_id_first model_row_être` (screen 4) | `Conjuguer/Views/ModelBrowseView.swift` |
| `info_row_<stableKey>` identifiers | `verify_screen_loaded info_row_dedication` (screens 6 & 7 settle); `info_row_participe_passe` (screen 6 scroll target); `info_row_indicatif_present` (screen 7) | `Conjuguer/Views/InfoBrowseView.swift` + `Info.stableKey` in `Conjuguer/Models/Info.swift` |
| `Info.stableKey` field | source of every `info_row_<stableKey>` (locale-independent; `heading` is localized) | `Conjuguer/Models/Info.swift` |
| `quiz_start_button` identifier | quiz nav for screens 5 and 8 | `Conjuguer/Views/QuizView.swift` |
| `input_quiz_conjugation` identifier | answer field for screens 5 and 8 | same file |
| `Quiz.generateScreenshotFixture()` + `exportFixtureAnswers()` | DEBUG-gated 30-pair fixture; JSON written to `Documents/screenshot_fixture_answers.json` when launched with `-CONJUGUER_QUIZ_FIXTURE screenshot` | `Conjuguer/Models/Quiz.swift` |
| `results_score` identifier | `verify_screen_loaded results_score` after the 30-answer loop | `Conjuguer/Views/QuizResultsView.swift` |

The `info_row_<stableKey>` keys are locale-independent ASCII (e.g. `indicatif_present`, `participe_passe`, `dedication`); `verb_row_<infinitif>` and `model_row_<exemplar>` carry French text (e.g. `verb_row_avoir`, `model_row_être`) — the driver passes them as UTF-8 and matches via `describe-ui` + `jq`, which handles non-ASCII fine.

### Sim Runtime Drift

If the iOS 26.3 simulator runtime is replaced by 26.4+, the AXTree shape may shift slightly — especially for system-controlled surfaces like the StoreKit review prompt. Recreate the sims on the new runtime, re-verify workarounds #7 and #12 still match, and re-run a single test cell:

```bash
scripts/take_screenshots.sh --device "iPad Pro 13-inch (M4)" --lang en --view quiz_results
```

### Identifier Renames in App Code

Use the touchpoint table above as the rename checklist. After any identifier change:

```bash
rg -n "<old_identifier>" Conjuguer/
rg -n "<old_identifier>" scripts/take_screenshots.sh
```

Update both sides; re-run a single test cell to verify.

### Locale Shifts and New Languages

If a third app language ships:

1. Append the localized "Skip" label to `ONBOARDING_LABELS` in the driver.
2. Append the language code to `LANGS=( en fr )` in the driver.
3. Add a corresponding `case` arm in `launch_with_lang()` for the locale string.
4. Re-run `--view quiz_results --lang <new-lang>` to verify `dismiss_review_prompt`'s sweep still finds the system buttons in the new language.

The vertical-sweep dismiss (workaround #12) is lang-agnostic by design, so step 4 should pass without further change.

### SwiftUI Version Bumps

A SwiftUI version that changes how `accessibilityIdentifier` propagates, or where `AXFrame` is reported, can break `tap_id_first` silently. After any major SwiftUI bump:

```bash
axe describe-ui --udid <UDID> | jq '[.. | objects | select(.AXUniqueId? == "verb_row_avoir")][0]'
```

If `AXFrame` is missing or the structure has changed, `tap_id_first` needs a corresponding update.

### Re-running Individual Cells

Visual review will surface bad cells. Re-run any single one via the `--device` / `--lang` / `--view` filter flags (Quick Start). Each filter is independent; combine to narrow further.

## Maintenance Triggers

- **New model or info topic.** If the change alters which 9 views ship as App Store screenshots, update [`docs/screenshot-plan.md`](screenshot-plan.md) first; the driver's `VIEWS` array follows. New info topics need a `stableKey` in `Info.swift` (the `info_row_<stableKey>` identifier comes from it).
- **New device size class.** Add the device-class label to `DEVICES`, calibrate `tab_coords_for()` (top vs. bottom tab bar — iPad's regular size class uses a top segmented bar at y=54; iPhone's is a bottom pill bar at y=899.3), and verify the scroll targets still apply. `udid_for()` resolves the new device by name automatically.
- **`axe` upstream fix for the iPad `--id` `typeMismatch` bug.** If a future `axe` release fixes the bug, `tap_id` can be simplified back to `axe tap --id` directly. The driver's `tap_id_first` is currently always-on; after upstream fix it can become iPad-only or be removed.

## Known Gotchas

- **Flip TipKit off before the run.** Tips are a compile-time master switch (`TipDisplay.tipsEnabled` in `Conjuguer/Models/ConjuguerTips.swift`). Set it to `false`, run the sweep, then restore `true`. If you forget, the "Try the Quiz" / "Explore Models" tip cards can appear in the VerbBrowseView / ModelBrowseView screenshots. (The driver builds once at start, so the flag must be set first.)
- **Default sorts drive screens 1 and 3.** Screen 1 relies on `Settings.verbSortDefault == .frequency` (être on top); screen 3 on `Settings.modelSortDefault == .irregularity` (être model at/near top). The driver does not change sorts — segmented pickers render with empty AXTree children on iOS 26 and aren't individually addressable by id. A fresh install starts at the defaults, so this holds; if either default changes, re-spec those screens.
- **The "TENSES" / "TEMPS" scroll is calibration-sensitive.** Screen 6 wants the Tenses section header at the top. `scroll_until_top info_row_participe_passe 170` brings the section's first row near the top so the header shows just above it — tune the target y (170) if the header is clipped or too low. Likewise screen 7's `scroll_until_top info_row_indicatif_present 400` parks that row in the safe middle band before tapping.
- **Apple Intelligence Tutor surfaces are availability-gated.** The Tutor row in InfoBrowseView (and the AI page in OnboardingView) render only when `languageModelService.isAvailable`. On a simulator without Apple Intelligence the Tutor row shows an "unavailable" cell instead. None of the 9 target screenshot views depend on the Tutor row, so this doesn't affect the sweep — but be aware if the spec ever adds a Tutor-adjacent screen.
- **Review-prompt cooldown is per-install.** `seed_defaults` pre-seeds `lastReviewPromptDate` for in-run prompts, but a manual screenshot capture of the StoreKit modal would still require uninstalling/reinstalling first.
- **iPad first-boot is ~70s on a fresh sim.** Data-migration plugins initialize on first boot; subsequent boots are ~22s. The driver's `WAIT_FOR_RENDER_BUDGET_S=20` accommodates the post-launch render poll, but the `xcrun simctl bootstatus -b` step itself can block for ~70s during that initial boot. Don't kill the sweep thinking it's hung — `bootstatus -b` is doing the right thing.
