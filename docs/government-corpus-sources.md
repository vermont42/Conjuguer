# Government-corpus sources (provenance manifest)

Provenance for the **government tier** of the French example corpus — the raw documents
mined for example sentences covering the technical tail of the ~980 usage-ranked verbs.

**Why this file is tracked.** The raw `.txt` files live under `corpus/originals/government/`,
which is **gitignored** (large, re-fetchable — see `CLAUDE.md` › *Literature-Example Corpus*).
This manifest is the durable record: it preserves attribution (a condition of every open
license used here) and lets anyone re-fetch the sources. Only the eventual derived JSON ships
in the app.

**License gate (per `docs/government-corpus-licensing.md`).**
- 🇨🇭 **Switzerland** — official reports of authorities/administrations are **public domain**
  under **Art. 5 URG** (Federal Copyright Act). No per-document license check needed.
- 🇫🇷 **France** — government works are **copyrighted by default**; included here **only** where
  **Licence Ouverte 2.0 / Etalab** is positively confirmed (or public domain). The
  per-document license evidence was verified at acquisition time; documents whose open
  license could not be confirmed were skipped (see *Skipped on license grounds* below).

Cleaning: each file was extracted (mostly `pdftotext`) and **aggressively reduced to running
prose** — page furniture, TOCs, tables, figures, captions, footnotes, abbreviation lists,
name lists, and URLs stripped; hyphenated line-breaks rejoined; UTF-8 with French accents
preserved. No sentence extraction has been run yet.

Batch acquired: **2026-06-16** — 20 documents (10 Swiss + 10 French), ~4.97 MB total.

## Documents

| Filename | Title | Publisher / office | Jurisdiction | Source URL | License | Retrieved | Size |
|---|---|---|---|---|---|---|---|
| ch-fed-conseil-federal-loi-co2-2022.txt | Message relatif à la révision de la loi sur le CO2 pour la période postérieure à 2024 (22.061), 16 sept. 2022 | Conseil fédéral / DETEC (OFEV) | Switzerland (federal) | https://www.fedlex.admin.ch/eli/fga/2022/2651/fr | PD — Art. 5 URG | 2026-06-16 | 152 KB |
| ch-fed-ofs-pauvrete-2012.txt | Pauvreté en Suisse : concepts, résultats et méthodes (enquête SILC 2008–2010) | Office fédéral de la statistique (OFS) | Switzerland (federal) | https://www.bfs.admin.ch/bfsstatic/dam/assets/348362/master | PD — Art. 5 URG | 2026-06-16 | 188 KB |
| ch-fed-ofev-environnement-suisse-2022.txt | Environnement Suisse 2022 — Rapport du Conseil fédéral | Office fédéral de l'environnement (OFEV) | Switzerland (federal) | https://www.bafu.admin.ch/dam/fr/sd-web/GjWv4YDOaKui/umweltbericht2022.pdf | PD — Art. 5 URG | 2026-06-16 | 275 KB |
| ch-fed-oft-transfert-trafic-2025.txt | Rapport sur le transfert du trafic, juillet 2023 à juin 2025 (19 nov. 2025) | Office fédéral des transports (OFT) | Switzerland (federal) | https://www.bav.admin.ch/dam/fr/sd-web/XDjNDhXEeaxf/rapport-sur-le-transfert-2025.pdf | PD — Art. 5 URG | 2026-06-16 | 278 KB |
| ch-fed-ofcom-haut-debit-2025.txt | Loi sur la promotion du haut débit (LPHD) — Rapport explicatif (procédure de consultation) | Office fédéral de la communication (OFCOM) | Switzerland (federal) | https://www.bakom.admin.ch/dam/fr/sd-web/pNK-dHlMfH55/erlaeuternder-bericht-breitbandfoerdergesetz.pdf | PD — Art. 5 URG | 2026-06-16 | 139 KB |
| ch-fed-suisse-numerique-cyberstrategie-2023.txt | Cyberstratégie nationale (CSN) | Centre national pour la cybersécurité (NCSC) / Conseil fédéral | Switzerland (federal) | https://www.ncsc.admin.ch/dam/ncsc/fr/dokumente/strategie/cyberstrategie-ncs/Nationale-Cyberstrategie-NCS-2023-04-13-FR.pdf.download.pdf/Nationale-Cyberstrategie-NCS-2023-04-13-FR.pdf | PD — Art. 5 URG | 2026-06-16 | 100 KB |
| ch-ge-rapport-gestion-conseil-etat-2006.txt | Rapport de gestion 2006 du Conseil d'État | République et canton de Genève | Switzerland (canton Genève) | https://www.ge.ch/document/rapport-gestion-2006-du-conseil-etat-republique-canton-geneve/telecharger | PD — Art. 5 URG | 2026-06-16 | 373 KB |
| ch-vd-rapport-gestion-2025.txt | Rapport annuel de gestion 2025 | État de Vaud (Conseil d'État) | Switzerland (canton Vaud) | https://publication.vd.ch/fileadmin/ra/ce/rag/2025/Rapport_annuel_de_gestion_2025_-_Publication_-optimise.pdf | PD — Art. 5 URG | 2026-06-16 | 420 KB |
| ch-vs-rapport-gestion-2006.txt | Rapport de gestion 2006 du Conseil d'État | État du Valais | Switzerland (canton Valais) | https://www.vs.ch/documents/741795/743640/2006%20Rapport%20annuel%20du%20Conseil%20d'Etat.pdf/3c45e1e2-8a7d-4c7c-a1fd-08b5418f6d51 | PD — Art. 5 URG | 2026-06-16 | 459 KB |
| ch-fr-rapport-activite-conseil-etat-2025.txt | Rapport d'activité du Conseil d'État 2025 | Conseil d'État du Canton de Fribourg | Switzerland (canton Fribourg) | https://www.fr.ch/document/589501 | PD — Art. 5 URG | 2026-06-16 | 224 KB |
| fr-france-strategie-intelligence-artificielle-travail-2018.txt | Intelligence artificielle et travail | France Stratégie | France | https://www.strategie-plan.gouv.fr/files/files/Publications/Rapport/fs-rapport-intelligence-artificielle-28-mars-2018_0.pdf | Licence Ouverte 2.0 | 2026-06-16 | 166 KB |
| fr-ademe-transitions-2050-2021.txt | Transition(s) 2050 — Choisir maintenant, agir pour le climat | ADEME (Agence de la transition écologique) | France | https://librairie.ademe.fr/ged/6531/transitions2050-rapport-compresse2.pdf | Licence Ouverte 2.0 | 2026-06-16 | 254 KB |
| fr-cnil-rapport-annuel-2023.txt | 44ᵉ rapport annuel 2023 | CNIL | France | https://www.cnil.fr/sites/cnil/files/2024-05/cnil_44e_rapport_annuel_2023.pdf | Licence Ouverte 2.0 | 2026-06-16 | 203 KB |
| fr-anssi-panorama-cybermenace-2024.txt | Panorama de la cybermenace 2024 (CERTFR-2025-CTI-003) | ANSSI / CERT-FR | France | https://www.cert.ssi.gouv.fr/uploads/CERTFR-2025-CTI-003.pdf | Licence Ouverte 2.0 | 2026-06-16 | 88 KB |
| fr-strategie-ia-villani-2018.txt | Donner un sens à l'intelligence artificielle : pour une stratégie nationale et européenne | Cédric Villani / Premier ministre (via vie-publique.fr / DILA) | France | https://www.vie-publique.fr/files/rapport/pdf/184000159.pdf | Licence Ouverte 2.0 | 2026-06-16 | 297 KB |
| fr-cerema-mobilites-decarbonees-2022.txt | Mobilités décarbonées. Un défi global (Les dossiers) | CEREMA | France | https://www.cerema.fr/fr/centre-ressources/boutique/mobilites-decarbonees-defi-global | Licence Ouverte 2.0 | 2026-06-16 | 363 KB |
| fr-insee-emploi-pauvrete-demographie-2024.txt | Recueil de cinq études Insee Première (emploi, niveau de vie/pauvreté, bilan démographique ; nos 1987, 2044, 2063, 1978, 2033) | INSEE | France | https://www.insee.fr/fr/statistiques/7936590 | Licence Ouverte 2.0 | 2026-06-16 | 65 KB |
| fr-france-strategie-soutenabilites-2022.txt | Soutenabilités ! Orchestrer et planifier l'action publique | France Stratégie | France | https://www.strategie-plan.gouv.fr/files/2025-01/fs-2022-rapport-soutenabilites-mai_0_0.pdf | Licence Ouverte 2.0 | 2026-06-16 | 366 KB |
| fr-sante-publique-demain-2022.txt | Dessiner la santé publique de demain | Ministère des solidarités et de la santé (Franck Chauvin) (via vie-publique.fr / DILA) | France | https://www.vie-publique.fr/rapport/284241-dessiner-la-sante-publique-de-demain | Licence Ouverte 2.0 | 2026-06-16 | 368 KB |
| fr-insee-references-entreprises-2023.txt | Les entreprises en France — Insee Références, édition 2023 | INSEE | France | https://www.insee.fr/fr/statistiques/fichier/7681078/ENTFRA23.pdf | Licence Ouverte 2.0 | 2026-06-16 | 76 KB |

## License evidence (France — per-document confirmation)

Switzerland needs no per-document check (Art. 5 URG, public domain). France confirmations:

- **France Stratégie** (both files) — site-wide mentions légales (`strategie-plan.gouv.fr/mentions-legales`): *"Sauf mention contraire, tous les contenus de ce site sont sous licence etalab-2.0."* No contrary per-document notice.
- **ADEME** (Transition(s) 2050) — the official `data.gouv.fr` dataset entry lists the license verbatim as *"Licence Ouverte / Open Licence version 2.0."*
- **CNIL** (rapport annuel 2023) — the gouv.fr documentation portal (`documentation-administrative.gouv.fr`, entry adm-01860320v1) tags the document *"© Licence ouverte v 2.0"* (Etalab). (Note: CNIL's *general editorial* pages are CC BY-ND, but the annual report itself is Licence Ouverte.)
- **ANSSI / CERT-FR** (Panorama 2024) — the PDF colophon states *"Publié sous licence Ouverte / Open Licence (Etalab — V2.0)"*; corroborated by the CERT-FR mentions légales.
- **Villani report** (stratégie IA) — hosted on vie-publique.fr (DILA); site footer: *"Sauf mention contraire, tous les textes de ce site sont sous licence etalab-2.0."*
- **CEREMA** (mobilités décarbonées) — the publication's CEREMA catalog entry (`doc.cerema.fr`) lists *Conditions d'utilisation: "Licence Ouverte Etalab"*; corroborated by CEREMA site-wide mentions légales.
- **INSEE** (both files) — INSEE "Mentions légales et crédits" (`insee.fr/fr/information/2008466`): publications under *Licence Ouverte / Open Licence v2.0 (Etalab)*, attribution *"Source : Insee."*
- **Ministère de la santé** (Dessiner la santé publique de demain) — hosted on vie-publique.fr (DILA), site-wide etalab-2.0; no contrary per-document notice.

## Skipped on license grounds (France)

Promising sources excluded because an open license could **not** be positively confirmed
(per the strict gate — *when in doubt, skip*):

- **Cour des comptes** — the authoritative `data.gouv.fr` release of full-text reports is **ODbL** (Open Database License), not Licence Ouverte; `ccomptes.fr` mentions légales were unreachable and the report PDF carried no in-document license. → skipped.
- **Haut Conseil pour le climat** — its *Informations légales* page asserts copyright (*"© Haut conseil pour le climat – 2019-2024"*) with reproduction **by prior authorization**; no Etalab found on site, PDFs, or data.gouv.fr. → skipped.
- **ARCEP** — `arcep.fr` mentions légales impose **no-commercial-use + no-modification** reproduction terms on editorial reports (incompatible with Licence Ouverte); only ARCEP's *datasets* on data.gouv.fr are Licence Ouverte, not the prose reports. → skipped.

These were backfilled with additional confirmed-Etalab documents (a second France Stratégie
report, a vie-publique.fr health report, and a second INSEE Références volume) to reach the
10-document French target.

## Domain / verb-variety spread

- **Government / administrative:** Swiss federal & cantonal management reports (GE, VD, VS, FR), French public-policy & sustainability reports (France Stratégie ×2, santé publique).
- **Environment / climate / energy:** OFEV, ADEME, France Stratégie soutenabilités.
- **Transport / mobility / infrastructure:** OFT, CEREMA.
- **Technology / cyber / digital / telecom:** Suisse numérique cyberstratégie, OFCOM haut débit, ANSSI panorama, CNIL, Villani IA, France Stratégie IA-travail.
- **Economy / statistics / social:** OFS pauvreté, INSEE ×2.
