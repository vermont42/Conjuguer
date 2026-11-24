#!/usr/bin/env python3
"""Merge, check, review, and approve the Phrases à trous sentences.

Consumes: Conjuguer/Models/gap_sentences.json, a JSON array in which each sentence carries id,
  verb (a key of Verb.verbs), tense (a QuizTenseSlot case name), person (a PersonNumber raw value,
  absent for a participle), gender ("f" or "m", present only where the sentence fixes the
  agreement), fr (the French with the conjugation in braces), en, and reviewed.

Produces, by subcommand:
  merge DRAFT.json [DRAFT.json ...]
      Appends drafted sentences (the fields above without id or reviewed) to the file, as drafts.
      Gives each an id (verb.tense.n), puts the narrow no-break space French takes before ! ? : ;
      and inside guillemets, and writes the typographic apostrophe.
  check
      What can be checked without the app: one pair of braces; the subject pronoun before the
      braces against the person; a simple tense's braces against corpus/working/conjugations.json,
      which scripts/write_forms_json.sh writes. The authoritative check is GapSentenceTests.
  review [--all] [--out PATH]
      A Markdown sheet of the drafts (or, with --all, every sentence), grouped by verb, with the
      conjugation in bold.
  approve ID [ID ...] | approve --all [--except ID ...]
      Marks sentences reviewed. A release build asks only reviewed sentences; a debug build asks
      drafts too and marks them on the card (GapSentences.includesDrafts).
  status
      Counts of reviewed and draft sentences, and of verbs.

Run from the repo root:  python3 scripts/gap_sentences.py status

Why it rewrites the whole file: gap_sentences.json is written by json.dumps(indent=2,
ensure_ascii=False) and nothing else, so a load-and-dump round trip reproduces it byte for byte
apart from what changed. That is NOT true of Localizable.xcstrings, which Xcode formats with
" : " separators; never point this pattern at that file (see .claude/rules/localization_catalog.md).

The machine check lives in ConjuguerTests/Models/GapSentenceTests.swift, which conjugates each
sentence's cell with the app's own Conjugator. Run it after any edit to the file.
"""

import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PATH = ROOT / "Conjuguer" / "Models" / "gap_sentences.json"
CONJUGATIONS = ROOT / "corpus" / "working" / "conjugations.json"

NARROW = " "
FIELDS = ["id", "verb", "tense", "person", "gender", "fr", "en", "reviewed"]
TENSE_NAMES = {
    "indicatifPrésent": "indicatif présent",
    "impératif": "impératif",
    "passéComposé": "passé composé",
    "imparfait": "imparfait",
    "futurSimple": "futur simple",
    "conditionnelPrésent": "conditionnel présent",
    "subjonctifPrésent": "subjonctif présent",
    "plusQueParfait": "plus-que-parfait",
    "conditionnelPassé": "conditionnel passé",
    "participePrésent": "participe présent",
    "participePassé": "participe passé",
    "passéSimple": "passé simple",
}
SIMPLE = {"indicatifPrésent", "imparfait", "futurSimple", "conditionnelPrésent", "subjonctifPrésent", "passéSimple", "impératif"}
PERSONS = {"fs": "je", "ss": "tu", "ts": "il/elle", "fp": "nous", "sp": "vous", "tp": "ils/elles"}
PERSON_NAMES = {"fs": "firstSingular", "ss": "secondSingular", "ts": "thirdSingular", "fp": "firstPlural", "sp": "secondPlural", "tp": "thirdPlural"}
SUBJECTS = {"je": "fs", "j": "fs", "tu": "ss", "il": "ts", "elle": "ts", "on": "ts", "nous": "fp", "vous": "sp", "ils": "tp", "elles": "tp"}
# Words that may come between a subject pronoun and its verb: ne and the object pronouns.
CLITICS = {"ne", "n", "me", "m", "te", "t", "se", "s", "le", "la", "l", "les", "lui", "leur", "y", "en", "nous", "vous"}


def load():
    return json.loads(PATH.read_text()) if PATH.exists() else []


def save(sentences):
    ordered = [{key: s[key] for key in FIELDS if key in s} for s in sentences]
    PATH.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n")


def typeset(french):
    french = french.replace("'", "’").strip()
    french = re.sub(r"[   ]*([!?:;])", NARROW + r"\1", french)
    french = re.sub(r"«[   ]*", "«" + NARROW, french)
    french = re.sub(r"[   ]*»", NARROW + "»", french)
    return french


def merge(sentences, drafts):
    counts = {}
    for s in sentences:
        key = (s["verb"], s["tense"])
        counts[key] = max(counts.get(key, 0), int(s["id"].rsplit(".", 1)[1]))
    added = 0
    for path in drafts:
        for draft in json.loads(pathlib.Path(path).read_text()):
            key = (draft["verb"], draft["tense"])
            counts[key] = counts.get(key, 0) + 1
            sentence = {
                "id": f"{draft['verb'].replace(' ', '_')}.{draft['tense']}.{counts[key]}",
                "verb": draft["verb"],
                "tense": draft["tense"],
                "fr": typeset(draft["fr"]),
                "en": draft["en"].strip(),
                "reviewed": False,
            }
            if draft.get("person"):
                sentence["person"] = draft["person"]
            if draft.get("gender"):
                sentence["gender"] = draft["gender"]
            sentences.append(sentence)
            added += 1
    save(sentences)
    print(f"merged {added}; {len(sentences)} sentences")


def subject_person(before):
    words = [w for w in re.split(r"[\s’',]+", before.lower()) if w]
    index = len(words) - 1
    while index >= 0 and words[index] in CLITICS:
        index -= 1
    if index >= 0 and words[index] in SUBJECTS:
        return SUBJECTS[words[index]]
    run = words[index + 1:]
    if run and run[0] in ("nous", "vous"):
        return SUBJECTS[run[0]]
    return None


def check(sentences):
    conjugations = json.loads(CONJUGATIONS.read_text()) if CONJUGATIONS.exists() else None
    problems = []
    for s in sentences:
        braces = re.findall(r"\{([^}]*)\}", s["fr"])
        if len(braces) != 1 or s["fr"].count("{") != 1 or s["fr"].count("}") != 1:
            problems.append((s["id"], "needs exactly one pair of braces"))
            continue
        before = s["fr"].split("{", 1)[0]
        person = s.get("person")
        found = subject_person(before)
        if found and person and found != person and s["tense"] != "impératif":
            problems.append((s["id"], f"subject before the braces is {PERSONS[found]}, person is {PERSONS[person]}"))
        if conjugations is not None and s["tense"] in SIMPLE and person:
            dump_key = re.sub(r" (\w+)$", r" (\1)", s["verb"])
            forms = conjugations.get(dump_key, {}).get(f"{s['tense']}.{PERSON_NAMES[person]}")
            if forms is None:
                problems.append((s["id"], "no such cell"))
            elif braces[0].lower() not in forms.lower().split("/"):
                problems.append((s["id"], f"braces {braces[0]!r}, conjugator {forms.lower()!r}"))
        if s["tense"] == "impératif" and person not in ("ss", "fp", "sp"):
            problems.append((s["id"], "an impératif is ss, fp, or sp"))
    for identifier, problem in problems:
        print(f"{identifier}: {problem}")
    print(f"{len(problems)} problems in {len(sentences)} sentences")


def review(sentences, include_all, out):
    shown = [s for s in sentences if include_all or not s["reviewed"]]
    title = "Phrases à trous" if include_all else "Phrases à trous to review"
    lines = [f"# {title} ({len(shown)})", ""]
    lines.append("Each conjugation in bold has passed the machine check, which confirms it against the")
    lines.append("Conjugator. What it cannot judge is the rest: whether the sentence is natural, whether its")
    lines.append("subject fits the person and the agreement, whether the context earns the tense, and whether")
    lines.append("the English says the same thing.")
    verb = None
    for s in shown:
        if s["verb"] != verb:
            verb = s["verb"]
            lines += ["", f"## {verb}", ""]
        cell = TENSE_NAMES.get(s["tense"], s["tense"])
        if "person" in s:
            cell += f", {PERSONS.get(s['person'], s['person'])}"
        if s.get("gender") == "f":
            cell += ", fém."
        french = re.sub(r"\{([^}]*)\}", r"**\1**", s["fr"])
        mark = "" if s["reviewed"] else " (draft)"
        lines.append(f"- `{s['id']}`{mark}, {cell}: {french}  ")
        lines.append(f"  {s['en']}")
    text = "\n".join(lines) + "\n"
    if out:
        pathlib.Path(out).write_text(text)
        print(f"wrote {len(shown)} sentences to {out}")
    else:
        sys.stdout.write(text)


def approve(sentences, ids, approve_all, excepted):
    known = {s["id"] for s in sentences}
    unknown = [i for i in ids + excepted if i not in known]
    if unknown:
        sys.exit(f"unknown ids: {', '.join(unknown)}")
    chosen = known - set(excepted) if approve_all else set(ids)
    changed = 0
    for s in sentences:
        if s["id"] in chosen and not s["reviewed"]:
            s["reviewed"] = True
            changed += 1
    save(sentences)
    print(f"approved {changed}; {sum(not s['reviewed'] for s in sentences)} drafts remain")


def status(sentences):
    reviewed = sum(s["reviewed"] for s in sentences)
    verbs = {s["verb"] for s in sentences}
    print(f"{len(sentences)} sentences: {reviewed} reviewed, {len(sentences) - reviewed} drafts; {len(verbs)} verbs")


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    m = sub.add_parser("merge")
    m.add_argument("drafts", nargs="+")
    sub.add_parser("check")
    r = sub.add_parser("review")
    r.add_argument("--all", action="store_true")
    r.add_argument("--out")
    a = sub.add_parser("approve")
    a.add_argument("ids", nargs="*")
    a.add_argument("--all", action="store_true")
    a.add_argument("--except", dest="excepted", nargs="*", default=[])
    sub.add_parser("status")
    args = parser.parse_args()
    sentences = load()
    if args.command == "merge":
        merge(sentences, args.drafts)
    elif args.command == "check":
        check(sentences)
    elif args.command == "review":
        review(sentences, args.all, args.out)
    elif args.command == "approve":
        if not args.all and not args.ids:
            sys.exit("name ids to approve, or pass --all")
        approve(sentences, args.ids, args.all, args.excepted)
    else:
        status(sentences)


if __name__ == "__main__":
    main()
