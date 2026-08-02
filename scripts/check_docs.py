#!/usr/bin/env python3
"""Assert the checkable claims this repo's documentation makes about itself.

Consumes:  the repo's Markdown files and the four target folders.
Produces:  a report on stdout. Exit 0 if every claim holds, 1 otherwise.
Run:       python3 scripts/check_docs.py

Why this exists
---------------
Two failures on 2026-08-02, both silent, both from documentation drifting away from the tree
it describes.

`KillSwitches.swift` was created by moving two enums out of `Models/ConjuguerTips.swift`.
Eleven references in `docs/screenshot-playbook.md` still named the old path, including the
copy-paste `sed` commands an operator runs before an App Store screenshot sweep. That doc warns,
two paragraphs above those commands, that `sed` exits 0 when its pattern matches nothing — so a
stale path fails exactly the way a renamed switch would: quietly, with the sweep proceeding and
tips still on. Nothing failed. Nothing could have.

`docs/project-structure.md` was ported the same day from Konjugieren, where CLAUDE.md calls it a
cache and asks that it be updated on every add, remove, or rename. Prose asking to be re-read
does not get re-read; Konjugieren learned this when four documents claimed a stale verb count and
one of them shipped the wrong number to the App Store. This does the check instead.

Scope
-----
Only claims a machine can settle, and only ones that are true-or-false regardless of when they
were written. A link either resolves or does not. A file either appears in the index or does not.
Deliberately absent is anything count-shaped: `docs/blog_notes.md` is dated project memory whose
value is preserving what was true then, and `prompts/` archives session prompts whose paths
describe the tree as it was. Checking those would report history as breakage. If a count check is
ever added, scope it by file the way Konjugieren's CACHE_FILES does, not by pattern.
"""

import pathlib
import re
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent

# Directories whose Markdown is not this repo's documentation, or whose contents are build
# products rather than sources. `corpus` holds source texts and extraction output, not prose
# about the app: in Old French verse a bracketed gloss abutting a parenthesis is ordinary
# ("cur[uçus](ius)"), and no amount of parser care distinguishes that from a link.
SKIP_DIRS = {".git", "build", "corpus", "DerivedData", "node_modules", ".build"}

INDEX = "docs/project-structure.md"

# The synchronized target folders plus Shared/, which compiles into both targets. These are the
# trees project-structure.md promises to describe.
SOURCE_ROOTS = ["Conjuguer", "ConjuguerTests", "ConjuguerWidget", "Shared"]

# Bundled data files live alongside the code that parses them and are indexed the same way, so
# they are held to the same completeness standard. Scoped to Models/ because that is where the
# shipped data sits; asset catalogs and sounds are summarized by folder in the index, not listed
# file by file, and enumerating them would demand a precision the index does not claim.
DATA_GLOBS = ["Conjuguer/Models/*.xml", "Conjuguer/Models/*.json"]

# The target stops at whitespace so a Markdown image title survives the parse: the README opens
# with ![Conjuguer](Images/Splash.png "Conjuguer's Launch Screen"), whose target is the path
# alone.
LINK_RE = re.compile(r"\[[^\]]*\]\((\S+?)[)\s]")

# Inline code spans are stripped before links are scanned. Docs that *describe* Markdown quote
# its syntax — prompts/code-review-suggestions-union.md says links render as `[text](url)` — and
# a literal placeholder inside backticks is not a claim that a file named "url" exists.
CODE_SPAN_RE = re.compile(r"`[^`]*`")

# Filenames as they appear in the index's tree. The character class carries the accented letters
# because this repo has French-named sources — ConjuguerTests/Models/NousPrésentStemTests.swift
# would otherwise read as two tokens and go missing.
FILENAME_RE = re.compile(r"[A-Za-z0-9_+.À-ſ]+\.(?:swift|xml|json)")


def markdown_files():
    """Every Markdown file that is this repo's documentation, in a stable order."""
    return sorted(
        p for p in REPO.rglob("*.md")
        if not (SKIP_DIRS & set(p.relative_to(REPO).parts))
    )


def rel(path):
    return path.relative_to(REPO).as_posix()


def check_links():
    """Relative Markdown links resolve.

    Checked in all Markdown, journals included: unlike a count, a link is not true-as-of-a-date.
    Anchors (`#section`) are stripped before the existence test — the target file is what is
    being asserted, and heading text is not stable enough to be worth pinning.
    """
    failures = []
    for path in markdown_files():
        for lineno, line in enumerate(path.read_text().splitlines(), 1):
            for match in LINK_RE.finditer(CODE_SPAN_RE.sub("", line)):
                target = match.group(1).split("#")[0]
                if not target or target.startswith(("http://", "https://", "mailto:")):
                    continue
                if not (path.parent / target).exists():
                    failures.append(f"{rel(path)}:{lineno}: broken link to {target}")
    return failures


def indexed_filenames():
    return set(FILENAME_RE.findall((REPO / INDEX).read_text()))


def source_files():
    paths = [p for root in SOURCE_ROOTS for p in (REPO / root).rglob("*.swift")]
    paths += [p for glob in DATA_GLOBS for p in REPO.glob(glob)]
    return paths


def check_index_covers_sources():
    """Every source file appears in project-structure.md.

    This is the half that catches an *addition* nobody indexed. It is the cheaper failure of the
    two — a session that finds a file missing from the index reads the file — but it is also the
    one that accumulates, because adding a file is routine and updating the index is a separate
    thought.
    """
    missing = sorted(rel(p) for p in source_files() if p.name not in indexed_filenames())
    return [f"{INDEX} does not mention {name}" for name in missing]


def check_index_has_no_phantoms():
    """Every file project-structure.md names still exists.

    This is the half that catches a *rename* or a *deletion*, and it is the one worth having.
    A missing entry is a gap a reader notices; a phantom entry is a confident claim that a file
    lives somewhere it does not, and it gets believed rather than checked. It is also the exact
    shape of the failure that motivated this script: `Models/ConjuguerTips.swift` outlived the
    switches it once held, in eleven places, without anything noticing.
    """
    on_disk = {p.name for p in source_files()}
    phantoms = sorted(indexed_filenames() - on_disk)
    return [f"{INDEX} names {name}, which does not exist" for name in phantoms]


CHECKS = [
    ("relative links", check_links),
    ("project-structure.md covers every source file", check_index_covers_sources),
    ("project-structure.md names no missing file", check_index_has_no_phantoms),
]


def main():
    total = 0
    for label, check in CHECKS:
        failures = check()
        total += len(failures)
        status = "FAIL" if failures else "ok"
        print(f"[{status}] {label}" + (f" ({len(failures)})" if failures else ""))
        for failure in failures:
            print(f"       {failure}")
    print()
    print(f"{total} problem{'' if total == 1 else 's'}")
    return 1 if total else 0


if __name__ == "__main__":
    sys.exit(main())
