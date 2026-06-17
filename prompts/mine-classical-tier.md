# Mine the "classical" tier (La Fontaine + Molière) for the 144 Chanson-only verbs

Clean-session prompt. **Context:** the modern-prose mining is done — `corpus/json/literature_examples.json`
covers all **982 usage-ranked** verbs. Separately, `corpus/json/chanson_examples.json` attaches an
Old-French *Chanson de Roland* example to **332** verbs. **144** of those Chanson verbs are *not* in
the ranked 982, so they currently have a Chanson example but **no modern example**. They're special
verbs (archaic reflexes the poem actually contains) and the owner wants to honor each with a modern
example below the Chanson one.

A new **`classical` corpus tier** (17th-c. French: La Fontaine's *Fables* + Molière's *Œuvres
complètes*) was added to bridge the gap between *Roland* (~1100) and the existing 19th-c. novels. A
smoke test already proved it works. **This task: run the real mine over the 144, merge results, and
author the residue.**

```
Read @CLAUDE.md (the "Literature-Example Corpus" section) and @prompts/mine-classical-tier.md, then
mine the new corpus/originals/classical/ tier (La Fontaine + Molière) for modern example sentences
for the 144 Chanson-only verbs (Chanson example but not in the ranked 982). Write a provenance
manifest, regenerate forms_all.json, build a target index over the classical tier ranked by
distinctively-verbal tokens, fan out subagents to select + translate (rejecting noun/homograph
uses), merge into corpus/json/literature_examples.json keyed by verb id, and author the archaic
residue. Use the Workflow tool / subagents for the fan-out to keep token cost down.
```

## The 144 target set — recompute it, don't trust a hand-copied list

```python
import json
ch  = json.load(open("corpus/json/chanson_examples.json"))
lit = json.load(open("corpus/json/literature_examples.json"))
targets = sorted(v for v in ch if v not in lit)   # 144 verbs
```

These keys are **bare infinitives** (`occire`, `quérir`, `gésir`, …). Note the verb-id gotcha below.

## What already exists

- **`corpus/originals/classical/`** (gitignored, like all `originals/`): five Project Gutenberg
  plain-text files, all **public domain**, 19th-c. Garnier editions (so **modern orthography** —
  matches the app's generated forms; this was the key risk and it's clear):
  - `lafontaine-fables.txt` (Gutenberg #56327) — **the workhorse**, most hits.
  - `moliere-oeuvres-t1.txt … t4.txt` (#40086, #43535, #50173, #57270).
- **`corpus/working/forms_all.json`** (gitignored, regenerable): `{ "<surface form>": ["<verb id>", …] }`
  over **all ~6,320 verbs** — needed because the canonical `forms.json` only has the ranked 982 and
  these 144 are *un*ranked. Produced by `ConjuguerTests/Models/CorpusFormsDumpTests.testDumpAllVerbForms`.
- **`corpus/working/smoke_test_classical.py`**, **`smoke_normalize_probe.py`** (gitignored): the
  throwaway probes that produced the numbers below. Reuse or delete.

### Smoke-test results (what to expect)

- **Raw coverage: 99/144** get a token hit in the classical tier.
- **~20 of those 99 are homograph false positives** — the matched token is a noun/pronoun/adjective,
  not the verb. The selection step **must reject these** and dig for a genuine verbal use (or fall
  through to authoring). Known false-positive leads:
  `angoisser→angoisses`, `baiser→(noun)`, `bouter→boutons`, `brocher→broche`, `celer→cela`,
  `conter→content`, `corner→cornes`, `déserter→désertes`, `escrimer→escrime`, `fier→(adj)`,
  `forfaire→forfait`, `gésir→jus`, `luire→lui`, `mater→mata`, `muer→mue`, `nombrer→nombre`,
  `poindre→point`, `priser→prise`(prendre), `rayer→rayons`, `secourir→secours`, `seoir→soit`(être),
  `sourdre→sourds`, `traire→trait`. **Genuine verbal yield ≈ 75.**
- **45 hard misses** (no token at all in the tier) — mostly genuinely archaic, likely **authoring
  candidates**:
  `adouber affermer affiler affubler appareiller arguer attarder blêmir ceindre chaloir charrier
  cingler clamer corroyer crouler déclore déjeter démailler démener détordre embattre embroncher
  empenner enfreindre enluminer enquérir ester fiancer flamber froisser gemmer gracier guerroyer
  honnir jouter lacer navrer occire quérir rallier reluire remembrer repairer saillir éclisser`.
- The pre-1740 `-oit` spelling in La Fontaine (`étoit`, `avoit`) costs only ~2 of the 144 (those
  forms belong to common verbs already ranked), so **don't bother normalizing orthography.**

## Two gotchas that will waste your time if you miss them

1. **Verb-id normalization.** `forms_all.json` keys verbs by `infinitifWithPossibleExtraLetters`
   (e.g. `"haïr (France)"`, `"haïr (Québec)"`), but `chanson_examples.json` /
   `literature_examples.json` use the **bare infinitive** (`"haïr"`). Strip a trailing `" (…)"` with
   `re.sub(r"\s*\(.*\)$", "", vid)` before intersecting, or you'll silently drop every regional/
   disambiguated verb (this hid `haïr`, `ouïr`, … in the first smoke run).
2. **Stale incremental compilation when (re)generating `forms_all.json`.** `run_tests.sh
   --only-testing ConjuguerTests/CorpusFormsDumpTests` may report "Executed 0/1 tests" and silently
   reuse a cached test binary that lacks `testDumpAllVerbForms`. Fix: delete the test intermediates
   first, then run:
   ```bash
   DD=$(xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer -showBuildSettings | awk '/ BUILD_DIR =/{print $3; exit}')
   rm -rf "$(dirname "$DD")"/Intermediates.noindex/Conjuguer.build/*/ConjuguerTests.build
   "$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/CorpusFormsDumpTests/testDumpAllVerbForms
   ```
   Expect `~6,320 verbs → ~226,618 distinct forms`.

## Tasks

1. **Provenance manifest** — create `docs/classical-corpus-sources.md` (mirror the other
   `docs/*-corpus-sources.md`). Record: La Fontaine *Fables* (Gutenberg #56327), Molière *Œuvres
   complètes* T1–T4 (#40086/#43535/#50173/#57270); all **public domain** via Project Gutenberg;
   19th-c. Garnier editions (modernized spelling). License = PD → courtesy attribution only (no
   CC/Etalab obligations, unlike the wikipedia/government tiers).

2. **Register the tier in the scripts.** Add `"classical"` to the `TIERS` tuple in
   `corpus/working/build_corpus_index.py` **and** `build_tail_index.py`. Put it right after
   `literature` in priority (it's the closest register to the novels).

3. **(Re)generate `forms_all.json`** via the test in the gotcha box above.

4. **Build a target index for the 144 over the classical tier.** Adapt **`build_tail_index.py`**
   (it already targets a specific uncovered-verb set, ranks candidates by *how distinctively verbal*
   the token is — infinitive/participle/gerund over a bare noun-homograph stem, which is exactly the
   defense against the homograph problem above). Point it at: target set = the 144; forms =
   `forms_all.json` (not `forms.json`); tiers = `classical` (optionally append government/technology/
   wikipedia as fallback for stragglers). It writes shards for the workflow.

5. **Select + translate (fan out — use the Workflow tool or subagents).** Run
   `corpus/working/mine_examples.workflow.js` (or equivalent) over the shards. Each subagent, per
   verb: pick the earliest candidate that is a **genuine verbal use** (reject the noun/adjective/
   pronoun homographs — pass it the false-positive list above as guidance), re-open the source file
   at the line for the full clean sentence, and translate to English. Return schema-validated
   `{fr, en, source, line, token}`. **This is the token-heavy step — that's why it's a fan-out, not
   inline.**

6. **Merge into `corpus/json/literature_examples.json`**, keyed by **verb id** (bare infinitive for
   these). `source` = `lafontaine-fables.txt` or `moliere-oeuvres-tN.txt`, with the 1-based `line`.
   The file then covers the ranked 982 **plus** these special verbs; note that in a comment / the
   CLAUDE.md corpus section. (The app shows examples keyed by verb id and nests the existing Chanson
   example beneath — so each of the 144 ends up with modern + Chanson, exactly the goal.)

7. **Author the residue.** For verbs with no genuine verbal use in the classical tier (the archaic
   misses + any homograph-only hits the selectors reject) — `occire`, `quérir`, `ester`, `chaloir`,
   `gésir`, etc. — write original example sentences, `"source": "Claude (Opus 4.8)"`, `"line": null`,
   exactly as the existing 19-verb tail did. Log each in `docs/authored-examples.md` (or a new
   `docs/classical-authored.md`) with why authoring was needed. **Don't** attribute an authored
   sentence to a corpus.
   - **Optional, only if the owner opts in:** the truly-archaic stragglers could instead be mined
     from Villon/Rabelais — but their pre-1635 orthography (`estre`, `congnoistre`) won't match the
     modern generated forms, so that path needs normalized-spelling editions. Authoring is the
     default; flag this as a knob (below).

8. **Report final coverage** — how many of the 144 got a classical example vs. authored, and the
   La Fontaine/Molière split. Run any `report` subcommand the scripts provide.

## Cross-dependency with the app-wiring prompt

`prompts/wire-examples-into-app.md` consumes `literature_examples.json` and has a **source taxonomy
table** for attribution + Credits. Adding `lafontaine-…` / `moliere-…` introduces **new source
prefixes** — add a row to that table (both = public domain, courtesy credit, no license text
required) and to `docs/classical-corpus-sources.md`. If the app wiring hasn't been done yet, just
make sure the new prefixes are documented so that task picks them up.

## Guardrails

- **Don't regenerate the existing 982** — this task only *adds* the 144's keys. If one reads poorly,
  hand-edit that single JSON entry.
- **`corpus/` is outside the app target.** New scripts/intermediates under `corpus/working/` are
  gitignored; the durable outputs that get committed are `corpus/json/literature_examples.json`, the
  new `docs/classical-corpus-sources.md`, and the script edits. The raw `corpus/originals/classical/`
  `.txt` stay gitignored (re-fetchable from Gutenberg).
- **Token budget is the whole reason this is a fresh session** — do the per-verb select/translate as
  a subagent fan-out (Workflow tool), not in the main loop. Don't read the 0.5 MB source files into
  the main context; the index + shards exist precisely so subagents read only their slice.
- **ios-build-verify skill** for the one build/test you need (the `forms_all.json` dump). Mind the
  stale-compile gotcha.

## Acceptance criteria

- `docs/classical-corpus-sources.md` exists and attributes both works (PD/Gutenberg).
- `build_corpus_index.py` + `build_tail_index.py` recognize the `classical` tier.
- `corpus/json/literature_examples.json` gains an entry for **all 144** verbs — classical-mined where
  a genuine verbal use exists (target ≈ 75), authored otherwise — each with `fr`, `en`, `source`,
  `line`, `token`, AI-authored ones marked `"Claude (Opus 4.8)"` / `"line": null`.
- A coverage report states the classical-vs-authored split. No homograph noun/adjective sentences
  slipped through as "verbal" examples (spot-check the ~20 known false-positive verbs).

## Knobs (decide with the owner if unsure)

- **Output location** — extend `literature_examples.json` (recommended: one file, app shows by verb
  id) vs. a separate `chanson_verb_examples.json`. Extending is simplest and matches how the app
  looks examples up.
- **Residue strategy** — author the archaic stragglers (default, fast, explicit AI attribution) vs.
  add a Villon/Rabelais sub-tier with normalized orthography (richer, closer to *Roland*, but real
  preprocessing work). Recommend authoring now; Villon/Rabelais as a later enhancement.
- **Fallback tiers for stragglers** — whether step 4 also draws government/technology/wikipedia
  candidates for the 144 before authoring (cheap, might rescue a few technical-register verbs), or
  stays classical-only for register purity.
