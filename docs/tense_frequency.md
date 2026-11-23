# How Often Each Tense Occurs

The verb page orders its cards by these counts: the simple tenses first, then the compound ones,
each block from most to least frequent. Measured on 2026-11-22 for Phase 6 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md), which
ports Konjugieren's Phase 7 and its
[`conjugationgroup_frequency.md`](../../Konjugieren/docs/conjugationgroup_frequency.md).
`TenseTable` in `Conjuguer/Models/TenseTable.swift` holds the resulting order.

To reproduce:

```bash
scripts/write_forms_json.sh                                   # refreshes corpus/working/conjugations.json
python3 scripts/count_tenses.py                               # the tables below, as Markdown
python3 scripts/count_tenses.py --examples impératif          # sample contexts behind one count
python3 scripts/count_tenses.py --examples passéSimple --folder government
```

A run takes about twelve seconds.

## The Sample

The `.txt` files in the five folders of `corpus/originals/`, about 1.8 million words. The texts
are gitignored; [`literature_example_corpus.md`](literature_example_corpus.md) describes them.

| Folder | What it holds | Register |
|---|---|---|
| `literature` | Flaubert's *Madame Bovary*, Proust's *Du côté de chez Swann*, Zola's *L'Assommoir* | Nineteenth- and twentieth-century narrative, with dialogue |
| `classical` | Molière's works in four volumes, with a nineteenth-century introduction, and La Fontaine's fables | Seventeenth-century theater and verse |
| `government` | Twenty Swiss and French public reports | Administrative |
| `wikipedia` | Twenty-five French Wikipedia articles | Encyclopedic |
| `technology` | Four short guides from Switzerland's NCSC | Instructions, 12,000 words |

The *Chanson de Roland* in `literature` is skipped: it is Old French, which the modern
Conjugator cannot read. The PDFs beside the `.txt` files are the same books and are skipped too.

## The Method

`ConjugationMapTool`, through `scripts/write_forms_json.sh`, writes every cell of every verb to
`corpus/working/conjugations.json`. The script reads that table, adding the agreed forms of each
participe passé (allée, allés, allées), so it and the verb page agree on what a conjugation is.

1. **Cleaning.** Project Gutenberg boilerplate is dropped, and its wrapped lines are joined into
   paragraphs, rejoining words hyphenated across a break. In the other folders each line is a
   paragraph. Elisions are split (j'ai, qu'il), and so are hyphenated pronouns (dit-il, a-t-il,
   donne-moi). Seventeenth-century spellings of the imparfait and the conditionnel (étoit,
   sauroit) are read as their modern forms.
2. **Which words can be verbs.** A capitalized word inside a line is a name, and an all-capital
   word is a heading or a speaker. A word after an article, a possessive, or a preposition is a
   noun (le fait, la porte, de place), unless a subject pronoun stands before it ("il le
   porte"); en before a participe présent is a gérondif and counts. About forty spellings that
   are nearly always another word count only beside a subject pronoun: prepositions (entre,
   contre, pendant), adverbs (puis, plus, point), été the season, tu the pronoun. A stoplist
   drops about a hundred nouns and adjectives found by reading the samples (content, président,
   politique). A participe présent whose agreed forms (importante, importants) the folder uses is
   an adjective, and counts only after en.
3. **Compounds.** A form of avoir or être followed, within four words of negation, adverbs, or an
   inverted pronoun, by a participe passé is a compound tense, named by the auxiliary's tense:
   ai, avais, eus, aurai, aurais, aie, eusse, aie (impératif). ai eu followed by a second
   participle is a passé surcomposé. être counts only when the participle's verb takes être, or
   when a reflexive pronoun precedes it (s'est levé), which tells "est allé" (passé composé) from
   "est adopté" (passive). The passive, avoir or être + participle (infinitif passé), and
   ayant or étant + participle are counted apart, since the page shows none of them.
4. **Simple tenses.** Every verb word left over counts under its tense. A subject pronoun before
   the word, or inverted after it, fixes its person: "je finis" is a présent or a passé simple
   in the first person, never a participle. Without one, the subject is a noun and the verb is in
   the third person, so "les objectifs définis" is a participle, not je définis. An impératif
   must start a sentence that ends with a period or an exclamation mark (or be followed by a
   hyphenated object, as in donne-moi), and must not be a word the folder mostly uses as a noun
   (Lutte, Analyse, Centre opening a heading). A subjonctif needs que earlier in its clause.
5. **Shared words.** A word that is still two tenses (il finit, présent or passé simple; que je
   parle, présent or subjonctif) is shared among them in the proportions the folder's
   unambiguous words show, computed separately inside and outside a que clause and refined over
   twenty rounds. So Zola's narrative gives "il finit" mostly to the passé simple, and a
   government report gives it to the présent.

## The Results

Shares within each block, in percent. "Balanced" averages the five folders' shares, so that the
government reports, the largest folder, do not outvote the novels. "Pooled" adds the counts.

| Folder | Files | Words | Simple and participles | Compound |
|---|---:|---:|---:|---:|
| literature | 3 | 467,792 | 55,576 | 5,597 |
| classical | 5 | 440,940 | 52,930 | 4,697 |
| government | 20 | 725,255 | 53,203 | 6,956 |
| wikipedia | 25 | 193,072 | 16,795 | 1,161 |
| technology | 4 | 12,175 | 1,272 | 5 |

### Simple tenses and participles

| Tense | Balanced | literature | classical | government | wikipedia | technology | Pooled |
|---|---:|---:|---:|---:|---:|---:|---:|
| indicatifPrésent | 47.3 | 20.0 | 60.9 | 49.4 | 56.0 | 50.0 | 44.3 |
| participePassé | 25.3 | 12.4 | 8.8 | 34.9 | 30.4 | 40.0 | 19.9 |
| imparfait | 10.3 | 40.0 | 6.4 | 1.6 | 3.4 | 0.1 | 15.0 |
| participePrésent | 5.2 | 6.6 | 2.9 | 6.7 | 5.8 | 4.1 | 5.5 |
| passéSimple | 4.6 | 14.6 | 5.9 | 0.4 | 1.4 | 0.8 | 6.5 |
| futurSimple | 2.3 | 1.1 | 4.5 | 3.4 | 1.3 | 1.3 | 2.8 |
| conditionnelPrésent | 1.8 | 2.7 | 2.9 | 2.2 | 0.8 | 0.4 | 2.4 |
| subjonctifPrésent | 1.6 | 0.6 | 3.6 | 1.5 | 0.7 | 1.8 | 1.7 |
| impératif | 1.1 | 0.8 | 3.1 | 0.0 | 0.0 | 1.5 | 1.2 |
| subjonctifImparfait | 0.5 | 1.3 | 0.9 | 0.0 | 0.0 | 0.0 | 0.7 |

### Simple tenses alone

| Tense | Balanced | literature | classical | government | wikipedia | technology | Pooled |
|---|---:|---:|---:|---:|---:|---:|---:|
| indicatifPrésent | 71.1 | 24.6 | 69.0 | 84.7 | 87.8 | 89.5 | 59.3 |
| imparfait | 13.0 | 49.4 | 7.3 | 2.7 | 5.4 | 0.1 | 20.1 |
| passéSimple | 5.8 | 18.0 | 6.7 | 0.6 | 2.3 | 1.4 | 8.7 |
| futurSimple | 3.3 | 1.4 | 5.1 | 5.8 | 2.1 | 2.3 | 3.7 |
| conditionnelPrésent | 2.5 | 3.3 | 3.3 | 3.7 | 1.3 | 0.7 | 3.2 |
| subjonctifPrésent | 2.3 | 0.7 | 4.1 | 2.5 | 1.1 | 3.3 | 2.3 |
| impératif | 1.4 | 0.9 | 3.5 | 0.1 | 0.0 | 2.7 | 1.6 |
| subjonctifImparfait | 0.5 | 1.6 | 1.0 | 0.0 | 0.1 | 0.0 | 0.9 |

### Compound tenses

| Tense | Balanced | literature | classical | government | wikipedia | technology | Pooled |
|---|---:|---:|---:|---:|---:|---:|---:|
| passéComposé | 75.3 | 19.8 | 73.6 | 96.5 | 86.6 | 100.0 | 66.7 |
| plusQueParfait | 15.7 | 59.4 | 10.9 | 1.9 | 6.5 | 0.0 | 22.0 |
| conditionnelPassé | 4.2 | 11.2 | 4.4 | 1.0 | 4.5 | 0.0 | 5.2 |
| subjonctifPlusQueParfait | 2.1 | 6.5 | 4.0 | 0.0 | 0.0 | 0.0 | 3.0 |
| subjonctifPassé | 1.4 | 0.6 | 4.5 | 0.3 | 1.5 | 0.0 | 1.5 |
| passéAntérieur | 0.7 | 2.2 | 0.7 | 0.0 | 0.4 | 0.0 | 0.9 |
| futurAntérieur | 0.6 | 0.4 | 1.9 | 0.3 | 0.6 | 0.0 | 0.7 |
| passéSurcomposé | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |
| impératifPassé | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 | 0.0 |

### Counted apart

| Construction | literature | classical | government | wikipedia | technology |
|---|---:|---:|---:|---:|---:|
| infinitif passé (avoir or être + participle) | 377 | 263 | 75 | 44 | 2 |
| participe composé (ayant or étant + participle) | 147 | 105 | 99 | 50 | 0 |
| passive (être + participle of an avoir verb) | 1,243 | 1,480 | 4,277 | 1,418 | 237 |

### Participles counting those inside compounds

| Folder | participePassé alone | inside a compound | participePrésent |
|---|---:|---:|---:|
| literature | 6,867 | 5,597 | 3,676 |
| classical | 4,662 | 4,697 | 1,555 |
| government | 18,554 | 6,956 | 3,589 |
| wikipedia | 5,107 | 1,161 | 977 |
| technology | 509 | 5 | 52 |

## What the Counts Show

- **The order is robust.** Balanced and pooled shares give the same order in both blocks. The
  simple block reads présent, imparfait, passé simple, futur, conditionnel, subjonctif présent,
  impératif, subjonctif imparfait. Before Phase 6 the page put the passé simple ahead of the
  imparfait and the subjonctif imparfait ahead of the impératif.
- **Register decides the past.** In the novels the imparfait (49%) and the passé simple (18%)
  outweigh the présent (25%), and the plus-que-parfait (59%) outweighs the passé composé (20%).
  In the government reports, Wikipedia, and the technology guides the présent is above 80% and the
  passé composé above 85%. Wikipedia's history articles use the passé simple (2.3%) where the
  reports do not (0.6%).
- **Close pairs.** The futur antérieur (0.6%) follows the passé antérieur (0.7%) only because the
  novels weight it so: four folders of five put the futur antérieur first. The subjonctif
  plus-que-parfait (2.1%) leads the subjonctif passé (1.4%) on the novels' "eût été" and
  "fût venu", a literary register.
- **The technology folder is small.** Twelve thousand words hold five compounds, all passé
  composé, so its compound column is noise. It counts as one folder in five all the same, as the
  plan asked.
- **Participles.** A participe passé standing alone (adjectival, as in "la loi adoptée") is 25% of
  the simple block, second only to the présent, and the participe présent is 5%. Counting the
  participle inside every compound adds about half again (pooled). Josh placed the personless card
  between the blocks (2026-11-22), as Konjugieren placed its participles after its simple tables.

## Known Errors

Reading a sample of every count leaves these, none large enough to change the order:

- Adjectives spelled like a third-person présent of a rare verb still pass: "complexe",
  "explicite" after a noun count, and inside a que clause they are shared with the subjonctif.
- A noun subject is not recognized as such, so a présent after a relative que ("le rapport que le
  Conseil rédige") is shared with the subjonctif in the proportions of the folder's que clauses.
- Headings without a final period are not orders, but a heading that runs into its first sentence
  ("Devise de la ville et de…") can be read as one.
- A subject pronoun across a comma is not seen, so "Il entra, regarda" counts regarda as an
  unambiguous passé simple, which it is, but "il finit, rougit" shares rougit.
- The impératif loses lowercase orders after an exclamation mark ("cours ! attends") unless a
  hyphenated pronoun follows.
