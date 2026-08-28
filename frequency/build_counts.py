#!/usr/bin/env python3
"""GLÀFF + Lexique 4 -> frequency/verb-counts.json, one row per distinct infinitive.

Reads the two lexicons downloaded per frequency/README.md, extracts verb-lemma frequency
counts for every infinitive in Conjuguer/Models/verbs.xml, estimates a FrWaC-equivalent
count for the infinitives no corpus lists, and writes verb-counts.json plus a report.

Run from the repo root:  python3 frequency/build_counts.py
"""

import argparse
import collections
import json
import math
import os
import re
import statistics
import sys
import unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FREQ = os.path.join(ROOT, "frequency")
VERBS_XML = os.path.join(ROOT, "Conjuguer", "Models", "verbs.xml")
GLAFF = os.path.join(FREQ, "glaff-1.2.2.txt")
OLDIES = os.path.join(FREQ, "oldiesSubLexicon.txt")
LEXIQUE = os.path.join(FREQ, "Lexique4", "Lexique4.tsv")
EDITORIAL = os.path.join(FREQ, "editorial-counts.json")
OUT = os.path.join(FREQ, "verb-counts.json")
REPORT = os.path.join(FREQ, "report.md")

CLAMP_RANK = 1000
MIN_R_SQUARED = 0.6

# A handful of GLÀFF lemmas failed to join against FrWaC: every form, the infinitive
# included, carries a count of ~0 while Le Monde and Frantext count the verb in the
# hundreds. A 1.25-billion-word web corpus cannot contain zero occurrences of `convaincre`,
# so such a count is a defect rather than a measurement, and the row is treated as
# unmeasured — routed through the estimate tiers and flagged provisional — instead of
# ranking a common verb near the bottom of the list. The thresholds are deliberately far
# from any honest register difference: at 2026-08-28 they caught exactly `convaincre`
# (2 FrWaC hits against 503 in Frantext), while the register outliers the research flagged
# (`faillir`, `étayer`, inflated in Le Monde, not depressed in FrWaC) stay measured.
QUARANTINE_RATIO = 0.02
QUARANTINE_FLOOR = 200

# GLÀFF is `|`-separated with 17 fields; these are the 0-based indices of the three
# *lemma* absolute-frequency columns (README fields 8, 12, 16). Every inflected form of a
# lemma repeats the lemma count, so a max over the lemma's rows recovers it.
GLAFF_TAG, GLAFF_LEMMA = 1, 2
GLAFF_FRANTEXT, GLAFF_LM10, GLAFF_FRWAC = 7, 11, 15


def french_key(word):
    """Mirrors `compare(_:locale: Util.french)`: accents are a secondary difference, and ICU
    expands the ligatures, so œilletonner sorts under `oe` rather than after every `z`."""
    expanded = word.replace("œ", "oe").replace("Œ", "OE").replace("æ", "ae").replace("Æ", "AE")
    stripped = "".join(c for c in unicodedata.normalize("NFD", expanded) if not unicodedata.combining(c))
    return (stripped.lower(), word)


def target_infinitives():
    text = open(VERBS_XML, encoding="utf-8").read()
    infinitives = re.findall(r'<verb in="([^"]+)"', text)
    old_ranks = {}
    for infinitif, attrs in re.findall(r'<verb in="([^"]+)"([^/]*)/>', text):
        match = re.search(r'\bfr="(\d+)"', attrs)
        if match:
            old_ranks[infinitif] = int(match.group(1))
    return sorted(set(infinitives), key=french_key), old_ranks


def read_glaff():
    lemmas = {}
    with open(GLAFF, encoding="utf-8") as handle:
        for line in handle:
            fields = line.rstrip("\n").split("|")
            if len(fields) < 17 or not fields[GLAFF_TAG].startswith("V"):
                continue
            try:
                counts = (
                    int(fields[GLAFF_FRWAC]),
                    int(fields[GLAFF_LM10]),
                    int(fields[GLAFF_FRANTEXT]),
                )
            except ValueError:
                continue
            lemma = fields[GLAFF_LEMMA]
            previous = lemmas.get(lemma)
            lemmas[lemma] = counts if previous is None else tuple(map(max, previous, counts))
    return lemmas


def read_oldies():
    """The obsolete-entry lexicon carries no frequency columns; it only tells us that a
    missing verb is a Wiktionnaire archaism rather than an oversight."""
    lemmas = set()
    with open(OLDIES, encoding="utf-8") as handle:
        for line in handle:
            fields = line.rstrip("\n").split("|")
            if len(fields) >= 3 and fields[1].startswith("V"):
                lemmas.add(fields[2])
    return lemmas


def read_lexique():
    lemmas = {}
    with open(LEXIQUE, encoding="utf-8") as handle:
        header = handle.readline().rstrip("\n").split("\t")
        lemma_column = header.index("4_Lemme")
        pos_column = header.index("5_Cgram")
        frequency_column = header.index("12_FreqLemme")
        for line in handle:
            fields = line.rstrip("\n").split("\t")
            if len(fields) <= frequency_column or not fields[pos_column].startswith("VER"):
                continue
            try:
                frequency = float(fields[frequency_column])
            except ValueError:
                continue
            lemma = fields[lemma_column]
            lemmas[lemma] = max(lemmas.get(lemma, 0.0), frequency)
    return lemmas


def fit_calibration(rows):
    """Least-squares log(frwac) = a + b·log(lexique4), over verbs both sources count."""
    points = [
        (math.log(row["lexique4_per_million"]), math.log(row["frwac"]))
        for row in rows.values()
        if row.get("frwac", 0) > 0 and row.get("lexique4_per_million", 0) > 0
    ]
    n = len(points)
    mean_x = sum(x for x, _ in points) / n
    mean_y = sum(y for _, y in points) / n
    covariance = sum((x - mean_x) * (y - mean_y) for x, y in points)
    variance = sum((x - mean_x) ** 2 for x, _ in points)
    slope = covariance / variance
    intercept = mean_y - slope * mean_x
    residuals = sorted(y - (intercept + slope * x) for x, y in points)
    total = sum((y - mean_y) ** 2 for _, y in points)
    residual_sum = sum(r ** 2 for r in residuals)
    r_squared = 1 - residual_sum / total
    quartiles = [residuals[int(q * (n - 1))] for q in (0.25, 0.5, 0.75, 0.95)]
    return intercept, slope, r_squared, n, quartiles


def prefix_ratios(lexique):
    """median(lexique4(prefix + base) / lexique4(base)) per hyphenated prefix."""
    by_prefix = collections.defaultdict(list)
    for lemma, frequency in lexique.items():
        if "-" not in lemma or frequency <= 0:
            continue
        prefix, _, base = lemma.rpartition("-")
        base_frequency = lexique.get(base, 0.0)
        if base_frequency > 0:
            by_prefix[prefix + "-"].append(frequency / base_frequency)
    ratios = {prefix: statistics.median(values) for prefix, values in by_prefix.items() if len(values) >= 3}
    everything = [value for values in by_prefix.values() for value in values]
    return ratios, statistics.median(everything)


def split_compound(infinitif, known):
    """Returns (prefix, base) if the infinitive is a prefixed form of a verb we can measure."""
    if "-" in infinitif:
        prefix, _, base = infinitif.rpartition("-")
        return prefix + "-", base
    for prefix in ("co", "contre", "entre", "sous", "sur", "re", "dé"):
        if infinitif.startswith(prefix) and infinitif[len(prefix):] in known:
            return prefix, infinitif[len(prefix):]
    return None, None


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dry-run", action="store_true", help="report only; write nothing")
    args = parser.parse_args()

    targets, old_ranks = target_infinitives()
    glaff = read_glaff()
    oldies = read_oldies()
    lexique = read_lexique()

    rows = {}
    quarantined = []
    for infinitif in targets:
        row = {}
        if infinitif in glaff:
            frwac, lm10, frantext = glaff[infinitif]
            corroboration = max(lm10, frantext)
            if corroboration >= QUARANTINE_FLOOR and frwac < QUARANTINE_RATIO * corroboration:
                quarantined.append((infinitif, frwac, lm10, frantext))
            else:
                row["frwac"] = frwac
            row["lm10"] = lm10
            row["frantext"] = frantext
        if infinitif in lexique:
            row["lexique4_per_million"] = lexique[infinitif]
        rows[infinitif] = row

    measured = sorted((row["frwac"] for row in rows.values() if "frwac" in row), reverse=True)
    clamp = measured[CLAMP_RANK - 1]

    intercept, slope, r_squared, fit_n, quartiles = fit_calibration(rows)
    ratios, global_ratio = prefix_ratios(lexique)
    editorial = json.load(open(EDITORIAL, encoding="utf-8")) if os.path.exists(EDITORIAL) else {}

    estimates = collections.defaultdict(list)
    for infinitif in targets:
        row = rows[infinitif]
        if "frwac" in row:
            continue
        if row.get("lexique4_per_million", 0) > 0:
            count = math.exp(intercept + slope * math.log(row["lexique4_per_million"]))
            basis = f"Lexique 4 {row['lexique4_per_million']:.4f} per million"
            method = "lexique4-fit"
        else:
            prefix, base = split_compound(infinitif, {k for k, v in rows.items() if "frwac" in v})
            base_count = rows.get(base, {}).get("frwac") if base else None
            if base_count:
                ratio = ratios.get(prefix, global_ratio)
                count = base_count * ratio
                basis = f"{base} ({base_count}) × {ratio:.4f}, the {prefix} prefix ratio"
                method = "base-ratio"
            elif infinitif in editorial:
                count = editorial[infinitif]["count"]
                basis = editorial[infinitif]["reason"]
                method = "editorial"
            else:
                estimates["unresolved"].append(infinitif)
                continue
        count = min(int(round(count)), clamp)
        row["frwac_estimate"] = {"count": count, "method": method, "basis": basis}
        estimates[method].append(infinitif)

    failures = []
    if estimates["unresolved"]:
        failures.append(
            f"{len(estimates['unresolved'])} infinitives have neither a measured nor an estimated "
            f"count; add them to editorial-counts.json: {', '.join(sorted(estimates['unresolved'], key=french_key))}"
        )
    if r_squared < MIN_R_SQUARED:
        failures.append(f"calibration R² {r_squared:.3f} is below {MIN_R_SQUARED}")

    def primary(infinitif):
        row = rows[infinitif]
        return row.get("frwac", row.get("frwac_estimate", {}).get("count"))

    def sort_key(infinitif):
        row = rows[infinitif]
        return (
            -(primary(infinitif) or -1),
            -row.get("lm10", -1),
            -row.get("frantext", -1),
            -row.get("lexique4_per_million", -1),
            french_key(infinitif),
        )

    ordered = sorted(targets, key=sort_key)
    ranks = {infinitif: index + 1 for index, infinitif in enumerate(ordered)}

    if ordered[:3] != ["être", "avoir", "faire"]:
        failures.append(f"FrWaC top three are {ordered[:3]}, not être/avoir/faire")
    over_clamp = [i for i in targets if rows[i].get("frwac_estimate", {}).get("count", 0) > clamp]
    if over_clamp:
        failures.append(f"estimates above the clamp: {over_clamp}")

    # Only meaningful on the first run: `apply_counts.py` removes the 2021 `fr` ranks this
    # compares against, so a rebuild after the migration reports no continuity numbers.
    shared = [i for i in targets if i in old_ranks]
    spearman, movers = None, []
    if len(shared) > 1:
        new_order = {infinitif: index for index, infinitif in enumerate(sorted(shared, key=lambda i: ranks[i]))}
        old_order = {infinitif: index for index, infinitif in enumerate(sorted(shared, key=lambda i: old_ranks[i]))}
        n = len(shared)
        spearman = 1 - 6 * sum((new_order[i] - old_order[i]) ** 2 for i in shared) / (n * (n * n - 1))
        movers = sorted(shared, key=lambda i: -abs(new_order[i] - old_order[i]))[:20]

    zeros = [i for i in targets if rows[i].get("frwac") == 0]
    zero_everywhere = [
        i for i in zeros
        if not rows[i].get("lm10") and not rows[i].get("frantext") and not rows[i].get("lexique4_per_million")
    ]
    tie_groups = collections.Counter(primary(i) for i in targets)

    lines = []
    write = lines.append
    write("# Frequency build report\n")
    write(f"- {len(targets)} distinct infinitives in `verbs.xml`.")
    write(f"- GLÀFF covers {sum(1 for i in targets if 'frwac' in rows[i])}; Lexique 4 covers "
          f"{sum(1 for i in targets if 'lexique4_per_million' in rows[i])}.")
    write(f"- Calibration over {fit_n} verbs: log(frwac) = {intercept:.4f} + {slope:.4f}·log(lex4), "
          f"R² = {r_squared:.4f}; residual quartiles (log) "
          f"{quartiles[0]:.3f} / {quartiles[1]:.3f} / {quartiles[2]:.3f}, 95th {quartiles[3]:.3f} "
          f"(×{math.exp(quartiles[2]):.2f} at Q3, ×{math.exp(quartiles[3]):.2f} at P95).")
    write(f"- Clamp (measured count at rank {CLAMP_RANK}): {clamp}.")
    write(f"- Global hyphen prefix ratio: {global_ratio:.4f}; per-prefix: "
          + ", ".join(f"{p} {r:.3f}" for p, r in sorted(ratios.items())) + ".")
    write(f"- Measured zeros: {len(zeros)} in FrWaC, {len(zero_everywhere)} in every source.")
    if spearman is None:
        write("- No 2021 `fr=` ranks remain in verbs.xml to compare against.\n")
    else:
        write(f"- Spearman vs the 2021 `fr=` ranks over {len(shared)} verbs: {spearman:.4f}.\n")

    write("## Estimated counts\n")
    for method in ("lexique4-fit", "base-ratio", "editorial"):
        chosen = sorted(estimates[method], key=lambda i: ranks[i])
        write(f"### {method} ({len(chosen)})\n")
        for infinitif in chosen:
            estimate = rows[infinitif]["frwac_estimate"]
            write(f"- `{infinitif}` → {estimate['count']} hits, rank #{ranks[infinitif]} — {estimate['basis']}")
        write("")

    write("## Quarantined FrWaC counts\n")
    if quarantined:
        for infinitif, frwac, lm10, frantext in quarantined:
            estimate = rows[infinitif]["frwac_estimate"]
            write(f"- `{infinitif}`: FrWaC {frwac} against Le Monde {lm10} / Frantext {frantext} — "
                  f"estimated {estimate['count']} ({estimate['method']}), rank #{ranks[infinitif]}")
    else:
        write("None.")
    write("")

    write("## Absent from GLÀFF\n")
    absent = [i for i in targets if "frwac" not in rows[i]]
    write(f"{len(absent)} infinitives: " + ", ".join(f"`{i}`" for i in sorted(absent, key=french_key)) + "\n")
    archaic = sorted(set(absent) & oldies, key=french_key)
    write(f"Of those, {len(archaic)} appear in GLÀFF's obsolete-entry lexicon (no counts there): "
          + ", ".join(f"`{i}`" for i in archaic) + "\n")

    write("## Top 30\n")
    write(", ".join(ordered[:30]) + "\n")

    write("## Biggest movers vs 2021\n")
    if not movers:
        write("Not computable: verbs.xml no longer carries the 2021 ranks.")
    for infinitif in movers:
        write(f"- `{infinitif}`: #{old_ranks[infinitif]} → #{ranks[infinitif]} "
              f"({primary(infinitif)} FrWaC hits)")
    write("")

    write("## Largest tie groups (shared primary count)\n")
    for count, size in tie_groups.most_common(8):
        write(f"- {size} verbs at {count} hits")
    write("")

    report = "\n".join(lines)
    print(report)

    if failures:
        print("\nGATE FAILURES:", file=sys.stderr)
        for failure in failures:
            print(f"  - {failure}", file=sys.stderr)
        sys.exit(1)

    if args.dry_run:
        print("\n--dry-run: nothing written.")
        return

    with open(OUT, "w", encoding="utf-8") as handle:
        json.dump({i: rows[i] for i in targets}, handle, ensure_ascii=False, indent=1, sort_keys=False)
        handle.write("\n")
    open(REPORT, "w", encoding="utf-8").write(report + "\n")
    print(f"\nWrote {OUT} and {REPORT}.")


if __name__ == "__main__":
    main()
