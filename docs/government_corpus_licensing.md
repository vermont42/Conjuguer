# Government-document licensing for the French example corpus

Research note for the planned **government / technology fallback corpora** (the technical
tail of the ~980 usage-ranked verbs, mirroring Konjugieren's `corpus/government/` and
`corpus/technology/` tiers). The question: to what extent are government documents from
**France, Switzerland, Belgium, and Quebec/Canada** public domain or freely usable —
the way German government documents are under § 5 UrhG?

> **Disclaimer:** General legal information, not legal advice. Copyright in official works
> is genuinely "fuzzy" in several of these countries (the literature says so explicitly).
> For anything shipped commercially, confirm the specific document's license.

## The key distinction that drives everything

There are **two separate legal questions**, with different answers in every country:

1. **Official legal texts** — laws, decrees, regulations, court decisions. Free (or nearly
   so) almost everywhere.
2. **Government *reports* and *publications*** — the prose you'd actually mine for verb
   examples (the analog of Germany's *Berufsbildungsbericht* / *Bundesverkehrswegeplan*).
   **This is where the four jurisdictions diverge sharply**, and it's the category that
   matters for the corpus.

### The German baseline (why Konjugieren could do this freely)

Germany's **§ 5 UrhG** is unusually generous. § 5(1) frees laws/ordinances/decrees;
§ 5(2) frees **"other official works published in the official interest for general public
information"** — covering the public-facing ministry reports Konjugieren used. So in
Germany *both* tiers are essentially public domain (subject only to an attribution /
no-distortion duty). **None of the four French-speaking jurisdictions is quite this clean.**

## Ranking for the corpus use case (best → worst)

| Jurisdiction | Official legal texts | Government **reports/prose** | Verdict |
|---|---|---|---|
| **🇨🇭 Switzerland** | Public domain (Art. 5 URG) | **Public domain** — Art. 5 explicitly frees "decisions, minutes and **reports** issued by authorities and public administrations" | **Best.** Closest to Germany. Swiss federal docs are published in French. |
| **🇫🇷 France** | Public domain; Légifrance is Licence Ouverte 2.0 | **Copyrighted by default**, but most is released under **Licence Ouverte 2.0 (Etalab)** = permissive (commercial OK, attribution only) | **Good, with per-document license check.** |
| **🇧🇪 Belgium** | Public domain (Art. XI.172 §2 CDE — "official acts of authority") | **Murky** — the exclusion covers official *acts*, not clearly *reports/brochures*; those can remain copyrighted | **Partial.** Use open-data releases. |
| **🇶🇨 Quebec** | **Crown copyright asserted even over statutes** | **Copyrighted, reproduction prohibited without authorization** (Quebec.ca) | **Worst.** Avoid Quebec.ca; use open-license portals only. |

## Detail by jurisdiction

### 🇨🇭 Switzerland — strongest match to Germany

**Art. 5 of the Federal Copyright Act (URG/LDA)** excludes from protection: "acts,
ordinances, international treaties and other official enactments; … **decisions, minutes
and reports issued by authorities and public administrations**; and patent
specifications." That second clause is the prize — **government reports are flat-out
public domain**, like Germany. Switzerland publishes federally in French (an official
language), so Swiss-French administrative prose (federal offices; cantonal reports from
Geneva/Vaud/Valais) is directly usable. **For the technical-verb fallback tier,
Switzerland alone could likely supply most of what's needed, cleanly.**

### 🇫🇷 France — the "mixed" case

- **Official legal texts** (lois, décrets, jurisprudence) are public domain, and Légifrance
  states *"Sauf mention contraire, tous les contenus de ce site sont sous licence
  etalab-2.0."*
- **Government reports are copyrighted by default** — Wikimedia's France guidance warns:
  *"one should assume by default that anything from a government entity is copyrighted."*
  France has **no broad § 5-style exclusion**.
- **The escape hatch: Licence Ouverte 2.0 (Etalab)** — France's permissive open license
  (worldwide, commercial use allowed, **attribution the only obligation**; compatible with
  CC-BY / OGL). Decree 2017-638 made it the reference license for public-sector
  information, so most of `data.gouv.fr` and many ministry publications carry it.
- **⚠️ Watch the license per source.** Not everything is Licence Ouverte. Wikimedia notes
  `gouvernement.fr` website content is **CC BY-NC-ND** (non-commercial + no-derivatives) —
  **not** usable in the app. Prefer documents explicitly tagged Licence Ouverte / Etalab,
  and check before relying on any given report.

### 🇧🇪 Belgium — official acts free, reports unclear

**Art. XI.172 §2 of the Code of Economic Law** (formerly Art. 8 §2 of the 1994 Act):
*official acts of authority* give rise to no copyright — laws, decrees, ordinances,
parliamentary documents, court decisions. But this is **narrower than Switzerland**: it
frees official *acts*, not necessarily ministry *reports/brochures*, which can remain
under copyright (Belgian public authorities can hold copyright). French is an official
language, so Walloon/Brussels/federal French-language material exists — but for prose
reports, lean on Belgium's open-data releases (often Licence Ouverte / CC-BY) rather than
assuming the document is free.

### 🇶🇨 Quebec / Canada — most restrictive

- **Crown copyright** (s. 12, Copyright Act, R.S.C. 1985): works "prepared or published by
  or under the direction or control of" the Crown are protected for **50 years**.
- **Quebec is aggressive about it.** Quebec.ca's copyright page: *"It is prohibited to
  reproduce, download, store, translate, adapt, publish or represent in public the
  copyrighted materials of the Gouvernement du Québec without prior authorization,"* with
  **no commercial/non-commercial distinction** and Crown copyright asserted over
  *"statutes, regulations, reports, and pamphlets."* General Quebec.ca prose is
  **off-limits without permission**.
- **The clean paths for Québécois / Canadian French:**
  - **Données Québec** open data → **CC BY 4.0** (permissive, commercial OK, attribution).
    But it's mostly *datasets*, not prose.
  - **Federal Government of Canada** content → **Open Government Licence – Canada**
    (permissive, commercial use allowed, attribution). Because Canada is officially
    bilingual, `canada.ca` and `open.canada.ca` hold **vast amounts of French-language
    government prose** under OGL-Canada — the best freely-usable source of Canadian-French
    administrative text, and a better bet than Quebec.ca itself.
  - Federal **statutes and court decisions** are separately reproducible under the
    *Reproduction of Federal Law Order*.

## Practical recommendation for the corpus

1. **The main corpus isn't affected.** Proust (d. 1922), Zola (d. 1902), Flaubert
   (d. 1880) are all public domain under life+70 — government docs are only the
   *technical-tail fallback*, so the volume needed from them is small.
2. **For the fallback tier, prioritize by legal cleanliness:** **Switzerland
   (public-domain reports)** → **France under Licence Ouverte 2.0** → **Canada federal
   under OGL-Canada** → Belgium open-data → (avoid Quebec.ca general publications).
3. **Attribution is required by all the open licenses** (Etalab, OGL-Canada, CC-BY). The
   JSON `source` field already does this — record the document + license, and consider a
   corpus credits/licenses note.
4. **Secondary option — the quotation exception.** Extracting *one sentence per verb* (not
   redistributing documents) is permitted under France's *exception de courte citation*
   (Art. L.122-5 CPI), Belgium's and Switzerland's quotation rights (CH: Art. 25 URG), and
   Canada's *fair dealing*. A single attributed sentence is a strong quotation case — but
   it's more legally fragile and jurisdiction-specific than using public-domain / openly
   licensed sources, so treat it as a backup, not the plan. (The appeal of the German
   model is that it avoided this question entirely.)

**Bottom line:** None of the four is as frictionless as Germany's § 5, but **Switzerland
comes closest** (reports are genuinely public domain), **France is fine where Licence
Ouverte applies** (check per document), **Canada-federal under OGL-Canada is the right
door for Québécois French** (not Quebec.ca), and **Belgium is workable via open-data
releases**. Quebec's own government publications are the one category to steer clear of
without permission.

## Sources

- Switzerland Federal Copyright Act (URG), Art. 5 — [WIPO Lex](https://wipolex-res.wipo.int/edocs/lexdocs/laws/en/ch/ch229en.html) · [Wikimedia Commons: Switzerland](https://commons.wikimedia.org/wiki/Commons:Switzerland)
- France — [Wikimedia Commons: France copyright rules](https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/France) · [Licence Ouverte / Etalab 2.0 (PDF)](https://www.etalab.gouv.fr/wp-content/uploads/2018/11/open-licence.pdf) · [Licence Ouverte — Wikipedia](https://en.wikipedia.org/wiki/Licence_Ouverte) · [Légifrance open-data/API terms](https://www.legifrance.gouv.fr/contenu/menu/a-propos-de-legifrance-beta/open-data-et-api)
- Belgium — [Copyright in the Code of Economic Law (Kluwer Copyright Blog)](https://legalblogs.wolterskluwer.com/copyright-blog/copyright-in-the-new-belgian-code-of-economic-law-codification-and-new-regulation/) · [Wikimedia Commons: Belgium](https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/Belgium)
- Canada / Quebec — [Wikimedia Commons: Canada (Crown copyright, s.12)](https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/Canada) · [Gouvernement du Québec — Copyright](https://www.quebec.ca/en/copyright) · [Données Québec — CC BY 4.0](https://www.donneesquebec.ca/licence/)
- Germany — [Wikimedia Commons: Germany (§ 5 UrhG)](https://commons.wikimedia.org/wiki/Commons:Copyright_rules_by_territory/Germany)
