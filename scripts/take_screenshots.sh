#!/usr/bin/env bash
# Drive ios-build-verify (and axe/simctl directly) through the 36 App Store
# screenshots described in docs/screenshot-plan.md.
#
# Usage:
#   scripts/take_screenshots.sh  # all 36
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max"  # 18
#   scripts/take_screenshots.sh --lang fr  # 18
#   scripts/take_screenshots.sh --view model_browse  # 4
#   scripts/take_screenshots.sh --device "iPhone 17 Pro Max" --lang fr --view quiz_results  # 1
#
# See docs/screenshot-playbook.md for setup, recovery guidance, and a
# cross-referenced workarounds index. Calibration values and per-view nav
# functions are inline below.
#
# Compatible with macOS bash 3.2 (system default): uses case-statement lookup
# functions instead of associative arrays.

set -euo pipefail

# ---------------------------------------------------------------------------
# Repo root (cwd-independent)
# ---------------------------------------------------------------------------
# Resolve the repo root from this script's own location (scripts/ is one level
# below the root) so the driver works from any working directory — screenshots
# land under <repo>/docs/screenshots and Conjuguer.xcodeproj resolves absolutely.
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "$SCRIPT_DIR/.." && pwd)

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

APP_BUNDLE_ID='software.racecondition.Conjuguer'
# Onboarding is normally suppressed by pre-seeding hasSeenOnboarding=true (see
# seed_defaults). These labels are a belt-and-suspenders fallback for the
# wait_for_render loop in case onboarding still surfaces. (workaround #11)
ONBOARDING_LABELS=( "Skip" "Passer" )

DEVICES=( "iPhone 17 Pro Max" "iPad Pro 13-inch (M4)" )
LANGS=( en fr )
VIEWS=( verb_browse verb_view model_browse model_view quiz_mid \
        info_browse info_view quiz_results settings )

# ---------------------------------------------------------------------------
# Lookup tables (case statements; bash 3.2-compatible)
# ---------------------------------------------------------------------------

appearance_for() {
  case "$1" in
    verb_browse)  echo dark  ;;
    verb_view)    echo light ;;
    model_browse) echo dark  ;;
    model_view)   echo light ;;
    quiz_mid)     echo dark  ;;
    info_browse)  echo light ;;
    info_view)    echo dark  ;;
    quiz_results) echo light ;;
    settings)     echo dark  ;;
  esac
}

# Resolve a simulator UDID by its exact device name. Unlike Konjugieren's driver
# (which hardcoded UDIDs to dodge _resolve_udid.sh's paren-in-name regex bug),
# this matches the name as a literal in Python, so the iPad's Apple-default name
# "iPad Pro 13-inch (M4)" works unchanged — no sim renaming needed.
udid_for() {
  xcrun simctl list devices available | python3 -c '
import sys, re
name = sys.argv[1]
for line in sys.stdin:
    m = re.match(r"\s+(.*?) \(([0-9A-Fa-f-]{36})\) \(", line.rstrip())
    if m and m.group(1) == name:
        print(m.group(2))
        break
' "$1"
}

# Tab-bar pixel centers (logical points). Order: verbs models quiz info settings.
# Measured 2026-07-26 on iOS 26 from each tab's own AXFrame (x + w/2, y + h/2), not
# ported from a sibling app — the row that shipped here previously was byte-identical
# to Konjugieren's, i.e. a measurement of *that* app's German labels. Every one of
# those five numbers landed inside the right iPad segment but near its left edge (Info
# cleared the edge by 6.25 pt), so the taps worked and the calibration looked verified.
#
# The iPad row is per-language and the iPhone row is not, for a structural reason. The
# iPad's regular size class renders a top segmented bar that sizes each segment to its
# label, so a longer word displaces every center after it: FR "Verbes"/"Modèles"/
# "Paramètres" shift all five centers (Verbs 386.25 → Verbes 369). The compact iPhone
# pill instead distributes items into equal-width slots, so a localized label changes
# the text without moving the slot center — verified by reverse-probing all five iPhone
# coordinates in both languages (`axe describe-ui --point`, which is the only way: the
# pill exposes no AXRadioButton children at all).
tab_coords_for() {
  case "$1/$2" in
    "iPhone 17 Pro Max"/*)      echo "67,899.3 142.7,899.3 220,899.3 296.2,899.3 372.6,899.3" ;;
    "iPad Pro 13-inch (M4)"/en) echo "386.25,54 469.5,54 547.75,54 612.5,54 692,54" ;;
    "iPad Pro 13-inch (M4)"/fr) echo "369,54 461.75,54 544.75,54 609.5,54 701.5,54" ;;
  esac
}

# iPad's verb_browse anchor renders slowly (6,320 verbs in regular size class).
wait_budget_for() {
  case "$1" in
    "iPhone 17 Pro Max")     echo 10 ;;
    "iPad Pro 13-inch (M4)") echo 45 ;;
  esac
}

# ---------------------------------------------------------------------------
# CLI parsing
# ---------------------------------------------------------------------------

DEVICE_FILTER=""
LANG_FILTER=""
VIEW_FILTER=""

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \?//'
  exit 0
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device) DEVICE_FILTER="$2"; shift 2 ;;
    --lang)   LANG_FILTER="$2";   shift 2 ;;
    --view)   VIEW_FILTER="$2";   shift 2 ;;
    -h|--help) usage ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log() { echo "[take_screenshots] $*" >&2; }

# Per-iteration state (set inside loop):
UDID=""
DEVICE=""
DEVICE_SLUG=""
WAIT_FOR_RENDER_BUDGET_S=10
CURRENT_TAB_CENTERS=()

apply_device_state() {
  DEVICE="$1"
  UDID=$(udid_for "$DEVICE")
  [[ -n "$UDID" ]] || { log "no available simulator named '$DEVICE' — see Simulator Setup in the playbook"; exit 2; }
  DEVICE_SLUG="${DEVICE// /-}"
  WAIT_FOR_RENDER_BUDGET_S=$(wait_budget_for "$DEVICE")
}

# Tab centers depend on the language on iPad (see tab_coords_for), so they are
# resolved inside the language loop rather than once per device.
apply_lang_state() {
  local centers
  centers=$(tab_coords_for "$DEVICE" "$1")
  [[ -n "$centers" ]] || { log "no tab centers for '$DEVICE' / '$1'"; exit 2; }
  IFS=' ' read -ra CURRENT_TAB_CENTERS <<< "$centers"
}

ensure_booted() {
  if ! xcrun simctl list devices booted | grep -q "$UDID"; then
    log "booting $DEVICE ($UDID) — iPad first-boot can take ~70s"
    xcrun simctl boot "$UDID"
  fi
  xcrun simctl bootstatus "$UDID" -b >/dev/null
}

set_appearance() {
  xcrun simctl ui "$UDID" appearance "$1" >/dev/null
}

terminate_app() {
  xcrun simctl terminate "$UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
}

uninstall_app() {
  xcrun simctl uninstall "$UDID" "$APP_BUNDLE_ID" >/dev/null 2>&1 || true
}

install_app() {
  xcrun simctl install "$UDID" "$1"
}

# Pre-seed two persisted Settings values (both stored as strings via
# GetterSetterReal → UserDefaults; see Settings.swift) so the sweep isn't
# interrupted:
#   - hasSeenOnboarding = true  → OnboardingView never shows (workaround #2/#11).
#   - lastReviewPromptDate = now → ReviewPrompterReal's 180-day cooldown blocks
#     every StoreKit review prompt this run (workaround #7).
# Bool/Date SettingValue decoders accept the string forms "true" and the unix
# epoch, so -string is correct for both.
seed_defaults() {
  xcrun simctl spawn "$UDID" defaults write "$APP_BUNDLE_ID" hasSeenOnboarding -string true >/dev/null 2>&1 || true
  xcrun simctl spawn "$UDID" defaults write "$APP_BUNDLE_ID" lastReviewPromptDate -string "$(date +%s)" >/dev/null 2>&1 || true
}

launch_with_lang() {
  local lang="$1" locale
  case "$lang" in
    en) locale='en_US' ;;
    fr) locale='fr_FR' ;;
    *) log "unknown lang: $lang"; return 1 ;;
  esac
  xcrun simctl launch "$UDID" "$APP_BUNDLE_ID" \
    -AppleLanguages "($lang)" \
    -AppleLocale "$locale" \
    -CONJUGUER_QUIZ_FIXTURE screenshot >/dev/null
}

axe_tree() {
  axe describe-ui --udid "$UDID" 2>/dev/null || echo "{}"
}

# jq predicate that matches an element whose AXUniqueId is exactly $id OR begins
# with "$id-". SwiftUI propagates accessibilityIdentifier through the row's
# NavigationLink wrapper, so a row tagged "verb_row_avoir" surfaces in the AXTree
# as "verb_row_avoir-verb_row_avoir". The "-" boundary keeps the prefix match from
# colliding with sibling ids (e.g. verb_row_avoir vs verb_row_aller). (workaround #3)
ID_MATCH='select(.AXUniqueId? != null and (.AXUniqueId == $id or (.AXUniqueId | startswith($id + "-"))))'

axe_has_id() {
  axe_tree | jq -e --arg id "$1" "[.. | objects | $ID_MATCH] | length > 0" >/dev/null 2>&1
}

wait_for_render() {
  local anchor="${1:-verb_browse_sort}"
  local deadline=$(($(date +%s) + WAIT_FOR_RENDER_BUDGET_S))
  while [[ $(date +%s) -lt $deadline ]]; do
    local tree
    tree=$(axe_tree)
    if echo "$tree" | jq -e --arg id "$anchor" \
        "[.. | objects | $ID_MATCH] | length > 0" \
        >/dev/null 2>&1; then
      return 0
    fi
    for label in "${ONBOARDING_LABELS[@]}"; do
      if echo "$tree" | jq -e --arg l "$label" \
          '[.. | objects | select(.AXLabel? == $l)] | length > 0' \
          >/dev/null 2>&1; then
        axe tap --label "$label" --udid "$UDID" >/dev/null 2>&1 || true
        break
      fi
    done
    sleep 0.5
  done
  log "wait_for_render timed out (${WAIT_FOR_RENDER_BUDGET_S}s) on $DEVICE for $anchor"
  return 5
}

verify_screen_loaded() {
  wait_for_render "$1"
}

# Return the AXFrame "x y w h" of the LARGEST-AREA element whose AXUniqueId matches
# $1, or empty string if none is currently rendered.
#
# Largest-area, not depth-first-first: an id can match several elements, and the one
# standing for the whole row is the widest. Taking [0] tapped whichever the traversal
# reached first, which on iPad is sometimes a non-interactive AXStaticText heading
# sitting above the tappable AXButton — tapping it does nothing at all, silently, so
# the sweep captured the wrong screen and reported success (Konjugieren's info_view
# shipped that way for two releases). Preferring AXButton is the tempting fix and is
# wrong: on iPad a verb row exposes its translation as a button while the infinitive
# is static text, so that rule taps the translation and stops navigating. Largest-area
# is the only rule correct at all five tap sites, and it degrades to the old behaviour
# wherever the old behaviour worked.
#
# Selection is in awk rather than jq on purpose: computing area in jq means a regex
# against the AXFrame string inside a double-quoted bash string that already
# interpolates $ID_MATCH, and the escaping is unreadable. The sed has already
# reduced each frame to "x y w h".
frame_of() {
  axe_tree | jq -r --arg id "$1" \
    "[.. | objects | $ID_MATCH | select(.AXFrame? != null)] | .[] | .AXFrame" \
    | sed -E 's/[{},]/ /g; s/  +/ /g' \
    | awk 'NF >= 4 { area = $3 * $4; if (area > best) { best = area; line = $0 } } END { if (line != "") print line }'
}

# SwiftUI propagates accessibilityIdentifier to child elements, so `axe tap --id`
# refuses to disambiguate when multiple matches exist; it also throws a Swift
# typeMismatch in some iPad screen states. So we extract the first match's frame
# and tap its center via coords. (workarounds #3 and #9)
tap_id() {
  tap_id_first "$1"
}

tap_id_first() {
  local id="$1" frame x y w h cx cy
  frame=$(frame_of "$id")
  if [[ -z "$frame" ]]; then
    log "tap_id_first: no element with id '$id'"
    return 1
  fi
  read -r x y w h <<< "$frame"
  cx=$(awk "BEGIN{printf \"%.2f\", $x + $w/2}")
  cy=$(awk "BEGIN{printf \"%.2f\", $y + $h/2}")
  axe tap -x "$cx" -y "$cy" --udid "$UDID" >/dev/null
  sleep 0.7
}

# Is the soft keyboard currently on screen?
#
# The keyboard belongs to a separate process, so it does NOT appear in the app's
# `axe describe-ui` tree at all — a full-tree dump of a screen with the keyboard
# plainly visible returns zero keyboard elements. `describe-ui --point` *does*
# see it (the same trick the review-prompt dismiss uses on the StoreKit modal),
# so probe a coordinate in the middle of the key field and ask what is under it:
# a single-character label ("g") means keys are there; anything longer is the
# app's own content showing through, i.e. no keyboard.
#
# The point is deliberately mid-keyboard rather than on the space bar: space
# reports a blank label, indistinguishable from "nothing found".
#
# Probe points were validated on iPhone 17 Pro Max and iPad Pro 13-inch (M4) on
# iOS 26.3 (in the sibling app Conjugar). They are a property of the *device*,
# not the app, and both apps target these same two device types — so they carry
# over. Re-check if the device list changes.
keyboard_is_visible() {
  local probe labels
  case "$DEVICE" in
    "iPhone 17 Pro Max")     probe="220,760"  ;;
    "iPad Pro 13-inch (M4)") probe="516,1120" ;;
    *) return 1 ;;
  esac
  labels=$(axe describe-ui --point "$probe" --udid "$UDID" 2>/dev/null \
    | jq -r '[.. | objects | select(.AXLabel? != null and .AXLabel != "") | .AXLabel] | join("|")' 2>/dev/null)
  [[ -n "$labels" && ${#labels} -le 2 ]]
}

# Put the target device's keyboard into a known state.
#
#   set_keyboard_state visible  -> hardware keyboard DETACHED, soft keyboard on screen
#   set_keyboard_state hidden   -> hardware keyboard ATTACHED, no soft keyboard
#
# The two are one setting, not two: iOS shows the software keyboard for a focused field
# exactly when no hardware keyboard is attached, and Simulator's
# "I/O > Keyboard > Connect Hardware Keyboard" menu item is what attaches/detaches it. The
# menu acts on the FRONTMOST device window, hence the raise/frontmost guards below.
#
# Why the sweep needs BOTH states, which is the whole shape of this function (found in the
# sibling app Conjugar on 2026-08-01, ported here the same day; workaround #20):
#
#   - Screen 5 must SHOW the keyboard, so it needs the hardware keyboard detached.
#   - Every quiz answer is pasted with Cmd+V (workaround #5: axe type has no keycodes for
#     French accents — `axe type "était"` fails outright). axe injects that combo as
#     HARDWARE key events, which the device ignores while the hardware keyboard is
#     detached: with it off, Cmd+V silently does nothing and the field keeps its
#     placeholder, while `axe type` (software-keyboard path) still works.
#
# So the answer is pasted with the keyboard attached and the hardware keyboard is detached
# afterwards, purely to raise the soft keyboard for the capture. Detaching does not disturb
# the field's contents. nav_quiz_results wants the opposite state throughout: it submits 30
# answers with Cmd+V and Return and never photographs a keyboard.
#
# Cmd+K ("Toggle Software Keyboard") is what this did through 2026-08-01. It no longer
# surfaces the keyboard on this toolchain (Xcode 26.3) while a hardware keyboard is
# attached — the keystroke lands (Simulator frontmost, osascript exit 0) and nothing
# happens, and clicking that menu item directly is equally inert, while toggling Connect
# Hardware Keyboard works instantly. Verified by hand on Conjugar's live quiz screen. It is
# gone rather than kept as a fallback: it cannot help, and a stray toggle of a second
# keyboard setting makes this state machine harder to reason about.
#
# The menu item is a TOGGLE whose checkmark is only readable while the menu is open, so
# this never reads the setting — it clicks and then asks the screen whether the keyboard is
# where it should be, which is the property that actually matters. That check is also what
# makes the function idempotent across cells: the setting persists across app launches, so
# without it the second quiz_mid cell would toggle the keyboard back off and the four
# quiz_mid shots would alternate. (workarounds #6, #10, #19 and #20)
#
# The window is matched on the FULL device name, not a family substring ("iPhone").
# Simulator titles its windows "<device name> – iOS <version>", so `$DEVICE` selects
# exactly one; a family substring does not. Observed 2026-07-26: a concurrent session
# in a sibling app had "iPhone 17" booted alongside this sweep's "iPhone 17 Pro Max",
# System Events enumerated the foreign window first, and Cmd+K went to it — so both
# iPhone quiz_mid cells captured with no keyboard while the sweep reported success.
set_keyboard_state() {
  local want="$1" window_match="$DEVICE" attempt front
  if keyboard_state_is "$want"; then
    return 0
  fi
  # `delay 0.5`, not 0.2: with a freshly-activated Simulator the window list is
  # briefly unenumerable and AXRaise fails with -1719 "Invalid index", which
  # reads exactly like a missing-permission failure and sends you chasing the
  # wrong thing.
  #
  # Retried, and never fatal. That same unenumerable window list is a race, not a steady
  # state, and the first quiz cell of a sweep runs moments after a fresh install, which is
  # exactly when it loses. A genuine permission failure fails all three attempts and still
  # gets a warning, and the state check reports the real outcome either way, so continuing
  # costs at most one reviewable screenshot.
  #
  # The menu click is gated on Simulator actually being frontmost, and that guard is NOT
  # redundant with the AXRaise above. When the raise silently fails to take focus, a
  # keystroke still SUCCEEDS — it just lands in whichever app *is* frontmost. Observed
  # 2026-07-26, where a stray Cmd+K launched Fitness on the host Mac while the sweep
  # reported nothing wrong. Checking frontmost first turns a silent misfire into a log line
  # naming the app that caught it — and because the check sits INSIDE the loop, a transient
  # focus steal recovers on the next attempt instead of costing the cell. It earns its keep:
  # during Conjugar's 2026-08-01 sweep it correctly refused to click while Safari and then
  # VS Code held focus, costing one retried cell instead of one shipped defect.
  #
  # A device can be BOOTED yet have no Simulator WINDOW: `xcrun simctl boot` does not always
  # make Simulator.app attach one when Simulator is already running, and a per-language
  # reboot is the usual way in. Nothing else in the sweep notices, because simctl and axe
  # talk to the device rather than to the UI — but AXRaise then has no window to raise and
  # fails with -1719 "Invalid index", indistinguishable from the missing-permission failure.
  # Checking first turns that into a log line naming the real cause. Recovery is
  # deliberately NOT attempted here — restoring a window means quitting and relaunching
  # Simulator.app, too blunt mid-sweep; prep_screenshot_sim.sh does it at reboot time, where
  # a relaunch costs nothing. (workaround #19)
  for attempt in 1 2 3; do
    if [[ "$(osascript -e 'tell application "System Events" to tell process "Simulator" to get name of every window' 2>/dev/null || true)" != *"$window_match"* ]]; then
      log "keyboard($want) attempt $attempt: no Simulator window matching '$window_match' (device booted but windowless? see prep_screenshot_sim.sh); not touching the menu"
      sleep 1.0
      continue
    fi
    if osascript -e 'tell application "Simulator" to activate' \
              -e 'delay 0.5' \
              -e "tell application \"System Events\" to tell process \"Simulator\" to perform action \"AXRaise\" of (first window whose title contains \"$window_match\")" \
              -e 'delay 0.3' \
              >/dev/null 2>&1; then
      front=$(osascript -e 'tell application "System Events" to name of first process whose frontmost is true' 2>/dev/null || true)
      if [[ "$front" != "Simulator" ]]; then
        log "keyboard($want) attempt $attempt: frontmost is '${front:-unknown}', not Simulator; not touching the menu"
        sleep 1.0
        continue
      fi
      if toggle_hardware_keyboard && keyboard_state_is "$want"; then
        return 0
      fi
    fi
    log "keyboard($want) attempt $attempt did not land; retrying"
    sleep 1.0
  done
  log "warning: could not put the keyboard in state '$want' on $DEVICE (accessibility permission for /usr/bin/osascript, Simulator never came frontmost, or the device has no Simulator window)"
}

keyboard_state_is() {
  if [[ "$1" == visible ]]; then
    keyboard_is_visible
  else
    ! keyboard_is_visible
  fi
}

# Click Simulator's "I/O > Keyboard > Connect Hardware Keyboard" for the frontmost device
# window. Callers must have raised the right window first — the menu acts on whichever
# device is frontmost, which is the same reason set_keyboard_state raises before touching
# it. Returns non-zero only if the click itself failed (missing accessibility permission,
# menu path renamed by a future Xcode).
toggle_hardware_keyboard() {
  osascript -e 'tell application "System Events" to tell process "Simulator" to click menu item "Connect Hardware Keyboard" of menu 1 of menu item "Keyboard" of menu 1 of menu bar item "I/O" of menu bar 1' \
    >/dev/null 2>&1 || return 1
  sleep 1.2  # keyboard slide-up animation
}

# axe type lacks HID-keycode mappings for non-ASCII characters (French accents
# é è à ç ô î û …), so route typing through the system pasteboard + Cmd+V. Works
# for any Unicode and bypasses the soft-vs-hardware keyboard distinction.
# (workaround #5)
type_via_pasteboard() {
  local text="$1"
  printf '%s' "$text" | xcrun simctl pbcopy "$UDID"
  sleep 0.15
  axe key-combo --modifiers 227 --key 25 --udid "$UDID" >/dev/null  # Cmd+V
}

# Current contents of the quiz answer field, or empty string.
quiz_field_value() {
  axe_tree | jq -r --arg id input_quiz_conjugation \
    "[.. | objects | $ID_MATCH | .AXValue] | map(select(. != null and . != \"\")) | .[0] // \"\"" \
    2>/dev/null
}

# Paste one answer into the quiz field and CONFIRM it landed.
#
# The confirmation is not belt-and-braces; it covers a real failure introduced by the
# soft-keyboard fix. QuizView focuses the answer field after Start and re-focuses it after
# each submit, so the driver's old `tap_id input_quiz_conjugation` was tapping a field that
# already had focus. With the hardware keyboard attached that was harmless. With it
# detached (see set_keyboard_state) the same tap raises iOS's edit callout — "Paste |
# AutoFill" — which both swallows the Cmd+V that follows AND sits in the middle of the
# screenshot. Observed in Conjugar on 2026-08-01: an otherwise perfect quiz_mid cell with a
# placeholder-empty field and the callout over the question card.
#
# So attempt 1 does NOT tap: it relies on the app's own focus, which is the state it
# actually leaves behind. Only if the value fails to land does it fall back to tapping the
# field (attempt 2) and to Cmd+A-then-replace (attempt 3), each of which can raise the
# callout — a defect in the capture, but a visible one, and better than an empty field. In
# nav_quiz_results the check matters for a different reason: a silently missed paste there
# would desynchronize every later answer from its question.
#
# Note the field reports its PLACEHOLDER as its AXValue when empty, not "", which is why
# this compares against the expected answer rather than testing for emptiness.
# (workaround #20)
paste_into_quiz_field() {
  local answer="$1" attempt value
  for attempt in 1 2 3; do
    case "$attempt" in
      2) tap_id_first input_quiz_conjugation || true ;;
      3) tap_id_first input_quiz_conjugation || true
         axe key-combo --modifiers 227 --key 4 --udid "$UDID" >/dev/null 2>&1 || true  # Cmd+A
         sleep 0.2 ;;
    esac
    type_via_pasteboard "$answer"
    sleep 0.35
    value=$(quiz_field_value)
    if [[ "$value" == "$answer" ]]; then
      return 0
    fi
    log "paste attempt $attempt: field reads '${value:-<empty>}', expected '$answer'"
  done
  log "warning: could not paste '$answer' into the quiz field on $DEVICE"
  return 0
}

tap_tab() {
  local tab_name="$1" index
  case "$tab_name" in
    verbs)    index=0 ;;
    models)   index=1 ;;
    quiz)     index=2 ;;
    info)     index=3 ;;
    settings) index=4 ;;
    *) log "unknown tab: $tab_name"; return 1 ;;
  esac
  local center="${CURRENT_TAB_CENTERS[$index]}"
  axe tap -x "${center%,*}" -y "${center#*,}" --udid "$UDID" >/dev/null
  sleep 0.7
}

swipe_up_pts() {
  local pts="$1"
  [[ "$pts" -le 0 ]] && return 0
  local start_y=600
  local end_y=$((start_y - pts))
  axe swipe --start-x 200 --start-y "$start_y" \
            --end-x 200 --end-y "$end_y" --duration 1.0 \
            --udid "$UDID" >/dev/null
  sleep 0.5
}

# Scroll the current list until the element with id $1 has its top edge at or
# above $2 (logical points). $3 = max swipes, $4 = per-swipe distance (smaller =
# finer landing, less overshoot). More robust than a fixed per-device scroll
# table for the deep Info-list rows (the Tenses section sits below the About +
# Concepts sections). Overshoot guard: a lazy list drops off-screen rows from the
# AXTree, so once we've seen the row and it then vanishes, it has scrolled above
# the top — stop there (the section header is sticky and stays pinned at top).
scroll_until_top() {
  local id="$1" target_y="$2" max_iters="${3:-15}" step="${4:-120}" i frame y seen=0
  for (( i = 0; i < max_iters; i++ )); do
    frame=$(frame_of "$id")
    if [[ -n "$frame" ]]; then
      seen=1
      read -r _ y _ _ <<< "$frame"
      if awk "BEGIN{exit !($y <= $target_y)}"; then
        return 0
      fi
    elif [[ "$seen" -eq 1 ]]; then
      return 0
    fi
    swipe_up_pts "$step"
  done
  log "scroll_until_top: '$id' not at/above y=$target_y after $max_iters swipes"
  return 0
}

read_fixture_answers_path() {
  local data_dir
  data_dir=$(xcrun simctl get_app_container "$UDID" "$APP_BUNDLE_ID" data 2>/dev/null)
  echo "$data_dir/Documents/screenshot_fixture_answers.json"
}

# Largest frame-to-frame difference (ImageMagick -metric AE) still considered "settled".
#
# MEASURED, not guessed, on iOS 26 on 2026-07-26 — these are Conjuguer's own numbers, so
# don't port them to another app. It cannot be 0 because the quiz screen never settles:
# QuizView's elapsed-time counter ticks with a `.snappy` animation and the text cursor
# blinks. 18 consecutive-frame samples on the iPhone quiz screen ran 6.4e6–2.5e7 (iPad,
# 2.4e6–6.9e6; a static screen such as Settings scores exactly 0). Against that, an iPad
# tab cross-fade sampled 1.2e8 just after the tap, 2.8e10 at the content swap, and 7.4e8
# still fading 0.35 s later. 5e7 is the geometric middle of the 2.5e7 ↔ 1.2e8 gap. That
# gap is only ~5x, narrower than one might like, so re-measure rather than nudge this if
# the "still changing after 8 samples" warning starts appearing.
STABLE_PIXEL_TOLERANCE=50000000

# Block until consecutive screenshots stop differing. No accessibility-based wait can do
# this job: switching tabs on iPad cross-fades, and the outgoing screen's anchor leaves
# the AX tree within ~0.3 s of the tap while the fade is still plainly visible. AX state
# answers "has the view hierarchy changed"; a screenshot is graded on "has the image
# stopped moving", and the two diverge exactly during animation — which is when a capture
# goes wrong. Konjugieren shipped tab-switch captures with the previous screen's verb list
# ghosted through them. This also covers slow layout (the long Info articles) without a
# per-screen special case.
wait_for_stable_screen() {
  local dir previous current differing i
  if ! command -v magick >/dev/null 2>&1; then
    sleep 1.0
    return 0
  fi
  dir=$(mktemp -d)
  previous="$dir/previous.png"
  current="$dir/current.png"
  if ! axe screenshot --udid "$UDID" --output "$previous" >/dev/null 2>&1; then
    rm -rf "$dir"
    sleep 1.0
    return 0
  fi
  for i in 1 2 3 4 5 6 7 8; do
    sleep 0.35
    axe screenshot --udid "$UDID" --output "$current" >/dev/null 2>&1 || break
    # `|| true` is load-bearing: `magick compare` exits 1 whenever the images differ,
    # which is the normal case here, and under `set -o pipefail` (:19) that makes the
    # assignment fail and `set -e` abort the whole sweep.
    differing=$(magick compare -metric AE "$previous" "$current" null: 2>&1 | awk '{print $1}' || true)
    # awk, not [[ -le ]]: the metric comes back in scientific notation (1.80683e+10).
    if [[ -n "$differing" ]] \
       && awk -v d="$differing" -v t="$STABLE_PIXEL_TOLERANCE" 'BEGIN { exit !(d + 0 <= t + 0) }'; then
      rm -rf "$dir"
      return 0
    fi
    mv "$current" "$previous"
  done
  log "wait_for_stable_screen: screen still changing after 8 samples on $DEVICE"
  rm -rf "$dir"
  return 0
}

take_screenshot() {
  local slug="$1"
  wait_for_stable_screen
  mkdir -p "$REPO_ROOT/docs/screenshots"
  local ts out
  ts=$(date +%Y%m%d-%H%M%S)
  out="$REPO_ROOT/docs/screenshots/${ts}-${slug}.png"
  axe screenshot --udid "$UDID" --output "$out" >/dev/null
  # axe writes RGBA; App Store Connect rejects any screenshot with an alpha
  # channel ("Images can't include alpha channels or transparencies"), so
  # flatten at capture rather than discovering it at upload time.
  if command -v magick >/dev/null 2>&1; then
    magick "$out" -background white -alpha remove -alpha off "$out"
  else
    log "WARNING: magick not found; $out keeps its alpha channel and will be rejected"
  fi
  log "captured: $out"
}

# ---------------------------------------------------------------------------
# Per-view nav functions
# ---------------------------------------------------------------------------

nav_verb_browse() {
  : # default landing; wait_for_render already ran in main loop. Frequency sort
    # is the default (Settings.verbSortDefault = .frequency), so être is on top.
}

nav_verb_view() {
  tap_id_first verb_row_avoir
}

nav_model_browse() {
  tap_tab models
  # Irregularity sort is the default (Settings.modelSortDefault = .irregularity),
  # which puts the most irregular model (être) at/near the top per the spec.
  verify_screen_loaded model_row_être
}

nav_model_view() {
  tap_tab models
  tap_id_first model_row_être
}

nav_quiz_mid() {
  tap_tab quiz
  tap_id quiz_start_button
  sleep 1.0  # let Quiz.start() write the fixture file + render the first question
  local fixture first_answer
  fixture=$(read_fixture_answers_path)
  first_answer=$(jq -r '.[0].answer' "$fixture")
  # Paste FIRST, with the hardware keyboard attached, because Cmd+V only works in that
  # state; then detach it so the soft keyboard rises for the capture. Detaching leaves the
  # field's contents alone. The field is already focused (QuizView focuses it after Start),
  # which is why nothing taps it here — see paste_into_quiz_field. (workaround #20)
  set_keyboard_state hidden
  paste_into_quiz_field "$first_answer"
  set_keyboard_state visible
  sleep 0.5  # let the keyboard slide-up finish before the screenshot
}

nav_info_browse() {
  tap_tab info
  # The segmented/animated tab can finish its highlight before the NavigationStack
  # swaps content; anchor on the first info row so the screenshot waits for the list.
  verify_screen_loaded info_row_dedication
  # Spec: scroll so the "TENSES" (FR "TEMPS") section header is at top. The Tenses
  # section is third (after About + Concepts), so bring its first row (participe
  # passé) just under the pinned header. Tune the target_y if the header is clipped.
  scroll_until_top info_row_participe_passe 200
}

nav_info_view() {
  tap_tab info
  verify_screen_loaded info_row_dedication
  # Indicatif Présent lives partway down the Tenses section; scroll it into the
  # safe middle band (clear of the tab bar) before tapping.
  scroll_until_top info_row_indicatif_present 400
  tap_id_first info_row_indicatif_present
}

nav_quiz_results() {
  tap_tab quiz
  tap_id quiz_start_button
  sleep 1.0
  local fixture answer i
  fixture=$(read_fixture_answers_path)
  # Cmd+V needs the hardware keyboard attached; this screen never shows a keyboard, so keep
  # it attached throughout. A preceding quiz_mid cell leaves it detached. (workaround #20)
  set_keyboard_state hidden
  # No tap: the field is focused after Start and re-focused after each submit, and tapping
  # it raises the edit callout that eats the paste (see paste_into_quiz_field).
  for i in $(seq 0 29); do
    answer=$(jq -r ".[$i].answer" "$fixture")
    paste_into_quiz_field "$answer"
    axe key 40 --udid "$UDID" >/dev/null   # Return; submitAnswer() re-focuses the field
    sleep 0.3
  done
  sleep 1.0  # let the results sheet animate in
  if ! axe_has_id results_score; then
    log "results_score not in AX tree; attempting review-prompt dismiss"
    dismiss_review_prompt
    sleep 0.7
  fi
  verify_screen_loaded results_score
}

# Fallback only: seed_defaults should keep the StoreKit review prompt from ever
# firing, but if one slips through it is the system dialog, so its button labels
# are system-localized ("Not Now" / "Pas maintenant"). The modal opaques the AX
# tree, but describe-ui --point inside it returns each element. Sweep a vertical
# line and tap the bottommost AXButton. (workaround #12)
dismiss_review_prompt() {
  local x_center y last_button_y=""
  case "$DEVICE" in
    "iPhone 17 Pro Max")     x_center=220 ;;
    "iPad Pro 13-inch (M4)") x_center=512 ;;
    *) return 0 ;;
  esac
  for y in 540 575 610 645 680 715; do
    if axe describe-ui --point "${x_center},${y}" --udid "$UDID" 2>/dev/null \
       | grep -qE '"role" : "AXButton"'; then
      last_button_y=$y
    fi
  done
  if [[ -n "$last_button_y" ]]; then
    axe tap -x "$x_center" -y "$last_button_y" --udid "$UDID" >/dev/null 2>&1
    sleep 0.5
    return 0
  fi
  log "review-prompt button not found in vertical sweep"
  return 0
}

nav_settings() {
  tap_tab settings
  # Spec: Quiz Difficulty picker at top — it is the first control, so no scroll.
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

resolve_ibv_scripts() {
  local path
  # Search only the marketplace clone, never ~/.claude broadly: the plugin cache
  # (~/.claude/plugins/cache/ios-build-verify/<version>/) holds several versions at
  # once, shared across apps, and `find`'s directory order is unspecified — so the
  # broad glob picked an arbitrary release to build App Store screenshots with. The
  # marketplace clone has no version segment and yields exactly one match.
  path=$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)
  [[ -n "$path" ]] || { log "ios-build-verify scripts not found"; exit 2; }
  echo "$(dirname "$path")"
}

resolve_app_path() {
  local built_dir
  built_dir=$(xcodebuild -project "$REPO_ROOT/Conjuguer.xcodeproj" -scheme Conjuguer \
    -destination 'generic/platform=iOS Simulator' \
    -showBuildSettings 2>/dev/null \
    | awk -F= '/^[[:space:]]+BUILT_PRODUCTS_DIR / { gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit }')
  [[ -n "$built_dir" ]] || { log "could not resolve BUILT_PRODUCTS_DIR"; exit 2; }
  echo "$built_dir/Conjuguer.app"
}

filter_skip() {
  local value="$1" filter="$2"
  [[ -z "$filter" ]] && return 1
  [[ "$value" == "$filter" ]] && return 1
  return 0
}

main() {
  # ios-build-verify's build_app.sh resolves its config + project relative to the
  # current directory, so anchor cwd at the repo root regardless of where the
  # driver was invoked from.
  cd "$REPO_ROOT"

  IBV_SCRIPTS=$(resolve_ibv_scripts)
  log "ibv scripts: $IBV_SCRIPTS"

  log "building once (install per device after)"
  "$IBV_SCRIPTS/build_app.sh"

  local app_path
  app_path=$(resolve_app_path)
  [[ -d "$app_path" ]] || { log "app bundle not found at $app_path"; exit 2; }
  log "app bundle: $app_path"

  for device in "${DEVICES[@]}"; do
    if filter_skip "$device" "$DEVICE_FILTER"; then continue; fi
    apply_device_state "$device"
    log "===== device: $device ($UDID) ====="
    ensure_booted
    log "uninstalling + installing fresh"
    uninstall_app
    install_app "$app_path"
    seed_defaults

    for lang in "${LANGS[@]}"; do
      if filter_skip "$lang" "$LANG_FILTER"; then continue; fi
      apply_lang_state "$lang"

      for view in "${VIEWS[@]}"; do
        if filter_skip "$view" "$VIEW_FILTER"; then continue; fi

        log "--- $device / $lang / $view ---"
        set_appearance "$(appearance_for "$view")"
        terminate_app
        launch_with_lang "$lang"
        wait_for_render
        "nav_$view"
        take_screenshot "${DEVICE_SLUG}-${lang}-${view}"
      done
    done
  done

  log "done."
}

main "$@"
