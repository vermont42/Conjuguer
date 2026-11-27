# Review of the Browse and Verb-Page Code

A review of what [`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md)
built for the Verbs and Models tabs, asked for in
[`prompts/verb_browse_review.md`](../prompts/verb_browse_review.md). Done 2026-11-25 against
`88dbb96`. It reviews the code as it stands, so where the pedagogy plan has since edited a browse
file, the review reads the edited file.

**Nothing here has been fixed.** [`plans/verb_browse_fixes.md`](../plans/verb_browse_fixes.md)
is the plan for fixing it, and each finding will gain a line here when its phase lands.

## Summary

The browse work is sound where it is a model: the search matcher, the conjugation map and index,
the edit-distance guess, the deeplink builders, the learner's record, and the draw are careful,
deterministic, and well tested (about 290 tests across 22 suites). No signal carries a verb or
typed text, at any call site. The defects are where the work meets SwiftUI presentation and where
a workaround was applied to one screen and not its twin.

The findings that matter most:

1. **Two tabs present the same deeplinked verb page (B1), and a verb link inside a presented
   article opens nothing (B2).** Both were reproduced in the simulator. After the Info tab has
   been visited once, every verb link (widget, Spotlight, Look Up a Verb, Random Verb) logs a
   UIKit assertion that "will become a hard exception in a future release", builds the page twice,
   and records the open twice. The cause is older than the browse plan, but the browse plan hung
   the open record, the visit signals, and four new entry points on it.
2. **On iPad, an accent key tapped in the empty Models search field is lost (B3).** Reproduced.
   It is the bug Phase 10 fixed for the Verbs tab only.
3. **A link that resolves to nothing still closes whatever sheet is open (B4).** Reproduced.
4. **A quiz from a model's page can ask one question ten times (B5).** falloir's page at
   Beginner, the default level, asks "il faut" ten times, and Ten More asks ten more.
5. **The fallback that presents a sheet when a page has no navigation stack is dead code in four
   views (S2),** and the routing state behind B1, B2, and B4 has one shape that would remove all
   three (S1).

Counts: 30 bugs (2 high, 10 medium, 18 low), 3 gaps in what search understands, 15 findings on
structure, 9 on duplication, and 6 on tests and docs. Four of the bugs were reproduced in the
simulator, three are suspected, and the rest are traced.

## How This Was Done

I read every browse-era file myself: about 8,000 lines of app code, the plan's sixteen "How it
differed" notes, and `docs/feature_architecture.md`. Five Opus reviewers each read one slice
independently (search core, verb list, verb page, Models tab and collections, deeplinks and
intents), with no knowledge of my notes or of each other's. I then checked their findings against
the code, and ran the app on Conjuguer's own iPhone and iPad simulators for the ones that needed
it. I did not read Konjugieren's review until everything above [the comparison](#konjugierens-findings-checked-here)
was written.

Each finding says how sure it is:

- **Reproduced**: seen in the simulator on 2026-11-25, with what was seen.
- **Traced**: followed through the code to the wrong outcome, by me or by a reviewer whose trace I
  then compared with my own reading of the same code. The low-severity ones got that comparison and
  no second trace.
- **Suspected**: the code path is real, and the outcome needs a run that I could not make. Each
  says what would confirm it.

**Not covered:** VoiceOver by ear, a real device, a Mac, the app running in French,
`scripts/count_tenses.py` and the frequency pipeline's changes, and the quiz beyond `QuizScope`
and `QuizSheet`. Two simulator runs left marks: the iPhone's record gained opens of rire, boire,
and lire, and the iPad's review card for venir was revealed.

Decisions that the plan records as Josh's are not re-argued. Where a finding touches one, it says
so. A finding that predates the browse plan is marked **older**, and is here because the browse
work depends on it.

## Bugs

### High

**B1. Two tabs present the same deeplinked verb page.** *Reproduced. Older, made worse.*
`VerbBrowseView.swift:182` and `InfoBrowseView.swift:50` each attach `.sheet(item: $world.verb)`.
The Verbs tab is always loaded, and the Info tab stays loaded once visited, so from then on a verb
link asks two tabs to present, one of them off screen. Measured with one link on a fresh launch,
then again after visiting the Info tab:

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): every page a link opens is one
`RoutedSheet` that `MainTabView` alone presents, and no tab presents one.
`RoutedSheetTests.aLinkedVerbIsPresentedOnce` hosts `MainTabView` in a window, loads the Info tab,
and finds one `viewAppeared` and an `openCount` of 1 per link; with a second presenter put back in
the Info tab, it finds two of each.

| | Info tab never visited | Info tab visited once |
|---|---|---|
| UIKit assertion in the log | none | "Presenting view controller … from detached view controller `TabHostingController` is not supported, and may result in incorrect safe area insets and a corrupt root presentation … Will become a hard exception in a future release." |
| Times the page's headings were built | 6 | 15 |
| `openCount` stored for the verb | 1 | 2 |

So after one visit to the Info tab, each deeplinked verb is counted as two opens in the learner's
record, sends `viewAppeared` and `leaveVerbView` twice, and calls `practice.recordLookup` twice.
This is very likely also the cause of Phase 12's "a link that arrives while a verb sheet is up is
sometimes dropped or arrives late", though in my one try of that case (aller up, then a venir
link) the second page did replace the first. The double presenter dates from `fdee834`, before the
plan. **Fix:** present every routed sheet from one modifier (see S1).

**B2. A verb link inside a presented article closes the article and opens nothing.** *Reproduced.
Older.* I opened `conjuguer://info/passe_compose` and tapped "être" in the article. The article's
sheet went away, no verb page appeared in any tab, and SwiftUI logged "Currently, only presenting a
single sheet is supported. The next sheet will be presented when the currently presented sheet gets
dismissed", followed by B1's assertion. The article sheet's `InfoView` has no `openLink`
(`InfoBrowseView.swift:46`), so its links go to `World.handleInAppURL` (`InfoView.swift:68-73`),
which sets `world.verb` while the `world.info` sheet is up, and neither presenter of `verb` is
free. An article link tapped inside an Info-tab article reaches the same state, since it too sets
`world.info` through `handleInAppURL`, so this does not need a link from outside (that path is
traced, not run). The model page's irregularities article (`ModelView.swift:80-83`) has the same
shape. The verb page's own article sheet does not: `TenseArticleSheet` pushes inside the sheet.
**Fix:** give every presented article what `TenseArticleSheet` has, a stack and an `openLink` that
pushes (see S1).

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): every presented article is an
`ArticleSheet`, with a stack of its own, and the Info tab's articles push in the tab's stack.
`InfoView` reads its links as values and pushes them onto whichever stack shows it, so a verb link
in a routed article, a model page's irregularities article, or an Info-tab article pushes the verb
page there.

### Medium

**B3. On iPad, an accent key tapped in the empty Models search field is lost.** *Reproduced.*
On the iPad simulator I focused the empty Models field and tapped ê: the field stayed empty and
the key row vanished. With "p" typed first, the same tap gave "pê". The Verbs tab's row follows
`searchIsEngaged`, which outlasts the focus by 0.7 seconds, and inserts through `insertLetter`,
which waits out the dismissal (`VerbBrowseView.swift:384-433`, `549-561`). The Models tab's copy
still follows `searchIsFocused` and appends at once (`ModelBrowseView.swift:237-246`). The two
functions carry the same comment word for word. Phase 10's note says the Verbs row was fixed, and
the Models row was not moved over. être, écrire, and étudier all begin with an accent. **Fix:**
one shared piece for both tabs (see D5).

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): both tabs' key rows follow
`SearchEngagement.isEngaged` and insert through `SearchEngagement.insert`. Reproduced first on the
old build on the iPad simulator; after the fix, ê tapped in the empty Models field gave "ê" with
être first, and typing went on in the field.

**B4. A link that resolves to nothing still closes the open sheet.** *Reproduced.* With lire's
page up, `conjuguer://list/nonsense` closed it. `World.handleURL` calls `clearDeeplinkTargets()`
before it knows whether the link resolves (`World.swift:204`), so an unknown `list/`, `info/`, or
host closes every routed sheet and drops a pending search, daily session, or challenge request.
An unknown `verb/` or `model/` target does that and also switches tab with nothing to show
(`World.swift:257-264`, `282-284`), while unknown `list/` and `info/` targets leave the tab alone.
`docs/feature_architecture.md` says an unknown key "does nothing". The tests that pin rejection
all start from a cleared state, so they cannot see it. **Fix:** resolve first, then clear and
assign only on success.

**Fixed on `main` 2026-11-25**, by Phase 1 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`World.handle(_:)` resolves a parsed `Deeplink` to a value and clears and assigns only when it
resolves. An unknown `verb/`, `model/`, `list/`, or `info/` target, an unknown host, and a
malformed link change nothing, and `DeeplinkTests.testALinkThatNamesNothingChangesNothing` starts
each from an open verb page, a model, a pending search, and a pending daily session. (Since Phase 2
there is one routed sheet, so the test starts from the verb page alone and checks that the sheet
keeps its identity.)

**B5. A quiz over chosen verbs repeats itself.** *Traced.* Two parts:

- *One cell, ten times.* `canBeQuizzed(at:)` asks only whether some cell exists
  (`QuizScope.swift:263-265`), and `levelMixQuestions` falls back to a repeated cell with no cap
  (`QuizScope.swift:182-202`). falloir's model 4-5C holds one verb with one cell at Beginner (the
  default level), so its page's Quiz button asks "il faut" ten times, and Ten More ten more.
  apparoir's 4-1D does it at every level, and férir's 2-4 ("féru") from Elementary up, though the
  doc says 2-4 shows no Quiz button. `QuizScopeTests.aDefectiveVerbIsAskedOnlyTheCellsItHas`
  asserts the count of ten, so it pins the padding.
- *Ten More forgets the first ten.* `continueSession()` calls `scope.questions(level:using:)`
  with an empty `asked` set each round (`Quiz.swift:204-213`, `438-440`), where the default quiz
  passes what earlier rounds asked. A My Verbs quiz of three verbs at Beginner has 27 cells, and
  its second round repeats about four of the first round's ten.

**Fix:** cap a round at the distinct cells available, carry `asked` across rounds, and decide what
a collection with fewer than, say, three cells shows (see the open questions).

**Fixed on `main` 2026-11-27**, by Phase 11 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): a round over chosen verbs asks no cell the session has asked, so it is as long as the unasked cells allow, up to ten, and Ten More passes the session's questions and is offered only while an unasked cell remains (`QuizScope.hasUnaskedCell(at:asked:)`). A collection's Quiz button and Start for My Verbs need three cells at the learner's level (`QuizScope.hasEnoughCells(at:)`), so falloir's 4-5C at Beginner, apparoir's 4-1D, and férir's 2-4 from Elementary show no Quiz button. A My Verbs quiz of three verbs at Beginner now asks 10, 10, and 7. `aDefectiveVerbIsAskedOnlyTheCellsItHas` asserts falloir's own count of cells.

**B6. The keyboard highlight is a row index, so it goes stale when the rows change.** *Traced.*
`keyboardSelection` is cleared only when the text changes (`VerbBrowseView.swift:131-133`). On
iPad: arrow down three times through the recents, then end the search, and the third verb of the
whole list is drawn highlighted. Or open the second recent with Return, come back, and the
highlight sits on a different verb, because the open moved that verb to the top; Return now opens
the other one. **Fix:** store the selected verb's id and derive the index.

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbSearchModel` keeps the
selected verb's id, and a row is drawn highlighted only while its verb is among the rows the keys
reach. On the iPad simulator, ↓↓ to boire among the recents, a tap on boire, Back, and Command-F
showed boire first and still highlighted. The second scenario's Return could not be tried: an
empty search field sends no submit, so Return over a recent does nothing (it did nothing before,
too).

**B7. A pronominal compound with nous or vous loses a pronoun.** *Traced.* For "nous nous sommes
levés", `ConjugationQuery` drops the first nous as subject and keeps the second as the reflexive
pronoun, and the row's text is built with one of them (`VerbSearch+Conjugations.swift:84-88`):
"nous sommes levés: Passé Composé (nous)". That reads as the passive the code refuses to match,
and it does not survive a round trip: Look Up a Verb sends the text as the link's `match`,
`MarkedConjugations(text:on:)` parses it again with one nous, finds no reflexive pronoun, and
lever's page opens unmarked. "je me suis levé" works. **Fix:** write the pronoun twice, and test
that every sentence row's text re-parses to the same cells.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): a pronominal compound with nous or vous writes the pronoun twice ("nous nous sommes levés"), and `testARowsTextReadsBackAsTheSameCells` reads every sentence row's text back through `MarkedConjugations(text:on:)` and finds the same cells. Before the fix it failed for nous and vous.

**B8. A second link to the verb already showing changes the marks and nothing else.** *Traced.*
Look up "vais", then, with aller's page up, "suis allé". The sheet's item keeps its identity, so
the page is not presented again: the new cell is marked, but the page does not scroll to it
(`scrollToFirstMark` is gated on `!hasAppeared`), the compound block is not forced on
(`compoundTensesAreForcedOn` keeps its first value), and no new visit begins, so the second lookup
sends no `viewAppeared` and records no open. **Fix:** give each routed verb its own identity, as
`PracticeSetRequest` has.

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): each `RoutedSheet` has its own
identity, so a second link to the page showing replaces the sheet with a fresh page, which scrolls
to the new mark, opens the compound block if the mark needs it, and begins a new visit.
`RoutedSheetTests` pins the identity and the second visit.

**B9. On iPad, the review card and My Verbs rows push without the workaround.** *Suspected.*
`pushFromSearch` exists because a tap that ends an empty search pushes during the search's
dismissal, and UIKit drops the push. Browse rows and recents go through it. `openReviewCard` and
`myVerbRow` call `path.append` directly (`VerbBrowseView.swift:353-358`, `534-537`), and both can
be on screen with the empty field focused when there are no recents (a learner who only takes
quizzes, or who pressed Clear). To confirm on the iPad: Clear the recents, star a verb, choose My
Verbs, focus the field, and tap the row. I did not, because it meant clearing the simulator's
record.

**Confirmed and fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md). On the iPad simulator, with no
recents, one starred verb, and the empty field focused, a tap on the My Verbs row and a tap on a
revealed card each showed no page, and UIKit logged "…while an existing transition or presentation
is occurring; the navigation stack will not be updated." The My Verbs tap also recorded an open of
a page never shown. Both now push through `SearchEngagement.push`, as the tab's other rows do, and
after the fix both opened their pages.

**B10. The control's and the shortcuts' links wait for the next activation.** *Suspected. The
mechanism is older.* The Find a Verb control, both Random Verb intents, and Start Quiz write a link
into the App Group's defaults, and the app reads it only when the scene becomes active
(`ConjuguerApp.swift:58-69`, `105-114`). If `perform` runs after that moment, the link opens at
the next activation, perhaps days later. `docs/release.md` already asks for a device check of the
control, which would settle it if it also covers a warm launch. `OpenURLIntent` would remove the
mailbox.

**Left for a device, 2026-11-27**, by Phase 12 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): still Suspected, since only a device can say when `perform()` runs against the scene's activation. `docs/release.md` § Before Submitting, item 10, holds the warm-and-cold check and sketches both fixes (`OpenURLIntent`, or a timestamp on the stashed link and a Darwin notification). Neither was built, because neither could be shown to work without a device.

**B11. A cold Look Up a Verb, or a cold `search` link, loads the conjugation index on the main
actor.** *Suspected.* The verb list warms `ConjugationIndex.bundled` from a detached task, but
`LookUpVerbIntent`, `VerbEntityQuery`, and `openRequestedSearch` can each touch it first, inside
`MainActor.run` or a view callback (`LookUpVerbIntent.swift:30-33`, `VerbEntity.swift:61-67`,
`VerbBrowseView.swift:672-685`). The plan measured the load and fold at about 2.2 seconds in a
Debug build. A Release timing of a cold `conjuguer://search?q=vais` would say whether it matters.

**Fixed on `main` 2026-11-27**, by Phase 12 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md), after measuring: in a Release build on the simulator, cold, a `search?q=vais` link held the main actor 0.82 to 0.88 s and the Look Up path 0.79 to 1.83 s, nearly all of it the fold. `ConjugationIndex.warmBundled()`, `@concurrent`, is awaited by Look Up, the entity query, the requested search, and the verb list. A `verb/…?match=` link resolved cold in the synchronous `SceneRouter.handle(_:)` still builds the index on the main actor.

**B12. œuvrer's page reads "je œuvre".** *Traced, and the fold checked in Swift. Older.*
`PersonNumber.elides(before:hasAspiratedH:)` strips the first letter's accent and tests it against
a, e, i, o, u (`ConjugationLabels.swift:138-145`). œ is a ligature with no accent to strip, so it
is not a vowel to this test, and every simple-tense je cell of œuvrer and œilletonner shows "je"
where French writes "j'œuvre". VoiceOver reads the same string, and the quiz's answer frame and
Name the Conjugation call the same function (`AnswerFrame.swift:72`, `Recognition.swift:168`).
The rule predates the plan; Phase 4 moved it into this file and Phase 8 made the key conjugations
share it. **Fix:** count œ and æ as vowels, and pin œuvrer's je cell.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `elides` lists œ and æ as vowels. œuvrer's je cells read j'œuvre, j'œuvrais, and j'ai œuvré, and the quiz's frame gives "j'". Name the Conjugation calls the rule only for a pronominal verb's reflexive pronoun, and no pronominal verb begins with a ligature.

### Low

**B13. Typing a hyphenated form sounds the trombone at the hyphen.** *Traced.* "dis-moi" plays it
at "dis-", "dis-m", and "dis-mo", and shows the empty state with a guess each time, because
`verbPart(ofHyphenated:)` needs every part after the hyphen to be a whole pronoun
(`ConjugationQuery.swift:83-89`). The code already avoids this for "s'" and for pronouns alone.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `ConjugationQuery.isStillBeingTyped` covers a last word that ends in a hyphen or in the start of a pronoun after one, so "dis-", "dis-m", "dis-mo", and "lève-to" play no trombone and get no guess. Before the fix, typing "dis-moi" a letter at a time sounded the trombone once and started three guesses.

**B14. A pronoun typed alone is offered a guess.** *Traced, and simulated by a reviewer over the
built map.* "nous" finds nothing, as intended, but `guess` does not ask `isOnlyPronouns`
(`VerbBrowseView.swift:581`), so the empty state suggests foutre through "fous".

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbSearch.guess` returns nothing for a query still being typed, so "nous" gets no guess in the list or in Look Up a Verb, where it had offered foutre.

**B15. `meanings(of:)` splits inside parentheses.** *Traced.* It splits on commas before it strips
parentheticals (`VerbSearch.swift:283-291`), so remercier's "thank, fire (an employee,
euphemistically)" yields "fire (an employee" and "euphemistically)". Six glosses are affected
(chantourner, desserrer, écaler, locher, ratonner, remercier): "fire" no longer ranks remercier
as a whole meaning, "belt" becomes a meaning of desserrer, and Spotlight gets names like "etc.)".

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): parentheticals are dropped before the gloss is split. remercier's meanings are thank and fire, so "fire" finds it as a whole meaning; desserrer's is loosen alone, so "belt" finds it as a word of the gloss.

**B16. The twenty-verb limit on recents is applied before starred verbs are removed.** *Traced.*
`recent()` takes the twenty newest, and My Verbs then filters out the starred ones
(`LearnerVerbs.swift:69-77`, `LearnerVerbStore.swift:31-33`). A learner who starred twelve of the
last twenty sees eight under Recent.

**Fixed on `main` 2026-11-26**, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `LearnerVerbs.recentUnstarred` leaves out the starred before it takes twenty, and `myVerbs` uses it. The unused `limit` parameter is gone, and `recent` is a property.

**B17. Doubled entries change places between launches.** *Traced.* The alphabetical verb list
compares `infinitif` alone over `Verb.verbs.values`, whose order changes with each launch's hash
seed (`VerbBrowseView.swift:712-714`), so haïr (France) and haïr (Québec) can swap. The
frequency order breaks the tie by id. The Models tab's alphabetical order has the same gap for
haïr's two models (`ModelBrowseView.swift:281-283`).

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `Verb.byFrequency` and `Verb.alphabetically` break a tie by id, and `VerbModel.alphabetically` and `byIrregularity` by the model's id, so haïr (France) comes before haïr (Québec), and 2-3A before 2-3B, whatever order the dictionary gives. `VerbOrderTests` sorts both entries and both models in each input order; with the old comparison the reversed input stayed reversed.

**B18. Tasks that are never cancelled race each other.** *Traced.* The 0.7-second linger starts a
new task at each loss of focus (`VerbBrowseView.swift:396-401`), so focus lost, regained, and lost
again within 0.7 seconds disengages early, which reopens the window the workaround closes. Two
search requests half a second apart can focus the field mid-pop (`687-695`). The "address copied"
note can vanish a second after a second tap (`FailedVerbSearchView.swift:86-98`). `.task(id:)`
cancels for free.

**Fixed on `main` 2026-11-26** for the linger and the two requests, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`SearchEngagement` cancels the linger at each change of focus, a waiting push when another comes,
and a waiting focus when another request comes, which waits for the same pop to end. Tests pin
each. The "address copied" note is left for a later phase.

**B19. The widget's My Verbs days do not take verbs in turn.** *Traced.* `verbOfTheDay` indexes
`myVerbs[turn % count]` (`VerbDraw.swift:40-45`), and the recents in that list are newest first, so
opening the widget's verb moves it to the front and the next My Verbs day can show it again while
another waits. The rotation is fair only over the starred verbs.

**Fixed on `main` 2026-11-26**, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md). A stable order indexed by turn would not have served: once the list grows, `turn % count` lands anywhere. A My Verbs day now takes the verb whose last My Verbs day is longest ago, and the snapshot file (`WidgetSnapshotBundle.myVerbsLastShown`) carries those days from one write to the next. Tests with a list that grows and one that reorders between turns failed against the old draw.

**B20. Spotlight never deletes an entry.** *Traced.* `indexAppEntities` adds and updates
(`VerbSpotlight.swift:43-64`). A verb removed from `verbs.xml`, or one whose key changes when it
gains a second entry, leaves a result that opens the Verbs tab with nothing (and, by B4, closes
any open sheet).

**Fixed on `main` 2026-11-27**, by Phase 12 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): each index deletes the named index's entries before writing them (`SpotlightIndex.deleteAllEntries`), and a failed delete still indexes but leaves the version unrecorded, so the next launch tries again. The index sits behind a `SpotlightIndex` protocol so that `VerbSpotlightIndexingTests` pins the order.

**B21. Look Up a Verb says the same line twice for a doubled infinitive.** *Traced.* "haïssons"
belongs to both entries of haïr, and the answer names neither the extra letters nor the gloss
(`VerbLookup.swift:53-58`).

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): every Look Up answer names a doubled infinitive with its extra letters, so haïssons gives one line for haïr (France) and one for haïr (Québec).

**B22. A hyphenated impératif typed without accents loses its "-toi".** *Traced.*
"debrouille-toi" lists the présent and subjonctif cells of débrouiller instead of the impératif
alone, because the confirmation uses the typed word, unfolded
(`VerbSearch+Conjugations.swift:46`).

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): a hyphenated word's pronouns go back onto the verb as the app spells it, so "debrouille-toi" confirms "débrouille-toi" and lists débrouiller's impératif alone.

**B23. A query of spaces hides the collections but lists every model.** *Traced.*
`showsCollections` tests `searchText.isEmpty` (`ModelBrowseView.swift:98-100`), where the search
itself trims.

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the Models tab searches its
trimmed text, so a query of spaces is no search, and the collections stay.

**B24. On iPad, a first accent key in a field the control opened is reported as `tab`.**
*Traced.* The key's touch ends the focus, `fieldClosed()` clears the pending source
(`VerbBrowseView.swift:157-161`), and the search that begins is the tab's.

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the field counts as closed when
`SearchEngagement` lets go, not at the loss of focus, and the linger holds until a waiting letter
lands. `SearchEngagementTests.theLingerHoldsUntilAWaitingLetterLands` pins the second half.

**B25. French text typeset in Swift with an English colon.** *Traced.* The search row's line,
"vais: Indicatif Présent (je)" (`MatchedConjugation.swift:49-51`), which Phase 5 flagged for Josh
before the rule of 2026-11-23, and the model page's "Parent: " and participe passé label
(`ModelView.swift:108`, `137`). See the open questions.

**The row's line fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): "vais : Indicatif Présent (je)" in both languages, and so in the Look Up answer. An infinitive's Look Up answer moved its colon into the catalog (`Lookup.keyConjugations`), with U+202F in French. The model page's labels are Phase 10's.

**The model page's labels fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): "Parent:" and "Participe Passé:" carry their colons in the catalog (`ModelView.parentLabel`, `ModelView.participleLabel`), with U+202F in French. The stem alterations' rows keep their English colon, since they are the irregularity notation that `.claude/rules/localization_catalog.md` leaves alone.

**B26. The keyboard highlight is color only.** *Traced.* Neither the row nor the guess card adds
the selected trait, so VoiceOver and Full Keyboard Access cannot tell which row Return will open
(`VerbBrowseView.swift:228`, `256`).

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the highlighted row and the guess
card add `.isSelected`. AXe does not report traits, so this was checked in the code only.

**B27. A search that lands below a block's first card reports the visit as `header`.** *Traced.*
Only the first card of each block reports reaching it (`VerbView.swift:89`, `582`). "sois" lands
être on the subjonctif présent card without the présent ever coming on screen, so a learner who
reads the marked cell and leaves sends `leaveVerbView` with `deepestSection` `header`, which reads
as a bounce. Every compound landing but the passé composé does the same. **Fix:** let every card of
a block report its block; `VerbVisit.reach` already keeps the deepest.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): every tense card reports its block, and the personless card reports `simple`. The wiring is in the view, so no unit test fails without it; `VerbVisitTrackerTests` pins that a section reached mid-visit counts.

**B28. The article opener leaks into sheets presented from inside an article sheet.** *Traced.*
`tenseArticleOpener` is an environment value set on the article sheet's whole stack
(`VerbView.swift:708-710`), and sheets inherit the environment. A verb page inside an article
sheet, then Test Me, then a correction's verb link, gives a page whose article button appends to
the article sheet's path underneath the quiz: nothing visible happens, and an extra article is
waiting when the quiz closes. The path is long. The cause is a back channel that no stack scopes.
**Fix:** have `verbPageNavigation` inject the opener per stack, as it injects `verbPagePush`.

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the back channel is gone. Each stack
says through `verbPageNavigation(path:pushesTenseArticles:done:)` whether a verb page on it pushes
its tense articles, and every stack sets it, so a sheet presented inside an article sheet, which
builds its own stack, clears it.

**B29. The Related Verbs card's titles read the French verb in an English voice,** and two card
headings lack the header trait. *Traced in code; not heard.* "Built on prendre" and "Same model:
venir (6-7)" are each one `Text` with no locale (`RelatedVerbsView.swift:24`, `38`), where
`docs/voiceover.md` asks for a label and a French-marked value. Overview and the color key's title
skip `.isHeader` (`VerbView.swift:215`, `454`), so the heading rotor misses the page's first card.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): each relation's title is a label ("Built on", "Same model:") beside a French-marked value, as `docs/voiceover.md` asks, and Overview and the color key's title carry the header trait. Not heard with VoiceOver.

**B30. Look Up a Verb cannot open the page of an infinitive that has a twin.** *Traced. Found
through Konjugieren's review, not by mine.* `literalAnswerKinds` includes `.exactFoldedInfinitive`
(`VerbLookup.swift:32`), though the comment below it says "a folded spelling answers only when
nothing literal does". So "pêcher", typed with its accent, has two answers, pêcher and pécher, and
the shortcut names both and opens the search instead of the page. `verbs.xml` has 26 such pairs,
among them coûter and couter, brûler and bruler, répartir and repartir, tâcher and tacher, mâter
and mater, rôder and roder. **Fix:** make the literal tier `[.exactInfinitive, .conjugation]`,
fall back to the folded kinds, and test one pair.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the literal tier is the exact infinitive and the literal conjugation, and the folded kinds answer only when it is empty. pêcher, pécher, brûler, bruler, coûter, and couter each open their own page; pecher still names pêcher and pécher.

## Gaps in What Search Understands

The plan records that object pronouns (le, la, lui) and periphrases ("vais manger") are not
handled. These are different, and each is something a learner would type.

**G1. "c'est", "ce sont", "ça va", and "est-ce" find nothing, and no guess.** *Traced.* ce, c',
ça, and cela are not among the subjects (`ConjugationQuery.swift:28`), and ce is not among the
hyphenated pronouns. The learner sees only "If you believe that “c'est” is a French verb, please
email".

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): ce, c', ça, ca, and cela are subjects, and ce follows a hyphen. "c'est", "ce sont", "ça va", "cela suffit", "est-ce", "qu'est-ce", and "c'était" find être, aller, and suffire.

**G2. An inverted compound finds nothing.** *Traced.* "vas-tu" and "a-t-il" work, but "as-tu
mangé" and "est-il allé" do not, because the auxiliary is looked up as typed
(`VerbSearch+Conjugations.swift:113-125`). Looking up its verb part is one line.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): an inverted auxiliary is looked up by its verb part, so "as-tu mangé", "est-il allé", and "a-t-elle fini" find manger, aller, and finir.

**G3. An infinitive with a pronoun finds nothing, and then the guess finds it.** *Traced.*
`frenchQuery` strips only "se " and "s'" (`VerbSearch.swift:262-269`), while `ConjugationQuery`
strips subjects, me, te, y, en, que, and ne. So "y aller", "s'en aller", "me lever", and "ne pas
manger" sound the trombone, and the guess, which uses the other stripper, then offers the exact
infinitive at distance zero. Two strippers have drifted (see S10).

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbSearch.frenchQuery` drops what `ConjugationQuery` drops, so "y aller", "s'en aller", "me lever", and "ne pas manger" find their infinitives as exact matches.

**G4. Typing toward a hyphenated form** is B13.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): see B13.

## Structure and Smells

**S1. Routing is nine optionals, six sheet modifiers, and three hand-written parsers.** This is
the shape behind B1, B2, B4, and B8.

- `World.verb`, `verbSource`, and `verbMarks` are three properties that mean something only
  together, and `VerbDestination` already bundles exactly those three (`World.swift:38-42`).
  `collection` is already one destination value. `clearDeeplinkTargets` must list every optional.
- The routed items are presented by six `.sheet` modifiers on four views.
- `World.resolveDeeplinkEntity`, `ModelView`'s `OpenURLAction` (`ModelView.swift:59-74`), and
  `TenseArticleSheet.open` (`VerbView.swift:724-741`) each check the scheme and the component
  count, read `pathComponents[1]`, switch on the host, and look up `Verb.verbs`, with silent
  differences. `InfoView.handleInfoLink` has the verb in hand, builds a URL from it, and passes
  the URL to be parsed back into the verb.
- `url.analyticsSource ?? .deeplink` is written seven times, and the `search` route repeats
  `openSearch`'s three steps instead of calling it.

The builders are typed and the parser is not. **Shape:** a `Deeplink` enum with `init?(url:)` and
`var url`, so one round-trip test covers every route; `World.handle(_:)` resolves it to a value and
clears only on success; one `RoutedSheet` enum presented from one modifier on `MainTabView`; and
in-app links carried as values (`.verb(Verb)`, `.article(Info)`), never as URLs.

**Partly fixed on `main` 2026-11-25**, by Phase 1 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
the parser. `Deeplink` (`Utils/Deeplink.swift`) is the grammar's only parser and its only builder;
the `URL` builders, `analyticsSource`, and the three hand-written parsers are gone, `ModelView` and
the article sheet match on `Deeplink(url:)`, `InfoView` hands over values rather than URLs, and the
search route and `openSearch` share one path. The nine optionals and the six sheet modifiers are
Phase 2's.

**Fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the nine optionals are one
`World.routedSheet` and three requests, the routed pages are presented by one `.sheet` on
`MainTabView`, and an article's links reach `InfoView` as values. The model page's verb links and an
article's links stay URLs inside their `AttributedString`s, because a `Text` link can be nothing
else; each is read back once, where it is tapped.

**S2. The "present a sheet when there is no stack" fallback is dead in four views.** Every place
that builds a `VerbView`, `ModelView`, `RelatedVerbListView`, or `VerbCollectionView` either pushes
it through `verbPageNavigation` or wraps it in `.sheetDismissable()`, which injects `verbPagePush`
too. I checked all fourteen construction sites. So `verbPagePush` is nil only in previews, and these
are unreachable: `VerbView.DetailSheet`'s `.verb`, `.model`, and `.relatedList` and the switch in
`open(_:)` (`VerbView.swift:386-401`), `ModelView.DetailSheet.verb`, and the `sheetVerb` state and
sheet in `RelatedVerbListView` and `VerbCollectionView`. Phase 2's "not handled" note about
`ModelView`'s verb sheet describes one of them. The push itself is `(any Hashable) -> Void`, so a
type with no registered destination is dropped silently. **Shape:** one `VerbPageRoute` enum
(verb, model, related list, collection) with one `navigationDestination`, a push action that is
never nil, and the fallbacks deleted.

**Fixed on `main` 2026-11-25**, by Phase 4 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbPageRoute` has five
cases (a verb, a model with its order, the verbs built on a root, a collection, and an article,
which Phase 2 had registered as a fifth type), and `verbPageNavigation` registers one destination
whose exhaustive switch gives each a page. `VerbPagePush` takes a route and is never nil. Its
default asserts. The four views' sheets and `VerbView.open(_:)` are gone, as are `ModelDestination`
and `RelatedVerbListDestination`, and previews push in a `PreviewStack`.

**S3. `VerbBrowseView` is 722 lines holding four state machines.** Thirteen `@State`s and a focus
state feed `isSearching`, `showsRecents`, `showsMyVerbs`, and `showsReviewCard`, and then
`displayedVerbs`, `browseSource`, `keyboardTargets`, `listHeading`, and `verbCollection` each
re-derive what the list is showing. Particulars:

- `searchResults` and `searchMatches` are parallel arrays kept aligned by hand, and `BrowseSearch`
  is called with a closure that ignores its argument (`571-582`), so all it adds is the trombone.
- `searchFocusLostAt` is a `Date` only ever compared with nil, so after the field first loses
  focus, every later tap on a browse row takes the asynchronous path (`26`, `409-418`).
- An ended search runs the whole search again to fill its report (`648-653`), because
  `onChange` replaced the matches one line earlier. The plan's recorded quirk, that backspacing
  reports the last letter, has the same cause: the tracker keeps only the latest text.
- `listHeading` hashes 6,330 infinitives on every body pass (`279`), and
  `Array(verbs.enumerated())` is rebuilt with it.
- `reviewCardIsChosen` exists only to choose once, which the outer `onAppear`'s guard already does.

**Shape:** one `enum ListContent { all, results, noResults, recents, myVerbs }` that everything
switches on, and four seams: an `@Observable` search model (text, matches, guess, selection,
tracker), a review-card model, a `MyVerbsList` view, and the iPad engagement workaround shared
with the Models tab.

**The search model fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbSearchModel`
holds the text, one list of results (each a match with its position), their count of infinitives,
the guess, the selection, and the tracker, and reports an ended search from its results.
`BrowseSearch` is gone. `searchFocusLostAt` became `SearchEngagement.isLingering`. The rest
(`ListContent`, the review card, My Verbs) is Phase 6's.

**The rest fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): one `VerbListContent` (all, results,
no results, recents, My Verbs) says what the list shows, and the view switches on it.
`MyVerbsList` and `ReviewCardHost` have files of their own, and the card's rules are
`ReviewCardModel`'s, so `reviewCardIsChosen` is the model's private `hasChosen`.

**S4. The verb page is rebuilt about six times per open, and the compound cards are recomputed
each time.** *Measured.* One open built the page's headings six times in the first seconds, with
no interaction. `VerbConjugations.memoized` caches the simple cards, but `CompoundTensesView`
conjugates its fifty-odd cells in its initializer on every pass (`VerbView.swift:558-574`). That
was a cost paid on request while the toggle was off by default; Phase 6 turned it on, so every
page pays it six times. One cause of the passes: the page reads the learner's record for its star,
and recording the open writes that record, which re-renders the new page and every verb page still
alive beneath it in the stack. The two blocks also age differently. The simple cards are a `let`
captured when the page is created, and the compound cards are rebuilt on each pass, so a page left
open across a change of the pronoun-gender setting may show "il" above and "elle est allée" below
(suspected, not run). **Fix:** cache the compound sections beside the simple ones, look the cache
up from `body` rather than storing its answer, and give the star its own small view.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md). The suspicion did not reproduce: on the iPhone simulator, a page pushed in the Verbs tab and one pushed in the Models tab both followed a change of pronoun gender in both blocks, before and after a tap on the star, since each tab's stack built its pages afresh. The cost was real. `VerbConjugations` now holds the compound cards beside the simple ones, cached by verb and gender, and the page reads the cache from `body`. The star is a view of its own. Counted by a log line in `body` and one where the cards are conjugated, on the iPhone simulator: a push of faire from the Verbs tab built the page 3 times before and 2 after; prendre's page in a link's sheet over it, 5 times before and 4 after, and faire's page beneath was rebuilt once before and not after; apprendre pushed from prendre's related chips, 2 times before and 1 after, with each page beneath rebuilt once before, and after only prendre's. The compound cards were conjugated on every pass before and once per page after.

**S4a. `VerbView` is 756 lines with seams of its own.** The visit tracker is four `@State` flags
and five callbacks (see T1); the example card owns chanson state that `init` recomputes on every
parent pass and then discards; `TenseArticleSheet` repeats `SheetDismissable` nearly line for line
and exists only to add an `Info` destination. The tense cards, the article sheet, and the example
card could each move to a file unchanged. Scroll targets are strings spelled three ways
(`TenseTable.scrollID`, `Section.scrollID`, `VerbConjugations.scrollID(for:)`), where `TenseTable`
is already `Hashable` and could be the id itself.

**Partly fixed on `main` 2026-11-25**, by Phase 2 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `TenseArticleSheet` is gone.
`ArticleSheet` is `InfoView` in a `.sheetDismissable(pushesTenseArticles: true)`. The rest is
Phase 9's.

**The rest fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbVisitTracker` holds the visit's rules, each event returning what to signal and whether to record an open; `ExampleCard` owns its chanson state; the tense cards are in `TenseCards.swift` and the example card in `ExampleCard.swift`; a card's scroll target is its `TenseTable`, and the three `scrollID`s are gone.

**S5. Related verbs are derived at run time from etymology prose in the interface's language.**
`VerbBase.base(of:)` accepts a base when the verb's etymology contains `~base~`
(`RelatedVerbs.swift:117-133`). That one test feeds the Related Verbs card, the widget draw's
weight (`VerbDraw.isBase`), and the quiz draw (`QuizDraw.swift:121`). The two languages agree
today: a reviewer's Python port of the rule found the same 1,412 bases in each. But nothing tests
it, the suite runs in English only, and the etymologies are rewritten in bulk by a pipeline. A reworded etymology would silently change a verb's relatives,
and could make the widget's verb of the day differ between a French and an English device. The
exception lists (`falsePairs`, `knownPairs`, sixty-odd prefixes) are data living in code.
**Shape:** compute the base table once at build time, beside the conjugation map, from one
language, and test it; or at least pin that both languages agree for every verb.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md), the second way (Josh, 2026-11-25): `RelatedVerbsTests.testTheBaseRuleGivesTheSameAnswerInEnglishAndFrench` runs the rule over both languages' etymologies, read through `Etymology.texts(in:)`, and passes today.

**S6. `TenseTable` states the same mapping several ways.** `tenses` (table to cells) and
`Tense.table` (cell to table) are inverse switches kept by hand, `TenseTable.isCompound` restates
`Tense.isCompound` (it could be `representative.isCompound`), and `articleKey` and `secondName` are
twenty-case switches. `Tense.article` scans `Info.infos` for every heading on every body pass.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `TenseTable.isCompound` is `representative.isCompound`, and `Tense.article` reads `Info.withStableKey`, a dictionary built once. The inverse switches stay: each is exhaustive, which the compiler checks, and `testEveryCellBelongsToTheTableThatListsIt` checks that they agree.

**S7. `QuizScope` is a bag of flags.** *Mostly the pedagogy plan's, noted because collections
depend on it.* `isRanked` is a ten-term conjunction that every new kind must extend, and a model's
practice starts no Live Activity only because it happens to set `collection` for analytics
(`QuizScope.swift:129-131`). One `Kind` enum would make these exhaustive switches.

**Fixed on `main` 2026-11-27**, by Phase 11 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `QuizScope.Kind` has a case for each place a quiz starts, and ranking, Ten More, the Live Activity, the verb link, and `Quiz`'s draw are exhaustive switches over it. The boolean flags and optional fields are gone from the stored properties; those still read are computed from the kind. `QuizScopeTests` builds every scope and pins which is ranked, which starts a Live Activity, which prefers its band, and which hides the verb link.

**S8. Two identities for a verb.** `Verb.id` is "sortir (obtain)" and `dictionaryKey` is "sortir
obtain". Search keys its matches by one and its lookup table by the other within one function
(`VerbSearch.swift:103-110`), accessibility identifiers use `infinitif`, which the two entries
share (`verb_row_haïr` twice, and `model_row_haïr` twice), and the model page shows the key
itself, "haïr France", where every other screen shows "haïr (France)" (older).

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the identifiers that name a verb use its dictionary key (`verb_row_haïr France`, `related_haïr France`, `collection_verb_…`, `related_list_verb_…`) and a model's row its id (`model_row_2-3A`), and the model page names its verbs "haïr (France)". Search keys its matches by dictionary key too, as its lookup table does. `Verb.id` remains, as `Identifiable` asks, and as the tie-break of the sort comparators.

**S9. Small dead or misleading things.**

- `VerbSearch.MatchKind` is `Comparable` by case order, but ranking uses `tier`, and nothing
  compares kinds; a future `min` by kind would rank wrongly (`VerbSearch.swift:19`, `62-64`).
- `VerbSearch.keysCache` re-checks each cached entry against the verb's text on every keystroke
  "so that a test's made-up verb never reads the keys of a real verb" (`314-333`): production code
  bent around a test.
- No caller: `VerbCollection.isFeatured`, `ModelView`'s `world`, `URL.modelDeeplink(_: VerbModel)`
  (tests only), `WidgetSnapshotWriter.generateSnapshot(date:myVerbs:)` (tests only).
- `Shared/LearnerVerbs.swift` says the record lives in the App Group "so the widget extension can
  read what the app writes". Nothing in the widget reads it.
- `SeededRandomNumberGenerator`'s header says it exists so tests can check draws. It seeds every
  learner's verb of the day.
- `FlowLayout` lives in `RelatedVerbsView.swift` and is used by the quiz's sentences.
- `ModelSearch.seenVerbs` holds model ids.
- `BrowseSearch`'s header calls itself "the one piece the Verb and Model browse screens genuinely
  share", which five shared types now contradict.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `MatchKind` lost its `Comparable`, and its comment says that `tier` decides rank. Each `Verb` carries `VerbSearchKeys` (the folded infinitive and the gloss's meanings) from the moment it is made, so `keysCache` and its check against a test's verb are gone. `ModelSearch.seenVerbs` is `modelsFoundByAVerb`. The rest of S9 belongs to other phases.

**Fixed on `main` 2026-11-26**, in part, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `Shared/LearnerVerbs.swift` (and `PracticeRecord.swift`, and `World`'s comment on the shared defaults) now say the widget reads neither record; `SeededRandomNumberGenerator`'s header says it draws every learner's verb of the day; and the test-only `generateSnapshot(date:myVerbs:)` is gone. `isFeatured`, `ModelView`'s `world`, `URL.modelDeeplink(_: VerbModel)`, `FlowLayout`'s home, and `BrowseSearch`'s header remain.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md), in part: `FlowLayout` has its own file and proposes the row's width to each child, `isFeatured` and `ModelView`'s `world` are gone, and `VerbDestination` moved to a file named for it (Konjugieren's S3). `URL.modelDeeplink(_: VerbModel)` and `BrowseSearch`'s header remain for Phase 13.

**Found already gone, 2026-11-27**, by Phase 12 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `URL.modelDeeplink(_: VerbModel)` was deleted with the rest of the URL builders when `Deeplink` arrived in Phase 1 (`5543a98`). Phases 8 and 10 listed it as remaining from the review's text, not the code. `BrowseSearch`'s header remains for Phase 13.

**S10. One rule, several copies.** Lowercase-and-NFC normalization is written in
`ConjugationMap.key`, `Verb.normalizedConjugation`, `AnswerSpelling.normalized`, and
`FormsJSON.normalize`. The subject pronouns are listed in `ConjugationQuery` and `AnswerSpelling`.
The pronoun stripping of G3 is the case where two copies have already drifted.

**Fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the infinitive side and the conjugation side share `ConjugationQuery`'s stripper (G3). `AnswerSpelling.normalized`, `ConjugationMatch`'s normalization, and `FormsJSON` now call `ConjugationMap.key`, the one lowercase-and-NFC rule, which the tool compiles. The subject pronouns are still listed in both `ConjugationQuery` and `AnswerSpelling`, because they answer different questions: grading accepts a person's own pronouns, and search drops ce and ça, which grading must not accept.

**S11. Four intents with one body, and links typed by hand.** `OpenVerbSearchIntent`, both Random
Verb intents, and `OpenQuizIntent` differ only in the string they stash. Those strings and
`WidgetDeeplink`'s two are the grammar written out a second time, outside the builders. The doc
says `DeeplinkTests` pins each literal, and it pins three of six.

**Fixed on `main` 2026-11-27**, by Phase 12 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the four intents adopt `PendingDeeplinkIntent`, a nonisolated protocol with one `perform()`, and each names a `WidgetDeeplink` case, `OpenQuizIntent` included. `WidgetDeeplink` moved to `Shared/` and spells all six links, the widget's two among them. `DeeplinkTests` pins each to the URL `Deeplink` builds for the same place, and the verb link for every key, so `docs/feature_architecture.md`'s sentence about it is now true.

**S12. `LearnerVerbStore` sorts the whole record on every read.** `recentVerbs` sorts every entry
ever opened and is read about six times per body pass through `showsRecents`
(`LearnerVerbStore.swift:27-33`). The record never shrinks, since collection progress needs every
open.

**Fixed on `main` 2026-11-26**, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the store sorts its lists once per change of the record and keeps them as keys, mapped to verbs on read, since the store exists before the verbs load.

**S13. The model page rebuilds its list of links in `body`.** `verbsWithDeepLinks(order:)` sorts
with French collation and parses Markdown for up to 4,859 links (parler's model) on each pass
(`ModelView.swift:240`). The run of links is Josh's decision; caching it per model and order is
free. A model's collection also filters all 6,330 verbs for what `model.verbs` already lists.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbModel.verbsWithDeepLinks(order:)` (in `VerbModel+Verbs.swift`) is built once per model and order and kept, and names a doubled entry "haïr (France)". A model's collection, its practice, and the Related Verbs card read `VerbModel.entriesByFrequency`, the model's own list of keys sorted once.

**S14. A model type sends analytics.** `VerbCollection.signalView` reaches `Current`
(`VerbCollection.swift:209-214`) while the views beside it use the environment's `world`, as
`BrowseSearch` reaches `Current.soundPlayer`.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbCollection.viewParameters(source:)` says what to send, and `VerbCollectionView` sends `viewCollection` through the environment's `world`.

## Duplication

**D1. The verb row is built four times:** `VerbBrowseView.swift:286`, `FailedVerbSearchView.swift:31`,
`VerbCollectionView.swift:106`, `RelatedVerbsView.swift:132`. A `BrowseRow(verb:detail:isChecked:)`
initializer would hold the badge's format once.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `BrowseRow(verb:detail:isChecked:)` builds every verb row, the collection's and the related list's included.

**D2. `VerbCollectionView` and `RelatedVerbListView` are one page written twice,** and have
drifted: only the collection page has the iPad grid, and the two sort alphabetically by different
keys.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbListPage` serves both, with the iPad grid, the picker, and one alphabetical rule (`Verb.alphabetically`). The related list gains the grid in a regular-width stack. `RelatedVerbListView` stays as a type, since its name is the `viewName` its `viewAppeared` sends.

**D3. Sort comparators.** "By frequency" is written six times with two different tie-breakers
(`dictionaryKey` in `FrequencyBand` and `VerbCollection`, `id` in `RelatedVerbs` and
`VerbBrowseView`), and the French alphabetical compare three times. "A model's verbs by frequency"
is built four ways.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `Verb.byFrequency` and `Verb.alphabetically`, and `VerbModel.alphabetically` and `byIrregularity`, each with a tie-break, sort every list; `VerbSort.areInIncreasingOrder` picks one for a sort. A model's verbs by frequency are `VerbModel.entriesByFrequency`, used by all four places that built them.

**D4. The grid and list branches** of `VerbBrowseView.verbCollection` repeat the row, the
identifier, and the scroll handler, and `ModelBrowseView` repeats the model button and the
empty-search overlay in both of its branches. `VerbCollectionView.verbList` and `verbRows` show the
split.

**Fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): in the Verbs tab the scroll handler and the
`ScrollViewReader` wrap both branches once, and the rows are built by one function; in the Models
tab one `modelButton` serves both branches, and the empty-search overlay is applied once.
`VerbCollectionView` was already split and is unchanged.

**D5. The two tabs' search plumbing.** `sortPickerOrKeyRow` with its comment, the `searchable`
modifiers (placement, capitalization, autocorrection), the store bootstrap, and
`updateSearchResults` exist in both tabs, and B3 is what the drift cost.

**Fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `browseSearchable` and
`SortPickerOrKeyRow` (`BrowseSearchField.swift`) are written once, and `SearchEngagement` serves
both tabs.

**D6. Share-button anchoring** (`@State` frame, `onGeometryChange`, the zero check) is written at
four sites, one of them browse's (`VerbCollectionView.swift:134`, `165-170`, `193`).

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `ShareButton` hands its frame to its action, and `ShareSheet.present` treats a zero rect as none, so no call site checks. The collection's bar and the challenge's Share Result use it. The custom quiz's share is a `Menu`, and the hub's challenge row a `QuizHubRow`, so neither is a button to wrap; each keeps its own `onGeometryChange` and lost only its zero check.

**D7. `VerbListMode` restates `VerbSort`'s cases** with a conversion each way (`VerbSort.swift`).
`case sorted(VerbSort), myVerbs` would not.

**Fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbListMode` is `.sorted(VerbSort)` or
`.myVerbs`, in `Utils/VerbListMode.swift`.

**D8. Which key conjugations a verb has is decided twice,** in `Verb.keyConjugations()`
(`KeyConjugations.swift:21-27`) and in the practice schedule (`PracticeItemMapping.swift:66-76`),
whose comment admits the coupling. If one changes, the review card shows forms the schedule does
not hold.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `Verb.keyConjugationsByStem()` decides, and both read it.

**D9. The red question-mark article button** is written in `VerbView.swift:647-655` and
`ModelView.swift:199-207`, differing in hint and action.

**Fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `ArticleButton(hint:action:)`. Its model-page hint's "infomation" was corrected on the way.

## Tests and Docs

**T1. The verb list's rules are in private view methods that no test reaches.** Which event
finishes a search, what Return opens (the highlight, else the first result, else the guess, else
the recents), that a dismissal before the reveal snoozes, and that the card is chosen once: a
refactor could drop any of these and every test would pass. `SearchTracker` and the practice
record are tested as types, and the wiring is not. S3's seams are what would make it testable.
The verb page's visit rules are the same case: that every `viewAppeared` pairs with one
`leaveVerbView`, and that a resume records no open, holds in the code as traced, and lives in
`onAppear`, `onDisappear`, and two `onChange`s that no test runs.

**The search's part fixed on `main` 2026-11-26**, by Phase 5 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`VerbSearchModelTests` pins which events finish a search and what each reports, and what Return
opens. The review card and the visit are Phases 6 and 9.

**The review card's part fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`ReviewCardModelTests` pins the choice once per opening, a dismissal before and after the reveal,
one reveal, one signal per offer, and a stale offer dropped. The visit is Phase 9's.

**The visit's part fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `VerbVisitTrackerTests` pins the first visit's open, a resume after a page, the background, and the page's own sheet, no open on a resume, and the pairing over every order of five events.

**T2. "A relaunch keeps today's verb" is untested through the disk.** `writeSnapshots(now:)`
reads `WidgetConstants.snapshotsURL` and `Current` directly, so no test can point it at a file.
A future required field in `WidgetSnapshot` would make the decode fail silently and redraw the
verb at every activation.

**Fixed on `main` 2026-11-26**, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `writeSnapshots(to:myVerbs:now:)` takes its file and My Verbs, and `nextBundle(after:myVerbs:now:)` is a function from the old bundle to the new. Tests write through a temporary file: a missing one, a corrupt one, another day's, an older build's bare list, an identical rewrite skipped, today's verb kept when My Verbs changes, and My Verbs' turns carried a week on.

**T3. Tests that cannot fail.** `testVerbBuilderRoundTrips` returns early when the key is unknown,
and "s'entre-déchirer" is not a key, so that row tests nothing; it also passes a `match` that marks
nothing and never checks the marks (`DeeplinkTests.swift:402-411`).
`aDayGivesTheSameVerbEveryTime` calls a pure function twice. The unknown-link tests start with
nothing open (B4), and `aDefectiveVerbIsAskedOnlyTheCellsItHas` pins B5.

**Partly fixed on `main` 2026-11-25**, by Phase 1 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
`testVerbBuilderRoundTrips` requires each verb, uses entre-déchirer (whose key has no "s'") for its
pronominal row, and checks the one cell each row's `match` marks; the unknown-link test starts with
a page open. `aDayGivesTheSameVerbEveryTime` and `aDefectiveVerbIsAskedOnlyTheCellsItHas` remain.

**`aDefectiveVerbIsAskedOnlyTheCellsItHas` corrected on `main` 2026-11-27**, by Phase 11 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): it asserts that falloir alone is asked each of its cells once, fewer than ten. `aDayGivesTheSameVerbEveryTime` remains.

**T4. Nothing tests that a search row's text re-parses to the same cells** (B7), or that related
verbs agree across the two languages (S5).

**The row half fixed on `main` 2026-11-26**, by Phase 7 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): see B7. The related verbs half is Phase 9's.

**The related verbs half fixed on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): see S5.

**T5. Doc claims that are false today,** all in `docs/feature_architecture.md`: Return and the
arrows act "only while the field holds a query" (§ Search; § The Learner's Verbs says otherwise);
an unknown key "does nothing" (B4); férir's 2-4 shows no Quiz button (B5); the guess allows "one
edit per three letters" (it allows one for one or two letters); `DeeplinkTests` pins every literal
link (S11); the widget takes My Verbs "in turn" (B19); the page's own model sheet ends a visit
(the model page has been pushed since Phase 7, and the sheets that end a visit are the article and
Test Me); "nine French tenses have no French alternate" (six catalog values are empty); the color
key and the tip "both obey `TipDisplay.tipsEnabled`" (`shouldShowColorKey` does not read it).

**férir's 2-4 corrected on `main` 2026-11-27**, by Phase 11 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): it now shows no Quiz button from Elementary up, as the doc says, and the doc names the three-cell floor.

**The verb page's three corrected on `main` 2026-11-26**, by Phase 9 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the sheets that end a visit are the article and Test Me; six tenses have no French second name, named; and the color key now obeys `TipDisplay.tipsEnabled`, as the doc said, since it is a hint that goes once dismissed.

**T6. `docs/voiceover.md` has no row for the collection views,** and the verb row's two languages
inside a `Button`, which the plan left untested in Phase 0, 1, 2, and 5, are still untested.

**Fixed on `main` 2026-11-27**, by Phase 10 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `docs/voiceover.md` has rows for the collection page and the related list (`VerbListPage`), the bar, and the Models tab's row. The page and the bar are read from the accessibility tree, not heard; the row is untested; and the verb row's two languages inside a `Button` remain untested.

## Seen Outside the Scope

Not browse code, and noted in passing:

- **Multiple windows.** `UIApplicationSupportsMultipleScenes` is true (older), and every window
  shares the one `World`: a link switches tab and presents in every window. The browse work added
  two more single-window assumptions, the static `VerbSearchArrowKeys` (two windows cross their
  arrow keys) and the one `searchRequest`. See the open questions.

  **Fixed on `main` 2026-11-25**, by Phase 3 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md):
  each window owns a `SceneRouter` holding its tab, its routed sheet, and its requests, and
  `VerbSearchArrowKeys` keeps a closure per window. Seen first on the iPad simulator with two
  windows: a tab switch in one showed in the other, one boire link presented the page in both and
  counted two opens, and a search link sent to the window in front filled the other window's field.
- **`PracticeStore` migrates a `LearnerVerbs.review` field** that existed on `main` only between
  browse Phase 13 and pedagogy Phase 11, and that no release wrote.

  **Fixed on `main` 2026-11-26**, by Phase 8 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): the migration, its legacy type, `PracticeRecord.adopt`, their tests, and the paragraphs describing them are gone.
- **The review card can act on a stale offer:** a card chosen at launch is still revealed, and
  signalled, after its verb was looked up or the record reset in the same session.

  **Fixed on `main` 2026-11-26**, by Phase 6 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): `PracticeStore.holds(_:at:)` says whether
  each of an offer's items is still due, and `ReviewCardModel` drops an unrevealed offer that fails
  it when the record changes, when the card appears, and before a reveal. Seen on the iPad
  simulator: an unrevealed aller card left the list once aller was opened from search.
- **A collection's quiz draws uniformly over its entries,** so a quiz from parler's model page
  asks about 87% verbs from outside the 1,000 most frequent, and the pronominal collection about
  94% (a reviewer's Python estimate). See the open questions.

  **Fixed on `main` 2026-11-27**, by Phase 11 of [`verb_browse_fixes.md`](../plans/verb_browse_fixes.md): a collection's quiz, and a custom quiz or practice set over a collection, takes the collection's verbs inside the level's band first, and the rest once those are asked (`QuizScope.prefersBandVerbs`). A My Verbs quiz and a shared list do not, since the learner or a teacher chose those verbs. At Advanced the band is every verb, so nothing changes there.

## Checked and Found Sound

- **Privacy.** Every browse-era signal, at every call site, sends enum raw values and bands. A
  link's `source` passes through `AnalyticsSource(rawValue:)`; `q` and `match` never reach a
  parameter; a model's collection reports `model`.
- **Search ranking.** The tier and frequency sort is total and deterministic, whatever order the
  verbs arrive in. The demotion of folded matches follows the doc for pêch, pre, mate, and crois.
  NFD input, ligatures, and case are handled.
- **The guess.** `BoundedEditDistance`'s early exit is valid for swaps, its letter-count floor is
  a true lower bound, and ties never depend on dictionary order.
- **The map.** The UTF-8 sort, the text and LZFSE round trip, agreement of the map with
  `conjugations(matching:)` on defects and agreed participles, and the build phase's inputs and
  outputs.
- **Deeplink parsing.** Percent-encoded keys with spaces and accents, query items, extra
  segments, empty targets, and the builders' encoding of `&`, `=`, `#`, `/`, and `?`.
- **Cold launch.** Every entry point goes through `handleURL`'s guard, and `ensureLoaded` cannot
  parse twice.
- **The learner's record.** Keys are dictionary keys, so doubled infinitives stay apart; every
  later field is optional and a test fails if one is not; equal dates sort deterministically.
- **The draw.** Weights cannot sum to zero, day arithmetic is DST-safe, and the frequent draw is
  pinned to an independent reimplementation.
- **The search tracker** never double-reports across opens, re-opens, clears, and requests.
- **Etymologies load synchronously on first use,** so `VerbBase` never caches an answer from
  before they loaded, which I had suspected.

## Konjugieren's Findings, Checked Here

[`../Konjugieren/docs/verb_browse_review.md`](../../Konjugieren/docs/verb_browse_review.md)
reviewed the German original on the same day. I read it only after everything above was written,
then checked each of its findings against Conjuguer's code. Konjugieren itself was not reviewed or
changed. **Carried over** means the port has the same defect; **did not** means the port differs
there; **does not apply** means French or Conjuguer's design has no such thing.

### Correctness, Performance, and Privacy

| Its finding | Here | Notes |
|---|---|---|
| **C1** A folded infinitive counts as literal: the ranking | Does not apply | `exactFoldedInfinitive` still outranks `conjugation`, but I checked the built map and no unaccented French conjugation folds to another verb's accented infinitive, so nothing misranks. |
| **C1** …: the stranded separable verbs | Does not apply | French has no separable rows. |
| **C1** …: Look Up a Verb and twin infinitives | **Carried over** | B30, with 26 pairs here against its 18. I had missed it. |
| **C2** The widget's My Verbs rotation repeats a verb | **Carried over** | B19. |
| **C3** The red-letter guard is true for every verb | Did not | Conjuguer's key reads only the simple and personless cells, has no capital "Sie", and Phase 6 saw parler's page without it. |
| **C4** Tidying My Verbs erases collection progress | **Carried over** | Open question 5. Its two additions hold here too: the swipe erases as Clear does, and `firstOpened` and `openCount` are written on every open and read nowhere, so progress could count `firstOpened`. **Fixed on `main` 2026-11-26** by Phase 8: progress counts `firstOpened`, and Reset Practice forgets it. |
| **C5** "Alphabetical" is code-point order | Did not | Phase 7 gave the model page French collation, and the newer lists use it. `VerbModel.sortVerbs()` still sorts by code point, but every reader re-sorts. The copied comparators are D3. |
| **C6** Swiss spelling missing from captions | Does not apply | No regional spelling. |
| **C7** A strong second reading drops out | Does not apply | No readings. |
| **C7** Recent can show fewer than 20 | **Carried over** | B16. |
| **C7** A bad link cancels a good pending one | **Carried over** | B4, reproduced, and worse here: it also closes the sheet on screen. |
| **C7** Two entry points bypass the route | Did not | No Open Verb intent or Handoff; Spotlight goes through `URL.verbDeeplink` and `handleURL`. |
| **C7** Spotlight's migration flag; entries never removed; rebuilt at every launch | Part | No migration here, and indexing is gated on the version. Never removing an entry carried over (B20). |
| **C7** A collection key stored as the link spelled it | Does not apply | A featured key resolves to the collection itself, a model's id is ASCII, and analytics sends `model`. |
| **F1** A failed search computes its guess on the main thread | **Carried over, mitigated** | Not listed above. Phase 5 bounded the distance and measured at most 0.3 s per keystroke in a Debug build, against Konjugieren's 0.8 s; it is still synchronous in `updateSearchResults`. Its fix (compute off the main actor, cancel when the text changes) applies. **Fixed on `main` 2026-11-26** by Phase 5 of the fixes plan: finnissons fell from 0.25–0.27 s on the main thread to 0.08–0.09 s, the search alone. |
| **F2** Related verbs rebuilt in `body` | Did not | `Verb.related` is cached per verb. |
| **F2** Look Up a Verb may build the index on the main actor | **Carried over** | B11. |
| **F2** An ended search is computed again | **Carried over** | S3. |
| **P1** A correction's group link says which verb was missed | Did not | The correction's model link pushes `ModelDestination`, and a model's page sends `viewAppeared` only. No signal pairs `quizCorrection` with a collection, and a model's collection value is `model`. |

### Docs, Duplication, Smells, Elegance, and Tests

| Its finding | Here | Notes |
|---|---|---|
| **G1** The widget does not read the learner's record | **Carried over** | S9. |
| **G2** The frequency doc overstates two Konjunktiv counts | Does not apply | A rule of the German counting script. `scripts/count_tenses.py` is Conjuguer's own, and this review did not read it. |
| **G3** `DeeplinkTests` pins copies of the widget's links | **Carried over** | S11. |
| **G4** A migration for data no shipped build wrote | **Carried over** | Seen Outside the Scope. **Fixed on `main` 2026-11-26** by Phase 8: deleted. |
| **G5** Dwell time includes time under a sheet | Did not | The page's own sheets end the visit (`VerbView.swift:173-179`). |
| **G6** The Related Verbs card has no `VerbPageSection` | **Carried over** | Not listed above. The sections are header, simple, compound, etymology, and example. **Fixed on `main` 2026-11-26** by Phase 9: `related`, staged in the privacy file. |
| **G7** Stale prose | Does not apply | Its five are Konjugieren's. The tool's note about a non-atomic write still holds here, since the script sandbox is on. Conjuguer's own stale prose is T5. |
| **D1** "The cells this text fills" written three times | Did not | `MarkedConjugations(text:on:)` calls the one search function. |
| **D2**, **D3**, **D7** The zu-infinitive, finite parts, the main-clause split | Does not apply | German. |
| **D4** A stem's key conjugation computed twice | **Carried over** | D8, between the page and the practice schedule. |
| **D5** The collection and family views repeat themselves | **Carried over** | D2 and D4. Its bar-and-quiz mismatch did not: the bar and its quiz read one list. |
| **D6** Widget and intent links | **Carried over** | S11. |
| **S1** `VerbBrowseView` does too much | **Carried over** | S3. |
| **S2** `searchFocusLostAt` is a `Date` used as a `Bool` | **Carried over** | S3. |
| **S3** Declarations in files named for something else | **Carried over** | `FlowLayout` in `RelatedVerbsView.swift`, `VerbDestination` in `VerbVisit.swift`, `VerbListMode` in `VerbSort.swift`. **Fixed on `main` 2026-11-27** by Phases 6 and 10: each has a file named for it, as does `RelatedVerbListView`. |
| **S4** `keysCache` is a global memo | **Carried over, changed** | The port re-checks each entry against the verb's text to protect tests (S9). Its fix, storing the folded infinitive on `Verb` at parse time, removes the cache. |
| **S5** App-wide statics with multiple scenes | **Carried over** | Seen Outside the Scope, and open question 3. |
| **S6** An analytics value decides the interface; `isRanked` | **Carried over** | S7. |
| **S7** Timed workarounds, none cancelled | **Carried over** | B18. |
| **S8** The sort picker returns during a search and does nothing | **Carried over** | Not listed above. With text in the field and the keyboard down, the picker shows, and choosing My Verbs changes nothing (`showsMyVerbs` needs an empty field). **Fixed on `main` 2026-11-26** by Phase 5 of the fixes plan: the picker is disabled while the field has text, in both tabs. |
| **S9** Unused or unguarded | Part | Carried over: `recent(limit:)`'s unused parameter; the tool accepts any `--flag`, so a mistyped output name is skipped silently (`main.swift:38-46`); `ConjugationMap(compressed:)` turns invalid UTF-8 into an empty map. Did not: the unused URL prefix, which Phase 9 removed. **Fixed on `main` 2026-11-27** (the tool and the map), by Phase 12 of the fixes plan: the tool refuses an unknown or repeated flag, and `ConjugationMap(compressed:)` throws `ReadError.notUTF8`. |
| **S10** Both apps build the tool into one directory | **Carried over** | `scripts/write_forms_json.sh:31` uses `$TMPDIR/ConjugationMapTool-build`, the same path as Konjugieren's. A prefix on either side fixes both. **Fixed on `main` 2026-11-27**, by Phase 12 of the fixes plan: the directory is `$TMPDIR/ConjuguerConjugationMapTool-build`. |
| **E1** `Row` and `Entry` are one shape twice | Does not apply | No separable rows. |
| **E2** A redundant case in the cell rows | **Carried over** | `conjugationParts` names the three personless tenses in a case whose result the default's `guard` already gives (`VerbConjugations.swift:112-121`). **Fixed on `main` 2026-11-26** by Phase 9: the case names only the impératif passé, which has a person and no pronoun. |
| **E3** Static tables pick the tracked sections | Did not | Conjuguer compares with the block's first section, which has its own cost (B27). |
| **T1** Tests that cannot fail | Part | `testNoParameterValueEchoesTheQuery` is here and holds by the types. The other two are Konjugieren's. Conjuguer's own are T3. |
| **T2** Tests that check a copy | Part | The retyped widget links (S11). |
| **T3** Branches with no test | **Carried over** | Twins (B30), the rotation with a changing list (B19), the writer's disk path (T2), the visit pairing (T1), and the schedule across a daylight-saving day. |
| **T4** Exact assertions against a growing corpus | **Carried over, mildly** | `Set(results) == ["pécher", "pêcher"]` (`VerbSearchTests.swift:61`). |

### Costs of Settled Decisions

- **Opening a verb from the widget counts as forgetting it:** carried over.
  `PracticeStore.recordLookup` reschedules for every source but the review card
  (`PracticeStore.swift:100-108`).
- **The search-scope flip:** does not apply; Conjuguer has no setting.
- **The sein collection may ask a haben reading:** does not apply; a French verb has one
  auxiliary in the data.

### What Each Review Found That the Other Did Not

Konjugieren's review found five things here that mine had not: B30, and the four marked "not
listed above" (the guess on the main thread, the missing page section, the idle sort picker, and
the shared build directory).

Mine lists these, which Konjugieren's does not. Whether they hold in Konjugieren was **not
checked**, since that app is outside this task; the ones in shared designs are worth a look there.

- The duplicate verb sheet and the article sheet's dead-end link (B1, B2), which depend on
  Conjuguer's Info tab also presenting `world.verb`.
- The Models tab's accent row (B3). Konjugieren has one search field, so this is the port's.
- The single-cell quiz and Ten More's repeats (B5), the stale keyboard highlight (B6), the
  nous/vous pronominal text (B7), the second link to an open verb (B8), and the hyphen's trombone
  (B13).
- The dead sheet fallbacks (S2), and related verbs read from etymology prose (S5), which is
  Conjuguer's own way of finding a base.

## Open Questions for Josh

These are the decisions the plan needed. **Josh answered them on 2026-11-25**, and
[`plans/verb_browse_fixes.md`](../plans/verb_browse_fixes.md) § Decisions Already Made records
each answer. In short: everything in this review is in the plan's scope; routing becomes one
routed sheet with a parsed link type, owned by a router per window; `VerbBrowseView` is split in
full; a thin quiz gets a short round and a floor of three cells; all four search gaps are closed;
collection progress counts a verb once it has ever been opened, and Reset Practice is the full
forget; French punctuation applies wherever the text is French; related verbs get a test that the
two languages agree; a collection's quiz favors the level's band; and the suspected findings are
confirmed before they are fixed. The questions stay below as they were asked.

1. **Routing (B1, B2, B4, B8, S1).** One routed sheet presented from `MainTabView`, with a parsed
   `Deeplink` type; or the smallest fix, which removes the Info tab's duplicate verb sheet and
   gives presented articles a stack. A third way is to push a deeplinked verb onto the Verbs tab's
   stack instead of presenting a sheet, since the link switches to that tab anyway.
2. **How much restructuring.** S2 (delete the dead fallbacks, one route enum) and S3 (split
   `VerbBrowseView`) are worth doing on their own, or only where a bug fix passes through.
3. **Multiple windows.** Turn `UIApplicationSupportsMultipleScenes` off, or give each scene its
   own router. The Swiss institution ran the app on Macs.
4. **A collection with almost nothing to ask (B5).** Shorten the round to the cells there are,
   and hide Quiz below some floor (Test Me's three is a natural one), or keep ten with a cap on
   repeats.
5. **Clear in My Verbs.** As built and documented, it forgets every open, which resets every
   collection's "looked up" count and check marks, with no confirmation, though the section it
   sits in shows at most twenty verbs. A swipe on one recent verb does the same to that verb. Keep
   it, confirm first, or keep "looked up" apart from "recent" by counting progress on
   `firstOpened`, which is already stored and never read.
6. **What search should understand (G1 to G3, B13).** All four, or only the cheap ones (G1 and G2
   are a few words and one line).
7. **The French colon (B25).** "vais : Indicatif Présent (je)" with U+202F in both languages, in
   French only, or left as an exception; and the same for the model page's "Parent:".
8. **Related verbs (S5).** A build-time base table, or a test that the two languages agree.
9. **Collection quizzes and rare verbs.** Draw uniformly as now, or favor the learner's band.
10. **The suspected ones (B9, B10, B11).** Confirm on a simulator or device before planning, or
    fix on the strength of the trace.
