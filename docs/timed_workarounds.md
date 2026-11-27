# Timed Workarounds

Every wait the app makes because SwiftUI or UIKit gives it no event to wait for. Each entry says
what the wait is for, how long it is, and how to tell whether a new iOS has made it unnecessary.
Gathered by the Closing of [`plans/verb_browse_fixes.md`](../plans/verb_browse_fixes.md) on
2026-11-27, from every `Task.sleep` in `Conjuguer/`, `Shared/`, and `ConjuguerWidget/`.

To test an entry, set its wait to zero in a scratch build, run the check on the device it names,
and look for the failure it describes. If the failure is gone on the oldest iOS the app supports,
delete the wait and its `Hack:` comment, and remove the entry here. Use Conjuguer's own simulators,
as `CLAUDE.md` and the `verify-in-simulator` skill say.

## The Search Field on iPad

Both browse tabs share these through `SearchEngagement` (`Conjuguer/Utils/SearchEngagement.swift`).
`docs/feature_architecture.md` § The Learner's Verbs (Recents) describes them as behavior. Each is
a task that the next one of its kind cancels (B18 of [`verb_browse_review.md`](verb_browse_review.md)).

| Wait | For | How long | Seen on |
|---|---|---|---|
| `SearchEngagement.lingering` | A tap outside an empty search field ends its focus at touch-down. Views that follow the focus (the recents, the accent key row) would vanish under the finger, so they follow `isEngaged`, which lets go after the wait. | 0.7 s after the last loss of focus | iPadOS 26.3 (Konjugieren); Conjuguer's iPad simulator (B3, B9) |
| `ViewControllerTransitions.waitUntilIdle()` | A push from that same tap arrives while the search is still being dismissed, and UIKit drops it ("the navigation stack will not be updated"). The push, and any accent letter tapped then, waits until no view controller has a transition coordinator or is being dismissed. | Polls every 50 ms, giving up after 1 s; returns at once when nothing is moving, as on iPhone | iPadOS 26.3 (Konjugieren); Conjuguer's iPad simulator (B9) |
| `SearchEngagement.popDuration` | A search request (Command-F, a `search` link, the Find a Verb control) that pops a verb page must wait for the pop before focusing the field. Focus set during the pop updates the focus state without making the field first responder, so typing goes nowhere. | 500 ms after the pop begins | Konjugieren, iOS 26 |

**How to tell.** On the iPad simulator, with something in the recents:

- **The linger:** set `lingering` to `.zero`. Focus the empty Verbs field and tap a recent verb,
  then focus the empty Models field and tap é. If the page opens and the letter lands, the linger
  is unneeded.
- **The dismissal wait:** pass `waitForDismissal: {}` to `SearchEngagement`. Repeat the recent-verb
  tap, then clear the recents, star a verb, choose My Verbs, focus the field, and tap the row (B9's
  check). If each opens its page and the log has no "navigation stack will not be updated", the
  wait is unneeded.
- **The pop:** set `popDuration` to `.zero`. Push a verb page, press Command-F (or open
  `conjuguer://search?q=aller` with `simctl openurl`), and type. Try it on the iPhone too. If the
  letters land in the field, the wait is unneeded.

## The Tutor from Onboarding

| Wait | For | How long |
|---|---|---|
| `InfoBrowseView`'s `.task(id: router.shouldNavigateToTutor)` | Onboarding's tutor button switches to the Info tab and dismisses onboarding's sheet in the same tap, and the tutor page is then pushed onto the Info tab's stack. The code records no reason for the wait. The likely one is the dropped push above, since the push would otherwise arrive during the sheet's dismissal. | 500 ms |

**How to tell.** Set the wait to zero, reset onboarding (Settings, or a fresh install on the
simulator), and finish onboarding from its tutor page's button, on a device or simulator where
the tutor is available. If the tutor opens every time, the wait is unneeded. If it is still needed,
`ViewControllerTransitions.waitUntilIdle()` would wait exactly as long as the dismissal takes.

## The Quiz's Keyboard

`QuizView` gives the answer field the keyboard again in four places by clearing its focus state and
setting it after a wait (`refocusAnswer(after:)`, `refocusField(after:)`). The focus state can read
true after Return or a push has taken the keyboard away, so setting it again at once changes
nothing.

| Where | For | How long |
|---|---|---|
| Back from a page opened from a held correction | The field must be on screen again after the pop, so that Return continues | 450 ms |
| A correction appears, or a slip leaves the first attempt to edit | Return resigned the field | 50 ms |
| A recognition question submitted with a part missing | Return resigned the field | 50 ms |
| A choice question gives way to a typed one | The next question's field must be on screen | 100 ms |

**How to tell.** Set each delay to zero and, on the iPhone simulator with the hardware keyboard
connected: answer a question wrong, tap the correction's verb link, go back, and press Return
(the quiz should continue); answer wrong and press Return twice; press Return on a recognition
card with the tense missing; and answer a choice question and then type the next answer. If the
keyboard is where each step expects, the wait is unneeded.

## The Quiz's Spoken Announcements

| Wait | For | How long |
|---|---|---|
| `Quiz.announcePublishedProperties()` | With VoiceOver running, the next question's prompt (and a speed round's miss) is spoken a second after the question changes. The code dates from 2022 (`7d93d14`, "make accessible") and records no reason. The likely one is that VoiceOver, reading the element that takes its focus as the screen changes, would otherwise talk over the announcement. | 1.0 s |

**How to tell.** Only by ear, with VoiceOver on a device. Set the wait to zero, take a quiz, and
listen for whether each prompt is spoken whole. This belongs with release day's VoiceOver check
(`docs/release.md`).

## Waits That Are Not Workarounds

These wait on purpose and need no new iOS to remove them: the "Address copied" note's four
seconds on screen (`FailedVerbSearchView`; B18 of the review left its race), the entrance
animations' delays in onboarding and the tutor, the Live Activity's stale and linger intervals,
and the quiz's one-second clock.
