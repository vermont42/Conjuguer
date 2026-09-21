#!/usr/bin/env python3
"""Shared loading and normalization for the Stage 1 verb-pass audits.

Every audit script in this directory (`audit_conjugations.py`, `audit_flags.py`,
`lint_glosses.py`, `check_examples.py`, `build_candidates.py`, `build_verb_pass_shards.py`)
reads the same five inputs, so they live here once:

    Conjuguer/Models/verbs.xml                        the app's verb entries, with ranks
    corpus/working/conjugations.json                  every simple-tense form, from the engine
    corpus/working/wiktionary/wiktionary_en_verbs.json
    corpus/working/wiktionary/wiktionary_fr_verbs.json
    corpus/working/wiktionary/authors.json            + authors_overrides.json merged last

Ranks are recomputed here rather than read from anywhere, because nothing exports them:
`VerbParser.ranked(_:)` groups entries by infinitif, orders by the four raw corpus counts in
the order (hi, hn, hl, hs) with a missing count sorting last, and breaks ties on the entry key
under French collation. This module reproduces that, so a rank printed by an audit is the rank
the app shows.

See prompts/verb-pass-plan.md, Stage 1.
"""
import json
import locale
import pathlib
import re
import unicodedata

REPO = pathlib.Path(__file__).resolve().parents[2]
WORKING = REPO / "corpus" / "working"
WIKT = WORKING / "wiktionary"
OUT_DIR = WORKING / "verb_pass"
VERBS_XML = REPO / "Conjuguer" / "Models" / "verbs.xml"
EXAMPLES_JSON = REPO / "Conjuguer" / "Models" / "literature_examples.json"
EXAMPLES_COPY = REPO / "corpus" / "json" / "literature_examples.json"
CONJUGATIONS = WORKING / "conjugations.json"
ORIGINALS = REPO / "corpus" / "originals"

# The tense keys `testDumpAllConjugations` writes, grouped so audits can talk about families.
SIMPLE_TENSES = [
    "indicatifPrésent", "imparfait", "passéSimple", "futurSimple",
    "conditionnelPrésent", "subjonctifPrésent", "subjonctifImparfait", "impératif",
]
PERSON_NUMBERS = [
    "firstSingular", "secondSingular", "thirdSingular",
    "firstPlural", "secondPlural", "thirdPlural",
]
IMPERATIVE_PERSON_NUMBERS = ["secondSingular", "firstPlural", "secondPlural"]


def tense_keys():
    keys = []
    for tense in SIMPLE_TENSES:
        people = IMPERATIVE_PERSON_NUMBERS if tense == "impératif" else PERSON_NUMBERS
        keys.extend(f"{tense}.{person}" for person in people)
    keys.extend(["participePassé", "participePrésent", "passéComposé.firstSingular"])
    return keys


TENSE_KEYS = tense_keys()


def nfc(text):
    return unicodedata.normalize("NFC", text or "")


_FRENCH_COLLATION = False


def french_key(text):
    """Sort key matching `Util.french` well enough for the rank tie-break."""
    global _FRENCH_COLLATION
    if not _FRENCH_COLLATION:
        for name in ("fr_FR.UTF-8", "fr_FR.utf8", "fr_FR"):
            try:
                locale.setlocale(locale.LC_COLLATE, name)
                _FRENCH_COLLATION = True
                break
            except locale.Error:
                continue
    return locale.strxfrm(text) if _FRENCH_COLLATION else text


VERB_RE = re.compile(r"<verb\s+([^>]*?)/>")
ATTR_RE = re.compile(r'(\w+)="([^"]*)"')


def load_verbs():
    """The app's verb entries in file order, ranked as `VerbParser.ranked(_:)` ranks them.

    Each entry: id, infinitive, extra_letters, gloss, model, auxiliary, is_reflexive,
    defect_group, aspirated_h, the four counts, hits_are_provisional, rank, line.
    `id` is `infinitifWithPossibleExtraLetters`, the key `conjugations.json` uses.
    """
    text = VERBS_XML.read_text(encoding="utf-8")
    entries = []
    for line_number, line in enumerate(text.splitlines(), start=1):
        match = VERB_RE.search(line)
        if not match:
            continue
        attributes = dict(ATTR_RE.findall(match.group(1)))
        infinitive = nfc(attributes["in"])
        extra = nfc(attributes["ex"]) if "ex" in attributes else None
        entries.append({
            # `Verb.id` is `infinitifWithPossibleExtraLetters`, which parenthesizes the extra
            # letters ("haïr (France)"). `VerbParser`'s dictionary key does not ("haïr France");
            # nothing outside the parser sees that spelling, and conjugations.json uses this one.
            "id": f"{infinitive} ({extra})" if extra else infinitive,
            "infinitive": infinitive,
            "extra_letters": extra,
            "gloss": nfc(attributes["tn"]),
            "model": attributes["mo"],
            "auxiliary": "être" if attributes.get("re") == "t" else
                         ("être" if attributes.get("ay") == "e" else "avoir"),
            "auxiliary_attribute": attributes.get("ay"),
            "is_reflexive": attributes.get("re") == "t",
            "defect_group": attributes.get("dg"),
            "aspirated_h": attributes.get("ah") == "t",
            "counts": [_int(attributes.get(key)) for key in ("hi", "hn", "hl", "hs")],
            "hits_are_provisional": attributes.get("hp") == "y",
            "line": line_number,
        })
    _assign_ranks(entries)
    return entries


def _int(value):
    try:
        return int(value)
    except (TypeError, ValueError):
        return None


def _assign_ranks(entries):
    groups = {}
    for entry in entries:
        groups.setdefault(entry["infinitive"], []).append(entry)

    def sort_key(infinitive):
        counts = groups[infinitive][0]["counts"]
        # `ranked(_:)` breaks ties on the GROUPING key, which is the infinitif, not the entry key.
        return ([-(count if count is not None else -1) for count in counts],
                french_key(infinitive))

    for rank, infinitive in enumerate(sorted(groups, key=sort_key), start=1):
        for entry in groups[infinitive]:
            entry["rank"] = rank
    return len(groups)


def load_json(path):
    with open(path, encoding="utf-8") as handle:
        return json.load(handle)


def load_conjugations():
    return load_json(CONJUGATIONS)


def load_english():
    return load_json(WIKT / "wiktionary_en_verbs.json")


def load_french():
    return load_json(WIKT / "wiktionary_fr_verbs.json")


def load_examples():
    return load_json(EXAMPLES_JSON)


def load_authors():
    """Wikidata resolutions with the hand corrections merged last, as Stage 0.3 specifies."""
    authors = load_json(WIKT / "authors.json")
    overrides = load_json(WIKT / "authors_overrides.json")
    for name, record in overrides.items():
        if name.startswith("_"):
            continue
        authors[name] = record
    return authors


PUBLIC_DOMAIN_BEFORE = 1931  # decision 2: the author's death year, not the edition year.


def is_public_domain(author_record):
    year = (author_record or {}).get("death_year")
    return year is not None and year < PUBLIC_DOMAIN_BEFORE


def plain(form):
    """An app form with its irregularity markers dropped: `pEUvent` → `peuvent`."""
    return nfc(form).lower()


def alternates(form):
    """App forms are joined by `/` when the engine offers alternates: `pEUX/pUIs`."""
    return [plain(part) for part in nfc(form).split("/") if part]


def write_json(path, payload):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as out:
        json.dump(payload, out, ensure_ascii=False, indent=1)
    print(f"  wrote {path.relative_to(REPO)} ({path.stat().st_size:,} bytes)")


def write_jsonl(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as out:
        for row in rows:
            out.write(json.dumps(row, ensure_ascii=False) + "\n")
    print(f"  wrote {path.relative_to(REPO)} ({len(rows):,} lines, {path.stat().st_size:,} bytes)")


# --- defect groups -------------------------------------------------------------------------
# `DefectGroup.init` decodes `uo` (uses only) / `du` (doesn't use) into a set of unused tenses.
# Reproduced here over the simple-tense universe the audits compare, so a disagreement on a
# tense the paradigm never uses can be told apart from a disagreement that matters.
DEFECT_GROUPS_XML = REPO / "Conjuguer" / "Models" / "defectGroups.xml"
SHORTHAND_LETTERS = {
    "r": "indicatifPrésent", "x": "passéSimple", "i": "imparfait", "f": "futurSimple",
    "c": "conditionnelPrésent", "b": "subjonctifPrésent", "q": "subjonctifImparfait",
    "h": "impératif",
}
PERSONLESS_SHORTHANDS = {"pp": "participePassé", "rr": "participePrésent", "sf": "radicalFutur"}
SHORT_PERSON_NUMBERS = {
    "1s": "firstSingular", "2s": "secondSingular", "3s": "thirdSingular",
    "1p": "firstPlural", "2p": "secondPlural", "3p": "thirdPlural",
}


def _shorthand_keys(code):
    if code in PERSONLESS_SHORTHANDS:
        return {PERSONLESS_SHORTHANDS[code]}
    if code in SHORT_PERSON_NUMBERS:  # a bare person-number hits every family at that person
        person = SHORT_PERSON_NUMBERS[code]
        return {key for key in TENSE_KEYS if key.endswith("." + person)}
    tense = SHORTHAND_LETTERS.get(code[:1])
    if not tense:
        return set()
    rest = code[1:]
    if rest == "A":
        return {key for key in TENSE_KEYS if key.startswith(tense + ".")}
    person = SHORT_PERSON_NUMBERS.get(rest)
    key = f"{tense}.{person}" if person else None
    return {key} if key in TENSE_KEYS else set()


def load_defect_groups():
    """{group id: (set of unused tense keys, English description)}."""
    text = DEFECT_GROUPS_XML.read_text(encoding="utf-8")
    groups = {}
    for match in re.finditer(r"<defectGroup\s+([^>]*?)/>", text):
        attributes = dict(ATTR_RE.findall(match.group(1)))
        uses_only, doesnt_use = attributes.get("uo"), attributes.get("du")
        if uses_only is None and doesnt_use is None:
            unused = set(TENSE_KEYS)
        elif doesnt_use is not None:
            unused = set()
            for code in doesnt_use.split(","):
                unused |= _shorthand_keys(code)
        else:
            unused = set(TENSE_KEYS)
            for code in uses_only.split(","):
                unused -= _shorthand_keys(code)
        groups[attributes["id"]] = (unused, attributes.get("en", ""))
    return groups
