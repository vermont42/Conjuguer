# Plan: Tutor-Row Kill Switch for Screenshots

**Status:** proposed, not implemented.
**Ported from:** Conjugar, where this shipped 2026-07-18 as `TutorDisplay.tutorUnavailableRowEnabled`.
**Estimated size:** ~20 lines of app code, plus playbook and journal prose.

## Why — and this one is not hypothetical

`InfoBrowseView` shows a Conjugation Tutor entry in the **Concepts** section. When the
on-device model is available it is a `NavigationLink`; when it is not, it falls back to
`tutorUnavailableCell(reason:)` — a cell reading "Apple Intelligence is still getting ready.
Please try again later." (`L.Tutor.reasonModelNotReady`).

The simulator always takes the fallback, and structurally so: `World.simulator`
(`Conjuguer/Utils/World.swift:114`) injects `LanguageModelServiceReal()`, **not** the Dummy,
so the sim asks the real `SystemLanguageModel.availability` and gets `.unavailable(…)`.

**The row is already in the shipped screenshots.** Verified against
`docs/screenshots/version_3/`:

| Cell | Tutor row visible? |
|---|---|
| `iPad_English/6.png` | **Yes** — "Conjugation Tutor / Apple Intelligence is still getting ready. Please try again later." |
| `iPad_French/6.png` | **Yes** — "Tuteur de Conjugaison / Apple Intelligence se prépare encore. Veuillez réessayer plus tard." |
| `iPhone_English/6.png` | No — the sweep scrolls to the Tenses header, pushing Concepts off the top |
| `iPhone_French/6.png` | No — same scroll |

So **two of the four `info_browse` cells in the last upload bundle carry an "Apple
Intelligence is unavailable" notice.** Whether that shipped to the App Store depends on which
bundle Josh actually uploaded, but it is in `version_3` on disk.

> **Correct a stale claim while you are here.** `docs/screenshot-playbook.md` (~line 450)
> asserts: *"None of the 9 target screenshot views depend on the Tutor row, so this doesn't
> affect the sweep."* That is wrong for iPad. It happens to hold on iPhone, and only by
> accident of the scroll target (`scroll_until_top info_row_participe_passe 170`) — a
> calibration value, not a guarantee. Retune that scroll and the iPhone cells inherit the
> problem too. Fix the sentence in the same pass.

## Design constraints (learned from Conjugar)

1. **Suppress the unavailable cell only.** Guard the `else if let reason = …` branch, never
   the `isAvailable` branch. A switch that can hide a *working* feature is a footgun; this
   one structurally cannot.
2. **Default `true`.** Ordinarily on; flipped `false` only for a sweep, restored after.
3. **Compile-time, not `UserDefaults`.** The driver builds once at start, so a runtime flag
   invites a stale-build mismatch. (Contrast the onboarding suppression, which is
   deliberately runtime — the driver seeds `hasSeenOnboarding`, workaround #2.)

## Conjuguer-specific: there are **two** branches to gate

This is the one real difference from Conjugar, whose `InfoBrowseView` has a single
`@ViewBuilder tutorSection`. Conjuguer has two sibling properties, one per size class, in
`Conjuguer/Views/InfoBrowseView.swift`:

- `tutorListRow` (lines ~120–129) — compact / iPhone list layout
- `tutorGridCell` (lines ~131–143) — regular / **iPad grid layout, which is the one actually
  affected**

**Gate both.** Gating only the list row would leave the iPad — the device where the bug is
visible — unchanged, and would be very easy to "verify" on iPhone and call done.

## Steps

### 1. Add the switch

`Conjuguer/Models/ConjuguerTips.swift` already hosts `TipDisplay.tipsEnabled`, so the
convention exists and this simply joins it. Add below `TipDisplay`:

```swift
enum TutorDisplay {
  /// Master switch for the tutor entry's *unavailability* cell, mirroring
  /// `TipDisplay.tipsEnabled`. Ordinarily `true`. Set to `false` before generating
  /// screenshots (then restore to `true`).
  ///
  /// The tutor needs Apple Intelligence, which is never available in a simulator —
  /// `World.simulator` injects the *real* service, so availability resolves against the
  /// host and fails. `InfoBrowseView` therefore renders a reason cell there ("Apple
  /// Intelligence is still getting ready…"), which is honest on a device but reads as a
  /// defect in an App Store screenshot. Only the reason cell is suppressed: when the model
  /// *is* available the entry still renders its `NavigationLink`, so this switch can never
  /// hide a working feature.
  static let tutorUnavailableRowEnabled = true
}
```

### 2. Gate both branches

```swift
// tutorListRow
} else if let reason = world.languageModelService.unavailabilityReason,
          TutorDisplay.tutorUnavailableRowEnabled {
  tutorUnavailableCell(reason: reason)
}

// tutorGridCell
} else if let reason = world.languageModelService.unavailabilityReason,
          TutorDisplay.tutorUnavailableRowEnabled {
  tutorUnavailableCell(reason: reason)
    .card()
}
```

Then check the **call site** at lines ~98–101:

```swift
if section.category == .concepts {
  tutorListRow
    .listRowBackground(Color.customBackground)
}
```

When `tutorListRow` resolves to empty, SwiftUI's `List` may still emit a row container for
it — an empty cell with a background and separators where the tutor used to be. Verify in the
built UI; if a ghost row appears, hoist the switch into the `if` condition
(`if section.category == .concepts, TutorDisplay.tutorUnavailableRowEnabled || world.languageModelService.isAvailable`)
or wrap the call site rather than the branch. **This is the step most likely to need an
iteration, so budget for it.** The grid path has no such container concern.

### 3. Verify — on iPad specifically

```bash
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer \
  -destination 'platform=iOS Simulator,name=iPad Pro 13-inch (M4)' build
```

Drive to the Info tab and confirm the Concepts section shows exactly its four concept cells
with no tutor cell and **no gap in the grid flow** where it used to be. Repeat on iPhone
(scroll up to Concepts — the sweep's scroll hides it, so scroll deliberately) to confirm no
ghost list row. Then flip back to `true` and confirm the cell returns on both. **Both
directions, both size classes** — this is a four-way check, and the iPad grid is the one
that matters.

### 4. Update `docs/screenshot-playbook.md`

The playbook mentions `TipDisplay.tipsEnabled` in **three prose places** but has **no
kill-switch table and no `sed` commands**. Adding a table is the tidiest way to carry two
switches. Suggested, before *Quick Start*:

```markdown
## Disable tips and the tutor row first (then restore)

Two compile-time switches, both in `Conjuguer/Models/ConjuguerTips.swift`, both ordinarily
`true`. **Set both to `false` before running the driver and restore both afterward.** The
driver builds once at start, so they must be flipped *before* you launch it.

| Switch | Effect when `false` | What you get if you forget |
|---|---|---|
| `TipDisplay.tipsEnabled` | `ConjuguerApp` skips `Tips.configure()`, so every `TipView` / `.popoverTip(_:)` stays hidden. | A tip card lands in one of the browse/quiz/settings shots. |
| `TutorDisplay.tutorUnavailableRowEnabled` | `InfoBrowseView` drops the tutor **unavailability cell** (both size-class branches). Only that cell — the working `NavigationLink` is untouched. | Both **iPad** `info_browse` shots carry "Apple Intelligence is still getting ready." (iPhone escapes it only via the scroll target.) |

```bash
# before the sweep
sed -i '' 's/static let tipsEnabled = true/static let tipsEnabled = false/; \
           s/static let tutorUnavailableRowEnabled = true/static let tutorUnavailableRowEnabled = false/' \
  Conjuguer/Models/ConjuguerTips.swift

# after the sweep — restore
sed -i '' 's/static let tipsEnabled = false/static let tipsEnabled = true/; \
           s/static let tutorUnavailableRowEnabled = false/static let tutorUnavailableRowEnabled = true/' \
  Conjuguer/Models/ConjuguerTips.swift

git diff --stat Conjuguer/Models/ConjuguerTips.swift   # must be empty when you are done
```
```

Also:
- Update the **paste-in prompt block** (~line 24), which currently names only
  `TipDisplay.tipsEnabled`, to say *both* switches.
- Update the **Prerequisites** bullet (~line 52) likewise.
- Add **workaround #15** (the list tops out at #14).
- Add the file to *Don't Break These — Driver Anchor Dependencies*.
- **Fix the stale Known Gotcha at ~line 450** per the note above.

### 5. Re-shoot the affected cells, and bump the bundle

The two iPad `info_browse` cells must be re-captured; the other 34 are unaffected:

```bash
scripts/take_screenshots.sh --device "iPad Pro 13-inch (M4)" --lang en --view info_browse
scripts/take_screenshots.sh --device "iPad Pro 13-inch (M4)" --lang fr --view info_browse
```

Then rebuild `docs/screenshots/latest/` and project a **`version_4`** bundle (`version_3` is
the newest on disk). Read both new PNGs before assembling — per Conjugar's experience, a
driver exit code of 0 does not mean the screenshot is of the right screen.

### 6. Journal it

Append a `## <Title> (YYYY-MM-DD)` entry to `docs/blog_notes.md` (newest at bottom, narrative
not changelog). Worth recording: that the row was already sitting in `version_3`'s iPad
shots; that iPhone escaped only by accident of a scroll calibration; that Conjuguer needed
**two** branches gated where Conjugar needed one; and that the switch cannot hide a working
tutor.

## Out of scope

- `OnboardingView`'s AI page (`OnboardingView.swift:19`, `:92`) — onboarding is not in the
  sweep's nine views and is separately suppressed by the seeded `hasSeenOnboarding`. Revisit
  only if an onboarding screenshot is ever specced.
- Making the tutor available in the simulator. That is host eligibility, not a flag, and it
  means the listing will never show the tutor *entry point*. If Josh wants that shot, it has
  to be taken by hand on an Apple-Intelligence-capable device.
- Retuning the iPhone `scroll_until_top` target. Out of scope here, but note the iPhone's
  immunity is incidental, not designed.
