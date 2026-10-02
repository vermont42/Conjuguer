#!/usr/bin/env python3
"""Write the verb-pass report and the approvals file Josh edits before Stage 4.

Stage 3 of prompts/verb-pass-plan.md. Reads the Stage 2 shards and results, the skeptic
shards and verdicts, and the live verbs.xml, and writes:

    docs/verb-pass-report.md                     counts first, then one section per task in
                                                 frequency-rank order, the corpus and quotation
                                                 picks with their provenance status (warnings
                                                 first), the unsure flags, the checkers' other
                                                 notes, and the refuted items in an appendix
    corpus/working/verb_pass/approvals.json      every upheld or partly item and every pick
                                                 without a provenance warning, set to "pending"

A skeptic item whose verdict file is missing or invalid is reported as `pending` and left out
of approvals.json, so the script can run mid-Stage 3 without pretending to be finished.

With --pass-dir corpus/working/verb_pass/stage5 (Stage 5.5) it reads the Stage 5 files instead,
where every item is a new example, and writes docs/verb-pass-report-stage5.md and
verb_pass/stage5/approvals.json, so the Stage 4 report and approvals are never touched.

Usage:
    python3 corpus/working/build_report.py
    python3 corpus/working/build_report.py --pass-dir corpus/working/verb_pass/stage5
"""
import collections
import datetime
import json
import re
import sys

import validate_verb_pass as validator
import verb_pass_lib as lib

REPORT = lib.REPO / "docs" / "verb-pass-report.md"
APPROVALS = lib.OUT_DIR / "approvals.json"
ADDED = lib.REPO / "corpus" / "working" / "added_glosses.json"
ADDED_PREFIX = "gloss:added|"
TASKS = ["gloss", "example", "new_example", "flag"]
TASK_TITLES = {
    "gloss": "Glosses",
    "example": "Existing examples",
    "new_example": "Authored examples",
    "flag": "Flags",
}
VERDICTS = ["upheld", "partly", "refuted", "pending"]
CLEAN_PICKS = {"verbatim", "excerpt"}
PICK_STATUS_ORDER = ["unmatched", "wrong_kind", "not_public_domain", "miscited", "late_edition",
                     "excerpt", "verbatim"]
BANDS = [(1, 1500), (1501, 3000), (3001, 4500), (4501, None)]


def load_stage2():
    verbs, records = {}, {}
    for path in sorted(validator.SHARDS.glob("shard_*.json")):
        if not (validator.RESULTS / path.name).exists():
            continue
        shard = lib.load_json(path)
        results = lib.load_json(validator.RESULTS / path.name)["results"]
        for verb, record in zip(shard["verbs"], results):
            verbs[verb["id"]] = verb
            records[verb["id"]] = record
    return verbs, records


def load_skeptic():
    items = []
    for path in sorted(validator.SKEPTIC_SHARDS.glob("shard_*.json")):
        number = int(path.stem.split("_")[1])
        shard = lib.load_json(path)
        errors, _, results = validator.validate_skeptic(number)
        for position, item in enumerate(shard["items"]):
            verdict = results[position] if not errors else None
            items.append({**item, "shard": number,
                          "skeptic": verdict or {"verdict": "pending", "severity": None,
                                                 "reason": None}})
    return items


def apostrophe_partly(item):
    """A `partly` on an example that cites the apostrophe. Decision 3's curly apostrophe is the
    gloss house style; every shipped example uses the straight one, so the objection may be the
    skeptic misapplying it. The reason still has to be read for any other objection."""
    reason = (item["skeptic"].get("reason") or "").lower()
    return (item["task"] in ("example", "new_example") and item["skeptic"]["verdict"] == "partly"
            and "apostrophe" in reason)


PARENTHESIS_ALLOWED = re.compile(r"allows parenthes\w* for|(?<!non-)register parenthe|allowed by house style"
                                 r"|exactly what house style allows|register in parenthes|marking register"
                                 r"|marks register correctly")
PARENTHESIS_OBJECTION = re.compile(r"non-register|domain (label|note)|parenthes")
PARENTHESIS_RULE = re.compile(r"register|region|house style|forbid|misuse|clarif|object|domain|explanatory")


def parenthesis_gloss(item):
    """A gloss verdict that leans on decision 3's old "parentheses only for register or region".
    Josh amended that rule on 2026-09-27 to allow a parenthesis that fixes which sense of an
    ambiguous English word is meant ("put down (set down)"), so the objection may no longer hold.
    The reason still has to be read for any other objection."""
    if item["task"] != "gloss":
        return False
    for sentence in re.split(r"(?<=[.;])\s+", item["skeptic"].get("reason") or ""):
        sentence = sentence.lower()
        if PARENTHESIS_ALLOWED.search(sentence):
            continue
        if PARENTHESIS_OBJECTION.search(sentence) and PARENTHESIS_RULE.search(sentence):
            return True
    return False


LENGTH_RULE = re.compile(r"definition_like|\b\d+[- ]word|read(ing)? aloud|read-aloud|hear aloud|two or three "
                         r"senses|too long|wordy|\bshorten|\btrim|compress|concise|condens|\blong\b|verbose"
                         r"|lengthy", re.I)


def length_gloss(item):
    """A gloss item whose checker evidence or skeptic reason leans on length. Josh dropped the
    read-aloud limit on 2026-09-27, after réaliser's eight live senses were cut to three, so a
    change that only shortens a correct gloss should not ship."""
    text = f"{item.get('evidence') or ''} {item['skeptic'].get('reason') or ''}"
    return item["task"] == "gloss" and bool(LENGTH_RULE.search(text))


def load_added(verbs):
    """The gloss changes no checker raised, from added_glosses.json, with rank and current gloss.

    `verbs` is the live verbs.xml by id, so a card shows what the app ships today."""
    if not ADDED.exists():
        return []
    added = []
    for entry in lib.load_json(ADDED)["items"]:
        verb = verbs.get(entry["id"])
        if verb is None:
            sys.exit(f"added_glosses.json names {entry['id']!r}, which is not in verbs.xml")
        added.append({**entry, "rank": verb["rank"], "current": verb["gloss"]})
    return sorted(added, key=lambda a: (a["rank"], a["id"]))


def load_card_notes():
    """False-friend sweep findings on verbs that already have a gloss card, by verb id."""
    if not ADDED.exists():
        return {}
    return {note["id"]: note for note in lib.load_json(ADDED).get("card_notes", [])}


def item_key(item):
    task = f"flag:{item['flag']}" if item["task"] == "flag" else item["task"]
    if task == "new_example" and (item.get("proposed") or {}).get("kind") not in (None, "authored"):
        task = "pick"
    return f"{task}|{item['id']}"


def md(text):
    if text is None:
        return "—"
    return str(text).replace("|", "\\|").replace("\n", " ").strip()


def show(value):
    if value is None:
        return "—"
    if isinstance(value, bool):
        return "yes" if value else "no"
    if isinstance(value, dict):
        return json.dumps(value, ensure_ascii=False)
    return str(value)


def evidence_text(evidence):
    if isinstance(evidence, list):
        return "; ".join(map(str, evidence)) or None
    return evidence


def item_block(item):
    skeptic = item["skeptic"]
    lines = [f"#### {item['id']} (rank {item['rank']})"]
    verdict = skeptic["verdict"] + (f", {skeptic['severity']}" if skeptic.get("severity") else "")
    task = item["task"]
    if task == "gloss":
        lines.append(f"- **Gloss:** {md(item['current'])} → **{md(item['proposed'])}**")
        lines.append(f"- **Checker:** `{item['checker_verdict']}`, {item.get('checker_confidence')} "
                     f"confidence. {md(item['evidence'])}")
    elif task == "example":
        current = item["current"] or {}
        proposed = item["proposed"] or {}
        lines.append(f"- **Example:** {md(current.get('fr'))} / *{md(current.get('en'))}* "
                     f"({md(current.get('source'))})")
        lines.append(f"- **Checker:** `{item['checker_verdict']}`. {md(evidence_text(item['evidence']))}")
        if proposed.get("proposed_en"):
            lines.append(f"- **Proposed English:** {md(proposed['proposed_en'])}")
        replacement = proposed.get("replacement")
        if replacement:
            lines.append(f"- **Proposed replacement ({replacement.get('kind')}):** "
                         f"{md(replacement.get('fr'))} / *{md(replacement.get('en'))}*")
    elif task == "new_example":
        proposed = item["proposed"]
        lines.append(f"- **Authored:** {md(proposed.get('fr'))}")
        lines.append(f"- **English:** {md(proposed.get('en'))}")
        lines.append(f"- **Token:** {md(proposed.get('token'))} · gloss {md(item['gloss_current'])}"
                     + (f" (proposed {md(item['gloss_proposed'])})" if item.get("gloss_proposed") else "")
                     + f" · {len(item.get('candidates') or [])} candidate(s) passed over")
    else:
        lines.append(f"- **Flag `{item['flag']}`:** {md(show(item['current']))} → "
                     f"**{md(show(item['proposed']))}**")
        lines.append(f"- **Checker:** {md(item['evidence'])}")
    if apostrophe_partly(item):
        verdict += " (mentions the apostrophe; examples use the straight one, see Counts)"
    if parenthesis_gloss(item):
        verdict += " (cites the old parenthesis rule, see Counts)"
    if length_gloss(item) and item["skeptic"]["verdict"] in ("upheld", "partly"):
        verdict += " (leans on the dropped length rule, see Counts)"
    lines.append(f"- **Skeptic:** {verdict}. {md(skeptic.get('reason'))}")
    for note in item.get("checker_notes") or []:
        lines.append(f"- *Note:* {md(note)}")
    return "\n".join(lines)


def picks_table(rows):
    out = ["| Rank | Verb | Kind | Status | French | English | Source |",
           "|---|---|---|---|---|---|---|"]
    for row in rows:
        example = row["example"]
        candidate = row["candidate"] or {}
        source = candidate.get("source") or example.get("source")
        if example["kind"] == "tier":
            source = f"{candidate.get('source') or example.get('source')}:" \
                     f"{candidate.get('line') or example.get('line')}"
        elif candidate.get("author"):
            source = ", ".join(str(part) for part in (candidate.get("author"), candidate.get("title"),
                                                      candidate.get("year"), candidate.get("death_year") and
                                                      f"d. {candidate['death_year']}") if part)
        status = row["status"] if row["status"] in CLEAN_PICKS else f"**{row['status']}**: {row['detail']}"
        out.append(f"| {row['rank']} | {row['id']} | {example['kind']} | {md(status)} | "
                   f"{md(example.get('fr'))} | {md(example.get('en'))} | {md(source)} |")
    return "\n".join(out)


def build_picks(verbs, records):
    picks = []
    for identifier, record in records.items():
        example = record.get("new_example")
        if not example or example.get("kind") == "authored":
            continue
        status, detail, candidate = validator.pick_status(example, verbs[identifier])
        picks.append({"id": identifier, "rank": verbs[identifier]["rank"], "example": example,
                      "status": status, "detail": detail, "candidate": candidate})
    picks.sort(key=lambda p: (PICK_STATUS_ORDER.index(p["status"]) if p["status"] not in CLEAN_PICKS
                              else len(PICK_STATUS_ORDER), p["rank"], p["id"]))
    return picks


HAND_FIELDS = ("decision", "value", "note")


def carry_over_decisions(approvals):
    """Keep what Josh (or a triage) wrote in the previous approvals.json across a rebuild.

    An item's decision, value and note survive, and so does an item the builder no longer
    generates (a hand-added `late_edition` pick, say). Hand-edited `defaults` survive whole.
    Without this, re-running the report would silently reset every decision to pending.
    """
    if not APPROVALS.exists():
        return 0
    previous = lib.load_json(APPROVALS)
    if any(rule.get("decision") != "pending" for rule in previous.get("defaults", [])):
        approvals["defaults"] = previous["defaults"]
    carried = 0
    for key, old in previous.get("items", {}).items():
        hand = {field: old[field] for field in HAND_FIELDS
                if field in old and old[field] not in (None, "pending")}
        if key not in approvals["items"]:
            if key.startswith(ADDED_PREFIX):
                continue
            approvals["items"][key] = old
            carried += 1
        elif hand:
            approvals["items"][key].update(hand)
            carried += 1
    return carried


def band_label(low, high):
    return f"{low:,}–{high:,}" if high else f"{low:,}+"


PRIOR_TITLES = {
    "removed": "flawed example removed in Stage 4",
    "en_quotation": "English-Wiktionary quotation under copyright",
    "pick_rejected": "pick rejected in review",
    "pick_provenance": "pick with a provenance warning",
    "authored_refuted": "authored sentence refuted",
    "authored_rejected": "authored sentence rejected in review",
    "none_proposed": "nothing proposed",
    "stage5_refuted": "Stage 5 proposal refuted, tried again (5b–5e)",
    "stage5_replaced": "Stage 5 example replaced at Josh's request",
    "other": "other",
}


def latest_attempts(items):
    """The last example item per verb, and the last gloss item, so a retry (a later shard)
    supersedes the refuted attempt. Gloss items come only from Stage 5c."""
    latest = {}
    for item in items:
        latest[(item["id"], item["task"] == "gloss")] = item
    superseded = len(items) - len(latest)
    order = sorted(latest.values(), key=lambda i: (i["rank"], i["id"], i["task"] != "gloss"))
    return order, superseded


def stage5_source(item):
    proposed, candidate = item["proposed"], item.get("candidate") or {}
    if proposed.get("kind") == "authored":
        return proposed.get("source")
    if proposed.get("kind") == "tier":
        return f"{candidate.get('source') or proposed.get('source')}:{candidate.get('line') or proposed.get('line')}"
    parts = [candidate.get("author"), candidate.get("translator") and f"trans. {candidate['translator']}",
             candidate.get("title"), candidate.get("year"),
             candidate.get("death_year") and f"d. {candidate['death_year']}"]
    return f"{proposed.get('kind')}: " + (", ".join(str(part) for part in parts if part) or "editors' usage example")


def stage5_block(item):
    proposed, skeptic, prior = item["proposed"], item["skeptic"], item.get("prior") or {}
    verdict = skeptic["verdict"] + (f", {skeptic['severity']}" if skeptic.get("severity") else "")
    lines = [f"#### {item['id']} (rank {item['rank']})",
             f"- **Gloss:** {md(item['gloss_current'])}",
             f"- **French:** {md(proposed.get('fr'))}",
             f"- **English:** {md(proposed.get('en'))}",
             f"- **Source:** {md(stage5_source(item))}"
             + (f" · provenance `{item['pick_status']}`" if item.get("pick_status") else "")
             + f" · token {md(proposed.get('token'))}",
             f"- **Before:** {PRIOR_TITLES.get(prior.get('reason'), prior.get('reason'))}",
             f"- **Skeptic:** {verdict}. {md(skeptic.get('reason'))}"]
    for note in item.get("checker_notes") or []:
        lines.append(f"- *Note:* {md(note)}")
    return "\n".join(lines)


def main_stage5(report, approvals_path):
    """Stage 5.5: every item is a new example, authored or picked, judged by the skeptic."""
    global APPROVALS
    APPROVALS = approvals_path
    verbs, records = load_stage2()
    every = load_skeptic()
    first = {}
    for item in every:
        if item["task"] != "gloss":
            first.setdefault(item["id"], item)
    first_refuted = sum(1 for i in first.values() if i["skeptic"]["verdict"] == "refuted")
    items, superseded = latest_attempts(every)
    glosses = [i for i in items if i["task"] == "gloss"]
    standing_glosses = {g["id"] for g in glosses if g["skeptic"]["verdict"] in ("upheld", "partly")}
    orphans = [i["id"] for i in items if i["task"] != "gloss" and i.get("gloss_proposed")
               and i["id"] not in standing_glosses]
    items = [i for i in items if i["task"] != "gloss"]
    listed = lib.load_json(validator.STAGE5 / "verbs.json")
    today = datetime.date.today().isoformat()
    kind_of = {i["id"]: ("authored" if i["proposed"].get("kind") == "authored" else "pick") for i in items}
    tally = collections.defaultdict(collections.Counter)
    for item in items:
        tally[kind_of[item["id"]]][item["skeptic"]["verdict"]] += 1
    by_prior = collections.defaultdict(collections.Counter)
    for item in items:
        by_prior[(item.get("prior") or {}).get("reason")][item["skeptic"]["verdict"]] += 1
    unchecked = [row for row in listed if row["id"] not in kind_of]
    standing = [i for i in items if i["skeptic"]["verdict"] in ("upheld", "partly")]
    without = [i for i in items if i["skeptic"]["verdict"] not in ("upheld", "partly")]
    judged = sum(tally[k][v] for k in tally for v in ("upheld", "partly", "refuted"))
    refuted = sum(tally[k]["refuted"] for k in tally)
    pending = sum(tally[k]["pending"] for k in tally)
    rate = f"{refuted / judged:.1%}" if judged else "n/a"
    flagged_notes = [(verbs[i]["rank"], i, r["notes"]) for i, r in records.items() if r.get("notes")]
    flagged_notes.sort(key=lambda row: (row[0], row[1]))

    out = [f"# Verb pass report, Stage 5 ({today})", "",
           "Generated by `corpus/working/build_report.py --pass-dir corpus/working/verb_pass/stage5` from the "
           "Stage 5 check results and skeptic verdicts; see Stage 5 of `prompts/verb-pass-plan.md`. Do not edit "
           "by hand: re-run the script. Decisions go in `corpus/working/verb_pass/stage5/approvals.json`, which "
           "the same run writes. Stage 5 is example-only: it took the "
           f"{len(listed):,} verb entries that still had no example after Stage 4 through the pass again, and "
           "the skeptic read every proposal, corpus and quotation picks included.", "",
           "## Counts", "",
           "| Proposal | Items | Upheld | Partly | Refuted | Pending |", "|---|---|---|---|---|---|"]
    for kind in ("authored", "pick"):
        row = tally[kind]
        out.append(f"| {kind} | {sum(row.values()):,} | " + " | ".join(f"{row[v]:,}" for v in VERDICTS) + " |")
    total = collections.Counter()
    for row in tally.values():
        total.update(row)
    out.append(f"| **All** | **{sum(total.values()):,}** | " +
               " | ".join(f"**{total[v]:,}**" for v in VERDICTS) + " |")
    out += ["", f"Refutation rate over the {judged:,} judged items: **{rate}**." +
            (f" {pending:,} items have no valid verdict yet." if pending else "") +
            (f" Each verb is counted once, by its latest attempt: {superseded:,} refuted proposals were "
             "tried again (Stages 5b–5e), and the retry replaces them here. Counting first attempts only, "
             f"the skeptic refuted {first_refuted:,} of {len(first):,} ({first_refuted / len(first):.1%})."
             if superseded and first else ""), "",
            *([f"**Warning:** {len(orphans)} example(s) fit only a gloss proposal the skeptic refuted: "
               + ", ".join(orphans) + "."] if orphans else []), "",
            f"**{len(standing):,} verbs have an example standing for review. {len(without) + len(unchecked):,} "
            "stay without one** if the review accepts everything that stands"
            + (f", {len(unchecked):,} of them because their check shard has no valid result yet" if unchecked else "")
            + ".", "",
            "### By why the verb had no example before", "",
            "| Before | Verbs | Upheld | Partly | Refuted | Pending |", "|---|---|---|---|---|---|"]
    for reason, title in PRIOR_TITLES.items():
        row = by_prior.get(reason)
        if row:
            out.append(f"| {title} | {sum(row.values()):,} | " + " | ".join(f"{row[v]:,}" for v in VERDICTS) + " |")
    if glosses:
        gloss_standing = [g for g in glosses if g["skeptic"]["verdict"] in ("upheld", "partly")]
        out += ["", "## Glosses (Stage 5c)", "",
                f"{len(glosses):,} gloss changes proposed in Stage 5c, for verbs whose example kept failing "
                f"because the gloss misstated the verb; {len(gloss_standing):,} stand. Each was proposed with "
                "CNRTL dictionary evidence (TLFi, Académie, Littré) and judged by the skeptic. A verb's "
                "example below may fit only its proposed gloss, so accept or reject the two together.", ""]
        for item in glosses:
            skeptic = item["skeptic"]
            out += [f"#### {item['id']} (rank {item['rank']})",
                    f"- **Gloss:** {md(item['current'])} → **{md(item['proposed'])}**",
                    f"- **Checker:** `{item['checker_verdict']}`, {item.get('checker_confidence')} confidence. "
                    f"{md(item['evidence'])}",
                    f"- **Skeptic:** {skeptic['verdict']}"
                    + (f", {skeptic['severity']}" if skeptic.get("severity") else "") + f". {md(skeptic.get('reason'))}",
                    ""]
    out += ["", "## Examples standing", "",
            f"{len(standing):,} upheld or partly, in rank order. A `partly` verdict says what would fix the "
            "item; type the corrected French and English as its value, or reject it.", ""]
    for item in standing:
        out += [stage5_block(item), ""]
    out += ["## Verbs that stay without an example", "",
            "Each verb below stays without an example: the skeptic refuted its Stage 5 proposal"
            + (", or it has no valid check result yet" if unchecked else "") + ". The reason says what was wrong.", "",
            "| Rank | Verb | Gloss | Proposed | Source | Skeptic’s reason |", "|---|---|---|---|---|---|"]
    for item in without:
        out.append(f"| {item['rank']} | {item['id']} | {md(item['gloss_current'])} | "
                   f"{md(item['proposed'].get('fr'))} | {md(stage5_source(item))} | "
                   f"{md(item['skeptic'].get('reason'))} |")
    for row in unchecked:
        out.append(f"| {row['rank']} | {row['id']} | {md(row['gloss'])} | — | — | no valid check result |")
    out += ["", "## Gloss and flag remarks for a later pass", "",
            "Stage 5 checkers were told to leave glosses and flags alone and to note anything wrong. "
            f"{len(flagged_notes):,} verbs carry notes; they are not decisions.", ""]
    for rank, identifier, notes in flagged_notes:
        out.append(f"- **{identifier}** ({rank}): " + " · ".join(md(n) for n in notes))
    out.append("")
    report.write_text("\n".join(out), encoding="utf-8")
    print(f"  wrote {report.relative_to(lib.REPO)} ({report.stat().st_size:,} bytes)")

    approvals = {
        "_readme": [
            "Stage 5. Set each decision to accept or reject; Stage 5.6 applies only accept. review means "
            "a human still has to look, and nothing applies it.",
            "An item's own decision wins. A pending item takes the first default whose task and rank band "
            "match it (max_rank null means no upper bound); a default never applies to a partly item. All "
            "defaults start pending.",
            "Keys are new_example|<verb id> for an authored sentence and pick|<verb id> for a corpus or "
            "quotation pick. A partly item may carry a value {\"fr\", \"en\"}; accept without one applies "
            "the proposal unchanged.",
            "Re-running build_report.py keeps every decision, value and note here.",
        ],
        "defaults": [{"task": task, "min_rank": low, "max_rank": high, "decision": "pending"}
                     for task in ("new_example", "pick", "gloss") for low, high in BANDS],
        "items": {},
    }
    for item in standing:
        entry = {"decision": "pending", "rank": item["rank"], "verdict": item["skeptic"]["verdict"],
                 "severity": item["skeptic"].get("severity")}
        if item.get("pick_status"):
            entry["status"] = item["pick_status"]
        if item["skeptic"]["verdict"] == "partly":
            entry["value"] = None
            if apostrophe_partly(item):
                entry["apostrophe"] = True
        approvals["items"][item_key(item)] = entry
    for item in glosses:
        verdict = item["skeptic"]["verdict"]
        if verdict in ("upheld", "partly"):
            entry = {"decision": "pending", "rank": item["rank"], "verdict": verdict,
                     "severity": item["skeptic"].get("severity")}
            if verdict == "partly":
                entry["value"] = None
            approvals["items"][item_key(item)] = entry
    carried = carry_over_decisions(approvals)
    lib.write_json(APPROVALS, approvals)
    print(f"  kept {carried:,} hand-made decision(s) from the previous approvals.json")
    if glosses:
        print(f"  Stage 5c glosses: {len(glosses)} proposed, "
              f"{sum(1 for g in glosses if g['skeptic']['verdict'] in ('upheld', 'partly'))} standing")
    print(f"  {len(approvals['items']):,} approval items; judged {judged:,}, refuted {refuted:,} ({rate}), "
          f"pending {pending:,}; {len(without) + len(unchecked):,} verbs stay without an example")


def main():
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("--pass-dir", help="a pass directory other than verb_pass/ (Stage 5: "
                                           "corpus/working/verb_pass/stage5)")
    options = parser.parse_args()
    if options.pass_dir:
        directory = (lib.REPO / options.pass_dir).resolve()
        if directory != validator.STAGE5.resolve():
            sys.exit("--pass-dir supports only corpus/working/verb_pass/stage5")
        validator.use_pass_dir(validator.STAGE5, example_only=True)
        main_stage5(lib.REPO / "docs" / "verb-pass-report-stage5.md", validator.STAGE5 / "approvals.json")
        return
    verbs, records = load_stage2()
    items = load_skeptic()
    picks = build_picks(verbs, records)
    added = load_added({v["id"]: v for v in lib.load_verbs()})
    today = datetime.date.today().isoformat()

    tally = collections.defaultdict(collections.Counter)
    severity = collections.defaultdict(collections.Counter)
    for item in items:
        tally[item["task"]][item["skeptic"]["verdict"]] += 1
        if item["skeptic"].get("severity"):
            severity[item["skeptic"]["verdict"]][item["skeptic"]["severity"]] += 1
    pick_tally = collections.Counter((p["example"]["kind"], p["status"]) for p in picks)
    unsure = [(verbs[i]["rank"], i, flag) for i, r in records.items()
              for flag in r.get("flags") or [] if flag.get("verdict") == "unsure"]
    unsure.sort(key=lambda row: (row[0], row[1]))
    judged = sum(tally[t][v] for t in TASKS for v in ("upheld", "partly", "refuted"))
    refuted = sum(tally[t]["refuted"] for t in TASKS)
    pending = sum(tally[t]["pending"] for t in TASKS)

    out = [f"# Verb pass report ({today})", "",
           "Generated by `corpus/working/build_report.py` from the Stage 2 results and the Stage 3 "
           "skeptic verdicts; see `prompts/verb-pass-plan.md`. Do not edit by hand: re-run the script. "
           "Decisions go in `corpus/working/verb_pass/approvals.json`, which the same run writes.", "",
           "## Counts", "",
           "### Skeptic verdicts by task", "",
           "| Task | Items | Upheld | Partly | Refuted | Pending |", "|---|---|---|---|---|---|"]
    for task in TASKS:
        row = tally[task]
        out.append(f"| {TASK_TITLES[task]} | {sum(row.values()):,} | " +
                   " | ".join(f"{row[v]:,}" for v in VERDICTS) + " |")
    total = collections.Counter()
    for task in TASKS:
        total.update(tally[task])
    out.append(f"| **All** | **{sum(total.values()):,}** | " +
               " | ".join(f"**{total[v]:,}**" for v in VERDICTS) + " |")
    rate = f"{refuted / judged:.1%}" if judged else "n/a"
    out += ["", f"Refutation rate over the {judged:,} judged items: **{rate}**." +
            (f" {pending:,} items have no valid verdict yet." if pending else ""), "",
            "### Severity by verdict", "",
            "| Verdict | Error | Hedge | Nitpick |", "|---|---|---|---|"]
    for verdict in ("upheld", "partly", "refuted"):
        row = severity[verdict]
        out.append(f"| {verdict} | {row['error']:,} | {row['hedge']:,} | {row['nitpick']:,} |")
    out += ["", "### Corpus and quotation picks (checked in code, not by the skeptic)", "",
            "| Kind | " + " | ".join(PICK_STATUS_ORDER) + " |",
            "|---|" + "---|" * len(PICK_STATUS_ORDER)]
    for kind in ("tier", "wiktionnaire", "wiktionary_en"):
        out.append(f"| {kind} | " + " | ".join(f"{pick_tally[(kind, s)]:,}" for s in PICK_STATUS_ORDER) + " |")
    out += ["", "`verbatim` and `excerpt` are clean; `excerpt` is one whole sentence lifted unchanged "
            "out of a longer candidate. `late_edition` is a quotation printed more than twenty years "
            "after its author's death: usually a reprint, but the class also holds translations of "
            "foreign authors and Wikidata namesakes, which the death-year rule passes, so each needs a "
            "human look and none is in approvals.json. Every other status is a provenance warning. Stage 4 copies "
            "`source` and `line` from the matched candidate, never from the result file.", "",
            f"{sum(1 for i in items if apostrophe_partly(i)):,} `partly` verdicts on examples mention the "
            "apostrophe. The skeptics applied decision 3's curly apostrophe, which is the *gloss* house "
            "style, to example sentences, but all 1,141 shipped examples use the straight one. Where the "
            "apostrophe is the only objection, the item is effectively upheld; those carry "
            "`\"apostrophe\": true` in approvals.json.", "",
            f"{sum(1 for i in items if parenthesis_gloss(i)):,} gloss verdicts object to a parenthesis "
            "under decision 3's original \"parentheses only for register or region\". Josh amended the "
            "rule on 2026-09-27: a parenthesis may also fix which sense of an ambiguous English word is "
            "meant, as in \"put down (set down)\", where a bare \"put down\" could read as an insult. "
            "Upheld and partly ones carry `\"parenthesis\": true` in approvals.json.", "",
            f"{sum(1 for i in items if length_gloss(i) and i['skeptic']['verdict'] in ('upheld', 'partly')):,} "
            "upheld or partly gloss items lean on length (a word count, the definition_like lint, or "
            "\"short enough to read aloud\"). Josh dropped that rule on 2026-09-27, after réaliser's "
            "eight live senses were cut to three. They carry `\"length\": true` in approvals.json.", "",
            f"Unsure flag verdicts, left for Josh: **{len(unsure)}**. "
            f"Entries carrying checker notes: **{sum(1 for r in records.values() if r.get('notes')):,}**.",
            ""]

    for task in TASKS:
        standing = [i for i in items if i["task"] == task and i["skeptic"]["verdict"] in ("upheld", "partly")]
        waiting = [i for i in items if i["task"] == task and i["skeptic"]["verdict"] == "pending"]
        out += [f"## {TASK_TITLES[task]}", "",
                f"{len(standing):,} upheld or partly, in rank order. Refuted items are in the appendix."
                + (f" {len(waiting):,} still await a verdict and are listed with them." if waiting else ""), ""]
        for item in standing + waiting:
            out += [item_block(item), ""]

    out += ["## Added glosses", "",
            f"{len(added):,} gloss changes that no checker raised, from `corpus/working/added_glosses.json`. "
            "No skeptic judged them, and no default rule decides them.", ""]
    for entry in added:
        out += [f"#### {entry['id']} (rank {entry['rank']})", "",
                f"- **Gloss:** {md(entry['current'])} → **{md(entry['proposed'])}**",
                f"- **Why ({entry['origin']}):** {md(entry['reason'])}", ""]

    out += ["## Corpus and quotation picks", "",
            f"{len(picks):,} picks, provenance warnings first, then clean picks in rank order.", "",
            picks_table(picks), ""]

    out += ["## Unsure flag verdicts", "", "| Rank | Verb | Flag | Checker’s reason |", "|---|---|---|---|"]
    for rank, identifier, flag in unsure:
        out.append(f"| {rank} | {identifier} | `{flag.get('flag')}` | {md(flag.get('reason'))} |")
    out.append("")

    shown = {i["id"] for i in items if i["skeptic"]["verdict"] != "refuted"}
    other_notes = sorted(((verbs[i]["rank"], i, r["notes"]) for i, r in records.items()
                          if r.get("notes") and i not in shown), key=lambda row: (row[0], row[1]))
    out += ["## Other checker notes", "",
            f"Notes on the {len(other_notes):,} verbs not shown in a section above. They mostly explain "
            "why a candidate sentence was passed over.", ""]
    for rank, identifier, notes in other_notes:
        out.append(f"- **{identifier}** ({rank}): " + " · ".join(md(n) for n in notes))
    out.append("")

    refuted_items = [i for i in items if i["skeptic"]["verdict"] == "refuted"]
    out += ["## Appendix: refuted items", "",
            "| Rank | Verb | Task | Proposed | Severity | Skeptic’s reason |", "|---|---|---|---|---|---|"]
    for item in refuted_items:
        proposed = item["proposed"]
        if item["task"] == "new_example":
            proposed = proposed.get("fr")
        elif item["task"] == "example":
            proposed = f"{item['checker_verdict']}: {(proposed or {}).get('proposed_en') or '—'}"
        elif item["task"] == "flag":
            proposed = f"{item['flag']} → {show(proposed)}"
        out.append(f"| {item['rank']} | {item['id']} | {item['task']} | {md(proposed)} | "
                   f"{item['skeptic'].get('severity')} | {md(item['skeptic'].get('reason'))} |")
    out.append("")
    REPORT.write_text("\n".join(out), encoding="utf-8")
    print(f"  wrote {REPORT.relative_to(lib.REPO)} ({REPORT.stat().st_size:,} bytes)")

    approvals = {
        "_readme": [
            "Set each decision to accept or reject. Stage 4 applies only accept. review means a human "
            "still has to look: no default touches it and Stage 4 does not apply it.",
            "An item's own decision wins. An item still pending takes the first default whose task "
            "and rank band match it (max_rank null means no upper bound); a default never applies "
            "to a partly item. Anything still pending is not applied.",
            "Keys are <task>|<verb id>; flags are flag:<name>|<verb id>; corpus and quotation picks "
            "are pick|<verb id>. A partly item needs a value: put the replacement in value, or its "
            "accept applies the checker's proposal unchanged. A value is a string (the gloss, the "
            "English translation, or the flag value), except on a new_example, where it is "
            "{\"fr\", \"en\"}.",
            "gloss:added|<verb id> is a gloss change no checker raised, from "
            "corpus/working/added_glosses.json, whose proposed text an accept without a value "
            "applies. Like a partly item, a default never applies to it.",
            "Re-running build_report.py keeps every decision, value and note here, and any item added "
            "by hand.",
        ],
        "defaults": [{"task": task, "min_rank": low, "max_rank": high, "decision": "pending"}
                     for task in ("gloss", "example", "new_example", "flag", "pick")
                     for low, high in BANDS],
        "items": {},
    }
    for item in items:
        verdict = item["skeptic"]["verdict"]
        if verdict not in ("upheld", "partly"):
            continue
        entry = {"decision": "pending", "rank": item["rank"], "verdict": verdict,
                 "severity": item["skeptic"].get("severity")}
        if verdict == "partly":
            entry["value"] = None
            if apostrophe_partly(item):
                entry["apostrophe"] = True
        if parenthesis_gloss(item):
            entry["parenthesis"] = True
        if length_gloss(item):
            entry["length"] = True
        approvals["items"][item_key(item)] = entry
    for entry in added:
        if f"gloss|{entry['id']}" in approvals["items"]:
            sys.exit(f"added_glosses.json: {entry['id']} already has a gloss card; note it there instead")
        approvals["items"][ADDED_PREFIX + entry["id"]] = {"decision": "pending", "rank": entry["rank"],
                                                          "verdict": "added", "value": None}
    for pick in picks:
        if pick["status"] in CLEAN_PICKS:
            approvals["items"][f"pick|{pick['id']}"] = {"decision": "pending", "rank": pick["rank"],
                                                        "status": pick["status"]}
    carried = carry_over_decisions(approvals)
    lib.write_json(APPROVALS, approvals)
    print(f"  kept {carried:,} hand-made decision(s) from the previous approvals.json")
    print(f"  {len(approvals['items']):,} approval items; skeptic items judged {judged:,}, "
          f"refuted {refuted:,} ({rate}), pending {pending:,}")


if __name__ == "__main__":
    main()
