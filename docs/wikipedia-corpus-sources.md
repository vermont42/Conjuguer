# Wikipedia-corpus sources (provenance manifest)

Provenance for the **wikipedia tier** of the French example corpus — French Wikipedia articles
mined for the software/business and general-modern verbs whose *verbal* uses appear only in
consumer/encyclopedic register, not in the literature, government, or formal-technology tiers
(`saler`, `sucrer`, `tailler`, `surnommer`, `reconstruire`, `dissoudre`, `spécialiser`, …).

**Why this file is tracked.** The raw `.txt` extracts live under `corpus/originals/wikipedia/`,
which is **gitignored** (re-fetchable). This manifest is the durable record and — importantly for
this tier — carries the **attribution** that CC BY-SA requires. Only the derived JSON ships.

**License — CC BY-SA 4.0 (a deliberate, owner-approved exception).** Unlike the government and
technology tiers (PD / Licence Ouverte only), French Wikipedia text is **Creative Commons
Attribution-ShareAlike 4.0** (and GFDL). It was admitted to this corpus by explicit decision of
the repo owner because it is the only open-licensed source of the consumer/encyclopedic register
these verbs need. Obligations this imposes:
- **Attribution** — each example's source article is recorded here and in
  `json/literature_examples.json` (the `source` field carries the `wp-…` filename; this manifest
  maps it to the article title + URL).
- **ShareAlike** — derived adaptations of CC BY-SA text must be shared under a compatible license.
  Single short example sentences are quotation-scale, but if a future build ships a substantial
  derived corpus the share-alike term must be honored. Flagged here so the decision is not silent.

Extraction: plain-text article bodies via the MediaWiki API
(`action=query&prop=extracts&explaintext`), UTF-8, accents preserved. No further cleaning.

Batch acquired: **2026-06-16** — 25 articles, ~1.27 MB total.

## Documents

| Filename | Article | Source URL | License | Retrieved | Size |
|---|---|---|---|---|---|
| wp-academie-francaise.txt | Académie française | https://fr.wikipedia.org/wiki/Académie_française | CC BY-SA 4.0 | 2026-06-16 | 80 KB |
| wp-action-finance.txt | Action (finance) | https://fr.wikipedia.org/wiki/Action_(finance) | CC BY-SA 4.0 | 2026-06-16 | 18 KB |
| wp-bicyclette.txt | Bicyclette | https://fr.wikipedia.org/wiki/Bicyclette | CC BY-SA 4.0 | 2026-06-16 | 63 KB |
| wp-bourse-economie.txt | Bourse (économie) | https://fr.wikipedia.org/wiki/Bourse_(économie) | CC BY-SA 4.0 | 2026-06-16 | 27 KB |
| wp-confiture.txt | Confiture | https://fr.wikipedia.org/wiki/Confiture | CC BY-SA 4.0 | 2026-06-16 | 12 KB |
| wp-course-hippique.txt | Course hippique | https://fr.wikipedia.org/wiki/Course_hippique | CC BY-SA 4.0 | 2026-06-16 | 40 KB |
| wp-diplome.txt | Diplôme | https://fr.wikipedia.org/wiki/Diplôme | CC BY-SA 4.0 | 2026-06-16 | 5 KB |
| wp-dissolution-de-lassemblee-nationale-france.txt | Dissolution de l'Assemblée nationale (France) | https://fr.wikipedia.org/wiki/Dissolution_de_l'Assemblée_nationale_(France) | CC BY-SA 4.0 | 2026-06-16 | 56 KB |
| wp-esclavage.txt | Esclavage | https://fr.wikipedia.org/wiki/Esclavage | CC BY-SA 4.0 | 2026-06-16 | 88 KB |
| wp-fortification.txt | Fortification | https://fr.wikipedia.org/wiki/Fortification | CC BY-SA 4.0 | 2026-06-16 | 19 KB |
| wp-gymnastique-artistique.txt | Gymnastique artistique | https://fr.wikipedia.org/wiki/Gymnastique_artistique | CC BY-SA 4.0 | 2026-06-16 | 5 KB |
| wp-le-havre.txt | Le Havre | https://fr.wikipedia.org/wiki/Le_Havre | CC BY-SA 4.0 | 2026-06-16 | 122 KB |
| wp-medecine.txt | Médecine | https://fr.wikipedia.org/wiki/Médecine | CC BY-SA 4.0 | 2026-06-16 | 30 KB |
| wp-napoleon-ier.txt | Napoléon Ier | https://fr.wikipedia.org/wiki/Napoléon_Ier | CC BY-SA 4.0 | 2026-06-16 | 138 KB |
| wp-orfevrerie.txt | Orfèvrerie | https://fr.wikipedia.org/wiki/Orfèvrerie | CC BY-SA 4.0 | 2026-06-16 | 5 KB |
| wp-paris.txt | Paris | https://fr.wikipedia.org/wiki/Paris | CC BY-SA 4.0 | 2026-06-16 | 231 KB |
| wp-patisserie.txt | Pâtisserie | https://fr.wikipedia.org/wiki/Pâtisserie | CC BY-SA 4.0 | 2026-06-16 | 12 KB |
| wp-referencement-naturel.txt | Référencement naturel | https://fr.wikipedia.org/wiki/Référencement_naturel | CC BY-SA 4.0 | 2026-06-16 | 14 KB |
| wp-reseau-social.txt | Réseau social | https://fr.wikipedia.org/wiki/Réseau_social | CC BY-SA 4.0 | 2026-06-16 | 105 KB |
| wp-salaison.txt | Salaison | https://fr.wikipedia.org/wiki/Salaison | CC BY-SA 4.0 | 2026-06-16 | 8 KB |
| wp-serpent.txt | Serpent | https://fr.wikipedia.org/wiki/Serpent | CC BY-SA 4.0 | 2026-06-16 | 47 KB |
| wp-sucre.txt | Sucre | https://fr.wikipedia.org/wiki/Sucre | CC BY-SA 4.0 | 2026-06-16 | 58 KB |
| wp-taille-de-la-vigne.txt | Taille de la vigne | https://fr.wikipedia.org/wiki/Taille_de_la_vigne | CC BY-SA 4.0 | 2026-06-16 | 21 KB |
| wp-television.txt | Télévision | https://fr.wikipedia.org/wiki/Télévision | CC BY-SA 4.0 | 2026-06-16 | 44 KB |
| wp-voile-sport.txt | Voile (sport) | https://fr.wikipedia.org/wiki/Voile_(sport) | CC BY-SA 4.0 | 2026-06-16 | 12 KB |

## Coverage contribution

This batch rescued **11** verbs whose verbal uses appear only in this register, lifting
`json/literature_examples.json` to **963 / 982 (98.1 %)**:

`coter` (Bourse), `dissoudre` (Dissolution de l'Assemblée), `enchaîner` + `spécialiser`
(Gymnastique artistique), `grouper` + `sucrer`-context (Sucre), `poster` (Paris — "des touristes
postent des photos"), `reconstruire` (Le Havre), `relater` (Académie française), `saler`
(Salaison), `surnommer` (Bicyclette — "surnommèrent la machine boneshaker"), `tailler` (Taille de
la vigne).

## Still uncovered after this batch (19 verbs — diminishing returns)

- **Inherent form-collisions** (matched token belongs to another word; no corpus resolves these):
  `faillir` (↔ *falloir*), `plaire` (↔ adverb *plus*), `violer` (↔ adjective *violent*), `lover`
  (↔ English "love"), `ouvrer` (↔ *ouvrir*).
- **Noun/adjective-dominant; would need imperative how-to prose** (e.g. Wikibooks recipes for
  `sucrer`, SEO guides for `référencer`, device guides for `brancher`): `adjoindre`, `brancher`,
  `diplômer`, `députer`, `illimiter`, `référencer`, `sucrer`, `typer`, `téléviser`, `voiler`.
- **Rare/archaic or absent**: `carrer`, `enceindre`, `foncer`, `handicaper`.
