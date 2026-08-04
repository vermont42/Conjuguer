# Screenshot Playbook

> **⚠️ Updated 2026-07-18 — NOT RE-TESTED.** This playbook and
> `scripts/take_screenshots.sh` were refreshed from findings made while porting the same
> harness to the sibling app **Conjugar**, and from a large machine-wide simulator prune the
> same day. The changes are believed correct but **no cell of this sweep has been run since**,
> and no simulator was booted to confirm. Treat the first run as a verification run: shoot a
> single cell (`--lang fr --view quiz_results`) and inspect it before trusting a full sweep.
> Specifically unverified here: the iPad tab coordinates (see *Per-View Navigation Recipes*)
> and the keyboard probe points (workaround #6).

> **Keyboard mechanism replaced 2026-08-01 — ported from Conjugar, NOT yet run here.**
> `Cmd+K` ("Toggle Software Keyboard") stopped working on this toolchain (Xcode 26.3); the
> driver now attaches and detaches the **hardware** keyboard instead, and that turns the two
> quiz recipes into a small state machine because `axe`'s Cmd+V paste needs the opposite
> state from the one that shows the keyboard. See **workaround #20**, which is where the
> whole thing is explained. It was found and verified end to end in Conjugar's 2026-08-01
> sweep; here it is a careful port, checked against this app's `QuizView` (the answer field
> is `input_quiz_conjugation` and is focused on start and after each submit, so the removed
> tap really was redundant) and syntax-checked, but **no Conjuguer cell has been shot with
> it**. Shoot `--view quiz_mid` first and look at the PNG before trusting a full sweep.

Captures App Store screenshots for Conjuguer via `scripts/take_screenshots.sh`. The driver carries the calibration values, per-view navigation, and the workarounds inline as comments; this playbook is the prose-and-procedure wrapper around it.

## Running it from a fresh Claude session

One thing you must do yourself first — it needs a click in System Settings and a session can't do it: grant **Accessibility permission to `/usr/bin/osascript`** (System Settings → Privacy & Security → Accessibility → add it). Without it the driver cannot drive Simulator's menu bar, so it cannot detach the hardware keyboard and the `quiz_mid` shot comes out keyboard-less (the driver treats this as non-fatal and the run still completes; see workaround #20). Then paste this to the session:

```
Create the 36 App Store screenshots for this release. Read docs/screenshot-playbook.md
and docs/screenshot-plan.md first, then drive scripts/take_screenshots.sh to produce all
36 (9 views × en/fr × iPhone 17 Pro Max + iPad Pro 13-inch (M4)).

Before running:
- Set ALL THREE kill switches to false in Conjuguer/Utils/KillSwitches.swift —
  OnboardingDisplay.onboardingEnabled, TipDisplay.tipsEnabled, and
  TutorDisplay.tutorUnavailableRowEnabled — and restore all three to true when all
  screenshots are captured. See "Disable onboarding, tips, and the tutor row first" for the sed
  commands.
- Confirm both simulators exist (see "Simulator Setup") and that jq + axe are on PATH.

After running:
- Visually review every captured PNG (Read each one). Re-run any bad cell with the
  --device/--lang/--view filters. Pay special attention to the two iPad Info scroll
  targets (the 200/400 values in scroll_until_top) — they were calibrated on iPhone only.
- Assemble docs/screenshots/latest/ and the numbered version_<N>/ upload bundle per the
  playbook (this is the next release, so use the next version_N).
- Run scripts/verify_store_media.sh docs/screenshots/version_<N> and fix anything it
  reports BEFORE uploading. Visual review cannot see an alpha channel or a wrong
  display-size slot; this catches both.
- Confirm which display-size tile App Store Connect is actually offering — see
  "Confirm which slot App Store Connect is offering" in docs/screenshot-plan.md. A
  correct capture uploaded to the wrong tile is rejected.
```

Gotchas the session should keep in mind (also covered below): this machine may have **duplicate simulators** with those two names — `udid_for()` takes the first match by list order, so if a run targets the wrong device, prune dupes (`xcrun simctl delete unavailable`). The full sweep is ~30–45 min and the iPad's first boot can block ~70s — that's `bootstatus -b` working, not a hang.

## Scope

App Store screenshots only — 9 views × 2 languages × 2 devices = 36 PNGs. Not a general-purpose iOS screenshot framework. The capture spec lives in [`docs/screenshot-plan.md`](screenshot-plan.md).

## Prerequisites

- macOS with Xcode 26+ and the iOS 26.3+ simulator runtime installed.
- `axe` CLI on PATH (see `ios-build-verify` SKILL.md for installation).
- **Simulator.app running — the driver now handles this itself.** `ensure_simulator_app`
  launches it when absent, and `assert_framebuffer_live` refuses to run against a device that
  renders black (workaround #21). Both run in a preflight pass *before* `build_app.sh`, so a
  dead simulator costs seconds instead of a wasted build. You no longer have to remember to open
  Simulator first; leaving it open is still the best state to run in, since the keyboard steps
  need its menu bar.
- `ios-build-verify` skill installed; resolve its scripts directory once per session:
  ```bash
  export IBV_SCRIPTS=$(dirname "$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
  ```
  Search `marketplaces`, **not** `~/.claude` broadly — the plugin cache holds several
  versions at once and `find`'s order is unspecified (workaround #18).
- macOS Accessibility permission granted to `osascript`. System Settings → Privacy & Security → Accessibility → add `/usr/bin/osascript`. The driver depends on this to click **I/O ▸ Keyboard ▸ Connect Hardware Keyboard** for the `quiz_mid` keyboard (workaround #20; it was a Cmd+K keystroke through 2026-08-01, workaround #6). **Granted on this machine as of 2026-07-18.** A *missing* permission is not the only way the AXRaise step fails: a freshly-activated Simulator briefly reports no windows and the resulting `-1719 "Invalid index"` looks identical to a permission problem. The driver now waits 0.5 s after `activate` for that reason.
- **You can use the Mac during a sweep — with one caveat.** Taps, swipes, captures,
  launches and the pasteboard copy all go through `simctl`/`axe`, which talk to the
  **device**, so they do not care what is frontmost on the host. The exception is the
  keyboard step: Simulator's **menu bar** is the only way to attach/detach the hardware
  keyboard, and AppleScript can only click the menu of the frontmost app. That is a few
  seconds inside `quiz_mid` and `quiz_results` — 4 of the 36 cells, so roughly 8 short
  windows per full sweep. Steal focus during one and the driver logs
  `frontmost is 'X', not Simulator; not touching the menu` and that cell needs a re-shoot.
  It **refuses to act rather than clicking blind**, so the cost is a retry, never a stray
  click into your own app — the guard exists because a stray Cmd+K once launched Fitness on
  the host Mac. It also retries 3×, so a momentary steal usually recovers by itself.
  Observed for real in Conjugar's 2026-08-01 sweep (Safari, then VS Code).
- Two simulators named `iPhone 17 Pro Max` and `iPad Pro 13-inch (M4)` (see "Simulator Setup"). The driver resolves their UDIDs by name at run time — no hardcoding. **Confirm exactly one iOS-26 device matches each name before running:** `udid_for()` takes the first match in `simctl list` order, which is oldest-runtime-first, so a stale-runtime duplicate silently wins. Both names resolved cleanly on 2026-07-18 after the prune.
- **Disable onboarding, TipKit tips, *and* the tutor row first (then restore all three).** All three switches live in
  [`Conjuguer/Utils/KillSwitches.swift`](../Conjuguer/Utils/KillSwitches.swift) and must be `false` **before** you launch the driver (it builds once at start), then restored to `true`. `OnboardingDisplay.onboardingEnabled = false` stops the first-launch onboarding cover from auto-presenting over a shot on a freshly installed app. `TipDisplay.tipsEnabled = false` makes `ConjuguerApp` skip `Tips.configure()`, so every `TipView` (notably "Try the Quiz" on VerbBrowseView and "Explore Models" on ModelBrowseView) and `.popoverTip(_:)` stays hidden — no per-call-site changes needed. `TutorDisplay.tutorUnavailableRowEnabled = false` drops the tutor *unavailability* cell from InfoBrowseView. See **"Disable onboarding, tips, and the tutor row first"** below for the copy-paste `sed` commands and what each costs you if forgotten.
- **Clean the iPad status bar (App Store polish).** The driver does *not* manage the status bar, so iPad shots ship with whatever the simulator's clock and **system language** produce — and the iPad status bar shows a *date* (e.g. a German `Freitag 26. Juni` if the sim's system language is German), which looks unprofessional on an EN/FR listing. iPhone shots are unaffected (the notch shows only the time). Set a clean status bar before the iPad sweep — see **"Clean Status Bar"** below. (Not needed for iPhone.)

## Disable onboarding, tips, and the tutor row first (then restore)

Three compile-time switches, all in [`Conjuguer/Utils/KillSwitches.swift`](../Conjuguer/Utils/KillSwitches.swift), all ordinarily `true`. **Set all three to `false` before running the driver and restore all three afterward.** The driver builds once at start, so they must be flipped *before* you launch it.

| Switch | Effect when `false` | What you get if you forget |
|---|---|---|
| `OnboardingDisplay.onboardingEnabled` | `ConjuguerApp` never auto-presents the first-launch onboarding cover. `hasSeenOnboarding` is left untouched, and the Settings "Show Onboarding" button still works. | On a freshly installed app the welcome tour covers the first shot (and any shot taken before it is dismissed). Invisible on a simulator that has already run the app, which is what makes it easy to forget. |
| `TipDisplay.tipsEnabled` | `ConjuguerApp` skips `Tips.configure()`, so every `TipView` / `.popoverTip(_:)` stays hidden. | A tip card lands in one of the browse/quiz/settings shots. |
| `TutorDisplay.tutorUnavailableRowEnabled` | `InfoBrowseView` drops the tutor **unavailability cell** (both size-class branches). Only that cell — the working `NavigationLink` is untouched. | Both **iPad** `info_browse` shots carry "Apple Intelligence is still getting ready." (iPhone escapes it only via the scroll target — see the Tutor gotcha.) |

Use the `-e` form below. A single expression with `;`-separated substitutions split across
lines with a trailing backslash **fails on macOS** — BSD `sed` reports `newline can not be
used as a string delimiter` and changes nothing. Always eyeball the `grep` afterward: `sed`
exits 0 when a pattern matches nothing, so a renamed switch fails *silently* and the sweep
proceeds with onboarding, tips, and the tutor row still on.

```bash
# before the sweep
sed -i '' \
  -e 's/static let onboardingEnabled = true/static let onboardingEnabled = false/' \
  -e 's/static let tipsEnabled = true/static let tipsEnabled = false/' \
  -e 's/static let tutorUnavailableRowEnabled = true/static let tutorUnavailableRowEnabled = false/' \
  Conjuguer/Utils/KillSwitches.swift
grep -n 'onboardingEnabled = \|tipsEnabled = \|tutorUnavailableRowEnabled = ' Conjuguer/Utils/KillSwitches.swift  # all three must read false

# after the sweep — restore
sed -i '' \
  -e 's/static let onboardingEnabled = false/static let onboardingEnabled = true/' \
  -e 's/static let tipsEnabled = false/static let tipsEnabled = true/' \
  -e 's/static let tutorUnavailableRowEnabled = false/static let tutorUnavailableRowEnabled = true/' \
  Conjuguer/Utils/KillSwitches.swift

git diff --stat Conjuguer/Utils/KillSwitches.swift   # must be empty when you are done
```

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

> **Alpha channels — flattened at capture since 2026-07-25.** `axe screenshot` writes
> **RGBA**, and App Store Connect rejects any screenshot carrying an alpha channel
> ("Images can't include alpha channels or transparencies"). `take_screenshot()` now pipes
> each capture through `magick … -alpha remove -alpha off` immediately, so fresh sweeps are
> compliant. Two consequences worth knowing: **`magick` is now effectively required** (the
> driver warns and continues without it, producing rejectable PNGs), and **every bundle
> shot before that date is non-compliant** — all 40 files of `version_4` were RGBA and
> failed at upload. Flatten old bundles before reusing them.

For App Store Connect upload, copy the latest version of each cell to `docs/screenshots/latest/`:

```bash
rm -rf docs/screenshots/latest && mkdir -p docs/screenshots/latest && \
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

> **`latest/` is a per-release projection, not an accumulating archive** — hence the
> leading `rm -rf`. Without it, a re-shoot leaves the previous release's files sitting
> beside the new ones (the sibling app Konjugieren's went from 36 to 72 this way), and the
> numbered-bundle snippet below iterates `latest/*.png` mapping each file to a slot number.
> With two candidates per slot, which one wins depends on glob order. It happens to resolve
> correctly while timestamps sort in release order — not a property worth betting an upload
> on. The timestamped originals stay in `docs/screenshots/`, so clearing `latest/` loses
> nothing.

### Per-Release Upload Bundles

App Store Connect's upload dialog takes one (device × locale) at a time and orders screenshots alphabetically by filename. The descriptive `latest/` names — useful as an archive — get in the way at upload time. For each release, project `latest/` into a numbered bundle:

```
docs/screenshots/version_<N>/
├── iPhone_English/{1..10}.png
├── iPhone_French/{1..10}.png
├── iPad_English/{1..10}.png
└── iPad_French/{1..10}.png
```

> **`10.png` is not a driver view — carry it forward by hand.** Slots 1–9 come from `VIEWS`;
> slot 10 is a **hand-captured arcade-game shot** (the game behind *Game Instructions*), which
> the driver has never produced. Its status bar was set differently (`100%`, an unrelated date),
> so it is visibly not from a sweep. The projection snippet below only emits 1–9, so a bundle
> regenerated straight from `latest/` **silently loses slot 10** — the shipped bundle would go
> from 10 screenshots to 9 with no error. After projecting, copy it over explicitly:
>
> ```bash
> for f in iPhone_English iPhone_French iPad_English iPad_French; do
>   cp "version_<PREV>/$f/10.png" "version_<N>/$f/10.png"
> done
> ```
>
> (Discovered 2026-07-18 while cutting `version_4`: `version_3` had 10 files per folder where
> this section documented 9.) If the game shot is ever re-taken, do it by hand and mind that its
> status bar will not match the swept cells unless you set the override first.

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

`latest/` stays untouched as the timestamped archive; `version_<N>/` is a regenerable projection — re-running the snippet after a re-shoot produces the same 36 files (slots 1–9 × 4 folders; slot 10 is the hand-copied game shot above, for 40 in the shipped bundle). If the playbook table ever reorders, edit only the inner `case` block.

## Simulator Setup

The driver targets two simulators by name and resolves their UDIDs at run time (`udid_for()` matches the exact device name from `xcrun simctl list devices available`). You only need the two devices to exist with the default names.

> **Prune note (2026-07-18).** This machine was pruned hard that day: every iOS 18 device,
> every iOS 26.0 device, and all 305 devices on uninstalled runtimes were deleted (354 devices
> → 37). Both names still resolve, and the `iPad Pro 13-inch (M4)` that `udid_for()` now finds
> is a **freshly created iOS 26.3 device** — it is not the sim that was in place when this
> playbook was first written. That is the main reason this file is marked untested.
>
> Because this driver resolves **by name**, it is exposed to a hazard a UDID-hardcoding driver
> is not: `udid_for()` returns the *first* match in `simctl list` order, which is
> oldest-runtime-first. A leftover same-named sim on an older runtime therefore wins, and the
> install dies with *"Requires a Newer Version of iOS"*. Note `xcrun simctl delete unavailable`
> does **not** clear those — a device on an old-but-*installed* runtime is "available" and
> survives that command. Delete or rename such duplicates by UDID. Check with:
>
> ```bash
> xcrun simctl list devices available | grep -E 'iPhone 17 Pro Max|iPad Pro 13-inch \(M4\)'
> ```

To (re)create either after `simctl erase` or `simctl delete unavailable`:

```bash
RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-26-3

xcrun simctl create "iPhone 17 Pro Max" \
  com.apple.CoreSimulator.SimDeviceType.iPhone-17-Pro-Max \
  "$RUNTIME"

xcrun simctl create "iPad Pro 13-inch (M4)" \
  com.apple.CoreSimulator.SimDeviceType.iPad-Pro-13-inch-M4-8GB \
  "$RUNTIME"
```

**The device-type id changed.** Xcode 26 splits the M4 into 8 GB and 16 GB variants, so the
bare `…iPad-Pro-13-inch-M4` no longer resolves — use `…iPad-Pro-13-inch-M4-8GB`. The M4 type is
still offered on the 26.3 runtime even though a fresh Xcode install seeds only an M5, so
creating it by hand is the way to get the name this driver expects.

**No sim renaming needed.** Konjugieren's driver hardcoded UDIDs and renamed the iPad to dodge `_resolve_udid.sh`'s regex-special-char bug (parens in `TARGET_SIM`). Conjuguer's driver bypasses `_resolve_udid.sh` entirely and matches the device name as a Python string literal, so `iPad Pro 13-inch (M4)` works unchanged.

## Clean Status Bar

The driver itself never touches the status bar, so by default every shot carries the
simulator's live clock, battery, and signal state — and on **iPad** the status bar also
shows a **date**, rendered in the simulator's **system language** (independent of the
app's `-AppleLanguages` override). A sim whose system language is German thus stamps
`Freitag 26. Juni` onto otherwise-English/French iPad screenshots.

> **This is not iPad-only, despite the date being an iPad thing** (learned in Conjugar,
> 2026-07-26, and ported here). The *pinned clock itself is locale-formatted*: with the
> identical `--time "9:41"` override, an `en_US` device renders `9:41` and an `fr_FR`
> device renders `09:41`. So if you set the system language on only one device, or on
> neither, the iPhone and iPad clocks disagree *within the same language*. Run the
> language dance on **both** devices; only the *date* handling below is iPad-specific.

**Use [`scripts/prep_screenshot_sim.sh`](../scripts/prep_screenshot_sim.sh)** rather than
running the steps below by hand. It does them in the order that matters — set system
language → reboot → **re-apply** the override → verify — and prints the resulting override
state and `AppleLanguages` so you can see both landed instead of assuming it. It also
checks that the rebooted device actually has a Simulator *window* (workaround #19).

```bash
scripts/prep_screenshot_sim.sh "iPhone 17 Pro Max" en      # then shoot --lang en
scripts/prep_screenshot_sim.sh "iPad Pro 13-inch (M4)" fr  # then shoot --lang fr
```

Ported from Conjugar 2026-07-26, where the ordering trap below was hit twice in one day.
The manual steps are kept for reference, and because they document *why* the order is what
it is:

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

6. **Soft keyboard suppression** (`take_screenshots.sh::set_keyboard_state, keyboard_is_visible`)
   *Symptom:* Simulator forwards host hardware-keyboard events; the soft keyboard is suppressed by default. *Fix (through 2026-08-01):* send Cmd+K via `osascript` (Simulator's "Toggle Software Keyboard"). **Superseded — Cmd+K is inert on this toolchain; the driver now attaches/detaches the hardware keyboard. See workaround #20.** The probe-point half of this entry still stands, and `set_keyboard_state` still depends on it.

   **Corrected 2026-07-18 — the idempotency guard was broken.** It counted AXTree elements
   labelled `space`, which is *always zero*: the keyboard runs in its own process and does not
   appear in a full `axe describe-ui` dump at all. Since Cmd+K is a **toggle** whose state
   persists in Simulator across app launches, the guard never firing means the second
   `quiz_mid` cell of a sweep switches the keyboard back **off** — the four `quiz_mid` shots
   alternate keyboard/no-keyboard, silently, in a run that reports success. `describe-ui
   --point` *can* see the keyboard (same trick as workaround #12 on the StoreKit modal), so
   `keyboard_is_visible` now probes a mid-keyboard coordinate and treats a ≤2-character label
   (`g`) as keys-present. Not the space bar — it reports a blank label, indistinguishable from
   "nothing found". The caller — `set_keyboard_state` since 2026-08-01 — re-checks after
   toggling and warns if it did not land.

   The probe points (`220,760` iPhone / `516,1120` iPad) were validated on iOS 26.3 in
   Conjugar. They are a property of the **device**, not the app, and this driver's two sims are
   the same device types — but they have not been run against *this* app. Verify on first use.

7. **StoreKit review-prompt suppression** (`take_screenshots.sh::seed_defaults`)
   *Symptom:* the StoreKit review modal (`ReviewPrompterReal`, used even in the simulator World config) opaques the AXTree mid-loop. It fires when `promptActionCount % 10 == 0` **and** ≥180 days since `lastReviewPromptDate`. *Fix:* pre-seed `lastReviewPromptDate` to now via `simctl spawn defaults write`, so the 180-day cooldown blocks every prompt this run. (Fallback: workaround #12.)

8. **Deep Info-list rows** (`take_screenshots.sh::scroll_until_top, nav_info_browse, nav_info_view`)
   *Symptom:* the Tenses section (and `info_row_indicatif_present` within it) sits below the About + Concepts sections, off-screen on launch — and a lazy list doesn't report off-screen rows' frames. A fixed-distance swipe is fragile across devices. *Fix:* `scroll_until_top` swipes in 200pt increments until the target row's frame top reaches a target y, then stops (robust to device + dynamic-type differences).

9. **`axe --id` typeMismatch on iPad** (`take_screenshots.sh::tap_id`)
   *Symptom:* `axe tap --id` / `--label` throw a Swift `typeMismatch` decoding error in some iPad screen states (e.g., QuizView pre-Start). *Fix:* route all `tap_id` calls through `tap_id_first` (describe-ui + coord-tap) — same path as workaround #3.

10. **Multi-sim window focus** (`take_screenshots.sh::set_keyboard_state`)
    *Symptom:* with both sims booted, Cmd+K hits whichever Simulator window is frontmost. *Fix:* AXRaise the target sim's window by title-substring match before sending the keystroke.

    **Fixed 2026-07-26: the match is now the FULL device name (`$DEVICE`), not a family
    substring (`iPhone` / `iPad`).** Simulator titles its windows `<device name> – iOS
    <version>`, so the full name selects exactly one; the family substring did not, and it
    disambiguated only while exactly one simulator per family was booted. This is not
    hypothetical — it fired during this very sweep. A concurrent session in a sibling app had
    `iPhone 17` booted alongside `iPhone 17 Pro Max`, System Events enumerated the foreign
    window first, Cmd+K went to it, and **both** iPhone `quiz_mid` cells captured
    keyboard-less while the sweep reported success. Confirmed directly:

    ```bash
    osascript -e 'tell application "System Events" to tell process "Simulator" to get name of (first window whose title contains "iPhone")'            # -> iPhone 17 – iOS 26.3        (wrong)
    osascript -e 'tell application "System Events" to tell process "Simulator" to get name of (first window whose title contains "iPhone 17 Pro Max")' # -> iPhone 17 Pro Max – iOS 26.3 (right)
    ```

    **Also fixed 2026-07-26: the keystroke is now gated on Simulator actually being
    frontmost.** The window match above fixes *which Simulator window* catches Cmd+K; this
    guards the worse case, where Simulator is not the frontmost **application** at all and the
    keystroke goes to a different program entirely. A *bare* retry does not help, because
    `keystroke` *succeeds* — it lands wherever focus is, `osascript` returns 0, and workaround
    #6's post-toggle check reports only that the keyboard is missing, never that the keystroke
    went elsewhere. Observed in the Conjugar repo on 2026-07-26, where a stray Cmd+K launched
    the **Fitness** app on the host Mac while the run reported nothing wrong. The guard queries
    `name of first process whose frontmost is true` after the AXRaise and refuses to send the
    keystroke (logging the app that would have caught it) rather than firing blind.

    **Restructured 2026-07-26 into Konjugieren's 3× retry loop**, so all three apps now share
    one shape (they differ only in how each derives `window_match`: Conjuguer uses the whole
    `$DEVICE` string, Conjugar and Konjugieren a device-family substring). The frontmost check
    sits *inside* the loop, which upgrades it from a pure safety valve: a **transient** steal —
    Simulator still coming forward, another app momentarily frontmost — now recovers on attempt
    2 instead of costing the cell, which is what the original single-attempt guard did. A
    **persistent** steal burns all three attempts, sends **zero** keystrokes, and ends in
    `AppleScript Cmd+K failed 3x (accessibility permission …, or Simulator never came
    frontmost)`. The loop also absorbs the -1719 AXRaise race, which is a race rather than a
    steady state. Control flow verified against a stubbed harness in all three cases (clean /
    transient / persistent).

    Workaround #6's post-toggle check is still the thing that surfaces a failure here, and it
    logs `soft keyboard still not visible after Cmd+K`. If you see that line now, list the
    windows (`osascript -e 'tell application "System Events" to tell process "Simulator" to get
    name of every window'`) — a *second window for the same device name* would still be
    ambiguous, as would a device whose name is a prefix of another booted device's.

    Also note the AppleScript's `delay` after `activate` is now **0.5 s** (was 0.2 s): a
    freshly-activated Simulator briefly reports no windows, and the resulting `-1719 "Invalid
    index"` error reads exactly like a missing Accessibility permission. It is not one.

11. **Localized onboarding labels** (`take_screenshots.sh::ONBOARDING_LABELS`)
    *Symptom:* the onboarding-Skip button label is localized (`Skip` / `Passer`). *Fix:* array of all known labels; the wait-for-render loop tries each (fallback to workaround #2's pre-seed).

12. **Lang-agnostic StoreKit dismiss** (`take_screenshots.sh::dismiss_review_prompt`)
    *Symptom:* if a review prompt slips past #7, its button labels are system-localized (`Not Now` / `Pas maintenant`), and the modal has both single-button and post-star-tap two-button states. *Fix:* vertical sweep of `describe-ui --point` at a known x-center, tap the bottommost `AXButton` found.

13. **Dynamic UDID resolution** (`take_screenshots.sh::udid_for`)
    *Symptom:* `_resolve_udid.sh`'s regex match breaks on the iPad's paren-bearing default name. *Fix:* resolve UDIDs by exact device name with a Python literal comparison, so no hardcoded UDIDs and no sim renaming.

14. **Status bar (time + iPad date language)** (operator step, not in the driver — see *Clean Status Bar*)
    *Symptom:* iPad shots carry the live clock and a system-language date (e.g. German `Freitag 26. Juni`). *Fix:* `simctl status_bar override --time "9:41" …` (persists across install, cleared on reboot) for the clock/battery/signal, plus a per-language **system-language change + reboot** to localize the iPad date. `--time` rejects `"9:41 AM"`/ISO strings — pass a bare `"9:41"`.

15. **Tutor-row kill switch** (`TutorDisplay.tutorUnavailableRowEnabled`, operator step — not in the driver)
    *Symptom:* the simulator can never reach Apple Intelligence — `World.simulator` injects the *real* `LanguageModelServiceReal`, so `SystemLanguageModel.availability` resolves against the host and fails — so `InfoBrowseView` renders "Apple Intelligence is still getting ready. Please try again later." where the tutor entry goes. On iPad that cell sits in the visible Concepts grid and **shipped in `version_3`'s two iPad `info_browse` shots**. *Fix:* set the switch to `false` before the sweep (see *Disable onboarding, tips, and the tutor row first*), restore after. Only the unavailability cell is gated; the `isAvailable` `NavigationLink` branch is untouched, so the switch structurally cannot hide a working tutor. Both size-class branches (`tutorListRow`, `tutorGridCell`) are gated — verified 2026-07-18 on iPhone 17 and iPad Pro 13-inch (M4), in both switch positions: no ghost `List` row when off, cell returns when on.

16. **Frame-to-frame stability wait** (`take_screenshots.sh::wait_for_stable_screen`, `STABLE_PIXEL_TOLERANCE`)
    *Symptom:* switching tabs on iPad cross-fades, and a capture taken during the fade shows the previous screen ghosted through the new one — which is what the sibling app Konjugieren shipped. Long Info articles have the same shape (slow layout, capture lands mid-render). **No accessibility-based wait can catch either:** the outgoing screen's anchor leaves the AX tree within ~0.3 s of the tap while the fade is still plainly visible, because AX state answers "has the hierarchy changed" while a screenshot is graded on "has the image stopped moving". *Fix:* before each capture, sample screenshots 0.35 s apart and compare with `magick compare -metric AE` until consecutive frames differ by less than `STABLE_PIXEL_TOLERANCE`, giving up after 8 samples with a log line. Degrades to a flat `sleep 1.0` when `magick` is absent. The tolerance is **measured, not guessed** (`5e7`, from an iPhone quiz floor of 6.4e6–2.5e7 against an iPad cross-fade of 1.2e8–2.8e10) and is a property of *this* app — never port it.

17. **Largest-area frame selection** (`take_screenshots.sh::frame_of`)
    *Symptom:* an id can match several AXTree elements, and taking the depth-first first one taps whichever the traversal happened to reach. In Konjugieren an iPad Info row exposed its heading as an `AXStaticText` *above* the tappable `AXButton`; tapping non-interactive static text does nothing at all, so the sweep captured the wrong screen in all four cells and reported success for two releases. *Fix:* pick the largest-area match — the element standing for the whole row is the widest one. Preferring `AXButton` looks like the fix and is not: on iPad a verb row exposes its translation as a button while the infinitive is static text, so that rule taps the translation instead. Verified 2026-07-26 that Conjuguer currently has exactly **one** match at every tap site on both devices in both languages, so this is a safety net here rather than a live fix.

18. **Pinned plugin resolution** (`take_screenshots.sh::resolve_ibv_scripts`)
    *Symptom:* `find ~/.claude -path '*ios-build-verify*'` matches both the marketplace clone and every version under `plugins/cache/ios-build-verify/<version>/` (0.2.1 and 0.3.1 were both present), and `find` does not guarantee directory order — so which release built the App Store screenshots was unspecified. *Fix:* search only `~/.claude/plugins/marketplaces`, which has no version segment and yields exactly one match.

19. **A booted simulator can have no Simulator *window*, which silently kills Cmd+K**
    (`prep_screenshot_sim.sh::ensure_simulator_window`, `take_screenshots.sh::set_keyboard_state`)
    *Symptom:* one `quiz_mid` cell captured with **no keyboard**, the driver having logged
    three `AppleScript Cmd+K attempt N failed` lines and then the 3× warning. Both causes
    that warning used to name were false — the accessibility permission was granted and
    Simulator did come frontmost. *Cause:* `xcrun simctl boot` does not always make
    Simulator.app attach a window when Simulator is already running, and a per-language
    reboot is the usual way in. The device is then **booted but windowless**: `simctl` and
    `axe` keep working, because they talk to the device rather than the UI, so the rest of
    the sweep is unaffected — but `AXRaise of (first window whose title contains "$DEVICE")`
    has nothing to raise and fails with `-1719 "Invalid index"`, which looks exactly like a
    permission failure. *Fix, in two places:* `prep_screenshot_sim.sh` checks for the window
    after its reboot and, if absent, quits and relaunches Simulator.app (on launch it
    attaches a window to every already-booted device); `set_keyboard_state` checks for it
    inside its existing 3× loop, before each AXRaise, and logs the real cause instead of
    the misleading one. The driver deliberately does **not** attempt recovery — quitting
    Simulator mid-sweep is too blunt — so a windowless device still costs one reviewable
    screenshot, it just no longer costs an hour of chasing permissions.
    *Observed in Conjugar on 2026-07-26 and ported here the same day; not yet seen in
    Conjuguer, and the recovery branch has not been exercised end to end anywhere, because
    the windowless state proved intermittent and would not reproduce on demand.*

20. **Cmd+K is dead; the keyboard is now a two-state machine**
    (`take_screenshots.sh::set_keyboard_state, keyboard_state_is, toggle_hardware_keyboard,
    paste_into_quiz_field`)
    *Symptom (in Conjugar, 2026-08-01):* `quiz_mid` came out keyboard-less with
    `soft keyboard still not visible after Cmd+K` — the same visible defect as workaround
    #19, but with none of its causes: the accessibility permission was granted, Simulator
    came frontmost, and the window was there. *Cause:* on Xcode 26.3, Cmd+K — Simulator's
    **Toggle Software Keyboard** — no longer surfaces the keyboard while a hardware keyboard
    is attached. Clicking that menu item directly via AppleScript is equally inert, so it is
    not a keystroke-delivery problem. What governs the keyboard is
    **I/O ▸ Keyboard ▸ Connect Hardware Keyboard**: iOS shows the software keyboard for a
    focused field exactly when no hardware keyboard is attached, and unchecking it raises the
    keyboard instantly.
    *The trap that makes this more than a one-line fix:* every quiz answer is pasted with
    Cmd+V (workaround #5 — `axe type` has no keycodes for French accents), and axe injects
    that combo as **hardware** key events, which the device **ignores while the hardware
    keyboard is detached**. So the two requirements are mutually exclusive at any instant:
    pasting needs it attached, photographing the keyboard needs it detached. Detaching does
    not disturb the field's contents, so the driver orders them — `set_keyboard_state hidden`
    → paste → `set_keyboard_state visible` → capture — and `nav_quiz_results`, which submits
    30 answers and never photographs a keyboard, holds `hidden` throughout.
    `set_keyboard_state` keeps #10's and #19's window / frontmost / 3× retry guards verbatim,
    including this repo's full-device-name window match; it never reads the menu's checkmark
    (only readable while the menu is open) but clicks and then asks the screen, which is also
    what makes it idempotent across cells.
    *Second-order defect, fixed with it:* with the keyboard up, the driver's
    `tap_id input_quiz_conjugation` was tapping a field that **already had focus** (`QuizView`
    focuses it on start and after each submit), which raises iOS's **"Paste | AutoFill" edit
    callout** — it swallowed the Cmd+V *and* sat in the middle of the screenshot. The tap is
    gone from both quiz recipes, and `paste_into_quiz_field` now confirms the field actually
    holds the answer before moving on, falling back to tap / Cmd+A-replace only when it does
    not. In `nav_quiz_results` that check earns its keep differently: a silently missed paste
    there desynchronizes every later answer from its question.
    *Note on the empty-field read:* the field's `AXValue` reports the **placeholder** when
    empty, not `""` — so the check compares against the expected answer rather than testing
    for emptiness.
    *Status here: ported, not yet run.* Verified end to end in Conjugar (both directions of
    the state machine, on both devices); in Conjuguer it is syntax-checked and matched against
    this app's identifiers only. Shoot `--view quiz_mid` and look at the PNG before committing
    to a full sweep.

21. **A booted simulator can render pure black while every other signal says it is fine**
    (`take_screenshots.sh::ensure_simulator_app, assert_framebuffer_live`)
    *Symptom:* `xcrun simctl bootstatus -b` reports success, `axe describe-ui` returns a
    complete home-screen accessibility tree with icons — and every capture is a mean-0 black
    PNG, from both `axe screenshot` and `simctl io screenshot`. In the run where this was
    found, `simctl launch` also hung for 21 minutes against the same device.
    *Why it is dangerous:* `wait_for_render` polls the **accessibility tree**, which stays
    perfectly healthy throughout. Nothing in the driver's wait path can see this, so the sweep
    runs to completion, reports success, and writes a full set of black screenshots. A live AX
    tree proves the device is *running*, not that it is *rendering* — those are different
    claims, and only the pixels can settle the second one.
    *Fix:* `assert_framebuffer_live` captures a probe frame and requires `magick`'s `%[mean]`
    above 1 (a threshold, not `!= 0` — a nearly-black frame is just as dead, while a live
    dark-mode screen clears it easily on status-bar text alone). It retries 10× at 3 s, because
    a just-booted device legitimately renders black while SpringBoard comes up, then exits 2
    with a diagnostic. `ensure_simulator_app` launches Simulator.app when it is not running.
    Both are called from `ensure_booted`, and `main` runs a **preflight pass over every target
    device before the build**, so this fails in seconds rather than after a ~10-minute
    `build_app.sh`.
    *Cause never established — read this before chasing it.* Simulator.app being absent was the
    most visible anomaly, but **launching it did not clear the condition**, so the tempting
    "headless boot breaks rendering" story is a correlation that was never earned. Quitting and
    relaunching Simulator.app, `simctl shutdown all`, and `launchctl remove
    com.apple.CoreSimulator.CoreSimulatorService` all failed too. **Only a host reboot worked.**
    If you hit this, reboot rather than working down that list. A stray `screencapture`
    permission dialog was also sitting on the host and is worth dismissing first, since a modal
    there can stall host-side capture indefinitely.
    *Observed in Conjuguer on 2026-08-04; the guard is ported to all three apps. The failing
    state is not reproducible on demand, so the abort path was verified by pointing
    `assert_framebuffer_live` at a shut-down device (exits 2 with the diagnostic) and the pass
    path against a live one (returns in ~1 s).*

## Per-View Navigation Recipes

> **Tab coordinates were measured here on 2026-07-26** and `tab_coords_for()` now takes a
> **language** as well as a device. The prior suspicion was correct: the inherited row
> (`355 / 441.5 / 523 / 587.75 / 667.25`) was a measurement of the sibling app Konjugieren's
> *German* labels, byte-identical to that app's. Every one of those five taps landed inside
> the right iPad segment, so the calibration looked verified — but near each segment's left
> edge, `Info` clearing the boundary by only 6.25 pt.
>
> The iPad row is per-language and the iPhone row is not, structurally: the iPad's regular
> size class sizes each segment to its label, so FR `Verbes` / `Modèles` / `Paramètres`
> displace every center after them (Verbs 386.25 → Verbes 369). The compact iPhone pill
> distributes items into equal-width slots, so a longer localized label changes the text
> without moving the slot center.
>
> Re-measure per app and per language; never copy another app's row. The iPad's top bar
> reports each tab as an `AXRadioButton`:
>
> ```bash
> axe describe-ui --udid <IPAD_UDID> \
>   | jq '[.. | objects | select(.role? == "AXRadioButton")] | .[] | {AXLabel, AXFrame}'
> ```
>
> Center = `x + w/2`, `y + h/2`. An off-center-but-working tap is the early warning that
> geometry drifted. The **iPhone** pill exposes no `AXRadioButton` children at all, so it
> cannot be measured this way — probe it in reverse, tapping a coordinate and reading back
> the label:
>
> ```bash
> axe describe-ui --point "296.2,899.3" --udid <IPHONE_UDID> \
>   | jq -r '[.. | objects | select(.AXLabel? != null and .AXLabel != "") | .AXLabel]'
> ```

| # | View | Mode | Driver function | Notes |
|---|---|---|---|---|
| 1 | VerbBrowseView | dark | `nav_verb_browse` | Default landing; `wait_for_render verb_browse_sort`. Frequency sort is the default → être on top. |
| 2 | VerbView | light | `nav_verb_view` | `tap_id_first verb_row_avoir`. |
| 3 | ModelBrowseView | dark | `nav_model_browse` | `tap_tab models` → settle on `model_row_être`. Irregularity sort is the default → être model at/near top. |
| 4 | ModelView | light | `nav_model_view` | `tap_tab models` → `tap_id_first model_row_être`. |
| 5 | QuizView (mid) | dark | `nav_quiz_mid` | `tap_tab quiz` → `quiz_start_button` → `set_keyboard_state hidden` → paste fixture answer 0 → `set_keyboard_state visible`. Captured before submit (keyboard visible per spec). The field is not tapped — it is already focused, and tapping it raises an edit callout (workaround #20). |
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
| `OnboardingDisplay.onboardingEnabled` / `TipDisplay.tipsEnabled` / `TutorDisplay.tutorUnavailableRowEnabled` | operator flips all three to `false` pre-sweep; renaming any of them silently breaks the documented `sed` commands, which fail *quietly* (`sed` reports no error when a pattern matches nothing) | `Conjuguer/Utils/KillSwitches.swift` |
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

- **Upload through Media Manager, not the version page's tile.** The version page exposes
  **one tile per device family**, and which display size it accepts follows what the app
  shipped previously — not what's current. Conjuguer 1.5 shipped 6.5", so the 2.0 page
  offered only an *iPhone 6.5" Display* tile and rejected this driver's 6.9" captures
  (1320 × 2868), a perfectly valid App Store size. **View All Sizes in Media Manager**
  exposes every display size instead, and **2.0 shipped through it with the native
  1320 × 2868 and 2064 × 2752 captures accepted unchanged** — no downscaling, no
  regenerated bundle. Keep the downscale recipes in
  [`docs/screenshot-plan.md`](screenshot-plan.md) as the fallback.
- **Run `scripts/verify_store_media.sh` before every upload.** It asserts accepted
  dimensions, absence of alpha, and (for previews) duration, H.264 level, stream count,
  frame rate, and audio bit rate — none of which is visible in a screenshot review. It
  grades in two tiers: **blocking** for what is known to stop an upload (wrong dimensions,
  alpha, duration outside 15–30 s) and **advisory** for spec deviations that App Store
  Connect has accepted in practice (sibling app Konjugieren shipped previews at Level
  5.0/5.1 with 125 kbps audio and a stray timecode track).
- **Flip TipKit off before the run — and the tutor row with it.** Tips are a compile-time master switch (`TipDisplay.tipsEnabled` in `Conjuguer/Utils/KillSwitches.swift`). Set it to `false`, run the sweep, then restore `true`. If you forget, the "Try the Quiz" / "Explore Models" tip cards can appear in the VerbBrowseView / ModelBrowseView screenshots. (The driver builds once at start, so the flag must be set first.) The neighboring `OnboardingDisplay.onboardingEnabled` and `TutorDisplay.tutorUnavailableRowEnabled` need the same treatment in the same pass — see *Disable onboarding, tips, and the tutor row first*.
- **Default sorts drive screens 1 and 3.** Screen 1 relies on `Settings.verbSortDefault == .frequency` (être on top); screen 3 on `Settings.modelSortDefault == .irregularity` (être model at/near top). The driver does not change sorts — segmented pickers render with empty AXTree children on iOS 26 and aren't individually addressable by id. A fresh install starts at the defaults, so this holds; if either default changes, re-spec those screens.
- **The "TENSES" / "TEMPS" scroll is calibration-sensitive.** Screen 6 wants the Tenses section header at the top. `scroll_until_top info_row_participe_passe 170` brings the section's first row near the top so the header shows just above it — tune the target y (170) if the header is clipped or too low. Likewise screen 7's `scroll_until_top info_row_indicatif_present 400` parks that row in the safe middle band before tapping.
- **Apple Intelligence Tutor surfaces are availability-gated — and this *does* affect the sweep.** The Tutor row in InfoBrowseView (and the AI page in OnboardingView) render only when `languageModelService.isAvailable`. A simulator can never satisfy that (`World.simulator` injects the *real* service, so availability resolves against the host), so the Tutor row shows an "unavailable" cell reading "Apple Intelligence is still getting ready." **On iPad that cell falls inside the `info_browse` shot** — it is present in both iPad cells of the `version_3` bundle on disk. iPhone escapes it only *by accident*: `scroll_until_top info_row_participe_passe 170` pushes Concepts off the top. That is a calibration value, not a guarantee — retune it and iPhone inherits the problem. Set `TutorDisplay.tutorUnavailableRowEnabled = false` before the sweep (workaround #15); the switch gates only the unavailability cell, never the working `NavigationLink`.
- **Review-prompt cooldown is per-install.** `seed_defaults` pre-seeds `lastReviewPromptDate` for in-run prompts, but a manual screenshot capture of the StoreKit modal would still require uninstalling/reinstalling first.
- **iPad first-boot is ~70s on a fresh sim.** Data-migration plugins initialize on first boot; subsequent boots are ~22s. The driver's `WAIT_FOR_RENDER_BUDGET_S=20` accommodates the post-launch render poll, but the `xcrun simctl bootstatus -b` step itself can block for ~70s during that initial boot. Don't kill the sweep thinking it's hung — `bootstatus -b` is doing the right thing.
