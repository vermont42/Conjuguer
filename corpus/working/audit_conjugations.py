#!/usr/bin/env python3
"""Stage 1.1 — diff the app's conjugations against English Wiktionary's tables.

Reads `corpus/working/conjugations.json` (the engine's own output, dumped by
`CorpusFormsDumpTests.testDumpAllConjugations`) and `wiktionary_en_verbs.json`, maps
Wiktionary's tag sets onto the app's tense keys, and writes one JSONL line per disagreement to
`corpus/working/verb_pass/audit_conjugations.jsonl`.

Systematic differences are not disagreements and are dropped before comparison:

  * rows tagged `multiword-construction` (the compound tenses, "avoir + past participle"),
    `alternative`, `obsolete`, `archaic`, `dated`, `rare`, `nonstandard`, `uncommon`,
    `misspelling`, `proscribed`, or a region (`Louisiana`, `Quebec`, `Canada`, …);
  * hyphenated reflexive imperatives ("lève-toi"), and the reflexive pronoun on a pronominal
    verb's table, which the app does not conjugate;
  * the 1990 spellings — a Wiktionary form that equals the app's with è→é in a futur or
    conditionnel stem, or with the circumflex dropped from i or u.

The app's uppercase irregularity markers are lowercased before comparing, and its `/`-joined
alternates are split, so a match against any alternate is agreement.

Usage:  python3 corpus/working/audit_conjugations.py
"""
import collections
import re

import verb_pass_lib as L

# Tags that make a form row something other than the app's single canonical form.
SKIP_TAGS = {
    "multiword-construction", "table-tags", "inflection-template", "alternative", "canonical",
    "obsolete", "archaic", "dated", "rare", "nonstandard", "uncommon", "misspelling",
    "proscribed", "dialectal", "noun", "error-unrecognized-form",
    "Louisiana", "Quebec", "Canada", "Early", "Modern", "French", "Switzerland", "Belgium",
}
PERSON_TAG = {"first-person": "first", "second-person": "second", "third-person": "third"}
NUMBER_TAG = {"singular": "Singular", "plural": "Plural"}
PRONOUNS = ("me ", "m'", "te ", "t'", "se ", "s'", "nous ", "vous ")
FUTUR_STEMS = ("futurSimple", "conditionnelPrésent")


def tense_key(tags):
    """The app tense key a Wiktionary form row belongs to, or None if the row is not one."""
    tags = set(tags or [])
    if tags & SKIP_TAGS:
        return None
    person = next((PERSON_TAG[t] for t in tags if t in PERSON_TAG), None)
    number = next((NUMBER_TAG[t] for t in tags if t in NUMBER_TAG), None)

    if "participle" in tags:
        if "past" in tags:
            return "participePassé"
        if "present" in tags and "gerund" in tags:
            return "participePrésent"
        return None
    if "imperative" in tags:
        if person == "second" and number == "Singular":
            return "impératif.secondSingular"
        if person == "first" and number == "Plural":
            return "impératif.firstPlural"
        if person == "second" and number == "Plural":
            return "impératif.secondPlural"
        return None
    if not person or not number:
        return None
    if "subjunctive" in tags:
        if "present" in tags:
            return f"subjonctifPrésent.{person}{number}"
        if "imperfect" in tags:
            return f"subjonctifImparfait.{person}{number}"
        return None
    if "conditional" in tags:
        return f"conditionnelPrésent.{person}{number}"
    if "indicative" not in tags:
        return None
    if "present" in tags:
        return f"indicatifPrésent.{person}{number}"
    if "imperfect" in tags:
        return f"imparfait.{person}{number}"
    if "past" in tags and "historic" in tags:
        return f"passéSimple.{person}{number}"
    if "future" in tags:
        return f"futurSimple.{person}{number}"
    return None


def strip_pronoun(form):
    """Drop the reflexive pronoun a pronominal table carries: "me fie" → "fie".

    Applied to every row, not only the `reflexive`-tagged ones: a verb Wiktionary treats as
    pronominal-only (*s'abstenir*, *s'évanouir*) conjugates its whole table with the pronoun
    attached and no tag to say so, while the app conjugates the bare verb.
    """
    previous = None
    while previous != form:
        previous = form
        low = form.lower()
        for pronoun in PRONOUNS:
            if low.startswith(pronoun):
                form = form[len(pronoun):].strip()
                break
    return form


def wiktionary_table(entries):
    """{tense key: [form, …]} from every entry of a verb, reflexive rows used only as a fallback."""
    direct = collections.defaultdict(list)
    reflexive = collections.defaultdict(list)
    for entry in entries:
        for row in entry.get("forms") or []:
            form = L.nfc(row.get("form") or "").strip()
            tags = row.get("tags") or []
            if not form or form in {"-", "—"}:
                continue
            if form.startswith(("/", "\\", "[")):
                continue  # wiktextract occasionally files a pronunciation as a form row
            key = tense_key(tags)
            if not key:
                continue
            target = reflexive if "reflexive" in tags else direct
            value = strip_pronoun(form)
            if value and value not in target[key]:
                target[key].append(value)
    for key, forms in reflexive.items():
        if key not in direct:
            direct[key] = forms
    return direct


def no_circumflex(form):
    return form.translate(str.maketrans("îûÎÛ", "iuIU"))


def accepted(app_forms, wiktionary_form, key):
    """True when the difference is one of the systematic ones rather than a disagreement."""
    candidate = wiktionary_form.lower()
    if candidate in app_forms:
        return True
    if key.startswith("impératif") and ("-" in candidate or " " in candidate):
        return True  # "abstiens-toi", "vas-y": the app conjugates the bare imperative
    if any(no_circumflex(app) == no_circumflex(candidate) for app in app_forms):
        return True  # 1990 spelling: paraître/paraitre, dûmes/dumes
    if key.split(".")[0] in FUTUR_STEMS:
        if any(app.replace("è", "é") == candidate.replace("è", "é") for app in app_forms):
            return True  # 1990 spelling: cèderai/céderai
    return False


ENDING = re.compile(r"(.{1,4})$")


def doubling_variant(app, wiktionary, infinitive):
    """True for the -eler/-eter orthographic split, which is not an engine error.

    The app spells these verbs the traditional way (*déchiquetterais*, *ruissellerais*); the
    English Wiktionary table gives the grave-accent spelling the 1990 rectifications made the
    recommended one for every -eler/-eter verb except *appeler*, *jeter* and their compounds.
    Both are current. Which one the app should ship is a judgement for the pass, not a diff.
    """
    if not (infinitive.endswith("eler") or infinitive.endswith("eter")):
        return False
    return app.replace("ell", "èl").replace("ett", "èt") == wiktionary


def classify(entry, key, app_forms, wiktionary_forms, disagreement_count, unused_keys):
    if key in unused_keys:
        return "defective_gap"
    app, wik = app_forms[0], wiktionary_forms[0].lower()
    if doubling_variant(app, wik, entry["infinitive"]):
        return "eler_eter_doubling"
    if len(wiktionary_forms) > 1:
        return "wiktionary_alternative"
    if disagreement_count >= 8:
        return "wrong_model"
    if ENDING.search(app).group(1) == ENDING.search(wik).group(1):
        return "missing_alteration"
    return "unknown"


def main():
    verbs = L.load_verbs()
    conjugations = L.load_conjugations()
    english = L.load_english()
    defect_groups = L.load_defect_groups()

    rows = []
    covered = 0
    for entry in verbs:
        entries = english.get(entry["infinitive"])
        if not entries:
            continue
        covered += 1
        table = wiktionary_table(entries)
        app_table = conjugations[entry["id"]]
        disagreements = []
        for key, wiktionary_forms in table.items():
            if key not in app_table:
                continue
            app_forms = L.alternates(app_table[key])
            if any(accepted(app_forms, form, key) for form in wiktionary_forms):
                continue
            disagreements.append((key, app_forms, wiktionary_forms))
        unused_keys = defect_groups.get(entry["defect_group"], (set(), ""))[0]
        for key, app_forms, wiktionary_forms in disagreements:
            rows.append({
                "verb": entry["id"],
                "rank": entry["rank"],
                "model": entry["model"],
                "tense_key": key,
                "app": app_table[key],
                "wiktionary": wiktionary_forms,
                "kind": classify(entry, key, app_forms, wiktionary_forms,
                                 len(disagreements), unused_keys),
            })

    rows.sort(key=lambda row: (row["rank"], row["verb"], row["tense_key"]))
    L.write_jsonl(L.OUT_DIR / "audit_conjugations.jsonl", rows)

    kinds = collections.Counter(row["kind"] for row in rows)
    verbs_hit = {row["verb"] for row in rows}
    print(f"  {covered:,} of {len(verbs):,} entries have an English-Wiktionary table")
    print(f"  {len(rows):,} disagreements over {len(verbs_hit):,} verbs")
    for kind, count in kinds.most_common():
        print(f"    {kind}: {count:,}")
    worst = collections.Counter(row["verb"] for row in rows).most_common(15)
    print("  most disagreements: " + ", ".join(f"{verb} ({count})" for verb, count in worst))


if __name__ == "__main__":
    main()
