#!/usr/bin/env python3
"""Fetch CNRTL dictionary entries for a few verbs, as evidence for the verb pass.

Stage 5c of prompts/verb-pass-plan.md: the verbs whose Stage 5 example was refuted because the
gloss is wrong or the shard's reference is too thin. One request per verb to CNRTL's JSON API
(TLFi, Wiktionnaire, Académie 8e and 9e, Littré, and concordance lines), a few seconds apart, as
the plan's "Live lookups" section allows for a handful of single-verb checks; never a scraping
run. A French-Wiktionary entry that only redirects ("Variante de paquer", "Autre orthographe de
croûter") also fetches the verb it points to.

The raw answers are cached under `wiktionary/cnrtl_cache/<word>.json`, so a dropped connection
costs nothing and a re-run fetches only what is missing. `--evidence` writes, for each verb,
the dictionary text with its tags stripped, to `verb_pass/stage5/cnrtl.json`:

    { "<verb>": { "<source>": "<text>", "concordance": [ "<author>, <title> (<date>): …" ],
                  "redirects": { "<target>": { … } } } }

This is evidence for a checker and a skeptic, never shipped text. The TLFi is ATILF's copyrighted
compilation, and a concordance line is a snippet, not a sentence.

Usage:
    python3 corpus/working/fetch_cnrtl.py panneauter empatter …
    python3 corpus/working/fetch_cnrtl.py --evidence panneauter empatter …
"""
import argparse
import html
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request

import verb_pass_lib as lib

ENDPOINT = "https://www.cnrtl.fr/api/word/"
USER_AGENT = "Conjuguer-verb-pass/1.0 (https://github.com/vermont42/Conjuguer; vermontcoder@gmail.com)"
CACHE = lib.WORKING / "wiktionary" / "cnrtl_cache"
EVIDENCE = lib.OUT_DIR / "stage5" / "cnrtl.json"
SOURCES = ("tlfi", "wiktionnaire", "academie9", "academie8", "littre")
MAX_SOURCE = 3500
MAX_CONCORDANCE = 8
DELAY = 3.0
REDIRECT = re.compile(r"(?:Variante|Autre orthographe|Orthographe rectifiée|variante orthographique)"
                      r"(?: de| par)?\s+([a-zàâäçéèêëîïôöùûüœ-]+er|[a-zàâäçéèêëîïôöùûüœ-]+ir|[a-zàâäçéèêëîïôöùûüœ-]+re)\b",
                      re.IGNORECASE)


def cached(word):
    return CACHE / f"{word}.json"


def fetch(word):
    """The verb's entry. `/api/word/<word>` answers with the first homograph, which for *baiser* is
    the noun, so an answer that is not a verb but lists one under `others` is fetched again as
    `/api/word/<word>/verbe`."""
    payload, was_cached = fetch_path(word, urllib.parse.quote(word))
    header = (payload or {}).get("header") or {}
    if header.get("pos") != "verbe" and any(o.get("pos") == "verbe" for o in header.get("others") or []):
        payload, was_cached = fetch_path(f"{word}.verbe", urllib.parse.quote(word) + "/verbe")
    return payload, was_cached


def fetch_path(name, route):
    path = cached(name)
    if path.exists():
        return json.loads(path.read_text(encoding="utf-8")), True
    request = urllib.request.Request(ENDPOINT + route,
                                     headers={"User-Agent": USER_AGENT, "Accept": "application/json"})
    for attempt in range(4):
        try:
            with urllib.request.urlopen(request, timeout=60) as response:
                payload = json.loads(response.read().decode("utf-8"))
            CACHE.mkdir(parents=True, exist_ok=True)
            path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
            time.sleep(DELAY)
            return payload, False
        except (urllib.error.URLError, TimeoutError, json.JSONDecodeError) as error:
            wait = 5 * (attempt + 1)
            print(f"    {word}: {type(error).__name__} {error}; retrying in {wait}s", file=sys.stderr)
            time.sleep(wait)
    return None, False


def text_of(fragments):
    joined = " ".join(fragment for fragment in fragments if isinstance(fragment, str))
    joined = re.sub(r"<(?:div|br)[^>]*>", " ¶ ", joined)
    joined = html.unescape(re.sub(r"<[^>]+>", " ", joined))
    joined = " ".join(joined.split())
    return re.sub(r"(?:\s*¶\s*)+", " ¶ ", joined).strip(" ¶")


def evidence(payload):
    found = {}
    for block in (payload or {}).get("content", []):
        source = block.get("id")
        if source in SOURCES:
            text = text_of(block.get("content") or [])
            if text:
                found[source] = text[:MAX_SOURCE] + (" …" if len(text) > MAX_SOURCE else "")
        elif source == "concordance":
            lines = []
            for row in (block.get("content") or [])[:MAX_CONCORDANCE]:
                snippet = row.get("content") or {}
                lines.append(f"{row.get('name')}, {row.get('title')} ({row.get('date')}): …"
                             f"{snippet.get('left', '')}[{snippet.get('matching', '').strip()}]"
                             f"{snippet.get('right', '')}…")
            if lines:
                found["concordance"] = lines
    return found


def redirect_targets(word, found):
    targets = set()
    for source in ("wiktionnaire", "tlfi", "academie9", "littre"):
        for match in REDIRECT.finditer(found.get(source, "")[:400]):
            target = lib.nfc(match.group(1).lower())
            if target != word:
                targets.add(target)
    return sorted(targets)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("verbs", nargs="+")
    parser.add_argument("--evidence", action="store_true", help="also write verb_pass/stage5/cnrtl.json")
    options = parser.parse_args()
    table, failed = {}, []
    for verb in (lib.nfc(v) for v in options.verbs):
        payload, was_cached = fetch(verb)
        if payload is None:
            failed.append(verb)
            continue
        found = evidence(payload)
        redirects = {}
        for target in redirect_targets(verb, found):
            target_payload, _ = fetch(target)
            if target_payload is None:
                failed.append(target)
                continue
            redirects[target] = evidence(target_payload)
        if redirects:
            found["redirects"] = redirects
        table[verb] = found
        print(f"  {verb}{' (cached)' if was_cached else ''}: {', '.join(k for k in found if k != 'redirects') or 'nothing'}"
              + (f"; redirects to {', '.join(redirects)}" if redirects else ""))
    if options.evidence:
        lib.write_json(EVIDENCE, table)
    if failed:
        print(f"  failed: {', '.join(failed)}; re-run to retry", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
