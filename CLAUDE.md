# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands

This project uses the **`ios-build-verify` Claude Code skill** for building, testing,
and verifying the app. The build/test scripts pipe `xcodebuild` through `xcbeautify`
for concise output and tee raw output to `build.log` as a fallback. Per-project
configuration lives at `.claude/ios-build-verify.config.sh` (target sim: iPhone 17 /
iOS 26; scheme: `Conjuguer`) and is sourced by every script.

Scripts live under the skill's install path. Resolve it once, then invoke by name:

```bash
export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")

# Build the app
"$IBV_SCRIPTS/build_app.sh"

# Run all tests
"$IBV_SCRIPTS/run_tests.sh"

# Run a single suite or method (Swift Testing form: Target/Suite/method() — note trailing ())
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/VerbModelTests
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/CompoundTenseTests/testCompoundTenses
```

### Verifying the app (simulator-driven)

The skill can launch the app and inspect/drive the UI so changes can be verified
beyond unit tests:

```bash
"$IBV_SCRIPTS/build_app.sh"                  # COMPILE first — launch_app.sh does NOT build (see warning below)
"$IBV_SCRIPTS/launch_app.sh"                 # boot + install the last-built .app + launch + wait-for-render
"$IBV_SCRIPTS/screenshot.sh <context-slug>"  # capture a PNG under docs/screenshots/
"$IBV_SCRIPTS/describe_ui.sh"                # dump the accessibility tree
"$IBV_SCRIPTS/tap_tab.sh <verbs|models|quiz|info|settings>"  # tap a main tab
```

> **⚠️ `launch_app.sh` does NOT compile.** It resolves `BUILT_PRODUCTS_DIR` via
> `xcodebuild -showBuildSettings` (which doesn't build), then installs whatever `.app`
> already exists there and launches it. **After editing source, you MUST run
> `build_app.sh` (or `run_tests.sh`) first** — otherwise `launch_app.sh` reinstalls the
> *previous* binary and your screenshots show pre-edit UI. (`launch_app.sh` does terminate
> the running process before install, so a stale *process* isn't the issue — a stale
> *build* is.) A symptom: edit → `launch_app.sh` → screenshot is byte-identical to the
> last one across multiple different edits. Always `build_app.sh && launch_app.sh`.

The launch anchor is `verb_browse_sort` (the sort `Picker` in `VerbBrowseView`). Add
more `.accessibilityIdentifier`/`.accessibilityValue` modifiers on a migration-by-use
basis as verification flows need them. See the skill's `SKILL.md` for the full verify
surface (named-intent ops, annotation checks, iOS 26 control caveats).

#### Accessibility identifiers added so far

| Identifier | Element | Notes |
|---|---|---|
| `verb_browse_sort` | Sort `Picker` in `VerbBrowseView` | Launch anchor (`FIRST_SCREEN_ID`). |
| `input_quiz_conjugation` | Answer `TextField` in `QuizView` | Carries `.accessibilityValue(input)`, so `read_value`/`set_value`/`type_text --id` work with read-back. |
| `picker_settings_quizDifficulty` | Quiz-difficulty segmented `Picker` in `SettingsView` | 2 segments (Regular, Ridiculous). |
| `picker_settings_pronounGender` | Pronoun-gender segmented `Picker` in `SettingsView` | 3 segments (Feminine, Masculine, Both). |

List rows (verbs, models, info headings) and tab buttons are not yet annotated —
drive them by `AXLabel` / `tap_tab.sh` for now.

#### iOS 26 control caveats specific to this app

- **Accented input (é, è, à, ç, …):** `axe type` rejects non-ASCII. The skill's
  `set_value.sh` / `type_text.sh` (v0.3.0+) auto-route non-ASCII through a
  `simctl pbcopy` + Cmd+V pasteboard fallback, so French conjugations enter
  correctly. The quiz field is reachable by id, so prefer `type_text.sh --id
  input_quiz_conjugation "<answer>"` (gives read-back); the field also auto-focuses
  after **Start**, so a bare `axe type` into the focused field also works for ASCII.
- **Segmented pickers** render with empty AXTree children on iOS 26, so segments
  aren't individually addressable by id. The parent identifier locates the control's
  frame; `verify_segment.sh` then verifies a segment's label + selected state, but
  **requires `--segments N` explicitly** (it can't infer the count through the
  children-empty bug): `--segments 2` for `picker_settings_quizDifficulty`,
  `--segments 3` for `picker_settings_pronounGender`. To *drive* a selection, compute
  the segment center from the id'd frame (`x + width*(i+0.5)/N`, `y + height/2`) and
  `tap_xy.sh`.

#### Completing a quiz (regular difficulty)

A regular-difficulty quiz is 30 questions; `Quiz.process(_:)` advances on every
submission regardless of correctness, so completion = submit an answer to all 30.
After **Start**, the answer field auto-focuses; type into `input_quiz_conjugation`
and send Return (`axe key 40`) per question. The `Progress: N / 30` label tracks
position; the run ends with a `QuizResultsView` sheet (label `Results`).

The field **stays focused across submissions** (`submitAnswer()` re-sets focus), so a
fast sweep is: tap it once (`tap_id.sh input_quiz_conjugation`), then loop
`axe type "<answer>"` + `axe key 40` — batch many pairs into one Bash call and
`screenshot.sh` between batches to check
progress. **Caveat:** if focus is lost (e.g. after a `describe_ui`/screenshot detour),
`axe type`/`axe key 40` silently no-op and the quiz won't advance — re-tap the field by
id before resuming. To exercise all three result-icon colors, mix outcomes: a correct
conjugation → green, a correct skeleton with a dropped accent (e.g. `detends` for
`détends`) → blue partial, junk (`x`) → red.

**SourceKit vs. the build:** editing a view file often triggers SourceKit "Cannot find
X in scope" diagnostics for same-module symbols. If `build_app.sh` succeeds, the build
is authoritative — do not "fix" SourceKit-only diagnostics.

#### False "temp filesystem … is full (0MB free)" errors & truncated Bash output

Two related Claude Code harness bugs (native macOS build, seen through 2.1.173; live
repros and full analysis in `~/Desktop/claude-code-bug-report.md`):

- The **"Command output was lost: the temp filesystem at …/tasks is full (0MB free) …
  ENOSPC"** banner is **false** — a broken `statfs` (`bsize=0`) computes 0MB on any
  volume. It really means the call produced no stdout and exited non-zero (a lone
  no-match `grep` suffices). Treat it as a plain non-zero exit. Don't chase disk space,
  and don't prefix commands with `rm -rf` of temp dirs (older advice here did; it was
  useless, and the broad `tasks/*` variants can delete live capture files of concurrent
  sessions).
- **Mid-command output truncation** (sections of a compound command silently missing,
  sometimes rendered as success) came from the harness shadowing `grep`/`find`/`rg`
  with embedded tools whose child process can kill the shell. Global mitigations are
  active on this machine (real ripgrep; `--allowedTools Grep,Glob` in the `claude`
  alias; a PreToolUse hook prefixing `unset -f grep find rg`). If truncation
  reappears, re-run via `command grep` / `command find`, and treat missing output as
  unknown — never as "no matches". `screenshot.sh <slug>` and appending progress to a
  real file (then `Read`) remain good stdout-free verification channels.

### Diagnostic fallback (raw xcodebuild)

Useful when `xcbeautify`'s lossy filter drops an early-stage error. Prefer the skill
scripts as the default path so future sessions exercise the skill.

```bash
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 17' build
xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:ConjuguerTests/VerbModelTests
```

### Linting

SwiftLint runs as a **git pre-commit hook** (`.githooks/pre-commit`), not as an Xcode
build phase, so it gates commits without slowing every build. It lints only the staged
Swift files with `--strict`, honoring `.swiftlint.yml`; any violation blocks the commit
(drop `--strict` in the hook to make warnings non-blocking). Enable it once per clone:

```bash
git config core.hooksPath .githooks
```

If `swiftlint` isn't installed the hook prints a warning and lets the commit through.

#### Rules worth pre-empting while writing (so the hook doesn't bounce a commit)

- **`conditional_returns_on_newline`** — a `guard`/`if` that returns must put the `return`
  on its **own line**, never inline. The project keeps this rule on purpose: one-statement-
  per-line makes stepping through control flow in the debugger easier (you can breakpoint
  the `return` itself and see whether the branch was taken). Write:

  ```swift
  guard etymologies == nil else {
    return
  }
  ```

  not `guard etymologies == nil else { return }`. The same applies to `if x { return }`,
  `guard … else { return nil }`, `… else { continue }`, etc. — break the body onto its own
  line. (Seen in practice: an inline `guard … else { return }` passed the build but blocked
  the commit under `--strict`.)

## Architecture Overview

Conjuguer is an iOS app for learning French verb conjugations. It conjugates 6,320 verbs across all French tenses.

### Project Layout (synchronized folders)

The project uses **Xcode synchronized folders** (`PBXFileSystemSynchronizedRootGroup`),
not classic groups: the two target folders `Conjuguer/` and `ConjuguerTests/` are each
synced as a root group, and Xcode mirrors their on-disk contents into the targets by file
type. Practical consequences:

- **Adding a source, test, or resource file requires no `project.pbxproj` edit and no Xcode
  step** — just create the file on disk under the appropriate folder and it is compiled or
  bundled automatically (`.swift` → Sources, asset/`.xml`/`.json`/`.mp3`/etc. → Resources).
  Likewise, deleting a file needs no project edit. This is why new test classes get their own
  files (e.g. `DeeplinkTests.swift`) rather than being appended to an existing file.
- **All test doubles live in the app target** (`TestApp.swift`, `GetterSetterFake.swift`,
  `GameCenterStub.swift`, `ReviewPrompterDummy.swift`, `AnalyticsServiceSpy.swift`,
  `AnalyticsLocaleStub.swift`, `URLProtocolStub.swift`), referenced by `World.swift` for the
  simulator/unitTest configs, so the whole `Conjuguer/` tree compiles into one target.
- The only files inside the synced folders excluded from a target are the per-target
  `Info.plist`s (via `membershipExceptions`); `Conjuguer.entitlements` is wired through
  `CODE_SIGN_ENTITLEMENTS` and is not bundled. Don't add new files under a synced folder that
  should *not* ship — they'd be picked up automatically; exclude them with a membership
  exception or keep them outside the folder.

### Core Domain Model

- **Verb** (`Models/Verb.swift`): Represents a French verb with properties like infinitif, translation, model reference, auxiliary (avoir/être), and frequency data. Stored in a static dictionary keyed by infinitif.

- **VerbModel** (`Models/VerbModel.swift`): Defines conjugation patterns. Models form a hierarchy via `parentId` for inheritance of conjugation rules. Each model specifies stem alterations, endings for different tense groups, and participe endings.

- **Conjugator** (`Models/Conjugator.swift`): The conjugation engine. Takes an infinitif and tense, retrieves the verb and its model, applies stem alterations, and returns the conjugated form. Handles both simple and compound tenses.

- **Tense** (`Models/Tense.swift`): Enum covering all French tenses (indicatif présent, passé composé, subjonctif, etc.). Uses associated values for person/number where applicable.

### Data Loading

Verb and model data is loaded from XML files at app startup via `VerbData.parse()`:
- `verbs.xml` - All 6,320 verbs (frequency-of-use ships inline via each verb's `fr` attribute)
- `verbModels.xml` - Conjugation pattern definitions
- `defectGroups.xml` - Defective verb groups

(`frequencies.xml` is bundled but **not** parsed at startup — the former `FrequencyParser`
was dead code and has been removed; `Verb.maxFrequency` holds the highest rank.)

### Dependency Injection

The `World` pattern (`Utils/World.swift`) provides dependency injection via a global `Current` variable. Three configurations exist:
- `device` - Production with real analytics (AWS Amplify/Pinpoint), GameKit, real URLSession
- `simulator` - Uses test analytics/GameCenter, stubbed URLSession
- `unitTest` - Uses in-memory settings (GetterSetterFake), test doubles

### Protocol-Based Abstractions

All external services have protocol abstractions with production and test implementations, named in the Fowler test-double convention — `…Real` for the production conformer, `…Fake`/`…Stub`/`…Spy`/`…Dummy` for the double:
- `GetterSetter` → `GetterSetterReal` / `GetterSetterFake`
- `GameCenter` → `GameCenterReal` / `GameCenterStub`
- `ReviewPrompter` → `ReviewPrompterReal` / `ReviewPrompterDummy`
- `AnalyticsService` → `AnalyticsServiceReal` (AWS Pinpoint) / `AnalyticsServiceSpy`
- `AnalyticsLocale` → `AnalyticsLocaleReal` / `AnalyticsLocaleStub` (named `AnalyticsLocale`, not `Locale`, to avoid shadowing `Foundation.Locale`)

> **Convention — adding a new behavior protocol with real + test-double conformances.** Name the protocol a **plain role noun** — no `-able`/`-Protocol`/`-ing` suffix (`GetterSetter`, `GameCenter`, `ReviewPrompter`). Name the production conformer `<Protocol>Real` and the test double `<Protocol><Role>`, where `<Role>` is the [Fowler test-double type](https://martinfowler.com/bliki/TestDouble.html) that matches what the double actually *does*:
> - **`Fake`** — a working implementation with a production-unsuitable shortcut, e.g. an in-memory store (`GetterSetterFake`).
> - **`Stub`** — returns canned answers, no real logic (`GameCenterStub`, `AnalyticsLocaleStub`).
> - **`Spy`** — a stub that *also records* how it was called, for assertions (`AnalyticsServiceSpy`).
> - **`Mock`** — pre-programmed with expectations it verifies. **`Dummy`** — fills a slot but is never exercised for its behavior (`ReviewPrompterDummy`).
>
> Because the protocol and all its conformers share a prefix, they **sort together in Xcode's Project Navigator** — the point of the convention (and consistent with the `CatFancy-final` app). One type per file, filename = type name (synced folders bundle them automatically). **Check for a name collision** before settling on the protocol name: the bare noun must be free, so the production type takes `…Real` (the protocol `GameCenter` is only available because the former `GameCenter` class became `GameCenterReal`), and `AnalyticsLocale` avoids shadowing `Foundation.Locale`. Wire the real conformer into `World.device` and the double into `World.simulator` / `.unitTest`. Doubles that conform to a **system** protocol rather than an app one stay outside the scheme — `URLProtocolStub` (Foundation `URLProtocol`) and `TestApp` (SwiftUI `App`, whose real counterpart is `ConjuguerApp`).

### SwiftUI Structure

- **MainTabView**: Root view with 5 tabs (Verbs, Models, Quiz, Info, Settings)
- Uses `@Observable` macro (iOS 17+) for the World class
- Deep linking support via `onOpenURL` for verb/model/info navigation

### Key Utilities

- **Settings** (`Utils/Settings.swift`): User preferences via protocol-based storage (UserDefaults or Dictionary)
- **L** (`Models/L.swift`): Localization strings wrapper
- **SoundPlayer/Utterer**: Audio feedback for quiz interactions

### Literature-Example Corpus (`corpus/`)

`corpus/` holds the pipeline that builds literature example sentences for the app's
~980 **usage-ranked** verbs — one modern-prose example per verb, plus a *Chanson de
Roland* example nested where one exists. It is a build-time data pipeline, **not part
of the shipped app target**; only the finished JSON is bundled.

**Pipeline stages (folders):**

| Folder | Contents | Tracked? | Role |
|---|---|---|---|
| `corpus/originals/` | Domain-tier subfolders of raw sources: `literature/` (PDFs of Proust, Zola, Flaubert + `chanson-roland-oxford.txt`) and `government/` (Swiss/French public-document `.txt`) | **No** | Raw source material — large and re-fetchable |
| `corpus/grokked/` | `chanson.md` | **Yes** | Hand-built parsed intermediate: numbered Old French with the modern infinitive bracketed per line, plus a line-by-line Claude translation |
| `corpus/working/` | tracked build scripts (`build_chanson_examples.py`, `build_corpus_index.py`, `build_tail_index.py`, `build_literature_examples.py`, `mine_examples.workflow.js`); ignored intermediates (`forms.json`, `corpus_index.json`, `tail_index.json`, `shards/`) and `*.md` progress notes | **Mixed** | Build scripts + regenerable intermediates |
| `corpus/json/` | `chanson_examples.json`, `literature_examples.json` | **Yes** | Finished exports, bundled into the app |

**`.gitignore` rule — track only durable artifacts.** The repo tracks finished JSON
(`json/`), the hand-built intermediate (`grokked/`), and the build script
(`working/build_chanson_examples.py`); it ignores the source originals and the `working/*.md`
progress notes. The principle is *reproducibility*: `chanson.md` is irreplaceable manual
transcription/translation and must be tracked, whereas the PDFs are re-fetchable and the
JSON regenerates from `chanson.md` in seconds via the script. (Contrast the sibling app
Konjugieren, which gitignores its *entire* corpus — correct there because its sources are
all downloaded public-domain texts.) When adding files under `corpus/`, remember the
whitelist: anything new under a tracked subfolder is committed automatically; new
ignored content needs a matching `!`/exclude pair.

**`build_chanson_examples.py`** parses `grokked/chanson.md` per laisse, resolves each bracketed
gloss to a canonical `verbs.xml` key (`in="…"`), and writes `json/chanson_examples.json`
keyed by infinitif. It reports coverage and *unmatched* gloss tokens rather than silently
dropping them. This hand-bracket-then-resolve approach suits the one fully-treated poem.

**Modern-prose pass — generated-forms index + subagent select/translate.** The pass over the
novels (and government tier) moves the expensive work *off* the LLM and into deterministic code,
so subagents only do the part that needs judgment. Three stages:

1. **Form dump (`ConjuguerTests/Models/CorpusFormsDumpTests.swift`).** A build-time tool riding the
   test target (so it reuses the app's authoritative `Conjugator` and already-loaded verb data),
   *not* a behavioral test. It conjugates every usage-ranked verb across all tenses/persons and
   writes `working/forms.json` — `{ "<surface form>": ["<verb id>", …] }`. This makes irregulars
   (`veux`/`voulons`/`voudrai` → vouloir) and false substrings (`ancr` in "rancœur") non-issues:
   the index matches whole generated word-forms, not hand-written stem patterns. Run on demand:
   `run_tests.sh --only-testing ConjuguerTests/CorpusFormsDumpTests`. (Compound tenses emit only the
   *participle*, not the auxiliary — else "ai" would map to every avoir-verb and make each "j'ai …"
   a false hit.)
2. **Index build (`build_corpus_index.py`).** ONE tokenizing pass over each source `.txt` (apostrophe-
   and hyphen-splitting, NFC, lowercased), looking every token up in `forms.json`, writing
   `working/corpus_index.json` = `{ "<verb id>": [ {doc, line, token, text}, … ] }`. Candidates are
   gathered from all three novels independently, then merged round-robin with a **per-verb rotating
   lead author** so the first candidate (what selectors reach for) is spread evenly across
   Flaubert/Proust/Zola — not drained from whichever is scanned first; government docs append as
   fallback. Prints coverage, the lead-author balance, and the zero-coverage tail. A token mapping to
   several verbs (homographs: `suis` → être & suivre) is recorded under each; context disambiguates.
3. **Select + translate (`build_literature_examples.py shard` → `mine_examples.workflow.js`).** The
   python `shard` subcommand splits the index into ~30-verb shard files (so each subagent reads only
   its slice, not the 1.1 MB whole). The Workflow fans out one subagent per shard: each picks the
   earliest candidate that is a genuine *verbal* use (rejecting same-spelled nouns like "ancre"),
   re-opens the source at the line for the full clean sentence, and translates it — returning a
   schema-validated array. Write the aggregate to `json/literature_examples.json`, then
   `build_literature_examples.py report <json>` prints the final author balance. Current coverage:
   **974/982 ranked verbs (99.2%)**; the 8 zero-coverage verbs are the technical tail
   (`télécharger`, `reconstruire`, …) for the future technology tier.

**Future work (partially built):** the three novels won't cover the technical tail of the
ranked verbs, so government- and technology-domain fallback corpora (mirroring
Konjugieren's `corpus/government/` and `corpus/technology/` tiers) supplement them under
`corpus/originals/`. The **government** tier now exists (`corpus/originals/government/`,
Swiss/French public documents — see `prompts/get-government-corpus.md` and
`docs/government-corpus-licensing.md`); the modern-prose pass over the literature + government
tiers is **built and run** (stages 1–3 above) — `json/literature_examples.json` currently holds
**951/982** verbs with a balanced example + translation.

**Tail rescue (`build_tail_index.py`).** Verbs whose surface form equals a common noun
(`signer`/`signe`, `programmer`/`programme`) initially came back null because the literature-first
index filled all five candidate slots with *noun* uses, crowding out the *verbal* uses that exist
in administrative/technical prose. `build_tail_index.py` targets just the uncovered verbs
(ranked − placed), rebuilds their candidates from the **government + technology** tiers only, and
**ranks each candidate by how distinctively verbal its token is** (infinitive/participle/gerund/
imperfect over the bare noun-stem form) so the genuine verbal occurrences lead. Re-mining that
tail rescued ~40 verbs from the *existing* government tier with no new sources. It writes shards
directly for `mine_examples.workflow.js`; merge its results back into `literature_examples.json`.

**Technology tier.** `build_corpus_index.py` now recognizes a third `technology` tier
(`corpus/originals/technology/`, same gitignore treatment as the others). It covers the genuine
residual — real tech/news verbs absent from literature *and* government (`télécharger`,
`téléviser`, `reconstruire`, …). Acquire license-clean French tech sources (Swiss NCSC = PD per
Art. 5 URG; French ANSSI/CNIL/cybermalveillance = Licence Ouverte/Etalab — the same legal gate as
the government tier, see `docs/government-corpus-licensing.md`), record them in a tracked manifest,
then re-run `build_tail_index.py` + the workflow. A few residual verbs are inherent form-collisions
(`faillir`↔*falloir*, `plaire`↔"plus", `violer`↔"violent") that no corpus cleanly resolves.
