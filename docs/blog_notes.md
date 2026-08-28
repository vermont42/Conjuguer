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

## InfoView: the article heading was a truncating navigation title (2026-07-25)

Josh sent a screenshot of the *Conditionnel Passé* Info article on a 375pt-wide phone at a
raised Dynamic Type size. The navigation bar read **"Conditionnel Pas…"**. The cause was
`InfoView`'s `.navigationTitle(shouldShowInfoHeading ? "" : info.heading)`: a UIKit large
title truncates rather than wraps, and it scales with Dynamic Type, so it runs out of width
twice over — narrow screen *and* big text. The longest heading, "Subjonctif
Plus-que-parfait", would truncate even at default type on a modern phone.

Reproducing took a detour. On the configured simulator (iPhone 17, 402pt) at default type,
"Conditionnel Passé" fits exactly, so the first capture looked fine. Bumping the sim to
`xcrun simctl ui <udid> content_size extra-extra-extra-large` reproduced it — note the
option is spelled `content_size` with an underscore, while `simctl`'s own usage text lists
it that way but the obvious `content-size` guess silently prints the usage block and
returns success, so a compound command sails past the failure.

There was no clean way to make a large title wrap — SwiftUI gives no hook into the
navigation bar's title label, and `.navigationBarTitleDisplayMode(.inline)` merely shrinks
the font and truncates later. The better answer was already in the codebase: `VerbView` and
`ModelView` set no navigation title at all and render their heading as the first `Text` of
the scrolling content, where it wraps. `InfoView` was the outlier, and it already had that
exact layout behind `shouldShowInfoHeading` — which the two sheet call sites passed `true`
and only the pushed nav destination left `false`. So the fix was to delete the flag, always
show the in-content heading, and drop `.navigationTitle`. (This also resolves a standing
code-review note in `prompts/code-review-suggestions-union.md`, which had flagged
`VerbView.shouldShowVerbHeading` as vestigial and pointed at `InfoView` as the version that
honored its flag. Now neither has one.)

Small bonus while the heading moved: it now carries
`.frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)`, matching what
`InfoBrowseView` already does for the identical string in its rows. A navigation title
could never get that, so VoiceOver had been reading "Conditionnel Passé" with English
phonology on this screen.

Verified by pushing the worst-case article at XXXL type and at default: the full heading
renders on both, wrapping when it must. 219 tests pass; SwiftLint `--strict` clean.

## App Store description refreshed for 2.0 (2026-07-25)

`docs/description.txt` had been carrying launch-era numbers. Rather than trust them, every
numeric claim got re-derived from the shipping data files:

- **5,222 regular / 1,098 irregular** (was 5,217 / 1,097). Computed by walking
  `verbModels.xml`'s `pa` inheritance chain and treating a model as regular when no ancestor
  contributes a stem alteration (`p`) and the participe ending is lowercase — the same two
  inputs `VerbModel.computeIrregularities()` uses. Exactly three models qualify: `1-1`
  (parler), `2-1` (finir), `5-1A`. Total checks out at 6,320, matching CLAUDE.md.
- **Seventy-seven defective verbs** (was sixty-six). 73 verbs carry a `dg` attribute
  directly; four more (chauvir, contrefoutre, déclore, refoutre) inherit defectiveness from
  their model, and the parser resolves both, so 77 is the honest number. The three exotics
  named in the copy — ester, issir, gésir — are all verb-level `dg`, so they survive the
  recount.
- **981 frequency ranks, être → ancrer** — still exactly right (`Verb.maxFrequency = 981`;
  rank 1 is être, 981 is ancrer). Aside: 982 verbs carry an `fr` attribute because *sortir*
  appears twice at rank 56. Not worth mentioning in marketing copy, but noted here in case a
  future session sees the off-by-one and thinks the constant is stale.
- **réaliser has eight translations** — verified against its `tn` attribute. Claim holds.
- Etymologies: 986 verbs (`Etymologies.json`, en + fr both 986) → "nearly a thousand".
  Examples: 1,126 verbs in `literature_examples.json` → "more than 1,100"; 332 nested
  *Chanson de Roland* entries.

Added the four features Josh asked for (Tutor, widgets, etymologies, example uses). The
widget paragraph goes beyond the release notes deliberately: the notes mention only the
Verb of the Day widget, Control Center, and the Live Activity, but the target also ships
`QuizWidget` (answerable in place via `AnswerQuizIntent`) and `RandomVerbControl` alongside
`QuickQuizControl`, so the copy names all four surfaces.

Deliberately left out, since the ask was scoped to those four: the Arc de Triomphe game,
alternate app icons, and the first-launch tour. Easy to add if Josh wants the description to
mirror the release notes more closely.

Max length: App Store descriptions cap at **4,000 characters** (subtitle 30, promotional
text 170, keywords 100). The new copy is 1,829 — no pressure at all, and room to grow if the
omitted features get added. French translation deferred at Josh's request.

## French for the description; release-notes game paragraph resynced (2026-07-25)

Josh added an arcade-game paragraph to `docs/description.txt` and softened the same
paragraph in `docs/release-notes-2.0.txt` ("family-friendly", and combat / high score
dropped from the feature list). Two jobs: retranslate that one release-notes paragraph, and
translate the whole description.

`git diff` confirmed the release-notes edit was a single line, so only the French game
sentence moved: `combat` and `meilleur score` deleted, `familial` added. Nothing else in the
French half needed touching — worth checking rather than assuming, since the English summary
paragraph (line 6) also mentions the game and could have picked up "family-friendly" but
didn't.

For the description translation, terminology came from the app's own catalogs rather than
from invention:

- Tab names from `Localizable.xcstrings`: the Info tab is **Info** in French (not "Infos")
  and Settings is **Paramètres** (not "Réglages"). `Tutor.heading` is "Tuteur de
  Conjugaison", so the description says *le tuteur de conjugaison*.
- Widget names from `ConjuguerWidget/Localizable.xcstrings`: « Verbe du jour », and the quiz
  widget is "Quiz de conjugaison".

**Known divergence, left alone deliberately:** the release notes' French says *l'onglet
Infos* and *les Réglages*, which don't match the app's actual French UI. Fixing that wasn't
part of the ask, and it's Josh's copy, so it stayed — flagged in the reply instead.

Typography follows each file's existing house style, which differs between them:
`release-notes-2.0.txt` uses straight apostrophes throughout, `description.txt` uses curly
(`’`) plus curly double quotes in the English half. The French translation therefore uses
curly apostrophes and guillemets « », and French thousands separators (5 222, 1 098, 1 100).
The `_all_` / `_full_` underscore emphasis carries over as `_tous_` / `_complètes_`.

Lengths after the edit: English 1,993 characters, French 2,309 — each independently under
the 4,000-character App Store cap, which is what matters, since the two localizations are
submitted as separate fields rather than as one file. Twelve paragraphs on each side.

### Follow-up: release-notes French aligned to the app's tab names (2026-07-25)

Josh said align, so the divergence flagged in the previous entry is gone. Four sites in
`docs/release-notes-2.0.txt`, all in the French half:

- l'onglet **Infos** → l'onglet **Info** (twice: the Tutor paragraph and the sources
  sentence)
- se cache dans les **Réglages** → dans les **Paramètres**
- articles d'Infos regroupés → **articles de l'onglet Info regroupés** — a literal "articles
  d'Info" reads wrong in French, so this one needed rephrasing rather than a token swap

Done with a Python pass that asserts each old string occurs exactly once before replacing,
so a silent no-op or an over-broad replace would have thrown instead of quietly producing
plausible-looking output. The two marketing files now agree with each other and with
`Localizable.xcstrings`.

Not touched, and worth a decision before the next French copy is written: the French half
says « l'île dynamique » for Dynamic Island, which Apple France leaves untranslated. Outside
the alignment ask, and a different question (Apple's own terminology, not Conjuguer's), so
it stayed.

### Follow-up: Dynamic Island left in English (2026-07-25)

« l'île dynamique » → « la Dynamic Island » in both marketing files (release notes line 33,
description line 40), matching Apple France, which ships the name untranslated. Feminine
article, per Apple's own French copy.

Deliberately *not* untranslated alongside it: « activité en direct » and « centre de
contrôle ». Those look like the same case but aren't — Apple France does translate Live
Activities and Control Center, so the French there is already the correct localized name.
Dynamic Island is the outlier.

## App Store media rejected: two different problems wearing one error (2026-07-25)

Josh hit "The dimensions of one or more previews are wrong" on the 2.0 version page and
read it as one problem — sizes are off. It was two, and only one of them is what the banner
says.

**The video.** The banner is about the preview only: it wants 886 × 1920, and
`English iPhone.mov` was 1320 × 2868. Probing the file turned up three more violations the
banner never mentions, all of which would have bounced it on the next upload:

- H.264 **Level 5.0**; Apple caps app previews at High Profile **Level 4.0**
- **15.2 Mbps**; the spec's target is 10–12
- audio at **126 kbps**; the spec asks for 256 kbps stereo AAC (48 kHz was already fine)
- a stray **data track** (stream 2), and Apple requires all tracks be enabled

Re-encoded to `~/Desktop/ASC-upload/video/`. Two traps in doing it. First, `-map 0:v:0 -map
0:a:0` alone did *not* drop the data track — `-dn` was needed. Second, and easy to miss: the
first re-encode came out **30.014 s** against a hard 30 s maximum, from a source that was
exactly 30.000. Fixed with `-frames:v 900` (900 ÷ 30 fps = exactly 30.000 s) plus
`-shortest`. Worth re-probing every output rather than trusting the command; the first
attempt looked clean and was over the limit.

Aspect ratios don't quite match — 1320:2868 is 0.4603, 886:1920 is 0.4614 — so
`scale=886:-2,crop=886:1920` scales by width and trims ~3 px off each end rather than
stretching by 0.24%.

**The screenshots.** Not what Josh assumed. 1320 × 2868 is a *valid* App Store size — for
the **6.9" display**. The tile he dropped onto is the **6.5" Display** tile, which takes
only 1242 × 2688 or 1284 × 2778. The version page shows just that one iPhone tile (1.5
shipped 6.5"); the 6.9" slot is behind "View All Sizes in Media Manager".

Independently, all ten PNGs are **RGBA**, and Apple's spec is explicit: "Images can't
include alpha channels or transparencies." They'd have failed in the 6.9" slot too. This one
was invisible from the error banner and only surfaced from `file`/`sips` on the originals —
worth checking first on any future screenshot batch, since the capture pipeline evidently
produces alpha by default.

Built both sets under `~/Desktop/ASC-upload/`: a 6.9" set (same pixels, alpha stripped) and
a 6.5" set (scaled to 1284 wide, 12 px center crop, alpha stripped). Spot-checked the 6.5"
crop at thumbnail size — status bar and tab bar both survive.

Originals untouched; everything written to a new Desktop folder. Nothing uploaded — that's
Josh's call. Still to do if he wants them: the French iPhone set and both iPad sets, which
almost certainly carry the same alpha flaw and the same preview-encoding flaws.

Aside, from reading the live page: the Description field already holds the new English copy
at 2,007 characters (our file is 1,993 — the field appears to count slightly differently),
so that part of the listing is in place.

### Follow-up: remaining previews converted, French screenshots fixed (2026-07-25)

The iPad question answered itself on probing: `English iPad.mov` and `French iPad.mov` are
**2048 × 2732**, and iPad app previews must be **1200 × 1600**. They also repeat every
secondary flaw the iPhone video had, one of them worse — **Level 5.1** (cap is 4.0), 12.6 /
13.8 Mbps (target 10–12), 126 kbps audio, and the same stray data track. So: yes, all three
needed converting, and none of them for the reason the App Store Connect banner gave, since
that banner only ever mentioned dimensions.

Convenient accident: iPad's 2048 × 2732 is 0.7496 against 1200 × 1600's 0.7500 — near-perfect
4:3, so the scale-and-crop trims about one pixel. The iPhone pair loses ~3 px per end.

All four previews now: 30.000 s exactly (900 frames), H.264 High L4.0, 30 fps, AAC stereo
48 kHz ≈ 249 kbps, two streams each, 21–28 MB. Video bit rates land at 5.7–7.6 Mbps against
Apple's 10–12 "target" — flat UI content gives x264 nothing to spend bits on. It's a target
rather than a limit, and it can be forced higher if a reviewer ever objects.

French iPhone screenshots had the identical RGBA flaw as the English set, so both variants
were built the same way. English output folders got renamed to `screenshots_English_*` to
match.

**Open, and not done because it wasn't asked:** the iPad screenshots
(`version_4/iPad_English`, `iPad_French`) are **2064 × 2752** — a valid 13" size, so no
resize needed — but they are **RGBA** too and will be rejected on that alone. One flatten
pass away from usable.

### Follow-up: iPad screenshots flattened (2026-07-25)

Both iPad sets flattened to RGB. No resize was strictly needed — 2064 × 2752 is a valid 13"
size — but a 2048 × 2732 (12.9") variant went alongside it, for the same reason the iPhone
upload failed in the first place: the version page exposes exactly one tile per device
family, and which size that tile wants depends on what the app shipped last time. The iPhone
tile turned out to be 6.5" rather than 6.9". Having both iPad sizes on disk means whichever
tile the iPad section shows, a matching set is ready without another round trip.

2064 × 2752 is exactly 3:4; 2048 × 2732 is 0.74963, so the 12.9" variant scales by height
and loses one pixel of width.

`~/Desktop/ASC-upload/` is now complete: 8 screenshot folders (2 languages × {iPhone 6.9,
iPhone 6.5, iPad 13, iPad 12.9}, 10 images each) plus 4 previews. Every file verified for
dimensions and absence of alpha by assertion rather than by eye — `file`/`sips` output
filtered for anything that *doesn't* match the expected value, so a silent miss shows up as
output instead of as a clean-looking run. Nothing uploaded; all originals untouched.

## Hardening the App Store media pipeline against a repeat (2026-07-25)

After fixing the rejected 2.0 media by hand, Josh asked for doc changes so it doesn't
happen again. Reading the four media docs turned up something better than a gap: a
**factual error** that actively caused the failure.

`docs/app-store-preview-videos.md` specified Final Cut projects at 1320 × 2868 (iPhone)
and 2048 × 2732 (iPad) and asserted "These are Apple's standard App Store app-preview
sizes." They are *screenshot* sizes. Previews take **886 × 1920** (every current iPhone
class — 6.9/6.5/6.3/6.1, one file serves all) and **1200 × 1600** (iPad). The doc even
reasoned its way there explicitly, rejecting 886 × 1920 as "the legacy 6.5″ size, still
accepted" in favor of the size with an exact-pixel simulator match. Pixel-exactness with
the simulator is worth nothing when the delivered file is a size the store refuses —
Konjugieren, which the doc was ported from, had it right all along. That note is now
inverted into a warning that names the mistake, so a future reader hits the correction
where the error used to live.

Six changes, all applied:

1. **Preview doc**: project table corrected to 886 × 1920 / 1200 × 1600; simulator table
   reframed around "record native, scale down in the project" with Spatial Conform =
   **Fill** on iPhone (0.4603 vs 0.4614 — *Fit* would letterbox).
2. **Preview doc, new "Export settings and conformance" section**: the four violations
   FCP's default export produced that the error banner never mentioned (Level 5.0/5.1,
   15–16 Mbps, 126 kbps audio, stray timecode track), plus the ffmpeg normalization pass
   as a guaranteed-conformance final step. Called out the two non-obvious flags: `-dn` is
   required because `-map 0:v:0 -map 0:a:0` does *not* drop the data track, and
   `-frames:v` is how duration gets pinned.
3. **`video_script.md`**: was engineered to land at exactly 30.000 s — the hard maximum,
   zero margin. Retargeted to 29 s, citing the 30.014 s re-encode that would have been
   rejected.
4. **`take_screenshots.sh`**: flatten each capture at `take_screenshot()`. `axe screenshot`
   writes RGBA and Apple forbids alpha, which is why all 40 `version_4` files failed. The
   driver warns rather than dying if `magick` is missing.
5. **`screenshot-plan.md`**: new section on confirming which display-size *tile* App Store
   Connect is offering. This was the subtler half of the failure — 1320 × 2868 is a
   perfectly valid size that was rejected because the page showed a 6.5" tile (1.5 shipped
   6.5"). Includes downscale recipes for both device families.
6. **`scripts/verify_store_media.sh`** (new): the durable fix, since docs get skimmed and
   an executable check does not. Asserts accepted dimensions, no alpha, duration bounds,
   H.264 level ≤ 4.0, exactly 2 streams, frame rate, audio bit rate.

The verifier was tested against known-bad and known-good inputs rather than assumed
correct: `version_4` → 40 alpha failures, exit 1; the original `.mov`s → wrong dimensions
+ Level 5.0 + 3 streams + 126 kbps audio, exit 1; `~/Desktop/ASC-upload` → all clear,
exit 0; bad path → exit 2. It also emits a WARN (not a failure) on the four fixed videos,
since I encoded them at exactly 30.000 s before writing the 29 s guidance — accurate, and
a good demonstration that the margin check fires.

One judgment call: the accepted-size lists are hardcoded, so a genuinely new Apple display
class will look like a broken export. There's a comment at the list saying so, and both
docs now say to re-read Apple's spec pages each release rather than trusting local tables.

### Follow-up: ported to Konjugieren, and the severity split was wrong (2026-07-25)

Porting today's media hardening to the sibling app turned up evidence that corrected work
done here earlier in the session.

Konjugieren's shipped 1.2 previews (on disk at `~/Desktop/Final/Konjugieren`) carry H.264
**Level 5.0/5.1**, **125 kbps** audio, and a **third timecode stream** — and they are live
on the App Store. So App Store Connect enforces *dimensions* strictly and tolerates the
codec-detail deviations. `verify_store_media.sh` as first written failed all of those,
which would have blocked files that demonstrably shipped, and the playbook line claiming
"everything it checks is something that has actually been rejected or nearly rejected
here" was simply false.

Both were corrected: the script now grades **blocking** (wrong dimensions, alpha, duration
outside 15–30 s) versus **advisory** (level, audio bit rate, stream count, no-margin
duration), with the evidence recorded in a comment at the split so a future reader can
promote an item if one ever does block an upload. `app-store-preview-videos.md` gained a
paragraph saying plainly that of its conformance table, dimensions and duration are
enforced and the rest is cleanup.

Re-tested after the change: `~/Desktop/ASC-upload` → 0 blocking / 4 advisory, exit 0;
`~/Desktop/Final/Konjugieren` → 3 blocking (two superseded 2048 × 2732 iPad masters plus a
**30.015 s** file that is genuinely over the cap) / 21 advisory, exit 1; Conjuguer's
original previews → 12 blocking.

Konjugieren also had two latent problems of its own — every driver-produced `version_2`
screenshot is RGBA (its four hand-made `10.png` slots are RGB, which is what identifies the
driver as the source), and that 30.015 s preview. Its `video_script.md` had the same
zero-margin arithmetic this repo's did. Details in that repo's journal.

### Follow-up: the second rejection — non-square pixels (2026-07-25)

The iPad preview was rejected again after the dimension fix, from the correct Media
Manager tile, with the same "dimensions are wrong" wording. The file was 1200 × 1600. The
file was also wrong.

`ffmpeg`'s `scale=W:-2` rounds the computed height to an even number and then **preserves
the source display aspect by writing a compensating sample aspect ratio** rather than
accepting the rounding. So the output carried `SAR 2048:2049` — non-square pixels — and a
*display* aspect of 512:683 instead of 3:4. `width`/`height` read 1200 × 1600 to every
check I had. App Store Connect evaluates display dimensions and refused it, using the
identical error message a genuinely mis-sized file produces. The iPhone files had it too:
`SAR 105930:105877`.

What made this diagnosable was the sibling app: Konjugieren's *accepted* previews probe as
`SAR 1:1, DAR 3:4`. Comparing a known-good file against a known-bad one field by field
found in one step what reading the spec would not have — Apple's page says nothing about
pixel aspect ratio.

Fix is `setsar=1` between the scale and the crop. All four re-encoded; they now match
Konjugieren's accepted geometry exactly, at 29.000 s (the new guidance) rather than the
earlier 30.000 s, so the bundle is 0 blocking / 0 advisory.

**The verifier's failure is the more useful lesson.** It checked `width`/`height` and
passed the file — a check that confirms the thing you thought to measure while the actual
requirement sits one field over. It now fails on any SAR that isn't 1:1, with the ffprobe
incantation and the fix in the message.

Also worth recording: my first regression test for the new check was worthless. I re-scaled
an already-square file and watched it stay square, which proves nothing. The real test
re-derives the bad file from the original 2048 × 2732 master with the old command,
confirms `SAR 2048:2049` came back, and then checks the verifier blocks it. A regression
test that can't reproduce the bug isn't a regression test.

Both repos updated: `setsar=1` in the ffmpeg recipe, the SAR check in both copies of
`verify_store_media.sh`, and the trap written up in both video docs.

### Outcome: 2.0 media accepted, submission succeeded (2026-07-25)

The `setsar=1` re-encode was accepted and Conjuguer 2.0 went in. Recording what that
does and does not prove, since the docs written today were based on inference:

**Confirmed.** 886 × 1920 / 1200 × 1600 are the right preview sizes. Square pixels matter.
Flattened screenshots pass. A 29.000 s preview at H.264 High L4.0 with 256 kbps stereo
audio and exactly two streams is accepted.

**Not isolated.** The accepted re-encode changed *two* variables at once — it added
`setsar=1` and moved duration from 30.000 s to 29.000 s. SAR is much the likelier culprit
(Konjugieren shipped a 30.015 s preview, so the cap clearly isn't enforced to the
millisecond), but the upload didn't separate them. Noted in the preview doc rather than
quietly claiming a clean causal result.

**Still unmeasured.** The advisory tier remains advisory on Konjugieren's evidence alone.
Today's files were conformant on every advisory item, so nothing new was learned about
whether Level 5.0, 125 kbps audio, or a stray timecode track would block an upload today.

Josh asked why App Store Connect rejects alpha at all. Worth checking rather than
speculating: the `version_4` captures were **fully opaque** — `magick … -alpha extract`
reports max alpha at every pixel — so Apple refused a channel containing no information.
That reframes the rule usefully: it is a *format* check, not a *content* check. Apple
publishes no rationale, but the plausible one is that screenshots get re-derived into
scaled variants and JPEG representations, JPEG has no alpha, and partial transparency
would need a compositing rule that differs between the store's light and dark chrome —
so refusing the channel outright is cheaper and more deterministic than proving every
pixel opaque. Written into `screenshot-plan.md` in both repos, because "but it looks fine"
is the natural (wrong) reaction to this rejection.

## Six screenshot-driver fixes ported from Konjugieren, plus a seventh found while verifying (2026-07-26)

Konjugieren — the German sibling app — ran its 1.3 screenshot sweep and wrote up six
defects the sweep exposed, all in a driver that had been ported from *this* repo. Josh
asked to port the fixes back. The through-line worth keeping is not the six diffs: it is
that **not one of those failures announced itself**. No non-zero exit, nothing in the log,
no missing file. Each produced a plausible-looking screenshot of the wrong thing, and two
had been shipping in Konjugieren's App Store listing for two releases. A green sweep is
not evidence of a correct sweep. That is the whole argument for doing this work *before* a
release shoot rather than after.

**Plugin resolution was picking an arbitrary release.** `resolve_ibv_scripts` searched
`~/.claude` broadly for `ios-build-verify`. That glob matches the marketplace clone *and*
every version under `plugins/cache/ios-build-verify/<version>/`, which holds several at
once and is shared across Josh's apps. Confirmed live here: the cache held 0.2.1 and 0.3.1,
and `find` — whose directory order is unspecified — returned a cache copy first. So which
release built the App Store screenshots was luck. Narrowed the search to
`~/.claude/plugins/marketplaces`, which has no version segment and yields exactly one
match. Fixed the same glob in CLAUDE.md, which had it too.

**`frame_of` now takes the largest-area match, and this one is a safety net here rather
than a live fix.** An id can match several AXTree elements; `[0]` took whichever
depth-first reached first. In Konjugieren an iPad Info row exposed its heading as an
`AXStaticText` sitting *above* the tappable `AXButton`, and tapping non-interactive static
text does nothing at all — silently — so four cells captured the Info list instead of the
article. Worth recording that **preferring `AXButton` is the obvious fix and is wrong**:
Konjugieren tried it first, and on iPad a verb row exposes its translation as a button
while the infinitive is static text, so that rule taps the translation and stops
navigating. It fixed `info_view` and broke `verb_view`. Largest-area is the only rule
correct at all five tap sites, and it has a reason rather than merely fitting the data —
the element standing for the whole row is the widest one. Then I checked whether Conjuguer
actually needs it: tabulated every tap site (`verb_row_avoir`, `model_row_être`,
`quiz_start_button`, `input_quiz_conjugation`, and the three `info_row_*`) on both devices
in both languages, and **every single one has exactly one match**, so old and new selectors
agree everywhere today. Kept the change anyway — it costs nothing and it degrades to the
old behaviour wherever the old behaviour worked — but labelled it honestly in the playbook
so nobody later reads it as having fixed a bug here.

**The tab coordinates really were another app's measurements.** The iPad row
(`355 / 441.5 / 523 / 587.75 / 667.25`) was byte-identical to Konjugieren's, which is a
measurement of *German* labels. Conjuguer's second tab is Models, not Familien. Measured
from the AXTree: English centres are `386.25 / 469.5 / 547.75 / 612.5 / 692`, so every
inherited number was 20–30 pt off. They all still *landed inside* the right segment —
which is exactly why this survived; `Info` cleared its boundary by 6.25 pt. French differs
again (`Verbes` 369, `Paramètres` 701.5), because the iPad's regular size class sizes each
segment to its label, so one longer word displaces every centre after it. `tab_coords_for()`
now takes a language as well as a device, resolved inside the language loop. The iPhone
needs no equivalent and the reason is structural, not luck: the compact pill distributes
items into equal-width slots, so a localized label changes the text without moving the slot
centre. Verified by reverse-probing all five iPhone coordinates in both languages, which is
the only way — the pill exposes no `AXRadioButton` children at all.

**Waiting for the screen to stop moving is the fix with the broadest reach, and no
accessibility check can substitute for it.** Switching tabs on iPad cross-fades. The
outgoing screen's anchor leaves the AX tree within ~0.3 s of the tap while the fade is
still plainly visible, because AX state answers "has the hierarchy changed" while a
screenshot is graded on "has the image stopped moving" — and those diverge precisely
during animation, which is exactly when a capture goes wrong. Konjugieren shipped captures
with the previous screen's verb list ghosted through them. `wait_for_stable_screen` now
samples screenshots 0.35 s apart and compares with `magick compare -metric AE` until
consecutive frames settle. Two implementation details that bite: `magick compare` **exits 1
whenever the images differ**, which is the normal case, so under `set -o pipefail` the
assignment fails and `set -e` kills the sweep — hence the load-bearing `|| true`; and the
metric comes back in scientific notation (`1.53e+10`), so the comparison has to go through
`awk`, not `[[ -le ]]`.

The tolerance was **measured here, not copied** — Konjugieren's 1e8 is a measurement of a
different app. It cannot be zero, because Conjuguer's quiz screen never settles: the
elapsed-time counter ticks with a `.snappy` animation and the cursor blinks. 18
consecutive-frame samples on the iPhone quiz screen ran 6.4e6–2.5e7 (iPad 2.4e6–6.9e6; a
static screen such as Settings scores exactly 0). Against that, an iPad tab cross-fade
sampled 1.2e8 just after the tap, 2.8e10 at the content swap, and 7.4e8 still fading
0.35 s later. `5e7` is the geometric middle of the 2.5e7 ↔ 1.2e8 gap. Worth flagging that
this gap is only ~5×, narrower than Konjugieren's, so the honest instruction in the code is
to re-measure rather than nudge the constant if the "still changing" warning starts
appearing. An instrumented run proved the mechanism rather than just its silence: tap
Settings on iPad → sample 1 = 1.53e10 (mid-fade, correctly rejected), sample 2 = 2.36e7
(settled), 4.42 s total.

**`latest/` accumulated across releases.** The playbook built it with `mkdir -p` and no
clearing, so a re-shoot left the previous release's files beside the new ones (Konjugieren's
went 36 → 72), and the numbered-bundle snippet that follows maps `latest/*.png` to slot
numbers — two candidates per slot, winner decided by glob order. It resolves correctly only
while timestamps happen to sort in release order. Added the `rm -rf`, and said in prose that
`latest/` is a per-release *projection*, not an archive; the timestamped originals stay put.

**Fixture answers are now lowercased on the way out of Swift.** `exportFixtureAnswers`
wrote `Conjugator.conjugatedString(...)` verbatim, which is mixed-case by design —
uppercase marks irregular characters for red highlighting. Those capitals are correct
*output*, not a defect, and nothing in the conjugator changed. The problem is narrower and
purely about the screenshot: the answer field depicts what a *user* typed, and no human
types `aI faIT`. Checked the two things worth checking before a blanket `.lowercased()`.
First, grading: `ConjugationResult.score` lowercases both sides and the app compares
against its own in-memory value, never this file — so scoring is unaffected, and the
re-shot results screens still read 30/30. Second, whether any of the 30 answers is
legitimately capitalized — dumped the fixture and none is. Done in Swift rather than the
driver on purpose: shell `tr '[:upper:]' '[:lower:]'` works on bytes and silently skips
every accented capital, which in French is most of them.

### The seventh fix, which the verification sweep handed over

Mid-verification Josh mentioned a concurrent session in `../Conjugar.mig` was also driving
simulators. That turned into a diagnosis rather than a nuisance. The full sweep had logged
exactly one complaint — `soft keyboard still not visible after Cmd+K`, on both iPhone
`quiz_mid` cells — and `ensure_soft_keyboard` raises `first window whose title contains
"iPhone"`, a *family* substring. The other session had `iPhone 17` booted alongside this
sweep's `iPhone 17 Pro Max`, and System Events enumerated the foreign window first, so
Cmd+K went to the wrong simulator. Confirmed directly rather than by inference: `contains
"iPhone"` returns `iPhone 17 – iOS 26.3`, `contains "iPhone 17 Pro Max"` returns the right
one. Simulator titles its windows `<device name> – iOS <version>`, so matching on the full
`$DEVICE` removes the whole ambiguity class; the old comment had even predicted this
failure and left it unfixed. iPad escaped only because its family match happened to hit the
right window first. This is the same shape as the ported six — a silent degrade that still
reports success — which is why it was worth fixing rather than just noting.

The two iPhone `quiz_mid` cells from this sweep are therefore keyboard-less and want a
re-shoot on an uncontested simulator. The re-shoot attempt failed on its own evidence of
interference: `wait_for_render` timed out because a system modal, **`Open in "Conjugar"?`**,
was sitting on top of my app on that same simulator. Left it alone rather than tapping
Cancel — that dialog belongs to another session's run.

**Verification.** All 36 cells captured, exit 0, and **zero** `wait_for_stable_screen`
warnings across the sweep. Reviewed all 36 as four contact sheets; every cell shows the
right screen in the right appearance and the right language, with no ghosting, and every
iPad tab highlight confirms the new per-language coordinates land correctly. One
false alarm worth recording so the next reader doesn't repeat it: iPad `info_view` looked
*light* to me in a 320px-wide montage cell and is specced dark — `magick -format
'%[fx:mean]'` says 0.0695, i.e. plainly dark, and the full-size file confirms it. Don't
grade appearance from a thumbnail. `verify_store_media.sh` reports 0 blocking / 0 advisory
on all 36. Full test suite: 219 tests in 19 suites pass. Kill switches restored and
`git diff --stat` on `ConjuguerTips.swift` is empty.

**Not done, deliberately.** This is not the extraction. Josh plans to factor screenshot
generation out of Konjugieren, Conjuguer, and Conjugar so the three stop drifting; a
half-extraction done while applying these would make that harder. Also left alone: the
iPad status bar in this sweep carries a French date (`Dimanche 26 juillet`) even in the
English cells, because `status_bar override` cannot set the date's language — that is the
already-documented workaround #14 (a per-language system-language change plus reboot), an
operator step for a real release shoot, and this was a verification sweep.

## Two fixes back from Conjugar's port session (2026-07-26)

Conjugar spent a session porting this repo's and Konjugieren's screenshot fixes forward. It
found two things worth sending back.

**The stored bundles were still RGBA — `version_3` and `version_4`, 40 of 40 each.** The
flattening added to `take_screenshot` on 2026-07-25 only affects captures taken *after* it,
and this repo has not re-shot since. `version_4` is the bundle App Store Connect actually
rejected for alpha; whatever flattened copies were uploaded live outside the repo, so the
files on disk were the rejected originals with nothing marking them as such. Konjugieren had
the same situation and handled it deliberately, leaving `version_2` as-is with a "flatten
then" note in its journal; here there was no note at all, so the next person reusing
`docs/screenshots/version_4` would have walked straight back into the rejection.

Both bundles are now flattened in place. The check that made this safe rather than
destructive: every file was confirmed fully opaque first (`%[opaque]` true and minimum alpha
1 at every pixel), and each flatten was verified to leave the colour data untouched —
`magick compare -metric AE -alpha off original flattened` returns 0 for all 80 files — before
the result replaced the original. The archived artifacts still depict exactly what shipped;
only the empty channel is gone. Both now pass `verify_store_media.sh` clean.

**The Cmd+K keystroke is now gated on Simulator being frontmost.** Workaround #10 was fixed
on 2026-07-26 by matching the full device name so AXRaise picks the right *window*. The gap
that remained is one level up: if Simulator is not the frontmost *application* at all, the
keystroke goes to a different program entirely. Retrying cannot catch it, because
`keystroke` succeeds — it lands wherever focus happens to be, `osascript` returns 0, and
workaround #6's post-toggle check reports only that the keyboard is missing, never that the
keystroke went somewhere else.

This is not theoretical. During Conjugar's measurement session a stray Cmd+K launched the
**Fitness** app on Josh's Mac; he noticed and asked why, which is the only reason it was
caught at all. In a real sweep the same misfire costs two keyboard-less `quiz_mid` cells and
says nothing about the cause. The guard reads `name of first process whose frontmost is true`
after the AXRaise and, on anything but Simulator, logs the offending app's name instead of
firing blind.

Not ported here: Conjugar measured its own `STABLE_PIXEL_TOLERANCE` at 7.5e7 over 112
quiz-screen samples and found a benign-motion outlier at 4.6e7 — well above the 2.5e7 max
this repo recorded over 18 samples. If that distribution is representative, this repo's floor
is understated and 5e7 has less headroom than its comment claims. Worth a longer sampling run
before the next sweep; not changed here on another app's evidence.

## The Cmd+K guard becomes a retry loop (2026-07-26)

A third round-trip with the Conjugar session, and this one flows the other way: the frontmost
guard this repo contributed came back improved.

Recap of the guard, added earlier today: `ensure_soft_keyboard` raises the target Simulator
window and then, before typing, asks System Events which application is actually frontmost —
because when AXRaise silently fails to take focus, `keystroke` still *succeeds* and lands
wherever focus happens to be. Conjugar hit that live, sending a stray Cmd+K into the Fitness
app while the sweep reported nothing wrong.

What that version got wrong was the *shape*, not the check. It did one raise, one frontmost
check, and gave up if the check failed. But the failure it guards against is not always
permanent: Simulator may still be coming forward, or another app may be frontmost for a
moment. Treating a momentary steal as fatal turns it into a keyboard-less `quiz_mid` cell when
waiting a second would have fixed it. Konjugieren had already folded the identical check into
a 3× retry loop, which handles both shapes of the problem, and that is now what all three apps
run.

The subtlety worth writing down is why the loop is not just "retry the thing that failed."
Retrying a *bare* keystroke is useless — it misfires three times instead of once, because
`osascript` returns 0 each time. The loop is correct only because the frontmost check lives
inside it, so every attempt re-raises, re-checks, and types only on success. A persistent
steal therefore ends with three log lines naming the offending app and **zero** keystrokes
sent.

Verified with a stubbed harness (fake `osascript` returning a scripted sequence of frontmost
answers, counting attempts and keystrokes), in this repo and in Conjugar, with identical
results: clean 1/1, persistent steal 3 attempts and 0 keystrokes, transient steal recovering
on attempt 2 with 1 keystroke.

One intentional divergence survives, and it should: this repo matches its Simulator window on
the whole `$DEVICE` string, while Conjugar and Konjugieren use a device-family substring. That
is the fix from earlier today for the "iPhone" prefix selecting the wrong window here, and it
is documented in workaround #10 in all three playbooks so nobody "harmonizes" it away. Only
`scripts/take_screenshots.sh` and `docs/screenshot-playbook.md` changed; no app code, and the
script passes `bash -n`.

## Ported from Conjugar: the status-bar prep script, and a guard for windowless simulators (2026-07-26)

Conjugar shot its `version_2` App Store bundle today and lost one cell to a failure worth
importing the defenses for. Its iPad came back from a per-language reboot **booted but with
no Simulator window**, so `ensure_soft_keyboard`'s `AXRaise of (first window whose title
contains …)` had nothing to raise, failed three times with `-1719 "Invalid index"`, and the
`quiz_mid` cell captured without a keyboard. The driver's own warning named two causes —
missing accessibility permission, Simulator never frontmost — and both were false.

Conjuguer is squarely exposed to this. It has the same `ensure_soft_keyboard`, the same
`quiz_mid` cell, and — the part that makes it likely rather than theoretical — a playbook
that prescribes exactly the set-language → `simctl shutdown` → `simctl boot` sequence that
produces the windowless state, as hand-typed commands.

Two things landed. First, `scripts/prep_screenshot_sim.sh`, which did not exist here: it does
the *Clean Status Bar* steps in the order that matters (set system language → reboot →
**re-apply** the override → verify) and prints proof that each landed. That ordering is the
whole reason the script exists — `status_bar override` survives install/launch but is cleared
by every reboot, while a language change requires one, so an override set first is silently
wiped and that language ships with a live wall clock. It also checks the rebooted device has
a Simulator window and, if not, quits and relaunches Simulator.app, which is the only thing
that reattaches one (`open -a Simulator --args -CurrentDeviceUDID` is ignored when Simulator
is already running, and File ▸ Open Simulator clicks without effect).

Second, a window check in `ensure_soft_keyboard` itself, inside the existing 3× loop, right
before the AXRaise. Detection belongs in the driver even though recovery belongs in prep,
because the driver is what needs the window and what was reporting the wrong cause. Its
position inside the loop matters for the same reason the frontmost guard's does: the window
list is briefly unenumerable just after Simulator activates, so a transient recovers on the
next attempt while a real windowless device burns all three and sends zero keystrokes. The
driver does not attempt recovery — quitting Simulator mid-sweep is too blunt.

One deliberate difference preserved: this repo matches the Simulator window on the full
`$DEVICE` string rather than a family substring, dating from the day a stray `iPhone 17`
stole this sweep's Cmd+K. The prep script matches the same way, and the executable body of
`ensure_soft_keyboard` still differs from Conjugar's and Konjugieren's only in that one line.

Also imported: a correction to this playbook's claim that the language dance is iPad-only.
The *date* is, but the pinned clock is locale-formatted — `en_US` renders `9:41` and `fr_FR`
renders `09:41` from the identical `--time "9:41"` — so treating only the iPad makes the two
devices disagree inside the same language.

Verified with a stubbed-`osascript` harness: window present → 1 raise, 1 keystroke; missing →
3 attempts, 0 keystrokes, three accurate log lines; missing-then-present → recovery on
attempt 2. Identical output across all three repos, both scripts pass `bash -n`, and no app
code was touched. Not verified anywhere: the *recovery* branch, because the windowless state
proved intermittent and would not reproduce on demand after the fact.

## Reviewing the ported video script (2026-07-26)

Josh rewrote `docs/video_script.md` from Konjugieren's version and asked for an error check.
Most of the port was faithful and the app-facing claims all hold up against the source of
truth: 6,320 verbs in `verbs.xml`, `abaisser` first and `zyeuter` last, seventeen tenses in
`Tense.swift` (eight simple plus nine compound), `avoir` a real model (`id="4-10"`) among 95,
"Show Compound Tenses" byte-identical to `VerbView.showCompoundTenses`, "Indicatif Présent"
byte-identical to `Info.indicatifPrésentHeading` (the *French* catalog value lowercases the
`p`, which matters only for the French clips), and "timed" honest because `Quiz` runs an
`elapsedTime` counter that feeds `bonusForElapsedTime`.

The real defect was arithmetic. The header asserted 34 seconds of raw footage minus
half-second transitions landing at 30. Five clips means four transitions, and an FCP
transition overlaps its own duration of media, so four half-second transitions cost two
seconds, not four. The stated numbers only cohere with one-*second* transitions — FCP's
default. The version Josh replaced had said 32/0.5/2 correctly *and* carried the note that
the library must be switched to 0.5 s in Settings ▸ Editing; dropping that note is what let
the mismatch look plausible. Restored both. Josh chose 32.

Second regression: the port dropped every per-clip duration and every French label. The
durations matter because without them there is no way to hit any stated total; the old
6/6/6/7/7 sums to exactly 32, so they went back verbatim. The French labels matter because
`app-store-preview-videos.md` says the deliverable is four videos — English and French, iPhone
and iPad — so half the deliverables had no script. Retranslated, reusing the prior French for
clips 1, 2, and 4 and writing new lines for the two labels Josh had rewritten. Clip 3's first
pass rendered "every conjugation model of every French verb" literally, which is redundant in
French; Josh took the alternative built on the verified count instead, so both languages now
name the number — `All 95 French conjugation models.` / `Les 95 modèles de conjugaison du
français.`

On duration policy: Josh wants 30 s and the evidence backs him. The 2.0 rejection was almost
certainly `setsar=1`, not length — Konjugieren shipped a **30.015 s** preview that App Store
Connect accepted. The one caveat worth recording is that `-frames:v 900` alone does not
guarantee a ≤30 s file: it bounds the video stream only, `-shortest` does not retroactively
trim audio against it, and AAC's 1024-sample frames (~21.3 ms) can push the container past
30.000 — which is exactly how the earlier 30.014 s file happened. A hard `-t 30` alongside it
fixes that. Moot for this file in the end: Josh deleted the whole spec section, so the encode
guidance now lives only in `app-store-preview-videos.md`, and the two docs no longer
contradict each other on frame count. Josh then asked for that file to be updated, so 30 s is
now the standard everywhere — see below.

Small fixes: `QuizVew` → `QuizView` (a typo inherited from Konjugieren), the clip-4 label's
hyphen back to the colon the source used, an `#` on the title so it outranks the `##` below
it, and a trailing newline.

## Retargeting the preview pipeline to 30 seconds (2026-07-26)

Josh's position throughout was that 30 s is fine, and the evidence agrees with him more than
the docs did. `app-store-preview-videos.md` had retreated to 29 s after a 30.000 s master
re-encoded to 30.014 s — but that retreat treated the symptom. The 2.0 rejection was almost
certainly `setsar=1`, and Konjugieren shipped a **30.015 s** preview that App Store Connect
accepted, so the cap is demonstrably not enforced to the millisecond. Backing off a full
second bought margin against a bug rather than fixing it.

The bug is worth writing down precisely, because `-frames:v` looks like it should be
sufficient and isn't. It bounds the *video* stream only. `-shortest` does not retroactively
trim audio against it. AAC codes 1024 samples per frame — about 21.3 ms at 48 kHz — so the
audio track runs on to the next whole frame past the last video frame, and the **container**
duration, which is what `ffprobe` and App Store Connect actually read, lands over. 30.014 and
Konjugieren's 30.015 are both that same ~14 ms tail. `-t 30` truncates every output stream and
removes it. So the pass is now `-frames:v 900 -t 30`, with a `format=duration` check (not a
video-stream check) as the verification step.

`verify_store_media.sh` had to move with the doc, and this was the part that would have bitten
silently: its advisory branch warned whenever duration fell in `(29.5, 30.0]` with the message
"aim for 29s". Under the new target that fires on *every* conformant file, which is how a
verifier trains people to ignore it. Deleted the branch rather than retuning it — >30.0 already
fails, 30.000 is now deliberate, and there is no remaining band that means anything. The
blocking message now names `-frames:v 900 -t 30` and says why `-frames:v` alone is not enough,
so a future reader hitting a 30.014 s file gets the mechanism at the point of failure instead
of having to find it in the doc.

Left the historical caveat at `app-store-preview-videos.md:182` intact — the accepted upload
really did change two variables at once, and that remains true and worth not over-trusting.
Added a pointer under it recording that the 30 s target is deliberate as of today. Also left
the older blog entries' 29 s guidance alone: they are dated memory of what was believed then,
and rewriting them would destroy the only record of why the number moved.

## video_script.md gains the simctl recording commands (2026-07-30)

Josh asked which simulator to record the app-preview clips on, and the answer already
existed — `app-store-preview-videos.md` § "Simulators to record from" names
`iPhone 17 Pro Max` (1320 × 2868) and `iPad Pro 13-inch (M5)` (2064 × 2752). Both are
installed on the iOS 26.3 runtime, so there was nothing to download. But the answer lived
one document away from `video_script.md`, which is the file actually open while recording,
so the follow-up was to put the invocations in the script itself — and in the sibling
scripts in Konjugieren and Conjugar, neither of which has an `app-store-preview-videos.md`
at all. For those two the script is now the *only* place the recording procedure exists.

The one design decision worth recording: **resolve UDIDs by name at run time, don't paste
them.** Konjugieren's `take_screenshots.sh` hardcodes `E73F9CB3-…` under the label
`iPad Pro 13-inch (M4)`, and that UDID today belongs to a device *renamed*
`Konjugieren iPad Screenshots`. The map still works, but its label is now a lie, which is
exactly the failure a doc full of pasted UDIDs invites. The resolver added to all three
scripts is:

```bash
udid() { xcrun simctl list devices available | sed -n "s/^ *$1 (\([0-9A-F-]\{36\}\)) .*/\1/p" | head -1; }
```

Verified before shipping it, including the prefix hazard — `iPhone 17` is a prefix of
`iPhone 17 Pro Max`, and because the pattern requires the name to be followed by ` (` it
returns the plain 17, not the Pro Max. The parentheses in `iPad Pro 13-inch (M5)` are
literal in a BRE, so no escaping was needed there either.

Two capture flags that are not the defaults and matter: `--codec h264` (simctl defaults to
HEVC; H.264 masters drop into Final Cut without transcoding) and `--mask black` (otherwise
the unmasked framebuffer is written, corners and all — and Apple rejects alpha, the flaw
that sank the `version_4` screenshots). Also documented that `recordVideo` captures at
native pixel resolution regardless of how small the Simulator window is drawn, that Ctrl-C
is the only correct way to stop it (SIGINT is what finalizes the file), and that captures
are variable-frame-rate up to 60 — the 30 fps cap is an export concern, not a capture one.

Each script now ends its recording section with an `ffprobe` check for `1320,2868,1:1`,
because dimensions are the one defect the export can't repair, and wrong dimensions are
what got all four 2.0 previews rejected in the first place.

Konjugieren needed one deviation: its fifth clip carries a standing note that a simulator
bug forces real hardware, so `simctl` doesn't apply there. That section now says so
explicitly and points at QuickTime movie recording, with the caveat that a physical device
records at its own native size (changing the Spatial Conform the clip needs) and shows a
live clock instead of the pinned 9:41.

**Follow-up the same day: rewritten around hand recording.** Josh doesn't want to drive
the recording from the shell — he launches the simulator and records by hand — and asked
the question the whole section should have answered first: does the invocation affect App
Store Connect at all, or is conformance purely a post-processing concern?

Purely post. Worth stating plainly because it collapses a lot of anxiety: only two
capture-time facts matter, and neither is a flag. *Which device* you record fixes the
native pixel size and therefore the aspect and the Spatial Conform; and the capture has to
be the device framebuffer rather than the Mac screen. Everything ASC enforces — 886 × 1920,
SAR 1:1, H.264 High ≤ L4.0, ≤ 30 fps, 15–30 s, an AAC track — is imposed by Final Cut and
the ffmpeg normalize, and the master violates nearly all of it by construction (Simulator
writes HEVC, variable frame rate up to 60, at native size). So `simctl io recordVideo` and
File ▸ Record Screen produce equally acceptable masters; the choice is convenience.

So the sections in all three scripts were rewritten: `open -a Simulator` (or `simctl boot`
plus `open`), Run from Xcode to install, `prep_screenshot_sim.sh` for language + 9:41, then
**Simulator ▸ File ▸ Record Screen** / **Stop Recording**. Verified those menu items still
exist in Xcode 26.3 by pulling the strings out of `Simulator.app/Contents/Resources/
Base.lproj/MainMenu.nib` — "Record Screen" and "Stop Recording" are both there, and
`Localizable.strings` confirms the output is named `Simulator Screen Recording %@`. The
`simctl` route survives as one sentence, framed as scriptable-but-equivalent.

One hazard the hand path introduces that the scripted one didn't have: **macOS screen
recording is the trap.** ⌘⇧5 or QuickTime ▸ New Screen Recording aimed at the Simulator
*window* captures at point size × display scale with window chrome baked in — on the order
of 860 × 1864 instead of 1320 × 2868 — and no conform fixes that without upscaling.
Simulator's own Record Screen is framebuffer-based and immune. That is the one way "record
it by hand" produces a rejectable file.

I had also written up a second hazard — that a silent capture carries no audio stream and
`verify_store_media.sh` grades a missing AAC track as blocking — and Josh cut it: the
previews always carry a music track and he always exports video and audio. The check is
real, the scenario isn't, so the paragraph came back out of all three scripts. Worth
remembering as a pattern: a verifier's failure modes are not automatically warnings worth
printing, and guessing at someone's editing habits is how a playbook accumulates noise.

**Correction, from Josh's actual captures.** He recorded the five English iPhone clips with
Simulator's built-in Record Screen and left them in `~/Desktop/Clips/English/iPhone/`.
Probing them settled a claim I had asserted in all three scripts without checking: the
recordings are **H.264 High, Level 5.0**, not HEVC. The HEVC default I cited is
`simctl io recordVideo`'s, documented in its `--help`; Simulator's GUI recorder evidently
differs, which is why `--codec h264` matters on the `simctl` path and is moot on the menu
path. All three docs corrected.

The rest of the probe is a clean confirmation of the playbook: 1320 × 2868, SAR 1:1,
yuv420p, no audio track, durations 11.8–38.9 s against 6/6/6/7/7 s targets. Right device,
right size, generous trim slack.

Frame pacing was the one thing that looked alarming and wasn't. Average frame rates ran
9.8–52.5 fps, and clip 2 has a **7.3-second stretch with zero frames**. That is variable-
rate capture working as designed — frames are written when pixels change — and Josh
confirmed the scrolls varied in speed. Final Cut conforms it to 30 fps and holds the
stills. Worth writing down because "avg_frame_rate = 9.8" on a 20-second clip reads like a
broken capture and isn't; the diagnostic that actually answers the question is the
per-second frame histogram, not the average.

A frame-by-frame content check (four stills per clip, tiled into one contact sheet) matched
the script: frequency-sorted browse, être with compound tenses through etymology, model
browse → avoir (4-10), quiz with typed answers, Info → Indicatif Présent. Status bar pinned
at 9:41 in every clip. One editorial flag raised for Josh: near the top of InfoBrowseView,
where clip 5 begins, the Conjugation Tutor row reads "Apple Intelligence is still getting
ready. Please try again later." — a true state of that simulator, and not something to show
in a store preview.

**Two switches flipped for a re-shoot, and a stale status corrected.** Clip 5 needed the
tutor-unavailability row gone, and the mechanism already existed — no new code, just
`TutorDisplay.tutorUnavailableRowEnabled = false` (plus `TipDisplay.tipsEnabled = false`,
which the playbook always pairs with it, since a TipKit card popping into a browse clip
would be worse than the tutor row). Verified in the built UI that CONCEPTS drops to its
four concept rows with no ghost row or separator gap — the specific failure the kill-switch
plan predicted for the iPhone `List` path. Both must go back to `true` after recording.

While there: `prompts/tutor-row-killswitch.md` still read "Status: proposed, not
implemented" — and `git log` shows why. Commit `05e8da6` (2026-07-18) *added that file and
implemented the switch in the same commit*, so the status line was stale the moment it
landed. A plan document that ships alongside its own implementation will always say
"proposed" unless someone edits it in that commit, which is an easy thing to miss and a
mildly dangerous one: the next reader either re-implements a shipped feature or, as nearly
happened here, distrusts the mechanism and works around it. The file now states the
implementing commit, marks itself as design rationale rather than a work order, and points
at `docs/screenshot-playbook.md` for the operating instructions. Checked the one claim
that could have been wishful — step 5's re-shoot — against `version_4/iPad_English/6.png`:
CONCEPTS renders four cells, no tutor row.

## Browse rows, unified — and the chevron that wouldn't leave (2026-08-01)

Four small asks against `VerbBrowseView` and `ModelBrowseView`, from
`prompts/verb_browse_updates.md`, plus a fifth that arrived mid-flight.

**The sort picker moved to the bottom on iPhone**, mirroring Conjugar (Josh's Spanish
sibling app), where the Frequency/Alphabetical control sits just above the tab bar — a
thumb's reach from where the hand already is, instead of a screen away at the top. The
implementation is a plain `if horizontalSizeClass == .regular` fork inside the `VStack`:
the picker is bound once into a local `let` and placed either above the tip or after the
collection, so there's no duplicated `Picker` body. iPad keeps it at the top, where it
reads as a filter over the adaptive grid; on a large canvas, banishing it to the bottom
edge puts it nowhere near the content it governs. `ModelBrowseView`'s picker was initially
left at the top, because the prompt named only `VerbBrowseView`; that made the two browse
screens inconsistent, so it was flagged rather than changed unilaterally, and Josh asked
for it to move too. Same treatment, same size-class fork — the Irregularity /
Alphabetical / Identifier control now sits above the tab bar on iPhone.

**The chevrons were the interesting part.** `List` adds a disclosure indicator to any row
containing a `NavigationLink`, and no modifier turns it off; the folklore fix is a `ZStack`
with an opacity-0 link behind the row, which works but leaves the row's real content
outside the tappable/announced element. The deterministic fix was to stop using
`NavigationLink` in these two screens entirely: rows are `Button`s that set a
`@State selectedVerb` / `selectedModel`, and the push happens through
`.navigationDestination(item:)` (iOS 17+). Both the compact `List` and the regular-width
`LazyVGrid` use the same mechanism now, so `navigationDestination(for:)` is gone from both
files. VoiceOver reads the row and announces "Button"; the chevron is gone.

That change surfaced a latent accessibility bug. With the identifier on the row *inside*
the button's label, SwiftUI merges the two elements and **concatenates their identifiers** —
`describe_ui` showed `verb_row_avoir-verb_row_avoir`, which means `tap_id.sh verb_row_avoir`
had never worked, chevrons or not. Moving `.accessibilityIdentifier` onto the `Button`
itself (via a small `rowIdentifier(_:)` helper, since it's applied in both the list and grid
branches) produced clean ids, verified by tapping through to `VerbView` and `ModelView`.
CLAUDE.md's identifier table gained the row ids and the gotcha.

**The shared row** is `BrowseRow` (`title`, optional `subtitle`, optional `Badge` of text +
tint + optional a11y label). The old `IrregularityBadge` in `ModelView.swift` was its only
badge implementation and is now dead code, deleted; `irregularityBadgeFont` became
`browseBadgeFont`, since verb ranks wear it too. The verb rank picked up that same pill
treatment — Conjuguer blue on a 15%-opacity capsule, vertically centered (the old row used
`HStack(alignment: .firstTextBaseline)`, which pinned "#1" to the infinitif's baseline and
left it hanging above the two-line row's center). A nil accessibility label means the badge
is hidden from VoiceOver, which is what the rank wants (it's already in the row's visual
order and adds nothing spoken); the irregularity badge keeps "73% Irregular".

**Then: a count header, "6,320 VERBS".** Both sibling apps show one, and the number has to
be locale-formatted — French groups with a narrow no-break space, not a comma. First
attempt used a String Catalog plural variation selecting on a second `%lld` argument while
rendering `%2$@` (the formatted string). The build refused it outright: *"Plural variation
requires referencing the number in the string… use separate top-level strings for one and
greater than one."* Which is the answer — `verbCountSingular` / `verbCountPlural`, with the
`count == 1` test in `L.swift`. That test is correct for both shipped languages (French
would need `count <= 1` if zero were reachable, since French treats 0 as singular, but the
header is hidden when the search finds nothing). Verified in the simulator: `6,320 VERBS`
in English, `6 320 verbes` in French (narrow space confirmed via `describe_ui`), and
`1 verb` after narrowing the search to `rabaisser`.

**The count header was in the wrong container.** Sitting in the screen's `VStack`, above
the `List`, it was outside the scroll view — so a rubber-band drag at the top of the list,
which expands `.searchable`'s field downward, drew the search field straight through
"6,320 VERBS". Fixed by moving it *into* the scrolling content: the first row of the
`List` (`listRowSeparator(.hidden)`, matching row background) in compact width, and the
first child of the `ScrollView` above the `LazyVGrid` in regular width. A pinned `Section`
header would have been the wrong fix — it would stop overlapping the search bar, but it
still wouldn't move with the verbs, which is what Josh asked for. Verified by dragging the
list: the count scrolls out of view along with the first rows.

Not verified: the iPad grid path. No iPadOS 26 runtime is installed — the available iPad
simulators are iOS 17 and the install fails on `MinimumOSVersion`. The regular-width change
is mechanical (`NavigationLink` → `Button` with the same label), but it is unexercised.
219 tests pass; SwiftLint `--strict` is clean on every touched file.

## réaliser etymology: loosen the opening comparison (2026-08-01)

The `réaliser` gloss opened "Unlike the other verbs here, …", which asserted more than it
could support: the etymology corpus now covers hundreds of verbs, several of which are
also post-Latin French formations rather than direct inheritances, so "the other verbs
here" was quietly false. Softened to "Unlike many commonly used verbs," in `en` and
"À la différence de nombreux verbes courants," in `fr` — same rhetorical setup for the
"not inherited, but built from ~réel~ + ~-iser~" point, without the universal claim.

Edited `Conjuguer/Models/Etymologies.json` via Python (raw-text replace with a
`count == 1` assertion per language, then `json.load` to validate) rather than the Edit
tool. The Etymologies corpus is plain JSON, not a String Catalog, but it carries the same
hazard: the prose is full of curly quotes and guillemets that are fine, while any ASCII
`"` touched through a rendered-text editor would land unescaped.

Noticed in passing: the working tree also showed `Localizable.xcstrings` losing an empty
`"%@%%"` entry — not from this change, and consistent with the documented Xcode-IDE
re-serialization. Left alone rather than reverted, per the catalog guidance.

## iPad grid path verified at last — iPadOS 26.3 is installed now (2026-08-01)

The previous entry closed with "the iPad grid path is unverified: no iPadOS 26 runtime is
installed, the available iPad simulators are iOS 17, and the install fails on
`MinimumOSVersion`." That is no longer true — iOS 26.3 (23D8133) is present with eight iPad
devices, so the regular-width path finally got exercised on iPad Pro 13-inch (M5).

Everything the last change touched holds up on iPad. The three-column `LazyVGrid` renders,
`verb_browse_count` reads "6,320 VERBS" above it, and 72 `verb_row_<infinitif>` buttons carry
clean single identifiers — no `verb_row_x-verb_row_x` concatenation, so the "put the id on the
`Button`, not the label" rule survives the grid path too. The scroll question the iPhone work
raised answers correctly here: after a swipe, `verb_browse_count` moves from y=201 to y=-738.5
while `verb_browse_sort` stays pinned at y=154. The count scrolls with the verbs; the sort
control is chrome. Tapping a grid cell pushes `VerbView`, confirming the `NavigationLink` →
`Button` conversion works in regular width.

Two traps worth recording, both costing a cycle:

**The skill's verify-half scripts cannot address a simulator whose name contains parentheses.**
`launch_app.sh` and `_resolve_udid.sh` interpolate `TARGET_SIM` straight into an ERE —
`grep -E "^[[:space:]]+${TARGET_SIM} \("` — so "iPad Pro 13-inch (M5)" is parsed with `(M5)` as
a capture group and matches nothing; the script reports "simulator not found" for a device that
plainly exists. `build_app.sh` is unaffected because `xcodebuild -destination name=` compares
literally, which makes the failure mode confusing: the build succeeds against the very device
the launcher then claims is missing. Every iPad and every recent iPhone Pro has parens in its
name, so this blocks the whole verify half on those devices. Worked around for the verification
itself by driving `simctl`/`axe` directly against the UDID, then fixed upstream the same day
(see the next entry).

**`axe describe-ui` fails for the first ~10–25 s after a simulator boots, and says something
untrue about why.** It exits 1 with "No translation object returned for simulator. This means
you have likely specified a point onscreen that is invalid or invisible due to a fullscreen
dialog" — no dialog anywhere, and no point had been specified. `axe screenshot` keeps working
throughout, which is what makes it feel like a UI problem: screenshots go through the device,
the accessibility bridge is a separate channel that simply is not up yet.

The first diagnosis here was wrong and is worth recording as such, because it was wrong in a
seductive way. Running an AppleScript `AXRaise` on the device's window appeared to fix it
instantly, so the entry originally claimed describe-ui needs the target window raised rather
than merely present, and filed it as a sibling of the windowless-simulator trap in
`prep_screenshot_sim.sh`. That survived one confirming observation and no disconfirming ones.
Testing it properly the next hour killed it: describe-ui works fine with the window backgrounded,
with it hidden, and with it minimized. What the AXRaise detour actually bought was *time* — two
tool round-trips, several seconds — during which the bridge finished coming up. A post-hoc
`simctl shutdown && boot` plus a poll loop showed 19 consecutive rejections before the first
success, which is the real shape of it.

The cost was never the wait. Every call site in the skill discarded stderr and captured stdout,
so a bridge that was merely not ready yet arrived downstream as an *empty AXTree* — which the
skill's own docs teach agents to read as launch-time modal gating. The failure mode is an agent
hunting for a review prompt or permission alert that does not exist.

Bonus: the first on-screen row after scrolling happened to be `réaliser`, so the same pass
confirmed the reworded etymology renders — "Unlike many commonly used verbs, ~réaliser~ is not a
direct inheritance from Latin…" — with markup and the Flaubert *Madame Bovary* example intact.

## Fixing both simulator traps upstream in ios-build-verify 0.3.2 (2026-08-01)

Both traps from the iPad verification got fixed in `../ios-build-verify` rather than worked
around here. Josh released them as 0.3.2 and bumped the plugin version.

**Literal device-name matching** (`scripts/_sim_udid.sh`, new). One awk pass replaces the
`grep -E` interpolation, comparing the name as text and requiring the UDID column's leading
`" ("` so `iPhone 17` still refuses to resolve `iPhone 17 Pro`. `tail -1` keeps preferring the
newest runtime. Both resolution sites — `_resolve_udid.sh` (booted) and `launch_app.sh`
(available) — now share it instead of duplicating a subtle pattern.

**A retry-aware AXTree reader** (`scripts/_axe_tree.sh`, new). `axe_describe_ui` retries while
AXe reports the bridge unreachable and passes every other error straight through with its stderr
intact, so a genuinely-not-booted device still fails in about a second. All 15 raw
`axe describe-ui` calls across 12 scripts route through it; past that helper, an empty tree
really is an empty tree. `_resolve_udid.sh` sources it, so anything resolving a UDID gets it
for free.

Two things worth remembering from the fixing:

The first version of the wrapper returned success on *every* error path. The cause is a bash
subtlety worth internalizing: `$?` read after `fi` carries the status of the **if statement**
(0 when no branch ran), not of the condition. The status has to be captured inside an `else`.
The bug was invisible in the happy path and would have silently converted every hard failure
into "empty tree, exit 0" — strictly worse than the problem being fixed.

Verification did not actually require the version bump. The skill scripts read their config from
`$(pwd)/.claude/ios-build-verify.config.sh` and resolve their helpers from `BASH_SOURCE`, so
running the *source repo's* scripts with the cwd set to Conjuguer exercises the edits against
this app while bypassing the plugin cache entirely. That gave a real end-to-end pass — cold-boot
launch on the iPad, `describe_ui` in both forms, `verify_screen_loaded`, `verify_label_visible`,
`read_value` including its exit-4 classification, `tap_tab`, `tap_id`, `verify_segment --point`,
plus an iPhone 17 regression and a bogus-name exit 3 — before anything was released.

**Housekeeping found along the way:** `~/.claude/skills/ios-build-verify` was a symlink pinned to
the *0.3.1 cache directory*, which is why the skill list showed `ios-build-verify` twice. It
silently served pre-fix scripts (regex bug included) and a SKILL.md 2.4 KB short of current, and
being pinned to a version directory it could never pick up an update. Deleted; the plugin
install covers Conjuguer, Konjugieren, and Calculator3 at the current version. What saved this
project in practice is the `IBV_SCRIPTS` resolver in CLAUDE.md searching
`~/.claude/plugins/marketplaces` rather than `~/.claude` broadly — written to avoid picking an
arbitrary cached version, and it dodged this too.

## KillSwitches.swift gains an onboarding switch (2026-08-02)

The screenshot kill switches — `TipDisplay.tipsEnabled` and
`TutorDisplay.tutorUnavailableRowEnabled` — had been living at the top of
`Models/ConjuguerTips.swift`, which was where the first one (tips) naturally belonged and
where the second one accreted by proximity. They now live together in
`Utils/KillSwitches.swift`, matching Konjugieren's layout. Pure move; the enum names are
unchanged, so no call site moved with them. (The file needs no `import Foundation`: two
enums of `Bool` constants depend on nothing but the language.)

The gap that prompted the move: Konjugieren has a **third** switch, `OnboardingDisplay
.onboardingEnabled`, and Conjuguer did not. Conjuguer has the same first-launch
`fullScreenCover` in `ConjuguerApp`, gated only on `!Current.settings.hasSeenOnboarding`
— so on a freshly-installed simulator the welcome tour auto-presents over whatever screen
a screenshot sweep or App Store preview recording is trying to capture. The fix is the
same one-token change Konjugieren uses:

```swift
get: { OnboardingDisplay.onboardingEnabled && !Current.settings.hasSeenOnboarding },
```

Two properties of that placement are deliberate and worth not undoing later. Only the
*automatic* presentation consults the switch — the Settings "Show Onboarding" button
presents `OnboardingView(isReshow: true)` directly and ignores it, so the flow stays
manually reachable while the switch is off (an App Store reviewer can still find it).
And because the cover never presents when the switch is `false`, `hasSeenOnboarding` is
never written — the sweep doesn't quietly consume the user's first-launch state, so
flipping the switch back to `true` restores the real behavior on the same install.

`docs/video_script.md` already carried the pre-recording checklist line "ensure that
values in `KillSwitches.swift` are `false`", phrased generically over the file rather
than naming each switch — so it covers the new one without an edit. That phrasing was
luck rather than foresight, but it's the right shape and should stay generic.

Build passes. Not verified in the simulator: exercising it means flipping the switch,
rebuilding, and uninstalling the app to reset `hasSeenOnboarding`, and the logic is a
single boolean `&&` on a binding that already worked.

## docs/project-structure.md: porting Konjugieren's file index (2026-08-02)

Josh asked me to add `KillSwitches.swift` to "the index of files" and guessed it lived in
CLAUDE.md or something CLAUDE.md references. It doesn't — not in this repo. Konjugieren
has `docs/project-structure.md`, a 299-line annotated tree wired into its CLAUDE.md with a
"this doc is a cache, update it on add/remove/rename" rule. Conjuguer had no counterpart;
the only directory tree in the repo was a small one inside the screenshot playbook. Worth
recording because the misremembering is the interesting part: a doc's existence doesn't
announce itself across repos, and two sibling apps that share an author, a skill, and most
of an architecture will keep inviting exactly this confusion.

What the move *did* break, and what nobody would have noticed until it silently misfired:
`docs/screenshot-playbook.md` referenced `Conjuguer/Models/ConjuguerTips.swift` in eleven
places, including the copy-paste `sed` commands an operator runs before a sweep. The doc
itself warns two paragraphs above those commands that `sed` exits 0 when its pattern
matches nothing — so a stale *path* fails the same quiet way a renamed *switch* would, and
the sweep proceeds with tips and the tutor row still on. Repointed all eleven, added the
new onboarding switch to the table and to both `sed` blocks, and verified the commands
round-trip against the real file (flip all three to `false`, restore, `diff` clean).
Deliberately left stale: `prompts/tutor-row-killswitch.md` and the journal's own account of
where the switches used to live. Those are records of what was true then, not instructions.

Then ported the index. 166 Swift files, and the annotations are the expensive part — the
tree regenerates with one `find`, but "GameState+Henyard.swift — Mechanic 4, La
Basse-Cour" required opening the file. That asymmetry is the argument for the doc and also
the argument for keeping it honest: the descriptions are what a future session will believe
instead of reading. Two entries exist specifically to stop a wrong guess a filename invites
— `frequencies.xml` looks load-bearing and is bundled but never parsed, and
`VerbModelTests.swift` looks hand-written and is generated. Verified coverage
programmatically rather than by eye: extracted every `*.swift` token from the doc and
diffed it against `find` output, both directions empty.

One nuance worth carrying forward, now also written into CLAUDE.md: the two staleness modes
are not equally bad. A missing entry costs a session one `find` — it sees the gap and reads
the file. A wrong entry gets believed. So when the budget for maintenance is short, fix
renames and repurposed files first and let adds-and-deletes drift.

## scripts/check_docs.py: making the index-staleness rule enforceable (2026-08-02)

Ported the link-and-coverage subset of Konjugieren's `check_docs.py`, and backported to
Konjugieren's CLAUDE.md the one sentence Conjuguer's cache note had gained in the
meantime — that a missing index entry and a wrong one are not equally bad. The two repos'
notes now differ only in Conjuguer's pointer to this script.

Three checks, all chosen because they are true-or-false regardless of when the text was
written: relative Markdown links resolve; every source file appears in
`project-structure.md`; every file that doc names still exists. Konjugieren's version also
asserts corpus counts, commit hashes, and a licensing invariant. Those were deliberately
left out — not as a first increment, but because the count check there needs a hand-maintained
CACHE_FILES allowlist to avoid reporting `blog_notes.md` and `roadmap.md` as broken for
faithfully recording what was true in June. Conjuguer has the same hazard in `prompts/`,
whose archived session prompts describe the tree as it stood. A count check here would need
the same allowlist, so it should be added deliberately or not at all.

The first run failed three times, and all three were the checker's fault rather than the
docs'. The README opens with an image carrying a title attribute —
`![Conjuguer](Images/Splash.png "Conjuguer's Launch Screen")` — and a naive `[^)]+` target
swallows the quoted title. `code-review-suggestions-union.md` *describes* Markdown, so the
literal `[text](url)` appears inside backticks; stripping inline code spans before scanning
fixes that precisely. And `corpus/grokked/chanson.md` is Old French verse where a bracketed
gloss abutting a parenthesis is ordinary orthography: line 1811 reads `cur[uçus](ius)`,
which is link syntax by coincidence and unparseable-around in principle. `corpus/` is source
text rather than prose about the app, so it joined the skip list. Worth noting that all three
false positives came from *other* repos' Markdown conventions not being this repo's — the
kind of thing a port inherits silently.

Then negative-tested all three checks rather than trusting a green run, since a checker that
cannot fail is worse than none: dropped an unindexed `.swift` into `Shared/` (coverage
fired), added a phantom filename to the index (phantom check fired), added a dangling link
(link check fired), restored, and confirmed zero problems and no leftover probe file. The
green run at the top of this entry means something only because of that.

Josh asked, mid-task, about `../Conjugar.mig`: it has neither the index nor the cache note,
and its only directory tree is the one inside its screenshot playbook — the same state
Conjuguer was in this morning. He's handling that repo in a separate session. Recording the
audit here so that session doesn't have to redo it: Konjugieren has both, Conjuguer now has
both plus the enforcement script, Conjugar.mig has neither.

## IBV_SCRIPTS becomes the dev/prod switch for ios-build-verify (2026-08-02)

Carried over from a Conjugar session. Conjugar had been invoking `ios-build-verify` through a
hand-made `~/.claude/skills/ios-build-verify` symlink pointing into the *versioned* plugin
cache — pinning a release, needing re-pointing on every update, and by then silently gone,
which broke the build command its CLAUDE.md documented. Conjuguer was never exposed to that:
it already resolved `IBV_SCRIPTS` against the marketplace clone, and `take_screenshots.sh`
already carried the comment explaining why the search is scoped to `plugins/marketplaces`
rather than `~/.claude` broadly. That comment is the reason the Conjugar fix was a five-minute
job instead of a rediscovery, which is a decent argument for writing the rationale down next to
the code rather than only in a doc.

The gap that did apply here: the skill is developed locally at
`~/Desktop/workspace/ios-build-verify` but consumed from GitHub, so both the marketplace clone
and the cache hold published code, and testing an unpublished change meant publishing it first.
Since every call site already resolves a scripts directory instead of hardcoding one,
`IBV_SCRIPTS` *is* the dev/prod switch — export it at the dev repo, unset it to go back. That
needed only documentation (a blockquote under "Build and Test Commands") and one change to
`scripts/take_screenshots.sh`, which called `resolve_ibv_scripts` unconditionally and so
ignored an override.

The tempting way to write that override is `: "${IBV_SCRIPTS:=$(resolve_ibv_scripts)}"`, and it
is wrong under `set -euo pipefail`. The `:` builtin always succeeds, so the resolver's `exit 2`
— which runs in a command substitution and therefore leaves only the subshell — is swallowed,
and the sweep runs on with an *empty* `IBV_SCRIPTS`, invoking `/build_app.sh`. A probe in
Conjugar confirmed it: `SURVIVED with X=[]`, exit 0. The plain assignment it would have replaced
aborts correctly, since a failing substitution in an assignment does trip errexit. The guard is
therefore a boring `if [[ -z "${IBV_SCRIPTS:-}" ]]`, and both branches were exercised against
this repo's own resolver before the edit was trusted.

One machine-state note for future sessions: `ios-build-verify` is now installed at **user**
scope in addition to the per-project scope this repo, Konjugieren, and Calculator3 each had —
that is `claude plugin install`'s default, and it covers every iOS project from one record. The
now-redundant project-scope entries were left in place; consolidating them is a separate call.

Same-session follow-up: the consolidation happened after all. The three project-scope entries
are gone and `ios-build-verify` is installed at user scope only, which `~/.claude/settings.json`
enables globally. Two things worth knowing if this is ever redone. `claude plugin uninstall`
defaults to `--scope user`, so removing a *project* entry requires an explicit `-s project` —
the bare command would have removed the one record worth keeping. And the uninstall edits the
repo: it dropped `"ios-build-verify@ios-build-verify": true` from `enabledPlugins` in this
repo's checked-in `.claude/settings.json`, which is the change committed alongside this note.
The `extraKnownMarketplaces` block in that same file was left alone, correctly — it says where
the marketplace lives, not that the plugin is installed, so a fresh clone still knows where to
fetch the skill from.

## Recovering from a media-services reset, ported from Konjugieren (2026-08-02)

Josh hit a silent-audio bug in Konjugieren: no sound when starting a quiz or answering a question,
with audio feedback on, the phone unmuted, and sound apparently still working in that app's game.
Instrumenting `play` and running the build on the device caught the cause in one line, with the
session category reading `AVAudioSessionCategorySoloAmbient` and `AVAudioPlayer.play()` returning
`false`. `.soloAmbient` is the system default that no code in any of these three apps ever sets.
That pair is the signature of an `AVAudioSession` media-services reset: `mediaserverd` restarts,
the session reverts to defaults, and every existing `AVAudioPlayer` becomes an orphan that refuses
to play. Konjugieren's `docs/blog_notes.md` entry "The quiz went silent, and the audio session was
the reason" has the full trace.

Conjuguer had the same exposure, for the same reason: nothing here observed
`mediaServicesWereResetNotification` or `interruptionNotification`, `AudioSession.configure` set a
category but never activated the session, and `sounds` caches an `AVAudioPlayer` per effect for the
life of the process. One reset would have silenced this app until relaunch too.

The one thing worth recording, because it looks like a defense and is not: `warmUpSounds()` runs at
every game start from `GameState`, so it is tempting to assume the players get refreshed regularly.
They do not. It filters to names *absent* from `sounds`, so orphaned players are skipped rather than
replaced. Nothing short of a relaunch would have recovered.

The fix follows Apple's documented recovery. `AudioSession.configure` now activates the session as
well as setting the category, and is re-invokable, since that is what recovery needs.
`SoundPlayerReal.setup` registers for both notifications: a reset triggers `rebuildAudio` (drop
every player, reconfigure, warm up again, resume the music if it was meant to be playing), and an
interruption ending just reconfigures, which covers the far more common phone-call and Siri cases
where the players survive but the session does not.

The in-band retry needed a different shape here than in Konjugieren. That app checks
`player.play()`'s `Bool` inline; this one dispatches `play()` to `playbackQueue` to keep the
blocking audio-server round trip off the game loop, and was discarding the result. Since that `Bool`
is the *only* in-band signal a reset produces, it is now checked on the queue and a `false` hops
back to the main actor to rebuild. The rebuild is throttled to one per five seconds, because
without that a game frame playing a persistently failing sound would reallocate every player every
frame. `isMusicActive` is tracked explicitly rather than read back from `musicPlayer.isPlaying`,
since an orphaned player's reported state is not trustworthy.

Verifying a real reset is not possible: the simulator delegates audio to the host Mac and has no
`mediaserverd` to kill, and a device will not restart one. Konjugieren's port of this code was
verified by posting the notification synthetically and watching the rebuild run, the category
return to `Playback`, and playback resume. 219 tests in 19 suites pass here.

## Re-shooting screenshots 1 and 3 for the new browse views (2026-08-04)

`2bae3b6` ("Browse views: bottom sort picker, shared row, verb count, no chevrons") changed
VerbBrowseView and ModelBrowseView enough that the `version_4` iPhone screenshots were stale: they
still showed the sort picker above the rows, chevrons on every row, and no verb-count header. Only
the iPhone shots needed replacing, and only slots 1 and 3, so this was a two-view re-shoot rather
than a sweep.

Two things cost most of the session, and neither was the app.

**A booted simulator can render nothing while insisting it is fine — cause never established.**
Stated carefully, because the obvious story is not supported: Simulator.app being absent was the
most visible anomaly, but *launching it did not fix anything*, so "boot it headless and captures go
black" is a correlation this session did not earn. `scripts/take_screenshots.sh` calls
`xcrun simctl boot` and never checks whether Simulator.app is running. It was not. The device
booted headless, `bootstatus -b` returned success, `axe describe-ui` returned a complete home-screen
accessibility tree — and then `simctl launch` hung for 21 minutes and had to be killed. Every
framebuffer capture came back pure black (mean pixel 0) from both `axe screenshot` and `simctl io`
while the AX tree kept insisting the UI was fine. That split is the diagnostic worth remembering:
**a live AX tree proves the device is running, not that it is rendering**, and the driver's
`wait_for_render` polls the AX tree, so it cannot detect this state at all. Launching Simulator.app,
quitting and relaunching it, `simctl shutdown all`, and `launchctl remove
com.apple.CoreSimulator.CoreSimulatorService` all failed to clear it; a host reboot did. There was
also a `screencapture` permission dialog sitting on the host — worth dismissing before blaming the
graphics stack, since a modal there can stall host-side capture attempts indefinitely.

**`status_bar override --time` renders through the device's system locale.** The existing
`version_4` iPhone shots show `7:29`–`7:35`, so the four replacements had to blend in rather than
jump to Apple's `9:41`. Setting `--time "7:30"` produced `07:30` — a leading zero the neighbouring
eight shots do not have. The sim had drifted to `AppleLanguages = ("en-ES","es-ES")` /
`AppleLocale = en_001`, which is 24-hour; `simctl status_bar list` echoes the normalized `07:30`
either way, so the override string is not the tell. Setting `AppleLocale = en_US` + `AppleLanguages
= ("en")` and rebooting the device (which clears the override — re-apply after) got `7:30` with no
leading zero. The playbook already documents the language dance for the *iPad date*; it matters on
iPhone too, for the *clock format*, and that is a distinct reason from the one written down.

Two findings about the app itself, captured rather than fixed:

- ModelBrowseView has no count header. Only VerbBrowseView got one (`verb_browse_count`), which
  matches the commit message but reads as an inconsistency between two otherwise-parallel screens.
- The new iPhone `List` draws a **separator above the first row**, so `être` sits under a stray rule
  where the old layout had the sort picker. Confirmed by cropping old and new captures at the same
  offset: the old shot has no such line. Minor, but it is in the shipped screenshot now.

The `latest/` projection was deliberately left alone — it still holds the 2026-06-26 sweep, so it
was already out of step with the July bundle `version_4` was cut from, and refreshing four of its
files would have mixed three sweeps rather than two. `scripts/verify_store_media.sh
docs/screenshots/version_4` reports 40 images, 0 blocking, 0 advisory.

## A preflight the AX tree could never provide (2026-08-04)

Follow-up to the black-framebuffer incident above. The driver had no way to notice that state, and
that gap is the interesting part: `wait_for_render` polls the accessibility tree, the accessibility
tree was *perfectly healthy* the entire time, and the pixels were black. A sweep in that condition
runs to completion, reports success, and writes 36 black PNGs. The failure is silent by
construction, because the only channel that can observe it is the one the driver never consulted.

So the guard asserts on pixels. `assert_framebuffer_live` grabs a probe frame and requires
`magick`'s `%[mean]` above 1 — a threshold rather than `!= 0`, since a nearly-black frame is just as
dead, while a live dark-mode screen clears it on white status-bar text alone. It retries 10× at 3 s
because a just-booted device legitimately renders black for a moment, then exits 2.
`ensure_simulator_app` launches Simulator.app when absent.

The placement mattered more than the check. Both run from `ensure_booted`, but `ensure_booted` was
only reachable from the per-device loop, which runs *after* `build_app.sh` — so a dead simulator
would still have cost a ten-minute build before anyone found out. `main` now runs a preflight pass
over every target device before building, honoring `--device`. Verified by log ordering:
`preflight: iPhone 17 Pro Max` precedes `building once`.

The abort path could not be verified against the real fault, because the condition never reproduced
after the reboot. It was verified by substitution instead: pointed at a shut-down device it exits 2
with the diagnostic; against a live one it returns in about a second. That is weaker evidence than
catching the real thing, and worth saying plainly rather than letting the tests imply more than they
show.

Ported verbatim to Konjugieren (workaround #18) and Conjugar.mig (#26), whose `ensure_booted` was
byte-identical to this one. The wording in all three refuses to claim headless boot as the cause —
launching Simulator.app did not fix the original failure, and a future session that reads a
confident causal story here will burn an hour re-testing remedies that were already tried.

## Release notes for 2.1, drafted from the post-ship diff (2026-08-05)

Josh confirmed from App Store Connect that 2.0 went live about a week ago, which settled a
question the repo could not answer on its own. `MARKETING_VERSION` was bumped to 2.0 on
2026-06-25, but the submission was not accepted until 2026-07-25 (`8cd8d83`) — a month later,
after the media rejections. Reading "since 2.0" off the version bump therefore credits the
release with a month of work it does not contain, and reading it off the ship date credits it
with none. The submission commit is the honest cut line, and everything before it — the
TelemetryDeck migration, all six code-review phases, the minigame fixes, the widget work — is
in the shipped binary.

That leaves a genuinely small 2.1: five commits touch app code after the submission, and only
three of them are things a user would notice.

The one that justifies a release at all is the audio recovery fix (`473e3f8`). A media-services
reset orphans every cached `AVAudioPlayer`, and this app caches one per effect for the life of
the process, so a single reset silenced it until relaunch. That is a bug worth shipping a
version for; the browse-view rework is the pleasant thing to put next to it.

Two changes were deliberately left out of the notes. The `réaliser` etymology edit (`5b1e553`)
is a four-word rewording of one clause — "Unlike the other verbs here" became "Unlike many
commonly used verbs" — and belongs in a diff, not on a version page. The `Quiz.swift` change
in `c51e223` lowercases the screenshot fixture's exported answers; it exists only so a driver
can type plausible-looking input, and no user reaches it.

The rank badge, the count header, and the moved sort picker all came from `2bae3b6`, but the
count header landed only in `VerbBrowseView` — `ModelBrowseView` has no equivalent. Checked
before writing, because "both lists now show how many results match" is the kind of sentence
that is easy to write and wrong.

Written English-only at Josh's request; he will edit the English, and French relocalization
comes after that rather than before. `MARKETING_VERSION` is still 2.0 — nothing here bumps it.

## French for the 2.1 notes, and a settings toggle that never existed (2026-08-05)

Relocalized the 2.1 notes after Josh approved the English. The translation was routine; the
useful part was what checking the terminology turned up.

The English claimed the app could fall silent "with audio feedback still switched on." Looking
up the French label for that setting found no such key, and `Settings.swift` has no sound
preference at all — Conjuguer has never had an audio toggle. The phrasing had come from the
audio-fix commit message, which describes Konjugieren's repro on Josh's phone ("audio feedback
on and the phone unmuted"), and that app's settings are not this one's. Replaced with "for no
apparent reason," which is both true and a better description of the symptom.

The obvious repair — "even with the device unmuted" — would have been wrong too. `AudioSession`
sets `.playback` with `.mixWithOthers`, so the app plays through the ring/silent switch by
design; inviting users to check the mute switch would send them after the wrong thing.

Tab names in the French notes are the app's own: `Navigation.verbs` is "Verbes" and
`Navigation.models` is "Modèles", read out of the catalog rather than translated freehand, so
the notes name what a French user actually sees. The sort control is "le sélecteur de tri" and
the rank badge "une pastille arrondie" — neither is a UI string, so both are prose choices.

Worth generalizing: a commit message is evidence about the commit, not about the app, and this
one was a port whose narrative belonged to a sibling app. Verifying user-facing claims against
the catalog and the source is cheap; App Store copy that describes a setting a user cannot find
is the kind of error that generates support mail.

## One knob for the build number (2026-08-05)

The 2.1 bump was correct — all four `MARKETING_VERSION` sites, app and widget, Debug and
Release — but checking it surfaced a separate problem in the neighborhood. The build number was
settable from two unrelated mechanisms: the app's `CFBundleVersion` was the literal string `1`
in `Conjuguer/Info.plist`, while the widget had no such key at all and generated its plist from
`CURRENT_PROJECT_VERSION = 1` in its own target settings. They agreed at 1 by coincidence, not
by construction.

That coincidence is load-bearing. An app extension whose `CFBundleVersion` disagrees with its
container fails validation at upload, so the failure mode is a rejected submission — and 2.0
already needed several upload attempts. Bumping to build 2 by editing the Info.plist alone
would have produced exactly that.

Consolidated onto `CURRENT_PROJECT_VERSION` at the **project** level, removed the widget
target's own copy so it inherits, and pointed the app's `CFBundleVersion` at
`$(CURRENT_PROJECT_VERSION)`. Xcode stores project-level settings per configuration, so the
value physically appears twice in the pbxproj (Debug and Release), but it is one row in Xcode's
project-level editor and one `replace` from a script. `MARKETING_VERSION` is untouched and
still lives in four target-level sites; the same consolidation would work for it and was left
alone as a separate change.

Verified by substitution rather than by reading the diff: set the project-level value to 42,
built, and confirmed **both** `Conjuguer.app` and the embedded `ConjuguerWidgetExtension.appex`
reported `CFBundleVersion` 42 with `CFBundleShortVersionString` 2.1 — which proves the widget
really is inheriting and not falling back to a default. Restored to 1 and rebuilt to confirm
the committed state. 219 tests in 19 suites pass.

Worth keeping in mind for the next release: `agvtool` also drives `CURRENT_PROJECT_VERSION`, so
this arrangement stays compatible with it, which an xcconfig holding the version would not have
been.

## README: de-versioned, re-shot, and put on a diet (2026-08-05)

The README had drifted into being a 2.0 press release: a "Version 2.0 Features" heading, and
six screenshots that predated 2.0 with an apologetic parenthetical admitting the quiz, minigame,
tutor, and widgets weren't pictured. Both problems compound with every release — the heading
goes stale on a version bump, and the disclaimer grows.

Retitled the section to plain **Features** and rewrote the bullets to describe the app rather
than a delta from some earlier version. That meant checking each claim against source instead
of carrying the old prose forward, which caught a real error: the 2.0 text said the arcade
minigame is "unlocked from the quiz." It isn't, and there is no unlock gate at all —
`SettingsView` presents `GameView()` from a plain button behind a `fullScreenCover`. Fixed to
"reachable from Settings." Also verified before asserting: the Info tense texts really do quote
both Proust and the *Chanson de Roland* (13 and 4 `Info.*` keys respectively, by a JSON scan of
the catalog); there are two Control Center controls (`QuickQuizControl`, `RandomVerbControl`);
and the VoiceOver claim is stronger than "it's localized" — `accessibilityLabel`s route through
`L`, and `.frenchPronunciation()` / `.englishPronunciation()` switch the speech language so
French forms aren't read aloud as English. Added a real *Building from Source* section (iOS 26,
Swift 6, the `Secrets.xcconfig` copy, the `core.hooksPath` one-liner) and a pointer into `docs/`.

Screenshots: deleted the six 750×1334 relics and rebuilt from
`docs/screenshots/version_4/iPhone_English` (slots 1–9) plus a hand-shot minigame capture. Used
the newer minigame shot from `~/Downloads` rather than the bundle's `10.png` — same scene, but
score 30 with ghosts, a robot, and power-ups on screen instead of an empty opening field.

Two things worth remembering about the image work:

**Layout beats resolution.** First pass kept the old two-column table. Rendered through GitHub's
own markdown API and viewed in Chrome, each row was over 1000px tall — ten screenshots meant
~5000px of scrolling. Switched to two five-column tables with `<img width="190">`; the whole
gallery now fits in roughly two screens. Markdown image syntax can't carry a width, so those
cells are HTML `<img>` tags, which GitHub renders fine inside a table.

**Dithering is not a free win, and it isn't uniform.** Resized to 800px wide and quantized to a
256-colour palette, which took the set from ~3.6MB to ~1.1MB. Dropping to 128 colours saved
another 15% but put visible speckle on the light-theme card backgrounds — rejected on sight.
Then tried `+dither` (dithering off) at 256 colours, expecting a uniform improvement, and got a
*split* result: the two light-theme conjugation tables halved (`verb.png` 182KB→90KB,
`model.png` 182KB→95KB) and looked cleaner, while the dark screens with gradient icon art got
*worse* (`tense.png` 125KB→157KB, `settings.png` 163KB→170KB). Flat UI colour quantizes exactly,
so dithering there only adds noise the PNG filter has to encode; gradients genuinely need it.
Took the smaller variant per image. Final: 45–163KB each, 964KB for all eleven including
`Splash.png`.

Verification was GitHub's `/markdown` API → a static HTML file → Chrome. Note the browser tool
refuses `file://` URLs, so the preview has to be served: a scratch directory with symlinks to
`Images/` and `apple.png`, `python3 -m http.server`, and the relative paths resolve exactly as
they will on github.com.

Post-review addendum. Josh rewrote the SwiftUI line to "The app is now entirely SwiftUI," which
is very nearly true and worth being precise about: `Views/GameCenterAuthView.swift` is still a
`UIViewControllerRepresentable`, and it is the only UIKit bridge left in `Conjuguer/`, `Shared/`,
and `ConjuguerWidget/`. Softened to "SwiftUI throughout, apart from a small UIKit shim that hosts
Game Center's authentication UI."

That raised a follow-up: is the shim still required, or is it debt? The shim is a zero-sized
representable mounted in `QuizView` for one reason — `GKLocalPlayer.authenticateHandler` vends a
`UIViewController` that the caller must present, so something has to own a presenter.

I first guessed that `GKAccessPoint` could take over, on the theory that activating it
authenticates the local player as a side effect, which would let `GameCenterAuthView`,
`GameCenterAuthCoordinator`, and the `onViewController:` parameter all go. **That guess was
wrong**, and it is recorded here so no future session rediscovers it as fact. Checked against the
iOS 26.2 SDK headers, which are authoritative for what this project compiles against:

- `GKLocalPlayer.h:255` — on iOS, `authenticateHandler` is still
  `void(^)(UIViewController *, NSError *)`, `API_AVAILABLE(ios(6.0))`, **not deprecated**.
- `GKLocalPlayer.h:48` — the watchOS variant of the same property is `void(^)(NSError *)`, with
  no view controller. The platforms are modelled differently on purpose, which is good evidence
  that the VC is intrinsic to the iOS presentation model rather than vestigial.
- `GKAccessPoint.h` — **no mention of authentication anywhere**. Apple's docs for `isActive` say
  only that the access point "appears after you initialize the local player." It displays; it
  does not authenticate.
- `GameKit.swiftmodule/arm64e-apple-ios.swiftinterface` — imports Combine, Foundation, and os.
  No SwiftUI, no `View` conformances, no async `authenticate` symbol. There is no SwiftUI-native
  GameKit surface as of this SDK.

There *is* a callback that could replace the `completion:` closure driving the analytics signals:
`GKPlayerAuthenticationDidChangeNotificationName` (`GKLocalPlayer.h:99`, iOS 4.1+, "posted
whenever authentication status changes"). But it only observes status — it presents nothing — so
the shim survives either way, which makes the swap churn without payoff.

Conclusion: `GameCenterAuthView.swift` is a genuine platform constraint, not technical debt. No
code changed. The lesson worth keeping is procedural: SDK headers settled in one grep what the
rendered docs could not (Apple's doc pages are JS-rendered, so `WebFetch` returns only the page
title — use `xcrun --sdk iphoneos --show-sdk-path` and read the headers instead).

## Reconciling two audit docs that had gone stale in opposite directions (2026-08-08)

Josh went looking for the SwiftUI audit material to cite in a job-application essay (a Waymo
prompt: "describe a time you used SwiftUI for a real-world deployment"). Finding it surfaced a
documentation problem worth recording, because the failure mode is one this repo is structurally
prone to.

There are **two** audits, four days apart in June 2026, and they are easy to conflate: the
SwiftUI-modernization audit (~30 numbered issues, Phases 0–8, landed in `fdee834`) and the
UI/design audit (30 ranked recommendations, Batches A–F, landed in `c67738a`). Their surviving
docs are `future-swiftui-fixes.md` and `conjuguer-ui-issues.md` respectively.

Both had drifted from the code, in opposite directions.

`conjuguer-ui-issues.md` **understated** what had shipped. The file carries an explicit
instruction to prepend `✅ DONE —` to each item as it's resolved — and nobody ever did, across
all six batches. So a document that was actually 29/30 complete read as entirely open. That's the
worse of the two failures: a stale to-do list doesn't merely fail to inform, it actively
misdirects, and it would have cost a future session a full re-derivation to discover the work was
already done. Reconciled by reading the current source view-by-view rather than trusting session
notes, and each item now carries a `**Shipped:**` line naming the symbol that resolves it, so the
claim is checkable rather than assertable. Several items shipped *better* than specced — the
sensory-feedback item, for instance, was specced as two triggers and shipped as one closure keyed
on the results count, which fires exactly once per submission.

`future-swiftui-fixes.md` **overstated** what remained. Of its four deferred parts, two had been
made moot by later work (the `UITextView`/`NSAttributedString` pipeline they concerned was deleted
outright in the code-review batches) and one was done. Only the nav-bar aesthetic decision is
genuinely open — and it turns out to be the *same* decision as the UI list's item #26, tracked
independently in two places without either knowing about the other. They're now cross-linked.

**The trap that nearly produced a wrong answer.** The deferred deep-link buffer (Part 2d) specced
a `@State private var pendingURL` in `ConjuguerApp`. Grepping `pendingURL` returns nothing, and
the first reconciliation pass duly marked it open. It had in fact shipped a month later in
`1f359d4`, as `World.pendingDeeplink` drained by `drainPendingDeeplink()` — put on `World` rather
than the app struct precisely because the widget `.widgetURL` path needed it too, which was the
bug that forced the fix. The lesson: **a spec's proposed identifier is not evidence of anything.**
Grepping the name a document *proposed* tests whether the document was followed literally, not
whether the problem was solved. Verify against behavior — or at minimum grep the concept, not the
identifier — before writing "still open" next to something.

That same class of drift is why the reconciliation added a *Stale anchors* table to
`quiz-best-score-followup.md` instead of just closing it: that doc's spec references
`GameCenterable.swift`, `TestGameCenter.swift`, `notStartedView()`, and `Localizable.strings`, all
of which have since been renamed (`GameCenter.swift`, `GameCenterStub.swift`,
`notStartedBriefing`, `Localizable.xcstrings`). The feature it specs also shipped by another route
entirely — the briefing's best score reads `Settings.bestScore`, persisted locally by `Quiz.swift`,
so none of the proposed GameKit work was needed. The doc is kept anyway, since a leaderboard-backed
score remains a real alternative if a cross-device best score is ever wanted.

No code changed. The essay prompt at `~/Desktop/workspace/Conjugar/prompts/essay.md` now carries a
background section drawn from this reconciliation, including the caveat that both audits were
AI-assisted and that the essay should characterize that deliberately rather than by omission.

## Frequency data for all 6,320 verbs: the research (2026-08-28)

The verb list has carried Sketch Engine ranks for 981 verbs since 2021, and Konjugieren's
DWDS success (permission granted 2026-08-26, ranks for all 3,572 verbs) made the gap in
Conjuguer look like a solvable problem rather than a fact of life. Josh's prompt
(`prompts/freq_prompt.md`) asked for a research pass: start with Lexical Computing and what a
paid plan costs, then search widely, using the Chrome MCP where it helped. The result is
[`verb-frequency-sources.md`](verb-frequency-sources.md).

**The first finding reframed the question.** The 1,000-item cap on word lists from Sketch
Engine's preloaded corpora is *identical* for trial and paid accounts — the account-limitations
page lists the same "1,000 items from one list" in both columns. So the €152.04/year freelancer
plan (found by driving the JS price calculator in Chrome and then reading its backing API at
`pay.sketchengine.eu/api.cgi?c=pricelist`, which also gave the academic rates) buys nothing
toward the goal. A longer list is a bespoke, quoted data product with no published price; the
sample research licence for academics has its fee redacted and forbids commercial use anyway.
The doc drafts the quote request, and asks in the same email whether one-lemma-per-request API
querying under a subscription — Konjugieren's DWDS pattern — would be acceptable instead.

**The second finding made paying optional.** GLÀFF, a CC BY-SA 3.0 lexicon built from
Wiktionnaire at Toulouse, carries lemma counts from FrWaC (1.25 billion words), Le Monde, and
Frantext. Downloaded from the CNRS mirror on Hugging Face (the Toulouse server refused
connections) and matched against `verbs.xml`: 6,265 of 6,316 distinct infinitives, and its
FrWaC ordering agrees with the existing ranks at Spearman 0.924. Lexique 4 — a 2026 release
that turned up mid-research, 316 million words of subtitles — covers 5,614 and correlates at
only 0.567, because subtitles rank *vouloir*, *parler*, *aimer*, and *tuer* where the web
ranks *permettre*, *consulter*, and *utiliser*. That register question is now the real decision,
and the doc lays it out rather than settling it.

**Things that failed, so nobody retries them.** `get_page_text` returned nothing on Sketch
Engine's pricing pages (the accessibility tree via `read_page` worked); screenshots came back
"omitted due to error" all session, so every price was read from the DOM or the API. Leipzig's
download site sat behind a proof-of-work bot check and answered "This language is not known
to us" for French at the URL tried. `corpus.leeds.ac.uk` timed out. COW's FRCOW16 is gone —
Roland Schäfer's May 2025 post says he and Felix Bildhauer paid for the server themselves
until 2024. And the tempting shortcut of summing a subtitle *form* list through GLÀFF's
form→lemma map produced *taire* as the third most common French verb, because *tu* is its past
participle; form lists need a tagger, full stop.

**Side effect.** The coverage runs caught seven `verbs.xml` entries that no dictionary knows:
five infinitives with a dropped *v* (`préenir`, `récidier`, `réolvériser`, `transaser`,
`désenaser`) and two missing accents (`eduquer`, `egorger`), plus common verbs the list lacks
outright (*alléger*, *éduquer*, *encaisser*, *perpétuer*, *égorger*). Those are logged in the
doc for a separate fix. No code changed; nothing was sent or purchased.

## Two plans out of the frequency research (2026-08-28)

Josh asked for two prompt files to act on the research. Neither has been run.

[`prompts/fix-and-add-verbs.md`](../prompts/fix-and-add-verbs.md) handles the side finding:
the seven `verbs.xml` entries no lexicon knows. Reading them with their glosses settled what
each one is — `préenir` carries prévenir's exact gloss and model (`6-7`) and prévenir exists
forty lines later, so it is a duplicate to delete, while the other six are renames whose
existing `mo` values already fit the corrected spellings. The "five missing verbs" turned out
to be three net-new entries (*alléger*, *encaisser*, *perpétuer*) plus the two accent fixes
(*éduquer*, *égorger*); Josh then pulled the research doc's other ten into scope, so the plan
adds thirteen entries (6,320 → 6,332), one of them *dépourvoir*, which is defective and so
drags in `defectGroups.xml` — group 13, *faillir*'s, is the candidate, with a new group as the
fallback if the dictionaries say "unused" rather than "rare". It also inherits two
ground truths worth recording: the corpus originals are still on disk, so examples can be
mined rather than authored, and a grep of the Oxford Roland found no *alegier* or *esgorgier*,
so the Chanson-example step Josh asked for will most likely end in an honest "none" — the plan
requires the check anyway, because the reflex table is audited, not guessed. A trap it
defuses: `VerbView.sourceClaude` hard-codes "Claude (Opus 4.8)", so any example authored by
this session must not inherit that label.

[`prompts/glaff-frequency-ranking.md`](../prompts/glaff-frequency-ranking.md) is the
implementation of the research's recommendation, with the decisions pinned so a future
session does not reopen them: FrWaC primary, LM10 → Frantext → Lexique 4 tie-breaks, counts
stored as `hi`/`hn`/`hl`/`hs` with absent ≠ zero, ranks derived in `VerbParser.ranked` the
way Konjugieren does it, duplicate `ex=` entries sharing a rank. Two consumers needed thought
beyond the parser: the widget's verb-of-the-day pool is "ranked verbs" today, which after the
change would mean all 6,328 distinct infinitives including *abcéder* with no example, so the plan switches it to
"verbs with a literature example"; and `Info.valuePropositionText` still promises rankings
"for the top 981 French verbs, from être to ancrer". Credits keep Lexical Computing as five
years of history, add GLÀFF and Lexique 4, and carry the line Josh asked for mid-turn: that
he studied at the Université de Toulouse, where GLÀFF was built. Two later instructions shaped
both files: neither plan commits (Josh does), and the second plan assumes the first has run
and says nothing about it — no ordering checks, no "if the other plan has landed" branches.

## Estimates for the verbs no corpus lists (2026-08-28)

Before signing off Josh asked what happens to ranks for verbs outside the corpus — he prefers
that frequency never be blank, and Konjugieren's estimated counts had served fine. Checking
the answer exposed a flaw in the second plan as written: its tie-breaker tuple put "absent
from GLÀFF" below "one FrWaC hit," and GLÀFF omits hyphenated compounds by design, so
*sous-estimer* — 11.5 per million in subtitles — would have ranked under *bêcheveter*. The fix
is Konjugieren's `hp`: an estimated count, flagged, clamped below the measured count at rank
1,000, and reported as a population. A log-log fit of FrWaC on Lexique 4 over the 5,572 verbs
both list (`7.57 + 0.76·log`, R² 0.69, ±2.6× typical) places the 24 hyphenated verbs Lexique 4
has in plausible company (*sous-estimer* ≈ #1,050, *tire-bouchonner* ≈ #5,100); base-verb
scaling covers the ten compounds in no source; a hand-maintained editorial file covers nine
rarities. The research doc gained a *Verbs no corpus lists* section and
`glaff-frequency-ranking.md` a rewritten decision 5 and pipeline steps to match.

## Seven bad infinitives, thirteen new verbs, and a defective verb that needed a new group (2026-08-28)

The frequency research turned up two side findings in `verbs.xml`: seven infinitives no
dictionary knows, and a shortlist of common verbs the file simply lacks. This session fixed
both, then gave the additions the same treatment their neighbours in the top 1,500 already
have — an etymology in both languages and an example sentence with honest provenance.

`préenir` was a duplicate: *prévenir* already sat 40 lines below with the same model and a
real frequency rank, so the line was deleted rather than repaired. The other six were
renamed after confirming each target on fr.wiktionary — including the two I least expected
to survive, *révolvériser* (« cribler de balles à l'aide d'un révolver », and the 1990
spelling of an older *revolvériser*) and *désenvaser*, which not only exists but has a
derivative, *redésenvaser*. Five of the seven had lost a *v* in what looks like one bad
transcription pass (`préenir`, `récidier`, `réolvériser`, `transaser`, `désenaser`); the
other two had lost an accent (`eduquer`, `egorger`). Three of the renames changed their
alphabetical home (`désenvaser`, `révolvériser`, `transvaser`), so the edit script re-inserted
every moved and new line at its French-collation position rather than editing in place. The
collation sweep afterwards reports exactly one out-of-order pair, `visionner > visibiliser`,
which predates this work and involves none of these lines.

`xmllint --valid` did not pass before this session and had nothing to do with the verb list:
the DOCTYPE declared `in tn mo ay fr dg` but the file also uses `re` (208 times), `ah` (60)
and `ex` (8). Three `#IMPLIED` declarations later it validates.

### dépourvoir and defect group 27

The plan proposed reusing defect group 13 (*faillir*'s "Impératif is not used. Rare outside
passé simple and participe passé"), on the strength of dictionaries that list *dépourvoir* in
the infinitive, passé simple, participe passé and compound tenses. The sources say something
narrower. The TLFi marks it *Vx.* and restricts it to "[Seulement à l'inf. et aux temps
composés]", adding the deflating note that its own examples "ne correspondent à aucun usage
attesté"; fr.Wiktionary says "il n'est guère usité qu'à l'infinitif et surtout au participe
passé". Neither mentions the passé simple, so group 13's description would have been wrong
about this verb in the one place it is most specific.

Encoding the right thing meant reading how the `uo`/`du` shorthand actually decodes.
`Tense.tensesForShorthand` knows only the *simple* tense families (`r x i f c b q h`, plus
`pp rr sf`) and bare person-numbers; there is no code for a compound family. So a `uo` group —
which starts from "everything is defective" and un-marks only what it lists — cannot express
"the compound tenses are used", and `uo="pp"` (groups 6 and 15) in fact marks every compound
tense defective. The plan anticipated this question and left the answer to be checked; the
answer is that `uo` can't do it. `du` can: group 27 is
`du="rA,iA,xA,fA,cA,bA,qA,hA,rr"` — strike every simple tense and the participe présent, and
what remains is the infinitif, the participe passé, and the eight compound families. That is
the TLFi's sentence, exactly. `hA` also strikes the impératif passé, via the
`mirrorImpératifToPassé` pass in `DefectGroup.applyDefect`, which is right: there is no
imperative at all. In the simulator *dépourvoir* now reads "Defective. Only participe passé
and compound tenses are used", with *dépourvu* live and *dépourvoyant*, *je dépourvois* and
the rest struck through.

The conjugation engine is untouched by defectivity, so `AddedVerbsTests` still pins
`il dépourvut` — *pourvoir*'s passé simple, not *voir*'s `dépourvit`. That was the one
conjugation worth a test: `mo="4-1C"` is doing real work.

### What the model says about alléger's future

The plan asked which spelling the app produces for *alléger*'s futur — `allégerai` or
`allègerai`. Model 1-6C (*protéger*) applies its é→è alteration only to `r1s,r2s,r3s,r3p,b1s,
b2s,b3s,b3p`, so the futur keeps the acute: **allégerai**, matching `protégerai` in the
generated model tests. Pleasingly, the subagent's etymology reaches the same fork from the
other side, noting that the traditional `allégera` competes with the 1990 rectifications'
`allègera` and that both are current — and the Flaubert example mined for the verb happens to
contain the finite form `allégera` itself.

### Examples: what the corpus had, and what it didn't

Thirteen of the fifteen were mined from the open tiers. The two best finds were literary and
both La Fontaine: *égorger* from *Le Cygne et le Cuisinier* ("Il alloit l'égorger, puis le
mettre en potage"), and — for *dépourvoir* — the opening of *La Cigale et la Fourmi*. That
second choice deserves a note, because the plan explicitly warned off "*dépourvu*-as-adjective".
There is no finite verbal use of *dépourvoir* anywhere in the corpus, and there could not be:
the verb is defective precisely down to its participle. "Se trouva fort dépourvue" is that
participle in predicative use — the verb's only living form — so it is the honest example, and
the alternative was inventing a sentence in a tense the dictionaries say nobody writes.

*alléger* came from Flaubert's comices-agricoles oration; *perpétuer* from a single clean
Wikipedia sentence ("Les guerres impériales ont perpétué la Révolution"); *impacter* from
France Stratégie, where the verb the Académie objects to appears without apology ("d'autres
facteurs que la technologie impactent le travail"). *acter* was the sneakiest to mine: a stem
regex on `act[eé]` returns 247 hits that are almost entirely the noun *acte* and Molière's act
headings, and the one genuine verbal use turned up as a side effect of the *éduquer* search —
"la planification écologique, dont la nécessité a été actée par le président de la République".

Two verbs had nothing. *bloguer* does not appear in any tier in any form; the corpus has
`blog`, `blogs`, `Blogger` and `blogosphère`, and no verb. *redimensionner* appears only as the
noun `redimensionnement`, four times. Both are therefore Claude-authored, which had a
consequence the plan flagged: `VerbView.sourceClaude` hard-coded "Claude (Opus 4.8)", and this
session is not Opus 4.8. `ExampleSource.claude` now carries the raw source string as an
associated value and `L.VerbView.sourceClaude(_:)` takes it as a parameter (`— example written
by %@` / `— exemple rédigé par %@`), so the 82 existing entries still render "Claude (Opus
4.8)" — verified on *plaire* in the simulator — and the two new ones render "Claude (Opus 5)".
Naming the wrong model would have been a small lie told 84 times.

### No Chanson examples, and that is the answer, not a gap

The reflex policy attaches a *Chanson de Roland* line only when it contains the modern verb's
own ancestor. Greps of `chanson-roland-oxford.txt` and the bracket glosses in `chanson.md`
found no `aleg-`, `esgorg-`, `desporv-`/`despurv-`, or even `porv-`/`purv-`: *alegier*,
*esgorgier* and *desporveir* are all absent from the Oxford text. The poem does carry `vestir`
fifteen times (knights donning mail), which is the ancestor of *vêtir*, **not** of
*réinvestir* — a learned borrowing of *investīre*, prefixed. Attaching it would have been
exactly the synonym-shaped mistake the policy exists to prevent. The other twelve verbs are
later borrowings or modern formations and could not appear in an eleventh-century poem;
spot-greps for `cadr`, `dessin`, `dimension`, `carte`, `blog`, `impact` and `educ`/`eduq`
returned zero.

### Recounted, not nudged

`verbs.xml` goes from 6,320 entries to **6,332** (−1 `préenir`, +13 new), over **6,328**
distinct infinitifs — the gap is the handful of verbs carrying two conjugation patterns
(*sortir*, *saillir*, …). The regular/irregular split was recomputed from
`VerbModel.irregularity` in a throwaway test rather than nudged: **5,235 regular / 1,093
irregular**, replacing a 5,217/1,097 pair that was already stale against a "6,314" total
nobody had updated. Defective verbs: **72** distinct infinitifs carry a `dg`, replacing
"sixty-six" / "soixante-six" in both languages. `Info.irregularitiesText`,
`Info.valuePropositionText`, `Info.creditsText`, both `Onboarding.browse*` strings, README,
CLAUDE.md and `docs/project-structure.md` all now agree.

Two documentation corrections fell out of the verification pass. `literature_examples.json`
and its `corpus/json/` twin were *not* byte-identical as the corpus doc claims — the bundled
copy had a trailing newline the other lacked; both are now written the way
`merge_classical.py` writes them (`json.dump(..., indent=1)`, no trailing newline) and `cmp`
is clean. And CLAUDE.md's note that the unannotated verb-search field sits at ≈ `201,191` on
iPhone 17 is wrong for the current layout: `describe_ui` puts the lone `AXTextField` at
`{{16, 70}, {315, 44}}`, centre ≈ `173,92`. The stale number cost two wasted taps before I
measured; the note now says to measure.

All 233 tests pass, including the 14 new ones in `AddedVerbsTests` — which, besides the
conjugations, assert that the seven old misspellings no longer conjugate at all.

## A frequency rank for every verb: GLÀFF replaces a capped 2021 export (2026-08-28)

Since 2021 Conjuguer has ranked verbs by frequency of use, and since 2021 it has ranked
exactly 981 of them. That was never a judgment about which verbs deserve a rank; it was
Sketch Engine's word-list export cap. The research that went looking for a replacement is
[`docs/verb-frequency-sources.md`](verb-frequency-sources.md) — the short version is that a
paid Sketch Engine subscription does not lift the cap (it is the same 1,000 items for trial
and paid accounts alike), a longer list is an individually quoted data purchase, and the best
free alternative is **GLÀFF 1.2.2**, a CC BY-SA 3.0 lexicon built from Wiktionnaire at
CLLE-ERSS in Toulouse that ships lemma counts from three corpora. This entry is the build.

**The shape of the change is Konjugieren's, not 2021's.** `verbs.xml` no longer stores a
rank. It stores counts — `hi` (FrWaC web hits, the primary key), `hn` (Le Monde), `hl`
(Frantext), `hs` (Lexique 4 subtitles ×1000) — and `VerbParser.ranked(_:)` derives the
1..6,328 rank once per parse. A rank is a property of the corpus, not of the verb: storing
ranks means adding one verb renumbers every verb below it, which is how a one-line change
becomes a 6,000-line diff. `Verb.maxFrequency = 981` became `Verb.rankCount`, which
`VerbData.publish` sets from the parse, so the denominator `VerbView` shows can't go stale
either.

**The numbers.** GLÀFF covers 6,284 of the 6,328 distinct infinitives. Spearman against the
2021 ranks over the 980 verbs both cover is **0.9236**, which is the whole reason web
register won over subtitle register: the top of the list barely moves. FrWaC's top ten is
*être, avoir, faire, pouvoir, devoir, aller, voir, dire, mettre, permettre* — the 2021 list
minus *consulter*. 116 verbs are measured at zero and take the last ranks alphabetically;
that is honest, since a corpus that could have seen them did not.

The biggest movers are almost all corrections rather than noise. *faillir* #22 → #900 and
*étayer* #128 → #1519 fall because Le Monde's lemmatizer had been collapsing *fallait* and
*étais* onto them; FrWaC is the sane one there. *poster* #461 → #54 is the web talking. The
three suspects the research flagged (*ligner* at 21,696 hits, *ouvrer*, *téter*) are FrWaC
tagger noise inflating rare verbs, and I left them measured as the plan said to — an oddly
high rank for a rare verb is a smaller lie than a hand-edited count.

**One count I did not leave alone.** *convaincre* carries 2 FrWaC hits against 503 in
Frantext, and *every* form including the bare infinitive shows zero occurrences — impossible
in 1.25 billion words of web text, so it is a failed join rather than a measurement. Shipping
it would have put *convaincre* at #6,074 of 6,328. Rather than hand-edit the number I added a
stated rule: a FrWaC count below 2% of the larger of the other two corpora, where that larger
one is itself at least 200, is treated as *unmeasured* and routed through the estimate tiers
like any verb GLÀFF lacks. The thresholds sit deliberately far from any honest register
difference, and on the build day they caught exactly one verb — *faillir* and *étayer*,
inflated elsewhere rather than depressed in FrWaC, stayed measured. *convaincre* now ranks
#1,001, clamped, flagged `hp="y"`. Still low for a verb that was #396, but the clamp exists
so no estimate can ever enter the top of the list, and I would rather it bind here than
special-case it.

**Nothing is blank.** GLÀFF omits hyphenated compounds by design, so absence from it is not
evidence of rarity — ranked by absence, *sous-estimer* (11.5 per million in subtitles) would
fall below *bêcheveter*. The 45 unmeasured infinitives get an estimated FrWaC-equivalent in
three tiers: 25 **calibrated** from Lexique 4 through a log-log fit
(`log(frwac) = 7.58 + 0.76·log(lex4)`, R² 0.69, typical error ±2.6×), 10 **scaled** from a
base verb by a measured prefix ratio, and 9 **editorial**, hand-assigned in
`frequency/editorial-counts.json` with a written reason each. The calibrated ones land in
plausible company: *sous-estimer* ≈ #1,050, *sous-entendre* ≈ #1,690, *pique-niquer* ≈
#2,190, *tire-bouchonner* ≈ #5,160. Every estimate is clamped to the measured count at rank
1,000 (13,773 hits) and flagged `hp="y"`, so the provisional population stays countable — 45
of 6,328.

Writing the editorial tier turned up two probable misspellings in `verbs.xml`: GLÀFF measures
`haubaner` and `ahaner`, one *n* each, where Conjuguer has `haubanner` and `ahanner`. The
counts are right either way and I used them, with the reason recorded; the spellings are a
note for the next verb-list audit, not this project's job.

**Two bugs the build found.** First, `VerbParser` keys its dictionary by
`infinitif + " " + extraLetters` (a space) while `Verb.infinitifWithPossibleExtraLetters`
formats the same thing with parentheses. My first `ranked(_:)` rebuilt the dictionary from
the latter and silently dropped `haïr France`, `ouïr`, `saillir`, and the Canadian `sortir` —
142 test failures, all conjugation, none of them obviously about ranking. Grouping by
dictionary *key* instead of by value fixed it, and the shared-rank test now pins the
behavior. Second, Python's French collation and Swift's disagreed on exactly one of 86 tie
groups: ICU expands `œ` to `oe`, so `œilletonner` sorts after *obvenir*, while stripping
combining marks leaves the ligature intact and sorts it after every *z*. I verified this the
direct way — dumped the tie groups, sorted them in a throwaway Swift script with
`compare(_:locale: Util.french)`, and diffed — and both `french_key()` functions now expand
the ligatures. 86 groups, 0 mismatches. `docs/frequencies.txt` and the app agree verb for
verb, which is the point: "verb 400" has to mean the same thing to a future subagent as it
does to the app.

**The widget pool moved on purpose.** `WidgetSnapshotWriter.eligibleVerbs()` filtered on
"has a rank", which was a proxy for "is one of the 981 that also have examples and
etymologies". With every verb ranked, that filter would have put *abcéder* on someone's Lock
Screen with nothing to show. The pool is now "has a literature example" — 1,144 entries
instead of 982 — so the verb of the day for a given date changes once, and then is stable.

**Credits.** Adam Kilgarriff's paragraph stays, in the past tense: Sketch Engine supplied the
rankings of the 981 most common verbs from 2021 to 2026, which is a true credit for five
years of a feature. Lexique 4 (New, Pallier, Schalchli, Bourgin & Gimenes) joins between
Nègre and Och; GLÀFF (Sajous, Hathout & Calderone) after Okada & Oguriso, with the note Josh
asked for — he studied at the Université de Toulouse, where GLÀFF was built. Both languages,
both rendering correctly in `RichTextView`. `Info.valuePropositionText` no longer says 981;
it says all 6,328, *from être to humoter*, which is the honest new pair.

The pipeline lives in `frequency/` at the repo root, outside both synchronized target folders
so nothing ships: three scripts, the tracked `verb-counts.json` and `editorial-counts.json`,
GLÀFF's own README (its licence asks that it travel with redistributed derived data), and
SHA-256s for the two 200 MB sources that are gitignored. `frequency/README.md` has the
re-download recipe. All 240 tests pass, `check_docs.py` is clean — after teaching it that
`verb-counts.json` is not a file called `counts.json`.

## The editorial tier was hiding two misspellings (2026-08-28)

The GLÀFF build left nine verbs in the editorial tier — the hand-assigned counts for verbs no
corpus lists. Writing a justification for each one is what caught the problem: two of the nine
reasons I wrote said, in effect, *this is the same verb as one GLÀFF measures, spelled
differently*. `verbs.xml` carried `ahaner` **and** `ahanner`, `haubaner` **and** `haubanner`
— identical translations, identical models (`1-1`), differing by one doubled *n*. TLFi,
Larousse and Wiktionnaire all give the one-*n* spellings; FrWaC has 95 hits for `ahaner` and
102 for `haubaner`, and has never seen either doubled form.

So these were not misspellings to correct in place — the correct spelling was already sitting
on the adjacent line. They were duplicate entries, and the fix was deletion. Both pre-date all
of this work; `git show fccc793` has them, and so does everything before it. Nine verbs of
editorial judgment became seven, and the unmeasured population went from 45 to 43 without a
single count changing. That is the shape a data-quality fix should have: the gap closed
because the gap was an error, not because I filled it in.

Worth stating for whoever runs the pipeline next. An estimate is where a data problem surfaces
whether you want it to or not. A verb that every corpus misses is sometimes genuinely rare and
sometimes just wrong, and the tier that forces you to write down *why* you chose a number is
the one that tells you which. The seven that survive — *anathémiser*, *bienvenir*,
*blistériser*, *coupasser*, *humoter*, *lock-outer*, *prompter* — each have a reason that
holds up: dictionary ghosts, an archaism, a packaging neologism, two anglicisms.

**The ripple.** Verb counts live in more places than feels reasonable, and the previous
session's "recount everything" pass mapped them, so this was mechanical rather than a hunt:
6,332 entries → **6,330**, 6,328 distinct infinitives → **6,326**, and the regular split
5,235 → **5,233** (both deletions were model `1-1`; the irregular 1,093 is untouched). That
covers `Info.irregularitiesText`, `Info.valuePropositionText`, both `Onboarding.browse*`
strings in both languages, README, CLAUDE.md, `docs/project-structure.md`, and
`frequency/README.md`. The value proposition still ends *from être to humoter* — the tail of
the list did not move, only its length.

`AddedVerbsTests.testMisspellingsNoLongerConjugate` grew from seven misspellings to nine, and
a new test asserts the survivors still conjugate, so a future data pass can't quietly
reintroduce either duplicate. 241 tests pass.

**Release notes.** `docs/release-notes-2.2.txt` covers the whole frequency change in both
languages: every verb ranked rather than the first 981, sorting by frequency now ordering the
entire list, the ranking computed before shipping so nothing is fetched over the network, and
the two duplicates removed — which is the honest explanation for why the app now advertises
6,330 verbs instead of 6,332, a number a returning user might otherwise read as verbs having
gone missing.
