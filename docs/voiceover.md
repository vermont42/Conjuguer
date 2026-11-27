# VoiceOver and Mixed-Language Pronunciation

Conjuguer puts French and English side by side: a French infinitive over its English gloss, French
conjugations under an English or French interface. VoiceOver reads each element in one language,
so the app tells it which. Follow this doc for anything tappable on the verb page or in the verb
list, and add to it when a screen finds a new pattern.

## Marking the Language

`.frenchPronunciation()` and `.englishPronunciation()` in `Modifiers.swift` set
`.environment(\.locale)` to `fr-FR` or `en-US`, and VoiceOver reads the element in that language.
Mark French text French whatever the interface language, and mark English text English, since a
francophone device would otherwise read "hate" with a French voice.

`.frenchPronunciation(forReal:)` applies the locale only when `forReal` is true. The Info tab
passes `info.alwaysUsesFrenchPronunciation`, so an article whose heading is French in both
languages (a tense's name) is read in French, and the others follow the interface.

## What Works and What Does Not

Konjugieren established these with VoiceOver on a device (see its `docs/voiceover.md`). They are
assumed to hold here, since the mechanism is the same SwiftUI environment. Mark a row confirmed for
Conjuguer when a session tests it here.

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
card's chips follow this pattern: each chip is one French element with the button trait and
an action.

**The verb list does not do this.** `VerbBrowseView` and `ModelBrowseView` wrap `BrowseRow`,
which marks its title French and its subtitle English, in a `Button`. By the table above, the
button flattens the row and one locale wins, so either the infinitive or the gloss is probably read
in the wrong language. This is inferred from Konjugieren's finding and has not been tested here.
The search results, the matched rows, the recents, and My Verbs all use this row, and none has been
tried with VoiceOver. The accessibility tree reads a row as one label ("être, be"), so its voice
can be judged only by listening. Whoever next rebuilds the verb row should test it with VoiceOver
and adopt the pattern if the guess holds.

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
with a French voice in the English interface. The Related Verbs card's row titles follow the pattern since
2026-11-26: "Built on" beside "prendre", and "Same model:" beside "venir (6-7)", each value marked
French (`RelatedVerbsView.relation(label:value:chips:)`).

## Conjugations

A conjugation cell on the verb page (`TenseSectionView`) shows the pronoun and the form as two
`Text`s. The pronoun is hidden from VoiceOver, and the form carries an `accessibilityLabel` of the
whole spoken line, pronoun and reflexive pronoun included, lowercased (`VerbConjugations.Cell.accessibility`,
from `conjugationParts`). The lowercasing matters: the display marks irregular letters by case
(red capitals, see `ConjugationText.swift`), and VoiceOver would spell "SUIS" letter by letter. The
personless card (participes and radical du futur) gives each cell its own row and element, so
VoiceOver reads allé, allant, and ir one at a time, each lowercased the same way. Any new place
that shows a conjugation should give VoiceOver the lowercased spoken form, as the review card's key
conjugations do. A search result's match line ("vais : Indicatif Présent (je)") needs nothing
extra: it is built from the map's lowercase keys and marked French.

A cell that a search matched carries the accessibility value "Matches your search" ("Correspond à
votre recherche"), so VoiceOver reads the form and then that it is the one found. The personless
card's cells carry it one by one, like the tense cards'. Not yet tried with VoiceOver running.

Nothing on the verb page speaks when tapped. A conjugation cell has no tap action, and `Utterer` is
used only by the quiz.

Each conjugation cell, and the infinitive at the top, carries a named action, Copy ("Copier"),
from `copyOnLongPress(_:)`, the same choice a long press offers. VoiceOver lists it in the actions
rotor. It copies the form without the pronoun, as the long press does. Not yet tried with
VoiceOver running.

## Pronunciation by Screen

| Screen | Approach |
|---|---|
| `VerbBrowseView`, `ModelBrowseView` | `BrowseRow` in a `Button`: title French, subtitle English, or French when it names the verb that found a model (see above); a search's match line French. The row the hardware keyboard's arrows highlight, and the failed search's guess card while highlighted, carry the selected trait, so Return's target is not told by color alone. Not tried with VoiceOver |
| `FrenchLetterKeyRow` | Each key a `Button` whose letter is marked French |
| `VerbView` (infinitive, headings, cells) | `.frenchPronunciation()` on each; the infinitive and each cell a Copy action |
| `VerbView` (share button) | A toolbar `Button` whose `Label` reads "Share" ("Partager") |
| `VerbView` (star) | A toolbar `Button` whose `Label` reads "Add to My Verbs" or "Remove from My Verbs" ("Ajouter à Mes verbes", "Retirer de Mes verbes"), so its label says what a tap will do |
| `VerbBrowseView` (recents and My Verbs) | The same `BrowseRow` in a `Button` as the list; the recents' "Recent" heading and My Verbs' "Starred" and "Recent" headings carry the header trait; a My Verbs row's swipe action is labeled "Delete" ("Supprimer") |
| `VerbBrowseView` (review card) | The verb-row pattern above: the infinitive (French) and the gloss (English) are separate elements, each a button with the card's action; then the prompt in the interface's language or, once revealed, the key conjugations, marked French, read lowercased and joined by semicolons, with the hint "Opens the verb’s page." The redacted placeholder is hidden, and ✕ is labeled "Dismiss" ("Fermer"). Not tried with VoiceOver |
| `VerbView` (gloss) | `.englishPronunciation()` |
| `VerbView` (model row) | A `Button` whose label is marked French, with a hint that it opens the model |
| `VerbView` (color key) | Each swatch combined into one element. The dismiss button is labeled |
| `VerbView` (tense headings) | The French name marked French and given the header trait; the second name ("also simple past", "aussi passé défini") a separate element in the interface's language, unmarked; the article button labeled "Info" with the hint "Opens the article about this tense." |
| `ModelView` | Exemplar, endings, and verbs marked French |
| `InfoBrowseView`, `InfoView` | `.frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)` |
| `QuizView` | The infinitive and the question French, the gloss English, plus the announcements below. The answer field's label reads its frame as one prompt in the interface's language ("je, feminine, blank"; "elles se, plural, blank"; "tu, blank, toi"), and the frame's own words are hidden. Not yet heard with VoiceOver |
| `QuizCorrectionView` | The two answers read as one element, which takes VoiceOver focus when a correction is held: "Incorrect. Your Answer: parle. Correct Answer: parlé. Letters that differ: é. This question will come up again." (the letters only when three or fewer, and the last sentence unless the question is itself a re-ask), with the hint "Swipe right for the links, then Continue." The verb link is marked French; each link's hint says the quiz waits with its clock stopped. Continue has its own hint, and a Magic Tap also continues. Read from the accessibility tree, not heard |
| `QuizView` (custom quiz) and `PracticeSetView` | The summary card (`CustomQuizSummaryCard`) is one element, its tense names marked French; a model's name is marked French, a band's or a list's title is not. Share is a menu with the hint "Shares your custom quiz as a link or a QR code". On a practice set's sheet the title carries the header trait, a list's verb chips are marked French, Start has the hint "Starts a quiz over this practice set", and Keep posts "Kept as My Custom Quiz" as an announcement, since the button only dims. The QR code is one image element labeled "QR code for this practice set", and the caption below it reads the set. Read from the accessibility tree, not heard |
| `MasteryView` | Each mark is its own element, read as its state ("Mastered", "Maîtrisé"). In a regular tense's card each pronoun above a mark is its own element marked French, so VoiceOver reads "je", then the state; a row's family reads "-er verbs" or "-er verbs with être" ("verbes en -er", "verbes en -er avec être"). A spelling-change card's exemplar, first changed form (lowercased), tense names, and pronouns are marked French. A verb row's infinitive is French, its gloss English, and each key conjugation French and lowercased after its mark. Section headings carry the header trait with their counts, and tense names too. Read from the accessibility tree, not heard |

## The Quiz's Announcements

A typed quiz moves on without a focus change VoiceOver would notice, so `Quiz` announces each
question itself. When `UIAccessibility.isVoiceOverRunning`, `announcePublishedProperties()` waits a
second after each question appears and speaks, through `Utterer.utter(_:localeString:)`, a series
of label and value pairs: the verb, its translation, the pronoun, the gender (in a compound tense only, as the
answer frame shows it), the tense, the progress, the score, and, with the Quiz Clock set to Show,
the elapsed time. A re-asked question begins with "Asked Again" / "Question reposée", which its
capsule on screen also reads. When the last answer was right but spelled another
standard way (connait for connaît), the series begins with "Correct. Also spelled:" and the app's
spelling, which the label beside the checkmark also reads. Each label is spoken in the interface's language (French
as `fr-FR`, otherwise the device's language and region), each French value in `fr-FR`, and the
translation in `en-US`. `Utterer` speaks through one shared `AVSpeechSynthesizer`, warms the
voices off the main thread at launch (`Utterer.setup()`), and plays `Sound.silence` after each utterance, a workaround whose forum thread the
code links.

A wrong answer is not announced. It holds the question, and `QuizView` moves VoiceOver focus to
the correction instead. The next question is announced after Continue.

The results' Ten More has the hint "Continues the quiz with ten more questions. The score carries
on." After it, focus returns to the answer field and the next question is announced as any other.
Not yet heard with VoiceOver.

A slip that earns one more try is announced ("Almost! Try once more.", in the interface's
language, through `Utterer`), and focus stays in the answer field, which still holds the first
attempt to edit. The feedback slot shows the same line, which VoiceOver reads in place. Not yet
heard with VoiceOver.

In Verb Essentials, a verb's three key conjugations are three questions on one screen. The full
series is spoken at a step's first blank only; a later blank announces just "Tense:" and its tense,
since the verb is already on screen. The answer field's label begins with its row's tense
("passé composé, elle, singular, blank"), and every other row is one element: "indicatif présent,
elle, singular, vient, right", "…, right on the second try", "…, wrong", or "futur simple, elle,
singular, not yet asked". A re-ask's given rows read their conjugation. Start's hint is "Starts a
quiz of three conjugations each of five irregular verbs", and Five More Verbs has its own. Read
from the accessibility tree, not heard.

In Phrases à trous, a sentence takes the pronoun's place in the series: after the verb and its
translation come "Sentence:" / "Phrase :", the sentence in `fr-FR` with "blank" where the answer
goes, and its English in `en-US`, then the tense and the progress. The answer field's label is
that same prompt ("Ce couteau, blank, à couper le pain", with "feminine" or "tu" where the screen
marks one), and the correction's spoken text ends with the completed sentence. The results' Example
Use is a button with the selected trait while open and the hint "Shows a sentence that uses this
verb, with its source". Read from the accessibility tree, not heard.

A choice question speaks its setting in `fr-FR`, the setting's English in `en-US`, "Which fits
here?" / "Laquelle convient ici ?", and the progress, in place of the verb, the pronoun, and the
tense. Each of its two sentences is one button, read as the sentence and its tense ("Si j'avais
plus de temps, je voyagerais., imparfait") with the hint "Chooses this sentence." Once one is
chosen, a sentence's value is "Your choice", "The right choice", or both, and focus moves to the
reason, one element read as "Correct." and the reason, or "Incorrect. The right choice:", the right
sentence, and the reason. Magic Tap continues, as from a held correction. Read from the
accessibility tree, not heard.

A new quiz screen or exercise that changes its question without moving focus needs the same
announcement, or an `AccessibilityNotification.Announcement`.
