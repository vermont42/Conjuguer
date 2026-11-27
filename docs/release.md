# The 2027 Release

What the next App Store release of Conjuguer must do, gathered in one place. `CLAUDE.md` § No
Release Before 2027 points here. Add to this document whenever work on `main` leaves a task for
release time, and delete it, along with that `CLAUDE.md` section, once the release has shipped and
every item below is done.

## Why There Is No Release Before 2027

Josh cannot cut an App Store release of Conjuguer, Konjugieren, or Conjugar from his present
MacBook, and he plans to replace it in 2027. He said so on 2026-11-10. TestFlight builds are
probably blocked too, since they need the same upload. Until then, work accumulates on `main` and
the shipped version does not change. When planning, do not sequence work around a near release,
and do not count on shipping a fix or an analytics signal in order to learn from it. Text hosted
outside the app, such as the privacy policy, can still change at any time.

The project's `MARKETING_VERSION` is 2.2. The 2.3 release notes,
[`release_notes_2.3.txt`](release_notes_2.3.txt), were begun for the verb corrections and the
etymologies and have not shipped. What has accumulated since is recorded in the Status tables of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md) and
[`plans/pedagogy_implementation.md`](../plans/pedagogy_implementation.md), which are the raw
material for the release notes.

## Before Submitting

1. **Create the new version in App Store Connect**, and set `MARKETING_VERSION` to match.
2. **Write the release notes** in English and French. Decide whether the release is 2.3, with the
   browse and pedagogy work added to
   [`release_notes_2.3.txt`](release_notes_2.3.txt), or a later number.
3. **Check the App Store description**, [`description.txt`](description.txt), against what the
   app now does, in both languages, and paste it into App Store Connect.
4. **Check the screenshots and previews** against the app, by
   [`screenshot_playbook.md`](screenshot_playbook.md) and [`video_script.md`](video_script.md),
   and redo any that show a screen the plans changed.
5. **Check the Random Verb control on a device** that had it in Control Center before updating.
   It now runs `OpenRandomVerbControlIntent` rather than the shipped `OpenRandomVerbIntent`, so
   that the verb page can tell the control from the Shortcuts app. The control's kind did not
   change, so an installed control should run the new intent, but this was never tried on a device.
6. **Try the lookups from outside the app on a device**, which were tried only in the
   simulator. Look Up a Verb from Siri and from the Shortcuts app: in the simulator the app
   opened on the right page but its spoken or shown answer never appeared, so check that Siri says
   "vais: Indicatif Présent (je) of aller" before opening the page. Spotlight: in the simulator only
   titles matched (aller found its entry; vais, "to go", and souviens found nothing), so check
   whether a device matches the keywords and alternate names. Add the Find a Verb control to
   Control Center and tap it. Long-press the icon for the Find a Verb quick action. Record what
   works in `docs/feature_architecture.md` § Lookup from Outside the App.
7. **Add the four level leaderboards to the version** and try them on a device before submitting,
   by [`game_center_setup.md`](game_center_setup.md) § Testing Before Release. They are in App
   Store Connect, in "Prepare for Submission", and a development build probably cannot see them
   until they belong to a version.
8. **Add the nine achievements to the version** with the leaderboards, and check on a device that
   View Achievements lists them, by [`game_center_setup.md`](game_center_setup.md) § Release Day
   and Testing.
9. **Try two windows on a real iPad, and on a Mac if one is at hand.** Each window owns its
   routing since the browse fixes' Phase 3 (2026-11-25), which was tried only on the iPad
   simulator, where the windows were full screen and reached through the app switcher. With two
   windows side by side: a tab switch in one leaves the other alone; a `conjuguer://` link, a
   widget's tap, and Look Up a Verb open in one window, not both; Command-F opens the search of the
   window in front; and ↑ and ↓ move the highlight only in the window whose field is focused. On
   the Mac, check also that a link does not open a new window, which SwiftUI's `WindowGroup` may do
   there for an external event.
10. **Check that the control's and the shortcuts' links open at once, warm and cold** (finding B10
    of [`verb_browse_review.md`](verb_browse_review.md), Phase 12 of the browse fixes). The Find a
    Verb, Random Verb, and Quick Quiz controls and the Random Verb shortcut each leave a link in
    the App Group's defaults (`PendingDeeplinkIntent`), and a window takes it only when it becomes
    active (`SceneRoot.drainPendingWidgetDeeplink`). If the intent's `perform()` runs after that
    moment, the link waits for the next activation, which may be days later. Try each of the four
    twice: once with the app killed, and once with it in the background on another tab. Each
    should open its page or tab on that tap. Then put the app in the background and bring it
    back, and kill it and launch it from its icon: no page should open by itself. If one does, or
    a tap opens nothing until the next activation, fix it by one of two ways and record which in
    `docs/feature_architecture.md` § Deeplinks:
    - **`OpenURLIntent`.** Have each intent return `.result(opensIntent: OpenURLIntent(url))`, so
      the system opens the link itself and the mailbox goes. This is the better fix if the control
      accepts it; Konjugieren's `docs/control_center_controls.md` records that a control's intent
      could not open a URL itself, so try the control first.
    - **A timestamp on the stashed link.** Store the time beside the link, have
      `drainPendingWidgetDeeplink` drop a link older than a minute, and have the app also drain
      when the shared defaults change while it is active (a Darwin notification that the intent
      posts, since `UserDefaults` does not notify across processes). The first stops a stale link
      from firing days later; the second opens a link that arrives after activation.

## On Release Day

1. **The privacy policy.** Analytics added on `main` since the last release need lines in the
   policy on the day the release ships, and not before. They wait in
   [`privacy_policy_pending.md`](privacy_policy_pending.md), which says how to apply them to
   [`privacy_policy2.txt`](privacy_policy2.txt).
2. **Which policy is deployed.** Two policy files list the analytics: `docs/privacy_policy2.txt`
   (bilingual, effective 2026-06-30) and `privacyPolicy4.md` at the repository root, whose name is
   kept because the App Store listing may point at it. Check which one the listing's privacy URL
   serves, and bring that one up to date with the same lines, or point the listing at the one that
   is current.
3. **Game Center.** Submit the four level leaderboards and the nine achievements with the
   version, then, once the release
   is live, archive the old `Leaderboard` and consider making Beginner the default, by
   [`game_center_setup.md`](game_center_setup.md) § On Release Day.

## Afterward

Delete this document and `CLAUDE.md` § No Release Before 2027, and remove the reminders that
point here.
