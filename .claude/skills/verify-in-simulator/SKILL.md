---
name: verify-in-simulator
description: Launch, screenshot, and drive Conjuguer in the iOS simulator to verify a change beyond unit tests. Covers the ios-build-verify verify scripts, this app's accessibility identifiers, iOS 26 control caveats (accented input, segmented pickers), and sweeping a quiz to completion.
---

# Verifying Conjuguer in the simulator

Resolve `IBV_SCRIPTS` first, as described under *Build and Test Commands* in `CLAUDE.md`.

The skill can launch the app and inspect/drive the UI so changes can be verified
beyond unit tests:

```bash
"$IBV_SCRIPTS/build_app.sh"                  # COMPILE first — launch_app.sh does NOT build (see warning below)
"$IBV_SCRIPTS/launch_app.sh"                 # boot + install the last-built .app + launch + wait-for-render
"$IBV_SCRIPTS/screenshot.sh <context-slug>"  # capture a PNG under docs/screenshots/
"$IBV_SCRIPTS/describe_ui.sh"                # dump the accessibility tree
"$IBV_SCRIPTS/tap_tab.sh <verbs|models|quiz|info|settings>"  # tap a main tab
```

> **⚠️ `launch_app.sh` does NOT compile.** It resolves `BUILT_PRODUCTS_DIR` via
> `xcodebuild -showBuildSettings` (which doesn't build), then installs whatever `.app`
> already exists there and launches it. **After editing source, you MUST run
> `build_app.sh` (or `run_tests.sh`) first** — otherwise `launch_app.sh` reinstalls the
> *previous* binary and your screenshots show pre-edit UI. (`launch_app.sh` does terminate
> the running process before install, so a stale *process* isn't the issue — a stale
> *build* is.) A symptom: edit → `launch_app.sh` → screenshot is byte-identical to the
> last one across multiple different edits. Always `build_app.sh && launch_app.sh`.

The launch anchor is `verb_browse_sort` (the sort `Picker` in `VerbBrowseView`). Add
more `.accessibilityIdentifier`/`.accessibilityValue` modifiers on a migration-by-use
basis as verification flows need them. See the skill's `SKILL.md` for the full verify
surface (named-intent ops, annotation checks, iOS 26 control caveats).

## Accessibility identifiers added so far

| Identifier | Element | Notes |
|---|---|---|
| `verb_browse_sort` | Sort `Picker` in `VerbBrowseView` | Launch anchor (`FIRST_SCREEN_ID`). Three segments: Frequency, Alphabetical, My Verbs. |
| `input_quiz_conjugation` | Answer `TextField` in `QuizView` | Carries `.accessibilityValue(input)`, so `read_value`/`set_value`/`type_text --id` work with read-back. |
| `quiz_shown_spelling` | The app's spelling beside the checkmark, after a right answer spelled another standard way | Launch with `-CONJUGUER_QUIZ_FIXTURE grading` and answer the first question `il connait`; its label is "Correct. Also spelled: connaît". |
| `quiz_almost` | "Almost! Try once more.", or a diagnosis's line and "Try once more.", in the feedback slot | Present while a slip or a diagnosed error waits for its second attempt; its label is the line. Launch with `-CONJUGUER_QUIZ_FIXTURE slips` and answer the first question `etes`, or with `diagnoses` and `suis allé`. |
| `quiz_correction_diagnosis` | The diagnosis's line in a held correction | Inside `quiz_correction`, whose label reads it after the differing letters, so AXe reports it only as part of that label. Answer a `diagnoses` fixture question wrongly twice. |
| `results_second_try` | "Second Try: N" in `QuizResultsView` | Present only when a second attempt was right. |
| `results_asked_again` | "Asked Again: N / M" in `QuizResultsView` | Present only when a question was asked again. |
| `results_time` | "Time: 0:49" in `QuizResultsView` | Present only with the Quiz Clock set to Show. |
| `results_level` | "Level: Intermediate" in `QuizResultsView` | Absent after Review and Practice My Mistakes, which ask by no level. |
| `results_ten_more` | Ten More in `QuizResultsView` | Absent after Test Me's three questions. `tap_id.sh` works on the iPhone; on the iPad Pro 11 tap ≈ `419,616`. The quiz resumes with the keyboard up. |
| `quiz_asked_again` | The "Asked Again" capsule above a re-asked question's verb | A missed question returns three questions later, or before the results. |
| `quiz_correction_will_be_asked_again` | "This question will come up again." in a held correction | Absent from a re-ask's own correction. |
| `quiz_correction` | The held correction's two answers, one element | Present while a wrong answer holds. Its label is the spoken correction ("Incorrect. Your Answer: …"). Launch with `-CONJUGUER_QUIZ_FIXTURE corrections` for eight kinds. |
| `quiz_correction_verb`, `quiz_correction_model` | The correction's links | Push the verb's page (scrolled to the asked cell) or the model's page over the quiz. The verb link is absent in Test Me's sheet. Back is the pushed page's top-left button (≈ `37,83` on the iPhone 17 in the tab, ≈ `37,110` in a sheet; ≈ `31,54` on the iPad Pro 11). |
| `quiz_continue_button` | The correction's Continue | Return in the field does the same. |
| `quiz_level_<level>` | A level tile in `SettingsView`'s Quiz Level card | `quiz_level_beginner`, `_elementary`, `_intermediate`, `_advanced`; `tap_id.sh` chooses it, and the chosen tile has the selected trait. The four sit in `grid_settings_quizLevel`. |
| `picker_settings_quizClock` | Quiz Clock segmented `Picker` in `SettingsView` | 2 segments (Hide, Show); Hide is the default. On the iPhone 17 at the top of Settings, Hide ≈ `116,526` and Show ≈ `285,526`. |
| `picker_settings_dailyReminder`, `picker_settings_dailyReminderTime` | Daily Reminder's Off/On segmented `Picker` and, while on, its time `DatePicker`, in `SettingsView`'s card after Quiz Clock | On asks for notification permission the first time; the system's alert is not the app's, so answer it with `tap_label.sh` (Allow) or by its frame. The time is easier written to the defaults (`dailyReminderMinutes`, minutes after midnight) than picked by tap. |
| `label_settings_dailyReminderDenied`, `button_settings_openNotificationSettings` | The red line and Open Settings, shown when notifications are refused | Appear after a refusal, or on Settings appearing with the reminder on and notifications turned off in the Settings app. A refusal sticks until the simulator's Settings app or `xcrun simctl privacy <udid> reset all software.racecondition.Conjuguer` resets it. |
| `picker_settings_pronounGender` | Pronoun-gender segmented `Picker` in `SettingsView` | 3 segments (Feminine, Masculine, Both). |
| `verb_example` | Example card in `VerbView` (below etymology) | Wraps the FR sentence, EN translation, source attribution, and nested *Chanson de Roland* example. |
| `verb_browse_count` | "N VERBS" header above the verb collection | Hidden when the search yields nothing. |
| `verb_row_<dictionaryKey>` | Row `Button` in `VerbBrowseView` (list and grid) | e.g. `verb_row_avoir`; a doubled infinitive's rows are `verb_row_haïr France` and `verb_row_haïr Québec`. |
| `model_row_<model id>` | Row `Button` in `ModelBrowseView` (list and grid) | e.g. `model_row_5-26` (être), `model_row_2-3A` and `model_row_2-3B` (haïr's two). |
| `french_letter_key_<letter>` | Accent key in `FrenchLetterKeyRow` (é è ê â î ô û ç) | Shown in place of the sort picker only while a search field is focused, e.g. `french_letter_key_ê`. `tap_id.sh` taps it and the field keeps focus. Over the quiz's answer field the row is a keyboard toolbar that AXe cannot see: tap a key by coordinate (with a hardware keyboard on the iPhone 17, y ≈ 816 and x ≈ 41, 86, 132, 178, 223, 269, 315, 361 for é to ç; on the iPad Pro 11, y ≈ 1167, é at x ≈ 70). Arrow keys (`axe key 80`, left) move the cursor if sent a few tenths of a second apart; faster presses are dropped. |
| `search_guess_intro` | "A guess at the verb you meant:" in `FailedVerbSearchView` | Present only when a failed verb search has a guess. |
| `search_guess_row` | The guess's row `Button` in `FailedVerbSearchView` | `tap_id.sh search_guess_row` opens the guessed verb. |
| `verb_request_link` | The "please email" line in `FailedVerbSearchView` | Its address is a `mailto:` link; tap the address by frame. The simulator has no Mail, so the tap copies the address and shows `address_copied_note`. |
| `address_copied_note` | The note under `verb_request_link` | Shows for four seconds after the address is copied. |
| `verb_related` | "Related Verbs" heading of the card at the bottom of `VerbView` | Scroll to the page's bottom first. |
| `related_<dictionaryKey>` | A verb chip on the Related Verbs card | e.g. `related_tenir`. `tap_id.sh` taps it; the verb pushes onto the current stack. |
| `related_all_built_on` | The "All N" chip of the card's "Built on …" row | Pushes `RelatedVerbListView`. |
| `related_all_model` | The "All N" chip of the card's "Same model" row | Pushes the model page in frequency order. |
| `related_list_sort` | Frequency/Alphabetical `Picker` in `RelatedVerbListView` | 2 segments. The page is `VerbListPage`, as a collection's is: a grid in a tab on the iPad, a list in a sheet. |
| `related_list_verb_<dictionaryKey>` | Row `Button` in `RelatedVerbListView` | e.g. `related_list_verb_remettre`. |
| `verb_share_button` | Share button in `VerbView`'s navigation bar | Opens the share sheet. Tap the sheet's Copy and read the text with `xcrun simctl pbpaste <udid>`. On the iPad it is a popover over the button. |
| `verb_star_button` | Star button in `VerbView`'s navigation bar | AXe cannot see navigation-bar buttons on iOS 26; tap it by position, between Done (in a sheet) and Share, and confirm by screenshot (a filled star). |
| `verb_test_button` | Test Me (clipboard) button in `VerbView`'s navigation bar | First in the bar, before the star; absent on the six verbs with only an infinitif. Invisible to AXe like the star: tap by position (≈ `250,100` in a sheet on the iPhone 17, ≈ `691,54` pushed on the iPad Pro 11) and confirm by the sheet's "1 / 3". The sheet's Quit is found by `tap_label.sh Quit`; its results' Done at ≈ `352,110` on the iPhone. |
| `quiz_start_button` | Start `Button` in the Quiz tab's briefing card | Starts the scope chosen in `quiz_scope_picker`. |
| `quiz_scope_picker` | All Verbs / My Verbs / Custom segmented `Picker` in the Quiz tab's briefing card | 3 segments; tap by frame from `describe_ui`, since the briefing's length moves it. Not stored across launches. |
| `custom_quiz_summary` | The custom quiz's Tenses and Verbs summary, one element | Present under the picker with Custom chosen and something chosen. |
| `custom_quiz_note` | The line under the summary | Says what to choose, that Start asks ten questions, or why Start is disabled (no verb has the tenses; My Verbs is empty). |
| `custom_quiz_choose_button` | Choose / Change, which pushes `CustomQuizEditor` | `tap_id.sh` works. Back is the editor's top-left button (≈ `37,83` on the iPhone 17). |
| `custom_quiz_tenses_by_level`, `custom_quiz_tense_<key>` | The editor's tense rows | Keys are the tense's `Info.stableKey`: `custom_quiz_tense_imparfait`, `custom_quiz_tense_passe_simple`. A tap toggles; the chosen row has the selected trait. |
| `custom_quiz_verbs_by_level`, `custom_quiz_verbs_<key>` | The editor's verb-set rows | Keys `top100`, `top300`, `top1000`, `all`, `myVerbs`, `etre`, `irregularFutur`, `pronominal`. Scroll down to reach them. |
| `custom_quiz_verbs_models` | The editor's Models row | Pushes `CustomQuizModelList`, whose rows are `custom_quiz_model-<id>` (`custom_quiz_model-1-3A`); a tap chooses the model and returns to the editor. |
| `quiz_review_button`, `quiz_mistakes_button` | Review and Practice My Mistakes on the Quiz tab's From Your Practice card | Present while the session has questions; `tap_id.sh` starts it at once. On the iPad tap by frame (Review ≈ `420,813` on the iPad Pro 11). Empty, they are `quiz_review_empty` and `quiz_mistakes_empty`, whose labels say why. The card's heading is `quiz_record_sessions`. |
| `quiz_exercises`, `quiz_verb_essentials_button` | The Exercises card's heading below From Your Practice, and its Verb Essentials row | Scroll down first: on the iPhone 17 the row is below the fold, and `tap_id.sh` taps off screen and does nothing. A tap starts the exercise at once. With `-CONJUGUER_QUIZ_FIXTURE essentials` it asks venir, se souvenir, faire, prendre, and aller (wrong answers in `docs/feature_architecture.md` § Verb Essentials). On the iPad Pro 11 in English the row's play button was at ≈ `785,993`. The results' `results_ten_more` reads Five More Verbs. |
| `quiz_model_practice_button` | The Exercises card's Conjugation Models row, below Verb Essentials | Pushes `ModelPracticeListView`. On the iPhone 17 scroll down first; `tap_id.sh` works once it is on screen. On the iPad Pro 11 in English it was at ≈ `400,1023`. |
| `model_practice_<id>` | A model's row in the list, e.g. `model_practice_6-7` | A tap expands the model's card below the row; a known model's label includes "Known". |
| `model_practice_alone_button`, `model_practice_mixed_button` | Alone and Mixed on a model's practice card, in the list or on the model's page (`conjuguer://model/1-2B`) | Each opens a `QuizSheet`; Mixed is disabled until another model of the same kind is known. With several models expanded in the list, their cards share these identifiers, so expand one at a time. A round alone of venir's model reads its questions from the tree: the verb follows `Score`, and a Verb Essentials field's label begins with its tense. |
| `model_practice_mixed_note`, `model_practice_known`, `model_practice_absence_note` | The card's line under its buttons, its Known seal, and the note of a model with no practice of its own | The absence note on parler's (1-1), aller's (1-9), and rompre's (5-1B) pages. |
| `quiz_recognition_button` | The Exercises card's Name the Conjugation row, below Verb Essentials | Scroll down first on the iPhone 17; `tap_id.sh` works once it is on screen. On the iPad Pro 11 in English it was at ≈ `417,993`. A tap starts the exercise at once; with `-CONJUGUER_QUIZ_FIXTURE recognition` it asks fûmes, suis, vis, parle, fait, est allée, me souviens, souviens-toi, finissons, and avions pris (answers worth trying in `docs/feature_architecture.md` § Name the Conjugation). |
| `recognition_prompt`, `recognition_tense_<slot>`, `recognition_person_<rawValue>`, `recognition_check_button` | The prompt, a tense chip (`recognition_tense_passéSimple`, `recognition_tense_participePassé`), a person chip (`recognition_person_fp`), and Check | `tap_id.sh` taps the chips on the iPhone; on the iPad tap their `describe_ui` frames. The person chips appear once a personal tense is chosen. Type the infinitive with `type_text.sh --id input_quiz_conjugation`: at Advanced on the iPhone the field sits under the floating accent row, so a tap at its centre lands on î. Check is under that row too, so send Return (`axe key 40`). |
| `quiz_sentences_button` | The Exercises card's Phrases à trous (Sentences) row, below Name the Conjugation | `quiz_sentences_empty` when the level has no sentence. Scroll down first on the iPhone 17; `tap_id.sh` works once it is on screen. On the iPad Pro 11 in English the row was at ≈ `417,1024`. A tap starts the exercise at once; with `-CONJUGUER_QUIZ_FIXTURE sentences` it asks ten sentences, one per kind of frame (answers worth trying in `docs/feature_architecture.md` § Phrases à trous). |
| `quiz_sentence_english`, `quiz_sentence_draft`, `quiz_correction_sentence` | A sentence's English under the field, the Draft label on an unreviewed sentence (debug builds only), and the completed sentence in a held correction | The field's label reads the sentence with "blank" in it, so a script can read each question from the tree. |
| `choice_setting`, `choice_prompt`, `choice_option_0`, `choice_option_1`, `choice_english`, `choice_reason` | A choice question's setting, "Which fits here?", its two sentences (buttons, in the order shown), the English, and the reason once chosen | One a default round from Elementary up, never first. `tap_id.sh choice_option_N` chooses on the iPhone; on the iPad tap the `describe_ui` frame. The card then holds, and `quiz_continue_button` (or Return) continues. With `-CONJUGUER_QUIZ_FIXTURE choices` the default quiz asks ten choices, the right sentence at index 0 on the first and alternating after. A sweep that types junk answers must detect `choice_prompt` and tap instead, since the field is gone. |
| `results_example_<verb key>`, `results_example_text` | Example Use on the first right results row of each verb, and the example it reveals | e.g. `results_example_venir`; `tap_id.sh` toggles it. Present in every quiz's results. |
| `quiz_level_menu` | The level tile on the Quiz tab's briefing card, a menu of the four levels | Shown for All Verbs and My Verbs. `tap_id.sh` opens it; tap a level by coordinate (on the iPhone 17 with the card scrolled to its tiles, Intermediate ≈ `238,360`). It writes the same setting as Settings. |
| `quiz_mastery_button` | The Mastery row on the From Your Practice card, below Practice My Mistakes | Pushes `MasteryView`. On the iPhone 17 it sits at the fold; `tap_id.sh` works. On the iPad Pro 11, where `tap_id.sh` failed with a decoding error on 2026-11-24, tap ≈ `210,756` in English. The page writes nothing, so a record seeded into the App Group plist (`practiceRecord`, with the app terminated) can be viewed and restored byte for byte. |
| `mastery_legend`, `mastery_regular_<slot key>`, `mastery_model_<model id>`, `mastery_verb_<dictionaryKey>` | The page's legend, a regular tense's card (`mastery_regular_indicatif_present`), a spelling-change model's card (`mastery_model_1-2B`), and an irregular verb's row (`mastery_verb_venir`) | The page is long and lazy: an identifier far below is not in `describe_ui` until scrolled near. Keep swipes clear of the tab bar (start above y ≈ 750 on the iPhone 17), or a swipe taps Quiz and pops to the hub. |
| `quiz_speed_round_button` | The Exercises card's Speed Round row, at its foot | `quiz_speed_round_empty` while fewer than five items are mastered; its label says how many are. Scroll down first on the iPhone 17; `tap_id.sh` works once it is on screen. On the iPad Pro 11 in English, dark, it was at ≈ `417,1082` after a swipe up. A tap starts the round at once. With `-CONJUGUER_QUIZ_FIXTURE speedRound` it opens whatever the record holds, on the eight items in `docs/feature_architecture.md` § Speed Round; a round still writes the device's best and last result. |
| `speed_round_right_answers`, `speed_round_time_left`, `speed_round_miss` | The round's count and time left (symbols on screen, words in their labels), and the missed question's line above the next field | The miss line's label is "Incorrect. The answer was: …", which a script can read to type the next round's right answers. The minute runs on the wall clock, so wait about 60 seconds for the results rather than counting answers. |
| `results_new_best`, `results_best`, `results_speed_round_again` | A Speed Round's or a ranked round's results: "New personal best!", "Your best: N"; and the round's Another Round | Another Round starts a fresh minute with the keyboard up; `tap_id.sh` works on the iPhone. For a ranked best, launch with `-CONJUGUER_QUIZ_FIXTURE screenshot` and type the answers it writes to the app's `Documents/screenshot_fixture_answers.json`: a level whose `bestScore.<level>` is 0 shows the new best, and one at 100 "Your best: 100". Write the bests back with `simctl spawn defaults write` afterward. |
| `quiz_daily_button` | From Your Practice's first row, the Daily Session | Always a button; a tap starts the session at once. Its line says the streak. `conjuguer://quiz/daily?source=reminder`, opened with `xcrun simctl openurl <udid>`, starts the same session as a tapped reminder would. The `-CONJUGUER_QUIZ_FIXTURE` fixtures apply to it, so `screenshot` gives a session whose answers are exported. |
| `results_daily_streak`, `results_daily_another` | A daily session's results: the streak line under the score, and Another Session while a repair awaits its second session | The streak lives in the App Group's defaults under `dailyStreak`, JSON of `{"sessions":{"2026-11-22":1}}`; seed it there to show a repair. |
| `quiz_challenge_button`, `quiz_challenge_share_button` | From Your Practice's second row, the Daily Challenge: it starts today's five questions at the learner's level, and once they are taken it shows the points over five dots and opens the share sheet | `conjuguer://quiz/challenge?source=challengeWidget` starts today's, and `?date=2026-11-24&level=advanced&source=challengeLink` that day's at that level; neither starts a challenge already taken. The fixtures do not apply. The results live in the App Group's defaults under `dailyChallengeResults`; remove that key to take today's again. |
| `results_challenge_dots`, `results_challenge_share` | A challenge's results: the five dots under the score, and Share Result in Ten More's place | On the iPad the share sheet is a popover anchored to the button. Copy in the sheet puts the text on the simulator's pasteboard, which `xcrun simctl pbpaste <udid>` reads. |
| `quiz_last_result` | The Last Quiz row on the From Your Practice card, one element | Absent until a quiz has shown its results. Finish a My Mistakes session for a quick one. |
| `quiz_best_score`, `quiz_leaderboard_button`, `quiz_achievements_button` | The best score, View Leaderboard, and View Achievements at the foot of the Quiz tab | Scroll down. The buttons show only while signed in to Game Center; the simulator's `GameCenterSpy` signs in when the tab appears, so they show there, and tapping one shows nothing. On the iPad, swipe in points (834 × 1194), not screenshot pixels: a swipe from y ≈ 1800 grabbed the home indicator on 2026-11-24 and shrank the app into a window, which the window's green button restored. |
| `quiz_my_verbs_note` | The line under `quiz_scope_picker` with My Verbs chosen | "Questions about N verbs in My Verbs", or how to add some; `quiz_start_button` is then disabled (`enabled: false` in `describe_ui`). |
| `recent_verbs_heading` | "Recent" heading over the recents in the empty focused search field | Present only when something has been opened. |
| `my_verbs_list` | The My Verbs `List` (third segment of `verb_browse_sort`) | Tap the picker's third segment by frame (`x + width*5/6`). Rows keep `verb_row_<dictionaryKey>`. Swipe a row left with `axe swipe --duration 0.4` at its `describe_ui` frame to show Delete. |
| `my_verbs_starred_heading`, `my_verbs_recent_heading` | Section headings in My Verbs | |
| `my_verbs_clear_recent` | Clear button in My Verbs' Recent heading | Empties Recent; keeps the stars and every collection's progress. |
| `my_verbs_empty` | My Verbs' empty state | |
| `review_card` | The review card above the verb list | Present at a launch or a return from the background when an irregular verb's key conjugation is due in the practice record. To seed one, write the App Group plist's `practiceRecord` JSON with an entry such as `key:venir:present` whose `schedule.due` is past (dates are seconds since 2001-01-01). Write it with `plutil` while the app is terminated (`simctl spawn defaults write` writes a different file), and reboot the simulator if the app still reads the old record, since the preferences daemon caches the domain. A tap anywhere reveals; a second tap opens the page. |
| `review_card_reveal` | The card's "Recall its conjugations, then tap to check." line | Gone once revealed. |
| `review_card_conjugations` | The card's revealed key conjugations | Tapping it opens the verb's page with `source` `reviewCard`. |
| `review_card_dismiss` | The card's ✕ | Before a reveal, snoozes the verb to the next day. |
| `picker_settings_reviewCardSuppression` | Suppress Review Card segmented `Picker` in `SettingsView` | 2 segments (Off, On). |
| `button_settings_resetPractice` | Reset Practice in `SettingsView`'s Practice Record card | Shown only while the practice record, the last quiz's result, a level's best score, the Speed Round's best, the daily streak, or the record of verbs ever opened holds anything; opens a confirmation alert whose destructive button erases all six, returning every `collection_progress` to zero while stars and Recent stay. |
| `model_verb_order` | Alphabetical/Frequency `Picker` above a model page's verbs | 2 segments; the verbs stay one `Text` of links, so tap a verb at its coordinates. |
| `collection_row_<key>` | A featured collection's row (iPhone) or card (iPad) atop the Models tab | Keys `top100`, `etre`, `irregularFutur`, `pronominal`. Hidden while the search field has text. |
| `collection_progress` | "3 of 100 looked up" in a `VerbCollectionBar`, on a collection's page or a model's verbs card | Read it before and after opening a verb to see the count rise. Clear and a swipe in My Verbs leave it; only Reset Practice lowers it. |
| `collection_quiz_button` | The bar's Quiz button | Opens a ten-question `QuizSheet` titled with the collection. Absent when no verb can be quizzed (1-10, 2-4). |
| `collection_share_button` | The bar's Share button | The popover anchors to it on iPad. |
| `collection_sort` | Frequency/Alphabetical `Picker` on a collection's page | 2 segments, Frequency first. |
| `collection_verb_<dictionaryKey>` | A verb row on a collection's page | e.g. `collection_verb_aller`; a green check marks a verb looked up. |
| `custom_quiz_share_button` | Share, beside Change on the Custom segment | Present only while Start is enabled. A menu: `tap_label.sh "Share Link"` opens the share sheet (Copy at ≈ `68,531` on the iPhone 17, then `simctl pbpaste`), `tap_label.sh "Show QR Code"` the QR view. On the iPad `tap_id.sh` fails; tap by its `describe_ui` frame, and the menu's rows by theirs. The menu items carry `practice_set_share_link` and `practice_set_show_qr_code`, which AXe does not report. |
| `practice_set_summary`, `practice_set_verbs` | A practice set's summary card and its list's verb chips | Open a set with `xcrun simctl openurl <udid> "conjuguer://quiz/set?tenses=imparfait&verbs=etre"`; it shows over any tab, and works from a cold launch. |
| `practice_set_start_button`, `practice_set_keep_button` | Start and Keep as My Custom Quiz on a set's sheet | Start opens a `QuizSheet` titled Practice Set; Quit returns to the set. Keep turns disabled ("Kept as My Custom Quiz"). The sheet's Done is `tap_label.sh Done` (`Terminé` in French). |
| `practice_set_nothing_to_ask` | The line above a disabled Start | `quiz/set?tenses=imperatif&verbs=model-4-5C` (falloir's model) |
| `practice_set_invalid` | "Practice Set Not Found" | `quiz/set?tenses=aoriste` |
| `practice_set_qr_code`, `practice_set_qr_summary` | The QR view's code and caption | Decode a screenshot's code with Core Image (`CIDetector` of type `CIDetectorTypeQRCode`) in a short Swift script to check the link. Take the screenshot a second or two after the cover appears; mid-animation it decodes to nothing. |

An identifier on a container that is not itself one element (a card) is inherited by every element
inside it and overrides theirs, so put a card's identifier on its heading (as `verb_related` is).
Put a row's identifier on the tappable `Button`, **not** on the row content inside its
label: SwiftUI merges the two elements and concatenates their identifiers, yielding
`verb_row_avoir-verb_row_avoir`, which `tap_id.sh` can't match.

Info headings and tab buttons are not yet annotated — drive them by `AXLabel` /
`tap_tab.sh` for now. The verb-search field is unannotated too; tap it at its
`describe_ui` frame (the lone `AXTextField` on the Verbs tab, `{{16, 70}, {315, 44}}` →
centre ≈ `173,92` on iPhone 17) before typing. Because verb names carry accents, drive it
with `type_text.sh --xy 173,92 "<verb>"` (pasteboard route) rather than `axe type`, which
rejects non-ASCII. Re-measure with `describe_ui.sh` rather than trusting this number. The field
moves: on a fresh launch it sits lower (frame y ≈ 169, so tap ≈ `201,191`), and once a search is
active it rises to the top (tap ≈ `173,70`, seen 2026-10-01). A tap at the old spot silently
misses, and the text goes nowhere.

**iPad:** both search fields are fixed bars under the title, and the
hardware-keyboard path works through AXe: Command-F is `axe key-combo --modifiers 227 --key 9`,
↓ and ↑ are `axe key 81` and `axe key 82`, Return is `axe key 40`. Escape (`axe key 41`) cancels the
search and clears its text. Key presses sent to Simulator.app through computer use do not reach the
device (Konjugieren). `tap_label.sh` did not find the iPad's top tab buttons on 2026-11-22; tap them
by coordinate (Models ≈ `370,54`, Quiz ≈ `448,54` on the Conjuguer iPad Pro 11).

**A long press** (a conjugation's Copy menu) is a held touch:
`axe touch -x <x> -y <y> --down --up --delay 1.2 --udid <udid>` at the cell's `describe_ui` frame
(the cell's label is the spoken line, e.g. `je vais`). Then tap Copy by coordinate and read
`simctl pbpaste`. A simulated rating prompt may cover a page at launch; tap Not Now first.

**Outside the app.** Links: `xcrun simctl openurl <udid> "conjuguer://search?q=suis"`
(or `verb/aller?match=vais`); terminate the app first to try a cold launch, and allow about 15 seconds
for the Debug build to load. Spotlight: `axe button home`, tap the Home Screen's Search pill (≈
`201,718` on the iPhone 17), `axe type` the word, then tap the result at its `describe_ui` frame (the
row's label is "aller, va · est allé · ira, go"). The quick action: the icon sits in the App Library
(swipe left past the last page); hold it with `axe touch -x 70 -y 214 --down --up --delay 1.2`, then
tap Find a Verb (≈ `133,285`). Look Up a Verb: `xcrun simctl launch <udid> com.apple.shortcuts`, tap
its tile under Conjuguer (≈ `60,340`), `axe type` the word, and tap the prompt's Done at ≈
`288,239`; a tap lower down dismisses the prompt and may run the Random Verb tile instead. These
coordinates are from 2026-11-22; re-measure with `describe_ui` if one misses.

## iOS 26 control caveats specific to this app

- **Accented input (é, è, à, ç, …):** `axe type` rejects non-ASCII. The skill's
  `set_value.sh` / `type_text.sh` (v0.3.0+) auto-route non-ASCII through a
  `simctl pbcopy` + Cmd+V pasteboard fallback, so French conjugations enter
  correctly. The quiz field is reachable by id, so prefer `type_text.sh --id
  input_quiz_conjugation "<answer>"` (gives read-back); the field also auto-focuses
  after **Start**, so a bare `axe type` into the focused field also works for ASCII.
- **Switches** (the verb page's "Show Compound Tenses" toggle) ignore an instant tap: `tap_xy.sh`,
  `axe tap --label`, and a swipe across the knob all left it unchanged on 2026-11-22. A held touch
  flips it: `axe touch -x <x> -y <y> --down --up --delay 0.15 --udid <udid>`, aimed at the switch
  at the row's right edge. Read the result from the element's `AXValue` (`1` on, `0` off).
- **Segmented pickers** render with empty AXTree children on iOS 26, so segments
  aren't individually addressable by id. The parent identifier locates the control's
  frame; `verify_segment.sh` then verifies a segment's label + selected state, but
  **requires `--segments N` explicitly** (it can't infer the count through the
  children-empty bug): `--segments 3` for `picker_settings_pronounGender`,
  `--segments 2` for `picker_settings_reviewCardSuppression`. To *drive* a selection, compute
  the segment center from the id'd frame (`x + width*(i+0.5)/N`, `y + height/2`) and
  `tap_xy.sh`.

## Launch arguments and appearance

`xcrun simctl launch <udid> software.racecondition.Conjuguer -CONJUGUER_QUIZ_FIXTURE grading
-AppleLanguages "(fr)" -AppleLocale fr_FR` launches with a quiz fixture and a language. On
2026-11-22 the Conjuguer iPhone 17 kept drawing the app light after `simctl ui <udid> appearance
dark`, through relaunches, while the iPad took dark at once; check dark on the iPad if the iPhone
will not switch.

To seed a stored setting, such as an old `quizDifficulty` to watch it migrate, terminate the app and
write through `defaults` inside the simulator, naming the plist by its full path without
`.plist`: `xcrun simctl spawn <udid> defaults write "$(xcrun simctl get_app_container <udid>
software.racecondition.Conjuguer data)/Library/Preferences/software.racecondition.Conjuguer"
quizDifficulty Ridiculous` (and `defaults delete … quizLevel`). On 2026-11-23 a `plutil` edit of
the same file was overwritten at launch by the preferences daemon's cached copy.

The control's and the shortcuts' stashed link (`widgetPendingDeeplink`) lives in the App Group's
plist, not the app's: `xcrun simctl spawn <udid> defaults write group.software.racecondition.Conjuguer
…` writes a stray file under the device's `data/Library/Preferences` that the app never reads
(2026-11-25). With the app terminated, `plutil -insert widgetPendingDeeplink -string
"conjuguer://verb/random?source=control"` on `$(xcrun simctl get_app_container <udid>
software.racecondition.Conjuguer groups | awk '{print $2}')/Library/Preferences/group.software.racecondition.Conjuguer.plist`
worked, and a launch took it.

## Two windows on the iPad

`-CONJUGUER_SECOND_WINDOW YES` (DEBUG only) asks iPadOS for a second window once the verbs load,
which neither Command-N through AXe nor a swipe could do (2026-11-25). iPadOS keeps the windows'
sessions, so a later launch can restore three or more. On the iPad Pro 11 they open full screen, one
at a time: reach the others through Simulator's Device › App Switcher (computer use, after
`request_access` for Simulator; select the iPad's window through Simulator's Window menu, since
another app's window may cover it). The switcher's thumbnails and their subtitles are snapshots
taken when a window left the screen, so open a window to read its state. `xcrun simctl openurl`
sends a link to the window in front. `axe key-combo --modifiers 227 --key 9` is Command-F, and
`axe key 81` and `axe key 82` are ↓ and ↑.

## Completing a quiz

A default quiz is a round of 10 questions, at the level chosen in Settings, and each miss adds a
re-ask three questions on, or before the results, so a sweep of junk answers runs to 20. A right
answer advances at once; a wrong one holds its
correction until Continue, which a second Return also triggers, so a sweep of junk answers sends
Return twice per question. Loop until `results_score` appears rather than counting. A slip (one letter off, or only accents wrong, in an answer of four
letters or more) first asks for one more try and leaves the answer in the field, so text typed next
is appended to it: set the field's value with `type_text.sh` rather than `axe type` to replace it.
After **Start**, the answer field auto-focuses; type into `input_quiz_conjugation`
and send Return (`axe key 40`) per question. The `N / M` label tracks
position, M growing with each re-ask; the run ends with a `QuizResultsView` sheet (label `Results`).

The field **stays focused across submissions** (`QuizView` re-sets focus after each Return), so a
fast sweep is: tap it once (`tap_id.sh input_quiz_conjugation`), then loop
`axe type "<answer>"` + `axe key 40` (twice after a wrong answer) — batch many pairs into one Bash call and
`screenshot.sh` between batches to check
progress. **Caveat:** if focus is lost (e.g. after a `describe_ui`/screenshot detour),
`axe type`/`axe key 40` silently no-op and the quiz won't advance — re-tap the field by
id before resuming. To exercise all three result icons, mix outcomes: a correct conjugation → a
green check, a dropped accent (e.g. `detends` for `détends`) followed by the right answer → a
hollow orange check, junk (`x`) → a red cross, which holds its correction.

**iPad, 2026-11-23:** `tap_id.sh` and `type_text.sh --id` failed on the Conjuguer iPad Pro 11 with
"typeMismatch … found an array instead" while the quiz showed. Tap Start by its frame from
`axe describe-ui` (≈ `417,787` in the tab), type ASCII with `axe type`, and paste accented answers
with `simctl pbcopy <udid>` and Command-V (`axe key-combo --modifiers 227 --key 25`). With a
hardware keyboard, Return still continues after Back from a linked page.
