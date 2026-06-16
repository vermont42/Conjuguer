# Technology-corpus sources (provenance manifest)

Provenance for the **technology tier** of the French example corpus — documents mined for the
software/digital/IT verbs that appear in neither 19th-century literature nor general government
administrative prose (`télécharger`, `installer`, `spécialiser`, …).

**Why this file is tracked.** The raw `.txt` files live under `corpus/originals/technology/`,
which is **gitignored** (re-fetchable — see `CLAUDE.md` › *Literature-Example Corpus*). This
manifest is the durable record: it preserves attribution and lets anyone re-fetch. Only the
derived JSON ships in the app.

**License gate (per `docs/government-corpus-licensing.md` — same legal framework as the government
tier).** This batch is **Swiss only**: official publications of Swiss authorities are **public
domain** under **Art. 5 URG** (Federal Copyright Act), so no per-document license check is needed.
A later batch may add French ANSSI/CNIL/cybermalveillance guides under **Licence Ouverte 2.0 /
Etalab** (verify per document).

**Why consumer how-to guides.** Verbs like `télécharger`/`installer`/`brancher` collide with
common nouns and appear *verbally* mainly in imperative/infinitive how-to prose ("téléchargez la
mise à jour", "pour installer le logiciel") — not in the noun-heavy formal reports of the
government tier. The OFCS/NCSC consumer guides supply exactly that register; the Si001 directive
adds bulk technical-IT vocabulary. (This mirrors Konjugieren's use of BSI consumer guides for
`installieren`/`speichern`/`klicken`.)

Cleaning: the PDF was extracted with `pdftotext -enc UTF-8` and stripped of page numbers, the
repeated running footer, and footnote/reference lines; the HTML guides were reduced to body
prose (`<p>/<li>/<h*>`), with site navigation/footer largely dropped. UTF-8, French accents
preserved.

Batch acquired: **2026-06-16** — 4 documents (all Swiss federal, OFCS/NCSC), ~86 KB total.

## Documents

| Filename | Title | Publisher / office | Jurisdiction | Source URL | License | Retrieved | Size |
|---|---|---|---|---|---|---|---|
| ch-ncsc-protection-informatique-base.txt | Si001 — Protection informatique de base dans l'administration fédérale (V5.1) | Office fédéral de la cybersécurité (OFCS / NCSC) | Switzerland (federal) | https://www.ncsc.admin.ch/dam/ncsc/fr/dokumente/dokumentation/vorgaben/sicherheit/si001/Si001-IT-Grundschutz-V5-1-f.pdf.download.pdf/Si001-IT-Grundschutz-V5-1-f.pdf | PD — Art. 5 URG | 2026-06-16 | 74 KB |
| ch-ncsc-protection-comptes.txt | Protégez vos comptes | Office fédéral de la cybersécurité (OFCS / NCSC) | Switzerland (federal) | https://www.ncsc.admin.ch/ncsc/fr/home/infos-fuer/infos-private/aktuelle-themen/schuetzen-sie-ihre-konten.html | PD — Art. 5 URG | 2026-06-16 | 3 KB |
| ch-ncsc-sauvegarde-donnees.txt | Vos données sont précieuses — sauvegarde (backup) | Office fédéral de la cybersécurité (OFCS / NCSC) | Switzerland (federal) | https://www.ncsc.admin.ch/ncsc/fr/home/infos-fuer/infos-private/aktuelle-themen/daten-sind-wertvoll.html | PD — Art. 5 URG | 2026-06-16 | 5 KB |
| ch-ncsc-protection-appareils.txt | Protection des appareils | Office fédéral de la cybersécurité (OFCS / NCSC) | Switzerland (federal) | https://www.ncsc.admin.ch/ncsc/fr/home/infos-fuer/infos-private/aktuelle-themen/geraeteschutz.html | PD — Art. 5 URG | 2026-06-16 | 3 KB |

## Coverage contribution

Of the 21 still-uncovered verbs that had any gov/tech candidate, this batch rescued **1**:
`télécharger` (*"…téléchargez-les toujours à partir du site du producteur…"*, from
`ch-ncsc-protection-appareils.txt`). Total placed in `json/literature_examples.json` rose to
**952 / 982 (96.9 %)**.

**Honest finding — the register, not the topic, is the blocker.** The remaining software/business
verbs appear in Swiss IT prose only as their **noun/adjective homographs** (`un poste` not *poster*,
`une branche` not *brancher*, `spécialisé` the adjective not *spécialiser*, `une référence` not
*référencer*). Their genuinely *verbal* uses live in **consumer/colloquial** register (blogs,
social-media and e-commerce how-tos, encyclopedia articles) that formal federal directives don't
provide. Formal Swiss PD sources have largely given what they can; pushing further needs that
register.

## Still uncovered after this batch (30 verbs)

- **Software/business homographs** — verbal only in consumer/colloquial prose (the realistic
  open-licensed source is **Wikipedia FR, CC BY-SA** — a licensing decision deferred to the repo
  owner, as the government tier deliberately avoided non-Etalab French): `adjoindre`, `brancher`,
  `coter`, `diplômer`, `députer`, `grouper`, `illimiter`, `ouvrer`, `poster`, `référencer`,
  `relater`, `saler`, `spécialiser`, `sucrer`, `tailler`, `typer`, `voiler`.
- **Absent general/news/archaic** — need news-adjacent prose (e.g. Wikinews FR, CC BY 2.5) or are
  genuinely rare: `carrer`, `dissoudre`, `enceindre`, `enchaîner`, `foncer`, `handicaper`, `lover`,
  `reconstruire`, `surnommer`, `téléviser`.
- **Inherent form-collisions** — no corpus resolves these (the matched token belongs to another
  word): `faillir` (↔ *falloir*: faut/faudra), `plaire` (↔ adverb *plus*: passé simple "je plus"),
  `violer` (↔ adjective *violent*).
