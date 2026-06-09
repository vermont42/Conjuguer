# Run the etymology pipeline for the four SELECT verbs

This is a one-shot task for a fresh session. It finishes the etymology work-list by
covering the four rare-but-wanted **select verbs** (the ranked 981 are handled by the
ordinary batch flow). Read `prompts/etymology-pipeline.md` first — it is the source of truth for
the research sources, markup rules, French register, JSON-munging cautions, and the
**subagent prompt template**. This file only specifies *which* verbs to do, the per-verb
notes, and the haïr conjugation oddity that must be worked in.

## The four verbs

These fall below rank 981, so they are not in `prompts/etymology-verbs.json`'s ranked list; they
are the select set named in `prompts/etymology-pipeline.md`. Glosses below are from `verbs.xml`,
augmented with the disambiguating notes from the pipeline.

```
gésir    — be located, lie dead, be buried   (defective; survives mainly in "ci-gît", "ci-gisent", "gisant")
haïr     — hate                               (Frankish/Germanic origin, cognate with English "hate")
ouïr     — listen, hear                       (from Latin audīre; now defective — "ouï-dire", "oyez", "j'ai ouï dire")
saillir  — jut out / to mate                  (TWO senses with two conjugation patterns; ONE etymology keyed on the infinitif)
```

Before launching, confirm which of these are **already** in `Conjuguer/Models/Etymologies.json`
and skip any that are present (the pipeline never overwrites silently):

```python
python3 -c "
import json, pathlib
done = set(json.loads(pathlib.Path('Conjuguer/Models/Etymologies.json').read_text())['en'])
for v in ['gésir','haïr','ouïr','saillir']:
    print(v, 'DONE' if v in done else 'TODO')"
```

## How to run it

Follow the pipeline's per-session procedure, scoped to just these verbs:

1. **Launch subagents (Step 2).** Use the **full subagent prompt template from
   `prompts/etymology-pipeline.md`** — it must be pasted in verbatim and self-contained (research
   sources, two-paragraph shape, tilde markup, curly-quote/guillemet rules, passé-simple
   register, the `ester` worked example, output format). Recommended split: **two
   `general-purpose` subagents** (e.g. {gésir, ouïr} and {haïr, saillir}) launched in a
   single message, or one subagent for all four — these are only four verbs, but they are
   unusual, so keep groups small to preserve research depth. **Delegate all etymology
   writing to subagents; write none yourself.**
2. **Extract from the JSONL transcripts (Step 3)**, validate markup (Step 4) — even tilde
   counts, en/fr tilde match, no `~~`, no ASCII `"`, paragraph break present — and fix any
   mismatches before merging.
3. **Merge (Step 5)** through `json.dumps`/`json.loads` into `Etymologies.json`, **validate
   JSON (Step 6)**, and **report (Step 7)**.

## Per-verb guidance for the subagent prompts

Add these as extra context after "Your verbs" in each subagent's prompt. They sharpen the
research; they do **not** relax the rule that accuracy outranks completeness — if a claim
can't be corroborated on fr.wiktionary / CNRTL / Le Robert, omit it rather than guess.

- **gésir** — from Latin ~iacēre~ (“to lie”). Note its defectiveness: it survives almost
  only in the present and imperfect and in the participle ~gisant~ (also the noun for a
  recumbent tomb effigy), and in the funerary formula ~ci-gît~ (“here lies”). The same
  root underlies ~adjacent~ and, via ~iacere~ “to throw,” the broader Latin family.
- **ouïr** — from Latin ~audīre~ (“to hear”). Once the ordinary verb for hearing, it was
  ousted by ~entendre~ and is now defective, fossilized in ~ouï-dire~ (“hearsay”), the
  archaic court cry ~oyez~, and ~j'ai ouï dire~. Same root as ~audience~, ~audio~,
  ~auditeur~, ~obéir~ (← ~oboedīre~, “to give ear to”).
- **saillir** — from Latin ~salīre~ (“to leap, jump”), PIE *~sel-~. Account for **both**
  senses in one etymology: the “jut out / project” sense and the animal-breeding “to mate /
  cover” sense both descend from “to leap.” Note the split conjugation in modern French
  (the “project” sense vs. the “leap/gush/mate” sense follow different patterns). Cognates:
  ~saillie~, ~saut~, ~sauter~, ~assaillir~, ~tressaillir~; English ~salient~, ~sally~,
  ~assault~.

### haïr — note the regionally specific conjugation oddities

`haïr` is the headline of this batch. Beyond the etymology (Frankish *~hatjan~ /
Old Frankish origin, cognate with English ~hate~, German ~hassen~; via Old French ~haïr~),
the **development paragraph must work in its conjugation oddities** as the memorable
detail, in **both** English and French. Verify each point against reliable sources
(Wiktionnaire, CNRTL, Grevisse / *Le Bon Usage*, Larousse/Robert conjugation tables) —
state only what they corroborate:

- **The tréma drops in the present-singular and 2nd-sg imperative.** In standard French
  `haïr` keeps the diaeresis (ï) throughout *except* the three singular persons of the
  présent de l'indicatif and the singular imperative: **je hais, tu hais, il/elle hait**
  (and imperative **hais**) — written without the tréma and pronounced as a single
  syllable /ɛ/, unlike the disyllabic /a.i/ of ~nous haïssons~, ~je haïssais~, etc.
- **The aspirate h blocks elision and liaison:** ~je hais~ (not *j'hais*), ~le haïr~ — no
  elision, no liaison.
- **Orthographic quirk in the passé simple / imperfect subjunctive:** the tréma replaces
  the circumflex other verbs would take, giving ~nous haïmes~, ~vous haïtes~, ~qu'il haït~
  (not *-îmes/-îtes/-ît*).
- **The regional oddity (the point the user specifically wants noted):** in **Canadian /
  Québécois French** and in much colloquial speech, the present singular is instead
  conjugated *with* the tréma retained and pronounced disyllabically — **je haïs, tu haïs,
  il haït** /a.i/ — diverging from the standard monosyllabic **je hais** /ɛ/. Present this
  as a living regional variation, not an error. Confirm the regional attribution before
  asserting it; if a source only calls it “familiar/colloquial” rather than specifically
  Canadian, describe it that way.

Keep all of this inside the normal two-paragraph etymology (descent, then development +
the conjugation story), in the same register and with the same tilde-bolded forms in
English and French.

## Done criteria

All four verbs present in **both** `en` and `fr` tables of `Etymologies.json`, Step 4
validator clean (even tildes, en/fr match, no stray ASCII quotes), JSON valid (Step 6). At
that point the ranked 981 ∪ the four select verbs are the complete target set; re-run the
Step 7 reporter to confirm what, if anything, remains.
