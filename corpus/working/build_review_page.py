#!/usr/bin/env python3
"""Build a local review page for the verb-pass approvals, and merge its decisions back.

Stage 3 of prompts/verb-pass-plan.md, for Josh's reading of approvals.json. The page shows
every item that the `defaults` rules leave to a human (all `partly` items, anything held for
`review`, and anything no default accepts), one at a time, with the current and proposed
values and both models' reasoning. Keys: A accept, R reject, E edit the value, U undo,
J/→ next, K/← previous. Decisions are kept in the browser's localStorage and exported as a
JSON file, which --merge folds into approvals.json.

Usage:
    python3 corpus/working/build_review_page.py               # writes verb_pass/review.html
    open corpus/working/verb_pass/review.html
    python3 corpus/working/build_review_page.py --merge ~/Downloads/verb-pass-decisions.json

Rebuild the page after changing `defaults`, since the item list depends on them.
"""
import argparse
import json
import sys

import build_report
import verb_pass_lib as lib

PAGE = lib.OUT_DIR / "review.html"
DECISIONS = {"accept", "reject", "review", "pending"}


def default_decision(approvals, task, rank):
    for rule in approvals["defaults"]:
        high = rule.get("max_rank")
        if rule["task"] == task and rule["min_rank"] <= rank and (high is None or rank <= high):
            if rule["decision"] != "pending":
                return rule["decision"]
    return None


def task_of(key):
    task = key.split("|", 1)[0]
    return "flag" if task.startswith("flag:") else task


def needs_a_human(key, entry, approvals):
    if entry["decision"] not in ("pending", "review"):
        return True
    if entry["decision"] == "review" or entry.get("verdict") == "partly":
        return True
    return default_decision(approvals, task_of(key), entry["rank"]) is None


def band(rank):
    for low, high in build_report.BANDS:
        if rank >= low and (high is None or rank <= high):
            return build_report.band_label(low, high)
    return "?"


def skeptic_record(item, entry):
    record = {
        "key": build_report.item_key(item),
        "id": item["id"], "rank": item["rank"], "band": band(item["rank"]),
        "task": task_of(build_report.item_key(item)),
        "verdict": item["skeptic"]["verdict"], "severity": item["skeptic"].get("severity"),
        "reason": item["skeptic"].get("reason"),
        "decision": entry["decision"], "value": entry.get("value"), "note": entry.get("note"),
        "apostrophe": bool(entry.get("apostrophe")),
        "gloss": item.get("gloss_current"),
        "notes": item.get("checker_notes") or [],
    }
    task = item["task"]
    if task == "gloss":
        record.update(current=item["current"], proposed=item["proposed"],
                      checker=f"{item['checker_verdict']}, {item.get('checker_confidence')} confidence",
                      evidence=item["evidence"])
    elif task == "example":
        current = item["current"] or {}
        proposed = item["proposed"] or {}
        replacement = proposed.get("replacement") or {}
        record.update(current=f"{current.get('fr')}\n{current.get('en')}\n({current.get('source')})",
                      proposed=proposed.get("proposed_en"),
                      replacement=(f"{replacement.get('fr')}\n{replacement.get('en')} "
                                   f"({replacement.get('kind')})") if replacement else None,
                      checker=item["checker_verdict"],
                      evidence=build_report.evidence_text(item["evidence"]))
    elif task == "new_example":
        proposed = item["proposed"]
        record.update(current=None, proposed={"fr": proposed.get("fr"), "en": proposed.get("en")},
                      token=proposed.get("token"), gloss_proposed=item.get("gloss_proposed"),
                      candidates=[f"[{c.get('kind')}] {c.get('text')}" for c in item.get("candidates") or []],
                      checker="authored")
    else:
        record.update(current=build_report.show(item["current"]),
                      proposed=build_report.show(item["proposed"]),
                      checker=f"flag {item['flag']}", evidence=item["evidence"])
    return record


def pick_record(pick, key, entry):
    candidate = pick["candidate"] or {}
    source = (f"{candidate.get('source')}:{candidate.get('line')}" if pick["example"]["kind"] == "tier"
              else ", ".join(str(part) for part in (candidate.get("author"), candidate.get("title"),
                                                     candidate.get("year")) if part))
    return {
        "key": key, "id": pick["id"], "rank": pick["rank"], "band": band(pick["rank"]), "task": "pick",
        "verdict": pick["status"], "severity": None, "reason": pick["detail"] or None,
        "decision": entry["decision"], "value": None, "note": entry.get("note"), "apostrophe": False,
        "gloss": None, "notes": [], "current": None,
        "proposed": {"fr": pick["example"].get("fr"), "en": pick["example"].get("en")},
        "checker": f"{pick['example']['kind']} pick", "evidence": source,
        "death_year": candidate.get("death_year"),
    }


def build():
    approvals = lib.load_json(build_report.APPROVALS)
    verbs, records = build_report.load_stage2()
    items = {build_report.item_key(i): i for i in build_report.load_skeptic()}
    picks = {f"pick|{p['id']}": p for p in build_report.build_picks(verbs, records)}
    rows = []
    for key, entry in approvals["items"].items():
        if not needs_a_human(key, entry, approvals):
            continue
        if key in items:
            rows.append(skeptic_record(items[key], entry))
        elif key in picks:
            rows.append(pick_record(picks[key], key, entry))
    order = {"gloss": 0, "example": 1, "flag": 2, "new_example": 3, "pick": 4}
    rows.sort(key=lambda r: (order[r["task"]], r["rank"], r["key"]))
    html = TEMPLATE.replace("/*DATA*/null", json.dumps(rows, ensure_ascii=False).replace("</", "<\\/"))
    PAGE.write_text(html, encoding="utf-8")
    counts = {}
    for row in rows:
        counts[row["task"]] = counts.get(row["task"], 0) + 1
    print(f"  wrote {PAGE.relative_to(lib.REPO)} ({PAGE.stat().st_size:,} bytes): {len(rows):,} items, "
          + ", ".join(f"{task} {count}" for task, count in counts.items()))


def merge(path):
    approvals = lib.load_json(build_report.APPROVALS)
    decisions = lib.load_json(path)
    changed, unknown = 0, []
    for key, decision in decisions.items():
        entry = approvals["items"].get(key)
        if entry is None:
            unknown.append(key)
            continue
        if decision.get("decision") not in DECISIONS:
            sys.exit(f"{key}: decision {decision.get('decision')!r}")
        before = (entry.get("decision"), entry.get("value"))
        entry["decision"] = decision["decision"]
        if decision.get("value") not in (None, ""):
            entry["value"] = decision["value"]
        if (entry.get("decision"), entry.get("value")) != before:
            changed += 1
    if unknown:
        sys.exit(f"{len(unknown)} key(s) not in approvals.json, nothing written: {', '.join(unknown[:5])}")
    lib.write_json(build_report.APPROVALS, approvals)
    tally = {}
    for entry in approvals["items"].values():
        tally[entry["decision"]] = tally.get(entry["decision"], 0) + 1
    print(f"  merged {len(decisions):,} decision(s), {changed:,} changed; approvals now "
          + ", ".join(f"{k} {v:,}" for k, v in sorted(tally.items())))


TEMPLATE = r"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Verb Pass Review</title>
<style>
:root { --bg:#fbfaf7; --card:#fff; --ink:#1d1d1f; --muted:#6e6e73; --line:#e3e1dc;
  --accept:#1f7a3a; --reject:#b3261e; --review:#8a5a00; --accent:#2f5bb7; --chip:#f0eee9; }
@media (prefers-color-scheme: dark) { :root { --bg:#161617; --card:#1f1f21; --ink:#f2f2f2; --muted:#a1a1a6;
  --line:#343437; --accept:#4cc27a; --reject:#ff7a70; --review:#e0b04a; --accent:#8fb0ff; --chip:#2a2a2d; } }
* { box-sizing:border-box; }
body { margin:0; background:var(--bg); color:var(--ink); font:15px/1.5 -apple-system, "SF Pro Text", system-ui, sans-serif; }
header { position:sticky; top:0; background:var(--bg); border-bottom:1px solid var(--line); padding:10px 16px; z-index:2; }
.bar { display:flex; flex-wrap:wrap; gap:8px; align-items:center; max-width:980px; margin:0 auto; }
select, button, input { font:inherit; color:inherit; background:var(--card); border:1px solid var(--line); border-radius:8px; padding:5px 10px; }
button { cursor:pointer; }
button.accept { border-color:var(--accept); color:var(--accept); }
button.reject { border-color:var(--reject); color:var(--reject); }
button.review { border-color:var(--review); color:var(--review); }
.progress { margin-left:auto; color:var(--muted); font-variant-numeric:tabular-nums; }
main { max-width:980px; margin:16px auto; padding:0 16px 80px; }
.card { background:var(--card); border:1px solid var(--line); border-radius:14px; padding:20px 22px; }
h1 { font-size:24px; margin:0 0 2px; }
.meta { color:var(--muted); margin-bottom:14px; }
.chip { display:inline-block; background:var(--chip); border-radius:999px; padding:1px 9px; margin-right:6px; font-size:13px; }
.chip.decided-accept { background:var(--accept); color:#fff; } .chip.decided-reject { background:var(--reject); color:#fff; }
.chip.decided-review { background:var(--review); color:#fff; }
.row { display:grid; grid-template-columns:140px 1fr; gap:4px 16px; padding:8px 0; border-top:1px solid var(--line); }
.row > div:first-child { color:var(--muted); font-size:13px; padding-top:2px; }
.big { font-size:18px; white-space:pre-wrap; }
.proposed { color:var(--accent); font-weight:600; }
.pre { white-space:pre-wrap; }
ul { margin:0; padding-left:18px; }
.actions { display:flex; gap:10px; margin-top:18px; flex-wrap:wrap; }
.actions button { padding:8px 16px; font-weight:600; }
textarea { width:100%; font:inherit; color:inherit; background:var(--bg); border:1px solid var(--line); border-radius:8px; padding:8px; min-height:60px; }
.hint { color:var(--muted); font-size:13px; margin-top:12px; }
.empty { text-align:center; color:var(--muted); padding:60px 0; }
@media (max-width:600px) { .row { grid-template-columns:1fr; } }
</style>
</head>
<body>
<header><div class="bar">
  <select id="task"><option value="">All tasks</option><option value="gloss">Glosses</option>
    <option value="example">Existing examples</option><option value="flag">Flags</option>
    <option value="new_example">Authored examples</option><option value="pick">Picks</option></select>
  <select id="verdict"><option value="">Any verdict</option><option value="upheld">upheld</option>
    <option value="partly">partly</option><option value="apostrophe">partly, apostrophe</option>
    <option value="late_edition">late_edition</option><option value="verbatim">verbatim</option></select>
  <select id="bandsel"><option value="">All ranks</option></select>
  <select id="state"><option value="open">Undecided or held</option><option value="all">All</option>
    <option value="decided">Decided</option></select>
  <input id="jump" placeholder="Go to verb" size="12">
  <button id="export">Export decisions</button>
  <label><button id="importbtn" type="button">Import</button><input id="import" type="file" accept=".json" hidden></label>
  <span class="progress" id="progress"></span>
</div></header>
<main id="main"></main>
<script>
const DATA = /*DATA*/null;
const STORE = "verb-pass-review-v1";
let saved = {};
try { saved = JSON.parse(localStorage.getItem(STORE) || "{}"); } catch (e) { saved = {}; }
const byKey = Object.fromEntries(DATA.map(r => [r.key, r]));
function isOpen(d) { return d === "pending" || d === "review"; }
function state(r) { return saved[r.key] || { decision: r.decision, value: r.value }; }
function persist() { try { localStorage.setItem(STORE, JSON.stringify(saved)); } catch (e) {} }
const $ = id => document.getElementById(id);
[...new Set(DATA.map(r => r.band))].forEach(b => { const o = document.createElement("option"); o.value = b; o.textContent = "Ranks " + b; $("bandsel").append(o); });
let list = [], pos = 0, editing = false;
function filter() {
  const t = $("task").value, v = $("verdict").value, b = $("bandsel").value, s = $("state").value;
  list = DATA.filter(r => (!t || r.task === t) && (!b || r.band === b)
    && (!v || (v === "apostrophe" ? r.apostrophe : r.verdict === v))
    && (s === "all" || (s === "open") === isOpen(state(r).decision)));
  pos = Math.min(pos, Math.max(0, list.length - 1));
}
function esc(s) { return String(s ?? "—").replace(/[&<>"]/g, c => ({ "&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;" }[c])); }
function show(v) { if (v == null) return "—"; if (typeof v === "object") return (v.fr || "") + "\n" + (v.en || ""); return v; }
function row(label, html) { return `<div class="row"><div>${label}</div><div>${html}</div></div>`; }
function render() {
  const decided = DATA.filter(r => !isOpen(state(r).decision)).length;
  $("progress").textContent = `${decided.toLocaleString()} of ${DATA.length.toLocaleString()} decided · ${list.length ? pos + 1 : 0} / ${list.length.toLocaleString()} in view`;
  if (!list.length) { $("main").innerHTML = `<div class="empty">Nothing matches. Change the filters.</div>`; return; }
  const r = list[pos], st = state(r);
  let h = `<div class="card"><h1>${esc(r.id)}</h1><div class="meta"><span class="chip">${esc(r.task)}</span><span class="chip">rank ${r.rank}</span>`
    + `<span class="chip">${esc(r.verdict)}${r.severity ? ", " + esc(r.severity) : ""}</span>`
    + (r.apostrophe ? `<span class="chip">apostrophe</span>` : "")
    + `<span class="chip decided-${esc(st.decision)}">${esc(st.decision)}</span></div>`;
  if (r.gloss && r.task !== "gloss") h += row("Gloss", esc(r.gloss) + (r.gloss_proposed ? ` → <span class="proposed">${esc(r.gloss_proposed)}</span>` : ""));
  if (r.current != null) h += row("Current", `<div class="big">${esc(show(r.current))}</div>`);
  h += row(r.task === "example" ? "Proposed English" : "Proposed", `<div class="big proposed">${esc(show(r.proposed))}</div>`);
  if (r.replacement) h += row("Replacement", `<div class="pre">${esc(r.replacement)}</div>`);
  if (r.token) h += row("Token", esc(r.token));
  h += row("Checker", `<div class="pre">${esc(r.checker)}${r.evidence ? ". " + esc(r.evidence) : ""}</div>`);
  if (r.reason) h += row(r.task === "pick" ? "Status" : "Skeptic", `<div class="pre">${esc(r.reason)}</div>`);
  if (r.death_year) h += row("Death year", esc(r.death_year));
  if (r.note) h += row("Note", `<div class="pre">${esc(r.note)}</div>`);
  if (r.notes && r.notes.length) h += row("Checker notes", `<ul>${r.notes.map(n => `<li>${esc(n)}</li>`).join("")}</ul>`);
  if (r.candidates && r.candidates.length) h += row(`Candidates (${r.candidates.length})`, `<ul>${r.candidates.map(c => `<li>${esc(c)}</li>`).join("")}</ul>`);
  if (st.value != null) h += row("Your value", `<div class="big">${esc(show(st.value))}</div>`);
  if (editing) {
    const v = st.value ?? r.proposed;
    h += typeof r.proposed === "object" && r.proposed
      ? row("Edit value", `<textarea id="vfr">${esc(v?.fr)}</textarea><textarea id="ven">${esc(v?.en)}</textarea>`)
      : row("Edit value", `<textarea id="vtext">${esc(v)}</textarea>`);
    h += `<div class="actions"><button class="accept" onclick="saveValue()">Save and accept (⌘↩)</button><button onclick="editing=false;render()">Cancel (Esc)</button></div>`;
  } else {
    h += `<div class="actions"><button class="accept" onclick="decide('accept')">Accept (A)</button><button class="reject" onclick="decide('reject')">Reject (R)</button>`
      + (r.task !== "pick" ? `<button onclick="editing=true;render()">Edit value (E)</button>` : "")
      + `<button class="review" onclick="decide('review')">Hold for review (H)</button><button onclick="undo()">Undo (U)</button>`
      + `<button onclick="move(-1)">← Prev (K)</button><button onclick="move(1)">Next → (J)</button></div>`;
  }
  h += `<div class="hint">Accepting a partly item without a value applies the checker's proposal unchanged. Decisions stay in this browser until you export them.</div></div>`;
  $("main").innerHTML = h;
  const first = document.querySelector("textarea"); if (first) first.focus();
}
function decide(d, value) {
  const r = list[pos]; if (!r) return;
  saved[r.key] = { decision: d, value: value !== undefined ? value : state(r).value };
  persist(); editing = false; advance();
}
function saveValue() {
  const r = list[pos];
  const value = $("vtext") ? $("vtext").value.trim() : { fr: $("vfr").value.trim(), en: $("ven").value.trim() };
  decide("accept", value);
}
function undo() { const r = list[pos]; if (!r) return; delete saved[r.key]; persist(); render(); }
function advance() { const key = list[pos] && list[pos].key; filter(); const i = list.findIndex(r => r.key === key); pos = i >= 0 ? Math.min(i + 1, list.length - 1) : Math.min(pos, list.length - 1); render(); }
function move(d) { pos = Math.max(0, Math.min(list.length - 1, pos + d)); editing = false; render(); }
document.addEventListener("keydown", e => {
  if (editing) { if (e.key === "Escape") { editing = false; render(); } if (e.key === "Enter" && (e.metaKey || e.ctrlKey)) saveValue(); return; }
  if (e.target.tagName === "INPUT" || e.target.tagName === "SELECT") return;
  const k = e.key.toLowerCase();
  if (k === "a") decide("accept"); else if (k === "r") decide("reject"); else if (k === "h") decide("review");
  else if (k === "e" && list[pos] && list[pos].task !== "pick") { editing = true; render(); }
  else if (k === "u") undo(); else if (k === "j" || e.key === "ArrowRight") move(1); else if (k === "k" || e.key === "ArrowLeft") move(-1);
});
["task", "verdict", "bandsel", "state"].forEach(id => $(id).addEventListener("change", () => { pos = 0; filter(); render(); }));
$("jump").addEventListener("keydown", e => { if (e.key !== "Enter") return; const q = e.target.value.trim().toLowerCase();
  let i = list.findIndex(r => r.id.toLowerCase() === q);
  if (i < 0) { $("state").value = "all"; $("task").value = ""; $("verdict").value = ""; $("bandsel").value = ""; filter(); i = list.findIndex(r => r.id.toLowerCase() === q); }
  if (i >= 0) { pos = i; render(); e.target.blur(); } });
$("export").addEventListener("click", () => {
  const blob = new Blob([JSON.stringify(saved, null, 1)], { type: "application/json" });
  const a = document.createElement("a"); a.href = URL.createObjectURL(blob); a.download = "verb-pass-decisions.json"; a.click();
});
$("importbtn").addEventListener("click", () => $("import").click());
$("import").addEventListener("change", e => { const f = e.target.files[0]; if (!f) return;
  f.text().then(t => { const d = JSON.parse(t); for (const k in d) if (byKey[k]) saved[k] = d[k]; persist(); filter(); render(); }); });
filter(); render();
</script>
</body>
</html>
"""


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--merge", metavar="DECISIONS_JSON")
    options = parser.parse_args()
    if options.merge:
        merge(options.merge)
    else:
        build()


if __name__ == "__main__":
    main()
