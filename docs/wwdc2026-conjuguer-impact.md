# WWDC 2026 → Conjuguer: Impact Analysis

**Date:** 2026-06-11 (WWDC week) · **Codebase:** `main` @ `83d61cf`
**Sources:** the three locally archived transcripts — Platforms State of the Union (session 102),
What's New in Swift (session 262), What's New in SwiftUI — read in full, plus
`prompts/code-review-suggestions-union.md` (the verified 33-item improvement plan, "union items"
below) and `docs/future-swiftui-fixes.md` (the Parts 2a–2d residue).

Claims about *Conjuguer* below were verified against the codebase (file:line cited). Claims about
the OS, Swift, and Xcode come from the transcripts only — API names are as spoken in sessions, exact
signatures and availability floors should be rechecked against documentation once the Xcode 27 betas
are installable. Apple's performance numbers ("up to 2×", "30% smaller") are Apple's claims.

---

## TL;DR

1. **The forced parts of the migration are a non-event here.** Conjuguer already targets iOS 26,
   ships Liquid Glass with no design opt-out, is universal + all-SwiftUI + scene-based, and just
   finished an adaptive-layout overhaul. The Liquid Glass opt-out removal and the resizability
   auto-opt-in both land on a codebase that's ready (§1.1, §1.2).
2. **Rebuilding with Xcode 27 fixes a real, measured waste for free.** `@State` is now a lazy macro
   (backported to iOS 17+ deployments): the `VerbStore` that today is constructed — including **two
   locale-aware sorts of all 6,320 verbs** — and discarded on every `MainTabView` re-evaluation will
   be constructed exactly once (§1.5). `ContentBuilder` also speeds type-checking at any deployment
   target.
3. **Two strategic features got dramatically cheaper:** (a) Spotlight/Siri integration via App
   Intents — Conjuguer's deeplink layer and stable infinitif keys are exactly the plumbing entities
   and intents need (§2.1); (b) on-device Foundation Models pedagogy — explain-my-quiz-mistake,
   grammar-term explanations grounded in the app's own Info articles, and OCR-driven reverse
   conjugation lookup, all with `Conjugator` as the non-negotiable source of truth (§2.2).
4. **The single most on-brand outcome: a French UI.** Xcode 27's in-context localization agent
   translates String Catalogs project-wide. Union item 29 (migrate the 618-line `L` enum to a
   catalog) should be promoted from Batch 7 to right after the bug batches — the content layer
   (`Etymologies.json`) is already bilingual and `knownRegions` already lists `fr` (§2.3).
5. **Plan adjustments are concentrated, not sweeping:** promote union items 29, 25, 26; item 33's
   new tests should be written in Swift Testing via the new XCTest interop (the suite is pure XCTest
   today); item 30's async/await refactors now silence real Swift 6.4 warnings; Batches 0–2 are
   untouched by WWDC and should land first (§5).

---

## 1. Migration: what Xcode 27 / the 27 SDKs actually change for this codebase

### 1.1 Liquid Glass — already adopted; the opt-out removal doesn't bite

The SOTU: once an app is recompiled with Xcode 27 it uses Liquid Glass unconditionally; the
compatibility opt-out is removed. **Verified status:** there is no `UIDesignRequiresCompatibility`
in `Conjuguer/Info.plist` or the build settings, and the deployment target is already 26.0
(`project.pbxproj:288`) — the app ships the new design today, so the forced migration is a no-op.

What arrives automatically (much of it *without* recompiling): better diffusion of complex content
behind glass, darkened edges and brighter specular highlights, and the new user-facing **tint
slider** (ultra clear ↔ fully tinted).

**Action:** after the first 27-SDK build, sweep the app with the slider at both extremes — the app
leans on `Color.customBackground` surfaces and bundled WorkSans faces (`Info.plist` `UIAppFonts`),
and the slider makes user-side contrast variance wider than iOS 26's. Fold in the deferred
future-fixes **2c** decision (uniform `.toolbarBackground` on the browse screens): iOS 27's
automatic scroll-under toolbar treatment ("a uniform toolbar appears … keeps the text legible") may
resolve 2c's aesthetic question with no code. Don't decide 2c on iOS 26 visuals.

### 1.2 Resizability — auto-opt-in lands on a mostly ready codebase

Rebuilding with the 27 SDK automatically opts the app into resizing on iPad and in iPhone Mirroring;
iPhone apps become resizable on iOS 27 itself.

**Verified readiness:** universal app (`TARGETED_DEVICE_FAMILY = "1,2"`, pbxproj:380), all-SwiftUI,
scene-based (`UIApplicationSupportsMultipleScenes` = true, Info.plist:47-48),
`.tabViewStyle(.sidebarAdaptable)` (MainTabView.swift:38), portrait+landscape declared on both
device families, and the phase-0–8 layout overhaul already replaced fixed spacers with adaptive
spacing. There is **no `UIScreen` or `AsyncImage` anywhere**; the only `GeometryReader` is
QuizView.swift:29.

**Actions:**
- Drag-test in the new resizable simulator/Live Previews (Xcode 27 previews grow resize handles).
- The two size-sensitive spots to exercise at extreme aspect ratios: QuizView (its GeometryReader
  layout) and the Dynamic Type cap (`Modifiers.swift:183`, future-fixes **2b**) — do 2b's cap review
  as part of this same audit rather than separately.
- Apple ships a **resizability agent skill**; see §4.1 for pulling it into this repo's workflow.

### 1.3 The `@State`-macro source break — audit, probably clean

`@State` changed from a dynamic property to a macro. The breaking pattern: a `@State` declaration
with a **default value** that is *also assigned in `init`* now errors ("use before initialization").
**Verified in the files inspected** (ConjuguerApp, MainTabView, VerbBrowseView): all `@State`
properties use inline defaults and no initializer reassigns one; no `State(initialValue:)` /
`self._x =` patterns found. Sweep the remaining views when 27 lands (`grep -rn "= State("
Conjuguer/` plus a look at any custom view `init`s) before the first build.

### 1.4 New warnings to expect on the first 27 toolchain build

- **Silently ignored errors from concurrency tasks** (Swift 6.4 warns). Audit candidates — the
  fire-and-forget `Task {}` sites: ReviewPrompter.swift:21, GameCenter.swift:28,
  RatingsFetcher.swift:64, QuizView.swift:265. (Quiz.swift:372-373 already `try?`s its sleep
  explicitly, which is a deliberate ignore and should stay quiet.) These are the same neighborhoods
  as the **8 known pre-existing concurrency warnings** (RatingsFetcher ×6, GameCenter ×1, Quiz ×1 —
  per future-swiftui-fixes.md): union item 30's async/await refactors now have compiler backing
  rather than being pure style (§5).
- **Swift Testing ↔ XCTest interop notices** appear only once suites start mixing (§3.3) —
  reported as warnings by default.
- `@diagnose` (§3.2) can corral known warnings per-declaration in the interim so the build stays
  readable and *new* warnings stand out.

### 1.5 Free wins from the rebuild (no code changes)

- **Lazy `@State` — the big one.** VerbBrowseView.swift:13 holds
  `@State private var store = VerbStore(world: Current)`, and `VerbStore.init`
  (VerbBrowseView.swift:123-151) performs two full locale-aware sorts of all 6,320 verbs. Under
  pre-27 semantics that initializer expression runs — and the result is discarded — on **every**
  `MainTabView` body re-evaluation (every tab switch re-evaluates it: `selectedTab` is bound right
  there, MainTabView.swift:16). After the Xcode 27 rebuild the store is initialized exactly once.
  Same story for `ModelBrowseView`'s `ModelStore` (union item 21). The behavior is **backported to
  iOS 17+**, so it applies at the current deployment target the moment the app is built with
  Xcode 27. Note what this does *not* fix: union item 21's environment-injection half (testability —
  the store still captures the global `Current` instead of the injected `World`) and union item 24
  (VerbView's conjugations are a stored `let`, not `@State`, so they still recompute per re-init).
- **`ContentBuilder`** unifies `Section`/`Group`/`ForEach` builder overloads — substantially faster
  type-checking and fewer "unable to type-check in reasonable time" walls. Toolchain-level, works
  at any deployment target. The heavily nested bodies in VerbView/ModelView/QuizView are exactly
  the shape this targets; Swift 6.4's general expression-type-checking work helps the same spots.
- **Nested-stack layout resizes up to 2× faster** (SwiftUI short-circuits redundant child
  measurement) — relevant now that resizing applies to this app on three surfaces (§1.2).
- General platform claims: faster launch and responsiveness after rebuild. Conjuguer's launch is
  dominated by its own XML parse, which is already off-main behind `LoadingView`
  (ConjuguerApp.swift:16-26), so expect modest gains here.
- **AsyncImage HTTP caching: N/A** — the app loads no remote images (RatingsFetcher is
  JSON-only).

---

## 2. Strategic opportunities

### 2.1 App Intents + Spotlight semantic index + Siri — the discoverability play

**What's new:** entity schemas and intent schemas Siri understands natively, Spotlight semantic
indexing with attribution back to the app, the View Annotations API (on-screen content becomes
actionable), and the system app-toolbox/orchestrator routing user requests to app capabilities.

**Why Conjuguer is unusually well positioned.** The hard prerequisites already exist:

- Stable, meaningful entity keys: verbs keyed by infinitif (6,320), models by id, Info articles by
  heading — all already reachable through the `conjuguer://` URL layer (Info.plist:23-35;
  `World.handleURL`/`handleInAppURL`, World.swift:114-175; behavior locked by `DeeplinkTests`).
- The natural feature ladder:
  1. `VerbEntity` (+ model/info entities) conforming to `IndexedEntity` → all 6,320 verbs in the
     Spotlight semantic index. A student types or asks for *étreindre* and lands in the app, with
     attribution.
  2. A `ConjugateVerbIntent(verb:tense:)` → Siri/Shortcuts speak or display `Conjugator` output
     without opening the app; "start a quiz" becomes Action-button-able.
  3. View Annotations on VerbView/ModelView rows → "what's *this* tense?" on-screen references.

**Honesty about schemas:** the SOTU's named schema categories (task management, photo editing,
communication) don't obviously include a conjugation-reference shape (the app's category is
literally `public.app-category.reference`, pbxproj:367). Custom intents and `IndexedEntity` deliver
Spotlight + Shortcuts regardless; *schema-grade* Siri reasoning depends on what schemas actually
ship — check the App Intents sessions/docs during the beta cycle.

**Prerequisites that overlap existing plans** (do these as the intents groundwork):
- Union 25 — extract the shared host→entity resolution out of `handleURL`/`handleInAppURL`: that
  extraction is precisely the shared core URL-entry and intent-entry should both call.
- Union 26 — stop reading `Current.settings.pronounGender` inside the engine: intents execute
  outside the view stack (and potentially before UI exists), so the engine's purity stops being a
  style point and becomes a correctness boundary.
- future-fixes 2d — the cold-launch pending-URL buffer generalizes to a single "data ready" gate
  for **every** external entry (URL, intent, Spotlight tap) while the XML parse is in flight.
  Promote 2d from optional to part of this work.

### 2.2 Foundation Models — on-device pedagogy, with the engine as ground truth

**What's new this year:** multimodal prompts (images) with integrated Vision tools (OCR), pluggable
server models (Claude, Gemini, anything conforming to the Language Model protocol), the Apple
Foundation Model on Private Cloud Compute **free of cloud-API cost for developers under 2M
first-time downloads** (Conjuguer qualifies by orders of magnitude), Dynamic Profiles (declarative
per-task model/tool/instruction switching in one session), an Evaluations framework, an `FM` CLI, an
app-private Core Spotlight RAG tool, and open-sourcing of the framework (server-side Swift) later
this summer. The base framework (text, guided generation, tool calling, on-device model) is an
iOS 26 API — usable at the current deployment target now; this year's additions will need iOS 27
gating or a target bump.

**Design rule first.** Conjuguer's brand is correctness — a conjugation reference that hallucinates
is worse than no feature. So: **the LLM is never the source of a conjugated form.** Expose
`Conjugator` to the model as a *tool* (the framework's tool-calling exists for exactly this), or
post-verify any model output containing conjugations against `Conjugator` before display, and label
generated content as generated. The deterministic engine stays authoritative; the model adds
pedagogy, narrative, and language understanding.

**Feature candidates, ranked by fit:**

1. **Reverse lookup / "Conjuguer Lens"** (27-gated; the most differentiating). Learners meet
   *étreignîmes* in the wild and can't find it in an infinitif-keyed reference. Camera/photo → the
   framework's Vision OCR tool extracts text → the model lemmatizes conjugated forms to infinitifs →
   deeplink into VerbView. Reverse conjugation is the classic hard feature for conjugation apps;
   an on-device LLM with OCR finally makes it cheap. Verification loop: `Conjugator` can confirm
   the claimed form actually appears in the claimed verb's paradigm before showing the match.
2. **Explain-my-mistake in the quiz** (buildable on iOS 26 today). After scoring, offer one tap:
   proposed answer + correct answer + `ConjugationResult` go to the on-device model for a two-line
   explanation ("you dropped the grave accent — *détendre* keeps *è* in…"). Fully grounded: both
   strings come from the app; the model only explains the difference. Pairs naturally with union
   item 3 (the accent-stripping scoring fix) and the existing partial-credit system.
3. **Grammar-term explanations** — the SOTU's "valley fold" pattern transposed: tap *subjonctif* or
   *passé simple* anywhere → a small on-device explanation, grounded via the new app-private Core
   Spotlight **RAG tool over the app's own Info articles**. Cheap, offline, low-risk.
4. **Example sentences per verb + tense.** Guided generation produces a sentence using the
   conjugated form; the app verifies (string-contains against `Conjugator` output) before display.
5. **Etymology long tail — pipeline, not runtime.** 590 of 6,320 verbs have curated etymologies
   (`Etymologies.json`, en+fr, 1.5 MB, lazy-loaded — Etymology.swift:14-36; produced by the
   `prompts/etymology-pipeline.md` flow). Runtime generation is the *most* hallucination-prone
   candidate here (etymologies are factual-historical claims), so keep the curated pipeline primary
   and clearly label anything generated on demand. Where this year's tools genuinely help is the
   **pipeline**: the `FM` command-line tool for fast prompt iteration and the **Evaluations
   framework** to regression-test prompts against the 590 gold entries (tone, `~bold~` markup
   discipline, length). Speculative but real: with the framework open-sourced and running
   server-side, the pipeline could become a Swift tool sharing the app's own `Verb`/`Etymology`
   types.

**Caveats:** Apple-Intelligence-capable hardware only (a student audience skews toward older,
cheaper devices) and PCC requires network — every feature above must be progressive enhancement
over a fully functional reference core. If several features ship, **Dynamic Profiles** is the right
shape: an on-device profile for cheap tasks (term explanations) and a PCC profile for deep ones
(lens/lemmatization), sharing one session transcript.

### 2.3 The localization unlock — promote union item 29

Today the UI is English-only via the hand-rolled `L` enum (618 lines), while the *content* layer is
already bilingual (`Etymologies.json` ships `en` and `fr` keyed by language; Etymology.swift:29-30
selects by `Locale.current`), `knownRegions` already lists `fr` (pbxproj:174-178), and
`CLANG_ANALYZER_LOCALIZABILITY_NONLOCALIZED = YES` is already set (pbxproj:240) — the project has
been pointing at localization for years without crossing.

Xcode 27's localization agent adds a language to a **String Catalog** and translates each string in
the context of its surrounding code and UI, project-wide. That makes the sequence:

1. Migrate `L` → `.xcstrings` (union item 29's "long term" half — it also subsumes the short-term
   key-hygiene step, e.g. the shared bare `"alphabetical"` key).
2. Run the localization agent for French (and as many further languages as review capacity allows).
3. Human-review — for French especially, where the app's own content can check the translator
   (the union item 29 note about interpolated `*WithColon` strings matters here: convert those to
   format-style strings *before* translating, or word-order bugs get baked into every language).

A French-UI option in a French-*learning* app is the most on-brand single outcome available from
this WWDC, and it converts item 29 from "Tier E polish, Batch 7" into an early, high-visibility
win. Recommended: schedule the catalog migration right after Batches 0–1.

---

## 3. Smaller adoption notes

### 3.1 SwiftUI APIs worth taking (all presented as 27-era)

- **`toolbarMinimizeBehavior(.onScrollDown)`** on the three browse screens: more verbs/models per
  screen on iPhone, matching the app's content-first lists. Decide together with future-fixes 2c
  after seeing iOS 27's automatic toolbar treatment (§1.1).
- **Full-fidelity text selection on iOS** — conjugation tables and etymologies become properly
  selectable wherever `.textSelection(.enabled)` is (or should be) applied; also one more reason to
  finish moving Info articles off `UITextView` (§6, union item 28).
- **`confirmationDialog`/`alert` item-binding** — matches the app's `.sheet(item:)` house style
  (ModelView's `DetailSheet` enum); adopt if/when a destructive confirmation ever ships.
- **Preview variants grid** ("pass the enum to the preview, get every state"): tailor-made for
  `ConjugationResult` (the green/blue/red result rows), `QuizState`, and defective-verb variants of
  ModelView. `PreviewSupport.bootstrap()` already makes previews self-contained, so adoption is
  cheap and it feeds the screenshot-driven verification flow.
- **Not applicable:** reorderable containers and swipe-actions-in-any-container (no user-ordered
  content; the lists are real `List`s), the prominent tab role (five peer tabs), the new Document
  API (not document-based), Spatial Preview (no macOS app), menu-bar icon policies (iPad/Mac
  menu-bar specifics don't apply to this UI).

### 3.2 Swift 6.3 / 6.4 in this codebase

- **`@diagnose`** — immediately useful twice: (a) scope the 8 known concurrency warnings
  (RatingsFetcher ×6, GameCenter ×1, Quiz ×1) to their declarations so they stop desensitizing
  builds until union item 30 deletes them properly; (b) once clean, promote selected groups
  (deprecations) to errors — the project's existing "0 deprecation warnings" bar becomes
  compiler-enforced rather than discipline-enforced.
- **`weak let`** — if any `@unchecked Sendable` lurks around the GameKit delegate plumbing, recheck
  whether it can become checked.
- The second memberwise initializer for mixed `internal`/`private` structs and `some`/`any`
  optional-parenthesization removal: incidental niceties; nothing to plan.
- **Explicitly not needed:** `@inline(always)`, `@specialized`, borrow/mutate accessors,
  `Iterable`, `UniqueBox`/`UniqueArray`/`Ref`/spans. Conjuguer's measured costs are algorithmic —
  store rebuilds (§1.5), VerbView recompute (union 24) — not copy/refcount-bound. In particular,
  don't let union item 13's `CyclingDeck` reach for `Iterable`; plain `Sequence`/indexing is right.
- `anyAppleOS`, module selectors (`::`), `@C` export, Swift-Java, Wasm, Embedded Swift: no current
  use. One strategic footnote: with an official **Swift SDK for Android** (6.3) and the
  GoodNotes-style Wasm path maturing, the conjugation engine — pure Swift + Foundation over
  XML/data tables — is a plausible shared core if Conjuguer ever goes multi-platform. Union item
  26's engine purification is the prerequisite either way. An option to keep open, not a
  recommendation.
- **`ProgressManager`**: the only plausible consumer is the launch XML parse, which is sub-second
  behind `LoadingView` — skip.
- `mapKeyedValues`, the new `FilePath` type, the task-cancellation shield, Subprocess 1.0: no
  call sites in an app of this shape.

### 3.3 Swift Testing — reframes union item 33, not the existing suite

**Verified fact:** the suite is pure XCTest today — all five test files import XCTest
(CompoundTenseTests, DeeplinkTests, VerbModelTests ×5,530 generated lines, TestUtils) — with 99
tests green. (CLAUDE.md's "Swift Testing form" note for `--only-testing` is anticipatory, not
descriptive.)

This year's interop changes the adoption calculus:

- XCTest assertion failures now surface as issues when called from Swift Testing, and `#expect`
  works inside `XCTestCase` — so item 33's **new** tests can be written as Swift Testing
  **parameterized tests** (`@Test(arguments:)` is exactly the shape of the planned
  `ConjugationResult.score` table, the `Settings` round-trip, and the DefectGroup-shorthand
  assertions) while the golden XCTest suite stays untouched and `TestUtils` helpers serve both.
- `Issue.record(severity: .warning)` is the right tool for golden-suite drift checks — surface
  regeneration diffs without blocking (relevant to item 33's regenerate-vs-table-driven debate).
- `Test.cancel()` gives clean dynamic skips for parameterized cases (e.g., defective-verb
  arguments that intentionally lack forms).
- Caveat: `swift test`'s new repeat-until-pass/fail flag is SwiftPM CLI; `run_tests.sh` drives
  `xcodebuild`, so it doesn't apply as-is. (The suite is deterministic; no current need.)
- Housekeeping when the first Swift Testing suite lands: update CLAUDE.md's `--only-testing`
  examples (Swift Testing methods take the trailing `()`), and decide the build-setting for
  promoting interop warnings to failures.

---

## 4. Tooling & workflow — this repo already runs an agentic loop

This repo's CLAUDE.md encodes a hand-built version of several things Xcode 27 now ships natively
(simulator driving, screenshot verification, accessibility-tree inspection). Concrete actions:

- **`xcrun agent skills export`** — Apple's specialist skills (SwiftUI, What's-New-in-SwiftUI,
  accessibility, universal sizing, testing, performance) export as markdown for use in non-Xcode
  agents. Export and wire the relevant ones into this repo's Claude Code setup; the
  universal-sizing skill feeds the §1.2 resizability audit directly, and the What's-New skill is a
  ready-made adoption checklist for §3.1.
- **Device Hub replaces Simulator.** The `ios-build-verify` harness drives the sim via
  `simctl`/AXe (`launch_app.sh`, `describe_ui.sh`, `tap_tab.sh`, `screenshot.sh`) and CLAUDE.md
  documents iOS 26-specific quirks. Watch items for the first 27 beta: (a) confirm `simctl`/AXe
  still behave under Device Hub (almost certainly — it's a new front end over the same runtime,
  but verify before trusting screenshots); (b) **retest the iOS 26 segmented-picker
  empty-AXTree bug** — if iOS 27 fixes it, `verify_segment.sh --segments N` and its CLAUDE.md
  caveat can be retired; (c) Xcode's native agents-drive-the-simulator tools may eventually
  subsume parts of the harness, but the harness works today — no preemptive change.
- **ACP (Agent Client Protocol)** — Xcode now hosts any compatible agent (shipping in an Xcode 26
  update per the SOTU, with Anthropic integration built in). An optional alternative surface to
  the current terminal flow; zero obligation, and the existing flow keeps working.
- **Xcode Cloud** — setup is now in-app and builds are claimed 2× faster. The repo currently has
  no CI (SwiftLint pre-commit only); this is the cheapest path to "run the 99 tests on every push"
  if CI is ever wanted.
- **Organizer crash agent** — agent-driven triage from symbolicated crash logs. The app ships
  Pinpoint analytics but App Store crash reports are the relevant feed; at v1.5 scale this is a
  free occasional check, not a workflow.

---

## 5. Effects on the 33-item plan (only items affected)

| Union item | Effect | What changes |
|---|---|---|
| 13 `CyclingDeck` | guard rail | Don't reach for `Iterable`/noncopyable machinery (§3.2); plain `Sequence`/indexing remains right. |
| 17 `fatalError` policy | helper | `@diagnose` manages warning groups during the transition; the new ignored-task-error warning pushes the same recoverable-errors direction. |
| 20 Settings helpers | note | The "property wrappers don't compose with `@Observable`" constraint stands. Apple's fix for the identical shape was a *macro* (`@State`); a custom macro is the eventual declarative answer if the helper-method shape ever feels insufficient. |
| 21 BrowseStore/env | reshaped | Lazy `@State` erases the rebuild waste for free (§1.5); the environment-injection half remains right for testability/previews and should align with the App Intents entry paths (§2.1). |
| 24 VerbView recompute | easier | Stored `let` is **not** covered by lazy `@State`; the `.task(id:)`/`@State` fix is unchanged in need and now the obviously idiomatic shape. |
| 25 `handleURL` extraction | **promoted** | The extracted resolution layer becomes the shared core for deeplinks *and* App Intents/Spotlight (§2.1). Design the seam with both callers in mind. |
| 26 engine reads `Current` | **promoted** | Intent/extension execution contexts make engine purity a correctness boundary, not a style preference; also the prerequisite for any multi-platform engine future (§3.2). |
| 28 NSAttributedString retirement | reinforced | Full-fidelity iOS text selection (§3.1) and the Info-article Dynamic Type gap (future-fixes 2a) both favor finishing the AttributedString migration. |
| 29 `L.swift` / String Catalog | **strongly promoted** | Unblocks Xcode 27 agentic localization → French UI (§2.3). Pull from Batch 7 to right after Batches 0–1; convert interpolated `*WithColon` strings to format-style first. |
| 30 service grab bag | strengthened | The RatingsFetcher/GameCenter async/await refactors now silence real Swift 6.4 warnings (§1.4), and they burn down the 8 known concurrency warnings. |
| 33 tests | reframed | Write the new tests as Swift Testing parameterized suites alongside the XCTest goldens via the new interop (§3.3). |

**Batch-order adjustments:** Batches 0–2 (bugs, deletions, latent correctness) are untouched by
WWDC — land them first, before beta churn. Add a **"27-migration gate" mini-batch** for when the
betas install: rebuild → 99 tests → warning audit (§1.4) → `@State` sweep (§1.3) → resizability
pass + Dynamic Type cap review (§1.2) → glass-slider sweep + 2c decision (§1.1) → AX-picker retest
(§4). Then pull item 29's catalog migration forward (§2.3).

---

## 6. Effects on future-swiftui-fixes.md (Parts 2a–2d)

- **2a (Info-article Dynamic Type):** unchanged in substance, but weigh it against union item 28 —
  migrating the articles to `AttributedString`/SwiftUI `Text` would make the `UIFontMetrics` patch
  moot. If 28 is scheduled within a release or two, skip 2a's interim fix.
- **2b (Dynamic Type cap reconsideration):** fold into the §1.2 resizability audit — same screens,
  same failure mode (layout at extremes), one verification pass.
- **2c (uniform nav tint):** **defer the decision until running on iOS 27** — the automatic
  scroll-under toolbar treatment may resolve it for free; decide during the glass-slider sweep.
- **2d (cold-launch deep-link buffer):** promoted from optional polish to **prerequisite for
  §2.1** — generalize it into a single "data ready" gate that buffers any external entry (URL,
  intent invocation, Spotlight tap) until `verbData.state == .loaded`.

---

## 7. Explicitly not applicable

The new Document API and `DocumentCreationSource` (not document-based) · Spatial Preview /
visionOS-adjacent features (no Mac/Vision presence) · reorderable containers and
`swipeActionsContainer` (no user-ordered content; lists are `List`s) · prominent tab role (five
peer tabs) · Core AI (no custom/converted models — Foundation Models covers every LLM need here) ·
MLX, Game Porting Toolkit, Metal CLI, Reality Composer Pro · macOS-specific glass refinements,
window corner radii, menu-bar icon policy · Subprocess, `FilePath`, task-cancellation shield,
`@C`/Java/Wasm/Embedded interop (today; see the §3.2 footnote) · Apple-silicon-only Mac App Store
binaries (iOS app) · AsyncImage caching and `asyncImageURLSession` (no remote images).

---

## Appendix A — codebase facts verified for this analysis

| Fact | Evidence |
|---|---|
| Deployment target iOS 26.0; Swift 6.0; strict concurrency `complete`; approachable concurrency + `MainActor` default isolation | project.pbxproj:288,295,376-379 |
| Universal app (iPhone + iPad) | project.pbxproj:380 (`TARGETED_DEVICE_FAMILY = "1,2"`) |
| No Liquid Glass opt-out anywhere | no `UIDesignRequiresCompatibility` in Info.plist or pbxproj |
| Multiple scenes enabled; portrait+landscape on both families | Info.plist:45-49,61-73 |
| Modern `Tab`-API TabView with `.sidebarAdaptable` | MainTabView.swift:16-38 |
| Launch parse async behind `LoadingView`; `onOpenURL` on the always-present container | ConjuguerApp.swift:13-28 |
| `VerbStore` built from global `Current` in `@State` default; init does two locale-aware sorts of 6,320 verbs | VerbBrowseView.swift:13,123-151 |
| No `UIScreen`/`AsyncImage`; sole `GeometryReader` | QuizView.swift:29 |
| Test suite is pure XCTest (5 files), 99 tests green | `import XCTest` in all ConjuguerTests files; future-swiftui-fixes.md |
| 8 pre-existing concurrency warnings (RatingsFetcher ×6, GameCenter ×1, Quiz ×1) | future-swiftui-fixes.md "Environment & constraints" |
| Fire-and-forget `Task {}` sites | ReviewPrompter.swift:21, GameCenter.swift:28, RatingsFetcher.swift:64, Quiz.swift:372, QuizView.swift:265 |
| Etymologies: lazy-loaded, language-keyed (en+fr), 1.5 MB, `~bold~` markup, pipeline in prompts/ | Etymology.swift:14-36; Etymologies.json |
| `knownRegions` already includes `fr`; localizability analyzer on; App Store category "reference" | project.pbxproj:174-178,240,367 |
| `conjuguer://` URL scheme registered | Info.plist:23-35 |
| No App Intents / CoreSpotlight / NSUserActivity usage today | repo-wide grep (only `onOpenURL`, ConjuguerApp.swift:27) |

## Appendix B — sourcing caveats & housekeeping

- All WWDC claims trace to the three archived transcripts; nothing here was verified against
  Apple documentation or betas (not yet installable at time of writing). API spellings
  (`visibilityPriority`, `ToolbarOverflowMenu`, `DocumentWriter`, `@diagnose`, Dynamic Profiles,
  …) are as spoken in sessions; availability floors for "this year's" Foundation Models and
  SwiftUI additions are inferred to be the 27 SDKs and should be confirmed.
- The transcripts' headers say they are gitignored; they were not (`git status` showed them
  untracked and ignorable by nothing in `.gitignore`). Fixed in this session by adding
  `docs/wwdc2026-*.txt` to `.gitignore` — the pattern is `.txt`-scoped so this analysis and any
  other WWDC markdown remain tracked.
- Companion docs: the 33-item plan (`prompts/code-review-suggestions-union.md`), its comparative
  analysis (`docs/model-eval-analysis.md`), the UI-issues residue (`docs/future-swiftui-fixes.md`).
