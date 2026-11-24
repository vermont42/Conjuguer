#!/usr/bin/env python3
"""Merge, check, review, and approve the quiz's choice questions.

Consumes: Conjuguer/Models/choice_questions.json, a JSON array in which each item carries id,
  verb (a key of Verb.verbs), person (a PersonNumber raw value, which both sentences share),
  gender ("f" or "m", present only where an être verb's agreement shows in either sentence),
  setting (a ChoiceSetting case name), reason (a ChoiceReason case name, which also gives the
  level from which the default quiz asks the item), right and other (each a tense, a
  QuizTenseSlot case name, and fr, the French with the conjugation in one pair of braces), en,
  and reviewed.

Produces, by subcommand:
  merge DRAFT.json [DRAFT.json ...]
      Appends drafted items (the fields above without id or reviewed) to the file, as drafts.
      Gives each an id (verb.rightTense.n), puts the narrow no-break space French takes before
      ! ? : ; and inside guillemets, and writes the typographic apostrophe.
  check
      What can be checked without the app: one pair of braces in each sentence; the two
      sentences the same outside their braces, but for an elided je, que, or the like; the two
      conjugations different; and each simple-tense conjugation against
      corpus/working/conjugations.json, which scripts/write_forms_json.sh writes. The
      authoritative check is ChoiceQuestionTests.
  review [--all] [--out PATH]
      A Markdown sheet of the drafts (or, with --all, every item), grouped by reason, with the
      right sentence first, each conjugation in bold, and the reason as the app words it.
  approve ID [ID ...] | approve --all [--except ID ...]
      Marks items reviewed. A release build asks only reviewed items; a debug build asks drafts
      too and marks them on the card (ChoiceQuestions.askable, which follows
      GapSentences.includesDrafts).
  status
      Counts of reviewed and draft items by level.

Run from the repo root:  python3 scripts/choice_questions.py status

Why it rewrites the whole file: choice_questions.json is written by json.dumps(indent=2,
ensure_ascii=False) and nothing else, so a load-and-dump round trip reproduces it byte for byte
apart from what changed. That is NOT true of Localizable.xcstrings, which Xcode formats with
" : " separators; never point this pattern at that file (see .claude/rules/localization_catalog.md).

The machine check lives in ConjuguerTests/Models/ChoiceQuestionTests.swift, which conjugates
both sentences' cells with the app's own Conjugator. Run it after any edit to the file.
"""

import argparse
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent
PATH = ROOT / "Conjuguer" / "Models" / "choice_questions.json"
CONJUGATIONS = ROOT / "corpus" / "working" / "conjugations.json"

NARROW = " "
FIELDS = ["id", "verb", "person", "gender", "setting", "reason", "right", "other", "en", "reviewed"]
SIMPLE = {"indicatifPrésent", "imparfait", "futurSimple", "conditionnelPrésent", "subjonctifPrésent", "passéSimple"}
PERSON_NAMES = {"fs": "firstSingular", "ss": "secondSingular", "ts": "thirdSingular", "fp": "firstPlural", "sp": "secondPlural", "tp": "thirdPlural"}
TENSE_NAMES = {
    "indicatifPrésent": "indicatif présent",
    "passéComposé": "passé composé",
    "imparfait": "imparfait",
    "futurSimple": "futur simple",
    "conditionnelPrésent": "conditionnel présent",
    "subjonctifPrésent": "subjonctif présent",
    "plusQueParfait": "plus-que-parfait",
    "conditionnelPassé": "conditionnel passé",
    "passéSimple": "passé simple",
}
SETTINGS = {
    "conversation": "Dans une conversation",
    "request": "Pour demander poliment",
    "story": "Dans un récit écrit",
    "history": "Dans un livre d’histoire",
}
# The English of each reason as Localizable.xcstrings words it, and the level that first asks it.
# Kept here by hand so that the sheet shows what the learner reads; if a reason is reworded in the
# catalog, reword it here too.
REASONS = {
    "completedEvent": ("elementary", "A completed action, at a definite moment in the past, takes the passé composé."),
    "pastDescription": ("elementary", "A past description or state, with no definite start or end, takes the imparfait."),
    "pastHabit": ("elementary", "A past habit, something done again and again, takes the imparfait."),
    "actionInProgress": ("elementary", "An action under way when another happens takes the imparfait; the other takes the passé composé."),
    "siImparfait": ("elementary", "After si, a hypothesis takes the imparfait, never the conditionnel."),
    "conditionnelAfterSi": ("elementary", "When si takes the imparfait, the result takes the conditionnel présent."),
    "futurAfterSiPrésent": ("elementary", "When si takes the présent, the result takes the futur simple."),
    "politeRequest": ("elementary", "To ask politely, speakers soften the request with the conditionnel présent."),
    "necessity": ("intermediate", "Il faut que and other expressions of necessity take the subjonctif."),
    "wish": ("intermediate", "A wish or a demand, as with vouloir que, souhaiter que, or aimer que, takes the subjonctif."),
    "emotion": ("intermediate", "An emotion, as with être content que or avoir peur que, takes the subjonctif."),
    "conjunction": ("intermediate", "Bien que, pour que, avant que, and sans que take the subjonctif."),
    "doubt": ("intermediate", "Doubt, as with je ne pense pas que or je doute que, takes the subjonctif."),
    "certainty": ("intermediate", "Penser que, croire que, and être sûr que, when affirmative, take the indicatif."),
    "hope": ("intermediate", "Espérer que takes the indicatif, often the futur, unlike souhaiter que."),
    "siPlusQueParfait": ("intermediate", "After si, a hypothesis about the past takes the plus-que-parfait, never the conditionnel passé."),
    "passéSimpleInWriting": ("advanced", "A written narrative, such as a tale, a novel, or a history book, tells its events in the passé simple."),
    "passéComposéInSpeech": ("advanced", "Speech no longer uses the passé simple; it tells what happened in the passé composé."),
}
LEVELS = ["elementary", "intermediate", "advanced"]
ELIDED = {"j’": "je ", "qu’": "que ", "n’": "ne ", "m’": "me ", "t’": "te ", "s’": "se ", "d’": "de "}


def load():
    return json.loads(PATH.read_text()) if PATH.exists() else []


def save(items):
    ordered = [{key: item[key] for key in FIELDS if key in item} for item in items]
    PATH.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n")


def typeset(french):
    french = french.replace("'", "’").strip()
    french = re.sub(r"[   ]*([!?:;])", NARROW + r"\1", french)
    french = re.sub(r"«[   ]*", "«" + NARROW, french)
    french = re.sub(r"[   ]*»", NARROW + "»", french)
    return french


def merge(items, drafts):
    counts = {}
    for item in items:
        key = (item["verb"], item["right"]["tense"])
        counts[key] = max(counts.get(key, 0), int(item["id"].rsplit(".", 1)[1]))
    added = 0
    for path in drafts:
        for draft in json.loads(pathlib.Path(path).read_text()):
            key = (draft["verb"], draft["right"]["tense"])
            counts[key] = counts.get(key, 0) + 1
            item = {
                "id": f"{draft['verb'].replace(' ', '_')}.{draft['right']['tense']}.{counts[key]}",
                "verb": draft["verb"],
                "person": draft["person"],
                "setting": draft["setting"],
                "reason": draft["reason"],
                "right": {"tense": draft["right"]["tense"], "fr": typeset(draft["right"]["fr"])},
                "other": {"tense": draft["other"]["tense"], "fr": typeset(draft["other"]["fr"])},
                "en": draft["en"].strip(),
                "reviewed": False,
            }
            if draft.get("gender"):
                item["gender"] = draft["gender"]
            items.append(item)
            added += 1
    save(items)
    print(f"merged {added}; {len(items)} items")


def parts(french):
    match = re.fullmatch(r"([^{}]*)\{([^{}]+)\}([^{}]*)", french)
    return match.groups() if match else None


def unelided(before):
    for elided, full in ELIDED.items():
        if before.lower().endswith(elided):
            return before[: -len(elided)] + full
    return before


def check(items):
    conjugations = json.loads(CONJUGATIONS.read_text()) if CONJUGATIONS.exists() else None
    problems = []
    for item in items:
        right, other = parts(item["right"]["fr"]), parts(item["other"]["fr"])
        if right is None or other is None:
            problems.append((item["id"], "each sentence needs exactly one pair of braces"))
            continue
        if unelided(right[0]).lower() != unelided(other[0]).lower() or right[2] != other[2]:
            problems.append((item["id"], "the sentences differ outside their braces"))
        if right[1].lower() == other[1].lower():
            problems.append((item["id"], "the two conjugations are the same"))
        if item["reason"] not in REASONS:
            problems.append((item["id"], f"unknown reason {item['reason']}"))
        if item["setting"] not in SETTINGS:
            problems.append((item["id"], f"unknown setting {item['setting']}"))
        if conjugations is None:
            continue
        for option, (_, braces, _) in (("right", right), ("other", other)):
            tense = item[option]["tense"]
            if tense not in SIMPLE:
                continue
            dump_key = re.sub(r" (\w+)$", r" (\1)", item["verb"])
            forms = conjugations.get(dump_key, {}).get(f"{tense}.{PERSON_NAMES[item['person']]}")
            if forms is None:
                problems.append((item["id"], f"{option}: no such cell"))
            elif braces.lower() not in forms.lower().split("/"):
                problems.append((item["id"], f"{option}: braces {braces!r}, conjugator {forms.lower()!r}"))
    for identifier, problem in problems:
        print(f"{identifier}: {problem}")
    print(f"{len(problems)} problems in {len(items)} items")


def bold(french):
    return re.sub(r"\{([^}]*)\}", r"**\1**", french)


def review(items, include_all, out):
    shown = [i for i in items if include_all or not i["reviewed"]]
    title = "Choice questions" if include_all else "Choice questions to review"
    lines = [f"# {title} ({len(shown)})", ""]
    lines.append("Both sentences of every item have passed the machine check, which confirms each")
    lines.append("conjugation against the Conjugator. What it cannot judge is the choice itself: whether a")
    lines.append("French speaker or writer in that setting would use the first sentence over the second,")
    lines.append("whether the reason is true of it, and whether the English says the same thing. The right")
    lines.append("sentence is listed first here; the app shows the two in either order.")
    reason = None
    order = list(REASONS)
    for item in sorted(shown, key=lambda i: order.index(i["reason"]) if i["reason"] in order else 99):
        if item["reason"] != reason:
            reason = item["reason"]
            level, line = REASONS.get(reason, ("?", reason))
            lines += ["", f"## {level.capitalize()}: {reason}", "", f"Reason: {line}", ""]
        mark = "" if item["reviewed"] else " (draft)"
        right = TENSE_NAMES.get(item["right"]["tense"], item["right"]["tense"])
        other = TENSE_NAMES.get(item["other"]["tense"], item["other"]["tense"])
        lines.append(f"- `{item['id']}`{mark} · {SETTINGS.get(item['setting'], item['setting'])}")
        lines.append(f"  - ✓ {bold(item['right']['fr'])} ({right})")
        lines.append(f"  - ✗ {bold(item['other']['fr'])} ({other})")
        lines.append(f"  - *{item['en']}*")
    text = "\n".join(lines) + "\n"
    if out:
        pathlib.Path(out).write_text(text)
        print(f"wrote {len(shown)} items to {out}")
    else:
        sys.stdout.write(text)


def approve(items, ids, approve_all, excepted):
    known = {i["id"] for i in items}
    unknown = [i for i in ids + excepted if i not in known]
    if unknown:
        sys.exit(f"unknown ids: {', '.join(unknown)}")
    chosen = known - set(excepted) if approve_all else set(ids)
    changed = 0
    for item in items:
        if item["id"] in chosen and not item["reviewed"]:
            item["reviewed"] = True
            changed += 1
    save(items)
    print(f"approved {changed}; {sum(not i['reviewed'] for i in items)} drafts remain")


def status(items):
    for level in LEVELS:
        at = [i for i in items if REASONS.get(i["reason"], ("",))[0] == level]
        print(f"{level}: {sum(i['reviewed'] for i in at)} reviewed, {sum(not i['reviewed'] for i in at)} drafts")
    print(f"total: {len(items)}")


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
    items = load()
    if args.command == "merge":
        merge(items, args.drafts)
    elif args.command == "check":
        check(items)
    elif args.command == "review":
        review(items, args.all, args.out)
    elif args.command == "approve":
        if not args.all and not args.ids:
            sys.exit("name ids to approve, or pass --all")
        approve(items, args.ids, args.all, args.excepted)
    else:
        status(items)


if __name__ == "__main__":
    main()
