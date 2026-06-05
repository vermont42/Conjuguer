# Prompt: Complete the full-treatment edition of *La Chanson de Roland*

This is a **self-contained working prompt** for a future Claude Code session. Paste
it (or point the session at this file) and follow the three steps in order. It
assumes no memory of the conversation that produced `corpus/chanson.md`; everything
needed is restated below.

---

## Objective

Build out `corpus/chanson.md` into the **complete** *Chanson de Roland* (Oxford
manuscript, the standard Bédier numbering, **~4,002 lines across 291 laisses**),
giving every laisse the same "full treatment" already applied to laisses I and VIII:

1. the **numbered original** Old French, one line per source line;
2. at the end of each original line, the **infinitive forms of its verbs** in
   brackets; and
3. a **fresh, own line-by-line translation**, numbered to match.

The work is large (~8,000 annotated output lines) and must be done in **chunks
across multiple turns**, with a progress ledger so any session can resume.

---

## Conventions (must match the existing file exactly)

These are the rules already in force in `corpus/chanson.md`. Do not change them;
extend them.

### Line numbering
- Use the **canonical Bédier line numbers** (1–4002), not per-laisse counters.
- Preserve laisse boundaries. The poem is divided into *laisses* (stanzas of
  varying length); mark each one.

### Verb brackets (on each original line)
- At the end of each original line, append `[...]` listing the **modern infinitive**
  of every verb appearing in that line, in order of appearance.
- Where the Old French verb's modern reflex is **obsolete or has drifted in
  meaning**, show the **Old French infinitive followed by the nearest current
  modern infinitive in parentheses**: e.g. `remaindre (rester)`.
- Where the verb survives directly into modern French with the same sense, give the
  single modern infinitive: e.g. `[être]`, `[conquérir]`, `[tenir]`.
- **Lines with no verb carry no bracket.**
- Identify verbs from the form in the text (e.g. `siedent`, `estuet`, `ad estet`);
  resolve auxiliaries too (`ad estet` → `[avoir, être]`).

### Established verb-gloss mappings (reuse for consistency; extend as needed)
| Old French | Bracket form |
|---|---|
| remaindre / remés / remaigne | `remaindre (rester)` |
| fraindre | `fraindre (briser)` |
| peceier | `peceier (dépecer)` |
| ocire / ocis | `ocire (tuer)` |
| estovoir / estuet / estoet | `estovoir (falloir)` |
| esbaneier | `esbaneier (s'amuser)` |
| seoir / siet / siedent | `seoir (asseoir)` |
| avoir, être, faire, tenir, prendre, devenir, jouer, descendre, saluer, demander, garder, atteindre, pouvoir, servir, réclamer, aimer, abattre, fleurir, escrimer, enseigner, conquérir | direct modern form |

As new verbs appear, add them to this table **in this prompt file** so later chunks
stay consistent. When a reflex is genuinely uncertain or disputed, prefer the
nearest modern equivalent and note the doubt rather than inventing certainty.

### Translation
- The translation is **your own**. You may take inspiration from published cribs
  and a glossary, but **re-render it yourself**, line for line.
- One translation line per original line, sharing the same canonical number.
- Faithful over poetic; flag any line you are unsure of with a trailing
  `<!-- uncertain: ... -->` HTML comment rather than guessing silently.

### Target document structure (per-laisse blocks)
Restructure `corpus/chanson.md` so each laisse is a **self-contained block** —
original (with verb brackets) immediately followed by its translation. This is far
more resumable than the current two-big-sections layout, so **migrate the existing
laisses I and VIII into this format** as part of the first chunk. Use this shape:

```
## Laisse VIII (lines 96–121)

**Original**
96. Li empereres se fait e balz e liez: [faire]
...

**Translation**
96. The emperor makes himself both merry and glad:
...
```

Keep the existing top-of-file header (source attribution, convention note,
"translation is my own" disclaimer).

---

## Step 1 — Download the original to `corpus/`

> **STATUS: DONE (2026-06).** The verified original is at
> `corpus/chanson-roland-oxford.txt` — 4,002 Bédier-numbered lines, 291 laisses
> (I–CCXCI), from Orbis Latinus (orbilat.com), Oxford/Digby 23. Endpoints and the
> laisse-VIII anchor (line 96) match `corpus/chanson.md`. See that file's header for
> the lacuna-numbering and edition caveats. A future run can skip to Step 2.

Goal: a clean, complete, machine-readable Old French Oxford text saved verbatim, to
work from offline so later chunks don't depend on re-fetching.

1. **Find a clean source.** Prefer a plain-text / HTML transcription over scanned
   OCR. Candidates to try (verify quality before trusting any):
   - Bibliotheca Augustana (hs-augsburg.de) — Old French Roland, Bédier text.
   - Wikisource (Old French / `ang`/`fro`) Oxford text.
   - Internet Archive Bédier editions (`lachansonderolan00bduoft`,
     `lachansonediart00bduoft`) and the Jenkins Oxford edition
     (`lachansonderolandatkjenkins`) — these are **scans/OCR**; usable only if a
     clean text layer exists.
   Use the Claude in Chrome MCP (`mcp__claude-in-chrome__*`) or `WebFetch` to fetch.
2. **Save it** to `corpus/chanson-roland-oxford.txt` (raw original only). Preserve
   laisse divisions and, if the source provides them, line numbers.
3. **Verify before proceeding:**
   - First line is `Carles li reis, nostre emperere magnes`.
   - Total line count is **≈4,002** (Oxford ms; allow minor edition variance).
   - Manuscript is **Oxford (Bodleian Digby 23)**, Bédier or Jenkins numbering.
   - Spot-check a known later line (e.g. the `AOI.` markers; Roland's death ~laisse
     174; the final line ~"Ci falt la geste que Turoldus declinet").
   - **If the line count or opening line don't match, stop and report** — do not
     build on a wrong or partial source.

---

## Step 2 — Process one chunk

Pick a **chunk size that fits comfortably in a single careful turn** — suggested:
**one laisse at a time**, or up to ~150 lines, whichever is smaller for dense
laisses. Then:

1. Read the next un-done range from `corpus/chanson-roland-oxford.txt`, starting
   where the progress ledger says (Step 3).
2. For each line in the chunk: keep the canonical number, transcribe the original
   verbatim, append the verb bracket per the conventions, and write your
   translation line.
3. Append the completed laisse block(s) to `corpus/chanson.md` in the per-laisse
   structure above.
4. Update the progress ledger (below).
5. Add any new verbs encountered to the mappings table in this file.

Quality bar: accuracy over speed. It is fine for a chunk to be a single laisse if
that keeps the verb analysis and translation correct.

---

## Step 3 — Loop the chunks until done

1. Maintain a **progress ledger** so any session can resume. Keep it at the top of
   `corpus/chanson.md` under a `## Progress` heading (or in `corpus/PROGRESS.md`),
   recording: last completed laisse number, last completed line number, and date.
   Example: `Last completed: laisse 24 / line 326 (2026-06-xx).`
2. Repeat **Step 2** for each subsequent chunk, resuming from the ledger, until
   **laisse 291 / line ~4002** is complete.
3. Every ~10 laisses, run a **consistency pass**: numbering is continuous and
   gap-free, every original line has a translation line, verb-bracket style is
   uniform, and the mappings table covers all glosses used.
4. **Final verification** when done:
   - Line count of original blocks ≈ 4,002 and matches the source.
   - No missing or duplicated line numbers.
   - Every original line has a matching translation line.
   - Remove the `## Progress` ledger (or mark it `COMPLETE`).

---

## Guardrails
- Old French is hard; **never fabricate** a reading, a verb identification, or a
  translation to appear complete. Mark uncertainty inline.
- Keep the hedged, scholarly tone already in the file for disputed etymologies.
- Don't silently switch source editions mid-poem — note any edition change.
- This is public-domain medieval text; the translation is original work. No
  copyright issue with the original, but do not paste a copyrighted modern
  translation — translate yourself.
