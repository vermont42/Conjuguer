# Conjuguer UI / Design — Unified Recommendation List

_Synthesized from six independent UI-audit runs (3 High-effort: `h1`–`h3`; 3 Max-effort: `m1`–`m3`, in `outputs/ui/`). Union of every distinct recommendation raised, ranked by impact, greatest to least. **No code was changed.** Each run drove the live app on iPhone 17 / iOS 26 via `ios-build-verify` and reviewed the view layer through the `ios-design-agent-skill` five-pillar lens. The app already ships a real design system — a custom **Work Sans** family, a five-color light/dark palette, and the signature **red-ending conjugation coding** — so almost every item below is an *extension* of that system, not a replacement._

**"Runs" column** = how many of the six audits raised it (of 6). Higher count ≈ higher confidence / broader consensus. **✅ Verified** = checked against the live source during synthesis (see `findings/3.md` → *Verification against source*). Impact ≈ (time-on-screen) × (severity) × (inverse implementation cost); the **Quiz is the core loop** and weighs heaviest.

> **Locating each item:** anchors are given as **file + symbol** (type / function / modifier / property names and distinctive snippets), *not line numbers* — so they stay valid as the code shifts while sessions work through this list (several items touch the same file, so line numbers would rot mid-session). `grep` the named symbol to jump to the current site.
>
> **Keep this file's anchors current (instruction to implementing sessions):** if you rename, move, or delete a symbol that an anchor above points to (a type, function, modifier, property, `L.*` key, SF Symbol string, or snippet), **update the affected anchor(s) in this file in the same change** so they keep resolving. When a fix resolves an item, **mark it done** — prepend `✅ DONE —` to its heading; **never delete a resolved item.** The list then doubles as a running tally of what's been accomplished. Sessions are not run in parallel, so you are free to edit this file directly.

> **Foundations first.** Five items are shared primitives that several others depend on — a `customSurface` color + `.card()` modifier (#9), a brand-colored title modifier (#12), a `customGreen` "correct" color (#23), a centralized `.sensoryFeedback` hook (#4), and a numeric text style (#5). Building these first (Batch A) keeps everything downstream DRY. The batch plan at the end sequences accordingly.

---

## 🔴 High impact

### 1. The quiz answer field is visually invisible → give it a surface + focus ring
**`QuizView.swift`** — the `TextField(L.QuizView.conjugation…)` bound to `conjugationFieldIsFocused` · Runs: 6/6 · ✅ Verified
The single most-used control in the app is a bare, borderless `TextField` — on screen it's just the gray placeholder "Conjugation" and a cursor, the *least* visible element on the densest screen. **Fix:** filled, rounded container (`Color.customForeground.opacity(~0.06)` in a `RoundedRectangle(cornerRadius: 12)`) with a focus-tinted border (`customBlue`/`customRed` when `conjugationFieldIsFocused`, gray otherwise). The focus ring doubles as a "field is live" cue for the auto-focus that `start()` already sets.

### 2. Give the quiz *question* a hierarchy distinct from the *metadata*
**`QuizView.swift`** — the `.constrainedBodyLabel()` prompt rows in the `quizState == .inProgress` branch · Runs: 5/6 (not h2)
Verb / Translation / Pronoun / Tense — plus Progress / Score / Elapsed — are seven near-identical `constrainedBodyLabel()` rows; nothing signals *what to produce*. **Fix:** make the verb the hero (heading weight), fold the grammatical ask (pronoun · tense) into one emphasized line, demote the translation to a subtitle, and push Progress/Score/Elapsed into a single compact, de-emphasized status strip.

### 3. Fill the barren "not started" quiz screen
**`QuizView.swift`** — the `quizState == .notStarted` block (Start `Button` + bottom `Spacer`) · Runs: 6/6 · ✅ Verified
~85–90% of the marquee screen is empty — a corner title and a small Start button pinned above the tab bar. **Fix:** a centered briefing — one-line description, the active difficulty (`world.settings.quizDifficulty`), "30 questions," and the best score (Game Center is wired) — with Start composed into it as a clear primary CTA rather than a stray button.

### 4. Add haptics and make answer feedback unmissable
**`QuizView.swift`** (the `.onSubmit` → `quiz.process`), **`Models/Quiz.swift`** (`numberCorrect`, `previousIncorrectAnswer`) · Runs: 6/6 · ✅ Verified (0 haptics today; sounds *do* exist)
There is **no haptic feedback anywhere** (0 `sensoryFeedback`). Note the app *already* plays per-answer **sounds** and speaks questions, so the gap is **tactile + visual**, not feedback in general. **Fix:** `.sensoryFeedback(.success, trigger: quiz.numberCorrect)` and an error feedback keyed to `quiz.previousIncorrectAnswer` (note: there is **no** `numberIncorrect` property — wire the error trigger to `previousIncorrectAnswer`); add a brief `checkmark.circle.fill`/`xmark.circle.fill` symbol flash and reserve a fixed-height slot so inserting the feedback lines doesn't shove the question upward.

### 5. Stabilize and animate the changing numbers (+ a progress bar)
**`QuizView.swift`** — the `Progress` / `Score` / `Elapsed` `Text`s · Runs: 6/6 · ✅ Verified (0 monospaced/numeric-text today)
Score, progress, and the per-second elapsed timer use proportional Work Sans digits, so the layout jitters as they tick. **Fix:** `.contentTransition(.numericText())` on the changing counts (font-agnostic — preferred, since Work Sans may not ship tabular figures, so plain `.monospacedDigit()` can be a no-op); replace the "1 / 30" text with a real `ProgressView(value:)` bar.

### 6. Fix the Start button truncating at large Dynamic Type ("Star" / "Sta…")
**`QuizView.swift`** — `Button(L.QuizView.start)` with `.buttonLabel()` + `.phaseAnimator([1.0, 1.1])` · Runs: 3/6 (Max only) · ✅ Verified (structure: no `lineLimit`/`minimumScaleFactor`)
At accessibility text sizes the `.buttonLabel()` font scales but the glass capsule doesn't reflow, and the `phaseAnimator` 1.0→1.1 scale pushes the label past the edge, clipping "Start." A real accessibility defect that **no High run caught** (none exercised AX sizes). **Fix:** `.lineLimit(1).minimumScaleFactor(0.7)` (or `.fixedSize()` so the capsule grows) on the Start label.

### 7. Make the Quiz Results feel like a result — hero score, semantic correctness color, labeled answers
**`QuizResultsView.swift`** (the `Score:` `.bodyLabel()` line), **`QuizResultView.swift`** (`conjugationResult.iconString` + `.foregroundStyle(Color.customGray)`) · Runs: 5/6 (hero) · 4/6 (icon/labels) · ✅ Verified
The payoff for 30 questions: the score is a plain `bodyLabel()` line; each result row is **center-aligned**, stacks the correct answer over the user's with **no labels**, and marks correctness with a **gray** ✓/✕ for *both* outcomes — the weakest possible signal. **Fix:** promote the score to a large `workSansSemiBold` numeral with `.contentTransition(.numericText())`; color the icon (`isCorrect ? customBlue/customGreen : customRed`); left-align rows; label the two answers ("Your answer" / "Correct").

### 8. Lay conjugation data out in real columns
**`VerbView.swift`** (`TenseSectionView`), **`ModelView.swift`** (`endingRow(_:_:)`) · Runs: 6/6 (2 partial) · ✅ Verified (structure)
Conjugations — the product — render as a left-aligned single column using ~40% of the width; `ModelView`'s endings are space-separated runs with **no pronoun labels** (`Ind. Présent: s s t * * *`), legible only if you already know the six-slot order. **Fix:** render each tense as a two-column `Grid` (pronoun \| form), keeping the red-ending `AttributedString` in the form cell. (Requires splitting `VerbConjugations.Cell` into `pronoun` + form-only `display` — done once, reused by both screens.) For `ModelView`, add a fixed `je tu il nous vous ils` header row.

### 9. Introduce surface depth — a reusable `.card()` + a `customSurface` token  ⭐ *foundation*
**`Utils/Modifiers.swift`, `Utils/ColorExtension.swift` + `Assets.xcassets`** · Runs: 6/6 · ✅ Verified (0 cards/shadows/materials)
Everything floats on one flat `customBackground`; there is zero elevation, grouping, or rhythm. **Fix:** add one `customSurface` colorset (light + dark, e.g. `customForeground` at ~4–5% over the background) and a `.card()` modifier (padding + `RoundedRectangle` + optional leading accent bar). This single primitive unlocks #7, #11, #15, #18 and the detail-screen grouping.

---

## 🟠 Medium impact

### 10. Document the red/blue conjugation color code
**`VerbView.swift`, `ModelView.swift`, or a new Info entry** · Runs: 5/6 (not h3)
The app's best idea — endings/irregular stems in `customRed` — is unexplained at the point of use; a newcomer just sees colored letters. **Fix:** a compact, dismissible inline legend on first conjugation view (`@AppStorage` "seen" flag), or a short "How to read conjugations" Info article linked from the existing "Irregularities" entry.

### 11. Settings: unify alignment, unify header color, group into cards
**`SettingsView.swift`** (the `ScrollView` whose bare `Text` headers center; `settingsSubheadingLabel()` vs `subheadingLabel()`), **`Utils/Modifiers.swift`** · Runs: 6/6 (alignment) · 5/6 (color) · ✅ Verified
The title is leading-aligned but the section headers are **centered** (they're bare `Text` children of a `ScrollView`, which centers); two headers use `settingsSubheadingLabel()` (**blue**) and "Ratings and Reviews" uses `subheadingLabel()` (**gray**) for the same role. **Fix:** wrap the scroll content in `VStack(alignment: .leading) { … }.frame(maxWidth: .infinity, alignment: .leading)`; use one header modifier (one color) for all three; wrap each setting + its description in `.card()` (#9).

### 12. Unify the screen-title color — bake the brand color into the title modifier  ⭐ *foundation*
**`Utils/Modifiers.swift`** (`HeadingLabel`); the bare `headingLabel()` titles in **`VerbView.swift`** / **`ModelView.swift`** · Runs: 2/6 (Max) · ✅ Verified
`headingLabel()` sets the font + `.isHeader` but **no color**, so `VerbView`/`ModelView` titles render black/primary while `QuizView`/`SettingsView`/`QuizResultsView` add `.foregroundStyle(Color.customBlue)` at the call site — the brand blue drifts screen to screen. (The High runs flagged a *different* title inconsistency — hand-rolled `Text` vs real `navigationTitle` — also worth a pass.) **Fix:** add `.foregroundStyle(Color.customBlue)` inside `HeadingLabel`; split the few in-content uses that intentionally want foreground color (e.g. the model exemplar) into a separate modifier.

### 13. Verbs list: add information scent and fix the system-font inconsistency
**`VerbBrowseView.swift`** — the `List` row `Text(verb.infinitifWithPossibleExtraLetters)` (no font modifier), vs `ModelBrowseView`'s `.tableText()` row · Runs: 4/6 (scent) · 1/6 (font, m3 only) · ✅ Verified (font)
The most-visited list shows 6,320 verbs as bare infinitives — no translation, no frequency cue. Separately, the row `Text` has **no font modifier**, so unlike `ModelBrowseView` (which uses `.tableText()`) the Verbs list silently renders in the **system font**, breaking the app's own type identity. **Fix:** a two-line cell — infinitive in Work Sans (French) over translation (de-emphasized, English) — which restores the brand font *and* adds scent; optionally a trailing frequency-rank badge when `verb.frequency != nil`.

### 14. Fix Dynamic Type fragmentation in detail metadata rows
**`VerbView.swift`** — the `L.VerbView.modelWithColon` and `auxiliaryWithColon` multi-`Text` `HStack`s · Runs: 3/6 (Max only) · ✅ Verified (structure)
"Model: être (5-26)" and "Auxiliary: avoir" are `HStack`s of three separate `Text` views; at accessibility sizes they shatter (the label splits from its colon, the id wraps alone). The sibling single-`Text` "Frequency:" row wraps fine — proof only the multi-`Text` horizontal layout breaks. **Fix:** concatenate each row into one `Text` (wraps as one flow) or use `ViewThatFits`/`LabeledContent` to fall back to vertical.

### 15. Models: badge the irregularity and lighten the heavy detail header
**`ModelBrowseView.swift`** (the `" • \(irregularity)%"` `decorator`), **`ModelView.swift`** (the stacked `headingLabel()` header lines) · Runs: ~5/6 · ✅ Verified
The list appends "• 78%" as plain inline text; the detail header stacks five `headingLabel()`-weight lines (exemplar, id, Parent, description) into a heavy black slab. **Fix:** render the irregularity as a tinted `Capsule` badge (in the list and/or as the detail header), and demote "Parent" to a subheading so the headword stands alone.

### 16. The Quiz Results sheet has no Done button
**`QuizView.swift`** — the `.sheet(isPresented: $quiz.shouldShowResults)` presenting `QuizResultsView()` · Runs: 2/6 (Max) · ✅ Verified
Unlike the app's other sheets, `QuizResultsView` is presented **without** `.sheetDismissable()`, so it has no "Done" — dismissal is swipe-only, which isn't discoverable. **Fix:** wrap the results content in `.sheetDismissable()` (the existing modifier supplies a NavigationStack + Done) or add a toolbar Done.

### 17. Make the `Model:` reference in `VerbView` tappable
**`VerbView.swift`** — the `L.VerbView.modelWithColon` row · Runs: 2/6 (Max) · ✅ Verified
The verb screen shows "Model: être (5-26)" as plain text even though there's a whole Models browser and `ModelView` already deep-links *out* to verbs — a one-way street. **Fix:** make the model a `NavigationLink`/deep link so users can jump verb → its model and back.

### 18. Group tense sections (and metadata) into cards
**`VerbView.swift`, `ModelView.swift`** (`TenseSectionView` and the Overview metadata block) · Runs: 4/6 · depends on #9
Tense blocks stack with only a colored subheading between them, so a long verb reads as one dense ribbon. **Fix:** wrap each `TenseSectionView` and the Overview metadata block in `.card()` (#9), optionally with a thin gradient rule or leading accent bar between sections.

### 19. Animate sort changes and list re-sorts
**`VerbBrowseView.swift`, `ModelBrowseView.swift`** — the `.onChange(of:)` for `verbSort`/`modelSort` calling `updateSearchResults` · Runs: 3/6
Flipping the segmented sort replaces the whole list instantly. **Fix:** wrap the `searchResults` reassignment in `withAnimation(.snappy)`; add `.sensoryFeedback(.selection, trigger: store.verbSort)` so the reorder reads as causal.

### 20. Fix the `timeString` sub-minute format ("34" vs "1:39")
**`Utils/IntExtension.swift`** — `timeString` (the sub-minute `else` branch) · Runs: 3/6 (Max) · ✅ Verified
Under a minute, `timeString` returns bare seconds (`"%d"`), so the in-quiz timer reads "Elapsed: 34" while the results screen reads "Time: 1:39" — two formats for the same quantity. (Both screens already call `.timeString`; the fix is the formatter, not the call sites.) **Fix:** return `"0:%02d"` in the `else` branch so both read as elapsed time.

### 21. Section the Info browse list
**`InfoBrowseView.swift`** · Runs: 3/6 (Max-leaning)
20+ topics sit in one flat list mixing app-meta (Dedication, Value Proposition), concepts (Terminology, Irregularities), and per-tense explainers. **Fix:** a grouped `List` with `Section("About") / Section("Concepts") / Section("Tenses")` so the tense references are findable.

### 22. Info articles: constrain reading width + confirm the body typeface
**`InfoView.swift`, `TextView.swift`** · Runs: 4/6 (width) · 1/6 (font, h3)
Long-form text runs edge-to-edge (fine on iPhone, too wide on iPad/large type). `h3` also suspects the `UITextView`/`NSAttributedString` body renders in the *system* font rather than Work Sans — worth confirming, since `m2`/`m3` praised the articles as a strength. **Fix:** `.frame(maxWidth: 680)` centered; verify the attributed-string builder sets `Fonts.body` explicitly; a touch more `lineSpacing`.

### 23. Disambiguate the overloaded red; add a `customGreen` "correct"  ⭐ *foundation*
**`Utils/Modifiers.swift`** (`FunButton`), **`Utils/ColorExtension.swift`** · Runs: 3/6 · ✅ Verified
`customRed` simultaneously means primary CTA (Start), destructive (Quit), benign link (Rate or Review), *and* error (wrong answer / irregular endings) — `FunButton` tints all buttons red. One color carrying four meanings dilutes all of them. **Fix:** reserve red for error/destructive; give primary CTAs a `customBlue`/primary tint; add a `customGreen` colorset (light + dark) so "correct" has its own semantic, freeing red to mean "wrong/irregular."

### 24. Reconsider the `xLarge` Dynamic Type cap on quiz text
**`Utils/Modifiers.swift`** (`ConstrainedBodyLabel` — the `.dynamicTypeSize(...DynamicTypeSize.xLarge)` cap) · Runs: 1/6 (h2) · ✅ Verified
`constrainedBodyLabel()` caps Dynamic Type at `.xLarge`, so low-vision users on the largest accessibility sizes get smaller-than-requested quiz text. The cap exists to protect the current fixed layout. **Fix:** once the quiz adopts a scrollable card layout (#1–#5), raise or remove the ceiling so the core learning screen honors the user's full text-size preference.

---

## 🟡 Low impact (polish)

### 25. Reconsider/soften the Start pulse and gate it on Reduce Motion
**`QuizView.swift`** — the Start button's `.phaseAnimator([1.0, 1.1])` · Runs: 2/6 (Max) · ✅ Verified (no reduce-motion guard)
The lone animation is a continuous 1.0→1.1 `scaleEffect`, which reads as slightly nervous and contributes to the "Star" truncation (#6). (Note: `h1` considers the subtle pulse a *strength* — this is a judgment call.) **Fix:** gate the `phaseAnimator` behind `@Environment(\.accessibilityReduceMotion)`, and consider a calmer `.symbolEffect(.pulse)` on a lead glyph instead of scaling the button.

### 26. Remove the header/content background seam on browse screens
**`Utils/Modifiers.swift`** (`Modifiers.modifyAppearances()`) · Runs: 1/6 (m1) · ✅ Verified
The large-title/search header renders on the **system** background while the list uses `customBackground`, leaving a visible two-tone seam (the appearance proxy sets the bar's font/color but not its background). **Fix:** `.toolbarBackground(Color.customBackground, for: .navigationBar)` + `.toolbarBackgroundVisibility(.visible, …)`, or set the nav-bar background in `modifyAppearances()`.

### 27. Move the Model help button inline with its heading
**`ModelView.swift`** — the `questionmark.diamond.fill` help `Button` in the Stem Alterations `HStack` · Runs: 1/6 (m1) · ✅ Verified
The help button is pushed to the far right by a `Spacer`, marooning it from the "Stem Alterations" heading it explains. **Fix:** `HStack(spacing: 6) { Text(…); helpButton; Spacer() }` so the affordance reads as attached.

### 28. Subtle scroll-transition fade on long reference lists
**`VerbView.swift`, `ModelView.swift`** · Runs: 2/6 (h1, h3)
Rows hard-clip at the scroll edges. **Fix:** a restrained `.scrollTransition { c, p in c.opacity(1 - abs(p.value) * 0.12) }`; degrades gracefully under Reduce Motion.

### 29. Sharpen `key: value` typography — distinct prefixes, small-caps section labels
**`Utils/Modifiers.swift`** (`SubheadingLabel`), **`QuizView.swift`, `VerbView.swift`** · Runs: 2/6 (h1, h3)
Structural prefixes ("Verb:", "Model:") share one style with their values; section labels signal hierarchy by size alone. **Fix:** render prefixes quieter (smaller, `customGray`); give `SubheadingLabel` `.smallCaps()` + slight tracking so section labels read as labels — a classic editorial device that suits the literary subject.

### 30. Atmosphere & iconography micro-polish (bundle)
**various** · Runs: 1–2/6 each
A grab-bag of small, on-brand touches: round + soft-shadow the in-article images (`InfoView`); gradient separators instead of plain rules; `.symbolEffect(.bounce, value: selectedTab)` on tab selection; reconsider `key.fill` (Models) / `gearshape.2.fill` (Settings) glyphs (`MainTabView`); pair the `LoadingView` spinner with the wordmark; trim the dead vertical space above the large titles. Implement opportunistically alongside the batches they touch.

---

## Proposed implementation batches

Sequenced so shared primitives land first, then the highest-traffic screen, then the payoff screen, then dense content, then cross-screen consistency, then polish. Batches B–D depend on A.

### Batch A — Foundations (build once, reuse everywhere)
> Low standalone UI change, but #7, #11, #15, #18 (cards) and #4, #7 (color/haptics) all lean on these.
- **#9** `customSurface` color + `.card()` modifier
- **#12** brand-colored title modifier (`HeadingLabel` gets `customBlue`)
- **#23** `customGreen` "correct" color + de-overload red
- **#4** centralized `.sensoryFeedback` hook on the quiz
- **#5** a shared numeric text style (`.contentTransition(.numericText())`)

### Batch B — Quiz core loop (highest time-on-screen)
- **#1** visible answer field + focus ring
- **#2** question hierarchy (verb hero, demoted status strip)
- **#3** fill the not-started screen
- **#6** Start-button truncation fix
- **#4 / #5** wire haptics + visual feedback and stabilized numbers/progress bar into the loop

### Batch C — Quiz results & correctness semantics
- **#7** hero score + colored correctness icon + labeled, left-aligned answers (uses `customGreen` from A)
- **#16** add the Results-sheet Done button

### Batch D — Core content (verb & model detail)
- **#8** two-column conjugation grid + labeled `ModelView` endings
- **#18** cards on tense sections / metadata (uses `.card()` from A)
- **#12** apply the unified title color (from A) to `VerbView`/`ModelView`
- **#10** the red/blue color legend
- **#15** lighten the model header + badge the irregularity
- **#17** make the `Model:` reference tappable

### Batch E — Consistency & accessibility
- **#11** Settings: alignment + header color + card grouping
- **#13** Verbs list: information scent + Work Sans font fix
- **#14** Dynamic Type fragmentation in detail rows
- **#24** revisit the `xLarge` quiz-text cap (now that the quiz is scrollable)
- **#20** `timeString` sub-minute format

### Batch F — Navigation polish & atmosphere
- **#21** section the Info list · **#22** Info reading width + body font
- **#19** animate sort changes
- **#26** browse header/content seam
- **#25** Start-pulse Reduce-Motion gate · **#27** Model help-button placement
- **#28 / #29 / #30** scroll fades, typographic sharpening, and the iconography/atmosphere bundle

---

_See `findings/3.md` for the cross-run analysis (who found what, effort-level effects, and the source verification behind every ✅ above). That document keeps its `file:line` citations on purpose — it is a dated snapshot of what the runs found, not a to-do list anyone acts on._
