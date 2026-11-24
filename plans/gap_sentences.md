# Brief: Drafting the Phrases à trous Sentences

**For:** the Sonnet subagents that draft the Sentences exercise's content (Phase 18 of
[`pedagogy_implementation.md`](pedagogy_implementation.md)), one range of verbs each. **Written:**
2026-11-23. The first drafts followed an earlier rule that marked only a feminine agreement; the
five être sentences that rule left unmarked were fixed by hand, and the rules below ask for both. Each subagent gets this brief and one verb sheet (the verbs of its range, with gloss,
auxiliary, and simple-tense forms from the app's own conjugator), and writes one JSON file.

## What a sentence is

A short, natural French sentence in which one verb is conjugated, with that conjugation in braces,
and an English translation. The app shows the sentence with an empty field in place of the braces,
the verb's infinitive and gloss above it, and the English below it. The learner types the
conjugation. So the sentence must make exactly one cell of the verb the right answer: the subject,
the time words, and the trigger (il faut que, si, hier, demain) should point to it.

## The format

A JSON array. Each element:

```json
{
  "verb": "aller",
  "tense": "passéComposé",
  "person": "fp",
  "fr": "Hier soir, nous {sommes allés} au cinéma.",
  "en": "Last night we went to the movies."
}
```

- `verb`: the verb's key exactly as the sheet's heading gives it (`aller`, `sortir exit`).
- `tense`: one of the names below.
- `person`: `fs` (je), `ss` (tu), `ts` (il, elle, on, a singular noun), `fp` (nous), `sp` (vous),
  `tp` (ils, elles, a plural noun). For the impératif, only `ss`, `fp`, `sp`. Omit it for
  `participePrésent` and `participePassé`.
- `gender`: `"f"` or `"m"` when the answer is an être verb's compound tense (see Agreement).
  Omit it otherwise.
- `fr`: the sentence, with the conjugation in **one** pair of braces.
- `en`: the translation, in American English.

Three more examples:

```json
{ "verb": "falloir", "tense": "subjonctifPrésent", "person": "ts", "fr": "Il est dommage qu'il {faille} partir si tôt.", "en": "It's a shame we have to leave so early." }
{ "verb": "venir", "tense": "passéComposé", "person": "ts", "gender": "f", "fr": "Ma sœur {est venue} me voir dimanche.", "en": "My sister came to see me on Sunday." }
{ "verb": "prendre", "tense": "impératif", "person": "sp", "fr": "{Prenez} la deuxième rue à droite.", "en": "Take the second street on the right." }
```

## The tenses

| `tense` | Level that first asks it |
|---|---|
| `indicatifPrésent`, `impératif` | Beginner |
| `passéComposé`, `imparfait`, `futurSimple`, `conditionnelPrésent` | Elementary |
| `subjonctifPrésent`, `plusQueParfait`, `conditionnelPassé`, `participePrésent` | Intermediate |
| `passéSimple` | Advanced |

Use no other tense.

## What goes in the braces

Exactly the conjugation the app's conjugator gives for the cell, and nothing else:

- **No subject pronoun.** `Je {parle}`, not `{Je parle}`. An elided pronoun stays outside:
  `J'{ai mangé}`, `qu'il {vienne}`.
- **No ne, pas, or object pronoun.** `Je ne {peux} pas venir.` `Je te {dis} la vérité.`
- **A compound tense is the auxiliary and the participle together**, with nothing between them:
  `Nous {avons fini} le travail.` So no negation, adverb, or inversion may split a compound
  tense: not `Je n'{ai} pas {fini}`, `J'ai déjà fini`, or `As-tu fini ?`. Put the adverb elsewhere
  (`Ce matin, j'{ai fini} mon travail.`) or use a simple tense for the negative.
- **The impératif** is the bare form: `{Viens} ici !`, `{Allons} au marché !`
- **The participe présent** is the bare form after en: `Il chante en {travaillant}.`
- **Copy the simple-tense forms from the sheet.** A form shown as `peux/puis` may be either. Build
  a compound tense from the sheet's auxiliary and participe passé: passé composé with the
  présent of avoir or être, plus-que-parfait with its imparfait, conditionnel passé with its
  conditionnel.

## Agreement

The conjugator agrees a participle only with the subject of an être verb.

- **An être verb** (the sheet says so) agrees with its subject in a compound tense, and its
  sentence always carries `gender`. A feminine subject takes `"gender": "f"` and the feminine
  form: `Elle {est partie}`, `Mes amies {sont arrivées}`. A masculine or mixed subject takes
  `"gender": "m"` and the masculine: `Ils {sont partis}`. With je, tu, nous, or vous, choose a
  gender, mark it, and make it visible if you can (`Marie et moi, nous {sommes allées}…`). The app shows
  a small (fém.) or (masc.) beside the field for je, tu, nous, and vous.
- **vous is plural** in an être verb's compound tense: `Vous {êtes partis}`, never a polite
  singular `êtes parti`. Do not use on with an être verb's compound tense.
- **An avoir verb's participle never agrees** in these sentences. So never put a direct object
  before it: no `la lettre que j'ai écrite`, no `je les ai vus`, no `je l'ai prise`. Put the
  object after: `J'{ai écrit} une lettre.`
- **No pronominal use.** None of these verbs is pronominal in the app, and a pronominal verb takes
  être in compound tenses, which the conjugator would not give: no `se trouver`, `se passer`,
  `se rendre`, `s'appeler`. Use the verb as the gloss gives it.
- **Verbs that take être here take it in every sentence.** passer, monter, sortir, rentrer, and
  retourner take être in the app. Do not write `il a passé un examen` or `elle a monté les
  valises`; choose an intransitive use (`Il {est passé} chez moi.`).

## Which cells, and how many

The sheet's header says your range. Write, for each verb:

- **Ranks 1 to 25: five sentences.** (1) indicatifPrésent or impératif; (2) passéComposé;
  (3) imparfait, futurSimple, or conditionnelPrésent; (4) subjonctifPrésent, plusQueParfait,
  conditionnelPassé, or participePrésent; (5) passéSimple, third person, in a short narrative or
  historical sentence (`Napoléon {mourut} en 1821.`).
- **Ranks 26 to 100: three sentences.** (1) indicatifPrésent or impératif; (2) passéComposé;
  (3) imparfait, futurSimple, conditionnelPrésent, or subjonctifPrésent.
- **Ranks 101 to 300: two sentences.** (1) indicatifPrésent, impératif, or passéComposé;
  (2) imparfait, futurSimple, conditionnelPrésent, or subjonctifPrésent.

Across your range, vary the persons (je, tu, il or elle or a noun, nous, vous, ils or elles or a
plural noun) and vary the tenses within each group, so that not every third sentence is an
imparfait. A verb the sheet marks DEFECTIVE takes only what the note allows. Where a verb has no
impératif, use the présent.

## Style

- **Short and plain**: six to twelve words, everyday vocabulary, one clause where possible. A
  learner at the level that first asks the tense should read it without a dictionary.
- **The context should earn the tense**: hier or l'année dernière for the passé composé, quand
  j'étais petit or tous les étés for the imparfait, demain or l'année prochaine for the futur,
  si + imparfait for the conditionnel présent, il faut que, je veux que, bien que, avant que, or
  pour que for the subjonctif, si + plus-que-parfait for the conditionnel passé, an earlier past
  for the plus-que-parfait (`Quand je suis arrivé, le train {était parti}.`).
- **Standard French** of France, natural and idiomatic, neither slang nor stiff. Use the sense the
  gloss gives; a common sense of the verb is better than a rare one.
- **Punctuation**: write a plain space before `!`, `?`, `:`, and `;` (the merge converts it to the
  narrow no-break space French takes). Use the typographic apostrophe or the straight one, but the
  same one throughout your file; the merge normalizes it.
- **English**: American, idiomatic rather than word for word ("We went to the movies", "this
  weekend", "the fall", "apartment"). Translate the meaning; keep the same tense sense.
- **Nothing a school would mind**: no violence, drink, politics, religion, brands, or real living
  people. Historical figures are fine for the passé simple.
- **No repeated frames.** Each sentence in your file should be different in shape and vocabulary
  from the others; do not reuse "Hier, nous …" for every passé composé.

## Before you write the file

Check every sentence: the braces hold exactly the sheet's form (or the compound you built), the
`person` matches the subject, the `gender` is present when, and only when, the answer is an
être verb's compound tense, and the `tense` is the one the sentence needs. Then write the JSON
array to the output path you were given, with `json`-valid escaping, and nothing else in the
file.
