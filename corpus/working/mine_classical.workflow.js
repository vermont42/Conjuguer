export const meta = {
  name: 'mine-classical-examples',
  description: 'Select + translate one modern example per Chanson-only verb from the classical-tier (La Fontaine + Molière) index shards',
  whenToUse: 'Stage C of the classical-tier mining for the 144 Chanson-only verbs, after build_classical_index.py writes shards',
  phases: [
    { title: 'Select+Translate', detail: 'one subagent per ~30-verb shard: reject homographs, pick the earliest genuine verbal use, recover + translate the sentence' },
  ],
}

// Prerequisite: `python3 corpus/working/build_classical_index.py` has written
// corpus/working/shards/shard_000.json … and reported the shard count (4).
//   Workflow({ scriptPath: 'corpus/working/mine_classical.workflow.js', args: { shardCount: 4 } })
// RETURNS { examples: [...] }; merge into corpus/json/literature_examples.json keyed by verb.

let parsedArgs = args
if (typeof parsedArgs === 'string') {
  try { parsedArgs = JSON.parse(parsedArgs) } catch (e) { parsedArgs = null }
}
const SHARD_COUNT = (parsedArgs && parsedArgs.shardCount) || 4
// Repo root for the paths handed to subagents. Defaults to '.' — subagents Read
// relative to the session's working directory (the repo root), so no absolute path is
// baked in. Override with args.repo (an absolute path) for an out-of-tree run.
const REPO = (parsedArgs && parsedArgs.repo) || '.'

const SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['examples'],
  properties: {
    examples: {
      type: 'array',
      items: {
        type: 'object',
        additionalProperties: true,
        required: ['verb', 'fr', 'en'],
        properties: {
          verb: { type: 'string' },
          source: { type: ['string', 'null'], description: 'basename of the chosen .txt, or null' },
          line: { type: ['integer', 'null'] },
          token: { type: ['string', 'null'] },
          fr: { type: ['string', 'null'], description: 'clean French sentence, or null if no usable verbal use' },
          en: { type: ['string', 'null'], description: 'natural English translation, or null' },
          note: { type: 'string', description: 'why null, when applicable' },
        },
      },
    },
  },
}

// Known homograph false positives from the smoke test — the matched token is a noun/pronoun/
// adjective, NOT the verb. Subagents must reject these and dig for a genuine verbal use (or null).
const FALSE_POSITIVES = `angoisser→angoisses(noun), baiser→un baiser(noun), bouter→boutons(noun), brocher→broche(noun), celer→cela(pronoun), conter→content(adj/verb contenter), corner→cornes(noun), déserter→désertes(adj), escrimer→escrime(noun), fier→fier(adjective "proud"), forfaire→forfait(noun), gésir→jus(noun), luire→lui(pronoun), mater→mata(verb mater? often "mâter"/noun), muer→mue(noun), nombrer→nombre(noun), poindre→point(noun/negation), priser→prise(noun, or prendre), rayer→rayons(noun "rays/shelves"), secourir→secours(noun), seoir→soit(être subjunctive), sourdre→sourds(adj "deaf"), traire→trait(noun)`

function promptFor(i) {
  const shard = `${REPO}/corpus/working/shards/shard_${String(i).padStart(3, '0')}.json`
  return `You are mining 17th-century French literature (La Fontaine's *Fables* and Molière's *Œuvres complètes*) for ONE clean example sentence per verb, for a French-verb learning app. These are archaic/literary verbs (occire = to slay, quérir = to fetch, gésir = to lie, ouïr = to hear, honnir = to shame, …) — the example should show the verb used as a genuine VERB.

Read the shard file \`${shard}\`. It is a JSON object mapping each verb (bare infinitive) to a pre-ordered list of candidate occurrences { doc, line, token, text }: doc = source .txt path (repo-relative, resolve it under ${REPO}), line = 1-based physical line number, token = the matched surface form, text = a ±100-char snippet (… marks truncation). The list is ordered so the most distinctively-verbal tokens (infinitive/participle/gerund) come first — respect that ordering.

CRITICAL — reject homographs. Many candidates match a same-spelled NOUN, ADJECTIVE, or PRONOUN, not the verb. Known traps in this batch: ${FALSE_POSITIVES}. For each candidate, read its snippet (and the source line) and confirm the token is genuinely the conjugated VERB in context (subject performing the action), not the homograph. Skip any candidate that is the noun/adjective/pronoun.

For EVERY verb in the shard:
1. Walk the candidate list and choose the EARLIEST candidate that is a genuine, natural VERBAL use of that exact verb (per the homograph rule above).
2. Open the chosen doc at the given line (read a few lines around it — these are verse plays/fables, so a sentence may span 1-3 short lines) to recover the FULL, clean French sentence. Trim to one coherent sentence or a tight clause. Keep original spelling, accents, and capitalization; you may drop a leading dash/speaker-dialogue marker.
3. Translate that sentence into natural, idiomatic modern English.
If NO candidate is a usable verbal example (all homographs/fragments), set fr, en, source, line, token all to null and add a short \`note\` explaining why (it will be authored by hand later).

Return { examples: [ { verb, source, line, token, fr, en, note? }, … ] } covering every verb in the shard, in file order. source = basename of the chosen doc (e.g. "lafontaine-fables.txt" or "moliere-oeuvres-t2.txt").`
}

phase('Select+Translate')
const results = await parallel(
  Array.from({ length: SHARD_COUNT }, (_, i) => () =>
    agent(promptFor(i), { label: `classical shard ${String(i).padStart(3, '0')}`, phase: 'Select+Translate', schema: SCHEMA })
  )
)

const examples = results.filter(Boolean).flatMap(r => (r && r.examples) || [])
const placed = examples.filter(e => e.fr).length
log(`collected ${examples.length} verbs (${placed} with a sentence) from ${SHARD_COUNT} shards`)
return { examples }
