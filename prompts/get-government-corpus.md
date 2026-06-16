# Acquire Swiss + French government corpus (clean-session prompt)

Read `@docs/government-corpus-licensing.md` first — it is the legal gate this session
must obey. The one-line summary: **Switzerland is public domain (take freely); France is
usable only where Licence Ouverte 2.0 / Etalab applies (verify per document; skip
CC BY-NC-ND).**

```
Read @docs/government-corpus-licensing.md and @CLAUDE.md (the "Literature-Example Corpus" section), then acquire a first batch of Swiss and French government documents for the corpus government tier. Save each as a plain UTF-8 .txt file of running prose (strip nav/boilerplate/tables) under corpus/originals/government/ (this folder is gitignored — raw sources stay local; only the eventual JSON ships). Target ~8–12 documents, a few hundred KB each, modern (post-2000) administrative/technical French, chosen for verb variety across government + technology domains.

COVERAGE STRATEGY: lean Swiss-heavy. Switzerland is both legally frictionless (public domain — no per-document license check) AND linguistically safe for this purpose: written federal administrative French is standard French, and Swiss particularities (Helvetisms) are almost entirely lexical/nominal — they don't affect verb choice or conjugation. So Switzerland should carry the BULK of coverage (aim ~⅔–¾ of the batch). Use France/Etalab to fill domain gaps Swiss sources miss (France-specific political/technical vocabulary), not as the primary workhorse.

LICENSE GATE (enforce strictly, per the research doc):
- Switzerland — PUBLIC DOMAIN under Art. 5 URG (official reports of authorities/administrations are not protected). Take federal and French-cantonal reports freely. Good sources: admin.ch (Conseil fédéral messages/rapports; offices fédéraux — OFS statistics, OFEV environment, OFT transport, OFCOM telecom, "Suisse numérique"/digital strategy), and French-cantonal sites (ge.ch, vd.ch, vs.ch, ne.ch, fr.ch, jura.ch — rapports de gestion/annuels). Pull a varied spread of offices/cantons so the verb coverage is broad.
- France — COPYRIGHTED BY DEFAULT; take ONLY documents explicitly under Licence Ouverte 2.0 / Etalab (or otherwise PD). Verify the license on each document's page/footer before saving. Prefer data.gouv.fr and ministry/agency reports that carry Etalab (e.g. France Stratégie, ADEME, Cour des comptes, CNIL, ANSSI, stratégie numérique/IA). SKIP anything CC BY-NC-ND (e.g. gouvernement.fr site content) — non-commercial/no-derivatives is unusable.

Use WebSearch/WebFetch to find and pull text. Where a page is JavaScript-rendered, blocks WebFetch, or only offers a PDF, use the Claude in Chrome MCP (load the core browser tools via ToolSearch, call tabs_context_mcp first, open a new tab) to navigate, confirm the license footer, and read the document text. Do not trigger dialogs.

PROVENANCE (required — attribution is a license condition and corpus/originals/ is gitignored, so the raw files won't preserve it): maintain a TRACKED manifest at docs/government-corpus-sources.md with one row per saved file: filename | title | publisher/office | jurisdiction | source URL | license (e.g. "PD — Art. 5 URG" or "Licence Ouverte 2.0") | date retrieved. Create the file if absent.

Report at the end: count + total size acquired, the per-domain/verb-variety spread, and any promising sources skipped on license grounds. Do NOT run sentence extraction.
```

## Knobs

- **Volume** — change "~8–12 documents" to a smaller "~3 documents (one Swiss federal,
  one Swiss cantonal, one France/Etalab)" for a quick validation run, or "until
  corpus/originals/government/ holds ~3 MB" for a fuller sweep.
- **Jurisdiction focus** — Switzerland is the cleanest legally; to minimize per-document
  license checking, append "Switzerland only this batch" and skip the France gate.
- **Domain steering** — add "weight toward technology/cyber vocabulary (OFCOM, ANSSI,
  CNIL, BSI-equivalents)" if a coverage check shows the technical verbs still uncovered.
- **Commit** — append "then commit docs/government-corpus-sources.md with a one-line
  message" to checkpoint the manifest (the raw .txt files stay gitignored).

## Guardrails

- **The license gate is the point** — when in doubt about a French document's license,
  skip it and note it in the report rather than saving it. Switzerland needs no such check.
- **Plain prose only** — these feed a later subagent extraction pass (per CLAUDE.md), so
  save running sentences, not tables/forms/figures. Strip site chrome and PDF headers.
- **Keep raw sources local** — `corpus/originals/` is gitignored on purpose (large,
  re-fetchable). Don't add gitignore exceptions for the .txt files; durability comes from
  the tracked `docs/government-corpus-sources.md` manifest, which lets anyone re-fetch.
- **Belgium / Quebec are out of scope here** — per the research doc they're murkier
  (Belgium) or restrictive (Quebec.ca); a later session can add Canada-federal OGL or
  Données Québec CC-BY if needed.

## Check progress without running anything

```bash
ls -lh corpus/originals/government/ 2>/dev/null && echo "---" && \
  { command grep -c '^|' docs/government-corpus-sources.md 2>/dev/null || echo 0; } \
  | sed 's/^/manifest rows: /'
```

## Questions from Claude (2026-06-16, before first run)

Read the prompt + `docs/government-corpus-licensing.md` and inspected repo state
(`corpus/originals/government/` and `docs/government-corpus-sources.md` don't exist yet;
`corpus/originals/` is gitignored as intended; only `frequencies.xml` exists — there is
no machine-readable list of the *uncovered* technical-tail verbs). The prompt is clear
and runnable as-is; my defaults if unanswered are noted per question.

1. **Run now, or is this a clean-session prompt to launch separately?** The doc is framed
   as a "clean-session prompt" and acquisition is web/Chrome-heavy. *Default if
   unanswered:* treat this turn as review-only — I append these questions and **do not**
   start acquiring until you say go (or paste the fenced block into a fresh session).

2. **Filename convention for the saved `.txt` files?** The manifest has a `filename`
   column but no scheme is specified. *Proposed default:*
   `<jur>-<office-or-canton>-<topic>-<year>.txt`, lowercase, ASCII slug — e.g.
   `ch-fed-ofs-rapport-annuel-2023.txt`, `ch-ge-rapport-gestion-2022.txt`,
   `fr-ademe-strategie-numerique-2022.txt`. OK, or do you want a different pattern?

3. **Verb-variety steering — broad-by-domain, or target a derived uncovered-verb list?**
   There's no ready list of the technical-tail verbs still needing examples, and the
   prompt frames selection by *domain* (government + technology prose). *Default:* select
   broadly across distinct offices/cantons/domains for verb spread, without first
   computing a target verb set from `frequencies.xml`/`verbs.xml`. Say so if you'd rather
   I derive and optimize against the uncovered tail first.

4. **How aggressively to strip non-prose?** Swiss/French reports are mostly PDF with prose
   interleaved with tables, figures, captions, footnotes, and running headers/footers.
   *Default:* keep only running sentences — drop tables/figures/captions/footnotes/page
   chrome even at the cost of losing some content — since these feed a later
   sentence-extraction pass that wants clean prose. Confirm that trade-off.

5. **Volume for this first batch?** *Default:* the prompt's `~8–12 documents` (Swiss-heavy,
   ~⅔–¾ CH). Switch to the "~3 documents" validation run from the Volume knob if you'd
   prefer a small shakedown before a full sweep.

6. **Commit the manifest at the end?** Per the Commit knob. *Default:* leave
   `docs/government-corpus-sources.md` uncommitted for you to review (raw `.txt` stay
   gitignored regardless). Say "commit" to have me check it in with a one-line message.
