# Script and Playbook for iOS App Store Previews

Ensure that videos are exactly 32 seconds *without* transitions. There are 5 clips, so 4 half-second transitions between them shrink the length by two seconds, to 30. (FCP's default transition duration is 1 second; this assumes it has been set to 0.5 second in Settings ▸ Editing.)

**Target 30.000 s exactly.** 30 s is the App Store's hard *maximum* and it is inclusive — a
file measuring 30.000000 s is accepted. Every second of a preview is precious, so spend all
thirty. What is *not* accepted is 30.015 s, which is what a careless delivery pass produces
from a perfectly good 30.000 s master: see **The 30.015 s trap** below.

## App Store preview specifications

Sizes, which are **not** the screenshot sizes — conflating the two got all four of
Conjuguer's 2.0 previews rejected with *"The app preview dimensions should be:
886 × 1920px or 1920 × 886px"*:

| Device | Preview size | Notes |
|---|---|---|
| iPhone | **886 × 1920** | One file serves *every* current iPhone class (6.9″, 6.5″, 6.3″, 6.1″). |
| iPad | **1200 × 1600** | Covers 13″, 12.9″, 11″, 10.5″. |

Record at native simulator resolution and let the Final Cut project scale down; the project resolution is what gets
delivered.

Verify before uploading:

```bash
scripts/verify_store_media.sh ~/Desktop/Final/Conjuguer
```

## Delivering the files

Compressor's export already conforms on everything App Store Connect enforces — 886 × 1920
/ 1200 × 1600, SAR 1:1, H.264 High ≤ L4.0, 30 fps, an AAC track, and exactly 30.000 s. The
delivery pass is cleanup for two cosmetic advisories: Final Cut writes a stray timecode
track (3 streams instead of 2), and Compressor's AAC lands near 128 kbps against the
256 kbps spec. Both shipped fine on Konjugieren 1.2, so this is polish, not a blocker.

```bash
cd ~/Desktop/Final/Conjuguer && mkdir -p upload
for f in *.mov; do
  ffmpeg -v error -y -i "$f" \
    -map 0:v:0 -map 0:a:0 \
    -c:v copy -c:a aac -b:a 256k -ar 48000 -ac 2 \
    -dn -sn -shortest -map_metadata -1 -movflags +faststart \
    "upload/$f"
done
```

The video is **stream-copied**, so the H.264 bitstream stays bit-identical to the master —
no generational loss, and no risk of disturbing the profile/level. Confirm it with
`ffmpeg -v error -i in.mov -map 0:v:0 -f md5 -` run against both files; the hashes must
match. Only the audio is transcoded. `-map_metadata -1` is not optional: with `-dn` alone,
the mov muxer re-creates a timecode track from the video stream's metadata.

### The 30.015 s trap

The obvious delivery pass is a pure remux — `-c copy` for *both* streams — and it is
**wrong**. It yields **30.015 s**, over the cap, from a master that measures exactly
30.000 s. Every file gains the same silent 15 ms.

Compressor writes a QuickTime **edit list** that trims the audio track back to the last
video frame. The AAC track physically holds 1409 frames — 1409 × 1024 ÷ 48000 = 30.058 s of
samples — and the edit list is the only thing hiding that tail. `ffmpeg -c copy` discards
edit lists, so the full audio track redefines the container duration.

`-t 30` does not rescue it, though `scripts/verify_store_media.sh` claimed it would until
August 2026. Under `-c copy` ffmpeg can only cut on AAC packet boundaries, and 30.000 s is
1406.25 packets — there is no packet to cut on, so the output stays 30.015 s.

**Re-encoding the audio is what fixes it.** `-shortest` stops the AAC encoder when the
900th video frame does, giving 1407 frames and a container duration of exactly
**30.000000**. This also explains the previously unattributed 30.015 s file in the sibling
app Konjugieren's 1.2 delivery: same symptom, same 15 ms, same step.

Always re-probe after any delivery pass — the failure is invisible in the picture:

```bash
ffprobe -v error -show_entries format=duration,nb_streams -of csv=p=0 upload/file.mov
# expect 2,30.000000
```

## Recording the clips

**Nothing about how the simulator is launched or recorded affects App Store Connect.**
Two capture-time facts matter: *which device* you record — that alone fixes the native
pixel size, and therefore the aspect and the Spatial Conform the clip needs — and that the
capture is the device *framebuffer*, not the Mac screen. Everything ASC enforces
(886 × 1920, SAR 1:1, H.264 High ≤ L4.0, ≤ 30 fps, 15–30 s, an AAC track) is imposed in
Final Cut and the export, and the capture satisfies none of it — Simulator's Record Screen writes
H.264 High at **Level 5.0**, variable frame rate, at native 1320 × 2868, with no audio
track. That is fine and expected.

Both recording simulators ship with the current Xcode and are already installed
(iOS 26.3). `docs/app-store-preview-videos.md` has the narrative behind the choices.

| Deliverable | Simulator | Native capture | On the timeline |
|---|---|---|---|
| iPhone — 886 × 1920 | `iPhone 17 Pro Max` | 1320 × 2868 | Spatial Conform **Fill** (crops the 0.24% aspect difference instead of letterboxing) |
| iPad — 1200 × 1600 | `iPad Pro 13-inch (M5)` | 2064 × 2752 | exactly 3:4 — no crop, no letterbox |

### Launch and record

1. `open -a Simulator`, then **File ▸ Open Simulator ▸ iOS 26.3 ▸ iPhone 17 Pro Max**
   (or `xcrun simctl boot 'iPhone 17 Pro Max' && open -a Simulator`).
2. Install the current build by pressing **Run** in Xcode with that simulator selected as
   the destination.
3. Set the language and pin the 9:41 status bar **once per (device, language) pass**, not
   between takes — the status bar is in frame for every second of every clip, and changing
   the system language requires a reboot:
   ```bash
   scripts/prep_screenshot_sim.sh 'iPhone 17 Pro Max' en    # then again with fr
   scripts/prep_screenshot_sim.sh 'iPad Pro 13-inch (M5)' en
   ```
4. Record with **Simulator ▸ File ▸ Record Screen**; stop with **File ▸ Stop Recording**.
   The file lands on the Desktop as `Simulator Screen Recording …`.

Record Screen captures the framebuffer at **native pixel resolution**; the window zoom
(Physical Size / Point Accurate / Pixel Accurate) does not change the output. If a
scripted capture is ever wanted instead, `xcrun simctl io <udid> recordVideo --codec h264
--mask black <file>` produces an equally acceptable master — the choice is convenience,
never conformance. (`--codec h264` is worth passing there because `simctl`'s default is
HEVC, unlike Record Screen's.)

### The one way hand-recording ruins a preview

Do **not** use macOS screen recording (⌘⇧5, or QuickTime ▸ New Screen Recording) aimed at
the Simulator window. That captures the *window* at point size × display scale, with
chrome and rounded window corners baked in — on the order of 860 × 1864 instead of
1320 × 2868 — and no Spatial Conform recovers it without upscaling. Simulator's own
Record Screen is framebuffer-based and immune.

### Check each capture before editing

```bash
ffprobe -v error -select_streams v:0 \
  -show_entries stream=width,height,sample_aspect_ratio -of csv=p=0 \
  ~/Desktop/'Simulator Screen Recording iPhone 17 Pro Max ….mov'   # expect 1320,2868,1:1
```

Dimensions are the one defect the export cannot repair, and wrong dimensions are exactly
what got all four 2.0 previews rejected.

Ensure that language and region are English and United States or French and France. Ensure that hardware keyboard is disconnected. Ensure that values in KillSwitches.swift are `false`.

First Clip - six seconds
Starts out at top of VerbBrowseView. Sort by frequency. Slowly scroll down for five seconds.
Label:
6,320 French verbs — from abaisser to zyeuter, sorted alphabetically or by frequency.
6 320 verbes français — d’abaisser à zyeuter, classés par ordre alphabétique ou par fréquence.

Second Clip - six seconds
"Show Compound Tenses" is selected. Starts out at top of être's VerbView. Slowly scroll down for five seconds.
Label:
Every conjugation of every verb — seventeen tenses at a glance.
Toutes les conjugaisons de chaque verbe — dix-sept temps d’un seul coup d’œil.

Third Clip - six seconds
Starts out on ModelBrowseView. Wait two seconds. Tap avoir. Wait one second. Slowly scroll down for three seconds.
Label:
All 95 French conjugation models.
Les 95 modèles de conjugaison du français.

Fourth Clip - seven seconds
Starts out on QuizView. Start. Type answer. Submit.
Label:
Quiz mode: Thirty timed questions to sharpen your conjugation skills.
Mode quiz : trente questions chronométrées pour aiguiser vos talents de conjugaison.

Fifth Clip - seven seconds
Starts out at top of InfoBrowseView. Scroll down so that Indicatif Présent is centered. Tap it. Slowly scroll down.
Label:
From Proto-Indo-European to modern French — the story behind every tense.
Du proto-indo-européen au français moderne — l’histoire de chaque temps.
