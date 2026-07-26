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
