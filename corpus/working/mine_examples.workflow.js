export const meta = {
  name: 'mine-literature-examples',
  description: 'Select + translate one example sentence per usage-ranked verb from the corpus index shards',
  whenToUse: 'Stage C of the literature corpus pipeline, after build_corpus_index.py + build_literature_examples.py shard',
  phases: [
    { title: 'Select+Translate', detail: 'one subagent per ~30-verb shard: pick the best candidate, recover the sentence, translate' },
  ],
}

// Prerequisite: `python3 corpus/working/build_literature_examples.py shard` has written
// corpus/working/shards/shard_000.json … and reported the shard count. Pass it in:
//   Workflow({ scriptPath: 'corpus/working/mine_examples.workflow.js', args: { shardCount: N } })
// The workflow RETURNS { examples: [...] }; write it to corpus/json/literature_examples.json,
// then `python3 build_literature_examples.py report corpus/json/literature_examples.json`.

const REPO = '/Users/josh/Desktop/workspace/Conjuguer'
// args may arrive as an object or a JSON string; tolerate both. Falls back to the known shard
// count (build_literature_examples.py shard currently produces 33) so a bare launch still works.
let parsedArgs = args
if (typeof parsedArgs === 'string') {
  try {
    parsedArgs = JSON.parse(parsedArgs)
  } catch (e) {
    parsedArgs = null
  }
}
const SHARD_COUNT = (parsedArgs && parsedArgs.shardCount) || 33

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

function promptFor(i) {
  const shard = `${REPO}/corpus/working/shards/shard_${String(i).padStart(3, '0')}.json`
  return `You are mining French literature for one clean example sentence per verb, for a French-verb learning app.

Read the shard file \`${shard}\`. It is a JSON object mapping each verb (infinitive) to a pre-ordered list of candidate occurrences { doc, line, token, text }: doc = source .txt path (under ${REPO}), line = 1-based line number, token = the matched surface form, text = a ±100-char snippet (… marks truncation).

For EVERY verb in the shard:
1. The candidate list is already ordered so the FIRST candidate is the preferred author — the ordering deliberately balances Flaubert / Proust / Zola across verbs, so RESPECT it: walk the list and choose the EARLIEST candidate that is a genuine, natural VERBAL use of that exact verb. Skip a candidate whose token is actually a same-spelled noun or adjective (e.g. "ancre" the anchor vs. the verb ancrer), or whose snippet is an unusable fragment.
2. Open the chosen doc at the given line (read a few lines around it) to recover the FULL, clean French sentence — not the truncated snippet. Trim to one coherent sentence (or a tight clause if the sentence is very long). Keep the original spelling and accents.
3. Translate that sentence into natural, idiomatic English.
If no candidate is a usable verbal example, set fr and en to null and add a short note explaining why.

Return the structured object { examples: [ { verb, source, line, token, fr, en, note? }, … ] } covering every verb in the shard, in file order. source is the basename of the chosen doc (e.g. "proust-du-cote-de-chez-swann-1913.txt").`
}

phase('Select+Translate')
const results = await parallel(
  Array.from({ length: SHARD_COUNT }, (_, i) => () =>
    agent(promptFor(i), { label: `shard ${String(i).padStart(3, '0')}`, phase: 'Select+Translate', schema: SCHEMA, model: 'sonnet' })
  )
)

const examples = results.filter(Boolean).flatMap(r => (r && r.examples) || [])
const placed = examples.filter(e => e.fr).length
log(`collected ${examples.length} verbs (${placed} with a sentence) from ${SHARD_COUNT} shards`)
return { examples }
