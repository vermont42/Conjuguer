#!/usr/bin/env python3
"""Build the per-verb Wiktionary reference files the verb pass audits against.

Downloads the two kaikki.org machine-readable Wiktionary extracts (English-edition French
entries, and the French-edition extract), streams each once, keeps only verb entries whose
NFC headword is one of the app's infinitives, and writes three files under
`corpus/working/wiktionary/`:

    wiktionary_en_verbs.json   { "<infinitive>": [entry, ...] }  senses/forms/etymology/IPA
    wiktionary_fr_verbs.json   { "<infinitive>": [entry, ...] }  senses with EVERY example
    meta.json                  URLs, Last-Modified, dump dates, coverage counts, gaps

The raw dumps land in `corpus/working/wiktionary/raw/` (gitignored, re-fetchable). A download
is skipped when the file is already present at exactly the byte count the server's
Content-Length reports, so re-running costs two HEAD requests.

Both extracts are CC BY-SA; see docs/wiktionary-quotation-sources.md for what the app uses
them for.

Usage:  python3 corpus/working/build_wiktionary_reference.py [--force-download]
"""
import argparse
import gzip
import json
import pathlib
import re
import sys
import unicodedata
import urllib.request

USER_AGENT = "Conjuguer-verb-pass/1.0 (https://github.com/vermont42/Conjuguer; vermontcoder@gmail.com)"

REPO = pathlib.Path(__file__).resolve().parents[2]
VERBS_XML = REPO / "Conjuguer" / "Models" / "verbs.xml"
OUT_DIR = REPO / "corpus" / "working" / "wiktionary"
RAW_DIR = OUT_DIR / "raw"

EN_URL = "https://kaikki.org/dictionary/French/kaikki.org-dictionary-French.jsonl"
EN_INDEX = "https://kaikki.org/dictionary/French/index.html"
# kaikki marks the per-language English-edition file deprecated. If it disappears, fall back to
# https://kaikki.org/dictionary/raw-wiktextract-data.jsonl.gz (2.7 GB) filtered on lang_code == "fr".
FR_URL = "https://kaikki.org/dictionary/downloads/fr/fr-extract.jsonl.gz"
FR_INDEX = "https://kaikki.org/frwiktionary/"


def nfc(string):
    return unicodedata.normalize("NFC", string)


def fetch(url, want_text=False):
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request) as response:
        data = response.read()
    return data.decode("utf-8", "replace") if want_text else data


def head(url):
    request = urllib.request.Request(url, method="HEAD", headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(request) as response:
        return {
            "content_length": int(response.headers.get("Content-Length", -1)),
            "last_modified": response.headers.get("Last-Modified"),
        }


def download(url, destination, force=False):
    """Fetch url to destination unless it is already there at the server's byte count."""
    info = head(url)
    expected = info["content_length"]
    if destination.exists() and not force:
        actual = destination.stat().st_size
        if actual == expected:
            print(f"  have {destination.name} ({actual:,} bytes, matches Content-Length)")
            return info
        print(f"  {destination.name} is {actual:,} bytes, server says {expected:,} — refetching")
    print(f"  downloading {url} → {destination.name} ({expected:,} bytes)")
    request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    written = 0
    with urllib.request.urlopen(request) as response, open(destination, "wb") as out:
        while chunk := response.read(1 << 20):
            out.write(chunk)
            written += len(chunk)
            print(f"\r    {written:,} / {expected:,}", end="", file=sys.stderr)
    print("", file=sys.stderr)
    return info


def dump_date(index_url):
    """The Wiktionary dump date kaikki states in the page footer, or None."""
    try:
        match = re.search(r"dump dated (\d{4}-\d{2}-\d{2})", fetch(index_url, want_text=True))
    except OSError as error:
        print(f"  could not read {index_url}: {error}")
        return None
    return match.group(1) if match else None


def app_infinitives():
    xml = VERBS_XML.read_text(encoding="utf-8")
    infinitives = [nfc(w) for w in re.findall(r'<verb in="([^"]+)"', xml)]
    return infinitives


def open_lines(path):
    if path.suffix == ".gz":
        return gzip.open(path, "rt", encoding="utf-8")
    return open(path, encoding="utf-8")


def english_entry(entry):
    return {
        "senses": [
            {
                "glosses": sense.get("glosses") or sense.get("raw_glosses") or [],
                "tags": sense.get("tags", []),
                "examples": [
                    {"text": x.get("text"), "english": x.get("english"), "ref": x.get("ref")}
                    for x in sense.get("examples", [])
                ],
            }
            for sense in entry.get("senses", [])
        ],
        "forms": [{"form": f.get("form"), "tags": f.get("tags", [])} for f in entry.get("forms", [])],
        "head_templates": [t.get("expansion") for t in entry.get("head_templates", [])],
        "etymology_text": entry.get("etymology_text"),
        "sounds": [s.get("ipa") for s in entry.get("sounds", []) if s.get("ipa")][:2],
        "categories": [
            c.get("name", "") if isinstance(c, dict) else str(c) for c in entry.get("categories", [])
        ],
    }


def french_entry(entry):
    return {
        "senses": [
            {
                "glosses": sense.get("glosses") or sense.get("raw_glosses") or [],
                "tags": sense.get("tags", []),
                # Every example, not a sample: candidate retrieval wants the choice.
                "examples": [{"text": x.get("text"), "ref": x.get("ref")} for x in sense.get("examples", [])],
            }
            for sense in entry.get("senses", [])
        ],
        "n_forms": len(entry.get("forms", [])),
        "tags": entry.get("tags", []),
        "head_templates": [t.get("expansion") for t in entry.get("head_templates", [])],
        "categories": [
            c.get("name", "") if isinstance(c, dict) else str(c) for c in entry.get("categories", [])
        ],
    }


def stream(path, wanted, prefilters, keep, lang_code=None):
    """One pass over a JSONL dump, substring-prefiltered before json.loads."""
    reference = {}
    lines = 0
    with open_lines(path) as handle:
        for line in handle:
            lines += 1
            if not all(p in line for p in prefilters):
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            if entry.get("pos") != "verb":
                continue
            if lang_code and entry.get("lang_code") != lang_code:
                continue
            word = nfc(entry.get("word", ""))
            if word not in wanted:
                continue
            reference.setdefault(word, []).append(keep(entry))
    return reference, lines


def write_json(path, payload):
    with open(path, "w", encoding="utf-8") as out:
        json.dump(payload, out, ensure_ascii=False, indent=1)
    print(f"  wrote {path.relative_to(REPO)} ({path.stat().st_size:,} bytes)")


def counts(reference, edition):
    """Coverage counts. The two editions carry different fields, so each reports its own."""
    examples = [x for verb in reference for e in reference[verb] for s in e["senses"] for x in s["examples"]]
    measured = {
        "verbs_covered": len(reference),
        "verbs_with_any_example": sum(
            1 for verb in reference
            if any(x.get("text") for e in reference[verb] for s in e["senses"] for x in s["examples"])
        ),
        "examples_with_a_reference": sum(1 for x in examples if x.get("ref")),
        "examples_total": len(examples),
    }
    if edition == "en":
        measured["verbs_with_translated_example"] = sum(
            1 for verb in reference
            if any(x.get("english") for e in reference[verb] for s in e["senses"] for x in s["examples"])
        )
        measured["verbs_with_conjugation_forms"] = sum(
            1 for verb in reference if any(e.get("forms") for e in reference[verb])
        )
    else:
        measured["verbs_with_conjugation_forms"] = sum(
            1 for verb in reference if any(e.get("n_forms") for e in reference[verb])
        )
    return measured


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--force-download", action="store_true", help="refetch both dumps")
    args = parser.parse_args()

    RAW_DIR.mkdir(parents=True, exist_ok=True)
    infinitives = app_infinitives()
    wanted = set(infinitives)
    print(f"app: {len(infinitives)} verb entries, {len(wanted)} distinct infinitives")

    print("English-edition extract:")
    en_raw = RAW_DIR / "kaikki-French.jsonl"
    en_info = download(EN_URL, en_raw, args.force_download)
    en_dump = dump_date(EN_INDEX)
    en_reference, en_lines = stream(
        en_raw, wanted, ['"pos": "verb"'], english_entry
    )
    print(f"  {en_lines:,} lines → {len(en_reference)} verbs covered")

    print("French-edition extract:")
    fr_raw = RAW_DIR / "fr-extract.jsonl.gz"
    fr_info = download(FR_URL, fr_raw, args.force_download)
    fr_dump = dump_date(FR_INDEX)
    fr_reference, fr_lines = stream(
        fr_raw, wanted, ['"verb"', '"fr"'], french_entry, lang_code="fr"
    )
    print(f"  {fr_lines:,} lines → {len(fr_reference)} verbs covered")

    write_json(OUT_DIR / "wiktionary_en_verbs.json", en_reference)
    write_json(OUT_DIR / "wiktionary_fr_verbs.json", fr_reference)

    missing_en = sorted(wanted - set(en_reference))
    missing_fr = sorted(wanted - set(fr_reference))
    missing_both = sorted(set(missing_en) & set(missing_fr))
    meta = {
        "generated_by": "corpus/working/build_wiktionary_reference.py",
        "license": "Wiktionary content is CC BY-SA 4.0; kaikki.org extracts carry it forward.",
        "app_verbs": {"entries": len(infinitives), "distinct_infinitives": len(wanted)},
        "english_edition": {
            "url": EN_URL,
            "bytes": en_info["content_length"],
            "last_modified": en_info["last_modified"],
            "wiktionary_dump_dated": en_dump,
            "jsonl_lines": en_lines,
            **counts(en_reference, "en"),
        },
        "french_edition": {
            "url": FR_URL,
            "bytes": fr_info["content_length"],
            "last_modified": fr_info["last_modified"],
            "wiktionary_dump_dated": fr_dump,
            "jsonl_lines": fr_lines,
            **counts(fr_reference, "fr"),
        },
        "gaps": {
            "missing_from_english": missing_en,
            "missing_from_french": missing_fr,
            "missing_from_both": missing_both,
            "note": (
                "A verb missing here is absent from the extract itself, not dropped by the filter: "
                "enfoncer has a live Wiktionnaire page but no fr-extract entry (checked against the "
                "raw dump, 2026-09-20). Verbs in missing_from_both have no machine-readable "
                "reference at all and must be judged from knowledge."
            ),
        },
    }
    write_json(OUT_DIR / "meta.json", meta)
    print(f"coverage: en {len(en_reference)}, fr {len(fr_reference)}, "
          f"no reference at all: {len(missing_both)} {missing_both}")


if __name__ == "__main__":
    main()
