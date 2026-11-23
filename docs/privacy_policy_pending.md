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
typed text: the policy says the app does not record the verbs you look up or any text you type, and
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
