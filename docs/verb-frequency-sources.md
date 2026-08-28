# Verb-frequency sources for all 6,320 verbs

Research notes, checked 2026-08-28, on where a frequency-of-use ranking for *every* verb in
`verbs.xml` could come from. Prices, limits, and coverage numbers were measured live that day;
the reproduction recipes are at the end. Nothing here has been sent, bought, or shipped.

## Short version

- **A paid Sketch Engine plan does not solve the problem.** The 1,000-item cap on word lists
  from preloaded corpora is identical for trial and paid accounts. That cap, not the free plan,
  is why Conjuguer has 981 ranks. A non-academic personal ("freelancer") subscription costs
  **€17.54/month, €46.77/quarter, or €152.04/year** (VAT-free for a US buyer), and buys
  nothing past the cap. A list longer than 1,000 items is a separate, individually quoted data
  purchase ("normally takes a week or two to generate"); no price is published anywhere.
- **The best free source is GLÀFF**, a CC BY-SA 3.0 lexicon built from Wiktionnaire by
  CLLE-ERSS (Université de Toulouse) that ships lemma frequency counts from three corpora,
  including the 1.25-billion-word FrWaC web corpus. It covers **6,265 of Conjuguer's 6,316
  distinct infinitives (99.2%)**, and its FrWaC ranking agrees with the existing Sketch Engine
  ranks at Spearman ρ = 0.924 over the 981 ranked verbs. No permission email is needed —
  attribution and share-alike on the derived data are the whole license.
- **Lexique 4** (released 2026, CC BY-SA 4.0) is the subtitle-register alternative: 316
  million words of film and TV subtitles, 5,614 of 6,316 verbs covered, but it reshuffles the
  top of the list (ρ = 0.567 against the current ranks) and cannot separate the tail (231
  verbs tie at 0.003 per million).
- **Recommendation:** rank from GLÀFF's FrWaC counts, break ties with its Le Monde and
  Frantext counts and then Lexique 4, store counts rather than ranks the way Konjugieren
  stores DWDS hits, and give the verbs GLÀFF lacks a flagged, clamped *estimate* rather than a
  blank or a bottom rank — GLÀFF omits hyphenated compounds by design, and *sous-estimer* is not
  rare (see *Verbs no corpus lists*). If a 23-billion-word ranking is worth paying for, send
  Lexical Computing the quote request drafted below first, because only they can say what it
  costs.

## Where Conjuguer stands

The 2021 data is still in the repo as `Conjuguer/Models/frequencies.xml`: a 1,000-item Sketch
Engine word-list export (`<str>`, `<frq>`, `<relfreq>`) that is bundled but never parsed. From
`être` (127,742,200 hits at 18,660.4 per million) the corpus was ≈ 6.85 billion tokens, which
matches **frTenTen17** (5.7 billion words, crawled December 2017). Seventeen of the 1,000
items are not verbs (`tandis`, `quant`, `etc.`, `qu`, `d`, `cest`, `y'a`, `trés`, …) and one or
two more are typos of verbs (`connait`, `etait`), which is the "19 verbs had bad data" of memory.
The 1,000th item has 71,263 hits, so the cutoff sits comfortably above the noise floor of that
corpus; the list is short because the export was capped, not because the corpus ran out.

`verbs.xml` has 6,320 `<verb>` entries and **6,316 distinct infinitives** — `haïr`, `ouïr`,
`saillir`, and `sortir` each appear twice, presumably one entry per model. 982 entries carry
`fr`; ranks run 1–981 with rank 56 assigned twice — once to each `sortir` entry — so 981 distinct verbs are ranked (`Verb.maxFrequency` is 981).
`VerbBrowseView` sorts unranked verbs after ranked ones, and the widget snapshot writer drops
them, so nothing crashes on a missing rank — the other ~5,340 entries simply have no `#` badge.

The Credits screen currently says that Lexical Computing, the company behind Sketch Engine,
"is the source of Conjuguer's verb-frequency data." Whatever source wins, that sentence and its
French rendering in `Info.creditsText` change with it.

## What "a ranking for every verb" actually needs

Five things, and the candidates fail on different ones.

1. **Coverage.** The source must know 6,316 lemmas, most of them rare. Dictionaries do; small
   corpora do not.
2. **Resolution in the tail.** A 50-million-word corpus sees the 4,000th verb once or twice a
   year, so hundreds of verbs tie. Only billion-word corpora separate them, and even FrWaC
   leaves ties (below).
3. **Lemmatization.** Counts must be per *lemma*, not per word form. A form list can be
   summed through Conjuguer's own conjugator, but homographs poison it: `suis` belongs to both
   `être` and `suivre`, `tu` is the past participle of `taire`, `lui` of `luire`, `maintenant`
   the present participle of `maintenir`. The naive experiment below put `taire` third in
   French.
4. **Register.** Web text ranks `permettre`, `consulter`, `utiliser`, `configurer` high;
   subtitles rank `vouloir`, `parler`, `aimer`, `tuer` high; novels rank `songer` and
   `murmurer` high. The choice is pedagogical, and it decides how much the existing 981 ranks
   move.
5. **License and permission.** Conjuguer is GPL and its data files are public on GitHub, so a
   source must allow redistribution of derived data. CC BY and CC BY-SA do; CC BY-NC (Leipzig's
   API data) and bespoke terms do not without a written yes — the lesson of Konjugieren's DWDS
   email, in `../../Konjugieren/docs/dwds-permission-email.md`.

## Lexical Computing / Sketch Engine

### Subscriptions (checked 2026-08-28)

Prices come from the calculator on `sketchengine.eu/prices-for-non-academic-personal-accounts/`
with "other country" (non-EU, so no VAT) selected, and from its backing API
(`pay.sketchengine.eu/api.cgi?c=pricelist`), which returns the same numbers.

| Account | Monthly | Quarterly | Yearly | Who qualifies |
|---|---|---|---|---|
| Free trial | €0 | — | — | Anyone, 30 days, no card |
| Academic personal (`acall`) | €9.34 | €25.72 | €87.71 | Researchers, teachers, students at academic institutions; "lexicography or non-academic activities" not allowed |
| Non-academic personal / "other freelancers" (`comtt`) | €17.54 | €46.77 | €152.04 | "Translator, interpreter, SEO or marketing professional" who sells to multiple clients |
| Freelance lexicographers, work teams, companies | quote | quote | quote | "Any use not included above is considered commercial, irrespective of whether it generates revenue directly, indirectly or not at all" |

The site's "from €4.85" banner is the cheapest academic rate and does not apply here. An
independent developer building a free app is not on the list of freelancer professions; the
terms page says "in all other cases, the prices are subject to an individual quotation based on
the type of use," and lexicography ("compiling and editing dictionaries and other similar
lexical works or databases") is "always considered commercial." A verb-frequency table for an
app is arguably a lexical database. Expect to be quoted, not to click Subscribe.

### The cap that matters

From `sketchengine.eu/guide/account-limitations/` and `guide/access-to-unlimited-wordlists/`:

- **Word list from a preloaded corpus: "1,000 items from one list", "no limit to the number
  of lists that can be generated" — for trial and paid accounts alike.**
- Keywords & terms: 1,000 items (100 on trial). Concordance download: 10,000 lines. Word
  sketch: 100 collocates per relation.
- User corpora (text you upload) have no word-list limit, which is irrelevant here: the point
  is their 23-billion-word corpus, not ours.
- Longer lists: "Access to unlimited lists from preloaded corpora for commercial purposes,
  lexicography or reselling" → request a quote at `sketchengine.eu/word-list-quote/`.
  "Access to unlimited lists from a preloaded corpus or corpora for academic purposes is
  possible upon signing a research agreement and paying an individually calculated fee."

The sample research agreement (`Data_Licence_Research_Wordlist_in_Sketch_Engine.pdf`) is
instructive even though Conjuguer cannot sign it: it is "only valid with an existing Sketch
Engine subscription," runs one year, charges a "manipulation fee of EUR [redacted]", forbids
commercial use and lexicography, and — the useful clause — lets the licensee "distribute items
derived from the Works provided that it is not possible to recreate the Works, in whole or in
part, from the distributed items." An ordinal rank per verb, with no counts, is exactly that
kind of derived item, and is the right thing to offer in the commercial quote request too.

Generating a list by regex-partitioning the word-list tool (verbs starting with *a*, then *b*,
…, seven lists under 1,000 each) would technically work and is exactly what the Fair Use Policy
means by stacking limits: "doing so regularly is considered cheating and frowned upon." Don't.

### What a purchase would buy

The corpus is **frTenTen23**: 23.8 billion words, 27,878,396,026 tokens, crawled 2022–2023,
tagged with FreeLing, four times the size of the 2017 corpus behind the current ranks and
twenty times FrWaC. That is the only candidate that would resolve the whole tail: in the 2017
corpus the 1,000th verb still had 71,263 hits, and a Zipf tail from there puts the 6,000th verb
in the hundreds of hits, not at zero. `lexicalcomputing.com/french-word-frequency-lists-for-download/`
describes the product ("we will provide a quotation based on the exact specifications and the
intended use of the wordlist"; "it normally takes a week or two to generate the data") and
links a free sample covering ranks 1,000–100,000 of the general list. The free French lists at
`sketchengine.eu/french-word-list/` are 500 words, 200 nouns, 200 adjectives, and **200
verbs** — no help.

### The API alternative, and why to ask before using it

Any account, trial or paid, can generate an API key. A single request per lemma
(`concsize` for `[lemma="abcéder" & tag="V.*"]`, or a filtered `wordlist` call) returns the
count the word-list export would have contained, which is what Konjugieren does against DWDS.
The Fair Use Policy allows 100 requests per minute, 900 per hour, 2,000 per day, so 6,320
lemmas is a four-day script under a €17.54 subscription. But the terms of use, FAQ, and API
documentation say nothing about redistributing counts obtained this way, and the word-list
pages make clear that a full-vocabulary list from a preloaded corpus is a product they sell.
Harvesting it one lemma at a time under a subscription that exists to sell that product is the
same gray zone as bulk-querying DWDS without asking, and DWDS said yes when asked. The draft
below asks both questions at once.

### Draft quote request

Submit through `sketchengine.eu/word-list-quote/` (name, email, company, website, intended
use: non-academic) or email `inquiries@sketchengine.eu`. Plain text, no Markdown.

```
Subject: Quote request: French verb-lemma frequency list for a free, open-source learning app

Dear Lexical Computing team,

I would like a quote for a lemma frequency list from frTenTen23, and I have a
question about an alternative route to the same data.

The app. Conjuguer is a French verb-conjugation reference and quiz app for iOS.
It conjugates 6,320 verbs, and each verb should carry a frequency rank that
orders the verb list so learners meet être and avoir before abcéder. The app is
free, has no advertising, no in-app purchases, and no subscriptions; I am an
independent developer, not a company. Its source code and data files are public
under the GPL at https://github.com/vermont42/Conjuguer, and the App Store
listing is https://apps.apple.com/us/app/conjuguer/id1588624373.

In 2021, with a free account, I generated a word list of the 1,000 most frequent
French verbs from what I believe was frTenTen17, and the app has credited Lexical Computing and
Sketch Engine as the source of its frequency data ever since. The 1,000-item cap
is why only 981 of the 6,320 verbs are ranked, and I would like to rank all of
them.

What I need. One list, French, corpus frTenTen23, lempos = verb, attributes:
lemma and raw frequency (relative frequency is welcome but not required). Either
all verb lemmas in the corpus, or only the 6,320 lemmas in the app if a filtered
list is cheaper; I can supply the infinitives as a text file.

What would be published. Only an ordinal rank per verb, an integer from 1 to
6,320, compiled into the app and visible in its public repository. No
frequencies, no corpus text, and nothing from which the list could be
reconstructed. I would credit Sketch Engine and Lexical Computing in the app's
Credits screen and the README in whatever wording you prefer, and I am happy to
commit to shipping ranks only in writing.

The alternative. If a bespoke list is out of proportion to this use, would it be
acceptable for me to take a non-academic personal subscription and obtain the
same counts through the API, one request per lemma, inside the Fair Use Policy
limits (about 6,320 requests spread over several days, once)? I would rather ask
than assume the subscription covers it.

Could you let me know the price and licence terms for the list, and whether the
API route is acceptable instead?

Thank you,

Josh Adams
vermontcoder@gmail.com
```

## Free sources, measured against `verbs.xml`

Every number below was computed on 2026-08-28 with the scripts in the appendix. "Coverage"
is the number of Conjuguer's 6,316 distinct infinitives that the source lists as a verb lemma.
"ρ vs current" is Spearman's rank correlation between the source's ordering and the existing
`fr` ranks over the verbs both have (979–981 of them).

| Source | Corpus, size | Lemmatized | License | Coverage | ρ vs current | Tail resolution |
|---|---|---|---|---|---|---|
| **GLÀFF 1.2.2** | FrWaC web ≈ 1,254M words; LM10 (Le Monde, 10 years) ≈ 220M; Frantext20e ≈ 29M | yes, TreeTagger | CC BY-SA 3.0 | **6,265** (99.2%) | **0.924** (FrWaC), 0.815 (LM10), 0.501 (Frantext) | 3,560 distinct FrWaC counts; 113 verbs at 0, 83 at 1, 65 at 2; 531 under 10 |
| **Lexique 4.00** (2026) | 316M words of subtitles (65,317 films/series, OpenSubtitles 2018) | yes, Cordial | CC BY-SA 4.0 | 5,614 (88.9%) | 0.567 | 2,186 distinct values; 231 verbs tie at 0.003/M; 1,494 under 0.1/M |
| Lexique 3.83 (2019) | 50M subtitles + 14.7M books (Frantext novels 1950–2000) | yes | CC BY-SA 4.0 | 5,425 (85.9%) | 0.535 | 211 verbs tie at 0.07/M |
| OpenSubtitles 2018 form list (hermitdave/FrequencyWords) | 318M tokens, 834,768 forms | **no** | CC BY-SA 4.0 | 5,712 via GLÀFF's form→lemma map | 0.532 | unusable: `taire` #3, `luire` #15, `maintenir` #26 |
| Google Books Ngram v3 French (2020) | 329 billion words 1500–2019 (35 billion in 2010–2019) | no, but 1-grams carry `_VERB` tags | CC BY 3.0 | untested | — | would need summing through the conjugator; OCR noise (`Plcust_VERB`) |
| Leipzig Wortschatz French | 1M–3M-sentence news/web/Wikipedia corpora | no | downloads CC BY; API data CC BY-NC | untested | — | rejected for German in Konjugieren for size and forms-not-lemmas; French is the same product |
| Sketch Engine free lists | frTenTen | yes | unstated | 200 verbs | — | — |

Sources that turned out not to exist, or not for us:

- **COW / FRCOW16**, the 10-billion-token French web corpus with lemma frequency lists, went
  offline in 2024. Roland Schäfer's post "What happened to webcorpora.org?" (25 May 2025) says
  he and Felix Bildhauer paid for the server themselves from 2014 to 2024, and that access is
  now by direct request for institutions able to manage the raw data. Not a path for an app.
- **Frantext** (ATILF/CNRS, ≈ 300M words) is subscription-only with no bulk frequency export;
  its 20th-century slice already lives in GLÀFF as the Frantext20e columns. There is no French
  counterpart to the DWDS frequency API.
- **Leeds Internet corpora** lists (CC BY 2.5, lemmatized, ≈ 100M-word web corpora):
  `corpus.leeds.ac.uk` timed out on every attempt on 2026-08-28. Smaller than FrWaC in any case.
- **A Frequency Dictionary of French** (Lonsdale & Le Bras, Routledge 2009): 5,000 lemmas from
  a 23-million-word corpus, copyrighted, too small.
- **Wiktionary's French frequency lists** are re-hostings of the OpenSubtitles and Leipzig data
  above. **wordfreq** (Python) is form-level and frozen. **Kelly** lists are CC BY-NC-ND-SA and
  9,000 words across all parts of speech.
- **Do it yourself** — run a French tagger (spaCy `fr_core_news`, Stanza, TreeTagger) over
  OSCAR, French Wikipedia, or the raw OpenSubtitles dump and count verb lemmas. Feasible at
  roughly 100M words per few hours on a laptop, but it reproduces what GLÀFF already did on a
  larger corpus with a tagger of the same generation, so it is a fallback, not a plan.

### GLÀFF in detail

GLÀFF (*Gros Lexique À tout Faire du Français*; Sajous, Hathout & Calderone 2013; Hathout,
Sajous & Calderone, LREC 2014) is 1.4 million inflected forms extracted from Wiktionnaire, each
with a GRACE tag, a lemma, IPA, and eight frequency columns: absolute and per-million counts
of the *categorized form* and the *categorized lemma* in Frantext20e, LM10, and FrWaC. The
official home `redac.univ-tlse2.fr/lexicons/glaff_en.html` refused connections on 2026-08-28;
the same files are mirrored by CNRS on Hugging Face at
`huggingface.co/datasets/datasets-CNRS/GLAFF` (`data/glaff-1.2.2.txt`, 157 MB, plus
`oldiesSubLexicon.txt` for obsolete entries; the README asks that it travel with any
redistribution). Corpus sizes above are back-computed from `être`'s absolute and per-million
lemma counts.

- **The 51 verbs it lacks** are mostly hyphenated compounds, which GLÀFF's current version
  excludes by design (*arc-bouter*, *contre-attaquer*, *court-circuiter*, *sous-estimer*,
  *pique-niquer*, *entre-tuer*, …; 25 of these are in Lexique 4), plus a few genuine rarities
  (*ahanner*, *bienvenir*, *occire*, *haubanner*, *coupasser*, *dégober*, *humoter*,
  *prompter*, *blistériser*, *lock-outer*) and seven `verbs.xml` entries that are not French
  verbs at all — see "Side findings."
- **113 covered verbs have zero FrWaC hits**, 91 have zero in all three corpora; with LM10 and
  Frantext as tie-breakers and Lexique 4 after them, 110 verbs remain at zero everywhere and
  another 403 sit in 108 small tie groups (`(1, 0, 0)` and the like). Measured zeros can
  honestly rank last, alphabetically within a tie. The *absent* verbs are a different matter —
  see *Verbs no corpus lists* below.
- **Tagger contamination is real but concentrated in lemmas Conjuguer does not have.** FrWaC
  was tagged automatically, so a rare verb that is homographic with a common noun or adjective
  inherits mis-tags: GLÀFF's most frequent "verbs" absent from Conjuguer are *permaner*
  (from *permanent*), *préciter* (*précité*), *pager*, *commer*, *oranger*, *pucer*,
  *computer*. Among Conjuguer's own verbs the FrWaC-versus-LM10 outliers are mostly honest
  register (cooking and IT verbs: *préchauffer*, *paramétrer*, *configurer*, *égoutter*,
  *émincer*, *désinstaller*), with a few suspects worth a look (*ligner* at 21,696 hits, *ouvrer*,
  *téter*). FrWaC and LM10 agree at ρ = 0.947 over all 6,265 verbs, which bounds the damage.
- **Continuity.** ρ = 0.924 against the current ranks means the top of the list barely moves:
  FrWaC's top 30 is *être, avoir, faire, pouvoir, devoir, aller, voir, dire, mettre, permettre,
  prendre, savoir, falloir, donner, trouver, vouloir, passer, venir, proposer, utiliser, rendre,
  rester, concerner, présenter, lire, connaître, créer, devenir, réaliser, écrire* — the same
  web-register list Sketch Engine gave, minus *consulter*.

### Lexique 4 in detail

Lexique 4.00 (New, Pallier, Schalchli, Bourgin & Gimenes, *Behavior Research Methods* 2026)
replaces Lexique 3's two corpora with one: 316 million words from 65,317 subtitle files, tagged
with Cordial. `Lexique4.tsv` (33 MB, 189,863 rows) has `4_Lemme`, `5_Cgram`, and
`12_FreqLemme` (per million; there is no absolute count column, so ties cannot be broken by
recomputing). The README in the zip says CC BY-SA 4.0; the download page's license *link*
points at CC BY-NC 4.0 while its *text* says BY-SA — the README and the CC-BY-SA licence file
shipped inside the archive are the authoritative pair, but it is worth one sentence to
`boris.new@univ-smb.fr` if Lexique data ends up in the app.

Its top 30 — *être, avoir, aller, faire, pouvoir, dire, vouloir, savoir, devoir, voir, venir,
penser, parler, prendre, croire, aimer, passer, trouver, laisser, attendre, arriver, falloir,
appeler, donner, regarder, partir, arrêter, tuer, mettre, demander* — is what people say, not
what the web writes, and New et al. have shown since 2007 that subtitle frequencies predict
how quickly readers recognize words better than book or web frequencies do. For a learner that
is a real argument. Against it: 702 of Conjuguer's verbs are absent, 3,216 of the covered ones
sit below one occurrence per million, and adopting it would reorder the 981 ranks users have
seen since 2021 (ρ = 0.567). The sensible use is as the last tie-breaker, and as the source for
the 25 verbs GLÀFF lacks but it lists — 24 hyphenated, plus *occire* — through the calibration
in the next section.

### Verbs no corpus lists: estimate, flag, clamp

Absence from GLÀFF is not evidence of rarity. Its 51 misses are 33 hyphenated compounds,
which its current version excludes by design, seven `verbs.xml` misspellings, and eleven
rarities. Treat absence as "below one hit" and *sous-estimer* — 11.5 per million in
subtitles, a top-1,100 verb by any measure — ranks under *bêcheveter*. Josh's preference is
that no verb's frequency be blank, and Konjugieren already has the pattern: an estimated
count carrying a provisional flag (`hp`), ranked like any other, clamped so it can never
reach the top, and reported as a population so a later source can replace it.

Three tiers cover the gap, measured on 2026-08-28:

- **Calibrated from Lexique 4** (the 24 hyphenated verbs it lists, plus *occire*). A
  least-squares fit of `log(frwac)` on `log(lex4 per million)` over the 5,572 verbs both
  sources list with nonzero counts gives `log(frwac) = 7.57 + 0.76 · log(lex4)`, R² = 0.69;
  the residual interquartile range is ±2.6× in count, the 95th percentile ±10×. Mid-list,
  ±2.6× is a few hundred rank places. Applied to the hyphenated verbs it yields *sous-estimer*
  ≈ 12,400 hits (≈ #1,050), *sous-entendre* ≈ 4,600 (≈ #1,700), *pique-niquer*,
  *sous-titrer*, *entre-tuer*, and *court-circuiter* ≈ 2,500 (≈ #2,200), *petit-déjeuner* and
  *contre-attaquer* ≈ 2,200 (≈ #2,300), *sous-traiter* ≈ 1,100 (≈ #3,000), *arc-bouter* ≈ 180
  (≈ #4,500), *tire-bouchonner* ≈ 55 (≈ #5,100). Every one of those is plausible company.
- **Scaled from the base verb** (the nine hyphenated verbs in no source — *casse-croûter*,
  *contre-manifester*, *contre-passer*, *contre-tirer*, *entre-manger*, *entre-nuire*,
  *entre-regarder*, *glisser-déposer*, *lock-outer* — plus *copiloter*): the base verb's
  measured count times a prefix ratio taken from the `sous-`/`contre-`/`entre-` pairs Lexique 4
  does have. Konjugieren measured its ratios per prefix from 446 real pairs; ten verbs justify
  one conservative median.
- **Editorial** (the rarities: *ahanner*, *anathémiser*, *bienvenir*, *blistériser*,
  *coupasser*, *dégober*, *haubanner*, *humoter*, *prompter*): a small hand-assigned count
  with a stated reason, kept in a tracked file. Most are dictionary ghosts and zero is a fair
  entry; the point is that the number is chosen, not missing.

The clamp: no estimate may exceed the measured count at rank 1,000 — 13,773 hits — so an
estimate can never enter the top of the list (Konjugieren clamps at its 900th verb). Measured
zeros are never estimated: a corpus that could have seen the verb and did not is data.

### The form-list dead end, for the record

Summing `fr_full.txt` (OpenSubtitles 2018) through GLÀFF's form→lemma map, splitting ambiguous
forms evenly, covers 5,712 verbs and ranks *taire* third (because *tu* is its past participle),
*plaire* tenth, *luire* fifteenth (*lui*), *mourir* 24th (*mort*), and *maintenir* 26th
(*maintenant*). Any form-level source — OpenSubtitles, Leipzig, Google Books — needs a POS
tagger in front of it, at which point it is the do-it-yourself option above.

## Which register should rank a learner's verbs?

| | Sketch Engine 2021 (frTenTen17, web) | GLÀFF FrWaC (web) | Lexique 4 (subtitles) |
|---|---|---|---|
| ρ vs current ranks | 1 | 0.924 | 0.567 |
| Rank of *vouloir* | 19 | 16 | 7 |
| Rank of *parler* | 34 | 36 | 13 |
| Rank of *aimer* | 49 | 42 | 16 |
| Rank of *tuer* | 231 | 320 | 28 |
| Rank of *permettre* | 11 | 10 | 146 |
| Rank of *utiliser* | 20 | 20 | 73 |
| Rank of *proposer* | 21 | 19 | 256 |
| Rank of *consulter* | 15 | 108 | 673 |

Staying with web text keeps faith with the existing ranks and with the Credits sentence's
history; switching to subtitles is defensible pedagogy but a visible change. The
recommendation above stays with web text for the primary key. Either way the data is free,
so the choice can be made — and remade — in a script.

## Side findings about `verbs.xml`

The coverage runs exposed entries that no source knows because they are wrong:

- **Five infinitives with a dropped *v*:** `préenir` (*prévenir* is present separately),
  `récidier` (*récidiver* is absent), `réolvériser` (*révolvériser*), `transaser`
  (*transvaser*), `désenaser` (*désenvaser*). The pattern suggests one bad transcription pass.
- **Two without their accent:** `eduquer` (*éduquer*), `egorger` (*égorger*).
- **Common verbs missing altogether**, by FrWaC hits: *alléger* (12,288), *éduquer* (10,698),
  *encaisser* (8,850), *dépourvoir* (8,632, defective), *perpétuer* (7,641), *réinvestir*,
  *acter*, *impacter*, *rediriger*, *cartographier*, *récidiver*, *égorger*, *bloguer*,
  *recadrer*, *redessiner*, *redimensionner*. GLÀFF-minus-Conjuguer has 15,145 lemmas, most
  of them tagger junk or Wiktionnaire neologisms, so this is a hand-curated shortlist, not the
  whole difference.
- The four duplicated infinitives (`haïr`, `ouïr`, `saillir`, `sortir`) are presumably
  deliberate (two models each); a frequency import must handle the duplicate keys.

None of this is the frequency project's job, but whichever script assigns counts will trip
over the seven bad spellings first.

## If GLÀFF is adopted: shape of the change

Mirror Konjugieren's design rather than the 2021 one:

1. **Store counts, derive ranks at parse time.** Konjugieren replaced its `fr` rank with a raw
   `hi` hit count and computes the dense 1..n rank in `VerbParser`, so adding a verb never
   renumbers the others. Conjuguer's `fr` attribute could become `hi` (FrWaC lemma count) with
   optional tie-breaker columns, or a single precomputed sort key; `Verb.maxFrequency` becomes
   the count of ranked verbs rather than a literal 981. Verbs GLÀFF lacks get an estimated `hi`
   under Konjugieren's `hp="y"` flag (see *Verbs no corpus lists*), so every verb has a count
   and the provisional population stays countable.
2. **Keep the pipeline out of the app target.** A `frequency/` folder at the repo root, like
   `corpus/`, with the build script tracked and the 157 MB GLÀFF file gitignored with its
   SHA-256 and download recipe in a README (Konjugieren's `verbdata/README.md` is the model).
3. **License.** CC BY-SA 3.0 requires attribution and that the derived database (the counts or
   ranks in `verbs.xml`) be shared under the same or a compatible license. The app is GPL;
   data files are separate works and can carry their own notice. Ship the GLÀFF README
   alongside, as it asks. Lexique 4's CC BY-SA 4.0 is compatible with 3.0 in the direction that
   matters (deriving from 3.0 material, releasing under 4.0).
4. **Credits.** Replace the Lexical Computing sentence with something like:

   > Verb-frequency rankings are derived from the FrWaC, Le Monde, and Frantext frequency
   > counts in GLÀFF (Sajous, Hathout & Calderone, CLLE-ERSS, Université de Toulouse), a
   > lexicon built from Wiktionnaire and released under the Creative Commons
   > Attribution-ShareAlike 3.0 license.
   >
   > Le classement des verbes par fréquence est dérivé des comptages de fréquence FrWaC,
   > Le Monde et Frantext de GLÀFF (Sajous, Hathout & Calderone, CLLE-ERSS, Université de
   > Toulouse), un lexique construit à partir du Wiktionnaire et publié sous licence Creative
   > Commons Attribution – Partage dans les mêmes conditions 3.0.

   Add the TALN 2013 citation the README requests to the README of the repository. If Lexique 4
   contributes tie-breaks or the hyphenated verbs, credit New et al. (2026) in the same breath.
5. **Delete `frequencies.xml`**, or keep it as provenance for the 2021 ranks in a docs folder;
   it is dead weight in the bundle either way.

## Appendix: reproduction recipes

Downloads (all public, no registration):

```bash
curl -sSLo glaff-1.2.2.txt "https://huggingface.co/datasets/datasets-CNRS/GLAFF/resolve/main/data/glaff-1.2.2.txt"
curl -sSLo Lexique400.zip "http://www.lexique.org/databases/Lexique400/Lexique400.zip"
curl -sSLo Lexique383.zip "http://www.lexique.org/databases/Lexique383/Lexique383.zip"
curl -sSLo fr_full.txt "https://raw.githubusercontent.com/hermitdave/FrequencyWords/master/content/2018/fr/fr_full.txt"
curl -sS "https://pay.sketchengine.eu/api.cgi?c=pricelist"   # subscription and storage prices
```

GLÀFF coverage and tie analysis (fields are `|`-separated; 8 = Frantext20e lemma count,
12 = LM10 lemma count, 16 = FrWaC lemma count, 1-based):

```python
import re, collections
inf = set(re.findall(r'<verb in="([^"]+)"', open('Conjuguer/Models/verbs.xml').read()))
lem = {}
for line in open('glaff-1.2.2.txt', encoding='utf-8'):
    f = line.rstrip('\n').split('|')
    if len(f) >= 17 and f[1].startswith('V'):
        vals = (int(f[7]), int(f[11]), int(f[15]))
        lem[f[2]] = max(lem.get(f[2], vals), vals)
have = [v for v in inf if v in lem]
print(len(have), 'covered;', sorted(inf - lem.keys()))
print(collections.Counter(lem[v][2] for v in have).most_common(5))  # FrWaC ties
```

Spearman against the current ranks: rank both orderings over the verbs both have and apply
`1 - 6·Σd² / n(n²-1)`; ties were left in source order, which flatters nobody in particular.
Lexique 4 uses columns `4_Lemme`, `5_Cgram` (starts with `VER`), `12_FreqLemme`; Lexique 3.83
uses `lemme`, `cgram == 'VER'`, `freqlemfilms2 + freqlemlivres`.

Pages consulted: `sketchengine.eu/price-list/`, `/guide/account-limitations/`,
`/guide/access-to-unlimited-wordlists/`, `/word-list-quote/`, `/fair-use-policy/`,
`/frtenten-french-corpus/`, `/french-word-list/`, `/academic-and-non-academic-subscriptions/`;
`lexicalcomputing.com/french-word-frequency-lists-for-download/`; `lexique.org`;
`huggingface.co/datasets/datasets-CNRS/GLAFF`; `rolandschaefer.net/archives/3663`;
`storage.googleapis.com/books/ngrams/books/datasetsv3.html`.
