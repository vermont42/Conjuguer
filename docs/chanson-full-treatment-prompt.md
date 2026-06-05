# Prompt: Complete the full-treatment edition of *La Chanson de Roland*

This is a **self-contained working prompt** for a future Claude Code session. Paste
it (or point the session at this file) and follow the three steps in order. It
assumes no memory of the conversation that produced `corpus/chanson.md`; everything
needed is restated below.

---

## Objective

Build out `corpus/chanson.md` into the **complete** *Chanson de Roland* (Oxford
manuscript, the standard Bédier numbering, **~4,002 lines across 291 laisses**),
giving every laisse the same "full treatment":

1. the **numbered original** Old French, one line per source line;
2. at the end of each original line, the **infinitive forms of its verbs** in
   brackets; and
3. a **fresh, own line-by-line translation**, numbered to match.

The work is large (~8,000 annotated output lines) and must be done in **chunks
across multiple turns**, with a progress ledger so any session can resume.

> **Current state (authoritative source = `corpus/progress.md`).** Laisses **I–XI
> (lines 1–167)** are complete and already in the per-laisse-block format described
> below; the one-time restructure from the old two-section layout is **done**. Do
> **not** re-migrate. Read `corpus/progress.md` for the exact resume point and pick up
> from the next laisse.

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
- **One lemma per line, listed once.** If the same verb appears twice on a line, list
  it once. For a compound (auxiliary + past participle), list **both** lemmas once
  each, auxiliary first: e.g. `avez … dit` → `[avoir, dire]` (not `[dire, avoir, dire]`);
  `ad prise` → `[avoir, prendre]`.
- **Pronominal verbs** take the reflexive modern infinitive: `se culchet` →
  `[se coucher]`, `s'esmaiez` → `esmaier (s'inquiéter)` (the parenthetical reflex
  already carries the `se`).

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
| derumpet | `derumpre (rompre)` |
| guarisez / guarir | `garir (guérir)` |
| esmaiez | `esmaier (s'inquiéter)` |
| carier | `carier (charrier)` |
| osteiet | `osteier (guerroyer)` |
| repairer | `repairer (rentrer)` |
| afiancer | `afiancer (garantir)` |
| senefiet | `senefier (signifier)` |
| acorder | `acorder (accorder)` |
| ventelet | `venteler (flotter)` |
| desfere | `desfaire (défaire)` |
| orrat / oëz | `oïr (entendre)` |
| tramist | `tramettre (transmettre)` |
| engignent | `engigner (tromper)` |
| aürer | `aürer (adorer)` |
| esmerez | `esmerer (affiner)` |
| luer | `luer (payer)` |
| redrecet | `redrecer (redresser)` |
| quid / quider | `cuidier (croire)` |
| establer | `establer (mettre à l'écurie)` |
| hosteler | `hosteler (héberger)` |
| cunreez | `cunreer (équiper)` |
| finet / finer | `finer (finir)` |
| encumbret | `encombrer (accabler)` |
| errer | `errer (voyager)` |
| escultet | `esculter (écouter)` |
| cuvent | `cuvenir (falloir)` |
| otriet | `otreier (octroyer)` |
| nuncerent | `noncier (annoncer)` |
| lodet / loerent | `loer (conseiller)` |
| degetuns | `degeter (rejeter)` |
| chalt | `chaloir (importer)` |
| duist | `duire (lisser)` |
| afaitad | `afaitier (arranger)` |
| toluz | `tolir (enlever)` |
| fruiset | `fruisier (briser)` |
| arses | `ardre (brûler)` |
| sumunt | `semondre (inviter)` |
| meslisez | `mesler (se quereller)` |
| blancheier | `blancheier (blanchir)` |
| aquisez | `aquiser (apaiser)` |
| ester | `ester (rester)` |
| eslisez | `eslire (choisir)` |
| esguardent | `esgarder (regarder)` |
| esrages | `esragier (s'enrager)` |
| muvrai | `mouvoir (susciter)` |
| esclair | `esclairier (soulager)` |
| sedeir | `seoir (asseoir)` |
| avoir, être, faire, tenir, prendre, devenir, jouer, descendre, saluer, demander, garder, atteindre, pouvoir, servir, réclamer, aimer, abattre, fleurir, escrimer, enseigner, conquérir, aller, venir, donner, appeler, conseiller, répondre, dire, mander, charger, louer, devoir, suivre, recevoir, vouloir, envoyer, perdre, conduire, mendier, voir, passer, trancher, monter, mettre, porter, savoir, conter, tendre, baisser, commencer, penser, lever, se coucher, confondre, amener, parler, enquérir, enchaîner, muer, trousser, avouer, s'en aller, contredire, croire, conquérir, mener, mettre, venger, joindre, vaincre, entreprendre, juger, jeter, craindre, durer, rire, livrer, commander, se dresser, se tenir | direct modern form |

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
Each laisse in `corpus/chanson.md` is a **self-contained block** — original (with verb
brackets) immediately followed by its translation. This layout is already in force for
laisses I–XI; **append new laisses in the same shape** (separated by a `---` rule), and
do not revert to the old two-section layout. Shape:

```
## Laisse VIII (lines 96–121)

**Original**
96. Li empereres se fait e balz e liez, [faire]
...

**Translation**
96. The emperor makes himself both joyful and glad,
...
```

Keep the existing top-of-file header (source attribution, convention note,
"translation is my own" disclaimer).

### Source edition (settled — no per-turn decision)
- **Laisse I** retains its original **UT-Austin Bédier** text (`amet`, `Saraguce`,
  `emperere`) — do not re-transcribe it.
- **Laisses II–291** are transcribed **verbatim** from the working raw source
  `corpus/chanson-roland-oxford.txt` (Orbis Latinus / orbilat), including its editorial
  brackets (`[S]erai`, `Char[l]es`), parentheticals (`(...)`, `m(er)ercit`), and its
  dropped apostrophes (`d argent`, `d or`). There is **no further edition switching**;
  this is recorded in the `chanson.md` header.

### Lacunae (read before transcribing — easy to mis-number)
`corpus/chanson-roland-oxford.txt` contains **6 lacuna rows** (see its header): 3
*unnumbered* narrative gaps (around laisses ~C–CL) and 3 that *occupy a numbered Bédier
slot* (a line lost in Oxford, in the Baligant section). Handle them explicitly:
- **Unnumbered lacuna** → emit **no** output line; add a `<!-- lacuna: narrative gap,
  no Bédier line here -->` note at the spot so numbering stays continuous.
- **Numbered lacuna** → **keep the canonical number**, write the original line as
  `N. [lacuna — line lost in Oxford ms]` (no verb bracket), and a matching translation
  line `N. [lacuna]`. This preserves the gap-free count of exactly 4,002.
Whenever you cross a lacuna, note it in `corpus/progress.md`.

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
   structure above (each new block preceded by a `---` rule).
4. Update the progress ledger (below).
5. Add any new verbs encountered to the mappings table in this file.

Quality bar: accuracy over speed. It is fine for a chunk to be a single laisse if
that keeps the verb analysis and translation correct.

### Finding the next chunk in the source
The source is tab-separated `<lineNo>\t<verse>` with `Laisse <roman>` headers. List
laisse boundaries and read a range with:

```bash
grep -n "^Laisse " corpus/chanson-roland-oxford.txt          # roman-numeral headers + file offsets
# then Read the file at the offset for the laisses you want
```

### Recommended execution: parallel subagents (one per laisse)
This is the workflow that proved fast and accurate. For a batch of N laisses:

1. In the orchestrator, `grep` the boundaries and Read the source span covering the
   whole batch.
2. Dispatch **one subagent per laisse, in parallel** (a single message with N Agent
   calls). Give each subagent: the full conventions above, its laisse's **verbatim**
   source lines, the roman numeral + line range, and the relevant rows of the mappings
   table. Instruct each to **transcribe verbatim, not fetch or search the web**, and to
   **return only the finished markdown block** (no preamble) in the exact
   `## Laisse … / **Original** / **Translation**` shape.
3. The orchestrator assembles the returned blocks in order, appends them to
   `corpus/chanson.md`, runs the consistency check (Step 3.3), updates the ledger, and
   adds new verbs to the mappings table.

A batch of ~10 laisses per turn is comfortable. Subagents occasionally emit a stray
preamble line before the block — strip it during assembly.

---

## Step 3 — Loop the chunks until done

1. Maintain a **progress ledger** so any session can resume. Keep it in `corpus/progress.md`,
   recording: last completed laisse number (Roman), last completed line number, and date.
   Example: `Last completed: laisse XXIV / line 326 (2026-06-xx).`
2. Repeat **Step 2** for each subsequent chunk, resuming from the ledger, until
   **laisse CCXCI / line ~4002** is complete.
3. Every ~10 laisses, run a **consistency pass**: numbering is continuous and
   gap-free, every original line has a translation line, verb-bracket style is
   uniform, and the mappings table covers all glosses used. Use this checker (extracts
   the per-block original vs. translation line numbers and asserts they are gap-free and
   identical):

   ```bash
   python3 - corpus/chanson.md <<'EOF'
   import re, sys
   txt = open(sys.argv[1]).read()
   blocks = re.split(r'^## Laisse ', txt, flags=re.M)[1:]
   orig, trans = [], []
   for b in blocks:
       parts = re.split(r'\*\*Translation\*\*', b)
       o = parts[0]; t = parts[1] if len(parts) > 1 else ''
       orig  += [int(m) for m in re.findall(r'^(\d+)\.', o, flags=re.M)]
       trans += [int(m) for m in re.findall(r'^(\d+)\.', t, flags=re.M)]
   print("orig:", len(orig), orig[0], "->", orig[-1])
   print("trans:", len(trans), trans[0], "->", trans[-1])
   exp = list(range(orig[0], orig[-1] + 1))   # NB: subtract known lacuna numbers if any fall in range
   print("orig gap-free:", orig == exp)
   print("trans matches orig:", orig == trans)
   EOF
   ```
   (If a *numbered* lacuna line falls in the range, it still carries its number, so it
   counts as present; *unnumbered* lacunae are correctly absent — adjust `exp` only if a
   gap is expected.)
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
