# Blog notes

## Large widget: real source attribution + fuller use of space (2026-07-13)

The large "Verb of the Day" widget had two rough edges, both visible in a `paraître`
screenshot. First, the example-use source read as a bare corpus filename —
`— zola-lassommoir-1877.txt` — instead of a human-readable citation. Second, the
example and etymology were clamped to 2 and 3 lines, so both truncated with "…" while
the bottom ~third of the widget sat empty (measured ~5–6 caption2 lines of dead space
below the etymology).

Fixes:

- **Real book/author.** The app already had the machinery: `ExampleSource.attribution`
  (in `Conjuguer/Models/ExampleSource.swift`) maps a raw corpus source like `zola-…` to
  `— Émile Zola, « L'Assommoir » (1877)`, and `VerbView` renders
  `example.provenance.attribution` directly. The widget path just never used it —
  `WidgetSnapshotWriter.generateSnapshot` stored `example?.source` (the filename)
  verbatim. Since `ExampleSource` is app-only (not in `Shared/`) and its `attribution`
  reaches into the app's `L` localization, computing the attribution at *snapshot-write
  time* in the app is the natural place: `exampleSource: example.map { $0.provenance.attribution }`.
  The widget then renders it verbatim (the string already carries the "— " lead-in), so
  `LargeWidgetView` dropped its old `"— \(source)"` re-prefixing. Updated the
  `SnapshotReader` placeholder's `exampleSource` to `"— Exemple"` to match the new
  convention. The `WidgetSnapshot.exampleSource` field now holds an attribution rather
  than a filename; left the field name as-is to avoid churning the Codable key (snapshots
  regenerate daily anyway).

- **Fill the space.** Bumped the example French `lineLimit` 2→4 and the etymology
  `lineLimit` 3→6, and gave the source line a 2-line cap (Wikipedia attributions can
  wrap). Geometry check against the screenshot: etymology lines were ~50px tall and there
  were ~290px of empty widget below them (~5.8 lines), so +5 content lines (example +2,
  etymology +3) fills to within ~40px of the bottom in the common single-line-source
  case — full without routinely overflowing. Worst case (long example + 2-line source +
  long etymology all at once) may clip the final etymology line, which degrades
  gracefully. The etymology write-time cap (360 chars, sentence-boundary-truncated) is
  already enough to feed 6 lines, so it was left alone.

Not touched (out of scope): the example text still shows the corpus's literal
`_Assommoir_` underscore markup in the quotation — a separate cosmetic issue.

Build green (app + widget). No tests referenced the old raw-filename `exampleSource`.
Widget rendering was reasoned from geometry rather than screenshotted (driving a home-
screen widget on the simulator is not part of the ios-build-verify flow).

## A kill switch for a screenshot that was already shipping (2026-07-18)

Ported from Conjugar, where the same switch shipped earlier today. The premise was not
hypothetical, which is what made it worth doing: the "Apple Intelligence is still getting
ready. Please try again later." cell was *already sitting in the `version_3` bundle on
disk*, in both iPad `info_browse` shots. I opened `version_3/iPad_English/6.png` to check
rather than take the claim on faith, and there it was — and worse than a stray notice, it
skews the Concepts grid, pushing Defectiveness down and out of alignment with its row.

The mechanism is structural, not a fluke. `World.simulator` injects the *real*
`LanguageModelServiceReal`, so even in the simulator the app asks
`SystemLanguageModel.availability`, resolves against the host, and gets `.unavailable`.
There is no simulator configuration that makes the tutor available; the fallback cell is
the only thing a sim can ever render there.

Two things about the port surprised me.

**Conjuguer needed two branches gated where Conjugar needed one.** Conjugar has a single
`@ViewBuilder tutorSection`; Conjuguer splits it by size class into `tutorListRow`
(iPhone `List`) and `tutorGridCell` (iPad `LazyVGrid`). Gating only the list row would
have left the iPad — the one device where the bug is actually visible — unchanged, and
would have been trivially easy to "verify" on iPhone and call finished. So I checked all
four combinations (two size classes × switch on/off) rather than the two that would have
looked convincing.

**The iteration I budgeted for never happened.** The plan flagged the iPhone call site as
the risky part: when `tutorListRow` resolves to empty, SwiftUI's `List` might still emit a
row container, leaving a ghost cell with a background and separators. It doesn't. The
AXTree settles it — Concepts holds exactly four 51pt rows, contiguous, and the gap to the
"Tenses" header is 22pt, identical to the About→Concepts gap. No hoisting of the condition
into the `if` was needed. Worth recording because the plan's guess about where the risk
lay was wrong, and the cheap measurement beat the reasoning.

The switch only ever gates the `else if let reason = …` branch, never the `isAvailable`
branch, so it structurally cannot hide a *working* tutor. That constraint is the whole
reason this is a safe thing to leave in the codebase.

Two incidental findings, both of the "documentation confidently describes something that
does not work" variety:

- **The `sed` commands in the plan are broken on macOS.** They split one expression across
  lines with a trailing backslash; BSD `sed` answers `newline can not be used as a string
  delimiter` and changes nothing. I only caught it because I ran the round-trip and the
  sha "matched" — a false pass, since *both* directions had no-opped. The `-e`-per-
  substitution form works, and the playbook now carries that plus a `grep` verification
  line, because `sed` exits 0 when a pattern matches nothing: rename a switch and the
  sweep quietly proceeds with tips and the tutor row still on.
- **The bundle projection loses a screenshot.** `version_3` had ten PNGs per folder where
  the playbook documented nine. Slot 10 is a hand-captured arcade-game shot the driver has
  never produced (its status bar reads `100%` and an unrelated date, so it visibly isn't
  from a sweep). Regenerating a bundle straight from `latest/` would have silently dropped
  it — ten screenshots down to nine, no error. `version_4` carries it forward explicitly
  and the playbook now says so.

Also corrected the stale playbook claim that "none of the 9 target screenshot views depend
on the Tutor row." It is wrong for iPad. iPhone escapes only by accident: `scroll_until_top
info_row_participe_passe 170` happens to push Concepts off the top. That is a calibration
number, not a guarantee — retune it and iPhone inherits the problem.

Re-shot the two iPad cells and cut `version_4`. A sha diff against `version_3` shows
exactly two files changed and the other 38 byte-identical. The sim needed handling first:
it was left in **Spanish** (`es_ES`) with a bogus `Carrier` override by the concurrent
Konjugieren session, and the iPad status bar renders its date in the *system* language,
independent of the app's `-AppleLanguages`. So each language is a set-language → reboot →
re-apply-override cycle before its capture. The driver's `scroll_until_top … not at/above
y=200 after 15 swipes` warning on both iPad runs is benign — the whole Info screen fits on
a 13-inch iPad, so there is nothing to scroll. I read both PNGs rather than trusting the
exit code, per the Conjugar lesson that a clean exit says nothing about which screen was
captured.

Both switches are restored to `true`; `git diff` on `ConjuguerTips.swift` shows only the
new `TutorDisplay` enum.
