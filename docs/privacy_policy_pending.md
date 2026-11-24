# Privacy-Policy Lines Waiting for a Release

[`privacy_policy2.txt`](privacy_policy2.txt) describes what the **shipped** app sends, in English
and then French, and Josh may deploy it at any time. A signal or parameter built on `main` gets its
line in the deployed policy on the day the release that sends it ships, not before. Until then the
line waits here. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md), adapted
from Konjugieren's file of the same name.

**On release day:** splice every section below into both languages of `privacy_policy2.txt`,
update its effective date in both ("Effective Date" and "Date d'entrée en vigueur"), deploy it, and
empty this file back down to this introduction. Add new bullets in the order given, after the last
bullet of section 2's list (the one about certain in-app actions and Game Center sign-in), unless a
section says otherwise. Check that the paragraph after that list, and section 5's "Quiz answers or
any text you type", are still true. `privacyPolicy4.md` at the repository root also lists the
analytics; [`release.md`](release.md) says what to do with it.

**When adding a signal or parameter on `main`:** add its lines here in English and French, in the
policy's plain register, naming the bands rather than the code's parameter keys. Name the plan and
phase that added it, and the date. Never stage a line for a signal that would carry a verb or any
typed text: the policy says the app does not send the verbs you look up or any text you type, and
that must stay true.

## Lookup signals (browse plan, Phase 3, 2026-11-22)

Adds `source` to the verb page's `viewAppeared`, and the signals `leaveVerbView` and
`finishSearch`. None names a verb or carries what was typed: every value comes from a fixed list
or a band. See [`feature_architecture.md`](feature_architecture.md#analytics) for the vocabulary.
Later phases that send new `source` values (a related verb, Spotlight, My Verbs, and so on) are
covered by the first bullet's "for example" unless they add a kind of surface it does not suggest.
Phase 5 (2026-11-22) added the match kinds for conjugations, and the third bullet's examples now
name them ("a conjugation"). Phase 7 (2026-11-22) began sending `related`, a verb opened from
another verb's Related Verbs card, and the first bullet's examples now name "another verb's page".

### English

New bullets for the list in section 2, after the bullet about certain in-app actions:

```
- How you reached a verb's page: for example from a search, the verb list, a model's page, another verb's page, an info article, a widget, Control Center, or a shortcut
- How far down a verb's page you scrolled (its top, the simple tenses, the compound tenses, the etymology, or the example sentences), and roughly how long the page was open (under 5 seconds, 5 to 15 seconds, 15 to 60 seconds, or longer)
- When a search for a verb ends: whether you opened a verb, the kind of match that found it (for example the infinitive, a conjugation, a spelling without accents, or an English meaning), and rough counts: the length of what you typed (1 to 2 letters, 3 to 5, 6 to 9, or 10 or more), how many verbs matched (none, 1, 2 to 10, or more), and where the verb you opened stood in the list (first, second to fifth, or lower)
```

The paragraph after the list now reads:

```
Your quiz score and elapsed time are collected, but, like all of these analytics, they are anonymized and are not tied to your identity (see Section 4). That you searched for a verb is recorded, with the rough counts above; what you typed is not. That you opened a verb's page is recorded; which verb is not. The app does not record your quiz answers, the verbs you look up, or any text you type.
```

### French

Nouveaux points pour la liste de la section 2, après le point sur certaines actions dans
l'application :

```
- La façon dont vous avez atteint la page d'un verbe : par exemple depuis une recherche, la liste des verbes, la page d'un modèle, la page d'un autre verbe, un article d'information, un widget, le Centre de contrôle ou un raccourci
- Jusqu'où vous avez fait défiler la page d'un verbe (son début, les temps simples, les temps composés, l'étymologie ou les exemples) et, approximativement, combien de temps la page est restée ouverte (moins de 5 secondes, de 5 à 15 secondes, de 15 à 60 secondes, ou davantage)
- À la fin d'une recherche de verbe : si vous avez ouvert un verbe, le type de correspondance qui l'a trouvé (par exemple l'infinitif, une forme conjuguée, une orthographe sans accents ou un sens anglais) et des ordres de grandeur : la longueur de votre saisie (1 à 2 lettres, 3 à 5, 6 à 9, ou 10 et plus), le nombre de verbes trouvés (aucun, 1, de 2 à 10, ou davantage) et la place du verbe ouvert dans la liste (premier, du deuxième au cinquième, ou plus loin)
```

Le paragraphe qui suit la liste devient :

```
Votre score au quiz et le temps écoulé sont collectés, mais, comme toutes ces statistiques, ils sont anonymisés et ne sont pas liés à votre identité (voir la section 4). Le fait que vous ayez cherché un verbe est enregistré, avec les ordres de grandeur ci-dessus ; ce que vous avez saisi ne l'est pas. Le fait que vous ayez ouvert la page d'un verbe est enregistré ; le verbe lui-même ne l'est pas. L'application n'enregistre pas vos réponses au quiz, les verbes que vous consultez, ni aucun texte que vous saisissez.
```

## Tense articles (browse plan, Phase 6, 2026-11-22)

Adds the signal `tapTenseArticle`, with no parameters: a tap on the button beside a tense's name on
a verb page, which opens that tense's article. It names neither the verb nor the tense. The
existing bullet about certain in-app actions covers it once its examples name it, so this section
changes that bullet rather than adding one.

### English

The bullet about certain in-app actions now reads:

```
- Certain in-app actions, such as opening the game, reshowing the onboarding, or opening a tense's article from a verb's page, and whether Game Center sign-in succeeded
```

### French

Le point sur certaines actions dans l'application devient :

```
- Certaines actions dans l'application, comme l'ouverture du jeu, le réaffichage de l'introduction ou l'ouverture de l'article d'un temps depuis la page d'un verbe, ainsi que la réussite ou l'échec de la connexion à Game Center
```

## Sharing a verb (browse plan, Phase 8, 2026-11-22)

Adds the signal `tapShareVerb`, with no parameters: a tap on the share button of a verb's page. It
does not name the verb, and it does not say whether anything was shared or where. Copying sends
nothing. Like Phase 6's signal, it changes the bullet about certain in-app actions rather than
adding one. If the Phase 6 section above has been applied, apply this one after it, since it
replaces the same bullet.

### English

The bullet about certain in-app actions now reads:

```
- Certain in-app actions, such as opening the game, reshowing the onboarding, opening a tense's article from a verb's page, or tapping the button that shares a verb's page, and whether Game Center sign-in succeeded
```

### French

Le point sur certaines actions dans l'application devient :

```
- Certaines actions dans l'application, comme l'ouverture du jeu, le réaffichage de l'introduction, l'ouverture de l'article d'un temps depuis la page d'un verbe ou un appui sur le bouton de partage de la page d'un verbe, ainsi que la réussite ou l'échec de la connexion à Game Center
```

## Lookup from outside the app (browse plan, Phase 9, 2026-11-22)

Adds `source` to `finishSearch`: where a verb search began, from a fixed list (the Verbs tab, the
Find a Verb control, the Home Screen quick action, the Look Up a Verb shortcut, or a link). It
also begins sending three `source` values on the verb page: `spotlight`, `lookup`, and
`quickAction` (the last for searches only). The first bullet's examples now name Spotlight, since
it is a kind of surface the list did not suggest, and the third bullet now names where the search
began. Neither names a verb or carries the word looked up. Apply this section after the Phase 3
section above, since it replaces two of that section's bullets.

### English

The first bullet now reads:

```
- How you reached a verb's page: for example from a search, the verb list, a model's page, another verb's page, an info article, a widget, Control Center, a shortcut, or Spotlight
```

The third bullet now reads:

```
- When a search for a verb ends: where it began (the verb list, Control Center, a Home Screen quick action, a shortcut, or a link), whether you opened a verb, the kind of match that found it (for example the infinitive, a conjugation, a spelling without accents, or an English meaning), and rough counts: the length of what you typed (1 to 2 letters, 3 to 5, 6 to 9, or 10 or more), how many verbs matched (none, 1, 2 to 10, or more), and where the verb you opened stood in the list (first, second to fifth, or lower)
```

### French

Le premier point devient :

```
- La façon dont vous avez atteint la page d'un verbe : par exemple depuis une recherche, la liste des verbes, la page d'un modèle, la page d'un autre verbe, un article d'information, un widget, le Centre de contrôle, un raccourci ou Spotlight
```

Le troisième point devient :

```
- À la fin d'une recherche de verbe : son point de départ (la liste des verbes, le Centre de contrôle, une action rapide de l'écran d'accueil, un raccourci ou un lien), si vous avez ouvert un verbe, le type de correspondance qui l'a trouvé (par exemple l'infinitif, une forme conjuguée, une orthographe sans accents ou un sens anglais) et des ordres de grandeur : la longueur de votre saisie (1 à 2 lettres, 3 à 5, 6 à 9, ou 10 et plus), le nombre de verbes trouvés (aucun, 1, de 2 à 10, ou davantage) et la place du verbe ouvert dans la liste (premier, du deuxième au cinquième, ou plus loin)
```

## My Verbs (browse plan, Phase 10, 2026-11-22)

Adds the signal `tapStarVerb`, with a `starred` parameter saying whether the tap starred the verb
or removed its star. It does not name the verb. Phase 10 also began sending the `recent` and
`myVerbs` sources for verb pages, which the first bullet of the Phase 3 section covers with "for
example". The app now keeps on the device a list of the verbs opened and starred, so the paragraph
after the list says "send" where it said "record", which the local list would otherwise make
untrue, and a new paragraph says the list stays on the device. Apply this section after the Phase
3, 6, and 8 sections above, since it replaces the bullet and the paragraph they give. Section 5's
"Quiz answers or any text you type" stays true.

### English

The bullet about certain in-app actions now reads:

```
- Certain in-app actions, such as opening the game, reshowing the onboarding, opening a tense's article from a verb's page, tapping the button that shares a verb's page, or starring a verb or removing its star, and whether Game Center sign-in succeeded
```

The last sentence of the paragraph after the list now reads:

```
The app does not send your quiz answers, the verbs you look up, or any text you type.
```

A new paragraph follows that paragraph:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, so that it can show your recent verbs and My Verbs. The list stays on your device and is never sent.
```

### French

Le point sur certaines actions dans l'application devient :

```
- Certaines actions dans l'application, comme l'ouverture du jeu, le réaffichage de l'introduction, l'ouverture de l'article d'un temps depuis la page d'un verbe, un appui sur le bouton de partage de la page d'un verbe, ou l'ajout ou le retrait de l'étoile d'un verbe, ainsi que la réussite ou l'échec de la connexion à Game Center
```

La dernière phrase du paragraphe qui suit la liste devient :

```
L'application n'envoie pas vos réponses au quiz, les verbes que vous consultez, ni aucun texte que vous saisissez.
```

Un nouveau paragraphe suit ce paragraphe :

```
L'application conserve une liste des verbes que vous avez ouverts et des verbes que vous avez marqués d'une étoile, afin d'afficher vos verbes récents et « Mes verbes ». Cette liste reste sur votre appareil et n'est jamais envoyée.
```

## A quiz over chosen verbs (browse plan, Phase 11, 2026-11-22)

Adds `source` to `quizStart`, `quizQuit`, and `quizCompletion`: where the quiz began, from a fixed
list (the Quiz tab over every verb, the Quiz tab over My Verbs, or Test Me on a verb's page). It
does not name the verbs a quiz asks about, not even for Test Me, whose quiz is about one verb. The
bullet on quiz lifecycle events says so, so this section changes that bullet rather than adding
one. It is an existing bullet, unlike the ones the sections above add. Only the default quiz posts
to Game Center now, which section 6's "When you submit a score" already allows.

### English

The bullet on quiz lifecycle events (the second of section 2's list) now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb or over My Verbs, or a verb's page
```

### French

Le point sur les événements du cycle de vie d'un quiz (le deuxième de la liste de la section 2)
devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes ou sur « Mes verbes », ou la page d'un verbe
```

## The review card (browse plan, Phase 13, 2026-11-22)

Adds the signals `viewReviewCard`, sent when the review card above the verb list appears, and
`tapRevealReviewCard`, sent when a tap reveals its conjugations. Neither has parameters, and
neither names the verb. Phase 13 also began sending the `reviewCard` source for verb pages, which
the first bullet of the Phase 3 section covers with "for example". The list kept on the device now
also holds when each verb is due for review. Apply this section after the Phase 10 section, since
it replaces the bullet about certain in-app actions and the paragraph about the list that Phase 10
gives. The Suppress Review Card setting sends nothing.

### English

The bullet about certain in-app actions now reads:

```
- Certain in-app actions, such as opening the game, reshowing the onboarding, opening a tense's article from a verb's page, tapping the button that shares a verb's page, starring a verb or removing its star, or revealing the conjugations on a review card, and whether Game Center sign-in succeeded
```

A new bullet follows it:

```
- That a review card, which offers a verb you looked up some days earlier, was shown
```

The paragraph about the list kept on the device now reads:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, with when each is next due for review, so that it can show your recent verbs, My Verbs, and review cards. The list stays on your device and is never sent.
```

### French

Le point sur certaines actions dans l'application devient :

```
- Certaines actions dans l'application, comme l'ouverture du jeu, le réaffichage de l'introduction, l'ouverture de l'article d'un temps depuis la page d'un verbe, un appui sur le bouton de partage de la page d'un verbe, l'ajout ou le retrait de l'étoile d'un verbe, ou l'affichage des conjugaisons d'une carte de révision, ainsi que la réussite ou l'échec de la connexion à Game Center
```

Un nouveau point le suit :

```
- L'affichage d'une carte de révision, qui vous propose un verbe consulté quelques jours plus tôt
```

Le paragraphe sur la liste conservée sur l'appareil devient :

```
L'application conserve une liste des verbes que vous avez ouverts et des verbes que vous avez marqués d'une étoile, avec la date à laquelle chacun doit être révisé, afin d'afficher vos verbes récents, « Mes verbes » et les cartes de révision. Cette liste reste sur votre appareil et n'est jamais envoyée.
```

## Collections (browse plan, Phase 14, 2026-11-22)

Adds the signals `viewCollection`, sent when the page of one of the four featured collections opens
(the 100 most frequent verbs, verbs taking être, irregular futur stems, pronominal verbs), and
`tapShareCollection`, sent when a collection's share button is tapped. Both carry `collection`,
which names one of the four, or says only `model` for a model's collection, never which model,
since some models hold a single verb. `viewCollection` also carries `source`: the Models tab, a
shared link, or another link. `quizStart` gains `collection` for a collection's quiz, and the quiz
signals and verb pages begin sending the `list` source, which the quiz bullet and the first bullet
of the Phase 3 section must name or cover. The progress a collection shows is counted on the device
from the list Phase 10 keeps, so the paragraph about that list gains a mention of it. Apply this
section after the Phase 11 and 13 sections, since it replaces the quiz bullet and the paragraph
about the list that they give.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb or over My Verbs, a verb's page, or a collection, with which collection for the four featured ones (a model's collection is named only as a model)
```

A new bullet follows the bullet about the review card:

```
- That you opened one of the featured collections of verbs (the 100 most frequent verbs, verbs taking être, irregular futur stems, or pronominal verbs), which one, and whether you reached it from the Models tab or a link; and that you tapped a collection's share button, with which collection (a model's collection is named only as a model)
```

The paragraph about the list kept on the device now reads:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, with when each is next due for review, so that it can show your recent verbs, My Verbs, review cards, and how many verbs of each collection you have looked up. The list stays on your device and is never sent.
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes ou sur « Mes verbes », la page d'un verbe ou une collection, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle est désignée seulement comme celle d'un modèle)
```

Un nouveau point suit le point sur la carte de révision :

```
- L'ouverture de l'une des collections de verbes mises en avant (les 100 verbes les plus fréquents, les verbes conjugués avec être, les radicaux du futur irréguliers ou les verbes pronominaux), laquelle, et si vous l'avez atteinte depuis l'onglet Modèles ou par un lien ; ainsi qu'un appui sur le bouton de partage d'une collection, avec le nom de la collection (la collection d'un modèle est désignée seulement comme celle d'un modèle)
```

Le paragraphe sur la liste conservée sur l'appareil devient :

```
L'application conserve une liste des verbes que vous avez ouverts et des verbes que vous avez marqués d'une étoile, avec la date à laquelle chacun doit être révisé, afin d'afficher vos verbes récents, « Mes verbes », les cartes de révision et le nombre de verbes de chaque collection que vous avez consultés. Cette liste reste sur votre appareil et n'est jamais envoyée.
```

## Screens the browse plan added (browse plan, Closing, 2026-11-22)

Found by the Closing's audit. Two screens added by the plan report themselves through the existing
`viewAppeared` signal, with their type names as `viewName`: `RelatedVerbListView`, a verb page's
full list of related verbs (Phase 7), and `VerbCollectionView`, a featured collection's page
(Phase 14). Neither names a verb, a model, or a collection; the collection is named only by the
Phase 14 section's `viewCollection`. The existing bullet on screens lists the kinds of screen, so
this section changes it rather than adding one. A model's page, collection bar and all, is still
`ModelView`, which "verb models" covers.

### English

The bullet on screens (the first of section 2's list) now reads:

```
- Which screens you visit (verbs, lists of related verbs, verb models, collections of verbs, quiz, info articles, settings, and the tutor)
```

### French

Le point sur les écrans (le premier de la liste de la section 2) devient :

```
- Les écrans que vous consultez (verbes, listes de verbes apparentés, modèles de verbes, collections de verbes, quiz, articles d'information, paramètres et le tuteur)
```

## A quiz's correction (pedagogy plan, Phase 3, 2026-11-23)

The quiz now holds a wrong answer's correction on its question, with links to the verb's page and
its model's page. A verb page opened from that link sends a new `source` value on `viewAppeared`,
`quizCorrection`. It names neither the verb nor the answer. A quiz's correction is a kind of
surface the first bullet's examples did not suggest, so they now name it. The model's page reports
itself as `ModelView`, as before. Apply this section after the Phase 9 section, since it replaces
that section's first bullet.

### English

The first bullet now reads:

```
- How you reached a verb's page: for example from a search, the verb list, a model's page, another verb's page, a quiz's correction, an info article, a widget, Control Center, a shortcut, or Spotlight
```

### French

Le premier point devient :

```
- La façon dont vous avez atteint la page d'un verbe : par exemple depuis une recherche, la liste des verbes, la page d'un modèle, la page d'un autre verbe, la correction d'une réponse au quiz, un article d'information, un widget, le Centre de contrôle, un raccourci ou Spotlight
```

## Quiz levels (pedagogy plan, Phase 5, 2026-11-23)

Four levels replace the regular and ridiculous difficulties. The quiz signals send `level` in place
of `difficulty`, and `quizStart`, which sent no difficulty, now sends it too. The value is one of
four from a fixed list. This section changes the existing bullet on the difficulty, the third of
section 2's list, rather than adding one.

### English

The bullet on the quiz difficulty now reads:

```
- Quiz level (beginner, elementary, intermediate, or advanced) when you start, quit, or complete a quiz
```

### French

Le point sur le niveau de difficulté du quiz devient :

```
- Le niveau du quiz (débutant, élémentaire, intermédiaire ou avancé) lorsque vous commencez, abandonnez ou terminez un quiz
```

## Ten questions, then ten more (pedagogy plan, Phase 7, 2026-11-23)

The quiz is now ten questions, which the results offer to continue by ten more, and a missed
question is asked again. `quizCompletion` stops sending the score, so no signal carries a score
or a count of right or wrong answers. The elapsed time on `quizQuit` and `quizCompletion` becomes
`duration`, a band of the time from the quiz's start. `quizCompletion`, sent at each round's
results, gains `questionCount`, the questions so far (10, 20, and so on). The new `quizAbandon`,
sent at the next launch, reports a quiz the app was left during, with its level, its source, and
the question reached. The question reached never counts a question asked again, which would tell
how many answers were wrong. Only a quiz's first ten questions post to Game Center, which section
6's "When you submit a score" already allows.

This section changes two existing bullets of section 2's list, the fourth and fifth (the question
reached, and the score and elapsed time), and the first sentence of the paragraph after the list,
in the version that the lookup signals section above gives it. On release day, also check
`privacyPolicy4.md`, whose list names "Finishing a quiz, with score" and whose example says that
Conjuguer's quizzes have thirty verbs; [`release.md`](release.md) says which policy to bring up to
date.

### English

The bullet on progress in a quiz now reads:

```
- How far you progressed in a quiz if you quit early or leave the app during it (the question number reached, reported the next time you open the app)
```

The bullet on the quiz score and elapsed time now reads:

```
- Roughly how long a quiz lasted when you complete or quit it (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer), and how many questions it had reached when you complete it (10, or 20 or more if you asked for ten more)
```

The first sentence of the paragraph after the list now reads:

```
How long a quiz lasted is collected in rough bands, but, like all of these analytics, it is anonymized and is not tied to your identity (see Section 4). Your quiz score is not collected.
```

### French

Le point sur la progression dans un quiz devient :

```
- Votre progression dans un quiz si vous l'abandonnez prématurément ou quittez l'application pendant celui-ci (le numéro de la question atteinte, transmis à la prochaine ouverture de l'application)
```

Le point sur le score au quiz et le temps écoulé devient :

```
- La durée approximative d'un quiz lorsque vous le terminez ou l'abandonnez (moins de 3 secondes, de 3 à 15 secondes, de 15 à 40 secondes, de 40 secondes à 2 minutes, ou davantage) et le nombre de questions atteint lorsque vous le terminez (10, ou 20 et plus si vous avez demandé dix questions de plus)
```

La première phrase du paragraphe qui suit la liste devient :

```
La durée d'un quiz est collectée par ordres de grandeur, mais, comme toutes ces statistiques, elle est anonymisée et n'est pas liée à votre identité (voir la section 4). Votre score au quiz n'est pas collecté.
```

## A custom quiz (pedagogy plan, Phase 9, 2026-11-23)

The Quiz tab gains a custom quiz over tenses, verbs, or both that the learner chooses. The quiz
signals send a new `source` value, `custom`, and `quizStart` gains `customChoice`, which says only
whether tenses, verbs, or both were chosen, never which. A custom quiz over a featured collection
or a model sends `collection` as a collection's own quiz does, a model's named only as a model. A
custom quiz posts nothing to Game Center. This section replaces the quiz bullet that the Collections
section above gives, so apply it after that one. The choice is kept on the device, in the app's
settings, and is never sent.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, or over a custom choice, a verb's page, or a collection, with which collection for the four featured ones (a model's collection is named only as a model); for a custom quiz, whether you chose tenses, verbs, or both, but not which
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes » ou sur mesure, la page d'un verbe ou une collection, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle est désignée seulement comme celle d'un modèle) ; pour un quiz sur mesure, si vous avez choisi des temps, des verbes ou les deux, mais pas lesquels
```

## Practice sets (pedagogy plan, Phase 10, 2026-11-23)

A custom quiz can be shared as a practice set, through a `conjuguer://` link or a QR code made on
the device. Adds `tapSharePracticeSet` (`method`, `link` or `qrCode`, and `customChoice`),
`viewPracticeSet` (`source`, and `outcome`, `opened` or `invalid`), and `tapKeepPracticeSet`, and
the `source` value `qrCode` (with `sharedLink` and `deeplink`) on the quiz signals of a practice
set's quiz. None names a tense or a verb. The link itself carries the set's tenses and verbs from
one device to another, but it travels only where the learner sends it, never to the developer. This
section replaces the quiz bullet that the custom quiz's section above gives, so apply it after that
one.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, or over a custom choice, a verb's page, a collection, or a practice set opened from a shared link or a QR code, with which collection for the four featured ones (a model's collection is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

New bullets for the list in section 2, after that one:

```
- When you share your custom quiz as a practice set: whether as a link or as a QR code, and whether it chose tenses, verbs, or both, but not which
- When you open a practice set: whether it came from a shared link or a QR code, and whether the app could read it
- When you keep a practice set as your custom quiz
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes » ou sur mesure, la page d'un verbe, une collection ou une série d'exercices ouverte depuis un lien partagé ou un code QR, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle est désignée seulement comme celle d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Nouveaux points pour la liste de la section 2, après celui-ci :

```
- Le partage de votre quiz sur mesure comme série d'exercices : sous forme de lien ou de code QR, et s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
- L'ouverture d'une série d'exercices : si elle vient d'un lien partagé ou d'un code QR, et si l'application a pu la lire
- Le fait de garder une série d'exercices comme votre quiz sur mesure
```

## The practice record (pedagogy plan, Phase 11, 2026-11-23)

The quiz now keeps a practice record on the device: for each conjugation or pattern a quiz answer
or a lookup has touched, how the last answer went and when it is next due for review. Quiz answers
are therefore recorded, on the device, so the policy's "does not record your quiz answers" becomes
"does not send". The record stays on the device and is never sent, and no signal carries an
answer, a count of right or wrong answers, or which verb or conjugation was asked. Adds
`tapResetPractice`, with no parameters, sent when Settings' Reset Practice is confirmed. The review
card's schedules moved from the list of verbs into the practice record, so the paragraph about the
list kept on the device changes too. Apply this section after the review card's section, whose
paragraph it replaces, and after the lookup signals section, whose last sentence it changes. On
release day, check that section 5's "Quiz answers or any text you type", which lists what is not
collected, still reads as what is not sent.

### English

A new bullet for the list in section 2, after the last:

```
- That you reset your practice record in Settings
```

The last sentence of the paragraph after the list, in the version the lookup signals section gives it, now reads:

```
The app does not send your quiz answers, the verbs you look up, or any text you type.
```

The paragraph about the list kept on the device now reads, followed by a new paragraph:

```
The app keeps a list of the verbs you have opened and the verbs you have starred, so that it can show your recent verbs and My Verbs. The list stays on your device and is never sent.

The app also keeps a practice record: for each conjugation your quiz answers and lookups have touched, whether your last answer was right and when it is next due for review, so that quizzes and review cards can bring it back. The practice record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### French

Un nouveau point pour la liste de la section 2, après le dernier :

```
- La réinitialisation de votre suivi des exercices dans les Paramètres
```

La dernière phrase du paragraphe qui suit la liste, dans la version que donne la section sur les signaux de consultation, devient :

```
L'application n'envoie pas vos réponses au quiz, les verbes que vous consultez, ni aucun texte que vous saisissez.
```

Le paragraphe sur la liste conservée sur l'appareil devient, suivi d'un nouveau paragraphe :

```
L'application conserve une liste des verbes que vous avez ouverts et des verbes que vous avez marqués d'une étoile, afin d'afficher vos verbes récents et « Mes verbes ». Cette liste reste sur votre appareil et n'est jamais envoyée.

L'application conserve aussi un suivi des exercices : pour chaque conjugaison que vos réponses aux quiz et vos consultations ont touchée, si votre dernière réponse était juste et le jour où elle doit être révisée, afin que les quiz et les cartes de révision la reproposent. Ce suivi reste sur votre appareil et n'est jamais envoyé. « Réinitialiser le suivi », dans les Paramètres, l'efface.
```

## Review and My Mistakes (pedagogy plan, Phase 12, 2026-11-23)

The Quiz tab gains two sessions drawn from the practice record: Review, of the conjugations due
for review, and Practice My Mistakes, of those whose last answer was wrong. The quiz signals send
two new `source` values, `review` and `mistakes`. **These sessions send no question counts.**
`quizCompletion` omits `questionCount`, and `quizQuit` and `quizAbandon` omit the question reached,
because a session shorter than ten is exactly as long as the learner's due or missed items, so its
length would be a count of wrong answers. Neither session posts to Game Center, which section 6
already allows. This section replaces the quiz bullet that the practice sets section above gives,
so apply it after that one, and it adds a clause to the two bullets the section on ten questions
gives.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, or as practice of your mistakes, a verb's page, a collection, or a practice set opened from a shared link or a QR code, with which collection for the four featured ones (a model's collection is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on progress in a quiz now reads:

```
- How far you progressed in a quiz if you quit early or leave the app during it (the question number reached, reported the next time you open the app), except in a review or in practice of your mistakes, whose length would tell how many answers were wrong
```

The bullet on how long a quiz lasted now reads:

```
- Roughly how long a quiz lasted when you complete or quit it (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer), and how many questions it had reached when you complete it (10, or 20 or more if you asked for ten more), except for a review or practice of your mistakes
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir ou pour revoir vos erreurs, la page d'un verbe, une collection ou une série d'exercices ouverte depuis un lien partagé ou un code QR, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle est désignée seulement comme celle d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la progression dans un quiz devient :

```
- Votre progression dans un quiz si vous l'abandonnez prématurément ou quittez l'application pendant celui-ci (le numéro de la question atteinte, transmis à la prochaine ouverture de l'application), sauf en révision ou pour revoir vos erreurs, dont la longueur révélerait le nombre de réponses fausses
```

Le point sur la durée d'un quiz devient :

```
- La durée approximative d'un quiz lorsque vous le terminez ou l'abandonnez (moins de 3 secondes, de 3 à 15 secondes, de 15 à 40 secondes, de 40 secondes à 2 minutes, ou davantage) et le nombre de questions atteint lorsque vous le terminez (10, ou 20 et plus si vous avez demandé dix questions de plus), sauf en révision ou pour revoir vos erreurs
```

## The practice hub (pedagogy plan, Phase 13, 2026-11-23)

The Quiz tab keeps the last quiz's results on the device, to show them: what was quizzed, the
level, the counts of right answers and second tries, the score, and the date. They are kept beside
the practice record, never sent, and erased by Reset Practice, so the practice-record paragraph
that the section on the practice record gives now names them. The leaderboard moves from the
closing of a quiz's results to a View Leaderboard button on the Quiz tab, which sends the new
`tapViewLeaderboard` with `source` `tab` and nothing else. Apply this section after the section on
the practice record.

### English

A new bullet for the list in section 2, after the last:

```
- That you opened a quiz leaderboard from the Quiz tab
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: for each conjugation your quiz answers and lookups have touched, whether your last answer was right and when it is next due for review, so that quizzes and review cards can bring it back, and the results of your last quiz, so that the Quiz tab can show them. The practice record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### French

Un nouveau point pour la liste de la section 2, après le dernier :

```
- L'ouverture d'un classement du quiz depuis l'onglet Quiz
```

Le paragraphe sur le suivi des exercices devient :

```
L'application conserve aussi un suivi des exercices : pour chaque conjugaison que vos réponses aux quiz et vos consultations ont touchée, si votre dernière réponse était juste et le jour où elle doit être révisée, afin que les quiz et les cartes de révision la reproposent, ainsi que le résultat de votre dernier quiz, afin que l'onglet Quiz puisse l'afficher. Ce suivi reste sur votre appareil et n'est jamais envoyé. « Réinitialiser le suivi », dans les Paramètres, l'efface.
```

## Verb Essentials (pedagogy plan, Phase 15, 2026-11-23)

The Quiz tab gains Verb Essentials, an exercise that asks three conjugations of each of five
irregular verbs. The quiz signals send a new `source` value, `verbEssentials`. Its rounds are
fifteen questions, and `quizCompletion` sends their count as other quizzes do, since a round's
length depends on no answer. It posts no score to Game Center, which section 6 already allows.
This section replaces the quiz bullets that the section on Review and My Mistakes gives, so apply
it after that one.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, as practice of your mistakes, or as the Verb Essentials exercise, a verb's page, a collection, or a practice set opened from a shared link or a QR code, with which collection for the four featured ones (a model's collection is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on how long a quiz lasted now reads:

```
- Roughly how long a quiz lasted when you complete or quit it (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer), and how many questions it had reached when you complete it (10, or 20 or more if you asked for ten more; 15 a round in Verb Essentials), except for a review or practice of your mistakes
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir, pour revoir vos erreurs ou dans l'exercice « L'essentiel du verbe », la page d'un verbe, une collection ou une série d'exercices ouverte depuis un lien partagé ou un code QR, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle est désignée seulement comme celle d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la durée d'un quiz devient :

```
- La durée approximative d'un quiz lorsque vous le terminez ou l'abandonnez (moins de 3 secondes, de 3 à 15 secondes, de 15 à 40 secondes, de 40 secondes à 2 minutes, ou davantage) et le nombre de questions atteint lorsque vous le terminez (10, ou 20 et plus si vous avez demandé dix questions de plus ; 15 par série dans « L'essentiel du verbe »), sauf en révision ou pour revoir vos erreurs
```

## Model practice (pedagogy plan, Phase 16, 2026-11-23)

Each conjugation model gains a practice, alone and mixed with the models the learner knows, started
from the model's page or from the Quiz tab's list of models. The quiz signals send two new `source`
values, `modelAlone` and `modelMixed`, and `quizStart` sends the `collection` value `model`, as a
model's own quiz already does, so the model is never named. A round alone sends its question count
as other quizzes do; a mixed round sends none, since its length depends on which models are known,
and that comes from the learner's answers. Nothing is posted to Game Center. Whether a model is
known is computed from the practice record on the device and sent nowhere. This section replaces
the quiz bullets that the section on Verb Essentials gives, so apply it after that one.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, as practice of your mistakes, or as the Verb Essentials exercise, a verb's page, a collection, a practice set opened from a shared link or a QR code, or the practice of a conjugation model, alone or mixed with models you know, with which collection for the four featured ones (a model's collection, or a model's practice, is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on how long a quiz lasted now reads:

```
- Roughly how long a quiz lasted when you complete or quit it (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer), and how many questions it had reached when you complete it (10, or 20 or more if you asked for ten more; 15 a round in Verb Essentials; up to 15 a round in a model's practice alone), except for a review, practice of your mistakes, or a model's mixed practice
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir, pour revoir vos erreurs ou dans l'exercice « L'essentiel du verbe », la page d'un verbe, une collection, une série d'exercices ouverte depuis un lien partagé ou un code QR, ou l'exercice d'un modèle de conjugaison, seul ou mélangé aux modèles que vous connaissez, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle, ou l'exercice d'un modèle, est désigné seulement comme celui d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la durée d'un quiz devient :

```
- La durée approximative d'un quiz lorsque vous le terminez ou l'abandonnez (moins de 3 secondes, de 3 à 15 secondes, de 15 à 40 secondes, de 40 secondes à 2 minutes, ou davantage) et le nombre de questions atteint lorsque vous le terminez (10, ou 20 et plus si vous avez demandé dix questions de plus ; 15 par série dans « L'essentiel du verbe » ; jusqu'à 15 par série dans l'exercice d'un modèle seul), sauf en révision, pour revoir vos erreurs ou dans l'exercice d'un modèle mélangé
```

## Name the Conjugation (pedagogy plan, Phase 17, 2026-11-23)

The Quiz tab gains Name the Conjugation, an exercise that shows a conjugation and asks for its
infinitive, tense, and person. The quiz signals send a new `source` value, `recognition`. Its rounds
are ten questions, and `quizCompletion` sends their count as the default quiz does. Its answers are
recorded nowhere, not even in the practice record on the device, and nothing is posted to Game
Center. This section replaces the quiz bullets that the section on model practice gives, so apply
it after that one.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, as practice of your mistakes, or as the Verb Essentials or Name the Conjugation exercise, a verb's page, a collection, a practice set opened from a shared link or a QR code, or the practice of a conjugation model, alone or mixed with models you know, with which collection for the four featured ones (a model's collection, or a model's practice, is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on how long a quiz lasted is unchanged: Name the Conjugation's rounds are 10 questions,
which it already covers.

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir, pour revoir vos erreurs ou dans l'exercice « L'essentiel du verbe » ou « Identifier la forme verbale », la page d'un verbe, une collection, une série d'exercices ouverte depuis un lien partagé ou un code QR, ou l'exercice d'un modèle de conjugaison, seul ou mélangé aux modèles que vous connaissez, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle, ou l'exercice d'un modèle, est désigné seulement comme celui d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la durée d'un quiz ne change pas : les séries d'« Identifier la forme verbale » comptent
10 questions, ce qu'il couvre déjà.

## Phrases à trous (pedagogy plan, Phase 18, 2026-11-23)

The Quiz tab gains Phrases à trous ("Sentences" in English), an exercise that asks a conjugation
inside a short sentence. The quiz signals send a new `source` value, `sentences`. Its rounds are
ten questions, and `quizCompletion` sends their count as the default quiz does. Its answers go
into the practice record on the device, as the quiz's do, and nothing is posted to Game Center.
The results' Example Use, which opens a verb's example sentence, sends nothing. This section
replaces the quiz lifecycle bullet that the section on Name the Conjugation gives, so apply it
after that one.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, as practice of your mistakes, or as the Verb Essentials, Name the Conjugation, or Sentences exercise, a verb's page, a collection, a practice set opened from a shared link or a QR code, or the practice of a conjugation model, alone or mixed with models you know, with which collection for the four featured ones (a model's collection, or a model's practice, is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on how long a quiz lasted is unchanged: a round of Sentences is at most 10 questions,
which it already covers.

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir, pour revoir vos erreurs ou dans l'exercice « L'essentiel du verbe », « Identifier la forme verbale » ou « Phrases à trous », la page d'un verbe, une collection, une série d'exercices ouverte depuis un lien partagé ou un code QR, ou l'exercice d'un modèle de conjugaison, seul ou mélangé aux modèles que vous connaissez, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle, ou l'exercice d'un modèle, est désigné seulement comme celui d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la durée d'un quiz ne change pas : une série de « Phrases à trous » compte au plus
10 questions, ce qu'il couvre déjà.

## Mastery (pedagogy plan, Phase 20, 2026-11-24)

The Quiz tab gains a Mastery page, which shows from the practice record on the device which forms
and irregular verbs the learner has mastered. The page reports itself through the existing
`viewAppeared` signal with the `viewName` `MasteryView`, and sends nothing about the record or the
level. This section changes the screens bullet that the section on screens the browse plan added
gives, and the practice-record paragraph that the section on the practice hub gives, so apply it
after both.

### English

The bullet on screens now reads:

```
- Which screens you visit (verbs, lists of related verbs, verb models, collections of verbs, quiz, your mastery of conjugations, info articles, settings, and the tutor)
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: for each conjugation your quiz answers and lookups have touched, whether your last answer was right and when it is next due for review, so that quizzes and review cards can bring it back and the Quiz tab can show what you have mastered, and the results of your last quiz, so that the Quiz tab can show them. The practice record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### French

Le point sur les écrans devient :

```
- Les écrans que vous consultez (verbes, listes de verbes apparentés, modèles de verbes, collections de verbes, quiz, votre maîtrise des conjugaisons, articles d'information, paramètres et le tuteur)
```

Le paragraphe sur le suivi des exercices devient :

```
L'application conserve aussi un suivi des exercices : pour chaque conjugaison que vos réponses aux quiz et vos consultations ont touchée, si votre dernière réponse était juste et le jour où elle doit être révisée, afin que les quiz et les cartes de révision la reproposent et que l'onglet Quiz puisse afficher ce que vous maîtrisez, ainsi que le résultat de votre dernier quiz, afin que l'onglet Quiz puisse l'afficher. Ce suivi reste sur votre appareil et n'est jamais envoyé. « Réinitialiser le suivi », dans les Paramètres, l'efface.
```

## Speed Round (pedagogy plan, Phase 21, 2026-11-24)

The Quiz tab gains the Speed Round ("Contre-la-montre" in French): sixty seconds of questions on
the conjugations the practice record says are mastered, counting right answers. The quiz signals
send a new `source` value, `speedRound`. **A round sends no question counts.** `quizCompletion`
omits `questionCount`, and `quizQuit` and `quizAbandon` omit the question reached, because a
round's length is how many questions were answered in a minute. Nothing is posted to Game Center,
which section 6 already allows. The round's best, the most right answers in one round, is kept on
the device beside the practice record, never sent, and erased by Reset Practice. A round moves
nothing in the practice record.

This section replaces the quiz lifecycle bullet that the section on Phrases à trous gives, the
progress bullet that the section on Review and My Mistakes gives, the bullet on how long a quiz
lasted that the section on model practice gives, and the practice-record paragraph that the section
on Mastery gives, so apply it after all four. Its progress bullet also names a model's mixed
practice, which has sent no question reached since the section on model practice but which that
section left out of the bullet.

### English

The bullet on quiz lifecycle events now reads:

```
- Quiz lifecycle events (starting, quitting, or completing a quiz), and where the quiz began: the Quiz tab, over every verb, over My Verbs, over a custom choice, as a review of what is due, as practice of your mistakes, or as the Verb Essentials, Name the Conjugation, Sentences, or Speed Round exercise, a verb's page, a collection, a practice set opened from a shared link or a QR code, or the practice of a conjugation model, alone or mixed with models you know, with which collection for the four featured ones (a model's collection, or a model's practice, is named only as a model); for a custom quiz or a practice set, whether it chose tenses, verbs, or both, but not which
```

The bullet on progress in a quiz now reads:

```
- How far you progressed in a quiz if you quit early or leave the app during it (the question number reached, reported the next time you open the app), except in a review, in practice of your mistakes, in a model's mixed practice, or in the Speed Round, whose length would reveal how your answers went
```

The bullet on how long a quiz lasted now reads:

```
- Roughly how long a quiz lasted when you complete or quit it (under 3 seconds, 3 to 15 seconds, 15 to 40 seconds, 40 seconds to 2 minutes, or longer), and how many questions it had reached when you complete it (10, or 20 or more if you asked for ten more; 15 a round in Verb Essentials; up to 15 a round in a model's practice alone), except for a review, practice of your mistakes, a model's mixed practice, or the Speed Round
```

The practice-record paragraph now reads:

```
The app also keeps a practice record: for each conjugation your quiz answers and lookups have touched, whether your last answer was right and when it is next due for review, so that quizzes and review cards can bring it back and the Quiz tab can show what you have mastered, the results of your last quiz, so that the Quiz tab can show them, and your best in the Speed Round. The practice record stays on your device and is never sent. Reset Practice in Settings erases it.
```

### French

Le point sur les événements du cycle de vie d'un quiz devient :

```
- Les événements du cycle de vie d'un quiz (démarrage, abandon ou achèvement d'un quiz) et son point de départ : l'onglet Quiz, sur tous les verbes, sur « Mes verbes », sur mesure, en révision de ce qui est à revoir, pour revoir vos erreurs ou dans l'exercice « L'essentiel du verbe », « Identifier la forme verbale », « Phrases à trous » ou « Contre-la-montre », la page d'un verbe, une collection, une série d'exercices ouverte depuis un lien partagé ou un code QR, ou l'exercice d'un modèle de conjugaison, seul ou mélangé aux modèles que vous connaissez, avec le nom de la collection pour les quatre collections mises en avant (la collection d'un modèle, ou l'exercice d'un modèle, est désigné seulement comme celui d'un modèle) ; pour un quiz sur mesure ou une série d'exercices, s'il porte sur des temps, des verbes ou les deux, mais pas lesquels
```

Le point sur la progression dans un quiz devient :

```
- Votre progression dans un quiz si vous l'abandonnez prématurément ou quittez l'application pendant celui-ci (le numéro de la question atteinte, transmis à la prochaine ouverture de l'application), sauf en révision, pour revoir vos erreurs, dans l'exercice d'un modèle mélangé ou au « Contre-la-montre », dont la longueur révélerait le résultat de vos réponses
```

Le point sur la durée d'un quiz devient :

```
- La durée approximative d'un quiz lorsque vous le terminez ou l'abandonnez (moins de 3 secondes, de 3 à 15 secondes, de 15 à 40 secondes, de 40 secondes à 2 minutes, ou davantage) et le nombre de questions atteint lorsque vous le terminez (10, ou 20 et plus si vous avez demandé dix questions de plus ; 15 par série dans « L'essentiel du verbe » ; jusqu'à 15 par série dans l'exercice d'un modèle seul), sauf en révision, pour revoir vos erreurs, dans l'exercice d'un modèle mélangé ou au « Contre-la-montre »
```

Le paragraphe sur le suivi des exercices devient :

```
L'application conserve aussi un suivi des exercices : pour chaque conjugaison que vos réponses aux quiz et vos consultations ont touchée, si votre dernière réponse était juste et le jour où elle doit être révisée, afin que les quiz et les cartes de révision la reproposent et que l'onglet Quiz puisse afficher ce que vous maîtrisez, le résultat de votre dernier quiz, afin que l'onglet Quiz puisse l'afficher, et votre record au « Contre-la-montre ». Ce suivi reste sur votre appareil et n'est jamais envoyé. « Réinitialiser le suivi », dans les Paramètres, l'efface.
```
