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
