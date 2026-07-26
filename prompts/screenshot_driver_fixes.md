# Port six screenshot-driver fixes found while shooting Konjugieren's 1.3 screenshots

## Status

Konjugieren is Conjuguer's German-verb sibling app. Konjugieren lives in ../Konjugieren.

**Planned, not started.** Written 2026-07-26 by the Konjugieren session that ran that app's
36-cell sweep and fixed what the sweep exposed. Every item below was diagnosed against a running
simulator in Konjugieren and then checked against Conjuguer's actual source, so the "this applies
here" claims are grounded rather than inferred from similarity.

**This is not the extraction project.** Josh plans to factor screenshot generation out of
Konjugieren, Conjuguer, and Conjugar so the three stop drifting. That is a separate, large piece
of work. This plan applies fixes to Conjuguer's driver as it stands today.

## Why these six and not others

Konjugieren's sweep was the first run since a refresh that had been ported from Conjuguer and
never executed. Eight of nine views were fine. What is worth carrying over is that **not one
failure announced itself**: no non-zero exit, nothing in the log, no missing file. Each produced a
plausible-looking screenshot of the wrong thing. Two of them had been shipping in the App Store
listing for two releases.

That is the argument for doing this before Conjuguer's next sweep rather than after. A green run
is not evidence.

## Order

Items 1 through 4 are independent and can land in any order. Item 5 is a measurement that may
turn out to change nothing. Item 6 is the only one touching Swift.

---

### 1. `resolve_ibv_scripts` resolves to an arbitrary plugin version

`scripts/take_screenshots.sh:552`:

```bash
path=$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)
```

`~/.claude` contains `plugins/marketplaces/ios-build-verify/` (a single git checkout that
`claude plugin marketplace update` pulls to the latest release) **and**
`plugins/cache/ios-build-verify/<version>/`, which holds several versions at once and is shared
across Josh's apps. On the machine this was found, the cache held both 0.2.1 and 0.3.1, and the
broad glob resolved to the cache copy. `find` does not guarantee directory order, so which release
builds the App Store screenshots is unspecified.

**Change to:**

```bash
path=$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)
```

The marketplace clone has no version segment, so it yields exactly one match. Konjugieren's
CLAUDE.md documents this convention; check whether Conjuguer's does, and add it if not.

**Verify:** the command prints exactly one path, under `marketplaces/`.

---

### 2. `frame_of` taps the first match, which is not always the tappable one

`scripts/take_screenshots.sh:239-243` takes `[0]` from a depth-first traversal. The comment above
`tap_id_first` justifies this with the children sharing the parent NavigationLink's bounds. In
Konjugieren that stopped being true, and the failure was total and silent: an InfoBrowseView row
reports its heading as a separate `AXStaticText` sitting **above** the tappable `AXButton`
(heading at y=846 h=20.5, button at y=870.5 h=38 on iPad). Depth-first `[0]` returns the heading,
tapping non-interactive static text does nothing at all, and the sweep captured the Info list in
all four `info_view` cells while reporting success.

**Preferring an `AXButton` is the obvious fix and it is wrong.** It was tried first. On iPad the
verb row exposes its translation and family tag as buttons while the infinitive is static text, so
that rule tapped the translation instead of the infinitive and stopped navigating: it fixed
`info_view` and broke `verb_view`, which had been correct. Tabulating all five tap sites showed
largest-area is the only rule correct everywhere, and it has a reason rather than merely fitting:
the element standing for the whole row is the widest one. It reduces to the old behaviour
everywhere the old behaviour worked.

**Change `frame_of` to pick the largest-area match.** Do the selection in `awk` after the existing
`sed`, not in `jq`. Computing area in jq means writing a regex against the `AXFrame` string inside
a double-quoted bash string that already interpolates `$ID_MATCH`, and the backslash escaping is
genuinely nasty. The `sed` has already produced `x y w h`:

```bash
frame_of() {
  axe_tree | jq -r --arg id "$1" \
    "[.. | objects | $ID_MATCH | select(.AXFrame? != null)] | .[] | .AXFrame" \
    | sed -E 's/[{},]/ /g; s/  +/ /g' \
    | awk 'NF >= 4 { area = $3 * $4; if (area > best) { best = area; line = $0 } } END { if (line != "") print line }'
}
```

Note this **must keep `$ID_MATCH`**, which is Conjuguer's own prefix-matching predicate
(`:202`) and has no equivalent in Konjugieren. Do not replace it with an exact-match comparison.

The output contract is unchanged: one line of `x y w h`, or empty when nothing matches, so
`tap_id_first` needs no edit.

**Verify** before trusting a sweep, on both devices, for every id the driver taps
(`verb_row_avoir`, `model_row_être`, `quiz_start_button`, `quiz_answer_field`, and each
`info_row_*`). Compare what the old and new selectors choose:

```bash
axe describe-ui --udid <UDID> \
  | jq -r --arg id "verb_row_avoir" '[.. | objects | select(.AXUniqueId? != null and (.AXUniqueId == $id or (.AXUniqueId | startswith($id + "-")))) | select(.AXFrame? != null)] | .[] | "\(.role)\t\(.AXFrame)"'
```

Any id where the widest element differs from the first is one to exercise with a single cell.

---

### 3. No wait for the screen to stop moving

Conjuguer's driver has no equivalent of this and it is the fix with the broadest reach.

Switching tabs on iPad cross-fades. Konjugieren's `tap_tab` slept a fixed 0.7 s and sometimes lost
the race, producing `family_browse` and `settings` captures with the previous screen's verb list
ghosted through them. **No accessibility-based wait can catch this.** The outgoing screen's anchor
leaves the AX tree within 0.3 s of the tap while the fade is still plainly visible. AX state
answers "has the view hierarchy changed"; a screenshot is graded on "has the image stopped
moving", and those diverge precisely during animation, which is exactly when a capture goes wrong.

The same check also covers slow layout. Konjugieren's Präsens Indikativ article is roughly 16,000
characters and takes about 2 s to lay out, well past `tap_id_first`'s 0.7 s settle; successive
screenshots differ throughout, so waiting for stability handles it without a per-screen special
case.

**Add before the capture in `take_screenshot()` (`:416`):**

```bash
# Largest frame-to-frame difference (ImageMagick -metric AE) still considered "settled".
# MEASURE THIS FOR CONJUGUER; see below. The Konjugieren value is 100000000.
STABLE_PIXEL_TOLERANCE=<measured>

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
    # `|| true` is load-bearing: `magick compare` exits 1 whenever the images differ, which is
    # the normal case here, and under `set -o pipefail` (:19) that makes the assignment fail and
    # `set -e` abort the sweep. Konjugieren's first attempt died after one screenshot.
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
```

and call `wait_for_stable_screen` as the first line of `take_screenshot()`.

**Measure the tolerance rather than copying Konjugieren's.** It cannot be zero, because at least
one captured screen never fully settles: Konjugieren's quiz screen has a blinking text cursor and
a ticking elapsed-time counter and never scored below about 7.5e6. Two genuinely different screens
scored 1.8e10. The threshold sits at 1e8, in the empty space between. Conjuguer's quiz screen will
have its own floor. Measure it by navigating to the noisiest captured screen and running:

```bash
for i in 1 2 3 4; do
  axe screenshot --udid <UDID> --output /tmp/a.png >/dev/null 2>&1
  sleep 0.35
  axe screenshot --udid <UDID> --output /tmp/b.png >/dev/null 2>&1
  magick compare -metric AE /tmp/a.png /tmp/b.png null: 2>&1 | awk '{print $1}'
done
```

Then pick a value roughly an order of magnitude above the largest sample. Record the measured
numbers in the comment, so the next person can tell a measurement from a guess.

---

### 4. `latest/` accumulates across releases

`docs/screenshot-playbook.md:126` builds `latest/` with `mkdir -p` and no clearing. After a
re-shoot, the previous release's files sit beside the new ones (Konjugieren's went from 36 to 72),
and the numbered-bundle snippet that follows iterates `latest/*.png` and maps each to a slot
number. With two candidates per slot, which one wins depends on glob order. It happens to resolve
correctly while timestamps sort in release order, which is not a property worth betting an upload
on.

**Change the snippet to `rm -rf docs/screenshots/latest && mkdir -p docs/screenshots/latest && \`**
and say in the prose that `latest/` is a per-release projection rather than an accumulating
archive. The timestamped originals stay in `docs/screenshots/`, so nothing is lost.

---

### 5. iPad tab coordinates: measure first, then decide

`scripts/take_screenshots.sh:83-88` takes only the device, and its iPad row is
`355,54 441.5,54 523,54 587.75,54 667.25,54`.

**That row is byte-identical to Konjugieren's, which is suspicious.** Measuring Konjugieren's
AXTree showed those five numbers are exactly its English tab centres, to the decimal, for the
labels Verbs / Families / Quiz / Info / Settings. Conjuguer's second tab is Models, not Families
(`nav_model_browse`, `tap_id_first model_row_être`). The iPad's regular size class renders a top
segmented bar that sizes each segment to its label, so a different word in slot 2 displaces every
centre after it. Both apps cannot be correct with the same numbers unless the two words happen to
render identically wide.

It may still work. An off-centre tap that lands inside the right segment succeeds silently, which
is exactly how Konjugieren's German case went unnoticed: every English centre landed inside its
German tab, but "Info" cleared the German tab's right edge by only 16.75 pt.

**Measure both languages before changing anything:**

```bash
axe describe-ui --udid <IPAD_UDID> \
  | jq '[.. | objects | select(.role? == "AXRadioButton")] | .[] | {AXLabel, AXFrame}'
```

Centre is `x + w/2`. Relaunch with `-AppleLanguages "(fr)" -AppleLocale fr_FR` and repeat.

**Then:** if English and French centres differ, give `tab_coords_for()` a `lang` parameter as
Konjugieren's now has, resolve tab centres per-language inside the language loop rather than once
per device, and pass the language through. If they happen to agree, correct the numbers if they
are wrong and leave the signature alone.

**Do not copy Konjugieren's German row.** Those are measurements of German labels in a different
app.

The iPhone needs no equivalent, and the reason is structural rather than lucky: the compact tab bar
distributes items into equal-width slots, so a longer localized label changes the text without
moving the slot centre. Konjugieren's iPhone coordinates were verified correct in both languages.
The iPhone pill also exposes no `AXRadioButton` children at all, so it cannot be measured this way;
probe it in reverse instead, tapping a coordinate and reading back the label:

```bash
axe describe-ui --point "296.2,899.3" --udid <IPHONE_UDID> \
  | jq -r '[.. | objects | select(.AXLabel? != null and .AXLabel != "") | .AXLabel]'
```

---

### 6. Quiz answers are typed in the conjugator's mixed-case convention

`Conjuguer/Models/Quiz.swift:328-336` writes `answer` straight from
`Conjugator.conjugatedString(...)`, and `Conjuguer/Utils/ConjugationText.swift:12` states the
convention: "non-letters are 'regular' (blue), uppercase letters are 'irregular' (red)". The driver
pastes that value verbatim (`:465`).

In Konjugieren, 22 of 30 fixture answers carried such capitals, including `IST geblIEben`.

**The capitals are correct output, not a defect.** Nothing in the conjugator or the highlighting
should change. The problem is narrower and entirely about the screenshot: the answer field depicts
what a *user* typed, and no human types `IST geblieben`. Normalize on the way into the field only.

**Change `:335` to `"answer": answer.lowercased()`** and comment why. Grading is unaffected: the
app compares against its own value in memory and never reads this file, which exists solely to be
typed by the driver.

**Do not do this in the shell.** `tr '[:upper:]' '[:lower:]'` operates on bytes and silently skips
every non-ASCII capital, which in French means every accented one. Swift's `.lowercased()` handles
them.

Check the fixture for a legitimately capitalized word before assuming a blanket lowercase is safe.
Konjugieren's 30 had none, the formal-`Sie` imperative not being among them; Conjuguer's plan may
differ. Dump it after a quiz starts:

```bash
python3 -c "
import json
a = json.load(open('<app-data>/Documents/screenshot_fixture_answers.json'))
for x in a: print(x['answer'], '->', x['answer'].lower())
"
```

Konjugieren also saw an intermittent 29/30 disappear once a capital ẞ stopped being pasted, so
this may fix a scoring flake as well.

## What must not change

- **Do not replace `ID_MATCH`.** Conjuguer's prefix-matching predicate (`:202`) is more capable
  than Konjugieren's exact match and item 2 must preserve it.
- **Do not port Konjugieren's measured numbers.** The German tab centres and the 1e8 stability
  tolerance are measurements of a different app. Port the shape, measure the values.
- **Do not remove the alpha flattening** in `take_screenshot()`. It is already correct here.
- **Do not treat this as the extraction.** Resist refactoring toward a shared driver while
  applying these; that is Josh's separate project, and a half-extraction would make it harder.

## Verification

1. **One cell per fix, before any full sweep.** `--device`, `--lang`, and `--view` combine, so
   each fix can be exercised in about a minute. Item 2 in particular wants one cell for every
   view that taps a row.
2. **A full sweep, then look at all 36.** Contact sheets make this cheap and catch the failures
   that matter here, since wrong-screen and ghosting are both obvious at thumbnail size:
   ```bash
   magick montage <9 files> -tile 5x2 -geometry 300x650+6+6 -background '#666' sheet.png
   ```
3. **`scripts/verify_store_media.sh docs/screenshots/version_<N>`** if Conjuguer has it. Expect
   0 blocking and 0 advisory.
4. **Confirm the kill switches are restored** afterward, whatever Conjuguer's equivalents are, and
   that `git diff --stat` on that file is empty.

## Journal

Append to Conjuguer's work journal per its CLAUDE.md. The entry worth writing is not the six
diffs. It is that a driver ported between two apps carried one app's measurements as though they
were infrastructure, and that every failure this plan fixes produced a plausible screenshot rather
than an error, which is why a green sweep proved nothing.
