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
