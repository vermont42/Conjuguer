# Future SwiftUI Fixes — Conjuguer (post-Phase-7)

## Context for the implementing session

You are working in **`~/Desktop/workspace/Conjuguer.do`** — a git repo where the SwiftUI work
from `conjuguer-swiftui-issues.md` has been implemented in the working tree (uncommitted; sessions
were told to make **no commits**). Status as of this writing:

- **Phases 0–6** (issues #1–#22, #25, #26, #29, #30) — done. See `phase0-baseline.md` …
  `phase6-verification.md`.
- **Phase 7** (the three Phase-6 deferrals: **#27** env injection, **#28** async launch parse,
  **#24** bare-`Spacer()` no-ops) — done. See `phase7-part1/2/3-verification.md`.
- **#3** (`.sheet(item:)`) — done, including the last holdout: `ModelView` now drives its verb /
  stem-alterations sheets from one `Identifiable` `DetailSheet` enum.
- **Phase 8, Part 1** (the last open audit issue, **#23** inter-element `Spacer().frame(height:)`)
  — **done.** See `phase8-part1-verification.md`.

So **the entire original issue list is now implemented.** What remains in this document is
**four small refinements that prior sessions deliberately deferred with rationale** (Parts 2a–2d,
each cites its source note) — all optional polish, no open audit issues left. They are independent —
do them as separate passes (and separate `phase8-*.md` notes), in any order.

**Environment & constraints**
- Deployment target iOS 26.0; Swift 6 language mode; `SWIFT_STRICT_CONCURRENCY = complete`;
  module-wide `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`. No `#available` gating needed.
- **8 pre-existing** Swift-6 concurrency warnings (RatingsFetcher ×6, GameCenter ×1, Quiz ×1) are
  expected — do not introduce new ones.
- SwiftUI deprecation-warning count is **0** — keep it at 0.
- **99 tests pass** — keep them green.
- Keep the working tree **uncommitted** unless told otherwise (the project's standing instruction).

**Verification (do this for every part)**
- Use the `ios-build-verify` skill / repo scripts (`build_app.sh`, `run_tests.sh`, `launch_app.sh`,
  `describe-ui`) on **iPhone 17 / iOS 26** (the target the phase docs used).
- Re-run the `CLAUDE.md` verify flows and compare to `phase0-baseline.md` /
  `phase6-verification.md` / `phase7-*.md`. Key anchors: `verb_browse_sort` (launch →
  VerbBrowseView) and `input_quiz_conjugation` (quiz question UI), plus quiz-completion → Results.
- Note: SourceKit shows spurious "Cannot find X in scope" diagnostics on edited view files
  (same-module symbols). `build_app.sh` is authoritative — a clean build means it compiles.
- Write each part's result in a short `phase8-*.md` note mirroring the existing phase docs.

---

## Part 1 — Issue #23 (the last open audit issue): `Spacer().frame(height:)` → stack spacing / padding ✅ DONE

**Severity:** Low · **Effort:** S–M (layout-sensitive) · **Files:** `Views/QuizView.swift`,
`Views/ModelView.swift`, `Views/QuizResultsView.swift`, `Views/QuizResultView.swift`.

**Status — done (Phase 8, Part 1).** Full write-up in `phase8-part1-verification.md`. All **15**
inter-element `Spacer().frame(height:)` no-ops across the four files were replaced with the adaptive
`VStack(spacing:)` / `.padding(...)` idiom; `grep -rn -B1 "\.frame(height:" Conjuguer/Views | grep
-A1 "Spacer()"` now returns nothing. `Spacer()` remains only as flexible space (vertical fillers,
horizontal `HStack` alignment). Build clean (0 deprecation, no new concurrency warnings), 99 tests
pass, and every designed gap was reproduced to sub-pixel via `describe_ui.sh` AX-frame tables.

### What was done, per file
- **`QuizView.swift`** — uniform 8-pt gaps → `VStack(alignment: .leading, spacing: Layout.defaultSpacing)`,
  all 9 fixed spacers deleted; the trailing not-started spacer → `.padding(.bottom, Layout.defaultSpacing)`
  on the Start-button `HStack`.
- **`ModelView.swift`** — content `VStack` → `spacing: 0`; the four 16-pt section breaks → `.padding(.top,
  Layout.doubleDefaultSpacing)` on the Défective / Endings / Verb(s)-Using headings and `.padding(.bottom,
  Layout.doubleDefaultSpacing)` on the last ending row (the unconditional break before the optional
  Stem-Alterations section).
- **`QuizResultsView.swift`** — heading + summary rows grouped in an inner `VStack(spacing: 0)` with the
  24-pt break as `.padding(.top, Layout.tripleDefaultSpacing)` on Score; the outer `VStack` keeps default
  spacing so the summary→`List` gap is preserved.
- **`QuizResultView.swift`** — trailing per-row spacer → `.padding(.bottom, Layout.defaultSpacing)` on the
  row `VStack`.

### Key learning (for the remaining parts and any future spacer work)
A `Spacer().frame(height: X)` renders a gap of **exactly X** because the spacer node suppresses the
VStack's default spacing around it. That default is **not uniformly 0** here: it is 0 between same-font
rows but **non-zero (~7–14 pt, font-pair-dependent)** between mismatched label fonts
(`headingLabel`/`bodyLabel` ↔ `subheadingLabel`). So a bare `.padding(.top, X)` *stacks on top of* the
default and over-spaces — `QuizView`'s body text is fine with plain `VStack(spacing:)`, but
`ModelView` / `QuizResultsView` needed `spacing: 0` on the stack crossing the font boundary for the
paddings to land at their nominal heights. Verified with defective (`conjuguer://model/2-5`) and
parented (`conjuguer://model/2-4`) models in addition to `être`.

---

## Part 2 — Refinements prior sessions deferred with rationale (optional polish)

These are documented sub-scopes of already-implemented issues, not new audit findings. Each is
optional; pick by appetite.

### 2a. Info-article Dynamic Type (from #8 / #12 — see `phase5-verification.md` note 1)
**Problem.** The #8 `TextView` fix removed the `uiView.font = preferredFont(.body)` override so the
Info articles render their designed WorkSans per-run typography (centered subheadings, real bold).
The trade-off, flagged at the time: those article fonts are now **fixed-size and no longer scale
with Dynamic Type**. There is no `UIFontMetrics` anywhere in the app today (grep-verified).
**Fix.** Scale the article fonts while keeping their design: wrap the `UIFont`s used in
`String.attributedText` (`Fonts.body` / `Fonts.subheading` / `Fonts.boldBody`) in
`UIFontMetrics(forTextStyle:).scaledFont(for:)`, and/or set `adjustsFontForContentSizeCategory = true`
on the `UITextView` in `TextView.makeUIView`. Preserve the per-run colors/weights and the link
styling.
**Done when.** Info articles scale with Dynamic Type yet keep their designed typography; build /
tests / verify green; spot-check an article (e.g. Terminology) at default and at an accessibility
size.

### 2b. Reconsider the `dynamicTypeSize(...xLarge)` cap (#12 — `Modifiers.swift:183`)
**Problem.** `ConstrainedBodyLabel` (`Modifiers.swift:178`) caps Dynamic Type at `.xLarge`
(`.dynamicTypeSize(...DynamicTypeSize.xLarge)`) to protect the quiz layout. The audit asked to
*reconsider* whether this app-wide-ish cap is necessary. (Note: the custom fonts already scale on
their `relativeTo:` curves up to this cap — #12 is done; this is only the cap review.)
**Fix.** Audit which screens genuinely need the cap. If only the quiz conjugation field / layout
breaks at large sizes, **scope the cap to that view** and let everything else scale to the full
accessibility range — or raise the cap. Verify the quiz layout (and `QuizResultsView`) at AX5
(`accessibility5`) doesn't clip or overlap.
**Done when.** The cap is applied only where a layout actually requires it; other text scales
further; no clipping at AX5 on the quiz path; build / tests / verify green.

### 2c. Uniform nav tint via `.toolbarBackground` (#21 — see `phase6-verification.md` note 1)
**Problem.** #21 removed the hard-coded opaque `UINavigationBar.appearance().backgroundColor`, so
the three browse screens' nav bars now render as bare iOS-26 Liquid Glass (the nav region reads
slightly lighter than the content). That is the direction #21 prescribes; whether a *uniform*
`customBackground` nav is preferred is an aesthetic call left open. No `.toolbarBackground` is used
today (grep-verified).
**Fix (only if a uniform tint is wanted).** Add
`.toolbarBackground(Color.customBackground, for: .navigationBar)` + `.toolbarBackground(.visible, for: .navigationBar)`
to `VerbBrowseView` / `ModelBrowseView` / `InfoBrowseView`. This is the issue's suggested
"prefer `.toolbarBackground` / `.tint`" option.
**Done when.** A deliberate decision is recorded — either keep the glass (do nothing, note it) or
apply a uniform `.toolbarBackground` across the three browse screens; build / tests / verify green.

### 2d. Cold-launch deep-link buffer (#28 — see `phase7-part2-verification.md` Notes)
**Problem.** Now that the 6,314-verb parse runs asynchronously behind `LoadingView`, a deep link
that arrives **during** the sub-second load reads still-empty stores: `handleURL` switches the tab
but the target sheet isn't pre-populated (nil lookup, no crash). `.onOpenURL` is already on the
always-present container so the URL isn't dropped — only its payload is too early. There is no
pending-URL buffer today (grep-verified). (For reference, one of the original six runs implemented
exactly this buffer.)
**Fix.** In `ConjuguerApp`, if `verbData.state != .loaded` when a URL arrives, stash it in
`@State private var pendingURL: URL?` instead of calling `handleURL`; replay it through
`Current.handleURL(_:)` once `state` becomes `.loaded` (then clear it). Keep the normal
already-loaded path calling `handleURL` directly.
**Done when.** A cold-launch `conjuguer://verb/<x>` (delivered while loading) presents the verb
sheet once data is ready; the warm path is unchanged; build / tests / verify green.

---

## Notes

- **Already done, do not redo:** #27 (`@Environment(World.self)` injection) and #18 (self-contained
  `#Preview`s via `PreviewSupport.bootstrap()`). You *could* extend previews to more screens
  (`QuizView`, the browse views), but it isn't required by the audit.
- **`ModelView` `.sheet` design:** its two presentations were intentionally collapsed into one
  `DetailSheet` enum because they are mutually exclusive. `InfoBrowseView` keeps **two**
  `.sheet(item:)` on purpose (it needs verb-on-top-of-info stacking — see its inline comment).
  Don't "consolidate" InfoBrowseView.
- Part 1 (#23) is **done** (`phase8-part1-verification.md`); the original audit list is fully closed.
  Parts 2a–2d are all that remain — genuinely optional and partly aesthetic — get a human decision on
  2c before doing it.
