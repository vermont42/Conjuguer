# Fact-check "A History of the French Verb System"

**Status:** not started. Written 2026-07-27 from the Conjugar session that ran the same
check on Conjugar's Spanish essay.

**Run this with ultracode on.** It is a fan-out job: roughly a dozen researchers, each
followed by an adversarial verifier. Say `ultracode` in your opening message, or turn it on
with `/effort`, then point Claude at this file.

## Why this exists

Conjugar's `Info.verbHistoryText` ("A History of the Spanish Verb System") was fact-checked
claim by claim in July 2026. The findings are in
`/Users/josh/Desktop/workspace/Conjugar.mig/docs/history_corrections.md`, and the corrected
prose is in `/Users/josh/Desktop/workspace/Conjugar.mig/docs/verb_history.txt`. Both files
are readable from this session; read them before doing anything else.

**The three essays share their opening sections as near-verbatim variants.** Conjuguer's
first nine sections cover the same ground as Conjugar's, sentence for sentence in places:

| Conjuguer section | Status |
|---|---|
| `From Stardust to Speech` | shared with Conjugar |
| `The Long Road to Language` | shared |
| `The Yamnaya and Proto-Indo-European` | shared |
| `The Verb System of Proto-Indo-European` | shared |
| `Ablaut: The Heart of Indo-European Morphology` | shared, retitled (Conjugar's is "Ablaut, and Why Spanish Nearly Lost It") |
| `The Road to Italy` | shared |
| `The People Already There` | shared |
| `Early Latin and Its Verbs` | shared |
| `The Classical Latin Verb` | shared |
| `Caesar in Gaul` onward | French-specific, never checked |

So a large share of Conjugar's corrections apply here **unchanged**, and the ones that do
not apply are more interesting than the ones that do: they are places where the port
mutated the prose into a different claim.

## What is different here, and will bite

1. **There is no editable extract.** The essay lives on a single JSON line in
   `Conjuguer/Assets/Localizable.xcstrings` under `Info.verbHistoryText`. Editing it there
   is the foot-gun `CLAUDE.md` warns about: the Edit tool renders `\"` as `"` and writes it
   back unescaped, corrupting the catalog.
2. **It is already translated.** `sourceLanguage` is `en`; there are `en` (4,270 words) and
   `fr` (4,721 words) localizations, both marked `translated`. Every correction therefore
   lands in two places, and a hedge that reads correctly in English can be flattened into a
   flat assertion in French. Conjugar's essay is English-only and never faced this.
3. **The markup is not Conjugar's.** No `^…^` headings and no `%…%` tappable terms. See the
   table at the bottom before writing any validator.
4. **Asterisks are linguistics, not markup.** `*e-` and friends are reconstructed-form
   notation. Do not "balance" them.

## Phase 0 — setup, before any fan-out

1. **Extract the essay to `docs/verb_history.txt`**, following the shape Conjugar uses: a
   header block documenting *this app's* markup and its rules, a dashed separator line, then
   the English body verbatim. `docs/purpose_and_use_proposed.txt` in Conjugar established
   the shape; copy it.
2. **Port `scripts/sync_verb_history.py`** from Conjugar, adapting the marker table and the
   link check to this app. Conjugar's version validates four things the parser will not:
   markers balance, markers do not nest, every non-URL link target names a real Info article,
   and no irregularity span starts with a lone capital. Here the link check becomes "every
   `‡…‡` payload is a well-formed URL." Negative-test each validator by corrupting a copy
   before trusting it, and confirm `--check` passes and the round-trip is byte-identical
   before touching anything else.
3. **Read Conjugar's `docs/history_corrections.md` in full.** Give each researcher the
   corrections that fall in its range and tell it to treat them as settled: its job in the
   shared sections is the residue, not a re-litigation.

## Phase 1 — fan out, one researcher per claim-domain

Cluster by subject matter, not by word count. Suggested split:

- **A. Cosmos and dispersal** — `From Stardust to Speech`, `The Long Road to Language`.
- **B. The steppe** — `The Yamnaya and Proto-Indo-European`.
- **C. PIE morphology** — `The Verb System of Proto-Indo-European`, `Ablaut`.
- **D. Italy** — `The Road to Italy`, `The People Already There`. The commissioning prompt
  asked specifically for Etruscan loanwords including *famille* and *personne*, so check
  each etymology individually rather than as a set. Conjugar's run found at least one
  loanword in this list attributed to Etruscan on no good authority.
- **E. Latin** — `Early Latin and Its Verbs`, `The Classical Latin Verb`.
- **F. Caesar** — `Caesar in Gaul`. Dates, Alesia, Vercingetorix, and any casualty or
  enslavement figures, which in popular sources descend from Plutarch and are not defensible
  as stated.
- **G. Gaulish** — `The Gaulish Substrate`. Every lexical item, the vigesimal *quatre-vingts*
  claim, and above all any claim that Gaulish caused a French sound change. The substrate
  explanation for Latin /u/ becoming French /y/ is a genuinely contested hypothesis and must
  not be stated flatly.
- **H. Vulgar Latin and the new future** — `Vulgar Latin and the Spoken Tongue`,
  `Inventing a New Future`. *cantare habeo* > *chanterai*, the Appendix Probi and its
  disputed date, the erosion of final consonants.
- **I. The Franks** — `The Franks and the Name of France`. Frankish superstrate lexicon, the
  w- > gu- change, Clovis, *Francia*, and the h aspiré.
- **J. Standardization** — `The Birth of French`. Serments de Strasbourg (842), the
  Ordonnance de Villers-Cotterêts (1539) and what it actually mandated, the Académie (1635).
- **K. Pronouns** — `The French Verb Since Old French`, `Why French Needs Its Pronouns`,
  `The Rise of On`. The pro-drop loss chronology, *on* < *homo*, and the *nous* > *on* shift.
- **L. The passé simple** — `The Death of the Passé Simple`, `The Verb System Today`. The
  essay was commissioned with the claim that the passé simple is dying "possibly because of
  sound changes that caused ambiguity," citing *choisis*. Verify both halves separately: the
  ambiguity is real, the causal story is a hypothesis, and the tense's survival in some
  spoken varieties is documented.
- **M. Port fidelity** — a dedicated agent that diffs Conjuguer's shared sections against
  Conjugar's corrected `verb_history.txt` and reports three lists: corrections that apply
  here unchanged, claims this essay already words correctly, and claims that mutated during
  the port into something different or worse. This is the highest-value agent in the run.
- **N. Internal consistency** — an agent with **no web access and no cluster**, holding the
  whole essay at once and asking only one question: does anything here contradict anything
  else here? Every other agent in this run reads a range, and a contradiction that lives
  *between* two ranges is invisible to both of them. In the Conjugar run this was the single
  category of error the fan-out structurally could not find, and the one Josh caught himself:
  the opening promised the steppe was "the reason a student has to memorize what *poder* does
  in the first person singular," while the stem-changes section a hundred and twenty-six lines
  later opened by declaring that exact alternation "not an irregularity at all" and used
  *puedo* as its headline example of the thing you do *not* memorize. Two agents each read
  their own line closely enough to find real errors there and neither could see it.
  Have this agent check, at minimum: promises made in the opening against what the body
  delivers; the same form, date, or etymology cited in two places with different values; a
  claim hedged in one section and stated flatly in another; and the closing summary against
  the sections it summarizes. The risk is *higher* in a ported essay than in an original one,
  because a claim revised during the port has every chance of falling out of step with a
  section that was not revised with it.

Rules for every researcher:

- Read the whole essay for context, then check every date, number, name, etymology,
  sound-change derivation, attribution of scholarly consensus, and quoted verb form in range.
- At least 8 to 15 distinct searches each. Prefer peer-reviewed work and standard handbooks
  (Pope, Rickard, Ayres-Bennett, the TLFi, von Wartburg's FEW, Fortson, Weiss, de Vaan) over
  Wikipedia, and say what each source actually states.
- **Judge each claim as written, including its hedges.** A properly hedged claim about a
  contested question is not an error. An unhedged claim about a contested question is, and so
  is a hedge that misrepresents where the consensus sits. This rule matters more than raw
  coverage: a fact-checker with a search engine and no self-skepticism will cheerfully
  "correct" a careful hedge into a confident mistake.
- Record blocked URLs (403, paywall, robots) and route around them via PMC, preprints, or
  mirrors. If a blocked page is decisive, use the Chrome MCP.
- Report a `confirmed` list as well as flags, so coverage is visible.

## Phase 2 — adversarial verification

Pipeline each cluster's findings straight into an independent skeptic, instructed to
**refute** them: research each proposed correction independently rather than re-reading the
first agent's sources, and decide upheld / partly / refuted. Default to skepticism. The
skeptic also hunts for claims the researcher missed. Grade every survivor:

- **factual-error** — a reader would be actively misinformed
- **needs-hedging** — the question is contested and the essay states it flatly
- **nitpick** — a specialist's quibble that misleads nobody

## Phase 3 — the app-internal agent

One agent does no web research. It verifies the essay against this app's own code:

- Every `‡…‡` link is a well-formed, live URL.
- Every `$…$` span reddens the letters the app would actually redden. Uppercase inside `$…$`
  means "irregular, shown red" (`StringExtensions.swift:198`, `isIrregular = char.isUppercase`),
  so each span should be the difference between the real form and its regular composition.
  Conjuguer has a real engine (`Models/Conjugator.swift`, `VerbModel.swift`); run it in a
  temporary Swift Testing test to check the spans, then delete the test file.
- Markers balance and do not nest. Nesting is the failure mode that bit Conjugar: a `$…$`
  inside a `~…~` clobbers the shared start index and duplicates a run, silently.
- Any claim the essay makes about Conjuguer itself matches what the app does.

## Phase 4 — the deliverable

`docs/history_corrections.md`, structured per finding: the quoted claim, its line, the
verdict and severity, what is actually true, the sources, and **concrete replacement prose
in the essay's voice** — same approximate length, markup preserved, and following the house
style Josh set when he commissioned the essay: no em-dashes, no parenthetical expressions,
commas or new sentences instead.

Because this essay is translated, every replacement must be given **in both English and
French**, and the French must carry the same hedge strength as the English. Check the French
separately: a correct English hedge can vanish in translation.

**Do not edit the essay.** The deliverable is the corrections document. Josh decides what
changes.

## This app's markup

From `Conjuguer/Utils/StringExtensions.swift`:

| Marker | Meaning |
|---|---|
| `` `…` `` | subheading |
| `~…~` | bold / emphasis |
| `$…$` | conjugation; uppercase letters inside are irregular, shown red |
| `‡…‡` | link |

There is no `^` marker and no `%…%` tappable term in this app. The parser fails **silently**
on bad markup, exactly as Conjugar's does, which is why the validator script is worth
building before anything else.

## Lessons from the Conjugar run

- Give each subagent absolute paths **inline in its prompt**. Passing them through workflow
  `args` failed there: the values arrived as the literal string `undefined`, and the agents
  only recovered because they were told to report broken instructions rather than guess.
- The shared-prose agent depends on Conjugar's corrections file. Do not start before you can
  read it.
- Expect the skeptic pass to knock down a meaningful share of first-pass findings. That is
  the pass working, not a waste. In Conjugar's run it dismissed **104 of 188 proposals**, and
  one of the kills was a finding already written into the document as a factual error.
- Decomposition is the highest-leverage decision and it has a cost. Cutting by claim-domain is
  what let a specialist overturn the standard account of Spanish's velar verbs, and it is also
  why nobody saw the essay contradict itself across two sections. Agent **N** above exists to
  pay that cost back; do not drop it as redundant.
