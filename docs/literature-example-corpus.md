# Literature-Example Corpus (`corpus/`)

`corpus/` holds the pipeline that builds literature example sentences for the app's
~980 **usage-ranked** verbs — one modern-prose example per verb, plus a *Chanson de
Roland* example nested where one exists. It is a build-time data pipeline, **not part
of the shipped app target**; only the finished JSON is bundled.

**Pipeline stages (folders):**

| Folder | Contents | Tracked? | Role |
|---|---|---|---|
| `corpus/originals/` | Domain-tier subfolders of raw sources: `literature/` (PDFs of Proust, Zola, Flaubert + `chanson-roland-oxford.txt`), `government/` (Swiss/French public-document `.txt`), `technology/` (Swiss NCSC cyber/IT, PD), `wikipedia/` (French Wikipedia, CC BY-SA) | **No** | Raw source material — large and re-fetchable |
| `corpus/grokked/` | `chanson.md`, `chanson_descendants.json` | **Yes** | Hand-built parsed intermediate: numbered Old French with the modern infinitive bracketed per line, plus a line-by-line Claude translation. `chanson_descendants.json` is the verified Old-French-head → modern-descendant table (see the reflex policy below) |
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

**`build_chanson_examples.py`** parses `grokked/chanson.md` per laisse and writes
`json/chanson_examples.json` **and the bundled copy `Conjuguer/Models/chanson_examples.json`**
(the app loads the latter — both must stay in sync; the script writes both). It reports coverage
and *unmatched* gloss tokens. This hand-bracket-then-resolve approach suits the one fully-treated
poem.

**Reflex-only attachment policy.** A bracket gloss is either `head (modern)` — `head` is the
Old French verb actually in the line, `modern` a hand-written meaning — or a bare modern lemma.
An example is attached to a modern verb **only when the line genuinely contains that verb's own
word** (its etymological ancestor form); otherwise the app shows no Chanson section for it. So:
- **bare token** (`brandir`) → the line contains that verb directly → attach.
- **`head (modern)` where `head` has a verified modern descendant in `verbs.xml`** → attach to
  the **descendant**, the verb whose ancestor the line really contains (a reflex): `oïr (entendre)`
  → **ouïr**, `eslire (choisir)` → **élire**, `desclore (ouvrir)` → **déclore**, `ferir (frapper)`
  → **férir**. The descendant may be any of the ~6,300 verbs, not just the usage-ranked ~980.
- **`head (modern)` where `head` left no surviving descendant in the dict** → **dropped**. The
  verb itself never appears in the poem (the gloss is only a synonym), so e.g. `frapper`, `tuer`,
  `choisir`, `ouvrir` get no Chanson example rather than one whose word isn't theirs.

The head→descendant decisions live in `grokked/chanson_descendants.json`, the merged result of a
per-head English-Wiktionary etymology audit (parallel subagents; the per-slice `working/audit_*.json`
outputs are ignored intermediates) plus a few manual overrides for doublets whose modern sense
diverged from the Roland usage (`targier`, `chalengier`, `asmer`, `tenser`). Re-run the audit and
regenerate that table if the bracketing changes; this script only consumes it.

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

**Tiers beyond literature.** `build_corpus_index.py` recognizes five tiers in priority order:
`literature`, `classical`, `government`, `technology`, `wikipedia` (each under
`corpus/originals/<tier>/`, same gitignore treatment; `build_tail_index.py` draws the tail from the
latter four). Each has a tracked provenance manifest under `docs/` recording attribution + license:
- **classical** (`docs/classical-corpus-sources.md`) — La Fontaine *Fables* + Molière *Œuvres
  complètes*, 17th-c. French, **PD via Project Gutenberg** (modernized 19th-c. Garnier orthography,
  so forms match). Added to bridge the gap between *Roland* (~1100) and the 19th-c. novels.
- **government** (`docs/government-corpus-sources.md`) — Swiss PD (Art. 5 URG) + French Etalab.
- **technology** (`docs/technology-corpus-sources.md`) — Swiss NCSC cyber/IT, PD. Consumer how-to
  register supplies imperative/infinitive forms (`téléchargez`) that formal reports lack.
- **wikipedia** (`docs/wikipedia-corpus-sources.md`) — French Wikipedia, **CC BY-SA 4.0**, an
  owner-approved license exception (the government/technology tiers are PD/Etalab only) because it
  is the only open source of the consumer/encyclopedic register the software/general verbs need.
  CC BY-SA's attribution + share-alike obligations are documented in that manifest.

Corpus mining reached **963/982 (98.1%)**. The final 19 — inherent form-collisions
(`faillir`↔*falloir*, `plaire`↔"plus", `violer`↔"violent") and noun/adjective-dominant verbs no
open corpus uses verbally — were filled with **original Claude-authored example sentences**
(`docs/authored-examples.md`), each carrying `"source": "Claude (Opus 4.8)"` + `"line": null` in
the JSON so AI authorship is explicit and never attributed to a corpus it didn't come from.
`literature_examples.json` now covers the ranked **982 + 144 Chanson-only special verbs = 1126**
(`100%`). To extend/replace a tier: add sources under it, re-run `build_tail_index.py` + the
workflow, and merge into `literature_examples.json`.

**Classical tier — the 144 Chanson-only verbs.** `chanson_examples.json` attaches a *Roland*
example to 332 verbs; **144** of those are not in the ranked 982 (archaic reflexes the poem
contains: `occire`, `quérir`, `gésir`, `ouïr`, `honnir`, …). To honor each with a *modern* example
below its Chanson one, the classical tier was mined via **`build_classical_index.py`** (targets the
144 — recomputed as `chanson − lit`, keyed by **bare infinitive**; uses `forms_all.json` over all
~6,320 verbs with a `re.sub(r"\s*\(.*\)$","",vid)` normalization gotcha; ranks candidates by
distinctively-verbal token) → **`mine_classical.workflow.js`** (4 shards, subagents reject
noun/adjective/pronoun homographs) → **`merge_classical.py`** (merges into `literature_examples.json`
keyed by verb, refuses to overwrite the existing 982). Result: **81 classical-mined** (36 La
Fontaine, 45 Molière) + **63 authored** (`docs/classical-authored.md` — 45 absent-from-tier +
18 homograph-only). Both the `corpus/json/` and bundled `Conjuguer/Models/` copies of
`literature_examples.json` must stay in sync (the app loads the latter via `ExampleData.swift`).
