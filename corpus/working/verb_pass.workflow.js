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
// Stage 5 adds examplesOnly: true and points shardDir/resultsDir at verb_pass/stage5/.
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
const EXAMPLES_ONLY = A.examplesOnly === true
const GLOSS_TOO = A.glossToo === true   // Stage 5c: a gloss fix may come with the example

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
flag verdict of \`change\`.` + (EXAMPLES_ONLY ? examplesOnlyBlock() : '') +
    (GLOSS_TOO ? glossTooBlock() : '')
}

// Stage 5c: verbs whose example kept failing because the gloss misstates the verb or the shard's
// reference was too thin. Each carries `cnrtl`, dictionary text fetched for this run.
function glossTooBlock() {
  return `

**This shard is Stage 5c, and it overrides the gloss rule above.** Every verb here has had at least
one example refuted, usually because the shipped gloss does not match what the verb means, or
because the shard's own reference was too thin to show how the verb is used. Each verb now carries
\`cnrtl\`: the entries of the TLFi, the Académie française (8th and 9th editions), Littré and the
Wiktionnaire from the CNRTL portal, a few concordance snippets with author and date, and under
\`redirects\` the entry of a verb this one is a spelling variant of. Read it before anything else.

- **Fix the gloss when it is wrong.** If the shipped \`gloss\` does not name what the evidence says
  the verb means (its commonest sense first), return a real gloss verdict (\`wrong_sense\`,
  \`missing_primary_sense\`, \`order\`) with \`proposed\` in house style, \`confidence\`, and
  \`evidence\` quoting the dictionary and naming it (TLFi, Académie 9e, Littré). If the gloss is
  right, say \`ok\` as before. Keep correct senses: add, reorder or replace, never trim a right one.
- **Label the register in the gloss** when every sense is dated, regional or a trade term:
  \`(dated)\`, \`(Quebec)\`, \`(Switzerland)\`, \`(cooperage)\`, \`(fishing)\`, \`(viticulture)\`.
- **Write the example for the gloss you propose** (or the shipped one, if it is \`ok\`), in a register
  the evidence supports: a trade term in a plain sentence about that trade, a dated word in a
  sentence that reads as period or literary French, a regional word in a setting from that region.
  Use only constructions the dictionaries show: their definitions and examples tell you whether the
  verb is transitive, intransitive or pronominal, and what it takes as object.
- **The dictionary examples are evidence, not candidates.** Never copy a TLFi, Académie or Littré
  example or a concordance snippet as your sentence. The TLFi is copyrighted, and a snippet is not
  a sentence. Write your own (\`kind: "authored"\`), unless one of \`candidates\` qualifies.
- A pronominal form is right only when the app conjugates the verb as pronominal (\`flags.re\`
  true). Say in \`notes\` if you think a flag is wrong, but do not change \`flags\`.
- \`prior.earlier_attempts\`, when present, lists every refuted attempt before the latest one in
  \`prior\`. Repeat none of them.
- \`prior.gloss_attempt\`, when present, is a gloss already proposed in this stage with the
  reviewer's verdict on it. If the verdict is \`upheld\`, propose that gloss again unchanged; if
  \`partly\`, propose it as the reviewer's reason corrects it; then write the example for it.
- **Do not paraphrase a dictionary.** A sentence that reuses a dictionary example's subject, verb
  and object, or turns a definition's wording into a sentence, is refuted as a copy, however you
  vary it. Invent your own scene: a different subject, a different object, a different situation,
  in a construction the dictionaries show.
- \`prior.hint\`, when present, is a reviewer's note on what the evidence allows for this verb. Follow
  it unless the dictionaries contradict it, and say so in \`notes\` if they do.`
}

// Stage 5 (args.examplesOnly): the verbs that still have no example after Stage 4, each with
// the attempt that failed before. Glosses and flags were settled in Stage 4, so the checker
// leaves them alone, and it must fill new_example for every verb: Stage 2's prompt let 83 verbs
// come back with nothing.
function examplesOnlyBlock() {
  return `

**This run is Stage 5, and it is example-only.** Every verb in this shard still has no example
after an earlier pass, and its \`example\` is null. The earlier pass's glosses and flags are
settled, so:

- Return \`gloss\` as \`{ "verdict": "ok", "proposed": null, "confidence": "high", "evidence":
  "Stage 5: example only" }\` and \`flags\` as \`[]\`, whatever you think of them. If a gloss or flag
  looks wrong, say so in \`notes\` for a later pass.
- \`example\` is \`{ "verdict": "none", "issues": [], "proposed_en": null }\`.
- **\`new_example\` must be filled for every verb.** A null \`new_example\` makes the whole file
  invalid. Prefer a candidate when one qualifies; otherwise write one sentence yourself.
- The sentence must fit the verb's **\`gloss\` as it stands in the shard**, which is the gloss the
  app ships today. Many glosses changed since the earlier pass.
- Each verb carries \`prior\`: what was proposed for it before, and why it failed. \`prior.reason\`
  is one of \`authored_refuted\` (a reviewer refuted the authored sentence: \`skeptic_reason\` says
  why), \`pick_provenance\` (a candidate was copied with an edit or the wrong citation:
  \`status\` and \`detail\`), \`en_quotation\` (an English-Wiktionary quotation still under
  copyright), \`pick_rejected\` (a person rejected the pick: \`note\`), \`removed\` (the old shipped
  example was flawed: \`checker_issues\`, \`skeptic_reason\`), \`none_proposed\` (nothing was
  proposed) or \`stage5_refuted\` (a second attempt: the proposal in \`prior\` was made in this
  same stage and refuted, \`skeptic_reason\` says why, and \`first_reason\` is why the verb had no
  example before that). **Do not propose the failed sentence again, and do not repeat its flaw.**
  If a refuted sentence was wrong about the sense, the form, the register or the translation, make
  sure yours is not. When \`skeptic_reason\` names a candidate that qualified, take that candidate,
  verbatim, unless it fails a rule above. A form must be one the app conjugates for this verb:
  do not use a pronominal form for a verb the app does not mark pronominal, nor a variant's
  spelling.
- **A pick is the candidate's \`text\` verbatim, or one whole sentence of it lifted unchanged.**
  Never trim words out of the middle, never fix the source's typography, never re-cite it: copy
  \`source\` and \`line\` from the candidate you took. Many of these verbs are here because an
  earlier checker trimmed or re-cited a sentence. If the only usable part of a candidate is a
  fragment, write a sentence instead.
- A \`wiktionary_en\` candidate with \`usage: true\` is an editors' usage example. With \`usage:
  false\` it is a quotation, and it carries \`author\`, \`death_year\` and \`ref\`; the public-domain
  rule applies to it exactly as to a \`wiktionnaire\` quotation.
- Translate a pick freshly and faithfully. Do not localize: a French title stays a French title
  ("monsieur le préfet" is not "inspector").`
}

// args.itemCounts maps a skeptic shard number to its item count; the builder cuts shards of
// 25, so only the last differs. Stage 3 agents dropped items on a short read, and a stated
// count gives them something to check against that is not what they happened to read.
function expectedItems(n) {
  const counts = A.itemCounts || {}
  return counts[n] || counts[String(n)] || 25
}

function skepticPrompt(n) {
  const p = paths(n)
  return `Re-examine shard ${n} of the Conjuguer verb pass: proposed changes, not verb data.

Read \`${p.shard}\`. It is \`{ "shard": ${n}, "items": [ … ] }\`; every entry is one change
another model proposed, with the current value, the proposed value, the checker's evidence,
and the reference senses for the verb. Pass an explicit \`limit\` large enough to read it in
one call, and continue with further \`offset\`/\`limit\` calls if it comes back truncated.
**Every item must appear in your result.** The shard holds exactly ${expectedItems(n)} items. If
you have read fewer, you have not reached the end of the file: keep reading until you have
all ${expectedItems(n)} and have reached the closing brace.

Try to refute each one. Default to \`refuted\` when the evidence in the shard does not
decide it. Check every quotation's public-domain claim yourself: the author's
\`death_year\` must be present and strictly less than 1931, and the reason says the year.

Besides the fields your instructions list, an item carries \`gloss_current\` (the live
gloss), \`checker_verdict\` and \`checker_confidence\` (the checker's own label), and
\`checker_notes\`. A \`new_example\` item carries \`gloss_proposed\` when the checker also
proposed a new gloss, so judge the sentence against either. Its \`conjugations\` rows are
the app's forms matching a word of the token; a row with \`tense_key: null\` means no app
form of the verb matches the token, which usually means the sentence uses a wrong form or a
spelling the app does not ship. A \`flag\` item names its \`flag\` and carries the Stage 1
\`audit\` row for it; for \`dg\` the proposal is described in \`evidence\`.

Write the result to \`${p.result}\` as
\`{ "shard": ${n}, "results": [ { id, task, verdict, severity, reason }, … ] }\`, one object
per item, in file order. Create the directory if the Write tool needs it. Then return the
structured summary, where \`verbs\` is how many items the file holds and
\`changes_proposed\` is how many you left standing (\`upheld\` or \`partly\`).` +
    (EXAMPLES_ONLY ? skepticExamplesOnlyBlock() : '') + (GLOSS_TOO ? skepticGlossTooBlock() : '')
}

function skepticGlossTooBlock() {
  return `

**This shard is Stage 5c.** A verb may carry two items: a \`gloss\` item, when the checker proposed
a corrected gloss, and its \`new_example\`. Every item carries \`cnrtl\`, dictionary text (TLFi,
Académie française 8th and 9th editions, Littré, Wiktionnaire, concordance snippets) fetched for
this run. It is evidence you may cite, and it settles questions the Wiktionary senses could not.

- **A gloss item** is judged as in a gloss pass: is the shipped gloss really wrong, and does the
  proposal name the verb's commonest sense in house style? Quote the dictionary that decides it. A
  register label in parentheses for a dated, regional or trade-only verb is house style.
- **A new_example item** is judged against \`gloss_proposed\` when there is one, and otherwise against
  \`gloss_current\`. If it fits only the proposed gloss, say so in the reason, since it can ship only
  with that gloss. The construction must be one the dictionaries show. A sentence that copies a
  dictionary example or a concordance snippet is refuted: those are not licensed for the app.
- An item whose verb had earlier attempts lists them in \`prior\` (\`earlier_attempts\`); a proposal
  that repeats any of them is refuted.
- \`prior.hint\`, when present, is a requirement from the app's owner or a reviewer, and
  \`prior.reason\` \`stage5_replaced\` means an example that stood was replaced at the owner's request.
  A proposal that ignores the hint is refuted.`
}

function skepticExamplesOnlyBlock() {
  return `

**This run is Stage 5.** Every item is a \`new_example\` for a verb that still has no example
after an earlier pass, so a refutation leaves the verb without one. Refute anyway when the
evidence says to: a wrong example is worse than none.

- An item whose \`proposed.kind\` is \`tier\`, \`wiktionnaire\` or \`wiktionary_en\` is a **pick**.
  It carries \`candidate\`, the candidate its French matched, and \`pick_status\`, the code's
  comparison: \`verbatim\` and \`excerpt\` (one whole sentence lifted unchanged) are clean;
  anything else (\`unmatched\`, \`miscited\`, \`wrong_kind\`, \`not_public_domain\`,
  \`late_edition\`) is a provenance failure, and the item is refuted unless \`pick_detail\`
  shows it is harmless. Judge a pick's **translation** as closely as an authored sentence's: it
  is the checker's own work and no one else has read it. A French title or office translated as
  something else ("monsieur le préfet" as "inspector") is a mistranslation.
- For a quotation the public-domain rule is yours to check, on \`candidate.death_year\`; for a
  \`wiktionary_en\` quotation (\`candidate.usage\` false) as for a \`wiktionnaire\` one. A
  translated quotation's \`death_year\` is already the later of author and translator.
- Every item carries \`prior\`, the attempt that failed before and why. A proposal that repeats
  the failed sentence, or its flaw, is refuted.
- The sentence must fit \`gloss_current\`, the gloss the app ships now. There is no gloss
  proposal in this run.
- Every item here has \`current: null\`.`
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
