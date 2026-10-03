#!/usr/bin/env python3
"""Stage 0 of prompts/etymology-tail-plan.md: the per-verb etymology evidence file.

For every infinitive absent from Conjuguer/Models/Etymologies.json, gathers the rank, the
gloss, the French and English Wiktionary etymology texts, a parsed formation (prefix,
suffix, parasynthetic, compound), the base's existing entry or its own word evidence, and a
heuristic tier. Reads only local files and writes corpus/working/etymology/evidence.json.

The raw dumps take about 90 s to scan, so the first run caches the headword index at
corpus/working/etymology/wiktionary_etym_index.pkl; pass --rebuild-index to refresh it.

Run from the repo root: python3 corpus/working/build_etymology_evidence.py
"""

import argparse
import collections
import gzip
import json
import pathlib
import pickle
import re
import unicodedata
import xml.etree.ElementTree as ET

ROOT = pathlib.Path(__file__).resolve().parents[2]
FREQ = ROOT / "docs/frequencies.txt"
VERBS_XML = ROOT / "Conjuguer/Models/verbs.xml"
ETYM = ROOT / "Conjuguer/Models/Etymologies.json"
FR_RAW = ROOT / "corpus/working/wiktionary/raw/fr-extract.jsonl.gz"
EN_RAW = ROOT / "corpus/working/wiktionary/raw/kaikki-French.jsonl"
EN_VERBS = ROOT / "corpus/working/wiktionary/wiktionary_en_verbs.json"
OUT_DIR = ROOT / "corpus/working/etymology"
INDEX = OUT_DIR / "wiktionary_etym_index.pkl"
OUT = OUT_DIR / "evidence.json"

OLD_SOURCES_FR = re.compile(
    r"\b(latin|latine|grec|grecque|francique|germani\w*|gotique|ancien français|moyen français|"
    r"ancien haut allemand|moyen haut allemand|arabe|occitan|provençal|gaulois|celtique|norrois|"
    r"hébreu|ancien néerlandais|moyen néerlandais|ancien occitan|ancien provençal|"
    r"indo-européen|vieux français|vieil anglais|ancien anglais|ancien bas francique)\b", re.I)
OLD_SOURCES_EN = re.compile(
    r"\b(Latin|Greek|Frankish|Germanic|Gothic|Old French|Middle French|Old High German|"
    r"Middle High German|Arabic|Occitan|Provençal|Gaulish|Celtic|Old Norse|Hebrew|Middle Dutch|"
    r"Old Dutch|Proto-Indo-European|Anglo-Norman|Old English)\b")
MODERN_SOURCES = re.compile(
    r"\b(anglais|italien|espagnol|allemand|néerlandais|portugais|russe|japonais|English|Italian|"
    r"Spanish|German|Dutch|Portuguese|Russian|Japanese)\b")
HEDGE_FR = re.compile(
    r"peut-être|origine (obscure|inconnue|incertaine|discutée|controversée)|incertain|discuté|"
    r"on rattache|probablement|hypothèse|controvers|obscur", re.I)
ALTERNATIVE_SOURCE = re.compile(
    r"\b(ou|soit)\b.{0,40}\b(du|de l’|de l')\s*(latin|grec|ancien français|moyen français|francique)", re.I)
HEDGE_EN = re.compile(
    r"\b(perhaps|possibly|probably|uncertain|unknown|obscure|disputed|unclear|doubtful)\b", re.I)

WORD = r"[A-Za-zÀ-ÖØ-öø-ÿŒœÆæ’'-]+"
AFFIX = r"(?:-[a-zàâäçéèêëîïôöûùüÿœ]+-?|[a-zàâäçéèêëîïôöûùüÿœ]+-)"
SUFFIX_LEAD = (r"(?:le suffixe|la désinence|la terminaison)"
               r"(?: (?:verbal|verbale|verbalisant|péjoratif|itératif|diminutif|augmentatif|privatif|"
               r"fréquentatif|négatif|antonymique|désinentiel|du premier groupe))*(?: en)?")


def nfc(s):
    return unicodedata.normalize("NFC", s)


def clean_fr(t):
    t = nfc(t).replace(" ", " ")
    t = re.sub(r"\s*\^\(\[\d+\]\)", "", t)
    t = re.sub(r"^(Verbe|Mot|Nom|Adjectif)(?=[Dd]érivé|[Dd]e |[Dd]énominal)", "", t)
    t = re.sub(r"\.(?=[A-ZÉ])", ". ", t)
    t = re.sub(r"^\((Verbe|Sens) ?\d*\)\s*", "", t)
    return t.strip()


def clean_base(b):
    b = b.strip(" .,;:«»“”\"()")
    b = re.sub(r"^(l’|l'|le |la |les |du |de |d’|d')", "", b)
    return b


def build_index():
    fr = collections.defaultdict(list)
    with gzip.open(FR_RAW, "rt", encoding="utf-8") as f:
        for line in f:
            if '"lang_code": "fr"' not in line:
                continue
            o = json.loads(line)
            if o.get("lang_code") != "fr":
                continue
            texts = o.get("etymology_texts") or []
            fr[nfc(o["word"])].append((o.get("pos"), [nfc(t) for t in texts]))
    en = collections.defaultdict(list)
    with open(EN_RAW, encoding="utf-8") as f:
        for line in f:
            o = json.loads(line)
            en[nfc(o["word"])].append((o.get("pos"), nfc(o.get("etymology_text") or "")))
    idx = {"fr": dict(fr), "en": dict(en)}
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    with open(INDEX, "wb") as f:
        pickle.dump(idx, f)
    return idx


def load_glosses():
    glosses = collections.defaultdict(list)
    for v in ET.parse(VERBS_XML).getroot().iter("verb"):
        g = v.get("tn")
        if g and g not in glosses[nfc(v.get("in"))]:
            glosses[nfc(v.get("in"))].append(g)
    return {k: "; ".join(v) for k, v in glosses.items()}


def dedupe(seq):
    out = []
    for x in seq:
        if x and x not in out:
            out.append(x)
    return out


def verb_ending_suffix(verb):
    for s in ("ir", "er", "re", "oir"):
        if verb.endswith(s):
            return "-" + s
    return None


FR_PATTERNS = [
    # Dérivé de châsse, avec le préfixe en- et le suffixe -er.
    (re.compile(rf"(?:[Dd]érivé |[Ff]ormé )?(?:[Dd]u verbe |[Dd]e |[Dd]u |[Dd]’|[Dd]')({WORD}),? avec (?:le )?préfixe ({AFFIX}) et {SUFFIX_LEAD} ({AFFIX})"),
     "parasynthetic"),
    # Dérivé de traduire, avec le préfixe re-.
    (re.compile(rf"(?:[Dd]érivé |[Ff]ormé )?(?:[Dd]u verbe |[Dd]e |[Dd]u |[Dd]’|[Dd]')({WORD}),? avec (?:le )?préfixe ({AFFIX})"), "prefix"),
    # Dérivé de scolaire, avec le suffixe -iser. / avec la désinence -er.
    (re.compile(rf"(?:[Dd]érivé |[Ff]ormé )?(?:[Dd]u radical de |[Dd]u verbe |[Dd]e |[Dd]u |[Dd]’|[Dd]')({WORD}),? (?:avec|et) {SUFFIX_LEAD} ({AFFIX})"), "suffix"),
    # Formé avec le suffixe -iser sur moderne.
    (re.compile(rf"[Ff]ormé avec le suffixe ({AFFIX}) sur ({WORD})"), "suffix_rev"),
    # Formé par ajout du préfixe sur- au nom ligne avec la désinence en -er
    (re.compile(rf"préfixe ({AFFIX}) au (?:nom|verbe|mot|radical) ({WORD}) avec {SUFFIX_LEAD} ({AFFIX})"), "parasynthetic_rev"),
    # Composé de a-, doux et -ir.
    (re.compile(rf"[Cc]omposé de ([a-zàâäçéèêëîïôöûùüÿœ]+-),? ({WORD}) et (?:de |du suffixe )?(-[a-zàâäçéèêëîïôöûùüÿœ]+)"), "parasynthetic_rev"),
    # Composé de re- et faire.
    (re.compile(rf"[Cc]omposé (?:de|du préfixe) ([a-zàâäçéèêëîïôöûùüÿœ]+-) et (?:de )?({WORD})"), "prefix_rev"),
    # Dénominal de vis et -er.
    (re.compile(rf"[Dd]énominal de ({WORD})(?: \(« [^»]*»\))? et ({AFFIX})"), "suffix"),
    # Composé de garde et de manger.
    (re.compile(rf"[Cc]omposé de ({WORD}) et (?:de |du |d’|d')({WORD})"), "compound"),
    # Dénominal de vis. / Déadjectival de mou.
    (re.compile(rf"(?:[Dd]énominal|[Dd]éadjectival|[Dd]érivé) de ({WORD})"), "bare"),
    (re.compile(rf"^(?:[Dd]e|[Dd]u|[Dd]’|[Dd]')\s?({WORD})\.?$"), "bare"),
    (re.compile(rf"^→ voir ({WORD})\.?$"), "bare"),
]


def parse_fr(verb, text):
    if OLD_SOURCES_FR.search(text.split(",")[0]) or re.match(r"(Emprunt|Issu|Du latin|Du grec)", text):
        return None
    for rx, kind in FR_PATTERNS:
        m = rx.search(text)
        if not m:
            continue
        g = [x for x in m.groups()]
        if kind == "parasynthetic":
            return {"kind": "parasynthetic", "affix": g[1], "suffix": g[2], "base": clean_base(g[0])}
        if kind == "parasynthetic_rev":
            return {"kind": "parasynthetic", "affix": g[0], "suffix": g[2], "base": clean_base(g[1])}
        if kind == "prefix":
            return {"kind": "prefix", "affix": g[1], "base": clean_base(g[0])}
        if kind == "prefix_rev":
            if g[1].startswith("-"):
                return {"kind": "suffix", "affix": g[1], "base": g[0]}
            return {"kind": "prefix", "affix": g[0], "base": clean_base(g[1])}
        if kind == "suffix":
            return {"kind": "suffix", "affix": g[1], "base": clean_base(g[0])}
        if kind == "suffix_rev":
            return {"kind": "suffix", "affix": g[0], "base": clean_base(g[1])}
        if kind == "compound":
            return {"kind": "compound", "affix": None, "base": clean_base(g[0]), "second": clean_base(g[1])}
        if kind == "bare":
            base = clean_base(g[0])
            if base.lower() in ("latin", "grec", "verbe", "radical", "nom", "anglais", "italien", verb):
                return None
            if verb_ending_suffix(base) and base[-2:] in ("er", "ir", "re"):
                return None
            return {"kind": "suffix", "affix": verb_ending_suffix(verb), "base": base}
    return None


EN_LEAD = re.compile(
    r"^(?:From|Equivalent to|By surface analysis,|Analy[sz]able as|Morphologically,? from|"
    r".*?corresponding to(?: modern French)?)\s+(.+)$")


def parse_en(verb, text):
    text = re.sub(r"\(“[^”]*”\)|“[^”]*”|\([^()]*\)", "", text)
    for sentence in re.split(r"(?<=\.)\s+|;\s*", text):
        m = EN_LEAD.match(sentence.strip())
        if not m or " + " not in m.group(1):
            continue
        parts = [p.strip(" .,") for p in m.group(1).split(" + ")]
        if any(len(p.split()) != 1 for p in parts):
            continue
        prefixes = [p for p in parts if p.endswith("-") and not p.startswith("-")]
        suffixes = [p for p in parts if p.startswith("-")]
        bases = [p for p in parts if p not in prefixes and p not in suffixes]
        if len(bases) != 1 or not re.fullmatch(WORD, bases[0]):
            continue
        base = bases[0]
        if prefixes and suffixes:
            return {"kind": "parasynthetic", "affix": prefixes[0], "suffix": suffixes[0], "base": base}
        if prefixes:
            return {"kind": "prefix", "affix": prefixes[0], "base": base}
        if suffixes:
            return {"kind": "suffix", "affix": suffixes[0], "base": base}
    return None


def is_source_mention(texts_fr, texts_en):
    old = any(OLD_SOURCES_FR.search(t) for t in texts_fr) or any(OLD_SOURCES_EN.search(t) for t in texts_en)
    modern = any(MODERN_SOURCES.search(t) for t in texts_fr + texts_en)
    return old, modern


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--rebuild-index", action="store_true")
    args = ap.parse_args()

    if INDEX.exists() and not args.rebuild_index:
        with open(INDEX, "rb") as f:
            idx = pickle.load(f)
    else:
        idx = build_index()
    fr_idx, en_idx = idx["fr"], idx["en"]

    ranks = {}
    for line in FREQ.read_text(encoding="utf-8").splitlines():
        r, v = line.split(" ", 1)
        ranks[nfc(v.strip())] = int(r)
    glosses = load_glosses()
    etym = json.loads(ETYM.read_text(encoding="utf-8"))
    covered = set(etym["en"])
    en_verbs = json.loads(EN_VERBS.read_text(encoding="utf-8"))
    app_verbs = set(ranks)
    missing = sorted((v for v in ranks if v not in covered), key=lambda v: ranks[v])

    def fr_texts(word, verbs_only):
        out = []
        for pos, ts in fr_idx.get(word, []):
            if verbs_only and pos != "verb":
                continue
            out += [clean_fr(t) for t in ts]
        return dedupe(out)

    def en_texts_verb(word):
        return dedupe([nfc(e.get("etymology_text") or "").strip() for e in en_verbs.get(word, [])])

    def en_texts_any(word):
        return dedupe([t.strip() for _, t in en_idx.get(word, [])])

    def base_status(base):
        if base in covered:
            return "covered"
        if base in app_verbs:
            return "missing"
        if base in fr_idx or base in en_idx:
            return "nonverb"
        return "unknown"

    records = {}
    for verb in missing:
        tfr = fr_texts(verb, True)
        ten = en_texts_verb(verb)
        formation = None
        parse_text = None
        for t in tfr:
            formation = parse_fr(verb, t)
            if formation:
                formation["source"] = "fr"
                parse_text = t
                break
            if OLD_SOURCES_FR.search(t) or HEDGE_FR.search(t):
                break
        if not formation and not (tfr and OLD_SOURCES_FR.search(tfr[0])):
            for t in ten:
                formation = parse_en(verb, t)
                if formation:
                    formation["source"] = "en"
                    parse_text = t
                    break
        if formation:
            for k in ("affix", "suffix"):
                if formation.get(k):
                    formation[k] = formation[k].lower()
            formation["base_status"] = base_status(formation["base"])
            if formation["kind"] == "compound":
                formation["second_status"] = base_status(formation["second"])
        else:
            formation = {"kind": "none"}

        rec = {
            "rank": ranks[verb],
            "gloss": glosses.get(verb, ""),
            "fr": tfr,
            "en": ten,
            "formation": formation,
            "base_etymology_en": None,
            "base_etymology_fr": None,
            "base_word_evidence": None,
        }
        base = formation.get("base")
        if base and formation["base_status"] == "covered":
            rec["base_etymology_en"] = etym["en"][base]
            rec["base_etymology_fr"] = etym["fr"][base]
        elif base and formation["base_status"] in ("nonverb", "unknown"):
            bfr = fr_texts(base, False)
            ben = en_texts_any(base)
            if bfr or ben:
                rec["base_word_evidence"] = {"word": base, "fr": bfr, "en": ben}

        evidence = "both" if tfr and ten else "fr" if tfr else "en" if ten else "none"
        old, modern = is_source_mention(tfr, ten)
        internal = formation["kind"] != "none" and formation["source"] == "fr"
        parse_hedges = bool(parse_text and (HEDGE_FR.search(parse_text) or HEDGE_EN.search(parse_text)))
        any_hedge = any(HEDGE_FR.search(t) for t in tfr) or any(HEDGE_EN.search(t) for t in ten)
        if evidence == "none":
            tier, reason = "none", "no evidence"
        elif internal and ALTERNATIVE_SOURCE.search(parse_text):
            tier, reason = "rich", "internal derivation, or an older source the text offers as an alternative"
        elif internal and not parse_hedges:
            tier, reason = "short", "internal derivation"
        elif internal:
            tier, reason = "rich", "internal derivation with a hedged origin"
        elif any_hedge:
            tier, reason = "rich", "hedged or disputed origin"
        elif any(OLD_SOURCES_FR.search(t) for t in tfr):
            tier, reason = "rich", "names an older source language"
        elif formation["kind"] != "none":
            if any(OLD_SOURCES_EN.search(t) for t in ten):
                tier, reason = "rich", "English names an older source language"
            else:
                tier, reason = "short", "internal derivation (English evidence)"
        elif old:
            tier, reason = "rich", "names an older source language"
        elif modern:
            tier, reason = "short", "modern borrowing"
        elif max(len(x) for x in tfr + ten) > 200:
            tier, reason = "rich", "a long history with no named source language"
        else:
            tier, reason = "short", "single line, no source language"
        rec.update({"tier": tier, "tier_reason": reason, "evidence": evidence})
        records[verb] = rec

    OUT.write_text(json.dumps(records, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    def show(title, counter):
        print(f"{title}: " + ", ".join(f"{k} {n}" for k, n in counter.most_common()))

    print(f"{len(records)} records -> {OUT.relative_to(ROOT)}")
    assert len(records) == len(missing) and set(records) == set(ranks) - covered
    show("tier", collections.Counter(r["tier"] for r in records.values()))
    show("evidence", collections.Counter(r["evidence"] for r in records.values()))
    show("formation.kind", collections.Counter(r["formation"]["kind"] for r in records.values()))
    for kind in ("prefix", "suffix", "parasynthetic", "compound"):
        show(f"base_status ({kind})", collections.Counter(r["formation"].get("base_status") for r in records.values()
                                                          if r["formation"]["kind"] == kind))
    missing_bases = {r["formation"]["base"] for r in records.values()
                     if r["formation"].get("base_status") == "missing"}
    print(f"distinct missing bases: {len(missing_bases)}")
    print(f"base_word_evidence present: {sum(1 for r in records.values() if r['base_word_evidence'])}")
    affixes = collections.Counter()
    for r in records.values():
        for k in ("affix", "suffix"):
            if r["formation"].get(k):
                affixes[r["formation"][k]] += 1
    print(f"distinct affixes: {len(affixes)}")
    show("affixes", affixes)


if __name__ == "__main__":
    main()
