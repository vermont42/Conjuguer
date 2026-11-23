# Phase 1 Variant Audit: Optional Standard Conjugations (T1.5)

**For:** Josh, to rule on each row before any variant becomes an accepted quiz answer.
**Written:** 2026-11-22, in Phase 1 of [`pedagogy_implementation.md`](pedagogy_implementation.md),
after Konjugieren's [`pedagogy_phase1_variant_audit.md`](../../Konjugieren/plans/pedagogy_phase1_variant_audit.md).

## Method

1. `scripts/write_forms_json.sh` wrote every verb's conjugations to `corpus/working/conjugations.json`.
2. A script compared each simple-tense cell with the table English Wiktionary gives for the same
   verb (`corpus/working/wiktionary/wiktionary_en_verbs.json`, the verb pass's snapshot), keeping
   rows tagged alternative, rare, or archaic, and listed every form the conjugator does not
   produce: 4,296 forms across 308 verbs. Of these, 2,448 are the 1990 grave accent in a futur
   or conditionnel stem (202 verbs) and 987 the 1990 -eler/-eter spelling (47 verbs). Most of
   the remaining 854 are noise: pronunciations filed as forms, "en" tables (s'en aller, s'en
   ficher), pronominal tables, and the Québec and modern readings of haïr and ouïr, which the
   app keeps as separate entries.
3. The 1990 rows were checked against the official text, "Les rectifications de l'orthographe",
   *Journal officiel*, 6 December 1990, in the Académie française's copy
   ([PDF](https://www.academie-francaise.fr/sites/academie-francaise.fr/files/rectifications_1990.pdf)),
   with [RENOUVO's rules page](http://www.renouvo.org/regles.php) as a second reading. The
   doublets were checked against Larousse's conjugation tables
   (`larousse.fr/conjugaison/francais/<verb>/`), which list alternatives side by side.

The Académie's declaration, printed in the *Journal officiel* in 1993: « Aucune des deux graphies
ne peut être tenue pour fautive. » So every 1990 row below is a second correct spelling, not a
correction.

The rule Josh set on 2026-11-22 governs what follows: a variant passes in the quiz only, with the
app's spelling shown quietly beside the checkmark, and the verb page keeps the spelling it has.

## Rows to Rule On

"Verbs" counts verbs in `verbs.xml` that the rule touches.

| # | Variant | Example (app / variant) | Verbs | Source | Recommendation |
|---|---|---|---:|---|---|
| R1 | No circumflex on i or u | connaît / connait; plaît / plait; traîne / traine; mû / mu; redû / redu; accroît / accroit | 713 | JO 1990, Règles 4: « On écrit désormais mu (comme déjà su, tu, vu, lu), plait (comme déjà tait, fait) … traine »; exceptions in 4a and 4b | Accept, with the text's exceptions kept: the passé simple's -îmes and -îtes and the subjonctif imparfait's -ît (vînmes, fûtes, qu'il eût, so also nous eûmes parlé and qu'il eût parlé); dû; jeûne; and croître, « étant donné que sa conjugaison est en partie homographe de celle du verbe croire ». The text adds « L'exception ne concerne pas les dérivés … (croître, mais accroitre) », hence accroit and redu. |
| R2 | -eler and -eter: è and one consonant, or the doubled consonant | étiquette / étiquète; amoncelle / amoncèle; ruissèle / ruisselle; cachète / cachette | 83 + 16 | JO 1990, Règles 5: « On conjugue donc, sur le modèle de peler et d'acheter : elle ruissèle, elle ruissèlera, j'époussète, j'étiquète … On ne fait exception que pour appeler (et rappeler) et jeter (et les verbes de sa famille) » | Accept both ways. The app writes 83 of these verbs the traditional way (étiquette), and the è is the variant. It writes 16 the rectified way (ruissèle, nivèle, ensorcèle, cachète, caquète, déchiquète, …), and the doubled consonant is the variant: Larousse lists both for each of them, as « il ruisselle / ruissèle ». Appeler, rappeler, and the jeter family stay doubled. The 26 verbs whose traditional spelling already has the è (acheter, geler, peler, harceler, modeler, celer, fureter, haleter, …) accept no doubled form. |
| R3 | è in the futur and conditionnel of céder's kind | céderai / cèderai; préférerais / préfèrerais; réglerait / règlerait | 213 | JO 1990, table 3a: « je céderai, j'allégerais → je cèderai, j'allègerais »; Analyse: « je cèderai, je cèderais, j'allègerai, j'altèrerai, je considèrerai » | Accept, for every verb whose présent has the è (cède). A verb whose présent has none (créer, réserver) is not of this kind. |
| R4 | sursoir | surseoirai / sursoirai | 1 | JO 1990, Graphies: « assoir, rassoir, sursoir (au lieu de asseoir, etc.) », note (a): « L'Académie française écrit déjà j'assois … j'assoirai, etc. (mais je surseoirai) » | Accept. Surseoir's futur and conditionnel are the only cells it changes: asseoir and rasseoir already give assoirai, and the quiz never asks an infinitive. |
| R5 | absout, dissout | absous / absout; ai dissous / ai dissout | 2 | JO 1990, Graphies: « absout, absoute (participe, au lieu de absous, absoute) »; « dissout, dissoute (au lieu de dissous, dissoute) » | Accept, in the participe passé and every compound tense. |
| R6 | interpeler | interpellons / interpelons; interpellé / interpelé | 1 | JO 1990, Graphies: « interpeler (au lieu de interpeller) », conjugated as appeler | Accept wherever appeler has one l (nous appelons, appelé). Where appeler doubles (j'appelle, j'appellerai), interpelle stays. |
| R7 | argüer | argue / argüe | 1 | JO 1990, Règles: « le tréma est ajouté dans quelques mots (exemples : argüer, gageüre …) » | Accept, in every cell (argüons, argüé). |
| R8 | Verbs in -otter with one t | grelotte / grelote | ~15 of 30 | JO 1990, Recommandations: verbs « formés sur une base en -ot » are written -oter (greloter, garroter), those formed on a noun in -otte keep -otter (botter, flotter) | Reject. It is a recommendation to lexicographers, not a rule, and deciding each verb needs its etymology. |
| D1 | vouloir's formal series | voulons / veuillons (impératif); voulions / veuillions, vouliez / veuilliez (subjonctif) | 1 | [Larousse](https://www.larousse.fr/conjugaison/francais/vouloir/): « veuillons / voulons »; « Veuillons reste pratiquement inusité »; « que nous voulions / que nous veuillions … plus utilisée que dans le registre très soutenu » | Accept. The app already gives veuille and veuillez beside veux and voulez. |
| D2 | éclôt, enclôt | éclot / éclôt; enclot / enclôt | 2 (+2) | [Larousse](https://www.larousse.fr/conjugaison/francais/eclore/): « L'Académie, dans la 9e édition de son Dictionnaire, écrit il éclôt et il enclôt, comme il clôt … Dans les éditions précédentes, elle écrivait il éclot » | Accept for éclore and enclore. Déclore and forclore follow clore by analogy, and Wiktionary gives déclôt and forclôt; accept them too, or reject them for want of a dictionary. |
| D3 | arguer's traditional diaeresis | argue / arguë; arguions / arguïons | 1 | [Larousse](https://www.larousse.fr/conjugaison/francais/arguer/): « argue / arguë », « arguions / arguïons » | Reject. R7's argüe is the official spelling of the same pronunciation, and the diaeresis on the e is rare. Not built. |
| D4 | Doubled consonants that Larousse does not give | harcèle / harcelle; modèle / modelle; agnèle / agnelle | 3 | Larousse's tables give only « harcèle », « modèle », « agnèle » (its remark on agneler says agnelle, which contradicts its own table) | Reject. Wiktionary only. |
| D5 | Archaic or nonstandard forms in Wiktionary | cueillirai, assaillerai, tressaillerai, je luis (luire's passé simple), il déchet, ils échettent | ~10 | Wiktionary tags, where any | Reject. |

Already accepted, since the conjugator gives both forms as "/" alternates: je paie and je paye
(and il paiera, il payera), je m'assieds and je m'assois (nous asseyons and assoyons, j'assiérai
and j'assoirai), je peux and je puis, veux and veuille, voulez and veuillez.

Not a conjugation, so not asked: the inversion aimè-je and puissè-je (JO 1990, table 3b), and the
invariable participle of laisser before an infinitive (table 6).

## Defects Found Along the Way

These concern the verb page, which this phase does not change.

| Finding | Detail | Suggestion |
|---|---|---|
| Sixteen -eler and -eter verbs show the rectified spelling | ruisseler, niveler, déniveler, ensorceler, déficeler, cacheter, caqueter, craqueter, déchiqueter, dépaqueter, duveter, tacheter, trompeter, briqueter, bêcheveter, marketer show il ruissèle where the rest of the app is traditional (il étiquette, il amoncelle) | Leave for a later session that changes their models, if Josh wants the verb page consistent. R2 accepts both spellings in the quiz either way. |
| éclore and enclore follow the Académie's eighth edition | The verb page shows il éclot and il enclot; the ninth edition writes éclôt and enclôt | Leave, or switch the page to the ninth edition. D2 accepts both in the quiz. |
| The default quiz asked defective cells | falloir in every person (Ridiculous's subjonctif imparfait, and the passé composé and futur pools), faillir in the impératif | Fixed in Phase 1: every draw now goes through the verb's defect group. |

## Rulings

**Josh, 2026-11-22.** Every row recommended for acceptance is accepted: R1, R2, R3, R4, R5, R6,
R7, D1, and D2, déclore and forclore included. R8, D3, D4, and D5 are rejected. All are built in
`Conjuguer/Models/StandardVariants.swift` and pinned row by row in `StandardVariantsTests`, with
the spellings each row must not accept.

- **Quiz acceptance only.** The verb page keeps the conjugator's spelling in every row, the plan's
  default.
- **The sixteen -eler and -eter verbs that the verb page writes in the rectified spelling stay as
  they are.** The quiz accepts both spellings, so nothing a learner types depends on which one
  the page shows.

One rule widened while building, on the evidence above: R2 was first written to give only the è
form. The sixteen verbs already written with è turned up when ruisseler's test failed, and
Larousse lists both spellings for every one of them, so R2 runs in both directions.
