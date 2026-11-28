# Fix the Verbs Tab's Truncated Search Prompt

Written 2026-11-28 by the Konjugieren session that fixed the same bug there. Run this in a fresh
Conjuguer session.

**Done 2026-11-28.** See `docs/blog_notes.md`, "Three Screenshots From a Small Phone".

## The bug

Josh's screenshot, `~/Downloads/f3.jpg`, shows the Verbs tab on his iPhone with the text size at
XXXL, the largest size below the accessibility sizes. The search field's prompt reads "Verb,
conjugation, or Engli…". The phone is 375 points wide, the width of an iPhone 12 mini, 13 mini,
or SE.

Josh does not want the prompt shortened for everyone. He wants the full prompt wherever it fits,
and a shorter one only where it would truncate.

## What Konjugieren learned (read before starting)

Konjugieren fixed this in commit `08457b7`. Read these three files before writing code:

- `../Konjugieren/Konjugieren/Utils/SearchPrompt.swift`: the fitting logic, about 50 lines.
- `../Konjugieren/KonjugierenTests/Utils/SearchPromptTests.swift`: its parameterized test.
- `../Konjugieren/docs/blog_notes.md`, the entry "The Search Prompt That Lost Three Points
  (2026-11-28)": what was tried, what failed, and why.

The facts that entry rests on were measured on the iOS 26.3 simulators with a temporary probe that
read the live `UISearchTextField`. They are facts about UIKit, not about Konjugieren, so they hold
here:

1. **The `prompt:` of `.searchable` is a UIKit placeholder, not a SwiftUI view.**
   `minimumScaleFactor` and `ViewThatFits` cannot reach it.
2. **The field's font is exactly `UIFont.preferredFont(forTextStyle: .body)`** at every size.
3. **Geometry.** The field sits 16 points from each edge of the content in compact width and 20
   in regular width. Its text area ends 7 points before the field's trailing edge. It begins past
   the magnifying glass, at a leading inset that grows with the text size:

   | Size | XS | S | M | L | XL | XXL | XXXL | AX1 | AX2 | AX3 | AX4 | AX5 |
   |---|---|---|---|---|---|---|---|---|---|---|---|---|
   | Inset (pt, rounded up) | 36 | 37 | 39 | 40 | 42 | 45 | 47 | 52 | 58 | 57 | 63 | 69 |

   AX3's inset is smaller than AX2's. That dip is real, not a typo.
4. **UIKit already shrinks the placeholder at the five accessibility sizes.** There, the private
   `UISearchBarTextFieldLabel` has `adjustsFontSizeToFitWidth` on and `minimumScaleFactor` set to
   14 divided by the font size, so the prompt shrinks to fit down to 14 points. From XS through
   XXXL it is off, and a long prompt truncates.
5. **Shrinking at every size cannot be done cleanly.** An appearance proxy for
   `adjustsFontSizeToFitWidth` is silently ignored, because the property is not a
   `UI_APPEARANCE_SELECTOR`. Both `UISearchTextField.appearance()` and
   `UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])` were tried. Setting it
   once on the live field did not stick either. Do not retry these. Josh chose the shorter-prompt
   ladder below over a view-hierarchy hack.

## How Conjuguer differs from Konjugieren

**The prompt is longer.** "Verb, conjugation, or English meaning" is 287 points at the default
size (L), against Konjugieren's 228. Widths measured in the system font, which matches UIKit
to within half a point:

| Prompt | L (17 pt) | XL (19) | XXL (21) | XXXL (23) | 14 pt |
|---|---|---|---|---|---|
| Verb, conjugation, or English meaning | 287 | 318 | 342 | 370 | 244 |
| Verbe, conjugaison ou sens anglais | 267 | 296 | 319 | 346 | 227 |

The text area is 296 points at L on a 375-point phone, and 289 at XXXL. On the 402-point "Conjuguer
iPhone 17" simulator, it is 323 at L and 316 at XXXL. So both languages truncate from XL upward on
Josh's phone, and from XXL upward on the simulator.

**At accessibility sizes, measure at 14 points instead of returning the full prompt.** Konjugieren
returns its full prompt at every accessibility size, because its longest prompt fits even at
UIKit's 14-point floor. Conjuguer's prompts fit there too (244 and 227 against 267 at AX5 on a
375-point phone). But Conjugar's Spanish prompt does not, so the three apps should share the
general rule: at an accessibility size, measure each candidate in a 14-point system font, which
is the smallest UIKit will shrink it to. This also needs the AX rows of the inset table above.

**Both browse tabs share `browseSearchable`** (`Conjuguer/Views/BrowseSearchField.swift`). The fix
belongs there, so the Models tab gets it too, even though "Model or verb" (106 points at L) and
"Modèle ou verbe" (166 at XXXL) never truncate.

## Steps

### 1. Strings

Add two shorter rungs for the Verbs prompt. Proposed wording (Josh may revise the French):

| Key | en | fr |
|---|---|---|
| `VerbBrowseView.searchPrompt` (exists) | Verb, conjugation, or English meaning | Verbe, conjugaison ou sens anglais |
| `VerbBrowseView.searchPromptShort` | Verb, conjugation, or meaning | Verbe, conjugaison ou sens |
| `VerbBrowseView.searchPromptShortest` | Verb or meaning | Verbe ou sens |

Konjugieren's ladder ends in "Search". Conjuguer's does not need that rung. The shortest rung is
163 points at XXXL and fits any width down to about 250 points, below which there is no iPhone
or iPad layout. `longestFitting` returns the last rung even when nothing fits, so a ladder needs no
rung that is guaranteed to fit.

Add the accessors to `Conjuguer/Models/L.swift` and the entries to
`Conjuguer/Assets/Localizable.xcstrings`. Follow `.claude/rules/localization_catalog.md`, which
loads when you touch either file: keep the catalog in Xcode's canonical format, validate the JSON
afterward, and confirm with `git diff --stat` that the catalog shows insertions only.

### 2. `Conjuguer/Utils/SearchPrompt.swift`

Port Konjugieren's file with the accessibility change. Use Conjuguer's file-header style (see
`BrowseSearchField.swift`). The comments below are the kind `CLAUDE.md` § Comments allows:
measured magic numbers and a UIKit constraint.

```swift
import SwiftUI
import UIKit

enum SearchPrompt {
  private static let trailingInset: CGFloat = 7
  // UIKit shrinks the placeholder to fit at accessibility sizes, but no smaller than the field's
  // 14-point minimumFontSize. Below those sizes it truncates.
  private static let accessibilityFloor: CGFloat = 14

  static func longestFitting(
    _ candidates: [String],
    containerWidth: CGFloat,
    dynamicTypeSize: DynamicTypeSize,
    sizeClass: UserInterfaceSizeClass?
  ) -> String {
    let longest = candidates.first ?? ""
    guard containerWidth > 0 else {
      return longest
    }
    let font = dynamicTypeSize.isAccessibilitySize
      ? UIFont.systemFont(ofSize: accessibilityFloor)
      : UIFont.preferredFont(
        forTextStyle: .body,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
      )
    let fieldMargin: CGFloat = sizeClass == .regular ? 20 : 16
    let available = containerWidth - 2 * fieldMargin - leadingInset(dynamicTypeSize) - trailingInset
    return candidates.first { width(of: $0, in: font) <= available } ?? candidates.last ?? longest
  }

  private static func width(of prompt: String, in font: UIFont) -> CGFloat {
    ceil((prompt as NSString).size(withAttributes: [.font: font]).width)
  }

  // Where UISearchTextField's text begins, past the magnifying glass, as measured on iOS 26.3.
  private static func leadingInset(_ dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch dynamicTypeSize {
    case .xSmall:
      return 36
    case .small:
      return 37
    case .medium:
      return 39
    case .large:
      return 40
    case .xLarge:
      return 42
    case .xxLarge:
      return 45
    case .xxxLarge:
      return 47
    case .accessibility1:
      return 52
    case .accessibility2:
      return 58
    case .accessibility3:
      return 57
    case .accessibility4:
      return 63
    case .accessibility5:
      return 69
    @unknown default:
      return 69
    }
  }
}
```

A width of 0 means the view has not been measured yet. Returning the longest prompt then avoids a
flash of a shorter one on launch.

### 3. Wire it into `browseSearchable`

`browseSearchable` is a function on `View`, which cannot hold the measured width. Turn its body
into a private `ViewModifier` that does, and change the `prompt: String` parameter to `prompts:
[String]`:

```swift
extension View {
  func browseSearchable(
    text: Binding<String>,
    prompts: [String],
    isFocused: FocusState<Bool>.Binding,
    engagement: SearchEngagement
  ) -> some View {
    modifier(BrowseSearchable(text: text, prompts: prompts, isFocused: isFocused, engagement: engagement))
  }
}

private struct BrowseSearchable: ViewModifier {
  let text: Binding<String>
  let prompts: [String]
  let isFocused: FocusState<Bool>.Binding
  let engagement: SearchEngagement
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var width: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
      .searchable(
        text: text,
        placement: BrowseLayout.searchPlacement,
        prompt: SearchPrompt.longestFitting(prompts, containerWidth: width, dynamicTypeSize: dynamicTypeSize, sizeClass: horizontalSizeClass)
      )
      // … the existing .searchFocused, .textInputAutocapitalization, .autocorrectionDisabled,
      // and .onChange, unchanged
  }
}
```

The callers then become:

- `VerbBrowseView.swift:93`: `prompts: [L.VerbBrowseView.searchPrompt,
  L.VerbBrowseView.searchPromptShort, L.VerbBrowseView.searchPromptShortest]`
- `ModelBrowseView.swift:82`: `prompts: [L.ModelBrowseView.searchPrompt]`

The modifier sits on the `ZStack` inside each `NavigationStack`, whose width is the content
width the field's 16- and 20-point margins are measured from. If the build complains about
storing a `FocusState<Bool>.Binding` in the modifier, it is a `DynamicProperty` and is allowed
there. Check the spelling before changing the design.

### 4. Tests: `ConjuguerTests/SearchPromptTests.swift`

Follow `.claude/rules/swift_testing.md`. Port Konjugieren's test. Two traps it hit:

- `@Test(arguments:)` is evaluated outside the suite's main actor, so a static ladder the
  arguments read must be `nonisolated private static let`.
- An untyped tuple such as `(402, .xxxLarge)` infers `Int`, not `CGFloat`. Konjugieren uses a
  small `Field` struct instead.

Pass the ladders as literal strings, so the test does not depend on the simulator's language.
Cases, computed from the widths above. Each leaves at least 3 points of margin, so a half-point
difference between macOS and iOS measurements cannot flip one:

| Ladder | Width | Size | Expected |
|---|---|---|---|
| en | 375 | XXXL | Verb or meaning (Josh's screenshot) |
| en | 375 | XL | Verb, conjugation, or meaning |
| en | 375 | L | full |
| en | 402 | XL | full |
| en | 402 | XXXL | Verb, conjugation, or meaning |
| en | 375 | AX1 | full (244 fits at 14 pt) |
| en | 375 | AX5 | full |
| fr | 375 | L | full |
| fr | 375 | XXL | Verbe, conjugaison ou sens |
| fr | 375 | XXXL | Verbe, conjugaison ou sens |
| en | 834, regular | XXXL | full |
| en | 0 | XXXL | full (not yet measured) |
| en | 100 | XXXL | Verb or meaning (nothing fits, so the last rung) |

Leave out fr at XL on 375 points and fr at XXL on 402 points. The full prompt misses by 2 points
and 1 point there, which is closer than the measurement can promise.

### 4.5 Additional changes

Fix the bug shown in ~/Downloads/f1.jpg . Then, delete the label shown in ~/Downloads/f2.jpg for all tenses.

### 5. Verify on the simulator

Use "Conjuguer iPhone 17" (402 points wide), never another app's device. Set each size with
`xcrun simctl ui <UDID> content_size <size>` (`large`, `extra-large`, `extra-extra-large`,
`extra-extra-extra-large`, `accessibility-medium`, `accessibility-extra-extra-extra-large`). Then
relaunch the app, because changing the size live can leave stale geometry. Screenshot each with
`xcrun simctl io <UDID> screenshot`, and run once in French with `xcrun simctl launch <UDID>
<bundle id> -AppleLanguages "(fr)"`. Expected on 402 points:

| Size | English | French |
|---|---|---|
| L, XL | full | full |
| XXL | Verb, conjugation, or meaning | either (the full prompt misses by 1 point) |
| XXXL | Verb, conjugation, or meaning | Verbe, conjugaison ou sens |
| AX-M, AX5 | full, shrunk by UIKit | full, shrunk by UIKit |

At XXL in French, either result is correct, but a truncated prompt is not. If the full prompt
shows, it must end in "anglais", not an ellipsis.

If the review prompt or onboarding gates the launch, uninstall the app for a clean start. Set the
size back to `large` at the end.

If a screenshot still truncates, Conjuguer's field geometry differs from Konjugieren's, and the
inset table needs re-measuring. Konjugieren's journal entry describes the probe: a timer that
walks the window for the `UISearchTextField` and logs its frame, `textRect(forBounds:)`, font, and
the placeholder `UILabel`'s frame and `adjustsFontSizeToFitWidth`. Delete it afterward.

### 6. Finish

- Run the whole suite. Read the run's test count, not just its exit status.
- Add `Utils/SearchPrompt.swift` and `SearchPromptTests.swift` to `docs/project_structure.md`,
  update the `BrowseSearchField.swift` entry if it describes `browseSearchable`, and run
  `python3 scripts/check_docs.py`.
- Run `swiftlint` from the repo root, because the pre-commit hook blocks on any violation.
- Append a `docs/blog_notes.md` entry that points to Konjugieren's for the measurements rather
  than repeating them, and says what was different here: the longer prompt and the 14-point rule.
