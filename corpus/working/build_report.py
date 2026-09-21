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

Usage:
    python3 corpus/working/build_report.py
"""
import collections
import datetime
import json

import validate_verb_pass as validator
import verb_pass_lib as lib

REPORT = lib.REPO / "docs" / "verb-pass-report.md"
APPROVALS = lib.OUT_DIR / "approvals.json"
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


def item_key(item):
    task = f"flag:{item['flag']}" if item["task"] == "flag" else item["task"]
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
            approvals["items"][key] = old
            carried += 1
        elif hand:
            approvals["items"][key].update(hand)
            carried += 1
    return carried


def band_label(low, high):
    return f"{low:,}–{high:,}" if high else f"{low:,}+"


def main():
    verbs, records = load_stage2()
    items = load_skeptic()
    picks = build_picks(verbs, records)
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
        approvals["items"][item_key(item)] = entry
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
