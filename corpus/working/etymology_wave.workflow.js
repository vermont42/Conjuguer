export const meta = {
  name: 'etymology-wave',
  description: 'Write one wave of verb etymologies (etymology-writer per shard) and skeptic-check each shard\'s rich entries (etymology-skeptic)',
  whenToUse: 'A wave of prompts/etymology-tail-plan.md, after etymology_wave.py select has written the shards',
  phases: [
    { title: 'Write', detail: 'one etymology-writer per shard, Sonnet' },
    { title: 'Skeptic', detail: 'one etymology-skeptic per shard with rich entries, Sonnet' },
  ],
}

// Launch with, for example:
//   Workflow({ scriptPath: 'corpus/working/etymology_wave.workflow.js',
//              args: { wave: 0, shards: ['s01', 's02', 's03', 's04'] } })
// Each agent writes its own file and returns only a summary; etymology_wave.py validate,
// merge and report read the files. The first line of every prompt names the wave, the role
// and the shard, which is how `report` attributes transcript tokens.

let A = args
if (typeof A === 'string') {
  try {
    A = JSON.parse(A)
  } catch (e) {
    A = null
  }
}
A = A || {}
const WAVE = Number.isInteger(A.wave) ? A.wave : 0
const SHARDS = Array.isArray(A.shards) ? A.shards : []
const SKIP_WRITE = Array.isArray(A.skipWrite) ? A.skipWrite : []
const DIR = `corpus/working/etymology/waves/w${String(WAVE).padStart(2, '0')}`

const WRITER_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['shard', 'verbs', 'short', 'rich', 'skipped', 'needs_lookup', 'web_verbs', 'chrome_verbs', 'wrote_file', 'context_check'],
  properties: {
    shard: { type: 'string' },
    verbs: { type: 'integer', description: 'entries in your results file, including skipped and needs_lookup' },
    short: { type: 'integer', description: 'entries written as short' },
    rich: { type: 'integer', description: 'entries written as rich' },
    skipped: { type: 'integer' },
    needs_lookup: { type: 'integer' },
    web_verbs: { type: 'integer', description: 'verbs for which you used the web at all' },
    chrome_verbs: { type: 'integer', description: 'verbs for which you needed claude-in-chrome' },
    wrote_file: { type: 'boolean' },
    context_check: { type: 'boolean' },
    note: { type: 'string' },
  },
}
const SKEPTIC_SCHEMA = {
  type: 'object', additionalProperties: false,
  required: ['shard', 'upheld', 'partly', 'refuted', 'wrote_file', 'context_check'],
  properties: {
    shard: { type: 'string' },
    upheld: { type: 'integer' }, partly: { type: 'integer' }, refuted: { type: 'integer' },
    wrote_file: { type: 'boolean' },
    context_check: { type: 'boolean' },
    note: { type: 'string' },
  },
}

function writer(s) {
  return agent(
    `Etymology wave ${WAVE}, writer, shard ${s}.\n\nShard file: \`${DIR}/shards/${s}.json\`.\nResults file: \`${DIR}/results/${s}.json\`.\n\nRead the shard (pass a \`limit\` large enough to take it in one read, and continue with \`offset\` if it comes back truncated), write an entry for every verb as your instructions describe, write the results file, then return the summary with shard "${s}".`,
    { label: `writer ${s}`, phase: 'Write', agentType: 'etymology-writer', model: 'sonnet', schema: WRITER_SCHEMA })
}

function skeptic(s) {
  return agent(
    `Etymology wave ${WAVE}, skeptic, shard ${s}.\n\nShard file: \`${DIR}/shards/${s}.json\`.\nResults file: \`${DIR}/results/${s}.json\`.\nVerdict file: \`${DIR}/verdicts/${s}.json\`.\n\nJudge every rich entry in the results file as your instructions describe, write the verdict file, then return the summary with shard "${s}".`,
    { label: `skeptic ${s}`, phase: 'Skeptic', agentType: 'etymology-skeptic', model: 'sonnet', schema: SKEPTIC_SCHEMA })
}

const out = await pipeline(
  SHARDS,
  s => (SKIP_WRITE.includes(s) ? Promise.resolve({ shard: s, rich: 1, wrote_file: true, reused: true }) : writer(s)),
  (w, s) => {
    if (!w || !w.wrote_file) {
      log(`${s}: writer failed; no skeptic`)
      return { shard: s, writer: w, skeptic: null }
    }
    if (w.rich === 0) {
      return { shard: s, writer: w, skeptic: null }
    }
    return skeptic(s).then(k => ({ shard: s, writer: w, skeptic: k }))
  },
)
return out
