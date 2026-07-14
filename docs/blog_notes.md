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
