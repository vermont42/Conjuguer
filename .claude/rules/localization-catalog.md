---
paths:
  - "**/*.xcstrings"
  - "Conjuguer/Models/L.swift"
---

# Editing the string catalogs

## Editing Localizable.xcstrings Safely

The Edit tool operates on **rendered text**, not raw JSON. This means the JSON escape sequence `\"` appears as a plain `"` in Edit's view. Consequently, any edit that adds, removes, or changes an ASCII double quote (`"`, U+0022) inside a JSON string value silently produces an unescaped `"` in the raw file, breaking JSON syntax.

**Safe quote types:** Unicode curly quotes (`“` `”` `„`) need no JSON escaping and can be edited freely with the Edit tool. (French body text already uses curly quotes and guillemets `«` `»`, so most prose edits are safe; the hazard is ASCII `"`.)

**The rule:** When an edit to a `.xcstrings` string value involves adding, removing, or changing ASCII `"` (U+0022) characters, use Python via Bash to perform the replacement on the raw file content, not the Edit tool. For example:

```bash
python3 -c "
import pathlib
p = pathlib.Path('Conjuguer/Assets/Localizable.xcstrings')
t = p.read_text()
t = t.replace('old escaped content', 'new escaped content')
p.write_text(t)
"
```

**Validation:** After every `.xcstrings` edit (regardless of tool used), validate JSON integrity before building:

```bash
python3 -c "import json; json.load(open('Conjuguer/Assets/Localizable.xcstrings'))"
```

## Canonical format — do NOT reflexively revert the catalog

`Localizable.xcstrings` is stored in **Xcode's canonical String Catalog format**
(space before colons — `"key" : {` — and expanded empty objects, `{\n\n    }`).
This format is a **stable fixpoint**: Xcode re-serializing it produces byte-identical
output, so it no longer drifts on its own. (It was normalized once in the
`l10n: normalize Localizable.xcstrings to Xcode's canonical format` commit.)

**The build does NOT rewrite the catalog.** `SWIFT_EMIT_LOC_STRINGS = NO`, so
`xcodebuild` never extracts/writes strings — clean *and* incremental builds leave
the file byte-identical (verified by SHA). The recurring ~4,700-line whitespace
"churn" seen in older sessions came from the **Xcode IDE app** (when open)
re-serializing the catalog to canonical format on save/indexing, **not** from
`build_app.sh`. Now that the committed file is already canonical, the IDE has
nothing to reformat.

**Consequence:** do **not** blanket-`git checkout -- Conjuguer/Assets/Localizable.xcstrings`
after a build to "remove churn" (older guidance and sessions did this — it was
treating a symptom and risked discarding real edits). If the working tree shows the
catalog modified, that is a **real change** — inspect the diff (`git diff`) and keep
or discard it deliberately.

**When editing externally (Python):** new keys you insert may not exactly match
Xcode's canonical whitespace. That is harmless — the file stays valid and builds
fine; the only cost is a small one-key formatting delta the IDE may later
canonicalize. Don't hand-fight it. To stay perfectly canonical, emit
`"key" : {` (space before colon) in inserted blocks, or let Xcode re-save once.

## Searching Within Localizable.xcstrings

Each localization value in `Localizable.xcstrings` occupies a single very long JSON line. Grep matches against these lines are truncated to `[Omitted long matching line]`, making Grep results useless for inspecting content. Instead:

1. **To find which key contains a phrase:** Use Grep to get the line number, then use Read with an offset to view that line.
2. **To find and replace text:** Use Python via Bash. Use a unique nearby string as an anchor to target the correct language section (e.g., a French word like `pourrait signifier` to distinguish `fr` from `en`).

## Rich Text Markup in Localizable.xcstrings

Long-form Info text (`dedicationText`, `creditsText`, and the per-tense `Info.*Text`
explanations) uses a custom markup system parsed by `StringExtensions.swift`
(`String.richTextBlocks` / `.bodySegments`) and rendered by `RichTextView.swift`:

| Marker | Purpose | Example |
|--------|---------|---------|
| `` ` `` | Section subheadings (rendered larger, centered, tagged as headers) | `` `Uses` ``, `` `Conjugation` `` |
| `~` | Bold/emphasis | `~indicatif présent~`, `~Conjuguer~` |
| `$...$` | Conjugation color-coding: **uppercase** letters mark irregular characters (rendered red), lowercase are regular | `$aperÇOis$`, `$sUis$` |
| `‡...‡` | Clickable URLs | `‡https://github.com/vermont42/Conjuguer‡` |

(Conjuguer's parser supports only those four markers — there is no emoji-asset or
flag-bullet markup. List bullets are literal `•` / `-` characters in the prose.)

**Subheadings are set off by a blank line on both sides.** A backtick heading runs
`"…end of paragraph.\n\n\`Next Heading\`\n\nFirst line…"` — `\n\n` before *and* after the
delimited heading. The blank lines are for source readability only: `String.richTextBlocks`
trims the newlines around a backtick heading, so the rendered gap comes from `RichTextView`
(its `defaultSpacing` plus the subheading's `.padding(.top)`), not from the blank lines. Both
languages match.
Before inserting a new section into a long-form Info text, scan the existing headings with
`re.finditer(r'\`[^\`]+\`', value)` in Python to confirm the article's spacing, since raw
JSON hides the rendered layout.

## Relocalization Workflow

When the English version of a long text is edited, the French version must be relocalized:

1. **Translate the prose** while maintaining natural French flow
2. **Preserve all markup** (`` ` ``, `~`, `$…$`, `‡…‡`) in equivalent positions
3. **Do NOT localize**:
   - French grammatical terms already in French — they stay French in *both* languages: `~indicatif présent~`, `~subjonctif imparfait~`, `~passé composé~`, etc.
   - French example sentences and the conjugated forms inside `$…$` (e.g. `$aperÇOis$`): keep the French sentence; translate only its English gloss/explanation, not the quotation itself
   - Literary attributions and proper names: `Marcel Proust`, `Du côté de chez Swann`, author/contributor names in `creditsText`, the app name `~Conjuguer~`
   - URLs (`‡…‡`) and license names (e.g. *Creative Commons Attribution-ShareAlike*)
4. **Match heading structure** exactly between languages
