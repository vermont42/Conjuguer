# The 2027 Release

What the next App Store release of Conjuguer must do, gathered in one place. `CLAUDE.md` § No
Release Before 2027 points here. Add to this document whenever work on `main` leaves a task for
release time, and delete it, along with that `CLAUDE.md` section, once the release has shipped and
every item below is done. Written 2026-11-22 for Phase 0 of
[`plans/browse_and_verb_implementation.md`](../plans/browse_and_verb_implementation.md), modeled on
Konjugieren's.

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
   Since browse Phase 3 it runs `OpenRandomVerbControlIntent` instead of `OpenRandomVerbIntent`,
   so that the verb page can tell the control from the Shortcuts app. The control's kind did not
   change, so an installed control should run the new intent, but this was never tried on a device.

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

## Afterward

Delete this document and `CLAUDE.md` § No Release Before 2027, and remove the reminders that
point here.
