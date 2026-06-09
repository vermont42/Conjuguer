# French Etymology Generation Pipeline

## Status

Seeded and live. `Conjuguer/Models/Etymologies.json` exists, `Etymology.swift` already
reads it (etym-starter.md step 4 is done), and the first verbs are in. **There is no stored "next
verb"** — resume by diffing the work-list against the keys already in `Etymologies.json`
(Step 1 / Step 7 do this automatically). To see where things stand, run the Step 7
one-liner. Just start at **Step 1** each session; Step 0 (seeding) is already complete.

## Goal

Populate `Conjuguer/Models/Etymologies.json` with an etymology for every verb in the
work-list (`etymology-verbs.json` — the 981 most-used verbs — plus the select verbs
below), in **both English and French**. The app reads this file via `Etymology.swift`
(see `etym-starter.md`, step 4).

This pipeline **generates** etymologies from research. (Konjugieren's analogous pipeline
only *translated* pre-existing English text; ours must research and write from scratch,
then render a parallel French version.) Run it repeatedly across sessions, a batch at a
time, until the work-list is exhausted.

## Output shape

`Conjuguer/Models/Etymologies.json` is keyed **language → infinitif → text**, exactly as
`Etymology.swift` expects:

```json
{
  "en": { "ester": "From Old French ~ester~ …", "...": "..." },
  "fr": { "ester": "De l'ancien français ~ester~ …", "...": "..." }
}
```

Each verb appears under both `"en"` and `"fr"`. Keys are sorted alphabetically.

### Both languages are required

Every verb **must** have both an English (`"en"`) and a French (`"fr"`) entry — French is
never optional. English is also the fallback: `Etymology.text(for:)` returns the `"en"`
text when the device language has no entry, so a missing English entry would leave some
users with nothing. A batch is not complete until both tables contain every verb in it; the
Step 4 validator rejects any verb missing either language. The French entry is written in
the literary register (passé simple, guillemets — see below).

## The work-list

`etymology-verbs.json` (in this `prompts/` folder) is the source of truth for *which*
verbs to cover and in what order:

```json
{ "count": 981,
  "verbs": [ { "rank": 1, "infinitif": "être", "gloss": "be" }, … ] }
```

`gloss` is the verb's English translation (from `verbs.xml`), handed to subagents as
disambiguating context. Process verbs in ascending `rank` order so the most useful verbs
get etymologies first.

### Select verbs (beyond the ranked 981)

A handful of rare-but-interesting verbs are covered even though they fall below rank 981. These are all done.

```
ester    (already authored — see seeding below)
gésir    (to lie / be lying; defective — "ci-gît")
haïr     (to hate; Frankish/Germanic origin, cognate with English "hate")
ouïr     (to hear; from Latin audīre, now defective — "ouï-dire", "oyez")
saillir  (to jut out / to mate; two conjugation patterns — see below)
```

Add more here as desired. For each select verb, look up its gloss once:
`python3 -c "import xml.etree.ElementTree as ET; print({v.get('in'):v.get('tn') for v in ET.parse('Conjuguer/Models/verbs.xml').getroot().iter('verb')}.get('gésir'))"`

The **target set** for the pipeline is the 981 ranked verbs ∪ the select verbs.

### Verbs with two conjugation patterns

A few verbs carry two entries in `verbs.xml` — one per conjugation pattern — most notably
`sortir` (intransitive *je suis sorti*, “to go out” / transitive *j'ai sorti*, “to take
out”; rank 56) and `saillir` (“to jut out” / “to mate”). Etymology is a property of the
**word**, not the conjugation pattern, so each such verb gets **one** entry keyed on its
infinitif, and it displays for both patterns. The work-list joins the two senses in
`gloss` (e.g. `sortir → "obtain; exit"`); the subagent should write a single etymology
that accounts for **both senses** where they share an origin.

---

## Per-session procedure

> **Working directory:** run all the Python/bash snippets below from the **repo root**
> (`/Users/josh/Desktop/workspace/Conjuguer`). That is why paths are repo-root-relative:
> the work-list is `prompts/etymology-verbs.json` (it lives beside this file) and the output
> is `Conjuguer/Models/Etymologies.json`.

### Step 0 (first session only): seed `Etymologies.json` — ✅ DONE

Already complete: `Conjuguer/Models/Etymologies.json` was seeded with the `ester` entry and
the file is live. Skip this step; begin at Step 1. (Kept for the record: seeding wrote
`{"en": {"ester": …}, "fr": {"ester": …}}` via `json.dumps`, so the pipeline could
accumulate into it.)

### Step 1: select the next batch

Compute the next BATCH of verbs = the smallest-numbered ranks (rank 1 = most-used first)
not yet in `Etymologies.json`.
Recommended batch: **5 subagents × ~8 verbs = ~40 per session** (generation + web research
is heavier than translation, so keep batches modest to avoid context compaction mid-run).

```python
python3 << 'ENDPY'
import json, pathlib
BATCH = 40
worklist = json.loads(pathlib.Path('prompts/etymology-verbs.json').read_text())['verbs']
select = [  # rare-but-wanted verbs below rank 981; rank 10_000 just sorts them last
    {"rank": 10_000, "infinitif": "gésir",   "gloss": "lie, be lying"},
    {"rank": 10_001, "infinitif": "haïr",    "gloss": "hate"},
    {"rank": 10_002, "infinitif": "ouïr",    "gloss": "listen, hear"},
    {"rank": 10_003, "infinitif": "saillir", "gloss": "bulge; mate"},
]
targets = worklist + select
done = set(json.loads(pathlib.Path('Conjuguer/Models/Etymologies.json').read_text())['en'])
todo = [v for v in targets if v['infinitif'] not in done][:BATCH]
print(f"{len([v for v in targets if v['infinitif'] not in done])} remaining; next {len(todo)}:")
for v in todo:
    print(f"  {v['rank']:>5}  {v['infinitif']:<16} {v['gloss']}")
# Split into ~8-verb groups for subagents and stash as JSON for the prompts:
groups = [todo[i:i+8] for i in range(0, len(todo), 8)]
pathlib.Path('/tmp/etym_batch.json').write_text(json.dumps(groups, ensure_ascii=False))
print(f"{len(groups)} groups -> /tmp/etym_batch.json")
ENDPY
```

### Step 2: launch parallel subagents

Launch one `general-purpose` subagent per group **in a single message** (parallel Agent
tool calls). Give each the self-contained prompt in the next section, substituting its
group's verbs (infinitif + gloss). Do **not** write etymologies yourself — delegate all of
them.

### Step 3: extract results from subagent transcripts

Subagents return a JSON object as their final text. Read it from the persisted JSONL
transcripts (survives context compaction), not from the live tool result:

The agent id alone locates the transcript — no session id needed. Each Agent tool result
prints its `agentId`; `find` resolves the path under whatever session dir is current
(there are several, so don't hard-code one):

```python
python3 << 'ENDPY'
import json, pathlib, subprocess
# (agent_id, output) — one per subagent; agent ids come from this run's Agent results.
agents = [("AGENT_ID_1", "/tmp/etym_g1.json"),
          ("AGENT_ID_2", "/tmp/etym_g2.json")]
for aid, out in agents:
    hit = subprocess.run(
        ["find", str(pathlib.Path.home() / ".claude"), "-path", "*subagents*",
         "-name", f"agent-{aid}.jsonl"],
        capture_output=True, text=True).stdout.splitlines()
    assert hit, f"transcript not found for {aid}"
    text = ""
    for line in pathlib.Path(hit[0]).read_text().splitlines():
        try: obj = json.loads(line)
        except: continue
        if obj.get("type") != "assistant": continue
        for b in obj.get("message", {}).get("content", []):
            if b.get("type") == "text": text = b["text"]
    text = text[text.find("{"):]      # drop any preamble before the JSON
    data = json.loads(text)
    pathlib.Path(out).write_text(json.dumps(data, ensure_ascii=False))
    print(f"{aid}: {len(data)} verbs -> {out}")
ENDPY
```

Substitute the agent ids from this run's Agent results.

**If `json.loads` raises `Extra data`,** the subagent emitted more than one top-level JSON
object in its final message (seen in practice: an agent that wrote an `en`-only block, then
a separate `fr`-only block, then a combined object). The single-object slice above grabs the
first one. Recover by scanning **all** top-level objects with `raw_decode` and keeping the
entries that carry both `en` and `fr`:

```python
python3 << 'ENDPY'
import json
dec = json.JSONDecoder()
objs, i = [], 0
while i < len(text):
    if text[i] == "{":
        try:
            o, end = dec.raw_decode(text, i); objs.append(o); i = end; continue
        except json.JSONDecodeError:
            pass
    i += 1
merged = {}
for o in objs:
    for verb, langs in o.items():
        if isinstance(langs, dict) and "en" in langs and "fr" in langs:
            merged[verb] = langs          # complete pair wins
        elif verb not in merged:
            merged.setdefault(verb, {}).update(langs)
data = {v: l for v, l in merged.items() if "en" in l and "fr" in l}
ENDPY
```

### Step 4: validate markup before merging

For every `(verb, lang)` value, check:

```python
python3 << 'ENDPY'
import json, glob
problems = []
for f in glob.glob('/tmp/etym_g*.json'):
    for verb, langs in json.load(open(f)).items():
        for lang in ("en", "fr"):
            t = langs.get(lang, "")
            if not t:                        problems.append((verb, lang, "MISSING"))
            if t.count("~") % 2:            problems.append((verb, lang, "odd ~ count"))
            if "~~" in t:                    problems.append((verb, lang, "~~ double tilde"))
            if '"' in t:                     problems.append((verb, lang, 'ASCII \" in prose'))
            if "\\n" in t:                   problems.append((verb, lang, "literal backslash-n"))
            if "\n\n" not in t:              problems.append((verb, lang, "no paragraph break"))
        # en/fr should bold the same forms -> tilde counts should match
        if langs.get("en","").count("~") != langs.get("fr","").count("~"):
            problems.append((verb, "en/fr", "tilde count mismatch"))
print("OK" if not problems else f"{len(problems)} issues:")
for p in problems: print("  ", p)
ENDPY
```

Fix issues (usually a stray tilde or an ASCII `"` that should be `“ ”`/`« »`) before
merging. A tilde-count mismatch between `en` and `fr` means one language bolded a form the
other didn't — reconcile them.

### Step 5: merge into `Etymologies.json`

Never hand-write JSON or put etymology text in a shell heredoc/inline dict — always go
through `json.dumps`/`json.loads`:

```python
python3 << 'ENDPY'
import json, glob, pathlib
p = pathlib.Path('Conjuguer/Models/Etymologies.json')
data = json.loads(p.read_text())
n = 0
for f in glob.glob('/tmp/etym_g*.json'):
    for verb, langs in json.load(open(f)).items():
        data["en"][verb] = langs["en"]
        data["fr"][verb] = langs["fr"]
        n += 1
for lang in data: data[lang] = dict(sorted(data[lang].items()))
data = dict(sorted(data.items()))
p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
print(f"merged {n}; totals en={len(data['en'])} fr={len(data['fr'])}")
ENDPY
```

### Step 6: validate JSON & summarize

```bash
python3 -c "import json; d=json.load(open('Conjuguer/Models/Etymologies.json')); print('Valid.', len(d['en']),'en /',len(d['fr']),'fr')"
```

Print a short table: verb | first 60 chars of the English etymology | en/fr tilde match.

### Step 7: report progress

```python
python3 -c "
import json, pathlib
wl = json.loads(pathlib.Path('prompts/etymology-verbs.json').read_text())['verbs']
done = set(json.loads(pathlib.Path('Conjuguer/Models/Etymologies.json').read_text())['en'])
todo = [v for v in wl if v['infinitif'] not in done]
print(f'Done {len(wl)-len(todo)}/{len(wl)} ranked verbs.', 
      f'Next: {todo[0][\"infinitif\"]} (rank {todo[0][\"rank\"]})' if todo else 'ALL RANKED VERBS DONE.')"
```

When the ranked 981 (and any select verbs) are all present in both tables, the pipeline is
complete and `etym-starter.md` step 4 (switch `Etymology.swift` to read the JSON) can proceed.

---

## Subagent prompt template

Give each subagent the prompt below, substituting **YOUR VERBS** with its group (each verb
as `infinitif — gloss`). The prompt is fully self-contained; the subagent cannot see this
file.

> You are a careful etymologist writing short, engaging verb etymologies for a French-verb
> learning app. You will be given several French verbs. For each, produce an etymology in
> **two languages, English and French**, conveying the same content. Do NOT write any
> files. Return ONLY the JSON object described at the end.
>
> ## Your verbs
>
> YOUR VERBS  *(e.g. `aimer — like, love`, one per line)*
>
> ## Research
>
> Base each etymology on reliable sources. **Prefer French Wiktionary
> (fr.wiktionary.org) as your primary source**, but use the two Wiktionaries for different
> things — they are organized differently and each is richer on a different axis:
> - **fr.Wiktionary** is the better *primary* source for the **French-specific** descent
>   (Old/Middle French forms, attestation dates), the native semantic-development notes, and
>   explicit dispute-flagging citing the TLFi/Littré/Académie. It also has **far broader
>   headword coverage** — rare French lemmas, regionalisms, archaisms, and obscure
>   derivatives that en.Wiktionary simply lacks an entry for — which matters for the select
>   rare verbs and for tracing derived-word families.
> - **en.Wiktionary** is usually richer for the **deep etymological chain** — the
>   Proto-Indo-European / Proto-Italic / Proto-Germanic reconstructions and the
>   cross-language cognate sets — because it maintains dedicated reconstruction pages and
>   per-etymon entries (`pingo`, `cedo`, `vigil`) and links them aggressively. fr.Wiktionary
>   verb étymologies are frequently a single sentence that stops at the Latin source and put
>   cognates/derivatives in a separate *Apparentés* box.
>
> So: take the French chain, register, and dispute notes from fr.Wiktionary; cross-reference
> en.Wiktionary's etymon/reconstruction pages for the PIE root and the cognates. (Don't
> assume fr.Wiktionary is "more detailed" overall — a 10-verb audit found its verb
> étymologies were the *thinner* of the two for 8 of 10 sampled verbs.)
> Corroborate and supplement with the CNRTL/TLFi (cnrtl.fr), the Dictionnaire de l'Académie
> française, and Le Robert. Use web search to
> verify the chain of descent and the reconstructed roots whenever you are not certain.
> **Write original prose** — do not copy source text. **Accuracy outranks completeness:**
> if a detail is genuinely uncertain, omit it rather than guess. Never invent a root or a
> cognate.
>
> ## Disputed origins — mark them, don't launder them
>
> When the origin of a verb (or of one vivid detail) is **disputed or merely proposed** in
> the sources, you have two acceptable choices: omit it, **or present it explicitly as
> disputed** — *never assert one contested hypothesis as settled fact.* The single most
> engaging, quotable detail of an entry is disproportionately the disputed one, and the
> temptation is to narrate it confidently; resist that. Concretely:
>
> - If fr.Wiktionary hedges (`peut-être`, `probablement`, `plutôt que`, `on rattache
>   parfois`, two competing accounts), **carry the hedge into your prose**: write *« selon
>   une hypothèse… »* / “by one account…”, *« le TLFi écarte l'idée que… »* / “the TLFi
>   rejects the idea that…”, “the origin is debated; the favored account is…”.
> - **Do not invent a literal concretization** of a figurative or uncertain development and
>   present it as the explanation. (Real failure caught in audit: `tromper` was given “*se
>   tromper de quelqu'un* = to blare a horn in someone's face” as “the favored explanation,”
>   which appears in no source and suppressed a rival theory.)
> - **Do not assert a descent step the sources don't support.** (Audit: `glisser`'s “from
>   Latin ~glaciāre~” — fr.Wiktionary gives only Frankish *~glidan~, and en.Wiktionary
>   routes the icy half through Frankish too, so the Latin step is uncorroborated.) If the
>   primary source gives a simple origin and a fuller blend appears only elsewhere, say so
>   (“traditionally also explained as a blend of…”) rather than presenting the blend as the
>   plain chain.
> - **Do not build a flourish on an unproven premise.** (Audit: `regretter`'s “Norse
>   raiders left a word for lamentation… crossed the Channel twice” dresses up an origin
>   fr.Wiktionary only proposes and en.Wiktionary routes differently.) A memorable closing
>   line is welcome — but only on facts that are actually settled.
>
> Marking disputes keeps the engaging detail (which is the point of the entry) while
> removing the only real accuracy risk. When you hedge, hedge **identically in both
> languages** so en/fr stay parallel.
>
> ## What to write (per verb)
>
> Two paragraphs, ~120–220 words each:
>
> 1. **Descent.** The chain from the modern French verb back through Old/Middle French to
>    Latin (or Frankish/Germanic, Greek, etc.) and, where well established, the
>    Proto-Indo-European root — plus a notable cognate or two in other languages (Italian,
>    Spanish, English, German…).
> 2. **Development.** How the meaning evolved, a memorable or surprising detail, and a few
>    modern French words descended from the same root. **If the memorable detail rests on a
>    disputed or proposed origin, mark it as such** (see “Disputed origins” above) — don't
>    state it as settled fact.
>
> Tone: educational, precise, engaging. Same content and level of detail in both
> languages.
>
> ## Markup (identical rules for both languages)
>
> - **Bold** every cited word-form, ancestral form, cognate, affix, and root by wrapping it
>   in a **single tilde on each side**: `~ester~`, `~stāre~`, `~re-~`. Bold **nothing
>   else** — not ordinary prose.
> - **Never** use double tildes (`~~mot~~`). The count of `~` in each value must be
>   **even** (every opener has a closer).
> - **Bold the same set of forms in the English and French versions**, so the two have the
>   same number of tildes.
> - **A bolded cognate must be introduced as a cognate in BOTH languages** — e.g. English
>   `~leash~` / l'anglais `~leash~`. **Never bold an English word that appears only as an
>   inline aside in the English prose** (e.g. "a dog's ~leash~", "a fellow ~liver~"): the
>   French version has no parallel for it, so the tilde counts diverge. Either present it
>   symmetrically as a named cognate in both languages, or leave it un-bolded in both.
> - **When you cite the headword verb inside an example phrase** ("rendre des comptes"),
>   bold it in **both** languages or **neither** — don't bold the bare verb in one language
>   while glossing it in quotes in the other.
> - **Reconstructed (unattested) forms** take a literal asterisk *before* the bold:
>   `*~steh₂-~`, `*~bʰuH-~`. Keep the asterisk outside the tildes.
> - **Subscripts/superscripts** in roots are written with real Unicode characters, never
>   markup: subscripts `₀₁₂₃` (e.g. `*~h₂epo~`), superscript modifier letters `ʰ ʷ ʲ`
>   (e.g. `*~bʰuH-~`). 
> - **Before returning, count the `~` characters in each verb's `en` string and in its `fr`
>   string — they MUST be equal.** If they differ, you bolded a form in one language that
>   you didn't bold in the other; find it and fix it. This en/fr tilde mismatch is the
>   single most common error, so do this check for every verb before you output the JSON.
>
> ## Quotation marks (keep JSON safe)
>
> - **English:** use curly quotes for glosses — `“to stand”`, not ASCII `"`.
> - **French:** use guillemets — `« se tenir debout »`.
> - **Never put an ASCII straight double-quote `"` anywhere in the prose.** It must appear
>   only as a JSON string delimiter. (Apostrophes — `l'ancien`, `s'être` — are fine.)
>
> ## French register
>
> Narrate historical development in the **passé simple**, the literary past tense, not the
> passé composé: write `fut`, `absorba`, `reprit`, `devint` — never `a été`, `a absorbé`,
> `est devenu`. Use natural, idiomatic French throughout.
>
> ## Paragraph break
>
> Separate the two paragraphs with one blank line (a real line break in the string).
>
> ## Worked example (the verb `ester`)
>
> `{"ester": {`
> `"en": "From Old French ~ester~ (“to stand, to be standing, to remain”), from Latin ~stāre~ (“to stand”), from Proto-Italic *~stāō~, from PIE *~steh₂-~ (“to stand”). Cognate with Italian ~stare~ and Spanish ~estar~, which survive as everyday verbs, and — through the same root — with English ~stand~ and ~stay~.\n\nIn Old French, ~ester~ was fully conjugated and meant “to stand” or “to remain.” Its territory was gradually carved up by other verbs: ~rester~ (~re-~ + ~ester~, “to remain behind”) took over the sense “to stay,” while ~être~ absorbed others. Most strikingly, the past participle of ~être~ — ~été~ — descends not from Latin ~esse~ (“to be”) but from ~status~, the past participle of ~stāre~ (“to stand”), the same root as ~ester~: ~être~ is a suppletive verb, and its “having been” is, etymologically, a “having stood.” Stripped of these everyday roles, ~ester~ survives in modern French only as a defective legal term, in the fixed expression ~ester en justice~ (“to appear before a court, to bring suit”), conjugated in almost no tenses — a fossil of a once-central verb. The same PIE root *~steh₂-~ underlies a vast family of French words, among them ~stable~, ~station~, ~statue~, ~constant~, and ~rester~ itself.",`
> `"fr": "De l'ancien français ~ester~ (« se tenir debout, rester »), du latin ~stāre~ (« se tenir debout »), de l'italique commun *~stāō~, de l'indo-européen *~steh₂-~ (« se tenir debout »). Apparenté à l'italien ~stare~ et à l'espagnol ~estar~, restés des verbes courants, ainsi qu'à l'anglais ~stand~ et ~stay~, issus de la même racine.\n\nEn ancien français, ~ester~ se conjuguait pleinement et signifiait « se tenir debout » ou « demeurer ». Son domaine fut peu à peu partagé entre d'autres verbes : ~rester~ (~re-~ + ~ester~, « rester en arrière ») reprit le sens de « demeurer », tandis qu'~être~ en absorba d'autres. Fait remarquable, le participe passé d'~être~ — ~été~ — ne descend pas du latin ~esse~ (« être ») mais de ~status~, participe passé de ~stāre~ (« se tenir debout »), la racine même d'~ester~ : ~être~ est un verbe supplétif, et son « avoir été » est, étymologiquement, un « s'être tenu debout ». Dépouillé de ces emplois courants, ~ester~ ne subsiste en français moderne que comme terme de droit défectif, dans l'expression figée ~ester en justice~ (« comparaître devant un tribunal, intenter une action »), conjugué à presque aucun temps — fossile d'un verbe jadis central. La même racine indo-européenne *~steh₂-~ est à l'origine de toute une famille de mots français, parmi lesquels ~stable~, ~station~, ~statue~, ~constant~, et ~rester~ lui-même."`
> `}}`
>
> ## Output format
>
> Return ONLY a JSON object, no markdown fencing, no commentary before or after:
>
> `{"verb1": {"en": "…", "fr": "…"}, "verb2": {"en": "…", "fr": "…"}, …}`
>
> Use real line breaks inside the strings for paragraph breaks (your JSON encoder will
> escape them as `\n`). Write `é à ç « » “ ”` and all accented letters as literal
> characters — they are JSON-safe; do not `\u`-escape them.

**End subagent prompt.**

---

## JSON munging advice

1. **Never** put etymology text in a shell heredoc or an inline Python dict — pass it only
   through `json.dumps`/`json.loads`. Build intermediate files with
   `pathlib.Path(...).write_text(json.dumps(data, ensure_ascii=False))`.
2. **Extract from the subagent JSONL transcripts on disk** (Step 3), not from the live tool
   result — transcripts survive context compaction, and the translation lives in the last
   `message.content[*].text` of a `type:"assistant"` line.
3. The curly-quote / guillemet rule means the **only** ASCII `"` in a subagent's output are
   its JSON delimiters, so `json.loads` cannot be tripped by a quote inside the prose. The
   Step 4 validator flags any stray ASCII `"` that slipped through.
4. **Validate JSON after every write** (Step 6).

## Lessons (carried from Konjugieren's pipeline + French-specific)

- **A subagent may silently omit the French entry entirely.** Seen in practice: an agent
  wrote ten polished `"en"` etymologies and emitted *no* `"fr"` key at all, despite the
  prompt demanding both languages and shipping a bilingual worked example. The Step 4
  validator's `MISSING` check catches this (it flags any `(verb, "fr")` with empty/absent
  text), and the en/fr tilde-mismatch check flags it a second way (`fr=0`). **Do not
  hand-write the missing French** — re-dispatch a fresh subagent for that whole group with
  an explicit, up-front warning that *both* `en` and `fr` are required for every verb and
  that an English-only return will be rejected. Re-running the group is cheap; the failure
  is all-or-nothing per agent, not per verb.
- **Tildes get dropped or added when subagents restructure a sentence.** The Step 4
  even-count and en/fr-match checks catch most of this. Common slip: bolding an English
  cognate that appears in un-tilded prose, or losing a tilde around a small word. A
  recurring shape: an English-only inline aside reuses a cognate the French version
  doesn't (e.g. a court that can `~quash~` a ruling, where the French just says `casser`),
  so `en` carries one extra tilde pair — un-bold the aside in `en` (a mechanical markup
  fix), don't add a phantom bold to `fr`. **Subagents' own "I counted N tildes each side"
  claims are unreliable** — one reported "26/26" on a verb that was actually 30/28. Trust
  the Step 4 validator, not the agent's self-report.
- **`*~root~`, not `~*root~`.** The reconstruction asterisk goes *outside* the tildes, or
  the asterisk renders inside the bold run.
- **Use real Unicode sub/superscripts.** `*~h₂epo~` and `*~bʰuH-~` already carry their
  glyphs; the renderer does no sub/superscript markup.
- **Passé simple, not passé composé** — this is the single most common French-register slip;
  re-read each French entry for stray `a + participle` forms.
- **Keep en and fr parallel.** Same facts, same bolded forms, same paragraph structure. If
  one language earns a detail the other can't support, drop it from both.
- **3–5 subagents × ~8 verbs.** Bigger batches risk compaction mid-run. If compaction
  happens, the agent transcripts/`*.output` files persist on disk and Step 3 recovers the
  results.
- **"Next" means the smallest remaining rank number (rank 1 first), not the verb after the
  last batch** — earlier
  batches can leave gaps. Step 1/Step 7 always diff the work-list against `Etymologies.json`.
- **The confident narrative voice launders disputed etymologies into fact.** A 10-verb
  audit (sampling completed entries against fr/en.Wiktionary) found content was roughly
  ⅓ recitation of the fr.Wiktionary étymologie, ½ accurate added comparative philology
  (PIE roots + cognates pulled from en.Wiktionary's deeper Latin trees) and storytelling,
  and **~9% over-confident framing of genuinely *disputed* origins** — the only real
  accuracy risk found. It clustered on the vivid "memorable detail," which is
  disproportionately the contested one: `tromper` (an invented "blare a horn in someone's
  face" presented as *the* explanation), `glisser` (an uncorroborated "from Latin
  ~glaciāre~" step), `regretter` (a settled "Norse raiders" story over a hedged origin).
  The fix is the **"Disputed origins" section** added to the subagent prompt: mark disputes
  as disputes rather than omitting or asserting them. Recitation share tracks how rich the
  fr.Wiktionary entry is (often one line), so most substance is *generated*, not recited —
  which is the point — but that is exactly why the disputed-origin discipline matters.
- **Minor source-fidelity slips to watch (caught in the same audit):** a reconstructed form
  miscopied from the primary source (`cuire` written `*~cocere~` for fr.Wiktionary's
  `*~cogere~`), and loose "same root as English X" framing where the English word shares
  only the deep PIE root, not the cited Latin etymon (`coûter` → *stand*/*stay*). Neither is
  a fabrication, but prefer reproducing the source's reconstructed form exactly and saying
  "through the same PIE root" when the link is distant.

## Reminders

- Launch all subagents for a batch in a **single message** (parallel Agent calls). If the
  runtime caps tool calls per message, split into 2–3 messages.
- Each subagent prompt must be fully self-contained — paste all rules and the worked
  example into every one.
- Do not write etymologies yourself; delegate all to subagents.
- Validate markup (Step 4) and JSON (Step 6) before considering a batch done.
