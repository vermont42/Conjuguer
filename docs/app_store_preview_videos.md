# App Store Preview Videos (Final Cut Pro)

How to set up and record the four App Store preview videos for a Conjuguer
release: **English iPhone, French iPhone, English iPad, French iPad**.

This mirrors the workflow used for the sibling app Konjugieren, whose Final Cut Pro
(FCP) library lives at `~/videos/Konjugieren.fcpbundle`. The settings below were
read directly off that library's projects.

## FCP terminology refresher (3-level hierarchy)

```
Library  (.fcpbundle file)        ← e.g. "Conjuguer"     (top-level document)
 └─ Event  (container)            ← e.g. "Event"         (holds media + projects)
     └─ Project  (a timeline)     ← one per video        (what you export)
```

- **Library** — the whole document. One per app.
- **Event** — a folder inside the library holding your media clips *and* projects.
  Named simply `Event` here. (Konjugieren used a date, e.g. `2-8-26`; a plain name is
  fine since there's only one.)
- **Smart Collections** — auto-created by FCP; ignore.
- **Project** — an editable timeline that exports to a video file. You create one per
  video.

## Projects to create

In the Event, create four Projects (**File ▸ New ▸ Project**, or ⌘N → click
**Custom Settings**, set **Video → Format: Custom**, enter the resolution, set
**Rate: 30**):

> **You must set Video → Format to "Custom" first.** The default format (1080p HD) only
> offers fixed landscape presets (1920×1080, etc.); the resolution fields don't become
> editable — and you can't type a portrait size — until Format = **Custom**.

| Project          | Format | Resolution    | Rate |
|------------------|--------|---------------|------|
| **English iPhone** | Custom | **886 × 1920** | **30p** |
| **French iPhone**  | Custom | **886 × 1920** | **30p** |
| **English iPad**   | Custom | **1200 × 1600** | **30p** |
| **French iPad**    | Custom | **1200 × 1600** | **30p** |

> **⚠️ App-preview sizes are NOT screenshot sizes. Do not reuse the screenshot table.**
> This is the single most expensive mistake available in this pipeline, and this document
> made it: through 2026-07-25 it specified 1320 × 2868 / 2048 × 2732 projects and called
> them "Apple's standard App Store app-preview sizes." They are *screenshot* sizes. All
> four videos were rejected at upload with *"The dimensions of one or more previews are
> wrong. The app preview dimensions should be: 886 × 1920px or 1920 × 886px."*

Apple's app-preview sizes, which differ from the screenshot sizes in every case:

- **886 × 1920** — **every** current iPhone display class (6.9″, 6.5″, 6.3″, 6.1″). One
  iPhone preview file serves all of them; there is no per-display-size iPhone preview.
- **1200 × 1600** — iPad 13″, 12.9″, 11″, and 10.5″. Same story.

> The earlier version of this note rejected 886 × 1920 as "the legacy 6.5″ size, still
> accepted" and switched to 1320 × 2868 for its exact-pixel simulator match. That
> reasoning is wrong end to end: 886 × 1920 is not legacy, not 6.5″-specific, and not
> optional — it is the only accepted portrait iPhone preview size. Konjugieren's projects
> had it right. Pixel-exactness with the simulator is worth nothing if the delivered file
> is a size the App Store refuses.

Current sizes are at
[App preview specifications](https://developer.apple.com/help/app-store-connect/reference/app-preview-specifications/).
Re-read that page each release rather than trusting this table.

## Simulators to record from

| Project size          | Simulator                            | Native resolution | vs. project |
|-----------------------|--------------------------------------|-------------------|-------------|
| 886 × 1920 (iPhone)   | **`iPhone 17 Pro Max`** (iOS 26)     | 1320 × 2868       | 67% downscale, ~0.24% aspect trim |
| 1200 × 1600 (iPad)    | **`iPad Pro 13-inch (M5)`** (iOS 26) | 2064 × 2752       | 58% downscale, aspect exact |

Neither device records at the preview size, and that is fine — record at native
resolution and let the project scale down. Downscaling loses nothing visible; what you
must not do is deliver at the recording size.

**Set Spatial Conform to *Fill* on the iPhone clips.** 1320 × 2868 is 0.4603 and
886 × 1920 is 0.4614 — close, but not equal. *Fit* would letterbox with thin black bars;
*Fill* crops roughly 3 px from each end, which is invisible. The iPad is 3:4 on both
sides (2064 × 2752 is exactly 0.75, 1200 × 1600 exactly 0.75), so either setting works
there.

### Why the iPad uses the 13″ M5

Record on the **iPad Pro 13-inch (M5)** — the only iOS-26 iPad Pro. (The older
**iPad Pro (12.9-inch) (6th generation)** is unusable regardless: Conjuguer's deployment
target is **iOS 26.0**, and that device exists only on iOS ≤ 18 runtimes, so the app
won't install and `xcodebuild` rejects the destination outright.) Both iPhone and iPad
footage then share the same iOS 26 look.

Its native 2064 × 2752 is exactly 3:4, matching the 1200 × 1600 project, so the
downscale is uniform with no crop and no letterbox.

> When you drop the recording onto the 1200 × 1600 timeline, FCP will offer to change
> project settings to match the clip. **Decline** — the project must stay at the
> App Store preview size. Accepting is how a rejected file gets made.

### Recording

- Record with `xcrun simctl io <udid> recordVideo <out.mov>` (or Simulator ▸ File ▸
  Record Screen). That captures at **native pixel resolution** even though the
  Simulator *window* may be displayed scaled down.
- To get the simulator UDIDs:
  ```bash
  xcrun simctl list devices available | grep -iE 'iPhone 17 Pro Max|iPad Pro 13-inch \(M5\)'
  ```
- Build/install the current app onto a recording simulator before recording. The
  `ios-build-verify` build skill is pinned to the iPhone 17 / iOS 26 sim in its config,
  so for these specific devices build by UDID directly:
  ```bash
  UDID=<sim-udid>   # iPhone 17 Pro Max, or iPad Pro 13-inch (M5)
  xcodebuild -project Conjuguer.xcodeproj -scheme Conjuguer \
    -destination "platform=iOS Simulator,id=$UDID" \
    -derivedDataPath build/preview-dd build
  xcrun simctl bootstatus "$UDID" -b
  xcrun simctl install "$UDID" \
    "$(find build/preview-dd/Build/Products -name Conjuguer.app | head -1)"
  xcrun simctl launch "$UDID" software.racecondition.Conjuguer
  ```

### Placing clips on the timeline

For both devices FCP will offer to *change project settings to fit the clip*
(1320 × 2868 or 2064 × 2752). **Decline every time** — the project resolution is the
delivered resolution, and the clip resolution is never an accepted preview size.

- **iPhone (1320 × 2868 → 886 × 1920):** set the clip's Spatial Conform to **Fill**
  (Video inspector) so the 0.24% aspect difference crops instead of letterboxing.
- **iPad (2064 × 2752 → 1200 × 1600):** aspect is identical; no conform choice matters.

## Export settings and conformance

FCP's default share destination does **not** produce a conformant file. The 2026-07-25
exports violated four separate requirements that the App Store Connect error message
never mentioned — it complained only about dimensions.

**How much this matters is known, and it is less than it looks.** Sibling app Konjugieren
shipped its 1.2 previews with Level 5.0/5.1 video, 125 kbps audio, and a stray timecode
track, and App Store Connect accepted them. So of the rows below, **dimensions and
duration are enforced; the rest are cleanup.** `scripts/verify_store_media.sh` grades them
that way — blocking versus advisory — rather than treating every spec line as fatal.

| Requirement | Spec | What FCP's default export gave |
|---|---|---|
| H.264 profile/level | High, **≤ Level 4.0** | Level **5.0** (iPhone), **5.1** (iPad) |
| Video bit rate | 10–12 Mbps target | 15–16 Mbps (iPhone), 12.6–13.8 (iPad) |
| Audio | **256 kbps** stereo AAC, 44.1/48 kHz | 126 kbps |
| Tracks | video + audio, all enabled | a third **timecode data track** |
| Duration | 15 s min, **30 s max** | 30.000 s video, but a **30.014 s container** — see below |

Rather than fight the export dialog, treat FCP's output as a master and run every file
through this normalization pass, which enforces all of the above by construction:

```bash
# iPhone: W=886  H=1920      iPad: W=1200 H=1600
ffmpeg -y -i "master.mov" \
  -map 0:v:0 -map 0:a:0 -dn -sn \
  -vf "scale=${W}:-2,setsar=1,crop=${W}:${H}" \
  -frames:v 900 -t 30 -shortest \
  -c:v libx264 -profile:v high -level 4.0 -pix_fmt yuv420p -r 30 \
  -b:v 11M -maxrate 12M -bufsize 24M \
  -c:a aac -b:a 256k -ar 48000 -ac 2 \
  -map_metadata -1 -movflags +faststart \
  "preview.mp4"
```

Four details that are easy to get wrong:

- **`setsar=1` is not optional — omitting it produces a file that looks correct and is
  rejected anyway.** `scale=W:-2` rounds the computed height to an even number and then
  compensates by writing a non-square **pixel** aspect ratio. The result reports
  `width=1200, height=1600` to every casual check while carrying `SAR 2048:2049`, so its
  *display* aspect is 512:683 rather than 3:4. App Store Connect evaluates display
  dimensions and rejects it with the **exact same** "dimensions are wrong" message a
  genuinely mis-sized file gets. This cost a second upload attempt on 2026-07-25 after the
  dimensions had already been "fixed"; the `setsar=1` build was then **accepted, and 2.0
  submitted successfully**.

  > One caveat on that evidence, so a future reader doesn't over-trust it: the accepted
  > re-encode changed **two** things at once — it added `setsar=1` *and* moved the duration
  > from 30.000 s to 29.000 s. SAR is much the likelier cause (Konjugieren shipped a
  > 30.015 s preview, so the duration cap is evidently not enforced to the millisecond),
  > but the upload did not isolate the variable. **As of 2026-07-26 the target is 30 s
  > again** — see the duration bullet below. Nothing in the accepted-upload evidence
  > argues for 29 s over 30 s; the earlier retreat to 29 was a reaction to an encode
  > that overshot the cap, and pinning the *container* duration addresses that directly.

  Verify with:

  ```bash
  ffprobe -v error -select_streams v:0 \
    -show_entries stream=width,height,sample_aspect_ratio,display_aspect_ratio \
    -of csv=p=0 preview.mp4
  # want: 1200,1600,1:1,3:4   (iPad)   or   886,1920,1:1,443:960   (iPhone)
  ```

- **`-dn` is required.** `-map 0:v:0 -map 0:a:0` alone does *not* drop the data track;
  it survives the mapping and shows up in `ffprobe` as a third stream.
- **`-frames:v 900` is not enough on its own; `-t 30` is what actually caps the file.**
  900 frames ÷ 30 fps = 30.000 s, but `-frames:v` bounds only the *video* stream, and
  `-shortest` does not retroactively trim audio against it. AAC codes 1024 samples per
  frame (~21.3 ms at 48 kHz), so the audio track runs to the next whole frame past 30 s
  and the **container** duration — which is what `ffprobe` and App Store Connect read —
  lands slightly over. That is the mechanism behind the **30.014 s** file that a naive
  re-encode of a 30.000 s master produced, and behind Konjugieren's 30.015 s preview.
  `-t 30` truncates every output stream at 30.000 s and removes the overshoot. Confirm
  the container, not just the video stream:

  ```bash
  ffprobe -v error -show_entries format=duration -of csv=p=0 preview.mp4
  # want: 30.000000 (or under) — not 30.014
  ```

  The raw FCP edit should be **32 s** with the four half-second transitions set in
  Settings ▸ Editing, which lands the export at 30 s before this pass ever runs; see
  [`video_script.md`](video_script.md) for the per-clip budget.
- **Bit rate will land under target** (5.7–7.6 Mbps observed) because flat UI content
  gives x264 little to encode. 10–12 Mbps is Apple's *target*, not a floor.

Then verify before uploading — never by eye:

```bash
scripts/verify_store_media.sh ~/Desktop/ASC-upload
```

## Frame rate provenance

30 fps was confirmed from the Konjugieren timelines' frame duration of `100/3000`
(= 1⁄30 s → 30 fps), stored in each project's `CurrentVersion.fcpevent` SQLite database.
