# Fable 5 vs. Opus 4.8 — Code-Review Eval Analysis

Internal reference. Four Claude Code sessions reviewed the Conjuguer codebase (commit
`32f8478`, 89 Swift files, 8,589 LOC app target) with the same core prompt at two effort
levels per model. This doc compares the four runs on volume, verified accuracy, coverage,
cost, and report craft. Every factual claim in all four reports was **verified against the
codebase** (every cited file read; every dead-code claim grepped; every bug claim traced);
run metrics were **mined from the session transcripts** under `~/.claude/projects/`.

The merged, deduplicated, verified suggestion list lives in
`prompts/code-review-suggestions-union.md`.

---

## 1. Verdict (TL;DR)

- **Fable-max won decisively on substance.** It found **14 of the 15 verified behavioral
  bugs** that exist across all four reports — 8 of them found by *no other session* —
  including the only must-fix user-facing defect (the model-sort preference silently
  resets every launch). It also produced the most complete dead-code inventory (15 of its
  16 rows verified; ~450 lines deletable).
- **Opus found essentially no bugs.** Opus-high found zero; Opus-max found three (one of
  them inside dead code). Both Opus reports are competent *refactoring* reviews — their
  duplication/structure findings are accurate and overlap heavily with Fable's — but they
  read the prompt's "most impactful" as "most lines saved," not "most likely wrong."
- **Effort mattered far more for Fable than for Opus.** Fable went from 21 files read /
  6 bugs (high) to 92 files read / 14 bugs (max), tripling its runtime to do it. Opus
  barely changed shape between high and max (4.5 → 5.6 min) — at high it even delegated
  all exploration to four Haiku subagents and never read a file itself.
- **Nothing was fabricated.** Across ~130 discrete claims, zero were invented. The error
  mode in every report was *overstatement* (inflated counts, overgeneralized patterns),
  and Opus-high — the only session that didn't read the code directly — had the most.
- **Cost: the 2× per-token premium compounded into a 4–7× per-session premium**, because
  Fable also chose to do more work. Fable-max cost ≈ $16.6 vs. Opus-max ≈ $2.3 (list-price
  equivalent). Cost *per verified bug* was nearly flat (≈ $0.8–1.2) across the three
  sessions that found any — but only Fable-max found the bugs that matter.

One-line summary: **Opus told you how to make this codebase prettier; Fable-max told you
where it is wrong.**

---

## 2. What was run (and three confounds)

| | Fable-high | Fable-max | Opus-high | Opus-max |
|---|---|---|---|---|
| Session ID | `011f4899…` | `f0e30976…` | `836b2e45…` | `5048348c…` |
| Model (transcript) | `claude-fable-5` | `claude-fable-5` | `claude-opus-4-8` | `claude-opus-4-8` |
| Started (UTC, Jun 9–10) | 00:16 | 00:27 | 00:59 | 01:04 |
| Output file (as written) | `code-review-suggestions.md` | `code-improvement-suggestions.md` | `code-improvement-suggestions.md` | `code-improvement-suggestions.md` |

All four ran back-to-back against the same tree state in the main repo. Each session chose
its own filename (the prompt didn't specify one); the files were renamed to the
`-<Model>-<effort>` convention afterward.

**Confounds to keep in mind:**

1. **Prompt wording differed slightly.** The Opus sessions got the canonical prompt
   verbatim. The Fable sessions' prompt was prefixed with *"I just got access to
   Anthropic's new Fable model and would like to try it out."* — a possible (mild)
   thoroughness prime. The core ask was identical.
2. **n = 1 per cell.** One run per model×effort combination. Run-to-run variance for this
   kind of task is real (a different run of Opus-max might have read more files, or
   Fable-high fewer). Treat deltas of ±20% on any count as noise; the 2–5× deltas are the
   signal.
3. **The judge is Fable.** This analysis was produced by Fable 5 (max effort) — the same
   model family as two of the contestants — in a session that took 32:49 and used
   543,579 tokens. Mitigation: every comparative claim here rests
   on code-verified facts (does the bug exist at the cited line? is the symbol dead?), not
   on taste. The verification verdicts are reproducible by grep.

---

## 3. Run metrics (from transcripts)

| Metric | Fable-high | Fable-max | Opus-high | Opus-max |
|---|---:|---:|---:|---:|
| Wall clock | 10m 37s | **32m 0s** | **4m 27s** | 5m 35s |
| API calls (main loop) | 17 | 56 | 6 | 14 |
| Subagents spawned | 0 | 0 | **4 (Haiku 4.5 Explore)** | 0 |
| Tool calls (main) | 30 | 128 | 9 | 36 |
| — Read / Bash / Write+Edit | 21 / 8 / 1 | 93 / 33 / 2 | 0 / 3 / 2 (+4 Agent) | 25 / 10 / 1 |
| Unique files Read | 21 | **92** | 0 (subagents: 77) | 25 |
| Output tokens | 22,482 | 65,373 | 9,780 (+13,983 sub) | 23,713 |
| Cache writes (1h TTL) | 127,247 | 227,273 | 43,847 (+138,652 @5m sub) | 116,135 |
| Cache reads | 1.38M | **8.75M** | 0.24M (+1.20M sub) | 1.13M |
| Report length (lines / words) | 415 / 2,319 | 447 / 3,118 | 281 / 1,723 | 313 / 1,888 |

Strategy notes worth more than the raw numbers:

- **Opus-high never read a file.** It split the codebase into four areas (domain models,
  views, utils/infra, localization+tests) and farmed each to an Explore subagent —
  which Claude Code runs on **Haiku 4.5**. Its report is a synthesis of Haiku summaries.
  That's the cheapest and fastest strategy here, and it shows in the output: every
  overclaim in Opus-high (see §8) is the kind of detail you get wrong when you've only
  seen a summary. This is partly a *harness* effect (Claude Code's Explore agents are
  Haiku), not purely a model-capability effect.
- **Opus-max read 25 files directly** — the obviously-central ones — and was rewarded
  with the alunir dead-code bug and an exact `fatalError` census (59 — verified exact).
- **Fable-high read 21 files** in 10 minutes, similar surface coverage to Opus-max, but
  banked different findings (the search bug, `futurStemsRecursive`, ReviewPrompter).
- **Fable-max read 92 of 89+ files** — i.e., effectively everything including tests and
  the XML data — and its report says so ("full read of the app and test targets"). It is
  the only session that opened `defectGroups.xml`, which is where three of its unique
  bugs live (h2p, and the data knowledge behind the dead `FrequencyParser` call).

## 4. Cost (list-price API equivalent)

Prices: Fable 5 $10/$50 per MTok in/out; Opus 4.8 $5/$25; Haiku 4.5 $1/$5. Cache: reads
0.1× input; writes 2.0× (1h TTL, which all four main sessions used) or 1.25× (5m TTL,
which the subagents used). Sessions ran on a subscription, so these are notional
API-equivalent dollars, useful for *ratios* more than absolutes.

| Cost component | Fable-high | Fable-max | Opus-high (incl. subs) | Opus-max |
|---|---:|---:|---:|---:|
| Input | $0.03 | $0.05 | $0.01 | $0.02 |
| Output | $1.12 | $3.27 | $0.24 + $0.07 | $0.59 |
| Cache writes | $2.54 | $4.55 | $0.44 + $0.17 | $1.16 |
| Cache reads | $1.38 | $8.75 | $0.12 + $0.12 | $0.57 |
| **Total** | **$5.08** | **$16.61** | **$1.18** | **$2.35** |

| Efficiency | Fable-high | Fable-max | Opus-high | Opus-max |
|---|---:|---:|---:|---:|
| Distinct suggestions (deduped, sub-items counted) | 27 | **53** | 26 | 24 |
| Verified behavioral bugs (of 15 total) | 6 | **14** | 0 | 3 |
| $ / suggestion | $0.19 | $0.31 | $0.05 | $0.10 |
| $ / verified bug | $0.85 | $1.19 | — | $0.78 |
| Minutes / verified bug | 1.8 | 2.3 | — | 1.9 |

Two readings of the same table:

- **Per unit of *finding*, costs converge.** Among sessions that found bugs at all,
  a verified bug cost ≈ $0.80–1.20 and ≈ 2 minutes regardless of model. The premium
  bought *more* findings, not cheaper ones.
- **The per-token premium compounds.** Fable costs 2× per token, but Fable-max cost 7.1×
  Opus-max — because the more capable model *chose* to read 3.7× more files, think
  longer, and write 2.8× more output. When you buy Fable for a task like this you are
  implicitly buying its appetite, not just its rate card. (Most of Fable-max's bill is
  cache reads — the tax for dragging 92 files through context repeatedly.)

---

## 5. What they found — volume and kind

Distinct actionable items per report (sub-items expanded, intra-report duplicates merged):

| Category | Opus-high | Opus-max | Fable-high | Fable-max |
|---|---:|---:|---:|---:|
| Verified behavioral bugs | 0 | 3 | 6 | **14** |
| Dead-code items | 0 | 6 | 6 | **16** (15 verified) |
| Duplication / structure refactors | ~12 | ~10 | ~11 | ~12 |
| Smells / modernization / polish | ~9 | ~5 | ~4 | ~17 |
| Test-coverage gaps | 5 | 0 | 0 | 4 |
| **Total** | **26** | **24** | **27** | **53** |

The refactoring core — the middle of the table — is nearly the same list in all four
reports: Quiz's 13 copy-pasted cycling decks, `Tense`'s four 17-case switches, the
shorthand-codec switch in `StemAlteration`, `Settings`' load/persist boilerplate, the
ending-group enums as code-instead-of-data, browse-view duplication. Any single session
would have given you that core. What separates them is everything *around* it.

## 6. The verified-bug scoreboard

Fifteen behavioral defects were claimed across the four reports; all fifteen verified as
real against the code (details and line numbers in the union file). ✅ found and called a
defect; ◐ flagged as suspicious without confirming; — missed.

| # | Verified bug | OH | OM | FH | FM |
|---|---|:-:|:-:|:-:|:-:|
| 1 | `modelSort` pref never survives relaunch (writes case name, reads rawValue) | — | — | — | ✅ |
| 2 | Browse search is case/diacritic-sensitive (`etre` ≠ `être`) | — | — | ✅ | ✅ |
| 3 | Quiz scoring leaks accent-stripping across alternate answers (`pàie` → full credit) | — | — | — | ✅ |
| 4 | `DefectGroup` `h2p` marks wrong impératif-passé row (live via group 8 → *clore*) | — | — | — | ✅ |
| 5 | ModelView endings grid passes local, not recursive, alterations | — | — | — | ✅ |
| 6 | ReviewPrompter freezes `Date()` at construction | — | — | — | ✅ |
| 7 | ReviewPrompter constructs a second live `Settings` (DI bypass) | — | — | ✅ | ✅ |
| 8 | `futurStemsRecursive` always trims `stems[0]` regardless of which stem matched | — | ◐ | ✅ | ✅ |
| 9 | `futurStemsRecursive` reads parent's *local* alterations (grandparent `sf` dropped) | — | — | — | ✅ |
| 10 | `sorted(by: >=)` violates strict-weak-ordering (UB) | — | — | — | ✅ |
| 11 | Stem-alteration labels iterate a `Set` → nondeterministic display order | — | — | — | ✅ |
| 12 | `printConjugations` ignores its parameter, hardcodes `"alunir"`, shadows the param | — | ✅ | ✅ | ✅ |
| 13 | Quiz decks pre-increment → element 0 of every pool skipped on first lap | — | ✅ | ✅ | ✅ |
| 14 | `VerbView.shouldShowVerbHeading` stored but never read — 3 call sites pass `true` to no effect | — | — | ✅ | — |
| 15 | `Quiz.gameCenter` injected but never read (`completeQuiz` uses `Current.gameCenter`) | — | — | — | ✅ |
| | **Total** | **0** | **3** | **6** | **14** |

Notes:

- Bug 1 is the only *every-user, every-launch* defect in the set, and it took the most
  expensive session to find it. The mechanism (string-interpolating an enum on write,
  `rawValue` lookup on read, raw values capitalized) requires holding three files in mind
  at once — exactly the kind of cross-file inference that distinguishes a deep read from
  a skim. Fable-max also correctly identified why `verbSort` escapes the same bug (its
  raw values equal its case names by luck).
- Bug 4 required reading the *data file*: the buggy `h2p` arm only fires if some defect
  group actually uses `h2p` in `doesntUse`. Group 8 does (verb: *clore*). No other
  session opened `defectGroups.xml`.
- Bug 14 (Fable-high's unique) is the inverse case: FH noticed `InfoView` honors its
  `shouldShowInfoHeading` while `VerbView` ignores its equivalent. Fable-max — for all
  its thoroughness — missed it, which is the concrete proof that even a 92-file read
  isn't exhaustive, and the union of reports beats any single one.
- Opus-high's report opens with "Nothing here is a known crash in normal use" — a scope
  note that aged poorly given bugs 1–4 were sitting in the files its subagents
  summarized.

## 7. Coverage overlap

Cluster-level view of the ~40 deduplicated finding clusters in the union file:

| Found by | Clusters | Examples |
|---|---:|---|
| All 4 sessions | 5 | Quiz cycling decks; `Tense.personNumber` switches; shorthand decode switch; Settings boilerplate; ending-groups-as-data |
| Exactly 3 | 7 | debug-dump duplication; core dead-code set; off-by-one; typo cluster; diacritic consolidation; fatalError policy; browse-view duplication |
| Exactly 2 | ~8 | search bug (FH+FM); ReviewPrompter (FH+FM); parser scaffold (OH+FM); parent-chain resolver (OH+FM); `Verb.id = UUID()` (FH+FM); quiz-question tuples (FH+FM) |
| Unique to one | ~20 | see below |

Unique-find counts (clusters no other session surfaced): **Fable-max 13** (eight bugs,
`FrequencyParser`+9 more dead-code rows, Imparfait ≡ ConditionnelPrésent byte-identical,
strings-as-data endings round-trip, analytics-hook modifier, model-layer `Current`
bypass, `CLAUDE.md` verb-count discrepancy), **Opus-high 5** (L.swift → String Catalog,
`none`/`NONE` sentinels, `Double`/`Int` extension nits, the generated-`VerbModelTests`
critique, `CompoundTenseTests`/`DeeplinkTests` critiques), **Fable-high 5**
(`shouldShowVerbHeading`, VerbView recompute-per-init, additive-scan helper,
`Character("")` trap pattern, valid-endings list duplication), **Opus-max 4**
(`handleURL` near-dup, dictionary mutation-while-iterating style note,
`maxIrregularityCount = 41` magic number, swallowed `catch` in `verbsWithDeepLinks`).

So: the consensus core is real and would have been found for $1.18. Roughly half the
total value of the eval — and nearly all the *correctness* value — lives in the unique
finds, and 13 of those 22 belong to Fable-max.

## 8. Accuracy audit — claims that didn't survive cleanly

No report fabricated anything. These are the overstatements/misclassifications found
during verification (also listed as corrections in the union appendix):

| Report | Claim | Reality |
|---|---|---|
| Opus-high | "The three Browse views are the same view three times" (incl. Info) | `InfoBrowseView` has no picker, no search, no `updateSearchResults` — only the nav scaffold matches. FH/FM framed it correctly as 2 views + a future third. |
| Opus-high | `StemAlteration.init` is "a 60+ case shorthand-decoding switch" | 42 cases (~104 lines). |
| Opus-high | "Five identical 'resolve up the parent chain' properties … else `fatalError`" | Only 3 of 5 `fatalError`; `stemAlterationsRecursive` *merges* the chain (different shape) and `participeEndingRecursive` falls back to `""`. The proposed single generic resolver would change behavior if applied naively. |
| Opus-high | Fix Settings boilerplate with "a `@SettingsPersisted` property wrapper" | Property wrappers don't compose with `@Observable`. Both Fable reports explicitly flagged that constraint and proposed helper methods instead. |
| Opus-high | InputView "business logic living in the view" ranked #5 | `InputView` is `#if DEBUG`-only (maintainer tool, never ships). No report noticed, but OH's *ranking* leaned on it hardest. |
| Opus-max | `for model in models { models[…]?… }` "works only because they mutate values, not structure — fragile" | Legal, well-defined Swift (iteration runs over a value-semantic copy); a style nit, not fragility. Cleanup suggestion still fine. |
| Fable-high | Debug dump = "nine consecutive copy-pasted blocks" | Eleven (FM counted correctly). |
| Fable-high + Fable-max | `bonusForElapsedTime` "is the linear function `max(0, 450 − 50·((t−1)/60))`" | Off by one bracket: formula yields 350 at t=121; table says 400. Correct form: `400 − 50·((t−121)/60)` for t>120, clamped at 0. Both Fable reports made the same arithmetic slip. |
| Fable-max | `StemAlteration.init` "~100 cases" | 42 cases (~109 lines — right if "cases" meant lines). |
| Fable-max | Analytics `.onAppear` hook: "nine occurrences" | Ten. |
| Fable-max | `Utterer.defaultLocaleString` listed under *dead code* | It's referenced by `Utterer.setup()`. The real issue (duplicate of `englishLocaleString`) stands; the dead classification doesn't. |

Pattern: Opus-high's misses are *structural* (wrong shape of the code — the cost of
reviewing via subagent summaries); the Fable misses are *numeric* (counts off by one or
two, an arithmetic slip in a parenthetical). The lone proposed-fix errors that would
actually misbehave if applied blind: OH's resolver/property-wrapper suggestions, and the
Fable pair's bonus formula.

## 9. Citation precision spot-checks

Verified-exact citations (a sample of the ones checked):

- **Opus-max:** "59 occurrences" of `fatalError` in the app target — grep says exactly
  59. Line cites `Conjugator.swift:244-253`, `VerbConjugations.swift:123-130`,
  `World.swift:146-151`, `PasseSimpleGroup.swift:114-120, 202-208` — all exact.
- **Fable-max:** `L.swift:604, 613` (bare `"alphabetical"` keys), `RatingsFetcher.swift:14`
  ("initializaed"), `QuizVerbs.swift:25`, `VerbView.swift:116` (`maxFrequency`'s only
  caller), `ModelView.swift:169-172` and `:224-233`, `VerbModelTests` = 5,530 lines
  (exact wc) — all exact.
- **Fable-high:** `Conjugator.swift:62, 181, 215` (the `Character("")` trap),
  `QuizView.swift:135-136`, `Verb.swift:102` + `InputView.swift:90` (duplicated endings
  array) — all exact.
- **Opus-high:** "89 Swift files, ~8,600 LOC" (89 / 8,589 — exact), "L.swift — 618 lines"
  (exact), `AnalyticsLocale.swift:24`, `RealAnalyticsLocale.swift:12-13` — exact.

All four cite accurately when they cite. The difference is what they chose to look at.

## 10. Did each report's own "most impactful first" ordering hold up?

The prompt asked for impact ordering. Grading each report's #1–#3 against what
verification says actually matters:

- **Fable-max: best alignment.** It restructured the whole report around the principle
  ("they affect real behavior, so they outrank any pure-style item") and put the
  persistence bug at 1.1. Its §1 is exactly the list a maintainer should fix first.
- **Fable-high: good.** Quiz boilerplate #1 and dump-dup #2 are line-count plays, but the
  user-facing search bug appears at #3 and its closing paragraph explicitly calls it "the
  best user-visible quick win."
- **Opus-max: reasonable.** Its #1 (a `conjugatedString` helper to kill the
  Result-unwrap boilerplate) is a genuinely high-leverage enabler, and dead code at #3 is
  honest sequencing. No bugs to rank because it found few.
- **Opus-high: weakest.** Pure maintainability ordering, plus an explicit (and wrong)
  assurance that nothing behavioral lurked. Also ranked the DEBUG-only `InputView` at #5.

## 11. Did model choice matter?

At equal effort, yes — in kind, not just degree:

- **Quantity:** roughly equal at high (27 vs 26 items); Fable 2.2× at max (53 vs 24).
- **Kind:** every Opus finding is about *shape* (duplication, structure, style); Fable
  found shape *plus* behavior. The bug scoreboard is 20-to-3 in Fable's favor across
  effort levels.
- **Depth of inference:** the Fable-only finds share a signature — they require chaining
  facts across files (write path vs. read path vs. raw-value declarations; XML data vs.
  parser arm; loop variable vs. mutation target). Opus's findings are mostly visible
  within a single screen of code.
- **Strategy:** Opus-high delegated; everything else read directly. Whether that's
  "Opus 4.8 at default effort prefers delegation" or a one-off roll, it materially capped
  what the $1.18 bought — its inputs were Haiku summaries.
- **Same-model overlap is high but not nesting:** Fable-max found 13 of Fable-high's 15
  significant clusters plus 30 more; the two misses (e.g. `shouldShowVerbHeading`) prove
  max isn't a strict superset of high even within a model.

## 12. Did effort matter?

- **For Fable, enormously.** high → max: 3× wall clock, 4.4× files read, 2× suggestions,
  6 → 14 bugs, +9 dead-code items, plus the only test-target read. Max effort changed
  *behavior* (read everything, including data files and CLAUDE.md), not just verbosity.
- **For Opus, marginally.** high → max: +1 minute, subagents → direct reads (25 files),
  0 → 3 bugs, comparable item count, slightly sharper citations. The strategy change
  (delegate vs. read) is the biggest visible difference, and it plausibly *is* the effort
  knob expressing itself — but the output ceiling moved only a little.
- Cross pairing worth noting: **Fable-high ≥ Opus-max** on bug yield (6 vs 3) at 2.2× the
  cost and 2× the wall clock. If the budget question is "cheapest way to find real
  defects," Fable-high was the efficiency sweet spot in this sample; Fable-max was the
  completeness play.

## 13. Report craft (style, structure, usability)

- **Structure:** FM's bugs → duplication → smells → dead code → tests → polish taxonomy
  is the most actionable; OM/OH's single ranked list reads better top-to-bottom; FH's
  flat list with a closing "first move" paragraph is a good middle.
- **Fix sketches:** all four include compilable-looking Swift sketches. FM's are the most
  careful about constraints (notes the `@Observable`/property-wrapper conflict, proposes
  the keypath-based resolver with the name string for the error). OH's sketches are the
  most likely to need rework (resolver, property wrapper).
- **Honesty markers:** FM uniquely closes with a verification disclaimer ("verified by
  code inspection only — each deserves a confirming test"). OM uniquely confirms its
  dead-code list was grepped ("Confirmed unreferenced (grepped the whole tree)") — and
  the grep claims held.
- **Length efficiency:** words per distinct item: OH 66, OM 79, FH 86, FM 59. Fable-max
  is simultaneously the longest report and the *densest*.

## 14. Choosing Fable vs. Opus (and effort) for this kind of work

Pricing reality: Fable 5 = $10/$50 per MTok vs. Opus 4.8 = $5/$25 — 2× per token, and in
practice 4–7× per session on open-ended review because Fable works the task harder.
Claude Code's default effort for these models is `xhigh` (untested here); this eval
bracketed it with `high` and `max`.

| Task | Recommendation | Why (from this eval's evidence) |
|---|---|---|
| "Find anything actually wrong" — correctness audit, pre-release sweep, unfamiliar code | **Fable, max effort** | The only configuration that found the persistence bug, scoring bug, and data-dependent display bugs. Nothing else came close; $17 is cheap against one shipped defect. |
| Routine tidy-up list, "what should I refactor next" | **Opus, high or max** | The refactoring core was consensus across all four; Opus delivers it for $1–2.50 in ~5 min. Don't pay 7× for the same Quiz-decks finding. |
| Best bug-per-dollar on a budget | **Fable, high** | 6 verified bugs incl. the search UX defect for ~$5 in ~11 min. |
| Repeated/CI-style review cadence | Opus (or smaller) for the cadence; **periodic Fable-max deep pass** | The two reviews are complementary: shape weekly, behavior quarterly. |
| Anything where the model picks its own strategy | Prefer max/xhigh effort on either model | The one delegated-exploration run (Opus-high) was the weakest on substance and the most error-prone on detail. If using high effort, consider prompting against subagent delegation for review tasks. |
| Judging/synthesis of others' findings (like this doc) | Either; verification matters more than model | All four were factually reliable when they had actually read the code. Make whatever model you use *verify against source*. |

Heuristic that fits the data: **the Fable premium is justified exactly when a missed
finding is expensive** — bugs, security, data integrity. When the cost of a miss is "we
refactor it next month instead," Opus's list is the same list.

## 15. Limitations

- Single run per cell; no variance estimate.
- "Impact" rankings encode my judgment of this app's priorities (correctness > UX >
  maintainability) — defensible but not the only weighting.
- Costs assume list pricing and the observed cache-TTL mix; actual subscription
  accounting differs.
- Effort level isn't recorded in transcripts; the high/max labels come from the session
  setup (file naming), corroborated by the volume/duration patterns.
- The judge-is-Fable bias mitigations are described in §2; the raw materials (four
  reports, transcripts, code) remain available for an independent re-grade.

## 16. Pointers

- Transcripts: `~/.claude/projects/-Users-josh-Desktop-workspace-Conjuguer/<session-id>.jsonl`
  (IDs in §2; Opus-high's four Haiku subagent transcripts are under
  `836b2e45…/subagents/`).
- Source reports: `prompts/code-review-suggestions-{Opus,Fable}-{high,max}.md`.
- Merged + verified suggestion list with implementation order:
  `prompts/code-review-suggestions-union.md`.
