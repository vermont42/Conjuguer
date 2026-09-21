#!/usr/bin/env python3
"""Stage 1.2 — compare the app's four verb flags against both Wiktionaries.

  auxiliary (`ay`)   English Wiktionary's compound-tense row, "avoir + past participle" or
                     "être + past participle". A reflexive verb is être in the app whatever
                     `ay` says, so only non-reflexive entries are compared.
  pronominal (`re`)  every sense tagged reflexive or pronominal, in either edition.
  defective (`dg`)   French Wiktionary's "Verbes défectifs en français" category, or a sense
                     tagged defective in either edition.
  aspirated h (`ah`) the sense category "French terms with aspirated h" / "with mute h".

Writes `corpus/working/verb_pass/audit_flags.json`, disagreements only:
`{ "<verb id>": [ { flag, app, wiktionary, evidence } ] }`.

The h-aspiration signal is not in the Stage 0 reference files: wiktextract files those two
categories per SENSE, and `build_wiktionary_reference.py` keeps only the ENTRY-level
`categories`, which the English edition leaves null. Rather than rebuild the reference, this
script makes one pass over the raw English dump for the h-initial verbs and caches the answer
in `corpus/working/wiktionary/h_classes.json`; the pass is skipped when the cache is present.
If the raw dump has been deleted the h check is reported as unavailable rather than silently
producing no disagreements.

Usage:  python3 corpus/working/audit_flags.py [--refresh-h]
"""
import argparse
import collections
import json

import verb_pass_lib as L

RAW_ENGLISH = L.WIKT / "raw" / "kaikki-French.jsonl"
H_CLASSES = L.WIKT / "h_classes.json"
ASPIRATED_CATEGORY = "French terms with aspirated h"
MUTE_CATEGORY = "French terms with mute h"
PRONOMINAL_TAGS = {"reflexive", "pronominal"}
DEFECTIVE_TAGS = {"defective"}
DEFECTIVE_CATEGORY_FR = "Verbes défectifs en français"


def build_h_classes(infinitives):
    """{verb: "aspirated" | "mute"} for the h-initial verbs, from the raw English dump."""
    if H_CLASSES.exists():
        return L.load_json(H_CLASSES), "cached"
    if not RAW_ENGLISH.exists():
        return None, "unavailable"
    wanted = {verb for verb in infinitives if verb.lower().startswith("h")}
    classes = {}
    with open(RAW_ENGLISH, encoding="utf-8") as handle:
        for line in handle:
            if ASPIRATED_CATEGORY not in line and MUTE_CATEGORY not in line:
                continue
            try:
                entry = json.loads(line)
            except json.JSONDecodeError:
                continue
            word = L.nfc(entry.get("word", ""))
            if word not in wanted or entry.get("pos") != "verb":
                continue
            names = {category.get("name", "") if isinstance(category, dict) else str(category)
                     for sense in entry.get("senses", [])
                     for category in sense.get("categories", [])}
            if ASPIRATED_CATEGORY in names:
                classes[word] = "aspirated"
            elif MUTE_CATEGORY in names and word not in classes:
                classes[word] = "mute"
    L.write_json(H_CLASSES, classes)
    return classes, "built"


def english_auxiliaries(entries):
    """The set of auxiliaries the compound-tense rows name: {"avoir"}, {"être"}, or both.

    A verb that takes either auxiliary by sense (*monter*, *passer*, *sortir*, *tomber*) carries
    BOTH rows, and the extract writes the avoir one first. Reading only the first row therefore
    reports the app's deliberate choice (decision 4: one auxiliary per entry, the one the gloss
    leads with) as an error, which it is not.
    """
    found = set()
    for entry in entries:
        for row in entry.get("forms") or []:
            tags = set(row.get("tags") or [])
            if not {"infinitive", "multiword-construction"} <= tags:
                continue
            form = (row.get("form") or "").strip()
            for auxiliary in ("s'être", "être", "avoir"):
                if form.startswith(auxiliary):
                    found.add(auxiliary)
                    break
    return found


def senses(entries):
    return [sense for entry in entries for sense in entry.get("senses", [])]


def all_senses_pronominal(entries):
    """True when EVERY sense of every entry is tagged reflexive or pronominal.

    Every sense, not every *tagged* sense: most French-Wiktionary senses carry no tag at all, so
    ignoring the untagged ones would call any verb with one pronominal sense pronominal-only —
    which it did, for 434 verbs, *abandonner* among them.
    """
    all_tags = [set(sense.get("tags") or []) for sense in senses(entries)]
    if not all_tags:
        return False
    return all(tags & PRONOMINAL_TAGS for tags in all_tags)


def is_defective(english_entries, french_entries):
    evidence = []
    for entry in french_entries or []:
        if DEFECTIVE_CATEGORY_FR in (entry.get("categories") or []):
            evidence.append(f"fr category “{DEFECTIVE_CATEGORY_FR}”")
            break
    for label, entries in (("en", english_entries), ("fr", french_entries)):
        for sense in senses(entries or []):
            if set(sense.get("tags") or []) & DEFECTIVE_TAGS:
                evidence.append(f"{label} sense tagged defective")
                break
    return evidence


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--refresh-h", action="store_true", help="rebuild h_classes.json")
    arguments = parser.parse_args()
    if arguments.refresh_h and H_CLASSES.exists():
        H_CLASSES.unlink()

    verbs = L.load_verbs()
    english = L.load_english()
    french = L.load_french()
    h_classes, h_status = build_h_classes([verb["infinitive"] for verb in verbs])
    print(f"  h-aspiration source: {h_status}"
          + (f" ({len(h_classes):,} h-initial verbs classified)" if h_classes else ""))

    report = {}
    covered = 0
    for entry in verbs:
        english_entries = english.get(entry["infinitive"])
        french_entries = french.get(entry["infinitive"])
        if not english_entries and not french_entries:
            continue
        covered += 1
        disagreements = []

        auxiliaries = english_auxiliaries(english_entries or [])
        plain_auxiliaries = auxiliaries - {"s'être"}
        if len(plain_auxiliaries) == 1 and not entry["is_reflexive"]:
            wiktionary = plain_auxiliaries.pop()
            if wiktionary != entry["auxiliary"]:
                disagreements.append({
                    "flag": "ay",
                    "app": entry["auxiliary"],
                    "wiktionary": wiktionary,
                    "evidence": f"en compound row “{wiktionary} + past participle”, and only that one",
                })

        pronominal = (all_senses_pronominal(english_entries or [])
                      or all_senses_pronominal(french_entries or []))
        if pronominal != entry["is_reflexive"]:
            where = []
            if all_senses_pronominal(english_entries or []):
                where.append("en")
            if all_senses_pronominal(french_entries or []):
                where.append("fr")
            disagreements.append({
                "flag": "re",
                "app": entry["is_reflexive"],
                "wiktionary": pronominal,
                "evidence": ("every sense tagged pronominal in " + "+".join(where)) if where
                            else "neither edition tags every sense pronominal "
                                 "(some senses may be; the app's entry is pronominal-only)",
            })

        defective = is_defective(english_entries, french_entries)
        if bool(defective) != (entry["defect_group"] is not None):
            disagreements.append({
                "flag": "dg",
                "app": entry["defect_group"],
                "wiktionary": bool(defective),
                "evidence": "; ".join(defective) or "no defective marking in either edition",
            })

        if h_classes is not None and entry["infinitive"].lower().startswith("h"):
            h_class = h_classes.get(entry["infinitive"])
            if h_class and (h_class == "aspirated") != entry["aspirated_h"]:
                disagreements.append({
                    "flag": "ah",
                    "app": entry["aspirated_h"],
                    "wiktionary": h_class == "aspirated",
                    "evidence": f"en sense category “French terms with {h_class} h”",
                })

        if disagreements:
            report[entry["id"]] = disagreements

    L.write_json(L.OUT_DIR / "audit_flags.json", report)
    by_flag = collections.Counter(item["flag"] for items in report.values() for item in items)
    print(f"  {covered:,} of {len(verbs):,} entries covered by at least one edition")
    print(f"  {len(report):,} verbs with a flag disagreement")
    for flag, count in by_flag.most_common():
        print(f"    {flag}: {count:,}")


if __name__ == "__main__":
    main()
