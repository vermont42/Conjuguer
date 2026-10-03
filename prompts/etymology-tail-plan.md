# Etymologies for the other 5,325 verbs: working plan (2026-10-03)

**Status:** planned; nothing run yet. Mark each stage ✅ with a dated correction note wherever the plan
proves wrong, as the Chanson and verb-pass plans did. Do not commit; Josh commits.

`Etymologies.json` covers 1,001 of the 6,326 infinitives: the 981 most used, the select verbs, and a
few more. This plan covers the rest. The writing runs in **waves**. After each wave the session stops
and reports, and **Josh decides whether to run another one**, based on his five-hour-window usage. A
wave is one session. Every subagent runs on **Sonnet 5.5**.

## Decisions (Josh, 2026-10-03)

| Question | Decision |
|---|---|
| Model | Every subagent (affix writers, etymology writers, skeptics) runs on Sonnet 5.5. Pass `model: 'sonnet'` explicitly and confirm `claude-sonnet-5-5` in the transcripts. |
| Context | Every subagent runs from a definition in `.claude/agents/` with **`omitClaudeMd: true`**, as `verb-skeptic.md` does. The brief gives all the background it needs, so the project's CLAUDE.md stays out of its context. The one CLAUDE.md rule that governs the output goes into each brief verbatim: no em dash joining two clauses that each have a subject and a predicate. |
| Length | **Tiered by evidence.** A transparent derivation or a thin-evidence verb gets one paragraph of about 60–120 words. A verb with a real history (Latin, Greek, Frankish or Old French descent, an older borrowing, a disputed origin) keeps the existing two-paragraph format of 120–220 words a paragraph. |
| Reuse | **Rewritten into the entry.** A derivative's writer receives its base verb's existing etymology and the affix library's card. It writes a standalone entry that states the formation and briefly restates the deep chain in its own words. No app change. |
| Affix library | **Build-time only.** `prompts/etymology-affixes.json` is tracked and not shipped. It is written once, before any wave. |
| Research | **Offline evidence first, web for gaps.** Each shard carries the evidence. A writer goes to the web only for a verb with no evidence, or where the sources conflict. If a site blocks WebFetch, the writer uses claude-in-chrome. |
| Skeptic | **Rich tier only.** Every entry gets the code validator. Sonnet skeptics check the two-paragraph entries. A one-paragraph entry gets a code check that the base and affix it names match the evidence. |
| Wave size | **Pilot, then size.** Wave 0 is about 100 verbs and measures the cost. Josh sets the size of later waves from that. |
| Order | Most used first (`docs/frequencies.txt`, which matches the app's ranks), except that a base is always written before its derivatives (see stage 2). |

## What the data looks like (measured 2026-10-03)

- **Covered is not the same as top-ranked.** The 1,001 were chosen from the old Sketch Engine
  ranking, and the September re-rank reshuffled it. 80 covered verbs now rank below 981 (*ester*
  1064, *saillir* 2646, *vaincre* 5338, …), and 60 verbs ranked within the top 981 have no entry
  (*ficher* 520, *abonner* 617, *téléphoner* 779, *choir* 844, *conjuguer* 971, …). Everything
  here keys on "absent from `Etymologies.json`", never on a rank cutoff. So the covered rare verbs
  are skipped and serve as bases, and the 60 lead the pilot.
- **Evidence.** French Wiktionary carries `etymology_texts` for 5,050 of the 5,325 verbs and English
  Wiktionary carries `etymology_text` for 3,742. 5,193 have one or the other; **132 have neither**
  (*affadir*, *bruiner*, *complimenter*, *contusionner*, *dribler*, …).
- **Most of it is short.** The median French étymologie is 40 characters, and the median English one
  is 26. A rough classification of the French text finds about 2,270 internal derivations ("De
  traduire avec le préfixe re-", "Dérivé de scolaire, avec le suffixe -iser"), 1,530 that name a
  source language, and 1,260 other (modern borrowings, onomatopoeia, "origine obscure").
- **Affixes.** The French evidence names about 60 prefixes and 35 suffixes. The most frequent are
  *dé-* 389, *-er* 419 (denominal), *-iser* 283, *re-* 252, *en-* 132, *dés-* 121, *é-* 70, *a-* 63,
  *ré-* 47, *sur-* 39, *-ir* 34, *-ifier* 30.
- **Bases.** About 1,030 missing verbs are "prefix + base" derivations. 351 of their bases already
  have an etymology, 412 bases are themselves missing verbs, and 271 bases are not verbs in the app.
- **Size.** `Etymologies.json` is 2.5 MB for 1,001 verbs. A tiered tail should land at roughly 8–10
  MB in all. `Etymology.loadIfNeeded()` decodes the whole file, both languages, on first use, on the
  main actor (and so does the widget snapshot writer). Stage 3 measures that cost once the pilot
  provides a realistic per-entry size.

## Paste to run

**Session 1** (stages 0–3: evidence, affixes, pilot wave):

```
Read @prompts/etymology-tail-plan.md and carry out stages 0 through 3: build the evidence file
(stage 0), write and skeptic-check the affix library (stage 1), set up the wave tooling and agent
definitions (stage 2), and run wave 0, the pilot (stage 3), with workflows; use the Workflow tool.
Before starting, ask me for my five-hour usage percentage; ask again at the end. Stop after the pilot,
report per the wave report in stage 2, and propose a wave size. Mark completed steps with ✅ and add
a correction note wherever the plan proved wrong. Do not commit; Josh commits.
```

**Every later session** (one wave):

```
Read @prompts/etymology-tail-plan.md and run the next wave of stage 4 at the size recorded in the
wave ledger, with workflows; use the Workflow tool. Before starting, ask me for my five-hour usage
percentage; ask again at the end. Stop after the wave and report. Update the ledger, journal the
wave, and do not commit; Josh commits.
```

---

## 0. Evidence file

Write `corpus/working/build_etymology_evidence.py` (tracked; whitelist it in `.gitignore` beside the
other tracked `corpus/working/` scripts). It reads only local files, never the network:

- `docs/frequencies.txt` for the rank, and `verbs.xml` for the gloss (`tn`). A verb with two entries
  joins its glosses, as `etymology-verbs.json` did for *sortir*.
- `corpus/working/wiktionary/raw/fr-extract.jsonl.gz`, for French `etymology_texts`. It must use the
  **raw** dump, because `wiktionary_fr_verbs.json` dropped the étymologie. Keep every verb entry's text
  for the headword, NFC-normalized, deduplicated.
- `corpus/working/wiktionary/wiktionary_en_verbs.json`, for English `etymology_text`.
- `Conjuguer/Models/Etymologies.json`, to mark what is done and to supply a base's existing entry.

For each of the 5,325 verbs it writes one record to `corpus/working/etymology/evidence.json`
(ignored):

```json
{ "retraduire": {
    "rank": 2417, "gloss": "retranslate",
    "fr": ["De traduire avec le préfixe re-."],
    "en": ["From re- + traduire."],
    "formation": { "kind": "prefix", "affix": "re-", "base": "traduire",
                   "base_status": "covered" },
    "base_etymology_en": "…", "base_etymology_fr": "…",
    "base_word_evidence": null,
    "tier": "short", "tier_reason": "internal derivation", "evidence": "both" } }
```

- **`formation`.** Parse the French text first ("De X avec le préfixe Y", "Dérivé de X, avec le
  suffixe -Y", "Formé avec le suffixe -Y sur …", "Composé de …"), then the English ("From X + -Y").
  `kind` is one of `prefix`, `suffix`, `parasynthetic` (both prefix and suffix, *en-* + *-ir* on a
  noun), `compound`, or `none`. `base_status` is one of `covered`, `missing` (a verb in this plan),
  `nonverb` (a noun or an adjective), or `unknown`.
- **`base_word_evidence`.** When the base is a noun or an adjective, look up its own French and
  English etymology text in the raw dumps (any part of speech). *scolariser*'s writer then gets
  *scolaire*'s origin without going to the web. This one lookup removes most of the web need.
- **`tier`.**
  - `short`: an internal derivation whose base is covered, missing, or has word evidence; a modern
    borrowing (English, Italian, after about 1700) with a one-line source; or a verb whose only
    evidence is a single line with no source language.
  - `rich`: the text names Latin, Greek, Frankish or another Germanic language, Old or Middle
    French, Arabic, or Occitan as a source; or it hedges ("peut-être", "origine obscure", "incertain",
    "discuté", "on rattache").
  - `none`: no evidence at all.

  The writer may move a verb between the tiers and must say why (stage 2), so the heuristic only
  needs to be mostly right.

Print the tier counts, the `evidence` counts, the `formation.kind` counts, and the number of `missing`
bases, and record them in this plan as a correction note if they differ much from the section above.

**Acceptance:** 5,325 records; every verb absent from `Etymologies.json` is present; the counts are
printed and recorded.

## 1. Affix library

Collect every affix that `evidence.json` names (about 95), grouped by allomorph: *dé-/dés-/des-/de-*,
*re-/ré-/r-/ra-*, *en-/em-*, *é-/es-/ex-*, *a-/ad-*, *con-/co-/com-*, *mé-/més-*, and so on. The
verb-forming endings that mean only "made into a verb" (*-er*, *-ir* on a noun) get one shared card.

**Agent definitions.** Write two tracked definitions first: `.claude/agents/etymology-affix-writer.md`
(`model: sonnet`, `omitClaudeMd: true`, no `tools` restriction, so it has the web and claude-in-chrome)
and `.claude/agents/etymology-affix-skeptic.md` (`model: sonnet`, `omitClaudeMd: true`,
`tools: Read, Write`). Each carries its whole brief: the card shape below, the markup rules, the
em-dash rule, and, for the writer, the claude-in-chrome tab rules from stage 2.

**Writers.** Sonnet 5.5, about 4 agents of about 24 affixes each, in one workflow. They have web
access (fr.Wiktionary affix pages, the TLFi's affix entries on cnrtl.fr, en.Wiktionary), with the
claude-in-chrome fallback described in stage 2. Each card is factual notes for later writers, not
prose to ship:

```json
{ "re-": {
    "group": ["re-", "ré-", "r-", "ra-"],
    "allomorphy": "r- before a vowel (rouvrir), ré- mostly in learned words …",
    "origin_en": "Latin ~re-~ (“back, again”), …",
    "origin_fr": "Du latin ~re-~ (« en arrière, de nouveau »), …",
    "senses": ["repetition", "return to a former state", "intensive (no sense of repetition)"],
    "productive": "fully productive today",
    "examples": ["refaire", "revenir", "remplir"],
    "cognates": ["English re- (borrowed via French and Latin)"],
    "pitfalls": "Many re- verbs are not 'again + verb': remplir, rendre …",
    "sources": ["…"] } }
```

`origin_en` and `origin_fr` follow the etymology markup rules (single tildes, `*~root~`, curly quotes
and guillemets), so writers can lift phrasing straight into an entry. The `pitfalls` field matters
most: it is where a fossilized prefix (*remplir*, *rendre*, *dépendre*) gets flagged, so the writers
don't misanalyze it as transparent.

**Skeptic.** Every card gets one, since each card will be reused hundreds of times: 2
`etymology-affix-skeptic` agents, which check the cards against the sources the writer cited. Then
apply the fixes.

**Josh reviews** the cards for *dé-*, *re-*, *en-*, *-iser* and *-ifier* in the session report before
the pilot uses them. The pilot can run meanwhile, but if he changes a card, rerun the pilot shards
that used it.

**Acceptance:** `prompts/etymology-affixes.json` has a card for every affix in `evidence.json`; it is
valid JSON; tildes are even and `en`/`fr` tilde counts match within each card; every allomorph maps
to exactly one card.

## 2. Wave tooling and agents

### Selection with bases first

`corpus/working/etymology_wave.py` (tracked) with subcommands:

- `select --wave N --size S` takes the next `S` verbs by rank that are not in `Etymologies.json`, then
  applies the **base pull-forward** rule. If a selected verb's `formation.base_status` is `missing`,
  the base joins this wave and the derivative moves to the next one. It writes the shards (below).
  The rule applies recursively, so a chain like *dés-* + *en-* + base resolves within two waves.
- `validate --wave N` runs the checks below over the wave's results.
- `merge --wave N` merges the validated (and skeptic-fixed) entries into `Etymologies.json`, using
  the sorted `json.dumps` merge from `etymology-pipeline.md` Step 5.
- `report --wave N` prints the wave report.

**Shards.** The unit is weight: a `short` verb weighs 1 and a `rich` verb weighs 2.5. A shard holds
about 30 units (about 30 short verbs or 12 rich ones). Each shard file under
`corpus/working/etymology/waves/wNN/shards/` carries its verbs' full `evidence.json` records, the
affix cards those verbs use, and nothing else. Results go to `…/wNN/results/sMM.json`, and skeptic
verdicts to `…/wNN/verdicts/sMM.json`.

### Agent definitions

Two tracked definitions in `.claude/agents/`, in the shape of `verb-checker.md` / `verb-skeptic.md`.
Each carries its whole brief, so a workflow prompt only has to name a shard file:

- **`etymology-writer.md`**: `model: sonnet`, `omitClaudeMd: true`. Omit `tools` so the writer
  inherits the session's tools, including WebSearch, WebFetch, and the claude-in-chrome MCP tools
  (loaded through ToolSearch). The body is the subagent prompt from `etymology-pipeline.md`, carried
  over **intact** (the research guidance, *Disputed origins*, the markup rules, quotation marks,
  passé simple, the `ester` worked example), with these changes:
  - **Context.** Add a short paragraph about the app: an iOS app teaching French conjugation, with
    an etymology card on each verb's page, read by English and French speakers. With CLAUDE.md
    omitted, this is the writer's only background.
  - **Em dashes.** Never use an em dash to join two clauses that each have a subject and a
    predicate. Start a new sentence instead, or, less often, use a semicolon. An em dash around a
    parenthetical aside that is not itself a clause is fine. This applies to both languages.
  - **Input and output.** Read the named shard file and write the results file. Return a one-line
    summary. Never touch `Etymologies.json`.
  - **Evidence first.** The shard's evidence is the primary source. Go to the web only when a verb's
    `evidence` is `none`, or when its French and English texts disagree on the chain. Record every
    URL used in `sources`.
  - **Blocked sites.** If WebFetch is blocked or refused (cnrtl.fr, Le Robert, the Académie), use
    claude-in-chrome. Load the tools in one ToolSearch call. Open **your own** tab with
    `tabs_create_mcp`, never use a tab you did not open, and close it when done, because other
    writers share the browser. If Chrome fails twice, set `needs_lookup` with the reason and move on.
  - **Tiers.**
    - `short`: one paragraph, about 60–120 words in each language. State the formation (bold the
      base and the affix), give the base's origin briefly from `base_etymology_*` or
      `base_word_evidence`, give the affix's sense from its card, and, if there is one, a date of
      first attestation or a notable sense shift.
    - `rich`: the existing two-paragraph format.
    - The writer may move a verb to the other tier, with `tier_reason`. Promote a verb when the
      derivation hides a real history (a fossilized prefix, a borrowing behind a French-looking
      form). Demote a verb when there is nothing more to say. Never pad a short entry to make it
      look rich.
  - **Reuse.** For a derivative, restate the base's chain in your own words, keeping only the
    links that matter (Latin source, a famous cognate). Do not copy the base entry's sentences. Do
    not contradict it either: if the evidence disagrees with the base's entry, say so in `notes`.
  - **No evidence.** If a `none` verb still has no reliable source after the web, write nothing for
    it. Set `skipped: "no reliable source"`. No entry is better than an invented one.
  - **Result shape.** `{ verb: { tier, tier_reason, en, fr, sources, notes, needs_lookup?, skipped? } }`.
- **`etymology-skeptic.md`**: `model: sonnet`, `omitClaudeMd: true`, `tools: Read, Write`, in the
  spirit of `verb-skeptic.md` (default refuted, judge from the shard only). It receives the rich
  entries with their evidence, the base and affix material, and the writer's `sources` and `notes`.
  For each entry it returns `upheld`, `partly` (with the corrected `en` **and** `fr`), or `refuted`
  (with the reason). It refutes a root, cognate or date the evidence doesn't support, a disputed
  origin stated as settled, a fossilized prefix analyzed as transparent, and an en/fr pair that
  disagree on a fact. A `partly` fix is text that ships, so the brief also carries the markup rules,
  the passé simple rule and the em-dash rule.

### Validator (code, every entry)

The Step 4 checks of `etymology-pipeline.md`: missing language, odd `~` count, `~~`, ASCII `"`,
literal `\n`, `~*`, `*word*` emphasis, and en/fr tilde mismatch. Plus these:

- **Paragraphs and length.** A `short` entry has exactly one paragraph and 40–150 words in each
  language. A `rich` entry has exactly two paragraphs, each paragraph 90–260 words. (The pipeline's
  "no paragraph break" check applies to `rich` only.)
- **Formation.** A `short` entry whose evidence has a `formation` bolds both the base (`~traduire~`)
  and the affix (`~re-~`) in both languages. An entry whose base is `covered` bolds no root absent
  from both the base entry and the shard's evidence (flag it, don't reject it: the writer may have
  used the web, so check `sources`).
- **Passé composé (French).** Flag `\b(a|ont|est|sont|fut) (été )?\w+(é|ée|és|ées|i|is|it|u|us)\b`
  in a historical sentence for a skim. Flag it; don't reject it, because the present-tense "est formé"
  is fine.
- **Coverage.** Every verb in the shard is present, `skipped`, or `needs_lookup`, and no verb outside
  the shard appears.

A shard failing on markup only is fixed mechanically, per the pipeline's *Lessons*: drop the
inline-aside bold in `en`; move `~*` to `*~`. A shard with a missing language or a wrong verb set
reruns whole.

### One wave

1. **Ask Josh for his five-hour usage %.**
2. `etymology_wave.py select`, then a workflow that runs the writer shards and then, through
   `pipeline()`, each shard's rich entries into a skeptic. Use `agentType: 'etymology-writer'` /
   `'etymology-skeptic'` and `model: 'sonnet'`. A workflow cannot read files, so the agents write
   results and the script returns only their one-line summaries.
3. `validate`. Fix or rerun. Then apply the skeptic verdicts: `partly` uses the skeptic's text (and
   that text is validated again), `refuted` is dropped from the wave and listed with its reason. A
   dropped verb returns in a later wave only with a note in its evidence about what went wrong.
4. **`needs_lookup` verbs.** Up to about 10 a wave, the orchestrator does the lookup itself with
   claude-in-chrome, adds the result to the verb's evidence, and reruns that verb in a one-shard
   writer call. More than that go to the next wave.
5. `merge`, then validate the JSON (pipeline Step 6).
6. **Wave report** (`report`), printed for Josh:
   - verbs merged, skipped, refuted, and deferred (with reasons);
   - tier split, and tier moves in each direction;
   - skeptic rates;
   - web use (how many verbs, and how many needed Chrome);
   - tokens by agent type and per verb by tier, summed from the subagent transcripts' `usage`, with
     the model of each transcript (all must be `claude-sonnet-5-5`);
   - Josh's usage % at the start and end, and the difference;
   - the remaining count, and the next wave's first verbs.
   - **Twenty sample cards**: ten short, ten rich, chosen by index and not by eye, each with its
     evidence beside it.
7. Update the ledger below, journal the wave in `docs/blog_notes.md`, and stop.

## 3. Wave 0: the pilot

About 100 verbs: the first by rank after the covered ones, plus pull-forward. The head of the list
is the most used of the rest, so the pilot will run **richer than average**, and later waves will be
cheaper per verb. So the proposal for the wave size must use the per-tier cost, weighted by the
tier split that remains, not the pilot's raw average.

Beyond the normal wave report:

- **Wave size.** Propose a size that uses at most about 60% of a five-hour window, so the window
  still has room for the orchestrator and for reruns. Record Josh's choice in the ledger.
- **Workflow size.** The session's workflow guideline is under 10 agents. If the chosen size needs
  more writers and skeptics than that, either split the wave into two workflows run back to back, or
  ask Josh to raise "Dynamic workflow size" in `/config`.
- **Load cost.** Extrapolate the file size to all 6,326 verbs from the pilot's average entry. Measure
  the cold decode of a synthetic file that size (pad with copies of real entries) in a unit test or
  a throwaway Swift script on the simulator. If it costs more than about 100 ms, propose (do not
  make) a split by language (`Etymologies-en.json` / `-fr.json`), since the app only ever reads one.
- **In the app.** Build, run the suite, and in the simulator open one short-tier verb and one
  rich-tier verb from the pilot. Check the etymology card and the widget snapshot's 360-character
  truncation.

## 4. Later waves

Each later session runs one wave (stage 2, *One wave*) at the ledger's size, then stops. Josh decides
whether to run the next one. Near the end, the remaining `none` verbs may form a small wave of their
own, with web lookups for every verb.

## 5. Finishing (when the ledger reaches zero, or Josh calls it)

- `prompts/etymology-pipeline.md`: its *Status* and *Goal* should say that all verbs are covered and
  point here; its subagent prompt now lives in `.claude/agents/etymology-writer.md`, so say which copy
  is canonical. `prompts/run-etymology-pipeline.md`: point at this plan.
- `docs/project-structure.md` for the new tracked scripts, the agent definitions and
  `etymology-affixes.json`; then `python3 scripts/check_docs.py`.
- List the verbs that are still skipped, for Josh.
- Release notes, if Josh wants a line ("every verb now has an etymology"), in both languages.
- A journal entry summing up the whole run.

## Wave ledger

| Wave | Date | Size | Merged | Skipped / refuted / deferred | Usage Δ (5-h %) | Tokens | Remaining |
|---|---|---|---|---|---|---|---|
| 0 (pilot) | | ~100 | | | | | 5,325 |

## Out of scope

- Rewriting any of the 1,001 existing entries. If a derivative's writer finds its base entry wrong,
  it goes in `notes` and the wave report lists it for Josh.
- Changing how the app shows etymologies, apart from the stage 3 language-split proposal.
- Bulk fetching from the TLFi. `fetch_cnrtl.py` is for single-verb checks, never a scraping run; the
  writers' live lookups are per verb and only for gaps.
