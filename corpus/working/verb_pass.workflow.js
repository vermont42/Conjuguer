export const meta = {
  name: 'verb-pass',
  description: 'Check (or skeptically re-examine) shards of French verb data against the Wiktionary evidence assembled in each shard file',
  whenToUse: 'Stage 2 and Stage 3 of prompts/verb-pass-plan.md, after build_verb_pass_shards.py (check mode) or build_skeptic_shards.py (skeptic mode)',
  phases: [
    { title: 'Check', detail: 'one verb-checker per shard: gloss, example, candidate selection, flags' },
    { title: 'Skeptic', detail: 'one verb-skeptic per shard of proposed changes: refute by default' },
  ],
}

// Prerequisite: the shard files exist. Launch with, for example:
//   Workflow({ scriptPath: 'corpus/working/verb_pass.workflow.js', args: {
//     mode: 'check', shards: [1, 2, 3],
//     shardDir: 'corpus/working/verb_pass/pilot',
//     resultsDir: 'corpus/working/verb_pass/pilot/results/sonnet',
//     model: 'sonnet', modelLabel: 'Sonnet 5' } })
//
// Each agent WRITES ITS OWN RESULT FILE and returns only a summary. The full verdicts
// cannot come back through the return value: 6,326 of them would be several megabytes in
// the orchestrator's context. Validate the files afterwards and re-queue any shard whose
// file is missing or invalid.

let parsedArgs = args
if (typeof parsedArgs === 'string') {
  try {
    parsedArgs = JSON.parse(parsedArgs)
  } catch (e) {
    parsedArgs = null
  }
}
const A = parsedArgs || {}

const MODE = A.mode === 'skeptic' ? 'skeptic' : 'check'
const REPO = A.repo || '.'
const MODEL = A.model || undefined          // undefined -> the agent definition's own model
const MODEL_LABEL = A.modelLabel || 'Claude'
const SHARD_DIR = A.shardDir ||
  (MODE === 'check' ? 'corpus/working/verb_pass/shards'
                    : 'corpus/working/verb_pass/skeptic/shards')
const RESULTS_DIR = A.resultsDir ||
  (MODE === 'check' ? 'corpus/working/verb_pass/results'
                    : 'corpus/working/verb_pass/skeptic/results')
const SHARDS = Array.isArray(A.shards) ? A.shards : []

const SUMMARY_SCHEMA = {
  type: 'object',
  additionalProperties: false,
  required: ['shard', 'verbs', 'changes_proposed', 'wrote_file', 'context_check'],
  properties: {
    shard: { type: 'integer', description: 'the shard number you were given' },
    verbs: { type: 'integer', description: 'how many entries your result file contains' },
    changes_proposed: { type: 'integer', description: 'entries carrying at least one proposed change' },
    wrote_file: { type: 'boolean', description: 'true once the result file is written' },
    context_check: {
      type: 'boolean',
      description: 'true if you were handed project build instructions (Xcode, SwiftLint, ios-build-verify); false if your context is only this task and the shard',
    },
    note: { type: 'string', description: 'anything that went wrong, if anything did' },
  },
}

function paths(n) {
  const name = `shard_${String(n).padStart(3, '0')}.json`
  return { shard: `${REPO}/${SHARD_DIR}/${name}`, result: `${REPO}/${RESULTS_DIR}/${name}` }
}

function checkPrompt(n) {
  const p = paths(n)
  return `Check shard ${n} of the Conjuguer verb pass.

Read \`${p.shard}\`. It is a JSON object \`{ "shard": ${n}, "verbs": [ … ] }\`; every entry
of \`verbs\` is one verb of the app with all the reference evidence gathered for it. The
file is long — up to about 9,000 lines — so pass an explicit \`limit\` large enough to take
it in one call (say 12000), and if the read comes back truncated, continue with further
\`offset\`/\`limit\` calls until you have reached the closing brace. **Every verb in the
file must appear in your result.** Count them before you start and count them again at the
end; a short result file is worse than a slow one.

For each verb, in file order, do these five things.

1. **Gloss.** Verdict one of \`ok\`, \`typo\`, \`wrong_sense\`, \`missing_primary_sense\`,
   \`order\`, \`style\`, with \`proposed\` (a full replacement gloss in house style, or
   null), \`confidence\` (\`high\`, \`medium\`, \`low\`) and \`evidence\` naming the sense
   you rest on. Which question you are answering depends on \`gloss_provenance.class\`: a
   verbatim-from-English-Wiktionary gloss is judged on selection and order, a gloss with no
   English source is judged as a translation of the French definition and checked for the
   machine-translation signature. Do not propose a change to a gloss you judge correct.

2. **Existing example.** When \`example\` is non-null, judge it: the verb used verbally in a
   glossed sense, a faithful translation, a correct form, a register that suits a learner.
   Verdict one of \`ok\`, \`verb_absent\`, \`not_verbal\`, \`wrong_sense\`,
   \`mistranslation\`, \`wrong_form\`, \`register\`; \`none\` when there is no example.
   Propose a fix only to the English. Never rewrite the French of a corpus or quotation
   sentence.

3. **A new example**, when the verb has none or the existing one is unusable. Walk
   \`candidates\` in order and take the first that is a genuine **verbal** use in a glossed
   sense, one complete clean sentence, and — for a \`wiktionnaire\` quotation — public
   domain, meaning \`death_year\` is present and strictly less than 1931. Reject a whole
   list that only ever uses the same-spelled noun or adjective. When nothing qualifies,
   write one sentence yourself, with \`"source": "Claude (${MODEL_LABEL})"\`, \`"line":
   null\` and \`"kind": "authored"\`. Copy a chosen sentence's French verbatim.

4. **Flags.** Adjudicate every entry in \`audits.flags\`, and any flag the evidence shows is
   wrong, as \`{ flag, verdict, reason }\` with \`verdict\` one of \`app_correct\`,
   \`change\`, \`unsure\`. The app stores one value per verb, so name the sense you are
   conjugating for.

5. **Notes.** Anything else: a misspelled or non-existent infinitive, a duplicate entry, an
   offensive or dated gloss, a conjugation row that looks like a real engine bug. Usually
   empty.

Write the result to \`${p.result}\` in the shape your instructions fix:
\`{ "shard": ${n}, "results": [ { id, gloss, example, new_example, flags, notes }, … ] }\`,
one object per verb, in file order, keyed by the shard's own \`id\`. Create the directory if
the Write tool needs it. Then return the structured summary, where \`verbs\` is how many
entries the file holds and \`changes_proposed\` is how many of them carry a gloss verdict
other than \`ok\`, an example verdict other than \`ok\`/\`none\`, a \`new_example\`, or a
flag verdict of \`change\`.`
}

function skepticPrompt(n) {
  const p = paths(n)
  return `Re-examine shard ${n} of the Conjuguer verb pass: proposed changes, not verb data.

Read \`${p.shard}\`. It is \`{ "shard": ${n}, "items": [ … ] }\`; every entry is one change
another model proposed, with the current value, the proposed value, the checker's evidence,
and the reference senses for the verb. Pass an explicit \`limit\` large enough to read it in
one call, and continue with further \`offset\`/\`limit\` calls if it comes back truncated.
**Every item must appear in your result.**

Try to refute each one. Default to \`refuted\` when the evidence in the shard does not
decide it. Check every quotation's public-domain claim yourself: the author's
\`death_year\` must be present and strictly less than 1931, and the reason says the year.

Write the result to \`${p.result}\` as
\`{ "shard": ${n}, "results": [ { id, task, verdict, severity, reason }, … ] }\`, one object
per item, in file order. Create the directory if the Write tool needs it. Then return the
structured summary, where \`verbs\` is how many items the file holds and
\`changes_proposed\` is how many you left standing (\`upheld\` or \`partly\`).`
}

if (!SHARDS.length) {
  throw new Error('verb_pass.workflow.js: args.shards must be a non-empty array of shard numbers')
}

const PHASE = MODE === 'check' ? 'Check' : 'Skeptic'
const AGENT_TYPE = MODE === 'check' ? 'verb-checker' : 'verb-skeptic'
const promptFor = MODE === 'check' ? checkPrompt : skepticPrompt

phase(PHASE)
log(`${MODE} mode: ${SHARDS.length} shard(s) from ${SHARD_DIR} -> ${RESULTS_DIR}` +
    (MODEL ? ` on ${MODEL}` : ' on the agent definition\'s own model'))

const summaries = await parallel(SHARDS.map(n => () =>
  agent(promptFor(n), {
    label: `${MODE} shard ${String(n).padStart(3, '0')}`,
    phase: PHASE,
    schema: SUMMARY_SCHEMA,
    agentType: AGENT_TYPE,
    ...(MODEL ? { model: MODEL } : {}),
  })
))

const ok = summaries.filter(Boolean)
const missing = SHARDS.filter((n, i) => !summaries[i])
const leaked = ok.filter(s => s.context_check).map(s => s.shard)
log(`${ok.length}/${SHARDS.length} shards returned; ` +
    `${ok.reduce((t, s) => t + (s.verbs || 0), 0)} entries, ` +
    `${ok.reduce((t, s) => t + (s.changes_proposed || 0), 0)} carrying a proposed change`)
if (missing.length) {
  log(`no summary from shard(s): ${missing.join(', ')} — re-queue them`)
}
if (leaked.length) {
  log(`context_check TRUE in shard(s): ${leaked.join(', ')} — omitClaudeMd did not apply`)
}

return {
  mode: MODE,
  model: MODEL || null,
  resultsDir: RESULTS_DIR,
  summaries: ok,
  missing,
  context_check_true: leaked,
}
