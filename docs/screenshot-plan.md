The time has come to create Conjuguer's App Store screenshots. Many are required. What follows is Josh's plan for creating those.

There are nine categories of screenshot:

1: VerbBrowseView: show verbs sorted by frequency of use, with être on top; DARK
2: VerbView: show conjugation of avoir; LIGHT
3: ModelBrowseView: show this screen with être on top (the default Irregularity sort ranks the être model at/near the top); DARK
4: ModelView: show être; LIGHT
5: QuizView: show quiz in progress with correct, proposed answer typed; randomness is fine; ensure that virtual keyboard is visible; DARK
6: InfoBrowseView: show screen scrolled so that the "TENSES" section header ("TEMPS" in French) is at top; LIGHT
7: InfoView: show Indicatif Présent screen; DARK
8: QuizResultsView: show quiz results with a score, elapsed time, and per-question review visible; LIGHT
9: SettingsView: show settings screen with QUIZ DIFFICULTY at top; DARK

Create iPhone 6.9" screenshots using iPhone 17 Pro Max simulator. Create iPad 13" screenshots using iPad Pro 13-inch (M4) simulator.

Create all screenshots with the iPhone and iPad running in both English and French modes.

The end product is thirty-six screenshots.

## Before shooting: confirm which slot App Store Connect is offering

Shooting the right pixel size is not sufficient. **App Store Connect's version page shows
exactly one tile per device family, and which display size that tile accepts depends on
what the app shipped last time.** Conjuguer 1.5 shipped 6.5" iPhone screenshots, so the
2.0 page offered only an **iPhone 6.5" Display** tile — and the 6.9" captures produced by
this plan (1320 × 2868) were rejected there on 2026-07-25, despite being a perfectly
valid App Store size.

Check the tile before generating an upload bundle. The drop zone states its accepted
sizes verbatim; read them off the page rather than assuming.

- To upload **6.9"** (1320 × 2868) when the page shows a 6.5" tile, go through
  **View All Sizes in Media Manager**, which exposes every display size.
- To fill the **6.5"** tile instead, downscale (native capture stays the master):

  ```bash
  # 1320 × 2868 → 1284 × 2778 (6.5"), alpha stripped
  magick in.png -background white -alpha remove -alpha off \
    -resize 1284x -gravity center -crop 1284x2778+0+0 +repage out.png
  ```

- The iPad equivalent, if its tile asks for 12.9" rather than 13":

  ```bash
  # 2064 × 2752 → 2048 × 2732 (12.9"), alpha stripped
  magick in.png -background white -alpha remove -alpha off \
    -resize x2732 -gravity center -crop 2048x2732+0+0 +repage out.png
  ```

Both recipes scale on the axis that leaves the target size *inside* the scaled image and
center-crop the remainder — 12 px for the iPhone, 1 px for the iPad — rather than
stretching to fit.

## Alpha channels

`axe screenshot` writes **RGBA**, and Apple rejects any screenshot with an alpha channel:
"Images can't include alpha channels or transparencies." `scripts/take_screenshots.sh`
now flattens each capture immediately, so a fresh sweep is compliant. Bundles predating
2026-07-25 (`version_4` and earlier) are **not** — flatten before uploading, and run
`scripts/verify_store_media.sh` over any bundle before it goes near App Store Connect.