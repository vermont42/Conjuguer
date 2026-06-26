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

## Simulators to record from (exact pixel matches — zero scaling)

| Project size                 | Simulator                                  | Native resolution |
|------------------------------|--------------------------------------------|-------------------|
| 1320 × 2868 (iPhone 6.9″)    | **`iPhone 17 Pro Max`**                    | 1320 × 2868 ✅ |
| 2048 × 2732 (iPad 12.9″)     | **`iPad Pro (12.9-inch) (6th generation)`** | 2048 × 2732 ✅ |

Both record at exactly the project resolution — no aspect-ratio reframing.

> Avoid the newer **iPad Pro 13-inch (M4/M5)** sims here: they're 2064 × 2752, which
> would rescale into the 2048 × 2732 project. Use the **12.9″ 6th generation**.

### Recording

- Record with `xcrun simctl io <udid> recordVideo <out.mov>` (or Simulator ▸ File ▸
  Record Screen). That captures at **native pixel resolution** even though the
  Simulator *window* may be displayed scaled down.
- To get the simulator UDIDs:
  ```bash
  xcrun simctl list devices available | grep -iE 'iPhone 17 Pro Max|iPad Pro \(12.9-inch\) \(6th'
  ```
- Build/install the current app before recording (the project's build skill):
  ```bash
  export IBV_SCRIPTS=$(dirname "$(find ~/.claude -path '*ios-build-verify*' -name build_app.sh 2>/dev/null | head -1)")
  "$IBV_SCRIPTS/build_app.sh"
  ```

### Placing clips on the timeline

When you drop a recording onto its timeline, FCP should report **"matches project
settings"** (no rescale). If it instead offers to *change project settings to fit the
clip*, **decline** — the project resolution is already correct.

## Frame rate provenance

30 fps was confirmed from the Konjugieren timelines' frame duration of `100/3000`
(= 1⁄30 s → 30 fps), stored in each project's `CurrentVersion.fcpevent` SQLite database.
