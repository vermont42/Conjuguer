# App Store Preview Videos (Final Cut Pro)

How to set up and record the four App Store preview videos for a Conjuguer
release: **English iPhone, French iPhone, English iPad, French iPad**.

This mirrors the workflow used for the sibling app Konjugieren, whose Final Cut Pro
(FCP) library lives at `~/videos/Konjugieren.fcpbundle`. The settings below were
read directly off that library's projects.

## FCP terminology refresher (3-level hierarchy)

```
Library  (.fcpbundle file)        ← e.g. "Conjuguer"     (top-level document)
 └─ Event  (dated container)      ← e.g. "6-26-26"       (holds media + projects)
     └─ Project  (a timeline)     ← one per video        (what you export)
```

- **Library** — the whole document. One per app.
- **Event** — a folder inside the library holding your media clips *and* projects.
  Name it with the date (matches the Konjugieren convention, e.g. `2-8-26`).
- **Smart Collections** — auto-created by FCP; ignore.
- **Project** — an editable timeline that exports to a video file. You create one per
  video.

## Projects to create

In the dated Event, create four Projects (**File ▸ New ▸ Project**, or ⌘N → click
**Custom Settings**, set **Video → Format: Custom**, enter the resolution, set
**Rate: 30**):

| Project          | Format | Resolution    | Rate |
|------------------|--------|---------------|------|
| **English iPhone** | Custom | **1320 × 2868** | **30p** |
| **French iPhone**  | Custom | **1320 × 2868** | **30p** |
| **English iPad**   | Custom | **2048 × 2732** | **30p** |
| **French iPad**    | Custom | **2048 × 2732** | **30p** |

These are Apple's standard App Store app-preview sizes:

- **1320 × 2868** = iPhone **6.9″** display (the current primary iPhone slot).
- **2048 × 2732** = iPad **12.9″** Pro display (accepted for the 13″ slot).

> Note: Konjugieren's iPhone projects used **886 × 1920** (the legacy 6.5″ size, still
> accepted). Conjuguer switches to **1320 × 2868** (6.9″) because it's the current
> primary size *and* it has an exact-pixel simulator match (see below), so there's no
> rescaling.

## Simulators to record from

| Project size                 | Simulator                       | Native resolution | vs. project |
|------------------------------|---------------------------------|-------------------|-------------|
| 1320 × 2868 (iPhone 6.9″)    | **`iPhone 17 Pro Max`** (iOS 26) | 1320 × 2868       | exact match ✅ |
| 2048 × 2732 (iPad 12.9″)     | **`iPad Pro 13-inch (M5)`** (iOS 26) | 2064 × 2752   | ~0.78% downscale (see below) |

The iPhone records at exactly the project resolution — no reframing.

### Why the iPad uses the 13″ M5, not the 12.9″ 6th gen

The exact-pixel iPad would be the **iPad Pro (12.9-inch) (6th generation)** (native
2048 × 2732). **It cannot be used:** Conjuguer's deployment target is **iOS 26.0**, but
that device only exists on iOS ≤ 18 runtimes (Apple dropped it from the iOS 26 runtime
in favor of the 13″ M4/M5). An iOS-26 app won't install on it, and `xcodebuild` rejects
the destination outright.

So record on the **iPad Pro 13-inch (M5)** (the only iOS-26 iPad Pro). Its native
2064 × 2752 scales into the 2048 × 2732 project as a **uniform ~0.78% downscale with an
identical 3:4 aspect ratio** — no cropping, no letterboxing, visually imperceptible. The
delivered file is still a valid 2048 × 2732, which App Store Connect accepts. Bonus: both
iPhone and iPad footage then share the same iOS 26 look.

> When you drop the 13″ M5 recording onto the 2048 × 2732 timeline, FCP will offer to
> change project settings to match the clip (2064 × 2752). **Decline** — keep the project
> at 2048 × 2732 so the export is an accepted App Store size; the sub-1% scale is fine.

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

- **iPhone (1320 × 2868):** the recording matches the project exactly — FCP reports
  **"matches project settings"** (no rescale). Nothing to do.
- **iPad (2064 × 2752 → 2048 × 2732):** FCP will offer to *change project settings to
  fit the clip*. **Decline** — keep the project at 2048 × 2732 (an accepted App Store
  size); the uniform ~0.78% downscale is imperceptible.

## Frame rate provenance

30 fps was confirmed from the Konjugieren timelines' frame duration of `100/3000`
(= 1⁄30 s → 30 fps), stored in each project's `CurrentVersion.fcpevent` SQLite database.
