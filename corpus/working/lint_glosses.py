#!/usr/bin/env python3
"""Stage 1.3 — lint the app's English glosses, and classify where each one came from.

Two outputs in one file, `corpus/working/verb_pass/gloss_lint.json`:

    { "<verb id>": { "gloss": "...", "rank": n,
                     "lint": [ { rule, detail } ],
                     "gloss_provenance": { class, first_sense_is_en_first, only_tagged_senses } } }

The lint rules follow decision 3's house style: bare infinitive, commonest sense first, American
spelling, the curly apostrophe, parentheses only for register or region, a plain phrase over an
obscure single word, and short enough to read aloud. They flag; they do not decide. A
descriptive gloss was often Josh's deliberate choice (*accoutrer* is "equip, furnish with
dress" rather than "accouter"), so `definition_like` is a list to consider, never a defect.

Provenance matters because it changes what the pass should judge: a gloss copied verbatim from
English Wiktionary is judged on sense SELECTION and ORDER, one that matches no English sense is
judged on FAITHFULNESS to the French definition it was translated from.

Usage:  python3 corpus/working/lint_glosses.py
"""
import collections
import pathlib
import re

import verb_pass_lib as L

DICT_DIR = pathlib.Path("/usr/share/dict")
WHITELIST = L.WORKING / "gloss_lint_whitelist.txt"
DEFINITION_WORDS = ("someone's", "something's", "oneself", "someone’s", "something’s")
DEFINITION_WORD_COUNT = 6
TAGGED_AS_MARGINAL = {"dialectal", "dated", "rare", "slang", "obsolete", "archaic"}
STOPWORDS = {
    "a", "an", "and", "as", "at", "be", "by", "for", "from", "in", "into", "of", "off", "on",
    "onto", "or", "out", "over", "the", "to", "up", "with", "make", "made", "become", "get",
    "someone", "something", "oneself", "one", "s", "cause", "put", "take", "give",
}
WORD = re.compile(r"[A-Za-zÀ-ÿ’'-]+")
BRITISH_FIXED = {
    "judgement": "judgment", "practise": "practice", "fulfil": "fulfill",
    "defence": "defense", "offence": "offense", "licence": "license",
    "programme": "program", "moulder": "molder", "smoulder": "smolder", "mould": "mold",
    "storey": "story", "tyre": "tire", "plough": "plow", "draught": "draft",
    "grey": "gray", "aluminium": "aluminum", "sulphur": "sulfur", "manoeuvre": "maneuver",
    "jewellery": "jewelry", "cosy": "cozy", "kerb": "curb", "pyjamas": "pajamas",
}
# -our and -re are not productive rules: "four" is not "for" and "shore" is not "shoer". The
# British forms that actually occur in glosses are a closed set, so list them.
BRITISH_FIXED.update({word: word[:-3] + "or" for word in (
    "colour", "favour", "behaviour", "honour", "labour", "neighbour", "odour", "rumour",
    "savour", "vapour", "harbour", "armour", "humour", "splendour", "valour", "endeavour",
    "flavour", "parlour", "ardour", "candour", "clamour", "glamour", "rigour", "tumour",
    "vigour", "saviour", "succour", "arbour", "demeanour",
)})
BRITISH_FIXED.update({word: word[:-2] + "er" for word in (
    "centre", "metre", "litre", "fibre", "theatre", "calibre", "sombre", "spectre", "lustre",
    "manoeuvre", "sceptre", "meagre", "ochre", "sabre", "goitre", "louvre", "mitre", "nitre",
    "philtre", "saltpetre", "titre", "reconnoitre", "sepulchre",
)})


def load_dictionary():
    words = set()
    for name in ("web2", "web2a", "propernames"):
        path = DICT_DIR / name
        if path.exists():
            words |= {line.strip().lower() for line in path.open(encoding="utf-8", errors="replace")}
    if WHITELIST.exists():
        words |= {line.strip().lower() for line in WHITELIST.open(encoding="utf-8")
                  if line.strip() and not line.startswith("#")}
    return words


# The 1934 Webster's behind /usr/share/dict/words carries lemmas only, so a plural or a gerund
# reads as an unknown word. Back off through the regular inflections before reporting one.
BACK_OFF = [("ies", "y"), ("es", ""), ("s", ""), ("ing", ""), ("ing", "e"), ("ed", ""), ("ed", "e"),
            ("d", ""), ("ning", "n"), ("ping", "p"), ("ting", "t"), ("ging", "g"), ("ming", "m"),
            ("ned", "n"), ("pped", "p"), ("tted", "t"), ("lly", "l"), ("ly", ""), ("er", ""),
            ("er", "e"), ("ier", "y"), ("est", ""), ("iest", "y")]


def known_word(token, words):
    if token in words:
        return True
    return any(token.endswith(suffix) and (token[:-len(suffix)] + replacement) in words
               for suffix, replacement in BACK_OFF)


def normalize_sense(text):
    text = L.nfc(text).strip().lower().replace("’", "'")
    text = re.sub(r"^to\s+", "", text)
    return re.sub(r"\s+", " ", text).strip(" .;")


def split_outside_parentheses(text, separators=(",",)):
    parts, depth, current = [], 0, ""
    for character in text:
        if character == "(":
            depth += 1
        elif character == ")":
            depth = max(0, depth - 1)
        if character in separators and depth == 0:
            parts.append(current)
            current = ""
        else:
            current += character
    parts.append(current)
    return [part.strip() for part in parts if part.strip()]


def english_sense_parts(sense):
    """A sense's gloss, plus its semicolon-, comma- and "or"-separated pieces.

    Commas are split OUTSIDE parentheses only, so "to water (cattle, fields etc.), give water
    to (a person)" yields "water (cattle, fields etc.)" rather than three fragments of it.
    """
    gloss = (sense.get("glosses") or [""])[0]
    parts = {normalize_sense(gloss)}
    for clause in gloss.split(";"):
        for piece in split_outside_parentheses(clause):
            parts.add(normalize_sense(piece))
            for alternative in piece.split(" or "):
                parts.add(normalize_sense(alternative))
    return {part for part in parts if part}


def is_verbatim(sense, parts):
    """True when a gloss sense copies an English one, allowing English's trailing object.

    English Wiktionary writes "to corner someone", "to roll along a surface", "to cut down (a
    tree)"; a gloss that copies the sense drops the object. A leading-word-boundary prefix match
    therefore counts as verbatim, which is what "copies its senses verbatim" meant when the
    4,581 / 463 / 516 split was measured.
    """
    return any(part == sense or part.startswith(sense + " ") for part in parts)


def content_words(text):
    return {word.lower().strip("'’-") for word in WORD.findall(text)} - STOPWORDS


def provenance(gloss, english_entries, french_entries):
    if not english_entries:
        return {
            "class": "no_en_entry" if french_entries else "none",
            "first_sense_is_en_first": None,
            "only_tagged_senses": None,
        }
    senses = [sense for entry in english_entries for sense in entry.get("senses", [])]
    per_sense = [english_sense_parts(sense) for sense in senses]
    every_part = set().union(*per_sense) if per_sense else set()

    gloss_senses = [normalize_sense(part) for part in split_outside_parentheses(gloss)]
    gloss_senses = [sense for sense in gloss_senses if sense]
    verbatim = [is_verbatim(sense, every_part) for sense in gloss_senses]
    if all(verbatim) and verbatim:
        klass = "all_verbatim"
    elif any(verbatim):
        klass = "some_verbatim"
    else:
        klass = "none_verbatim"

    first_is_first = (bool(gloss_senses) and bool(per_sense)
                      and is_verbatim(gloss_senses[0], per_sense[0]))
    matched = [index for index, parts in enumerate(per_sense)
               if any(is_verbatim(sense, parts) for sense in gloss_senses)]
    tags = [set(senses[index].get("tags") or []) for index in matched]
    plain_exists = any(not (set(sense.get("tags") or []) & TAGGED_AS_MARGINAL) for sense in senses)
    only_tagged = bool(tags) and all(tag & TAGGED_AS_MARGINAL for tag in tags) and plain_exists
    return {
        "class": klass,
        "first_sense_is_en_first": first_is_first,
        "only_tagged_senses": only_tagged,
    }


def lint(entry, english_entries, words, shared_glosses, english):
    gloss = entry["gloss"]
    hits = []
    senses = [normalize_sense(part) for part in split_outside_parentheses(gloss)]
    duplicates = [sense for sense, count in collections.Counter(senses).items() if count > 1]
    if duplicates:
        hits.append({"rule": "duplicate_sense", "detail": "; ".join(duplicates)})
    if "'" in gloss:
        hits.append({"rule": "straight_apostrophe", "detail": gloss})
    if ";" in gloss:
        hits.append({"rule": "semicolon", "detail": gloss})
    if re.match(r"^to\s+", gloss, re.IGNORECASE):
        hits.append({"rule": "leading_to", "detail": gloss})

    for token in WORD.findall(gloss):
        low = token.lower().strip("'’-")
        low = re.sub(r"[’']s$", "", low)  # a possessive is the noun, not an unknown word
        if not low:
            continue
        if low in BRITISH_FIXED:
            hits.append({"rule": "british_spelling", "detail": f"{low} → {BRITISH_FIXED[low]}"})
        elif low.endswith(("ise", "ises", "ising", "ised", "isation", "isations")):
            american = low.replace("ise", "ize", 1)
            # Only when the -ize form exists and the -ise one is not itself standard English
            # ("promise", "advertise", "exercise" end in -ise and are not British spellings).
            if american in words and low not in words:
                hits.append({"rule": "british_spelling", "detail": f"{low} → {american}"})
        elif not known_word(low, words):
            hits.append({"rule": "unknown_word", "detail": low})

    if english_entries:
        english_words = set()
        for english_entry in english_entries:
            for sense in english_entry.get("senses", []):
                english_words |= content_words((sense.get("glosses") or [""])[0])
        if english_words and not (content_words(gloss) & english_words):
            hits.append({"rule": "no_overlap",
                         "detail": "shares no content word with any English-Wiktionary sense"})

    twins = shared_glosses.get(gloss.lower(), [])
    others = [other for other in twins if other != entry["id"]]
    if others:
        mine = {part for english_entry in english_entries or []
                for sense in english_entry.get("senses", [])
                for part in english_sense_parts(sense)}
        for other in others:
            other_infinitive = other.split(" (")[0]
            theirs = {part for english_entry in english.get(other_infinitive, [])
                      for sense in english_entry.get("senses", [])
                      for part in english_sense_parts(sense)}
            if mine and theirs and not (mine & theirs):
                hits.append({"rule": "duplicate_gloss",
                             "detail": f"same gloss as {other}, which shares no English sense"})

    words_in_gloss = len(WORD.findall(gloss))
    reasons = []
    if words_in_gloss >= DEFINITION_WORD_COUNT:
        reasons.append(f"{words_in_gloss} words")
    if any(marker in gloss.lower() for marker in DEFINITION_WORDS):
        reasons.append("definition phrasing")
    if reasons:
        hits.append({"rule": "definition_like", "detail": ", ".join(reasons)})
    return hits


def main():
    verbs = L.load_verbs()
    english = L.load_english()
    french = L.load_french()
    words = load_dictionary()
    print(f"  dictionary: {len(words):,} words"
          + (f" (+{sum(1 for _ in WHITELIST.open()) if WHITELIST.exists() else 0} whitelisted)"))

    shared_glosses = collections.defaultdict(list)
    for entry in verbs:
        shared_glosses[entry["gloss"].lower()].append(entry["id"])

    report = {}
    classes = collections.Counter()
    rules = collections.Counter()
    for entry in verbs:
        english_entries = english.get(entry["infinitive"])
        french_entries = french.get(entry["infinitive"])
        record = provenance(entry["gloss"], english_entries, french_entries)
        classes[record["class"]] += 1
        hits = lint(entry, english_entries, words, shared_glosses, english)
        for hit in hits:
            rules[hit["rule"]] += 1
        report[entry["id"]] = {
            "gloss": entry["gloss"],
            "rank": entry["rank"],
            "lint": hits,
            "gloss_provenance": record,
        }

    L.write_json(L.OUT_DIR / "gloss_lint.json", report)
    flagged = sum(1 for record in report.values() if record["lint"])
    print(f"  {flagged:,} of {len(verbs):,} glosses carry at least one lint hit")
    for rule, count in rules.most_common():
        print(f"    {rule}: {count:,}")
    print("  provenance: " + ", ".join(f"{name} {count:,}" for name, count in classes.most_common()))
    marginal = sum(1 for record in report.values() if record["gloss_provenance"]["only_tagged_senses"])
    print(f"  built only from marginal senses while a plain one exists: {marginal:,}")
    verbatim = [record for record in report.values()
                if record["gloss_provenance"]["class"] == "all_verbatim"]
    lead = sum(1 for record in verbatim if record["gloss_provenance"]["first_sense_is_en_first"])
    print(f"  of the {len(verbatim):,} all-verbatim glosses, {lead:,} lead with the entry's "
          f"first sense and {len(verbatim) - lead:,} do not")


if __name__ == "__main__":
    main()
