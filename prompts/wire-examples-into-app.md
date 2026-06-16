# Wire the literature examples into the app (VerbView + Credits)

Clean-session prompt. The example-mining pipeline is **done** — `corpus/json/literature_examples.json`
now holds one example sentence + English translation for **all 982 usage-ranked verbs (100 %)**.
This task is purely app-side: surface each verb's example in `VerbView` (below the etymology
section), attribute every source correctly, and reproduce the licenses that require it on the Info
screen's Credits blurb. **No corpus/pipeline work — do not re-run mining.**

```
Read @CLAUDE.md (esp. the "Literature-Example Corpus" section) and the four provenance manifests
(docs/government-corpus-sources.md, docs/technology-corpus-sources.md, docs/wikipedia-corpus-sources.md,
docs/authored-examples.md), then wire corpus/json/literature_examples.json into the app: show each
verb's example below the etymology in VerbView, attribute sources, and add the required credits +
licenses to the Info screen. Build, test, and verify in the simulator with the ios-build-verify skill.
```

## What already exists (the data)

**`corpus/json/literature_examples.json`** — a JSON object keyed by **verb id** (the verbs.xml
`in=` value = `Verb.infinitifWithPossibleExtraLetters`; bare infinitive for almost all verbs, but
a few are `"sortir (obtain)"`-style). Each value:

```json
"reconstruire": { "fr": "…le centre-ville a été reconstruit…", "en": "…the city centre was rebuilt…",
                  "source": "wp-le-havre.txt", "line": 59, "token": "reconstruit" }
```

`fr` = the French example sentence, `en` = its English translation, `source` = the origin (see
taxonomy below), `line` = 1-based line in the (gitignored) source `.txt` or `null` for authored,
`token` = the conjugated form that occurs.

### Source taxonomy (drives both per-example attribution and the Credits/licenses)

| `source` prefix | Origin | License | Attribution needed? |
|---|---|---|---|
| `proust-…`, `zola-…`, `flaubert-…` | Proust *Du côté de chez Swann* (1913), Zola *L'Assommoir* (1877), Flaubert *Madame Bovary* (1857) | Public domain | Courtesy credit |
| `ch-…` (not `ch-ncsc-…`) | Swiss federal/cantonal public documents | PD — Art. 5 URG | Courtesy credit |
| `fr-…` | French government agencies (ADEME, CNIL, ANSSI, INSEE, France Stratégie, CEREMA, …) | **Licence Ouverte / Etalab 2.0** | **Required** (attribution + license) |
| `ch-ncsc-…` | Swiss OFCS/NCSC cyber/IT guides | PD — Art. 5 URG | Courtesy credit |
| `wp-…` | French Wikipedia articles | **CC BY-SA 4.0** | **Required** (attribution + license + share-alike) |
| `Claude (Opus 4.8)` | 19 original AI-authored examples (the verbs no corpus covered) | — | **Credit Claude** |

The manifests under `docs/` map each `source` filename → human title + URL + license. Use them to
build the display-attribution lookup; **`docs/authored-examples.md`** lists the 19 Claude-authored
verbs and why each needed authoring.

## Tasks

1. **Bundle the JSON.** `corpus/` is *outside* the app target (the synced-folder roots are
   `Conjuguer/` and `ConjuguerTests/` only — see CLAUDE.md). So copy
   `corpus/json/literature_examples.json` to somewhere under `Conjuguer/` (e.g.
   `Conjuguer/Resources/literature_examples.json` or alongside `Conjuguer/Models/verbs.xml`) so the
   synced folder auto-bundles it — **no project.pbxproj edit needed.** Note in a comment that
   `corpus/json/…` is the canonical pipeline output and the bundled copy must be refreshed if the
   corpus is regenerated. (Don't ship the raw `corpus/originals/` `.txt` — they're gitignored.)

2. **Model + loader.** Add an `Example` model (`fr`, `en`, `source`, `token`, optional `line`) and a
   loader that decodes the bundled JSON into a `[String: Example]` keyed by verb id, mirroring the
   existing data-load pattern (`VerbData`/`VerbParser`, `Utils/VerbData.swift`). Decide eager
   (alongside `VerbData.parse()`) vs. lazy; eager is simplest given the small file. Look up an
   example by `verb.infinitifWithPossibleExtraLetters` (fall back to `verb.infinitif`).

3. **VerbView UI — below etymology.** In `VerbView` (the verb detail screen), add an **Example**
   section *below the existing etymology section*. Show the French sentence, the English
   translation, and a small **per-example attribution line** derived from `source` (e.g.
   *« — Proust, Du côté de chez Swann »*, *« — Wikipédia, "Le Havre" (CC BY-SA 4.0) »*, *« — exemple
   rédigé par Claude (Opus 4.8) »*). Per-use attribution is good UX and helps satisfy the CC BY-SA /
   Etalab attribution terms at point of display. Every verb has an example, so no empty-state is
   strictly required, but guard for a missing key gracefully.
   - **Reference (non-binding):** Konjugieren's `VerbView` shows example sentences similarly — see
     `/Users/josh/Desktop/workspace/Konjugieren` (find its `VerbView`/example UI). It's a sibling
     German app with the same architecture; borrow layout ideas, don't copy verbatim.
   - **Optional, secondary:** where `corpus/json/chanson_examples.json` has an entry for the verb,
     the established design nests an Old-French *Chanson de Roland* example beneath the modern one.
     Wire it only if straightforward; the modern example is the priority.

4. **Credits + licenses on the Info screen.** The Info screen has a Credits blurb (find the Info
   model / `InfoView` / the rich-text Credits entry — deep link `conjuguer://info/…`). Add a
   **"Sources & licences des exemples"** section that:
   - Credits the literary authors/works (PD), Swiss authorities (PD — Art. 5 URG), and French
     agencies (Licence Ouverte/Etalab) — list the agencies from `docs/government-corpus-sources.md`.
   - For **Wikipedia (CC BY-SA 4.0):** name the articles used (from
     `docs/wikipedia-corpus-sources.md`) or link them, state CC BY-SA 4.0 with a link
     (https://creativecommons.org/licenses/by-sa/4.0/), and include the **share-alike** notice.
   - For **Etalab:** attribute and link the Licence Ouverte 2.0
     (https://www.etalab.gouv.fr/licence-ouverte-open-licence/).
   - **Credit Claude (Opus 4.8)** for the 19 authored example sentences
     (per `docs/authored-examples.md`).
   - **Reproduce the license texts** the licenses require: at minimum CC BY-SA 4.0 and Licence
     Ouverte 2.0 — either inline (a dedicated Info/licenses entry) or via clearly-labeled links.
     Swiss/literary PD needs only courtesy attribution, no license text.
   - Keep it localizable (this app localizes via `L`/`String(localized:)` — match existing Info
     copy conventions, French + English).

5. **Build, test, verify.** Use the **ios-build-verify** skill (see CLAUDE.md for the script
   invocations): `build_app.sh`, `run_tests.sh`, then `build_app.sh && launch_app.sh` +
   `screenshot.sh` to confirm the Example section renders under etymology in `VerbView` and the
   Credits/licenses appear on Info. Add an accessibility identifier to the example view if it helps
   verification (the launch anchor is `verb_browse_sort`; navigate Verbs → a verb → detail).

## Guardrails

- **Synced folders:** adding the `.swift` model/loader and the bundled `.json` under `Conjuguer/`
  needs no Xcode/pbxproj step — they're picked up automatically. One type per file, filename = type
  name.
- **SwiftLint pre-commit (`--strict`):** `conditional_returns_on_newline` is on — put every
  `guard/if … return/continue` body on its own line. Enable the hook once per clone:
  `git config core.hooksPath .githooks`.
- **SourceKit vs. build:** same-module "Cannot find X in scope" diagnostics are unreliable; if
  `build_app.sh` succeeds, the build is authoritative.
- **Attribution is a license condition, not optional polish** — the CC BY-SA (Wikipedia) and Etalab
  (French gov) sources legally require it; that's the point of task 4. PD/Swiss/literary credit is
  courtesy but expected.
- **Don't regenerate the corpus** — the JSON is final at 982/982. If a verb's example reads poorly,
  hand-edit that one entry in the JSON; don't re-run the pipeline.

## Acceptance criteria

- Every verb's detail screen shows its example (FR + EN) **below etymology**, with a source
  attribution line.
- The Info Credits blurb attributes all tiers and **reproduces CC BY-SA 4.0 + Licence Ouverte 2.0**
  (text or links), names the Wikipedia articles, and credits Claude (Opus 4.8) for the 19 authored
  examples.
- `run_tests.sh` is green; a simulator screenshot shows both the VerbView example and the Info
  credits.

## Knobs

- **Per-example attribution display** — full ("— Wikipédia, « Le Havre » (CC BY-SA 4.0)") vs. terse
  ("— Wikipédia"). Terser in `VerbView`, full in the Info licenses section is a reasonable split.
- **Licenses inline vs. linked** — reproduce CC BY-SA / Etalab text inside a new Info entry for full
  offline compliance, or link out to keep the blurb short. Inline is safest for license
  reproduction.
- **Chanson nesting** — include the nested *Chanson de Roland* example (task 3, optional) now, or
  defer to a follow-up.
