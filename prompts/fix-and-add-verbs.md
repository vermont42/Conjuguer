# Fix seven bad infinitives and add the missing common verbs

Clean-session prompt. The frequency research of 2026-08-28
([`docs/verb-frequency-sources.md`](../docs/verb-frequency-sources.md), § *Side findings about
`verbs.xml`*) matched every infinitive in `Conjuguer/Models/verbs.xml` against three lexicons and
found seven entries that no dictionary knows because they are misspelled, and fifteen common
verbs the list lacks. This plan fixes both, and gives the added verbs the same treatment their
neighbors in the top 1,500 have: an etymology and an example sentence (with a *Chanson de
Roland* example where the poem contains the verb's own ancestor).

```
Read @prompts/fix-and-add-verbs.md and carry it out end to end: fix the seven bad infinitives
in Conjuguer/Models/verbs.xml, add the fifteen missing verbs, give them etymologies
(via prompts/etymology-pipeline.md — subagents write all etymology text) and example sentences
(open corpus first, a Chanson example wherever the poem contains the verb's ancestor,
Claude-authored only as a last resort), update every hard-coded verb count, build and test with
the ios-build-verify skill, verify in the simulator, and journal in docs/blog_notes.md.
```

## Part A — the seven entries

Five infinitives lost a *v* (one bad transcription pass, by the look of it) and two lost their
accent. Line numbers are as of 2026-08-28.

| Line | Current `in` | `tn` | `mo` | What it is | Action |
|---|---|---|---|---|---|
| 4633 | `préenir` | prevent, notify, warn | 6-7 | *prévenir*, which already exists at line 4673 (`mo="6-7" fr="462"`) | **delete the line** |
| 4962 | `récidier` | reoffend, recidivate | 1-1 | *récidiver* (absent) | rename `in` |
| 5253 | `réolvériser` | shoot with a revolver | 1-1 | *révolvériser* (absent) | rename `in` |
| 6076 | `transaser` | decant | 1-1 | *transvaser* (absent) | rename `in` |
| 1978 | `désenaser` | de-silt | 1-1 | *désenvaser* (absent; cf. `envaser` at line 2752) | rename `in` |
| 2370 | `eduquer` | educate | 1-1 | *éduquer* (absent) | rename `in` |
| 2393 | `egorger` | slit the throat of | 1-2B | *égorger* (absent) | rename `in` |

Before renaming, confirm each target infinitive on fr.wiktionary.org or CNRTL — the point is to
replace a non-word with a word, so a target that turns out unattested should be deleted instead.
The existing `mo` values are right for the targets (`1-2B` is the *manger* pattern, which
*égorger* follows; `1-1` fits the other -er verbs), so a rename touches only `in`.

No JSON references any of the seven — `Etymologies.json`, `literature_examples.json`, and
`chanson_examples.json` were grepped on 2026-08-28 — so nothing else renames with them.

### Editing rules for `verbs.xml`

- **Edit as text**, never through `ElementTree`: the file has a DOCTYPE, hand indentation, and a
  fixed attribute order (`in tn [ay] [re] mo [fr] [dg] [ah] [ex]` — see the emitter in
  `Conjuguer/Views/InputView.swift`, ~line 170). A parse-and-serialize round trip would churn
  all 6,320 lines. `git diff --stat` afterward must show only the lines you meant to touch.
- **Keep the file alphabetical.** The renames mostly land where their misspellings sat (`eduquer`
  → `éduquer` and `egorger` → `égorger` already sort among the *e-* verbs under French
  collation), but check the immediate neighbors of every renamed and added line. A quick
  collation check (macOS ships `fr_FR.UTF-8`):

  ```python
  import locale, re
  locale.setlocale(locale.LC_COLLATE, "fr_FR.UTF-8")
  ins = re.findall(r'<verb in="([^"]+)"', open("Conjuguer/Models/verbs.xml").read())
  for a, b in zip(ins, ins[1:]):
      if locale.strcoll(a, b) > 0:
          print("out of order:", a, ">", b)
  ```

  Pre-existing reports that don't involve your lines can be ignored; report them in the journal.
- Validate afterward: `xmllint --noout --valid Conjuguer/Models/verbs.xml` (xmllint ships with
  macOS; the DOCTYPE is real).
- Do **not** add `fr=` to new entries. The 2021 ranks stop at 981 and come from a corpus; a
  hand-picked rank would be a number that looks measured and is not.

## Part B — the fifteen missing verbs

First, the five named in the research summary, in the order the research listed them. Two of
them are produced by Part A's accent fixes, so this table adds three entries.

| Verb | How it arrives | `mo` | Suggested `tn` | FrWaC hits (for scale) |
|---|---|---|---|---|
| **alléger** | new entry | `1-6C` — the *protéger*/*abréger* pattern (é→è before a mute e, g→ge before a/o: *j'allège, nous allégeons*) | lighten, relieve, ease | 12,288 |
| **éduquer** | rename of `eduquer` | `1-1` | educate, bring up | 10,698 |
| **encaisser** | new entry | `1-1` | cash, collect; take (a blow) | 8,850 |
| **perpétuer** | new entry | `1-1` (like *situer*, *continuer*, *tuer*) | perpetuate | 7,641 |
| **égorger** | rename of `egorger` | `1-2B` | slit the throat of, slaughter | 2,184 |

For scale: 12,288 FrWaC hits puts *alléger* around rank 1,000 in the web corpus; these are
verbs a learner meets. Confirm each `mo` against an existing verb on the same model
(`protéger` is `1-6C` at line 4720; `manger` is `1-2B` at line 3914) rather than by
intuition, and check the app's own future/conditional for `protéger` so *alléger* matches it.

**The other ten** — the rest of the research doc's shortlist; Josh added them to this plan on
2026-08-28. All are new entries. (*récidiver*, also on that list, arrives via Part A.) The base
verb named in the `mo` column is the existing entry whose model the new verb copies; confirm
each against the file rather than trusting the line number.

| Verb | `mo` | Suggested `tn` | FrWaC hits | Notes |
|---|---|---|---|---|
| **dépourvoir** | `4-1C` (*pourvoir*, line 4610) **plus `dg="13"`** | deprive, leave without | 8,632 | Defective. Larousse and Le Robert restrict it to the infinitive, passé simple, participe passé, and compound tenses — which is defect group 13 (*"Impératif is not used. Rare outside passé simple and participe passé."*), today held only by *faillir*. Confirm on CNRTL; if a source disagrees, pick the closest **existing** group rather than adding one. The participle *dépourvu* (and *au dépourvu*) is the living form. |
| **réinvestir** | `2-1` (*investir*, line 3700) | reinvest | 3,863 | |
| **acter** | `1-1` | record, take formal note of; enact | 3,667 | Belgian and legal French first; spread in France in the 2000s |
| **impacter** | `1-1` | impact, affect | 3,408 | In Le Robert, though prescriptivists still object |
| **rediriger** | `1-2B` (*diriger*, line 2177) | redirect | 3,375 | *nous redirigeons* |
| **cartographier** | `1-1` (*photographier*, line 4464) | map, chart | 2,394 | |
| **bloguer** | `1-1` (*naviguer*, line 4155 — *gu* stays before *o*: *nous bloguons*) | blog | 2,570 | |
| **recadrer** | `1-1` (*cadrer*, line 752) | reframe, refocus; rein (someone) in | 2,125 | |
| **redessiner** | `1-1` (*dessiner*, line 2069) | redraw, redesign | 2,060 | |
| **redimensionner** | `1-1` (*dimensionner*, line 2170) | resize | 2,060 | |

Thirteen new entries in all, plus the two renames: `verbs.xml` grows from 6,320 entries to
**6,332** (−1 `préenir`, +13).

### B.1 — *dépourvoir* means touching the defect-group machinery

*dépourvoir* is the one addition that is not a plain `<verb>` line, because it is defective, and
defectiveness in Conjuguer is data: `Conjuguer/Models/defectGroups.xml` defines numbered groups
(`<defectGroup id="…" en="…" fr="…" uo="…"|du="…"/>`), a verb joins one with `dg="<id>"`, and
`VerbView` uses `DefectGroup.isDefectiveForTense(_:)` to mark the unused tenses and show the
group's bilingual description. Read `DefectGroup.swift` (`applyDefect`,
`Tense.tensesForShorthand`, `PersonNumber.byShortDisplayName`) and `DefectGroupParser.swift`
before deciding; the encoding is compact (`du` = "doesn't use" these codes, `uo` = "uses only"
these codes; never both) and the only way to learn it is to read how the existing 26 groups
decode. Then:

1. **Establish the facts** from CNRTL, Larousse, and Le Robert: which tenses *dépourvoir* is
   attested in today (the dictionaries converge on infinitive, passé simple, participe passé,
   and the compound tenses built on *dépourvu*; *au dépourvu* is a fossil).
2. **Fit or add a group.** Group 13 (`du="hA"`: *faillir*'s "Impératif is not used. Rare outside
   passé simple and participe passé.") is the closest existing group and needs no
   `defectGroups.xml` edit — reuse it if "rare outside" is an honest description. If the
   dictionaries say *unused* rather than *rare*, add a new group `27` with `uo` listing exactly
   the used tenses (mind that compound tenses are separate concrete cases — check whether
   listing the participe passé keeps them, or whether they must be listed), an `en` and an `fr`
   description in the file's existing style, and cite the decision in the journal. Do not
   invent a group that no dictionary supports.
3. **Verify in the app**: open *dépourvoir* in `VerbView` and compare with *faillir* — the
   description renders, the unused tenses are marked the way *faillir*'s are, and the participe
   passé still conjugates (`dépourvu`, `dépourvue`, …).
4. **The defective-verb count** in `Info.valuePropositionText` moves (see Part F).

## Part C — prove the conjugations

Add `ConjuguerTests/Models/AddedVerbsTests.swift` (Swift Testing; `@MainActor`; see the
*Testing* section of CLAUDE.md) using the shared helper
`T.testConjugation(infinitif:tense:expected:extraLetters:)` from `ConjuguerTests/TestUtils.swift`.
Cover the forms that exercise each model's quirk:

- *alléger*: `j'allège` (indicatif présent 1s), `nous allégeons`, `il allégea` (passé simple),
  and whatever the app produces for `protéger`'s futur 1s applied to *alléger* (`allégerai` or
  `allègerai` — match the model, then state in the journal which spelling the model yields).
- *égorger*: `nous égorgeons`, `il égorgea`.
- *perpétuer*: `je perpétue`, `nous perpétuons`, `perpétué`.
- *encaisser*: `j'encaisse`, `encaissé`.
- *éduquer*: `nous éduquons` (no c/qu alternation), `éduqué`.
- One form each for the four renamed rare verbs (*récidiver*, *révolvériser*, *transvaser*,
  *désenvaser*), so the renames are pinned.
- *dépourvoir*: `dépourvu` (participe passé) and `il dépourvut` (passé simple — *pourvoir*'s
  *pourvut*, not *voir*'s *vit*); then confirm in the simulator that `VerbView` shows defect
  group 13's note for it, the way it does for *faillir*.
- *réinvestir*: `nous réinvestissons`, `réinvesti`. *rediriger*: `nous redirigeons`,
  `il redirigea`. *bloguer*: `nous bloguons`, `blogué`. *cartographier*: `nous cartographions`.
- One present-tense form and the participe passé each for *acter*, *impacter*, *recadrer*,
  *redessiner*, *redimensionner*.

Run the file alone first, then the whole suite:

```bash
export IBV_SCRIPTS=$(dirname "$(find ~/.claude/plugins/marketplaces -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
"$IBV_SCRIPTS/run_tests.sh" --only-testing ConjuguerTests/AddedVerbsTests
"$IBV_SCRIPTS/run_tests.sh"
```

`VerbModelTests.swift` is generated per *model*, not per verb, so it needs no regeneration.

## Part D — etymologies for the fifteen added verbs

Follow [`prompts/etymology-pipeline.md`](etymology-pipeline.md) exactly as
[`run-etymology-select-verbs.md`](run-etymology-select-verbs.md) did for its four verbs: Step 2
(launch subagents with the **verbatim** prompt template — delegate all etymology writing; write
none yourself), Step 3 (extract from transcripts), Step 4 (validate markup: even tildes, en/fr
match, no `~~`, no ASCII `"`, paragraph break present), Step 5 (merge through `json.loads`/
`json.dumps`), Step 6 (validate JSON), Step 7 (report). Three subagents of five verbs each,
launched in one message, keeps the research depth the pipeline expects.

Precondition check (skip any verb already present — the pipeline never overwrites silently):

```python
python3 -c "
import json, pathlib
done = set(json.loads(pathlib.Path('Conjuguer/Models/Etymologies.json').read_text())['en'])
for v in ['alléger','éduquer','encaisser','perpétuer','égorger','dépourvoir','réinvestir',
          'acter','impacter','rediriger','cartographier','bloguer','recadrer','redessiner',
          'redimensionner']:
    print(v, 'DONE' if v in done else 'TODO')"
```

Research hints to hand the subagents (leads, not claims — the pipeline's rule that accuracy
outranks completeness still governs; drop anything fr.wiktionary / CNRTL / Le Robert won't
corroborate):

- **alléger** — Old French *alegier*, from Late Latin *alleviāre* (*ad-* + *levis*, "light");
  same family as *léger*, *soulager*, *allègement*; English *alleviate*, *levity*. Note the
  modern spelling hesitation *allégera*/*allègera* (the 1990 rectifications) — the app's model
  picks one, and the etymology can mention the doublet.
- **éduquer** — a learned 15th/16th-century borrowing from Latin *ēducāre* ("to rear, bring
  up"), a frequentative related to *ēdūcere* ("to lead out"); it displaced no inherited form;
  cognate *éducation*, English *educate*. Worth a sentence on why *élever* was the everyday verb.
- **encaisser** — *en-* + *caisse*, from Occitan/Provençal *caissa* < Latin *capsa* ("box");
  the sense chain box → cash box → to cash (a cheque) → to take (a blow, colloquial);
  English *case*, *cash*, *capsule* are cousins.
- **perpétuer** — Latin *perpetuāre*, from *perpetuus* ("continuous, uninterrupted"), *per-* +
  *petere* ("to seek, to go toward"); cognate *perpétuel*, *perpétuité*, English *perpetuate*.
- **égorger** — *é-* (Latin *ex-*) + *gorge*, from Late Latin *gurga* / Latin *gurges*
  ("whirlpool, gullet"); the sense "cut the throat" then "slaughter, fleece (a customer)";
  cognates *gorge*, *engorger*, *dégorger*, English *gorge*, *regurgitate*.
- **dépourvoir** — *dé-* (Latin *dis-*) + *pourvoir*, from Latin *prōvidēre* ("to foresee,
  provide for"); Old French *desporveoir*; the participle *dépourvu* ("destitute of", and *au
  dépourvu*, "off guard") is what survives; cognates *pourvoir*, *prévoir*, English *provide*,
  *purvey*.
- **réinvestir** — *re-* + *investir*, from Latin *investīre* ("to clothe, to surround");
  the money sense came through Italian *investire* and English *investment*; cognates *vêtir*,
  *investiture*, English *invest*.
- **acter** — from *acte* (Latin *āctum*, "a thing done"), long confined to Belgian and legal
  French (*acter une décision*) before spreading in France in the 2000s; the Académie's
  reservations are part of the story; cognates *acte*, *actionner*, English *act*.
- **impacter** — from *impact* (Latin *impactus*, past participle of *impingere*, "to strike
  against"); attested in the 1980s–90s under the influence of English *to impact*, and much
  criticized; cognates *impact*, English *impinge*.
- **rediriger** — *re-* + *diriger*, from Latin *dīrigere* ("to set straight, direct"); the
  web sense (redirect a URL) is a 1990s calque of English *redirect*; cognates *direct*,
  *dresser* (< *dīrēctiāre*), English *direct*.
- **cartographier** — from *cartographie* (*carte* + *-graphie*, 1830s); *carte* < Latin
  *charta* < Greek *khártēs* ("sheet of papyrus"); cognates *carte*, *charte*, English *chart*,
  *card*.
- **bloguer** — from *blog* (English *weblog*, 1997–99), attested in French around 2002–03;
  the Office québécois's *bloguer* over *blogger* is a nice detail; cognates *blog*, *blogueur*.
- **recadrer** — *re-* + *cadrer*, from *cadre* < Italian *quadro* < Latin *quadrum*
  ("square"); photographic "reframe" (20th c.), then figurative "bring back into line"
  (*recadrer un employé*); cognates *cadre*, *quadrilatère*, English *quadrant*, *square*.
- **redessiner** — *re-* + *dessiner* < Italian *disegnare* < Latin *dēsignāre* ("to mark
  out"); the same Latin gave the learned *désigner* — a doublet worth a sentence; English *design*.
- **redimensionner** — *re-* + *dimensionner*, from *dimension* < Latin *dīmēnsiō* ("a
  measuring out", from *mētīrī*); the computing sense (resize) is late 20th century; cognates
  *mesurer*, *mètre*, English *measure*, *dimension*.

## Part E — example sentences

`Conjuguer/Models/literature_examples.json` (the bundled copy; identical to
`corpus/json/literature_examples.json` — the two must stay byte-identical) is keyed by verb id
(`Verb.infinitifWithPossibleExtraLetters`; bare infinitive here) with values
`{fr, en, source, line, token}`. Read the *Literature-Example Corpus* section of CLAUDE.md and
[`docs/literature-example-corpus.md`](../docs/literature-example-corpus.md) before touching it.

### E1. Modern example — corpus first

The source texts are on disk under `corpus/originals/{literature,government,technology,wikipedia,classical}/`
(gitignored, but present as of 2026-08-28). For each of the fifteen verbs, search the tiers for a
genuinely **verbal** use — not the nouns *allègement*, *éducation*, *caisse*, *impact*,
*cartographie*, *blog*, or the adjectives *perpétuel* and *dépourvu*-as-adjective — with a stem
regex (`allég|allèg`, `éduqu`, `encaiss`, `perpétu`, `égorg`, `dépourv`, `réinvest`, `act[eé]`,
`impact[eé]`, `redirig`, `cartographi`, `blogu`, `recadr`, `redessin`, `redimensionn`) or by
generating the verb's forms with the conjugator. The technology, government, and Wikipedia tiers
are the likeliest homes for *rediriger*, *redimensionner*, *bloguer*, *cartographier*, *acter*,
and *impacter*; the novels for *dépourvoir* and *égorger*. Prefer a self-contained sentence with a clean
translation. Record it in the pipeline's schema: `source` = the originals filename, `line` =
1-based line in that file, `token` = the conjugated form. The tier's license and attribution
are already handled by `ExampleSource` and the Credits text (`proust-…`/`zola-…`/
`flaubert-…`/`lafontaine-…`/`moliere-…` public domain; `ch-…` Swiss PD; `fr-…` Etalab;
`wp-…` CC BY-SA). Check the four provenance manifests under `docs/` if you add a *new* source
file; do not add new source texts for these verbs.

### E2. Chanson de Roland example — if the poem contains the verb's ancestor

The Chanson pipeline (`corpus/working/build_chanson_examples.py`, driven by
`corpus/grokked/chanson.md` bracket glosses and `corpus/grokked/chanson_descendants.json`)
attaches a Roland example to a modern verb **only when the line genuinely contains that verb's
own ancestor form** — the reflex policy in `docs/literature-example-corpus.md`. So for each new
verb, look for the Old French ancestor in `corpus/originals/literature/chanson-roland-oxford.txt`
and in the bracket glosses of `chanson.md`: *alegier* / *alegement* for *alléger*, *esgorgier*
for *égorger*, *desporveir* / *despurveir* for *dépourvoir*; the other twelve are later
borrowings or modern formations and almost certainly absent. A grep on 2026-08-28 found no
*alegier*, *esgorgier*, or *desporv-* forms in either file, so expect "none available" — but
check, because the point of the reflex table is that these attachments are audited, not
guessed.

If an ancestor **is** there: add the bracket gloss on that line in `chanson.md`
(`head (modern)` form), add or confirm the `head → descendant` row in
`chanson_descendants.json` with a confidence and note, re-run `build_chanson_examples.py` (it
writes both `corpus/json/chanson_examples.json` and the bundled
`Conjuguer/Models/chanson_examples.json`), and confirm the new key in its coverage report.
If not, write "no Chanson example: ancestor absent from the Oxford text" in the journal and move
on. Never attach a line whose gloss is only a synonym.

### E3. Claude-authored fallback — last resort, and it has consequences

If no open tier uses a verb verbally, author a sentence the way `docs/authored-examples.md`
documents (verbal form, natural register, English translation), with `"line": null` and a
`source` beginning with `Claude`. Two things then have to change with it:

- `VerbView.sourceClaude` (en/fr in `Localizable.xcstrings`) hard-codes *"example written by
  Claude (Opus 4.8)"*, and `ExampleSource.init` maps any `Claude…` source to that one label.
  A sentence written by this session is not Opus 4.8. Either carry the model name in the
  source string (`"Claude (Fable 5)"`) and make `ExampleSource.claude` carry it through to a
  parameterized label (`— example written by %@`), or keep the label model-free. Do not ship a
  label that names the wrong model.
- `Info.creditsText` says "Eighty-two verbs had no clean verbal use … written originally by
  Claude (Opus 4.8)" in both languages. Update the count and the wording, and add the new rows
  to `docs/authored-examples.md`.

### E4. Writing the JSON

Insert the new keys in alphabetical position and write with `json.dump(indent=1,
ensure_ascii=False)` — that is the file's existing format — to **both** copies, then verify:

```bash
cmp Conjuguer/Models/literature_examples.json corpus/json/literature_examples.json && echo identical
git diff --stat   # only additions on the two example files
```

`ExampleData.example(for:)` looks up by `infinitifWithPossibleExtraLetters`, falling back to
`infinitif`, so no code changes are needed for the lookup.

## Part F — every hard-coded count

`verbs.xml` goes from 6,320 entries to **6,332** (−1 `préenir`, +13 new). Update:

| Where | Today | Note |
|---|---|---|
| `README.md` lines 6 and 18 | 6,320 | |
| `CLAUDE.md` lines 282 and 339 | 6,320 | line 339 also describes `fr` — leave that to the frequency plan |
| `docs/project-structure.md` line 83 (`verbs.xml`) | 6,320 | |
| `Onboarding.browseTitle`, `Onboarding.browseBody` (en + fr) | 6,320 / 6 320 | French uses a thin/plain space: `6 332` |
| `Info.irregularitiesText` (en; check fr) | "Of the 6,314 verbs … 5,217 have conjugations that are completely regular" | **already stale** (6,314 ≠ 6,320) |
| `Info.valuePropositionText` (en + fr) | "5,217 regular … 1,097 irregular" | same stale split; the "top 981 … from être to ancrer" sentence is the frequency plan's |
| `Info.valuePropositionText` (en + fr) | "full conjugations for sixty-six defective French verbs" / "soixante-six" | **already stale**: 71 distinct infinitifs carry `dg` today, and *dépourvoir* makes 72 — recount distinct infinitifs with `dg` and fix both languages |

Recompute the regular/irregular split rather than nudging it: after `VerbData.loadSynchronously()`
(or inside a temporary `@Test`), count distinct infinitifs whose model has
`VerbModel.models[verb.model]?.irregularity == 0` (`VerbModel.computeIrregularities()` sets it,
and `VerbData.publish` runs it), and use that pair. Leave historical prose alone
(`docs/blog_notes.md`, `docs/video_script.md`, `docs/screenshot-playbook.md`, the
`take_screenshots.sh` comment, old prompts).

`Localizable.xcstrings` rules from CLAUDE.md apply: edit values that gain or lose an ASCII `"`
only via Python on the raw file; validate with
`python3 -c "import json; json.load(open('Conjuguer/Assets/Localizable.xcstrings'))"` after every
edit; when an English long text changes, relocalize the French by the *Relocalization Workflow*
rules (French grammatical terms and quoted French stay French; markup positions preserved).

## Part G — verify and journal

1. `build_app.sh && launch_app.sh`, then in the Verbs tab tap the search field (≈ `201,191` on
   iPhone 17), `axe type "alléger"`, open the row (`tap_id.sh verb_row_alléger`), and
   `screenshot.sh added_verb_alleger`: the etymology and the example card (`verb_example`) must
   both render. Repeat for one renamed verb (`éduquer`) to confirm the rename reached the UI.
2. `python3 scripts/check_docs.py` (link and project-structure checks).
3. Append a `## … (YYYY-MM-DD)` entry to `docs/blog_notes.md`: what was wrong, what was renamed
   versus deleted, which examples were mined versus authored, whether any Chanson ancestor
   turned up, which defect group *dépourvoir* got and why, and the recomputed
   regular/irregular and defective counts.
4. Do not commit; Josh commits. The SwiftLint pre-commit hook will run `--strict` when he
   does, so mind `conditional_returns_on_newline` in the new test file now.

## Done criteria

- `xmllint --valid` passes; the seven bad spellings are gone; all thirteen new entries exist
  (*alléger*, *encaisser*, *perpétuer*, *dépourvoir* with its defect group, *réinvestir*,
  *acter*, *impacter*, *rediriger*, *cartographier*, *bloguer*, *recadrer*, *redessiner*,
  *redimensionner*); the entry count is 6,332 and every listed count says so.
- `AddedVerbsTests` and the full suite pass.
- All fifteen added verbs have `en` and `fr` etymologies (Step 4 validator clean) and an example
  with honest provenance in both JSON copies; Chanson examples added wherever an ancestor
  exists, and the journal says where it does not.
- Journal entry written, `check_docs.py` clean, working tree left for Josh to commit.
