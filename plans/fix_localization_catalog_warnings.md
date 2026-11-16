# Task: two String Catalog fixes for Conjuguer and Konjugieren

This prompt covers **two independent fixes** to the localization catalogs of both
apps. They touch the same files but different fields, so do them as separate logical
commits. You can do Part 1, Part 2, or both — they don't depend on each other.

- **Part 1** — replace the `%` rich-text link delimiter (fixes the red
  *"format specifiers do not match"* warnings).
- **Part 2** — clear the `extractionState: "stale"` keys (fixes the yellow
  *"References to this key could not be found in source code"* warnings).

## Locations (both parts)

- Conjuguer: `~/Desktop/workspace/Conjuguer`
  - Parser: `Conjuguer/Utils/StringExtensions.swift`
  - Catalog: `Conjuguer/Assets/Localizable.xcstrings` (langs: `en`, `fr`)
  - Build/verify: the `ios-build-verify` skill (`build_app.sh`, `run_tests.sh`,
    `launch_app.sh`, `screenshot.sh`).
- Konjugieren: `~/Desktop/workspace/Konjugieren`
  - Parser: `Konjugieren/Utils/StringExtensions.swift`
  - Catalog: `Konjugieren/Assets/Localizable.xcstrings` (langs: `de`, `en`)
  - Builds/runs the same way (it has an equivalent skill/config).

The app catalogs are the only ones affected. (Conjuguer also ships
`ConjuguerWidget/Localizable.xcstrings`, but it is already hand-authored with explicit
`Widget.*` keys and `extractionState: "manual"` — leave it alone.)

Keep the formatting reviewable: Xcode writes `.xcstrings` with **keys sorted
alphabetically, 2-space indent, `ensure_ascii=False`** (accented chars kept literal),
and a trailing newline. When editing programmatically, use
`json.dump(d, f, ensure_ascii=False, indent=2, sort_keys=True)` + trailing newline,
then open the catalog in Xcode once and commit whatever it re-normalizes to.

---

# Part 1 — replace the `%` link delimiter

## Why

Both apps render rich text in their Info/credits/etymology screens using a tiny custom
markup language whose delimiters are defined in `Utils/StringExtensions.swift`:

| Separator | Char | Role |
|---|---|---|
| `subheadingSeparator` | `` ` `` | subheading |
| `boldSeparator` | `~` | bold |
| **`linkSeparator`** | **`%`** | **link** (`%text%`, or `%https://…%`) |
| `conjugationSeparator` | `$` | inline conjugation |
| `emojiSeparator` (Konjugieren only) | `^` | emoji |

A link is authored as a matched pair `%…%`; the content is either a URL (starts with
`http`) or text that gets percent-encoded into a URL (see `String.linkSegment(for:)`).

`%` collides with printf/`String(format:)` conversion specifiers, so Xcode's String
Catalog editor misreads every `%word` as a format specifier (`%https…`→`%h`,
`%défectif…`→`%d`). When a key's two localizations wrap different words/URLs, the
inferred specifier lists differ and Xcode shows a red **"The format specifies … do not
match …"** warning.

Current state (verified):
- **Conjuguer** (`en`/`fr`): 35 strings use `%` link markup; **2** mismatch and warn —
  `Info.passéSimpleText` and `Info.subjonctifImparfaitText`.
- **Konjugieren** (`de`/`en`): 7 strings use `%` link markup; **0** mismatch today, but
  the landmine is latent and will fire as Info content grows.

## Chosen delimiter

Use **`‡`** (U+2021, DOUBLE DAGGER). Verified absent from both catalogs and from the
other markup separators; never appears in URLs or French/German prose, so no content
collision. (If you prefer another char, it must be absent from both catalogs and all
link content — do NOT use `§` (present in the Konjugieren catalog), and avoid anything
printf-special.)

## The gotcha that makes this non-trivial

You **cannot** do a naïve `s/%/‡/g`, because (1) genuine format specifiers (`%@`,
`%lld`, `%%`, `%1$@`) must be preserved, and (2) a link word's first letter can look
like a conversion (`%défectif%` ↔ `%d`), so you can't classify a lone `%` by the char
after it.

What makes it safe: **the link `%` markup and the genuine format specifiers live in
disjoint strings.** Verified — no link-bearing (prose) string in either catalog
contains `%@`, `%lld`, `%ld`, `%%`, or `%n$@`; those only appear in short count/plural
format strings that contain no link markup. So the safe rule is per-string:

> For each `stringUnit.value`: if it contains an unambiguous format token (`%@`,
> `%lld`, `%ld`, `%%`, or `%<digits>$`), leave it untouched. Otherwise replace every
> `%` in it with `‡`.

Re-verify this disjointness per app before trusting the rule; if any string ever
contains both, handle it by hand.

## Steps (per app, its own commit — do NOT bundle the two apps)

1. Change `linkSeparator` to `"‡"` in that app's `StringExtensions.swift`.
2. Transform the catalog programmatically: walk every
   `strings[key].localizations[lang].stringUnit.value` (and any plural/`variations`
   sub-units), apply the per-string rule, write back. Print how many strings changed and
   total `%`→`‡` replacements (expect ~35 strings for Conjuguer, ~7 for Konjugieren).
3. Grep each app for `%` used as markup anywhere else (none expected; genuine
   `String(format:)`/printf `%` in code stays).
4. Verify: build, run tests, launch, and screenshot **Info → Credits** (many links) and
   a tense Info page that had a link (e.g. passé simple); confirm links render styled
   and are tappable. Then re-run a per-key specifier-mismatch scan over the catalog and
   confirm **0** mismatched keys (was 2 in Conjuguer).
5. Commit, e.g. `i18n: switch rich-text link delimiter from % to ‡ to stop format-specifier warnings`.

---

# Part 2 — clear the stale `extractionState` keys

## Why

Both catalogs show a swarm of yellow **"References to this key could not be found in
source code"** warnings: keys marked `extractionState: "stale"` (Conjuguer ~150 of 167;
Konjugieren ~95 of 359).

The keys are **not dead** — every one is referenced, but *indirectly* through an `L`
enum wrapper, e.g.:

```swift
enum L {
  enum BrowseView {
    static var sortOrder: String { String(localized: "BrowseView.sortOrder") }
  }
}
```

Both targets already build with `SWIFT_EMIT_LOC_STRINGS = YES`, but Xcode's extractor
doesn't reconcile keys reached through the wrapper's computed properties, so it leaves
them `"stale"`. A clean build does not clear them.

## The fix

For each key currently `extractionState: "stale"` **that is referenced in source**,
change its `extractionState` to `"manual"`. `"manual"` means "I manage this string by
hand; don't match it against source," which is the truth for wrapper-accessed keys, and
it silences the warning. This is the same state Conjuguer's widget catalog already uses.

**Tradeoff to call out in the commit message:** `"manual"` keys lose Xcode's automatic
*dead-key* detection — if a usage is later removed, Xcode won't flag the orphan. That's
the accepted cost of the `L`-wrapper pattern. (The only alternative is to stop using
`L` and call `String(localized:)` at every site — a large refactor that defeats the
wrapper's purpose; do NOT do that.)

## Steps (per app, its own commit)

1. Enumerate the stale keys from the catalog JSON.
2. For each, grep the app's Swift sources (exclude the `.xcstrings` itself) for the
   key literal, e.g. `rg -F '"BrowseView.sortOrder"' <App>/` (ripgrep handles the
   accented keys like `Info.passéSimpleText`). Classify:
   - **Referenced** → set `extractionState` to `"manual"`.
   - **Not referenced anywhere** → do NOT auto-delete. List these for review and report
     them; the project keys are static literals so an unreferenced one is almost
     certainly dead, but confirm it isn't built dynamically before deleting in a
     follow-up. (Expectation from spot checks: essentially all stale keys are
     referenced.)
3. Write the catalog back (same formatting discipline as above).
4. Verify: build + run tests (no behavior change expected). Re-open the catalog in Xcode
   and confirm the yellow warnings are gone. Programmatic check: confirm no
   `"extractionState": "stale"` entries remain.
5. Commit, e.g. `i18n: mark wrapper-referenced catalog keys manual to clear stale warnings`.

## Order / interaction with Part 1

Independent. If you do both in one session, do Part 1 first (it edits
`stringUnit.value`) then Part 2 (it edits `extractionState`) so the diffs stay distinct,
and keep them as separate commits per app (up to 4 commits total).

---

End every commit message with the standard Claude Code co-author signature.
