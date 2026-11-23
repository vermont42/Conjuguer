# VoiceOver and Mixed-Language Pronunciation

Conjuguer puts French and English side by side: a French infinitive over its English gloss, French
conjugations under an English or French interface. VoiceOver reads each element in one language,
so the app tells it which. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md), adapted
from Konjugieren's `docs/voiceover.md`. Follow it for anything tappable on the verb page or in the
verb list, and add to it when a screen finds a new pattern.

## Marking the Language

`.frenchPronunciation()` and `.englishPronunciation()` in `Modifiers.swift` set
`.environment(\.locale)` to `fr-FR` or `en-US`, and VoiceOver reads the element in that language.
Mark French text French whatever the interface language, and mark English text English, since a
francophone device would otherwise read "hate" with a French voice.

`.frenchPronunciation(forReal:)` applies the locale only when `forReal` is true. The Info tab
passes `info.alwaysUsesFrenchPronunciation`, so an article whose heading is French in both
languages (a tense's name) is read in French, and the others follow the interface.

## What Works and What Does Not

Konjugieren established these with VoiceOver on a device. They are assumed to hold here, since the
mechanism is the same SwiftUI environment. Mark a row confirmed for Conjuguer when a session tests
it here.

| Approach | Works? | Notes |
|---|---|---|
| `.environment(\.locale)` on a view | Yes | VoiceOver reads that element in the locale |
| The locale on a parent, plain `Text` children | Yes | The children inherit it |
| A different locale on each child inside a `Button` or `NavigationLink` | **No** | The button flattens its children into one element, and only one locale applies |
| `.accessibilityElement(children: .contain)` on a `NavigationLink` | **No** | Ignored. A link always flattens |
| `NSAttributedString.Key.accessibilitySpeechLanguage` converted to `AttributedString` | **No** | The attribute is stripped in the conversion |
| `Text("a") + Text("b")` with different locales | **No** | Concatenation makes one `Text`, and one locale wins |

## Pattern: Tappable Text in Two Languages

When a row holds French and English that should each be read in their own language, do not wrap it
in a `Button` or a `NavigationLink`. Make each piece its own element, give each the button trait
and an action, and handle the visual tap on the row:

```swift
struct VerbRow: View {
  let verb: Verb
  let open: () -> Void

  var body: some View {
    VStack(alignment: .leading) {
      Text(verb.infinitifWithPossibleExtraLetters)
        .frenchPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { open() }
      Text(verb.translation)
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { open() }
    }
    .contentShape(.rect)
    .onTapGesture { open() }
  }
}
```

`.onTapGesture` handles a finger's tap, `.accessibilityAction` handles VoiceOver's double tap, and
`.isButton` tells VoiceOver that the element does something. The parent opens the page by setting
its navigation state (in the Verbs tab, its `NavigationPath`; on a verb or model page, the
`verbPagePush` environment action) rather than through a `NavigationLink`. The Related Verbs
card's chips (Phase 7) follow this pattern: each chip is one French element with the button trait
and an action.

**Today's verb list does not do this.** `VerbBrowseView` and `ModelBrowseView` wrap `BrowseRow`,
which marks its title French and its subtitle English, in a `Button`. By the table above, the
button flattens the row and one locale wins, so either the infinitive or the gloss is probably read
in the wrong language. This is inferred from Konjugieren's finding and has not been tested here.
A phase that rebuilds the verb row (Phase 1's search results, Phase 5's matched rows, Phase 10's
recents) should test it with VoiceOver and adopt the pattern if it is so. Phase 1 (2026-11-22) kept the row and its `Button`, adding only a French subtitle for the Models
tab's member matches, so the question is still open; the accessibility tree reads a row as one
label ("être, be"), and its voice can be judged only by listening. Phase 10 (2026-11-22) reused
the same row for the recents and My Verbs, unchanged, and was not tried with VoiceOver either.

## Pattern: A French Value Beside an Interface Label

For a line such as "Auxiliaire : être", put the label and the value in an `HStack` as separate
`Text`s, mark the value French, and give the label `.fixedSize(horizontal: true, vertical: false)`
so the stack does not squeeze it:

```swift
HStack(alignment: .top, spacing: 0) {
  Text(L.VerbView.auxiliaryWithColon + " ")
    .fixedSize(horizontal: true, vertical: false)
  Text(verb.auxiliary.verb)
    .frenchPronunciation()
}
```

`VerbView.metaRow` today marks the whole row French, label included, which reads an English label
with a French voice in the English interface.

## Conjugations

A conjugation cell on the verb page (`TenseSectionView`) shows the pronoun and the form as two
`Text`s. The pronoun is hidden from VoiceOver, and the form carries an `accessibilityLabel` of the
whole spoken line, pronoun and reflexive pronoun included, lowercased (`VerbConjugations.Cell.accessibility`,
from `conjugationParts`). The lowercasing matters: the display marks irregular letters by case
(red capitals, see `ConjugationText.swift`), and VoiceOver would spell "SUIS" letter by letter. The
personless card (participes and radical du futur) does the same, joining its three cells' spoken
forms. Since browse Phase 6 the personless card gives each cell its own row and element, so
VoiceOver reads allé, allant, and ir one at a time. Any new place that shows a conjugation, such as the key conjugations, should give VoiceOver
the lowercased spoken form in the same way. A search result's match line ("vais: Indicatif Présent
(je)", since browse Phase 5) needs nothing extra: it is built from the map's lowercase keys and
marked French.

A cell that a search matched (browse Phase 5) carries the accessibility value "Matches your search"
("Correspond à votre recherche"), so VoiceOver reads the form and then that it is the one found.
Since Phase 6 the personless card's cells carry it one by one, like the tense cards'. Not yet tried
with VoiceOver running.

Nothing on the verb page speaks when tapped. A conjugation cell has no tap action, and `Utterer` is
used only by the quiz.

Since browse Phase 8 each conjugation cell, and the infinitive at the top, carries a named action,
Copy ("Copier"), from `copyOnLongPress(_:)`, the same choice a long press offers. VoiceOver lists
it in the actions rotor. It copies the form without the pronoun, as the long press does. Not yet
tried with VoiceOver running.

## Pronunciation by Screen

| Screen | Approach |
|---|---|
| `VerbBrowseView`, `ModelBrowseView` | `BrowseRow` in a `Button`: title French, subtitle English, or French when it names the verb that found a model (see above); a search's match line French |
| `FrenchLetterKeyRow` | Each key a `Button` whose letter is marked French |
| `VerbView` (infinitive, headings, cells) | `.frenchPronunciation()` on each; the infinitive and each cell a Copy action (Phase 8) |
| `VerbView` (share button, Phase 8) | A toolbar `Button` whose `Label` reads "Share" ("Partager") |
| `VerbView` (star, Phase 10) | A toolbar `Button` whose `Label` reads "Add to My Verbs" or "Remove from My Verbs" ("Ajouter à Mes verbes", "Retirer de Mes verbes"), so its label says what a tap will do |
| `VerbBrowseView` (recents and My Verbs, Phase 10) | The same `BrowseRow` in a `Button` as the list; the recents' "Recent" heading and My Verbs' "Starred" and "Recent" headings carry the header trait; a My Verbs row's swipe action is labeled "Delete" ("Supprimer") |
| `VerbView` (gloss) | `.englishPronunciation()` |
| `VerbView` (model row) | A `Button` whose label is marked French, with a hint that it opens the model |
| `VerbView` (color key) | Each swatch combined into one element. The dismiss button is labeled |
| `VerbView` (tense headings, Phase 6) | The French name marked French and given the header trait; the second name ("also simple past", "aussi passé défini") a separate element in the interface's language, unmarked; the article button labeled "Info" with the hint "Opens the article about this tense." |
| `ModelView` | Exemplar, endings, and verbs marked French |
| `InfoBrowseView`, `InfoView` | `.frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)` |
| `QuizView` | The infinitive and the question French, the gloss English, plus the announcements below |

## The Quiz's Announcements

A typed quiz moves on without a focus change VoiceOver would notice, so `Quiz` announces each
question itself. When `UIAccessibility.isVoiceOverRunning`, `announcePublishedProperties()` waits a
second after each question appears and speaks, through `Utterer.utter(_:localeString:)`, a series
of label and value pairs: the verb, its translation, the pronoun, the gender, the tense, the
progress, the score, and the elapsed time. Each label is spoken in the interface's language (French
as `fr-FR`, otherwise the device's language and region), each French value in `fr-FR`, and the
translation in `en-US`. `Utterer` speaks through one shared `AVSpeechSynthesizer`, warms the
voices off the main thread at launch (`Utterer.setup()`), and plays `Sound.silence` after each utterance, a workaround whose forum thread the
code links.

A new quiz screen or exercise that changes its question without moving focus needs the same
announcement, or an `AccessibilityNotification.Announcement`.
