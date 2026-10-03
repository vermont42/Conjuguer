#!/usr/bin/env python3
"""The etymology tail's wave tool (prompts/etymology-tail-plan.md, stages 1 and 2).

Affix library (stage 1):
  affix-batches --batches 4     write the writers' input files from evidence.json
  affix-assemble                merge the writers' parts and the skeptic fixes into
                                prompts/etymology-affixes.json, then check it

Waves (stage 2):
  select   --wave N --size S    pick the next verbs (bases first) and write the shards
  validate --wave N             check the wave's results (and skeptic texts)
  merge    --wave N             merge the validated entries into Etymologies.json
  report   --wave N             print the wave report

Run from the repo root.
"""

import argparse
import collections
import json
import pathlib
import re
import sys
import unicodedata

ROOT = pathlib.Path(__file__).resolve().parents[2]
WORK = ROOT / "corpus/working/etymology"
EVIDENCE = WORK / "evidence.json"
AFFIX_DIR = WORK / "affixes"
AFFIX_LIB = ROOT / "prompts/etymology-affixes.json"
ETYM = ROOT / "Conjuguer/Models/Etymologies.json"
FREQ = ROOT / "docs/frequencies.txt"

# Card key -> the allomorphs it covers. Every affix evidence.json names must appear exactly once.
AFFIX_GROUPS = {
    "dé-": ["dé-", "dés-", "des-", "de-"],
    "re-": ["re-", "ré-", "r-", "ra-"],
    "en-": ["en-", "em-"],
    "é-": ["é-", "es-", "ex-"],
    "a-": ["a-", "ad-", "ac-"],
    "ab-": ["ab-"],
    "con-": ["con-", "co-", "com-"],
    "mé-": ["mé-", "més-"],
    "entre-": ["entre-", "entr-"],
    "trans-": ["trans-", "tré-", "tres-", "tra-"],
    "sous-": ["sous-", "sou-"],
    "ca-": ["ca-", "cha-"],
    "far-": ["far-"],
    "pour-": ["pour-"],
    "for-": ["for-"],
    "par-": ["par-"],
    "per-": ["per-"],
    "sur-": ["sur-"],
    "contre-": ["contre-"],
    "pré-": ["pré-"],
    "inter-": ["inter-"],
    "in-": ["in-"],
    "auto-": ["auto-"],
    "post-": ["post-"],
    "dis-": ["dis-"],
    "sub-": ["sub-"],
    "télé-": ["télé-"],
    "radio-": ["radio-"],
    "super-": ["super-"],
    "mal-": ["mal-"],
    "juxta-": ["juxta-"],
    "poly-": ["poly-"],
    "héli-": ["héli-"],
    "rétro-": ["rétro-"],
    "pyro-": ["pyro-"],
    "anté-": ["anté-"],
    "bis-": ["bis-"],
    "syn-": ["syn-"],
    "-er": ["-er", "-ir"],
    "-t-": ["-t-", "-ter"],
    "-iser": ["-iser", "-ise"],
    "-ifier": ["-ifier", "-fier"],
    "-ier": ["-ier"],
    "-oyer": ["-oyer", "-ayer", "-eyer"],
    "-oter": ["-oter", "-otter", "-ot"],
    "-ailler": ["-ailler"],
    "-asser": ["-asser", "-asse"],
    "-eter": ["-eter", "-et-"],
    "-eler": ["-eler"],
    "-iller": ["-iller"],
    "-ouiller": ["-ouiller"],
    "-iner": ["-iner"],
    "-onner": ["-onner"],
    "-ocher": ["-ocher"],
    "-âcher": ["-âcher"],
    "-in": ["-in"],
    "-type": ["-type"],
}
HEAVY_CARDS = {"dé-", "re-", "en-", "é-", "a-", "-er", "-iser", "-ifier", "con-", "trans-", "sur-", "entre-"}


def load_json(p):
    return json.loads(pathlib.Path(p).read_text(encoding="utf-8"))


def write_json(p, data, indent=1):
    p = pathlib.Path(p)
    p.parent.mkdir(parents=True, exist_ok=True)
    p.write_text(json.dumps(data, ensure_ascii=False, indent=indent) + "\n", encoding="utf-8")


def formation_affixes(rec):
    f = rec["formation"]
    return [f[k] for k in ("affix", "suffix") if f.get(k)]


def allomorph_to_card(groups):
    out = {}
    for key, forms in groups.items():
        for form in forms:
            if form in out:
                raise SystemExit(f"allomorph {form} is in two cards: {out[form]} and {key}")
            out[form] = key
    return out


# ---------------------------------------------------------------- affix library (stage 1)

def cmd_affix_batches(args):
    ev = load_json(EVIDENCE)
    to_card = allomorph_to_card(AFFIX_GROUPS)
    named = collections.Counter(a for r in ev.values() for a in formation_affixes(r))
    unmapped = sorted(set(named) - set(to_card))
    if unmapped:
        raise SystemExit(f"affixes with no card: {unmapped}")
    users = collections.defaultdict(list)
    for verb, rec in sorted(ev.items(), key=lambda kv: kv[1]["rank"]):
        for a in formation_affixes(rec):
            users[to_card[a]].append(verb)
    app_verbs = [line.split(" ", 1)[1].strip() for line in FREQ.read_text(encoding="utf-8").splitlines()]

    cards = []
    for key, forms in AFFIX_GROUPS.items():
        verbs = users.get(key, [])
        samples = [{"verb": v, "fr": ev[v]["fr"][:2], "en": ev[v]["en"][:1]} for v in verbs[:8]]
        prefixes = [f for f in forms if f.endswith("-") and not f.startswith("-")]
        suffixes = [f.strip("-") for f in forms if f.startswith("-")]
        shaped = []
        for v in app_verbs:
            if v in verbs:
                continue
            if any(v.startswith(p.rstrip("-")) and len(v) > len(p) + 2 for p in prefixes) or \
               any(v.endswith(s) and len(v) > len(s) + 2 for s in suffixes if len(s) > 2):
                shaped.append(v)
        cards.append({"key": key, "group": forms, "uses": named_total(forms, named),
                      "verbs_using_it": verbs[:25], "evidence_samples": samples,
                      "app_verbs_with_this_shape": shaped[:40]})

    weights = [(3 if c["key"] in HEAVY_CARDS else 1, c) for c in cards]
    bins = [[] for _ in range(args.batches)]
    loads = [0] * args.batches
    for w, c in sorted(weights, key=lambda x: -x[0]):
        i = loads.index(min(loads))
        bins[i].append(c)
        loads[i] += w
    for i, b in enumerate(bins, 1):
        write_json(AFFIX_DIR / f"input_{i}.json", {"batch": i, "cards": b})
        print(f"batch {i}: {len(b)} cards, weight {loads[i - 1]}: {', '.join(c['key'] for c in b)}")


def named_total(forms, named):
    return sum(named.get(f, 0) for f in forms)


TILDE_FIELDS = ("origin_en", "origin_fr")


def markup_problems(text):
    probs = []
    if text.count("~") % 2:
        probs.append("odd ~ count")
    if "~~" in text:
        probs.append("~~")
    if '"' in text:
        probs.append('ASCII "')
    if "~*" in text:
        probs.append("~* (want *~)")
    if re.search(r"\*(?!~)[^*~\n]+?\*", text):
        probs.append("*word* emphasis")
    if "\\n" in text:
        probs.append("literal \\n")
    return probs


def cmd_affix_assemble(args):
    lib = {}
    for part in sorted(AFFIX_DIR.glob("part_*.json")):
        lib.update(load_json(part))
    for vf in sorted(AFFIX_DIR.glob("verdict_*.json")):
        for res in load_json(vf)["results"]:
            card = lib.get(res["key"])
            if card is None:
                print(f"verdict for unknown card {res['key']}")
                continue
            card["skeptic"] = res["verdict"]
            if res["verdict"] == "partly":
                for field, value in res.get("fixes", {}).items():
                    card[field] = value
    overrides = AFFIX_DIR / "overrides.json"
    if overrides.exists():
        for key, fields in load_json(overrides).items():
            lib.setdefault(key, {}).update(fields)
    for card in lib.values():
        card.pop("source_notes", None)
    problems = check_affix_library(lib)
    lib = {k: lib[k] for k in AFFIX_GROUPS if k in lib}
    write_json(AFFIX_LIB, lib, indent=2)
    print(f"{len(lib)} cards -> {AFFIX_LIB.relative_to(ROOT)}")
    verdicts = collections.Counter(c.get("skeptic", "unchecked") for c in lib.values())
    print("skeptic: " + ", ".join(f"{k} {n}" for k, n in verdicts.most_common()))
    for p in problems:
        print("  PROBLEM", p)
    if problems:
        sys.exit(1)


def check_affix_library(lib):
    problems = []
    ev = load_json(EVIDENCE)
    named = {a for r in ev.values() for a in formation_affixes(r)}
    seen = {}
    for key, card in lib.items():
        for form in card.get("group", []):
            if form in seen:
                problems.append(f"{form} maps to both {seen[form]} and {key}")
            seen[form] = key
        for field in TILDE_FIELDS:
            if not card.get(field):
                problems.append(f"{key}: missing {field}")
            for p in markup_problems(card.get(field, "")):
                problems.append(f"{key}.{field}: {p}")
        if card.get("origin_en", "").count("~") != card.get("origin_fr", "").count("~"):
            problems.append(f"{key}: en/fr tilde mismatch "
                            f"({card.get('origin_en', '').count('~')}/{card.get('origin_fr', '').count('~')})")
    for form in sorted(named - set(seen)):
        problems.append(f"affix {form} has no card")
    for key in AFFIX_GROUPS:
        if key not in lib:
            problems.append(f"card {key} missing")
    return problems




# ---------------------------------------------------------------- waves (stage 2)

STATUS = WORK / "status.json"
LOOKUPS = WORK / "lookups.json"
WEIGHT = {"short": 1.0, "rich": 2.5, "none": 2.5}
SHARD_UNITS = 30


def wave_dir(n):
    return WORK / "waves" / f"w{n:02d}"


def load_status():
    return load_json(STATUS) if STATUS.exists() else {}


def card_map():
    if not AFFIX_LIB.exists():
        raise SystemExit(f"{AFFIX_LIB.relative_to(ROOT)} is missing; finish stage 1 first")
    lib = load_json(AFFIX_LIB)
    return lib, allomorph_to_card({k: c["group"] for k, c in lib.items()})


def current_base_status(rec, covered, app_verbs):
    f = rec["formation"]
    base = f.get("base")
    if not base:
        return None
    if base in covered:
        return "covered"
    if base in app_verbs:
        return "missing"
    return f["base_status"]


def resolve_root(verb, ev, covered, chosen, seen=None):
    """The verb to write now so that `verb` never precedes its base: `verb` itself, or the
    first missing ancestor whose own base is settled. None means `verb` must wait while an
    ancestor is already in this wave."""
    seen = seen or set()
    if verb in seen:
        return verb
    seen.add(verb)
    rec = ev.get(verb)
    base = rec and rec["formation"].get("base")
    if not base or base in covered or base not in ev or base == verb:
        return verb
    if base in chosen:
        return None
    return resolve_root(base, ev, covered, chosen, seen)


def shard_record(verb, ev, etym, covered, app_verbs, to_card, status, lookups):
    rec = json.loads(json.dumps(ev[verb]))
    rec = {"verb": verb, **rec}
    f = rec["formation"]
    if f.get("base"):
        f["base_status"] = current_base_status(ev[verb], covered, app_verbs)
        if f["base_status"] == "covered":
            rec["base_etymology_en"] = etym["en"][f["base"]]
            rec["base_etymology_fr"] = etym["fr"][f["base"]]
    rec["affix_cards"] = sorted({to_card[a] for a in formation_affixes(ev[verb]) if a in to_card})
    hist = status.get(verb)
    rec["history"] = hist.get("note") if hist and hist.get("outcome") in ("refuted", "deferred") else None
    if verb in lookups:
        rec["lookup"] = lookups[verb]
        if rec["evidence"] == "none":
            rec["evidence"] = "lookup"
    return rec


def write_shards(n, verbs, ev, name_prefix="s", start=1):
    etym = load_json(ETYM)
    covered = set(etym["en"])
    app_verbs = set(load_json(EVIDENCE)) | covered
    lib, to_card = card_map()
    status = load_status()
    lookups = load_json(LOOKUPS) if LOOKUPS.exists() else {}
    shards, cur, units = [], [], 0.0
    for v in verbs:
        w = WEIGHT[ev[v]["tier"]]
        if cur and units + w > SHARD_UNITS:
            shards.append(cur)
            cur, units = [], 0.0
        cur.append(v)
        units += w
    if cur:
        shards.append(cur)
    # Fold a small trailing shard into the one before it.
    if len(shards) > 1 and sum(WEIGHT[ev[v]["tier"]] for v in shards[-1]) < SHARD_UNITS / 3:
        shards[-2] += shards.pop()
    d = wave_dir(n)
    names = []
    for i, group in enumerate(shards, start):
        name = f"{name_prefix}{i:02d}"
        recs = [shard_record(v, ev, etym, covered, app_verbs, to_card, status, lookups) for v in group]
        cards = sorted({c for r in recs for c in r["affix_cards"]})
        write_json(d / "shards" / f"{name}.json", {
            "wave": n, "shard": name, "verbs": recs,
            "affix_cards": {c: {k: val for k, val in lib[c].items() if k != "skeptic"} for c in cards}})
        units = sum(WEIGHT[ev[v]["tier"]] for v in group)
        rich = sum(1 for v in group if ev[v]["tier"] != "short")
        print(f"  {name}: {len(group)} verbs ({rich} rich/none), {units:g} units, cards: {', '.join(cards) or '-'}")
        names.append(name)
    return names


def plan_selection(size, ev, covered, status):
    blocked = {v for v, s in status.items() if s.get("outcome") == "skipped"}
    deferred = [v for v, s in status.items() if s.get("outcome") == "deferred" and v not in covered]
    pool = sorted((v for v in ev if v not in covered and v not in blocked), key=lambda v: ev[v]["rank"])
    order = deferred + [v for v in pool if v not in deferred]
    chosen, pushed, pulled = [], [], {}
    for v in order:
        if len(chosen) >= size:
            break
        if v in chosen:
            continue
        root = resolve_root(v, ev, covered, set(chosen))
        if root == v:
            chosen.append(v)
        else:
            pushed.append(v)
            if root and root not in chosen:
                chosen.append(root)
                pulled[root] = v
    chosen_set = set(chosen)
    # A derivative whose base joined after it must wait too.
    late = [v for v in chosen if ev[v]["formation"].get("base") in chosen_set and v not in pulled]
    for v in late:
        chosen.remove(v)
        pushed.append(v)
    return chosen, pushed, pulled


def cmd_select(args):
    ev = load_json(EVIDENCE)
    etym = load_json(ETYM)
    covered = set(etym["en"])
    status = load_status()
    d = wave_dir(args.wave)
    if (d / "selection.json").exists() and not args.force:
        raise SystemExit(f"{d.relative_to(ROOT)}/selection.json exists; pass --force to redo it")
    chosen, pushed, pulled = plan_selection(args.size, ev, covered, status)
    chosen.sort(key=lambda v: ev[v]["rank"])
    tiers = collections.Counter(ev[v]["tier"] for v in chosen)
    print(f"wave {args.wave}: {len(chosen)} verbs ({', '.join(f'{k} {n}' for k, n in tiers.most_common())}); "
          f"{len(pulled)} bases pulled forward, {len(pushed)} derivatives pushed to the next wave")
    for base, deriv in pulled.items():
        print(f"  pulled {base} (rank {ev[base]['rank']}) for {deriv} (rank {ev[deriv]['rank']})")
    names = write_shards(args.wave, chosen, ev)
    write_json(d / "selection.json", {"wave": args.wave, "size": args.size, "verbs": chosen,
                                      "pulled": pulled, "pushed": pushed, "shards": names})


def cmd_reshard(args):
    ev = load_json(EVIDENCE)
    verbs = [v.strip() for v in args.verbs.split(",") if v.strip()]
    unknown = [v for v in verbs if v not in ev]
    if unknown:
        raise SystemExit(f"not in evidence.json: {unknown}")
    names = write_shards(args.wave, verbs, ev, name_prefix=args.prefix, start=args.start)
    print(f"wrote {', '.join(names)}")


# ---------------------------------------------------------------- validation

EMPH = re.compile(r"\*(?!~)[^*~\n]+?\*")
# The plan's pattern flagged every present-tense passive (est formé, est issu), which the plan itself
# allows. This keeps the real hits: avoir + participle, and être + the participle of a verb that
# takes être.
PASSE_COMPOSE = re.compile(
    r"\b(?:a|ont) (?:été )?\w{2,}(?:é|ée|és|ées|i|is|it|u|us|ert|ait)\b|"
    r"\b(?:est|sont) (?:devenue?s?|venue?s?|revenue?s?|née?s?|morte?s?|entrée?s?|sortie?s?|partie?s?|"
    r"arrivée?s?|tombée?s?|restée?s?|passée?s?|apparue?s?|parvenue?s?|retournée?s?)\b")
# Rich paragraphs: the shipped entries' first paragraphs have a median of 76 words (en) and a 10th
# percentile of 58, so the plan's 90-word floor rejected the house style. 50 sits below the shipped
# 10th percentile of either paragraph.
RICH_MIN, RICH_MAX = 50, 260
EMDASH_CLAUSE = re.compile(
    r"—\s+(?:[^—.;:]*?\b)(?:is|was|were|are|became|had|has|took|gave|came|est|était|fut|furent|devint|"
    r"prit|donna|vint|sont|étaient)\b")
BOLD = re.compile(r"(\*?)~([^~]+)~")


def nfc(s):
    return unicodedata.normalize("NFC", s)


def bare(s):
    """Lowercase with the diacritics stripped, so stāre matches stare and ǵ matches g."""
    return "".join(c for c in unicodedata.normalize("NFD", s.lower()) if not unicodedata.combining(c))


def words(p):
    return len(p.split())


def entry_problems(verb, entry, rec, cards, tier=None):
    """Returns (rejects, flags) for one entry. `rec` is the shard record."""
    rejects, flags = [], []
    tier = tier or entry.get("tier")
    texts = {lang: entry.get(lang) or "" for lang in ("en", "fr")}
    for lang, t in texts.items():
        if not t.strip():
            rejects.append(f"{lang}: MISSING")
            continue
        for p in markup_problems(t):
            rejects.append(f"{lang}: {p}")
        paras = [p for p in t.split("\n\n")]
        if tier == "short":
            if len(paras) != 1 or "\n" in t:
                rejects.append(f"{lang}: short entry has {len(paras)} paragraphs")
            elif not 40 <= words(t) <= 150:
                rejects.append(f"{lang}: short entry has {words(t)} words (want 40-150)")
        elif tier == "rich":
            if len(paras) != 2:
                rejects.append(f"{lang}: rich entry has {len(paras)} paragraphs")
            else:
                for i, p in enumerate(paras, 1):
                    if not RICH_MIN <= words(p) <= RICH_MAX:
                        rejects.append(f"{lang}: rich paragraph {i} has {words(p)} words "
                                       f"(want {RICH_MIN}-{RICH_MAX})")
        else:
            rejects.append(f"unknown tier {tier!r}")
        if EMDASH_CLAUSE.search(t):
            flags.append(f"{lang}: em dash may join two clauses: …{EMDASH_CLAUSE.search(t).group(0)[:60]}…")
    if texts["en"].count("~") != texts["fr"].count("~"):
        rejects.append(f"en/fr tilde mismatch ({texts['en'].count('~')}/{texts['fr'].count('~')})")
    for m in PASSE_COMPOSE.finditer(texts["fr"]):
        flags.append(f"fr: passé composé? '{m.group(0)}'")

    f = rec["formation"]
    if tier == "short" and f.get("kind") not in (None, "none") and f.get("source") == "fr":
        bolded = {lang: {nfc(b).lower() for _, b in BOLD.findall(t)} for lang, t in texts.items()}
        base = nfc(f.get("base", "")).lower()
        group = set()
        for c in rec.get("affix_cards", []):
            group |= {nfc(x).lower() for x in cards.get(c, {}).get("group", [])}
        for lang in ("en", "fr"):
            if base and base not in bolded[lang]:
                flags.append(f"{lang}: base ~{f['base']}~ not bolded")
            if group and not (group & bolded[lang]):
                flags.append(f"{lang}: affix ({'/'.join(sorted(group))}) not bolded")

    evidence_text = nfc(" ".join(
        rec.get("fr", []) + rec.get("en", []) +
        [rec.get("base_etymology_en") or "", rec.get("base_etymology_fr") or ""] +
        sum(([*(rec.get("base_word_evidence") or {}).get("fr", []), *(rec.get("base_word_evidence") or {}).get("en", [])],), []) +
        [json.dumps(cards.get(c, {}), ensure_ascii=False) for c in rec.get("affix_cards", [])] +
        [json.dumps(rec.get("lookup") or "", ensure_ascii=False)]))
    evidence_text = bare(evidence_text)
    seen_roots = set()
    for star, form in BOLD.findall(texts["en"]):
        looks_old = star or re.search(r"[āēīōūȳăĕĭŏŭ₀-₉ʰʷ]", form)
        if form in seen_roots:
            continue
        seen_roots.add(form)
        if looks_old and bare(form).strip("-") not in evidence_text:
            flags.append(f"root {'*' if star else ''}~{form}~ not in the shard's evidence"
                         f"{' (writer cited sources)' if entry.get('sources') else ' (no sources cited)'}")
    return rejects, flags


def mechanical_fix(t):
    t = t.replace("~*", "*~")
    t = EMPH.sub(lambda m: m.group(0)[1:-1], t)
    return t


def load_shard(d, name):
    return load_json(d / "shards" / f"{name}.json")


def wave_shard_names(d):
    return sorted(p.stem for p in (d / "shards").glob("*.json"))


def validate_wave(n, fix=False, quiet=False):
    d = wave_dir(n)
    out = {"shards": {}, "entries": {}, "skeptic": {}}
    for name in wave_shard_names(d):
        shard = load_shard(d, name)
        cards = shard["affix_cards"]
        recs = {r["verb"]: r for r in shard["verbs"]}
        rpath = d / "results" / f"{name}.json"
        if not rpath.exists():
            out["shards"][name] = "no results file"
            continue
        try:
            res = load_json(rpath)
        except json.JSONDecodeError as e:
            out["shards"][name] = f"invalid JSON: {e}"
            continue
        if fix:
            changed = 0
            for e in res.values():
                for lang in ("en", "fr"):
                    if e.get(lang):
                        new = mechanical_fix(e[lang])
                        if new != e[lang]:
                            e[lang] = new
                            changed += 1
            if changed:
                write_json(rpath, res)
                print(f"  {name}: {changed} mechanical markup fixes")
        missing = [v for v in recs if v not in res]
        extra = [v for v in res if v not in recs]
        shard_issues = []
        if missing:
            shard_issues.append(f"missing verbs: {missing}")
        if extra:
            shard_issues.append(f"verbs not in shard: {extra}")
        out["shards"][name] = "; ".join(shard_issues) or "ok"
        for v, e in res.items():
            if v not in recs:
                continue
            if e.get("skipped") or e.get("needs_lookup"):
                out["entries"][v] = {"shard": name, "state": "skipped" if e.get("skipped") else "needs_lookup",
                                     "reason": e.get("skipped") or e.get("needs_lookup"), "rejects": [], "flags": []}
                continue
            rej, flg = entry_problems(v, e, recs[v], cards)
            out["entries"][v] = {"shard": name, "state": "reject" if rej else "ok", "tier": e.get("tier"),
                                 "rejects": rej, "flags": flg}
        vpath = d / "verdicts" / f"{name}.json"
        if vpath.exists():
            try:
                verdicts = load_json(vpath)["results"]
            except (json.JSONDecodeError, KeyError) as e:
                out["shards"][name] += f"; verdict file invalid: {e}"
                verdicts = []
            for vd in verdicts:
                v = vd.get("verb")
                if v not in recs:
                    continue
                entry = {"verdict": vd.get("verdict"), "reason": vd.get("reason"), "rejects": [], "flags": []}
                if vd.get("verdict") == "partly":
                    fixed = {"en": mechanical_fix(vd.get("en") or ""), "fr": mechanical_fix(vd.get("fr") or "")}
                    entry["rejects"], entry["flags"] = entry_problems(v, fixed, recs[v], cards, tier="rich")
                out["skeptic"][v] = entry
    write_json(d / "validation.json", out)
    if not quiet:
        print_validation(out)
    return out


def print_validation(out):
    bad_shards = {k: v for k, v in out["shards"].items() if v != "ok"}
    states = collections.Counter(e["state"] for e in out["entries"].values())
    print("shards: " + (", ".join(f"{k}: {v}" for k, v in bad_shards.items()) if bad_shards else "all ok"))
    print("entries: " + ", ".join(f"{k} {n}" for k, n in states.most_common()))
    for v, e in out["entries"].items():
        if e["rejects"]:
            print(f"  REJECT {v} ({e['shard']}): {'; '.join(e['rejects'])}")
    for v, e in out["entries"].items():
        for f in e["flags"]:
            print(f"  flag {v}: {f}")
    if out["skeptic"]:
        sk = collections.Counter(e["verdict"] for e in out["skeptic"].values())
        print("skeptic: " + ", ".join(f"{k} {n}" for k, n in sk.most_common()))
        for v, e in out["skeptic"].items():
            if e["rejects"]:
                print(f"  REJECT skeptic text {v}: {'; '.join(e['rejects'])}")
            for f in e["flags"]:
                print(f"  flag skeptic text {v}: {f}")


def cmd_validate(args):
    validate_wave(args.wave, fix=args.fix)


# ---------------------------------------------------------------- merge

def cmd_merge(args):
    n = args.wave
    d = wave_dir(n)
    val = validate_wave(n, fix=True, quiet=True)
    status = load_status()
    accepted, outcomes = {}, {}
    rich_needing_verdict = []
    demoted = set()
    for name in wave_shard_names(d):
        rpath = d / "results" / f"{name}.json"
        if not rpath.exists():
            continue
        res = load_json(rpath)
        for v, e in res.items():
            info = val["entries"].get(v)
            if not info:
                continue
            # A verb rerun in a later shard (reshard --start) is judged by that shard alone.
            if info["shard"] != name:
                continue
            if info["state"] == "skipped":
                outcomes[v] = ("skipped", e.get("skipped"))
                continue
            if info["state"] == "needs_lookup":
                outcomes[v] = ("deferred", f"needs lookup: {e.get('needs_lookup')}")
                continue
            if info["state"] == "reject":
                outcomes[v] = ("rejected", "; ".join(info["rejects"]))
                continue
            if e.get("tier") == "rich":
                sk = val["skeptic"].get(v)
                if not sk:
                    rich_needing_verdict.append(v)
                    outcomes[v] = ("held", "rich entry with no skeptic verdict")
                    continue
                if sk["verdict"] == "refuted":
                    outcomes[v] = ("refuted", sk["reason"])
                    continue
                if sk["verdict"] == "partly":
                    vd = next(x for x in load_json(d / "verdicts" / f"{name}.json")["results"] if x.get("verb") == v)
                    fixed = {"en": mechanical_fix(vd["en"]), "fr": mechanical_fix(vd["fr"])}
                    if sk["rejects"] and args.defer_stubs:
                        outcomes[v] = ("deferred", "the skeptic cut the entry below the rich floor, mostly by deleting "
                                       "uncited claims beyond the shard; rerun once those claims can be sourced")
                        continue
                    if sk["rejects"]:
                        # A skeptic that cut a rich entry down to its supported core can leave too little
                        # for two paragraphs. If that core passes as one short paragraph, ship it as short.
                        joined = {lang: " ".join(fixed[lang].split("\n\n")) for lang in ("en", "fr")}
                        rec = next(r for r in load_shard(d, name)["verbs"] if r["verb"] == v)
                        rej, _ = entry_problems(v, joined, rec, load_shard(d, name)["affix_cards"], tier="short")
                        if rej:
                            outcomes[v] = ("rejected", "skeptic text failed validation: " + "; ".join(sk["rejects"]))
                            continue
                        accepted[v] = joined
                        demoted.add(v)
                        outcomes[v] = ("merged", "skeptic partly, demoted to short: the supported text fit one paragraph")
                        continue
                    accepted[v] = fixed
                    outcomes[v] = ("merged", "skeptic partly")
                    continue
            accepted[v] = {"en": e["en"], "fr": e["fr"]}
            outcomes[v] = ("merged", "upheld" if e.get("tier") == "rich" else "short")
    if args.dry_run:
        print(f"would merge {len(accepted)}")
    else:
        p = ETYM
        data = load_json(p)
        for v, langs in accepted.items():
            data["en"][v] = langs["en"]
            data["fr"][v] = langs["fr"]
        for lang in data:
            data[lang] = dict(sorted(data[lang].items()))
        data = dict(sorted(data.items()))
        p.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        check = load_json(p)
        assert set(check["en"]) == set(check["fr"]), "en/fr key sets differ"
        print(f"merged {len(accepted)}; totals en={len(check['en'])} fr={len(check['fr'])}. Valid JSON.")
        for v, (outcome, note) in outcomes.items():
            status[v] = {"wave": n, "outcome": outcome, "note": note}
        write_json(STATUS, status)
    write_json(d / "outcomes.json", {v: {"outcome": o, "note": note, **({"final_tier": "short"} if v in demoted else {})}
                                     for v, (o, note) in outcomes.items()})
    counts = collections.Counter(o for o, _ in outcomes.values())
    print("outcomes: " + ", ".join(f"{k} {c}" for k, c in counts.most_common()))
    for v, (o, note) in outcomes.items():
        if o not in ("merged",):
            print(f"  {o} {v}: {note}")


# ---------------------------------------------------------------- report

def transcript_usage(paths):
    """Sums `usage` per agent transcript. Returns [{file, kind, shard, models, tokens…}].

    A workflow transcript opens with the harness relaying the session's latest user request, so the
    task (and its "Etymology wave N, role, shard sXX." line) is in a later user line. A message's
    usage is streamed over several lines sharing its id; the last line carries the final counts."""
    rows = []
    for path in paths:
        for f in sorted(pathlib.Path(path).rglob("agent-*.jsonl")):
            task, models, per_msg = None, {}, {}
            for line in f.read_text(encoding="utf-8").splitlines():
                try:
                    o = json.loads(line)
                except json.JSONDecodeError:
                    continue
                msg = o.get("message") or {}
                if o.get("type") == "user" and task is None:
                    c = msg.get("content")
                    text = c if isinstance(c, str) else " ".join(
                        b.get("text", "") for b in c or [] if isinstance(b, dict))
                    task = re.search(r"Etymology wave (\d+), (writer|skeptic), shard (\S+?)\.", text)
                if o.get("type") == "assistant" and msg.get("id"):
                    per_msg[msg["id"]] = msg.get("usage") or {}
                    if msg.get("model"):
                        models[msg["id"]] = msg["model"]
            if not task:
                continue
            usage = collections.Counter()
            for u in per_msg.values():
                for k, val in u.items():
                    if isinstance(val, int):
                        usage[k] += val
            rows.append({"file": f.name, "wave": int(task.group(1)), "kind": task.group(2),
                         "shard": task.group(3), "models": dict(collections.Counter(models.values())), **usage})
    return rows


def tok_total(r):
    return sum(r.get(k, 0) for k in ("input_tokens", "cache_creation_input_tokens",
                                     "cache_read_input_tokens", "output_tokens"))


def cmd_report(args):
    n = args.wave
    d = wave_dir(n)
    ev = load_json(EVIDENCE)
    etym = load_json(ETYM)
    sel = load_json(d / "selection.json")
    outcomes = load_json(d / "outcomes.json") if (d / "outcomes.json").exists() else {}
    val = load_json(d / "validation.json") if (d / "validation.json").exists() else {"entries": {}, "skeptic": {}}
    results, recs = {}, {}
    for name in wave_shard_names(d):
        for r in load_shard(d, name)["verbs"]:
            recs[r["verb"]] = r
        rp = d / "results" / f"{name}.json"
        if rp.exists():
            for v, e in load_json(rp).items():
                results[v] = {**e, "shard": name}
    L = []
    say = L.append
    say(f"# Etymology wave {n} report\n")
    oc = collections.Counter(o["outcome"] for o in outcomes.values())
    say(f"- **Selected:** {len(sel['verbs'])} verbs ({len(sel['pulled'])} bases pulled forward, "
        f"{len(sel['pushed'])} derivatives pushed to the next wave)")
    say("- **Outcomes:** " + ", ".join(f"{k} {c}" for k, c in oc.most_common()))
    for kind in ("skipped", "refuted", "deferred", "rejected", "held"):
        rows = [(v, o["note"]) for v, o in outcomes.items() if o["outcome"] == kind]
        for v, note in rows:
            say(f"  - {kind} *{v}*: {note}")
    before = collections.Counter(recs[v]["tier"] for v in results)
    after = collections.Counter(e.get("tier") for e in results.values() if e.get("en"))
    moves = collections.Counter((recs[v]["tier"], e.get("tier")) for v, e in results.items()
                                if e.get("en") and recs[v]["tier"] != e.get("tier"))
    say(f"- **Tiers:** heuristic {dict(before)}; written {dict(after)}")
    say("- **Tier moves:** " + (", ".join(f"{a}→{b} {c}" for (a, b), c in moves.items()) or "none"))
    for v, e in results.items():
        if e.get("en") and recs[v]["tier"] != e.get("tier"):
            say(f"  - *{v}* {recs[v]['tier']}→{e.get('tier')}: {e.get('tier_reason')}")
    sk = collections.Counter(e["verdict"] for e in val.get("skeptic", {}).values())
    tot = sum(sk.values())
    if tot:
        say("- **Skeptic:** " + ", ".join(f"{k} {c} ({100 * c / tot:.0f}%)" for k, c in sk.most_common()))
    web = collections.Counter(e.get("web", "none") for e in results.values())
    say(f"- **Web use:** {web.get('webfetch', 0) + web.get('chrome', 0)} verbs "
        f"({web.get('chrome', 0)} needed Chrome)")
    notes = [(v, e["notes"]) for v, e in results.items() if e.get("notes")]
    if notes:
        say("- **Writer notes:**")
        for v, note in notes:
            say(f"  - *{v}*: {note}")

    if args.transcripts:
        rows = [r for r in transcript_usage(args.transcripts) if r["wave"] == n]
        models = collections.Counter(m for r in rows for m in r["models"])
        say(f"- **Transcripts:** {len(rows)}; models: {dict(models)}")
        for kind in ("writer", "skeptic"):
            ks = [r for r in rows if r["kind"] == kind]
            if not ks:
                continue
            agg = collections.Counter()
            for r in ks:
                for k in ("input_tokens", "cache_creation_input_tokens", "cache_read_input_tokens", "output_tokens"):
                    agg[k] += r.get(k, 0)
            say(f"  - {kind}: {len(ks)} agents, total {sum(agg.values()):,} tokens "
                f"(input {agg['input_tokens']:,}, cache write {agg['cache_creation_input_tokens']:,}, "
                f"cache read {agg['cache_read_input_tokens']:,}, output {agg['output_tokens']:,})")
        # Per-verb cost by tier: fit writer tokens per shard = a*short + b*rich (least squares).
        shard_rows = collections.defaultdict(lambda: {"tokens": 0, "out": 0})
        for r in rows:
            if r["kind"] == "writer":
                shard_rows[r["shard"]]["tokens"] += tok_total(r)
                shard_rows[r["shard"]]["out"] += r.get("output_tokens", 0)
        xs = []
        for name, agg in shard_rows.items():
            shard = d / "shards" / f"{name}.json"
            if not shard.exists():
                continue
            tiers = collections.Counter(results.get(r["verb"], {}).get("tier") or r["tier"]
                                        for r in load_json(shard)["verbs"])
            xs.append((tiers.get("short", 0), tiers.get("rich", 0) + tiers.get("none", 0), agg["tokens"], agg["out"]))
        fit = least_squares_2(xs)
        sk_rows = [r for r in rows if r["kind"] == "skeptic"]
        rich_judged = max(1, sum(1 for e in val.get("skeptic", {}).values()))
        sk_per = sum(tok_total(r) for r in sk_rows) / rich_judged if sk_rows else 0
        if fit:
            a, b, ao, bo = fit
            say(f"- **Per verb (writer, least-squares over {len(xs)} shards):** short ≈ {a:,.0f} tokens "
                f"({ao:,.0f} output), rich ≈ {b:,.0f} tokens ({bo:,.0f} output); skeptic ≈ {sk_per:,.0f} per rich entry")
        else:
            say("- **Per verb:** too few shards for a fit")
    if args.usage_start is not None and args.usage_end is not None:
        say(f"- **Five-hour usage:** {args.usage_start}% → {args.usage_end}% "
            f"(Δ {args.usage_end - args.usage_start} points)")
    remaining = [v for v in ev if v not in etym["en"]]
    status = load_status()
    nxt, _, _ = plan_selection(10, ev, set(etym["en"]), status)
    say(f"- **Remaining:** {len(remaining)}; next wave starts with {', '.join(nxt)}")

    say("\n## Twenty sample cards (chosen by index)\n")
    merged = [v for v, o in outcomes.items() if o["outcome"] == "merged"]
    for tier in ("short", "rich"):
        pool = sorted((v for v in merged if results[v].get("tier") == tier), key=lambda v: recs[v]["rank"])
        picks = [pool[i * len(pool) // 10] for i in range(min(10, len(pool)))]
        say(f"### {tier.capitalize()} ({len(pool)} merged; indices {[i * len(pool) // 10 for i in range(len(picks))]})\n")
        for v in picks:
            r = recs[v]
            say(f"#### {v} (rank {r['rank']}, {r['gloss']}; {outcomes[v]['note']})\n")
            say(f"**Evidence (fr):** {' / '.join(r['fr']) or '—'}  ")
            say(f"**Evidence (en):** {' / '.join(r['en']) or '—'}\n")
            say(f"**EN:** {etym['en'].get(v, '').replace(chr(10) + chr(10), ' ¶ ')}\n")
            say(f"**FR:** {etym['fr'].get(v, '').replace(chr(10) + chr(10), ' ¶ ')}\n")
    text = "\n".join(L) + "\n"
    (d / "report.md").write_text(text, encoding="utf-8")
    print(text)


def least_squares_2(xs):
    if len(xs) < 3:
        return None
    def solve(idx):
        s11 = sum(x[0] * x[0] for x in xs)
        s12 = sum(x[0] * x[1] for x in xs)
        s22 = sum(x[1] * x[1] for x in xs)
        t1 = sum(x[0] * x[idx] for x in xs)
        t2 = sum(x[1] * x[idx] for x in xs)
        det = s11 * s22 - s12 * s12
        if abs(det) < 1e-9:
            return None
        return (t1 * s22 - t2 * s12) / det, (s11 * t2 - s12 * t1) / det
    tok, out = solve(2), solve(3)
    if not tok or not out or min(tok) <= 0:
        return None
    return tok[0], tok[1], out[0], out[1]


# ---------------------------------------------------------------- main

def main():
    ap = argparse.ArgumentParser()
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("affix-batches")
    p.add_argument("--batches", type=int, default=4)
    sub.add_parser("affix-assemble")
    p = sub.add_parser("select")
    p.add_argument("--wave", type=int, required=True)
    p.add_argument("--size", type=int, required=True)
    p.add_argument("--force", action="store_true")
    p = sub.add_parser("reshard")
    p.add_argument("--wave", type=int, required=True)
    p.add_argument("--verbs", required=True, help="comma-separated")
    p.add_argument("--prefix", default="r")
    p.add_argument("--start", type=int, default=1)
    p = sub.add_parser("validate")
    p.add_argument("--wave", type=int, required=True)
    p.add_argument("--fix", action="store_true", help="apply the mechanical markup fixes in place")
    p = sub.add_parser("merge")
    p.add_argument("--wave", type=int, required=True)
    p.add_argument("--dry-run", action="store_true")
    # Since wave 1 the skeptic keeps uncited standard background, so a text it cuts below the rich
    # floor is genuinely thin, and it ships as one short paragraph unless --defer-stubs is passed.
    p.add_argument("--defer-stubs", action="store_true",
                   help="defer a skeptic text too short for two paragraphs instead of shipping it as one short paragraph")
    p = sub.add_parser("report")
    p.add_argument("--wave", type=int, required=True)
    p.add_argument("--transcripts", nargs="*", help="workflow transcript directories")
    p.add_argument("--usage-start", type=float)
    p.add_argument("--usage-end", type=float)
    args = ap.parse_args()
    {"affix-batches": cmd_affix_batches, "affix-assemble": cmd_affix_assemble, "select": cmd_select,
     "reshard": cmd_reshard, "validate": cmd_validate, "merge": cmd_merge, "report": cmd_report}[args.cmd](args)


if __name__ == "__main__":
    main()
