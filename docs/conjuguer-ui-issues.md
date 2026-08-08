# Conjuguer UI / Design — Unified Recommendation List

_Synthesized from six independent UI-audit runs (3 High-effort: `h1`–`h3`; 3 Max-effort: `m1`–`m3`, in `outputs/ui/`). Union of every distinct recommendation raised, ranked by impact, greatest to least. **No code was changed.** Each run drove the live app on iPhone 17 / iOS 26 via `ios-build-verify` and reviewed the view layer through the `ios-design-agent-skill` five-pillar lens. The app already ships a real design system — a custom **Work Sans** family, a five-color light/dark palette, and the signature **red-ending conjugation coding** — so almost every item below is an *extension* of that system, not a replacement._

**"Runs" column** = how many of the six audits raised it (of 6). Higher count ≈ higher confidence / broader consensus. **✅ Verified** = checked against the live source during synthesis (see `findings/3.md` → *Verification against source*). Impact ≈ (time-on-screen) × (severity) × (inverse implementation cost); the **Quiz is the core loop** and weighs heaviest.

> **Locating each item:** anchors are given as **file + symbol** (type / function / modifier / property names and distinctive snippets), *not line numbers* — so they stay valid as the code shifts while sessions work through this list (several items touch the same file, so line numbers would rot mid-session). `grep` the named symbol to jump to the current site.
>
> **Keep this file's anchors current (instruction to implementing sessions):** if you rename, move, or delete a symbol that an anchor above points to (a type, function, modifier, property, `L.*` key, SF Symbol string, or snippet), **update the affected anchor(s) in this file in the same change** so they keep resolving. When a fix resolves an item, **mark it done** — prepend `✅ DONE —` to its heading; **never delete a resolved item.** The list then doubles as a running tally of what's been accomplished. Sessions are not run in parallel, so you are free to edit this file directly.

> **Foundations first.** Five items are shared primitives that several others depend on — a `customSurface` color + `.card()` modifier (#9), a brand-colored title modifier (#12), a `customGreen` "correct" color (#23), a centralized `.sensoryFeedback` hook (#4), and a numeric text style (#5). Building these first (Batch A) keeps everything downstream DRY. The batch plan at the end sequences accordingly.

---

## Status (reconciled 2026-08-08)

**29 of 30 items are done; 1 is open and 1 is partially done.** The batches were implemented but
nobody marked the list as they went, so this file read as fully open for weeks. Reconciled by
reading the current source view-by-view (not by trusting session notes).

- **Done: #1–#25, #27, #28, #29** — each carries a `**Shipped:**` line naming the symbol that
  resolves it, so the claim is checkable.
- **Open: #26** (browse header/content seam). Its stated cause no longer exists — the
  `Modifiers.modifyAppearances()` appearance proxy was deleted by the separate SwiftUI-modernization
  audit (its issue #21), so the nav bar is now bare iOS-26 Liquid Glass. Whether to impose a uniform
  `.toolbarBackground(Color.customBackground, …)` is an unresolved **aesthetic decision**, tracked in
  parallel as Part 2c of [`future-swiftui-fixes.md`](future-swiftui-fixes.md). Decide once, resolve both.
- **Partial: #30** (atmosphere bundle) — 3 of 5 sub-items shipped; see the item for which two remain.

Two anchors in the original text pointed at symbols that no longer exist (`ConstrainedBodyLabel`,
`TextView.swift`). Per this file's own instruction they have been updated in place, with the
supersession noted.

---

## 🔴 High impact

### ✅ DONE — 1. The quiz answer field is visually invisible → give it a surface + focus ring
**`QuizView.swift`** — the `TextField(L.QuizView.conjugation…)` bound to `conjugationFieldIsFocused` · Runs: 6/6 · ✅ Verified
The single most-used control in the app is a bare, borderless `TextField` — on screen it's just the gray placeholder "Conjugation" and a cursor, the *least* visible element on the densest screen. **Fix:** filled, rounded container (`Color.customForeground.opacity(~0.06)` in a `RoundedRectangle(cornerRadius: 12)`) with a focus-tinted border (`customBlue`/`customRed` when `conjugationFieldIsFocused`, gray otherwise). The focus ring doubles as a "field is live" cue for the auto-focus that `start()` already sets.
**Shipped:** `QuizView.answerField` — exactly the prescribed fill (`customForeground.opacity(0.06)`, radius 12) plus a `.strokeBorder` ring that goes `customBlue` at 2 pt when focused and `customGray.opacity(0.4)` at 1 pt otherwise, animated with a 0.15 s `easeInOut`.

### ✅ DONE — 2. Give the quiz *question* a hierarchy distinct from the *metadata*
**`QuizView.swift`** — the `questionBlock` / `statusStrip` computed properties in the `quizState == .inProgress` branch · Runs: 5/6 (not h2)
Verb / Translation / Pronoun / Tense — plus Progress / Score / Elapsed — are seven near-identical `constrainedBodyLabel()` rows; nothing signals *what to produce*. **Fix:** make the verb the hero (heading weight), fold the grammatical ask (pronoun · tense) into one emphasized line, demote the translation to a subtitle, and push Progress/Score/Elapsed into a single compact, de-emphasized status strip.
**Shipped:** the flat row stack is now three named blocks. `questionBlock` renders the infinitive at `largeTitleFont`, the translation at `.smallLabel()`, and one combined ask line (`"\(pronoun) · \(tense)"`) at `buttonFont`; `statusStrip` collapses progress / score / elapsed into one `.smallLabel()` `HStack` under the progress bar. (Anchor updated: `.constrainedBodyLabel()` no longer exists anywhere — see #24.)

### ✅ DONE — 3. Fill the barren "not started" quiz screen
**`QuizView.swift`** — the `notStartedBriefing` builder in the `quizState == .notStarted` block · Runs: 6/6 · ✅ Verified
~85–90% of the marquee screen is empty — a corner title and a small Start button pinned above the tab bar. **Fix:** a centered briefing — one-line description, the active difficulty (`world.settings.quizDifficulty`), "30 questions," and the best score (Game Center is wired) — with Start composed into it as a clear primary CTA rather than a stray button.
**Shipped:** `notStartedBriefing` — a `graduationcap.fill` glyph, the `L.QuizView.briefing` one-liner, and a `.card()` of three `Label`s (difficulty · question count · best score), with Start composed in as the CTA. **The best-score readout shipped too**, but *not* via the Game Center read that [`quiz-best-score-followup.md`](quiz-best-score-followup.md) specced: `Quiz.swift` persists the high score locally to `Settings.bestScore`, and the briefing shows `L.QuizView.bestScore(world.settings.bestScore)` when it's above 0 — no `GameCenter` protocol change was needed.

### ✅ DONE — 4. Add haptics and make answer feedback unmissable
**`QuizView.swift`** (the `.sensoryFeedback(trigger: quiz.quizResults.count)` and the `feedbackSlot` builder), **`Models/Quiz.swift`** (`quizResults`, `previousIncorrectAnswer`) · Runs: 6/6 · ✅ Verified (0 haptics today; sounds *do* exist)
There is **no haptic feedback anywhere** (0 `sensoryFeedback`). Note the app *already* plays per-answer **sounds** and speaks questions, so the gap is **tactile + visual**, not feedback in general. **Fix:** `.sensoryFeedback(.success, trigger: quiz.numberCorrect)` and an error feedback keyed to `quiz.previousIncorrectAnswer` (note: there is **no** `numberIncorrect` property — wire the error trigger to `previousIncorrectAnswer`); add a brief `checkmark.circle.fill`/`xmark.circle.fill` symbol flash and reserve a fixed-height slot so inserting the feedback lines doesn't shove the question upward.
**Shipped:** one `.sensoryFeedback` closure triggered by `quiz.quizResults.count` returns `.success` or `.error` depending on whether `previousIncorrectAnswer` is nil — cleaner than the two-trigger sketch, since it fires exactly once per submission. `feedbackSlot` reserves a fixed `feedbackSlotHeight` (64 pt) so the question never jumps, and flashes the result icon with `.symbolEffect(.bounce, value: quiz.quizResults.count)`.

### ✅ DONE — 5. Stabilize and animate the changing numbers (+ a progress bar)
**`QuizView.swift`** — the `statusStrip` counts; **`Utils/Modifiers.swift`** (`NumericText` / `.numericText()`) · Runs: 6/6 · ✅ Verified (0 monospaced/numeric-text today)
Score, progress, and the per-second elapsed timer use proportional Work Sans digits, so the layout jitters as they tick. **Fix:** `.contentTransition(.numericText())` on the changing counts (font-agnostic — preferred, since Work Sans may not ship tabular figures, so plain `.monospacedDigit()` can be a no-op); replace the "1 / 30" text with a real `ProgressView(value:)` bar.
**Shipped:** a shared `.numericText()` modifier (`.monospacedDigit()` + `.contentTransition(.numericText())`) applied to the progress count, score, and elapsed timer, each with a `.snappy` animation; the strip is headed by a real `ProgressView(value:total:)` tinted `customBlue`. The modifier is reused on the results hero score (#7) and the Settings version footer.

### ✅ DONE — 6. Fix the Start button truncating at large Dynamic Type ("Star" / "Sta…")
**`QuizView.swift`** — `startButton` (`Button(L.QuizView.start)` with `.buttonLabel()` + the gated `.phaseAnimator([1.0, 1.1])`) · Runs: 3/6 (Max only) · ✅ Verified (structure: no `lineLimit`/`minimumScaleFactor`)
At accessibility text sizes the `.buttonLabel()` font scales but the glass capsule doesn't reflow, and the `phaseAnimator` 1.0→1.1 scale pushes the label past the edge, clipping "Start." A real accessibility defect that **no High run caught** (none exercised AX sizes). **Fix:** `.lineLimit(1).minimumScaleFactor(0.7)` (or `.fixedSize()` so the capsule grows) on the Start label.
**Shipped:** `.lineLimit(1).minimumScaleFactor(0.7)` on the Start label, and the same pair on the Quit button in `titleRow` (which had the identical exposure). The contributing pulse is now Reduce-Motion-gated — see #25.

### ✅ DONE — 7. Make the Quiz Results feel like a result — hero score, semantic correctness color, labeled answers
**`QuizResultsView.swift`** (the `scoreFont` hero numeral), **`QuizResultView.swift`** (`conjugationResult.feedbackIconString` + `.feedbackColor`) · Runs: 5/6 (hero) · 4/6 (icon/labels) · ✅ Verified
The payoff for 30 questions: the score is a plain `bodyLabel()` line; each result row is **center-aligned**, stacks the correct answer over the user's with **no labels**, and marks correctness with a **gray** ✓/✕ for *both* outcomes — the weakest possible signal. **Fix:** promote the score to a large `workSansSemiBold` numeral with `.contentTransition(.numericText())`; color the icon (`isCorrect ? customBlue/customGreen : customRed`); left-align rows; label the two answers ("Your answer" / "Correct").
**Shipped:** the score is a `scoreFont` `customBlue` numeral under a small "Score:" caption, with `.numericText()` and `.lineLimit(1).minimumScaleFactor(0.5)`, addressable as `results_score`. Rows are leading-aligned and labeled via `L.ResultsView.yourAnswerWithColon` / `.correctWithColon` (gray prefix, `mixedCaseString` value). Correctness color/icon moved onto the model as `ConjugationResult.feedbackColor` / `.feedbackIconString` — one source of truth shared by the results row and the in-quiz `feedbackSlot` (#4). (Anchors updated: the old `iconString` + `.foregroundStyle(Color.customGray)` pair is gone.)

### ✅ DONE — 8. Lay conjugation data out in real columns
**`VerbView.swift`** (`TenseSectionView`), **`ModelView.swift`** (`endingsCard`, `endingSlots(_:)`, `Self.gridPronouns`) · Runs: 6/6 (2 partial) · ✅ Verified (structure)
Conjugations — the product — render as a left-aligned single column using ~40% of the width; `ModelView`'s endings are space-separated runs with **no pronoun labels** (`Ind. Présent: s s t * * *`), legible only if you already know the six-slot order. **Fix:** render each tense as a two-column `Grid` (pronoun \| form), keeping the red-ending `AttributedString` in the form cell. (Requires splitting `VerbConjugations.Cell` into `pronoun` + form-only `display` — done once, reused by both screens.) For `ModelView`, add a fixed `je tu il nous vous ils` header row.
**Shipped:** `VerbConjugations.Cell` was split as prescribed; `TenseSectionView` renders a `Grid` of `GridRow`s (pronoun at `.smallLabel()` and `accessibilityHidden`, form at `bodyFont` carrying `cell.accessibility`). `ModelView.endingsCard` builds a six-column `Grid` behind a horizontal `ScrollView`, with the fixed `je tu il nous vous ils` header row (`Self.gridPronouns`) and a full-width tense label row (`gridCellColumns`) above each ending row; empty slots render `_` via `endingSlots(_:)`.

### ✅ DONE — 9. Introduce surface depth — a reusable `.card()` + a `customSurface` token  ⭐ *foundation*
**`Utils/Modifiers.swift`** (`Card` / `.card(accent:)`), **`Utils/ColorExtension.swift`** (`customSurface`) **+ `Assets.xcassets`** · Runs: 6/6 · ✅ Verified (0 cards/shadows/materials)
Everything floats on one flat `customBackground`; there is zero elevation, grouping, or rhythm. **Fix:** add one `customSurface` colorset (light + dark, e.g. `customForeground` at ~4–5% over the background) and a `.card()` modifier (padding + `RoundedRectangle` + optional leading accent bar). This single primitive unlocks #7, #11, #15, #18 and the detail-screen grouping.
**Shipped:** `Color.customSurface` colorset plus `.card(accent: Color? = nil)` — padding, `customSurface` fill, continuous 12-pt corners, and the optional 4-pt leading accent bar. It is now the app's most-reused primitive: `VerbView`, `ModelView`, `SettingsView`, `QuizView`, `InfoBrowseView`, and both browse grids.

---

## 🟠 Medium impact

### ✅ DONE — 10. Document the red/blue conjugation color code
**`VerbView.swift`** — `colorKey` / `colorKeySwatch(color:label:)`, gated on `@AppStorage("hasSeenConjugationColorKey")` · Runs: 5/6 (not h3)
The app's best idea — endings/irregular stems in `customRed` — is unexplained at the point of use; a newcomer just sees colored letters. **Fix:** a compact, dismissible inline legend on first conjugation view (`@AppStorage` "seen" flag), or a short "How to read conjugations" Info article linked from the existing "Irregularities" entry.
**Shipped:** the inline-legend option. `VerbView.colorKey` is an accent-barred `.card(accent: .customBlue)` with a title, an explanation, and two labeled swatches (blue = regular, red = irregular), dismissed by an `xmark.circle.fill` button that sets `hasSeenColorKey` — so it appears once and never again.

### ✅ DONE — 11. Settings: unify alignment, unify header color, group into cards
**`SettingsView.swift`** (`settingCard(title:content:)`), **`Utils/Modifiers.swift`** · Runs: 6/6 (alignment) · 5/6 (color) · ✅ Verified
The title is leading-aligned but the section headers are **centered** (they're bare `Text` children of a `ScrollView`, which centers); two headers use `settingsSubheadingLabel()` (**blue**) and "Ratings and Reviews" uses `subheadingLabel()` (**gray**) for the same role. **Fix:** wrap the scroll content in `VStack(alignment: .leading) { … }.frame(maxWidth: .infinity, alignment: .leading)`; use one header modifier (one color) for all three; wrap each setting + its description in `.card()` (#9).
**Shipped:** all three fixes, via one `settingCard(title:content:)` builder that every section now goes through (difficulty, pronoun gender, app icon, ratings, onboarding, game) — a single `.subheadingLabel()` header color, leading alignment from the enclosing `VStack(alignment: .leading)` + `.frame(maxWidth: .infinity, alignment: .leading)`, and `.card()` grouping. The divergent `settingsSubheadingLabel()` modifier was deleted. A quiet `aboutFooter` (wordmark + version, `.numericText()`) was added below the cards.

### ✅ DONE — 12. Unify the screen-title color — bake the brand color into the title modifier  ⭐ *foundation*
**`Utils/Modifiers.swift`** (`HeadingLabel`, `HeadingForegroundLabel`) · Runs: 2/6 (Max) · ✅ Verified
`headingLabel()` sets the font + `.isHeader` but **no color**, so `VerbView`/`ModelView` titles render black/primary while `QuizView`/`SettingsView`/`QuizResultsView` add `.foregroundStyle(Color.customBlue)` at the call site — the brand blue drifts screen to screen. (The High runs flagged a *different* title inconsistency — hand-rolled `Text` vs real `navigationTitle` — also worth a pass.) **Fix:** add `.foregroundStyle(Color.customBlue)` inside `HeadingLabel`; split the few in-content uses that intentionally want foreground color (e.g. the model exemplar) into a separate modifier.
**Shipped:** exactly the prescribed split — `HeadingLabel` now sets `customBlue`, and the deliberate foreground-colored uses moved to a new `headingForegroundLabel()` (used by `InfoView`'s in-content article heading). The call-site `.foregroundStyle(Color.customBlue)` duplicates are gone.

### ✅ DONE — 13. Verbs list: add information scent and fix the system-font inconsistency
**`Views/BrowseRow.swift`** (`BrowseRow` — `title` / `subtitle` / `Badge`), used by **`VerbBrowseView.verbRow(_:)`** and **`ModelBrowseView`** · Runs: 4/6 (scent) · 1/6 (font, m3 only) · ✅ Verified (font)
The most-visited list shows 6,320 verbs as bare infinitives — no translation, no frequency cue. Separately, the row `Text` has **no font modifier**, so unlike `ModelBrowseView` (which uses `.tableText()`) the Verbs list silently renders in the **system font**, breaking the app's own type identity. **Fix:** a two-line cell — infinitive in Work Sans (French) over translation (de-emphasized, English) — which restores the brand font *and* adds scent; optionally a trailing frequency-rank badge when `verb.frequency != nil`.
**Shipped:** everything including the optional badge, extracted into a shared `BrowseRow` view so the Verbs and Models lists can't drift again. Infinitive at `.tableText()` (Work Sans, French locale) over translation at `.smallLabel()` (English locale), with a trailing `Capsule` rank badge (`#\(frequency)`, `customBlue`) when a frequency exists.

### ✅ DONE — 14. Fix Dynamic Type fragmentation in detail metadata rows
**`VerbView.swift`** — `metaRow(_:_:)` and `modelReferenceText(_:)` · Runs: 3/6 (Max only) · ✅ Verified (structure)
"Model: être (5-26)" and "Auxiliary: avoir" are `HStack`s of three separate `Text` views; at accessibility sizes they shatter (the label splits from its colon, the id wraps alone). The sibling single-`Text` "Frequency:" row wraps fine — proof only the multi-`Text` horizontal layout breaks. **Fix:** concatenate each row into one `Text` (wraps as one flow) or use `ViewThatFits`/`LabeledContent` to fall back to vertical.
**Shipped:** the concatenation option. `metaRow(_:_:)` builds one `Text` from an `AttributedString` (gray prefix + foreground value) and serves both the Auxiliary and Frequency rows; `modelReferenceText(_:)` does the same for the Model row, folding even its trailing chevron into the single `Text` so the whole reference wraps as one flow. The multi-`Text` `HStack`s are gone.

### ✅ DONE — 15. Models: badge the irregularity and lighten the heavy detail header
**`ModelBrowseView.swift`** (`irregularityBadge(percent:)` + `ModelAndDecorator.irregularityBadge`), **`ModelView.swift`** (`headerCard`) · Runs: ~5/6 · ✅ Verified
The list appends "• 78%" as plain inline text; the detail header stacks five `headingLabel()`-weight lines (exemplar, id, Parent, description) into a heavy black slab. **Fix:** render the irregularity as a tinted `Capsule` badge (in the list and/or as the detail header), and demote "Parent" to a subheading so the headword stands alone.
**Shipped:** both. The `" • \(irregularity)%"` string decorator became a real trailing `BrowseRow.Badge` (tinted `Capsule`, with its own VoiceOver label "N% irregular"), attached only in the irregularity sort order. `ModelView.headerCard` now keeps `headingLabel()` for just the exemplar + id on one baseline-aligned row, demotes the description to `.bodyLabel()` and Parent to `.smallLabel()`, and wraps the lot in a `.card()`.

### ✅ DONE — 16. The Quiz Results sheet has no Done button
**`QuizView.swift`** — the `.sheet(isPresented: $quiz.shouldShowResults)` presenting `QuizResultsView().sheetDismissable()` · Runs: 2/6 (Max) · ✅ Verified
Unlike the app's other sheets, `QuizResultsView` is presented **without** `.sheetDismissable()`, so it has no "Done" — dismissal is swipe-only, which isn't discoverable. **Fix:** wrap the results content in `.sheetDismissable()` (the existing modifier supplies a NavigationStack + Done) or add a toolbar Done.
**Shipped:** `.sheetDismissable()` on the presented `QuizResultsView`, matching every other sheet in the app.

### ✅ DONE — 17. Make the `Model:` reference in `VerbView` tappable
**`VerbView.swift`** — `modelRow(_:)` → the `DetailSheet.model` case · Runs: 2/6 (Max) · ✅ Verified
The verb screen shows "Model: être (5-26)" as plain text even though there's a whole Models browser and `ModelView` already deep-links *out* to verbs — a one-way street. **Fix:** make the model a `NavigationLink`/deep link so users can jump verb → its model and back.
**Shipped:** the row is a plain-styled `Button` that sets `detailSheet = .model(model)`, presenting `ModelView` in a dismissable sheet — closing the verb ⇄ model loop. It reads as tappable via the blue value + trailing chevron (#14/#29) and carries `L.VerbView.modelButtonHint` for VoiceOver.

### ✅ DONE — 18. Group tense sections (and metadata) into cards
**`VerbView.swift`** (`TenseSectionView`, `overviewCard`, `personlessCard`, `etymologyCard(_:)`, `exampleCard(_:)`), **`ModelView.swift`** (`headerCard`, `endingsCard`, `stemAlterationsCard(_:)`, `verbsUsingCard`) · Runs: 4/6 · depends on #9
Tense blocks stack with only a colored subheading between them, so a long verb reads as one dense ribbon. **Fix:** wrap each `TenseSectionView` and the Overview metadata block in `.card()` (#9), optionally with a thin gradient rule or leading accent bar between sections.
**Shipped:** `.card()` on every `TenseSectionView` (simple and compound) and on the Overview block — and the pattern went further than the item asked, with the etymology, example, personless, and all four `ModelView` sections carded too. The optional gradient rule was not used; the accent bar is reserved for the color key (#10).

### ✅ DONE — 19. Animate sort changes and list re-sorts
**`VerbBrowseView.swift`, `ModelBrowseView.swift`** — the `.onChange(of: store.sort)` calling `updateSearchResults` · Runs: 3/6
Flipping the segmented sort replaces the whole list instantly. **Fix:** wrap the `searchResults` reassignment in `withAnimation(.snappy)`; add `.sensoryFeedback(.selection, trigger: store.verbSort)` so the reorder reads as causal.
**Shipped:** both, on both browse screens — `withAnimation(.snappy) { updateSearchResults(playSoundIfEmpty: false) }` plus `.sensoryFeedback(.selection, trigger: store.sort)`. (Anchor updated: the per-screen `verbSort`/`modelSort` state was since unified into a generic `BrowseStore.sort`.)

### ✅ DONE — 20. Fix the `timeString` sub-minute format ("34" vs "1:39")
**`Utils/IntExtension.swift`** — `timeString` (the sub-minute `else` branch) · Runs: 3/6 (Max) · ✅ Verified
Under a minute, `timeString` returns bare seconds (`"%d"`), so the in-quiz timer reads "Elapsed: 34" while the results screen reads "Time: 1:39" — two formats for the same quantity. (Both screens already call `.timeString`; the fix is the formatter, not the call sites.) **Fix:** return `"0:%02d"` in the `else` branch so both read as elapsed time.
**Shipped:** the `else` branch returns `String(format: "0:%02d", remainingSeconds)`, so both readouts agree.

### ✅ DONE — 21. Section the Info browse list
**`InfoBrowseView.swift`** — `infoCollection` over `Info.sections`; **`Models/Info.swift`** (`Info.Category`) · Runs: 3/6 (Max-leaning)
20+ topics sit in one flat list mixing app-meta (Dedication, Value Proposition), concepts (Terminology, Irregularities), and per-tense explainers. **Fix:** a grouped `List` with `Section("About") / Section("Concepts") / Section("Tenses")` so the tense references are findable.
**Shipped:** an `Info.Category` grouping drives `Info.sections`, rendered as real `Section`s with `.subheadingLabel()` headers in the compact `List` and as titled `LazyVGrid` groups in the regular-width layout. The Tutor row is slotted into the Concepts section in both layouts.

### ✅ DONE — 22. Info articles: constrain reading width + confirm the body typeface
**`InfoView.swift`** (the `.frame(minWidth: 0, maxWidth: 680)` on `RichTextView`), **`Views/RichTextView.swift`** · Runs: 4/6 (width) · 1/6 (font, h3)
Long-form text runs edge-to-edge (fine on iPhone, too wide on iPad/large type). `h3` also suspects the `UITextView`/`NSAttributedString` body renders in the *system* font rather than Work Sans — worth confirming, since `m2`/`m3` praised the articles as a strength. **Fix:** `.frame(maxWidth: 680)` centered; verify the attributed-string builder sets `Fonts.body` explicitly; a touch more `lineSpacing`.
**Shipped:** the `maxWidth: 680` reading measure is in place. The font question was settled by deletion rather than verification — the whole `UITextView`/`NSAttributedString` pipeline (`TextView.swift`, `String.attributedText`) was retired in favor of a native SwiftUI `RichTextView` that composes `Text` runs in the app's own fonts, so the system-font risk `h3` suspected no longer has a mechanism. (Anchor updated: `TextView.swift` no longer exists.)

### ✅ DONE — 23. Disambiguate the overloaded red; add a `customGreen` "correct"  ⭐ *foundation*
**`Utils/Modifiers.swift`** (`FunButton`), **`Utils/ColorExtension.swift`** (`customGreen`), **`Models/ConjugationResult.swift`** (`feedbackColor`) · Runs: 3/6 · ✅ Verified
`customRed` simultaneously means primary CTA (Start), destructive (Quit), benign link (Rate or Review), *and* error (wrong answer / irregular endings) — `FunButton` tints all buttons red. One color carrying four meanings dilutes all of them. **Fix:** reserve red for error/destructive; give primary CTAs a `customBlue`/primary tint; add a `customGreen` colorset (light + dark) so "correct" has its own semantic, freeing red to mean "wrong/irregular."
**Shipped:** `FunButton` now takes `tint: Color = .customBlue`, so buttons are blue by default and red is passed explicitly only where it means destructive (`Quit`). `Color.customGreen` was added and is surfaced through `ConjugationResult.feedbackColor`, giving "correct" its own semantic in the quiz feedback slot and the results rows; red is left to mean wrong / irregular.

### ✅ DONE — 24. Reconsider the `xLarge` Dynamic Type cap on quiz text
**`Utils/Modifiers.swift`** — the cap and its `ConstrainedBodyLabel` modifier have been **removed**; no `.dynamicTypeSize(…)` clamp remains anywhere in the app · Runs: 1/6 (h2) · ✅ Verified
`constrainedBodyLabel()` caps Dynamic Type at `.xLarge`, so low-vision users on the largest accessibility sizes get smaller-than-requested quiz text. The cap exists to protect the current fixed layout. **Fix:** once the quiz adopts a scrollable card layout (#1–#5), raise or remove the ceiling so the core learning screen honors the user's full text-size preference.
**Shipped:** removed outright, in the sequence the item prescribed. The Batch B rework made the quiz scrollable (`inProgressContent` and the not-started briefing are both `ScrollView`s), which removed the layout pressure the cap existed to relieve; `ConstrainedBodyLabel` and every `constrainedBodyLabel()` call site were then deleted. A repo-wide grep for `dynamicTypeSize` now returns nothing, so all text honors the user's full accessibility range. This also closes Part 2b of [`future-swiftui-fixes.md`](future-swiftui-fixes.md), which had the same cap open as a "reconsider" item.

---

## 🟡 Low impact (polish)

### ✅ DONE — 25. Reconsider/soften the Start pulse and gate it on Reduce Motion
**`QuizView.swift`** — `startButton`'s `.phaseAnimator([1.0, 1.1])`, gated on `@Environment(\.accessibilityReduceMotion)` · Runs: 2/6 (Max) · ✅ Verified (no reduce-motion guard)
The lone animation is a continuous 1.0→1.1 `scaleEffect`, which reads as slightly nervous and contributes to the "Star" truncation (#6). (Note: `h1` considers the subtle pulse a *strength* — this is a judgment call.) **Fix:** gate the `phaseAnimator` behind `@Environment(\.accessibilityReduceMotion)`, and consider a calmer `.symbolEffect(.pulse)` on a lead glyph instead of scaling the button.
**Shipped:** the judgment call went to `h1` — the pulse was kept (it reads as a strength) but is now gated: `startButton` returns the bare button when `reduceMotion` is on and the `phaseAnimator` version otherwise. The `.symbolEffect(.pulse)` alternative was adopted elsewhere, on the Tutor row's `brain.head.profile.fill` glyph.

### 26. Remove the header/content background seam on browse screens
**`VerbBrowseView.swift`, `ModelBrowseView.swift`, `InfoBrowseView.swift`** — the `NavigationStack` + `.navigationTitle` + `.searchable` headers (the former `Modifiers.modifyAppearances()` appearance proxy has since been **deleted**) · Runs: 1/6 (m1) · ✅ Verified
The large-title/search header renders on the **system** background while the list uses `customBackground`, leaving a visible two-tone seam (the appearance proxy sets the bar's font/color but not its background). **Fix:** `.toolbarBackground(Color.customBackground, for: .navigationBar)` + `.toolbarBackgroundVisibility(.visible, …)`, or set the nav-bar background in `modifyAppearances()`.
**Status — open, pending an aesthetic decision (the only unresolved item).** The stated *cause* is gone: the separate SwiftUI-modernization audit (its issue #21) deleted the `UINavigationBar.appearance()` proxy entirely, so the nav bar is now bare iOS-26 Liquid Glass rather than a mismatched opaque fill. What remains is a genuine choice, not a defect — leave the glass (which is what iOS 26 prescribes, and the nav region reading slightly lighter than the content is intended) or impose a uniform brand tint with `.toolbarBackground(Color.customBackground, for: .navigationBar)` + `.toolbarBackground(.visible, …)` across the three browse screens. **This is the same open question as Part 2c of [`future-swiftui-fixes.md`](future-swiftui-fixes.md)** — decide once and close both. Neither modifier appears in the source today (grep-verified).

### ✅ DONE — 27. Move the Model help button inline with its heading
**`ModelView.swift`** — the `questionmark.diamond.fill` help `Button` in `stemAlterationsCard(_:)` · Runs: 1/6 (m1) · ✅ Verified
The help button is pushed to the far right by a `Spacer`, marooning it from the "Stem Alterations" heading it explains. **Fix:** `HStack(spacing: 6) { Text(…); helpButton; Spacer() }` so the affordance reads as attached.
**Shipped:** verbatim — `HStack(spacing: 6)` with the heading, the button, then the `Spacer`, so the affordance sits against the heading it explains.

### ✅ DONE — 28. Subtle scroll-transition fade on long reference lists
**`Utils/Modifiers.swift`** (`ScrollFade` / `.scrollFade()`), applied throughout **`VerbView.swift`, `ModelView.swift`** · Runs: 2/6 (h1, h3)
Rows hard-clip at the scroll edges. **Fix:** a restrained `.scrollTransition { c, p in c.opacity(1 - abs(p.value) * 0.12) }`; degrades gracefully under Reduce Motion.
**Shipped:** the exact 0.12 coefficient, extracted into a reusable `.scrollFade()` modifier that reads `@Environment(\.accessibilityReduceMotion)` and returns full opacity when Reduce Motion is on — so the graceful degradation is built into the primitive rather than each call site. Applied to every card in `VerbView` and `ModelView`.

### ✅ DONE — 29. Sharpen `key: value` typography — distinct prefixes, small-caps section labels
**`Utils/Modifiers.swift`** (`SubheadingLabel`), **`QuizView.swift`, `VerbView.swift`** (`metaRow(_:_:)`, `modelReferenceText(_:)`), **`QuizResultView.swift`** (`answerText(label:answer:)`) · Runs: 2/6 (h1, h3)
Structural prefixes ("Verb:", "Model:") share one style with their values; section labels signal hierarchy by size alone. **Fix:** render prefixes quieter (smaller, `customGray`); give `SubheadingLabel` `.smallCaps()` + slight tracking so section labels read as labels — a classic editorial device that suits the literary subject.
**Shipped:** both halves. `SubheadingLabel` is now `buttonFont.smallCaps()` with `tracking(0.5)` in `customGray`. Prefixes are demoted to `customGray` against a foreground- or blue-colored value wherever a `key: value` row survives — `VerbView.metaRow(_:_:)` and `modelReferenceText(_:)`, and `QuizResultView.answerText(label:answer:)` for "Your answer:" / "Correct:". (The quiz's own "Verb:" / "Tense:" prefixes disappeared entirely in #2's rework — the hierarchy now carries that meaning.)

### 🟡 PARTIAL — 30. Atmosphere & iconography micro-polish (bundle)
**various** · Runs: 1–2/6 each
A grab-bag of small, on-brand touches: round + soft-shadow the in-article images (`InfoView`); gradient separators instead of plain rules; `.symbolEffect(.bounce, value: selectedTab)` on tab selection; reconsider `key.fill` (Models) / `gearshape.2.fill` (Settings) glyphs (`MainTabView`); pair the `LoadingView` spinner with the wordmark; trim the dead vertical space above the large titles. Implement opportunistically alongside the batches they touch.
**Shipped (3 of 5):**
- **In-article images** — `InfoView` rounds them to a continuous 12-pt radius with a soft `customForeground.opacity(0.2)` shadow.
- **`LoadingView` wordmark** — the spinner is now paired with the Splash mark and a `largeTitleFont` "Conjuguer" in `customBlue`.
- **Dead vertical space** — the browse screens' hand-rolled title rows became real `.navigationTitle`s, and the remaining hand-rolled titles sit on a consistent `Layout.tripleDefaultSpacing` top inset.

**Still open (2 of 5), both deliberate judgment calls rather than oversights:**
- **Tab-selection `.symbolEffect(.bounce, value: selectedTab)`** — not applied in `MainTabView` (grep-verified). `.symbolEffect` is used elsewhere (the quiz feedback icon bounces, the Tutor glyph pulses), so this is a taste question about whether tab switching needs its own flourish.
- **Gradient separators** — not adopted; the app uses plain `Divider()` (one site, in `VerbView.chansonSection`) and relies on `.card()` surfaces for separation instead, which arguably makes rules redundant.
- The **`key.fill` / `gearshape.2.fill` glyph review** was a "reconsider," not a change request; both glyphs remain, which counts as the reconsideration having resolved in favor of the status quo.

---

## Proposed implementation batches

Sequenced so shared primitives land first, then the highest-traffic screen, then the payoff screen, then dense content, then cross-screen consistency, then polish. Batches B–D depend on A.

**All six batches are complete**, except the two judgment calls noted above (#26's uniform-tint decision in Batch F, and #30's two unadopted flourishes).

### ✅ Batch A — Foundations (build once, reuse everywhere)
> Low standalone UI change, but #7, #11, #15, #18 (cards) and #4, #7 (color/haptics) all lean on these.
- **#9** `customSurface` color + `.card()` modifier ✅
- **#12** brand-colored title modifier (`HeadingLabel` gets `customBlue`) ✅
- **#23** `customGreen` "correct" color + de-overload red ✅
- **#4** centralized `.sensoryFeedback` hook on the quiz ✅
- **#5** a shared numeric text style (`.contentTransition(.numericText())`) ✅

### ✅ Batch B — Quiz core loop (highest time-on-screen)
- **#1** visible answer field + focus ring ✅
- **#2** question hierarchy (verb hero, demoted status strip) ✅
- **#3** fill the not-started screen ✅
- **#6** Start-button truncation fix ✅
- **#4 / #5** wire haptics + visual feedback and stabilized numbers/progress bar into the loop ✅

### ✅ Batch C — Quiz results & correctness semantics
- **#7** hero score + colored correctness icon + labeled, left-aligned answers (uses `customGreen` from A) ✅
- **#16** add the Results-sheet Done button ✅

### ✅ Batch D — Core content (verb & model detail)
- **#8** two-column conjugation grid + labeled `ModelView` endings ✅
- **#18** cards on tense sections / metadata (uses `.card()` from A) ✅
- **#12** apply the unified title color (from A) to `VerbView`/`ModelView` ✅
- **#10** the red/blue color legend ✅
- **#15** lighten the model header + badge the irregularity ✅
- **#17** make the `Model:` reference tappable ✅

### ✅ Batch E — Consistency & accessibility
- **#11** Settings: alignment + header color + card grouping ✅
- **#13** Verbs list: information scent + Work Sans font fix ✅
- **#14** Dynamic Type fragmentation in detail rows ✅
- **#24** revisit the `xLarge` quiz-text cap (now that the quiz is scrollable) ✅ — removed outright
- **#20** `timeString` sub-minute format ✅

### 🟡 Batch F — Navigation polish & atmosphere
- **#21** section the Info list ✅ · **#22** Info reading width + body font ✅
- **#19** animate sort changes ✅
- **#26** browse header/content seam — **open, pending an aesthetic decision** (see #26)
- **#25** Start-pulse Reduce-Motion gate ✅ · **#27** Model help-button placement ✅
- **#28** scroll fades ✅ · **#29** typographic sharpening ✅ · **#30** iconography/atmosphere bundle 🟡 partial

---

_See `findings/3.md` for the cross-run analysis (who found what, effort-level effects, and the source verification behind every ✅ above). That document keeps its `file:line` citations on purpose — it is a dated snapshot of what the runs found, not a to-do list anyone acts on. **Note:** `findings/3.md` and the `outputs/ui/` run transcripts are not in this repo — they lived in the audit's working directory and were not carried over._
