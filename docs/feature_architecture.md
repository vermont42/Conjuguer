# Feature Architecture

How Conjuguer's feature systems work, one section each. Keep it true: a section that describes code
that has since changed misleads the next session more than a missing section would.

## Search

The Verbs and Models tabs each show a list with a search field and a sort picker. One function,
`VerbSearch.matches`, matches and ranks verbs for both, and Look Up a Verb and `VerbEntity`'s string
query use it too.

### Architecture

| File | Purpose |
|------|---------|
| `VerbBrowseView.swift` | The Verbs tab: the list (a `List` on iPhone, a `LazyVGrid` of cards on iPad), the sort picker, the search field, and the verb count. `VerbBrowse.makeStore` builds the store |
| `ModelBrowseView.swift` | The Models tab, built the same way. `ModelBrowse.makeStore` builds the store |
| `BrowseStore.swift` | A generic `@Observable` store that holds a list presorted for each sort order and persists the chosen order through a closure |
| `BrowseSearch.swift` | `BrowseSearch.results(in:query:playSoundIfEmpty:search:)`: every item for a blank query, otherwise what the tab's search closure returns, with a sad trombone when that is nothing |
| `VerbSearch.swift` | The matching and ranking rule. `MatchKind` names each kind of match, for the `matchKind` signal parameter. Also the guess |
| `VerbSearch+Conjugations.swift` | Reverse lookup: a conjugation, simple or compound, finds its verbs |
| `ConjugationQuery.swift` | A query as a conjugation's words: subject and reflexive pronouns, elision, que, y, en, and negation dropped |
| `ConjugationIndex.swift` | The conjugation map indexed by folded spelling, and the packed folds the guess measures; `BoundedEditDistance` |
| `MatchedConjugation.swift` | The conjugation a result matched, its cells, the row's line ("vais: Indicatif Présent (je)"), and the `MarkedConjugations` a page opens with |
| `ModelSearch.swift` | Finds a model by its exemplar or by any of its verbs, through `VerbSearch` without glosses |
| `FailedVerbSearchView.swift` | The verb list's empty state: `ContentUnavailableView.search`, the guess, and the line asking the learner to email a missing verb |
| `VerbSearchCommands.swift`, `VerbSearchArrowKeys.swift` | Command-F, and the arrow keys through results, on iPad and Mac |
| `FrenchLetterKeyRow.swift` | é è ê â î ô û ç keys, with an `insert` closure: the search fields append, and the quiz's answer field inserts at the cursor |
| `BrowseRow.swift` | The row both tabs show: a French title, a subtitle (English gloss, or the French verb that found a model), and a badge |
| `VerbSort.swift`, `ModelSort.swift` | The sort orders: Frequency (the default) and Alphabetical for verbs; Irregularity, Alphabetical, and Identifier for models. `Settings` stores the choice. Search ignores them |

### Matching

- **The query.** Trimmed and lowercased. For the French side, a leading "se " or "s'" (or "s’")
  is dropped, since pronominal verbs are stored without it; a bare "s'" searches as "s". For the
  English side, a leading "to " is dropped. Extra letters (haïr's "France", sortir's "exit") are
  not searched.
- **Folding.** `VerbSearch.fold` lowercases, turns œ into oe and æ into ae, and strips diacritics,
  so etre finds être and manoeuvrer finds manœuvrer.
- **Kinds and tiers.** `MatchKind`, best first: exact infinitive; exact after folding; then one tier
  holding a conjugation (literal or folded), an infinitive prefix, a whole English meaning (one
  comma-separated sense of the gloss, its parenthetical note dropped, so "can (food)" means "can"),
  and a folded prefix; then a whole word of the gloss; then an infinitive substring, literal or
  folded; then a gloss substring. Each verb appears once, with its best kind; on a tie a
  conjugation wins, because its row can name the cells.
- **Order within a tier** is by frequency rank, whatever the sort order, so venir leads under
  Alphabetical and "go" puts aller (#6) ahead of gonfler. A folded match ranks below a literal one
  in the same tier only when the query carries an accent or ligature: pêch puts pêcher before
  pécher, but pre ranks préparer by its frequency among the bare pre- verbs. The two exact tiers
  are always apart, so typed mater leads mâter, and pecher shows pêcher and pécher by frequency.
  Folded matches also rank below the rest of their tier when the word typed is itself a literal
  conjugation: mate is mater's, so mater leads and mâter and matérialiser follow the literal
  prefixes.
- **Models.** Every model whose exemplar matches comes first, ranked as the exemplars rank, then
  every other model that has a matching verb, ranked by its best verb, which the row shows as its
  subtitle (devenir under venir). Glosses are not searched there.
- **Field.** Autocapitalization and autocorrection are off. The placeholders are "Infinitive or
  English meaning" and "Model or verb". While a field is focused, `FrenchLetterKeyRow` replaces the
  sort picker (on iPhone it then sits just above the keyboard), because a
  `ToolbarItemGroup(placement: .keyboard)` never appears for the navigation bar's search field on
  iOS 26.3, as Konjugieren found too. A key appends its letter.
- **No result.** `BrowseSearch` plays `Sound.randomSadTrombone` when the text changes, not when
  the sort order changes, and not for a query of only spaces. The Models tab shows
  `ContentUnavailableView.search`. The Verbs tab shows `FailedVerbSearchView`: the
  same view, then a guess, then "If you believe that “…” is a French verb, please email
  vermontcoder@gmail.com", whose address is a `mailto:` link (`URL.mailto`) with the subject and
  body filled in with the query in the learner's language. A device that cannot open the link,
  such as the simulator, copies the address to the clipboard instead and says so for four seconds.
- **The guess.** `VerbSearch.guess` folds the query as search does (reflexive pronoun dropped,
  accents and ligatures folded) and measures optimal string alignment distance (Levenshtein plus a
  swap of two adjacent letters) to every folded infinitive and to every folded
  conjugation when the query is one word once its pronouns are dropped. A guess must be within one
  edit per three letters, and never more than three; on a tie an infinitive beats a conjugation,
  then the more frequent verb wins, then the earlier spelling. So venier finds venir, assoir
  asseoir, manjer manger (ahead of manier, also one edit away), finnissons finir through finissons
  (whose cells the guess's card names and its page marks), and xyzzyq nothing, in which case only
  the mail line shows. Glosses are not considered. A Debug build measures 230,000 folds between
  keystrokes because `BoundedEditDistance` discards most by their letter counts, abandons a
  comparison once it must exceed the limit, and `ConjugationIndex.nearestFolds` measures lengths
  nearest the query's first and tightens the limit with each find: at most about 0.3 s, against 9 s
  without them.
- **Keyboard (iPad and Mac).** The search field is a bar under the title that stays put
  (`.navigationBarDrawer(displayMode: .always)`, `BrowseLayout.searchPlacement`) on both tabs,
  because iPadOS 26 shrinks `.automatic` search into a toolbar button that ignores `.searchFocused`.
  iPhone keeps `.automatic`. **Command-F** is a top-level menu command (Verbs › Find a Verb) that
  calls `World.openSearch(text: nil, source: .tab)`: it closes any deeplinked page, switches to the
  Verbs tab, and sets `searchRequest`, which `VerbBrowseView` answers by popping any pushed verb page
  (waiting 500 ms for the pop, or the focus does not take) and focusing the field, keeping its text.
  The `search` route, the Find a Verb control, and the quick action make the same request with
  text (§ Deeplinks).
  **↑ and ↓** move a highlight through the results in reading order (a red accent bar on a card, a
  red tint on a list row), stopping at either end; the first ↓ lands on the first result. They need
  `VerbSearchArrowKeys`, a `UIKeyCommand` on the window's root view controller installed only while
  the verb field is focused, because a focused text field consumes them ahead of every SwiftUI
  mechanism. **Return** opens the highlighted result, else the first, else the guess. Return and the
  arrows act only on the iPad idiom (which a Mac running the iPad app also reports) and only while
  the field holds a query, so the iPhone keyboard's Search key keeps its usual behavior.
- **Cost.** One search over 6,330 verbs takes about 20 ms on the Intel simulator, and about 50 ms
  with reverse lookup, in a Debug build. `VerbSearch` caches each verb's folded keys after the
  first search.

### Reverse Lookup

A conjugation finds its verb, through the map ([Conjugation Map](#conjugation-map)) indexed by
`ConjugationIndex`.

- **The query.** `ConjugationQuery` splits elided words (j'ai is j' and ai, with ’ read as ') and
  drops leading words that a sentence puts around a conjugation, while one word remains: subject
  pronouns, que and qu', ne and n', reflexive pronouns (me, te, se, elided or not, and a second nous
  or vous), y, and en. After a ne, it drops pas, plus, jamais, rien, point, and guère too. So "je
  vais", "j'ai", "il y a", "que je sois", "je ne sais pas", and "je me souviens" are vais, ai, a,
  sois, sais, and souviens. A query of pronouns alone ("j'", "nous") is still being typed, so it
  plays no trombone when it finds nothing.
- **One word** is looked up as typed and then folded (`ConjugationIndex.spellings`), so etait finds
  était. Each verb's cells (`Verb.conjugations(matching:)`) confirm it and name the row; a map entry
  that is only an infinitive is left to the infinitive search. A hyphenated word is tried whole
  (arc-boutait), then with the confirming text whole and its verb alone (souviens-toi matches only
  souvenir's impératif), then as its verb alone (lève-toi, vas-tu, a-t-il).
- **More than one word** is a compound: the last word, the participle, is looked up as typed and
  folded, and every spelling of the auxiliary's words is tried against that verb's compound cells,
  so "ai mangé", "est allée", "avions fini", and "etait allee" work. When the query carried a
  reflexive pronoun, an avoir verb's compound also matches with être, as its pronominal use: "je
  me suis levé" is lever's passé composé, je, though the page shows "j'ai levé". Without one, "est
  levé" is a passive and matches nothing. Every other multi-word query finds only what the
  infinitive and gloss search finds.
- **The row** adds a French line in red under the gloss: the conjugation as the app spells it, then
  each tense once with its matching persons, joined by a dot: "suis: Indicatif Présent (je, tu) ·
  Impératif (tu)" under suivre. Tense names are `Tense.titleCaseName`, French in both languages.
  The third persons follow the pronoun setting, except that a participle agreed in the feminine
  names elle or elles ("est allée: Passé Composé (elle)"). An agreed participe passé alone reads
  "allées: Participe Passé (accordé)". A pronominal compound keeps its reflexive pronoun ("me suis
  levé"), because the page's cell does not show it.
- **Short queries.** Sixteen conjugations have one or two letters: a, ai, as, es, eu, vu, su, lu,
  bu, dû, mû, né, pu, ri, tu, and va. Sharing the prefix tier puts the common verbs' first (a, ai,
  and as find avoir; es être; du, typed without its accent, devoir), and lets a rare verb's fall
  among the verbs the learner may be typing toward: ri lists risquer, then rire, and réa, réer's
  passé simple, lists réaliser and réagir ahead of réer. A tier above the prefixes, as in
  Konjugieren, would have put réer first for réa, enter for ente, and conter for conte.
- **Landing.** Opening a result pushes a `VerbDestination` with `MarkedConjugations`, the matched
  tenses in page order. `VerbView` shows the compound block when any is compound, even if the
  learner has hidden it, without changing the stored choice ([Verb Page](#verb-page)). It scrolls
  to the first marked card (`VerbConjugations.scrollID(for:)`, read from the same `TenseTable` that
  builds the cards) after its first appearance, tints each marked cell with
  `Color.markedConjugation`, and gives it the accessibility value "Matches your search". A marked
  participle is tinted in its row of the personless card. The guess, when guessed from a
  conjugation, marks its page the same way.
- **Cost.** `ConjugationIndex.bundled` loads the map (1.2 s in a Debug build) and folds the 107,000
  keys that have accents (1.0 s), so `VerbBrowseView` builds it from a detached task when the tab
  first appears. A lookup costs a few `conjugations(matching:)` calls, about 10 ms each.

### Opening a Verb

A tap in the Verbs tab appends a `VerbDestination` to the tab's `NavigationPath`. A deeplink instead
sets `Current.verb`, which the Verbs tab presents as a sheet (see [Deeplinks](#deeplinks)), and the
Info tab does the same for a verb link in an article. Every page that leads to another (a related
verb, the model row, a model page's verb links) pushes it onto whichever stack shows it, through
`VerbPagePush`; see [Related Verbs](#related-verbs).

## Verb Page

The page orders its cards by frequency, names each tense twice, and gives each tense an article.

### Architecture

| File | Purpose |
|------|---------|
| `Models/TenseTable.swift` | `TenseTable`, the page's cards in order, and on `Tense` the card that shows it (`table`), its article (`articleKey`, `article`), and its second name |
| `Utils/VerbConjugations.swift` | Builds each card's cells from `TenseTable` and notes whether the verb's own cells have red letters (`hasIrregularLetters`) |
| `Views/VerbView.swift` | The page; `TenseHeading` (name, second name, article button), `MarkableConjugation`, and `TenseArticleSheet` |
| `Models/ConjuguerTips.swift` | `ScrollToBottomTip` |
| `scripts/count_tenses.py` | The corpus count behind the order ([`tense_frequency.md`](tense_frequency.md)) |

### The Order

The simple tenses first, then the personless card, then the compound tenses, each block from most
to least frequent in `corpus/originals` with its five folders weighted equally: présent,
imparfait, passé simple, futur, conditionnel, subjonctif présent, impératif, subjonctif
imparfait; then passé composé, plus-que-parfait, conditionnel passé, subjonctif plus-que-parfait,
subjonctif passé, passé antérieur, futur antérieur, passé surcomposé, impératif passé. The
personless card (participe passé, participe présent, radical du futur) sits between the blocks,
where the participe passé introduces the compound tenses built from it (Josh, 2026-11-22). The
order changes the verb page only: Info, the quiz, and the model page keep theirs. Search's row
lines and its landing follow it, since `Verb.conjugations(matching:)` reads `TenseTable` too
("fait: Indicatif Présent (il) · Participe Passé").

### Headings

Each card's heading is the tense's French name, then a red question-mark diamond, the model page's
button for the irregularities article, which opens the tense's Info article. Under the name is a
second name in the app's language: "also simple past" in English, "aussi passé défini" in French,
each the name its learners' textbooks use (Josh, 2026-11-22). Nine French tenses have no French
alternate, and their catalog value is empty, so no line shows. The personless card gives each of its
three cells such a heading.

**The article** opens in `TenseArticleSheet`, so closing it returns to the same verb. A link
inside to another article or to a verb pushes it inside the sheet, and a verb page there pushes
its own articles rather than presenting another sheet (the `tenseArticleOpener` environment
value). `InfoView` takes an optional `openLink` for this; without one, its links go to
`World.handleInAppURL`.

### The Compound Block

The "Show Compound Tenses" toggle starts on, and the learner's choice is stored
(`@AppStorage("showsCompoundTenses")`), so a learner who hides the block finds it hidden on the next
page and after a relaunch (Josh, 2026-11-22). A search that matched a compound tense shows the block
on that page anyway, and touching the toggle there stores the new choice.

### The Color Key and the Scroll Tip

The color-key card shows until dismissed (`hasSeenConjugationColorKey`), and only on a page whose
verb has red letters of its own, in its simple tenses or personless cells (Josh, 2026-11-22). Every
compound tense has red letters in avoir's or être's forms, so this test leaves them out: parler's
page shows no key. In the key's place, `ScrollToBottomTip` points to the etymology and examples. A
page that appears after the key was dismissed unlocks it (a persisted TipKit parameter), so the two
never appear one straight after the other, and reaching the etymology or the examples retires it.
Both obey `TipDisplay.tipsEnabled`.

## Related Verbs

The verb page leads to related verbs, and the model page can list its verbs by frequency.

### Architecture

| File | Purpose |
|------|---------|
| `Models/RelatedVerbs.swift` | `VerbBase` (a verb's base and root), `RelatedVerbs`, and `Verb.related`, cached per entry |
| `Views/RelatedVerbsView.swift` | The card at the bottom of the verb page, `RelatedVerbListView` (every verb built on a root), and `FlowLayout` |
| `Views/VerbPageNavigation.swift` | `VerbPagePush`, `ModelDestination`, `RelatedVerbListDestination`, and `verbPageNavigation(path:done:)` |

### Finding a Base

French marks no prefix in the data, and a suffix match alone fails (oublier ends in lier). A verb
is built on a base when one of `VerbBase.prefixes` (allomorphs, as ap- in apprendre, res- in
ressortir, d- in décrire) leaves a verb of at least three letters, and the verb's etymology in
`Etymologies.json` names that verb as a word, `~prendre~`. Of two candidates the longer base wins.
`VerbBase.falsePairs` removes nine pairs that pass but are wrong: the etymology names the base to
refute the link (supplier/plier, épisser/pisser, délibérer/libérer) or the letters are a
coincidence (arriver names English ~river~). `VerbBase.knownPairs` adds six that fail because the
etymology names only the Latin verb (advenir's ~venīre~). The **root** follows bases until none is
left: redécouvrir, découvrir, couvrir. Every verb built on a root ends in it, so the page finds the
family by suffix and checks each candidate's root.

Measured 2026-11-22: about 1,420 verbs have a base, in about 820 families (poser 23, venir 18,
mettre 16). Of the 300 most frequent verbs, the 65 with a base are all right. Thirteen are compounds
formed in Latin whose meaning has drifted (attendre on tendre, demander on mander, rester on the
archaic ester), and Josh kept them (2026-11-22). allier is built on lier by the same reasoning
(Latin alligare, ad + ligare). The rule reads the etymology in the app's language. Every pair
appears in both languages today, so the families are the same in French and English.

### The Card

Josh chose the bottom of the page, below the examples, from screenshots (2026-11-22). Two rows,
each of up to six chips:

- **Built on prendre**: the root verb first (for a doubled root, the entry that shares this verb's
  model, so ressortir leads to sortir "exit" and assortir to sortir "obtain"), then the family by
  frequency. More than six adds "All 11", which pushes `RelatedVerbListView`, Frequency first, with
  an Alphabetical control. The choice is not stored.
- **Same model: venir (6-7)**: the most frequent verb of each other root in the model, by frequency
  (tenir, appartenir on venir's page; donner, trouver, passer on parler's). The most frequent verb
  wins over the root verb, so demander rather than mander speaks for its root. "All 29" pushes the
  model page in frequency order. The row is hidden when the model holds only this verb's family
  (prendre's 5-2). The model row at the top still leads there.

The card is hidden when both rows are empty. Chips are `onTapGesture` with an `accessibilityAction`
and the button trait, one element each, read in French, as `docs/voiceover.md` asks.

### Navigation

`VerbPagePush` is an environment action that each stack injects through `verbPageNavigation`: the
Verbs tab, the Models tab, every `.sheetDismissable()` sheet, and `TenseArticleSheet`. All four
hold a `NavigationPath` and register destinations for `VerbDestination`, `ModelDestination`, and
`RelatedVerbListDestination`. In a sheet, each pushed page gets the Done button too. Josh chose
(2026-11-22) that the verb page's model row and a model page's verb links push as the chips do,
so no sheet stacks on a sheet. A page with no `VerbPagePush` in its environment (a preview) falls
back to a sheet.

### The Model Page's Order

A segmented control above "Verbs Using This Model" chooses Alphabetical (the default) or Frequency.
The choice is not stored. The list stays a run of `conjuguer://verb/` links in one `Text` (Josh,
2026-11-22), since model 1-1 has 4,859 verbs and Konjugieren saw about 1,000 rows in a non-lazy
stack peg the CPU. Alphabetical uses French collation (`Util.french`), since a plain sort puts
écouter after the z's.

## Copy and Share

A learner can copy a conjugation and share a verb.

### Architecture

| File | Purpose |
|------|---------|
| `Models/KeyConjugations.swift` | `Verb.keyConjugations()`, `Verb.keyTenses`, `Verb.citationInfinitif`, and `Verb.shareText()` |
| `Utils/ShareSheet.swift` | Presents `UIActivityViewController` with an `LPLinkMetadata` header, and on iPad anchors its popover to the share button |
| `Utils/Modifiers.swift` | `copyOnLongPress(_:)`: a context menu with Copy, and a VoiceOver action of the same name |
| `Utils/URLExtensions.swift` | `URL.appStore`, the App Store page with no storefront, so the App Store opens the reader's own |

### Key Conjugations

The il forms of the présent, the passé composé, and the futur simple, in that order (Josh,
2026-11-22): "vient · est venu · viendra". They stand with no label, here and wherever else they
show. The participle agrees with il whatever the pronoun-gender setting, because no pronoun stands
before it. A reflexive verb keeps its pronoun, elided as its cells elide it
(`PersonNumber.thirdPersonReflexivePronoun`): "se souvient · s'est souvenu · se souviendra". A form
the verb's defect group marks unused is left out, so falloir gives all three, gésir gives only
"gît", and accroire gives none. The function returns mixed case, as the Conjugator writes it, so a
caller can show red letters (the auxiliary's irregular letters are capitals too); the share text
lowercases them. Spotlight's entries, Look Up a Verb's answers, and the review card read this
function.

### Sharing

A share button in the verb page's navigation bar (`verb_share_button`) sends:

```
se souvenir, “remember”
se souvient · s'est souvenu · se souviendra

Every conjugation of se souvenir is in Conjuguer:
https://apps.apple.com/app/conjuguer/id1588624373
```

In French the gloss stands in guillemets and the last lines read "Toutes les conjugaisons du verbe
se souvenir sont dans Conjuguer :", where "du verbe" spares the sentence an elision (de aller). The
infinitive is the citation form, with the pronoun of a verb that is only pronominal, though the
page's heading shows the bare infinitive over its Reflexive note. A verb with no key conjugation
drops that line. The text carries the App Store link only, never a `conjuguer://` link (carried
over from Konjugieren, 2026-11-12). The sheet's header shows the citation infinitive and the
learner's chosen app icon. `ShareLink` is not used: Konjugieren found that in a toolbar it reports
no tap, so `tapShareVerb` could not be sent, and that a `SharePreview` removed Copy from the sheet.
On iPad the popover anchors to the bar button whose label is "Share", searched only among what is
on screen; iOS 26 draws it with no arrow, over the button.

### Copying

A long press on a conjugation, or a right-click on a Mac, opens a context menu with Copy, the
platform's convention, which needs no "Copied" toast. It copies the form as the cell shows it, in
lowercase and without the pronoun beside it ("vais", "suis allée", "souviens-toi"). A long press on
the infinitive at the top copies it. An empty cell copies nothing; a form struck through as unused
copies, since it is shown. A tap does nothing: nothing on the verb page speaks.

## Conjugation Map

The app bundle carries every one-word conjugation of every verb, mapped to the verbs it belongs to,
so that search can start from a conjugation: vais finds aller, and suis finds être and suivre.
[Reverse lookup](#reverse-lookup) and Spotlight's keywords read it.

### Architecture

| File | Purpose |
|------|---------|
| `ConjugationMapTool/main.swift` | A macOS command-line target. It parses the three XML files and writes the map, and, when asked, the corpus pipelines' dumps |
| `ConjugationMapTool/FormsJSON.swift` | The three dumps in `corpus/working` (`forms.json`, `forms_all.json`, `conjugations.json`), ported byte for byte from the retired `CorpusFormsDumpTests` harness. `scripts/write_forms_json.sh` runs them |
| `Conjuguer/Models/ConjugationMap.swift` | The map's rules, its text format, `build()`, and `ConjugationMap.bundled`. Compiled by the app and by the tool |
| `Conjuguer/Models/ConjugationMatch.swift` | `Verb.conjugations(matching:)`, app only |
| `Conjuguer/Models/ConjugationLabels.swift` | The core's display members, which reach `Current.settings` or `L` and so stay out of the tool |

**The tool compiles the app's own conjugation core**: 24 files of `Conjuguer/Models` and
`Conjuguer/Utils`, listed in a membership exception on the `Conjuguer` folder in
`project.pbxproj`. The core takes the pronoun gender explicitly; the app's overloads in
`ConjugationLabels.swift` default it to the setting. A caller with a verb in hand passes
`verb.pronounGender` instead, which is masculine for an impersonal verb whatever the setting. A core file that starts reaching `Current`,
`L`, or SwiftUI breaks the tool's build, and the member belongs in `ConjugationLabels.swift`.

**The build phase.** The app target depends on the tool, so an iOS build builds it for the Mac
first (host architecture only, no dSYM, `SKIP_INSTALL`). The app's "Generate Conjugation Map"
Run Script phase, after Resources, declares `verbs.xml`, `verbModels.xml`, `defectGroups.xml`,
and the tool's executable as inputs and writes `ConjugationMap.lzfse` straight into the bundle, so
nothing generated is committed. The executable stands for the Conjugator's sources, because Xcode
relinks it exactly when one of them changes. Measured on 2026-11-22: an unchanged rebuild skipped
the phase; touching `verbs.xml` ran it; a code edit to `ConjugationMap.swift` relinked the tool
and ran it; deleting the tool, so that it relinked to identical bytes, ran it too. Judge this by
the map's timestamp, not by the build log, and not by the tool's timestamp either: each switch
between a test run and a build re-signs the tool (its entitlements differ between the two), which
leaves the map alone, rightly, since a new signature cannot change the map.

### The map

- **What a verb contributes**: its infinitive; every simple tense and both participles, each
  `/`-separated alternate on its own (paie, paye); and the participe passé's agreed forms for
  every verb, since a text agrees an avoir verb's participle with a preceding object
  (`ConjugationMap.agreedForms(ofParticiple:)`: allée, allés, allées; dû gives due, dus, dues;
  pris gives prise and pris; dissous gives dissoute). Left out: the radical du futur, which no
  text writes; every cell the verb's defect group lacks; and the compound tenses, whose words the
  map already holds. Entries for avoir and être would otherwise attach to every verb.
- **Keys** are lowercase and NFC. **Values** are keys of `Verb.verbs`, so a doubled infinitive's
  entries stay apart: sors is "sortir exit" only, and sortir is both. Homographs keep every verb
  (suis, vis, tu, été).
- **The format** is one line per conjugation, `suis⇥suivre⇥être`, sorted by UTF-8 bytes, compressed
  with LZFSE: 242,966 conjugations, 5.0 MB of text, 615,655 bytes in the bundle, built in about 3.5
  seconds by the Release tool. (Figures as of 2026-11-22, after béer's and douer's defect groups
  were corrected.) `sorted()` is not used, because it left 155 keys out of order, and two builds of
  the same data wrote different bytes.
- **Loading** `ConjugationMap.bundled` takes 1.2 seconds in a Debug build on this Intel Mac's
  simulator, so the verb list builds `ConjugationIndex.bundled`, which loads it, from a background
  task before the first search. It is a `nonisolated static let`.

### Matching cells

`Verb.conjugations(matching:)` returns every cell whose conjugation equals a text, in the page's
order (`TenseTable.allTenses`: the simple tenses, the three personless cells, the compound tenses), each
a `ConjugationMatch` of a `Tense` and an `isAgreement` flag. Case and spacing are ignored, and
accents are not: "etait" matches nothing, so search must fold before it calls. A compound cell
matches with its participle agreed either way (est allé, est allée). An impératif matches as the
quiz asks for it (souviens) and as a reflexive verb's page shows it (souviens-toi). The participe
passé also matches agreed, with `isAgreement` set. Defective cells and the infinitive never
match. The radical du futur is a cell and does match (ir for aller). It needs no map and costs
about 10 ms per verb in a Debug build, so compute it for a row only when the row is shown.

## Analytics

Every signal is named in `AnalyticsName`, every parameter key in `ParameterKey`, and every
parameter value in an enum or a band, all in `Analytics/Analytics.swift`. `AnalyticsReal` sends
through TelemetryDeck, and `AnalyticsSpy` records in the simulator and under unit tests. Every
screen reports itself with one signal, `viewAppeared`, whose `viewName` is the view's type name
(`.recordsAppearance(as:)` in `Modifiers.swift`); the verb page reports through its visit instead
(below). **No signal may carry a verb or any typed text**, because the privacy policy says the app
"does not record your quiz answers, the verbs you look up, or any text you type". Counts and
durations go out in bands (`AnalyticsBand`), never as exact numbers. New signals and parameters
wait for the release in [`privacy_policy_pending.md`](privacy_policy_pending.md).

### Lookup signals

Names match Konjugieren's where the signal is new, so the apps can be read side by side; the verb
page's arrival keeps Conjuguer's `viewAppeared`, so that TelemetryDeck's history of verb pages stays
one series.

| Signal | Parameters | Sent |
|---|---|---|
| `viewAppeared` with `viewName` `VerbView` | `source` (below) | When a verb visit begins: the page arrives, or returns with `source` `resume` after another tab, its own model sheet, or the background |
| `leaveVerbView` | `deepestSection` (`header`, `simple`, `compound`, `etymology`, `example`), `dwell` (`0-5s`, `5-15s`, `15-60s`, `60s+`) | Exactly once for each verb page's `viewAppeared`: when the page leaves the screen, its model sheet opens, or the app goes to the background |
| `finishSearch` | `source` (where the search began: `tab`, `control`, `quickAction`, `lookup`, or `deeplink`), `outcome` (`opened`, `abandoned`, `noResult`), `queryLength` (`1-2`, `3-5`, `6-9`, `10+`), `resultCount` (`0`, `1`, `2-10`, `11+`), `matchKind` (below), `resultPosition` (`1`, `2-5`, `6+`, `none`) | Once per verb search: when a result or the guess is opened (by tap, Return, or the arrow keys), the field is cleared, or the app goes to the background with text in the field |

**A visit** (`VerbVisit`) is one stretch of a verb page on screen, uncovered by its own model sheet,
with the app in the foreground. It is the same whether the page was pushed (Verbs tab) or presented
as a sheet (a deeplink, an Info link, a model page). A page that returns starts a new visit whose
`source` is `resume`, so every verb page's `viewAppeared` pairs with one `leaveVerbView`, background
time never counts as reading, and arrivals are the visits whose source is not `resume`. A resumed
visit starts from the deepest section already on screen. The App Store version sent
`viewAppeared` for `VerbView` on each `onAppear` and never on a return from the background; the
current code also sends it on that return, as `resume`. A sheet that something else presents over a
page (a deeplink's verb over a pushed page, say) does not end the page's visit.

**Reaching a section** means a third of its first card on screen (`onScrollVisibilityChange`,
threshold 0.3): the présent card for `simple`, the passé composé card for `compound`, then the
etymology and example cards. The compound block shows only when its toggle is on, which is on by
default and remembered, so a learner who never hides the block reaches it on the way to the
etymology. A tense article's sheet ends the visit as the model sheet does, and closing it resumes
the visit.

**`tapTenseArticle`**, with no parameters, counts taps on a tense heading's article button.
Konjugieren's counterpart is `tapConjugationgroupArticle`.

**`tapShareVerb`**, with no parameters, counts taps on the verb page's share button, whether or not
the learner then shares. Copying sends nothing.

**`tapStarVerb`** counts taps on the verb page's star, with `starred` (`true` or `false`), the state
after the tap, so that a count of devices with a starred verb can be told from taps that unstar. It
does not name the verb.

**A search** (`SearchTracker`, `SearchReport`) begins with the first non-blank letter and ends
once. Returning to the results and opening another verb without editing the text sends no second
`finishSearch`, though the page still reports `search`. Editing the text after an open begins a new
search, so deleting the query letter by letter reports an abandoned search of its last letters. An
abandoned search's `matchKind` is that of the top result it passed over. Opening the guess reports
`opened`, `resultCount` `0`, `matchKind` `guess`, and position `1`. `resultCount` counts rows, so a
doubled infinitive (haïr) counts twice. The Models tab's search sends nothing.

**Where a search began** is `finishSearch`'s `source`: `tab` for one typed in the Verbs tab,
Command-F included, or the surface whose search link opened the field (`control`, `quickAction`,
`lookup`, or `deeplink` for a link without a `source`). Without it, a page reached through the
control's search would report only `search`. `SearchTracker.fieldOpened(from:)` holds the surface
for the next search, `fieldClosed()` forgets it if nothing was typed, and a search that the opening
interrupts ends there.

**`matchKind`** is `VerbSearch.MatchKind`'s case by name, through an exhaustive switch
(`analyticsValue` in `SearchReport.swift`), so a new kind cannot go unnamed: `exactInfinitive`,
`exactFoldedInfinitive`, `conjugation`, `infinitivePrefix`, `glossMeaning`, `foldedConjugation`,
`foldedInfinitivePrefix`, `wholeWordGloss`, `infinitiveSubstring`, `foldedInfinitiveSubstring`,
`glossSubstring`; plus `guess` and `none`. An opened guess reports `guess` whether it came from an
infinitive or a conjugation.

### The `source` vocabulary

`AnalyticsSource` is one vocabulary for the verb page's `viewAppeared`, `finishSearch`,
`viewCollection`, and the quiz signals. Values are Konjugieren's names wherever the surface is the
same.

| Value | Sent today? | Meaning |
|---|---|---|
| `browse` | Yes | A row of the verb list with the search field blank |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess at the verb meant, shown when a search finds nothing |
| `modelPage` | Yes | A verb in a model page's list, in the Models tab or in a sheet over a verb page |
| `infoLink` | Yes | A verb linked from an Info article (`?source=infoLink`) |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget (`WidgetDeeplink`, `?source=widget`) |
| `control` | Yes | The Random Verb control in Control Center (`OpenRandomVerbControlIntent`); for `finishSearch`, the Find a Verb control |
| `shortcut` | Yes | Open Random Verb run from the Shortcuts app or as its App Shortcut (`OpenRandomVerbIntent`) |
| `deeplink` | Yes | A `conjuguer://` link with no `source` item, or one outside this vocabulary: a `verb/` link for the verb page, a `search` link for `finishSearch`, a `list/` link for `viewCollection` |
| `resume` | Yes | The same page appearing again (above) |
| `related` | Yes | A verb on a verb page's Related Verbs card, or in its full list |
| `spotlight` | Yes | A Spotlight result |
| `lookup` | Yes | Look Up a Verb, when the word settles one verb. For `finishSearch`, a search the lookup opened |
| `quickAction` | Yes | For `finishSearch` only: a search the Home Screen quick action opened |
| `recent` | Yes | A recent verb in the empty focused search field |
| `myVerbs` | Yes | A verb in My Verbs. For the quiz signals, a quiz over My Verbs |
| `tab` | Yes | For `finishSearch` only: a search typed in the Verbs tab, Command-F included. For the quiz signals, a quiz begun from the Quiz tab; for `tapViewLeaderboard`, the Quiz tab's button. For `viewCollection`, a collection opened in the Models tab |
| `verbPage` | Yes | The quiz signals only: Test Me on a verb page |
| `reviewCard` | Yes | The review card, tapped after its conjugations are revealed |
| `list` | Yes | A verb on a featured collection's page; for the quiz signals, a collection's quiz |
| `sharedLink` | Yes | `viewCollection`: a collection opened from a shared `list/` link. `viewPracticeSet` and the quiz signals: a practice set opened from shared text (§ Practice Sets) |
| `qrCode` | Yes | `viewPracticeSet` and the quiz signals: a practice set opened from its QR code |
| `quizCorrection` | Yes | The verb link in a quiz's held correction (§ Quiz) |
| `custom` | Yes | The quiz signals only: a custom quiz from the Quiz tab (§ The Custom Quiz) |
| `review` | Yes | The quiz signals only: Review, from the Quiz tab (§ Review and My Mistakes) |
| `mistakes` | Yes | The quiz signals only: Practice My Mistakes, from the Quiz tab (§ Review and My Mistakes) |
| `verbEssentials` | Yes | The quiz signals only: Verb Essentials, from the Quiz tab (§ Verb Essentials) |
| `modelAlone`, `modelMixed` | Yes | The quiz signals only: a model's practice, alone or mixed, from its page or the hub's list (§ Model Practice) |
| `recognition` | Yes | The quiz signals only: Name the Conjugation, from the Quiz tab (§ Name the Conjugation) |
| `sentences` | Yes | The quiz signals only: Phrases à trous, from the Quiz tab (§ Phrases à trous) |
| `speedRound` | Yes | The quiz signals only: the Speed Round, from the Quiz tab or its results (§ Speed Round) |
| `daily` | Yes | The quiz signals only: the daily session, from the Quiz tab or its results (§ Daily Session) |
| `reminder` | Yes | The quiz signals only: a daily session begun by tapping the daily reminder (`quiz/daily?source=reminder`) |

**How the source travels.** The verb list pushes a `VerbDestination` (verb and source) rather than
a bare `Verb`, and the cells a search matched (`marks`). A link carries `source` as a query item
(`conjuguer://verb/aller?source=widget`), because a widget or an intent can hand the app only a
URL. `World.resolveDeeplinkEntity` stores it in `World.verbSource` (`URL.analyticsSource`),
falling back to `deeplink`, and the sheets that present `World.verb` pass it to `VerbView`. A model
page passes `modelPage` itself. The link grammar (§ Deeplinks) keeps the item on every route.

**The convention for new surfaces.** A change that adds a way to reach a verb page passes its
value in `VerbDestination`, in a link's `source` item, or directly to `VerbView`, marks it sent in
the table above, and stages its privacy line. The other browse signals are `tapShareVerb`,
`tapStarVerb` (with `starred`, the state after the tap), `source` on `quizStart`, `quizQuit`, and
`quizCompletion`, `viewReviewCard` and `tapRevealReviewCard` (§ The Review Card), and
`viewCollection`, `tapShareCollection`, and `collection` on `quizStart` (§ Collections). The Quiz
tab's View Leaderboard sends `tapViewLeaderboard` with `source` `tab` (§ The Practice Hub). There is
no `tapTestVerb`: Test Me starts its quiz as its sheet appears, so the tap and `quizStart` with
`verbPage` are one event.

## Deeplinks

The app opens `conjuguer://` links from the widgets, the Control Center controls, App Intents, the
Home Screen quick action, Spotlight, Info articles, and model pages. Anything outside the app that
can hand Conjuguer only a URL uses one. There is no web domain, so there are no universal links.

### Grammar

Every route follows one shape. It is Konjugieren's grammar (its `docs/feature_architecture.md`
§ Deeplink System) with Conjuguer's routes.

```
conjuguer://<route>[/<target>][?<item>=<value>&…]
```

- **The route** is the host. It names the kind of place: a verb, the search, a model, an article.
- **The target** is at most one path segment, percent-encoded, naming one thing of that kind: a
  verb's `Verb.verbs` key, a model's identifier, an article's stable key. `search` takes none, and
  every other route takes exactly one (`URL.hasDeeplinkTarget`); a link that breaks this is ignored.
- **Text travels in query items, never in the path**, because it can hold spaces, apostrophes, and
  slashes ("j'ai mangé"). Query items modify a route; unknown ones are ignored.
- **`source`** may follow any route that leads to a verb page, a search, a collection, or a quiz.
  The `quiz` route reads it only for a practice set (`quiz/set`) and a daily session (`quiz/daily`).
  It names the surface that built the link, from `AnalyticsSource`, because a widget or an intent
  can hand the app nothing but a URL. A missing or unknown value counts as `deeplink`.
- **Builders, not literals.** App code builds links with `URL.verbDeeplink`, `URL.searchDeeplink`,
  `URL.infoDeeplink`, `URL.modelDeeplink`, `URL.listDeeplink`, `URL.practiceSetDeeplink`, and `URL.dailySessionDeeplink`, which percent-encode. Only the widget extension and
  `Shared/`, which cannot see `AnalyticsSource`, write literals (`WidgetDeeplink.verb(_:)`, the
  pending links of `OpenQuizIntent`, `OpenRandomVerbIntent`, `OpenRandomVerbControlIntent`, and
  `OpenVerbSearchIntent`), and `DeeplinkTests` pins each literal's source to the vocabulary.

| Route | Target | Query items | Opens | Shipped |
|---|---|---|---|---|
| `verb` | A `Verb.verbs` key (`aller`; `ha%C3%AFr%20France` for one entry of a doubled infinitive), or `random` | `source`; `match`, a conjugation the page marks as it marks a search's match (`verb/aller?match=vais`) | The verb page as a sheet over the Verbs tab (or the Info tab, for an article's link), scrolled to the first marked cell. `random` draws from the 1,000 most frequent verbs, or from My Verbs one time in three (`VerbDraw`). An unknown verb opens the Verbs tab and nothing else; a `match` that fills no cell opens the page unmarked | Yes; `match` is unreleased |
| `search` | None | `q`, the text; `source` | The verb list with its search field, any verb page closed. With text, the results show with the keyboard down; with none (or `q` empty), the field is cleared and focused for typing | No |
| `model` | A model's identifier (`1-1`) | `source`, which a shared model sends as `sharedLink` and nothing reads yet | The model page as a sheet over the Models tab | Yes; `source` is unreleased |
| `info` | A stable key (`futur_simple`), or a legacy position (`info/0`) | None | The article as a sheet over the Info tab. An unknown key or out-of-range position does nothing | Yes; keys are unreleased |
| `quiz` | `set`, a practice set; `daily`, a daily session; anything else (`OpenQuizIntent` sends `quiz/start`) | For `set`: the custom quiz's stored form (`tenses`, and `verbs` or `infinitives`), `level`, `source`. For `daily`: `source` | `set`: the practice set as a sheet over whatever tab is open, never starting a quiz (§ Practice Sets). `daily`: the Quiz tab, which starts a daily session (`World.dailySessionRequest`) unless a quiz is in progress or showing its results (§ Daily Session). Anything else: the Quiz tab, starting a quiz unless one is in progress | Yes; `set` and `daily` are unreleased |
| `list` | A featured collection's key (`top100`, `etre`, `irregularFutur`, `pronominal`) | `source` | The collection's page as a sheet over the Models tab. An unknown key does nothing. A model's collection is reached by its `model/` link, not by `list/model-<id>` | No |

A `match` is read as search reads a query (`MarkedConjugations(text:on:)`, through
`VerbSearch.conjugationMatches`), so it may be anything a search row matched: vais, était, "ai
mangé", or "me suis levé" on lever's page, which marks "ai levé" as a search's pronominal compound
does ([Reverse Lookup](#reverse-lookup)). Look Up a Verb sends the row's own spelling.

### Architecture

| File | Purpose |
|------|---------|
| `URLExtensions.swift` | The grammar's constants (routes, query-item names), `isDeeplink`, `hasDeeplinkTarget`, `analyticsSource`, `deeplinkQueryValue(named:)`, and the builders |
| `World.swift` | `handleURL(_:)` clears `verb`, `verbMarks`, `verbModel`, `collection`, `info`, `searchRequest`, `practiceSet`, and `dailySessionRequest`, resolves the link (`resolveDeeplinkEntity(from:)`), and selects the tab. `handleInAppURL(_:)` resolves without clearing or switching tabs, for links inside Info articles. `openSearch(text:source:)` is the search route's effect, which Command-F also uses (`text` nil keeps the field's text) |
| `Info.swift` | `Info.info(deeplinkTarget:)` resolves a stable key or a legacy position |
| `MatchedConjugation.swift` | `MarkedConjugations(text:on:)` reads a `match` item |
| `VerbBrowseView.swift` | Consumes `searchRequest` on appear and on change, since a link can arrive before the tab first appears, and presents `verb` with `verbSource` and `verbMarks` |
| `ModelBrowseView.swift`, `InfoBrowseView.swift` | Present `verbModel`, `collection`, and `info` as sheets; the Info tab also presents `verb`, for an article's verb link |
| `ModelView.swift` | Intercepts its own `verb/` links (the verbs list, built by `VerbModel.verbsWithDeepLinks`) through an `OpenURLAction` and pushes the verb |
| `InfoView.swift` | Turns an article's links into `info/` or `verb/` links and hands them to `handleInAppURL(_:)`, or to the verb page's article sheet |
| `ConjuguerApp.swift` | Receives links through `.onOpenURL`; a Spotlight result through `.onContinueUserActivity(CSSearchableItemActionType)`, turned into a `verb/` link with `source` `spotlight`; and on each activation, a link that a control's or a shortcut's intent left in the shared defaults (`WidgetConstants.pendingDeeplinkKey`) |
| `QuickActions.swift` | The Home Screen quick action, which hands its `search` link to `handleURL` |
| `Intents/LookUpVerbIntent.swift` | `OpenLookupResultIntent` hands Look Up a Verb's link to `handleURL` |

**The cold-launch race.** A link can arrive before `VerbData` has finished parsing, when
`Verb.verbs` is still empty. `handleURL` then stores it in `pendingDeeplink`, and `ConjuguerApp`
replays it with `drainPendingDeeplink()` once the data has loaded. Every entry point goes through
`handleURL`: `.onOpenURL`, the shared defaults' pending link, Spotlight's continuation, the quick
action (whose scene delegate receives it before any view exists), and Look Up a Verb's result. The
`search` route waits too, so that its request reaches a verb list that has its verbs. An App Intent
that needs the verbs before any window exists awaits `VerbData.ensureLoaded()`, which parses once
however many callers ask.

### Examples

```
conjuguer://verb/aller                                  → aller's page
conjuguer://verb/aller?match=vais&source=lookup         → aller's page at the présent, je vais marked
conjuguer://verb/manger?match=ai%20mang%C3%A9           → manger's page at the passé composé, the compound block shown
conjuguer://search?q=suis&source=lookup                 → the verb list searched for "suis" (être and suivre)
conjuguer://search?source=control                       → the verb list with an empty, focused field
conjuguer://info/futur_simple                           → the Futur Simple article
conjuguer://info/0                                      → the Dedication article (legacy position)
conjuguer://model/1-9                                   → aller's model
conjuguer://list/etre?source=sharedLink                 → the Verbs Taking Être collection
conjuguer://quiz/set?tenses=imparfait&verbs=etre        → a practice set: the imparfait of the verbs taking être
conjuguer://quiz/set?infinitives=parler,venir&level=beginner&source=qrCode → a practice set over two verbs at Beginner's tenses
conjuguer://quiz/daily?source=reminder                  → the Quiz tab, starting a daily session
```

## Lookup from Outside the App

Five surfaces reach Conjuguer from outside the app.

| Surface | Files | What it does |
|---|---|---|
| Look Up a Verb | `Intents/LookUpVerbIntent.swift`, `Models/VerbLookup.swift` | Asks for a word, answers ("vais: Indicatif Présent (je) of aller"), and opens the verb's page, marked, when one verb answers; otherwise the search |
| App Shortcuts | `Intents/ConjuguerShortcuts.swift` | Look Up a Verb, Start Quiz (`OpenQuizIntent`), and Random Verb (`OpenRandomVerbIntent`), with English phrases only |
| Find a Verb control | `ConjuguerWidget/FindVerbControl.swift`, `Shared/OpenVerbSearchIntent.swift` | Opens the empty, focused search (`search?source=control`) |
| Quick action | `App/QuickActions.swift` | "Find a Verb" on a long press of the icon: the same search, with `source` `quickAction` |
| Spotlight | `Intents/VerbEntity.swift`, `Intents/VerbSpotlight.swift` | One entry per verb entry, in the named index `verbs` |

**What Look Up a Verb opens.** `VerbLookup` reads the verb list's own `VerbSearch.matches`, so the
two cannot disagree. An infinitive (folded or not) and a conjugation both answer, and a folded
conjugation (etait) answers only when nothing literal does. One answering verb opens its page with
`match` set to the matched conjugation; two or more (suis: être and suivre), a gloss ("go"), a
misspelling, or nothing opens the search for the word, where the list shows every match or the
guess. At most four verbs are named. An infinitive's answer is its citation form, its gloss, and
its key conjugations with no label ("aller, “go”: va · est allé · ira"); a conjugation's is the
search row's line and the verb ("vais: Indicatif Présent (je) of aller"; French "…, du verbe
aller"). The third person follows the pronoun setting, as the row does.

**Why a second intent.** An intent's result can open the app only by naming another intent, so
Look Up a Verb returns `.result(opensIntent:dialog:)` naming the hidden `OpenLookupResultIntent`,
which hands the link to `World.handleURL`. A shortcut's phrase can carry only an entity or an enum,
never free text, so the intent asks for the word, with autocorrection off and the default keyboard,
which has accents.

**Spotlight.** Each `VerbEntity` (identifier: the `Verb.verbs` key; title: the citation form, "se
souvenir"; subtitle: the gloss) carries the key conjugations as its description, the gloss's
meanings and the key conjugations as alternate names, and every one-word conjugation in the
conjugation map plus the meanings with and without "to" as keywords. Indexing takes several seconds
of the main actor, since the key conjugations need the Conjugator, so
`VerbSpotlight.indexVerbsIfNeeded()` indexes only when the app's version and build, or the entries'
`format` constant, differ from the last index that succeeded. **Raise `format` when the entries
change**, or a development build with unchanged version numbers keeps the old entries. A tapped
result arrives as a `CSSearchableItemActionType` activity whose identifier is "VerbEntity/<key>".

## The Learner's Verbs

One record of the learner's own verbs, kept on the device and never sent: each verb opened (first
and last date, and a count) and each verb starred. Recents, My Verbs, the quiz's My Verbs scope, the
verb of the day, and the collections read it. When a verb is due on the review card is the practice
record's business (§ Quiz, The Practice Record).

| Piece | File | Role |
|---|---|---|
| `LearnerVerbs` | `Shared/LearnerVerbs.swift` | The record: a `Codable` value of entries keyed by `Verb.dictionaryKey`, so that each entry of haïr, ouïr, saillir, and sortir keeps its own opens and star |
| `LearnerVerbStore` | `Models/LearnerVerbStore.swift` | `Current.learnerVerbs`: records, saves each change, and answers in `Verb`s, skipping any key no longer in `verbs.xml` |
| `VerbListMode` | `Utils/VerbSort.swift` | The verb list's picker: Frequency, Alphabetical, My Verbs |

**Where it lives.** The store saves the record as JSON under `LearnerVerbs.storageKey` in the App
Group's defaults (`WidgetConstants.sharedDefaults`, through `GetterSetterReal(userDefaults:)`), so
that the widget can decode it with `LearnerVerbs(json:)` without the verb list. The widget does not
read it today: the app draws the widget's verbs, My Verbs included, when it writes the snapshots.
Unit tests give it a `GetterSetterFake`. **Every field added later must be optional**: synthesized
decoding requires every non-optional key, so a new required field would decode every older record as
nothing, and the learner's verbs would vanish. `LearnerVerbsTests` pins this. No cap on entries.

**An open** is a verb page's arrival by any route: `VerbView.beginVisit` records one whenever it
sends `viewAppeared` with a source other than `resume`. A page that returns after a tab switch,
the background, or its own sheet is not a new open.

**The star** is a button in the verb page's navigation bar, before Share. It reads "Add to My
Verbs" or "Remove from My Verbs" and gives a selection haptic.

**Recents.** While the search field is focused and empty, and anything has been opened, the list
shows the last twenty verbs opened under "Recent" instead of every verb, with the source `recent`.
The arrow keys and Return reach them on iPad and Mac. They, and the accent key row, follow
`searchIsEngaged`, which lets go of the focus 0.7 seconds after the field does: on iPad a tap
outside an empty field ends its focus at touch-down, so views that followed the focus vanished
under the finger (Konjugieren). The push from such a tap waits for the search's dismissal to end
(`ViewControllerTransitions.waitUntilIdle()`), since UIKit drops a push made during it, and an
accent key tapped then waits likewise, sets the letter, and refocuses the field.

**My Verbs** is the third segment of the verb list's picker, with the starred verbs (newest star
first) under "Starred" and the recent verbs not starred under "Recent", whose Clear button forgets
every open and keeps the stars. Search ignores the picker, as it ignores the sort order. Only the
sort order is remembered across launches, so a relaunch shows the list in its order. My Verbs is a
`List` of its own, on iPad too, because only a `List`'s rows can be swiped: a swipe deletes a
verb, star and opens alike (`LearnerVerbs.remove`), since unstarring alone would move an opened
verb from Starred to Recent. A starred verb first asks, in an alert, whether to remove its star;
its swipe button is not `.destructive`, because that role removes the row before the learner
answers. Rows open with the source `myVerbs`.

### The Review Card

Each launch, and each return from the background, the verb list shows one card above its rows when
an irregular verb's key conjugation is due in the practice record (§ Quiz, The Practice Record): the
verb whose key conjugation is longest overdue, captioned by what touched it last ("Looked up 3 days
ago", or "Practiced 3 days ago" when a quiz answer came after the lookup; "yesterday" for one), its
gloss, and its key conjugations hidden under a redacted placeholder over "Recall its conjugations,
then tap to check." A tap anywhere reveals them, red letters and all; a second tap opens the page,
with `source` `reviewCard`, and a chevron says so; ✕ dismisses the card. Nothing replaces a
dismissed card until the next opening, and the card hides while a search, the recents, or My Verbs
shows. On iPad it stops at 560 points rather than spanning the grid. The Suppress Review Card
setting (`ReviewCardSuppression`, Off by default, stored as `reviewCardSuppression`) hides any card
at once and chooses none at later openings; turning it Off chooses one at once. The schedule keeps
running underneath.

**Only irregular verbs** reach the card (Josh, 2026-11-23): a regular verb's answers move patterns
that every verb of its family shares, so a lookup of parler has nothing of its own to schedule. A
verb with no key conjugations, such as accroire, is passed over, and so is a due passé simple, which
the card does not show.

| Piece | Role |
|---|---|
| `PracticeStore.cardOffer(at:)` | The verb and its due shown key conjugations, with the days since and whether a lookup or an answer came last |
| `Views/ReviewCardView.swift` | The card. `VerbBrowseView` chooses the offer, once per opening, and applies each tap to the record |

**What moves a key conjugation** (Josh for Konjugieren, 2026-11-13, carried over). An open of the
verb puts its key conjugations in the first box, due the next day, and so does any later open, since
looking a verb up again suggests it was forgotten. An open from the card itself is the exception
(`recordLookup(_:source:)` with `reviewCard`). Revealing moves each due one up a box
(`recordReview`); one not due keeps its place. Dismissing before revealing is no review: each keeps
its box and returns the next day (`snooze`). Clear in My Verbs forgets the opens and leaves the
practice record. Keys are `Verb.dictionaryKey`s, so sortir's two entries keep their own items.

**Signals.** `viewReviewCard`, once per card shown, and `tapRevealReviewCard`, once per reveal,
with no parameters and no verb. The setting sends nothing.

### Collections

Josh chose (2026-11-22) four featured collections at the top of the Models tab, and every model a
collection on its own page. A collection is a fixed list of verbs a learner can finish and a teacher
can assign. It shows how many of its verbs have been looked up, starts a quiz on itself, and shares
as a link.

| Collection | Key | Verbs |
|---|---|---|
| 100 Most Frequent Verbs | `top100` | `FrequencyBand.top100`, one entry per infinitive: sortir's two share a rank, and only sortir "exit" is kept |
| Verbs Taking Être | `etre` | Auxiliary être and not pronominal: aller, venir, naître, and their kin (38) |
| Irregular Futur Stems | `irregularFutur` | Third-group verbs (`VerbDraw.isIrregular`) and envoyer's model whose radical du futur is not the infinitive (less a final e): ser-, ir-, viendr-, devr-, enverr-. The spelling changes of the first group and prévoir's regular futur are left out |
| Pronominal Verbs | `pronominal` | Every verb `verbs.xml` marks reflexive (217) |
| A model | `model-<id>` | The model's verbs. Shown in the model's page, not in the featured list |

| Piece | File | Role |
|---|---|---|
| `VerbCollection` | `Models/VerbCollection.swift` | The cases, keys, membership (`contains`, `verbs`, cached, most frequent first), titles, descriptions, links, share text, `analyticsValue`, and `QuizScope.collection(_:)` |
| `VerbCollectionDestination` | `Models/VerbCollection.swift` | A featured collection and how it was reached, pushed through `verbPageNavigation` or presented from a link (`World.collection`) |
| `VerbCollectionView` | `Views/VerbCollectionView.swift` | A featured collection's page: title, description, the bar, a Frequency/Alphabetical picker (not stored), and its verbs as rows with a check on each looked up |
| `VerbCollectionBar` | `Views/VerbCollectionView.swift` | "3 of 100 looked up", Quiz, Share, and a progress bar. The collection page has it, and so does every model page, in its verbs card |
| `VerbCollectionRow` | `Views/VerbCollectionView.swift` | A featured collection in the Models tab: a row on iPhone, a card in a grid on iPad, with its count and a progress bar |

**In the Models tab.** A Collections section leads the list, and a Models heading follows it,
while the search field is empty; any text hides both, leaving the results. A row pushes the
collection's page in the tab's stack.

**Progress** counts the verbs with an open (`LearnerVerbStore.openedCount(of:)`), entries rather
than infinitives, so it matches the rows. A star alone does not count, and Clear in My Verbs resets
every collection's progress, since it forgets the opens.

**The quiz** is `QuizScope.collection(_:)`: ten unranked questions, with Ten More, at the learner's level over
the collection's verbs, in a `QuizSheet` over the page, the same sheet Test Me uses, whose title it
replaces with the collection's (`QuizScope.title`). Unlike a My Verbs quiz it starts no Live
Activity, since a tap on the activity would open the Quiz tab rather than the sheet. A collection
none of whose verbs can be quizzed (ester's 1-10, férir's 2-4) shows no Quiz button.

**Sharing** sends the title, the count, the six most frequent verbs in citation form ("se
souvenir"), the link, and the App Store link. A featured collection's link is
`conjuguer://list/<key>?source=sharedLink`; a model's is its existing
`conjuguer://model/<id>?source=sharedLink`, so each model has one link. The share sheet anchors
to the bar's button on iPad (`ShareSheet.present(anchorRect:)`).

**Signals.** `viewCollection` (`collection`, `source`), once per featured page, its return from a
verb page not counted. `source` is `tab` (the Models tab), `sharedLink`, or `deeplink`.
`tapShareCollection` (`collection`). `quizStart` gains `collection` for a collection's quiz. A
model's page keeps its `viewAppeared` and sends no `viewCollection`. Every model sends `collection`
`model`, never its identifier, because a model of one verb (aller's 1-9) would name the verb. A
verb opened from a collection's page has `source` `list`; one opened from a model's page keeps
`modelPage`.

## Quiz

A quiz of ten questions, which Ten More continues by ten more. The learner types each conjugation,
and a missed question is asked once more. A quiz can also ask about chosen verbs (§ Quiz Scopes),
or about tenses and verbs the learner puts together (§ The Custom Quiz). Verb Essentials asks the
key conjugations of irregular verbs (§ Verb Essentials), each model can be practiced alone and
then mixed with the models the learner knows (§ Model Practice), Name the Conjugation asks the
other way round (§ Name the Conjugation), and Phrases à trous asks a conjugation inside a sentence
(§ Phrases à trous). From Elementary up, one question of each default round asks which of two
sentences a speaker would use (§ Choice Questions).

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` quiz state: building the questions, rounds and Ten More (`continueSession()`), re-asks, the timer, scoring, the second attempt a slip or a diagnosis earns (`firstAttempt`, `firstAttemptDiagnosis`), the held correction (`QuizCorrection`), the Live Activity, Game Center, the quiz signals, and VoiceOver announcements |
| `QuizClock.swift` | The Quiz Clock setting, Hide or Show (§ Rounds, Re-asks, and the Clock) |
| `QuizAbandonment.swift` | The quizzes in progress, kept so that the next launch can send `quizAbandon` for one the app was left during (§ Signals) |
| `CustomQuiz.swift`, `CustomQuizView.swift` | The custom quiz: `CustomQuiz` (chosen tenses and a `QuizVerbSet`), its stored form, `QuizScope.custom(_:myVerbs:)`, and the editor and model list the Quiz tab pushes (§ The Custom Quiz) |
| `QuizDraw.swift` | The verbs of a quiz whose verbs were not listed (the default quiz, or a custom quiz over a band): `QuizDraw`, which draws them from a band with a fixed share of irregular, core, and prefixed verbs; `QuizVerbPool`, a kind of verb a tense is asked of, read from the data; and `QuizVerbTraits`, where a model is irregular |
| `QuizLevel.swift` | The four levels, chosen in Settings, and the tenses each asks; `QuizTenseSlot`, a tense as the quiz asks it, with its cells, its weight, and its pools |
| `QuizScope.swift` | What a quiz asks about, its question count, and its analytics source; the questions of a quiz over chosen verbs; `Verb.hasCell(_:)` and `canBeQuizzed(at:)` |
| `QuizQuestion.swift`, `QuizResult.swift`, `QuizState.swift` | A question (verb, tense, and the step it shares with others on one screen), an answered question, and the quiz's lifecycle |
| `VerbEssentials.swift`, `VerbEssentialsRowView.swift` | Verb Essentials: its scope, its draw, the rows of a step, and where a missed blank returns (§ Verb Essentials) |
| `ModelPractice.swift`, `ModelPracticeCard.swift`, `ModelPracticeListView.swift` | A model's practice: what it asks, when a model is known, the draws alone and mixed, the card on a model's page, and the hub's list of models (§ Model Practice) |
| `ConjugationResult.swift` | Grades an answer as a total or no match (`ConjugationResult.grade`), with the conjugation to show beside a right answer spelled another standard way (`AnswerGrade`); a question's result is also `.secondAttemptMatch` when a slip's second attempt was right |
| `AnswerSlip.swift` | Whether a wrong answer is a slip that earns one more attempt (§ One More Try) |
| `AnswerDiagnosis.swift` | Why a wrong answer is wrong, when the Conjugator can say so for certain, as one line (§ Naming the Error) |
| `AnswerFrame.swift`, `AnswerFrameView.swift` | The shape of the expected answer around the field (§ The Answer Frame) |
| `AnswerSpelling.swift` | Reads a typed answer before grading: case, spacing, the typographic apostrophe, and the pronouns of the asked person |
| `AnswerDifference.swift`, `QuizCorrectionView.swift` | The held correction of a wrong answer (§ The Held Correction) |
| `StandardVariants.swift` | Spellings the quiz accepts beside the conjugator's: the 1990 rectifications, a few doublets that dictionaries list, and passer's compound tenses with avoir |
| `CyclingDeck.swift` | Deals a pool's elements in order and reshuffles when it runs out |
| `Shared/PracticeRecord.swift`, `Shared/ReviewSchedule.swift` | The practice record: `PracticeItem`, what an answer exercises, and `PracticeRecord`, a box and a due date per item (§ The Practice Record) |
| `PracticeItemMapping.swift`, `PracticeStore.swift`, `QuizDueItems.swift` | Which item a question exercises; `Current.practice`, which records answers and lookups and offers the review card; and the due items a default round mixes in |
| `QuizView.swift`, `QuizResultsView.swift`, `QuizResultView.swift` | The Quiz tab's practice hub (§ The Practice Hub), the quiz screen, and the results sheet |
| `LastQuizResult.swift` | The last quiz's results, which the hub shows (§ The Practice Hub) |
| `Mastery.swift`, `MasteryView.swift` | What the practice record has mastered at the level: the regular families' patterns, the spelling-change models' own, and the band's irregular verbs (§ Mastery) |
| `ChoiceQuestion.swift`, `ChoiceQuestionView.swift`, `choice_questions.json` | The choice question a default round asks from Elementary up: its items, settings, reasons, draw, and card (§ Choice Questions) |
| `LiveActivities.swift`, `LiveActivitiesReal.swift`, `LiveActivitiesSpy.swift` | Starts, updates, and ends the quiz's Live Activity through `Current.liveActivities`: ActivityKit on device and in the simulator, a spy under unit tests |

### Levels

The learner chooses a level in Settings, and nothing unlocks. Each level adds tenses to the one
before, in the order French courses teach them:

| Level | Roughly | Tenses added |
|---|---|---|
| Beginner (Débutant) | A1 | Indicatif présent; impératif |
| Elementary (Élémentaire) | A2 | Passé composé and the participe passé; imparfait; futur simple; conditionnel présent |
| Intermediate (Intermédiaire) | B1 | Subjonctif présent; plus-que-parfait; conditionnel passé; participe présent |
| Advanced (Avancé) | B2 and above | Futur antérieur; subjonctif passé; passé simple; subjonctif imparfait and plus-que-parfait; passé antérieur; passé surcomposé; impératif passé |

The ladder follows the Université de Genève Maison des langues' grammar outlines ("Éléments de
grammaire A1–A2" and "B1–B2", 2025), the Clermont-Ferrand CASNAV's B1 sheet after the Eaquals/CIEP
inventory of 2015 (the subjonctif at B1, the passé simple at B1 for recognition), and Antwerp's
B2 inventory (the futur antérieur at B2). Josh chose it on 2026-11-23, and with it that every
tense is asked in every person, the literary ones included.

**Weights.** Each question draws a tense by a fixed weight from the level's tenses
(`QuizTenseSlot.drawWeighted`): the présent and the passé composé 3; the impératif, imparfait,
futur simple, conditionnel présent, subjonctif présent, passé simple, and subjonctif imparfait 2;
the other compound tenses and both participles 1. A compound tense other than the passé composé is
light because only its auxiliary is new. A weight belongs to a tense as a whole, whatever its
number of cells, and never changes with what the learner has done. At Advanced the weights total
30, so a plus-que-parfait is one draw in thirty.

**Verbs.** The default quiz asks the verbs of the level's band (`QuizLevel.band`): the 100 most
frequent at Beginner, 300 at Elementary, 1,000 at Intermediate, and all 6,326 at Advanced. A scoped
quiz asks the verbs chosen, whatever the band. `QuizDraw.questions(level:count:using:)` draws every
question's tense by weight first, then fixes what the quiz as a whole asks of its verbs, and only
then draws each question's pool and verb to fit, so that the counts are exact rather than likely:

- **Half irregular.** Half of the questions, rounded up, ask an irregular verb as
  `VerbDraw.isIrregular` counts them: the third group as French schools teach it, which includes
  rendre and attendre, plus aller (Josh, 2026-11-23, as for the verb of the day). Rounded up, since
  the two core verbs are irregular and a draw of nine, beside a round's choice question or a due
  item, would otherwise leave its other questions mostly regular.
- **Core verbs.** At least two questions ask être, avoir, aller, faire, pouvoir, vouloir, devoir, or
  savoir (`QuizDraw.coreInfinitifs`).
- **Prefixed verbs.** A verb with a base (`VerbBase.base(of:)`, as on the verb page) is a
  derivative. One in the 300 most frequent (`QuizDraw.frequentDerivativeBand`) draws as freely as a
  base verb, since revenir and comprendre are as basic as venir and prendre. At Intermediate and
  Advanced, whose bands reach past it, one to three questions, chosen per quiz, ask a rarer
  derivative, and no other question does. At Beginner and Elementary at least one question asks a
  derivative.
- **One entry left out.** Sortir's two entries share its counts, which measure sortir to exit, so
  the default quiz never asks sortir to obtain (`QuizDraw.excludedEntries`), a legal term that
  would otherwise rank #78.

Each question then takes one of its tense's `verbPools` that has a verb fitting its share and
role, and a verb from that pool not yet asked in the quiz where one can be found. Each person comes
from a deck of the six (the impératif's from its three). A pool is a rule read from the data and
applied to the band (`QuizVerbPool.admits`), so that the structure of a tense's questions holds at
every level:

| Tenses | Pools (one drawn per question) |
|---|---|
| Indicatif présent | regular -er (2), regular -ir (2), regular -re, the big three (être, avoir, aller), présent stem changers |
| Passé composé and every other compound tense | regular -er, -ir, -re, the big three, être auxiliaries, irregular participes passés |
| Participe passé | regular -er, -ir, -re, irregular participes passés (2) |
| Subjonctif présent | regular -er, -ir, -re, the big three |
| Imparfait, impératif, participe présent | any verb of the band |
| Futur simple, conditionnel présent | regular futur stems (2), irregular futur stems |
| Passé simple, subjonctif imparfait | regular -er, -ir, -re, the big three, irregular participes passés |

Regular -er is every first-group model but aller's, spelling changes included (manger, appeler);
regular -ir is the second group; regular -re is rendre's model. An être auxiliary is a verb whose
data names être, not a pronominal one. The other pools read the capitals with which the conjugator
marks irregular letters (`QuizVerbTraits`, kept per model): a présent stem changer has a marked
présent cell (je viens, j'appelle, nous mangeons), an irregular futur stem a marked radical
(viendr-, appeller-), and an irregular participe passé a marked participle, among irregular verbs
only, since fichu, maudit, and féru alone would make a pool of oddities whenever a question asks a
regular verb. A question asking an irregular verb draws only from the pools that hold one, so the
big three never answer for a regular question. `QuizDrawTests` pins the band, the share, the core
and derivative counts, the pools' rules, sortir, and that no verb outside the core takes more than
one question in fifty at Elementary and above.

**Settings.** The level is stored under `quizLevel`. A new install starts at Beginner. On the first
launch with levels, a stored `quizDifficulty` of Ridiculous becomes Advanced and anything else
Elementary, the level nearest Regular's mix; the old key is left in place and no longer read once
`quizLevel` exists. Settings shows the levels as four tiles, each with a gauge whose needle rises
with the level, since a segmented control truncates Intermediate and Intermédiaire on an iPhone.
`ChangeLevelTip` invites a change of level after a finished default quiz. Settings attaches its
popover tips only while it is on screen, since the tab stays alive once visited, and a tip that
becomes eligible while it is hidden would float over another tab.

**No question asks a cell the verb lacks.** A drawn person that the verb's defect group marks
unused gives way to the next person the verb has, so falloir is asked only in the third-person
singular. A verb without any cell of the tense, such as faillir in the impératif, is never drawn
for it. `Quiz(gameCenter:seed:)` takes a seed that makes every draw repeatable;
`QuizTests` builds a hundred seeded quizzes at each level and finds no defective cell, and
`QuizLevelTests` pins each level's tenses, the weights, and the pools.

A debug launch argument, `-CONJUGUER_QUIZ_FIXTURE screenshot`, replaces the draw with a fixed plan for
App Store screenshots and exports its answers (see
[`screenshot_playbook.md`](screenshot_playbook.md)). `-CONJUGUER_QUIZ_FIXTURE grading` asks eleven
questions whose right answers exercise the grading below. Typed in order, with
the feminine default: `il connait`, `je parle`, `j'ai parlé`, `nous sommes allées`, `j'étiquète`,
`je cèderai`, `je me souviens`, `souviens-toi`, `êtes`, `il plait`, and `j'ai passé`.
`-CONJUGUER_QUIZ_FIXTURE frames` asks one question for each kind of answer frame, twice over:
`je` (parler), `j'` (aimer), `je` (haïr, aspirated h), `elle`, `elles`, `j' (fém.)` (parler,
passé composé), `nous (fém.)` (aller), `je me`, `je m'` (s'absenter), `tu t' (fém.)`, `(tu) ______-toi !`,
`(nous) ______ !`, `(vous) (fém.) ______ !` (aller, impératif passé), and the two participles.
`-CONJUGUER_QUIZ_FIXTURE corrections` asks eight questions, once, each with a wrong answer that
shows a kind of correction. Typed in order, with the feminine default: `ai parle` and `etes` (the
accent marked), `finisons` (a missing letter, marked only in the right answer),
`allerai` (irai, a different word), `est venu` (the agreement's missing e), `prendent`, `je me
souvient` (the pronouns dropped, the s marked), and `ecrivias` (a missing accent and a swap). The
last holds before the results. All but `ecrivias` are slips or diagnosed errors, so each asks for
one more try first: type it again to reach its correction, where a diagnosed one keeps its line.
`-CONJUGUER_QUIZ_FIXTURE slips` asks twelve questions, once. Typed in order, with the feminine
default, every one earns one more try, which the right answer after it takes for 5 points. These
are slips, which say "Almost!": `etes` (then `êtes`), `ai parle` (`ai parlé`), `prenent`
(`prennent`), and `veus` (`veux`). The rest are diagnosed (§ Naming the Error), and say why:
`achete` (type it again to see the line held in the correction), `placa` (`plaça`), `suis allé`
(`suis allée`, the agreement), `finirions` (finir's conditionnel for its futur), `parle` (the
présent for the participe passé parlé), `prit` (the passé simple for the subjonctif imparfait
prît), `eut` (likewise for eût, under four letters), and `viens` (je's présent for il's vient).
`-CONJUGUER_QUIZ_FIXTURE diagnoses` asks fifteen questions, once, one for each kind of diagnosis.
Typed in order, with the feminine default: `suis allé`, `ai parlée`, `a venue`, `m'ai souvenue`,
`a montée`, `parties`, `sortissent`, `mangons`, `appele`, `venirai`, `faisez`, `finissons`,
`venait`, `prendu`, and `finent`. Each asks for one more try with its line.
`-CONJUGUER_QUIZ_FIXTURE levels` asks eight questions, once, one in each tense only Advanced asks.
The answers, with the feminine default: `aurons fini`, `sois venue`, `prirent`, `fût`, `fusse
partie`, `eut vu`, `ai eu parlé`, and `soyez rentrées`. A fixture's results show the level chosen
in Settings.

### The Answer Frame

The question names the verb and the tense. The person sits beside the field, in the frame that
`QuizQuestion.answerFrame` builds and `AnswerFrameView` draws on one line:

- **A personal tense** shows its subject pronoun, and a pronominal verb's reflexive one, before
  the field: `nous ______`, `je me ______`. The pronoun elides as the expected answer requires
  (`j'`, `je m'`, `tu t'`), through `PersonNumber.preamble`, so it reads as French. That reveals that
  the answer begins with a vowel or a mute h, and, for je in a compound tense, that the auxiliary
  is avoir. Josh accepted the hint on 2026-11-22, since the quiz is practice. The third person
  shows il or elle and ils or elles as the pronoun-gender setting chooses, except for an
  impersonal verb (`Verb.isImpersonal`: falloir, pleuvoir, the weather verbs, apparoir, chaloir),
  which is il and ils under any setting, as on its verb page, in search results, in the widget,
  and in the results' rows (`Verb.pronounGender(for:)`, kept on each `QuizResult`).
- **A compound tense** adds the gender its participle may agree with, `(fém.)` or `(masc.)`, after
  je, tu, nous, and vous, whose pronouns do not show it. It shows for every compound tense, avoir
  verbs included, so that it does not reveal the auxiliary, and for no simple tense.
- **The impératif** shows the person it addresses, `(tu) ______ !`, since tu and vous take
  different answers, and a pronominal verb's `-toi`, `-nous`, or `-vous` after the field.
- **A participle** is a bare field.
- **A sentence** (§ Phrases à trous) puts its own words around the field, in place of the
  pronoun, wrapped word by word.

The frame's words are not graded. A learner who types them anyway (`j'ai parlé`, `souviens-toi`)
is still right, through `AnswerSpelling`. The words are hidden from VoiceOver, and the field's
label reads the frame as one prompt (`AnswerFrame.spokenPrompt`): "je, feminine, blank", with an
elided pronoun read whole and "singular" or "plural" after il, elle, ils, and elles, which sound
alike. `AnswerFrameView` keeps the field outside the `ForEach`es that draw the words, so that the
field keeps its identity, and the keyboard its focus, when the next question's words differ.

### The Held Correction

A right answer advances at once. A wrong one holds its question, after one more try if it was a
slip (§ One More Try)
(`Quiz.correction`): the clock stands still (`Quiz.clockTicked()`), `process(proposedAnswer:)`
ignores further answers, and `continueAfterCorrection()` moves on, to the results after the last
question. Return continues, through the field, which keeps the learner's answer and the keyboard;
the view refocuses the field when it holds, since Return resigns it, and again after Back from a
linked page. The Live Activity's timer cannot pause, so its start date moves later by the time the
clock stood still at each update. Quitting releases a held correction.

`QuizCorrectionView` sits under the answer field, in a card with a red accent:
Your Answer and Correct Answer, a row of links, and Continue, capped at 400 points and centered on
an iPad. `AnswerDifference.nearest` reads the answer as grading does (`AnswerSpelling.candidates`,
so a typed pronoun is dropped) and picks the nearest of the cell's "/" alternates, the first
winning a tie. `AnswerDifference.between` aligns the two with `VerbSearch.editDistance`'s costs and
marks what the cheapest alignment leaves unmatched: a wrong letter or accent on both sides, an
extra letter in the learner's answer, a missing one only in the right answer, and a swap on both
letters. Case is ignored, so a red letter is never a difference. The red letters mark
irregularity, so a difference is a tinted background instead, struck through in red in the
learner's answer and underlined in green in the right one.

**The links** open the verb's page, scrolled to the asked cell and marked (`MarkedConjugations`,
`source` `quizCorrection`), and its model's page. `QuizView` holds its own `NavigationStack`, with
`verbPageNavigation`, whose root hides the navigation bar, so the pages push over the held
question and Back returns to it. In a sheet the pushed pages have no Done, which would close the
sheet without Quit. A quiz begun from the verb's page (`QuizScope.isVerbPage`) leaves out the verb
link. While a quiz is in progress the `isBeneathQuiz` environment value hides Test Me on a pushed
verb page and the Quiz button of a model's collection bar, so that no quiz starts inside a quiz.
After Continue the next question's feedback slot is empty, since the correction has been read.

### One More Try

A wrong answer that is only a slip earns one more attempt before the correction
(`AnswerSlip.isSlip(proposedAnswer:correctAnswers:verb:tense:)`). A slip is within one edit of a
right spelling (an insertion, deletion, substitution, or swap of two adjacent letters, as in
`VerbSearch.editDistance`), or differs from it only in accents, cedillas, and diaereses, however
many: `etes` for êtes, `ai prefere` for ai préféré. The answer is read as grading reads it, so a
typed pronoun is dropped first, and it is compared with every alternate and `StandardVariants`
spelling. The right spelling must have four letters or more, spaces and apostrophes not counted,
so `ete` for été is not a slip, and no compound answer falls under the limit.

**An answer that spells another cell of the verb is not a slip**, however near: `parle` for the
participe passé parlé is the présent, `prit` for prît the passé simple, and `viens` for il vient
the wrong person. `Verb.conjugations(matching:)` decides, and a match in the asked cell itself
does not count, so `suis allé` where the setting asks for suis allée, a participle agreed the
other way, would be a slip, but the agreement's diagnosis comes first (§ Naming the Error).

`Quiz.firstAttempt` holds the slip while the question waits (`isAwaitingSecondAttempt`). The clock
keeps running, since the learner is still answering. The feedback slot shows "Almost! Try once
more.", or a diagnosis's line and "Try once more." (`Quiz.secondAttemptPrompt`), in orange (`Color.secondAttempt`), the first attempt stays in the field to edit, and the
field takes the keyboard back. A chirp and a light tap mark it, not the buzz of a wrong answer. A
question gets one more attempt at most: a right second attempt scores 5 points and the result `.secondAttemptMatch`, shown by a hollow orange check in
the next question's feedback slot, and a wrong one goes to the held correction. The results count
right second attempts apart ("Second Try: 2", under "Correct: 8 / 10", which counts first attempts
only), and a row whose question took two attempts shows "First Try:" with the slip above Your
Answer. The Live Activity's correct count is first attempts only.

### Naming the Error

A wrong answer is diagnosed before it is judged a slip
(`AnswerDiagnosis.diagnose(proposedAnswer:correctAnswers:verb:tense:pronounGender:)`). Every
diagnosis is an exact construction from the verb's own tables, compared with the answer as grading
reads it (`AnswerSpelling.candidates`); nothing is inferred from resemblance, since a wrong
diagnosis is worse than none. The checks run in this order, and the first that fits wins:

| Diagnosis | Example | Line |
|---|---|---|
| `agreement` | suis allé for suis allée | With être, the participle agrees with the subject, here feminine. |
| `agreementWithAvoir` | ai parlée | With avoir, the participle does not agree with the subject. |
| `wrongAuxiliary` | ai allé; est mangé | Aller takes être, not avoir, in its compound tenses. |
| `pronominalAuxiliary` | m'ai souvenu | A pronominal verb takes être in its compound tenses. |
| `auxiliaryWithoutObject` | a monté | Without a direct object, monter takes être, not avoir. |
| `missingAuxiliary` | allée alone | This tense needs an auxiliary before the participle. |
| `otherEntry` | sortissent for sortir (exit) | That is sortir (obtain). The question asks sortir (exit). |
| `spellingChange` | mangons, commencait, appele, achete, cédent, employe | Before a or o, manger keeps an e after the g, so the g stays soft. |
| `futurStem` | venirai, envoyerai, voirions | Venir has an irregular futur stem, shared by the conditionnel. |
| `vousTes` | vous faisez, disez | With vous, faire ends in -tes in the présent. |
| `otherPerson` | finissons for vous | That is the conjugation for nous. |
| `otherTense` | venait for the passé simple | That is the imparfait. (With its persons when the asked one is not among them.) |
| `regularForm` | prendu, ils prendent, a ouvri | That is the regular form, as rendre has it. Prendre is irregular here. |
| `otherGroup` | ils finent, rendâmes, a metté | That is how verbs like parler are conjugated, and finir is not one. |

The auxiliary checks pass over verbs whose other auxiliary is also standard in some sense
(demeurer, accourir, apparaître), and passer, whose avoir is accepted, so j'ai passée is the
agreement with avoir. The être verbs that take avoir with a direct object (monter, sortir, and
eight more) get the line about the object, which stays true of j'ai monté la
valise. The spelling change is read from where parler's conjugation of the verb and the right one
differ, and a difference that is none of the five changes gets no line. The regular and other-group
forms conjugate the verb with parler's, finir's, or rendre's model
(`Conjugator.conjugate(verb:model:tense:pronounGender:)`); another cell of the verb is checked
before them, since a real form the learner recalled is the nearer explanation. Tense names stay
French, and French elides before a vowel ("C’est l’imparfait"), through a second key.

Every diagnosis earns one more try, sharing the slip's mechanism and its limit of one
(`Quiz.firstAttemptDiagnosis`), as Josh chose on 2026-11-23. A right
repair scores 5 points. The held correction shows the diagnosis of the final answer, under the two
answers with a lightbulb, so a repair wrong in some other way may show none
(`QuizCorrection.diagnosis`); VoiceOver reads it after the differing letters. Nothing about a
diagnosis is sent.

### Rounds, Re-asks, and the Clock

**A round is ten questions** (`Quiz.questionCount`), and the results offer **Ten More**
(`Quiz.continueSession()`, "Encore dix"), which appends a fresh draw of ten, so that every round
has the default quiz's mix of irregular, core, and prefixed verbs. A fresh draw passes over verbs
asked earlier in the session while another fits (`QuizDraw.questions(level:count:asked:using:)`).
The score, the clock, and the results list carry on, the progress reads 11 / 20, and the first
question of the new round has an empty feedback slot (`Quiz.lastRoundResult`). Ten More has no
limit. Test Me's three questions offer none (`QuizScope.continues`). In DEBUG, a fixture is asked
again by Ten More.

**A missed question is asked once more** (`QuizQuestion.isReask`), `Quiz.reaskGap` (3) questions
later, or at the round's end, before the results, when fewer remain (`Quiz.reaskPosition`). A
re-ask is not asked a third time, whatever its answer. The correction of a question that will
return says "This question will come up again." / "Cette question reviendra.", and its re-ask shows
an "Asked Again" / "Question reposée" capsule above the verb, as its row in the results does. A
right re-ask scores 5, on either attempt, like a right second attempt (`QuizResult.points`), and
the results count re-asks apart ("Asked Again: 1 / 2", "Questions reposées : 1 / 2") under
"Correct: 8 / 10", which counts the round's own questions. The progress counts re-asks, so a miss
lengthens it (1 / 11).

**The clock** is the Quiz Clock setting (`QuizClock`, `Settings.quizClock`): Hide / Masquer by
default, or Show / Afficher. Hidden, the quiz shows no time, nor do its results, its Live
Activity, or VoiceOver's announcement; the clock still counts. The Live Activity starts with each
round of a tab quiz; its content state carries the session's total, which re-asks and Ten More
grow, and its start date and elapsed time are nil while the clock is hidden, when the Dynamic
Island shows the level in their place. `ChangeLevelTip` is donated, and the level's leaderboard and
best score are reported, at the first round's results only.

### Grading and Scoring

`ConjugationResult.grade(proposedAnswer:correctAnswers:verb:tense:)` compares the answer with each
alternate the conjugator separates with `Tense.alternateConjugationSeparator` ("/"). It first reads
the answer through `AnswerSpelling.candidates`: case, runs of whitespace, and the keyboard's curly
apostrophe are ignored, and so is a leading subject pronoun of the asked person (je or j', tu, il,
elle, or on, nous, vous, ils or elles), so "j'ai parlé" is ai parlé. A pronominal verb's cells come
without their reflexive pronoun (souviens), so "je me souviens", "me souviens", and the impératif's
"souviens-toi" pass as well. No pronoun is stripped before another person's answer, an impératif,
or a participle.

- **Total match** (10 points): equal to an alternate, or to one of its `StandardVariants`. A variant
  is a second standard spelling: the 1990 rectifications (il plait, il connait, mu, j'étiquète, je
  cèderai, sursoirai, absout, interpelons, argüe) and doublets Larousse lists (veuillons, il éclôt).
  Passer's compound tenses also pass with avoir and an unagreed participle (j'ai passé beside je
  suis passée), since passer takes avoir with a direct object and the quiz gives no context; Josh
  chose this on 2026-11-23, for passer alone.
  The conjugator writes some -eler and -eter verbs the traditional way (étiquette) and some the
  rectified way (ruissèle), and either spelling passes, except for the verbs whose traditional
  spelling already has the è (acheter, geler, harceler, modeler). A right answer spelled as a
  variant carries `AnswerGrade.shownSpelling`, the app's spelling, which the quiz shows beside the
  checkmark and VoiceOver announces before the next question. The verb page keeps the app's
  spelling. Josh's rulings, row by row, are in
  [`plans/pedagogy_phase1_variant_audit.md`](../plans/pedagogy_phase1_variant_audit.md).
- **No match** (0 points). An accent is part of the spelling: "etait" for "était" is wrong, and
  so is "etes" for "êtes", since the rectifications drop only the circumflex of i and u, and keep
  it in the passé simple's -îmes and -îtes, the subjonctif imparfait's -ît and -ût, dû, and
  croître. Agreement is required: "sommes allés" where the pronoun-gender setting asks for allées
  is wrong. Many such answers are slips, which earn one more try for half the points (§ One More
  Try).

**The accent keys.** The answer field is an ordinary `TextField`, so `FrenchLetterKeyRow` sits in a
`ToolbarItem(placement: .keyboard)` above the keyboard, unlike the search fields'. The field binds
its `TextSelection`, and a key replaces the selection or inserts at the cursor, then leaves the
cursor after the letter. With a hardware keyboard, iOS draws the toolbar as a floating bar at the
bottom of the screen.

Every level scores 10 a right answer and nothing else: there is no multiplier and no time bonus.
The first round of every default quiz reports its score to the leaderboard of the level the quiz
began at, and keeps it as that level's best score if it is higher: its ten questions without their
re-asks (`Quiz.firstRoundScore`), so that every ranked score has a ceiling of 100. Ten More's points
and a re-ask's are the learner's alone. A scoped quiz does neither (below). Quitting reports
nothing. `Settings` keeps one best score per level (`bestScore(at:)`, `recordScore(_:at:)`, under
the keys `bestScore.<level>`), and the Quiz tab's foot shows the current level's. The one best score
across levels that older installs hold, under the key `bestScore`, is removed at launch, not
migrated, since its level is unknown and it may come from a thirty-question quiz (Josh,
2026-11-23).

**Leaderboards.** One per level, with the IDs `conjuguer.level.beginner`, `.elementary`,
`.intermediate`, and `.advanced` (`QuizLevel.leaderboardID` in `Utils/GameCenter.swift`), which App
Store Connect makes permanent. `GameCenter.reportScore(_:level:)` posts to the level's board, and
`showLeaderboard(level:)` opens it from the Quiz tab's View Leaderboard (§ The Practice Hub). Nothing breaks ties at
100 (Josh, 2026-11-23). `GameCenterSpy` records both calls for tests and the simulator. The boards,
their settings, and what remains for release day are in
[`game_center_setup.md`](game_center_setup.md).

The answer is graded against the question's own verb entry, extra letters included
(`Verb.extraLetters`), so sortir (obtain) is graded as finir-like (il sortit) and sortir (exit) as
partir-like (il sort).

### Quiz Scopes

A `QuizScope` says which verbs a quiz asks about (nil for the default quiz), how many questions it
asks, and its `source`. `Quiz.start(scope:)` defaults to `.allVerbs`, which the Start button and the
`quiz/` link use. A new kind of quiz adds a constructor, as collections added `.collection(_:)` (§
Collections).

| Scope | Questions | Where |
|---|---|---|
| `.allVerbs` | The default quiz at the learner's level | The Quiz tab with All Verbs chosen; the `quiz/` link |
| `.myVerbs(_:)` | 10 at the learner's level over the learner's starred and recent verbs, with Ten More | The Quiz tab with My Verbs chosen |
| `.verbPage(_:)` | 3, on one verb, with no Ten More | Test Me on a verb page |
| `.collection(_:)` | 10 at the learner's level over a collection's verbs, with Ten More | A collection's Quiz button, on its page or a model's page |
| `.custom(_:myVerbs:)` | 10 over the learner's chosen tenses, verbs, or both, with Ten More | The Quiz tab with Custom chosen (§ The Custom Quiz) |
| `PracticeSet.scope(source:)` | 10 over a shared set's tenses and verbs, at the set's level, with Ten More | Start on a practice set's sheet (§ Practice Sets) |
| `.speedRound` | As many as the learner answers in 60 seconds, on mastered items, with Another Round | The hub's Speed Round row (§ Speed Round) |
| `.daily(source:)` | 10 at the learner's level, due items first, with no Ten More | The hub's Daily Session row, its results' Another Session, and the reminder (§ Daily Session) |

**A scoped quiz uses the learner's level.** Each question draws a tense by its weight from the
level's tenses that some verb of the scope has, so a tense no verb has is never drawn and a My
Verbs quiz of only falloir still asks ten. It then takes the next verb from a shuffled deck of
the scope's verbs, and a cell of the tense that the verb's defect group has (`Verb.hasCell`),
preferring a cell not yet asked of that verb. A verb without the tense passes it to the next verb.

**Test Me's three questions** ask three different tenses of the level, drawn by weight without
replacement and without participles, since any passé composé already tests the participe passé.
A verb with fewer tenses (gésir has only the présent and imparfait), or a level with fewer
(Beginner has two), is asked further cells of the tenses it has, then the level's participles
(choir, which has only its participe passé, is asked that from Elementary up). A verb with nothing
at the learner's level cannot be quizzed (`Verb.canBeQuizzed(at:)`), and its page shows no Test Me
button: the six verbs that have only their infinitif (accroire, bayer, and their kin) at any level,
and choir at Beginner. A collection's Quiz button follows the same rule. Random draws go through an
injectable `RandomNumberGenerator`; tests use `SeededRandomNumberGenerator`.

**What a scoped quiz leaves out.** Only the default quiz posts to Game Center, sets the best score,
and donates to `ChangeLevelTip` (Josh's rule for Konjugieren, 2026-11-13). Test Me and a collection's quiz start no Live Activity; a My Verbs quiz
does, being a full round in the Quiz tab.

**Test Me** is a clipboard button (`pencil.and.list.clipboard`) first in the verb page's navigation
bar, before the star. It presents `QuizSheet` (in `QuizView.swift`) through the page's `detailSheet`, so the visit
ends while the sheet shows and resumes after. The sheet holds its own `Quiz`, so a quiz in progress
in the Quiz tab is untouched, and shows `QuizView(sheetScope:)`, which starts the quiz as it
appears, sends no `viewAppeared`, skips Game Center sign-in, and closes on Quit or when the results
close. It cannot be swiped away mid-quiz, so every quiz it starts ends in `quizQuit` or
`quizCompletion`. On iPad it is a form sheet, and a tap outside it does nothing mid-quiz.

**The Quiz tab's picker** (All Verbs, My Verbs, Custom) sits in the briefing card above Start. With My
Verbs chosen, a line says how many verbs the quiz will ask about, or how to add some, and Start is
disabled while the list is empty. The segment chosen is not stored, so the tab opens on All Verbs
at every launch and the default quiz stays the default. Of Konjugieren's filled start screen, only
the fact tiles were ported (§ The Practice Hub); its big scope symbol and its verbs as chips were
not.

### The Custom Quiz

The Custom segment of the Quiz tab's picker lets the learner choose tenses, a set of verbs, or both.
Its briefing shows a summary (Tenses, Verbs), a line saying what Start will do, and Choose or
Change, which pushes `CustomQuizEditor` onto the tab's stack. The editor lists "Set by Your Level"
and the nineteen tenses the quiz can ask, in the order the levels add them, each with its second
name; then "Set by Your Level", the 100, 300, and 1,000 most frequent verbs, every verb, My Verbs
(only while it has verbs or is the choice), the three featured collections other than the top 100,
and Models, a further push (`CustomQuizModelList`) listing every model with verbs in identifier
order. Each tap is kept at once in `Settings.customQuiz`, which Settings does not show.

- **A part left unchosen is the level's.** Tenses alone ask the level's band; a verb set alone asks
  the level's tenses. Any tense may be chosen at any level.
- **A band or every verb is mixed** as the default quiz is, through `QuizDraw.questions(slots:band:…)`
  with the chosen tenses: half irregular, two core verbs, one to three rare derivatives where the
  band reaches them. A collection, a model, or My Verbs is a list (`QuizScope.verbs`), asked as
  § Quiz Scopes describes, over the chosen tenses or the level's.
- **The top-100 collection is offered only as the band**, which holds the same verbs under the same
  key, `top100`.
- **Start is disabled** while nothing is chosen, while a kept choice of My Verbs meets an empty
  list, and while no verb of a list has any chosen tense (falloir's model and the impératif):
  `CustomQuiz.canBeAsked(at:myVerbs:)`. The line under the summary says which.
- **Never ranked.** `QuizScope.isRanked` requires `custom == nil`, so a custom quiz posts to no
  leaderboard, sets no best score, and donates nothing to `ChangeLevelTip`. It has Ten More and a
  Live Activity like any ten-question quiz in the tab. The DEBUG quiz fixtures apply only to the
  default quiz.
- **The stored form** is `tenses=indicatif_present,imparfait&verbs=etre`: a tense's key is its
  article's `Info.stableKey`, and a verb set's is `top100`, `top300`, `top1000`, `all`, `myVerbs`,
  a featured collection's key, or `model-<id>`. The keys are permanent, since the choice is kept
  between launches and can travel in a link. A key that names nothing is dropped and the rest kept,
  except a model's: settings load before the models are parsed, so `model-<id>` is accepted
  unchecked, and a model that names nothing holds no verbs and cannot start.

### Practice Sets

A custom quiz can be shared as a link or a QR code, so that a teacher can hand a class one set
without accounts or a server. With Custom chosen and Start enabled, Share sits beside Change on the
Quiz tab, a menu of Share Link and Show QR Code. Share Link opens the share sheet with a summary
(Tenses, Verbs), a `conjuguer://quiz/set` link, and the App Store link; there is no web domain.
Show QR Code covers the screen with the link's code, made on the device (`QRCode`, Core Image,
medium error correction), dark on white in either appearance, with the summary and a line on
scanning beneath it; the screen stays awake while it shows.

- **Opening a set** (`World.practiceSet`, a `PracticeSetRequest`) shows `PracticeSetView` as a
  page-sized sheet over whatever tab is open, never starting a quiz unasked. It shows the summary,
  a list's verbs as chips (twelve, then "and N more"), Start, which runs the quiz in a `QuizSheet`
  over the set, and Keep as My Custom Quiz, which replaces the learner's custom quiz only when
  tapped. A later link replaces the sheet. Start is disabled, with the custom quiz's "nothing to
  ask" line, when no verb of a list has a chosen tense.
- **The level travels only while a part is left to it**, so everyone who opens a set is asked the
  same tenses and verbs whatever their own level. `QuizScope.level` makes the set's level win over
  the learner's in `slots(at:)`, `band(at:)`, and `Quiz.level`, without touching the setting. A
  kept set, like any custom quiz, uses the learner's level.
- **My Verbs travels as its verbs**, the first 50, in `infinitives=` (`QuizVerbSet.list`, each a
  `Verb.verbs` key, so `ha%C3%AFr%20France` names one entry of haïr). Fifty of the longest
  infinitives, with every tense, still fit a code, where a hundred overflow it: each é takes nine
  bytes percent-encoded. The editor lists a kept list only while it is the choice, since nothing in
  the editor can build one. A stored list keeps keys it cannot check, since settings load before
  the verbs are parsed; a link, read only once they are, drops unknown verbs.
- **The length does not travel.** Every set is ten questions, then Ten More, as Josh decided for
  Konjugieren; a length can be added to the link later without breaking it.
- **Invalid links.** A `quiz/set` link that names no tense or verb set this version knows shows
  "Practice Set Not Found" with a line that the link may be cut short or need a newer app. Unknown
  tenses, verb sets, verbs, a model that names nothing, and an unknown level are dropped and the
  rest kept. A link naming `verbs=myVerbs` drops that part, since it would ask the opener's own.
- **Unranked, in a sheet.** A set's quiz has `custom`, so it posts nothing and sets no best score,
  and like a collection's quiz it starts no Live Activity (`QuizScope.isPracticeSet`), since a tap
  on the activity would open the Quiz tab instead.
- **Signals.** `tapSharePracticeSet` (`method` `link` or `qrCode`, and `customChoice`),
  `viewPracticeSet` (`source`, and `outcome` `opened` or `invalid`), and `tapKeepPracticeSet`. The
  quiz signals of a set's quiz send `source` `sharedLink`, `qrCode`, or `deeplink`, `level` the
  set's, and `customChoice`. None names a tense or a verb.

### The Practice Record

Every final answer, in every scope, moves an item of a record kept on the device and never sent, as
the answer is given, so a quiz quit after six questions has still practiced six. The sad trombone
stays. Settings' Reset Practice (`button_settings_resetPractice`), shown while the record or the
last quiz's result or the Speed Round's best holds anything, erases all three behind a confirmation
and sends `tapResetPractice`.

**Two kinds of item** (`PracticeItem`). The families were Josh's choice, 2026-11-23.

- **A pattern** is a tense and person shared by every verb of a regular family: parler's -er (every
  first-group model but aller's), finir's -ir (the second group), and rendre's -re (rendre's,
  rompre's, and foutre's models; prendre's, battre's, and mettre's are built on rendre's in
  `verbModels.xml`, but are irregular). A spelling-change model has patterns of its own only for
  the cells its change marks with capitals: nous mangeons is manger's pattern and je mange parler's;
  j'appelle and j'appellerai are appeler's and j'appelais parler's. A compound tense is judged by
  its participle, since the auxiliary's own capitals say nothing of the verb, and a compound tense
  conjugated with être, pronominal verbs included, is a pattern apart from avoir's, since it asks
  the agreement. Key: `pattern:1-2B:indicatif_present:fp`, `pattern:1-1:passe_compose:fs:etre`,
  `pattern:2-1:participe_passe`.
- **A key conjugation** is one of an irregular verb's stems: the présent (vient), the passé composé
  (est venu), the futur (viendra), and the passé simple (vint), which the card does not show (Josh,
  2026-11-23). The impératif, the imparfait, the subjonctif présent, and the participe présent count
  against the présent; the participe passé and every compound tense against the passé composé; the
  conditionnel présent against the futur; the subjonctif imparfait against the passé simple. A
  review asks the il form. Key: `key:venir:present`, `key:sortir exit:passe_simple`.

Keys are permanent: changing one orphans every learner's schedule for its item. They name verbs by
`Verb.dictionaryKey`, tenses by `Tense.articleKey`, and persons by `PersonNumber` raw value, so that
the widget, which has no verb list, can read the record.

**The ladder** is `ReviewSchedule`'s, 1, 3, 7, 14, and 30 days, the last repeating, with due dates
at the start of a day. A wrong answer starts an item over. A right one moves it up only when it is
due, so that a pattern asked three times in a session does not climb three boxes in an afternoon. A
new item answered right enters the second box, and one answered wrong the first. A slip's right
second attempt counts as right. A re-ask is another answer: after a miss the item is not due, so a
right re-ask leaves it in the first box.

**Due items in a default round.** Up to three a round (`QuizDraw.dueItemLimit`), the most overdue
first, placed at random among a draw of seven, in Ten More rounds too. Only the default quiz mixes
them in (`QuizScope.mixesDueItems`); a scoped quiz, a custom quiz, and a practice set ask what was
chosen. An item is skipped when the level does not ask its tense (a passé simple below Advanced) or
its verb is beyond the level's band. A pattern is asked of a verb of the band that shares it,
preferring the model's own verbs.

**Where it lives.** `PracticeStore` (`Current.practice`) saves JSON under `practiceRecord` in the App
Group's defaults, through the same `GetterSetterReal` as `LearnerVerbs`. **Every field added to
`PracticeRecord.Entry` must be optional**, as for `LearnerVerbs`.

**The migration.** Browse's review card kept a schedule per verb on `LearnerVerbs.Entry.review`. A
launch with no practice record reads the learner's verbs' JSON at once, before anything can save
them without their old field, and migrates it once the verbs are loaded (`migrateIfNeeded()`, which
`ConjuguerApp` calls after `VerbData.load()`, and every store method calls first), since only the
verbs say which are irregular. Each irregular verb's schedule, or its last open for an entry from
before the card, becomes its shown key conjugations' schedule; a regular verb's is dropped. The
record is saved even when nothing migrates, and Reset saves it empty rather than removing it, so
that no later launch reads the old opens as schedules.

### Review and My Mistakes

Two sessions drawn from the practice record, started from a "From Your Practice" card below the
Quiz tab's briefing card (`QuizRecordSession`, `QuizScope.recordSession`).

- **Review** asks the record's due items, the most overdue first. **Practice My Mistakes** asks the
  items whose last answer was wrong, the most recently missed first
  (`PracticeRecord.missedItems()`); an item leaves once answered right, and a lookup does not clear
  it.
- **What is asked.** A key conjugation asks its il form of its verb, as the review card shows it. A
  pattern asks its cell of a verb from the level's band that shares the pattern
  (`QuizDraw.patternVerb`), or of any verb when the band has none, as it may not for a rare
  spelling-change model. Neither is held to the level's tenses or band, so Review asks what the
  default round's due items leave out (a passé simple at Beginner, a rare verb looked up). A verb's
  due key conjugations sit together in the verb page's order, vient · est venu · viendra · vint,
  at the place of the first drawn.
- **Rounds.** Ten items, then Ten More while an askable item remains that the session has not
  asked. Fewer than ten make a shorter round, whose results say "Correct: 1 / 2". My Mistakes
  needs the exclusion, since a mistake missed again stays a mistake. Re-asks and one more try work
  as in any quiz, and every answer moves the record.
- **Never ranked**, mixing in no due items, and donating nothing to `ChangeLevelTip`. They ask by
  no level (`QuizScope.asksByLevel`), so their results name none, and their Live Activity shows
  the session's name where a quiz shows its level. While a session runs or shows its results, the title row
  reads "Review" or "Practice My Mistakes".
- **The card.** A row with questions shows their count and a play symbol (`quiz_review_button`,
  `quiz_mistakes_button`), and a tap starts the session. An empty row is not a button
  (`quiz_review_empty`, `quiz_mistakes_empty`) and says why: Review gives the days to the next due
  item, or, with nothing scheduled, says that quiz answers and irregular verbs looked up come due a
  day or more later; My Mistakes says that a missed question waits there until answered right. Each
  row is one VoiceOver element, its title and its count or reason, and a startable row has a hint.
- **No counts in the signals.** A session shorter than ten is as long as the learner's due or
  missed items, so its length would count wrong answers. `quizCompletion` omits `questionCount`,
  and `quizQuit` and `quizAbandon` omit `lastQuestionIndex` (`QuizScope.sendsQuestionCounts`);
  `QuizAbandonment.Entry.lastQuestionIndex` is optional.

### The Practice Hub

The Quiz tab, before a quiz, says what a session is, how long it takes, the level, what is due,
and how the last quiz went. From the top:

- **The briefing card**: the symbol, a line on what a session does (a correction for a wrong
  answer, a missed question back later), the scope picker, and for All Verbs and My Verbs three
  tiles: "10 Questions", "2–3 Minutes", and the level. Custom shows its summary in place of the
  tiles. Then Start.
- **The minutes** are a fixed estimate. No timing is kept to derive one, and showing the learner's
  own times would undo the hidden clock. VoiceOver reads "Two to three minutes".
- **The level's tile is a menu** (`quiz_level_menu`) of the four levels, with a chevron to say so.
  It writes the same setting as Settings' level tiles, sends nothing (as Settings sends nothing),
  and counts as the action `ChangeLevelTip` suggests.
- **From Your Practice**: the Daily Session (`quiz_daily_button`, § Daily Session), Review and My
  Mistakes (§ Review and My Mistakes), then **Mastery**
  (`quiz_mastery_button`), whose chevron says it pushes a page (§ Mastery), then **Last Quiz**
  (`quiz_last_result`), absent until a quiz has finished: "All Verbs · Elementary · today", then
  "Correct: 7 / 10 · Second Try: 1 · Score: 75".
- **Exercises** (`quiz_exercises`): ways to practice beside the quiz, each a row like Review's
  (`QuizHubRow`): Verb Essentials (`quiz_verb_essentials_button`), Name the Conjugation
  (`quiz_recognition_button`), and Phrases à trous (`quiz_sentences_button`), which start at
  once, Conjugation Models
  (`quiz_model_practice_button`), whose chevron says it pushes the list of models (§ Model
  Practice), and the Speed Round (`quiz_speed_round_button`, or `quiz_speed_round_empty` while
  fewer than five items are mastered; § Speed Round).
- **The foot**: the level's best score, when there is one, and a small View Leaderboard button
  (`quiz_leaderboard_button`), shown only while signed in to Game Center, which opens the current
  level's board and sends `tapViewLeaderboard` with `source` `tab`. Competing is beside the point
  of practice, so nothing else opens the leaderboard: closing a quiz's results does not.

**The last result** (`LastQuizResult`) is written at each round's results, so after Ten More it is
the session so far, by every scope, Test Me's three questions included. A quit quiz writes
nothing, since its results were never shown. It keeps a kind (`allVerbs`, `myVerbs`, `verbPage`,
`collection`, `custom`, `practiceSet`, `review`, `mistakes`, `verbEssentials`, `modelAlone`,
`modelMixed`, `recognition`, `sentences`, `speedRound`, `daily`) and a verb's `dictionaryKey`, a collection's key, or a practiced model's id rather
than a title, so that it reads in the current language. Review, My Mistakes, a model's practice,
and the Speed Round keep no level, and the Speed Round's row shows no score, since it counts right
answers. `PracticeStore` keeps it as JSON under `lastQuizResult` in the App Group's
defaults, beside the record, on the device and never sent; Reset Practice forgets it, and the
Practice Record card shows while either exists (`hasAnythingToReset`).

### Mastery

The hub's Mastery row ("Maîtrise") reads "Mastered: 10 of 368 patterns · 1 of 50 verbs" and pushes
`MasteryView`, which shows what the practice record has made secure at the current level. Josh
chose its shape on 2026-11-24 from mockups: a display that separates the kinds of item rather than
a grid of verbs against tenses, which would have shown an irregular verb's présent, impératif, and
imparfait as three cells always alike, since they are one item.

- **Three states, each its own shape**: mastered (●, the third box or higher, whose interval is
  seven days, `MasteryState.masteredBox`), learning (◐, any lower box, a lookup included), and not
  yet practiced (○, no entry). A wrong answer sends an item back to learning.
- **Regular Verbs** ("Verbes réguliers"): a card per tense of the level, with a row for each family
  (-er for parler's patterns, -ir for finir's, -re for rendre's) and a mark under each person, or
  one mark for a participle. A compound tense adds an être row for a family whose band verbs take
  être (arriver, descendre, or a pronominal verb), since `PracticeItem` keeps those patterns apart.
- **Spelling Changes** ("Particularités orthographiques"): a card per spelling-change model in the
  `verbModels.xml` order, titled by its exemplar and its first changed form ("lancer · nous
  lançons", the irregular letters in red), with a line per tense that marks only the cells the
  model's change marks. Its other cells are the family's, on the cards above.
- **Irregular Verbs** ("Verbes irréguliers"): the most frequent verbs of the level's band that are
  learned verb by verb, at most fifty (thirty-six at Beginner, whose band holds no more), each
  with its gloss and its key conjugations as far as the level asks: the présent at Beginner, the
  passé composé and futur from Elementary, the passé simple at Advanced. A verb counts as mastered
  once each of those is.
- **Which patterns a level shows**: those a verb of its band can be asked in its tenses, so the
  page and the default quiz agree: 46 at Beginner, 223 at Elementary, 368 at Intermediate, and 901
  at Advanced, about half of them spelling changes. Which patterns exist depends only on a verb's
  model and whether its compound tenses take être, so `Mastery` measures one verb of each kind per
  cell, skipping a defective one, and caches the result per level. Measuring every verb of
  Advanced's band would take seconds; a test measures the other three levels that way and checks
  that the two agree.
- **The page only shows.** A verb links to nothing, since opening its page is a lookup, which
  sends its key conjugations back to the first box.
- **Signals.** The page reports itself through `viewAppeared` with `viewName` `MasteryView`.
  Nothing about the record or the level is sent.

### Verb Essentials

Given an irregular verb, the learner types its key conjugations (§ Copy and Share, Key
Conjugations): the présent, passé composé, and futur simple of the third-person singular, "L’essentiel du
verbe" in French. The three rows show together, each with its tense above it and its own blank in
the answer frame (`elle [ ]`, `elle s' [ ]`), and Return grades the current one.

- **One blank, one question.** A verb is three `QuizQuestion`s sharing a `stepID`, so every quiz
  mechanism applies to each blank unchanged: one more try for a slip or a diagnosis, at half
  points; the held correction, under its row; and the practice record, where each answer moves its
  own key conjugation through `PracticeItem.exercised`.
- **The pronoun follows the setting**, as in any quiz: elle and est venue with the feminine
  default, il and est venu with masculine. The verb page's key conjugations, which stand without a
  pronoun, are always masculine.
- **The field stays put in the hierarchy.** `QuizView` draws the rows before the current one and
  the rows after it as separate children around the one field, so the field keeps its identity,
  and the keyboard its focus, as it moves down a row. An answered row shows the right conjugation
  and its mark, so the feedback slot shows only a request for one more try.
- **What it asks.** Five verbs a round from the level's band (all verbs at Advanced) that are
  learned verb by verb and have all three key conjugations (`Verb.isAskedByVerbEssentials`): aller
  and the third group, but not rendre's verbs, which the record keeps as patterns, nor gésir, nor
  sortir (obtain). Distinct within a session until the band runs out. The level's tenses do not
  apply, so a Beginner is asked passés composés and futurs.
- **Re-asks.** A missed blank returns after the next step, as a step of its own whose other rows
  are given in gray, and a second miss in the same verb joins it (`Quiz.reaskPlacement`).
  Returning three questions later, as elsewhere, would drop it among another verb's blanks.
- **Rounds.** Fifteen questions; the results offer **Five More Verbs** ("Encore cinq verbes") in
  place of Ten More. Never ranked, no due items mixed in, no `ChangeLevelTip`. The results and the
  last result name the level, whose band it drew from. The title row and the Live Activity read
  "Verb Essentials" (`QuizScope.sessionTitle`).
- **VoiceOver.** The verb is announced at a step's first blank only; a later blank announces its
  tense. The field's label begins with its row's tense ("passé composé, elle, singular, blank"),
  and every other row is one element: "indicatif présent, elle, singular, vient, right", or
  "futur simple, elle, singular, not yet asked".
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE essentials` asks venir, se souvenir, faire, prendre,
  and aller, once Verb Essentials is started. Wrong answers worth typing, with the feminine default:
  `a venu` (the auxiliary), `est souvenu` (the agreement), `faira` (the futur stem), `a prendu` (a
  regular participle), and `est allé` (the agreement); each earns one more try with its line.

### Model Practice

Each model can be practiced alone, then mixed with the models the learner knows, from a card on the
model's page (`ModelPracticeCard`, before Verbs Using This Model) or from the hub's **Conjugation
Models** row ("Modèles de conjugaison"), which pushes `ModelPracticeListView`: the models with a
practice of their own, the most used first (by each model's most frequent verb: faire, devoir,
voir), each expanding onto the same card. The practice runs in a `QuizSheet` over either.

- **What a model's practice asks** (`ModelPractice`). A model learned verb by verb (aller and the
  third group but rendre's family) asks Verb Essentials over its ten most frequent verbs that Verb
  Essentials asks. A spelling-change model of the first or second group asks its **marked cells**,
  those the practice record keeps as the model's own patterns (nous mangeons, j'appelle,
  j'appellerai), each of one of its ten most frequent verbs, in rounds of up to ten, unasked cells
  first. Its simple tenses only, without the passé simple and the subjonctif imparfait, as Verb
  Essentials asks no literary tense. Josh chose the marked cells on 2026-11-23.
- **No practice of its own**, and the card says why (`ModelPractice.Absence`): parler's, finir's,
  and rendre's models, which every quiz asks; a spelling-change model with fewer than five marked
  cells (rompre, foutre, férir, ester, haïr's Québec model, ouïr), "This model departs from rendre
  in too few conjugations"; and a model of one verb (aller, être, pouvoir, sevrer), since one verb
  is not a pattern. A one-verb model still joins other models' mixes once known. A model with
  nothing to ask (gésir) shows no card.
- **Known.** At least half of the model's items past the first box of the practice record: three
  key conjugations a verb, or one pattern a marked cell. Computed, not stored, so a wrong answer
  can make a model unknown again. An item already in the record climbs only when due, so a verb
  practiced or looked up earlier the same day stays in the first box, and a model may need a second
  round, or tomorrow. The card and the list show a seal.
- **Mixed** opens once another model of the same kind is known, whether or not this one is (nothing
  is earned). Verb Essentials mixes take three of a round's five verbs from the model and two from
  the known models; a spelling-change mix, six of ten questions and four. Partners are taken one
  model at a time, so a known model of ten verbs does not crowd out one of one, and a short side
  leaves the rest to the other (Josh, 2026-11-23). The two kinds never mix.
- **Sessions.** Titled with the model ("venir (6-7)") or "Mixed: venir (6-7)" ("Mélangé : …");
  the results offer **Another Round** ("Encore une série"), since a round can be short, and name no
  level. Never ranked, no due items, no `ChangeLevelTip`, no Live Activity (it runs in a sheet).
- **Signals.** `source` `modelAlone` or `modelMixed`, with `quizStart`'s `collection` `model`, as a
  model's own quiz sends. A mixed session sends no counts (`QuizScope.sendsQuestionCounts`), since
  its length depends on which models are known, which comes from the learner's answers.
- **VoiceOver.** The card's heading is a header, Alone and Mixed have hints, a closed Mixed reads as
  dimmed with its reason after it, and a known model's row in the list reads "venir, (6-7), Known,
  48% Irregular". The quiz is Verb Essentials or an ordinary quiz and adds no state.
- **Identifiers.** `quiz_model_practice_button`, `model_practice_<id>` (a row of the list),
  `model_practice_alone_button`, `model_practice_mixed_button`, `model_practice_mixed_note`,
  `model_practice_known`, and `model_practice_absence_note`.

### Name the Conjugation

The quiz shows a conjugation, such as fûmes, and the learner types its infinitive and chooses its
tense and person from chips, since typing their names would test the metalanguage. "Identifier la
forme verbale" in French, after the classroom's exercise (Josh, 2026-11-23). It is the direction a
reader needs; the default quiz stays production practice.

- **The prompt** (`RecognitionQuestion`) is the conjugation as the conjugator writes it, irregular
  letters in red, with no subject pronoun. A pronominal verb keeps its reflexive pronoun as French
  writes it (me souviens, s'est souvenue, souviens-toi, se souvenant), so the pronoun narrows the
  person as it would for a reader; its impératif passé, which no text writes, is asked as its passé
  composé. A compound tense of an être verb follows the pronoun-gender setting (est allée).
- **Every right reading is accepted, and no prompt is avoided** (`RecognitionQuestion.cells`). The
  conjugation map names the verbs to try, by each word of the prompt, and each verb's cells of the
  offered tenses are conjugated in both genders and compared: suis is être's je présent and
  suivre's je and tu présent and tu impératif; vis is vivre's or voir's; parle is five cells of
  parler; fait is the participe passé or the il présent. Only the level's tenses count, since the
  learner cannot choose any other.
- **The infinitive** is graded as typed, case and spacing aside, with or without a pronominal
  verb's se (se souvenir, s'absenter, souvenir), and in its 1990 rectification (connaitre), after
  which the traditional spelling shows beside the check, as for a rectified conjugation.
- **The grade** (`RecognitionQuestion.grade`) is judged against the typed verb's cells when the
  infinitive is right, and against every cell otherwise, and calls a part wrong only when changing
  it can make the answer right. An answer with any part right earns one more try at half points,
  with a line naming what to check ("Check the tense." / "Vérifiez le temps."); an answer with
  nothing right goes straight to the correction. A participle has no person to judge.
- **The correction** shows the answer part by part, wrong parts in red and struck through, and
  every right answer, one line per infinitive and tense with the persons together ("parler ·
  indicatif présent · je, il/elle"). The results show the prompt above each row.
- **Not recorded.** Recognizing fûmes is not evidence of producing it, so an answer moves nothing
  in the practice record (Josh, 2026-11-23), and Review and My Mistakes never see it.
- **Rounds.** The default quiz's draw from the level's tenses and band, without due items: ten a
  round, Ten More, a re-ask three questions on. Never ranked, no `ChangeLevelTip`. The results and
  the last result name the level. The title row and the Live Activity read "Name the Conjugation".
- **The screen.** The prompt, then the feedback slot, the tense chips in the verb page's order,
  the person chips once a personal tense is chosen (three for the impératif, none for a
  participle), the infinitive's field, and Check, enabled once all three are given. Return checks
  too, and with a part missing it keeps the keyboard and VoiceOver says what to give. The chips are
  compact, since Advanced offers nineteen; with a hardware keyboard on the iPhone the floating
  accent row still covers Check at Advanced, so Return is the way there.
- **VoiceOver.** The question speaks its prompt ("Conjugation: fûmes"), not a verb and gloss. The
  chips are buttons with the selected trait under headers, the field reads "Infinitive", and the
  correction reads "Incorrect. Your Answer: aller, futur simple, ils/elles. Correct Answer: vivre,
  indicatif présent, je, tu; …".
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE recognition`, used once Name the Conjugation starts,
  offers Advanced's tenses for fûmes, suis, vis, parle, fait, est allée (or est allé), me souviens,
  souviens-toi, finissons, and avions pris. Answers worth trying: `etre` · passé simple · nous for
  fûmes (check the infinitive), être · indicatif présent · tu for suis (check the person), suivre ·
  passé simple · je for suis (check the tense), aller · futur simple · ils/elles for vis (nothing
  right, so the correction at once), and faire · participe passé for fait (right, with no person).
- **Identifiers.** `quiz_recognition_button`, `recognition_prompt`, `recognition_tense_<slot>`
  (`recognition_tense_passéSimple`), `recognition_person_<fs|ss|ts|fp|sp|tp>`, and
  `recognition_check_button`.

### Phrases à trous

A short authored sentence with its verb blanked, so that a conjugation is tied to a meaning:
"Hier soir, nous [ ] au cinéma." "Sentences" in English, "Phrases à trous" in French (Josh,
2026-11-23). A mode of its own, a row in the hub's Exercises; the default quiz asks no sentence.

- **The content** is `gap_sentences.json` (`GapSentence`, `GapSentences`): 750 sentences for the 300
  most frequent verbs, five for each of the first 25 (a présent or impératif, a passé composé, an
  imparfait, futur, or conditionnel, an Intermediate tense, and a passé simple), three for each of
  the next 75, and two for each of the next 200, which Beginner never asks. Each has an id
  (`aller.passéComposé.1`), its verb's key, a `QuizTenseSlot` name and a `PersonNumber` raw value,
  the French with the conjugation in one pair of braces, the English, `reviewed`, and, for an être
  verb's compound tense, `gender`. Claude drafted them (Sonnet subagents, from
  [`plans/gap_sentences.md`](../plans/gap_sentences.md)) and reread every one in place of Josh's
  review, as he chose. The file is written only by `json.dumps(indent=2, ensure_ascii=False)`,
  through `scripts/gap_sentences.py`, which merges drafts (typesetting the narrow no-break space and
  the apostrophe), pre-checks them, writes a review sheet, and approves them.
- **The machine check** (`GapSentenceTests`) confirms that every pair of braces holds the
  Conjugator's conjugation of its cell in the sentence's gender, that the quiz accepts it, that a
  sentence whose answer would vary with the learner's gender setting fixes a gender, that every
  sentence is asked at some level, and that the top 300 have their counts. The person against the
  subject, which the Conjugator cannot see when two cells share a form, is the script's `check`,
  by the subject pronoun before the braces.
- **One blank.** The braces hold the whole conjugation, auxiliary and participle together, and no
  pronoun, so no negation, adverb, or inversion splits a compound tense: "Ce matin, j'{ai fini}",
  never "je n'ai pas fini". A simple tense may stand in a negation ("Je ne {peux} pas").
- **Agreement is the sentence's.** A sentence's subject fixes an être verb's agreement
  (`QuizQuestion.pronounGender`), whatever the setting: "Mes cousines {sont arrivées}". For je, tu,
  nous, and vous in a compound tense the field shows (fém.) or (masc.), from the sentence or, for
  an avoir verb, the setting, as the one-line frame does, so the mark reveals no auxiliary. An
  impératif shows (tu), (nous), or (vous), since "{Viens} dîner chez nous" takes viens or venez
  alike.
- **The screen.** The verb, its gloss, and the tense, then the sentence laid out word by word
  (`AnswerFrameView`, `FlowLayout`) with a compact field of one width, so its width does not hint at
  the answer's length; a word that touches the blank (j', a following "!") stays beside the field.
  The English is below. Grading, one more try, the diagnosis ("Avec être, le participe s'accorde
  avec le sujet…" inside a sentence), the held correction, and the practice record work as in the
  quiz. The correction adds the completed sentence, and each results row shows it.
- **Rounds.** The level's sentences: the verb in the level's band and the tense among its tenses.
  Ten a round, the session's unasked sentences first and one a verb where the pool allows; a short
  pool makes a short round, and Ten More starts over once all are asked. Never ranked, no due
  items, no `ChangeLevelTip`. The results and the last result name the level.
- **Drafts.** A debug build asks unreviewed sentences too, with "Draft" / "Brouillon" on the card
  (`quiz_sentence_draft`), so a new sentence can be tried where a learner meets it; a release build
  asks only reviewed ones. All 750 are reviewed.
- **The literary reward.** Every quiz's results offer the verb's example sentence (the verb page's,
  with its attribution) on the first right row of each verb (`QuizResult.firstRightOfEachVerb`),
  behind an "Example Use" button (`results_example_<verb key>`). The quiz itself never pauses
  after a right answer. The reveal sends nothing, since only right rows offer it.
- **VoiceOver.** The field reads the sentence with "blank" in place of the answer ("Ce couteau,
  blank, à couper le pain"), with the gender or the addressee where the screen shows one. The
  question speaks the verb and gloss, then "Sentence:" and that prompt in French, and the English.
  The correction's spoken text ends with the completed sentence.
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE sentences`, used once Phrases à trous starts, asks ten
  sentences, one for each kind of frame (`Quiz.sentencesFixtureIDs`): viens (tu), sommes allées
  (fém.), ai eu after j', aille, prenant, écoute before a "!", a fallu, fit, êtes venues, and sommes
  restés. Answers worth trying: `sommes allés` for the second (the agreement diagnosis, then one
  more try) and `fait` for fit (the tense named, then the held correction with the sentence).
- **Identifiers.** `quiz_sentences_button` (or `quiz_sentences_empty`), `quiz_sentence_english`,
  `quiz_sentence_draft`, `quiz_correction_sentence`, `results_example_<verb key>`, and
  `results_example_text`.

### Choice Questions

A setting and the same sentence in two tenses or moods, and the learner taps the one a speaker or
writer would use: "Si j'avais plus de temps" or "Si j'aurais plus de temps". Not a mode: from
Elementary up, every default round asks one, Ten More's included, so every ranked round of a level
asks the same mix (`QuizScope.mixesChoiceQuestions`). My Verbs, custom quizzes, practice sets,
Review, and the exercises ask none. The design is Konjugieren's, where Josh chose it on 2026-11-15;
for Conjuguer he chose the five contrasts, about 60 items, and Claude's reread in place of his
review (2026-11-24).

- **The content** is `choice_questions.json` (`ChoiceQuestion`, `ChoiceQuestions`): 66 items. Each
  has an id (`avoir.imparfait.2`, by the right sentence's tense), its verb's key, a `PersonNumber`
  raw value both sentences share, a `gender` where an être verb's agreement shows in either, a
  `setting` (`ChoiceSetting`: conversation, a polite request, a written story, a history book,
  shown in French with its English gloss in the verb's place), a `reason` (`ChoiceReason`), the
  `right` and `other` sentences (each a `QuizTenseSlot` name and the French with the conjugation in
  braces), the English, and `reviewed`. Each sentence reads as a `GapSentence`, so Phrases à trous'
  braces, answer, and completed sentence serve both. The file is written only through
  `scripts/choice_questions.py` (merge, check, review, approve, status); the review sheet is
  [`plans/choice_questions.md`](../plans/choice_questions.md).
- **The reasons.** Eighteen one-line strings (`Choice.reason…`), each fixing the level its items are
  asked from and the tenses its two sentences may take. Elementary (33 items): the passé composé for
  a completed action, the imparfait for a description, a habit, or an action under way; si with the
  imparfait, not the conditionnel; the conditionnel présent after si with the imparfait, the futur
  after si with the présent; the conditionnel of a polite request. Intermediate (24): the subjonctif
  after necessity, a wish, an emotion, bien que, pour que, avant que, or sans que, and doubt; the
  indicatif after penser que, croire que, être sûr que, and espérer que; si with the
  plus-que-parfait, not the conditionnel passé. Advanced (9): the passé simple in a written story
  or a history book, the passé composé in speech.
- **The machine check** (`ChoiceQuestionTests`) confirms that both sentences are the Conjugator's
  conjugations of their cells in the item's gender, that the quiz accepts the right one, that the
  two sentences differ only in their braces (and an elision before them: "Je {travaillais}",
  "J'{ai travaillé}"), that the tenses are the reason's, and that each item is asked from its
  reason's level and not before, which also requires its verb in the level's band. The other
  sentence's tense may be one the level does not ask, since the learner reads it and never writes
  it.
- **The draw.** The typed questions are drawn first, one fewer, so that they come from the
  generator as a round without a choice would draw them; then the choice, the session's unasked
  items first, with the right sentence first or second at random (`ChoicePrompt`), placed anywhere
  but first, so that a round opens on a typed question with the keyboard up.
- **The card.** The setting and its gloss, "Which fits here?" / "Laquelle convient ici ?", the two
  sentences as buttons, each with its conjugation in bold blue and its tense named beneath, and the
  English. A tap holds the card, right or wrong, since a choice of two can be a lucky guess and the
  reason is the lesson: the right sentence ringed green with a check, a wrong choice ringed red with
  a cross, the other dimmed, the reason beside a lightbulb, and Continue (Return on a hardware
  keyboard). The clock stops while it holds (`Quiz.heldChoice`, `isHeld`). After Continue the next
  question's field takes the keyboard.
- **Scoring.** 10 points if right, none if wrong, with no second attempt and no re-ask, since either
  would ask a choice of two whose answer is known. A ranked round still scores out of 100. Choosing
  is not producing, so the practice record is untouched. The results row shows the right sentence,
  the chosen conjugation, and the right one.
- **Signals.** None new: the choice is a question of a default round, whose signals are unchanged.
- **Drafts.** A debug build asks unreviewed items too, with the Draft label; all 66 are reviewed.
- **VoiceOver.** The question speaks the setting in French, its gloss, "Which fits here?", and the
  progress. Each sentence is one button, read as the sentence and its tense; once chosen, its value
  is "Your choice", "The right choice", or both. Focus moves to the reason, read as "Correct." and
  the reason, or "Incorrect. The right choice:", the right sentence, and the reason. Magic Tap
  continues.
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE choices`, used when the default quiz starts, asks ten
  items, the right sentence first and second by turns (`Quiz.choicesFixtureIDs`): si j'avais, ai vu,
  travaillais, voudrais, ira, fasses, viendras after j'espère, avais su, naquit, and est tombée.
- **Identifiers.** `choice_setting`, `choice_prompt`, `choice_option_0`, `choice_option_1`,
  `choice_english`, `choice_reason`, and Continue's `quiz_continue_button`.

### Speed Round

Sixty seconds of questions on what the practice record says is mastered, counting right answers:
speed for material already accurate, the fluency strand of Paul Nation's four, and the one place
where the clock counts. "Speed Round" in English, "Contre-la-montre" in French (Josh, 2026-11-24).
A row at the foot of the hub's Exercises, with a bolt.

- **What it asks.** Items in the third box or higher (`MasteryState.masteredBox`, an interval of
  seven days), in key order, that can still be asked (`SpeedRound.masteredItems(in:)`). Nothing
  is mastered sooner than three days after its first right answer.
- **When it opens.** At five mastered items, repeated as the minute needs (Josh, 2026-11-24, as in
  Konjugieren). Below five, the row is no button and reads "Opens once you have mastered 5 forms,
  those whose next review is a week or more away. So far: 2". Open, it gives the best when there
  is one.
- **The draw** (`QuizDraw.speedRoundQuestions`). Ten at a time, more as the round reaches the last
  of them. Each item is asked once before any is asked again, and never twice running, across
  batches too. A key conjugation asks any cell of its stem that the level's tenses ask of its verb,
  by the tense's verb pools, or its own il cell (`speedRoundCells`): mastered vient asks nous
  venions at Elementary, but never qu'il vienne, which the default quiz never asks of venir. A
  pattern asks its own cell of a verb of the band that shares it, a different one each time where
  there are several, or of any verb where the band has none. Neither is otherwise held to the
  level, since a mastered item stays mastered when the level changes.
- **Answering.** A right answer counts and moves on. A miss moves on at once with the clock
  running: no second attempt, even for a slip or a diagnosed error, no correction, no re-ask. The
  next question shows the missed one's verb and right answer, written out with its pronoun, in the
  feedback slot (`speed_round_miss`, `SpeedRoundMiss`): "venir · (tu) viens !".
- **Nothing is recorded.** A miss does not send an item down the ladder, since speed errors are
  often haste, and a right answer does not move one up, since a record that counted only a timed
  round's hits would be one-sided.
- **The screen.** The bar is the minute; under it a check with the right answers and a timer with
  the time left (`speed_round_right_answers`, `speed_round_time_left`), as symbols, since the words
  wrap in French beside the time. They show whatever the Quiz Clock setting, and the last ten
  seconds are red.
- **The end.** At zero the question on screen and the rest of the batch are dropped, so the results
  list what was answered. The results read "Right Answers in 60 Seconds" over the count, then "New
  personal best!" (`results_speed_round_new_best`) or "Your best: 12"
  (`results_speed_round_best`), the count of the questions answered, and **Another Round**
  (`results_speed_round_again`), which starts a fresh minute with the keyboard up. No level, no
  time, no Ten More, no Live Activity, no Game Center, no best score, no `ChangeLevelTip`.
- **The best.** One personal best on the device, not one per level, kept by `PracticeStore` as
  `speedRoundBest` in the App Group's defaults beside the last result, and forgotten by Reset
  Practice. A round with none right sets none.
- **Signals.** The quiz signals with `source` `speedRound`, without `questionCount` or
  `lastQuestionIndex` (`QuizScope.sendsQuestionCounts`), since a round's length is how many
  questions were answered in a minute. The best is never sent.
- **VoiceOver.** Each question is announced as in the quiz, preceded after a miss by "Incorrect.
  The answer was:" and the answer in French, and followed by the right answers and the seconds
  left in place of the progress and score. "Ten seconds left." at ten, and at the end "Time is up.
  Right answers: 12." with the best. The miss line, the count, and the time are each one element
  read in words.
- **The fixture.** `-CONJUGUER_QUIZ_FIXTURE speedRound` opens the round whatever the record holds,
  on eight items (`SpeedRound.fixtureItems`): parler's je présent, finir's nous présent, rendre's
  ils imparfait, manger's nous présent, arriver's il passé composé (an être pattern), and venir's
  présent, faire's futur, and être's présent key conjugations. A round on it still writes the
  device's best and last result.

### Daily Session

Ten questions a day at the learner's level, a streak that one missed day does not break, and an
optional reminder. "Daily Session" in English, "Séance du jour" in French. The first row of From
Your Practice, with a calendar, or a flame once there is a streak.

- **What it asks** (`QuizScope.daily(source:)`, in `DailySession.swift`). The default quiz's draw,
  with the record's due items in place of its three: those the level asks and the band holds, most
  overdue first, up to all ten (`QuizScope.dueItemLimit`), so a passé simple due below Advanced
  waits for Review. **No choice question**, since a choice moves nothing in the record, and **no
  Ten More**: a second session is a session of its own, which a repair counts. Never ranked; it
  starts a Live Activity, as a ten-question quiz from the tab does. A quit session does not count.
  The `-CONJUGUER_QUIZ_FIXTURE` fixtures apply to it as to the default quiz.
- **The streak** (`DailyStreak`), kept by `PracticeStore` as JSON under `dailyStreak` in the App
  Group's defaults, beside the practice record. It stores finished sessions per calendar day and
  computes the streak from them. Its length is days practiced. **One missed day is repaired by two
  sessions the day after**, and the bridged day does not count; one session on that day starts a
  run of its own and shows as a repair in progress, and if the day ends there, the old streak is
  gone. Only the last two runs are kept. Days are counted in the calendar, so a 25-hour day is
  one. Reset Practice forgets the streak.
- **The hub's line** follows the status: the session's description; "Streak: 3 days. Today's
  session keeps it going." or "… Done for today."; "You missed yesterday. Two sessions today keep
  your 3-day streak."; "One more session today keeps your 3-day streak." The row always starts a
  session, a second on an ordinary day changing nothing.
- **The results** show the streak (`results_daily_streak`) under the score. While a repair awaits
  its second session they offer **Another Session** (`results_daily_another`) in Ten More's place.
- **The reminder.** Settings' Daily Reminder card, after Quiz Clock: Off or On
  (`picker_settings_dailyReminder`), and while on a time (`picker_settings_dailyReminderTime`),
  18:00 by default (`Settings.dailyReminder`, `dailyReminderMinutes`). Permission is asked only on
  turning it on; refused, the setting stays Off with a red line
  (`label_settings_dailyReminderDenied`) and Open Settings
  (`button_settings_openNotificationSettings`), which also show while On if notifications were
  later turned off in the Settings app. `DailyReminderPlan` schedules **one notification a day for
  14 days** rather than one that repeats, so that each can say what that day will have due ("Your
  daily session is ready, with 11 conjugations due for review.") or that its streak needs repair,
  and so that a day whose session is done gets none. `World.rescheduleReminders` replaces them when
  the setting or the time changes, a daily session finishes, practice is reset, the verbs finish
  loading, and the app becomes active or goes to the background; a learner away for two weeks stops
  being reminded. `ReminderScheduler` has `ReminderSchedulerReal` (the notification center) on the
  device and the simulator, and `ReminderSchedulerSpy` under unit tests.
- **Tapping a reminder** opens `conjuguer://quiz/daily?source=reminder`
  (`ReminderNotificationDelegate`, set in `AppDelegate`), which sets `World.dailySessionRequest`;
  the Quiz tab starts the session on appearing or on the request's change, unless a quiz is under
  way or showing results. A reminder due while the app is open shows nothing.
- **Signals.** The quiz signals with `source` `daily` or `reminder`, with `questionCount` as the
  default quiz sends it. `quizCompletion` adds `streak` (`1`, `2-6`, `7-29`, `30+`), the streak at
  stake while a repair is pending. `tapDailyReminder` carries `enabled`: `true`, `false`, or
  `denied` for a learner who turned it on and refused permission.
- **VoiceOver.** The row reads its title and line, with a hint; at the results, the streak line is
  spoken; Another Session has a hint. The widgets do not show the streak.

### Signals

`quizStart` (`level`, `source`), `quizQuit` (`level`, `lastQuestionIndex`, `duration`, `source`),
`quizCompletion` (`level`, `questionCount`, `duration`, `source`), and `quizAbandon` (`level`,
`lastQuestionIndex`, `source`). `source` is `tab`, `myVerbs`, `verbPage`, `list`, `custom`, `review`, `mistakes`, `verbEssentials`, `modelAlone`, `modelMixed`, `recognition`, `sentences`, `speedRound`, `daily`, or `reminder`, so a
three-question quiz does not inflate the ten-question quiz's completion rate.

- **No signal carries a score or a count of right or wrong answers.** `lastQuestionIndex` is the
  question reached, from zero across the session's rounds, re-asks not counted: a re-ask is
  inserted only after a miss, so a position that counted re-asks would tell how many answers were
  wrong.
- **`duration`** is the wall-clock time from the session's start to the quit or the results,
  background included, in `AnalyticsBand.quizDuration`'s bands: `0-3s` (exploring), `3-15s`,
  `15-40s`, `40s-2m`, and `2m+` (a struggle, or a session of several rounds).
- **`quizCompletion`** is sent at each round's results, with `questionCount` the session's
  questions so far (10, 20, …), so Ten More shows without a signal of its own and Ten More itself
  sends no `quizStart`.
- **Review and My Mistakes** send neither `questionCount` nor `lastQuestionIndex` (§ Review and
  My Mistakes), nor does a mixed model practice or the Speed Round (§ Speed Round).
- **A daily session's `quizCompletion`** also carries `streak`, in `AnalyticsBand.streak`'s bands
  (§ Daily Session).
- **`quizAbandon`** reports a quiz the app was left during. `QuizAbandonment` keeps one entry per
  `Quiz` in settings, written at the start and at each question and removed at a quit or the
  results, so an entry still there at the next launch belongs to a quiz that ended with the app.
  `ConjuguerApp.init()` sends one `quizAbandon` per entry and clears them. Entries are keyed by
  quiz, since a sheet's quiz can run beside the tab's. `level` is `beginner`, `elementary`, `intermediate`, or `advanced`, the
quiz's own, set when it starts, so a change in Settings mid-quiz cannot mislabel its quit or
completion. A collection's
`quizStart` also carries `collection` (§ Collections), and so does a custom quiz over a featured
collection or a model, which sends only `model`. A custom quiz's `quizStart` carries
`customChoice`: `tenses`, `verbs`, or `both`, which says what kind of choice was made without
saying which tenses or verbs.

## Widgets

The `ConjuguerWidget` extension holds two widgets, three Control Center controls, and the quiz's Live
Activity (`ConjuguerWidgetBundle`). It bundles only `Shared/` and `ConjuguerWidget/`, with no
conjugator and no verb data, so it shows what the app last wrote.

### Architecture

| File | Purpose |
|------|---------|
| `WidgetSnapshotWriter.swift` (app) | Writes seven daily `WidgetSnapshot`s, today first, to the App Group container, and reports whether the bytes changed so that `ConjuguerApp` reloads timelines only then |
| `WidgetSnapshot.swift` (`Shared/`) | The serialized verb and quiz question for one day |
| `WidgetConstants.swift` (`Shared/`) | The App Group, the snapshot file, and the shared-defaults keys (the quiz widget's answer, the pending deeplink) |
| `SnapshotReader.swift` | Reads the snapshots in the widget |
| `VerbDuJourWidget.swift` | The verb of the day: small, medium, large, and the rectangular and inline accessory families. One timeline entry per cached day |
| `QuizWidget.swift`, `AnswerQuizIntent.swift` | The daily quiz question, small and medium, with buttons that grade the tapped answer in place |
| `QuickQuizControl.swift`, `RandomVerbControl.swift`, `FindVerbControl.swift` | Control Center controls. Their intents (`OpenQuizIntent`, `OpenRandomVerbControlIntent`, `OpenVerbSearchIntent` in `Shared/`) store `conjuguer://quiz/start`, `conjuguer://verb/random?source=control`, or `conjuguer://search?source=control` in the shared defaults and open the app, which drains it on activation |
| `QuizLiveActivity.swift` | The quiz's Lock Screen and Dynamic Island presentation |
| `WidgetDeeplink.swift` | The verb widget's link to the verb's page |

### Choosing the Verb

`VerbDraw` chooses the widget's verb and every random verb (the control, `verb/random`, the
shortcut). The pool is `FrequencyBand.top1000`, the 1,000 most frequent infinitives (1,001 entries,
since sortir's two share a rank), weighted so that an irregular verb counts double and so does a
base verb: aller, venir, and faire count 4, apprendre and parler 2, rappeler 1. Irregular means the
third group as French schools teach it, models outside groups 1 and 2 plus aller
(`VerbDraw.isIrregular`), so the spelling changes of manger and appeler do not count. A base verb is
one `VerbBase.base(of:)` finds no base for. That reads the etymology in the device's language, but
on 2026-11-22 the English and French texts gave the same answer for all 1,000 verbs, so the draw
does not depend on the language.

Once My Verbs has entries (starred verbs, then the last 20 opened), it supplies one draw in three.
For the widget, that is every day whose number since 2025-01-01 is a multiple of three, taking My
Verbs in turn. Other days draw from the band with SplitMix64 (`SeededRandomNumberGenerator`)
seeded with the day number, so a day names the same verb in any process. A random verb has a
one-in-three chance of coming from My Verbs. A random verb opened is a recent verb, so it can
return as a My Verbs draw until it ages out of the recents.

`WidgetSnapshotWriter.writeSnapshots()` runs at every activation, and My Verbs may have changed
since the last write. So it first reads the bundle on disk, finds the snapshot for today
(`displayedVerb(in:on:)`), and keeps that verb for today in the new bundle. The six days after it
are drawn afresh. `isEligible` still requires an example sentence, which every verb has today.

The quiz question uses the day's verb, with a person and one of six tenses (présent, passé
composé, futur simple, imparfait, subjonctif présent, conditionnel présent) chosen from the day
number, and three wrong answers drawn from the verb's own other conjugations before any filler.
Because today's verb is kept, so are its question ID and the answered state the quiz widget
stores against it. A change of the pronoun-gender setting rewrites the snapshots.
