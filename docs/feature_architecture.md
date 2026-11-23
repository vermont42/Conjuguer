# Feature Architecture

How Conjuguer's feature systems work, one section each. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md) (the
**browse plan**), modeled on Konjugieren's document of the same name. It starts by describing what
the app does today, briefly, and the phases of the browse plan and of
[`plans/pedagogy_implementation.md`](../plans/pedagogy_implementation.md) extend it as they build.
Keep it true: a section that describes code that has since changed misleads the next session more
than a missing section would.

## Search

The Verbs and Models tabs each show a list with a search field and a sort picker. Since Phase 1 of
the browse plan (2026-11-22), one function, `VerbSearch.matches`, matches and ranks verbs for both,
and later callers (reverse lookup, Spotlight, the Look Up intent) are to use it too.

### Architecture

| File | Purpose |
|------|---------|
| `VerbBrowseView.swift` | The Verbs tab: the list (a `List` on iPhone, a `LazyVGrid` of cards on iPad), the sort picker, the search field, and the verb count. `VerbBrowse.makeStore` builds the store |
| `ModelBrowseView.swift` | The Models tab, built the same way. `ModelBrowse.makeStore` builds the store |
| `BrowseStore.swift` | A generic `@Observable` store that holds a list presorted for each sort order and persists the chosen order through a closure |
| `BrowseSearch.swift` | `BrowseSearch.results(in:query:playSoundIfEmpty:search:)`: every item for a blank query, otherwise what the tab's search closure returns, with a sad trombone when that is nothing |
| `VerbSearch.swift` | The matching and ranking rule. `MatchKind` names each kind of match, for Phase 3's `matchKind`. Also the guess |
| `VerbSearch+Conjugations.swift` | Reverse lookup (Phase 5): a conjugation, simple or compound, finds its verbs |
| `ConjugationQuery.swift` | A query as a conjugation's words: subject and reflexive pronouns, elision, que, y, en, and negation dropped |
| `ConjugationIndex.swift` | The conjugation map indexed by folded spelling, and the packed folds the guess measures; `BoundedEditDistance` |
| `MatchedConjugation.swift` | The conjugation a result matched, its cells, the row's line ("vais: Indicatif Présent (je)"), and the `MarkedConjugations` a page opens with |
| `ModelSearch.swift` | Finds a model by its exemplar or by any of its verbs, through `VerbSearch` without glosses |
| `FailedVerbSearchView.swift` | The verb list's empty state: `ContentUnavailableView.search`, the guess, and the line asking the learner to email a missing verb |
| `VerbSearchCommands.swift`, `VerbSearchArrowKeys.swift` | Command-F, and the arrow keys through results, on iPad and Mac |
| `FrenchLetterKeyRow.swift` | é è ê â î ô û ç keys, with an `insert` closure so the quiz's answer field can adopt it |
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
  `ContentUnavailableView.search`. The Verbs tab shows `FailedVerbSearchView` (since Phase 2): the
  same view, then a guess, then "If you believe that “…” is a French verb, please email
  vermontcoder@gmail.com", whose address is a `mailto:` link (`URL.mailto`) with the subject and
  body filled in with the query in the learner's language. A device that cannot open the link,
  such as the simulator, copies the address to the clipboard instead and says so for four seconds.
- **The guess.** `VerbSearch.guess` folds the query as search does (reflexive pronoun dropped,
  accents and ligatures folded) and measures optimal string alignment distance (Levenshtein plus a
  swap of two adjacent letters) to every folded infinitive and, since Phase 5, to every folded
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
  calls `World.openVerbSearch()`: it closes any deeplinked page, switches to the Verbs tab, and sets
  `verbSearchIsRequested`, which `VerbBrowseView` answers by popping any pushed verb page (waiting
  500 ms for the pop, or the focus does not take) and focusing the field, keeping its text.
  **↑ and ↓** move a highlight through the results in reading order (a red accent bar on a card, a
  red tint on a list row), stopping at either end; the first ↓ lands on the first result. They need
  `VerbSearchArrowKeys`, a `UIKeyCommand` on the window's root view controller installed only while
  the verb field is focused, because a focused text field consumes them ahead of every SwiftUI
  mechanism. **Return** opens the highlighted result, else the first, else the guess. Return and the
  arrows act only on the iPad idiom (which a Mac running the iPad app also reports) and only while
  the field holds a query, so the iPhone keyboard's Search key behaves as before.
- **Cost.** One search over 6,330 verbs takes about 20 ms on the Intel simulator, and about 50 ms
  with reverse lookup, in a Debug build. `VerbSearch` caches each verb's folded keys after the
  first search.

The table in the browse plan's **Conjuguer Today** section lists what typical queries returned
before Phase 1.

### Reverse Lookup

Since Phase 5 of the browse plan (2026-11-22), a conjugation finds its verb, through the map
([Conjugation Map](#conjugation-map)) indexed by `ConjugationIndex`.

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

A tap in the Verbs tab appends a `VerbDestination` to the tab's `NavigationPath`. A deeplink
instead sets `Current.verb`, which the Verbs tab presents as a sheet (see
[Deeplinks](#deeplinks)), and the Info tab does the same for a verb link in an article. Since
Phase 7, every page that leads to another (a related verb, the model row, a model page's verb
links) pushes it onto whichever stack shows it, through `VerbPagePush`; see
[Related Verbs](#related-verbs).

## Verb Page

Phase 6 of the browse plan (2026-11-22) ordered the cards, named them twice, and gave each an
article. It ports Konjugieren's Phase 7.

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

Each card's heading is the tense's French name, as before, then a red question-mark diamond, the
model page's button for the irregularities article, which opens the tense's Info article. Under
the name is a second name in the app's language: "also simple past" in English, "aussi passé
défini" in French, each the name its learners' textbooks use (Josh, 2026-11-22). Nine French
tenses have no French alternate, and their catalog value is empty, so no line shows. The
personless card gives each of its three cells such a heading.

**The article** opens in `TenseArticleSheet`, so closing it returns to the same verb. A link
inside to another article or to a verb pushes it inside the sheet, and a verb page there pushes
its own articles rather than presenting another sheet (the `tenseArticleOpener` environment
value). `InfoView` takes an optional `openLink` for this; without one, its links go to
`World.handleInAppURL` as before.

### The Compound Block

The "Show Compound Tenses" toggle starts on, and the learner's choice is stored
(`@AppStorage("showsCompoundTenses")`), so a learner who hides the block finds it hidden on the next
page and after a relaunch (Josh, 2026-11-22). A search that matched a compound tense shows the block
on that page anyway, and touching the toggle there stores the new choice.

### The Color Key and the Scroll Tip

The color-key card shows until dismissed (`hasSeenConjugationColorKey`), and since Phase 6 only on a
page whose verb has red letters of its own, in its simple tenses or personless cells (Josh,
2026-11-22). Every compound tense has red letters in avoir's or être's forms, so this test leaves
them out: parler's page shows no key. In the key's place, `ScrollToBottomTip` points to the
etymology and examples. A page that appears after the key was dismissed unlocks it (a persisted
TipKit parameter), so the two never appear one straight after the other, and reaching the
etymology or the examples retires it. Both obey `TipDisplay.tipsEnabled`.

## Related Verbs

Phase 7 of the browse plan (2026-11-22) gave the verb page a way to other verbs, and the model
page a frequency order. It ports Konjugieren's Phase 9.

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
mettre 16). Of the 300 most frequent verbs, the 65 with a base are all right. Thirteen are
compounds formed in Latin whose meaning has drifted (attendre on tendre, demander on mander,
rester on the archaic ester), and Josh kept them (2026-11-22), as Konjugieren kept verstehen with
stehen. allier is built on lier by the same reasoning (Latin alligare, ad + ligare), though the
plan named it as a false pair. The rule reads the etymology in the app's language. Every pair
appears in both languages today, so the families are the same in French and English.

### The Card

Josh chose the bottom of the page, below the examples, from screenshots (2026-11-22). Two rows,
each of up to six chips:

- **Built on prendre**: the root verb first (for a doubled root, the entry that shares this verb's
  model, so ressortir leads to sortir "exit" and assortir to sortir "obtain"), then the family by
  frequency. More than six adds "All 11", which pushes `RelatedVerbListView`, Frequency first, with
  an Alphabetical control. The choice is not stored.
- **Same model: venir (6-7)**: the most frequent verb of each other root in the model, by frequency
  (tenir, appartenir on venir's page; donner, trouver, passer on parler's). Konjugieren showed the
  root verb of each ablaut root. Here the most frequent verb wins, so demander rather than mander
  speaks for its root. "All 29" pushes the model page in frequency order. The row is hidden when the
  model holds only this verb's family (prendre's 5-2). The model row at the top still leads there.

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

A segmented control above "Verbs Using This Model" chooses Alphabetical (the default) or
Frequency. The choice is not stored. The list stays a run of `conjuguer://verb/` links in one
`Text` (Josh, 2026-11-22), since model 1-1 has 4,859 verbs and Konjugieren saw about 1,000 rows in
a non-lazy stack peg the CPU. Alphabetical now uses French collation (`Util.french`). The old plain
sort put écouter after the z's.

## Copy and Share

Phase 8 of the browse plan (2026-11-22) let a learner copy a conjugation and share a verb. It ports
Konjugieren's Phase 10.

### Architecture

| File | Purpose |
|------|---------|
| `Models/KeyConjugations.swift` | `Verb.keyConjugations()`, `Verb.keyTenses`, `Verb.citationInfinitif`, and `Verb.shareText()` |
| `Utils/ShareSheet.swift` | Presents `UIActivityViewController` with an `LPLinkMetadata` header, and on iPad anchors its popover to the share button |
| `Utils/Modifiers.swift` | `copyOnLongPress(_:)`: a context menu with Copy, and a VoiceOver action of the same name |
| `Utils/URLExtensions.swift` | `URL.appStore`, the App Store page with no storefront, so the App Store opens the reader's own |

### Key Conjugations

The il forms of the présent, the passé composé, and the futur simple, in that order (Josh,
2026-11-22): "vient · est venu · viendra". They stand with no label, here and wherever a later
phase shows them. The participle agrees with il whatever the pronoun-gender setting, because no
pronoun stands before it. A reflexive verb keeps its pronoun, elided as its cells elide it
(`PersonNumber.thirdPersonReflexivePronoun`): "se souvient · s'est souvenu · se souviendra". A
form the verb's defect group marks unused is left out, so falloir gives all three, gésir gives
only "gît", and accroire gives none. The function returns mixed case, as the Conjugator writes it,
so a caller can show red letters (the auxiliary's irregular letters are capitals too); the share
text lowercases them. Phase 9's Spotlight entries, Phase 13's review card, and the pedagogy plan's
key-conjugations exercise read `Verb.keyTenses` and this function.

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
lowercase and without the pronoun beside it ("vais", "suis allée", "souviens-toi"), as Konjugieren
copies "stehe auf". A long press on the infinitive at the top copies it. An empty cell copies
nothing; a form struck through as unused copies, since it is shown. A tap does nothing, as before:
nothing on the verb page speaks.

## Conjugation Map

Since Phase 4 of the browse plan (2026-11-22), the app bundle carries every one-word conjugation
of every verb, mapped to the verbs it belongs to, so that search can start from a conjugation:
vais finds aller, and suis finds être and suivre. Phase 5 builds the search on it. Nothing in the
interface reads it yet.

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
`ConjugationLabels.swift` default it to the setting. A core file that starts reaching `Current`,
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
- **The format** is one line per conjugation, `suis⇥suivre⇥être`, sorted by UTF-8 bytes,
  compressed with LZFSE: 242,966 conjugations, 5.0 MB of text, 615,655 bytes in the bundle, built in
  about 3.5 seconds by the Release tool. (Konjugieren's holds 50,056 conjugations in 173 KB.)
  (Figures as of 2026-11-22, after béer's and douer's defect groups were corrected.)
  `sorted()` is not used, because it left 155 keys out of order, and two builds of the same
  data wrote different bytes.
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

Built in Phase 3 of the browse plan (2026-11-22), ported from Konjugieren's Phase 3. Names match
Konjugieren's where the signal is new, so the apps can be read side by side; the verb page's
arrival keeps Conjuguer's `viewAppeared`, so that TelemetryDeck's history of verb pages stays one
series.

| Signal | Parameters | Sent |
|---|---|---|
| `viewAppeared` with `viewName` `VerbView` | `source` (below) | When a verb visit begins: the page arrives, or returns with `source` `resume` after another tab, its own model sheet, or the background |
| `leaveVerbView` | `deepestSection` (`header`, `simple`, `compound`, `etymology`, `example`), `dwell` (`0-5s`, `5-15s`, `15-60s`, `60s+`) | Exactly once for each verb page's `viewAppeared`: when the page leaves the screen, its model sheet opens, or the app goes to the background |
| `finishSearch` | `outcome` (`opened`, `abandoned`, `noResult`), `queryLength` (`1-2`, `3-5`, `6-9`, `10+`), `resultCount` (`0`, `1`, `2-10`, `11+`), `matchKind` (below), `resultPosition` (`1`, `2-5`, `6+`, `none`) | Once per verb search: when a result or the guess is opened (by tap, Return, or the arrow keys), the field is cleared, or the app goes to the background with text in the field |

**A visit** (`VerbVisit`) is one stretch of a verb page on screen, uncovered by its own model
sheet, with the app in the foreground. It is the same whether the page was pushed (Verbs tab) or
presented as a sheet (a deeplink, an Info link, a model page). A page that returns starts a new
visit whose `source` is `resume`, so every verb page's `viewAppeared` pairs with one
`leaveVerbView`, background time never counts as reading, and arrivals are the visits whose source
is not `resume`. A resumed visit starts from the deepest section already on screen. Before Phase 3,
`viewAppeared` for `VerbView` fired on each `onAppear` and never on a return from the background;
it now also fires on that return, as `resume`. A sheet that something else presents over a page
(a deeplink's verb over a pushed page, say) does not end the page's visit.

**Reaching a section** means a third of its first card on screen (`onScrollVisibilityChange`,
threshold 0.3): the présent card for `simple`, the passé composé card for `compound`, then the
etymology and example cards. The compound block shows only when its toggle is on. Until Phase 6
the toggle was off on every page, so `compound` was rare; since Phase 6 it is on by default and
remembered, so a learner who never hides the block reaches it on the way to the etymology.
A tense article's sheet ends the visit as the model sheet does, and closing it resumes the visit.

**`tapTenseArticle`**, with no parameters, counts taps on a tense heading's article button
(Phase 6, 2026-11-22). Konjugieren's counterpart is `tapConjugationgroupArticle`.

**`tapShareVerb`**, with no parameters, counts taps on the verb page's share button (Phase 8,
2026-11-22), whether or not the learner then shares. Copying sends nothing.

**A search** (`SearchTracker`, `SearchReport`) begins with the first non-blank letter and ends
once. Returning to the results and opening another verb without editing the text sends no second
`finishSearch`, though the page still reports `search`. Editing the text after an open begins a new
search, so deleting the query letter by letter reports an abandoned search of its last letters. An
abandoned search's `matchKind` is that of the top result it passed over. Opening the guess reports
`opened`, `resultCount` `0`, `matchKind` `guess`, and position `1`. `resultCount` counts rows, so a
doubled infinitive (haïr) counts twice. The Models tab's search sends nothing.

**`matchKind`** is `VerbSearch.MatchKind`'s case by name, through an exhaustive switch
(`analyticsValue` in `SearchReport.swift`), so a new kind cannot go unnamed: `exactInfinitive`,
`exactFoldedInfinitive`, `conjugation`, `infinitivePrefix`, `glossMeaning`, `foldedConjugation`,
`foldedInfinitivePrefix`, `wholeWordGloss`, `infinitiveSubstring`, `foldedInfinitiveSubstring`,
`glossSubstring`; plus `guess` and `none`. `conjugation` and `foldedConjugation` are sent since
Phase 5. An opened guess reports `guess` whether it came from an infinitive or a conjugation.

### The `source` vocabulary

`AnalyticsSource` is one vocabulary for the verb page's `viewAppeared` and, from Phase 11, the
quiz signals. Values are Konjugieren's names wherever the surface is the same.

| Value | Sent today? | Meaning |
|---|---|---|
| `browse` | Yes | A row of the verb list with the search field blank |
| `search` | Yes | A search result, opened by tap, Return, or the arrow keys |
| `searchGuess` | Yes | The guess at the verb meant, shown when a search finds nothing |
| `modelPage` | Yes | A verb in a model page's list, in the Models tab or in a sheet over a verb page |
| `infoLink` | Yes | A verb linked from an Info article (`?source=infoLink`) |
| `widget` | Yes | Any home-screen, lock-screen, or quiz widget (`WidgetDeeplink`, `?source=widget`) |
| `control` | Yes | The Random Verb control in Control Center (`OpenRandomVerbControlIntent`) |
| `shortcut` | Yes | Open Random Verb run from the Shortcuts app (`OpenRandomVerbIntent`); Phase 9's shortcuts too |
| `deeplink` | Yes | A `conjuguer://verb/` link with no `source` item, or one outside this vocabulary |
| `resume` | Yes | The same page appearing again (above) |
| `related` | Yes | A verb on a verb page's Related Verbs card, or in its full list (Phase 7) |
| `spotlight`, `lookup`, `quickAction` | Phase 9 | A Spotlight result; Look Up a Verb; the Home Screen quick action. Phase 9 should also add `source` to `finishSearch`, as Konjugieren's Phase 11 did, for searches these surfaces open |
| `recent`, `myVerbs` | Phase 10 | A recent verb in the empty focused field; a verb in My Verbs. For the quiz signals (Phase 11), `myVerbs` is a quiz over My Verbs |
| `tab`, `verbPage` | Phase 11 | The quiz signals only: a quiz begun from the Quiz tab; Test Me on a verb page |
| `reviewCard` | Phase 13 | The review card, opened after its conjugations are revealed |
| `list` | Phase 14 | A verb on a collection's page; for the quiz signals, a collection's quiz |

**How the source travels.** The verb list pushes a `VerbDestination` (verb and source) rather than
a bare `Verb`, and since Phase 5 the cells a search matched (`marks`). A link carries `source` as a query item
(`conjuguer://verb/aller?source=widget`), because a widget or an intent can hand the app only a
URL. `World.resolveDeeplinkEntity` stores it in `World.verbSource` (`AnalyticsSource.ofDeeplink`),
falling back to `deeplink`, and the sheets that present `World.verb` pass it to `VerbView`. A model
page passes `modelPage` itself. **Phase 9's grammar should keep this query item.**

**The convention for later phases.** A phase that adds a way to reach a verb page passes its value
in `VerbDestination`, in a link's `source` item, or directly to `VerbView`, marks it sent in the
table above, and stages its privacy line. Phase 8 added `tapShareVerb`; Phases 10 and 11 add `tapStarVerb`
(with `starred`, the state after the tap) and `tapTestVerb`. Phase 11 adds `source` to `quizStart`,
`quizQuit`, and `quizCompletion`.

## Deeplinks

The app opens `conjuguer://` links from the widgets, the Control Center controls, Info articles,
and model pages. There is no web domain, so there are no universal links.

### Grammar Today

```
conjuguer://<host>/<target>
```

A link must have exactly one path segment after the host (`URL.hasExpectedNumberOfDeeplinkComponents`
counts two path components, "/" and the target), or it is ignored. Query items do not count as
path components. The only one read is `source` on a `verb/` link, which names the surface that sent
it (§ Analytics); every other query item is ignored.

| Host | Target | Opens |
|---|---|---|
| `verb` | A verb's `dictionaryKey`, percent-encoded (`aller`; `ha%C3%AFr%20France` for one of a doubled infinitive's entries), or `random`; optionally `?source=` | The verb page as a sheet over the Verbs tab. `random` draws from all 6,330 entries (`Verb.verbs.values.randomElement()`). An unknown verb opens the Verbs tab and nothing else |
| `model` | A model's identifier (`1-1`) | The model page as a sheet over the Models tab |
| `info` | A position in `Info.infos` (`info/0`) | The article as a sheet over the Info tab. An out-of-range position does nothing |
| `quiz` | Anything (`OpenQuizIntent` sends `quiz/start`) | The Quiz tab, starting a quiz unless one is in progress |

Phase 9 of the browse plan replaces this section with one written grammar (text in query items,
`source` on every route, a `search` route, `info/` by stable key) and builders in place of the
literals listed below.

### Architecture

| File | Purpose |
|------|---------|
| `URLExtensions.swift` | The scheme, the hosts, `isDeeplink`, and `hasExpectedNumberOfDeeplinkComponents` |
| `World.swift` | `handleURL(_:)` clears `verb`, `verbModel`, and `info`, resolves the link (`resolveDeeplinkEntity(from:)`), and selects the tab. `handleInAppURL(_:)` resolves without clearing or switching tabs, for links inside Info articles |
| `ConjuguerApp.swift` | Receives links through `.onOpenURL`, and on each activation drains a link that a control's intent left in the shared defaults (`WidgetConstants.pendingDeeplinkKey`) |
| `VerbBrowseView.swift`, `ModelBrowseView.swift`, `InfoBrowseView.swift` | Present `Current.verb`, `Current.verbModel`, and `Current.info` as sheets |
| `ModelView.swift` | Intercepts its own `verb/` links (the verbs list) through an `OpenURLAction` and presents the verb as a sheet |
| `InfoView.swift` | Turns an article's links into `info/` or `verb/` links and hands them to `handleInAppURL(_:)` |

**The cold-launch race.** A widget's link can arrive through `.onOpenURL` before `VerbData` has
finished parsing, when `Verb.verbs` is still empty. `handleURL` then stores the link in
`pendingDeeplink`, and `ConjuguerApp` replays it with `drainPendingDeeplink()` once the data has
loaded. Any new entry point must go through `handleURL` so that it inherits this.

**Links written as literals.** `VerbModel.verbsWithDeepLinks()` (a model page's verbs list),
`InfoView.handleInfoLink(_:)`, `WidgetDeeplink.verb(_:)`, `OpenQuizIntent`, `OpenRandomVerbIntent`,
and `OpenRandomVerbControlIntent` each build their link from strings. Since Phase 3 the Info, widget,
and random-verb links carry a `source` item.

## Quiz

A timed quiz of thirty questions. The learner types each conjugation.

### Architecture

| File | Purpose |
|------|---------|
| `Quiz.swift` | `@Observable` quiz state: building the questions, the timer, scoring, the Live Activity, Game Center, the quiz signals, and VoiceOver announcements |
| `QuizVerbs.swift` | The curated verb pools the questions draw from |
| `QuizDifficulty.swift` | Regular or Ridiculous, chosen in Settings, and each one's score multiplier |
| `QuizQuestion.swift`, `QuizResult.swift`, `QuizState.swift` | A question (verb and tense), an answered question, and the quiz's lifecycle |
| `ConjugationResult.swift` | Grades an answer as a total, partial, or no match |
| `CyclingDeck.swift` | Deals a pool's elements in order and reshuffles when it runs out |
| `QuizView.swift`, `QuizResultsView.swift`, `QuizResultView.swift` | The quiz screen and the results sheet |
| `LiveActivityManager.swift` | Starts, updates, and ends the quiz's Live Activity |

### The Two Difficulties

**Regular** asks thirty questions by fixed quotas, each verb dealt from a `CyclingDeck` over a
`QuizVerbs` pool and each person from a deck of the six (the impératif from its three):

| Tense | Questions | Pools |
|---|---:|---|
| Indicatif présent | 7 | regular -er (2), regular -ir (2), regular -re, the big three (être, avoir, aller), présent stem changers |
| Passé composé | 6 | regular -er, -ir, -re, the big three, être auxiliaries, irregular participes passés |
| Subjonctif présent | 4 | regular -er, -ir, -re, the big three |
| Imparfait | 3 | the top thirty |
| Futur simple | 3 | regular futur stems (2), irregular futur stems |
| Conditionnel présent | 3 | regular futur stems (2), irregular futur stems |
| Impératif | 3 | the top thirty |
| Participe présent | 1 | the top thirty |

**Ridiculous** asks thirty fixed pairs of verb and tense (réaliser, choir, bruire, moudre, and so
on), with the person drawn from the deck. Either way the questions are shuffled.

A debug launch argument, `-CONJUGUER_QUIZ_FIXTURE screenshot`, replaces both with a fixed plan for
App Store screenshots and exports its answers (see
[`screenshot_playbook.md`](screenshot_playbook.md)).

### Grading and Scoring

`ConjugationResult.score(correctAnswers:proposedAnswer:)` compares lowercased text against each
alternate the conjugator separates with `Tense.alternateConjugationSeparator` ("/"):

- **Total match** (10 points): equal, or equal once circumflexes (â ê î ô û) are removed from
  both, so a missing circumflex costs nothing.
- **Partial match** (5 points): equal once every diacritic is folded away, so "etait" for "était"
  earns half.
- **No match** (0 points).

Each question's points are multiplied by the difficulty's `scoreModifier` (1 for Regular, 2 for
Ridiculous). A finished quiz scoring at least 150 earns a time bonus, from 450 points for two
minutes or less down by 50 a minute to nothing past ten. The best score is stored in `Settings`,
and every completed quiz, at either difficulty, reports its score to Game Center's leaderboard.
Quitting reports nothing.

### Signals

`quizStart` (`difficulty`), `quizQuit` (`difficulty`, `lastQuestionIndex`, `elapsedTime`), and
`quizCompletion` (`difficulty`, `score`, `elapsedTime`).

## Widgets

The `ConjuguerWidget` extension holds two widgets, two Control Center controls, and the quiz's Live
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
| `QuickQuizControl.swift`, `RandomVerbControl.swift` | Control Center controls. Their intents (`OpenQuizIntent`, `OpenRandomVerbControlIntent` in `Shared/`) store `conjuguer://quiz/start` or `conjuguer://verb/random?source=control` in the shared defaults and open the app, which drains it on activation |
| `QuizLiveActivity.swift` | The quiz's Lock Screen and Dynamic Island presentation |
| `WidgetDeeplink.swift` | The verb widget's link to the verb's page |

### Choosing the Verb

`WidgetSnapshotWriter.eligibleVerbs()` takes the verbs ranked 1,500 or better
(`verbOfTheDayRankLimit`) that have an example sentence, in rank order. Each day's verb is the one
at `(days since 2025-01-01 × 127) % count`. The quiz question uses the same verb, with a person and
one of six tenses (présent, passé composé, futur simple, imparfait, subjonctif présent,
conditionnel présent) chosen from the day number, and three wrong answers drawn from the verb's own
other conjugations before any filler. A change of the pronoun-gender setting rewrites the
snapshots. Phase 12 of the browse plan changes the draw.
