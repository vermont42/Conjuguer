#!/usr/bin/env python3
"""Stage 1.4 — check every shipped literature example for integrity.

Five checks per entry of `Conjuguer/Models/literature_examples.json`:

  verb_present     the French sentence contains a form of the verb, per conjugations.json
                   (lowercased, plus the participe passé with its agreement endings e/s/es,
                   and the infinitive itself, which the dump does not carry)
  token_is_a_form  `token` is such a form AND occurs in the sentence
  translated       `en` is non-empty
  source_line      `source` + `line` point at a line containing the token, where the tier file
                   is on disk. An authored example carries `line: null` and is exempt.
  shared_sentence  a sentence reused across verbs contains a form of each of them

Writes `corpus/working/verb_pass/example_integrity.json`:
`{ "<verb id>": { failures: [ { check, detail } ], example: {...} } }`, failures only, plus a
`_summary` key with the counts and the reuse groups.

Usage:  python3 corpus/working/check_examples.py
"""
import collections
import re

import verb_pass_lib as L

TOKEN_RE = re.compile(r"[^\W\d_]+", re.UNICODE)
PARTICIPLE_ENDINGS = ("e", "s", "es")
AUTHORED_PREFIX = "Claude"
# A mined token often carries the reflexive pronoun ("s'adressait"), which is not a form of the
# verb but is the right thing to have highlighted in the sentence. Strip it before testing.
PRONOUNS = ("me ", "m'", "te ", "t'", "se ", "s'", "nous ", "vous ")
# The classical tier is hard-wrapped, so a sentence that starts on `line` can carry its verb two
# or three lines later. `line` is where the sentence begins; search a window from there.
LINE_WINDOW = (-1, 4)


def unapostrophe(text):
    return text.replace("\u2019", "'")


def strip_pronoun(token):
    low = unapostrophe(token).lower()
    for pronoun in PRONOUNS:
        if low.startswith(pronoun):
            return low[len(pronoun):].strip()
    return low


def verb_forms(verb_id, table):
    """Every surface form of a verb, lowercased: the table, the agreeing participles, the
    infinitive. `passéComposé` is two words, so its auxiliary is taken as a form too — that is
    harmless here, since the check only ever asks whether a token is *one of* these."""
    forms = set()
    for key, value in table.items():
        for alternate in L.alternates(value):
            forms.update(alternate.split())
    participle = L.alternates(table.get("participePassé", ""))
    for form in participle:
        forms.update(form + ending for ending in PARTICIPLE_ENDINGS)
    forms.add(verb_id.split(" (")[0].lower())
    return {form for form in forms if form}


def tier_window(source, line_number):
    """(exact line, window around it) from the tier file, or (None, None) when it is absent."""
    for tier in ("literature", "classical", "government", "technology", "wikipedia"):
        path = L.ORIGINALS / tier / source
        if not path.exists():
            continue
        low, high = line_number + LINE_WINDOW[0], line_number + LINE_WINDOW[1]
        exact, window = "", []
        with open(path, encoding="utf-8", errors="replace") as handle:
            for number, text in enumerate(handle, start=1):
                if number == line_number:
                    exact = text
                if low <= number <= high:
                    window.append(text)
                elif number > high:
                    break
        return exact, " ".join(window)
    return None, None


def main():
    verbs = {entry["id"]: entry for entry in L.load_verbs()}
    conjugations = L.load_conjugations()
    examples = L.load_examples()

    # `ExampleData.example(for:)` looks a verb up by its id and then by its bare infinitif, so a
    # key like "haïr" legitimately serves both "haïr (France)" and "haïr (Québec)". Resolve a key
    # the same way, unioning the forms of every entry that shares the infinitive.
    by_infinitive = collections.defaultdict(list)
    for entry in verbs.values():
        by_infinitive[entry["infinitive"]].append(entry["id"])

    forms_by_verb = {}
    for verb_id in examples:
        ids = [verb_id] if verb_id in conjugations else by_infinitive.get(verb_id, [])
        if ids:
            forms_by_verb[verb_id] = set().union(
                *(verb_forms(verb_id, conjugations[one]) for one in ids))

    by_sentence = collections.defaultdict(list)
    for verb_id, example in examples.items():
        by_sentence[example["fr"]].append(verb_id)

    report = {}
    counts = collections.Counter()
    missing_tiers = set()
    for verb_id, example in examples.items():
        failures = []
        if verb_id not in forms_by_verb:
            failures.append({"check": "verb_present",
                             "detail": f"{verb_id} matches no verb entry"})
            report[verb_id] = {"failures": failures, "example": example}
            counts["verb_present"] += 1
            continue

        forms = forms_by_verb[verb_id]
        sentence_tokens = {token.lower() for token in TOKEN_RE.findall(unapostrophe(example["fr"]))}
        if not (sentence_tokens & forms):
            failures.append({"check": "verb_present",
                             "detail": "no form of the verb occurs in the sentence"})

        raw_token = (example.get("token") or "")
        token = strip_pronoun(raw_token)
        if token not in forms:
            failures.append({"check": "token_is_a_form",
                             "detail": f"token “{token}” is not a form of {verb_id}"})
        elif token not in sentence_tokens:
            failures.append({"check": "token_is_a_form",
                             "detail": f"token “{token}” does not occur in the sentence"})

        if not (example.get("en") or "").strip():
            failures.append({"check": "translated", "detail": "en is empty"})

        source = example.get("source") or ""
        line_number = example.get("line")
        if not source.startswith(AUTHORED_PREFIX):
            if line_number is None:
                failures.append({"check": "source_line",
                                 "detail": f"corpus source “{source}” carries no line number"})
            else:
                exact, window = tier_window(source, line_number)
                if exact is None:
                    missing_tiers.add(source)
                elif token:
                    if token in unapostrophe(exact).lower():
                        pass
                    elif token in unapostrophe(window).lower():
                        counts["token_on_a_nearby_line"] += 1
                    else:
                        failures.append({
                            "check": "source_line",
                            "detail": f"{source}:{line_number} and the lines around it do not "
                                      f"contain “{token}”",
                        })
        elif line_number is not None:
            failures.append({"check": "source_line",
                             "detail": f"authored example carries line {line_number}, expected null"})

        others = [other for other in by_sentence[example["fr"]] if other != verb_id]
        for other in others:
            if other in forms_by_verb and not (sentence_tokens & forms_by_verb[other]):
                failures.append({
                    "check": "shared_sentence",
                    "detail": f"sentence is also {other}'s, but holds no form of it",
                })

        if failures:
            report[verb_id] = {"failures": failures, "example": example}
            for failure in failures:
                counts[failure["check"]] += 1

    reuse = {sentence: ids for sentence, ids in by_sentence.items() if len(ids) > 1}
    report["_summary"] = {
        "examples": len(examples),
        "verbs_with_a_failure": len(report),
        "failures_by_check": dict(counts),
        "authored": sum(1 for example in examples.values()
                        if (example.get("source") or "").startswith(AUTHORED_PREFIX)),
        "reused_sentences": {sentence[:80]: ids for sentence, ids in reuse.items()},
        "tier_files_not_on_disk": sorted(missing_tiers),
    }
    L.write_json(L.OUT_DIR / "example_integrity.json", report)

    print(f"  {len(examples):,} examples over {len({v.split(' (')[0] for v in examples}):,} verbs")
    print(f"  {len(report) - 1:,} with at least one failure")
    for check, count in counts.most_common():
        print(f"    {check}: {count:,}")
    print(f"  {len(reuse):,} sentences used by more than one verb")
    if missing_tiers:
        print(f"  tier files not on disk (source_line unchecked): {sorted(missing_tiers)}")
    unknown = [verb_id for verb_id in examples if verb_id not in verbs]
    if unknown:
        print(f"  keys that are not verb entries: {unknown}")


if __name__ == "__main__":
    main()
