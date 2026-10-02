# Authored examples (Claude-original)

This file records every example sentence Claude wrote rather than found. It has four parts: the
21 below, the 63 archaic verbs of the *Chanson de Roland* in
[`classical-authored.md`](classical-authored.md), the 2,323 sentences of the verb pass, and the 266
of its Stage 5 in the last section. On 2026-10-01 the verb pass replaced one of the 63, *embroncher*,
whose sentence used a sense neither Wiktionary gives.

The 21 verbs below had **no clean verbal use in any open-licensed corpus tier**
(literature / government / technology / wikipedia). Most of their surface forms collide with a
common noun, adjective, or another verb (e.g. `plaire` ↔ adverb *plus*, `faillir` ↔ *falloir*,
`violer` ↔ adjective *violent*), so corpus mining could not place them; the last two —
`bloguer` and `redimensionner`, added on 2026-08-28 — are simply too new and too narrow for the
tiers to contain them verbally at all (the corpus has the nouns `blog` and `redimensionnement`
and nothing else).

These example sentences are therefore **original, AI-authored content** — not sourced from any
document. In `json/literature_examples.json` each carries `"line": null` and a `source` naming
the model that wrote it: `"Claude (Opus 4.8)"` for the first nineteen, `"Claude (Opus 5)"` for
`bloguer` and `redimensionner`. `ExampleSource.claude` carries that string through to the
displayed attribution, so the app never credits the wrong model. Provenance is explicit and
queryable; nothing here is attributed to a corpus source it did not come from. (Konjugieren
handled its corpus stragglers the same way.)

Each sentence uses the verb in a genuinely **verbal** form (the `token` column). `illimiter`
is a rare/neologistic verb; its example is given in the marketing register where it occurs.

| Verb | Form | French | English |
|---|---|---|---|
| adjoindre | s'adjoindre | Pour mener à bien le projet, la directrice a décidé de s'adjoindre deux spécialistes du climat. | To carry out the project, the director decided to bring on two climate specialists. |
| bloguer | blogue | Depuis qu'elle a pris sa retraite, elle blogue chaque semaine sur les oiseaux de son jardin. | Ever since she retired, she has been blogging every week about the birds in her garden. |
| brancher | branchez | Avant de lancer la mise à jour, branchez votre ordinateur sur le secteur. | Before starting the update, plug your computer into the mains. |
| carrer | carra | Il se carra dans son fauteuil et alluma tranquillement sa pipe. | He settled back squarely in his armchair and calmly lit his pipe. |
| diplômer | diplômer | Cette école vient de diplômer sa première promotion d'ingénieurs en cybersécurité. | This school has just graduated its first class of cybersecurity engineers. |
| députer | députa | L'assemblée députa trois de ses membres pour porter la pétition au roi. | The assembly delegated three of its members to bring the petition to the king. |
| enceindre | enceignaient | De puissants remparts enceignaient jadis toute la vieille ville. | Powerful ramparts once encircled the entire old town. |
| faillir | failli | J'ai failli manquer mon train ce matin à cause des embouteillages. | I nearly missed my train this morning because of the traffic. |
| foncer | fonça | Dès que le feu passa au vert, la voiture fonça dans l'avenue. | As soon as the light turned green, the car sped off down the avenue. |
| handicaper | handicapé | Une grave blessure au genou l'a handicapé pendant toute la saison. | A serious knee injury hampered him for the entire season. |
| illimiter | illimite | Ce nouveau forfait illimite vos appels et vos messages vers l'étranger. | This new plan makes your calls and texts abroad unlimited. |
| lover | lova | Le chat se lova au creux du canapé et ne bougea plus de la soirée. | The cat curled up in the hollow of the sofa and didn't move for the rest of the evening. |
| ouvrer | ouvré | Ce candélabre d'argent a été patiemment ouvré par un orfèvre vénitien. | This silver candelabrum was patiently wrought by a Venetian goldsmith. |
| plaire | plu | Ce roman m'a tellement plu que je l'ai lu deux fois de suite. | I enjoyed this novel so much that I read it twice in a row. |
| redimensionner | redimensionne | Il redimensionne la fenêtre pour voir les deux documents côte à côte. | He resizes the window so as to see the two documents side by side. |
| référencer | référencer | Une bonne agence saura référencer votre site afin qu'il apparaisse en première page. | A good agency will know how to optimize your website so that it appears on the first page. |
| sucrer | sucra | Elle sucra légèrement la crème avant de la servir aux invités. | She lightly sweetened the cream before serving it to the guests. |
| typer | typé | Le réalisateur a délibérément typé ses personnages pour les rendre reconnaissables. | The director deliberately gave his characters strong, recognizable types. |
| téléviser | télévisera | La chaîne publique télévisera la cérémonie d'ouverture en direct. | The public channel will broadcast the opening ceremony live. |
| violer | violé | En coupant à travers le terrain, les randonneurs ont violé le règlement du parc. | By cutting across the field, the hikers broke the park's rules. |
| voiler | voilèrent | Peu à peu, de gros nuages voilèrent le soleil. | Little by little, large clouds veiled the sun. |

<!-- verb-pass:start -->

## The verb pass (2,323 verbs, applied 2026-10-01)

Stage 2 of the verb pass (`prompts/verb-pass-plan.md`) had Claude (Sonnet 5) write a sentence for each verb that no corpus sentence or public-domain quotation served, and Stage 3 had Claude (Opus 5) check each one for grammar, sense, translation and register, and for a qualifying candidate passed over. The rows below are the ones Josh accepted, in frequency-rank order. Each carries `"source": "Claude (Sonnet 5)"` and `"line": null`.

| Rank | Verb | Form | French | English |
|---|---|---|---|---|
| 70 | représenter | représente | Ce tableau représente une scène de la campagne française au XIXe siècle. | This painting depicts a scene of the 19th-century French countryside. |
| 74 | participer | participe | Chaque enfant participe à la préparation du repas familial. | Each child takes part in preparing the family meal. |
| 92 | engager | engage | Le contrat l'engage à travailler cinq ans pour l'entreprise. | The contract commits him to working for the company for five years. |
| 94 | perdre | perd | Il perd toujours ses clés en rentrant du travail. | He always loses his keys when he gets home from work. |
| 98 | disposer | disposons | Nous disposons d'un budget limité pour ce projet. | We have a limited budget available for this project. |
| 110 | arrêter | arrêté | La police a arrêté le voleur juste devant la gare. | The police arrested the thief right in front of the station. |
| 197 | toucher | touche | Elle touche l'épaule de son ami pour le rassurer. | She touches her friend's shoulder to reassure him. |
| 228 | monter | monte | Elle monte l'escalier lentement pour ne pas réveiller les enfants. | She climbs the stairs slowly so as not to wake the children. |
| 263 | envisager | envisageons | Nous envisageons de déménager à Lyon l'année prochaine. | We are considering moving to Lyon next year. |
| 279 | visiter | visitons | Nous visitons souvent le musée du Louvre pendant nos vacances à Paris. | We often visit the Louvre museum during our vacations in Paris. |
| 289 | figurer | figure | Son nom figure sur la liste des candidats retenus pour l'entretien. | His name appears on the list of candidates selected for interview. |
| 295 | élever | élevé | Elle a élevé seule ses trois enfants après son divorce. | She raised her three children alone after her divorce. |
| 305 | livrer | livre | Le facteur livre le courrier tous les matins avant midi. | The postman delivers the mail every morning before noon. |
| 496 | sacrer | sacrera | On sacrera le nouveau roi dans la grande cathédrale la semaine prochaine. | They will crown the new king in the great cathedral next week. |
| 543 | restaurer | restauré | Les ouvriers ont restauré le vieux château médiéval pendant deux ans. | The workers restored the old medieval castle for two years. |
| 546 | tromper | trompé | Le vendeur a trompé les clients en leur vendant de faux bijoux. | The salesman deceived the customers by selling them fake jewelry. |
| 551 | corriger | corrige | Le professeur corrige les copies de ses élèves chaque soir. | The teacher corrects her students' papers every evening. |
| 581 | débattre | débattu | Les deux candidats ont débattu pendant deux heures avant l'élection. | The two candidates debated for two hours before the election. |
| 582 | salarier | salarie | L'entreprise salarie plus de cent employés dans son usine. | The company pays wages to more than a hundred employees at its factory. |
| 594 | casser | cassé | Le vase est tombé et s'est cassé en mille morceaux. | The vase fell and broke into a thousand pieces. |
| 655 | activer | activer | Il faut activer la nouvelle carte SIM avant de pouvoir l'utiliser. | You need to activate the new SIM card before you can use it. |
| 726 | découler | découle | De cette étude découle une conclusion importante pour la recherche. | An important conclusion for the research follows from this study. |
| 752 | greneler | grenelle | L'artisan grenelle le cuir pour lui donner un aspect plus texturé. | The craftsman grains the leather to give it a more textured look. |
| 773 | ligner | ligne | Mon grand-père ligne patiemment au bord de la rivière chaque dimanche matin. | My grandfather patiently fishes with a line by the river every Sunday morning. |
| 906 | meubler | meublé | Le jeune couple a meublé son appartement avec des meubles vintage dénichés aux puces. | The young couple furnished their apartment with vintage furniture found at the flea market. |
| 913 | dégrader | dégradé | Le général fut dégradé pour avoir désobéi aux ordres de son supérieur. | The general was demoted for having disobeyed his superior's orders. |
| 940 | percer | percé | L'ouvrier a percé un trou dans le mur pour installer l'étagère. | The worker drilled a hole in the wall to put up the shelf. |
| 954 | vacciner | vacciné | Le médecin a vacciné tous les enfants de l'école contre la grippe la semaine dernière. | The doctor vaccinated all the school's children against the flu last week. |
| 962 | coder | code | Elle code une nouvelle application mobile pendant son temps libre le week-end. | She codes a new mobile app in her free time on weekends. |
| 970 | facturer | facturé | Le garagiste nous a facturé deux cents euros pour la réparation du pare-brise. | The mechanic charged us two hundred euros for repairing the windshield. |
| 1002 | contaminer | contaminé | Le virus a rapidement contaminé plusieurs employés du bureau. | The virus quickly infected several employees at the office. |
| 1016 | retraiter | retraiter | L'usine va retraiter les eaux usées avant de les rejeter dans la rivière. | The plant will reprocess the wastewater before releasing it into the river. |
| 1021 | véhiculer | véhicule | Le bus scolaire véhicule les enfants jusqu'à l'école chaque matin. | The school bus carries the children to school every morning. |
| 1028 | affilier | affilier | Chaque nouvel employé doit s'affilier à la caisse de retraite de l'entreprise. | Every new employee must join the company's pension fund. |
| 1033 | écosser | écosser | Ma grand-mère m'apprend à écosser les petits pois avant de les faire cuire. | My grandmother is teaching me to shell the peas before cooking them. |
| 1047 | subordonner | subordonner | Le directeur a décidé de subordonner l'augmentation de salaire aux résultats de l'entreprise. | The director decided to make the pay raise contingent on the company's results. |
| 1048 | sous-estimer | sous-estimé | Les experts ont sous-estimé l'impact du changement climatique sur les récoltes. | The experts underestimated the impact of climate change on crop yields. |
| 1049 | peler | pèle | Le chef pèle soigneusement les pommes avant de préparer la tarte. | The chef carefully peels the apples before making the tart. |
| 1053 | annexer | annexé | Le royaume voisin a annexé la province après une brève guerre. | The neighboring kingdom annexed the province after a brief war. |
| 1057 | informatiser | informatisé | L'entreprise a entièrement informatisé tous ses dossiers administratifs l'année dernière. | The company fully computerized all its administrative records last year. |
| 1059 | taxer | taxer | Le gouvernement a décidé de taxer davantage les produits de luxe. | The government decided to tax luxury goods more heavily. |
| 1062 | crémer | crème | Le cuisinier crème toujours la soupe avant de la servir. | The cook always adds cream to the soup before serving it. |
| 1067 | poivrer | poivré | Elle a poivré généreusement le steak avant de le griller. | She generously peppered the steak before grilling it. |
| 1072 | redécouvrir | redécouvert | En rangeant le grenier, elle a redécouvert de vieilles lettres de sa grand-mère. | While tidying the attic, she rediscovered old letters from her grandmother. |
| 1079 | démunir | démuni | La crise économique a démuni de nombreuses familles de leurs économies. | The economic crisis left many families stripped of their savings. |
| 1108 | surfer | surfer | Le samedi, elle aime surfer sur les vagues de l'océan. | On Saturdays, she likes to surf the ocean waves. |
| 1136 | superposer | superposé | Le graphiste a superposé une carte transparente sur la photo pour montrer les nouvelles frontières. | The graphic designer superimposed a transparent map over the photo to show the new borders. |
| 1141 | scolariser | scolariser | La commune a décidé de scolariser tous les enfants réfugiés dès la rentrée prochaine. | The town decided to enroll all refugee children in school starting next term. |
| 1144 | contrer | contrer | Le gardien a réussi à contrer toutes les attaques de l'équipe adverse. | The goalkeeper managed to counter all of the opposing team's attacks. |
| 1150 | boucler | boucle | Elle boucle toujours la ceinture de son manteau avant de sortir. | She always buckles her coat belt before going out. |
| 1173 | brunir | bruni | Le soleil d'été a bruni sa peau en quelques jours. | The summer sun tanned his skin within a few days. |
| 1174 | déconcentrer | déconcentre | Le bruit dans le couloir déconcentre les élèves pendant l'examen. | The noise in the hallway distracts the students during the exam. |
| 1176 | hospitaliser | hospitaliser | Les médecins ont dû hospitaliser le patient après son accident de voiture. | The doctors had to hospitalize the patient after his car accident. |
| 1189 | indemniser | indemnisé | L'assurance a indemnisé le propriétaire pour les dégâts causés par l'incendie. | The insurance company compensated the owner for the damage caused by the fire. |
| 1215 | raffiner | raffine | L'usine raffine le pétrole brut pour produire de l'essence et du diesel. | The plant refines crude oil to produce gasoline and diesel. |
| 1219 | râper | râpe | Elle râpe du fromage frais pour garnir les pâtes avant de servir. | She grates some fresh cheese to top the pasta before serving. |
| 1230 | mémoriser | mémorise | Elle mémorise facilement les poèmes qu'elle lit à voix haute. | She easily memorizes the poems she reads aloud. |
| 1235 | sophistiquer | sophistiquent | Ils sophistiquent sans cesse leurs méthodes de fraude pour échapper à la police. | They keep making their fraud schemes more sophisticated to evade the police. |
| 1246 | chier | chié | Le chien a chié sur le trottoir devant chez nous. | The dog pooped on the sidewalk in front of our house. |
| 1285 | paramétrer | paramétrer | Il faut paramétrer le logiciel avant de l'utiliser pour la première fois. | You need to configure the software before using it for the first time. |
| 1288 | propulser | propulsent | Les gaz brûlants propulsent la fusée à travers l'atmosphère vers l'espace. | The hot gases propel the rocket through the atmosphere into space. |
| 1289 | griller | griller | Le matin, elle aime griller deux tranches de pain pour son petit-déjeuner. | In the morning, she likes to toast two slices of bread for breakfast. |
| 1295 | émincer | émince | Le cuisinier émince les oignons pour la sauce. | The cook thinly slices the onions for the sauce. |
| 1297 | polir | polit | Le menuisier polit le bois jusqu'à ce qu'il brille. | The carpenter polishes the wood until it shines. |
| 1298 | espacer | espace | Le jardinier espace les plants de tomates de cinquante centimètres. | The gardener spaces the tomato plants fifty centimeters apart. |
| 1304 | démarcher | démarche | Le vendeur démarche les clients par téléphone tous les jours. | The salesman canvasses customers by phone every day. |
| 1310 | tatouer | tatoue | Le tatoueur tatoue un dragon sur le bras du client. | The tattoo artist tattoos a dragon on the client's arm. |
| 1313 | archiver | archive | L'employée archive tous les documents importants à la fin de l'année. | The employee archives all the important documents at the end of the year. |
| 1318 | plafonner | plafonne | La loi plafonne les frais bancaires à trente euros par an. | The law caps banking fees at thirty euros per year. |
| 1327 | libeller | libeller | Le client demande à la banque de libeller le chèque à son nom. | The customer asks the bank to make out the check in his name. |
| 1343 | motoriser | motorisé | Le fermier a motorisé sa vieille charrette pour transporter plus vite les récoltes. | The farmer motorized his old cart to haul the harvest more quickly. |
| 1349 | industrialiser | industrialiser | Le gouvernement a décidé d'industrialiser la région pour créer des emplois locaux. | The government decided to industrialize the region in order to create local jobs. |
| 1350 | parrainer | parrainer | Une grande entreprise locale a accepté de parrainer le tournoi de football cette année. | A big local company agreed to sponsor the soccer tournament this year. |
| 1371 | sponsoriser | sponsoriser | Une grande marque de sport a accepté de sponsoriser l'équipe nationale de basketball. | A major sports brand agreed to sponsor the national basketball team. |
| 1382 | domicilier | domicilié | Après son divorce, il s'est domicilié à Lyon. | After his divorce, he took up residence in Lyon. |
| 1384 | décrypter | décrypter | Les experts ont réussi à décrypter le message codé en quelques heures. | The experts managed to decrypt the coded message within a few hours. |
| 1393 | préchauffer | préchauffer | Il faut préchauffer le four à deux cents degrés avant d'enfourner le gâteau. | You need to preheat the oven to two hundred degrees before putting in the cake. |
| 1394 | cotiser | cotise | Chaque employé cotise chaque mois à la caisse de retraite. | Each employee contributes to the pension fund every month. |
| 1395 | ailler | aillé | Le chef a aillé la sauce avant de la laisser mijoter. | The chef added garlic to the sauce before letting it simmer. |
| 1404 | louper | loupé | Il a loupé son train parce qu'il s'est réveillé trop tard. | He missed his train because he woke up too late. |
| 1432 | légitimer | légitimé | Le tribunal a légitimé l'enfant né hors mariage après le mariage de ses parents. | The court legitimized the child born out of wedlock after his parents married. |
| 1435 | sérier | sériait | Le bibliothécaire sériait les dossiers selon leur importance avant de les classer. | The librarian arranged the files in order of importance before filing them. |
| 1437 | masser | masse | Le kinésithérapeute masse les muscles endoloris de l'athlète après la course. | The physiotherapist massages the athlete's sore muscles after the race. |
| 1464 | stresser | stressent | Les examens de fin d'année stressent beaucoup les étudiants. | Year-end exams stress students out a lot. |
| 1480 | vitrer | vitré | Le menuisier a vitré la nouvelle porte du salon avant l'hiver. | The carpenter glazed the new living room door before winter. |
| 1493 | infecter | infecté | Le virus a rapidement infecté plusieurs ordinateurs du réseau de l'entreprise. | The virus quickly infected several computers on the company's network. |
| 1495 | enfiler | enfile | Elle enfile son manteau avant de sortir affronter le froid. | She puts on her coat before going out to face the cold. |
| 1496 | enraciner | enracinée | Cette tradition familiale s'est enracinée depuis plusieurs générations. | This family tradition has taken root over several generations. |
| 1505 | agresser | agressé | Le voleur a agressé le passant dans une rue sombre. | The thief assaulted the passerby in a dark street. |
| 1507 | survoler | survole | Le pilote survole la ville pour observer les dégâts après la tempête. | The pilot flies over the city to assess the damage after the storm. |
| 1511 | immatriculer | immatricule | Le concessionnaire immatricule la voiture avant de la livrer au client. | The dealership registers the car before delivering it to the customer. |
| 1512 | transcrire | transcrit | L'assistante transcrit les enregistrements de la réunion pour les archives. | The assistant transcribes the meeting recordings for the archives. |
| 1528 | climatiser | climatise | En été, on climatise le bureau pour que les employés travaillent confortablement. | In summer, they air-condition the office so employees can work comfortably. |
| 1529 | délocaliser | délocaliser | L'entreprise a décidé de délocaliser sa production en Asie pour réduire les coûts. | The company decided to relocate its production to Asia to cut costs. |
| 1549 | fidéliser | fidélise | Ce programme de points fidélise la clientèle en offrant des réductions régulières. | This points program builds customer loyalty by offering regular discounts. |
| 1554 | compresser | compresse | La machine compresse les déchets ménagers avant de les envoyer au recyclage. | The machine compresses household waste before sending it for recycling. |
| 1569 | haver | havent | Les mineurs havent la veine de charbon avant de faire sauter le front de taille. | The miners undercut the coal seam before blasting the coal face. |
| 1572 | originer | s'origine | Cette expression argotique s'origine dans le langage des marins du XIXe siècle. | This slang expression originated in the language of nineteenth-century sailors. |
| 1578 | pomper | pompe | Le fermier pompe l'eau du puits chaque matin pour arroser son jardin. | The farmer pumps water from the well every morning to water his garden. |
| 1592 | ciseler | cisèle | Le chef cisèle finement le persil avant de l'ajouter à la sauce. | The chef finely chops the parsley before adding it to the sauce. |
| 1594 | relaxer | relaxer | Après le travail, j'aime relaxer devant un bon film. | After work, I like to relax in front of a good movie. |
| 1599 | rééditer | rééditer | L'éditeur va rééditer ce roman classique avec une nouvelle couverture. | The publisher is going to reissue this classic novel with a new cover. |
| 1600 | gommer | gomme | L'élève gomme une faute avant de recommencer son dessin. | The student erases a mistake before starting his drawing over. |
| 1605 | concocter | concocté | Le chimiste a concocté une nouvelle formule pour ce parfum. | The chemist concocted a new formula for this perfume. |
| 1610 | corser | corse | Le cuisinier corse la sauce avec un peu de piment pour lui donner du caractère. | The cook spices up the sauce with a bit of chili to give it some character. |
| 1618 | vénérer | vénèrent | Les habitants du village vénèrent ce vieux saint depuis des générations. | The villagers have venerated this old saint for generations. |
| 1627 | irriguer | irrigue | Ce canal irrigue les champs de riz pendant la saison sèche. | This canal irrigates the rice fields during the dry season. |
| 1632 | doser | dose | Le médecin dose précisément le médicament selon le poids du patient. | The doctor doses the medication precisely according to the patient's weight. |
| 1652 | formater | formater | Avant d'installer le nouveau système, il faut formater le disque dur. | Before installing the new system, you need to format the hard drive. |
| 1655 | ressourcer | ressourcer | Après des semaines de stress, elle est partie à la montagne pour se ressourcer. | After weeks of stress, she went to the mountains to recharge. |
| 1656 | randonner | randonner | Chaque week-end, ils aiment randonner dans les montagnes environnantes. | Every weekend, they like to hike in the surrounding mountains. |
| 1657 | tomer | tomeront | Les éditeurs tomeront ce dictionnaire en trois volumes distincts. | The publishers will divide this dictionary into three separate volumes. |
| 1659 | réfuter | réfuté | Le scientifique a réfuté cette théorie grâce à de nouvelles preuves solides. | The scientist refuted this theory with solid new evidence. |
| 1662 | réécrire | réécrire | Elle a dû réécrire son rapport après les remarques de son responsable. | She had to rewrite her report after her manager's comments. |
| 1668 | crypter | crypter | Il faut crypter ces données sensibles avant de les envoyer par e-mail. | You need to encrypt this sensitive data before sending it by email. |
| 1670 | muter | muter | Le directeur a décidé de muter cet employé dans une autre succursale. | The manager decided to transfer this employee to another branch. |
| 1681 | dénicher | dénicher | Le journaliste a réussi à dénicher un témoin clé pour son reportage. | The journalist managed to track down a key witness for his report. |
| 1683 | retransmettre | retransmettre | La chaîne va retransmettre le match de football en direct ce soir. | The channel is going to rebroadcast the football match live tonight. |
| 1685 | décortiquer | décortique | Ma grand-mère décortique les crevettes avant de préparer la salade. | My grandmother shells the shrimp before making the salad. |
| 1687 | interviewer | interviewer | Le journaliste va interviewer le maire à propos du nouveau projet. | The journalist is going to interview the mayor about the new project. |
| 1688 | sous-entendre | sous-entendre | Son silence semblait sous-entendre qu'elle n'était pas d'accord. | Her silence seemed to imply that she disagreed. |
| 1694 | canaliser | canaliser | Le thérapeute l'a aidé à canaliser sa colère de façon plus constructive. | The therapist helped him channel his anger in a more constructive way. |
| 1701 | retranscrire | retranscrire | L'historien a dû retranscrire le manuscrit abîmé pour le rendre lisible. | The historian had to retranscribe the damaged manuscript to make it legible. |
| 1703 | rationaliser | rationaliser | L'entreprise a décidé de rationaliser sa production pour réduire les coûts. | The company decided to rationalize its production in order to cut costs. |
| 1704 | créditer | créditer | La banque va créditer votre compte du montant remboursé demain. | The bank will credit your account with the refunded amount tomorrow. |
| 1705 | râler | râler | Mon voisin n'arrête pas de râler à propos du bruit dans l'immeuble. | My neighbor never stops grumbling about the noise in the building. |
| 1707 | bander | bandé | L'infirmière a bandé la cheville blessée du randonneur avec soin. | The nurse carefully bandaged the hiker's injured ankle. |
| 1711 | épauler | épaulé | Ses collègues l'ont épaulé pendant toute la période difficile après son licenciement. | His colleagues supported him throughout the difficult period after he was laid off. |
| 1713 | ramer | ramer | Le samedi matin, ils aiment ramer sur le lac avant que le vent ne se lève. | On Saturday mornings, they like to row on the lake before the wind picks up. |
| 1714 | dissuader | dissuader | Ses parents ont essayé de le dissuader de partir seul en voyage. | His parents tried to dissuade him from traveling alone. |
| 1715 | pondérer | pondérer | Le comité doit pondérer chaque critère avant de choisir le meilleur projet. | The committee must weigh each criterion before choosing the best project. |
| 1717 | bayer | bayer | Il passait ses journées à bayer aux corneilles, sans jamais rien faire. | He spent his days gawking at nothing, never getting anything done. |
| 1718 | étoiler | s'étoile | Le ciel s'étoile lentement à mesure que la nuit tombe sur la vallée. | The sky slowly becomes studded with stars as night falls over the valley. |
| 1721 | contrarier | contrarier | Le mauvais temps a failli contrarier nos plans de randonnée. | The bad weather nearly upset our hiking plans. |
| 1723 | mondialiser | mondialisé | Le commerce en ligne a mondialisé les habitudes d'achat des consommateurs. | Online commerce has globalized consumers' shopping habits. |
| 1724 | exalter | exaltait | La musique l'exaltait tellement qu'il se mit à danser sur la place publique. | The music thrilled him so much that he started dancing in the public square. |
| 1726 | recomposer | recomposé | Les historiens ont recomposé le déroulement des événements grâce à de nouveaux documents. | Historians reconstructed the sequence of events using newly found documents. |
| 1729 | grever | grever | Cette lourde dette risque de grever le budget municipal pendant des années. | This heavy debt threatens to burden the municipal budget for years. |
| 1733 | bouder | boude | L'enfant boude dans son coin parce qu'il ne veut pas manger ses légumes. | The child is sulking in the corner because he doesn't want to eat his vegetables. |
| 1748 | camer | came | Il se came depuis qu'il traîne avec cette bande. | He's been doing drugs since he started hanging out with that crowd. |
| 1751 | zapper | zappe | Le soir, il zappe sans arrêt entre les chaînes sans rien regarder vraiment. | In the evening, he channel-surfs nonstop without really watching anything. |
| 1758 | scruter | scrute | Le douanier scrute chaque valise avant de laisser passer les voyageurs. | The customs officer scrutinizes every suitcase before letting travelers through. |
| 1759 | frustrer | frustré | Son échec à l'examen l'a beaucoup frustré. | His failure on the exam frustrated him greatly. |
| 1760 | matir | matit | L'artisan matit la surface du bijou pour lui donner un fini discret. | The craftsman mattes the surface of the jewelry to give it a subdued finish. |
| 1764 | cautionner | cautionner | La banque a accepté de cautionner le prêt de mon frère. | The bank agreed to guarantee my brother's loan. |
| 1769 | argenter | argente | L'artisan argente délicatement les couverts avant de les vendre. | The craftsman silver-plates the cutlery delicately before selling it. |
| 1780 | gaver | gave | Le fermier gave les oies chaque jour pour produire du foie gras. | The farmer force-feeds the geese every day to produce foie gras. |
| 1783 | échelonner | échelonné | Le professeur a échelonné les devoirs sur plusieurs semaines pour ne pas surcharger les élèves. | The teacher spread the homework out over several weeks so as not to overload the students. |
| 1789 | confire | confire | Ma grand-mère aime confire des cornichons chaque été dans le vinaigre. | My grandmother loves pickling cucumbers in vinegar every summer. |
| 1793 | incriminer | incriminé | Les enquêteurs ont incriminé le directeur financier dans cette affaire de fraude. | The investigators incriminated the chief financial officer in this fraud case. |
| 1801 | congeler | congeler | Elle préfère congeler les restes plutôt que de les jeter. | She prefers to freeze the leftovers rather than throw them away. |
| 1820 | concasser | concasse | Le chef concasse les tomates avant de préparer la sauce. | The chef dices the tomatoes before making the sauce. |
| 1825 | réaménager | réaménager | La mairie a décidé de réaménager la place principale pour y ajouter des bancs et des arbres. | City hall decided to redesign the main square to add benches and trees. |
| 1830 | appauvrir | appauvrir | La sécheresse continue a fini par appauvrir les sols de la région. | The ongoing drought eventually impoverished the region's soil. |
| 1832 | surgeler | surgèle | Le pêcheur surgèle son poisson dès qu'il rentre au port. | The fisherman deep-freezes his fish as soon as he returns to port. |
| 1840 | commercer | commerce | Ce village frontalier commerce depuis des siècles avec ses voisins par la rivière. | This border village has traded with its neighbors along the river for centuries. |
| 1847 | raccrocher | raccroché | Elle a raccroché le téléphone dès qu'elle a entendu la mauvaise nouvelle. | She hung up the phone as soon as she heard the bad news. |
| 1852 | perpétrer | perpétré | Les cambrioleurs ont perpétré ce vol audacieux en plein jour, devant plusieurs témoins. | The burglars perpetrated this brazen theft in broad daylight, in front of several witnesses. |
| 1861 | allaiter | allaite | Cette jeune mère allaite son bébé chaque matin avant d'aller travailler. | This young mother breastfeeds her baby every morning before going to work. |
| 1862 | ensoleiller | ensoleille | Le soleil du matin ensoleille toute la cuisine à travers la grande fenêtre. | The morning sun fills the whole kitchen with light through the big window. |
| 1865 | napper | nappe | Le chef nappe le gâteau de chocolat fondu avant de servir. | The chef coats the cake with melted chocolate before serving. |
| 1871 | chromer | chrome | L'artisan chrome soigneusement chaque pièce métallique avant de la vendre. | The craftsman carefully chrome-plates each metal part before selling it. |
| 1872 | asservir | asservir | Le dictateur cherchait à asservir tout le peuple par la peur et la propagande. | The dictator sought to enslave the entire population through fear and propaganda. |
| 1880 | inhumer | inhumé | Les archéologues ont découvert un guerrier viking inhumé avec son épée et son bouclier. | Archaeologists discovered a Viking warrior buried with his sword and shield. |
| 1882 | bronzer | bronzent | Beaucoup de touristes bronzent sur la plage pendant tout l'après-midi. | Many tourists tan on the beach all afternoon. |
| 1884 | galérer | galère | Je galère à trouver un appartement abordable dans cette ville. | I'm struggling to find an affordable apartment in this city. |
| 1888 | mousser | mousse | La bière fraîchement versée mousse abondamment dans le verre. | The freshly poured beer foams up generously in the glass. |
| 1897 | dédicacer | dédicacer | L'auteur a accepté de dédicacer son dernier roman après la conférence. | The author agreed to autograph his latest novel after the talk. |
| 1911 | syndiquer | syndiquer | Le nouveau responsable a réussi à syndiquer la majorité des ouvriers de l'usine. | The new representative managed to unionize most of the factory's workers. |
| 1913 | marginaliser | marginaliser | Cette nouvelle politique risque de marginaliser les petites entreprises locales. | This new policy risks marginalizing small local businesses. |
| 1920 | discréditer | discréditer | Ses adversaires politiques ont tenté de le discréditer avec de fausses accusations. | His political opponents tried to discredit him with false accusations. |
| 1931 | huiler | huile | Le mécanicien huile soigneusement les rouages de la vieille horloge chaque mois. | The mechanic carefully oils the gears of the old clock every month. |
| 1932 | instrumentaliser | instrumentaliser | Le parti tente d'instrumentaliser la crise pour gagner des voix aux élections. | The party is trying to exploit the crisis to win votes in the elections. |
| 1943 | jumeler | jumelée | La ville de Lyon s'est jumelée avec plusieurs villes étrangères pour favoriser les échanges culturels. | The city of Lyon has twinned with several foreign cities to encourage cultural exchange. |
| 1944 | lotir | lotir | La commune a décidé de lotir le terrain agricole pour construire de nouvelles maisons. | The town decided to divide the farmland into lots to build new houses. |
| 1955 | décompresser | décompresser | Après une longue semaine de travail, elle aime décompresser en marchant seule dans le parc. | After a long week of work, she likes to unwind by walking alone in the park. |
| 1957 | prospecter | prospecter | La société envoie des géologues pour prospecter la région à la recherche de nouveaux gisements. | The company sends geologists to prospect the region in search of new deposits. |
| 1968 | butter | butte | Le jardinier butte les pommes de terre pour protéger les tubercules du gel. | The gardener heaps soil around the potatoes to protect the tubers from frost. |
| 1969 | beurrer | beurre | Elle beurre généreusement sa tartine avant de la déguster au petit-déjeuner. | She generously butters her slice of bread before eating it for breakfast. |
| 1970 | stériliser | stérilise | Avant l'opération, l'infirmière stérilise soigneusement tous les instruments chirurgicaux. | Before the operation, the nurse carefully sterilizes all the surgical instruments. |
| 1985 | merder | merdé | J'ai complètement merdé mon entretien d'embauche parce que j'étais trop nerveux. | I completely screwed up my job interview because I was too nervous. |
| 1986 | accoler | accolé | Le graphiste a accolé les deux photos pour créer un effet de miroir. | The designer placed the two photos side by side to create a mirror effect. |
| 1987 | courser | coursé | Le chien a coursé le chat autour du jardin pendant plusieurs minutes. | The dog chased the cat around the garden for several minutes. |
| 1988 | boycotter | boycotter | Les habitants du quartier ont décidé de boycotter ce supermarché après le scandale sur les salaires. | The neighborhood residents decided to boycott this supermarket after the wage scandal. |
| 1992 | gréer | gréé | Les marins ont gréé le voilier tout au long de la matinée avant la traversée. | The sailors rigged the sailboat all morning before the crossing. |
| 2001 | panoramiquer | panoramiqué | Le réalisateur a panoramiqué sur la foule avant de couper la scène. | The director panned across the crowd before cutting the scene. |
| 2012 | culpabiliser | culpabilise | Elle culpabilise chaque fois qu'elle refuse une invitation de ses parents. | She feels guilty every time she turns down an invitation from her parents. |
| 2013 | enrober | enrobe | Le chef enrobe les fraises de chocolat fondu avant de les servir. | The chef coats the strawberries in melted chocolate before serving them. |
| 2014 | doucher | se douche | Après son jogging matinal, il se douche rapidement avant d'aller au travail. | After his morning run, he quickly showers before going to work. |
| 2017 | encrer | encre | L'imprimeur encre soigneusement la plaque avant de presser chaque feuille de papier. | The printer carefully inks the plate before pressing each sheet of paper. |
| 2032 | jubiler | jubilaient | Les supporters jubilaient après la victoire de leur équipe en finale. | The fans were jubilant after their team's win in the final. |
| 2034 | traumatiser | traumatisé | L'accident de voiture a traumatisé toute la famille pendant des années. | The car accident traumatized the whole family for years. |
| 2035 | calibrer | calibre | Le technicien calibre l'appareil de mesure avant chaque utilisation. | The technician calibrates the measuring device before each use. |
| 2041 | fragmenter | fragmenter | Le gouvernement a décidé de fragmenter le grand projet en plusieurs phases distinctes. | The government decided to split the large project into several separate phases. |
| 2044 | batailler | batailler | Les habitants du quartier ont dû batailler pendant des années pour obtenir ce nouveau parc. | Residents of the neighborhood had to battle for years to get this new park. |
| 2046 | distancer | distancé | Le coureur kenyan a rapidement distancé ses rivaux dans la dernière ligne droite. | The Kenyan runner quickly outdistanced his rivals in the final stretch. |
| 2048 | crécher | crèche | Pendant les vacances, il crèche chez son cousin à Marseille. | During the holidays, he's crashing at his cousin's place in Marseille. |
| 2051 | radier | radier | Le tribunal a décidé de radier l'avocat du barreau pour faute grave. | The court decided to strike the lawyer off the bar roll for serious misconduct. |
| 2052 | flécher | flécher | La mairie a décidé de flécher le sentier pour guider les randonneurs jusqu'au sommet. | The town hall decided to mark the trail with arrows to guide hikers to the summit. |
| 2055 | dégrouper | dégrouper | Dans le logiciel de retouche photo, elle a dû dégrouper les calques avant de modifier chaque élément. | In the photo-editing software, she had to ungroup the layers before editing each element. |
| 2064 | laquer | laque | Le menuisier laque soigneusement la commode avant de la vendre. | The carpenter carefully lacquers the dresser before selling it. |
| 2065 | épicer | épice | Le chef épice la sauce avec du piment et du cumin. | The chef spices the sauce with chili and cumin. |
| 2071 | démouler | démouler | La pâtissière laisse refroidir le gâteau avant de le démouler. | The pastry chef lets the cake cool before turning it out of the mold. |
| 2086 | interférer | interfère | Le bruit du chantier interfère avec la réception de la radio dans l'appartement. | The noise from the construction site interferes with the radio reception in the apartment. |
| 2094 | avorter | avorter | Faute de financement, le projet a fini par avorter avant même de commencer. | For lack of funding, the project ended up falling through before it even got started. |
| 2095 | remémorer | remémore | Ce vieux carnet lui remémore les étés passés chez ses grands-parents. | This old notebook reminds her of the summers spent at her grandparents' house. |
| 2096 | surélever | surélever | Le propriétaire a décidé de surélever la maison pour ajouter un étage. | The owner decided to raise the house in order to add a floor. |
| 2103 | timbrer | timbre | Le facteur exige qu'on timbre correctement chaque enveloppe avant de la déposer à la poste. | The postal worker requires each envelope to be properly stamped before it's dropped off at the post office. |
| 2108 | oxygéner | oxygéner | Faire du sport en plein air permet d'oxygéner le corps et l'esprit. | Exercising outdoors helps oxygenate both body and mind. |
| 2110 | laminer | laminera | L'usine laminera l'acier pour fabriquer de fines plaques métalliques. | The factory will roll (laminate) the steel to make thin metal sheets. |
| 2114 | démultiplier | démultiplier | Les nouveaux outils numériques permettent de démultiplier la productivité de l'équipe. | The new digital tools make it possible to multiply the team's productivity. |
| 2120 | flipper | flippé | Elle a complètement flippé quand elle a vu une araignée dans la baignoire. | She totally freaked out when she saw a spider in the bathtub. |
| 2121 | astreindre | astreint | Le règlement astreint tous les employés à porter un badge visible. | The regulation requires all employees to wear a visible badge. |
| 2123 | pronostiquer | pronostiquent | Les experts pronostiquent une hausse des températures pour les prochaines décennies. | Experts predict a rise in temperatures over the coming decades. |
| 2125 | hydrater | hydrater | Il faut boire beaucoup d'eau pour bien hydrater son corps pendant l'été. | You need to drink plenty of water to keep your body well hydrated during summer. |
| 2126 | terroriser | terrorise | Le tyran terrorise ses voisins depuis des années pour garder le pouvoir. | The tyrant has been terrorizing his neighbors for years to hold on to power. |
| 2132 | encercler | encerclé | Les policiers ont encerclé le bâtiment pour empêcher toute fuite. | The police surrounded the building to prevent anyone from escaping. |
| 2136 | ruser | ruser | Le renard doit ruser pour échapper aux chasseurs qui traquent sa moindre trace. | The fox has to use cunning to escape the hunters tracking its every move. |
| 2143 | sous-titrer | sous-titrer | Le studio a décidé de sous-titrer le film en plusieurs langues avant sa sortie internationale. | The studio decided to subtitle the film in several languages before its international release. |
| 2151 | voûter | voûté | Le maçon a voûté le plafond de la cave pour renforcer la structure ancienne. | The mason vaulted the cellar ceiling to reinforce the old structure. |
| 2153 | démasquer | démasquer | Le journaliste a réussi à démasquer l'imposteur qui se faisait passer pour un médecin. | The journalist managed to unmask the impostor who was posing as a doctor. |
| 2158 | liter | lite | Le maçon lite les pierres avec soin pour bâtir un mur solide et durable. | The mason lays the stones in courses carefully to build a strong, lasting wall. |
| 2159 | router | router | Le serveur va router automatiquement les paquets de données vers la destination correcte. | The server will automatically route the data packets to the correct destination. |
| 2161 | révoquer | révoquer | Le tribunal a décidé de révoquer la licence du restaurant après plusieurs infractions graves. | The court decided to revoke the restaurant's license after several serious violations. |
| 2162 | truquer | truqué | Les enquêteurs ont découvert que les employés avaient truqué les résultats du concours. | Investigators discovered that the employees had rigged the results of the competition. |
| 2165 | abreuver | abreuve | Le fermier abreuve ses vaches chaque matin avant de les mener au pâturage. | The farmer waters his cows every morning before leading them out to pasture. |
| 2166 | scotcher | scotché | Elle a scotché l'affiche au mur avant que les invités n'arrivent. | She taped the poster to the wall before the guests arrived. |
| 2171 | décompter | décompte | Le comptable décompte les frais de transport avant de valider la facture. | The accountant deducts the transport costs before approving the invoice. |
| 2172 | déambuler | déambuler | Le dimanche après-midi, ils aiment déambuler dans les rues du vieux quartier. | On Sunday afternoons, they like to stroll through the streets of the old quarter. |
| 2173 | décimer | décimé | La maladie a décimé la population du village en quelques semaines. | The disease decimated the village's population within a few weeks. |
| 2176 | pocher | pocher | La cuisinière décide de pocher les œufs dans de l'eau frémissante pendant trois minutes. | The cook decides to poach the eggs in simmering water for three minutes. |
| 2179 | dimensionner | dimensionner | L'ingénieur doit dimensionner correctement les câbles avant de lancer les travaux. | The engineer must properly size the cables before starting the work. |
| 2187 | infirmer | infirmer | Le nouveau témoignage vient infirmer la version des faits présentée par l'accusé. | The new testimony undermines the defendant's version of events. |
| 2189 | pique-niquer | pique-niquer | Chaque été, la famille aime pique-niquer au bord du lac avec des amis. | Every summer, the family likes to have a picnic by the lake with friends. |
| 2191 | expertiser | expertiser | Le notaire a demandé à un spécialiste d'expertiser le tableau avant la vente aux enchères. | The notary asked a specialist to appraise the painting before the auction. |
| 2197 | parasiter | parasite | Ce virus informatique parasite le système et ralentit tous les programmes. | This computer virus parasitizes the system and slows down every program. |
| 2199 | dénier | dénier | L'accusé continue de dénier toute implication dans cette affaire. | The defendant continues to deny any involvement in this affair. |
| 2201 | court-circuiter | court-circuiter | Le nouveau directeur a décidé de court-circuiter les procédures habituelles pour accélérer le projet. | The new director decided to bypass the usual procedures to speed up the project. |
| 2205 | décomplexer | décomplexé | Ce stage de théâtre a vraiment décomplexé les élèves les plus timides. | This drama workshop really freed the shyest students from their inhibitions. |
| 2211 | planquer | planqué | Il a planqué son argent sous le matelas avant de partir en voyage. | He hid his money under the mattress before going on a trip. |
| 2222 | tartiner | tartiner | Elle aime tartiner du miel sur ses tartines le matin. | She likes to spread honey on her toast in the morning. |
| 2224 | métisser | métissé | Les éleveurs ont métissé deux races de chevaux pour créer un animal plus robuste. | The breeders crossbred two horse breeds to create a hardier animal. |
| 2226 | truffer | truffé | Le chef a truffé le pâté avant de le mettre au four. | The chef studded the pâté with truffles before putting it in the oven. |
| 2227 | taler | talé | Elle a talé les pêches en les transportant dans un sac trop plein. | She bruised the peaches by carrying them in an overstuffed bag. |
| 2238 | défouler | défoule | Après une semaine stressante, il se défoule en courant pendant une heure. | After a stressful week, he unwinds by running for an hour. |
| 2250 | ramollir | ramolli | Le beurre a ramolli sur le comptoir pendant que je préparais le gâteau. | The butter softened on the counter while I was making the cake. |
| 2251 | encastrer | encastré | Le menuisier a encastré une étagère dans le mur pour gagner de la place. | The carpenter fitted a shelf into the wall to save space. |
| 2256 | sauner | saunent | Chaque été, les paludiers saunent dans les marais de Guérande. | Every summer, the salt workers harvest salt in the marshes of Guérande. |
| 2257 | désabonner | désabonné | Le service a désabonné automatiquement les utilisateurs inactifs après six mois. | The service automatically unsubscribed inactive users after six months. |
| 2261 | enter | enté | Le jardinier a enté un jeune poirier sur un vieux porte-greffe robuste. | The gardener grafted a young pear tree onto a sturdy old rootstock. |
| 2265 | styliser | stylisé | L'artiste a stylisé les feuilles de la plante pour créer un motif géométrique élégant. | The artist stylized the plant's leaves to create an elegant geometric pattern. |
| 2267 | skier | skier | Chaque hiver, ma famille va skier dans les Alpes pendant une semaine. | Every winter, my family goes skiing in the Alps for a week. |
| 2276 | dépanner | dépanner | Le mécanicien a réussi à dépanner ma voiture juste avant le week-end. | The mechanic managed to fix my car just before the weekend. |
| 2277 | photocopier | photocopier | J'ai dû photocopier tous les documents avant la réunion. | I had to photocopy all the documents before the meeting. |
| 2288 | riposter | riposté | Quand on l'a critiqué en public, il a immédiatement riposté avec des arguments solides. | When he was criticized in public, he immediately retorted with solid arguments. |
| 2293 | caricaturer | caricaturer | Le dessinateur aime caricaturer les hommes politiques dans son journal satirique. | The cartoonist loves to caricature politicians in his satirical newspaper. |
| 2299 | rocher | roche | La bière roche dès que la fermentation atteint son maximum. | The beer starts to foam once fermentation peaks. |
| 2300 | monopoliser | monopoliser | Cette entreprise cherche à monopoliser le marché du logiciel. | This company is trying to monopolize the software market. |
| 2302 | petit-déjeuner | petit-déjeuner | Je préfère petit-déjeuner tôt avant d'aller au travail. | I prefer to have breakfast early before going to work. |
| 2305 | encoder | encoder | Le logiciel doit encoder toutes les données avant de les envoyer. | The software must encode all the data before sending it. |
| 2311 | caraméliser | caraméliser | Il faut caraméliser le sucre à feu doux jusqu'à ce qu'il prenne une couleur dorée. | You need to caramelize the sugar over low heat until it turns golden. |
| 2312 | pister | pister | Les policiers ont réussi à pister le suspect grâce aux caméras de surveillance. | The police managed to track the suspect using the surveillance cameras. |
| 2316 | gripper | grippé | Le moteur a grippé à cause d'un manque d'huile. | The engine seized up from lack of oil. |
| 2320 | cloner | cloner | Les scientifiques ont réussi à cloner une brebis pour la première fois en 1996. | Scientists succeeded in cloning a sheep for the first time in 1996. |
| 2322 | castrer | castrer | Le vétérinaire va castrer le chat demain matin. | The vet is going to neuter the cat tomorrow morning. |
| 2324 | usiner | usiner | L'atelier va usiner ces pièces en acier avec une précision extrême. | The workshop will machine these steel parts with extreme precision. |
| 2325 | désinfecter | désinfecter | L'infirmière a pris le temps de désinfecter la plaie avant de la bander. | The nurse took the time to disinfect the wound before bandaging it. |
| 2326 | récidiver | récidivé | Le prisonnier a récidivé trois mois après sa sortie de prison. | The prisoner reoffended three months after his release from prison. |
| 2327 | chiner | chiner | Le week-end, elle aime chiner dans les brocantes à la recherche de vieux meubles. | On weekends, she likes to hunt for bargains at flea markets, looking for old furniture. |
| 2331 | dévaloriser | dévaloriser | Cette décision risque de dévaloriser fortement notre monnaie nationale. | This decision could severely devalue our national currency. |
| 2340 | débouter | débouter | Le tribunal a décidé de débouter le plaignant faute de preuves suffisantes. | The court decided to dismiss the plaintiff's claim for lack of sufficient evidence. |
| 2341 | globaliser | globaliser | Les grandes entreprises cherchent à globaliser leurs opérations pour réduire les coûts. | Large companies are seeking to globalize their operations in order to cut costs. |
| 2345 | délirer | délire | Quand il a de la fièvre, il délire pendant des heures. | When he has a fever, he raves for hours. |
| 2348 | fariner | farine | La boulangère farine le plan de travail avant d'étaler la pâte. | The baker flours the countertop before rolling out the dough. |
| 2349 | dactylographier | dactylographie | Elle dactylographie son rapport avant la réunion de demain matin. | She types up her report before tomorrow morning's meeting. |
| 2354 | fantasmer | fantasme | Il fantasme depuis des années sur un voyage autour du monde. | He has been fantasizing for years about a trip around the world. |
| 2355 | immigrer | immigré | Ma grand-mère a immigré en France dans les années 1960 pour trouver du travail. | My grandmother immigrated to France in the 1960s to find work. |
| 2358 | agripper | agrippe | L'enfant agrippe la main de sa mère en traversant la rue. | The child grips his mother's hand while crossing the street. |
| 2360 | estampiller | estampille | Le douanier estampille chaque passeport avant de laisser entrer les voyageurs. | The customs officer stamps each passport before letting travelers in. |
| 2361 | contre-attaquer | contre-attaqué | L'équipe a contre-attaqué rapidement après avoir récupéré le ballon. | The team counterattacked quickly after regaining the ball. |
| 2362 | immiscer | s'immisce | Le voisin s'immisce sans cesse dans les disputes familiales des autres. | The neighbor constantly interferes in other people's family disputes. |
| 2367 | cataloguer | catalogue | La bibliothécaire catalogue les nouveaux livres chaque matin avant l'ouverture. | The librarian catalogs the new books every morning before opening. |
| 2368 | flasher | flashé | Le radar a flashé la voiture qui roulait trop vite sur l'autoroute. | The speed camera flashed the car that was going too fast on the highway. |
| 2370 | pourchasser | pourchasse | Le chien pourchasse le chat autour du jardin sans jamais l'attraper. | The dog chases the cat around the garden without ever catching it. |
| 2372 | ressurgir | ressurgissent | De vieux souvenirs ressurgissent chaque fois qu'elle entend cette chanson. | Old memories resurface every time she hears that song. |
| 2377 | zoomer | zoome | Le photographe zoome sur le visage de l'enfant pour capturer son sourire. | The photographer zooms in on the child's face to capture her smile. |
| 2382 | cramer | cramé | Le pain a cramé dans le four pendant qu'elle regardait son téléphone. | The bread burned in the oven while she was looking at her phone. |
| 2383 | pimenter | pimenter | Le chef aime pimenter ses plats avec du piment d'Espelette. | The chef likes to spice up his dishes with Espelette pepper. |
| 2386 | fractionner | fractionner | Le comptable préfère fractionner le paiement total en trois versements mensuels. | The accountant prefers to split the total payment into three monthly installments. |
| 2394 | poncer | ponce | Le menuisier ponce la table en bois avant d'appliquer le vernis. | The carpenter sands the wooden table before applying the varnish. |
| 2397 | cailler | caillé | Le lait a caillé parce qu'il est resté trop longtemps hors du réfrigérateur. | The milk curdled because it was left out of the fridge for too long. |
| 2400 | incinérer | incinérer | La ville a décidé d'incinérer les déchets plutôt que de les enfouir. | The city decided to incinerate the waste rather than bury it. |
| 2402 | dénuder | dénude | Elle dénude soigneusement le fil électrique avant de le brancher. | She carefully strips the electrical wire before plugging it in. |
| 2405 | rediffuser | rediffuser | La chaîne a décidé de rediffuser cet épisode culte demain soir. | The channel decided to rerun this classic episode tomorrow night. |
| 2413 | réapprendre | réapprendre | Après son accident, elle a dû réapprendre à marcher pas à pas. | After her accident, she had to relearn how to walk step by step. |
| 2423 | nationaliser | nationaliser | Le nouveau gouvernement a décidé de nationaliser les compagnies pétrolières. | The new government decided to nationalize the oil companies. |
| 2426 | zipper | zipper | N'oublie pas de zipper ton manteau avant de sortir dans le froid. | Don't forget to zip up your coat before heading out into the cold. |
| 2427 | idéaliser | idéalise | L'artiste idéalise souvent son sujet pour en révéler la beauté profonde. | The artist often idealizes the subject to reveal its deeper beauty. |
| 2429 | dégraisser | dégraisser | Il faut dégraisser la poêle avant de préparer la sauce. | You need to degrease the pan before making the sauce. |
| 2430 | rafler | raflé | Les cambrioleurs ont raflé tous les bijoux avant l'arrivée de la police. | The burglars made off with all the jewelry before the police arrived. |
| 2431 | satiner | satine | Le vernis satine délicatement la surface du meuble en bois. | The varnish gives the wooden furniture's surface a delicate satin finish. |
| 2441 | naturaliser | naturaliser | Le musée a fait naturaliser un renard pour l'exposition sur la faune locale. | The museum had a fox stuffed for the exhibit on local wildlife. |
| 2442 | reclasser | reclasser | L'administration a décidé de reclasser ce document comme confidentiel. | The administration decided to reclassify this document as confidential. |
| 2450 | pédaler | pédale | Chaque matin, elle pédale rapidement pour arriver à l'heure au bureau. | Every morning, she pedals quickly to get to the office on time. |
| 2451 | préfacer | préface | Le célèbre romancier préface le premier livre de son étudiant. | The famous novelist writes the preface for his student's first book. |
| 2453 | poêler | poêle | Elle poêle des champignons avec de l'ail avant de les ajouter à la sauce. | She fries mushrooms with garlic in a pan before adding them to the sauce. |
| 2459 | secréter | secrétaient | Autrefois, les chapeliers secrétaient les peaux de lapin pour en faire du feutre. | In the past, hatters treated rabbit skins with mercury to turn them into felt. |
| 2461 | damer | dame | Chaque nuit, une machine dame les pistes de ski pour les préparer aux skieurs du lendemain. | Every night, a machine grooms the ski slopes to get them ready for the next day's skiers. |
| 2476 | préétablir | préétabli | Les organisateurs avaient préétabli un budget avant de lancer le projet. | The organizers had pre-established a budget before launching the project. |
| 2480 | aromatiser | aromatise | Le chef aromatise la sauce avec du thym et du laurier avant de servir. | The chef flavors the sauce with thyme and bay leaf before serving. |
| 2481 | papoter | papotent | Les deux amies papotent au café pendant des heures chaque samedi matin. | The two friends chat at the café for hours every Saturday morning. |
| 2485 | déshydrater | déshydrate | Le fabricant déshydrate les fruits pour les conserver plus longtemps. | The manufacturer dehydrates the fruit to preserve it longer. |
| 2489 | boiser | boise | Chaque printemps, l'association boise plusieurs hectares de terrain abandonné. | Every spring, the association plants trees on several hectares of abandoned land. |
| 2499 | saouler | s'est saoulé | Il s'est saoulé à la fête de fin d'année avec ses collègues. | He got drunk at the year-end party with his colleagues. |
| 2500 | fissurer | fissurer | Le gel a fini par fissurer le mur du vieux garage. | The frost eventually cracked the wall of the old garage. |
| 2501 | ixer | ixer | Le distributeur a décidé d'ixer ce film à cause de scènes trop violentes. | The distributor decided to X-rate this film because of overly violent scenes. |
| 2503 | aguerrir | se sont aguerris | Ces jeunes soldats se sont aguerris pendant leur premier hiver au front. | These young soldiers toughened up during their first winter at the front. |
| 2509 | relooker | relooker | Elle a décidé de relooker complètement son appartement avant l'arrivée des invités. | She decided to completely redo her apartment's look before the guests arrived. |
| 2513 | titiller | titille | Cette question titille ma curiosité depuis plusieurs jours. | This question has been titillating my curiosity for several days. |
| 2515 | sanctifier | sanctifier | Les fidèles se réunissent chaque dimanche pour sanctifier le jour du Seigneur. | The faithful gather every Sunday to keep the Lord's day holy. |
| 2516 | refiler | refilé | Mon frère m'a refilé son vieux vélo quand il en a acheté un neuf. | My brother passed his old bike on to me when he bought a new one. |
| 2521 | shooter | shooté | L'attaquant a shooté vers le but adverse depuis vingt mètres. | The forward shot toward the opposing goal from twenty meters out. |
| 2524 | légender | légende | Elle légende chaque photo avec la date et le lieu où elle a été prise. | She captions each photo with the date and place it was taken. |
| 2527 | renégocier | renégocier | Les deux entreprises ont décidé de renégocier le contrat après la hausse des prix. | The two companies decided to renegotiate the contract after the price increase. |
| 2529 | crucifier | crucifié | Selon la Bible, les Romains ont crucifié Jésus à Jérusalem. | According to the Bible, the Romans crucified Jesus in Jerusalem. |
| 2531 | patiner | patinent | Chaque hiver, les enfants patinent sur le lac gelé du village. | Every winter, the children ice-skate on the village's frozen lake. |
| 2532 | kidnapper | kidnappé | Les ravisseurs ont kidnappé le PDG devant son domicile lundi matin. | The kidnappers abducted the CEO in front of his home on Monday morning. |
| 2535 | intérioriser | intérioriser | Il a fini par intérioriser les critiques constantes de ses parents. | He eventually internalized his parents' constant criticism. |
| 2543 | prédisposer | prédisposé | Son enfance difficile l'a prédisposé à la méfiance envers les autres. | His difficult childhood predisposed him to distrust other people. |
| 2547 | resurgir | resurgi | Le vieux conflit territorial a resurgi après des décennies de calme apparent. | The old territorial conflict resurfaced after decades of apparent calm. |
| 2548 | barber | barber | Ce documentaire interminable a fini par barber tout le monde. | That endless documentary ended up boring everyone. |
| 2549 | piger | piges | Tu piges enfin pourquoi elle était si fâchée contre toi. | You finally get why she was so angry with you. |
| 2550 | fenêtrer | fenêtré | Les ouvriers ont fenêtré la façade pour laisser entrer plus de lumière. | The workers cut window openings into the façade to let in more light. |
| 2555 | désorienter | désoriente | Le brouillard épais désoriente complètement les randonneurs sur le sentier de montagne. | The thick fog completely disorients the hikers on the mountain trail. |
| 2557 | entrelacer | entrelace | Le jardinier entrelace les branches de vigne autour du treillis en bois. | The gardener interweaves the vine branches around the wooden trellis. |
| 2558 | resituer | resituer | Pour comprendre ce tableau, il faut le resituer dans son contexte historique. | To understand this painting, you have to place it back in its historical context. |
| 2562 | parader | parade | Le jeune champion parade devant la foule après avoir remporté le tournoi. | The young champion struts before the crowd after winning the tournament. |
| 2566 | socialiser | socialisent | Les nouveaux employés socialisent facilement pendant la pause déjeuner. | The new employees socialize easily during the lunch break. |
| 2572 | dévaler | dévalent | Les enfants dévalent la colline en riant aux éclats. | The children rush down the hill, laughing loudly. |
| 2575 | désemparer | désemparé | La tempête a désemparé le navire en pleine mer, brisant son mât principal. | The storm disabled the ship on the open sea, breaking its mainmast. |
| 2579 | poudrer | poudre | La maquilleuse poudre légèrement le visage de l'actrice avant le tournage. | The makeup artist lightly powders the actress's face before filming. |
| 2587 | désamorcer | désamorcent | Les techniciens désamorcent la bombe juste avant qu'elle n'explose. | The technicians defuse the bomb just before it explodes. |
| 2590 | scléroser | sclérosée | Avec le temps, cette administration s'est sclérosée et n'arrive plus à s'adapter. | Over time, this administration became ossified and can no longer adapt. |
| 2591 | rager | rage | Le petit garçon rage parce qu'il a perdu son jouet préféré. | The little boy is raging because he lost his favorite toy. |
| 2599 | débusquer | débusquer | Les policiers ont réussi à débusquer le voleur caché dans la grange. | The police managed to flush out the thief hiding in the barn. |
| 2600 | déchiqueter | déchiqueté | Le chien a déchiqueté le coussin en mille morceaux pendant notre absence. | The dog ripped the cushion to shreds while we were out. |
| 2601 | épépiner | épépine | Elle épépine les raisins avant de préparer la salade de fruits. | She deseeds the grapes before making the fruit salad. |
| 2602 | parachuter | parachuté | Le parti a parachuté un candidat inconnu dans cette circonscription. | The party parachuted an unknown candidate into this constituency. |
| 2608 | assener | assené | Le boxeur a assené un coup violent à son adversaire dès la première reprise. | The boxer landed a violent blow on his opponent in the very first round. |
| 2613 | domestiquer | domestiqué | Les premiers humains ont domestiqué le loup il y a plus de quinze mille ans. | Early humans domesticated the wolf more than fifteen thousand years ago. |
| 2617 | politiser | politiser | Certains journalistes reprochent au maire de politiser un simple débat sur l'urbanisme. | Some journalists accuse the mayor of politicizing a simple debate about urban planning. |
| 2618 | affairer | s'affairaient | Les serveurs s'affairaient dans la cuisine avant l'arrivée des premiers clients. | The waiters were busying themselves in the kitchen before the first guests arrived. |
| 2620 | layer | layé | Les forestiers ont layé un sentier pour faciliter l'accès à la parcelle. | The foresters cut a path through the forest to make the plot easier to reach. |
| 2621 | viabiliser | viabiliser | La commune a décidé de viabiliser plusieurs parcelles avant de les vendre aux particuliers. | The town decided to install utilities on several plots before selling them to individuals. |
| 2622 | désengager | désengager | Le gouvernement a décidé de désengager ses troupes de la région après l'accord de paix. | The government decided to withdraw its troops from the region after the peace agreement. |
| 2632 | lamer | lamer | Le mécanicien doit lamer soigneusement la surface avant de fixer le boulon. | The mechanic must carefully face off the surface before fastening the bolt. |
| 2636 | jardiner | jardiner | Le dimanche, elle aime jardiner tranquillement dans sa petite cour derrière la maison. | On Sundays, she likes to garden quietly in the small yard behind the house. |
| 2645 | dépoussiérer | dépoussiérer | Le samedi matin, elle aime dépoussiérer les étagères de la bibliothèque. | On Saturday mornings, she likes to dust the bookshelves. |
| 2646 | saillir (mate) | saillir | Le fermier laisse le taureau saillir la vache chaque printemps pour renouveler le troupeau. | The farmer lets the bull service the cow each spring to renew the herd. |
| 2649 | décontracter | décontracter | Après une longue journée de travail, il aime décontracter ses muscles avec un bain chaud. | After a long day at work, he likes to relax his muscles with a hot bath. |
| 2653 | métrer | métrer | L'architecte doit métrer soigneusement le terrain avant de dessiner les plans. | The architect must carefully survey the land before drawing up the plans. |
| 2654 | pailler | pailler | Au printemps, le jardinier aime pailler les massifs de fleurs pour limiter les mauvaises herbes. | In spring, the gardener likes to mulch the flower beds with straw to keep weeds down. |
| 2659 | prépayer | prépayé | Elle a prépayé son forfait mobile pour tout le mois. | She prepaid her mobile plan for the whole month. |
| 2662 | requalifier | requalifié | Le tribunal a requalifié les faits en abus de confiance. | The court reclassified the facts as breach of trust. |
| 2663 | réessayer | réessayez | Si la page ne charge pas, réessayez dans quelques minutes. | If the page doesn't load, try again in a few minutes. |
| 2666 | goudronner | goudronner | Les ouvriers vont goudronner la route cet été. | The workers are going to tar the road this summer. |
| 2668 | jauger | jaugé | Le douanier a jaugé le tonneau avant de l'expédier. | The customs officer gauged the barrel before shipping it. |
| 2669 | autoproclamer | autoproclamé | Il s'est autoproclamé champion du monde sans disputer aucun match. | He self-proclaimed himself world champion without playing a single match. |
| 2672 | désinstaller | désinstallé | Il a désinstallé le logiciel après l'avoir testé. | He uninstalled the software after testing it. |
| 2684 | prédéterminer | prédéterminent | Les gènes prédéterminent en partie notre risque de maladie. | Genes partly predetermine our risk of disease. |
| 2685 | remorquer | remorquer | Le camion a dû remorquer la voiture en panne jusqu'au garage. | The truck had to tow the broken-down car to the garage. |
| 2691 | coacher | coache | Elle coache des cadres d'entreprise depuis dix ans. | She has been coaching corporate executives for ten years. |
| 2693 | robotiser | robotisé | L'usine a robotisé toute sa chaîne de production pour réduire les coûts. | The factory automated its entire production line to cut costs. |
| 2694 | réprouver | réprouvé | Le tribunal a réprouvé fermement cette pratique injuste envers les employés. | The court firmly condemned this unfair practice toward employees. |
| 2698 | emmêler | emmêlé | Le vent a emmêlé ses cheveux longs pendant la promenade sur la plage. | The wind tangled her long hair during the walk on the beach. |
| 2699 | démobiliser | démobilisé | L'armée a démobilisé plusieurs milliers de soldats après la fin du conflit. | The army demobilized several thousand soldiers after the end of the conflict. |
| 2700 | diaboliser | diaboliser | Les médias ont tendance à diaboliser certains groupes sociaux sans nuance. | The media tend to demonize certain social groups without nuance. |
| 2712 | homogénéiser | homogénéise | Le fabricant homogénéise le lait pour empêcher la crème de remonter à la surface. | The manufacturer homogenizes the milk to keep the cream from rising to the top. |
| 2714 | quadriller | quadrillé | Le jardinier a quadrillé le terrain en carrés égaux avant d'y planter les légumes. | The gardener marked the plot into a grid of equal squares before planting the vegetables. |
| 2715 | terrifier | terrifié | Le film d'horreur a terrifié les enfants qui n'ont pas pu dormir cette nuit-là. | The horror movie terrified the children, who couldn't sleep that night. |
| 2719 | surligner | surligné | Elle a surligné les mots importants dans son manuel avant l'examen. | She highlighted the important words in her textbook before the exam. |
| 2720 | gerber | gerbent | Les ouvriers gerbent les palettes de marchandises jusqu'au plafond de l'entrepôt. | The workers stack the pallets of goods up to the ceiling of the warehouse. |
| 2725 | cadencer | cadençait | Le sergent cadençait les pas des recrues pendant l'entraînement matinal. | The sergeant kept the recruits marching in step during the morning drill. |
| 2731 | saboter | saboter | Les ouvriers ont décidé de saboter la machine pour protester contre leurs conditions de travail. | The workers decided to sabotage the machine to protest their working conditions. |
| 2732 | ravitailler | ravitailler | Chaque semaine, le camion vient ravitailler le village isolé en vivres et en médicaments. | Every week, the truck comes to resupply the isolated village with food and medicine. |
| 2734 | encarter | encarter | Le magazine a décidé d'encarter un échantillon de parfum dans son numéro de printemps. | The magazine decided to insert a perfume sample in its spring issue. |
| 2738 | chaîner | chaîné | L'arpenteur a chaîné le champ avant de dresser le plan cadastral. | The surveyor chained the field before drawing up the cadastral map. |
| 2739 | langer | langeait | Chaque matin, la jeune maman langeait son bébé avant de le nourrir. | Every morning, the young mother changed her baby's diaper before feeding him. |
| 2740 | déclasser | déclassé | L'arbitre a déclassé le coureur pour avoir triché pendant la course. | The referee demoted the runner for cheating during the race. |
| 2751 | instrumenter | instrumenté | Le notaire a instrumenté l'acte de vente devant les deux parties. | The notary drew up the deed of sale in front of both parties. |
| 2764 | métalliser | métallisent | Les usines métallisent les pièces en plastique pour leur donner un aspect métallique. | Factories metallize plastic parts to give them a metallic look. |
| 2765 | spolier | spolié | Les colons ont spolié les paysans de leurs terres ancestrales. | The settlers despoiled the peasants of their ancestral lands. |
| 2766 | désintégrer | désintégrer | Le rayon laser peut désintégrer n'importe quel matériau en quelques secondes. | The laser beam can disintegrate any material within seconds. |
| 2772 | coproduire | coproduire | Les deux studios ont décidé de coproduire ce film à gros budget. | The two studios decided to co-produce this big-budget film. |
| 2776 | transplanter | transplanter | Les chirurgiens ont réussi à transplanter un rein sain chez le patient. | The surgeons successfully transplanted a healthy kidney into the patient. |
| 2777 | boxer | boxer | Mon frère aime boxer tous les samedis matin au club de sport. | My brother likes to box every Saturday morning at the gym. |
| 2783 | auréoler | auréolé | Son succès aux Jeux olympiques l'a auréolé de gloire dans tout le pays. | His Olympic success crowned him with glory throughout the country. |
| 2785 | évider | évide | Le sculpteur évide le bloc de bois pour créer un bol léger. | The sculptor hollows out the block of wood to make a light bowl. |
| 2786 | polémiquer | polémiquent | Les deux hommes politiques polémiquent sans cesse à la télévision sur ce sujet sensible. | The two politicians constantly argue polemically on television about this sensitive topic. |
| 2787 | précariser | précariser | La nouvelle réforme du travail risque de précariser des milliers d'employés. | The new labor reform risks putting thousands of employees into precarious situations. |
| 2794 | ioniser | ioniser | Le rayonnement cosmique peut ioniser les molécules de l'atmosphère terrestre. | Cosmic radiation can ionize molecules in Earth's atmosphere. |
| 2795 | prédestiner | prédestinait | Ses parents pensaient que son talent musical le prédestinait à devenir chef d'orchestre. | His parents thought his musical talent destined him to become a conductor. |
| 2800 | paraphraser | paraphraser | Elle préfère paraphraser les propos du ministre plutôt que de les citer mot pour mot. | She prefers to paraphrase the minister's remarks rather than quote them word for word. |
| 2803 | anesthésier | anesthésier | Le médecin a dû anesthésier le patient avant l'opération. | The doctor had to anesthetize the patient before the operation. |
| 2806 | radicaliser | radicaliser | Les réseaux sociaux peuvent radicaliser rapidement de jeunes internautes isolés. | Social media can quickly radicalize young, isolated internet users. |
| 2812 | blinder | blindé | Les soldats ont blindé le véhicule pour résister aux attaques ennemies. | The soldiers armored the vehicle to withstand enemy attacks. |
| 2813 | défiscaliser | défiscaliser | De nombreux investisseurs cherchent à défiscaliser leurs revenus en achetant des œuvres d'art. | Many investors try to reduce their taxes by buying works of art. |
| 2816 | sous-payer | sous-payer | L'entreprise a été accusée de sous-payer ses employés pendant des années. | The company was accused of underpaying its employees for years. |
| 2819 | plastiquer | plastiqué | Des militants ont plastiqué le bâtiment administratif pendant la nuit. | Activists bombed the administrative building overnight with plastic explosives. |
| 2827 | colmater | colmaté | Les ouvriers ont colmaté la fuite d'eau avant qu'elle n'inonde la cave. | The workers plugged the water leak before it flooded the basement. |
| 2828 | décloisonner | décloisonner | La réforme vise à décloisonner les services administratifs pour mieux collaborer. | The reform aims to break down barriers between administrative departments so they can collaborate better. |
| 2834 | caver | cavent | Les mineurs cavent la roche pendant des heures pour trouver du minerai. | The miners dig into the rock for hours to find ore. |
| 2835 | nacrer | nacre | Le vernis nacre les boutons de la robe de mariée. | The varnish gives the wedding dress's buttons the sheen of mother-of-pearl. |
| 2836 | malaxer | malaxe | Le boulanger malaxe la pâte avant de la laisser reposer. | The baker kneads the dough before letting it rest. |
| 2838 | dénoyauter | dénoyauter | Il faut dénoyauter les cerises avant de préparer la confiture. | You need to pit the cherries before making the jam. |
| 2839 | cendrer | cendre | La fumée cendre peu à peu les murs de la vieille cheminée. | The smoke is gradually turning the walls of the old fireplace ash-gray. |
| 2840 | disserter | disserter | Le professeur a demandé aux élèves de disserter sur les causes de la Révolution. | The teacher asked the students to write an essay on the causes of the Revolution. |
| 2842 | dérégler | dérègle | Le décalage horaire dérègle complètement mon sommeil pendant plusieurs jours. | Jet lag completely disrupts my sleep for several days. |
| 2843 | présélectionner | présélectionné | Le jury a présélectionné dix candidats pour l'entretien final. | The panel shortlisted ten candidates for the final interview. |
| 2844 | plastifier | plastifie | La bibliothécaire plastifie la couverture des livres pour les protéger. | The librarian laminates the covers of the books to protect them. |
| 2846 | séquencer | séquencé | Les chercheurs ont séquencé le génome complet du virus en quelques heures. | The researchers sequenced the virus's entire genome within a few hours. |
| 2847 | rober | robe | L'ouvrier robe soigneusement chaque cigare avant de le rouler. | The worker carefully wraps each cigar in its tobacco leaf before rolling it. |
| 2848 | commuter | commuter | Le technicien peut commuter le signal entre les deux circuits en quelques secondes. | The technician can switch the signal between the two circuits in a few seconds. |
| 2850 | virevolter | virevoltent | Les danseuses virevoltent gracieusement sur la scène pendant tout le spectacle. | The dancers twirl gracefully on stage throughout the show. |
| 2853 | accoupler | accouple | Le fermier accouple les deux chevaux pour les faire travailler ensemble. | The farmer pairs the two horses so they can work together. |
| 2859 | surfacer | surface | Le menuisier surface la planche avant de l'assembler. | The carpenter planes the board smooth before assembling it. |
| 2863 | immuniser | immuniser | Le vaccin permet d'immuniser les enfants contre plusieurs maladies graves. | The vaccine makes it possible to immunize children against several serious diseases. |
| 2865 | civiliser | civiliser | Les missionnaires prétendaient civiliser les peuples qu'ils rencontraient. | The missionaries claimed to civilize the peoples they encountered. |
| 2866 | échantillonner | échantillonnent | Les techniciens échantillonnent l'eau de la rivière chaque mois pour vérifier sa qualité. | The technicians sample the river water every month to check its quality. |
| 2867 | ceinturer | ceinture | Elle ceinture fermement son manteau avant d'affronter le vent glacial. | She belts her coat tightly before facing the icy wind. |
| 2870 | saccader | saccade | Le train saccade violemment les passagers à chaque freinage brusque. | The train jolts the passengers violently with every abrupt braking. |
| 2872 | édulcorer | édulcoré | Le rédacteur a édulcoré le rapport pour ne pas effrayer les actionnaires. | The editor toned down the report so as not to alarm the shareholders. |
| 2875 | uriner | uriner | Le patient doit uriner dans ce flacon avant l'examen médical. | The patient must urinate into this container before the medical exam. |
| 2877 | aciduler | acidule | Le chef acidule la sauce avec un filet de jus de citron. | The chef acidulates the sauce with a dash of lemon juice. |
| 2878 | sonoriser | sonorise | Le technicien sonorise la salle avant le concert de ce soir. | The technician is setting up the sound system in the hall before tonight's concert. |
| 2884 | goutter | goutte | L'eau goutte lentement du robinet mal fermé pendant toute la nuit. | Water drips slowly from the poorly closed faucet all night long. |
| 2888 | destituer | destituer | Le conseil a voté pour destituer le président après le scandale financier. | The board voted to depose the president after the financial scandal. |
| 2890 | panacher | panache | Le fleuriste aime panacher les couleurs pour rendre chaque bouquet plus vivant. | The florist likes to mix colors to make each bouquet more vibrant. |
| 2896 | replanter | replantent | Les bénévoles replantent des arbres dans la forêt ravagée par l'incendie. | The volunteers are replanting trees in the forest ravaged by the fire. |
| 2902 | redorer | redore | Le doreur redore le cadre du tableau avant l'exposition. | The gilder regilds the picture frame before the exhibition. |
| 2904 | tapoter | tapote | Elle tapote l'écran de son téléphone en attendant le bus. | She taps her phone screen while waiting for the bus. |
| 2906 | singulariser | singularise | Son accent particulier le singularise parmi ses collègues. | His distinctive accent sets him apart from his colleagues. |
| 2916 | internationaliser | internationaliser | Le gouvernement souhaite internationaliser sa monnaie pour renforcer son influence économique. | The government wants to internationalize its currency to strengthen its economic influence. |
| 2921 | émousser | émousser | Le temps a fini par émousser sa colère contre son frère. | Time eventually dulled his anger toward his brother. |
| 2924 | flinguer | flingué | Le gangster a flingué son rival en pleine rue. | The gangster gunned down his rival in the middle of the street. |
| 2927 | aseptiser | aseptise | L'infirmière aseptise la plaie avant de poser le pansement. | The nurse disinfects the wound before applying the bandage. |
| 2928 | endeuiller | endeuille | Le décès du président endeuille tout le pays. | The president's death plunges the whole country into mourning. |
| 2930 | étalonner | étalonne | Le technicien étalonne l'appareil de mesure chaque matin avant utilisation. | The technician calibrates the measuring device every morning before use. |
| 2933 | désaffecter | désaffecter | La mairie a décidé de désaffecter l'ancienne caserne pour la transformer en musée. | The town council decided to decommission the old barracks in order to turn it into a museum. |
| 2934 | buller | buller | Le vernis frais commence à buller sous l'effet de la chaleur. | The fresh varnish is starting to bubble because of the heat. |
| 2936 | dédouaner | dédouaner | Le camionneur doit dédouaner sa marchandise avant de traverser la frontière. | The truck driver must clear his goods through customs before crossing the border. |
| 2939 | horrifier | horrifient | Ses mensonges horrifient toute la famille depuis des années. | His lies have been horrifying the whole family for years. |
| 2941 | boulonner | boulonne | Il boulonne dur toute la semaine pour finir le projet à temps. | He's working hard all week to finish the project on time. |
| 2946 | tonifier | tonifie | Cette crème tonifie la peau et lui donne un aspect éclatant. | This cream tones the skin and gives it a radiant look. |
| 2947 | démoder | démode | Ce style de veste ne se démode jamais, il reste toujours élégant. | This style of jacket never goes out of fashion; it always stays elegant. |
| 2949 | solutionner | solutionner | Les ingénieurs ont réussi à solutionner le problème technique en une journée. | The engineers managed to solve the technical problem in a single day. |
| 2954 | conceptualiser | conceptualiser | Les chercheurs ont mis des années à conceptualiser cette nouvelle théorie économique. | It took the researchers years to conceptualize this new economic theory. |
| 2957 | arnaquer | arnaqué | Ce vendeur malhonnête a arnaqué plusieurs clients avec de fausses promesses. | This dishonest salesman swindled several customers with false promises. |
| 2960 | temporiser | temporiser | Le gouvernement a préféré temporiser plutôt que de prendre une décision immédiate. | The government chose to stall rather than make an immediate decision. |
| 2961 | fauter | fauté | Le jeune stagiaire a fauté en oubliant d'envoyer le rapport à temps. | The young intern messed up by forgetting to send the report on time. |
| 2963 | réer | rée | Chaque automne, le cerf rée dans la forêt pour attirer les femelles. | Each autumn, the stag roars in the forest to attract the does. |
| 2964 | saliver | saliver | Le chien se met à saliver dès qu'il sent l'odeur de la viande. | The dog starts to salivate as soon as it smells the meat. |
| 2965 | exorciser | exorciser | Le prêtre a été appelé pour exorciser la vieille maison hantée. | The priest was called in to exorcise the old haunted house. |
| 2966 | marner | marne | Elle marne dur toute la semaine pour finir ses études. | She's slogging away hard all week to finish her studies. |
| 2969 | extérioriser | extérioriser | Elle a du mal à extérioriser ses émotions devant les autres. | She has trouble expressing her emotions in front of others. |
| 2971 | enculer | enculer | Ce vendeur véreux a essayé de nous enculer sur le prix de la voiture. | That crooked dealer tried to screw us over on the price of the car. |
| 2973 | piper | pipé | Le tricheur avait pipé les dés pour gagner à chaque partie. | The cheat had loaded the dice to win every game. |
| 2977 | chronométrer | chronomètre | Le coach chronomètre chaque coureur pendant l'entraînement du matin. | The coach times each runner during the morning training session. |
| 2980 | fouiner | fouiner | Le journaliste aimait fouiner dans les archives pour trouver des informations exclusives. | The journalist liked to snoop around in the archives to find exclusive information. |
| 2982 | désolidariser | désolidariser | Le maire a tenté de désolidariser sa commune du projet contesté. | The mayor tried to dissociate his town from the disputed project. |
| 2986 | sidérer | sidéré | La nouvelle de sa démission soudaine a sidéré toute l'équipe. | The news of his sudden resignation dumbfounded the whole team. |
| 2989 | blaguer | blaguer | Il aime blaguer avec ses collègues pendant la pause déjeuner. | He likes to joke around with his colleagues during lunch break. |
| 2990 | déglacer | déglacer | Le chauffeur a dû déglacer le pare-brise avant de démarrer sa voiture par ce matin glacial. | The driver had to de-ice the windshield before starting his car on this freezing morning. |
| 2995 | monnayer | monnayer | Certains influenceurs parviennent à monnayer leur notoriété en signant des contrats publicitaires. | Some influencers manage to cash in on their fame by signing advertising deals. |
| 2997 | entailler | entaillé | Le menuisier a entaillé la planche pour y insérer une charnière. | The carpenter cut a notch into the board to fit a hinge. |
| 2998 | pauser | pauser | Après deux heures de marche, les randonneurs ont décidé de pauser près de la rivière. | After two hours of walking, the hikers decided to take a break near the river. |
| 2999 | survolter | survolté | Le technicien a survolté la batterie pour redémarrer le vieux camion. | The technician boosted the battery to restart the old truck. |
| 3001 | déstructurer | déstructurer | Les architectes ont voulu déstructurer les codes traditionnels du salon d'exposition. | The architects wanted to deconstruct the traditional conventions of the exhibition hall. |
| 3003 | soufrer | soufre | Le vigneron soufre ses vignes chaque printemps pour prévenir l'oïdium. | The winegrower dusts his vines with sulfur every spring to prevent powdery mildew. |
| 3009 | gratiner | gratiner | Elle fait gratiner le gratin dauphinois au four pendant dix minutes. | She lets the dauphinoise gratin brown in the oven for ten minutes. |
| 3012 | malter | malte | Le brasseur malte l'orge pendant plusieurs jours avant de la brasser. | The brewer malts the barley for several days before brewing it. |
| 3013 | plagier | plagié | L'étudiant a plagié un article entier sans citer ses sources. | The student plagiarized an entire article without citing his sources. |
| 3015 | sous-traiter | sous-traite | L'entreprise sous-traite la fabrication des pièces à une usine polonaise. | The company subcontracts the manufacture of the parts to a Polish factory. |
| 3016 | fourvoyer | fourvoyé | Le guide inexpérimenté a fourvoyé les touristes dans la forêt obscure. | The inexperienced guide misled the tourists into the dark forest. |
| 3018 | recaler | recalé | Le jury a recalé le candidat à l'oral parce qu'il n'avait pas révisé. | The examining board failed the candidate on the oral exam because he hadn't studied. |
| 3019 | tabasser | tabassé | Deux hommes ont tabassé le vigile devant le bar hier soir. | Two men beat up the bouncer outside the bar last night. |
| 3020 | minuter | minute | L'entraîneur minute chaque exercice pour respecter le programme d'entraînement. | The coach times each exercise to keep to the training schedule. |
| 3021 | réinterpréter | réinterprété | Le nouveau directeur artistique a réinterprété la pièce classique de façon moderne. | The new artistic director reinterpreted the classic play in a modern way. |
| 3022 | auditer | audite | Le cabinet comptable audite les finances de l'entreprise chaque année. | The accounting firm audits the company's finances every year. |
| 3027 | torsader | torsade | Elle torsade ses cheveux avant de les attacher en chignon. | She twists her hair before pinning it into a bun. |
| 3029 | positiver | positiver | Après cet échec, elle a essayé de positiver et d'en tirer une leçon. | After that setback, she tried to stay positive and learn a lesson from it. |
| 3030 | désenchanter | désenchanter | Ce voyage décevant a fini par désenchanter les touristes les plus enthousiastes. | This disappointing trip ended up disenchanting even the most enthusiastic tourists. |
| 3033 | réunifier | réunifier | Le traité a permis de réunifier les deux provinces après des décennies de division. | The treaty made it possible to reunify the two provinces after decades of division. |
| 3036 | décoiffer | décoiffé | Le vent a décoiffé tous les passants sur le pont ce matin. | The wind messed up all the passersby's hair on the bridge this morning. |
| 3040 | intoxiquer | intoxiquer | Les vapeurs d'essence ont fini par intoxiquer les ouvriers dans le garage mal ventilé. | The gasoline fumes ended up poisoning the workers in the poorly ventilated garage. |
| 3041 | composter | composter | N'oubliez pas de composter votre billet avant de monter dans le train. | Don't forget to stamp your ticket before boarding the train. |
| 3052 | scénariser | scénarisé | Elle a scénarisé son premier long métrage avant même d'avoir vingt-cinq ans. | She wrote the screenplay for her first feature film before she was even twenty-five. |
| 3054 | décrédibiliser | décrédibiliser | Ces accusations infondées visent surtout à décrédibiliser le témoin principal du procès. | These baseless accusations are mainly aimed at discrediting the trial's key witness. |
| 3057 | dérailler | déraillé | Le train a déraillé après avoir heurté un arbre tombé sur la voie. | The train derailed after hitting a tree that had fallen on the tracks. |
| 3074 | sacraliser | sacraliser | Certains fans en sont venus à sacraliser leur chanteur préféré, comme s'il était un dieu vivant. | Some fans have gone so far as to make their favorite singer sacred, as if he were a living god. |
| 3078 | épiler | épile | L'esthéticienne épile les sourcils de sa cliente avec de la cire. | The beautician waxes her client's eyebrows. |
| 3079 | resservir | resservit | Il resservit du café à tous ses invités après le dessert. | He served coffee again to all his guests after dessert. |
| 3080 | déboussoler | déboussolé | Ce nouveau plan de la ville l'a complètement déboussolé. | This new city map completely disoriented him. |
| 3082 | galvauder | galvauder | Il ne faut pas galvauder ses talents en travaillant pour des projets sans intérêt. | You shouldn't squander your talents working on uninteresting projects. |
| 3083 | jucher | juche | Le coq juche sur la clôture chaque soir avant de dormir. | The rooster perches on the fence every evening before sleeping. |
| 3088 | dramatiser | dramatiser | Le journaliste a tendance à dramatiser chaque incident mineur. | The journalist tends to dramatize every minor incident. |
| 3090 | droguer | se droguent | Certains adolescents se droguent par curiosité ou à cause de la pression de leurs amis. | Some teenagers take drugs out of curiosity or because of peer pressure. |
| 3095 | diéser | diéser | Le professeur de musique demande à l'élève de diéser la note pour former l'accord correct. | The music teacher asks the student to sharpen the note to form the correct chord. |
| 3097 | assoiffer | assoiffés | La longue randonnée sous le soleil les a tous assoiffés. | The long hike under the sun made them all thirsty. |
| 3098 | apeurer | apeuré | Le bruit soudain dans le grenier a apeuré les enfants. | The sudden noise in the attic frightened the children. |
| 3099 | miniaturiser | miniaturiser | Les ingénieurs ont réussi à miniaturiser le moteur pour le nouveau drone. | The engineers managed to miniaturize the engine for the new drone. |
| 3100 | télécommander | télécommande | Il télécommande son drone depuis son téléphone portable. | He remote-controls his drone from his mobile phone. |
| 3101 | dévaluer | dévaluer | Le gouvernement a décidé de dévaluer la monnaie nationale pour stimuler les exportations. | The government decided to devalue the national currency to boost exports. |
| 3103 | gribouiller | gribouille | L'enfant gribouille des dessins sur toutes les pages de son cahier. | The child scribbles drawings on every page of his notebook. |
| 3106 | excentrer | excentrer | Le technicien a dû excentrer légèrement la roue pour corriger le déséquilibre. | The technician had to offset the wheel slightly to correct the imbalance. |
| 3112 | coulisser | coulisse | La porte coulisse doucement sur son rail avant de se fermer. | The door slides smoothly along its track before closing. |
| 3124 | câliner | câliner | Elle aime câliner son chat avant de s'endormir le soir. | She loves cuddling her cat before falling asleep at night. |
| 3125 | bétonner | bétonné | Les ouvriers ont bétonné la cour de l'école avant l'hiver. | The workers concreted over the schoolyard before winter. |
| 3129 | contresigner | contresigner | Le ministre doit contresigner ce décret pour qu'il devienne valide. | The minister must countersign this decree for it to become valid. |
| 3132 | connoter | connote | Ce mot connote une certaine tristesse dans ce contexte précis. | This word connotes a certain sadness in this particular context. |
| 3134 | décaper | décaper | Il faut décaper la vieille rambarde en fer avant de la repeindre. | You need to strip the old iron railing before repainting it. |
| 3141 | tuteurer | tuteurer | Il faut tuteurer les jeunes plants de tomates pour qu'ils poussent bien droits. | You need to stake the young tomato plants so they grow up straight. |
| 3142 | enherber | enherber | Les vignerons ont décidé d'enherber les rangs de vigne pour limiter l'érosion. | The winegrowers decided to sow grass between the vine rows to limit erosion. |
| 3144 | désister | désister | Le candidat a décidé de se désister avant le second tour. | The candidate decided to withdraw before the runoff. |
| 3145 | lainer | lainait | L'ouvrier lainait le tissu pour lui donner un aspect plus doux. | The worker was teaseling the cloth to give it a softer finish. |
| 3148 | tétaniser | tétanisé | Le choc électrique a tétanisé les muscles de sa jambe en un instant. | The electric shock tetanized the muscles in his leg instantly. |
| 3150 | effiler | effile | Le coiffeur effile les pointes des cheveux pour un rendu plus naturel. | The hairdresser thins the hair ends for a more natural look. |
| 3151 | haler | halent | Les mariniers halent la péniche le long du canal à l'aide d'un cordage. | The bargemen haul the barge along the canal with a rope. |
| 3159 | tergiverser | tergiversé | Le ministre a tergiversé pendant des heures avant de répondre à la question. | The minister equivocated for hours before answering the question. |
| 3163 | réincarner | se réincarne | Selon cette croyance, l'âme se réincarne dans un nouveau corps après la mort. | According to this belief, the soul is reincarnated in a new body after death. |
| 3165 | feuiller | feuiller | Les arbres commencent à feuiller dès les premiers jours du printemps. | The trees begin to come into leaf in the first days of spring. |
| 3166 | encapsuler | encapsulé | Le programmeur a encapsulé les données dans un objet unique. | The programmer encapsulated the data in a single object. |
| 3171 | givrer | givré | Le froid a givré les vitres pendant la nuit. | The cold frosted the windows overnight. |
| 3174 | cogiter | cogité | Il a cogité pendant des heures avant de prendre sa décision. | He mulled it over for hours before making his decision. |
| 3177 | butiner | butinent | Les abeilles butinent les fleurs du jardin tout l'été. | The bees gather pollen from the garden flowers all summer. |
| 3178 | intimer | intimé | Le juge a intimé à l'accusé de se taire. | The judge ordered the defendant to be silent. |
| 3186 | roter | roté | Le bébé a roté bruyamment après son biberon. | The baby burped loudly after its bottle. |
| 3192 | tarifer | tarife | Le boulanger tarife son pain en fonction du prix de la farine. | The baker sets the price of his bread according to the price of flour. |
| 3193 | nover | nover | Les deux banques ont convenu de nover le contrat de prêt initial en l'assortissant de nouvelles clauses. | The two banks agreed to novate the original loan agreement by adding new terms to it. |
| 3195 | tanner | tanne | Le tanneur tanne les peaux de vache avec de l'écorce de chêne. | The tanner tans cowhides with oak bark. |
| 3196 | insonoriser | insonoriser | Nous avons dû insonoriser le studio pour éviter de déranger les voisins. | We had to soundproof the studio to avoid disturbing the neighbors. |
| 3197 | franciser | franciser | Les Québécois ont tendance à franciser certains mots empruntés à l'anglais. | Quebecers tend to Frenchify certain words borrowed from English. |
| 3199 | câbler | câbler | L'électricien va câbler toute la maison avant l'installation des appareils. | The electrician is going to wire the whole house before the appliances are installed. |
| 3202 | mitrailler | mitraillé | Les soldats ont mitraillé la position ennemie avant l'assaut. | The soldiers machine-gunned the enemy position before the assault. |
| 3211 | doler | dole | Le charpentier dole la poutre pour lui donner une surface bien lisse. | The carpenter planes the beam to give it a nice smooth surface. |
| 3212 | tarer | tarer | L'humidité excessive a fini par tarer une partie de la cargaison de céréales. | Excessive humidity ended up spoiling part of the grain cargo. |
| 3213 | moitir | moitissait | La sueur moitissait le front du coureur après le marathon. | Sweat dampened the runner's forehead after the marathon. |
| 3214 | déshumaniser | déshumaniser | La guerre finit souvent par déshumaniser ceux qui y participent. | War often ends up dehumanizing those who take part in it. |
| 3215 | baguer | bague | L'ornithologue bague les oiseaux migrateurs pour suivre leurs déplacements. | The ornithologist bands migratory birds to track their movements. |
| 3217 | frimer | frimer | Il aime frimer devant ses copains avec sa nouvelle voiture. | He likes to show off in front of his friends with his new car. |
| 3219 | reboucher | reboucher | J'ai dû reboucher le trou dans le mur avant de repeindre la chambre. | I had to fill in the hole in the wall before repainting the room. |
| 3223 | annualiser | annualiser | Pour comparer les résultats, il faut annualiser le rendement du premier trimestre. | To compare the results, you need to annualize the first quarter's return. |
| 3224 | exulter | exulté | Les supporters ont exulté quand leur équipe a marqué le but de la victoire. | The fans exulted when their team scored the winning goal. |
| 3232 | dynamiter | dynamité | Les ouvriers ont dynamité la falaise pour construire la nouvelle route. | The workers dynamited the cliff to build the new road. |
| 3234 | béatifier | béatifié | Le pape a béatifié ce prêtre pour sa vie exemplaire de charité. | The pope beatified this priest for his exemplary life of charity. |
| 3237 | obnubiler | obnubilé | Depuis son voyage, il est obnubilé par l'idée de retourner au Japon. | Ever since his trip, he's been obsessed with the idea of going back to Japan. |
| 3238 | retordre | retordre | L'ouvrière doit retordre le fil avant de le tisser. | The worker has to re-twist the thread before weaving it. |
| 3239 | rembourrer | rembourré | Le tapissier a rembourré le canapé avec de la mousse neuve. | The upholsterer stuffed the sofa with new foam. |
| 3243 | romancer | romancé | L'auteur a romancé la vie du général pour en faire un best-seller. | The author fictionalized the general's life to turn it into a bestseller. |
| 3247 | réinjecter | réinjecter | Le gouvernement va réinjecter des fonds dans le système de santé. | The government is going to reinject funds into the healthcare system. |
| 3248 | provisionner | provisionner | L'entreprise doit provisionner des sommes pour couvrir ses litiges en cours. | The company must set aside funds to cover its ongoing lawsuits. |
| 3250 | mouliner | mouliné | Le boucher a mouliné la viande pour préparer des steaks hachés. | The butcher ground the meat to make hamburger patties. |
| 3251 | lésiner | lésiner | Il ne faut pas lésiner sur la qualité des ingrédients pour ce gâteau. | You shouldn't skimp on the quality of the ingredients for this cake. |
| 3252 | introniser | intronisera | On intronisera le nouveau roi lors d'une cérémonie solennelle à la cathédrale. | The new king will be enthroned during a solemn ceremony at the cathedral. |
| 3255 | customiser | customisé | Elle a customisé son vélo en ajoutant des autocollants colorés et un panier en osier. | She customized her bike by adding colorful stickers and a wicker basket. |
| 3258 | inciser | inciser | Le chirurgien doit inciser la peau avec précision avant de retirer la tumeur. | The surgeon must incise the skin precisely before removing the tumor. |
| 3261 | surclasser | surclasse | Cette nouvelle voiture électrique surclasse tous ses concurrents en autonomie et en confort. | This new electric car outclasses all its competitors in range and comfort. |
| 3265 | réanimer | réanimer | Les infirmiers ont réussi à réanimer le patient après un arrêt cardiaque. | The paramedics managed to revive the patient after a cardiac arrest. |
| 3274 | enchérir | enchéri | Au cours de la vente aux enchères, il a enchéri plusieurs fois pour remporter le tableau. | During the auction, he bid several times to win the painting. |
| 3278 | déliter | déliter | Après des années d'humidité, le mur en pierre a fini par se déliter complètement. | After years of dampness, the stone wall eventually crumbled apart completely. |
| 3279 | architecturer | architecturer | L'équipe a dû architecturer entièrement le système avant son lancement. | The team had to architect the entire system before its launch. |
| 3280 | placarder | placardé | Les étudiants ont placardé des affiches dans tout le campus pour annoncer le concert. | The students put up posters all over campus to announce the concert. |
| 3284 | complexer | complexée | Son accent l'a longtemps complexée, mais elle a fini par l'assumer avec fierté. | Her accent gave her a complex for a long time, but she eventually learned to embrace it with pride. |
| 3287 | chapeauter | chapeauter | Le nouveau directeur va chapeauter les trois départements de l'entreprise. | The new director will oversee the company's three departments. |
| 3290 | déconsidérer | déconsidérer | Ce scandale risque de déconsidérer toute l'entreprise auprès du public. | This scandal could discredit the whole company in the eyes of the public. |
| 3291 | uploader | uploade | Il uploade ses vidéos sur la plateforme chaque semaine. | He uploads his videos to the platform every week. |
| 3295 | décongeler | décongèle | Elle décongèle le poulet avant de préparer le dîner. | She thaws the chicken before making dinner. |
| 3296 | écailler | écaille | Le poissonnier écaille les poissons avant de les vendre. | The fishmonger scales the fish before selling them. |
| 3297 | flouer | floué | Le vendeur a floué plusieurs clients en leur vendant de fausses antiquités. | The seller conned several customers by selling them fake antiques. |
| 3299 | cuivrer | cuivre | L'artisan cuivre soigneusement la surface du bijou pour lui donner un reflet doré. | The craftsman carefully coats the piece of jewelry's surface with copper to give it a golden sheen. |
| 3300 | sous-évaluer | sous-évalué | Les analystes ont sous-évalué l'impact de la nouvelle réglementation sur le marché. | The analysts underestimated the new regulation's impact on the market. |
| 3301 | torpiller | torpillé | Le sénateur a torpillé le projet de loi à la dernière minute. | The senator torpedoed the bill at the last minute. |
| 3305 | retenter | retenter | Après cet échec, elle a décidé de retenter sa chance l'année suivante. | After that failure, she decided to try her luck again the following year. |
| 3306 | coéditer | coédité | Les deux professeurs ont coédité un manuel de grammaire française. | The two professors co-edited a French grammar textbook. |
| 3307 | crédibiliser | crédibilisent | Ces nouvelles preuves crédibilisent la version des faits présentée par le témoin. | This new evidence lends credibility to the witness's account. |
| 3308 | permanenter | permanenté | La coiffeuse a permanenté les cheveux de sa cliente pour lui donner du volume. | The hairdresser permed her client's hair to give it more volume. |
| 3310 | gainer | gaine | Le fabricant gaine les câbles électriques pour les protéger de l'humidité. | The manufacturer sheathes the electrical cables to protect them from moisture. |
| 3311 | copiner | copiner | Les deux nouveaux élèves ont vite commencé à copiner ensemble. | The two new students quickly started becoming friends. |
| 3312 | coopter | coopté | Le conseil d'administration a coopté un nouveau membre expert en finance. | The board of directors co-opted a new member who is a finance expert. |
| 3314 | dépolluer | dépolluer | L'entreprise doit dépolluer le site industriel avant la fin de l'année. | The company must clean up the pollution at the industrial site by the end of the year. |
| 3315 | lifter | lifté | Le chirurgien a lifté le visage de sa patiente pour effacer les rides. | The surgeon gave his patient a facelift to smooth away her wrinkles. |
| 3325 | lober | lobe | L'attaquant lobe élégamment le gardien pour marquer le but décisif. | The forward elegantly lobs the goalkeeper to score the decisive goal. |
| 3326 | fileter | filète | Le mécanicien filète l'extrémité de la tige avant de visser l'écrou. | The mechanic threads the end of the rod before screwing on the nut. |
| 3327 | arquer | arque | Sous le poids du sac, la planche arque dangereusement. | Under the weight of the bag, the plank bows dangerously. |
| 3328 | liguer | se liguent | Les habitants du village se liguent contre le maire pour empêcher le projet. | The villagers band together against the mayor to block the project. |
| 3331 | démaquiller | démaquille | Elle se démaquille avec une lotion douce avant de dormir. | She removes her makeup with a gentle lotion before going to sleep. |
| 3332 | patrouiller | patrouillent | Les policiers patrouillent dans le quartier chaque soir pour assurer la sécurité. | The police officers patrol the neighborhood every evening to ensure safety. |
| 3335 | chlorer | chlore | La ville chlore l'eau potable pour éliminer les bactéries. | The city chlorinates the drinking water to eliminate bacteria. |
| 3336 | aimanter | aimante | Ce gros aimant aimante facilement les clous en fer. | This large magnet easily magnetizes iron nails. |
| 3339 | fossiliser | fossilise | La roche fossilise les os de dinosaure enfouis pendant des millions d'années. | The rock fossilizes dinosaur bones buried for millions of years. |
| 3340 | faxer | faxe | Le secrétaire faxe le contrat signé au bureau de New York. | The secretary faxes the signed contract to the New York office. |
| 3345 | innerver | innerve | Le nerf sciatique innerve les muscles de la jambe et du pied. | The sciatic nerve innervates the muscles of the leg and foot. |
| 3349 | démotiver | démotivent | Les critiques constantes du patron démotivent complètement les employés. | The boss's constant criticism completely demotivates the employees. |
| 3352 | menotter | menotte | Le policier menotte le suspect avant de le conduire au poste. | The police officer handcuffs the suspect before taking him to the station. |
| 3353 | désacraliser | désacralisée | La cathédrale a été désacralisée avant d'être transformée en musée. | The cathedral was deconsecrated before being turned into a museum. |
| 3357 | nimber | nimbe | Le peintre aime nimber ses saints d'une lumière dorée. | The painter likes to surround his saints with a halo of golden light. |
| 3358 | vinifier | vinifient | Les vignerons vinifient le raisin récolté à la fin de l'été pour produire un vin fruité. | The winemakers vinify the grapes harvested at the end of summer to make a fruity wine. |
| 3359 | détremper | détremper | Il faut détremper les haricots secs dans l'eau pendant toute une nuit avant de les cuire. | You need to soak the dried beans in water overnight before cooking them. |
| 3361 | crêper | crêpe | La coiffeuse crêpe les cheveux de la mariée pour leur donner du volume. | The hairdresser backcombs the bride's hair to give it volume. |
| 3364 | riveter | rivette | L'ouvrier rivette soigneusement les plaques d'acier pour assembler la coque du navire. | The worker carefully rivets the steel plates together to assemble the ship's hull. |
| 3365 | chorégraphier | chorégraphié | Le chorégraphe a chorégraphié un ballet moderne pour la nouvelle saison de l'opéra. | The choreographer choreographed a modern ballet for the opera's new season. |
| 3367 | bâcher | bâche | Le fermier bâche les balles de foin avant l'arrivée de la pluie. | The farmer covers the hay bales with a tarp before the rain comes. |
| 3376 | convoyer | convoyaient | Des navires de guerre convoyaient le cargo à travers des eaux dangereuses. | Warships escorted the cargo ship through dangerous waters. |
| 3378 | revivifier | revivifié | Les pluies de printemps ont revivifié les jardins desséchés par l'hiver. | The spring rains brought the gardens, parched by winter, back to life. |
| 3384 | pressuriser | pressurisent | Les ingénieurs pressurisent la cabine de l'avion avant le décollage. | The engineers pressurize the plane's cabin before takeoff. |
| 3385 | ovuler | ovule | Une femme ovule généralement une fois par cycle menstruel. | A woman typically ovulates once per menstrual cycle. |
| 3386 | texturer | texture | Le graphiste texture le modèle 3D avant de l'exporter dans le jeu vidéo. | The graphic designer textures the 3D model before exporting it into the video game. |
| 3389 | imploser | implosé | L'immeuble abandonné a implosé en quelques secondes lors de la démolition. | The abandoned building imploded within seconds during the demolition. |
| 3391 | somnoler | somnolait | Le chat somnolait au soleil tout l'après-midi. | The cat dozed in the sun all afternoon. |
| 3393 | gausser | se gaussaient | Les collègues se gaussaient ouvertement de son accent pendant la réunion. | The colleagues openly mocked his accent during the meeting. |
| 3397 | pâturer | pâturent | Les vaches pâturent tranquillement dans le pré depuis le lever du soleil. | The cows have been grazing peacefully in the meadow since sunrise. |
| 3401 | échauder | échaudé | La cuisinière a échaudé les tomates pour retirer facilement la peau. | The cook scalded the tomatoes to remove the skin easily. |
| 3402 | revigorer | revigoré | Une bonne nuit de sommeil m'a complètement revigoré avant l'examen. | A good night's sleep completely reinvigorated me before the exam. |
| 3403 | maculer | maculé | L'encre a maculé la nappe blanche pendant qu'il écrivait sa lettre. | The ink stained the white tablecloth while he was writing his letter. |
| 3407 | manufacturer | manufacture | Cette usine manufacture des pièces automobiles depuis plus de cinquante ans. | This factory has been manufacturing car parts for more than fifty years. |
| 3408 | hiberner | hiberne | L'ours brun hiberne dans sa tanière pendant tout l'hiver. | The brown bear hibernates in its den throughout the winter. |
| 3410 | cheviller | chevillé | Le menuisier a chevillé les planches pour renforcer l'assemblage du meuble. | The carpenter doweled the boards together to reinforce the piece of furniture. |
| 3411 | couder | coudé | Le plombier a coudé le tuyau pour qu'il passe sous l'évier. | The plumber bent the pipe into an elbow shape so it would fit under the sink. |
| 3412 | instiller | instillé | Ses parents lui ont instillé le goût de la lecture dès son plus jeune âge. | His parents instilled a love of reading in him from a very young age. |
| 3414 | stupéfaire | a stupéfait | Cette révélation a stupéfait toute l'assemblée. | This revelation stunned the entire assembly. |
| 3416 | chambrer | chambré | Le sommelier a chambré la bouteille de rouge avant de la servir. | The sommelier brought the bottle of red wine to room temperature before serving it. |
| 3419 | soumissionner | soumissionné | L'entreprise a soumissionné pour le contrat de construction du nouveau pont. | The company bid for the contract to build the new bridge. |
| 3420 | désherber | désherbe | Le jardinier désherbe le potager chaque week-end au printemps. | The gardener weeds the vegetable garden every weekend in spring. |
| 3421 | airer | aire | L'aigle royal aire au sommet de la falaise depuis des années. | The golden eagle has been nesting atop the cliff for years. |
| 3423 | engorger | engorgé | Les feuilles mortes ont engorgé la gouttière après l'orage. | The dead leaves clogged the gutter after the storm. |
| 3431 | apparoir | appert | Il appert de ce rapport que le projet a échoué. | It is evident from this report that the project failed. |
| 3437 | lézarder | lézarde | L'humidité lézarde peu à peu le mur du sous-sol. | The dampness is gradually cracking the basement wall. |
| 3438 | pommer | pomment | Les choux pomment bien cette année grâce à la pluie. | The cabbages are heading up nicely this year thanks to the rain. |
| 3439 | entretuer | entretués | Les deux frères se sont entretués lors d'une violente dispute pour l'héritage. | The two brothers killed each other during a violent dispute over the inheritance. |
| 3443 | déblayer | déblayer | Après la tempête, les habitants ont dû déblayer les débris dans les rues. | After the storm, residents had to clear away the debris in the streets. |
| 3446 | meringuer | meringuer | Le pâtissier va meringuer la tarte au citron avant de la passer au four. | The pastry chef is going to top the lemon tart with meringue before putting it in the oven. |
| 3451 | sourciller | sourcillé | Elle a sourcillé en apprenant la nouvelle inattendue. | She frowned upon hearing the unexpected news. |
| 3452 | interjeter | interjeter | L'avocat a décidé d'interjeter appel du jugement rendu par le tribunal. | The lawyer decided to lodge an appeal against the court's ruling. |
| 3456 | cylindrer | cylindré | L'ouvrier a cylindré la route avant d'y couler le bitume. | The worker rolled the road before pouring asphalt over it. |
| 3461 | blondir | blondir | Il faut faire blondir les oignons dans le beurre avant d'ajouter la farine. | You need to sauté the onions in butter until golden before adding the flour. |
| 3462 | extorquer | extorqué | Les malfaiteurs ont extorqué de l'argent à la vieille dame. | The crooks extorted money from the old lady. |
| 3464 | désavantager | désavantager | Ce nouveau règlement risque de désavantager les petites entreprises face aux grandes. | This new regulation risks putting small businesses at a disadvantage compared to large ones. |
| 3466 | viander | viandent | Les cerfs viandent tranquillement dans la clairière au lever du jour. | The deer graze peacefully in the clearing at dawn. |
| 3467 | cranter | crante | Le menuisier crante soigneusement le bord de la planche avant de l'assembler. | The carpenter carefully notches the edge of the board before assembling it. |
| 3469 | solidariser | solidariser | Ce nouveau boulon permet de solidariser les deux poutres métalliques. | This new bolt makes it possible to join the two metal beams together. |
| 3470 | ioder | iode | Le fabricant iode le sel de table pour prévenir les carences en iode. | The manufacturer iodizes table salt to prevent iodine deficiencies. |
| 3472 | reprogrammer | reprogrammer | Le technicien a dû reprogrammer le robot après la mise à jour du logiciel. | The technician had to reprogram the robot after the software update. |
| 3473 | débroussailler | débroussaillent | Chaque printemps, les bénévoles débroussaillent le sentier pour éviter les incendies de forêt. | Every spring, the volunteers clear the brush from the trail to prevent forest fires. |
| 3474 | craqueler | se craqueler | Avec la chaleur, la peinture ancienne commence à se craqueler sur les volets. | With the heat, the old paint is starting to crack on the shutters. |
| 3476 | écorner | écorne | Le vétérinaire écorne les jeunes veaux pour éviter les blessures dans le troupeau. | The veterinarian dehorns the young calves to prevent injuries in the herd. |
| 3478 | vidanger | vidange | Le garagiste vidange le moteur tous les dix mille kilomètres. | The mechanic changes the oil in the engine every ten thousand kilometers. |
| 3481 | assagir | s'assagir | Avec l'âge, ce jeune homme impulsif a fini par s'assagir. | With age, this impulsive young man finally settled down. |
| 3484 | siliconer | siliconer | Certaines actrices décident de se faire siliconer les lèvres. | Some actresses decide to get silicone lip injections. |
| 3486 | motter | se motte | Au moindre bruit, la perdrix se motte aussitôt dans le champ. | At the slightest noise, the partridge instantly goes to ground in the field. |
| 3492 | lyophiliser | lyophilisent | Les scientifiques lyophilisent les aliments pour les conserver plus longtemps sans réfrigération. | Scientists freeze-dry food to preserve it longer without refrigeration. |
| 3493 | préfixer | préfixer | En linguistique, on peut préfixer un mot pour en modifier le sens. | In linguistics, you can prefix a word to change its meaning. |
| 3494 | équeuter | équeuter | Avant de préparer la confiture, il faut équeuter soigneusement les fraises. | Before making the jam, you need to carefully hull the strawberries. |
| 3495 | cloîtrer | cloîtrer | Après ce scandale, la famille a décidé de cloîtrer la jeune fille dans un couvent. | After that scandal, the family decided to cloister the young girl in a convent. |
| 3500 | pigmenter | pigmentent | Les mélanocytes pigmentent la peau en produisant de la mélanine. | Melanocytes pigment the skin by producing melanin. |
| 3501 | marmonner | marmonnait | Le vieil homme marmonnait des mots incompréhensibles en traversant la rue. | The old man was mumbling incomprehensible words as he crossed the street. |
| 3505 | enfaîter | enfaîte | L'ouvrier enfaîte le toit de tuiles rouges. | The worker tiles the roof with red tiles. |
| 3506 | grimer | grime | Le maquilleur grime les acteurs avant le spectacle. | The makeup artist applies makeup to the actors before the show. |
| 3508 | avoyer | avoie | Le menuisier avoie la scie pour que la lame ne coince plus dans le bois. | The carpenter sets the saw so the blade no longer binds in the wood. |
| 3509 | décharner | décharnait | La longue maladie décharnait peu à peu son corps. | The long illness was gradually wasting his body away. |
| 3511 | subtiliser | subtilisé | Le pickpocket a subtilisé le portefeuille du touriste dans la foule. | The pickpocket snatched the tourist's wallet in the crowd. |
| 3512 | sniffer | sniffé | Il a sniffé de la cocaïne avant la soirée. | He snorted cocaine before the party. |
| 3515 | pactiser | pactiser | Le maire a refusé de pactiser avec les entreprises corrompues. | The mayor refused to make a deal with the corrupt companies. |
| 3516 | filocher | filoché | Le détective a filoché le suspect dans les rues sombres. | The detective tailed the suspect through the dark streets. |
| 3521 | embrayer | embraye | Le conducteur embraye doucement pour faire avancer la voiture. | The driver gently engages the clutch to get the car moving. |
| 3526 | potentialiser | potentialisent | Certains médicaments potentialisent les effets de l'alcool sur le système nerveux. | Some medications potentiate the effects of alcohol on the nervous system. |
| 3527 | dégoter | dégoté | Il a fini par dégoter un appartement pas cher près du centre-ville. | He finally dug up a cheap apartment near downtown. |
| 3531 | hydrogéner | hydrogène | L'usine hydrogène l'huile végétale pour la transformer en margarine. | The factory hydrogenates vegetable oil to turn it into margarine. |
| 3534 | vinaigrer | vinaigre | Elle vinaigre la salade avant de la servir aux invités. | She dresses the salad with vinegar before serving it to the guests. |
| 3535 | barioler | bariolé | Les enfants ont bariolé les murs de la salle de classe avec des couleurs vives et criardes. | The children painted the classroom walls with bright, garish colors. |
| 3537 | extrader | extradé | La France a extradé le suspect vers l'Espagne après son arrestation à Paris. | France extradited the suspect to Spain after his arrest in Paris. |
| 3540 | ébouillanter | ébouillanté | Le cuisinier a ébouillanté les tomates avant de les peler. | The cook scalded the tomatoes before peeling them. |
| 3543 | raboter | rabote | Le menuisier rabote la planche pour qu'elle soit bien lisse. | The carpenter planes the board so it's nice and smooth. |
| 3544 | réhydrater | réhydrater | Les coureurs boivent des boissons isotoniques pour réhydrater leur corps après la course. | Runners drink isotonic drinks to rehydrate their bodies after the race. |
| 3545 | embouteiller | embouteillé | Un accident a embouteillé l'autoroute pendant plus de deux heures. | An accident jammed up the highway for more than two hours. |
| 3546 | bassiner | bassine | L'infirmière bassine la plaie avec une compresse tiède pour soulager la douleur. | The nurse bathes the wound with a warm compress to ease the pain. |
| 3552 | vernisser | vernisse | Le potier vernisse le vase avant de le cuire une seconde fois au four. | The potter glazes the vase before firing it a second time in the kiln. |
| 3553 | transfuser | transfuser | Les médecins ont dû transfuser le patient après l'accident pour compenser la perte de sang. | Doctors had to give the patient a transfusion after the accident to make up for the blood loss. |
| 3554 | surajouter | surajouté | L'architecte a surajouté un étage moderne au bâtiment historique. | The architect added an extra modern floor on top of the historic building. |
| 3557 | raciner | raciné | Le jeune arbre a raciné rapidement dans le sol meuble du jardin. | The young tree took root quickly in the garden's loose soil. |
| 3562 | vandaliser | vandalisé | Des inconnus ont vandalisé le monument aux morts pendant la nuit. | Unknown individuals vandalized the war memorial during the night. |
| 3567 | commissionner | commissionné | Le gouverneur a commissionné un nouvel officier pour diriger la garnison. | The governor commissioned a new officer to lead the garrison. |
| 3568 | vanner | vanner | Il n'arrête pas de vanner ses collègues au bureau. | He never stops teasing his colleagues at the office. |
| 3569 | déglinguer | déglingué | Le choc a complètement déglingué le vieux moteur de la voiture. | The impact completely wrecked the car's old engine. |
| 3570 | regonfler | regonflé | Le garagiste a regonflé les pneus avant le long trajet. | The mechanic reinflated the tires before the long trip. |
| 3572 | rapper | rapper | Le jeune artiste aime rapper sur des rythmes improvisés avec ses amis. | The young artist loves rapping over improvised beats with his friends. |
| 3573 | cambrioler | cambriolé | Des voleurs ont cambriolé la bijouterie pendant la nuit. | Thieves burgled the jewelry store during the night. |
| 3577 | fraiser | fraise | L'ouvrier fraise la pièce de métal avant de l'assembler. | The worker mills the metal part before assembling it. |
| 3579 | toiletter | toilette | Le vétérinaire toilette le chien avant de le rendre à ses propriétaires. | The vet grooms the dog before returning it to its owners. |
| 3585 | diffracter | diffracte | Le réseau diffracte la lumière blanche en un spectre de couleurs. | The grating diffracts white light into a spectrum of colors. |
| 3586 | émulsionner | émulsionne | Le chef émulsionne l'huile et le vinaigre pour préparer la vinaigrette. | The chef emulsifies the oil and vinegar to make the vinaigrette. |
| 3588 | punaiser | punaise | Elle punaise les photos de ses vacances sur le mur de sa chambre. | She pins up her vacation photos on her bedroom wall. |
| 3591 | rééduquer | rééduquer | Après son accident, elle a dû rééduquer sa jambe pendant plusieurs mois. | After her accident, she had to rehabilitate her leg for several months. |
| 3594 | effilocher | s'effiloche | Le bas de son jean s'effiloche à force d'être porté. | The hem of her jeans is fraying from being worn so much. |
| 3595 | brimer | brime | Le nouveau chef brime ses employés en leur donnant des tâches humiliantes. | The new boss bullies his employees by giving them humiliating tasks. |
| 3597 | clouter | cloute | L'artisan cloute la ceinture en cuir pour lui donner un style rock. | The craftsman studs the leather belt to give it a rock style. |
| 3598 | séculariser | séculariser | Le nouveau gouvernement a voté une loi pour séculariser les écoles publiques. | The new government passed a law to secularize public schools. |
| 3600 | minéraliser | minéralise | L'eau de source se minéralise en traversant les roches calcaires. | The spring water becomes mineralized as it passes through limestone rock. |
| 3605 | paresser | paresser | Le samedi, j'aime paresser au lit jusqu'à midi. | On Saturdays, I like to laze in bed until noon. |
| 3606 | touer | toue | Le remorqueur toue la péniche jusqu'au port malgré le fort courant. | The tugboat hauls the barge to the harbor despite the strong current. |
| 3608 | émuler | émuler | Elle espère émuler les grands champions qui l'ont précédée dans ce sport. | She hopes to emulate the great champions who came before her in this sport. |
| 3609 | rediscuter | rediscuter | Nous devrions rediscuter ce projet demain avec toute l'équipe. | We should discuss this project again tomorrow with the whole team. |
| 3612 | disculper | disculper | Les preuves ADN ont fini par disculper l'accusé après des années de procès. | The DNA evidence eventually exonerated the accused after years of trial. |
| 3614 | blablater | blablater | Mes voisines aiment blablater pendant des heures sur le trottoir. | My neighbors love to chit-chat for hours on the sidewalk. |
| 3617 | décalquer | décalque | L'élève décalque la carte de France pour son exposé de géographie. | The student traces the map of France for her geography presentation. |
| 3620 | brocarder | brocardaient | Les élèves brocardaient sans cesse le nouveau professeur à cause de son accent. | The students constantly mocked the new teacher because of his accent. |
| 3623 | matraquer | matraqué | La police a matraqué les manifestants pendant l'affrontement devant la mairie. | The police clubbed the protesters during the clash in front of city hall. |
| 3626 | plâtrer | plâtre | Le maçon plâtre soigneusement le mur avant d'appliquer la peinture. | The mason carefully plasters the wall before applying the paint. |
| 3627 | adsorber | adsorbe | Le charbon actif adsorbe les impuretés présentes dans l'eau potable. | Activated carbon adsorbs the impurities present in drinking water. |
| 3632 | glandouiller | glandouiller | Pendant les vacances, il préfère glandouiller devant la télé plutôt que sortir. | During the holidays, he'd rather bum around in front of the TV than go out. |
| 3636 | vaser | vase | Il vase depuis ce matin dans le Nord de la France. | It's been raining cats and dogs since this morning in the North of France. |
| 3638 | incuber | incube | La poule incube ses œufs pendant environ vingt et un jours. | The hen incubates its eggs for about twenty-one days. |
| 3639 | télescoper | télescopé | Le camion a télescopé la voiture arrêtée au feu rouge. | The truck crashed into the car stopped at the red light. |
| 3641 | snober | snobé | Elle a snobé son ancien camarade de classe à la soirée. | She snubbed her old classmate at the party. |
| 3642 | ébattre | s'ébattent | Les enfants s'ébattent joyeusement dans le jardin après l'école. | The children frolic happily in the garden after school. |
| 3643 | inactiver | inactivé | Le technicien a inactivé le compte après le départ de l'employé. | The technician deactivated the account after the employee left. |
| 3651 | disjoncter | disjoncté | Le four a disjoncté pendant la cuisson et toute la maison s'est retrouvée dans le noir. | The oven tripped the breaker while cooking, and the whole house went dark. |
| 3652 | pilonner | pilonné | L'artillerie a pilonné la ville toute la nuit sans interruption. | The artillery bombarded the city all night without stopping. |
| 3653 | déniveler | dénivelé | Les inondations ont dénivelé la route, créant des creux dangereux. | The flooding made the road uneven, creating dangerous dips. |
| 3655 | phraser | phraser | Le musicien a appris à phraser une mélodie avec beaucoup de sensibilité. | The musician learned to phrase a melody with great sensitivity. |
| 3656 | chemiser | chemisé | L'artisan a chemisé le moule de papier sulfurisé avant d'y verser la pâte. | The craftsman lined the mold with parchment paper before pouring in the batter. |
| 3661 | distordre | distordu | La forte chaleur a distordu les rails du chemin de fer en plein été. | The intense heat warped the railway tracks in the middle of summer. |
| 3662 | twister | twisté | Les danseurs ont twisté toute la soirée sur cette chanson des années soixante. | The dancers twisted all evening to that sixties song. |
| 3663 | patronner | patronner | Une grande entreprise locale a accepté de patronner le festival de musique cette année. | A large local company agreed to sponsor the music festival this year. |
| 3664 | téléguider | téléguidé | Les pirates informatiques ont téléguidé l'attaque depuis un pays étranger. | The hackers orchestrated the attack from a foreign country. |
| 3665 | dessaler | dessaler | Il faut dessaler la morue dans l'eau froide pendant plusieurs heures avant de la cuisiner. | You need to desalt the cod in cold water for several hours before cooking it. |
| 3667 | ritualiser | ritualise | Chaque matin, elle ritualise sa routine avec une tasse de thé et un peu de lecture. | Every morning, she ritualizes her routine with a cup of tea and some reading. |
| 3668 | pasticher | pastiché | Le jeune auteur a pastiché le style de Proust dans sa première nouvelle. | The young author pastiched Proust's style in his first short story. |
| 3671 | marger | marger | L'imprimeur a réglé la presse pour marger correctement chaque feuille avant l'impression. | The printer adjusted the press to set the margin correctly on each sheet before printing. |
| 3673 | biter | bite | Je n'y bite rien à ces instructions. | I don't understand a thing about these instructions. |
| 3675 | hybrider | hybrider | Les chercheurs veulent hybrider ces deux variétés pour obtenir un fruit plus résistant. | The researchers want to hybridize these two varieties to produce a hardier fruit. |
| 3676 | désarçonner | désarçonné | Le cavalier a été désarçonné quand son cheval s'est cabré soudainement. | The rider was thrown from his horse when it suddenly reared up. |
| 3677 | pasteuriser | pasteurise | L'usine pasteurise le lait avant de le mettre en bouteille. | The plant pasteurizes the milk before bottling it. |
| 3683 | couiner | couine | La porte du grenier couine chaque fois qu'on l'ouvre. | The attic door creaks every time you open it. |
| 3684 | tercer | tercer | Le vigneron doit tercer la vigne avant les vendanges pour ameublir la terre. | The winegrower has to plow the vineyard a third time before harvest to loosen the soil. |
| 3687 | christianiser | christianiser | Les missionnaires ont cherché à christianiser les populations locales au dix-septième siècle. | The missionaries sought to Christianize the local populations in the seventeenth century. |
| 3689 | radiodiffuser | radiodiffuser | La station va radiodiffuser le match en direct ce soir. | The station is going to broadcast the match live tonight. |
| 3691 | crasher | s'est crashé | L'avion s'est crashé peu après le décollage. | The plane crashed shortly after takeoff. |
| 3693 | mensualiser | mensualiser | L'entreprise a décidé de mensualiser le paiement des salaires. | The company decided to pay salaries monthly. |
| 3694 | swinguer | swinguer | L'orchestre de jazz fait swinguer toute la salle. | The jazz band gets the whole room swinging. |
| 3699 | réadapter | réadapter | Après son accident, il a dû réadapter sa manière de travailler. | After his accident, he had to readjust the way he worked. |
| 3700 | désinformer | désinformer | Certains médias cherchent à désinformer le public pour orienter l'opinion. | Some media outlets try to misinform the public in order to shape opinion. |
| 3702 | emmitoufler | emmitoufle | Elle emmitoufle son bébé dans une épaisse couverture avant de sortir. | She wraps her baby up warmly in a thick blanket before going out. |
| 3708 | polycopier | polycopié | Le professeur a polycopié le cours pour tous les étudiants. | The teacher duplicated the course notes for all the students. |
| 3710 | théâtraliser | théâtralisent | Les médias théâtralisent souvent les moindres incidents. | The media often dramatize the smallest incidents. |
| 3711 | apurer | apuré | Le comptable a apuré les comptes de l'association avant l'audit. | The accountant balanced the association's accounts before the audit. |
| 3712 | praliner | praliné | La pâtissière a praliné les amandes avant de les ajouter au gâteau. | The pastry chef coated the almonds with caramelized sugar before adding them to the cake. |
| 3713 | bruiter | bruite | Le technicien bruite les scènes de combat pour le film d'animation. | The technician creates the sound effects for the fight scenes in the animated film. |
| 3721 | coloriser | colorisé | Le studio a colorisé le vieux film noir et blanc pour la nouvelle diffusion. | The studio colorized the old black-and-white film for its rerelease. |
| 3723 | coltiner | coltiné | Je me suis coltiné tout le déménagement pendant que mes frères regardaient la télé. | I got stuck doing the entire move while my brothers just watched TV. |
| 3727 | cisailler | cisaille | L'ouvrier cisaille la tôle avec une pince spéciale avant de la souder. | The worker shears the sheet metal with a special tool before welding it. |
| 3730 | rempiler | rempiler | Après six mois de civil, il a décidé de rempiler dans l'armée. | After six months as a civilian, he decided to reenlist in the army. |
| 3731 | klaxonner | klaxonné | Le chauffeur a klaxonné plusieurs fois pour faire avancer la voiture devant lui. | The driver honked several times to get the car ahead of him moving. |
| 3732 | psychanalyser | psychanalysé | Le patient a été psychanalysé pendant plus de dix ans. | The patient was psychoanalyzed for more than ten years. |
| 3734 | grainer | graine | Le maroquinier graine le cuir avant de le teindre. | The leatherworker grains the leather before dyeing it. |
| 3735 | perquisitionner | perquisitionné | La police a perquisitionné l'appartement à la recherche de preuves. | The police searched the apartment for evidence. |
| 3738 | remballer | remballé | Le vendeur a remballé les articles invendus à la fin du marché. | The vendor repacked the unsold items at the end of the market. |
| 3739 | vouvoyer | vouvoie | Au travail, on vouvoie généralement ses supérieurs et ses collègues moins proches. | At work, people generally address their superiors and less close colleagues as 'vous.' |
| 3742 | syncoper | syncoper | Le musicien aime syncoper le rythme pour donner du swing à sa mélodie. | The musician likes to syncopate the rhythm to give his melody some swing. |
| 3745 | débâter | débâte | Le muletier débâte son âne après la longue randonnée dans les collines. | The muleteer unsaddles his donkey after the long trek through the hills. |
| 3746 | encoller | encolle | L'artisan encolle soigneusement le papier peint avant de le poser sur le mur. | The craftsman carefully glues the wallpaper before hanging it on the wall. |
| 3747 | transmuter | transmuter | Les alchimistes rêvaient de transmuter le plomb en or. | Alchemists dreamed of transmuting lead into gold. |
| 3752 | intervertir | interverti | Le typographe a interverti deux lettres en composant le titre du journal. | The typesetter transposed two letters while setting the newspaper's headline. |
| 3754 | fabuler | fabuler | Le vieil homme aime fabuler sur ses exploits de jeunesse pour impressionner ses petits-enfants. | The old man likes to make up stories about his youthful exploits to impress his grandchildren. |
| 3756 | dégermer | dégerme | Le fermier dégerme les pommes de terre avant de les stocker pour l'hiver. | The farmer removes the sprouts from the potatoes before storing them for winter. |
| 3759 | endoctriner | endoctriner | Le régime a tenté d'endoctriner les jeunes dès leur plus jeune âge. | The regime tried to indoctrinate the young from an early age. |
| 3760 | réexpédier | réexpédier | La poste va réexpédier le colis à la nouvelle adresse du client. | The post office will forward the package to the customer's new address. |
| 3762 | brutaliser | brutalisait | Le geôlier brutalisait les prisonniers sans la moindre pitié. | The jailer brutalized the prisoners without the slightest pity. |
| 3764 | débrayer | débrayer | Le mécanicien doit débrayer avant de changer de vitesse. | The mechanic must disengage the clutch before shifting gears. |
| 3765 | appâter | appâte | Le pêcheur appâte son hameçon avec un ver de terre. | The fisherman baits his hook with an earthworm. |
| 3766 | retisser | retissent | Les artisans retissent la tapisserie ancienne fil par fil pour la restaurer. | The craftsmen reweave the old tapestry thread by thread to restore it. |
| 3767 | sangler | sangle | L'écuyer sangle bien la selle avant de monter à cheval. | The groom straps the saddle up tightly before mounting the horse. |
| 3769 | carreler | carrelle | L'ouvrier carrelle la salle de bains avec des carreaux blancs et bleus. | The worker tiles the bathroom with white and blue tiles. |
| 3772 | calligraphier | calligraphie | Le moine calligraphie soigneusement chaque page du manuscrit médiéval. | The monk carefully writes each page of the medieval manuscript in calligraphy. |
| 3773 | déresponsabiliser | déresponsabilise | Le nouveau système déresponsabilise complètement les employés en cas d'erreur. | The new system completely relieves employees of responsibility for mistakes. |
| 3775 | islamiser | islamiser | Certains dirigeants ont cherché à islamiser progressivement les institutions du pays. | Some leaders sought to gradually Islamize the country's institutions. |
| 3776 | bafouiller | bafouille | L'élève bafouille quelques mots incompréhensibles devant toute la classe. | The student stammers a few incomprehensible words in front of the whole class. |
| 3780 | molester | molester | Les manifestants ont commencé à molester les journalistes venus couvrir l'événement. | The protesters began to manhandle the journalists who had come to cover the event. |
| 3782 | réemployer | réemployer | L'entreprise a décidé de réemployer les matériaux du bâtiment démoli pour un nouveau projet. | The company decided to reuse the materials from the demolished building for a new project. |
| 3784 | perfuser | perfuser | L'infirmière a dû perfuser le patient pour lui administrer les antibiotiques. | The nurse had to put the patient on an IV drip to give him the antibiotics. |
| 3787 | surexploiter | surexploiter | Certaines entreprises continuent de surexploiter les ressources naturelles sans se soucier des conséquences. | Some companies keep overexploiting natural resources without regard for the consequences. |
| 3791 | dépoter | dépoté | Le jardinier a dépoté le rosier avant de le planter dans le jardin. | The gardener took the rosebush out of its pot before planting it in the garden. |
| 3794 | révulser | révulse | Cette odeur de viande avariée révulse tout le monde dans la cuisine. | That smell of spoiled meat revolts everyone in the kitchen. |
| 3798 | dégeler | dégeler | Le soleil printanier a fini par dégeler la rivière gelée depuis des semaines. | The spring sun finally thawed the river that had been frozen for weeks. |
| 3799 | dégueulasser | dégueulasse | Ne dégueulasse pas la cuisine que je viens de nettoyer ! | Don't mess up the kitchen I just cleaned! |
| 3802 | décoloniser | décoloniser | Plusieurs pays africains ont cherché à décoloniser leur système éducatif après l'indépendance. | Several African countries sought to decolonize their education system after independence. |
| 3803 | subroger | subrogée | La compagnie d'assurance a été subrogée dans les droits de la victime après l'indemnisation. | The insurance company was subrogated to the victim's rights after paying the compensation. |
| 3805 | viner | vine | Le vigneron vine le vin doux pour stopper la fermentation et le conserver plus longtemps. | The winemaker fortifies the sweet wine to stop fermentation and preserve it longer. |
| 3806 | banquer | banquer | C'est encore moi qui dois banquer pour le cadeau d'anniversaire du patron. | Once again, I'm the one who has to fork out for the boss's birthday present. |
| 3808 | goinfrer | goinfrés | Les enfants se sont goinfrés de bonbons pendant la fête d'Halloween. | The kids stuffed themselves with candy during the Halloween party. |
| 3809 | ascensionner | ascensionner | Les alpinistes ont réussi à ascensionner le sommet malgré des conditions météo difficiles. | The climbers managed to ascend the summit despite difficult weather conditions. |
| 3811 | emboutir | embouti | Le camion a embouti l'arrière de ma voiture au feu rouge. | The truck crashed into the back of my car at the red light. |
| 3814 | chatonner | chatonné | Notre chatte a chatonné pour la troisième fois ce printemps. | Our cat gave birth to kittens for the third time this spring. |
| 3816 | bidonner | bidonné | Le journaliste a bidonné toute l'interview pour rendre l'article plus intéressant. | The journalist made up the entire interview to make the article more interesting. |
| 3817 | catapulter | catapulté | Le lanceur a catapulté le ballon à travers le terrain d'un seul geste. | The thrower catapulted the ball across the field in one motion. |
| 3818 | raturer | raturé | L'élève a raturé plusieurs mots dans sa dissertation avant de la rendre. | The student crossed out several words in her essay before handing it in. |
| 3819 | fretter | frette | Le maçon frette le pilier avec des bandes métalliques pour le renforcer. | The mason reinforces the pillar with metal bands to strengthen it. |
| 3822 | vampiriser | vampirise | Le patron vampirise ses employés en exigeant des heures supplémentaires sans compensation. | The boss vampirizes his employees by demanding unpaid overtime. |
| 3827 | embuer | embué | La buée de la douche a embué le miroir de la salle de bains. | The steam from the shower fogged up the bathroom mirror. |
| 3828 | biseauter | biseaute | Le vitrier biseaute les bords de la glace pour un effet plus élégant. | The glazier bevels the edges of the mirror for a more elegant look. |
| 3829 | circoncire | circoncit | Selon la tradition, on circoncit les garçons quelques jours après leur naissance. | According to tradition, boys are circumcised a few days after birth. |
| 3831 | régater | régatent | Chaque été, les marins du club régatent au large de la côte bretonne. | Every summer, the club's sailors race in regattas off the Breton coast. |
| 3832 | autodétruire | s'autodétruira | Le message s'autodétruira dans dix secondes après la lecture. | The message will self-destruct ten seconds after being read. |
| 3833 | itérer | itère | Le développeur itère sur le code jusqu'à ce que tous les tests passent. | The developer iterates on the code until all the tests pass. |
| 3834 | mutiner | mutinés | Les marins se sont mutinés contre le capitaine après des mois de mauvais traitement. | The sailors mutinied against the captain after months of mistreatment. |
| 3835 | différentier | différentie | En calcul infinitésimal, on différentie une fonction pour obtenir sa dérivée. | In calculus, you differentiate a function to obtain its derivative. |
| 3837 | détaxer | détaxer | Les touristes peuvent détaxer leurs achats en quittant le pays. | Tourists can get their purchases tax-free when leaving the country. |
| 3838 | moulurer | mouluré | Le menuisier a mouluré le cadre pour lui donner un aspect plus raffiné. | The carpenter added moldings to the frame to give it a more refined look. |
| 3841 | abjurer | abjurer | Le philosophe a été forcé d'abjurer ses convictions devant le tribunal. | The philosopher was forced to renounce his convictions before the tribunal. |
| 3842 | réimprimer | réimprimer | L'éditeur va réimprimer le roman après son succès inattendu. | The publisher is going to reprint the novel after its unexpected success. |
| 3843 | repeupler | repeuplée | Après l'incendie, la région a été repeuplée d'arbres résistants au feu. | After the fire, the region was replanted with fire-resistant trees. |
| 3844 | déréglementer | déréglementer | Le gouvernement a décidé de déréglementer le secteur des télécommunications. | The government decided to deregulate the telecommunications sector. |
| 3846 | engazonner | engazonné | Les jardiniers ont engazonné le terrain vague pour en faire un parc. | The gardeners turfed the vacant lot to turn it into a park. |
| 3847 | étriper | étripe | Le pêcheur étripe le poisson avant de le faire griller. | The fisherman guts the fish before grilling it. |
| 3850 | gratouiller | gratouille | Cette étiquette me gratouille le cou depuis ce matin. | This tag has been itching my neck since this morning. |
| 3851 | rempoter | rempote | Chaque printemps, je rempote mes plantes vertes dans des pots plus grands. | Every spring, I repot my houseplants into bigger pots. |
| 3853 | préluder | prélude | Cette grève prélude à des mois de tensions sociales dans le pays. | This strike is a prelude to months of social tension across the country. |
| 3854 | déculpabiliser | déculpabilisée | Cette conversation m'a beaucoup déculpabilisée après l'accident. | That conversation eased a lot of my guilt after the accident. |
| 3855 | materner | materne | Elle materne trop son fils adulte, ce qui l'empêche de devenir autonome. | She mollycoddles her adult son too much, which keeps him from becoming independent. |
| 3856 | croustiller | croustille | Le pain frais croustille sous la dent dès qu'il sort du four. | Fresh bread crunches under the teeth as soon as it comes out of the oven. |
| 3858 | dépassionner | dépassionne | Le médiateur dépassionne peu à peu le débat houleux entre les deux camps. | The mediator is gradually defusing the heated debate between the two sides. |
| 3859 | fourguer | fourgué | Il a fourgué sa vieille voiture à un ami pour trois fois rien. | He flogged his old car to a friend for next to nothing. |
| 3860 | excréter | excrètent | Les reins excrètent les déchets du sang sous forme d'urine. | The kidneys excrete waste from the blood in the form of urine. |
| 3861 | entre-déchirer | entre-déchirés | Les deux frères se sont entre-déchirés pendant des années à cause de l'héritage. | The two brothers tore each other apart for years over the inheritance. |
| 3864 | araser | arase | Le maçon arase le haut du mur pour qu'il soit parfaitement droit. | The mason levels off the top of the wall so it's perfectly straight. |
| 3865 | tacler | taclé | Le défenseur a taclé l'attaquant juste avant la ligne de but. | The defender tackled the attacker just before the goal line. |
| 3872 | galber | galbe | Le sculpteur galbe le pied de la chaise pour lui donner une ligne élégante. | The sculptor shapes the chair leg's curve to give it an elegant line. |
| 3874 | safraner | safrane | La cuisinière safrane le riz pour lui donner sa couleur dorée typique. | The cook adds saffron to the rice to give it its typical golden color. |
| 3878 | magnétiser | magnétise | Ce courant électrique magnétise la barre de fer en quelques secondes. | This electric current magnetizes the iron bar within seconds. |
| 3882 | fiscaliser | fiscaliser | Le gouvernement veut fiscaliser davantage les revenus du capital. | The government wants to tax capital income more heavily. |
| 3884 | franchiser | franchiser | Le groupe de restauration veut franchiser son concept dans toute l'Europe. | The restaurant group wants to franchise its concept across Europe. |
| 3885 | recompter | recompter | Le caissier a dû recompter la caisse à la fin de la journée. | The cashier had to recount the till at the end of the day. |
| 3887 | décontaminer | décontaminer | Les employés doivent décontaminer le laboratoire avant l'inspection annuelle. | The staff must decontaminate the lab before the annual inspection. |
| 3888 | dévider | dévide | Elle dévide lentement le fil de la bobine pour préparer le métier à tisser. | She slowly unwinds the thread from the spool to get the loom ready. |
| 3890 | crawler | crawle | Elle crawle tous les matins pendant une heure à la piscine municipale. | She does the crawl stroke every morning for an hour at the public pool. |
| 3892 | interpoler | interpolent | Les statisticiens interpolent les valeurs manquantes entre deux mesures connues. | Statisticians interpolate the missing values between two known measurements. |
| 3894 | lobotomiser | lobotomiser | Les médecins ont décidé de lobotomiser le patient dans les années 1950. | In the 1950s the doctors decided to lobotomize the patient. |
| 3895 | avarier | avarié | Le poisson s'est avarié pendant le trajet à cause de la chaleur. | The fish went bad during the trip because of the heat. |
| 3896 | tronçonner | tronçonne | Le bûcheron tronçonne les grosses branches tombées après la tempête. | The lumberjack saws up the big branches that fell after the storm. |
| 3900 | étamer | étame | L'artisan étame la casserole en cuivre pour éviter qu'elle ne s'oxyde. | The craftsman tin-plates the copper pot to keep it from oxidizing. |
| 3901 | empailler | empaillé | Le taxidermiste a empaillé le renard pour l'exposer au musée. | The taxidermist stuffed the fox to put it on display at the museum. |
| 3904 | dribbler | dribble | Le jeune attaquant dribble deux défenseurs avant de tirer au but. | The young forward dribbles past two defenders before shooting at goal. |
| 3905 | électrocuter | électrocuter | Le technicien a failli s'électrocuter en touchant un câble dénudé. | The technician nearly electrocuted himself by touching a bare wire. |
| 3914 | chantourner | chantourne | Le menuisier chantourne une planche pour former le dossier de la chaise. | The carpenter cuts the board into shape to form the back of the chair. |
| 3915 | veiner | veine | Le peintre veine soigneusement le faux marbre pour tromper l'œil. | The painter carefully veins the faux marble to fool the eye. |
| 3916 | astiquer | astique | Le soldat astique ses bottes avant l'inspection du matin. | The soldier polishes his boots before the morning inspection. |
| 3917 | paupériser | paupérisé | La crise économique a paupérisé toute une génération de jeunes diplômés. | The economic crisis pauperized an entire generation of young graduates. |
| 3919 | entre-regarder | entre-regardés | Les deux amis se sont entre-regardés un long moment avant de se remettre à rire. | The two friends looked at each other for a long moment before bursting out laughing again. |
| 3923 | ovationner | ovationné | La foule a ovationné le champion olympique à son retour au pays. | The crowd gave the Olympic champion a standing ovation when he returned home. |
| 3928 | amaigrir | amaigri | La maladie l'avait tellement amaigri qu'il ne pesait plus que quarante kilos. | The illness had left him so emaciated that he weighed only forty kilograms. |
| 3929 | dépolitiser | dépolitiser | Le nouveau maire a promis de dépolitiser la gestion des services municipaux. | The new mayor promised to depoliticize the management of municipal services. |
| 3930 | bivouaquer | bivouaqué | Les randonneurs ont bivouaqué au bord du lac avant de reprendre la montée le lendemain. | The hikers bivouacked by the lake before resuming the climb the next day. |
| 3931 | bouturer | bouturé | Le jardinier a bouturé plusieurs pieds de tomate à la fin de l'été. | The gardener propagated several tomato plants from cuttings at the end of summer. |
| 3935 | slalomer | slalomé | Le skieur a slalomé habilement entre les piquets malgré la neige tombante. | The skier deftly slalomed between the gates despite the falling snow. |
| 3936 | budgétiser | budgétisé | La mairie a budgétisé la rénovation du parc pour l'année prochaine. | City hall has budgeted for the park's renovation next year. |
| 3939 | réapprovisionner | réapprovisionne | Le supermarché réapprovisionne ses rayons de fruits tous les matins. | The supermarket restocks its fruit shelves every morning. |
| 3941 | peller | peller | Après la tempête, il a fallu peller l'entrée pendant plus d'une heure. | After the storm, we had to shovel the driveway for over an hour. |
| 3942 | revoter | revoté | Le conseil municipal a dû revoter la proposition après la contestation des résultats. | The town council had to revote on the proposal after the results were contested. |
| 3944 | sédimenter | sédimenter | Les particules d'argile ont fini par sédimenter au fond du lac. | The clay particles eventually settled and sedimented at the bottom of the lake. |
| 3946 | trimbaler | trimbaler | Elle en a assez de trimbaler ses valises dans toutes les gares. | She's tired of lugging her suitcases through every train station. |
| 3948 | escher | esché | Le pêcheur a esché son hameçon avec un ver de terre avant de lancer sa ligne. | The fisherman baited his hook with an earthworm before casting his line. |
| 3950 | fourcher | fourche | La route fourche à la sortie du village, alors il faut prendre à gauche. | The road forks just past the village, so you have to bear left. |
| 3952 | rationner | rationné | Le gouvernement a rationné l'essence pendant la guerre pour éviter la pénurie. | The government rationed gasoline during the war to prevent shortages. |
| 3954 | euthanasier | euthanasier | Le vétérinaire a dû euthanasier le chien malade pour abréger ses souffrances. | The vet had to euthanize the sick dog to end its suffering. |
| 3961 | racketter | rackettent | Ces individus rackettent les petits commerçants du quartier chaque semaine. | These men extort protection money from the neighborhood's small shopkeepers every week. |
| 3964 | remontrer | remontrer | Le professeur a dû remontrer l'exercice à toute la classe. | The teacher had to show the exercise to the whole class again. |
| 3965 | cogérer | cogèrent | Les deux fondateurs cogèrent l'entreprise depuis dix ans. | The two founders have co-managed the company for ten years. |
| 3968 | suffixer | suffixer | En linguistique, on peut suffixer un mot pour en changer la catégorie grammaticale. | In linguistics, you can suffix a word to change its grammatical category. |
| 3972 | réentendre | réentendre | Grâce à l'enregistrement, nous avons pu réentendre le discours du président. | Thanks to the recording, we were able to hear the president's speech again. |
| 3973 | frelater | frelatent | Certains vendeurs peu scrupuleux frelatent le vin pour augmenter leurs profits. | Some unscrupulous sellers adulterate the wine to increase their profits. |
| 3977 | emmurer | emmuré | Les moines ont emmuré le trésor pour le protéger des pillards. | The monks walled up the treasure to protect it from looters. |
| 3978 | décérébrer | décérébré | Les chercheurs ont décérébré le rat afin d'étudier ses réflexes spinaux. | The researchers decerebrated the rat in order to study its spinal reflexes. |
| 3982 | patouiller | patouiller | Les enfants adorent patouiller dans les flaques après la pluie. | The kids love splashing around in puddles after the rain. |
| 3984 | pensionner | pensionner | La famille a décidé de pensionner la vieille servante après sa retraite. | The family decided to pay the old servant a regular allowance after her retirement. |
| 3992 | délurer | délurer | Ses années passées à Paris ont fini par délurer ce jeune campagnard timide. | His years spent in Paris eventually made this shy country boy street-smart. |
| 3996 | surmener | surmène | Le médecin lui conseilla de ralentir avant que le stress ne le surmène complètement. | The doctor advised him to slow down before stress wore him out completely. |
| 3998 | latter | latté | Le charpentier a latté le plafond avant de poser les tuiles du toit. | The carpenter lathed the ceiling before laying the roof tiles. |
| 4001 | époustoufler | époustouflé | Sa performance a complètement époustouflé le jury du concours. | Her performance completely amazed the competition's judges. |
| 4003 | laïciser | laïciser | Le nouveau gouvernement a voté une loi pour laïciser l'enseignement public. | The new government passed a law to secularize public education. |
| 4004 | décolleter | décolleté | La couturière a décolleté la robe pour dégager les épaules de la mariée. | The seamstress cut the dress's neckline low to bare the bride's shoulders. |
| 4006 | polymériser | polymériser | Sous l'effet de la chaleur, ce plastique commence à polymériser rapidement. | Under the effect of heat, this plastic quickly begins to polymerize. |
| 4007 | fritter | fritter | Les ingénieurs chauffent la poudre métallique pour la fritter en une masse solide. | The engineers heat the metal powder to sinter it into a solid mass. |
| 4009 | déphaser | déphaser | Le technicien a réglé l'oscillateur pour déphaser le signal de quatre-vingt-dix degrés. | The technician adjusted the oscillator to shift the phase of the signal by ninety degrees. |
| 4010 | cascader | cascadait | L'eau claire du torrent cascadait joyeusement sur les rochers de la montagne. | The clear mountain stream water cascaded joyfully over the rocks. |
| 4017 | dépénaliser | dépénaliser | Plusieurs pays ont voté pour dépénaliser la possession de petites quantités de cannabis. | Several countries have voted to decriminalize possession of small amounts of cannabis. |
| 4019 | émécher | éméché | Quelques verres de champagne avaient légèrement éméché les invités avant le dîner. | A few glasses of champagne had left the guests slightly tipsy before dinner. |
| 4021 | cuber | cuber | Pour calculer le volume d'un cube, il faut cuber la longueur de son côté. | To calculate a cube's volume, you have to cube the length of its side. |
| 4022 | indifférer | indiffère | Ce genre de débat politique m'indiffère complètement. | That kind of political debate leaves me completely indifferent. |
| 4023 | mythifier | mythifié | Les médias ont mythifié cet acteur au point d'en faire une légende vivante. | The media have mythologized this actor to the point of turning him into a living legend. |
| 4024 | constitutionnaliser | constitutionnaliser | Le Parlement a voté pour constitutionnaliser le droit à l'avortement. | Parliament voted to enshrine the right to abortion in the constitution. |
| 4025 | sulfater | sulfate | Le vigneron sulfate ses vignes chaque printemps pour prévenir le mildiou. | The winegrower sprays his vines with sulfate each spring to prevent mildew. |
| 4027 | embrigader | embrigader | Le parti a tenté d'embrigader de jeunes étudiants pour sa campagne. | The party tried to rope young students into its campaign. |
| 4028 | surexposer | surexposé | Le photographe a surexposé la pellicule en oubliant de régler l'appareil. | The photographer overexposed the film by forgetting to adjust the camera settings. |
| 4029 | concélébrer | concélébré | Les deux prêtres ont concélébré la messe dominicale ensemble. | The two priests concelebrated the Sunday Mass together. |
| 4030 | microfilmer | microfilmé | La bibliothèque a microfilmé tous les journaux anciens pour les préserver. | The library microfilmed all the old newspapers to preserve them. |
| 4031 | rameuter | rameuté | Le chef de bande a rameuté ses complices pour le prochain cambriolage. | The gang leader rounded up his accomplices for the next burglary. |
| 4035 | occidentaliser | occidentaliser | Le régime a cherché à occidentaliser rapidement l'économie du pays. | The regime sought to rapidly westernize the country's economy. |
| 4038 | amocher | amoché | La chute l'a sérieusement amoché, mais il n'a rien de cassé. | The fall really banged him up, but he didn't break anything. |
| 4045 | feutrer | feutre | L'artisan feutre la laine pour fabriquer des chapeaux traditionnels. | The craftsman felts the wool to make traditional hats. |
| 4046 | repriser | reprisait | Ma grand-mère reprisait mes chaussettes trouées tous les hivers. | My grandmother used to darn my socks with holes every winter. |
| 4047 | préformer | préforme | L'usine préforme les pièces en plastique avant l'assemblage final. | The factory preforms the plastic parts before final assembly. |
| 4049 | gondoler | gondolé | Le carton a gondolé à cause de l'humidité dans la cave. | The cardboard warped because of the dampness in the cellar. |
| 4050 | ressemer | ressemer | Après la sécheresse, les agriculteurs ont dû ressemer une grande partie du champ. | After the drought, the farmers had to reseed much of the field. |
| 4052 | épiloguer | épilogué | Les critiques ont épilogué pendant des heures sur les moindres détails du film. | The critics went on and on for hours about the tiniest details of the film. |
| 4053 | déglutir | déglutir | Le patient avait du mal à déglutir après l'opération. | The patient had trouble swallowing after the operation. |
| 4054 | exfolier | exfolié | Le vent violent a exfolié les branches du jeune arbre en une seule nuit. | The violent wind stripped the leaves off the young tree in a single night. |
| 4055 | métaboliser | métabolise | Le corps humain métabolise le glucose pour produire de l'énergie. | The human body metabolizes glucose to produce energy. |
| 4057 | morfler | morflé | Il a beaucoup morflé quand ses parents ont découvert la vérité. | He really paid for it when his parents found out the truth. |
| 4058 | militariser | militariser | Le gouvernement a décidé de militariser la frontière après les incidents. | The government decided to militarize the border after the incidents. |
| 4060 | empaqueter | empaqueté | Elle a empaqueté les cadeaux avant de partir chez sa sœur. | She packaged up the gifts before leaving for her sister's house. |
| 4061 | congratuler | congratulé | Le maire a congratulé les pompiers pour leur courage lors de l'incendie. | The mayor congratulated the firefighters for their courage during the fire. |
| 4062 | acidifier | acidifie | Le jus de citron acidifie le lait, ce qui le fait cailler. | Lemon juice acidifies the milk, which makes it curdle. |
| 4063 | contre-tirer | contre-tiré | L'imprimeur a contre-tiré la gravure pour vérifier la netteté du trait. | The printer took a counterproof of the engraving to check the sharpness of the line. |
| 4066 | carencer | carencer | Une alimentation trop pauvre en fer peut carencer un enfant en pleine croissance. | A diet too poor in iron can cause a deficiency in a growing child. |
| 4067 | miter | mité | Le vieux pull en laine s'est mité dans le grenier. | The old wool sweater got moth-eaten in the attic. |
| 4068 | rewriter | rewriter | Le journaliste a dû rewriter l'article avant sa publication. | The journalist had to rewrite the article before it was published. |
| 4070 | désincarner | désincarner | Le romancier cherche à désincarner ses personnages pour les rendre plus symboliques. | The novelist seeks to disembody his characters in order to make them more symbolic. |
| 4071 | feinter | feinté | Le footballeur a feinté à droite avant de partir vers la gauche. | The footballer feinted to the right before darting off to the left. |
| 4074 | meuler | meule | L'artisan meule le couteau pour l'aiguiser correctement. | The craftsman grinds the knife on a grindstone to sharpen it properly. |
| 4075 | renfler | renfle | Le vent renfle les voiles du bateau. | The wind makes the boat's sails bulge. |
| 4077 | infantiliser | infantiliser | Le personnel médical a tendance à infantiliser les patients âgés. | Medical staff tend to infantilize elderly patients. |
| 4078 | cordonner | cordonne | L'artisan cordonne le fil de laine pour fabriquer une ceinture tressée. | The craftsman twists the wool thread into a rope to make a braided belt. |
| 4080 | ganser | ganse | La couturière ganse le col de la robe avec un ruban de soie. | The seamstress edges the dress's collar with a silk ribbon. |
| 4081 | romaniser | romanisé | Les conquérants ont romanisé la Gaule en plusieurs générations. | The conquerors Romanized Gaul over several generations. |
| 4082 | ignifuger | ignifuge | Le peintre ignifuge le bois avant de l'installer près de la cheminée. | The painter fireproofs the wood before installing it near the fireplace. |
| 4085 | hachurer | hachure | Le dessinateur hachure les zones d'ombre du croquis. | The draftsman hachures the shaded areas of the sketch. |
| 4087 | zieuter | zieute | Le vieux voisin zieute discrètement les allées et venues du quartier. | The old neighbor discreetly eyes the comings and goings of the neighborhood. |
| 4090 | atrophier | s'atrophier | Sans exercice régulier, les muscles finissent par s'atrophier. | Without regular exercise, muscles eventually atrophy. |
| 4091 | universaliser | universaliser | Les avancées scientifiques ont permis d'universaliser l'accès à cette technologie. | Scientific advances have made it possible to universalize access to this technology. |
| 4094 | dégotter | dégotté | Il a dégotté une vieille guitare dans un vide-grenier hier. | He dug up an old guitar at a flea market yesterday. |
| 4095 | triller | trille | Le rossignol trille doucement dans les branches au lever du jour. | The nightingale trills softly in the branches at daybreak. |
| 4096 | moquetter | moquetté | Nous avons moquetté le salon pour le rendre plus chaleureux en hiver. | We carpeted the living room to make it cozier in winter. |
| 4098 | désodoriser | désodorisé | Elle a désodorisé la voiture avec un spray parfumé au citron. | She deodorized the car with a lemon-scented spray. |
| 4100 | réimplanter | réimplanté | Le chirurgien a réimplanté le doigt sectionné quelques heures après l'accident. | The surgeon reimplanted the severed finger a few hours after the accident. |
| 4102 | asphalter | asphalté | Ils ont asphalté la nouvelle route la semaine dernière. | They asphalted the new road last week. |
| 4103 | dessouder | dessoudé | Le technicien a dessoudé le composant défectueux de la carte électronique. | The technician unsoldered the faulty component from the circuit board. |
| 4104 | phosphater | phosphate | L'usine phosphate les métaux pour les protéger de la corrosion. | The factory phosphates metals to protect them from corrosion. |
| 4105 | constiper | constiper | Ce médicament peut constiper certains patients s'il est pris trop longtemps. | This medication can constipate some patients if taken for too long. |
| 4109 | subodorer | subodore | Le vieux chasseur subodore la présence d'un renard près du poulailler. | The old hunter senses the presence of a fox near the henhouse. |
| 4110 | réfréner | réfréner | Elle a dû réfréner son envie de rire pendant la réunion sérieuse. | She had to curb her urge to laugh during the serious meeting. |
| 4111 | retraduire | retraduire | Le traducteur a dû retraduire le roman entier après la perte du premier manuscrit. | The translator had to retranslate the entire novel after the first manuscript was lost. |
| 4115 | intellectualiser | intellectualise | Il intellectualise trop ses émotions au lieu de les vivre simplement. | He intellectualizes his emotions too much instead of simply experiencing them. |
| 4118 | mégir | mégi | L'artisan a mégi la peau de chèvre avant de la travailler en gants souples. | The craftsman tawed the goatskin before working it into soft gloves. |
| 4120 | taguer | tagué | Des adolescents ont tagué le mur de l'école pendant la nuit. | Teenagers tagged the school wall during the night. |
| 4121 | nécroser | nécroser | L'infection a fini par nécroser une partie du tissu musculaire. | The infection eventually caused part of the muscle tissue to necrose. |
| 4122 | refourguer | refourguer | Le vendeur a essayé de me refourguer une vieille voiture rouillée. | The salesman tried to foist an old rusty car on me. |
| 4126 | chalouper | chaloupe | Elle chaloupe légèrement en marchant sur le trottoir, comme au rythme d'une musique. | She sways gently as she walks down the sidewalk, as if to the rhythm of music. |
| 4127 | taillader | taillade | Le boucher taillade la viande avec un grand couteau. | The butcher slashes the meat with a large knife. |
| 4128 | contorsionner | contorsionne | Le clown se contorsionne pour amuser les enfants. | The clown contorts himself to amuse the children. |
| 4129 | siphonner | siphonne | Le mécanicien siphonne l'essence du réservoir pour vider la voiture. | The mechanic siphons the gasoline out of the tank to empty the car. |
| 4131 | crocher | croche | Le pêcheur croche le poisson avec un grand harpon. | The fisherman hooks the fish with a large harpoon. |
| 4132 | nervurer | nervurer | L'architecte a fait nervurer la voûte de la cathédrale pour renforcer sa structure. | The architect had the cathedral's vault ribbed to reinforce its structure. |
| 4133 | élimer | s'élime | Ce vieux pull s'élime à force d'être porté tous les jours. | This old sweater is wearing out from being worn every day. |
| 4134 | marbrer | marbre | Le peintre marbre le papier pour imiter les veines du marbre véritable. | The painter marbles the paper to imitate the veins of real marble. |
| 4138 | vieller | vielle | Le musicien vielle sur la place du village chaque dimanche. | The musician plays the vielle in the village square every Sunday. |
| 4139 | harnacher | harnache | Le palefrenier harnache le cheval avant la longue course. | The groom harnesses the horse before the long ride. |
| 4141 | confluer | confluent | Les deux rivières confluent près du petit village. | The two rivers merge near the small village. |
| 4142 | sélecter | sélecte | Le comité sélecte les meilleurs candidats pour l'entretien final. | The committee selects the best candidates for the final interview. |
| 4145 | ébruiter | ébruité | Le journaliste a ébruité le scandale avant la conférence de presse. | The journalist leaked the scandal before the press conference. |
| 4146 | pinailler | pinailler | Arrête de pinailler sur des détails qui n'ont aucune importance. | Stop nitpicking over details that don't matter at all. |
| 4148 | dévitaliser | dévitaliser | Le dentiste doit dévitaliser cette dent infectée. | The dentist needs to perform a root canal on this infected tooth. |
| 4149 | braconner | braconné | Des chasseurs ont braconné dans la réserve naturelle pendant la nuit. | Poachers hunted illegally in the nature reserve during the night. |
| 4150 | dépolir | dépoli | L'artisan a dépoli la vitre pour laisser entrer la lumière sans montrer l'intérieur. | The craftsman frosted the glass pane so light could enter without revealing the interior. |
| 4151 | particulariser | particularise | L'historien particularise son analyse en citant des exemples précis. | The historian particularizes his analysis by citing specific examples. |
| 4152 | déminéraliser | déminéralise | L'usine déminéralise l'eau avant de l'utiliser dans les chaudières. | The plant demineralizes the water before using it in the boilers. |
| 4153 | déminer | démine | L'armée démine le champ avant l'arrivée des civils. | The army clears the mines from the field before civilians arrive. |
| 4158 | bourlinguer | bourlingué | Ce vieux marin a bourlingué pendant des années avant de s'installer à terre. | This old sailor roamed the seas for years before settling down on land. |
| 4159 | bourgeonner | bourgeonnent | Les arbres bourgeonnent dès les premiers jours du printemps. | The trees bud as soon as the first days of spring arrive. |
| 4161 | conscientiser | conscientiser | Cette campagne vise à conscientiser le public aux dangers du tabac. | This campaign aims to make the public aware of the dangers of tobacco. |
| 4163 | américaniser | américanisé | Le fast-food a rapidement américanisé les habitudes alimentaires du pays. | Fast food quickly Americanized the country's eating habits. |
| 4164 | étatiser | étatiser | Le gouvernement a décidé d'étatiser les chemins de fer après la guerre. | The government decided to nationalize the railways after the war. |
| 4166 | recorder | recordait | Le comédien recordait son texte chaque soir avant la représentation. | The actor rehearsed his lines aloud every evening before the show. |
| 4168 | déprogrammer | déprogrammé | La chaîne a déprogrammé l'émission après la polémique. | The network pulled the show off the air after the controversy. |
| 4169 | rançonner | rançonné | Les pirates ont rançonné le marchand avant de le libérer. | The pirates held the merchant for ransom before releasing him. |
| 4173 | décoincer | décoincer | Il a versé de l'huile pour décoincer la vieille serrure. | He poured oil to unjam the old lock. |
| 4175 | rouspéter | rouspété | Les clients ont rouspété contre les prix trop élevés du restaurant. | The customers grumbled about the restaurant's overly high prices. |
| 4178 | gélifier | gélifier | Le sucre aide à gélifier la confiture pendant la cuisson. | Sugar helps the jam gel during cooking. |
| 4179 | fringuer | fringuer | Elle adore fringuer ses enfants avec des vêtements colorés. | She loves dressing her kids in colorful clothes. |
| 4181 | exciser | exciser | Le chirurgien a dû exciser la tumeur avant qu'elle ne se propage. | The surgeon had to excise the tumor before it could spread. |
| 4185 | léviter | léviter | Le magicien prétendait pouvoir léviter au-dessus de la scène. | The magician claimed he could levitate above the stage. |
| 4189 | chlorurer | chlorure | On chlorure l'eau de la piscine pour éliminer les bactéries. | The pool water is chlorinated to eliminate bacteria. |
| 4191 | tempêter | tempêté | Le client a tempêté contre le vendeur après avoir reçu un colis endommagé. | The customer ranted at the salesman after receiving a damaged package. |
| 4192 | bridger | bridger | Mes grands-parents aiment bridger tous les vendredis soir avec leurs voisins. | My grandparents love playing bridge with their neighbors every Friday evening. |
| 4194 | bruler | bruler | Elle a laissé bruler le riz pendant qu'elle répondait au téléphone. | She let the rice burn while she was answering the phone. |
| 4195 | transmuer | transmuer | L'alchimiste rêvait de transmuer le plomb en or. | The alchemist dreamed of transmuting lead into gold. |
| 4197 | mathématiser | mathématisent | Les économistes mathématisent les comportements humains pour mieux les comprendre. | Economists mathematize human behavior in order to understand it better. |
| 4201 | jacter | jactent | Les copains jactent pendant des heures au café sans jamais se lasser. | The friends chat for hours at the café without ever getting tired. |
| 4203 | colleter | colleté | Le videur a colleté le jeune homme qui refusait de sortir du bar. | The bouncer collared the young man who refused to leave the bar. |
| 4204 | dropper | dropper | Ils ont décidé de dropper cette affaire après plusieurs mois d'enquête infructueuse. | They decided to drop the case after several months of fruitless investigation. |
| 4207 | rougeoyer | rougeoyaient | Les braises du feu de camp rougeoyaient encore au petit matin. | The campfire's embers were still glowing red at dawn. |
| 4208 | réabonner | réabonné | Après un an sans le lire, il a réabonné toute sa famille au journal local. | After a year without reading it, he resubscribed his whole family to the local paper. |
| 4209 | délégitimer | délégitimer | Certains hommes politiques cherchent à délégitimer les résultats de l'élection sans preuve. | Some politicians try to delegitimize the election results without any evidence. |
| 4210 | opacifier | opacifie | Le brouillard opacifie complètement le pare-brise en quelques secondes. | The fog completely opacifies the windshield within seconds. |
| 4211 | décroiser | décroisé | Elle a décroisé les bras pour applaudir à la fin du spectacle. | She uncrossed her arms to applaud at the end of the show. |
| 4212 | zigouiller | zigouiller | Dans le film, le tueur menace de zigouiller tous les témoins. | In the movie, the killer threatens to bump off all the witnesses. |
| 4214 | noyauter | noyauter | Des agents étrangers ont tenté de noyauter le syndicat pour orienter ses décisions. | Foreign agents tried to infiltrate the union to steer its decisions. |
| 4216 | pendouiller | pendouillait | Un fil électrique pendouillait dangereusement au-dessus de la rue après la tempête. | An electrical wire was dangling dangerously above the street after the storm. |
| 4217 | décaisser | décaisser | La banque va décaisser les fonds dès que le contrat sera signé. | The bank will pay out the funds as soon as the contract is signed. |
| 4220 | supplémenter | supplémenter | Les médecins recommandent de supplémenter son alimentation en vitamine D pendant l'hiver. | Doctors recommend supplementing your diet with vitamin D during the winter. |
| 4221 | raller | ralle | Chaque automne, le cerf ralle dans la forêt pour attirer les biches. | Every autumn, the stag roars in the forest to attract the does. |
| 4222 | hâler | hâlé | Après deux semaines de vacances au Portugal, le soleil lui avait bien hâlé la peau. | After two weeks of vacation in Portugal, the sun had given her a nice tan. |
| 4223 | granuler | granule | L'usine granule le sucre avant de l'emballer pour la vente. | The factory granulates the sugar before packaging it for sale. |
| 4226 | décommander | décommander | Ils ont dû décommander la réunion à la dernière minute à cause de la neige. | They had to cancel the meeting at the last minute because of the snow. |
| 4230 | musarder | musardé | Nous avons musardé tout l'après-midi dans les petites rues du vieux village. | We dawdled all afternoon through the little streets of the old village. |
| 4232 | enrubanner | enrubanné | Elle a enrubanné le cadeau avant de l'offrir à sa sœur. | She wrapped the gift in ribbon before giving it to her sister. |
| 4233 | crapahuter | crapahuter | Les randonneurs ont dû crapahuter pendant des heures sur ce sentier rocailleux. | The hikers had to tramp for hours along that rocky trail. |
| 4235 | canneler | cannelé | Le menuisier a cannelé les colonnes en bois pour leur donner un aspect classique. | The carpenter fluted the wooden columns to give them a classical look. |
| 4236 | penduler | pendule | Chaque jour, elle pendule entre sa maison en banlieue et son bureau au centre-ville. | Every day, she commutes between her house in the suburbs and her office downtown. |
| 4237 | renfrogner | se renfrogna | En entendant la mauvaise nouvelle, il se renfrogna aussitôt. | On hearing the bad news, he immediately scowled. |
| 4240 | filigraner | filigrané | L'orfèvre a filigrané un bracelet en argent avec une extrême finesse. | The goldsmith filigreed a silver bracelet with extreme delicacy. |
| 4245 | reboiser | reboiser | Le gouvernement prévoit de reboiser plusieurs hectares détruits par l'incendie l'année dernière. | The government plans to reforest several hectares destroyed by last year's fire. |
| 4246 | boulotter | boulotté | Les enfants ont boulotté toute la tarte aux pommes en dix minutes. | The kids scarfed down the whole apple pie in ten minutes. |
| 4248 | ornementer | ornementé | Elle a ornementé la façade de la maison avec des sculptures en pierre. | She ornamented the house's façade with stone carvings. |
| 4249 | rainurer | rainuré | Le menuisier a rainuré la planche pour y insérer un panneau. | The carpenter grooved the board to fit in a panel. |
| 4250 | radiographier | radiographié | Le médecin a radiographié le bras du patient pour vérifier s'il était cassé. | The doctor X-rayed the patient's arm to check whether it was broken. |
| 4252 | arabiser | arabiser | Le gouvernement a tenté d'arabiser l'administration après l'indépendance. | The government tried to Arabize the administration after independence. |
| 4253 | fliquer | fliquer | Le nouveau chef veut fliquer les employés en installant des caméras partout. | The new boss wants to police the employees by installing cameras everywhere. |
| 4256 | catéchiser | catéchisait | Le prêtre catéchisait les jeunes enfants tous les dimanches après la messe. | The priest catechized the young children every Sunday after Mass. |
| 4257 | convoler | convoler | Après des années de vie commune, ils ont enfin décidé de convoler. | After years of living together, they finally decided to get married. |
| 4259 | braser | brasé | Le plombier a brasé les tuyaux en cuivre pour éviter toute fuite. | The plumber brazed the copper pipes to prevent any leaks. |
| 4260 | détartrer | détartrer | Il faut détartrer la bouilloire régulièrement pour qu'elle fonctionne bien. | You need to descale the kettle regularly for it to work well. |
| 4261 | désertifier | désertifie | Cette région se désertifie rapidement à cause du changement climatique. | This region is rapidly desertifying because of climate change. |
| 4262 | surjouer | surjoué | L'acteur a un peu trop surjoué la scène de mort, ce qui a fait rire le public. | The actor overplayed the death scene a bit too much, which made the audience laugh. |
| 4263 | réarranger | réarrangé | Elle a réarrangé les meubles du salon pour créer plus d'espace. | She rearranged the living room furniture to create more space. |
| 4264 | suturer | suturé | Le chirurgien a suturé la plaie après l'opération. | The surgeon sutured the wound after the operation. |
| 4265 | capeler | capelé | Le marin a capelé l'aussière sur la bitte d'amarrage avant le départ. | The sailor looped the hawser over the mooring bollard before departure. |
| 4267 | dégazer | dégaze | Le mécanicien dégaze le réservoir avant de le réparer. | The mechanic degases the tank before repairing it. |
| 4269 | désintoxiquer | désintoxiquer | Le centre médical va désintoxiquer les patients dépendants aux opioïdes en six semaines. | The medical center will detoxify patients addicted to opioids over six weeks. |
| 4270 | sprinter | sprinte | Le coureur sprinte sur les cent derniers mètres pour gagner la course. | The runner sprints over the last hundred meters to win the race. |
| 4277 | copuler | copulent | Ces animaux copulent uniquement au printemps pour se reproduire. | These animals copulate only in spring to reproduce. |
| 4279 | rabrouer | rabroué | Le patron a rabroué son employé devant tout le monde pour une simple erreur. | The boss snubbed his employee in front of everyone over a simple mistake. |
| 4281 | aniser | anise | Le pâtissier anise la pâte pour donner un goût de réglisse au biscuit. | The pastry chef flavors the dough with aniseed to give the cookie a licorice taste. |
| 4282 | recaser | recaser | L'entreprise a réussi à recaser tous les employés licenciés dans d'autres services. | The company managed to relocate all the laid-off employees to other departments. |
| 4283 | défraîchir | défraîchir | Le soleil a fini par défraîchir les rideaux de la vitrine. | The sun eventually caused the shop window curtains to fade. |
| 4284 | écrêter | écrêter | Le barrage permet d'écrêter les crues du fleuve pendant la saison des pluies. | The dam makes it possible to clip the river's flood peaks during the rainy season. |
| 4285 | entuber | entubé | Le vendeur a entubé son client en lui vendant une voiture accidentée. | The salesman swindled his customer by selling him a wrecked car. |
| 4286 | démythifier | démythifier | Ce documentaire cherche à démythifier l'image du cow-boy américain. | This documentary seeks to debunk the myth of the American cowboy. |
| 4287 | déqualifier | déqualifier | L'automatisation a fini par déqualifier de nombreux ouvriers de l'usine. | Automation ended up deskilling many of the factory's workers. |
| 4288 | promotionner | promotionner | La marque a dépensé beaucoup d'argent pour promotionner son nouveau produit. | The brand spent a lot of money to promote its new product. |
| 4290 | entrapercevoir | entraperçu | À travers la foule, j'ai entraperçu mon ancien professeur de mathématiques. | Through the crowd, I caught a glimpse of my old math teacher. |
| 4291 | vocaliser | vocalise | La chanteuse vocalise pendant vingt minutes avant chaque concert. | The singer vocalizes for twenty minutes before every concert. |
| 4292 | marcotter | marcotte | Le jardinier marcotte le rosier pour obtenir de nouveaux plants. | The gardener layers the rosebush to produce new plants. |
| 4296 | pelleter | pelleter | Chaque hiver, il faut pelleter la neige devant la porte du garage. | Every winter, you have to shovel the snow in front of the garage door. |
| 4298 | canner | canner | Le pauvre gars a bien failli canner hier soir. | The poor guy nearly kicked the bucket last night. |
| 4299 | trianguler | trianguler | Les ingénieurs ont dû trianguler la position exacte du signal perdu. | The engineers had to triangulate the exact position of the lost signal. |
| 4300 | exciper | excipé | L'avocat a excipé de la prescription pour faire rejeter la plainte. | The lawyer pleaded the statute of limitations to have the complaint dismissed. |
| 4302 | arpéger | arpège | Elle arpège lentement les accords en jouant du piano. | She slowly arpeggiates the chords as she plays the piano. |
| 4305 | désendetter | se désendetter | Le pays doit se désendetter rapidement pour rassurer les marchés financiers. | The country must quickly deleverage itself to reassure the financial markets. |
| 4306 | déjuger | se déjuger | Le juge a refusé de se déjuger malgré les nouvelles preuves présentées. | The judge refused to reverse his ruling despite the new evidence presented. |
| 4307 | désocialiser | désocialiser | L'isolement prolongé peut désocialiser une personne au fil des années. | Prolonged isolation can desocialize a person over the years. |
| 4312 | désassembler | désassemblé | Le technicien a désassemblé l'ordinateur pour remplacer le disque dur. | The technician disassembled the computer to replace the hard drive. |
| 4316 | baraquer | baraquer | Le colonel a fait baraquer les soldats dans le village voisin pour la nuit. | The colonel had the soldiers billeted in the nearby village for the night. |
| 4318 | saucissonner | saucissonne | Le boucher saucissonne le rôti en tranches fines pour les clients. | The butcher slices the roast into thin pieces for customers. |
| 4319 | charcuter | charcuté | Le chirurgien amateur a charcuté le patient pendant l'opération improvisée. | The amateur surgeon butchered the patient during the improvised operation. |
| 4320 | déplafonner | déplafonner | Le gouvernement a décidé de déplafonner les cotisations sociales pour les hauts salaires. | The government decided to remove the cap on social security contributions for high earners. |
| 4321 | déneiger | déneigent | Les employés municipaux déneigent les rues dès la première tempête de l'hiver. | City workers clear the snow from the streets as soon as the first winter storm hits. |
| 4322 | égrapper | égrappe | Le vigneron égrappe le raisin avant de le presser. | The winemaker destems the grapes before pressing them. |
| 4324 | boudiner | boudine | Cette robe trop ajustée boudine complètement sa silhouette. | This overly tight dress squeezes her figure like a sausage. |
| 4325 | décélérer | décélère | Le train décélère en approchant de la gare. | The train slows down as it approaches the station. |
| 4327 | surpiquer | surpique | La couturière surpique les bords de la veste pour un fini plus solide. | The seamstress overstitches the edges of the jacket for a sturdier finish. |
| 4331 | armorier | armorier | Le roi a fait armorier le bouclier du chevalier avec les armes de sa famille. | The king had the knight's shield emblazoned with his family's coat of arms. |
| 4333 | briquer | brique | Le marin brique le pont du navire tous les matins avant le lever du soleil. | The sailor scrubs the ship's deck every morning before sunrise. |
| 4335 | relouer | reloue | Le propriétaire reloue l'appartement dès que les anciens locataires partent. | The landlord relets the apartment as soon as the previous tenants leave. |
| 4337 | ergoter | ergotent | Les avocats ergotent sur des détails insignifiants depuis des heures. | The lawyers have been quibbling over insignificant details for hours. |
| 4338 | entre-manger | s'entre-manger | Les deux poissons affamés finissent par s'entre-manger dans le bocal. | The two starving fish end up eating each other in the bowl. |
| 4339 | anémier | anémier | Ce régime trop pauvre en fer risque d'anémier les jeunes enfants. | This iron-poor diet risks making young children anemic. |
| 4340 | déboiser | déboiser | Les habitants ont dû déboiser la colline pour construire de nouvelles maisons. | The residents had to clear the forest from the hill to build new houses. |
| 4342 | entrebâiller | entrebâille | Elle entrebâille la porte pour vérifier que les enfants dorment bien. | She opens the door slightly to check that the children are sleeping soundly. |
| 4344 | cravacher | cravache | Le jockey cravache son cheval dans les derniers mètres de la course. | The jockey whips his horse in the final stretch of the race. |
| 4345 | picoter | picotait | Le vin blanc lui picotait la langue à chaque gorgée. | The white wine tingled on her tongue with every sip. |
| 4346 | dialyser | dialyse | Le médecin dialyse le patient trois fois par semaine à l'hôpital. | The doctor dialyzes the patient three times a week at the hospital. |
| 4351 | désinhiber | désinhiber | Un verre de vin suffit parfois à désinhiber les invités les plus timides. | A glass of wine is sometimes enough to disinhibit the shyest guests. |
| 4352 | cuiter | cuité | Il s'est cuité à la fête hier soir et a raté son cours ce matin. | He got wasted at the party last night and missed his class this morning. |
| 4353 | défenestrer | défenestré | Dans la légende, les rebelles ont défenestré les conseillers du château. | According to legend, the rebels threw the councilors out of the castle window. |
| 4354 | rembobiner | rembobine | Il rembobine la cassette avant de la ranger dans sa boîte. | He rewinds the cassette before putting it back in its case. |
| 4355 | poinçonner | poinçonne | L'orfèvre poinçonne chaque bijou en argent avant de le vendre. | The silversmith hallmarks each silver piece of jewelry before selling it. |
| 4356 | claustrer | claustrer | On a dû claustrer le patient contagieux dans une chambre isolée. | They had to confine the contagious patient to an isolated room. |
| 4357 | rainer | raine | Le menuisier raine la planche avant d'y insérer une autre pièce de bois. | The carpenter grooves the board before fitting another piece of wood into it. |
| 4360 | alphabétiser | alphabétise | Cette association bénévole alphabétise des adultes immigrés chaque soir. | This volunteer association teaches immigrant adults to read and write every evening. |
| 4363 | raquer | raquer | Il a fini par raquer pour réparer la voiture qu'il avait abîmée. | He ended up paying up to fix the car he had damaged. |
| 4365 | suréquiper | suréquipent | Certaines familles suréquipent leur cuisine d'appareils qu'elles n'utilisent jamais. | Some families overequip their kitchen with appliances they never use. |
| 4366 | désaccorder | désaccorder | L'humidité a fini par désaccorder complètement le piano du salon. | The humidity eventually put the living-room piano completely out of tune. |
| 4367 | désinvestir | désinvestir | L'entreprise a décidé de désinvestir ce secteur peu rentable. | The company decided to divest from this unprofitable sector. |
| 4368 | canarder | canardaient | Les snipers canardaient les soldats depuis les toits environnants. | The snipers were sniping at the soldiers from the surrounding rooftops. |
| 4371 | enficher | enficher | Il suffit d'enficher le câble USB dans le port pour démarrer le transfert. | Just plug the USB cable into the port to start the transfer. |
| 4372 | carrosser | carrosse | Le carrossier carrosse la nouvelle voiture avant sa mise en vente. | The coachbuilder fits a body onto the new car before it goes on sale. |
| 4374 | aléser | alèse | Le mécanicien alèse le cylindre pour l'ajuster au nouveau piston. | The mechanic reams the cylinder to fit the new piston. |
| 4375 | adjurer | adjure | Le prêtre adjure le démon de quitter le corps du possédé. | The priest adjures the demon to leave the possessed man's body. |
| 4376 | réexporter | réexporte | Le pays réexporte le pétrole brut importé après un léger raffinage. | The country reexports imported crude oil after light refining. |
| 4378 | cauchemarder | cauchemardé | Le petit garçon a cauchemardé toute la nuit après avoir vu ce film d'horreur. | The little boy had nightmares all night after watching that horror movie. |
| 4382 | moufter | moufter | Malgré l'injustice de la décision, personne n'a osé moufter. | Despite the unfairness of the decision, nobody dared say a word. |
| 4383 | précompter | précompter | L'employeur va précompter les cotisations sociales sur le salaire brut. | The employer will deduct social security contributions from the gross salary. |
| 4384 | fanfaronner | fanfaronner | Il aime fanfaronner devant ses amis après chaque victoire au tennis. | He loves to boast in front of his friends after every tennis win. |
| 4385 | lambrisser | lambrissé | Les menuisiers ont lambrissé le salon avec du bois de chêne clair. | The carpenters paneled the living room with light oak wood. |
| 4387 | biler | bile | Ne te bile pas pour l'examen, tu es très bien préparé. | Don't worry about the exam, you're very well prepared. |
| 4388 | saquer | saqué | Le patron a saqué trois employés à cause de la crise économique. | The boss sacked three employees because of the economic crisis. |
| 4389 | cousiner | cousinent | Nos deux familles cousinent depuis des années, se retrouvant à chaque fête. | Our two families have gotten along famously for years, meeting up at every celebration. |
| 4390 | déféquer | déféqué | Le chien a déféqué sur le trottoir devant chez moi. | The dog defecated on the sidewalk in front of my house. |
| 4392 | décompacter | décompacter | Il faut décompacter l'archive avant d'installer le logiciel. | You need to uncompress the archive before installing the software. |
| 4393 | boursoufler | boursoufler | La chaleur a fait boursoufler la peinture sur le mur extérieur. | The heat made the paint on the outside wall blister and swell. |
| 4395 | déstocker | déstocker | Le magasin va déstocker ses vieux modèles avant les soldes d'été. | The store is going to clear its old stock before the summer sales. |
| 4396 | nitrater | nitratent | Les agriculteurs nitratent leurs champs pour améliorer le rendement des cultures. | Farmers nitrate their fields to improve crop yields. |
| 4397 | châtaigner | châtaigné | Le boxeur a châtaigné son adversaire d'un crochet du droit. | The boxer landed a punch on his opponent with a right hook. |
| 4400 | razzier | razzié | Les pillards ont razzié le village avant l'aube. | The raiders raided the village before dawn. |
| 4402 | boubouler | bouboule | Le hibou bouboule doucement dans l'obscurité de la forêt. | The owl hoots softly in the darkness of the forest. |
| 4404 | repayer | repayer | Le client a dû repayer sa facture après une erreur bancaire. | The customer had to pay again after a banking error. |
| 4405 | ariser | arise | Le marin arise la grand-voile avant que la tempête n'arrive. | The sailor reefs the mainsail before the storm arrives. |
| 4407 | cafouiller | cafouille | L'imprimante cafouille encore et personne ne sait pourquoi. | The printer is glitching again and nobody knows why. |
| 4408 | moiser | moise | Le charpentier moise la poutre pour renforcer la structure du toit. | The carpenter braces the beam to reinforce the roof structure. |
| 4409 | géminer | géminé | Le typographe a géminé la consonne pour respecter la règle d'orthographe. | The typesetter doubled the consonant to follow the spelling rule. |
| 4410 | matricer | matrice | Le studio matrice le film juste avant sa sortie en salles. | The studio dubs the film just before its theatrical release. |
| 4411 | caréner | carène | Le chantier naval carène le voilier pour l'été prochain. | The shipyard is careening the sailboat in preparation for next summer. |
| 4412 | statufier | statufié | On a statufié le fondateur de l'entreprise devant le siège social. | They erected a statue of the company's founder in front of headquarters. |
| 4414 | balafrer | balafré | Le duel l'a balafré profondément sur la joue gauche. | The duel left him with a deep scar on his left cheek. |
| 4415 | désillusionner | désillusionné | Le film m'a désillusionné en trahissant l'esprit du roman original. | The film disillusioned me by betraying the spirit of the original novel. |
| 4416 | surimposer | surimposer | Le gouvernement a décidé de surimposer les revenus les plus élevés. | The government decided to overtax the highest incomes. |
| 4417 | mâchouiller | mâchouille | Le chien mâchouille son jouet en caoutchouc toute la journée. | The dog chews on its rubber toy all day long. |
| 4418 | toréer | toréer | Le jeune matador rêve de toréer dans les plus grandes arènes d'Espagne. | The young matador dreams of fighting bulls in Spain's biggest arenas. |
| 4419 | horripiler | horripile | Son habitude de couper la parole horripile tout le monde en réunion. | His habit of interrupting people exasperates everyone at meetings. |
| 4420 | peroxyder | peroxydé | La coiffeuse a peroxydé ses cheveux pour obtenir un blond platine. | The hairdresser bleached her hair to get a platinum blonde color. |
| 4422 | arraisonner | arraisonné | Les garde-côtes ont arraisonné le navire suspecté de trafic de drogue. | The coast guard boarded and inspected the ship suspected of drug trafficking. |
| 4423 | édenter | édenté | Le coup de poing l'a édenté d'un coup. | The punch knocked his teeth out in one blow. |
| 4426 | enguirlander | enguirlandé | Le patron l'a enguirlandé devant tout le monde à cause de son retard. | The boss told him off in front of everyone because of his lateness. |
| 4427 | efféminer | efféminait | Certains critiques jugeaient que la mode des années soixante efféminait les hommes. | Some critics felt that sixties fashion made men effeminate. |
| 4429 | épiner | épine | Le jardinier épine les jeunes rosiers pour les protéger des lapins. | The gardener hedges the young rose bushes with thorny branches to protect them from rabbits. |
| 4431 | anodiser | anodisent | Les techniciens anodisent les pièces en aluminium pour les protéger de la corrosion. | The technicians anodize the aluminum parts to protect them from corrosion. |
| 4432 | double-cliquer | Double-cliquez | Double-cliquez sur l'icône pour ouvrir le dossier. | Double-click the icon to open the folder. |
| 4435 | éperonner | éperonne | Le cavalier éperonne son cheval pour franchir la rivière plus vite. | The rider spurs his horse to cross the river faster. |
| 4437 | sasser | sasse | La meunière sasse la farine pour enlever les grumeaux. | The miller sifts the flour to remove the lumps. |
| 4438 | ébouriffer | ébouriffé | Le vent a ébouriffé ses cheveux pendant la promenade. | The wind ruffled her hair during the walk. |
| 4439 | magouiller | magouillé | Les élus ont magouillé pour truquer le résultat du vote. | The officials schemed to rig the vote's outcome. |
| 4444 | enfariner | enfarine | Le boulanger enfarine le plan de travail avant de pétrir la pâte. | The baker flours the countertop before kneading the dough. |
| 4445 | dégivrer | dégivre | Le matin, elle dégivre le pare-brise avant de partir travailler. | In the morning, she de-ices the windshield before leaving for work. |
| 4448 | inséminer | insémine | Le vétérinaire insémine la vache pour féconder le troupeau. | The veterinarian inseminates the cow to breed the herd. |
| 4450 | érailler | éraillé | Le chat a éraillé le tissu du canapé avec ses griffes. | The cat scratched (frayed) the couch fabric with its claws. |
| 4452 | scratcher | scratché | En rangeant sa planche à roulettes, il a scratché le plancher du garage. | While putting away his skateboard, he scratched the garage floor. |
| 4453 | préjudicier | préjudicie | Ce retard ne préjudicie en rien à l'avancement du projet. | This delay in no way prejudices the project's progress. |
| 4456 | ameublir | ameublit | Le jardinier ameublit la terre avant de planter les légumes. | The gardener loosens the soil before planting the vegetables. |
| 4458 | siniser | siniser | Le gouvernement cherche à siniser les minorités du Xinjiang. | The government is seeking to sinicize the minorities of Xinjiang. |
| 4459 | suralimenter | suralimenter | Les parents ne doivent pas suralimenter leur bébé pendant les premiers mois. | Parents should not overfeed their baby during the first few months. |
| 4461 | flexibiliser | flexibiliser | L'entreprise veut flexibiliser les horaires de travail de ses employés. | The company wants to make its employees' work hours more flexible. |
| 4463 | zinguer | zingue | Le couvreur zingue la toiture pour la protéger de la rouille. | The roofer covers the roof with zinc to protect it from rust. |
| 4464 | solubiliser | solubilise | Ce détergent solubilise les graisses dans l'eau chaude. | This detergent solubilizes fats in hot water. |
| 4465 | filialiser | filialiser | Le groupe a décidé de filialiser sa division informatique. | The group decided to spin off its IT division as a subsidiary. |
| 4466 | quintupler | quintuplé | L'entreprise a quintuplé son chiffre d'affaires en cinq ans. | The company quintupled its revenue in five years. |
| 4470 | sodomiser | sodomise | La loi punit sévèrement quiconque sodomise une personne sans son consentement. | The law severely punishes anyone who sodomizes a person without their consent. |
| 4472 | lyser | lyse | L'enzyme lyse la paroi des bactéries pour les détruire. | The enzyme lyses the bacterial cell wall to destroy them. |
| 4473 | catastropher | catastrophé | La nouvelle de son licenciement l'a catastrophé. | The news of his layoff left him staggered. |
| 4474 | locher | loche | En Normandie, on dit qu'on loche le pommier pour faire tomber les pommes. | In Normandy, they say you 'loche' the apple tree to shake the apples down. |
| 4475 | chouiner | chouiner | Arrête de chouiner pour un si petit bobo! | Stop whining over such a little scrape! |
| 4476 | sous-exposer | sous-exposé | Le photographe a sous-exposé la photo pour accentuer les ombres. | The photographer underexposed the photo to emphasize the shadows. |
| 4477 | décrépir | décrépi | Les ouvriers ont décrépi le vieux mur avant de le repeindre. | The workers stripped the old wall of its roughcast before repainting it. |
| 4479 | maroufler | marouflé | Le restaurateur a marouflé la vieille toile sur un support neuf avant de l'exposer. | The restorer glued the old canvas onto a new backing before putting it on display. |
| 4481 | équarrir | équarrit | Le boucher équarrit la carcasse avant de la vendre. | The butcher quarters the carcass before selling it. |
| 4483 | ligaturer | ligature | Le chirurgien ligature l'artère pour arrêter le saignement. | The surgeon ligates the artery to stop the bleeding. |
| 4484 | dépersonnaliser | dépersonnaliser | Le stress au travail peut dépersonnaliser les employés jusqu'à l'épuisement. | Work stress can depersonalize employees to the point of burnout. |
| 4489 | réimporter | réimporte | La société réimporte ces pièces après les avoir fait réparer à l'étranger. | The company reimports these parts after having them repaired abroad. |
| 4490 | centrifuger | centrifuge | Le laboratoire centrifuge les échantillons de sang pour séparer le plasma. | The lab centrifuges the blood samples to separate out the plasma. |
| 4492 | parcelliser | parcellisé | Le promoteur a parcellisé le grand terrain pour le vendre plus facilement. | The developer parceled out the large plot of land to make it easier to sell. |
| 4493 | latiniser | latinisé | Les Romains ont latinisé de nombreuses tribus gauloises au fil des siècles. | The Romans Latinized many Gallic tribes over the centuries. |
| 4494 | dépatouiller | dépatouillé | Il s'est dépatouillé tout seul pour réparer la voiture en panne. | He managed to muddle through and fix the broken-down car all by himself. |
| 4496 | réembaucher | réembauché | L'usine a réembauché les ouvriers licenciés l'année précédente. | The factory rehired the workers who had been laid off the previous year. |
| 4497 | buriner | burine | L'artiste burine patiemment la plaque de cuivre pour créer une gravure. | The artist patiently chisels the copper plate to create an engraving. |
| 4498 | silhouetter | silhouette | Le photographe silhouette les arbres contre le soleil couchant. | The photographer silhouettes the trees against the setting sun. |
| 4499 | contrefoutre | contrefout | Il s'en contrefout complètement de ce que les autres pensent de lui. | He couldn't care less what other people think of him. |
| 4500 | mégoter | mégoter | Il ne faut pas mégoter sur la qualité des ingrédients pour ce plat. | You shouldn't skimp on the quality of the ingredients for this dish. |
| 4501 | gauler | gaule | Chaque automne, il gaule les noix pour les faire tomber de l'arbre. | Every autumn, he knocks the walnuts down from the tree with a pole. |
| 4502 | arc-bouter | arc-boutent | Les arcs-boutants arc-boutent les murs de la cathédrale gothique. | The flying buttresses buttress the walls of the Gothic cathedral. |
| 4503 | sous-employer | sous-emploie | Cette entreprise sous-emploie ses ingénieurs les plus qualifiés. | This company underutilizes its most qualified engineers. |
| 4505 | barrir | barrit | L'éléphant barrit bruyamment en apercevant les lions au loin. | The elephant trumpets loudly upon spotting the lions in the distance. |
| 4507 | pouponner | pouponner | Depuis la naissance de sa petite-fille, elle adore pouponner tous les après-midi. | Ever since her granddaughter was born, she loves fussing over the baby every afternoon. |
| 4508 | macler | macle | L'ouvrier macle le verre en fusion avec une barre de fer pour l'homogénéiser. | The worker stirs the molten glass with an iron rod to make it uniform. |
| 4509 | mapper | mappe | Le logiciel mappe automatiquement les touches du clavier selon vos préférences. | The software automatically maps the keyboard keys according to your preferences. |
| 4510 | revisser | revissé | Il a revissé le couvercle du bocal après avoir goûté la confiture. | He screwed the lid back onto the jar after tasting the jam. |
| 4513 | clapir | clapit | Le lapin apeuré clapit soudainement dans son terrier. | The frightened rabbit suddenly cries out in its burrow. |
| 4514 | émulsifier | émulsifie | Le chef émulsifie l'huile et le vinaigre pour préparer la vinaigrette. | The chef emulsifies the oil and vinegar to make the vinaigrette. |
| 4516 | appointer | appointe | Le vieil homme appointe son crayon avant de dessiner le portrait. | The old man sharpens his pencil before drawing the portrait. |
| 4517 | réciproquer | réciproquer | Il m'a offert un cadeau, alors j'ai voulu réciproquer son geste. | He gave me a gift, so I wanted to reciprocate the gesture. |
| 4519 | fouger | fouge | Le sanglier fouge la terre à la recherche de racines et de vers. | The wild boar roots through the ground looking for roots and worms. |
| 4520 | discrétiser | discrétise | L'ingénieur discrétise l'équation différentielle pour la résoudre numériquement. | The engineer discretizes the differential equation to solve it numerically. |
| 4522 | déclassifier | déclassifier | Le gouvernement a décidé de déclassifier ces documents secrets après cinquante ans. | The government decided to declassify these secret documents after fifty years. |
| 4524 | désynchroniser | désynchronisé | Le logiciel a désynchronisé les sous-titres avec la vidéo par erreur. | The software accidentally desynchronized the subtitles from the video. |
| 4525 | gominer | gomine | Le jeune homme se gomine les cheveux avant de sortir en boîte. | The young man slicks his hair back with gel before going out clubbing. |
| 4527 | hypertrophier | hypertrophié | Après des années d'entraînement intense, ce muscle s'est considérablement hypertrophié. | After years of intense training, this muscle has become significantly hypertrophied. |
| 4530 | dévergonder | dévergondé | Le jeune homme s'est dévergondé après avoir quitté sa famille stricte. | The young man went off the rails after leaving his strict family. |
| 4531 | détoner | détoné | La bombe a détoné avec un bruit assourdissant au milieu de la nuit. | The bomb detonated with a deafening noise in the middle of the night. |
| 4532 | désargenter | désargenté | L'orfèvre a désargenté le vieux plat pour en récupérer le métal précieux. | The silversmith desilvered the old dish to recover the precious metal. |
| 4535 | poétiser | poétiser | Le poète cherche à poétiser les petits moments de la vie quotidienne. | The poet tries to poeticize the small moments of everyday life. |
| 4536 | financiariser | financiarisée | Certains critiques estiment que l'économie mondiale s'est trop financiarisée ces dernières décennies. | Some critics believe the global economy has become too financialized in recent decades. |
| 4538 | désappointer | désappointé | Le film a désappointé les critiques cadiens qui en attendaient beaucoup. | The film disappointed the Cajun critics who had expected a lot from it. |
| 4539 | enkyster | enkystée | La tumeur s'est enkystée avant même que les médecins la découvrent. | The tumor had encysted before doctors even discovered it. |
| 4543 | exemplifier | exemplifie | Cet exemple exemplifie parfaitement le problème que nous essayons de résoudre. | This example perfectly exemplifies the problem we are trying to solve. |
| 4544 | autocensurer | autocensurent | Les journalistes s'autocensurent parfois par peur des représailles politiques. | Journalists sometimes self-censor out of fear of political repercussions. |
| 4547 | encorder | encorde | Le guide encorde les grimpeurs avant l'ascension du glacier. | The guide ropes the climbers together before the ascent of the glacier. |
| 4549 | décompenser | décompensé | Le patient a décompensé après l'arrêt brutal de son traitement. | The patient decompensated after abruptly stopping his treatment. |
| 4550 | réabsorber | réabsorbe | Le corps réabsorbe lentement le liquide accumulé dans les tissus. | The body slowly reabsorbs the fluid that has built up in the tissue. |
| 4553 | bancher | banchent | Les ouvriers banchent le mur avant de couler le béton. | The workers put up the formwork before pouring the concrete. |
| 4555 | racoler | racole | Le rabatteur racole les touristes devant l'entrée du musée. | The tout solicits tourists in front of the museum entrance. |
| 4556 | tiller | tillent | Les paysans tillent le chanvre pour en extraire la fibre. | The farmers scutch the hemp to extract its fiber. |
| 4557 | crosser | crosse | Le joueur crosse la rondelle avec force vers le filet adverse. | The player smacks the puck hard toward the opposing net. |
| 4558 | smasher | smashe | Le joueur smashe la balle pour remporter le point décisif. | The player smashes the ball to win the deciding point. |
| 4559 | débrailler | débraille | En rentrant chez lui, il se débraille et dénoue sa cravate. | When he gets home, he loosens his clothes and undoes his tie. |
| 4562 | dépraver | dépraver | Le pouvoir absolu finit par dépraver même les esprits les plus nobles. | Absolute power eventually corrupts even the noblest of minds. |
| 4563 | tourber | tourbent | Les paysans tourbent la lande pour se chauffer en hiver. | The peasants dig peat from the moor to heat their homes in winter. |
| 4564 | réséquer | réséquer | Le chirurgien a dû réséquer une partie de l'intestin malade. | The surgeon had to resect part of the diseased intestine. |
| 4565 | cannibaliser | cannibaliser | Cette nouvelle offre risque de cannibaliser les ventes du produit existant. | This new offer risks cannibalizing sales of the existing product. |
| 4571 | débander | débande | L'infirmière débande la plaie pour vérifier la cicatrisation. | The nurse unwraps the bandage to check how the wound is healing. |
| 4573 | housser | housse | Elle housse les meubles avant de partir en vacances pour les protéger de la poussière. | She covers the furniture with dust sheets before leaving on vacation to protect it from dust. |
| 4575 | déchristianiser | déchristianiser | La Révolution française a tenté de déchristianiser la société pendant plusieurs années. | The French Revolution tried to dechristianize society for several years. |
| 4576 | hélitreuiller | hélitreuiller | Les secouristes ont dû hélitreuiller le randonneur blessé jusqu'à l'hôpital. | The rescuers had to winch the injured hiker up into the helicopter to get him to the hospital. |
| 4579 | musser | musse | Le chat se musse sous le lit dès qu'il entend du bruit. | The cat squeezes/hides itself under the bed as soon as it hears a noise. |
| 4583 | défroquer | défroqua | Le vieux moine défroqua après trente ans de vie monastique. | The old monk left the priesthood after thirty years of monastic life. |
| 4584 | chauler | chaulent | Chaque printemps, les fermiers chaulent les murs de l'étable pour la désinfecter. | Every spring, the farmers whitewash the barn walls to disinfect them. |
| 4586 | télédiffuser | télédiffusé | Ce reportage sera télédiffusé demain soir sur toutes les chaînes nationales. | This report will be broadcast on TV tomorrow evening on all the national channels. |
| 4588 | éviscérer | éviscéré | Le chasseur a éviscéré le lièvre avant de le préparer pour le dîner. | The hunter eviscerated the hare before preparing it for dinner. |
| 4593 | dérocher | dérocher | Les ouvriers ont dû dérocher le lit de la rivière avant de poser le nouveau pont. | The workers had to clear the rocks from the riverbed before laying the new bridge. |
| 4594 | dispatcher | dispatche | Le service dispatche les commandes vers les entrepôts régionaux chaque matin. | Every morning the department dispatches orders to the regional warehouses. |
| 4596 | fendiller | fendillé | La chaleur estivale a fendillé la peinture sur les volets en bois. | The summer heat has cracked the paint on the wooden shutters. |
| 4598 | pouliner | pouliné | La jument a pouliné pour la première fois ce printemps. | The mare foaled for the first time this spring. |
| 4601 | toussoter | toussota | Le vieil homme toussota discrètement avant de prendre la parole. | The old man gave a slight cough before speaking. |
| 4602 | apostasier | apostasier | Sous la torture, plusieurs prisonniers ont fini par apostasier. | Under torture, several prisoners eventually apostatized. |
| 4606 | collectiviser | collectiviser | Le nouveau gouvernement a décidé de collectiviser les terres agricoles du pays. | The new government decided to collectivize the country's farmland. |
| 4608 | mâter | mâté | Les charpentiers ont mâté le voilier avant la mise à l'eau. | The shipwrights masted the sailboat before it was launched. |
| 4611 | digresser | digresse | Le professeur digresse souvent avant de revenir à son sujet principal. | The professor often digresses before returning to his main topic. |
| 4612 | chaperonner | chaperonner | Sa tante a accepté de chaperonner les adolescents pendant la sortie scolaire. | Her aunt agreed to chaperone the teenagers during the school trip. |
| 4616 | roquer | roqué | Le joueur a roqué du côté du roi pour protéger sa tour. | The player castled kingside to protect his rook. |
| 4618 | décrisper | décrisper | Ce massage aide à décrisper les muscles du dos après une longue journée. | This massage helps to loosen up the back muscles after a long day. |
| 4619 | portraiturer | portraiturer | Le peintre a proposé de portraiturer la jeune mariée pour son anniversaire. | The painter offered to paint a portrait of the young bride for her birthday. |
| 4620 | démâter | démâté | La tempête a démâté le voilier en quelques minutes à peine. | The storm dismasted the sailboat in just a few minutes. |
| 4622 | émasculer | émasculent | Certains craignent que ces amendements n'émasculent la nouvelle loi sur l'environnement. | Some fear these amendments will emasculate the new environmental law. |
| 4623 | nickeler | nickelé | L'artisan a nickelé les poignées de porte pour les protéger de la rouille. | The craftsman nickel-plated the door handles to protect them from rust. |
| 4624 | hululer | hulule | Un hibou hulule dans la forêt toutes les nuits près de la cabane. | An owl hoots in the forest every night near the cabin. |
| 4627 | pyramider | pyramident | Les cartons s'entassent et pyramident dangereusement au fond de l'entrepôt. | The boxes are piling up and forming a dangerous pyramid at the back of the warehouse. |
| 4629 | décerveler | décerveler | Le dictateur voulait décerveler la population à coups de propagande incessante. | The dictator wanted to brainwash the population with relentless propaganda. |
| 4631 | rétroagir | rétroagir | Cette nouvelle loi va rétroagir sur les contrats signés l'année dernière. | This new law will apply retroactively to contracts signed last year. |
| 4632 | envaser | s'envase | Le petit port s'envase rapidement à cause des sédiments charriés par la rivière. | The small harbor is silting up quickly because of sediment carried by the river. |
| 4633 | suppurer | suppurer | La plaie mal soignée a commencé à suppurer au bout de quelques jours. | The poorly treated wound began to fester after a few days. |
| 4635 | relaisser | relaissé | Le facteur a relaissé le colis chez le voisin car personne ne répondait. | The postman left the package again with the neighbor since no one answered. |
| 4636 | douiller | douiller | Le vaccin ne fait pas très mal, mais l'infirmière prévient que ça va un peu douiller. | The shot doesn't hurt much, but the nurse warns it will sting a little. |
| 4638 | remplier | remplier | Avant de coudre l'ourlet, la couturière commence par remplier le tissu sur lui-même. | Before sewing the hem, the seamstress starts by folding the fabric over on itself. |
| 4639 | chanfreiner | chanfreiné | Le menuisier a chanfreiné les bords de la planche pour éviter les échardes. | The carpenter chamfered the edges of the board to avoid splinters. |
| 4644 | rechanger | rechanger | Elle a dû rechanger de vêtements après être tombée dans la flaque. | She had to change her clothes again after falling in the puddle. |
| 4645 | anastomoser | anastomoser | Les chirurgiens ont réussi à anastomoser les deux vaisseaux sanguins pendant l'opération. | The surgeons managed to connect the two blood vessels together during the operation. |
| 4648 | pommader | pommadé | Le coiffeur a pommadé ses cheveux pour leur donner un aspect brillant et lisse. | The barber pomaded his hair to give it a shiny, sleek look. |
| 4649 | blouser | blouser | Le vendeur a tenté de blouser le client avec une fausse antiquité. | The salesman tried to con the customer with a fake antique. |
| 4650 | grenouiller | grenouillent | Certains élus grenouillent dans l'ombre pour obtenir des faveurs personnelles. | Some officials scheme behind the scenes to gain personal favors. |
| 4654 | ankyloser | ankyloser | Le froid finit par ankyloser ses articulations après des heures d'attente dehors. | The cold eventually stiffened his joints after hours of waiting outside. |
| 4656 | surfacturer | surfacturé | Le garagiste a surfacturé la réparation en doublant le prix des pièces. | The mechanic overcharged for the repair by doubling the price of the parts. |
| 4657 | rembarrer | rembarré | Le patron a rembarré le stagiaire qui posait trop de questions pendant la réunion. | The boss rebuffed the intern who was asking too many questions during the meeting. |
| 4658 | goupiller | goupillé | Je ne sais pas comment il a goupillé ça, mais tout s'est bien passé. | I don't know how he pulled it off, but everything went fine. |
| 4659 | liserer | liseré | La couturière a liseré le col de la robe avec un ruban de soie. | The seamstress edged the dress's collar with a silk ribbon. |
| 4660 | hoqueter | hoqueter | Le bébé se mit à hoqueter après avoir bu son biberon trop vite. | The baby started hiccupping after drinking his bottle too fast. |
| 4662 | faisander | faisander | Le chasseur laisse faisander le gibier pendant plusieurs jours avant de le cuisiner. | The hunter lets the game hang for several days before cooking it. |
| 4663 | cloquer | cloquer | La chaleur du bitume a fini par cloquer la peinture de la voiture garée en plein soleil. | The heat of the asphalt eventually blistered the paint on the car parked in full sun. |
| 4664 | dégrever | dégrever | Le gouvernement a décidé de dégrever les petites entreprises pour stimuler l'économie locale. | The government decided to give small businesses tax relief to boost the local economy. |
| 4665 | défroisser | défroissé | Elle a défroissé sa robe avec un fer avant la cérémonie. | She ironed the wrinkles out of her dress before the ceremony. |
| 4666 | pétitionner | pétitionné | Les habitants du quartier ont pétitionné pour obtenir un nouveau feu de circulation. | The neighborhood residents petitioned for a new traffic light. |
| 4668 | réassurer | réassurer | La compagnie d'assurance a dû réassurer une partie de ses risques auprès d'un assureur plus important. | The insurance company had to reinsure part of its risks with a larger insurer. |
| 4669 | agonir | agoni | Le chauffeur a agoni d'injures le cycliste qui avait grillé le feu rouge. | The driver hurled insults at the cyclist who had run the red light. |
| 4670 | ringardiser | ringardisé | Les nouveaux smartphones ont vite ringardisé les anciens modèles. | The new smartphones quickly made the older models look outdated. |
| 4675 | bureaucratiser | bureaucratiser | La réforme a fini par bureaucratiser un processus qui était auparavant simple. | The reform ended up bureaucratizing a process that used to be simple. |
| 4677 | calorifuger | calorifugé | L'ouvrier a calorifugé les tuyaux du chauffage pour réduire les pertes de chaleur. | The worker insulated the heating pipes to reduce heat loss. |
| 4680 | helléniser | helléniser | Alexandre le Grand chercha à helléniser les régions conquises en Orient. | Alexander the Great sought to Hellenize the regions he conquered in the East. |
| 4681 | havir | havir | Le boucher a laissé havir la viande sur un feu trop vif, la brûlant en surface. | The butcher let the meat singe over too high a flame, scorching its surface. |
| 4683 | érotiser | érotiser | La publicité a tendance à érotiser des situations tout à fait banales. | Advertising tends to eroticize completely ordinary situations. |
| 4684 | fulgurer | fulgura | L'éclair fulgura dans le ciel noir, illuminant la vallée un instant. | The lightning flashed across the black sky, lighting up the valley for an instant. |
| 4685 | transcoder | transcoder | Le logiciel permet de transcoder une vidéo dans un format compatible avec le téléphone. | The software lets you transcode a video into a format compatible with the phone. |
| 4686 | agneler | agnelé | La brebis a agnelé pendant la nuit, donnant naissance à deux agneaux. | The ewe lambed during the night, giving birth to two lambs. |
| 4691 | entredéchirer | s'entredéchirent | Les deux clans s'entredéchirent pour le contrôle du territoire. | The two clans are tearing each other apart over control of the territory. |
| 4693 | dégoupiller | dégoupille | Le soldat dégoupille la grenade avant de la lancer. | The soldier pulls the pin out of the grenade before throwing it. |
| 4696 | contre-manifester | contre-manifester | Des dizaines de militants ont décidé de contre-manifester devant la préfecture. | Dozens of activists decided to stage a counterdemonstration in front of the prefecture. |
| 4698 | pétarader | pétaradait | La vieille mobylette pétaradait bruyamment dans les rues du village. | The old moped backfired loudly through the streets of the village. |
| 4699 | nucléariser | nucléariser | Ce pays a décidé de nucléariser son armée pour dissuader ses voisins. | This country decided to arm its military with nuclear weapons to deter its neighbors. |
| 4701 | capsuler | capsule | Le vigneron capsule chaque bouteille avant de l'expédier aux clients. | The winemaker caps each bottle before shipping it to customers. |
| 4702 | lignifier | se lignifient | Les parois cellulaires se lignifient progressivement pour renforcer la tige de la plante. | The cell walls gradually lignify to strengthen the plant's stem. |
| 4703 | conteneuriser | conteneuriser | Le port a commencé à conteneuriser une grande partie de ses marchandises dans les années 1970. | The port began to containerize a large share of its cargo in the 1970s. |
| 4704 | estérifier | estérifient | Les chimistes estérifient l'acide pour produire un parfum agréable. | Chemists esterify the acid to produce a pleasant scent. |
| 4707 | surir | suri | Le lait a suri à cause de la chaleur. | The milk went sour because of the heat. |
| 4708 | mâchonner | mâchonne | Le chien mâchonne son os dans le jardin depuis une heure. | The dog has been chewing on its bone in the yard for an hour. |
| 4709 | valdinguer | valdingué | Sous le choc, la valise a valdingué à travers la pièce. | From the impact, the suitcase went flying across the room. |
| 4710 | cocufier | cocufiait | Le mari a découvert que sa femme le cocufiait avec son meilleur ami. | The husband discovered that his wife was cheating on him with his best friend. |
| 4711 | poquer | poqué | Le chariot a poqué la portière de la voiture dans le stationnement. | The shopping cart dinged the car door in the parking lot. |
| 4712 | remployer | remploie | L'usine remploie les chutes de métal pour fabriquer de nouvelles pièces. | The factory reuses metal scraps to make new parts. |
| 4713 | regarnir | regarni | Après les travaux, ils ont regarni le salon avec de nouveaux meubles. | After the renovations, they refurnished the living room with new furniture. |
| 4714 | stipendier | stipendié | Le baron a stipendié plusieurs hommes de main pour intimider ses rivaux. | The baron hired thugs to intimidate his rivals. |
| 4715 | chiader | chiadé | Elle a chiadé son dossier de candidature pendant des semaines. | She polished her application for weeks. |
| 4719 | réhabituer | réhabituer | Il a fallu plusieurs semaines pour réhabituer le chien à vivre en appartement. | It took several weeks to get the dog used to living in an apartment again. |
| 4720 | rancir | ranci | Le beurre a ranci parce qu'il est resté trop longtemps hors du réfrigérateur. | The butter went rancid because it was left out of the fridge for too long. |
| 4725 | caoutchouter | caoutchoute | L'artisan caoutchoute les poignées des outils pour un meilleur confort. | The craftsman coats the tool handles with rubber for better comfort. |
| 4732 | manucurer | manucure | La coiffeuse manucure les mains de sa cliente avant le mariage. | The hairdresser manicures her client's hands before the wedding. |
| 4733 | techniciser | technicisé | Le fabricant a technicisé la procédure pour la rendre plus fiable. | The manufacturer made the procedure more technical to make it more reliable. |
| 4734 | gazéifier | gazéifie | Le fabricant gazéifie l'eau minérale avant de la mettre en bouteille. | The manufacturer carbonates the mineral water before bottling it. |
| 4735 | alpaguer | alpagué | Les policiers ont alpagué le voleur juste avant qu'il ne s'enfuie. | The police collared the thief just before he could get away. |
| 4736 | chaumer | chaument | Les fermiers chaument le champ après la moisson pour préparer le sol. | The farmers clear the stubble from the field after the harvest to prepare the soil. |
| 4738 | claudiquer | claudique | Depuis son accident, il claudique légèrement en marchant. | Since his accident, he limps slightly when he walks. |
| 4743 | désensibiliser | désensibilise | Le médecin désensibilise progressivement le patient à l'allergène. | The doctor gradually desensitizes the patient to the allergen. |
| 4744 | tournebouler | tourneboulé | Cette nouvelle inattendue l'a complètement tourneboulé. | This unexpected news completely upset him. |
| 4747 | ballonner | ballonne | Après un repas copieux, son ventre ballonne désagréablement. | After a heavy meal, his stomach bloats uncomfortably. |
| 4751 | signaliser | signalisent | Les ouvriers signalisent la route en travaux. | The workers are putting up signs on the road under construction. |
| 4752 | nidifier | nidifient | Les hirondelles nidifient sous le toit de la grange chaque printemps. | Swallows nest under the barn roof every spring. |
| 4755 | exsuder | exsude | La résine exsude lentement de l'écorce du pin. | Resin slowly exudes from the pine bark. |
| 4756 | esthétiser | esthétise | Le designer esthétise l'espace de travail avec des couleurs douces. | The designer aestheticizes the workspace with soft colors. |
| 4759 | réopérer | réopérer | Le chirurgien a dû réopérer le patient après une complication inattendue. | The surgeon had to operate on the patient again after an unexpected complication. |
| 4762 | louanger | louange | Le critique louange le nouveau film dans son article du journal. | The critic praises the new film in his newspaper article. |
| 4763 | chosifier | chosifier | La bureaucratie tend à chosifier les individus qu'elle est censée servir. | Bureaucracy tends to reify the individuals it is supposed to serve. |
| 4764 | dialectiser | dialectiser | Le philosophe cherche à dialectiser les contradictions du système économique. | The philosopher seeks to treat the contradictions of the economic system dialectically. |
| 4765 | brêler | brêlent | Les marins brêlent les caisses sur le pont avant que la tempête n'arrive. | The sailors tie down the crates on deck before the storm arrives. |
| 4767 | boucaner | boucanent | Les habitants boucanent la viande de sanglier pour la conserver plus longtemps. | The locals smoke wild-boar meat to preserve it longer. |
| 4768 | jargonner | jargonnent | Les employés jargonnent pendant les réunions au lieu de parler simplement. | The employees babble in jargon during meetings instead of speaking plainly. |
| 4769 | fonctionnariser | fonctionnariser | Le gouvernement a décidé de fonctionnariser tous les employés de cette agence publique. | The government decided to make all the employees of that public agency civil servants. |
| 4773 | herscher | herschait | Le jeune mineur herschait les wagonnets de charbon tout au long de la galerie. | The young miner pushed the coal carts along the length of the tunnel. |
| 4774 | énamourer | s'est énamourée | Elle s'est énamourée du jeune poète dès leur première rencontre. | She fell in love with the young poet from their very first meeting. |
| 4775 | accessoiriser | accessoiriser | Elle aime accessoiriser ses tenues avec des bijoux discrets. | She likes to accessorize her outfits with subtle jewelry. |
| 4776 | coasser | coassaient | Les grenouilles coassaient bruyamment près de l'étang au coucher du soleil. | The frogs were croaking loudly near the pond at sunset. |
| 4778 | anglaiser | anglaisait | Le maquignon anglaisait les chevaux de trait pour qu'ils portent la queue plus haute. | The horse dealer nicked the draft horses' tails so they would carry them higher. |
| 4783 | graniter | granite | L'artisan granite le mur de la façade pour lui donner un effet plus élégant. | The craftsman paints the facade wall to imitate granite, giving it a more elegant look. |
| 4784 | discutailler | discutaillent | Les deux avocats discutaillent sans fin sur des détails insignifiants du contrat. | The two lawyers quibble endlessly over insignificant details of the contract. |
| 4785 | microniser | micronise | L'usine micronise le sucre pour obtenir une poudre extrêmement fine. | The factory micronizes the sugar to produce an extremely fine powder. |
| 4786 | démonétiser | démonétiser | Le gouvernement a décidé de démonétiser les anciens billets de banque cette année. | The government decided to demonetize the old banknotes this year. |
| 4788 | soliloquer | soliloque | Le vieil homme soliloque parfois à voix haute quand il se sent seul. | The old man sometimes soliloquizes aloud when he feels lonely. |
| 4789 | pontifier | pontifier | Le conférencier aime pontifier sur des sujets qu'il connaît à peine. | The lecturer likes to pontificate on subjects he barely knows. |
| 4790 | départementaliser | départementaliser | Le gouvernement a voté pour départementaliser ce territoire d'outre-mer en 1946. | The government voted to make this overseas territory a department in 1946. |
| 4791 | rhumer | rhume | Le pâtissier rhume la pâte à baba pour lui donner plus de saveur. | The pastry chef mixes rum into the baba dough to give it more flavor. |
| 4792 | déboguer | débogue | L'ingénieure débogue le logiciel avant de le livrer au client. | The engineer debugs the software before delivering it to the client. |
| 4793 | carter | carte | Le videur carte systématiquement les clients avant de les laisser entrer en boîte de nuit. | The bouncer routinely checks IDs before letting customers into the nightclub. |
| 4794 | déréaliser | déréaliser | Le stress chronique peut déréaliser la perception du quotidien chez certaines personnes. | Chronic stress can make everyday perception feel disconnected from reality for some people. |
| 4795 | pâtisser | pâtisser | Le dimanche, elle aime pâtisser des tartes aux fruits pour toute la famille. | On Sundays, she likes to bake fruit tarts for the whole family. |
| 4799 | dénucléariser | dénucléariser | Les deux pays ont signé un accord pour dénucléariser progressivement la péninsule. | The two countries signed an agreement to gradually denuclearize the peninsula. |
| 4802 | ronéotyper | ronéotyper | Avant l'ère numérique, les enseignants devaient ronéotyper leurs polycopiés chaque semaine. | Before the digital era, teachers had to duplicate their handouts on a Roneo machine each week. |
| 4803 | maximaliser | maximaliser | L'entreprise cherche à maximaliser ses profits tout en réduisant les coûts. | The company is trying to maximize its profits while cutting costs. |
| 4806 | fétichiser | fétichiser | Certains critiques d'art reprochent au film de fétichiser la violence urbaine. | Some art critics accuse the film of fetishizing urban violence. |
| 4808 | juter | jutent | Les framboises bien mûres jutent abondamment quand on les écrase délicatement. | Ripe raspberries release a lot of juice when gently crushed. |
| 4809 | subdéléguer | subdéléguer | Le préfet peut subdéléguer certains pouvoirs administratifs à son adjoint. | The prefect can subdelegate certain administrative powers to his deputy. |
| 4810 | doublonner | doublonnent | Ces deux formulaires administratifs doublonnent, ce qui complique les démarches des usagers. | These two administrative forms overlap with each other, which complicates things for users. |
| 4812 | décapsuler | décapsule | Le serveur décapsule la bouteille de limonade avec un ouvre-bouteille avant de la servir. | The waiter uncaps the lemonade bottle with a bottle opener before serving it. |
| 4813 | empoter | empote | Au printemps, elle empote les jeunes plants avant de les mettre en pleine terre. | In spring, she pots the young seedlings before planting them in the ground. |
| 4814 | javelliser | javelliser | Après l'inondation, les employés ont dû javelliser tous les sols du sous-sol. | After the flood, the staff had to disinfect the entire basement floor with bleach. |
| 4817 | carapater | s'est carapaté | Dès qu'il a vu la police, le voleur s'est carapaté dans la ruelle. | As soon as he saw the police, the thief scarpered down the alley. |
| 4821 | tournicoter | tournicoter | Le chat n'arrête pas de tournicoter autour de la table pendant le dîner. | The cat keeps flitting around the table during dinner. |
| 4823 | biberonner | biberonner | Chaque nuit, elle se lève pour biberonner le nouveau-né qui pleure de faim. | Every night, she gets up to bottle-feed the newborn who's crying with hunger. |
| 4825 | entartrer | entartrer | L'eau calcaire finit par entartrer la bouilloire électrique en quelques mois. | Hard water eventually furs up the electric kettle within a few months. |
| 4826 | catir | catit | L'atelier catit le lin pour le rendre plus raide et plus lisse avant la vente. | The workshop stiffens the linen to make it firmer and smoother before selling it. |
| 4829 | farter | farte | Le skieur farte ses skis avant de dévaler la piste noire. | The skier waxes his skis before speeding down the black run. |
| 4831 | entre-détruire | s'entre-détruisent | Les deux clans s'entre-détruisent lors de leurs guerres incessantes. | The two clans keep destroying each other in their endless wars. |
| 4832 | sous-virer | sous-vire | La voiture sous-vire dangereusement dans le virage mouillé. | The car understeers dangerously in the wet turn. |
| 4833 | gouacher | gouache | L'artiste gouache un paysage marin pour l'exposition de printemps. | The artist paints a seascape in gouache for the spring exhibition. |
| 4835 | hotter | hotte | Le vendangeur hotte les raisins jusqu'au pressoir tout l'après-midi. | The grape-picker carries the grapes to the press in his back-basket all afternoon. |
| 4836 | ethniciser | ethnicisent | Certains médias ethnicisent des faits divers pour attirer l'attention. | Some media outlets ethnicize news stories to attract attention. |
| 4837 | ensiler | ensilent | Les agriculteurs ensilent le maïs à la fin de l'été pour nourrir le bétail. | Farmers store the corn in a silo at the end of summer to feed the livestock. |
| 4838 | commotionner | commotionné | Le coup a commotionné le boxeur, qui s'est écroulé sur le ring. | The blow concussed the boxer, who collapsed in the ring. |
| 4842 | driver | drive | Le golfeur drive la balle avec une puissance impressionnante sur le premier trou. | The golfer drives the ball with impressive power on the first hole. |
| 4843 | optimaliser | optimaliser | Les ingénieurs cherchent toujours à optimaliser l'utilisation des ressources disponibles. | Engineers always try to optimize the use of available resources. |
| 4847 | ristourner | ristourne | La compagnie d'assurance ristourne une partie de la prime aux clients fidèles. | The insurance company rebates part of the premium to loyal customers. |
| 4848 | gravillonner | gravillonne | L'entreprise gravillonne la route de campagne avant l'hiver. | The company covers the country road with gravel before winter. |
| 4850 | kératiniser | kératinise | Le corps kératinise certaines cellules de la peau pour les rendre plus résistantes. | The body keratinizes certain skin cells to make them more resistant. |
| 4851 | empoissonner | empoissonne | Le garde forestier empoissonne l'étang chaque printemps avec des truites. | The forest ranger stocks the pond with trout every spring. |
| 4854 | interligner | interligne | L'imprimeur interligne le texte pour rendre la lecture plus agréable. | The printer adds space between the lines to make reading more pleasant. |
| 4856 | fiche | se fiche | Il se fiche complètement de ce que les autres pensent de lui. | He couldn't care less what other people think of him. |
| 4857 | haubaner | haubanent | Les ouvriers haubanent le mât avant la tempête pour le stabiliser. | The workers stay the mast with cables before the storm to stabilize it. |
| 4858 | meugler | meuglent | Les vaches meuglent dès qu'elles aperçoivent le fermier avec le foin. | The cows moo as soon as they see the farmer with the hay. |
| 4859 | métamorphiser | métamorphise | La chaleur profonde métamorphise la roche sédimentaire en marbre. | Deep heat metamorphoses sedimentary rock into marble. |
| 4861 | antidater | antidaté | Le comptable a antidaté le chèque pour éviter des frais de retard. | The accountant backdated the check to avoid late fees. |
| 4865 | débecter | débecte | Cette odeur de poubelle me débecte complètement. | That garbage smell completely disgusts me. |
| 4867 | rubaner | rubane | Elle rubane le bouquet de fleurs avant de l'offrir. | She puts a ribbon on the bouquet of flowers before giving it. |
| 4868 | plastronner | plastronne | Il plastronne devant ses amis après avoir gagné le match. | He swaggers in front of his friends after winning the match. |
| 4870 | ravigoter | ravigote | Une tasse de café chaud le ravigote chaque matin. | A cup of hot coffee reinvigorates him every morning. |
| 4871 | télégraphier | télégraphie | Il télégraphie la nouvelle à sa famille dès son arrivée. | He telegraphs the news to his family as soon as he arrives. |
| 4872 | tropicaliser | tropicalisent | Les ingénieurs tropicalisent le matériel électronique avant de l'exporter. | The engineers adapt the electronic equipment for tropical conditions before exporting it. |
| 4875 | teiller | teille | Le paysan teille le lin avant de le filer. | The farmer rets the flax before spinning it. |
| 4877 | mucher | se muche | L'enfant se muche derrière le grand chêne pour jouer à cache-cache. | The child hides behind the big oak tree to play hide-and-seek. |
| 4879 | empanner | empanne | Le skipper empanne au dernier moment pour éviter la bouée. | The skipper gybes at the last moment to avoid the buoy. |
| 4880 | transhumer | transhument | Les bergers transhument leurs troupeaux vers les alpages chaque été. | The shepherds move their flocks to mountain pastures every summer. |
| 4881 | démarier | démarier | Le prêtre refusa de démarier les deux époux malgré leur demande. | The priest refused to unmarry the couple despite their request. |
| 4882 | calancher | a calanché | Le vieux chat a fini par calancher dans son sommeil. | The old cat finally kicked the bucket in its sleep. |
| 4883 | doigter | doigte | Le pianiste doigte soigneusement chaque passage difficile. | The pianist carefully fingers each difficult passage. |
| 4884 | surarmer | surarmer | Le gouvernement a été accusé de surarmer sa police face aux manifestants. | The government was accused of over-arming its police against the protesters. |
| 4885 | décatir | décatit | L'ouvrier décatit le tissu de laine pour lui enlever son apprêt avant la vente. | The worker decatizes the wool fabric to remove its finish before it is sold. |
| 4886 | cabotiner | cabotiner | L'avocat adore cabotiner devant les caméras pendant le procès. | The lawyer loves hamming it up in front of the cameras during the trial. |
| 4887 | maquetter | maquette | Le graphiste maquette le nouveau numéro du magazine avant l'impression. | The graphic designer lays out the new issue of the magazine before printing. |
| 4888 | oraliser | oraliser | Le professeur aide l'enfant sourd à oraliser ses pensées. | The teacher helps the deaf child express his thoughts orally. |
| 4889 | énucléer | énucléer | Le chirurgien doit énucléer l'œil malade pour éviter la propagation de la tumeur. | The surgeon must enucleate the diseased eye to prevent the tumor from spreading. |
| 4890 | couillonner | couillonné | Il a couillonné son collègue en lui faisant croire à une fausse réunion. | He tricked his colleague into believing there was a fake meeting. |
| 4891 | éployer | éploie | L'aigle éploie ses ailes avant de s'envoler du rocher. | The eagle spreads its wings before flying off the rock. |
| 4892 | menuiser | menuiser | Le grand-père aime menuiser dans son atelier le week-end. | Grandpa loves doing woodwork in his shop on weekends. |
| 4896 | vitrioler | vitriolé | L'agresseur a vitriolé le visage de sa victime lors de l'attaque. | The attacker threw acid at his victim's face during the assault. |
| 4899 | facetter | facette | Le lapidaire facette soigneusement chaque diamant avant de le vendre. | The lapidary facets each diamond carefully before selling it. |
| 4903 | marmiter | marmité | Les canons ont marmité les tranchées ennemies toute la nuit. | The guns shelled the enemy trenches all night. |
| 4904 | triballer | triballe | Le tanneur triballe les peaux pour les rendre plus souples. | The tanner works the hides to make them supple. |
| 4905 | vibrionner | vibrionne | Le petit garçon vibrionne sans cesse autour de la table pendant le dîner. | The little boy keeps bouncing around the table nonstop during dinner. |
| 4906 | surinvestir | surinvestissent | Certains investisseurs surinvestissent dans un seul secteur, ce qui augmente le risque. | Some investors overinvest in a single sector, which increases the risk. |
| 4907 | désamianter | désamiante | La ville désamiante plusieurs écoles avant la rentrée. | The city is removing asbestos from several schools before the school year starts. |
| 4911 | amariner | s'amariner | Après plusieurs semaines en mer, le jeune matelot a fini par s'amariner. | After several weeks at sea, the young sailor finally got his sea legs. |
| 4912 | interclasser | interclasse | Le service interclasse plusieurs listes de clients en une seule base de données. | The service merges several customer lists into a single database. |
| 4913 | palettiser | palettise | L'entrepôt palettise les cartons avant de les expédier aux clients. | The warehouse loads the boxes onto pallets before shipping them to customers. |
| 4916 | droper | drope | Le golfeur drope sa balle après qu'elle atterrit dans l'eau. | The golfer drops his ball after it lands in the water. |
| 4917 | réorchestrer | réorchestre | Le compositeur réorchestre la symphonie pour un orchestre plus restreint. | The composer is reorchestrating the symphony for a smaller ensemble. |
| 4919 | pigeonner | pigeonne | Le vendeur pigeonne plusieurs clients en leur vendant de fausses antiquités. | The dealer dupes several customers by selling them fake antiques. |
| 4920 | hucher | huche | Le berger huche pour rassembler ses moutons dispersés dans la vallée. | The shepherd calls out to gather his sheep scattered across the valley. |
| 4922 | rencarder | rencardé | Un ami m'a rencardé sur les meilleures adresses du quartier. | A friend gave me the lowdown on the best spots in the neighborhood. |
| 4923 | surentraîner | surentraîner | Le coach évite de surentraîner ses athlètes avant une compétition importante. | The coach avoids overtraining his athletes before an important competition. |
| 4924 | grener | grène | Le blé grène tardivement cette année à cause de la sécheresse. | The wheat is seeding late this year because of the drought. |
| 4925 | paraffiner | paraffine | L'apiculteur paraffine les cadres de la ruche pour les protéger de l'humidité. | The beekeeper paraffins the hive frames to protect them from moisture. |
| 4927 | indurer | indurer | La radiothérapie peut indurer les tissus environnants après plusieurs semaines. | Radiotherapy can harden the surrounding tissue after several weeks. |
| 4929 | glycériner | glycérine | Le pharmacien glycérine la préparation pour la rendre plus onctueuse. | The pharmacist adds glycerine to the preparation to make it smoother. |
| 4931 | ballaster | ballaste | Le cargo ballaste ses citernes pour stabiliser le navire avant le départ. | The cargo ship ballasts its tanks to stabilize the vessel before departure. |
| 4932 | occlure | occlut | Le chirurgien occlut l'artère pour arrêter l'hémorragie. | The surgeon occludes the artery to stop the bleeding. |
| 4934 | germaniser | germaniser | Le gouvernement voulait germaniser les provinces annexées après la guerre. | The government wanted to Germanize the annexed provinces after the war. |
| 4935 | guincher | guincher | Le samedi soir, ils aiment guincher dans les petits bals de quartier. | On Saturday nights, they like to boogie at the little neighborhood dances. |
| 4936 | dépuceler | dépucelé | Il se vantait d'avoir dépucelé toutes les filles de son village. | He bragged about having deflowered every girl in his village. |
| 4937 | champlever | champlevé | L'orfèvre a champlevé le cuivre avant d'y couler l'émail coloré. | The goldsmith hollowed out the copper before pouring in the colored enamel. |
| 4938 | translittérer | translittérer | Les linguistes ont dû translittérer le texte arabe en alphabet latin. | The linguists had to transliterate the Arabic text into the Latin alphabet. |
| 4939 | ségréger | ségréger | Le nouveau règlement risque de ségréger les élèves selon leur origine sociale. | The new regulation risks segregating students according to their social background. |
| 4940 | sporuler | sporule | Ce champignon sporule dès que l'humidité augmente. | This fungus produces spores as soon as the humidity rises. |
| 4941 | embringuer | embringuer | Il a essayé de m'embringuer dans son projet insensé. | He tried to drag me into his crazy scheme. |
| 4942 | traînasser | traînasse | Le dimanche après-midi, il traînasse dans son jardin sans rien faire de précis. | On Sunday afternoons, he mooches about in his garden without doing anything in particular. |
| 4943 | boursicoter | boursicote | Le retraité boursicote avec une petite somme chaque mois. | The retiree dabbles on the stock market with a small sum every month. |
| 4945 | rebaisser | rebaisser | Les prix vont sûrement rebaisser après les fêtes. | Prices will surely go down again after the holidays. |
| 4946 | décorner | décorner | Le fermier doit décorner les jeunes veaux avant l'été. | The farmer must dehorn the young calves before summer. |
| 4947 | puddler | puddler | L'ouvrier devait puddler la fonte pour en extraire les impuretés. | The worker had to puddle the pig iron to remove its impurities. |
| 4948 | copiloter | copiloter | Elle va copiloter l'avion lors du vol retour. | She will copilot the plane on the return flight. |
| 4949 | déniaiser | déniaisé | Le voyage l'a déniaisé ; il est devenu plus dégourdi. | The trip smartened him up; he became sharper. |
| 4950 | monologuer | monologuer | Resté seul dans sa chambre, il se mit à monologuer à voix haute. | Left alone in his room, he began to soliloquize aloud. |
| 4952 | pelucher | pelucher | Après plusieurs lavages, ce vieux pull a commencé à pelucher. | After several washes, this old sweater started to get fuzzy. |
| 4954 | empuantir | empuantit | La fumée de cigarette empuantit tout l'appartement. | Cigarette smoke stinks up the whole apartment. |
| 4959 | municipaliser | municipaliser | La ville a décidé de municipaliser la distribution d'eau. | The city decided to municipalize the water distribution service. |
| 4963 | boumer | boume | Ça boume entre eux depuis qu'ils ont réglé leurs différends. | Things are going well between them since they settled their differences. |
| 4966 | revouloir | reveut | Après leur dispute, elle le reveut dans sa vie. | After their argument, she wants him back in her life. |
| 4968 | regrossir | regrossi | Après sa maladie, il a bien regrossi grâce à la cuisine de sa grand-mère. | After his illness, he put the weight back on thanks to his grandmother's cooking. |
| 4969 | retreindre | retreint | Le chaudronnier retreint une plaque de cuivre pour en faire un vase. | The coppersmith hammers a copper plate into shape to make a vessel. |
| 4970 | folioter | foliote | Le relieur foliote soigneusement chaque page avant de relier le manuscrit. | The bookbinder carefully paginates each page before binding the manuscript. |
| 4971 | lemmatiser | lemmatise | Le logiciel lemmatise automatiquement chaque mot du texte avant l'analyse. | The software automatically lemmatizes each word of the text before analysis. |
| 4972 | encorner | encorné | Le taureau a encorné le torero avant que celui-ci ne puisse s'écarter. | The bull gored the bullfighter before he could get out of the way. |
| 4973 | staffer | staffé | Les artisans ont staffé le plafond de la salle de bal avant l'exposition. | The craftsmen covered the ballroom ceiling with staff before the exhibition. |
| 4975 | angliciser | anglicisé | Elle a anglicisé la prononciation de son prénom en s'installant à Londres. | She anglicized the pronunciation of her first name after moving to London. |
| 4976 | bizuter | bizuter | Les anciens élèves aimaient bizuter les nouveaux pendant la semaine de rentrée. | The senior students liked to haze the newcomers during orientation week. |
| 4978 | brinquebaler | brinquebalait | Le vieux camion brinquebalait sur la route caillouteuse. | The old truck rattled and jolted along the rocky road. |
| 4981 | postillonner | postillonne | Quand il s'énerve, il postillonne en parlant à toute vitesse. | When he gets worked up, he splutters as he talks at top speed. |
| 4982 | dépolariser | dépolarise | Le circuit dépolarise le courant avant qu'il n'atteigne le capteur. | The circuit depolarizes the current before it reaches the sensor. |
| 4983 | vulcaniser | vulcanise | L'usine vulcanise le caoutchouc pour rendre les pneus plus résistants. | The factory vulcanizes rubber to make tires more durable. |
| 4984 | désincruster | désincruste | Ce gommage désincruste les pores et adoucit la peau. | This scrub unclogs the pores and softens the skin. |
| 4985 | criser | criser | Si tu casses encore une assiette, ton frère va criser. | If you break another plate, your brother is going to freak out. |
| 4986 | chuinter | chuinte | La chouette chuinte doucement dans la nuit silencieuse. | The owl hoots softly in the silent night. |
| 4987 | treuiller | treuillent | Les ouvriers treuillent la benne jusqu'en haut du chantier. | The workers winch the skip up to the top of the construction site. |
| 4989 | embrancher | s'embranche | Cette petite route s'embranche sur l'autoroute quelques kilomètres plus loin. | This small road connects to the highway a few kilometers further on. |
| 4990 | dénationaliser | dénationaliser | Le nouveau gouvernement a décidé de dénationaliser plusieurs grandes entreprises publiques. | The new government decided to denationalize several major state-owned companies. |
| 4993 | réincorporer | réincorporer | L'armée a décidé de réincorporer les soldats démobilisés l'année dernière. | The army decided to reincorporate the soldiers who had been demobilized the previous year. |
| 4995 | talocher | talochait | Le grand frère talochait son cadet chaque fois qu'il désobéissait. | The older brother would clout his little brother every time he disobeyed. |
| 4996 | passepoiler | passepoile | La couturière passepoile le col de la veste pour lui donner du relief. | The seamstress pipes the jacket's collar to give it some definition. |
| 4997 | déconsigner | déconsigner | On peut déconsigner ses bagages à la consigne de la gare avant midi. | You can pick up your left luggage from the station's storage counter before noon. |
| 4998 | recristalliser | recristalliser | Le chimiste fait recristalliser le composé pour en améliorer la pureté. | The chemist recrystallizes the compound to improve its purity. |
| 4999 | abraser | abrase | Le vent chargé de sable abrase lentement la surface des rochers. | Sand-laden wind slowly abrades the surface of the rocks. |
| 5000 | bavasser | bavassent | Mes voisines bavassent pendant des heures sur le pas de la porte. | My neighbors natter for hours on the doorstep. |
| 5001 | feuler | feule | Le tigre feule doucement en sentant l'odeur de la viande. | The tiger growls softly at the smell of the meat. |
| 5002 | graphiter | graphite | Le technicien graphite les électrodes avant de les installer dans la batterie. | The technician applies graphite to the electrodes before installing them in the battery. |
| 5003 | formoler | formole | L'infirmière formole soigneusement les instruments chirurgicaux avant l'opération. | The nurse carefully disinfects the surgical instruments before the operation. |
| 5004 | moleter | molette | L'ouvrier molette la poignée métallique pour améliorer la prise en main. | The worker knurls the metal handle to improve grip. |
| 5006 | saumurer | saumure | Le charcutier saumure le jambon pendant plusieurs jours avant de le fumer. | The butcher soaks the ham in brine for several days before smoking it. |
| 5007 | équivoquer | équivoque | Le témoin équivoque sur les détails de l'accident pour éviter d'incriminer son ami. | The witness equivocates about the details of the accident to avoid incriminating his friend. |
| 5008 | slicer | slice | Le golfeur slice sa balle dans les arbres au moment le plus critique. | The golfer slices the ball into the trees at the worst possible moment. |
| 5009 | floculer | floculent | Les particules d'argile floculent lorsqu'on ajoute du sel à l'eau trouble. | The clay particles flocculate when salt is added to the murky water. |
| 5011 | grisailler | grisaillent | Les cheveux de mon père grisaillent rapidement depuis son cinquantième anniversaire. | My father's hair is quickly turning gray since his fiftieth birthday. |
| 5012 | insensibiliser | insensibilise | Le dentiste insensibilise la gencive avant d'arracher la dent. | The dentist numbs the gum before pulling the tooth. |
| 5013 | margotter | margotte | La caille mâle margotte dans le champ pour attirer une femelle. | The male quail makes its mating call in the field to attract a female. |
| 5014 | baratter | baratte | La fermière baratte la crème pendant une heure pour obtenir du beurre. | The farmer churns the cream for an hour to make butter. |
| 5015 | traficoter | traficote | Mon oncle traficote toujours des pièces détachées au marché noir. | My uncle is always dealing in spare parts on the black market. |
| 5016 | rechaper | rechape | Le garagiste rechape les pneus usés pour prolonger leur durée de vie. | The mechanic retreads the worn tires to extend their lifespan. |
| 5018 | diaphragmer | diaphragme | Le photographe diaphragme l'objectif pour obtenir une plus grande profondeur de champ. | The photographer stops down the lens to get greater depth of field. |
| 5019 | stérer | stère | Le bûcheron stère le bois empilé pour connaître son volume exact. | The woodcutter measures the stacked wood in cubic meters to find its exact volume. |
| 5020 | ripoliner | ripoline | Le gouvernement ripoline son image avant les élections sans changer de politique. | The government revamps its image before the elections without changing its policies. |
| 5022 | prolétariser | prolétarise | La mondialisation prolétarise de nombreux artisans qui perdent leur indépendance économique. | Globalization proletarianizes many craftsmen who lose their economic independence. |
| 5024 | ripailler | ripaillent | Les invités ripaillent joyeusement jusqu'à minuit lors du mariage. | The guests feast joyfully until midnight at the wedding. |
| 5025 | césariser | césarise | Le jury césarise cette actrice pour son rôle bouleversant dans le film. | The jury gives this actress the César Award for her moving role in the film. |
| 5026 | massicoter | massicote | L'imprimeur massicote les feuilles de papier pour uniformiser leur format. | The printer cuts the sheets of paper to a uniform size with a guillotine cutter. |
| 5028 | lapiner | lapiné | Notre lapine a lapiné cette nuit et a donné naissance à six lapereaux. | Our doe rabbit gave birth last night and produced six kits. |
| 5030 | crachoter | crachote | Le vieux poste de radio crachote légèrement avant de capter la station. | The old radio crackles slightly before it picks up the station. |
| 5032 | judiciariser | judiciarise | Le gouvernement judiciarise de plus en plus les conflits sociaux au lieu de négocier. | The government increasingly judicializes social conflicts instead of negotiating. |
| 5033 | expectorer | expectore | Le patient tousse et expectore abondamment à cause de sa bronchite. | The patient coughs and expectorates heavily because of his bronchitis. |
| 5034 | reprographier | reprographie | Le secrétariat reprographie les documents avant la réunion du conseil. | The secretariat photocopies the documents before the board meeting. |
| 5036 | marketer | markete | Cette entreprise markete ses produits uniquement via les réseaux sociaux. | This company markets its products only via social media. |
| 5037 | entrelarder | entrelarder | Le boucher aime entrelarder le rôti de fines tranches de lard avant de le cuire. | The butcher likes to lard the roast with thin strips of bacon before cooking it. |
| 5040 | remaquiller | remaquille | La maquilleuse remaquille l'actrice avant la scène suivante. | The makeup artist redoes the actress's makeup before the next scene. |
| 5041 | décuver | décuve | Le vigneron décuve le vin dès que la fermentation est terminée. | The winemaker removes the wine from the vat as soon as fermentation is finished. |
| 5043 | truander | truande | Ce vendeur truande les touristes en leur vendant de faux souvenirs. | This vendor cons tourists by selling them fake souvenirs. |
| 5044 | tonsurer | tonsuré | Le moine fut tonsuré avant de prononcer ses vœux. | The monk was tonsured before taking his vows. |
| 5045 | aluminer | alumine | L'usine alumine ces pièces métalliques pour les protéger de la corrosion. | The factory aluminizes these metal parts to protect them from corrosion. |
| 5048 | remordre | remord | Le chien apeuré remord la main qui essaie de le calmer. | The frightened dog bites again at the hand trying to calm it down. |
| 5049 | friter | frités | Les deux frères se sont frités hier soir à cause d'une vieille dette. | The two brothers had a fight last night over an old debt. |
| 5050 | réadmettre | réadmet | Le comité réadmet l'étudiant renvoyé l'an dernier après son appel. | The committee is readmitting the student who was expelled last year, following his appeal. |
| 5051 | bouffonner | bouffonner | Pendant la fête, mon oncle aime bouffonner pour faire rire les enfants. | At the party, my uncle likes to clown around to make the children laugh. |
| 5053 | inférioriser | infériorise | Ce professeur infériorise les élèves qui posent des questions simples. | That teacher belittles students who ask simple questions. |
| 5054 | dénaturaliser | dénaturaliser | Le gouvernement menace de dénaturaliser les citoyens reconnus coupables de trahison. | The government is threatening to denaturalize citizens found guilty of treason. |
| 5055 | repercer | reperce | Le mécanicien reperce le trou pour que la vis s'insère correctement. | The mechanic repierces the hole so the screw will fit properly. |
| 5057 | lexicaliser | lexicalisent | Les linguistes lexicalisent ce néologisme en l'ajoutant au dictionnaire officiel. | Linguists lexicalize this neologism by adding it to the official dictionary. |
| 5060 | empoussiérer | empoussière | Le vent du désert empoussière rapidement les meubles laissés dehors. | The desert wind quickly covers furniture left outside with dust. |
| 5062 | ronéoter | ronéote | Chaque matin, la secrétaire ronéote les circulaires destinées aux enseignants. | Every morning, the secretary runs off the circulars for teachers on the Roneo machine. |
| 5063 | écher | écher | Le pêcheur prend le temps d'écher soigneusement chaque hameçon avant de lancer sa ligne. | The fisherman takes the time to carefully bait each hook before casting his line. |
| 5064 | balkaniser | balkanisent | Les rivalités ethniques balkanisent davantage la région. | Ethnic rivalries are further balkanizing the region. |
| 5065 | amerrir | amerri | La capsule spatiale a amerri sans encombre dans l'océan Pacifique. | The space capsule splashed down safely in the Pacific Ocean. |
| 5068 | masculiniser | masculinise | Le styliste masculinise la silhouette de cette robe pour la collection d'automne. | The designer is masculinizing the silhouette of this dress for the fall collection. |
| 5069 | épouiller | épouille | Le vétérinaire épouille soigneusement le chien avant de le rendre à sa famille. | The vet carefully delouses the dog before returning it to its family. |
| 5070 | glouglouter | glougloute | La dinde glougloute joyeusement dans la basse-cour chaque matin. | The turkey gobbles happily in the barnyard every morning. |
| 5072 | démagnétiser | démagnétise | Le technicien démagnétise la carte pour effacer les données. | The technician demagnetizes the card to erase the data. |
| 5073 | pommeler | pommelle | Le peintre pommelle le ciel de petits nuages blancs pour son tableau. | The painter dapples the sky with little white clouds for his painting. |
| 5074 | rutiler | rutilent | Les vitraux rutilent sous le soleil couchant. | The stained-glass windows glow in the setting sun. |
| 5075 | somatiser | somatiser | Après l'accident, elle a commencé à somatiser son stress sous forme de maux de tête. | After the accident, she began to somatize her stress as headaches. |
| 5076 | désindustrialiser | désindustrialisé | Dans les années 1980, la crise a désindustrialisé plusieurs régions du pays. | In the 1980s, the crisis deindustrialized several regions of the country. |
| 5077 | vagir | vagit | Le nouveau-né vagit dès sa naissance dans la salle d'accouchement. | The newborn wails right from birth in the delivery room. |
| 5080 | démoduler | démodule | Le récepteur radio démodule le signal pour restituer le son. | The radio receiver demodulates the signal to recover the sound. |
| 5081 | enamourer | s'est enamouré | Il s'est enamouré d'elle dès leur première rencontre. | He fell in love with her from their very first meeting. |
| 5083 | discorder | discordent | Ces deux témoignages discordent sur l'heure exacte de l'incident. | These two accounts disagree about the exact time of the incident. |
| 5085 | stuquer | stuquent | Les artisans stuquent les murs du salon pour leur donner un fini lisse. | The craftsmen stucco the living room walls to give them a smooth finish. |
| 5086 | désentraver | désentrave | Le fermier désentrave le cheval avant de le laisser paître dans le pré. | The farmer unshackles the horse before letting it graze in the field. |
| 5089 | flemmarder | flemmarder | Le dimanche, il préfère flemmarder sur le canapé plutôt que de sortir. | On Sundays, he'd rather laze around on the couch than go out. |
| 5090 | jointoyer | jointoie | Le maçon jointoie les briques avec du mortier frais. | The mason grouts the bricks with fresh mortar. |
| 5091 | déconditionner | déconditionne | Le repos prolongé au lit déconditionne rapidement les muscles des jambes. | Prolonged bed rest quickly deconditions the leg muscles. |
| 5092 | défourailler | défouraille | Le braqueur défouraille dès que l'alarme se déclenche. | The robber draws his gun the moment the alarm goes off. |
| 5093 | becter | becter | Les gamins adorent becter des frites après l'école. | The kids love scarfing down fries after school. |
| 5094 | marginer | marginait | L'étudiant marginait ses notes de cours pour ajouter des remarques personnelles. | The student annotated the margins of his lecture notes with personal remarks. |
| 5096 | pantoufler | pantouflé | Après quinze ans dans l'administration, elle a pantouflé dans une grande banque privée. | After fifteen years in the civil service, she moved into a job at a big private bank. |
| 5097 | galonner | galonne | La couturière galonne le col de la veste pour l'embellir. | The seamstress braids the jacket collar to embellish it. |
| 5099 | renfiler | renfiler | Il faut renfiler l'aiguille avant de continuer la couture. | You need to rethread the needle before continuing the sewing. |
| 5101 | herbager | herbage | Le berger herbage ses moutons dans le pré communal chaque été. | The shepherd puts his sheep out to pasture in the communal meadow every summer. |
| 5104 | épisser | épisse | Le marin épisse les deux bouts de corde pour réparer l'amarre. | The sailor splices the two rope ends to repair the mooring line. |
| 5105 | ébavurer | ébavure | L'ouvrier ébavure la pièce métallique avant de l'assembler. | The worker deburrs the metal part before assembling it. |
| 5106 | judaïser | judaïser | Certains historiens disent que l'empire a tenté de judaïser certaines provinces conquises. | Some historians say the empire tried to Judaize certain conquered provinces. |
| 5107 | revernir | revernit | Le peintre revernit la vieille table avant de la vendre. | The painter revarnishes the old table before selling it. |
| 5108 | déchaumer | déchaume | Le fermier déchaume le champ après la moisson d'été. | The farmer clears the field of stubble after the summer harvest. |
| 5109 | raper | rape | Le jeune artiste rape sur un rythme improvisé lors de la soirée. | The young artist raps over an improvised beat at the party. |
| 5110 | chinoiser | chinoiser | Arrête de chinoiser sur des détails inutiles, on n'a pas le temps. | Stop quibbling over pointless details, we don't have time. |
| 5111 | flageoler | flageolaient | Ses jambes flageolaient tellement il avait peur avant l'examen. | His legs were shaking so much he was frightened before the exam. |
| 5114 | décapoter | décapote | Elle décapote sa voiture dès que le soleil brille. | She puts the top down on her car as soon as the sun is out. |
| 5115 | débobiner | débobine | Le technicien débobine le câble avant de le ranger. | The technician unwinds the cable before putting it away. |
| 5120 | gréser | grèse | L'artisan grèse la pierre pour la rendre parfaitement lisse. | The craftsman sands the stone with a grinding block to make it perfectly smooth. |
| 5121 | suçoter | suçote | Le bébé suçote son pouce pour s'endormir. | The baby sucks on his thumb to fall asleep. |
| 5122 | ambler | amblait | Le vieux cheval amblait tranquillement sur le chemin de campagne. | The old horse ambled calmly along the country road. |
| 5127 | engainer | engaine | Le soldat engaine son épée avant de quitter le champ de bataille. | The soldier sheathes his sword before leaving the battlefield. |
| 5129 | cryptographier | cryptographient | Les entreprises cryptographient leurs données sensibles avant de les transmettre. | Companies encrypt their sensitive data before transmitting it. |
| 5131 | surproduire | surproduisent | Les usines surproduisent parfois pour anticiper une hausse de la demande. | Factories sometimes overproduce to anticipate a rise in demand. |
| 5132 | chamoiser | chamoise | L'artisan chamoise la peau de chèvre pour en faire du cuir souple. | The craftsman chamois-dresses the goatskin to turn it into soft leather. |
| 5133 | sonnailler | sonnaillent | Les clochettes des vaches sonnaillent doucement dans le pré. | The cowbells jingle softly in the meadow. |
| 5134 | boucharder | boucharde | Le maçon boucharde la pierre pour lui donner une texture antidérapante. | The mason bush-hammers the stone to give it a nonskid texture. |
| 5135 | survirer | survire | La voiture survire dans le virage à cause de la pluie. | The car oversteers through the turn because of the rain. |
| 5139 | désaffilier | désaffilie | La fédération désaffilie le club pour non-paiement des cotisations. | The federation disaffiliates the club for non-payment of dues. |
| 5140 | encliqueter | encliquette | Le mécanicien encliquette la pièce pour qu'elle reste bien en place. | The mechanic clips the part into place so it stays put. |
| 5141 | béquiller | béquille | Le motard béquille sa moto avant d'entrer dans le café. | The biker puts his motorcycle on its kickstand before going into the café. |
| 5143 | nieller | nielle | L'orfèvre nielle le manche du poignard avec un motif d'argent noirci. | The silversmith niellos the dagger's handle with a blackened silver pattern. |
| 5145 | luger | luger | Les enfants adorent luger sur la colline enneigée après l'école. | The kids love to sled down the snowy hill after school. |
| 5146 | clamper | clampé | Le chirurgien a clampé l'artère avant de commencer l'opération. | The surgeon clamped the artery before starting the operation. |
| 5150 | abouter | aboute | Le menuisier aboute les deux planches pour former une table plus longue. | The carpenter joins the two boards end to end to make a longer table. |
| 5151 | récoler | récolé | L'huissier a récolé l'inventaire avant de clore le dossier. | The bailiff verified the inventory before closing the case file. |
| 5153 | ramager | ramage | Le rossignol ramage dès l'aube, remplissant le jardin de son chant. | The nightingale sings from dawn, filling the garden with its song. |
| 5155 | parementer | parementé | Le tailleur a parementé la veste avec un tissu de soie fine. | The tailor faced the jacket with fine silk fabric. |
| 5156 | resalir | resali | Le chien a resali le tapis juste après qu'on l'ait nettoyé. | The dog got the carpet dirty again right after we cleaned it. |
| 5157 | entre-égorger | entre-égorgées | Les deux tribus rivales se sont entre-égorgées pendant des décennies de guerre. | The two rival tribes tore each other's throats out over decades of war. |
| 5158 | tire-bouchonner | tire-bouchonnait | Son pantalon tire-bouchonnait sur ses chaussures tout l'après-midi. | His pants kept bunching up over his shoes all afternoon. |
| 5160 | resquiller | resquillé | Il a resquillé dans le métro en sautant par-dessus le tourniquet. | He rode the subway without a ticket by hopping over the turnstile. |
| 5161 | grailler | graillé | Les ouvriers ont graillé un sandwich avant de reprendre le chantier. | The workers grabbed a snack before getting back to the job site. |
| 5164 | ébrancher | ébranche | Le jardinier ébranche le vieux chêne pour laisser passer plus de lumière. | The gardener trims the branches off the old oak to let in more light. |
| 5167 | sandwicher | sandwichent | Les employés sandwichent rapidement à leur bureau avant la réunion. | The employees quickly grab a sandwich at their desks before the meeting. |
| 5168 | tayloriser | taylorisé | L'usine a taylorisé sa chaîne de production pour réduire les coûts. | The factory Taylorized its production line to cut costs. |
| 5169 | sexualiser | sexualise | La publicité sexualise souvent des situations banales pour attirer l'attention. | Advertising often sexualizes ordinary situations to grab attention. |
| 5170 | damasser | damasse | L'artisan damasse la lame d'acier pour lui donner un motif ondulé. | The craftsman damascenes the steel blade to give it a wavy pattern. |
| 5171 | apponter | apponter | Le pilote a réussi à apponter sur le porte-avions malgré le mauvais temps. | The pilot managed to land on the aircraft carrier despite the bad weather. |
| 5173 | défatiguer | défatigué | Cette courte sieste m'a bien défatigué avant le rendez-vous important. | This short nap really refreshed me before the important meeting. |
| 5174 | fayoter | fayote | Il fayote sans arrêt pour obtenir une promotion plus vite. | He's constantly brownnosing to get promoted faster. |
| 5175 | électrolyser | électrolyse | Le chimiste électrolyse l'eau pour produire de l'hydrogène et de l'oxygène. | The chemist electrolyzes water to produce hydrogen and oxygen. |
| 5176 | écimer | écime | Le jardinier écime les jeunes saules chaque printemps pour favoriser leur croissance. | The gardener pollards the young willows every spring to encourage their growth. |
| 5177 | caboter | cabote | Le petit cargo cabote le long de la côte bretonne, s'arrêtant dans chaque petit port. | The small cargo ship coasts along the Breton coastline, stopping in every little port. |
| 5178 | déforester | déforestent | Les grandes entreprises déforestent la forêt amazonienne pour cultiver du soja. | Large companies are deforesting the Amazon rainforest to grow soybeans. |
| 5179 | vaseliner | vaseline | L'infirmière vaseline le thermomètre avant de l'utiliser sur le patient. | The nurse coats the thermometer with vaseline before using it on the patient. |
| 5183 | dégripper | dégripper | Il a vaporisé de l'huile pour dégripper le vieux boulon rouillé. | He sprayed oil to loosen the old rusted bolt. |
| 5184 | cureter | cureter | Le chirurgien doit cureter l'utérus après une fausse couche. | The surgeon must curette the uterus after a miscarriage. |
| 5186 | clamser | clamser | Mon vieux chat a failli clamser d'une crise cardiaque la semaine dernière. | My old cat nearly kicked the bucket from a heart attack last week. |
| 5188 | créoliser | créoliser | Le contact prolongé entre les langues a fini par créoliser le vocabulaire local. | Prolonged contact between the languages eventually creolized the local vocabulary. |
| 5189 | euphoriser | euphorise | Cette musique entraînante euphorise instantanément toute la salle. | This upbeat music instantly sends the whole room into euphoria. |
| 5191 | désensabler | désensabler | Les pêcheurs ont dû désensabler le bateau échoué sur la plage. | The fishermen had to dig the sand away from the boat stranded on the beach. |
| 5192 | psychiatriser | psychiatriser | Certains médecins tendent à psychiatriser des comportements qui sont simplement inhabituels. | Some doctors tend to psychiatrize behaviors that are merely unusual. |
| 5194 | débourber | débourber | Le fermier a dû débourber le tracteur enlisé dans le champ. | The farmer had to get the tractor unstuck from the mud in the field. |
| 5195 | encocher | encoche | L'archer encoche la flèche avant de tendre son arc. | The archer nocks the arrow before drawing his bow. |
| 5196 | liaisonner | liaisonne | Le maçon liaisonne soigneusement chaque rangée de briques avec du mortier. | The mason carefully bonds each row of bricks with mortar. |
| 5199 | bringuebaler | bringuebale | Le vieux bus bringuebale sur la route caillouteuse à chaque virage. | The old bus jolts and sways on the bumpy road with every turn. |
| 5200 | canoter | canotent | Chaque été, ils canotent sur le lac paisible en admirant les montagnes environnantes. | Every summer, they go canoeing on the peaceful lake, admiring the surrounding mountains. |
| 5201 | quintessencier | quintessencie | Ce poème quintessencie à merveille la mélancolie de l'automne. | This poem perfectly distills the melancholy of autumn. |
| 5202 | défolier | défolier | L'armée a utilisé des produits chimiques pour défolier la forêt tropicale. | The army used chemicals to defoliate the tropical forest. |
| 5205 | dissoner | dissone | Cette note aiguë dissone étrangement avec le reste de la mélodie. | That high note clashes strangely with the rest of the melody. |
| 5206 | marabouter | marabouter | Le sorcier prétendait pouvoir marabouter quiconque refusait de le payer. | The witch doctor claimed he could put a curse on anyone who refused to pay him. |
| 5207 | raguer | raguer | Le cordage a fini par raguer contre le rocher et s'est rompu. | The rope eventually chafed against the rock and snapped. |
| 5208 | grenailler | grenaille | L'usine grenaille le métal fondu pour produire de petites billes. | The factory granulates the molten metal to produce small pellets. |
| 5209 | hydrofuger | hydrofuger | Il faut hydrofuger la façade avant l'arrivée de l'hiver. | The facade needs to be waterproofed before winter arrives. |
| 5210 | bachoter | bachotent | Les élèves bachotent toute la nuit avant l'examen de mathématiques. | The students are cramming all night before the math exam. |
| 5211 | cachetonner | cachetonner | Le musicien préfère cachetonner dans plusieurs orchestres plutôt que d'avoir un poste fixe. | The musician prefers to freelance for pay in several orchestras rather than hold a permanent position. |
| 5212 | sacquer | sacqué | Le patron a sacqué son employé après plusieurs retards. | The boss sacked his employee after several instances of lateness. |
| 5213 | hutter | hutté | Les bergers ont hutté au sommet de la montagne pour l'été. | The shepherds built a hut on the mountaintop for the summer. |
| 5216 | radiner | radiné | Il a radiné au dernier moment, juste avant la fermeture du magasin. | He showed up at the last moment, just before the store closed. |
| 5217 | refoutre | refoutu | Il a refoutu ses clés dans sa poche avant de sortir. | He put his keys back in his pocket before going out. |
| 5218 | postposer | postpose | En français, on postpose souvent l'adjectif après le nom. | In French, the adjective is often postposed after the noun. |
| 5219 | désexciter | désexcite | Le laser désexcite les atomes en libérant de l'énergie lumineuse. | The laser de-excites the atoms, releasing light energy. |
| 5220 | hercher | herchait | Le jeune mineur herchait les wagonnets de charbon toute la journée dans la galerie. | The young miner pushed the coal carts all day in the gallery. |
| 5221 | syndicaliser | syndicalisé | Le syndicat a syndicalisé la totalité de l'entreprise en un an. | The union unionized the entire company within a year. |
| 5222 | stariser | starisé | Ce film a starisé l'actrice inconnue du jour au lendemain. | This film turned the unknown actress into a star overnight. |
| 5223 | dealer | dealait | Il dealait de la drogue près du lycée avant d'être arrêté par la police. | He was dealing drugs near the high school before being arrested by the police. |
| 5224 | remailler | remaille | La couturière remaille délicatement les mailles filées de son pull en laine. | The seamstress carefully mends the runs in her wool sweater. |
| 5225 | ajointer | ajointe | Le charpentier ajointe les deux planches avant de les visser ensemble. | The carpenter butts the two planks together before screwing them. |
| 5226 | débarder | débardent | Les bûcherons débardent les troncs abattus jusqu'à la route forestière. | The lumberjacks haul the felled trunks to the forest road. |
| 5228 | transistoriser | transistorisé | Les ingénieurs ont transistorisé la radio pour la rendre plus légère. | The engineers transistorized the radio to make it lighter. |
| 5234 | ségréguer | ségréguer | Cette politique visait à ségréguer les quartiers selon l'origine ethnique des habitants. | This policy aimed to segregate neighborhoods according to residents' ethnic origin. |
| 5236 | biper | bipé | La chaîne a bipé le gros mot pendant la retransmission en direct. | The network bleeped out the swear word during the live broadcast. |
| 5237 | drageonner | drageonne | Le framboisier drageonne abondamment autour du pied de la haie. | The raspberry bush sends up suckers abundantly around the base of the hedge. |
| 5239 | échopper | échoppe | Le graveur échoppe minutieusement le cuivre pour créer les motifs de l'estampe. | The engraver meticulously chisels the copper to create the print's patterns. |
| 5240 | halener | halena | Le chien halena la piste du gibier avant de s'élancer dans les bois. | The dog scented the game's trail before dashing into the woods. |
| 5241 | prédiquer | prédique | En logique, on prédique une propriété du sujet de la phrase. | In logic, one predicates a property of the sentence's subject. |
| 5242 | yoyotter | yoyotte | Depuis son accident, il yoyotte complètement et ne reconnaît plus personne. | Since his accident, he's completely lost it and doesn't recognize anyone anymore. |
| 5243 | chloroformer | chloroformé | Le médecin a chloroformé le patient avant de procéder à l'opération. | The doctor chloroformed the patient before performing the operation. |
| 5247 | shampouiner | shampouine | Elle shampouine son chien tous les mois avant de le brosser. | She shampoos her dog every month before brushing him. |
| 5248 | détoxiquer | détoxiquer | Le médecin l'aide à détoxiquer son corps après ces excès de fête. | The doctor is helping him detoxify his body after the excesses of the party. |
| 5254 | trisser | trisse | L'hirondelle trisse sous les toits chaque matin de printemps. | The swallow cries out under the eaves every spring morning. |
| 5257 | bléser | blèse | Le petit garçon blèse encore un peu quand il parle vite. | The little boy still lisps a bit when he talks fast. |
| 5258 | nitrurer | nitrure | L'usine nitrure les pièces en acier pour durcir leur surface. | The factory nitrides the steel parts to harden their surface. |
| 5260 | rabouter | raboute | Le menuisier raboute deux planches pour former une longue table. | The carpenter joins two boards end to end to make a long table. |
| 5261 | vamper | vampe | Elle vampe le nouveau venu dès qu'il entre dans la soirée. | She vamps the newcomer the moment he walks into the party. |
| 5262 | folkloriser | folkloriser | Le gouvernement risque de folkloriser cette tradition en la réduisant à un spectacle touristique. | The government risks turning this tradition into mere folklore by reducing it to a tourist show. |
| 5263 | lanciner | lancine | Une douleur lancine son genou depuis l'opération. | A sharp pain has been shooting through his knee since the operation. |
| 5266 | néantiser | néantiser | Le nihiliste veut néantiser toute croyance en un sens supérieur. | The nihilist wants to annihilate all belief in any higher meaning. |
| 5272 | nasaliser | nasalisent | Les Parisiens nasalisent souvent la voyelle finale du mot. | Parisians often nasalize the final vowel of the word. |
| 5273 | raire | raire | Le cerf commence à raire dès la tombée de la nuit en période de rut. | The stag starts belling as night falls during the rutting season. |
| 5274 | défléchir | défléchit | Le bouclier magique défléchit les tirs ennemis avant qu'ils n'atteignent la cible. | The magic shield deflects enemy shots before they reach the target. |
| 5276 | tréfiler | tréfile | L'usine tréfile l'acier pour fabriquer des câbles solides. | The factory draws the steel into wire to make sturdy cables. |
| 5277 | africaniser | africaniser | Le nouveau gouvernement veut africaniser l'administration coloniale héritée. | The new government wants to Africanize the inherited colonial administration. |
| 5278 | nitrer | nitre | Le chimiste nitre le composé pour obtenir un explosif plus puissant. | The chemist nitrates the compound to produce a more powerful explosive. |
| 5279 | frisotter | frisottent | Ses cheveux frisottent dès qu'il fait humide dehors. | Her hair curls up as soon as it's humid outside. |
| 5281 | grattouiller | grattouille | Cette étiquette me grattouille dans le cou toute la journée. | This tag has been itching my neck all day. |
| 5282 | remmener | remmène | Le chauffeur remmène les enfants à la maison après l'école. | The driver takes the children back home after school. |
| 5283 | rebouter | reboute | Le rebouteux reboute le poignet foulé du jeune athlète avec des gestes précis. | The bonesetter sets the young athlete's sprained wrist with precise movements. |
| 5284 | calandrer | calandre | L'ouvrier calandre le tissu pour lui donner un fini lisse et brillant. | The worker calenders the fabric to give it a smooth, glossy finish. |
| 5286 | axiomatiser | axiomatisé | Le mathématicien a axiomatisé la théorie des ensembles pour en clarifier les fondements. | The mathematician axiomatized set theory to clarify its foundations. |
| 5287 | chouraver | chouravé | Le gamin a chouravé un vélo devant le supermarché. | The kid nicked a bike outside the supermarket. |
| 5288 | désinsectiser | désinsectisé | L'entreprise a désinsectisé l'entrepôt après avoir repéré des cafards. | The company de-insected the warehouse after spotting cockroaches. |
| 5289 | éluer | élue | Le chimiste élue les composés retenus sur la colonne avec un solvant approprié. | The chemist elutes the compounds trapped on the column using a suitable solvent. |
| 5290 | réimposer | réimposé | Le gouvernement a réimposé des droits de douane sur les importations d'acier. | The government reimposed tariffs on steel imports. |
| 5292 | magnétoscoper | magnétoscopé | Le technicien a magnétoscopé toute la finale de la coupe du monde pour ses enfants. | The technician recorded the entire World Cup final on VHS for his children. |
| 5293 | tortorer | tortoraient | Les gamins tortoraient un sandwich en rentrant de l'école. | The kids were scarfing down a sandwich on their way home from school. |
| 5296 | fumiger | fumige | Le vigneron fumige les vignes tous les printemps pour prévenir les maladies. | The winegrower fumigates the vines every spring to prevent disease. |
| 5297 | étrécir | étrécit | Le tailleur étrécit la veste pour qu'elle s'ajuste mieux à sa silhouette. | The tailor narrows the jacket so it fits her figure better. |
| 5298 | équerrer | équerre | Le menuisier équerre la planche avant de la découper avec précision. | The carpenter squares off the board before cutting it precisely. |
| 5300 | godiller | godille | Le rameur godille pour avancer sans faire de bruit. | The rower sculls to move forward without making any noise. |
| 5301 | contusionner | contusionné | La chute l'a contusionné au genou mais sans rien casser. | The fall bruised his knee but broke nothing. |
| 5303 | chevroter | chevrotait | Sa voix chevrotait d'émotion lorsqu'elle raconta son histoire. | Her voice quavered with emotion as she told her story. |
| 5304 | talquer | talque | L'infirmière talque délicatement la peau du nourrisson après le bain. | The nurse gently talcs the baby's skin after the bath. |
| 5307 | piffer | piffer | Je ne peux pas piffer ce type prétentieux qui parle sans arrêt. | I can't stand that pretentious guy who never stops talking. |
| 5308 | cafter | cafté | Le petit frère a cafté auprès de leur mère pour le vase cassé. | The little brother ratted them out to their mother over the broken vase. |
| 5309 | déséquiper | déséquipé | L'armateur a déséquipé le vieux cargo avant de le vendre à la casse. | The shipowner stripped the old cargo ship of its equipment before selling it for scrap. |
| 5312 | étouper | étoupe | Le charpentier étoupe les fissures de la coque avant de la mettre à l'eau. | The shipwright caulks the cracks in the hull before putting it in the water. |
| 5313 | soviétiser | soviétisé | Après la guerre, le régime a soviétisé l'ensemble du système éducatif. | After the war, the regime Sovietized the entire education system. |
| 5314 | ensauvager | ensauvagé | Le conflit prolongé a ensauvagé les rapports entre les deux camps. | The prolonged conflict made relations between the two camps more savage. |
| 5316 | boitiller | boitillait | Après sa chute, il boitillait légèrement en rentrant chez lui. | After his fall, he limped slightly on his way home. |
| 5319 | starifier | starifié | Cette émission de télé-réalité a starifié plusieurs inconnus du jour au lendemain. | This reality show turned several unknowns into stars overnight. |
| 5320 | ringarder | ringarde | Le forgeron ringarde le charbon pour raviver les flammes de la forge. | The blacksmith stirs the coals to revive the forge's flames. |
| 5321 | regrimper | regrimpé | Après être tombé, il a regrimpé rapidement sur son vélo pour continuer la course. | After falling, he quickly climbed back onto his bike to continue the race. |
| 5322 | mésuser | mésusez | Ne mésusez pas de votre pouvoir, car cela finira par vous nuire. | Don't misuse your power, because it will end up hurting you. |
| 5324 | surmouler | surmoulé | L'artisan a surmoulé une copie exacte du vase ancien pour la vendre moins cher. | The craftsman overmolded an exact copy of the ancient vase to sell it more cheaply. |
| 5325 | pyrograver | pyrogravé | L'artiste a pyrogravé un motif floral sur la planche de bois. | The artist burned a floral pattern into the wooden board. |
| 5326 | cafeter | cafeté | Il a cafeté son collègue auprès du patron pour éviter les ennuis. | He ratted on his colleague to the boss to avoid trouble. |
| 5327 | désaccoupler | désaccouple | Le technicien désaccouple les deux wagons avant de les envoyer sur des voies différentes. | The technician uncouples the two railcars before sending them onto different tracks. |
| 5329 | fédéraliser | fédéraliser | Le gouvernement souhaite fédéraliser certains services pour réduire les coûts administratifs. | The government wants to federalize certain services to cut administrative costs. |
| 5330 | damasquiner | damasquiné | L'artisan a damasquiné la lame de l'épée avec des filets d'argent. | The craftsman damascened the sword blade with silver threads. |
| 5331 | encaustiquer | encaustique | Chaque dimanche, elle encaustique les meubles anciens du salon. | Every Sunday, she waxes the antique furniture in the living room. |
| 5333 | zozoter | zozote | Le petit garçon zozote encore un peu quand il est fatigué. | The little boy still lisps a bit when he's tired. |
| 5335 | houblonner | houblonne | Le brasseur houblonne la bière pour lui donner un goût amer. | The brewer hops the beer to give it a bitter taste. |
| 5337 | désoxygéner | désoxygène | Le processus désoxygène le sang avant qu'il ne retourne aux poumons. | The process deoxygenates the blood before it returns to the lungs. |
| 5339 | bêtifier | bêtifie | Il bêtifie complètement quand il parle à son bébé. | He turns into a complete goofball when he talks to his baby. |
| 5340 | sextupler | sextuplé | L'entreprise a sextuplé ses profits en seulement trois ans. | The company sextupled its profits in just three years. |
| 5342 | duveter | duveter | Au printemps, les jeunes oiseaux commencent à se duveter dans le nid. | In spring, the young birds start growing downy feathers in the nest. |
| 5348 | yoyoter | yoyoter | Les enfants adorent yoyoter dans la cour pendant la récréation. | The children love playing with their yo-yos in the yard during recess. |
| 5349 | pacager | pacagent | Les moutons pacagent tranquillement dans le pré depuis ce matin. | The sheep have been grazing peacefully in the meadow since this morning. |
| 5350 | réinfecter | réinfecter | Sans traitement adapté, le virus peut réinfecter le patient rapidement. | Without proper treatment, the virus can reinfect the patient quickly. |
| 5351 | remplumer | remplumer | Après sa maladie, il commence enfin à se remplumer un peu. | After his illness, he is finally starting to put some weight back on. |
| 5354 | cancériser | cancériser | Cette tumeur bénigne risque de se cancériser si elle n'est pas surveillée. | This benign tumor may become cancerous if it isn't monitored. |
| 5355 | framboiser | framboisé | Le pâtissier a framboisé la génoise avant de la décorer de fruits frais. | The pastry chef flavored the sponge cake with raspberry before decorating it with fresh fruit. |
| 5356 | désulfurer | désulfurer | L'usine doit désulfurer le charbon avant de le brûler pour limiter la pollution. | The plant must desulfurize the coal before burning it to limit pollution. |
| 5358 | merdoyer | merdoyé | Devant la question du professeur, il a complètement merdoyé et n'a pas su répondre. | Faced with the teacher's question, he completely floundered and couldn't answer. |
| 5359 | excorier | excorier | Le frottement répété de la sangle a fini par excorier la peau du cheval. | The repeated rubbing of the strap eventually chafed the horse's skin raw. |
| 5360 | désacidifier | désacidifier | Les restaurateurs doivent désacidifier le papier ancien pour ralentir sa dégradation. | Conservators must deacidify old paper to slow its deterioration. |
| 5361 | aleviner | alevinent | Chaque printemps, les pêcheurs locaux alevinent la rivière avec de jeunes truites. | Every spring, local anglers stock the river with young trout. |
| 5363 | contrebattre | contrebattu | L'artillerie française a rapidement contrebattu les positions ennemies après le premier tir. | French artillery quickly returned fire on the enemy positions after the first shot. |
| 5364 | ferler | ferler | Avant la tempête, les marins se sont dépêchés de ferler les voiles. | Before the storm, the sailors hurried to furl the sails. |
| 5365 | sténographier | sténographier | La secrétaire savait sténographier un discours entier sans en perdre un mot. | The secretary could take down an entire speech in shorthand without missing a word. |
| 5368 | décalaminer | décalaminer | Le mécanicien a dû décalaminer le moteur encrassé par des années de trajets courts. | The mechanic had to decoke the engine, fouled by years of short trips. |
| 5369 | délaiter | délaiter | Après le barattage, la fermière prend soin de délaiter le beurre avant de le rincer. | After churning, the farmer carefully skims off the buttermilk before rinsing the butter. |
| 5370 | potabiliser | potabiliser | Cette usine utilise plusieurs filtres pour potabiliser l'eau de la rivière. | This plant uses several filters to make river water drinkable. |
| 5375 | débanaliser | débanaliser | Le nouveau chef a réussi à débanaliser ce plat traditionnel avec une présentation originale. | The new chef managed to make this traditional dish distinctive with an original presentation. |
| 5376 | criailler | criailler | Les enfants n'arrêtaient pas de criailler pour avoir plus de bonbons. | The children wouldn't stop whining for more candy. |
| 5377 | nanifier | nanifier | Les bonsaïistes taillent les racines pour nanifier le petit pin sans l'affaiblir. | Bonsai growers trim the roots to dwarf the little pine without weakening it. |
| 5379 | pifer | pifer | Il ne peut vraiment pas pifer son nouveau collègue trop bavard. | He really can't stand his overly talkative new colleague. |
| 5380 | amuïr | amuï | Le s final du mot s'est amuï au fil des siècles. | The word's final s fell silent over the centuries. |
| 5382 | déjauger | déjauger | À pleine vitesse, le hors-bord commence à déjauger et glisse presque sur l'eau. | At full speed, the speedboat starts to plane and skims almost on top of the water. |
| 5388 | biscuiter | biscuite | Le potier biscuite les vases avant de les émailler. | The potter fires the vases unglazed before glazing them. |
| 5389 | défibrer | défibre | L'usine défibre le bois pour produire de la pâte à papier. | The factory strips the wood of its fibers to make paper pulp. |
| 5390 | claveter | clavette | Le mécanicien clavette la poulie sur l'arbre moteur. | The mechanic keys the pulley onto the drive shaft. |
| 5392 | méjuger | méjugé | Il a méjugé la situation et a perdu une belle opportunité. | He misjudged the situation and lost a great opportunity. |
| 5395 | entretoiser | entretoise | Le charpentier entretoise les deux poutres pour renforcer la structure. | The carpenter braces the two beams to reinforce the structure. |
| 5396 | parafer | parafe | Le notaire parafe chaque page du contrat avant de le signer. | The notary initials every page of the contract before signing it. |
| 5397 | cyanoser | cyanose | Le manque d'oxygène cyanose les extrémités du patient. | The lack of oxygen is causing cyanosis in the patient's extremities. |
| 5398 | tartir | tarti | Le bébé a tarti dans sa couche pendant la sieste. | The baby pooped in his diaper during his nap. |
| 5399 | râteler | râtelle | Le jardinier râtelle les feuilles mortes dans l'allée. | The gardener rakes the dead leaves off the path. |
| 5400 | dépulper | dépulpe | On dépulpe les fruits pour obtenir un jus épais. | They mash the fruit into a pulp to get a thick juice. |
| 5401 | écrouir | écrouit | Le forgeron écrouit le métal en le martelant à froid. | The blacksmith work-hardens the metal by hammering it cold. |
| 5402 | postfacer | postfacé | L'écrivain a postfacé le roman de son ami avec quelques réflexions personnelles. | The writer wrote an afterword for his friend's novel with a few personal reflections. |
| 5403 | drosser | drossé | Le vent violent a drossé le voilier vers les rochers. | The strong wind drove the sailboat off course toward the rocks. |
| 5405 | dilacérer | dilacère | Elle dilacère les vieux documents avant de les jeter. | She shreds the old documents before throwing them away. |
| 5406 | rechristianiser | rechristianiser | Le missionnaire espérait rechristianiser la région après des décennies d'athéisme d'État. | The missionary hoped to re-Christianize the region after decades of state atheism. |
| 5408 | crachouiller | crachouille | Le vieux moteur crachouille de la fumée noire au démarrage. | The old engine sputters black smoke on startup. |
| 5409 | décaver | décavé | En remportant la dernière main, il a décavé son adversaire au poker. | By winning the last hand, he cleaned his opponent out at poker. |
| 5410 | pendiller | pendille | Une vieille ampoule pendille au bout d'un fil électrique. | An old lightbulb dangles from the end of an electrical wire. |
| 5413 | embraquer | embraque | Le marin embraque rapidement l'écoute pour border la voile. | The sailor quickly hauls in the sheet to trim the sail. |
| 5414 | débosseler | débosselle | Le carrossier débosselle l'aile de la voiture accidentée. | The body shop technician removes the dents from the crashed car's fender. |
| 5415 | transmigrer | transmigre | Selon cette croyance, l'âme transmigre d'un corps à un autre après la mort. | According to this belief, the soul transmigrates from one body to another after death. |
| 5416 | amodier | amodié | Le propriétaire a amodié ses terres agricoles à un jeune fermier. | The landowner leased his farmland to a young farmer. |
| 5417 | charroyer | charroient | Les paysans charroient le foin jusqu'à la grange avant l'orage. | The farmers cart the hay to the barn before the storm. |
| 5418 | emplafonner | emplafonné | Le camion a emplafonné la voiture arrêtée au feu rouge. | The truck slammed into the car stopped at the red light. |
| 5419 | dépurer | dépure | Le procédé dépure l'eau avant qu'elle n'atteigne les robinets. | The process purifies the water before it reaches the taps. |
| 5420 | revacciner | revacciné | Le médecin a dû revacciner l'enfant après l'échec du premier vaccin. | The doctor had to revaccinate the child after the first vaccine failed. |
| 5421 | cémenter | cémentaient | Les artisans cémentaient l'acier pour durcir sa surface. | Craftsmen case-hardened the steel to harden its surface. |
| 5454 | bordurer | bordurent | Les employés municipaux bordurent la nouvelle route avec des pavés blancs. | The municipal workers are edging the new road with white cobblestones. |
| 5457 | antéposer | antépose | En français, on antépose souvent l'adjectif au nom. | In French, the adjective is often placed before the noun. |
| 5458 | palissader | palissadèrent | Les soldats palissadèrent le camp pour se protéger des attaques nocturnes. | The soldiers fenced the camp with a palisade to protect against night raids. |
| 5459 | enrocher | enroché | Les ouvriers ont enroché la berge pour éviter l'érosion. | The workers riprapped the bank to prevent erosion. |
| 5460 | trabouler | traboulent | Les habitants du quartier traboulent pour rejoindre la place plus rapidement. | The neighborhood residents cut through the passageways to reach the square more quickly. |
| 5461 | déparasiter | déparasité | Le vétérinaire a déparasité le chien avant de le confier à sa nouvelle famille. | The vet dewormed the dog before handing him over to his new family. |
| 5462 | désenfumer | désenfumé | Les pompiers ont désenfumé le hall d'immeuble après l'incendie. | The firefighters cleared the smoke from the building lobby after the fire. |
| 5463 | déshuiler | déshuile | L'usine déshuile les graines avant de les transformer en farine. | The factory removes the oil from the seeds before turning them into flour. |
| 5464 | insculper | insculpe | L'orfèvre insculpe son poinçon sur chaque bijou en argent. | The goldsmith stamps his hallmark on every silver piece of jewelry. |
| 5465 | nominaliser | nominalise | En ajoutant un suffixe, on nominalise souvent un adjectif en français. | By adding a suffix, an adjective is often nominalized in French. |
| 5467 | chaptaliser | chaptalise | Le vigneron chaptalise le moût lorsque le raisin n'est pas assez mûr. | The winemaker chaptalizes the must when the grapes are not ripe enough. |
| 5470 | retéléphoner | retéléphone | Je n'ai pas pu te joindre tout à l'heure, alors je retéléphone. | I couldn't reach you earlier, so I'm calling back. |
| 5471 | viriliser | virilise | Le traitement hormonal virilise parfois la voix des patientes. | Hormone treatment sometimes masculinizes patients' voices. |
| 5472 | démoustiquer | démoustiqué | La commune a démoustiqué le marais avant l'arrivée des touristes. | The town treated the marsh for mosquitos before the tourists arrived. |
| 5473 | bateler | batelait | Le bateleur batelait sur la place du village, jonglant avec des couteaux. | The street performer juggled and did tricks in the village square, tossing knives. |
| 5475 | resaler | resalé | Le cuisinier a resalé la soupe car elle manquait de goût. | The cook added more salt to the soup because it lacked flavor. |
| 5476 | mithridatiser | mithridatisé | Le savant a mithridatisé le rat en lui donnant de petites doses de poison chaque jour. | The scientist immunized the rat against poison by giving it small doses each day. |
| 5477 | dépolymériser | dépolymérise | La chaleur dépolymérise certains plastiques en les décomposant en petites molécules. | Heat depolymerizes certain plastics by breaking them down into small molecules. |
| 5478 | épierrer | épierre | Le fermier épierre son champ chaque printemps avant de semer. | The farmer clears his field of stones each spring before planting. |
| 5479 | décoffrer | décoffrent | Les ouvriers décoffrent la dalle une fois que le béton a suffisamment durci. | The workers remove the formwork from the slab once the concrete has hardened enough. |
| 5480 | dépailler | dépaillé | L'artisan a dépaillé la vieille chaise avant d'y installer un nouveau cannage. | The craftsman stripped the old chair of its straw seat before fitting new caning. |
| 5481 | encaver | encave | Le vigneron encave les meilleures bouteilles pour les faire vieillir plusieurs années. | The winemaker stores the best bottles in the cellar to age them for several years. |
| 5482 | emprésurer | emprésure | Le fromager emprésure le lait tiède pour qu'il commence à cailler. | The cheesemaker adds rennet to the warm milk so it begins to curdle. |
| 5483 | étarquer | étarquent | Les marins étarquent la grand-voile pour profiter du vent arrière. | The sailors tauten the mainsail to take advantage of the tailwind. |
| 5485 | taquer | taque | Le typographe taque les caractères pour aligner parfaitement la page. | The typesetter squares up the type to perfectly align the page. |
| 5488 | défeuiller | défeuillent | Les tempêtes d'automne défeuillent rapidement les grands chênes du parc. | Autumn storms quickly defoliate the park's tall oak trees. |
| 5490 | désaisonnaliser | désaisonnalisent | Les économistes désaisonnalisent les données avant de comparer les mois entre eux. | Economists deseasonalize the data before comparing months to each other. |
| 5494 | recorriger | recorriger | L'enseignant a dû recorriger toutes les copies après avoir trouvé une erreur dans le corrigé. | The teacher had to re-grade all the papers after finding an error in the answer key. |
| 5495 | dégauchir | dégauchit | Le menuisier dégauchit la planche avant de la raboter finement. | The carpenter joints the board flat before sanding it smooth. |
| 5497 | rassir | rassit | Le pain rassit vite s'il n'est pas conservé dans un sac hermétique. | Bread goes stale quickly if it isn't kept in an airtight bag. |
| 5498 | reconsolider | reconsolider | Les archéologues ont dû reconsolider le mur ancien avant l'hiver. | The archaeologists had to reinforce the ancient wall again before winter. |
| 5500 | jogger | jogge | Chaque matin, elle jogge dans le parc avant d'aller au travail. | Every morning, she goes jogging in the park before heading to work. |
| 5501 | nordir | nordir | Le vent va nordir en fin de journée, selon les prévisions météo. | The wind will turn northerly by the end of the day, according to the forecast. |
| 5503 | désambiguïser | désambiguïser | Il faut désambiguïser cette phrase avant de la traduire automatiquement. | This sentence needs to be disambiguated before it can be machine-translated. |
| 5506 | démédicaliser | démédicaliser | Certains veulent démédicaliser l'accouchement en le rendant plus naturel. | Some people want to demedicalize childbirth by making it more natural. |
| 5508 | brancarder | brancarder | Les secouristes ont dû brancarder le randonneur blessé jusqu'à l'ambulance. | The rescuers had to carry the injured hiker to the ambulance on a stretcher. |
| 5509 | déprotéger | déprotéger | Il faut déprotéger le fichier avant de pouvoir le modifier. | You need to unprotect the file before you can edit it. |
| 5510 | épanneler | épannelle | Le tailleur de pierre épannelle le bloc avant de sculpter les détails. | The stonemason rough-hews the block before carving the details. |
| 5511 | abcéder | abcédé | La plaie a fini par abcéder malgré les soins appliqués. | The wound eventually turned into an abscess despite the treatment given. |
| 5512 | éthériser | éthérisé | Le chirurgien a éthérisé le patient avant l'opération. | The surgeon etherized the patient before the operation. |
| 5513 | décarbonater | décarbonate | L'usine décarbonate l'eau pour réduire le calcaire dans les tuyaux. | The plant decarbonates the water to reduce limescale in the pipes. |
| 5514 | débureaucratiser | débureaucratiser | Le nouveau maire veut débureaucratiser les démarches administratives de la ville. | The new mayor wants to debureaucratize the city's administrative procedures. |
| 5515 | resemer | resemer | Le fermier va resemer le champ après les fortes pluies qui ont abîmé les jeunes pousses. | The farmer will reseed the field after the heavy rains damaged the young shoots. |
| 5516 | encaserner | encaserner | L'armée a décidé d'encaserner les nouvelles recrues dès leur arrivée. | The army decided to barrack the new recruits as soon as they arrived. |
| 5518 | déballonner | s'est déballonné | Au dernier moment, il s'est déballonné et n'a pas sauté en parachute. | At the last moment, he chickened out and didn't jump with the parachute. |
| 5519 | juponner | juponne | La couturière juponne la robe pour lui donner plus de volume. | The dressmaker lines the skirt with a petticoat to give it more volume. |
| 5520 | cafarder | cafardé | Le petit garçon a cafardé son camarade auprès du professeur. | The little boy tattled on his classmate to the teacher. |
| 5522 | dessoler | dessoler | Le maréchal-ferrant a dû dessoler le cheval blessé avant de le soigner. | The farrier had to remove the horse's hoof sole before treating the injury. |
| 5523 | écroûter | écroûte | Le boulanger écroûte le pain rassis avant de préparer la chapelure. | The baker removes the crust from the stale bread before making bread crumbs. |
| 5524 | accastiller | accastillé | Le chantier naval a accastillé le voilier avec du matériel neuf avant la course. | The boatyard fitted out the sailboat with new gear before the race. |
| 5525 | desseller | desselle | Le cavalier desselle son cheval après une longue randonnée. | The rider unsaddles his horse after a long ride. |
| 5527 | doucir | doucit | Le vitrier doucit la glace avant de la polir une dernière fois. | The glazier smooths the glass before giving it one last polish. |
| 5529 | égueuler | égueulé | Le choc a égueulé le vieux pichet en terre cuite. | The impact chipped the rim of the old terracotta pitcher. |
| 5530 | cuveler | cuvelèrent | Les ouvriers cuvelèrent le puits pour empêcher l'effondrement des parois. | The workers lined the shaft with planking to keep the walls from collapsing. |
| 5532 | tanquer | tanqué | La voiture a tanqué contre le mur du garage. | The car crashed into the garage wall. |
| 5533 | rapetasser | rapetasse | Elle rapetasse ses vieux jeans avec des pièces de tissu coloré. | She patches up her old jeans with colorful fabric patches. |
| 5534 | cinématographier | cinématographié | Le réalisateur a cinématographié la scène du mariage sous la pluie. | The director filmed the wedding scene in the rain. |
| 5535 | zézayer | zézaie | Le petit garçon zézaie encore un peu quand il est fatigué. | The little boy still lisps a little when he's tired. |
| 5537 | septupler | septuplé | La population de la ville a septuplé en cinquante ans grâce à l'industrie. | The city's population septupled in fifty years thanks to industry. |
| 5539 | potiner | potiner | Les voisines aiment potiner sur la nouvelle famille qui vient d'emménager. | The neighbor women love to gossip about the new family that just moved in. |
| 5542 | dédifférencier | dédifférencient | Certaines cellules cancéreuses se dédifférencient et perdent leur fonction spécialisée. | Some cancer cells dedifferentiate and lose their specialized function. |
| 5543 | dessertir | dessertit | Le bijoutier dessertit délicatement le diamant avant de le remonter sur une nouvelle bague. | The jeweler carefully removes the diamond from its setting before mounting it on a new ring. |
| 5544 | grigner | grigne | Ce tissu grigne un peu à la couture si on ne le repasse pas bien. | This fabric wrinkles a bit at the seam if you don't iron it well. |
| 5546 | désaimanter | désaimanté | Le champ magnétique intense a désaimanté accidentellement toutes les cartes bancaires du sac. | The intense magnetic field accidentally demagnetized all the bank cards in the bag. |
| 5547 | remilitariser | remilitariser | Le pays a décidé de remilitariser sa frontière après les tensions récentes. | The country decided to remilitarize its border after the recent tensions. |
| 5548 | écussonner | écussonne | Le pépiniériste écussonne les jeunes rosiers en été pour obtenir de nouvelles variétés. | The nurseryman grafts young rose bushes in summer to create new varieties. |
| 5551 | endenter | endenté | Le forgeron a endenté la roue de fer pour qu'elle s'engrène parfaitement avec l'autre. | The blacksmith toothed the iron wheel so that it would mesh perfectly with the other one. |
| 5552 | avitailler | avitaillé | L'équipage a avitaillé le cargo en carburant et en vivres avant le grand départ. | The crew restocked the cargo ship with fuel and provisions before the big departure. |
| 5553 | désoperculer | désopercule | L'apiculteur désopercule les rayons de miel avant de les mettre dans l'extracteur. | The beekeeper uncaps the honeycomb frames before putting them in the extractor. |
| 5554 | receper | receper | Le vigneron va receper les vieux ceps pour stimuler une nouvelle pousse. | The winegrower is going to cut back the old vine stumps to stimulate new growth. |
| 5555 | roustir | rousti | Deux voyous ont rousti un touriste devant la gare hier soir. | Two thugs robbed a tourist in front of the station last night. |
| 5556 | dénazifier | dénazifier | Après la guerre, les autorités ont tenté de dénazifier l'administration allemande. | After the war, the authorities tried to denazify the German administration. |
| 5562 | jerker | jerke | Il jerke toute la soirée sur cette chanson des années soixante. | He dances the jerk all evening to that sixties song. |
| 5565 | déflagrer | déflagre | Le mélange chimique déflagre violemment au contact de la flamme. | The chemical mixture deflagrates violently on contact with the flame. |
| 5569 | désembuer | désembue | Elle désembue le pare-brise avant de démarrer la voiture. | She demists the windshield before starting the car. |
| 5571 | trévirer | trévirent | Les marins trévirent le canot de sauvetage avant la tempête. | The sailors hoist the lifeboat before the storm. |
| 5573 | terreauter | terreaute | Le jardinier terreaute le potager chaque printemps avant de semer. | The gardener adds compost to the vegetable patch every spring before sowing. |
| 5574 | entredévorer | s'entredévorent | Les deux rivaux s'entredévorent depuis des années dans cette querelle politique. | The two rivals have been tearing each other apart for years in this political feud. |
| 5575 | emmieller | emmielle | La grand-mère emmielle les crêpes avant de les servir aux enfants. | Grandma coats the crepes with honey before serving them to the children. |
| 5576 | désexualiser | désexualise | Le film désexualise complètement les personnages féminins pour se concentrer sur l'intrigue. | The film completely desexualizes the female characters to focus on the plot. |
| 5578 | lourer | loure | Le violoniste loure les premières mesures pour adoucir la mélodie. | The violinist plays the opening bars legato to soften the melody. |
| 5579 | empaumer | empaume | Le joueur empaume la balle avec assurance avant de la relancer. | The player grasps the ball firmly before throwing it back. |
| 5580 | partouzer | partouzer | Ils aiment partouzer dans des soirées privées entre amis. | They like to have group sex at private parties among friends. |
| 5581 | rucher | ruche | Le paysan ruche le foin en petits monticules avant l'hiver. | The farmer stacks the hay into small beehive-shaped mounds before winter. |
| 5582 | esquicher | esquiche | Elle esquiche le tube de dentifrice jusqu'à la dernière goutte. | She squeezes the toothpaste tube down to the last drop. |
| 5583 | désenvaser | désenvasent | Les ouvriers désenvasent le canal chaque année avant l'été. | Workers clear the silt from the canal every year before summer. |
| 5584 | chevaler | chevalent | Les ouvriers chevalent le mur fissuré avant de commencer les travaux. | The workers shore up the cracked wall with beams before starting work. |
| 5585 | boulocher | bouloche | Ce pull en laine bouloche rapidement après plusieurs lavages. | This wool sweater pills quickly after several washes. |
| 5586 | viroler | virole | L'artisan virole le manche du couteau avec un anneau de laiton. | The craftsman fits the knife handle with a brass ferrule. |
| 5587 | warranter | warrante | La banque warrante le stock de marchandises pour garantir le prêt. | The bank issues a warrant on the stock of goods to secure the loan. |
| 5588 | recéder | recède | L'entreprise recède ses actions à un autre investisseur après la faillite. | The company sells its shares on to another investor after the bankruptcy. |
| 5590 | esbroufer | esbroufe | Il esbroufe souvent ses collègues en racontant des exploits invérifiables. | He often shows off in front of his colleagues by telling unverifiable tales of his exploits. |
| 5591 | chaponner | chaponne | Le fermier chaponne les jeunes coqs pour améliorer la qualité de leur viande. | The farmer caponizes young roosters to improve the quality of their meat. |
| 5596 | amatir | amatit | L'orfèvre amatit la bague en argent pour lui donner un aspect mat. | The goldsmith gives the silver ring a matte finish. |
| 5597 | regreffer | regreffer | Le jardinier a dû regreffer le pommier après la première tentative ratée. | The gardener had to regraft the apple tree after the first attempt failed. |
| 5598 | regratter | regratter | Le maçon a dû regratter la façade avant de la repeindre entièrement. | The mason had to scrape the façade again before repainting it entirely. |
| 5600 | surjeter | surjette | Ma grand-mère surjette toujours les bords du tissu pour éviter qu'il s'effiloche. | My grandmother always overcasts the fabric edges so they won't fray. |
| 5601 | dérager | dérage | Mon frère dérage vite après une dispute et redevient de bonne humeur. | My brother calms down quickly after an argument and cheers up again. |
| 5602 | détracter | détracter | Certains journalistes n'hésitent pas à détracter les artistes qu'ils n'apprécient pas. | Some journalists don't hesitate to disparage artists they dislike. |
| 5604 | diphtonguer | diphtonguer | En ancien français, certaines voyelles toniques ont commencé à diphtonguer devant une consonne nasale. | In Old French, certain stressed vowels began to diphthongize before a nasal consonant. |
| 5605 | œuvrer | œuvre | Elle œuvre depuis des années pour améliorer l'accès à l'éducation dans son village. | She has worked for years to improve access to education in her village. |
| 5607 | graffiter | graffité | Des adolescents ont graffité le mur du collège pendant la nuit. | Teenagers graffitied the school wall during the night. |
| 5609 | déplâtrer | déplâtrer | Le médecin va déplâtrer le bras du patient la semaine prochaine. | The doctor is going to take the patient's arm out of its cast next week. |
| 5610 | désengluer | désengluer | Il a fallu une heure pour désengluer les plumes de l'oiseau piégé. | It took an hour to free the trapped bird's feathers from the glue. |
| 5611 | radioguider | radioguider | Les techniciens peuvent radioguider le drone depuis la tour de contrôle. | The technicians can guide the drone by radio from the control tower. |
| 5612 | paganiser | paganiser | Certains historiens estiment que l'empereur cherchait à paganiser de nouveau la cour. | Some historians believe the emperor was trying to re-paganize the court. |
| 5613 | déplomber | déplomber | Le technicien doit déplomber le compteur avant de le remplacer. | The technician must remove the lead seal from the meter before replacing it. |
| 5614 | gouailler | gouailler | Les gamins du quartier aimaient gouailler les passants depuis le trottoir. | The neighborhood kids liked to jeer at passersby from the sidewalk. |
| 5616 | embarrer | embarre | Le mécanicien embarre la roue arrière pour empêcher la voiture de reculer. | The mechanic chocks the rear wheel to keep the car from rolling back. |
| 5617 | étalager | étalage | Le boulanger étalage ses viennoiseries fraîches sur le comptoir chaque matin. | The baker displays his fresh pastries on the counter every morning. |
| 5618 | crapoter | crapoter | Il préfère crapoter sa cigarette plutôt que d'avaler la fumée. | He prefers to puff on his cigarette rather than inhale the smoke. |
| 5619 | débotter | débotter | Le valet se hâta de débotter le voyageur épuisé par la route. | The servant hurried to remove the boots of the traveler exhausted from the journey. |
| 5620 | discounter | discounter | Le magasin a décidé de discounter tous les articles d'été avant la rentrée. | The store decided to discount all the summer items before the back-to-school season. |
| 5621 | calaminer | calamine | Le vieux moteur diesel se calamine rapidement quand on roule uniquement en ville. | The old diesel engine quickly gets clogged with carbon deposits when driven only around town. |
| 5622 | carroyer | carroyer | Le géomètre a dû carroyer la carte pour faciliter la lecture des distances. | The surveyor had to grid the map into squares to make reading distances easier. |
| 5627 | délinéer | délinéer | L'architecte a pris soin de délinéer chaque détail de la façade sur son plan. | The architect took care to delineate every detail of the façade on his plan. |
| 5628 | dépriser | dépriser | Il ne faut pas dépriser les efforts que ces bénévoles accomplissent chaque semaine. | One shouldn't undervalue the efforts these volunteers make every week. |
| 5629 | déséchouer | déséchouer | L'équipage a travaillé toute la nuit pour déséchouer le cargo échoué sur le récif. | The crew worked all night to refloat the cargo ship stranded on the reef. |
| 5630 | glaiser | glaise | Le potier glaise soigneusement le moule avant d'y couler le plâtre. | The potter carefully coats the mold with clay before pouring in the plaster. |
| 5632 | enrésiner | enrésiner | Le pépiniériste va enrésiner cette parcelle abandonnée l'année prochaine. | The nursery grower is going to plant this abandoned plot with conifers next year. |
| 5633 | dépressuriser | dépressuriser | Le pilote a dû dépressuriser lentement la cabine avant l'atterrissage d'urgence. | The pilot had to slowly depressurize the cabin before the emergency landing. |
| 5634 | marivauder | marivaudaient | Les deux jeunes gens marivaudaient sur la terrasse au clair de lune. | The two young people flirted wittily on the terrace by moonlight. |
| 5635 | octupler | octuplé | La production a octuplé en dix ans grâce aux nouvelles machines. | Production increased eightfold in ten years thanks to the new machines. |
| 5637 | désorbiter | désorbiter | Les ingénieurs ont décidé de désorbiter le satellite hors service pour qu'il brûle dans l'atmosphère. | The engineers decided to deorbit the decommissioned satellite so it would burn up in the atmosphere. |
| 5639 | fasciser | fasciser | Certains historiens estiment que ce régime a cherché à fasciser progressivement l'ensemble de la société. | Some historians believe this regime sought to gradually impose fascism on society as a whole. |
| 5640 | bonimenter | bonimentait | Le camelot bonimentait devant la foule pour vendre ses couteaux miracles. | The huckster made his pitch to the crowd to sell his miracle knives. |
| 5641 | pitonner | pitonné | Le grimpeur a pitonné la paroi avant de s'élancer dans la voie difficile. | The climber drove in pitons on the rock face before setting off on the difficult route. |
| 5644 | encuver | encuvé | Le vigneron a encuvé les raisins fraîchement récoltés pour lancer la fermentation. | The winemaker put the freshly harvested grapes into the vat to start fermentation. |
| 5645 | merceriser | mercerise | L'usine mercerise le coton pour lui donner un aspect brillant et soyeux. | The factory mercerizes the cotton to give it a glossy, silky finish. |
| 5646 | camionner | camionne | L'entreprise camionne des marchandises entre Paris et Marseille chaque semaine. | The company trucks goods between Paris and Marseille every week. |
| 5647 | enliasser | enliasse | La secrétaire enliasse les factures avant de les classer dans le tiroir. | The secretary bundles the invoices together before filing them in the drawer. |
| 5650 | alcaliniser | alcalinise | Le jardinier alcalinise le sol acide en ajoutant de la chaux. | The gardener alkalizes the acidic soil by adding lime. |
| 5651 | toupiller | toupille | Le menuisier toupille les bords de la planche pour créer une moulure décorative. | The carpenter routs the edges of the board to create a decorative molding. |
| 5652 | arrenter | arrenté | Le seigneur a arrenté ses terres à un fermier moyennant une rente annuelle. | The lord leased out his land to a farmer in exchange for an annual rent. |
| 5655 | réincarcérer | réincarcérer | Le tribunal a décidé de réincarcérer le suspect après la violation de sa libération conditionnelle. | The court decided to reincarcerate the suspect after he violated his parole. |
| 5657 | désétatiser | désétatiser | Le gouvernement souhaite désétatiser certains services publics pour réduire les dépenses. | The government wants to denationalize certain public services to cut costs. |
| 5658 | ressemeler | ressemeler | Le cordonnier va ressemeler mes vieilles chaussures de randonnée. | The cobbler is going to resole my old hiking boots. |
| 5659 | draver | dravaient | Chaque printemps, les bûcherons dravaient les billots le long de la rivière. | Every spring, the lumberjacks floated the logs down the river. |
| 5660 | débâcler | débâclé | Le fleuve a débâclé plus tôt que d'habitude ce printemps à cause du redoux. | The river's ice broke up earlier than usual this spring because of the warm spell. |
| 5661 | impétrer | impétrer | L'avocat a réussi à impétrer une autorisation spéciale auprès du ministère. | The lawyer managed to procure a special authorization from the ministry. |
| 5664 | chougner | chougner | Arrête de chougner pour un jouet, on t'en achètera un autre. | Stop whining about the toy, we'll buy you another one. |
| 5666 | snifer | snifent | Certains jeunes snifent de la colle par curiosité dangereuse. | Some young people sniff glue out of dangerous curiosity. |
| 5667 | étamper | étampe | Le forgeron étampe le fer chaud pour lui donner sa forme. | The blacksmith punches the hot iron to shape it. |
| 5668 | déraser | dérase | Le maçon dérase le sommet du mur pour l'aligner avec le toit. | The mason levels off the top of the wall to align it with the roof. |
| 5669 | élinguer | élingue | Le docker élingue la caisse avant de la hisser sur le bateau. | The docker slings the crate before hoisting it onto the ship. |
| 5673 | désindexer | désindexer | Le site a demandé à Google de désindexer cette page obsolète. | The site asked Google to deindex the outdated page. |
| 5674 | rechasser | rechasse | Le fermier rechasse les corbeaux qui reviennent sans cesse dans le champ. | The farmer chases the crows away again as they keep coming back to the field. |
| 5675 | hébraïser | hébraïser | Chaque été, elle part en Israël pour hébraïser pendant plusieurs semaines. | Every summer, she goes to Israel to study Hebrew for several weeks. |
| 5677 | dessabler | dessablent | Les ouvriers dessablent la pièce de fonte avant de la polir. | The workers remove the sand from the cast piece before polishing it. |
| 5680 | vesser | vesse | Le chien vesse discrètement sous la table sans que personne ne s'en aperçoive. | The dog quietly farts under the table without anyone noticing. |
| 5681 | écharner | écharne | Le tanneur écharne la peau avant de la mettre à tremper. | The tanner defleshes the hide before soaking it. |
| 5682 | remboîter | remboîte | Le bijoutier remboîte délicatement les pièces du mécanisme après la réparation. | The jeweler carefully fits the mechanism's parts back together after the repair. |
| 5683 | contrebraquer | contrebraquer | Le conducteur a dû contrebraquer rapidement pour éviter que la voiture ne dérape. | The driver had to countersteer quickly to keep the car from skidding. |
| 5684 | bucher | buchent | Les étudiants buchent leurs cours toute la semaine avant l'examen. | The students hit the books all week before the exam. |
| 5685 | mégisser | mégisse | L'artisan mégisse les peaux de mouton pour en faire un cuir souple. | The craftsman taws sheepskins to make soft leather. |
| 5686 | ozoniser | ozonise | L'usine ozonise l'eau potable pour éliminer les bactéries. | The plant ozonizes the drinking water to kill bacteria. |
| 5687 | voliger | volige | Le charpentier volige le toit avant de poser les tuiles. | The carpenter battens the roof before laying the tiles. |
| 5688 | correctionnaliser | correctionnaliser | Le procureur a choisi de correctionnaliser cette affaire de vol. | The prosecutor chose to downgrade this theft case to a misdemeanor. |
| 5689 | enjuiver | enjuivé | L'historien explique comment la propagande antisémite prétendait que les Juifs avaient « enjuivé » la société française. | The historian explains how antisemitic propaganda claimed that Jews had 'Judaized' French society. |
| 5694 | mercantiliser | mercantilisé | Certains estiment que le football professionnel a totalement mercantilisé ce sport. | Some believe that professional football has completely commercialized the sport. |
| 5696 | coïter | coïtent | Les biologistes ont observé comment ces insectes coïtent au printemps. | Biologists observed how these insects copulate in the spring. |
| 5698 | postériser | postérise | Le studio postérise cette photo de voyage pour décorer le salon. | The studio turns this travel photo into a poster to decorate the living room. |
| 5699 | tabouiser | tabouise | Dans certaines familles, on tabouise encore les discussions sur l'argent. | In some families, discussions about money are still treated as taboo. |
| 5700 | rapprendre | rapprendre | Après son accident, il a dû rapprendre à marcher. | After his accident, he had to learn to walk again. |
| 5703 | jarreter | jarrette | Elle se jarrette avant de sortir pour la soirée. | She puts on her garter belt before going out for the evening. |
| 5705 | redéfaire | redéfait | Elle redéfait ses valises après avoir changé d'avis sur le voyage. | She unpacks her bags again after changing her mind about the trip. |
| 5706 | dévirer | dévire | Le marin dévire le cabestan pour donner du mou à l'amarre. | The sailor turns the capstan back to give some slack to the mooring line. |
| 5708 | bretteler | brettelle | Le maçon brettelle la pierre pour lui donner une texture rugueuse. | The mason dresses the stone with a toothed tool to give it a rough texture. |
| 5709 | réticuler | réticulent | Les fabricants réticulent le caoutchouc pour le rendre plus résistant. | Manufacturers cross-link the rubber to make it more durable. |
| 5710 | décimaliser | décimalisé | Le pays a décimalisé sa monnaie en 1795. | The country decimalized its currency in 1795. |
| 5712 | éjointer | éjointe | L'éleveur éjointe les oisillons pour les empêcher de s'envoler. | The breeder clips the young birds' wings to keep them from flying away. |
| 5713 | ragréer | ragrée | Le maçon ragrée les murs avant de les peindre. | The mason smooths the walls before painting them. |
| 5714 | voussoyer | voussoie | En France, on voussoie souvent les inconnus et les supérieurs. | In France, people often address strangers and superiors as vous. |
| 5715 | galéjer | galèje | Mon oncle galèje toujours quand il raconte ses histoires de pêche. | My uncle always spins tall tales when he tells his fishing stories. |
| 5716 | ratiner | ratine | L'usine ratine la laine pour obtenir un tissu plus doux. | The mill naps the wool to produce a softer fabric. |
| 5717 | dépointer | dépointe | L'employé dépointe à dix-huit heures avant de rentrer chez lui. | The employee clocks out at six p.m. before heading home. |
| 5718 | trémuler | trémulent | Ses mains trémulent légèrement quand elle est nerveuse. | Her hands tremble slightly when she's nervous. |
| 5719 | boyauter | boyautaient | Les enfants se boyautaient devant le clown au cirque. | The children were doubled up with laughter at the circus clown. |
| 5720 | dévernir | dévernit | Il dévernit le vieux meuble avant de le repeindre. | He strips the varnish off the old piece of furniture before repainting it. |
| 5721 | embroussailler | embroussaillent | Les ronces embroussaillent le sentier chaque été. | Brambles overgrow the path every summer. |
| 5723 | interfolier | interfolie | Le bibliothécaire interfolie le manuscrit avec des pages blanches pour les annotations. | The librarian interleaves the manuscript with blank pages for notes. |
| 5724 | hameçonner | hameçonné | Des pirates informatiques ont hameçonné des milliers d'utilisateurs avec un faux site bancaire. | Hackers phished thousands of users with a fake banking website. |
| 5725 | gréciser | grécise | Le traducteur grécise plusieurs noms propres dans sa nouvelle édition. | The translator Grecizes several proper names in his new edition. |
| 5726 | panteler | pantelait | Le coureur pantelait après le sprint final. | The runner was panting after the final sprint. |
| 5727 | lotionner | lotionne | Elle lotionne la peau du bébé après le bain. | She applies lotion to the baby's skin after the bath. |
| 5728 | communaliser | communalisé | La ville a communalisé la gestion de l'eau potable. | The city communalized management of the drinking-water supply. |
| 5729 | débillarder | débillarde | Le charpentier débillarde la poutre pour l'ajuster à la charpente. | The carpenter cuts the beam diagonally to fit the frame. |
| 5730 | prompter | prompte | Elle prompte l'IA pour générer une image de paysage. | She prompts the AI to generate a landscape image. |
| 5731 | débudgétiser | débudgétise | Le ministère débudgétise certaines dépenses pour alléger le budget de l'État. | The ministry removes certain expenses from the budget to lighten the state's finances. |
| 5733 | dépoétiser | dépoétisent | Les analyses techniques dépoétisent parfois la musique classique. | Technical analysis sometimes strips classical music of its poetic quality. |
| 5736 | grisoller | grisolle | L'alouette grisolle dans le ciel matinal. | The lark sings in the morning sky. |
| 5737 | ribouler | riboulé | Le clown a riboulé des yeux pour faire rire les enfants du public. | The clown rolled his eyes to make the children in the audience laugh. |
| 5738 | griveler | grivelé | Le client a grivelé au restaurant en partant discrètement sans régler l'addition. | The customer skipped out on the bill, leaving the restaurant quietly without paying. |
| 5739 | écrivailler | écrivaille | Ce jeune journaliste écrivaille sans relâche, remplissant des pages entières de textes médiocres. | This young journalist churns out endless pages of mediocre writing. |
| 5740 | réescompter | réescompté | La banque a réescompté ces effets de commerce pour obtenir des liquidités immédiates. | The bank rediscounted these bills of exchange to raise immediate cash. |
| 5741 | déganter | dégante | Le médecin dégante rapidement la main du blessé pour examiner la plaie. | The doctor quickly removes the glove from the injured man's hand to examine the wound. |
| 5743 | brimbaler | brimbalait | La vieille passerelle brimbalait dangereusement sous les rafales de vent violentes. | The old footbridge swayed dangerously under the violent gusts of wind. |
| 5744 | encaquer | encaque | Le pêcheur encaque les harengs fraîchement pêchés dans de grands tonneaux en bois. | The fisherman packs the freshly caught herrings into large wooden barrels. |
| 5746 | rentoiler | rentoile | Le restaurateur rentoile la toile ancienne, fragilisée par le temps, sur un support neuf. | The restorer reattaches the old canvas, weakened by age, onto a new backing. |
| 5747 | faseyer | faseyait | La voile faseyait bruyamment car le bateau remontait trop près du vent. | The sail was flapping noisily because the boat was sailing too close to the wind. |
| 5748 | reneiger | reneigé | Il a reneigé toute la nuit après une courte accalmie hier après-midi. | It snowed again all night after a brief lull yesterday afternoon. |
| 5749 | pignocher | pignochait | L'enfant pignochait dans son assiette sans vraiment avoir faim. | The child picked at his plate without really being hungry. |
| 5750 | précautionner | précautionné | Le guide a précautionné les randonneurs contre les risques d'avalanche avant l'ascension. | The guide forewarned the hikers about the risk of avalanche before the climb. |
| 5751 | treillager | treillage | Le jardinier treillage les rosiers grimpants contre le mur du jardin. | The gardener trellises the climbing roses against the garden wall. |
| 5752 | toupiner | toupiner | L'enfant regarde la toupie toupiner joyeusement sur le parquet du salon. | The child watches the top spin merrily on the living room floor. |
| 5754 | canuler | canule | Ce bruit de moteur qui n'arrête pas me canule terriblement. | That engine noise that won't stop is driving me crazy. |
| 5755 | contrepasser | contrepassé | Le comptable a dû contrepasser l'écriture erronée avant de clôturer les comptes. | The accountant had to reverse the erroneous entry before closing the books. |
| 5756 | décreuser | décreuse | L'artisan décreuse les cocons de soie dans un bain chaud avant le filage. | The craftsman degums the silk cocoons in a hot bath before spinning. |
| 5757 | margauder | margaude | Au printemps, la caille mâle margaude pour attirer une femelle dans les champs. | In spring, the male quail calls out to attract a female in the fields. |
| 5758 | salifier | salifie | Le chimiste salifie l'acide en ajoutant une base pour obtenir un composé stable. | The chemist salifies the acid by adding a base to obtain a stable compound. |
| 5759 | slaviser | slaviser | La politique impériale a cherché à slaviser les populations de la région conquise. | The imperial policy sought to Slavicize the populations of the conquered region. |
| 5762 | palanquer | palanquent | Les ouvriers palanquent la lourde caisse jusqu'au pont du navire. | The workers hoist the heavy crate up onto the ship's deck. |
| 5763 | javeler | javelle | Le paysan javelle le blé fauché en petits tas avant de le lier en gerbes. | The farmer stacks the mown wheat into small sheaves before binding it into bundles. |
| 5765 | écornifler | écornifle | Ce parasite écornifle sans cesse ses voisins pour obtenir un repas gratuit. | This freeloader constantly pesters his neighbors to score a free meal. |
| 5766 | rendosser | rendosse | Le pompier rendosse son uniforme dès que l'alarme retentit de nouveau. | The firefighter puts his uniform back on as soon as the alarm sounds again. |
| 5767 | ébouter | éboute | Le jardinier éboute les tiges de haricots avant de les cuire. | The gardener trims the ends off the bean stalks before cooking them. |
| 5769 | levretter | levrette | La hase levrette dans son terrier au printemps, donnant naissance à plusieurs levrauts. | The doe hare gives birth in her burrow in spring, bringing several leverets into the world. |
| 5770 | zinzinuler | zinzinule | La fauvette zinzinule doucement au petit matin dans le jardin. | The warbler warbles softly at dawn in the garden. |
| 5771 | rancarder | rancardé | Un indic a rancardé la police sur les projets du gang avant le braquage. | An informant tipped off the police about the gang's plans before the heist. |
| 5774 | palataliser | palatalisaient | En vieux français, les scribes palatalisaient souvent le k devant un e ou un i. | In Old French, scribes often palatalized the k before an e or an i. |
| 5776 | transvider | transvide | Le boulanger transvide la farine d'un grand sac dans plusieurs petits contenants. | The baker transfers the flour from a large sack into several small containers. |
| 5778 | pleuviner | pleuvine | Il pleuvine sans arrêt depuis ce matin, rendant les rues glissantes. | It has been drizzling nonstop since this morning, making the streets slippery. |
| 5780 | ressuer | ressuer | Après la cuisson, on laisse le pain ressuer avant de le trancher. | After baking, the bread is left to sweat out its moisture before being sliced. |
| 5781 | speeder | speedait | Le motard speedait sur l'autoroute pour arriver à temps. | The biker was speeding down the highway to get there in time. |
| 5782 | shampooiner | shampooine | Elle shampooine son chien tous les samedis avec un produit doux. | She shampoos her dog every Saturday with a gentle product. |
| 5784 | surcontrer | surcontre | Au bridge, elle surcontre l'annonce de ses adversaires pour doubler les points. | In bridge, she redoubles her opponents' bid to double the stakes. |
| 5785 | démaigrir | démaigrit | Le menuisier démaigrit la planche pour l'ajuster à l'épaisseur voulue. | The carpenter thins down the board to bring it to the required thickness. |
| 5786 | podzoliser | podzoliser | Les fortes pluies acides finissent par podzoliser les sols forestiers de la région. | The heavy acid rain eventually podzolizes the region's forest soils. |
| 5788 | gadgétiser | gadgétisent | Certains fabricants gadgétisent des objets du quotidien pour les rendre connectés. | Some manufacturers turn everyday objects into gadgets by making them connected. |
| 5789 | raplatir | raplatit | Le forgeron raplatit la tôle cabossée à coups de marteau. | The blacksmith flattens the dented sheet metal with hammer blows. |
| 5790 | élonger | élongent | Les marins élongent le câble d'ancre avant de le mouiller au fond. | The sailors pay out the anchor cable before letting it settle on the seabed. |
| 5792 | yodler | yodlait | Le randonneur yodlait joyeusement du sommet de la montagne suisse. | The hiker yodeled joyfully from the top of the Swiss mountain. |
| 5793 | grumeler | se grumelle | La sauce se grumelle si on ajoute la farine trop vite. | The sauce turns lumpy if the flour is added too quickly. |
| 5795 | torchonner | torchonne | Elle torchonne la table avant de dresser le couvert. | She wipes down the table with a cloth before setting it. |
| 5796 | convulsionner | convulsionne | La forte fièvre convulsionne parfois les jeunes enfants pendant la nuit. | High fever sometimes causes convulsions in young children at night. |
| 5798 | cosmétiquer | cosmétique | Avant le tournage, la maquilleuse cosmétique rapidement le visage de l'actrice. | Before filming, the makeup artist quickly applies cosmetics to the actress's face. |
| 5799 | désencadrer | désencadre | Le restaurateur désencadre le tableau avant de le nettoyer soigneusement. | The restorer removes the painting from its frame before carefully cleaning it. |
| 5800 | repleuvoir | repleuvoir | Il s'est mis à repleuvoir dès que nous sommes sortis sans parapluie. | It started raining again just as soon as we went out without an umbrella. |
| 5802 | kifer | kifent | Les jeunes kifent ce nouveau morceau de musique électronique. | Young people love this new electronic music track. |
| 5803 | désaligner | désaligna | Le sergent hurla, mais un soldat désaligna la troupe en trébuchant. | The sergeant shouted, but a soldier threw the ranks out of line by stumbling. |
| 5804 | ramender | ramende | Le pêcheur ramende son filet déchiré avant de reprendre la mer. | The fisherman mends his torn net before heading back out to sea. |
| 5805 | dragéifier | dragéifiés | Les comprimés sont dragéifiés pour masquer leur goût amer. | The tablets are sugar-coated to mask their bitter taste. |
| 5807 | scotomiser | scotomise | Le patient scotomise inconsciemment les souvenirs douloureux de son enfance. | The patient unconsciously blocks out the painful memories of his childhood. |
| 5808 | crailler | craillent | Les corneilles craillent bruyamment au-dessus du champ moissonné. | The crows caw loudly above the harvested field. |
| 5811 | décercler | décercle | Le tonnelier décercle le vieux tonneau avant de le réparer. | The cooper removes the hoops from the old barrel before repairing it. |
| 5812 | délarder | délarde | Le menuisier délarde la marche pour l'ajuster à l'escalier. | The carpenter splays the step so it fits the staircase. |
| 5813 | embrever | embrève | Le charpentier embrève les deux poutres pour les assembler solidement. | The carpenter joins the two beams together to fit them solidly. |
| 5814 | décarburer | décarbure | L'aciérie décarbure le métal en fusion pour réduire sa teneur en carbone. | The steel mill decarburizes the molten metal to reduce its carbon content. |
| 5815 | dénoyer | dénoient | Les ouvriers dénoient la galerie avant de reprendre les travaux. | The workers dewater the gallery before resuming work. |
| 5816 | désaminer | désamine | L'enzyme désamine l'acide aminé pour produire un composé différent. | The enzyme deaminates the amino acid to produce a different compound. |
| 5819 | postsynchroniser | postsynchronise | Le studio postsynchronise le film en plusieurs langues avant sa sortie. | The studio dubs the film into several languages before its release. |
| 5820 | rempocher | rempoche | Il rempoche son portefeuille après avoir payé le café. | He puts his wallet back in his pocket after paying for the coffee. |
| 5821 | ratonner | ratonnaient | L'historien décrit comment certains groupes armés ratonnaient dans les quartiers populaires durant cette période sombre. | The historian describes how certain armed groups carried out racist attacks in working-class neighborhoods during that dark period. |
| 5822 | attiger | attige | Il attige un peu avec ses excuses bidon. | He's exaggerating a bit with his lame excuses. |
| 5824 | mésallier | mésalliée | Elle s'est mésalliée en épousant un simple ouvrier, selon sa famille aristocratique. | According to her aristocratic family, she married beneath her rank by wedding a mere laborer. |
| 5825 | claqueter | claquette | La cigogne claquette bruyamment sur son nid au sommet du clocher. | The stork clatters loudly on its nest atop the bell tower. |
| 5826 | guillemeter | guillemette | Le correcteur guillemette soigneusement chaque citation dans le manuscrit. | The proofreader carefully puts each quotation in quotation marks in the manuscript. |
| 5828 | désengourdir | désengourdir | Elle bouge les doigts pour désengourdir sa main après le froid. | She wiggles her fingers to work the numbness out of her hand after the cold. |
| 5829 | embobeliner | embobeliné | Elle a embobeliné son patron avec des sourires flatteurs. | She wrapped her boss around her finger with flattering smiles. |
| 5830 | rembaucher | rembauche | L'usine rembauche ses anciens employés après la reprise économique. | The factory rehires its former employees after the economic recovery. |
| 5831 | faucarder | faucarde | Le jardinier faucarde les roseaux qui envahissent l'étang. | The gardener cuts back the reeds invading the pond. |
| 5832 | biturer | se biturent | Ils se biturent au bar chaque vendredi soir après le travail. | They get drunk at the bar every Friday night after work. |
| 5833 | lockouter | lockoute | La direction lockoute les employés pendant la grève. | Management locks out the employees during the strike. |
| 5834 | cordeler | cordelle | L'artisan cordelle la paille pour fabriquer une corde solide. | The craftsman twists the straw into a sturdy rope. |
| 5835 | gléner | glène | Le marin glène soigneusement le cordage sur le pont. | The sailor neatly coils the rope on the deck. |
| 5836 | hôler | hôle | Dans la forêt silencieuse, la chouette hôle sous la pleine lune. | In the silent forest, the tawny owl hoots under the full moon. |
| 5837 | parfondre | parfond | Le verrier parfond les couleurs pour les fixer définitivement sur la vitre. | The glassmaker fuses the colors to permanently set them onto the glass. |
| 5838 | bigorner | bigorne | Le forgeron bigorne le fer chaud sur son enclume. | The blacksmith forges the hot iron on his anvil. |
| 5839 | rembucher | rembuche | Le cerf rembuche dès qu'il entend les chiens aboyer. | The stag returns to the woods as soon as it hears the dogs barking. |
| 5841 | crachiner | crachine | Il crachine depuis ce matin, rendant les rues glissantes. | It's been drizzling since this morning, making the streets slippery. |
| 5842 | prérégler | prérègle | Elle prérègle la machine à laver avant de partir travailler. | She presets the washing machine before leaving for work. |
| 5843 | randomiser | randomise | Le logiciel randomise l'ordre des questions à chaque test. | The software randomizes the order of the questions each time you take the test. |
| 5859 | lisérer | lisère | La couturière lisère le col de la robe avec un ruban de soie rouge. | The seamstress trims the dress collar with a red silk ribbon. |
| 5862 | désajuster | désajusté | Le choc a désajusté le mécanisme de la montre, qui retarde maintenant de plusieurs minutes. | The impact threw the watch's mechanism out of alignment, and now it runs several minutes slow. |
| 5877 | débraguetter | débraguette | Il débraguette son pantalon avant d'aller aux toilettes. | He undoes his fly before going to the bathroom. |
| 5878 | dégrouiller | dégrouilles | Si tu ne te dégrouilles pas tout de suite, nous allons rater notre train. | If you don't hurry up right now, we're going to miss our train. |
| 5881 | dessaper | dessape | Une fois rentré, il dessape ses enfants trempés par la pluie. | Once home, he undresses his children who are soaked from the rain. |
| 5882 | hogner | hogne | Le chien hogne doucement quand un étranger s'approche de la maison. | The dog growls softly when a stranger approaches the house. |
| 5884 | glairer | glaire | La pâtissière glaire la pâte avant de la mettre au four pour qu'elle dore bien. | The pastry chef brushes the dough with egg white before baking it so it browns nicely. |
| 5885 | gouger | gouge | L'ébéniste gouge le bois pour créer une rainure décorative sur le tiroir. | The cabinetmaker gouges the wood to create a decorative groove in the drawer. |
| 5886 | emmétrer | emmètre | Le bûcheron emmètre les bûches le long du mur pour faciliter le comptage. | The woodcutter stacks the logs lengthwise along the wall to make counting easier. |
| 5887 | démascler | démasclent | Chaque été, les ouvriers démasclent les chênes-lièges pour récolter leur écorce. | Every summer, the workers strip the bark from the cork oaks to harvest it. |
| 5890 | arriser | arrisé | Devant la tempête qui se levait, les marins ont arrisé les voiles à la hâte. | As the storm rose, the sailors hastily reefed the sails. |
| 5892 | écoconcevoir | écoconcevoir | Les ingénieurs cherchent désormais à écoconcevoir chaque nouvel appareil électronique. | Engineers now try to eco-design every new electronic device. |
| 5893 | effleurir | effleurir | Le sel contenu dans la pierre finit par effleurir à la surface du mur. | The salt contained in the stone eventually effloresces on the surface of the wall. |
| 5894 | égriser | égrise | L'artisan égrise deux diamants bruts l'un contre l'autre avant de les tailler. | The craftsman grinds two rough diamonds against each other before cutting them. |
| 5896 | piqueniquer | piquenique | Chaque dimanche, la famille piquenique au bord de la rivière. | Every Sunday, the family picnics by the river. |
| 5897 | soutacher | soutache | La couturière soutache le col de la veste d'un galon noir élégant. | The seamstress trims the jacket's collar with elegant black braid. |
| 5899 | dégurgiter | dégurgite | Le bébé dégurgite un peu de lait après chaque tétée. | The baby regurgitates a little milk after each feeding. |
| 5901 | décléricaliser | décléricaliser | La nouvelle constitution visait à décléricaliser entièrement le système éducatif. | The new constitution aimed to fully declericalize the education system. |
| 5902 | technocratiser | technocratise | Certains craignent que la réforme ne technocratise davantage l'administration publique. | Some fear that the reform will further technocratize the public administration. |
| 5903 | grognasser | grognasse | Il grognasse contre tout et n'importe quoi dès le matin. | He grumbles about anything and everything first thing in the morning. |
| 5906 | affourager | affourage | Le matin, le fermier affourage ses vaches avant de partir travailler. | In the morning, the farmer fodders his cows before leaving for work. |
| 5908 | varapper | varappent | Chaque été, ils varappent dans les Alpes pendant tout un mois. | Every summer, they go rock climbing in the Alps for a whole month. |
| 5909 | épamprer | épampre | En été, le vigneron épampre la vigne pour que le raisin mûrisse mieux. | In summer, the winegrower trims the excess leaves so the grapes ripen better. |
| 5910 | pleuvioter | pleuviotait | Il pleuviotait toute la matinée, juste assez pour mouiller les trottoirs. | It drizzled all morning, just enough to wet the sidewalks. |
| 5912 | détroquer | détroque | L'ostréiculteur détroque les huîtres avant de les remettre en poche. | The oyster farmer detaches the oysters before putting them back in mesh bags. |
| 5913 | mendigoter | mendigote | Il mendigote quelques pièces devant la boulangerie chaque matin. | He begs for a few coins in front of the bakery every morning. |
| 5914 | tournailler | tournaille | Le chat tournaille autour de la maison depuis une heure. | The cat has been wandering round and round the house for an hour. |
| 5916 | oiseler | oiselait | Le paysan oiselait dans les vignes pour compléter son repas. | The peasant used to trap small birds in the vineyards to supplement his meal. |
| 5918 | dessuinter | dessuinte | L'usine dessuinte la laine brute avant de la teindre. | The factory removes the grease from raw wool before dyeing it. |
| 5920 | recalcifier | recalcifie | Le traitement recalcifie les os fragilisés du patient. | The treatment recalcifies the patient's weakened bones. |
| 5921 | embouter | emboute | Le plombier emboute le tuyau avant de le raccorder au robinet. | The plumber fits a tip onto the pipe before connecting it to the faucet. |
| 5922 | glatir | glatit | L'aigle glatit au sommet de la falaise avant de prendre son envol. | The eagle cries out atop the cliff before taking flight. |
| 5923 | vidimer | vidime | Le notaire vidime la copie du testament pour en garantir la conformité. | The notary certifies the copy of the will as a true copy of the original. |
| 5924 | exulcérer | exulcère | Le frottement du sac exulcère la peau de son épaule après une longue marche. | The rubbing of the bag chafes his shoulder after a long walk. |
| 5925 | frouer | froue | Le hibou froue dans la nuit, effrayant les promeneurs. | The owl hoots in the night, startling the walkers. |
| 5926 | hérissonner | se hérissonne | Le chat se hérissonne dès qu'il aperçoit le chien. | The cat bristles up as soon as it sees the dog. |
| 5927 | pétrarquiser | pétrarquise | Ce jeune poète pétrarquise dans ses premiers sonnets d'amour. | This young poet imitates Petrarch's style in his early love sonnets. |
| 5932 | réaccoutumer | réaccoutumer | Il faut du temps pour réaccoutumer les yeux à l'obscurité après une explosion de lumière. | It takes time to reaccustom your eyes to darkness after a burst of bright light. |
| 5936 | décapitaliser | décapitalisé | Le gouvernement a décapitalisé la ville pour des raisons stratégiques. | The government stripped the city of its capital status for strategic reasons. |
| 5937 | mordancer | mordance | Le teinturier mordance le tissu avant d'appliquer les couleurs. | The dyer mordants the fabric before applying the colors. |
| 5939 | épucer | épuce | Le vétérinaire épuce le chien avant de le rendre à ses propriétaires. | The vet removes the fleas from the dog before returning it to its owners. |
| 5940 | désencrasser | désencrasse | Il désencrasse le carburateur avant de remonter le moteur. | He cleans out the carburetor before reassembling the engine. |
| 5941 | écouvillonner | écouvillonne | L'infirmière écouvillonne la gorge du patient pour le test. | The nurse swabs the patient's throat for the test. |
| 5942 | émeriser | émerise | L'artisan émerise la lame pour la rendre plus tranchante. | The craftsman polishes the blade with emery to sharpen it. |
| 5943 | briefer | briefe | Le capitaine briefe son équipe avant chaque match important. | The captain briefs his team before every important match. |
| 5945 | écobuer | écobuent | Les paysans écobuent la lande avant les semailles. | The farmers pare and burn the moorland turf before sowing. |
| 5946 | taniser | tanise | Le vigneron tanise le vin en le laissant vieillir en fût de chêne. | The winemaker adds tannins to the wine by aging it in oak barrels. |
| 5948 | renquiller | renquille | Le chasseur renquille son couteau dans sa gaine après avoir dépecé le gibier. | The hunter sheathes his knife back in its case after dressing the game. |
| 5950 | varloper | varlope | Le menuisier varlope la planche pour la rendre parfaitement lisse. | The carpenter planes the board to make it perfectly smooth. |
| 5954 | contagionner | contagionne | Le virus contagionne rapidement tous les habitants du village. | The virus quickly infects all the villagers. |
| 5955 | débouquer | débouque | Le navire débouque enfin de la passe étroite pour gagner la haute mer. | The ship finally clears the narrow channel to reach open sea. |
| 5956 | tosser | tosse | Par gros temps, le bateau tosse contre le quai à chaque vague. | In rough weather, the boat bumps against the quay with every wave. |
| 5958 | stripper | strippe | Le chirurgien strippe la veine variqueuse du patient lors de l'opération. | The surgeon strips the patient's varicose vein during the operation. |
| 5960 | désatomiser | désatomiser | Le traité vise à désatomiser complètement la péninsule coréenne. | The treaty aims to completely denuclearize the Korean peninsula. |
| 5962 | marsouiner | marsouine | Le hors-bord marsouine dès qu'il prend de la vitesse. | The speedboat starts porpoising as soon as it picks up speed. |
| 5963 | rescinder | rescinde | Le tribunal rescinde le contrat signé sous la contrainte. | The court rescinds the contract signed under duress. |
| 5964 | débâtir | débâtit | La couturière débâtit l'ourlet avant de le recoudre correctement. | The seamstress unbastes the hem before sewing it properly again. |
| 5965 | décavaillonner | décavaillonne | Le vigneron décavaillonne à la main entre les ceps trop serrés. | The winegrower hand-tills the soil between the vines too close together for the plow. |
| 5966 | déculasser | déculasse | L'armurier déculasse le fusil avant de le nettoyer. | The gunsmith removes the breech before cleaning the rifle. |
| 5968 | épaufrer | épaufre | Le tailleur de pierre épaufre accidentellement le bloc de marbre en tapant trop fort. | The stonecutter accidentally chips the marble block by hitting it too hard. |
| 5969 | laryngectomiser | laryngectomise | Le chirurgien laryngectomise le patient atteint d'un cancer du larynx. | The surgeon performs a laryngectomy on the patient with laryngeal cancer. |
| 5970 | rempoissonner | rempoissonne | Le pêcheur rempoissonne l'étang chaque printemps avec de jeunes truites. | The fisherman restocks the pond with young trout every spring. |
| 5973 | déforcer | déforcer | Cette défaite politique va déforcer le gouvernement en place. | This political defeat will weaken the government in power. |
| 5975 | aveulir | aveulir | Des années de confort excessif ont fini par aveulir sa volonté. | Years of excessive comfort ended up enfeebling his will. |
| 5976 | encabaner | encabanent | Les autorités encabanent le voleur pour plusieurs années. | The authorities imprison the thief for several years. |
| 5977 | brésiller | brésille | L'artisan brésille la laine pour lui donner une teinte rouge éclatante. | The craftsman dyes the wool with brazilwood to give it a brilliant red hue. |
| 5979 | rentraire | rentraire | La couturière sait rentraire un tissu déchiré sans laisser de trace. | The seamstress knows how to invisibly mend torn fabric without leaving a trace. |
| 5980 | remmailler | remmaille | Elle remmaille soigneusement les mailles filées de son collant. | She carefully re-meshes the runs in her tights. |
| 5981 | décintrer | décintre | Le maçon décintre la voûte une fois le mortier bien sec. | The mason removes the supports from under the vault once the mortar is fully dry. |
| 5982 | dénitrifier | dénitrifient | Ces bactéries dénitrifient efficacement les sols agricoles saturés de nitrates. | These bacteria efficiently denitrify farmland soils saturated with nitrates. |
| 5983 | désectoriser | désectoriser | La mairie a décidé de désectoriser certaines écoles du quartier. | The city council decided to end the zoning system for some schools in the neighborhood. |
| 5984 | trimarder | trimarde | Ce vagabond trimarde sur les routes de France depuis plusieurs années. | This tramp has been roaming the roads of France for years. |
| 5985 | vétiller | vétille | Elle vétille sur des détails insignifiants au lieu d'avancer. | She fusses over trivial details instead of moving forward. |
| 5986 | déparier | déparie | L'éleveur déparie les pigeons pour séparer les mâles des femelles. | The breeder separates the pigeons to keep the males apart from the females. |
| 5987 | bostonner | bostonnent | Au bal du samedi soir, les couples bostonnent avec élégance jusqu'à minuit. | At the Saturday night ball, the couples dance the Boston elegantly until midnight. |
| 5989 | blettir | blettissent | Les poires blettissent rapidement si on les laisse au soleil. | The pears overripen quickly if left in the sun. |
| 5990 | dansoter | dansote | Le petit garçon dansote joyeusement devant ses grands-parents attendris. | The little boy dances clumsily and joyfully in front of his touched grandparents. |
| 5994 | chancir | chanci | Le pain a chanci après une semaine dans un placard humide. | The bread went moldy after a week in a damp cupboard. |
| 5995 | grossoyer | grossoie | Le notaire grossoie l'acte de vente avant la signature des parties. | The notary engrosses the deed of sale before the parties sign. |
| 5996 | transfiler | transfile | Le voilier transfile les deux pans de toile avant de les coudre définitivement. | The sailmaker laces the two canvas panels together before sewing them permanently. |
| 5997 | dépatrier | dépatrie | Le nouveau régime dépatrie de force les opposants politiques. | The new regime forcibly strips political opponents of their homeland. |
| 5998 | désenivrer | désenivre | Le café noir désenivre peu à peu les invités trop gais. | The black coffee gradually sobers up the overly cheerful guests. |
| 6002 | dérougir | dérougit | Le soleil dérougit peu à peu les vieux rideaux du salon. | The sun gradually fades the red out of the old living-room curtains. |
| 6003 | retuber | retube | Le mécanicien retube la chaudière usée pour prolonger sa durée de vie. | The mechanic retubes the worn-out boiler to extend its lifespan. |
| 6004 | rencaisser | rencaisse | Le jardinier rencaisse les orangers avant l'arrivée de l'hiver. | The gardener packs the orange trees back into their crates before winter arrives. |
| 6006 | bornoyer | bornoie | Le maçon bornoie le mur pour vérifier qu'il est bien droit. | The mason sights along the wall to check that it is straight. |
| 6008 | démastiquer | démastique | Le vitrier démastique la vieille fenêtre avant d'installer un nouveau carreau. | The glazier removes the putty from the old window before fitting a new pane. |
| 6009 | échalasser | échalasse | Le vigneron échalasse ses jeunes plants de vigne au printemps. | The winegrower stakes his young vines in spring. |
| 6012 | épreindre | épreint | Le fromager épreint le petit-lait du caillé à l'aide d'un linge fin. | The cheesemaker presses the whey out of the curd using a fine cloth. |
| 6014 | hourdir | hourdit | Le maçon hourdit les murs de la grange avec du mortier grossier. | The mason rough-fills the barn walls with coarse mortar. |
| 6015 | renformir | renformit | Le maçon renformit la façade fissurée avec un crépi épais. | The mason re-renders the cracked facade with a thick coat of plaster. |
| 6016 | trusquiner | trusquine | Le menuisier trusquine une ligne sur la planche avant de la scier. | The carpenter scribes a line on the board before sawing it. |
| 6042 | failler | s'est faillée | La roche s'est faillée sous la pression, créant une large fissure dans la montagne. | The rock fractured under the pressure, creating a wide fissure in the mountain. |
| 6052 | déramer | dérame | L'ouvrier dérame les feuilles de papier avant de les imprimer. | The worker fans out the sheets of paper before printing them. |
| 6053 | désaccentuer | désaccentue | Le logiciel désaccentue automatiquement les noms de fichiers. | The software automatically strips the diacritics from file names. |
| 6054 | désaérer | désaère | L'usine désaère le lait avant de le conditionner. | The factory deaerates the milk before packaging it. |
| 6055 | déshydrogéner | déshydrogène | Le procédé chimique déshydrogène l'éthane pour produire de l'éthylène. | The chemical process dehydrogenates ethane to produce ethylene. |
| 6056 | déverguer | déverguent | Les matelots déverguent les voiles avant la tempête. | The sailors unbend the sails from the yards before the storm. |
| 6057 | dracher | drache | Il drache depuis ce matin sur Bruxelles. | It's been pouring rain in Brussels since this morning. |
| 6058 | écrivasser | écrivasse | Il écrivasse toute la journée sans jamais rien publier. | He scribbles away all day without ever publishing anything. |
| 6059 | faluner | falune | Le paysan falune ses champs pour améliorer la terre. | The farmer fertilizes his fields with shell marl to improve the soil. |
| 6060 | goujonner | goujonne | Le menuisier goujonne les deux planches avant de les coller. | The carpenter dowels the two boards together before gluing them. |
| 6062 | sursemer | sursème | Le jardinier sursème la pelouse abîmée au printemps. | The gardener overseeds the damaged lawn in spring. |
| 6063 | casse-croûter | casse-croûte | On casse-croûte à midi avant de reprendre le travail. | We have a snack at noon before going back to work. |
| 6065 | télexer | télexe | Le bureau télexe le message dès sa réception. | The office telexes the message as soon as it arrives. |
| 6066 | brillantiner | brillantine | Le coiffeur brillantine les cheveux du client avant de le coiffer. | The barber applies brilliantine to the customer's hair before styling it. |
| 6068 | convivialiser | convivialise | Elle convivialise les réunions de travail en apportant des gâteaux. | She makes work meetings more convivial by bringing pastries. |
| 6069 | désembouteiller | désembouteille | La nouvelle route désembouteille enfin le centre-ville. | The new road finally relieves the traffic jam downtown. |
| 6070 | novelliser | novellise | Le scénariste novellise le film à succès en un roman. | The screenwriter novelizes the hit film into a book. |
| 6071 | calamistrer | calamistrait | Le coiffeur calamistrait soigneusement les cheveux de la mariée avant la cérémonie. | The hairdresser carefully curled the bride's hair before the ceremony. |
| 6072 | ébourrer | ébourre | Le tanneur ébourre les peaux avant de les traiter. | The tanner removes the hair from the hides before treating them. |
| 6074 | iodler | iodle | Le chanteur iodle joyeusement au sommet de la montagne. | The singer yodels joyfully at the top of the mountain. |
| 6075 | criticailler | criticaille | Il criticaille sans cesse les moindres détails du projet. | He's forever nitpicking at the smallest details of the project. |
| 6076 | désembourgeoiser | désembourgeoise | L'afflux de jeunes artistes désembourgeoise peu à peu ce quartier chic. | The influx of young artists is gradually stripping this posh neighborhood of its bourgeois character. |
| 6080 | carcailler | carcaille | La caille carcaille dans les blés au petit matin. | The quail cries out in the wheat field at dawn. |
| 6081 | tourniquer | tournique | Le vieux chien tournique autour de la table avant de s'installer. | The old dog keeps circling around the table before settling down. |
| 6082 | défroncer | défronce | La couturière défronce la jupe pour l'agrandir. | The seamstress lets out the gathers in the skirt to make it bigger. |
| 6083 | mollarder | mollarde | Le joueur mollarde par terre avant de reprendre le match. | The player spits on the ground before resuming the match. |
| 6085 | enchemiser | enchemise | La secrétaire enchemise les documents importants avant de les classer. | The secretary puts the important documents into a folder before filing them. |
| 6087 | pleuvoter | pleuvote | En automne, il pleuvote souvent sur la côte bretonne. | In autumn, it often drizzles along the Brittany coast. |
| 6088 | smurfer | smurfe | Il smurfe très bien devant ses amis chaque samedi soir. | He breakdances really well in front of his friends every Saturday night. |
| 6089 | contreficher | contrefiche | Il se contrefiche des remarques de ses collègues et continue son travail. | He doesn't give a darn about his colleagues' remarks and keeps working. |
| 6090 | collapser | collapser | Le vieux hangar a fini par collapser sous le poids de la neige. | The old shed eventually collapsed under the weight of the snow. |
| 6091 | réargenter | réargenter | L'orfèvre a dû réargenter les couverts ternis par les années. | The silversmith had to resilver the cutlery tarnished by the years. |
| 6094 | écanguer | écangue | Le fermier écangue le lin fraîchement récolté chaque automne. | The farmer scutches the freshly harvested flax every autumn. |
| 6095 | essoucher | essoucher | Avant de labourer, le paysan doit essoucher le champ envahi de vieux troncs. | Before plowing, the farmer must clear the stumps from the field overrun with old trunks. |
| 6096 | suroxyder | suroxyder | Si l'on n'est pas prudent, l'acide risque de suroxyder le métal exposé. | If one isn't careful, the acid may overoxidize the exposed metal. |
| 6098 | affourrager | affourrage | Chaque matin, l'éleveur affourrage ses vaches avant la traite. | Every morning, the farmer feeds fodder to his cows before milking. |
| 6099 | appertiser | appertise | L'usine appertise des légumes frais chaque été pour les conserver toute l'année. | The factory cans fresh vegetables every summer to preserve them all year long. |
| 6100 | arrérager | arrérager | Si vous ne payez pas à temps, votre loyer risque d'arrérager rapidement. | If you don't pay on time, your rent risks quickly falling into arrears. |
| 6101 | baladodiffuser | baladodiffuse | Chaque semaine, cette animatrice baladodiffuse une nouvelle émission sur la cuisine régionale. | Every week, this host podcasts a new episode about regional cuisine. |
| 6102 | cokéfier | cokéfie | L'usine cokéfie le charbon pour produire un combustible industriel. | The plant cokes the coal to produce an industrial fuel. |
| 6103 | débenzoler | débenzole | L'usine débenzole le gaz avant sa distribution aux clients. | The plant strips the benzol from the gas before it is distributed to customers. |
| 6104 | décommettre | décommet | Le marin décommet le vieux câble pour en récupérer les fils de cuivre. | The sailor unravels the old cable to recover its copper strands. |
| 6105 | décruer | décrue | L'artisan décrue la soie brute avant de la teindre en bleu profond. | The craftsman scours the raw silk before dyeing it deep blue. |
| 6106 | défaufiler | défaufile | La couturière défaufile le tissu une fois la couture définitive terminée. | The seamstress removes the basting stitches once the final seam is done. |
| 6107 | défeutrer | défeutrer | Il faut défeutrer ce vieux pull avant de le retricoter. | This old sweater needs to have its felting removed before it can be reknitted. |
| 6108 | démyéliniser | démyélinise | Cette maladie démyélinise progressivement les nerfs du patient. | This disease progressively demyelinates the patient's nerves. |
| 6109 | dénasaliser | dénasaliser | Le chanteur s'entraîne à dénasaliser certains sons pour mieux articuler. | The singer practices denasalizing certain sounds to articulate better. |
| 6110 | déroder | dérodent | Chaque hiver, les forestiers dérodent la parcelle pour favoriser la repousse. | Every winter, the foresters thin the plot to encourage new growth. |
| 6111 | égravillonner | égravillonne | Avant de replanter l'arbre, le jardinier égravillonne délicatement les racines. | Before replanting the tree, the gardener carefully removes the soil from its roots. |
| 6114 | entretailler | entretaille | Le vieux cheval fatigué s'entretaille à chaque foulée sur le chemin rocailleux. | The tired old horse knocks its legs together at every stride on the rocky path. |
| 6115 | épincer | épince | Le tailleur de pierre épince le bloc avec son épinçoir avant la finition. | The stonemason chisels the block with his épinçoir before finishing it. |
| 6116 | estrapasser | estrapassé | Le cavalier a estrapassé son cheval en le faisant tourner trop longtemps au manège. | The rider wore out his horse by having it circle the ring for too long. |
| 6117 | étalinguer | étalingue | L'équipage étalingue la chaîne de l'ancre avant d'appareiller. | The crew bends the anchor chain on before getting underway. |
| 6118 | éthérifier | éthérifie | Le chimiste éthérifie l'alcool pour obtenir un composé plus volatil. | The chemist etherifies the alcohol to obtain a more volatile compound. |
| 6121 | organsiner | organsine | Cette manufacture organsine la soie brute pour produire un fil résistant. | This mill twists raw silk into organzine to produce a strong thread. |
| 6122 | pervibrer | pervibrèrent | Les ouvriers pervibrèrent le béton frais pour éliminer les bulles d'air avant qu'il ne durcisse. | The workers vibrated the fresh concrete to remove air bubbles before it hardened. |
| 6123 | réimperméabiliser | réimperméabilise | Chaque printemps, je réimperméabilise mes chaussures de randonnée avant la saison des pluies. | Every spring, I waterproof my hiking boots again before the rainy season. |
| 6126 | surstocker | surstocké | L'entreprise a surstocké des masques pendant la pandémie, craignant une pénurie. | The company overstocked masks during the pandemic, fearing a shortage. |
| 6127 | trémater | trémata | Le voilier trémata un cargo plus lent au large des côtes bretonnes. | The sailboat overtook a slower cargo ship off the coast of Brittany. |
| 6128 | décommuniser | décommunisé | Après 1991, plusieurs pays d'Europe de l'Est ont décommunisé leurs institutions. | After 1991, several Eastern European countries decommunized their institutions. |
| 6129 | dansotter | dansottait | Le petit garçon dansottait maladroitement devant ses parents attendris. | The little boy danced clumsily in front of his fond parents. |
| 6130 | ténoriser | ténorisait | Pendant la répétition, il ténorisait avec assurance devant le chef d'orchestre. | During rehearsal, he sang tenor confidently in front of the conductor. |
| 6131 | maquereauter | maquereautait | Il maquereautait dans ce quartier depuis des années, exploitant plusieurs femmes. | He had been pimping in that neighborhood for years, exploiting several women. |
| 6132 | dénicotiniser | dénicotinise | L'usine dénicotinise le tabac avant de fabriquer des cigarettes légères. | The factory removes the nicotine from tobacco before making light cigarettes. |
| 6133 | aurifier | aurifie | Le dentiste aurifie les molaires abîmées de ses patients. | The dentist fills his patients' damaged molars with gold. |
| 6134 | pocharder | pochardé | Après la fête, il s'était complètement pochardé et ne savait plus où il habitait. | After the party, he had gotten completely drunk and no longer knew where he lived. |
| 6135 | gâtifier | gâtifie | Depuis son accident, le vieil homme gâtifie un peu plus chaque année. | Since his accident, the old man has been going soft in the head a bit more every year. |
| 6136 | coupailler | coupaillait | Le boucher coupaillait la viande sans grand soin, laissant des morceaux inégaux. | The butcher was hacking at the meat carelessly, leaving uneven pieces. |
| 6137 | abonnir | abonni | Le vieux vin s'est bien abonni pendant ces dix années de cave. | The old wine improved nicely over those ten years in the cellar. |
| 6138 | forlancer | forlancèrent | Les chiens forlancèrent le cerf caché dans les fourrés. | The dogs flushed the deer out of the thicket. |
| 6140 | moucheronner | moucheronnaient | À la surface de l'étang, les truites moucheronnaient au coucher du soleil. | At the surface of the pond, the trout were jumping to snap up gnats at sunset. |
| 6141 | embroncher | embroncha | Le couvreur embroncha soigneusement les tuiles pour qu'elles s'emboîtent bien. | The roofer carefully positioned the tiles so they fit together properly. |
| 6143 | déchiffonner | déchiffonna | Elle déchiffonna la robe froissée avant de la ranger dans l'armoire. | She smoothed out the wrinkled dress before putting it away in the closet. |
| 6144 | défruiter | défruitent | En automne, les ouvriers défruitent les pommiers du verger. | In autumn, the workers pick the fruit from the orchard's apple trees. |
| 6145 | désentoiler | désentoila | Le restaurateur désentoila le tableau pour transférer la peinture sur une toile neuve. | The conservator removed the old canvas backing to transfer the painting onto a new one. |
| 6146 | forjeter | forjette | Le mur du vieux bâtiment forjette légèrement à cet endroit, menaçant de s'effondrer. | The old building's wall bulges slightly at that spot, threatening to collapse. |
| 6147 | novéliser | novéliser | Le studio a demandé à un écrivain de novéliser le scénario du film. | The studio asked a writer to novelize the film's screenplay. |
| 6148 | pluviner | pluvinait | Dehors, il pluvinait doucement depuis le matin. | Outside, it had been drizzling gently since morning. |
| 6149 | saccharifier | saccharifie | L'enzyme saccharifie l'amidon en glucose. | The enzyme saccharifies the starch into glucose. |
| 6150 | travailloter | travaillote | Depuis sa retraite, il travaillote quelques heures par semaine dans son jardin. | Since retiring, he works a little here and there, a few hours a week in his garden. |
| 6151 | glavioter | glaviota | L'homme glaviota par terre avant d'entrer dans le bar. | The man spat on the ground before going into the bar. |
| 6152 | clamecer | clamecé | Le vieux bandit a clamecé dans une ruelle sombre, seul et oublié. | The old crook kicked the bucket in a dark alley, alone and forgotten. |
| 6153 | bigophoner | bigophoné | Il m'a bigophoné hier soir pour annoncer la nouvelle. | He called me last night to break the news. |
| 6154 | pagnoter | pagnota | Fatigué par le voyage, il se pagnota tôt après cette dure journée. | Tired from the trip, he went to bed early after that hard day. |
| 6155 | michetonner | michetonnent | Certaines jeunes femmes michetonnent le week-end pour arrondir leurs fins de mois. | Some young women engage in casual prostitution on weekends to make ends meet. |
| 6156 | rempaqueter | rempaqueta | Après avoir tout vérifié, elle rempaqueta soigneusement les cadeaux dans leur boîte. | After checking everything, she carefully repacked the gifts into their box. |
| 6157 | rebraguetter | rebraguette | Il rebraguette son pantalon avant de sortir de la cabine. | He zips his pants back up before coming out of the stall. |
| 6159 | dénatter | dénatte | Chaque soir, elle dénatte ses cheveux avant de se coucher. | Every evening, she unbraids her hair before going to bed. |
| 6160 | vousoyer | vousoient | Par respect, les élèves vousoient toujours leur professeur. | Out of respect, the students always address their teacher as vous. |
| 6161 | déraidir | déraidir | Le kinésithérapeute masse le genou pour déraidir l'articulation. | The physiotherapist massages the knee to loosen up the joint. |
| 6162 | méconduire | s'est méconduit | L'enfant s'est méconduit pendant toute la sortie scolaire. | The child misbehaved throughout the whole school outing. |
| 6164 | décliqueter | décliquette | Le technicien décliquette le mécanisme pour libérer la roue dentée. | The technician releases the catch on the mechanism to free the cog. |
| 6165 | étronçonner | étronçonne | Le bûcheron étronçonne le chêne avant de le débiter en planches. | The woodcutter strips the branches off the oak before cutting it into planks. |
| 6166 | pleuvasser | pleuvasse | Dehors, il pleuvasse depuis ce matin, juste assez pour mouiller les trottoirs. | Outside it's been drizzling on and off since this morning, just enough to wet the sidewalks. |
| 6167 | surgeonner | surgeonne | Le vieux pommier surgeonne chaque printemps près de sa base. | The old apple tree sends up suckers every spring near its base. |
| 6168 | drayer | draie | Le tanneur draie soigneusement chaque peau avant de la tanner. | The tanner carefully scrapes the flesh off each hide before tanning it. |
| 6169 | déhouiller | déhouillent | Les mineurs déhouillent la galerie avant de la fermer définitivement. | The miners clear the coal from the gallery before closing it for good. |
| 6171 | entrégorger | s'entrégorgeaient | Pendant la guerre civile, les clans rivaux s'entrégorgeaient sans pitié. | During the civil war, the rival clans slaughtered each other mercilessly. |
| 6172 | hongrer | hongre | Le maréchal-ferrant hongre le jeune étalon pour le calmer. | The farrier gelds the young stallion to calm him down. |
| 6173 | remprunter | remprunter | Il a dû remprunter de l'argent à sa sœur le mois suivant. | He had to borrow money from his sister again the following month. |
| 6174 | ruiler | ruile | Le maçon ruile soigneusement le joint entre le mur et le toit. | The mason carefully seals the joint between the wall and the roof with mortar. |
| 6175 | afflouer | afflouer | Les marins ont réussi à afflouer le cargo échoué sur les rochers. | The sailors managed to refloat the cargo ship stranded on the rocks. |
| 6176 | bocarder | bocardent | Les ouvriers bocardent le minerai pour en extraire l'or. | The workers crush the ore in a stamp mill to extract the gold. |
| 6177 | brasseyer | brasseyait | Fatigué, il brasseyait dans la rue sans même remarquer les passants. | Exhausted, he walked along with his arms dangling, not even noticing the passersby. |
| 6178 | conglutiner | conglutine | La colle conglutine les deux morceaux de bois en quelques minutes. | The glue bonds the two pieces of wood together within minutes. |
| 6181 | déléaturer | a déléaturé | Le rédacteur en chef a déléaturé le passage jugé trop polémique. | The editor-in-chief demanded that the overly controversial passage be struck out. |
| 6182 | déluter | délute | L'ouvrier délute soigneusement le joint avant de nettoyer la cornue. | The worker carefully removes the seal from the joint before cleaning the retort. |
| 6183 | désamidonner | désamidonne | Elle désamidonne le tissu avant de le repasser. | She removes the starch from the fabric before ironing it. |
| 6185 | déshypothéquer | déshypothéquer | La banque a accepté de déshypothéquer la maison après le remboursement du prêt. | The bank agreed to release the mortgage on the house once the loan was repaid. |
| 6186 | enchatonner | enchatonne | Le bijoutier enchatonne un saphir bleu au centre de la bague. | The jeweler sets a blue sapphire in the center of the ring. |
| 6187 | enchausser | enchausse | Le jardinier enchausse les poireaux avec de la paille pour les protéger du gel. | The gardener mulches the leeks with straw to protect them from frost. |
| 6188 | entradmirer | s'entradmiraient | Les deux artistes s'entradmiraient depuis leurs débuts dans le milieu musical. | The two artists had admired each other since their early days in the music scene. |
| 6189 | épinceter | épincette | Le jardinier épincette les jeunes pousses du tronc pour favoriser la croissance. | The gardener crops the young shoots from the trunk to encourage growth. |
| 6190 | épontiller | épontillent | Les ouvriers épontillent le plafond fissuré avant de commencer les travaux. | The workers shore up the cracked ceiling before starting the repairs. |
| 6191 | estrapader | estrapadaient | Au Moyen Âge, les autorités estrapadaient parfois les voleurs pour les punir. | In the Middle Ages, authorities sometimes subjected thieves to the strappado as punishment. |
| 6192 | féculer | fécule | On fécule les pommes de terre pour en extraire l'amidon. | Potatoes are processed into starch to extract the starch from them. |
| 6193 | ferrouter | ferroute | La SNCF ferroute des milliers de camions chaque année pour réduire la pollution routière. | SNCF piggybacks thousands of lorries onto trains every year to cut road pollution. |
| 6195 | harpailler | se harpaillent | Les deux frères se harpaillent sans cesse pour des broutilles. | The two brothers are forever squabbling over trifles. |
| 6196 | hier | hient | Les ouvriers hient le sol pour tasser la terre avant de couler le béton. | The workers ram the ground with a rod to pack the soil before pouring the concrete. |
| 6198 | joncer | jonce | Le rempailleur jonce les chaises anciennes avec des brins de rotin. | The chair-mender covers the old chairs with strands of rattan. |
| 6199 | langueyer | langueye | Le vétérinaire langueye le porc avant l'abattage. | The vet examines the pig's tongue before slaughter. |
| 6201 | malléabiliser | malléabilise | Ce traitement thermique malléabilise la fonte pour en faciliter le façonnage. | This heat treatment makes the cast iron malleable so it is easier to shape. |
| 6205 | recercler | recercle | Le tonnelier recercle les tonneaux usagés avant de les revendre. | The cooper re-hoops the old barrels before selling them on. |
| 6206 | rénetter | rénette | Le maréchal-ferrant rénette le sabot du cheval avant de poser le fer. | The farrier pares the horse's hoof with a knife before fitting the shoe. |
| 6207 | saietter | saiette | L'orfèvre saiette la pièce d'argent pour en raviver l'éclat. | The silversmith brushes the silver piece to bring back its shine. |
| 6209 | surjaler | surjalé | Le mouillage a mal tourné : la chaîne a surjalé autour du jas de l'ancre. | The anchorage went wrong: the chain fouled around the anchor's stock. |
| 6210 | verjuter | verjute | Le cuisinier verjute la sauce pour lui donner une pointe d'acidité. | The cook seasons the sauce with verjuice to give it a touch of acidity. |
| 6211 | rôdailler | rôdaillent | Les adolescents rôdaillent dans le quartier sans but précis le soir. | In the evening the teenagers hang around the neighborhood with nothing much to do. |
| 6213 | dépalisser | dépalisse | Le jardinier dépalisse le poirier avant de tailler les branches. | The gardener removes the supports from the pear tree before pruning its branches. |
| 6214 | hollandiser | hollandisent | Les colons hollandisent peu à peu les mœurs locales du comptoir. | Little by little the settlers give the trading post's local customs a Dutch character. |
| 6215 | zouker | zoukent | Les danseurs zoukent toute la nuit lors du festival antillais. | The dancers zouk all night long at the Caribbean festival. |
| 6216 | déhotter | déhotté | En entendant la sirène, il a déhotté aussitôt. | When he heard the siren, he took off right away. |
| 6217 | clayonner | clayonnent | Les ouvriers clayonnent le talus pour empêcher l'érosion de la terre. | The workers line the embankment with wattle to stop the soil from eroding. |
| 6218 | démieller | démielle | L'apiculteur démielle les cadres après la récolte. | The beekeeper extracts the honey from the frames after the harvest. |
| 6219 | délustrer | délustré | Le tissu a été délustré pour lui donner un aspect mat. | The fabric was stripped of its shine to give it a matte finish. |
| 6220 | courtauder | courtaude | Le maquignon courtaude les chevaux de trait selon la coutume ancienne. | The horse dealer docks the draft horses' tails, following the old custom. |
| 6221 | couchailler | couchaille | Il couchaille avec plusieurs personnes sans jamais s'engager. | He sleeps around with several people without ever committing to any of them. |
| 6223 | désenrayer | désenraye | Le charretier désenraye la roue bloquée par le sabot de frein. | The carter disengages the wheel jammed by the brake shoe. |
| 6224 | laïusser | laïusse | Le directeur laïusse pendant une heure sans jamais conclure. | The director holds forth for an hour without ever getting to the point. |
| 6225 | dégluer | déglue | Le chasseur déglue les plumes de l'oiseau capturé au piège. | The hunter removes the birdlime from the feathers of the trapped bird. |
| 6226 | dévirginiser | dévirginisait | Le rite antique dévirginisait symboliquement la jeune mariée avant les noces. | The ancient rite symbolically deflowered the young bride before the wedding. |
| 6227 | dégravoyer | dégravoie | Chaque crue dégravoie un peu plus les piles du vieux pont. | Each flood strips away a little more gravel from the piers of the old bridge. |
| 6228 | déjucher | déjuchent | Les poules déjuchent dès les premières lueurs de l'aube. | The hens leave the roost as soon as the first light of dawn appears. |
| 6229 | délinéamenter | délinéamente | Le géomètre délinéamente précisément les limites de la parcelle sur la carte. | The surveyor precisely delineates the parcel's boundaries on the map. |
| 6230 | désentortiller | désentortille | Elle désentortille patiemment le fil des écouteurs avant de partir. | She patiently untangles the earphone cord before leaving. |
| 6231 | dévolter | dévolte | Le technicien dévolte le circuit avant de le manipuler sans risque. | The technician reduces the circuit's voltage before handling it safely. |
| 6232 | labialiser | labialise | Le locuteur labialise la consonne finale pour imiter cet accent régional. | The speaker labializes the final consonant to imitate that regional accent. |
| 6233 | ressaigner | ressaigne | Sa cicatrice ressaigne chaque fois qu'il force sur ce bras. | His scar bleeds again every time he strains that arm. |
| 6234 | hormoner | hormonent | Certains éleveurs hormonent encore illégalement leur bétail pour accélérer sa croissance. | Some farmers still illegally treat their livestock with hormones to speed up growth. |
| 6235 | recarreler | recarrelle | Le carreleur recarrelle la salle de bain endommagée par la fuite d'eau. | The tiler retiles the bathroom damaged by the leak. |
| 6236 | galipoter | galipotent | Les marins galipotent la coque du bateau avant l'hiver. | The sailors tar the boat's hull before winter. |
| 6237 | désénerver | désénerve | Ce bain chaud désénerve toujours les enfants avant le coucher. | This warm bath always calms the children down before bedtime. |
| 6239 | entraccuser | s'entraccusent | Les deux voisins s'entraccusent chaque fois qu'un carreau se casse. | The two neighbors accuse each other every time a window breaks. |
| 6242 | bitturer | se bitture | Il se bitture dès qu'une fête commence. | He gets drunk as soon as a party starts. |
| 6244 | contremanifester | contremanifester | Des dizaines de militants sont venus contremanifester devant la mairie ce matin. | Dozens of activists came to counter-protest in front of city hall this morning. |
| 6245 | contretirer | contretire | L'artiste contretire l'estampe encore humide pour obtenir une image inversée. | The artist counterproofs the still-damp print to get a reversed image. |
| 6246 | copermuter | copermutent | Les deux curés copermutent leurs bénéfices avec l'accord de l'évêque. | The two priests exchange their benefices with the bishop's approval. |
| 6247 | coposséder | copossèdent | Les trois cousins copossèdent la maison de campagne héritée de leur grand-père. | The three cousins co-own the country house they inherited from their grandfather. |
| 6248 | décauser | décause | Il ne cesse de décauser ses voisins dès qu'ils ont le dos tourné. | He never stops badmouthing his neighbors the moment their backs are turned. |
| 6249 | décruser | décruse | L'usine décruse la soie brute pour éliminer la séricine collante. | The mill degums the raw silk to remove the sticky sericin. |
| 6250 | décuivrer | décuivre | Le fondeur décuivre le plomb impur avant de le raffiner davantage. | The smelter removes the copper from the impure lead before refining it further. |
| 6251 | dégasoliner | dégasoline | La raffinerie dégasoline le gaz naturel pour en extraire les hydrocarbures liquides. | The refinery degasolinizes the natural gas to extract the liquid hydrocarbons. |
| 6252 | dégazoliner | dégazoline | L'installation dégazoline le gaz naturel avant son transport par gazoduc. | The facility degasolinizes the natural gas before it is transported by pipeline. |
| 6253 | dégazonner | dégazonne | L'entrepreneur dégazonne la pelouse avant de poser la nouvelle terrasse. | The contractor removes the sod before laying the new patio. |
| 6254 | dégrosser | dégrosse | L'orfèvre dégrosse le fil d'argent avant de l'affiner davantage. | The silversmith draws down the silver wire before refining it further. |
| 6255 | délabialiser | délabialise | Le linguiste montre comment cette évolution phonétique délabialise la voyelle finale. | The linguist shows how this sound change delabializes the final vowel. |
| 6256 | démutiser | démutiser | L'orthophoniste s'efforce de démutiser l'enfant sourd depuis sa naissance. | The speech therapist works to teach speech to the child who has been deaf since birth. |
| 6257 | dénébuler | dénébule | Le vent finit par dénébuler la vallée en fin de matinée. | The wind eventually clears the fog from the valley by late morning. |
| 6258 | dénébuliser | dénébuliser | Le dispositif thermique permet de dénébuliser rapidement la piste d'atterrissage. | The heating system quickly clears the fog from the runway. |
| 6259 | déphosphorer | déphosphore | L'usine déphosphore les eaux usées avant de les rejeter dans la rivière. | The plant dephosphorizes the wastewater before releasing it into the river. |
| 6260 | désacclimater | désacclimate | Un séjour trop long en ville désacclimate peu à peu le randonneur à la montagne. | Too long a stay in the city gradually deacclimatizes the hiker to the mountains. |
| 6261 | désaciérer | désacière | Le forgeron désacière la barre pour la ramollir avant de la retravailler. | The blacksmith decarburizes the bar to soften it before reworking it. |
| 6262 | désagrafer | désagrafe | Il désagrafe les feuilles agrafées avant de les scanner. | He unstaples the stapled sheets before scanning them. |
| 6264 | désapparier | désapparie | L'éleveur désapparie les pigeons pour éviter qu'ils se reproduisent. | The breeder separates the paired pigeons to keep them from breeding. |
| 6265 | désassimiler | désassimile | Le corps désassimile certaines substances qu'il ne peut plus utiliser. | The body disassimilates certain substances it can no longer use. |
| 6266 | désembobiner | désembobine | Le technicien désembobine le câble avant de le ranger. | The technician unwinds the cable before putting it away. |
| 6267 | désenvenimer | désenvenime | Le médecin désenvenime la plaie après la morsure de serpent. | The doctor removes the venom from the wound after the snakebite. |
| 6268 | désenverguer | désenverguent | Les marins désenverguent les voiles avant l'arrivée de la tempête. | The sailors unbend the sails before the storm arrives. |
| 6269 | désulfiter | désulfite | Le vigneron désulfite le vin avant la mise en bouteille. | The winemaker removes the sulfites from the wine before bottling. |
| 6271 | écœurer | écœure | Cette odeur de poisson pourri m'écœure. | This smell of rotten fish disgusts me. |
| 6272 | éditionner | éditionne | L'imprimeur éditionne chaque exemplaire avant l'expédition. | The printer marks each copy with an edition number before shipping. |
| 6273 | élégir | élégit | Le charpentier élégit la poutre pour alléger la structure. | The carpenter thins down the beam to lighten the structure. |
| 6274 | émorfiler | émorfile | L'ouvrier émorfile la lame après l'avoir affûtée à la meule. | The worker deburrs the blade after sharpening it on the grindstone. |
| 6275 | enchevaucher | enchevauche | Le couvreur enchevauche les tuiles pour empêcher l'eau de pénétrer. | The roofer overlaps the tiles to keep water from getting in. |
| 6276 | enfutailler | enfutaille | Le brasseur enfutaille la bière avant de la laisser vieillir. | The brewer casks the beer before letting it age. |
| 6277 | engommer | engomme | L'ouvrier engomme le tissu pour le rendre imperméable. | The worker rubberizes the fabric to make it waterproof. |
| 6278 | entrenuire | s'entrenuisent | Les deux frères s'entrenuisent sans cesse par jalousie. | The two brothers keep harming each other out of jealousy. |
| 6279 | entrevoûter | entrevoûte | Le maçon entrevoûte l'espace entre les solives avec du plâtre. | The mason fills the space between the joists with plaster. |
| 6281 | fransquillonner | fransquillonnent | Certains Bruxellois fransquillonnent pour paraître plus raffinés. | Some Brussels residents put on an affected French accent to seem more refined. |
| 6282 | gournabler | gournable | Le charpentier de marine gournable les bordages de la coque. | The shipwright treenails the hull planking. |
| 6283 | graticuler | graticule | L'artiste graticule le dessin pour l'agrandir proportionnellement. | The artist grids the drawing into squares to enlarge it proportionally. |
| 6284 | halogéner | halogène | Le chimiste halogène le composé pour améliorer sa stabilité. | The chemist halogenates the compound to improve its stability. |
| 6286 | holographier | holographie | Le vieil homme holographie son testament avant de mourir. | The old man handwrites his will before he dies. |
| 6287 | homogénéifier | homogénéifie | L'usine homogénéifie le lait avant la mise en bouteille. | The factory homogenizes the milk before bottling it. |
| 6288 | hongroyer | hongroie | Le tanneur hongroie les peaux pour obtenir un cuir souple. | The tanner tans the hides to produce supple leather. |
| 6289 | joualiser | joualise | Le comédien joualise ses répliques pour rendre le personnage plus authentique. | The actor speaks his lines in joual to make the character more authentic. |
| 6291 | microcopier | microcopie | La bibliothèque microcopie les vieux journaux pour les conserver. | The library microfilms the old newspapers to preserve them. |
| 6292 | obvenir | obvient | Le domaine obvient à l'État faute d'héritier. | The estate falls to the state for lack of an heir. |
| 6293 | œilletonner | œilletonne | Le jardinier œilletonne les œillets pour favoriser une seule fleur. | The gardener removes the side shoots from the carnations to encourage a single bloom. |
| 6294 | paillassonner | paillassonne | Le jardinier paillassonne les jeunes plants avant le gel. | The gardener covers the young plants with straw mats before the frost. |
| 6295 | palissonner | palissonne | Le tanneur palissonne les peaux pour les assouplir. | The tanner stakes the hides to soften them. |
| 6296 | panosser | panosse | Elle panosse la cuisine tous les matins. | She mops the kitchen every morning. |
| 6297 | paumoyer | paumoie | Le matelot paumoie le cordage avant de l'inspecter. | The sailor hauls the rope in hand over hand before inspecting it. |
| 6299 | plasmifier | plasmifie | Le laboratoire plasmifie le gaz à très haute température. | The lab transforms the gas into plasma at very high temperature. |
| 6300 | poutser | poutse | Elle poutse la cuisine tous les samedis matin. | She cleans the kitchen every Saturday morning. |
| 6301 | quarderonner | quarderonne | Le tailleur de pierre quarderonne l'arête du bloc de calcaire. | The stonemason cuts a quarter-round molding along the edge of the limestone block. |
| 6302 | quartager | quartage | Le vigneron quartage la vigne pour ameublir la terre. | The winegrower gives the vineyard its fourth plowing to loosen the soil. |
| 6303 | radiobaliser | radiobalise | L'armée radiobalise la zone frontalière pour guider les avions. | The army equips the border zone with radio beacons to guide the planes. |
| 6304 | rapatronner | rapatronne | Le menuisier rapatronne les deux planches avant de les coller. | The carpenter joins and adjusts the two boards before gluing them. |
| 6305 | rapointir | rapointit | L'artisan rapointit le crayon avec un couteau. | The craftsman repoints the pencil with a knife. |
| 6306 | rapparier | rapparie | Le fermier rapparie les deux bœufs qui s'étaient séparés. | The farmer pairs the two oxen back up after they got separated. |
| 6307 | rappointir | rappointit | Le cordonnier rappointit l'aiguille émoussée. | The cobbler sharpens the blunted needle again. |
| 6309 | regréer | regrée | L'équipage regrée le voilier après la tempête. | The crew rerigs the sailboat after the storm. |
| 6310 | rempiéter | rempiète | La tricoteuse rempiète le talon du bas usé. | The knitter reknits the heel of the worn stocking. |
| 6312 | rengréner | rengrène | Le mécanicien rengrène l'engrenage dans la seconde roue. | The mechanic meshes the gear into the second wheel. |
| 6313 | renvider | renvide | La fileuse renvide le fil sur la broche. | The spinner rewinds the thread onto the spindle. |
| 6314 | retercer | reterce | Le vigneron reterce la vigne pour détruire les mauvaises herbes. | The winegrower tills the vineyard again to kill the weeds. |
| 6315 | rocouer | rocoue | L'artisan rocoue le tissu pour lui donner une teinte rouge. | The craftsman dyes the fabric with annatto to give it a red hue. |
| 6316 | serfouir | serfouit | Le jardinier serfouit la terre autour des salades. | The gardener hoes the soil around the lettuces. |
| 6317 | similiser | similise | L'usine similise le coton pour lui donner un aspect soyeux. | The factory treats the cotton to give it a silky sheen. |
| 6318 | surtondre | surtond | Le tanneur surtond la peau passée à la chaux. | The tanner dehairs the lime-treated hide. |
| 6319 | syncristalliser | syncristallise | Le composé syncristallise avec le sel dans la solution refroidie. | The compound co-crystallizes with the salt in the cooled solution. |
| 6320 | tanniser | tannise | Le vigneron tannise le vin en laissant macérer les rafles. | The winemaker adds tannins to the wine by letting the stems macerate. |
| 6322 | tchiper | tchipe | L'adolescent tchipe quand on lui donne un ordre. | The teenager sucks his teeth when he's given an order. |
| 6323 | tranchefiler | tranchefile | Le relieur tranchefile le dos du livre avec un fil de soie. | The bookbinder sews the headband on the spine with silk thread. |
| 6324 | blistériser | blistérise | Le fabricant blistérise les comprimés avant l'expédition. | The manufacturer blister-packs the tablets before shipping. |
| 6325 | coupasser | coupasse | L'apprenti coupasse le tissu, faute d'expérience. | The apprentice cuts the fabric poorly, for lack of experience. |
| 6326 | humoter | humote | Le vieillard humote son bouillon avec précaution. | The old man sips his broth cautiously, sucking it in. |

<!-- verb-pass:end -->

<!-- verb-pass-stage5:start -->

## Stage 5 of the verb pass (266 verbs, applied 2026-10-02)

Stage 5 of the verb pass took the verbs that still had no example after Stage 4. Claude (Sonnet 5.5) wrote a sentence for each verb that no corpus sentence or public-domain quotation served, some of them with CNRTL dictionary evidence (Stages 5c–5e), and Claude (Opus 5.5) checked every one. The rows below are the ones Josh accepted, in frequency-rank order, with the corrections he approved for the skeptic's `partly` verdicts. Each carries `"source": "Claude (Sonnet 5.5)"` and `"line": null`.

| Rank | Verb | Form | French | English |
|---|---|---|---|---|
| 78 | sortir (obtain) | sortissait | La décision sortissait son plein effet dès le lendemain de la signature. | The decision took full effect the day after it was signed. |
| 799 | trancher | tranché | Papa a tranché le jambon en fines lamelles pour le pique-nique. | Dad sliced the ham into thin strips for the picnic. |
| 1137 | dialoguer | dialogué | Après leur dispute, les deux voisins ont enfin dialogué calmement pendant une heure. | After their quarrel, the two neighbors finally talked calmly for an hour. |
| 1168 | saturer | saturé | Le chimiste a saturé la solution en ajoutant du sel jusqu'à ce qu'il ne se dissolve plus. | The chemist saturated the solution by adding salt until no more would dissolve. |
| 1365 | terrer | terré | Avant les gelées, le jardinier a terré le pied des rosiers pour protéger les racines. | Before the frosts, the gardener banked soil around the base of the rosebushes to protect the roots. |
| 1486 | liquider | liquide | Le magasin de meubles liquide tous ses canapés à moitié prix avant les travaux. | The furniture store is selling off all its sofas at half price before the renovations. |
| 1565 | marrer | marre | Je me marre toujours quand mon grand-père raconte ses blagues de pêcheur. | I always crack up when my grandfather tells his fishing jokes. |
| 1682 | cadrer | cadre | Son récit ne cadre pas du tout avec ce que les témoins ont raconté. | His account doesn't fit at all with what the witnesses described. |
| 1787 | médicaliser | médicaliser | On a tendance à médicaliser des problèmes qui relèvent simplement de la vie quotidienne. | There is a tendency to medicalize problems that are simply part of everyday life. |
| 1802 | déjanter | déjanté | Le pneu a déjanté dans le virage, et la voiture a fini dans le fossé. | The tire came off the rim in the curve, and the car ended up in the ditch. |
| 1831 | mouvementer | mouvementer | Le kiné m'a demandé de mouvementer doucement mon poignet plusieurs fois par jour. | The physiotherapist asked me to gently move my wrist several times a day. |
| 1896 | bouler | boule | Au printemps, le pigeon boule et tourne autour de la femelle en roucoulant. | In spring, the pigeon puffs up its throat and struts around the female, cooing. |
| 1903 | exclamer | se sont exclamés | En voyant le feu d'artifice, les enfants se sont exclamés : « Quelle merveille ! » | Seeing the fireworks, the children exclaimed, “How marvelous!” |
| 1904 | démanteler | démantelé | La police a démantelé un important réseau de trafiquants en moins d'une semaine. | The police dismantled a major network of traffickers in less than a week. |
| 2019 | historier | historiait | Le vieux pêcheur historiait longuement ses aventures en mer, et les enfants l'écoutaient sans bouger. | The old fisherman told his adventures at sea at great length, and the children listened without moving. |
| 2033 | épingler | épinglé | Elle a épinglé un petit badge sur le revers de sa veste avant de sortir. | She pinned a small badge to the lapel of her jacket before going out. |
| 2097 | graduer | graduait | Le fabricant graduait chaque éprouvette en millilitres avant de la mettre en vente. | The manufacturer marked each test tube with milliliter graduations before putting it on sale. |
| 2150 | clicher | cliché | Depuis le balcon, le reporter a cliché la manifestation avant que la police n'arrive. | From the balcony, the reporter photographed the demonstration before the police arrived. |
| 2319 | brader | brade | Le magasin brade tous ses manteaux d'hiver à la fin de la saison. | The store is selling off all its winter coats at rock-bottom prices at the end of the season. |
| 2512 | cloisonner | cloisonné | Ils ont cloisonné le grenier pour y aménager deux petites chambres. | They partitioned the attic to create two small bedrooms. |
| 2522 | oxyder | oxydé | L'humidité a oxydé les vis du portail en quelques mois. | The humidity oxidized the gate's screws within a few months. |
| 2564 | diligenter | diligenter | Le directeur a demandé à ses équipes de diligenter le traitement des dossiers urgents avant la fin de la semaine. | The director asked his teams to expedite the processing of the urgent files before the end of the week. |
| 2598 | schématiser | a schématisé | Pour nous expliquer le fonctionnement du moteur, le professeur a schématisé chaque étape au tableau. | To explain how the engine works, the teacher sketched out each step on the board. |
| 2605 | tiédir | a tiédi | Le café a tiédi pendant qu'elle répondait au téléphone. | The coffee turned lukewarm while she was on the phone. |
| 2627 | surtaxer | a surtaxé | Le maire a surtaxé les habitants du quartier, qui paient maintenant bien plus d'impôts que leurs voisins. | The mayor overtaxed the residents of the neighborhood, who now pay far more tax than their neighbors. |
| 2644 | enclaver | enclavé | Ce petit village est enclavé entre deux montagnes, sans route directe vers la ville. | This little village is shut in between two mountains, with no direct road to the city. |
| 2676 | carburer | carbure | Depuis la révision, le moteur de la vieille voiture carbure parfaitement, même en côte. | Since the service, the old car's engine runs perfectly, even uphill. |
| 2680 | arriérer | a arriéré | Le fermier a arriéré le paiement de ses fermages jusqu'à la récolte. | The farmer put off paying his rent until the harvest. |
| 2723 | dévoyer | ont dévoyé | Ses mauvaises fréquentations ont dévoyé le jeune homme, qui a abandonné ses études. | His bad company led the young man astray, and he dropped out of school. |
| 2754 | abstraire | abstrait | Le philosophe abstrait la notion de beauté des objets particuliers qui la manifestent. | The philosopher abstracts the notion of beauty from the particular objects that display it. |
| 2769 | réinscrire | a réinscrit | Elle a réinscrit son fils au club de natation pour la rentrée de septembre. | She signed her son up again at the swimming club for the September restart. |
| 2773 | effriter | effritent | La pluie et le gel effritent peu à peu les murs de la vieille église. | Rain and frost gradually crumble the walls of the old church. |
| 2791 | tiercer | tierce | Le fermier tierce ses champs à la fin de l'été, juste avant les semailles d'automne. | The farmer gives his fields their third plowing at the end of summer, just before the autumn sowing. |
| 2818 | charpenter | charpentent | Les compagnons charpentent les poutres du toit dans l'atelier. | The journeymen are hewing the roof beams in the workshop. |
| 2876 | raréfier | ont raréfié | Les chasseurs ont raréfié le gibier dans toute la vallée. | Hunters have made game scarcer throughout the valley. |
| 2972 | ajourer | a ajouré | L'artisan a ajouré le panneau de bois pour y dessiner de petites étoiles. | The craftsman perforated the wooden panel to form little stars in it. |
| 2993 | débaucher | a débauché | Faute de commandes, la fabrique a débauché une dizaine d'ouvriers en mars. | For lack of orders, the factory laid off about ten workers in March. |
| 3031 | dilapider | a dilapidé | Le fils a dilapidé en quelques années toute la fortune que son père avait mise de côté. | In just a few years the son squandered the entire fortune his father had set aside. |
| 3061 | magner | magner | Il faut se magner si on veut attraper le dernier train ce soir. | We have to hurry up if we want to catch the last train tonight. |
| 3077 | pourfendre | pourfendu | Dans son discours, le député a pourfendu la politique du gouvernement. | In his speech, the deputy attacked the government's policy. |
| 3105 | délester | délesté | Le pilote a délesté la montgolfière de deux sacs de sable pour reprendre de l'altitude. | The pilot dropped two sandbags of ballast from the hot-air balloon to regain altitude. |
| 3110 | palabrer | palabré | Les villageois ont palabré toute la soirée sous l'arbre sans prendre aucune décision. | The villagers talked on and on all evening under the tree without reaching any decision. |
| 3184 | défausser | défausse | L'ouvrier défausse la barre d'acier à coups de marteau avant de la souder. | The worker straightens the steel bar with hammer blows before welding it. |
| 3207 | carbonater | carbonatent | Les chimistes carbonatent la solution en y ajoutant du carbonate de sodium. | The chemists carbonate the solution by adding sodium carbonate to it. |
| 3259 | chialer | chialer | Arrête de chialer, ce n'est qu'un petit bobo ! | Stop crying, it's only a little boo-boo! |
| 3292 | ulcérer | ulcéré | Cette injustice a longtemps ulcéré le vieux soldat. | That injustice embittered the old soldier for a long time. |
| 3318 | mâtiner | mâtine | Ce romancier mâtine ses récits policiers d'humour noir. | This novelist blends black humor into his crime stories. |
| 3330 | kilométrer | kilométrer | On a décidé de kilométrer la nouvelle route en posant une borne tous les kilomètres. | They decided to mark the new road with kilometer posts, placing one every kilometer. |
| 3369 | croûter | croûter | Viens croûter avec nous, il y a des pâtes pour tout le monde. | Come eat with us, there's pasta for everyone. |
| 3382 | tuber | tubent | Les ouvriers tubent la tôle pour fabriquer des conduits de ventilation. | The workers form the sheet metal into tubes to make ventilation ducts. |
| 3436 | claironner | claironne | Chaque matin, le soldat claironne le réveil devant la caserne. | Every morning, the soldier sounds reveille on his bugle in front of the barracks. |
| 3479 | délaver | délavé | Le soleil a délavé les couleurs du vieux drapeau. | The sun has faded the colors of the old flag. |
| 3483 | compartimenter | compartimenté | Pour gagner de la place, l'architecte a compartimenté le grand hangar en plusieurs ateliers. | To save space, the architect divided the large hangar into several workshops. |
| 3533 | trompeter | trompeter | Inutile de trompeter la nouvelle avant que tout soit officiellement décidé. | There's no point trumpeting the news before everything has been officially decided. |
| 3563 | bagarrer | bagarrer | Ces gamins adorent se bagarrer dans la cour de récréation. | Those kids love to scrap in the schoolyard. |
| 3566 | picoler | picoler | Il passe ses soirées à picoler au bar avec ses copains. | He spends his evenings boozing at the bar with his buddies. |
| 3574 | pointiller | pointiller | Arrêtez de pointiller sur chaque virgule et passons à l'essentiel. | Stop quibbling over every comma and let's get to the point. |
| 3611 | étuver | étuve | Le laboratoire étuve les échantillons à cent degrés pendant une heure. | The laboratory dries the samples in a drying oven at one hundred degrees for an hour. |
| 3645 | truster | trustent | Quelques grands groupes trustent le marché de la distribution dans la région. | A few big companies monopolize the distribution market in the region. |
| 3666 | peinturer | peinturé | Nous avons peinturé les murs du salon en bleu pâle. | We painted the living room walls pale blue. |
| 3670 | interpénétrer | interpénètrent | Dans ce quartier, les cultures s'interpénètrent depuis des siècles. | In this neighborhood, the cultures have interpenetrated for centuries. |
| 3679 | poiler | poilés | On s'est tous poilés devant ce film hier soir. | We all laughed our heads off at that movie last night. |
| 3690 | orbiter | orbite | Le satellite orbite autour de la Terre toutes les quatre-vingt-dix minutes. | The satellite orbits the Earth every ninety minutes. |
| 3729 | phagocyter | phagocytent | Les globules blancs phagocytent les bactéries qui pénètrent dans le sang. | White blood cells phagocytize the bacteria that enter the bloodstream. |
| 3748 | intriquer | intriquent | Dans ce roman, les destins des personnages s'intriquent peu à peu. | In this novel, the characters' destinies gradually become intertwined. |
| 3778 | engoncer | engonce | Ce gros manteau l'engonce : on dirait qu'il n'a plus de cou. | That bulky coat swallows him up: it looks as if he has no neck left. |
| 3788 | castagner | castagner | Après le match, les supporters ont fini par se castagner devant le stade. | After the match, the fans ended up scrapping outside the stadium. |
| 3812 | glisser-déposer | glisser-déposer | Pour ajouter la photo, il suffit de glisser-déposer le fichier dans la fenêtre. | To add the photo, just drag and drop the file into the window. |
| 3825 | alcooliser | alcoolisé | Le barman a alcoolisé le jus de fruits sans prévenir les clients. | The bartender spiked the fruit juice with alcohol without warning the customers. |
| 3877 | égrainer | égrainait | Assise sur le perron, elle égrainait des épis de maïs pour nourrir les poules. | Sitting on the front steps, she shelled ears of corn to feed the chickens. |
| 3906 | baster | baster | Les vignerons de Lavaux ont refusé de baster devant les exigences du canton. | The Lavaux winegrowers refused to give in to the canton's demands. |
| 3926 | empierrer | empierré | Les ouvriers ont empierré le chemin de terre avant l'arrivée de l'hiver. | The workers surfaced the dirt road with crushed stone before winter arrived. |
| 3990 | gourer | gouré | Je me suis gouré de route et nous avons roulé une heure pour rien. | I took the wrong road and we drove for an hour for nothing. |
| 3994 | potasser | potasser | Il a passé tout le week-end à potasser ses cours de chimie avant l'examen. | He spent the whole weekend cramming his chemistry lessons before the exam. |
| 3999 | étrenner | étrenné | Elle a étrenné sa nouvelle robe le soir de l'anniversaire de sa sœur. | She wore her new dress for the first time on the evening of her sister's birthday. |
| 4002 | imperméabiliser | imperméabiliser | Il faut imperméabiliser ces bottes avec un spray avant la randonnée. | You need to waterproof these boots with a spray before the hike. |
| 4026 | sous-tendre | sous-tend | Cette théorie sous-tend l'ensemble de son raisonnement. | This theory underlies the whole of his reasoning. |
| 4039 | détourer | détouré | Le graphiste a détouré la photo pour supprimer l'arrière-plan. | The graphic designer cut the subject out of the photo to remove the background. |
| 4083 | corseter | corsetait | La couturière corsetait la mariée avec soin avant la cérémonie. | The seamstress carefully fitted the bride into her corset before the ceremony. |
| 4097 | ébrécher | ébréché | Il a ébréché son verre en le posant trop fort sur l'évier. | He chipped his glass by setting it down too hard on the sink. |
| 4099 | contre-indiquer | contre-indique | Le médecin contre-indique ce traitement aux personnes qui souffrent d'allergies. | The doctor advises against this treatment for people with allergies. |
| 4140 | déboîter | déboîté | Il a déboîté les deux éléments du tuyau pour le nettoyer. | He pulled the two sections of the pipe apart to clean it. |
| 4182 | mazouter | mazouté | La marée noire a mazouté des centaines d'oiseaux sur toute la côte. | The oil spill covered hundreds of birds in oil all along the coast. |
| 4213 | résiner | résiné | Il a résiné la coque du bateau pour la rendre étanche. | He coated the boat's hull with resin to make it watertight. |
| 4219 | gamberger | gamberger | Laisse-moi gamberger un peu avant de te donner ma réponse. | Let me think it over for a bit before I give you my answer. |
| 4293 | vrombir | vrombissent | Les abeilles vrombissent autour des fleurs du jardin pendant tout l'après-midi. | The bees hum around the flowers in the garden all afternoon. |
| 4308 | désaxer | désaxé | La mort de sa femme l'a complètement désaxé. | His wife's death completely unbalanced him. |
| 4326 | platiner | platine | L'atelier platine les contacts électriques pour qu'ils résistent mieux à la corrosion. | The workshop plates the electrical contacts with platinum so that they resist corrosion better. |
| 4336 | harper | harpait | Le vétérinaire a observé que la jument harpait légèrement en sortant de son box. | The vet noticed that the mare was hitching a hind leg slightly as she came out of her stall. |
| 4471 | tripatouiller | tripatouillé | Quelqu'un a tripatouillé les comptes de l'entreprise avant l'audit. | Someone tampered with the company's accounts before the audit. |
| 4534 | déplumer | déplumé | Le chat a attrapé l'oiseau et l'a à moitié déplumé avant que nous intervenions. | The cat caught the bird and had half plucked it before we stepped in. |
| 4552 | baratiner | baratiner | Il essaie de baratiner la serveuse pour obtenir son numéro de téléphone. | He is trying to chat up the waitress to get her phone number. |
| 4577 | rechausser | rechaussé | Après la plage, la mère a rechaussé l'enfant avant de rentrer à la maison. | After the beach, the mother put the child's shoes back on before heading home. |
| 4591 | relaver | relave | Le lave-vaisselle n'a pas bien nettoyé les assiettes, alors je les relave à la main. | The dishwasher didn't clean the plates properly, so I'm rewashing them by hand. |
| 4597 | insoler | s'insoler | Le médecin conseille aux convalescents de s'insoler progressivement, dix minutes le premier jour, puis un peu plus chaque matin. | The doctor advises convalescents to expose themselves to the sun gradually, ten minutes the first day, then a little more each morning. |
| 4614 | dépiler | dépile | Le tanneur dépile les peaux dans un bain de chaux avant de les travailler. | The tanner removes the hair from the hides in a lime bath before working them. |
| 4615 | putréfier | putréfie | La chaleur de l'été putréfie rapidement la viande laissée au soleil. | The summer heat quickly rots meat left out in the sun. |
| 4625 | invertir | invertit | Le télescope invertit l'image : le haut devient le bas. | The telescope inverts the image: the top becomes the bottom. |
| 4626 | caleter | caleter | Quand les flics sont arrivés, on a dû caleter vite fait. | When the cops showed up, we had to make ourselves scarce in a hurry. |
| 4690 | engrener | engrène | Chaque matin, le meunier engrène la trémie du moulin avant de lancer la meule. | Every morning the miller fills the mill's hopper with grain before starting the millstone. |
| 4827 | fuseler | fuseler | Le menuisier va fuseler les pieds de la chaise pour les rendre plus élégants. | The carpenter is going to shape the chair legs like spindles to make them more elegant. |
| 4834 | rétamer | rétamé | Le chaudronnier a rétamé les vieilles casseroles de cuivre de ma grand-mère. | The coppersmith re-tinned my grandmother's old copper pots. |
| 4841 | frigorifier | frigorifie | Cette usine frigorifie le poisson dès son arrivée du port pour le conserver. | This plant refrigerates the fish as soon as it arrives from the port, to preserve it. |
| 4844 | laitonner | laitonne | L'atelier laitonne les pièces de fer pour leur donner un bel éclat doré. | The workshop brass-plates the iron parts to give them a handsome golden sheen. |
| 4893 | chourer | chouré | Quelqu'un m'a chouré mon portable dans le métro. | Somebody swiped my phone on the metro. |
| 4897 | forclore | forclore | Le tribunal peut forclore le plaignant qui a laissé passer le délai de recours. | The court may debar a plaintiff who has let the appeal deadline pass. |
| 4901 | débriefer | débriefer | Après l'exercice, le capitaine va débriefer toute l'équipe. | After the exercise, the captain is going to debrief the whole team. |
| 4926 | ressuyer | ressuyé | Le jardinier a ressuyé les outils mouillés avant de les ranger. | The gardener dried off the wet tools before putting them away. |
| 4957 | décomprimer | décomprime | Après la remontée, le médecin décomprime lentement le plongeur dans un caisson. | After the ascent, the doctor slowly decompresses the diver in a chamber. |
| 4958 | cornaquer | cornaque | Un guide local cornaque les touristes à travers les ruelles de la vieille ville. | A local guide shows the tourists around the alleys of the old town. |
| 4965 | frégater | frégaté | Le chantier a frégaté ce navire marchand pour lui donner la ligne basse et élancée d'une frégate. | The shipyard built this merchant ship frigate-style to give it the low, sleek lines of a frigate. |
| 4977 | exonder | s'exondent | À marée basse, les rochers s'exondent et les oiseaux viennent y chercher des crabes. | At low tide, the rocks emerge from the water and the birds come to look for crabs. |
| 5010 | créner | crène | Le fondeur crène la lettre f, dont l'œil déborde du corps. | The typefounder kerns the letter f, whose face overhangs the body. |
| 5038 | clochardiser | clochardisé | Après son licenciement et son divorce, Paul a clochardisé en moins d'un an. | After losing his job and his marriage, Paul turned into a tramp in less than a year. |
| 5078 | striduler | stridulent | Le soir, les grillons stridulent dans l'herbe derrière la maison. | In the evening, the crickets chirp in the grass behind the house. |
| 5098 | zyeuter | zyeuter | Arrête de zyeuter mon assiette, tu as déjà mangé ! | Stop eyeing my plate, you've already eaten! |
| 5102 | tringler | tringlé | Dans ce film, le héros se vante d'avoir tringlé la femme de son patron. | In this film, the hero boasts of having shagged his boss's wife. |
| 5103 | remouiller | remouiller | Le linge a séché trop vite, alors je dois le remouiller avant de le repasser. | The laundry dried too fast, so I have to dampen it again before ironing it. |
| 5118 | pacquer | pacquent | Avant le départ du bateau, les ouvriers pacquent les morues salées dans des barils. | Before the boat leaves, the workers pack the salted cod in barrels. |
| 5119 | décorder | décordé | Après l'ascension, le guide a décordé le blessé et l'a installé sur le brancard. | After the climb, the guide untied the injured man from the rope and laid him on the stretcher. |
| 5123 | trépaner | trépané | Le chirurgien a trépané le patient pour soulager la pression sur son cerveau. | The surgeon trepanned the patient to relieve the pressure on his brain. |
| 5126 | démancher | démanché | Paul a démanché la vieille pioche pour y mettre un manche neuf. | Paul took the handle off the old pickaxe to fit a new one. |
| 5136 | invaginer | s'invagine | Chez l'embryon, la paroi de la blastula s'invagine pour former la gastrula. | In the embryo, the wall of the blastula invaginates to form the gastrula. |
| 5137 | retapisser | retapissé | Mon grand-père a retapissé les fauteuils du salon avec un beau velours vert. | My grandfather reupholstered the living-room armchairs in a lovely green velvet. |
| 5138 | instiguer | instiguait | Le meneur instiguait ses camarades à la révolte contre le directeur. | The ringleader was inciting his classmates to revolt against the headmaster. |
| 5149 | désaliéner | désaliéner | Pour Marx, seule une société plus juste pourrait désaliéner les travailleurs. | For Marx, only a fairer society could free workers from their alienation. |
| 5154 | décalcifier | décalcifier | Une alimentation pauvre en vitamine D peut décalcifier les os d'un enfant. | A diet low in vitamin D can decalcify a child's bones. |
| 5182 | ratiboiser | ratiboisé | Au poker, mon cousin m'a ratiboisé tout mon argent de poche. | At poker, my cousin cleaned me out of all my pocket money. |
| 5187 | rétreindre | rétreint | Le forgeron rétreint le tube d'acier à coups de marteau pour en réduire le diamètre. | The blacksmith hammers the steel tube narrower to reduce its diameter. |
| 5193 | tontiner | tontinent | Chaque mois, mes cousins tontinent avec leurs amis pour pouvoir financer un voyage. | Every month, my cousins take part in a tontine with their friends so they can fund a trip. |
| 5214 | amurer | amure | Sur l'ordre du capitaine, le matelot amure la misaine. | On the captain's order, the sailor hauls the foresail's tack taut. |
| 5299 | crouter | crouter | Il est midi passé, on va crouter un morceau avec les copains ? | It's past noon, shall we go grab a bite with the guys? |
| 5310 | alunir | aluni | Le 20 juillet 1969, Armstrong et Aldrin ont aluni dans la mer de la Tranquillité. | On July 20, 1969, Armstrong and Aldrin landed in the Sea of Tranquility. |
| 5317 | tapiner | tapiné | Les gars ont tapiné toute la semaine sur le chantier pour finir à temps. | The guys slogged away all week on the building site to finish on time. |
| 5334 | rapiner | rapinait | Au marché, le gamin rapinait dès que les marchands tournaient le dos. | At the market, the kid pilfered whenever the merchants turned their backs. |
| 5336 | bretter | a bretté | L'apprenti a bretté toutes les dalles de grès avant la pose. | The apprentice dressed all the sandstone slabs with a toothed chisel before they were laid. |
| 5341 | placardiser | placardisé | Après son refus de la mutation, la direction a placardisé Claire en lui retirant peu à peu ses dossiers. | After she refused the transfer, management sidelined Claire by gradually taking her files away. |
| 5352 | rebiquer | rebiquent | Ses cheveux rebiquent toujours à l'arrière, même après un coup de peigne. | His hair always sticks up at the back, even after a run of the comb. |
| 5367 | bigler | bigle | Depuis sa naissance, le petit garçon bigle un peu de l'œil gauche. | Since birth, the little boy has had a slight squint in his left eye. |
| 5381 | décadrer | décadré | Avant de vendre le tableau, l'antiquaire l'a décadré avec précaution. | Before selling the painting, the antiques dealer carefully took it out of its frame. |
| 5383 | ouatiner | ouatine | La couturière ouatine la doublure de ce manteau pour qu'il tienne plus chaud. | The seamstress quilts the lining of this coat with wadding so that it keeps warmer. |
| 5384 | margoter | margote | Dans les blés, une caille margote dès le lever du jour. | In the wheat fields, a quail is calling from daybreak. |
| 5423 | réaléser | réalésé | Le garagiste a réalésé les cylindres du moteur avant de monter de nouveaux pistons. | The mechanic rebored the engine cylinders before fitting new pistons. |
| 5424 | visibiliser | visibilise | Cette exposition visibilise le travail des femmes dans l'agriculture. | This exhibition makes women's work in agriculture visible. |
| 5425 | russifier | russifier | Au dix-neuvième siècle, le tsar a voulu russifier les provinces conquises. | In the nineteenth century, the tsar wanted to Russify the conquered provinces. |
| 5426 | estoquer | estoqué | Le chevalier a estoqué son adversaire d'un coup d'épée en pleine poitrine. | The knight ran his opponent through with a sword thrust to the chest. |
| 5428 | calfater | calfatent | Les charpentiers calfatent la coque du bateau avec de l'étoupe et du goudron. | The shipwrights are caulking the boat's hull with oakum and tar. |
| 5429 | dératiser | dératisé | La mairie a dératisé tout le quartier après l'invasion de rats. | The town hall rid the whole neighborhood of rats after the infestation. |
| 5430 | désadapter | désadapter | Une longue hospitalisation risque de désadapter un patient de sa vie quotidienne. | A long hospital stay can leave a patient unsuited to daily life. |
| 5433 | craqueter | craquetait | Le bois sec craquetait doucement dans la cheminée. | The dry wood was crackling softly in the fireplace. |
| 5435 | japoniser | japonise | Le chef japonise les recettes françaises en y ajoutant du miso et du yuzu. | The chef gives French recipes a Japanese twist by adding miso and yuzu. |
| 5437 | réensemencer | réensemencé | Les agriculteurs ont réensemencé le champ de blé après les fortes pluies. | The farmers reseeded the wheat field after the heavy rains. |
| 5439 | surmédicaliser | surmédicaliser | On reproche à ce système de surmédicaliser les accouchements normaux. | The system is criticized for overmedicalizing normal births. |
| 5441 | surhausser | surhaussé | On a surhaussé le mur du jardin pour se protéger des regards. | They raised the garden wall to shield themselves from prying eyes. |
| 5445 | dribler | drible | Le jeune attaquant drible le gardien et marque un but magnifique. | The young striker dribbles past the goalkeeper and scores a magnificent goal. |
| 5448 | syntoniser | syntonise | L'ingénieur syntonise les deux circuits sur la même fréquence. | The engineer tunes the two circuits to the same frequency. |
| 5449 | engober | engobe | La potière engobe le vase avant de le mettre au four. | The potter coats the vase with slip before putting it in the kiln. |
| 5450 | insolubiliser | insolubilise | Ce traitement chimique insolubilise les métaux lourds présents dans le sol. | This chemical treatment makes the heavy metals in the soil insoluble. |
| 5451 | suiffer | suiffe | Le matelot suiffe les cordages pour les protéger de l'humidité. | The sailor coats the ropes with tallow to protect them from damp. |
| 5452 | plucher | pluche | Mon vieux pull de laine pluche dès qu'on le lave. | My old wool sweater gets fluffy as soon as it is washed. |
| 5453 | délainer | délaine | Le tanneur délaine les peaux de mouton avant de les traiter. | The tanner removes the wool from the sheepskins before treating them. |
| 5455 | blatérer | blatère | Dans le pré, le bélier blatère avec insistance. | In the meadow, the ram bleats insistently. |
| 5540 | désarrimer | désarrimé | Le roulis a désarrimé les caisses, qui ont glissé d'un bord à l'autre de la cale. | The rolling of the ship broke the crates loose from their lashings, and they slid from one side of the hold to the other. |
| 5594 | briqueter | briqueté | Les ouvriers ont briqueté la cour de la vieille maison avant l'été. | The workers paved the old house's courtyard with brick before summer. |
| 5595 | panifier | panifie | Le boulanger panifie la farine de seigle pour faire un pain plus dense. | The baker turns rye flour into bread to make a denser loaf. |
| 5608 | déparler | déparles | Tu déparles, mon vieux, tu n'as rien compris à ce qu'on t'a dit. | You're talking nonsense, pal, you didn't understand a word of what you were told. |
| 5631 | dérader | déradé | Pendant la tempête, le cargo a déradé après la rupture de ses amarres et a dérivé vers le large. | During the storm, the freighter was driven from its anchorage after its mooring lines snapped, and drifted out to sea. |
| 5642 | désenvoûter | désenvoûter | Le sorcier a promis de désenvoûter la jeune fille que l'on disait ensorcelée. | The sorcerer promised to lift the spell from the girl who was said to be bewitched. |
| 5653 | grammaticaliser | grammaticalisé | Avec le temps, le français a grammaticalisé le mot « pas », devenu un simple marqueur de négation. | Over time, French grammaticalized the word “pas”, which became a mere marker of negation. |
| 5654 | guiper | guipe | L'électricien guipe le fil de cuivre de ruban isolant. | The electrician wraps the copper wire in insulating tape. |
| 5662 | louveter | louveté | La louve a louveté dans sa tanière au début du printemps. | The she-wolf whelped in her den at the start of spring. |
| 5670 | encartonner | encartonnent | Les ouvriers encartonnent les bouteilles avant de les expédier. | The workers pack the bottles into cartons before shipping them. |
| 5676 | mâchurer | mâchuré | Le ramoneur a mâchuré le mur blanc avec ses doigts noirs de suie. | The chimney sweep smeared the white wall with his soot-black fingers. |
| 5679 | conglomérer | conglomère | Avec le temps, la pression conglomère les grains de sable en une roche dure. | Over time, pressure binds the grains of sand together into a hard rock. |
| 5753 | panneauter | panneaute | Le braconnier panneaute à la lisière du bois pour prendre des lapins. | The poacher sets nets at the edge of the woods to catch rabbits. |
| 5794 | houpper | houppait | Elle houppait les fils de soie pour garnir le coussin. | She arranged the silk threads in tufts to trim the cushion. |
| 5806 | envoiler | s'est envoilé | L'acier s'est envoilé pendant la trempe. | The steel warped during hardening. |
| 5818 | vacuoliser | vacuoliser | Sous le microscope, on voit le cytoplasme se vacuoliser peu à peu. | Under the microscope, you can see the cytoplasm gradually vacuolize. |
| 5823 | calter | ont calté | Les cambrioleurs ont calté dès qu'ils ont entendu la sirène. | The burglars bolted as soon as they heard the siren. |
| 5844 | empatter | empattent | Pour éviter l'effondrement, les maçons empattent le vieux mur de la ferme. | To prevent a collapse, the masons are buttressing the old wall of the farm. |
| 5846 | ablater | ablate | Le vent chargé de sable ablate lentement la surface du rocher. | The sand-laden wind slowly ablates the surface of the rock. |
| 5847 | cacaber | cacabe | Au loin, une perdrix cacabe dans les blés. | In the distance, a partridge calls out in the wheat. |
| 5848 | déprolétariser | déprolétariser | Cette politique cherche à déprolétariser les quartiers ouvriers. | This policy aims to deproletarize the working-class neighborhoods. |
| 5849 | écacher | écache | Le forgeron écache le fer rouge sous le marteau. | The blacksmith flattens the red-hot iron under the hammer. |
| 5850 | émotter | émotte | Le paysan émotte son champ avec une herse avant de semer. | The farmer breaks up the clods in his field with a harrow before sowing. |
| 5851 | nitrifier | nitrifient | Certaines bactéries du sol nitrifient l'ammoniac en nitrates. | Some soil bacteria nitrify ammonia into nitrates. |
| 5852 | périphraser | périphrasait | Il périphrasait sans cesse pour éviter de dire la vérité. | He kept using roundabout phrasing to avoid telling the truth. |
| 5854 | tenonner | tenonne | Le menuisier tenonne les deux extrémités de la traverse. | The carpenter puts tenons on both ends of the crosspiece. |
| 5855 | lock-outer | a lock-outé | La direction a lock-outé tous les ouvriers après trois semaines de grève. | Management locked out all the workers after three weeks of strikes. |
| 5858 | désassortir | a désassorti | En remplaçant un seul fauteuil, il a désassorti tout le salon. | By replacing just one armchair, he spoiled the match of the whole living room set. |
| 5860 | déstaliniser | déstaliniser | Khrouchtchev a voulu déstaliniser l'Union soviétique à partir de 1956. | Khrushchev set out to destalinize the Soviet Union from 1956 on. |
| 5863 | adjectiver | adjectivent | Le français adjective volontiers les participes passés. | French readily adjectivizes past participles. |
| 5864 | biologiser | biologisent | Certains auteurs biologisent les comportements sociaux au lieu de les expliquer par l'histoire. | Some authors analyze social behavior from a strictly biological point of view instead of explaining it through history. |
| 5866 | écuisser | a écuissé | Le bûcheron a mal abattu le chêne et l'a écuissé en le faisant tomber. | The woodcutter felled the oak badly and splintered its trunk as it fell. |
| 5868 | volleyer | volleye | Au filet, il volleye la balle de coup droit. | At the net, he volleys the ball with a forehand. |
| 5869 | autorépliquer | s'autoréplique | Le virus informatique s'autoréplique sur chaque machine du réseau. | The computer virus replicates itself on every machine on the network. |
| 5870 | entredétruire | se sont entredétruites | Les deux factions rivales se sont entredétruites en quelques années. | The two rival factions destroyed each other within a few years. |
| 5871 | vermiller | vermille | Le sanglier vermille dans la terre humide sous les chênes. | The wild boar digs around in the damp ground beneath the oaks for worms. |
| 5873 | côcher | côche | Le coq côche la poule dans la basse-cour. | The rooster mates with the hen in the farmyard. |
| 5874 | toronner | toronne | Elle toronne le chanvre pour fabriquer une corde solide. | She twists the hemp into strands to make a strong rope. |
| 5875 | aciérer | acièrent | Les forgerons acièrent le fer pour en faire des lames solides. | The smiths convert the iron into steel to make strong blades. |
| 5876 | chartériser | a chartérisé | La compagnie a chartérisé un avion pour emmener les supporters. | The company chartered a plane to take the fans. |
| 5891 | dévitrifier | dévitrifier | Une chaleur prolongée peut dévitrifier le verre et le rendre opaque. | Prolonged heat can devitrify glass and make it opaque. |
| 5895 | jabler | jable | Le tonnelier jable les douves pour y loger le fond du tonneau. | The cooper cuts a groove in the staves to seat the head of the barrel. |
| 5900 | rabioter | rabiote | Ce commerçant rabiote toujours quelques centimes sur la monnaie rendue. | That shopkeeper always skims a few cents off the change he gives back. |
| 5907 | passementer | passemente | Elle passemente les rideaux du salon avec un galon doré. | She trims the living room curtains with a gold braid. |
| 5917 | bistourner | a bistourné | Il a bistourné la clé dans la serrure et l'a faussée. | He twisted the key the wrong way in the lock and bent it out of shape. |
| 5928 | sablonner | sablonnent | Les ouvriers sablonnent l'allée pour qu'elle ne soit plus glissante. | The workers cover the path with sand so that it is no longer slippery. |
| 5934 | cocoter | cocote | Ça cocote dans le vestiaire après le match. | It stinks in the locker room after the game. |
| 5935 | cocotter | cocotte | Ouvre la fenêtre, ça cocotte dans cette chambre depuis le match de foot. | Open the window, it's been stinking in this room since the soccer game. |
| 5944 | squeezer | squeezer | Au bridge, il a réussi à squeezer son adversaire au dernier tour. | At bridge, he managed to squeeze his opponent on the last trick. |
| 5953 | désaper | désape | Il désape son petit frère avant de le mettre dans le bain. | He undresses his little brother before putting him in the bath. |
| 5971 | bienvenir | bienvenir | Il sait se faire bienvenir de tous ses nouveaux collègues. | He knows how to make himself welcome to all his new colleagues. |
| 5991 | dépaqueter | dépaquetons | Après le déménagement, nous dépaquetons les cartons un par un. | After the move, we unpack the boxes one by one. |
| 6001 | violoner | violoner | Il passe ses soirées à violoner sans jamais faire de progrès. | He spends his evenings fiddling on the violin without ever making progress. |
| 6005 | terser | tersera | Le vigneron tersera sa vigne en juin, après les deux premiers labours. | The winegrower will give his vineyard its third plowing in June, after the first two. |
| 6011 | énouer | énouent | Les ouvrières énouent le drap de laine avec de petites pincettes avant de le teindre. | The workers pick the knots and debris out of the woolen cloth with small tweezers before dyeing it. |
| 6018 | dégober | dégobent | Les ostréiculteurs dégobent les huîtres dans des bassins d'eau claire avant de les vendre. | The oyster farmers purge the oysters in clean-water basins before selling them. |
| 6019 | vasouiller | vasouillé | Pris de court par la question, le candidat a vasouillé pendant toute sa réponse. | Caught off guard by the question, the candidate floundered through his whole answer. |
| 6020 | respectabiliser | respectabiliser | Ce nouveau titre ne suffira pas à respectabiliser son entreprise aux yeux des banques. | This new title will not be enough to make his company respectable in the eyes of the banks. |
| 6021 | démailloter | démaillote | La puéricultrice démaillote le bébé pour lui donner son bain. | The nursery nurse unswaddles the baby to give him his bath. |
| 6022 | jodler | jodlent | Dans la vallée, les bergers jodlent pour s'appeler d'un versant à l'autre. | In the valley, the shepherds yodel to call to each other from one slope to the other. |
| 6023 | haricoter | a haricoté | Pendant des années, le père Lucas a haricoté sans jamais faire fortune. | For years, old Lucas made petty deals without ever making a fortune. |
| 6024 | moufeter | moufeter | Il a obéi sans moufeter, de peur de contrarier le patron. | He obeyed without a word of protest, for fear of upsetting the boss. |
| 6025 | partouser | partousent | Selon la rumeur, ils partousent chaque week-end dans cette grande villa. | According to the rumor, they have orgies every weekend in that big villa. |
| 6026 | désapprovisionner | désapprovisionner | Le fournisseur a décidé de désapprovisionner les petits magasins du quartier. | The supplier decided to stop supplying the small shops in the neighborhood. |
| 6027 | enfûter | enfûte | Le vigneron enfûte le vin nouveau dès la fin du mois d'octobre. | The winemaker puts the new wine into casks as early as the end of October. |
| 6029 | forlonger | forlongé | Le cheval a forlongé tous ses poursuivants dans la dernière ligne droite. | The horse outdistanced all its pursuers on the final straight. |
| 6030 | décrêper | décrêpe | Le coiffeur lui décrêpe les cheveux avec un lissage à la kératine. | The hairdresser removes the frizz from her hair with a keratin smoothing treatment. |
| 6031 | entreregarder | entreregardent | Les deux enfants s'entreregardent sans oser dire un mot. | The two children look at each other without daring to say a word. |
| 6033 | déharnacher | déharnache | Le charretier déharnache les chevaux à la tombée du soir. | The carter unharnesses the horses at nightfall. |
| 6034 | dessangler | dessangle | Il dessangle son cheval avant de le brosser. | He loosens his horse's girth before brushing it. |
| 6036 | intailler | intaille | Le graveur intaille une émeraude pour en faire un sceau. | The engraver etches an emerald to make it into a seal. |
| 6037 | béqueter | béqueter | Les moineaux viennent béqueter les miettes sur la terrasse. | The sparrows come to peck at the crumbs on the terrace. |
| 6038 | emmouscailler | emmouscailler | Arrête de m'emmouscailler avec tes questions, je suis occupé ! | Stop bothering me with your questions, I am busy! |
| 6040 | déclaveter | déclaveter | Il faut déclaveter l'essieu avant de pouvoir retirer la roue. | You have to remove the key from the axle before you can take off the wheel. |
| 6043 | surcomprimer | a surcomprimé | Pour gagner en puissance, le préparateur a surcomprimé le moteur de la moto. | To gain power, the tuner raised the compression ratio of the motorcycle's engine. |
| 6044 | aicher | aiche | Le pêcheur aiche son hameçon avec un ver de terre. | The fisherman baits his hook with an earthworm. |
| 6045 | enlier | enlie | Le maçon enlie soigneusement les pierres en élevant le mur. | The mason carefully interlocks the stones as he raises the wall. |
| 6046 | entabler | entable | Le cheval s'entable quand le cavalier tire trop fort sur les rênes. | The horse gets its hips ahead of its shoulders when the rider pulls too hard on the reins. |
| 6047 | envider | envide | Elle envide le fil sur une bobine avant de commencer à tisser. | She winds the thread onto a spool before starting to weave. |
| 6048 | schlitter | schlittaient | Autrefois, les bûcherons schlittaient les troncs jusqu'à la vallée. | In the past, the lumberjacks used to sled the logs down to the valley. |
| 6049 | acétifier | acétifient | Des bactéries acétifient le vin et le transforment peu à peu en vinaigre. | Bacteria acetify the wine and gradually turn it into vinegar. |
| 6050 | bégueter | bégueter | J'entends une chèvre bégueter derrière la grange. | I hear a goat bleating behind the barn. |
| 6051 | délignifier | délignifier | Cette usine doit délignifier la pâte à papier avant de la blanchir. | This mill has to delignify the paper pulp before bleaching it. |
| 6078 | déchlorurer | déchlorurer | Le chimiste doit déchlorurer la solution avant de l'analyser. | The chemist has to remove the chlorides from the solution before analyzing it. |
| 6086 | entremanger | s'entremangent | Les poissons affamés s'entremangent dans le bassin. | The starving fish eat one another in the pond. |
| 6092 | remastiquer | remastiqua | Le gamin avait posé son chewing-gum sur la table ; il le reprit et le remastiqua. | The kid had set his chewing gum down on the table; he picked it up and chewed it again. |
| 6113 | enfleurer | enfleurer | Le parfumeur va enfleurer cette graisse avec des pétales de jasmin. | The perfumer is going to scent this fat with jasmine petals. |
| 6124 | rentrayer | rentrayait | Dans l'atelier de restauration, la tapissière rentrayait avec patience les trous de la vieille tenture, fil après fil. | In the restoration workshop, the tapestry worker patiently reweaved the holes in the old hanging, thread by thread. |
| 6125 | sarmenter | sarmenter | Après la taille, toute la famille vient sarmenter dans les vignes. | After pruning, the whole family comes to collect the cut vine shoots in the vineyard. |
| 6158 | toussailler | toussaille | Le vieil homme toussaille dans son fauteuil depuis ce matin. | The old man has been coughing on and off in his armchair since this morning. |
| 6184 | désengrener | désengrener | Il faut désengrener le pignon avant de démonter la boîte de vitesses. | You have to throw the pinion out of gear before taking the gearbox apart. |
| 6194 | gabarier | gabarie | L'ouvrier gabarie la pièce métallique avant de l'assembler. | The worker checks the metal part against a template before assembling it. |
| 6197 | insculpter | insculpte | L'orfèvre insculpte son poinçon sur chaque pièce d'argenterie. | The silversmith stamps his hallmark on every piece of silverware. |
| 6204 | rappareiller | rappareiller | Je cherche à rappareiller cette assiette avec les autres du service. | I am trying to match this plate with the others from the set. |
| 6238 | duplexer | duplexer | Les techniciens vont duplexer les deux salles de conférence par une liaison vidéo. | The technicians are going to link up the two conference rooms with a video connection. |
| 6241 | bêcheveter | bêcheveter | Il faut bêcheveter les sardines dans la boîte pour gagner de la place. | You have to place the sardines head-to-tail in the tin to save space. |
| 6243 | congréer | congréer | Le gabier va congréer le cordage pour combler les vides entre les torons. | The sailor is going to worm the rope to fill the gaps between the strands. |
| 6263 | désalper | désalpent | Chaque automne, les vaches désalpent au son des cloches. | Every autumn, the cows come down from the high pastures to the sound of bells. |
| 6270 | ébiseler | ébiseler | L'artisan va ébiseler le bord de ce miroir pour lui donner du cachet. | The craftsman is going to bevel the edge of this mirror to give it character. |
| 6280 | époutir | époutir | On doit époutir cette étoffe de laine avant de la teindre. | This wool cloth has to have its specks picked out before it is dyed. |
| 6285 | hannetonner | hannetonner | Autrefois, les paysans allaient hannetonner chaque printemps. | In the old days, farmers would go and exterminate June bugs every spring. |
| 6308 | recouponner | recouponner | La banque doit recouponner ces titres dont tous les coupons ont été détachés. | The bank has to reissue coupons for these securities, all of whose coupons have been detached. |
| 6311 | rengrener | rengrène | Après le réglage, le mécanicien rengrène les pignons pour que les dents s'emboîtent bien. | After the adjustment, the mechanic re-engages the pinions so the teeth mesh properly. |
| 6321 | tauder | taudent | Dès que le soleil tape, les matelots taudent pour abriter tout l'équipage. | As soon as the sun beats down, the sailors rig the awning to shelter the whole crew. |

<!-- verb-pass-stage5:end -->
