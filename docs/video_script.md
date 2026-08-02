# Script and Playbook for iOS App Store Previews

Ensure that videos are exactly 32 seconds *without* transitions. There are 5 clips, so 4 half-second transitions between them shrink the length by two seconds, to 30. (FCP's default transition duration is 1 second; this assumes it has been set to 0.5 second in Settings ▸ Editing.)

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
Starts out on QuizView. Start. Type answer. Submit. Repeat once.
Label:
Quiz mode: Thirty timed questions to sharpen your conjugation skills.
Mode quiz : trente questions chronométrées pour aiguiser vos talents de conjugaison.

Fifth Clip - seven seconds
Starts out at top of InfoBrowseView. Scroll down so that Indicatif Présent is centered. Tap it. Slowly scroll down.
Label:
From Proto-Indo-European to modern French — the story behind every tense.
Du proto-indo-européen au français moderne — l’histoire de chaque temps.
