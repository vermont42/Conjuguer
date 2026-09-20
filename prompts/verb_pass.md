1,140 of the 6,326 verbs have a literature example sentence. 5,186 do not.

A naive fix would be to use subagents to create only the example sentences. But I think a subagent pass on *all* verbs would be helpful. The inputs would be:

* Infinitive
* Gloss
* Example sentence, if any

The subagent would:
1. Check the gloss for typos.
2. Verify that the gloss is correct. The basis for the check could be training data, Wiktionary, or something else. I'd like your input on this. If the gloss seems incorrect, explain that to the orchestrator.
3. If an example sentence is present, verify that it matches the gloss. If the example sentence seems not to match, explain that to the orchestrator.
4. If no example sentence is present, check the corpus for that. If none is present, create one. Report the new example sentence, if any, back to the orchestrator.

Can you think of any other work that it would be helpful for subagents to do?

Running subagents for 6,326 verbs would be token-intensive. Two ways to reduce that cost are to use Sonnet for subagents *and* to use the `omitClaudeMd` key described [here](https://code.claude.com/docs/en/sub-agents?utm_source=it&utm_medium=email&utm_campaign=Week%2038:%20What%26%23x27;s%20New%20in%20Claude%20Code&utm_term=claude_code&utm_campaignId=19910328#supported-frontmatter-fields).

Once we finalize the work that subagents will do, we will create a prompt for them. We will then create a pipeline.
