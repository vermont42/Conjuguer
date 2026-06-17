# Classical-tier authored examples (Claude-original)

The 63 verbs below are **Chanson-only** verbs — they have a *Chanson de Roland* example
(`corpus/json/chanson_examples.json`) but are not among the 982 usage-ranked verbs, so the
modern-prose mining never covered them. The owner wanted each honored with a *modern* example
beneath its Chanson one. The new **classical tier** (La Fontaine + Molière — see
`docs/classical-corpus-sources.md`) supplied a genuine verbal example for **81** of the 144; the
**63** here had no usable verbal use in that tier and are therefore **original, AI-authored
sentences written by Claude (Opus 4.8)** — not drawn from any document.

In `corpus/json/literature_examples.json` each carries `"source": "Claude (Opus 4.8)"` and
`"line": null`, exactly like the earlier 19 ranked-verb stragglers (`docs/authored-examples.md`), so
AI authorship is explicit and never attributed to a corpus. Each sentence uses the verb in a
genuinely **verbal** form (the `token` column).

**Why authored, two cases:**
- **absent** (45 verbs) — the verb's word-forms never occur in La Fontaine or Molière at all
  (genuinely archaic: `occire`, `quérir`, `ester`, `chaloir`, `embattre`, …).
- **homograph-only** (18 verbs) — the tier contains only the same-spelled noun/adjective/
  pronoun, never the verb (`celer`↔*cela*, `luire`↔*lui*, `seoir`↔*soit*, `traire`↔*trait*,
  `secourir`↔*secours*, `poindre`↔*point*, `sourdre`↔*sourds*, …); the selector correctly rejected
  these rather than pass off a noun as a verbal example.

| Verb | Form | Why | French | English |
|---|---|---|---|---|
| absoudre | absout | homograph-only | Le prêtre absout le pécheur repentant de toutes ses fautes. | The priest absolves the repentant sinner of all his sins. |
| adouber | adouba | absent | Le roi adouba le jeune écuyer en le frappant du plat de son épée. | The king dubbed the young squire, striking him with the flat of his sword. |
| affermer | afferma | absent | Le seigneur afferma ses terres à un riche laboureur pour neuf années. | The lord leased out his lands to a wealthy farmer for nine years. |
| affiler | affila | absent | Le faucheur affila sa lame avant de se mettre à couper les blés. | The mower sharpened his blade before setting about cutting the wheat. |
| affubler | affublé | absent | On l'avait affublé d'un chapeau ridicule qui faisait rire tout le village. | They had got him up in a ridiculous hat that made the whole village laugh. |
| angoisser | angoissait | homograph-only | L'attente interminable des résultats l'angoissait au point de l'empêcher de dormir. | The endless wait for the results distressed him so much that it kept him from sleeping. |
| appareiller | appareilla | absent | Le navire appareilla dès l'aube et mit le cap sur les îles lointaines. | The ship set sail at dawn and headed for the distant islands. |
| arguer | argua | absent | Il argua de sa mauvaise santé pour se dispenser du long voyage. | He pleaded his poor health to get out of the long journey. |
| attarder | attarda | absent | Elle s'attarda longtemps devant la vitrine du libraire, incapable de choisir. | She lingered a long while at the bookseller's window, unable to choose. |
| blêmir | blêmit | absent | En apprenant la terrible nouvelle, il blêmit et dut s'appuyer contre le mur. | On hearing the terrible news, he turned pale and had to lean against the wall. |
| brandir | brandit | homograph-only | Le chevalier brandit son épée et s'élança au galop vers l'ennemi. | The knight brandished his sword and charged at a gallop toward the enemy. |
| ceindre | ceignit | absent | Avant la bataille, le guerrier ceignit son épée et boucla son armure. | Before the battle, the warrior girded on his sword and fastened his armor. |
| celer | celer | homograph-only | Elle ne put celer plus longtemps le chagrin qui lui rongeait le cœur. | She could no longer conceal the grief that was gnawing at her heart. |
| chaloir | chaut | absent | Peu lui chaut ce que pensent les envieux ; il suit sa route sans broncher. | Little does he care what the envious think; he goes his way without flinching. |
| charrier | charriait | absent | Le fleuve en crue charriait des troncs d'arbres et des pans de toiture. | The flooding river was carrying along tree trunks and sections of roofing. |
| cingler | cinglait | absent | Le vent du nord lui cinglait le visage tandis qu'il traversait la lande. | The north wind lashed his face as he crossed the moor. |
| clamer | clamait | absent | L'accusé clamait son innocence devant la cour assemblée. | The accused loudly proclaimed his innocence before the assembled court. |
| corroyer | corroyait | absent | L'artisan corroyait le cuir pour l'assouplir avant d'en faire des bottes. | The craftsman curried the leather to soften it before making boots from it. |
| crouler | crouler | absent | Rongée par les ans, la vieille tour menaçait de crouler au premier orage. | Worn away by the years, the old tower threatened to collapse at the first storm. |
| déclore | déclôt | absent | Au retour du printemps, le verger déclôt ses premières fleurs blanches. | With the return of spring, the orchard opens its first white blossoms. |
| défaillir | défaillir | homograph-only | Saisie par la chaleur, elle sentit ses forces défaillir et faillit tomber. | Overcome by the heat, she felt her strength give way and nearly fell. |
| déjeter | déjetée | absent | Avec l'humidité, la planche mal séchée s'était déjetée et fermait mal la porte. | With the damp, the poorly dried board had warped and no longer closed the door properly. |
| démailler | démailler | absent | Une seule maille qui file suffit à démailler tout le bas de soie. | A single running stitch is enough to unravel the whole silk stocking. |
| démener | démenait | absent | Il se démenait comme un beau diable pour sauver son commerce de la ruine. | He was struggling for all he was worth to save his business from ruin. |
| détordre | détordit | absent | Elle détordit patiemment le fil de fer pour libérer le petit oiseau pris au piège. | She patiently untwisted the wire to free the little bird caught in the trap. |
| embattre | embattit | absent | Le charron embattit la jante de fer brûlant autour de la roue de bois. | The wheelwright fitted the red-hot iron rim around the wooden wheel. |
| embroncher | embroncha | absent | Accablé de honte, le coupable embroncha la tête sans oser répondre. | Overcome with shame, the guilty man bowed his head, not daring to answer. |
| empenner | empenna | absent | L'archer empenna soigneusement chacune de ses flèches avant le tournoi. | The archer carefully fletched each of his arrows before the tournament. |
| encombrer | encombraient | homograph-only | Mille livres et paperasses encombraient le bureau du vieux notaire. | A thousand books and papers cluttered the old notary's desk. |
| enfreindre | enfreindre | absent | Nul ne saurait enfreindre la loi sans s'exposer à de lourdes peines. | No one may break the law without risking heavy penalties. |
| enluminer | enluminait | absent | Le moine enluminait les majuscules d'or fin et d'azur. | The monk illuminated the capital letters in fine gold and azure. |
| enquérir | enquit | absent | Dès son arrivée, elle s'enquit de la santé de son vieil ami. | As soon as she arrived, she inquired after her old friend's health. |
| escrimer | escrimait | homograph-only | Il s'escrimait depuis une heure à déchiffrer cette vieille écriture effacée. | He had been struggling away for an hour to decipher that faded old handwriting. |
| ester | ester | absent | La commune a le droit d'ester en justice pour défendre ses biens. | The municipality has the right to go to court to defend its property. |
| fiancer | fiancée | absent | Ses parents l'avaient fiancée fort jeune à un marchand de la ville voisine. | Her parents had betrothed her very young to a merchant from the neighboring town. |
| flamber | flambaient | absent | Les bûches sèches flambaient gaiement dans l'âtre de la grande salle. | The dry logs blazed merrily in the hearth of the great hall. |
| forfaire | forfaire | homograph-only | Jamais ce loyal serviteur n'eût voulu forfaire à l'honneur de sa maison. | Never would this loyal servant have wished to betray the honor of his house. |
| froisser | froissa | absent | Il froissa la lettre avec colère et la jeta au feu sans l'achever. | He angrily crumpled the letter and threw it into the fire without finishing it. |
| gemmer | gemmaient | absent | Au printemps, les résiniers gemmaient les pins pour en recueillir la sève. | In spring, the resin-tappers tapped the pines to collect their sap. |
| gracier | gracia | absent | Le roi gracia le condamné à la veille même de son supplice. | The king pardoned the condemned man on the very eve of his execution. |
| guerroyer | guerroyaient | absent | Les barons guerroyaient sans cesse contre leurs voisins pour un arpent de terre. | The barons waged war endlessly against their neighbors over an acre of land. |
| honnir | honnissait | absent | La foule honnissait le traître qu'on menait au gibet. | The crowd reviled the traitor being led to the gallows. |
| jouter | joutaient | absent | Les chevaliers joutaient en lice devant la cour émerveillée. | The knights jousted in the lists before the marveling court. |
| lacer | laça | absent | La servante laça le corset de sa maîtresse avant le bal. | The maid laced up her mistress's corset before the ball. |
| luire | luisait | homograph-only | Au loin, une faible lumière luisait à la fenêtre de la chaumière. | In the distance, a faint light gleamed at the window of the cottage. |
| mater | mata | homograph-only | Le capitaine mata la révolte des matelots d'une main de fer. | The captain crushed the sailors' mutiny with an iron hand. |
| muer | mue | homograph-only | Chaque année, le serpent mue et abandonne sa vieille peau. | Each year the snake molts and sheds its old skin. |
| navrer | navre | absent | Cela me navre de le voir gâcher ainsi un si beau talent. | It grieves me to see him squander such a fine talent like this. |
| occire | occire | absent | Le héros jura d'occire le dragon qui désolait la contrée. | The hero swore to slay the dragon that was ravaging the land. |
| poindre | poindre | homograph-only | Le jour commençait à poindre quand les voyageurs se remirent en route. | Day was beginning to break when the travelers set off again. |
| quérir | quérir | absent | On dépêcha un valet quérir le médecin au village voisin. | A servant was sent to fetch the doctor from the neighboring village. |
| rallier | rallia | absent | Le capitaine rallia ses hommes dispersés et reforma les rangs. | The captain rallied his scattered men and re-formed the ranks. |
| rayer | raya | homograph-only | D'un trait de plume, il raya son nom de la liste des invités. | With a stroke of the pen, he crossed his name off the guest list. |
| reluire | reluire | absent | Elle astiqua l'argenterie jusqu'à la faire reluire comme un miroir. | She polished the silverware until she made it gleam like a mirror. |
| remembrer | remembrer | absent | La commune a fait remembrer les parcelles morcelées pour faciliter les labours. | The municipality had the fragmented plots consolidated to make plowing easier. |
| repairer | repairait | absent | Le renard repairait au plus profond du bois dès que pointait l'aube. | The fox would return to its lair deep in the woods as soon as dawn broke. |
| saillir | saillait | absent | Un balcon de pierre saillait au-dessus du portail de la vieille demeure. | A stone balcony jutted out above the gateway of the old dwelling. |
| secourir | secourir | homograph-only | Les passants se précipitèrent pour secourir le vieillard tombé sur le verglas. | The passers-by rushed to help the old man who had fallen on the ice. |
| seoir | seyait | homograph-only | Cette robe de velours lui seyait à merveille. | That velvet gown suited her wonderfully. |
| sourdre | sourdait | homograph-only | Une source claire sourdait entre les rochers au pied de la colline. | A clear spring welled up among the rocks at the foot of the hill. |
| traire | trayait | homograph-only | Chaque matin, la fermière trayait ses vaches avant le lever du soleil. | Every morning the farmer's wife milked her cows before sunrise. |
| éclisser | éclissa | absent | Le rebouteux éclissa la jambe brisée du blessé avec deux planchettes. | The bonesetter splinted the injured man's broken leg with two small boards. |
| émerveiller | émerveillait | homograph-only | Le spectacle des étoiles filantes émerveillait les enfants. | The sight of the shooting stars filled the children with wonder. |
