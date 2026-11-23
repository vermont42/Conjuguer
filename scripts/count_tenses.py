#!/usr/bin/env python3
"""Counts how often each tense occurs in Conjuguer's text corpus.

The verb page orders its tense cards by these counts (Phase 6 of
plans/browse_and_verb_implementation.md). docs/tense_frequency.md describes the method and
records the results; read it before changing a rule here.

The script reads corpus/working/conjugations.json, which ConjugationMapTool writes from the same
Conjugator that builds the app's conjugation map, so the count and the page agree on what a
conjugation is. Run scripts/write_forms_json.sh first if the dump is missing or stale.

    python3 scripts/count_tenses.py                       # the tables, as Markdown
    python3 scripts/count_tenses.py --examples impératif  # sample contexts behind one count
    python3 scripts/count_tenses.py --examples passéSimple --folder government
"""

import argparse
import json
import random
import re
import sys
import unicodedata
import xml.etree.ElementTree as ET
from collections import Counter, defaultdict
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
CONJUGATIONS = REPO / "corpus" / "working" / "conjugations.json"
VERBS_XML = REPO / "Conjuguer" / "Models" / "verbs.xml"
ORIGINALS = REPO / "corpus" / "originals"

FOLDERS = ["literature", "classical", "government", "wikipedia", "technology"]

# Old French, which the modern Conjugator cannot read.
SKIPPED_FILES = {"chanson-roland-oxford.txt"}

SIMPLE_TENSES = [
    "indicatifPrésent", "passéSimple", "imparfait", "futurSimple", "conditionnelPrésent",
    "subjonctifPrésent", "subjonctifImparfait", "impératif",
]
COMPOUND_TENSES = [
    "passéComposé", "plusQueParfait", "passéAntérieur", "passéSurcomposé", "futurAntérieur",
    "conditionnelPassé", "subjonctifPassé", "subjonctifPlusQueParfait", "impératifPassé",
]
PARTICIPLES = ["participePassé", "participePrésent"]

COMPOUND_OF = {
    "indicatifPrésent": "passéComposé",
    "imparfait": "plusQueParfait",
    "passéSimple": "passéAntérieur",
    "futurSimple": "futurAntérieur",
    "conditionnelPrésent": "conditionnelPassé",
    "subjonctifPrésent": "subjonctifPassé",
    "subjonctifImparfait": "subjonctifPlusQueParfait",
    "impératif": "impératifPassé",
}

SUBJECTS = {
    "je": "firstSingular", "j'": "firstSingular", "tu": "secondSingular",
    "il": "thirdSingular", "elle": "thirdSingular", "on": "thirdSingular",
    "c'": "thirdSingular", "ce": "thirdSingular", "ça": "thirdSingular", "cela": "thirdSingular",
    "ceci": "thirdSingular", "nous": "firstPlural", "vous": "secondPlural",
    "ils": "thirdPlural", "elles": "thirdPlural",
}
# nous and vous are objects as often as subjects, so they count as a subject only when no other
# subject pronoun stands before them.
OBJECTS = {
    "me", "m'", "te", "t'", "se", "s'", "le", "la", "les", "l'", "lui", "leur", "y", "en",
    "ne", "n'", "nous", "vous",
}
REFLEXIVES = {"me", "m'", "te", "t'", "se", "s'", "nous", "vous"}
INVERTED = {"je", "tu", "il", "elle", "on", "nous", "vous", "ils", "elles", "ce"}
HYPHEN_PRONOUNS = INVERTED | {"t", "moi", "toi", "le", "la", "les", "lui", "leur", "y", "en", "m'", "t'"}

# A word after one of these is a noun or an infinitive's complement, not a conjugated verb.
DETERMINERS = {
    "le", "la", "les", "l'", "un", "une", "des", "du", "au", "aux", "ce", "cet", "cette", "ces",
    "mon", "ton", "son", "ma", "ta", "sa", "mes", "tes", "ses", "notre", "votre", "nos", "vos",
    "leur", "leurs", "chaque", "quelque", "quelques", "plusieurs", "aucun", "aucune", "tout",
    "toute", "tous", "toutes", "certains", "certaines", "nul", "nulle", "divers", "diverses",
    "différents", "différentes", "de", "d'", "à", "par", "pour", "sans", "sur", "sous", "dans",
    "avec", "entre", "vers", "chez", "contre", "selon", "après", "avant", "depuis", "pendant",
    "en", "dès", "quel", "quelle", "quels", "quelles", "cet", "nouveau", "nouvelle", "premier",
    "première", "seul", "seule", "grand", "grande", "petit", "petite", "bon", "bonne",
}

# Unambiguous signs of a noun: articles that are never object pronouns, and prepositions.
NOUN_MARKERS = {
    "un", "une", "des", "du", "au", "aux", "cet", "cette", "ces", "mon", "ma", "ton", "ta", "son",
    "sa", "mes", "tes", "ses", "notre", "votre", "nos", "vos", "leurs", "chaque", "quelques",
    "plusieurs", "aucun", "aucune", "de", "d'", "à", "par", "pour", "sur", "dans", "avec", "sans",
}

# Words between an auxiliary and its participle: negation, adverbs, inverted pronouns.
BETWEEN = {
    "pas", "plus", "jamais", "rien", "point", "guère", "déjà", "toujours", "bien", "mal",
    "beaucoup", "souvent", "encore", "même", "aussi", "peut-être", "enfin", "alors", "donc",
    "tout", "tous", "vraiment", "trop", "assez", "presque", "longtemps", "ainsi", "seulement",
    "certainement", "probablement", "sans", "doute", "jusqu'ici", "là", "ensuite", "néanmoins",
    "notamment", "également", "pourtant", "parfois", "toutefois", "désormais", "récemment",
    "ici",
} | INVERTED

# Spellings that are conjugations of some verb but are nearly always another word: prepositions,
# adverbs, conjunctions, and pronouns. They count only beside a subject pronoun ("je puis") or an
# auxiliary, so "puis" the adverb, "entre" the preposition, and "été" the season fall away.
FUNCTION_WORDS = {
    "entre", "contre", "plus", "puis", "pendant", "durant", "suivant", "maintenant", "soit",
    "été", "tu", "vu", "excepté", "attendu", "point", "devant", "concernant", "touchant",
    "moyennant", "nonobstant", "passé", "sauf", "or", "car", "fi", "mais", "pas", "sans",
    "ni", "fors", "las", "ores", "outre", "lui", "lors", "vis", "sus", "dessus", "pis", "mi", "vers",
}

# Words found by reading the samples behind each count: nouns and adjectives whose spelling is
# also some rare verb's conjugation.
STOPLIST = {
    "content", "contents", "excellent", "violent", "équivalent", "président", "résident",
    "expédient", "affluent", "influent", "ardent", "évident", "couvent", "parent", "négligent",
    "convergent", "divergent", "émergent", "précédent", "excédent", "agent", "argent", "moment",
    "ordonnance", "souvent", "comment", "vent", "dent", "cent", "lent", "gent", "client",
    "patient", "torrent", "talent", "accent", "absent", "présent", "récent", "fréquent",
    "urgent", "prudent", "ascendant", "commandant", "sergent", "régent", "adolescent",
    "rapport", "pays", "temps", "fois", "corps", "mot", "loi", "monde", "nombre", "forme",
    "place", "politique", "pratique", "programme", "compte", "marche", "porte", "suite",
    "contrôle", "travail", "partie", "vie", "fin", "face", "type", "base", "ligne", "cause",
    "zone", "page", "ville", "rôle", "titre", "texte", "terme", "œuvre", "oeuvre", "sorte",
    "date", "rue", "tête", "voix", "voie", "main", "mer", "air", "or", "son", "ton", "été",
    "cas", "lieu", "an", "ans", "jour", "jours", "ledit", "ladite", "fort", "nord", "sud",
    "ouest", "data", "mise",
}

# Agreed past participles of these verbs would collide with common words (pouvoir's "pue",
# devoir's "dus").
INVARIABLE_PARTICIPLES = {"être", "pouvoir", "devoir"}

CLAUSE_BREAKS = set(".!?;:«»()[]\"“”—…") | {"--"}
# A sentence, for an imperative, starts after these. A parenthesis or a colon does not start one:
# "Synonymes : bois" is a list, not an order.
SENTENCE_BREAKS = set(".!?;«»\"“”—…") | {"--"}
SENTENCE_ENDS = {".", "!", "?", "…", ";"}
COMMA = ","


def strip_accents(text):
    return "".join(c for c in unicodedata.normalize("NFD", text) if unicodedata.category(c) != "Mn")


class Lexicon:
    """Every spelling of every cell, with the readings it can have."""

    def __init__(self):
        cells = json.loads(CONJUGATIONS.read_text())
        root = ET.parse(VERBS_XML).getroot()
        self.auxiliary = {}
        self.pronominal = set()
        for verb in root.iter("verb"):
            infinitif = verb.get("in")
            self.auxiliary[infinitif] = verb.get("ay", "a")
            if verb.get("re") == "t":
                self.pronominal.add(infinitif)

        self.readings = defaultdict(set)    # spelling -> {(tense, person)}
        self.participles = defaultdict(set)  # spelling -> {verb}
        self.aux_readings = defaultdict(set)  # spelling -> {(aux, tense, person)}
        for verb_id, verb_cells in cells.items():
            verb = verb_id.split("(")[0].strip()
            for key, value in verb_cells.items():
                tense, _, person = key.partition(".")
                if tense not in SIMPLE_TENSES and tense not in PARTICIPLES:
                    continue
                spelling = value.lower()
                if not spelling or " " in spelling:
                    continue
                if tense == "participePassé":
                    for form in self.agreed(spelling, verb):
                        self.readings[form].add((tense, ""))
                        self.participles[form].add(verb)
                else:
                    self.readings[spelling].add((tense, person))
                if verb in ("avoir", "être"):
                    self.aux_readings[spelling].add((verb, tense, person))
        for aux in ("avoir", "être"):
            self.aux_readings[aux].add((aux, "infinitif", ""))

    @staticmethod
    def agreed(participle, verb):
        if verb in INVARIABLE_PARTICIPLES:
            return [participle]
        base = participle[:-1] + "u" if participle.endswith("û") else participle
        if participle.endswith(("s", "x")):
            return [participle, base + "e", base + "es"]
        return [participle, base + "e", base + "s", base + "es"]

    def lookup(self, word):
        if word in self.readings:
            return word
        # Seventeenth-century spelling of the imparfait and the conditionnel: étoit, sauroit. Only
        # those, since "parfois" and "trois" would otherwise become parfaire and traire.
        index = word.rfind("oi")
        if index >= 0:
            modern = word[:index] + "ai" + word[index + 2:]
            tenses = {t for t, _ in self.readings.get(modern, ())}
            if tenses & {"imparfait", "conditionnelPrésent"}:
                return modern
        return None


TOKEN = re.compile(r"[A-Za-zÀ-ÖØ-öø-ÿŒœ]+(?:[-'][A-Za-zÀ-ÖØ-öø-ÿŒœ]+)*'?|--|[.!?;:,«»()\[\]\"“”—…]")
ELISIONS = {"j", "l", "d", "m", "t", "s", "n", "c", "qu", "jusqu", "lorsqu", "puisqu", "quoiqu", "presqu"}
KEEP_WHOLE = {"aujourd'hui", "quelqu'un", "quelqu'une", "prud'homme", "prud'hommes"}


class Token:
    __slots__ = ("text", "word", "line_start", "capitalized", "inverted", "hyphen_object", "kind")

    def __init__(self, text, line_start=False):
        self.text = text
        self.word = text.lower()
        self.line_start = line_start
        self.capitalized = text[:1].isupper()
        self.inverted = False
        self.hyphen_object = False
        self.kind = "word"


def tokenize(paragraph_lines):
    tokens = []
    for line in paragraph_lines:
        line = line.replace("’", "'").replace("‘", "'").replace("_", " ")
        first = True
        for match in TOKEN.finditer(line):
            raw = match.group(0)
            if raw in CLAUSE_BREAKS or raw == COMMA:
                token = Token(raw)
                token.kind = "punct"
                tokens.append(token)
                continue
            if raw.isupper() and len(raw) > 1:
                first = False
                token = Token(raw)
                token.kind = "skip"
                tokens.append(token)
                continue
            for piece in split_word(raw):
                token = Token(piece, line_start=first)
                if piece.startswith("-"):
                    token.text = piece[1:]
                    token.word = token.text.lower()
                    if token.word in INVERTED:
                        token.inverted = True
                    else:
                        token.hyphen_object = True
                tokens.append(token)
                first = False
    return tokens


def split_word(raw):
    if raw.lower() in KEEP_WHOLE:
        return [raw]
    pieces = []
    rest = raw
    while "'" in rest[:-1]:
        head, _, tail = rest.partition("'")
        if head.lower() in ELISIONS:
            pieces.append(head + "'")
            rest = tail
        else:
            break
    if "-" in rest:
        parts = rest.split("-")
        if all(p.lower().rstrip("'") in HYPHEN_PRONOUNS for p in parts[1:]):
            pieces.append(parts[0])
            for part in parts[1:]:
                if part.lower() == "t":
                    continue
                pieces.append("-" + part)
            return pieces
    pieces.append(rest)
    return pieces


def paragraphs(path):
    text = path.read_text(encoding="utf-8", errors="replace")
    gutenberg = "*** START OF" in text
    if gutenberg:
        text = text.split("*** START OF", 1)[1].split("\n", 1)[1]
        text = text.split("*** END OF", 1)[0]
        text = re.sub(r"(\w)-\n(\w)", r"\1\2", text)
        block = []
        for line in text.split("\n"):
            if line.strip():
                block.append(line)
            elif block:
                yield block
                block = []
        if block:
            yield block
    else:
        for line in text.split("\n"):
            if line.strip():
                yield [line]


class Counter3:
    def __init__(self):
        self.certain = Counter()
        self.ambiguous = Counter()  # (frozenset of tenses, que flag) -> count
        self.examples = defaultdict(list)
        self.aside = Counter()

    def add(self, tenses, in_que, context):
        tenses = frozenset(tenses)
        if len(tenses) == 1:
            (tense,) = tenses
            self.certain[(tense, in_que)] += 1
        else:
            self.ambiguous[(tenses, in_que)] += 1
        for tense in tenses:
            bucket = self.examples[tense]
            if len(bucket) < 4000:
                bucket.append((context, len(tenses) > 1))

    def resolve(self, iterations=20):
        """Shares each ambiguous word among its tenses in the proportions the folder's words show,
        computed separately inside and outside a que clause."""
        totals = Counter()
        for (tense, in_que), count in self.certain.items():
            totals[(tense, in_que)] += count
        estimate = Counter(totals)
        for _ in range(iterations):
            updated = Counter(totals)
            for (tenses, in_que), count in self.ambiguous.items():
                weights = {t: estimate[(t, in_que)] + 0.5 for t in tenses}
                total = sum(weights.values())
                for tense, weight in weights.items():
                    updated[(tense, in_que)] += count * weight / total
            estimate = updated
        result = Counter()
        for (tense, _), count in estimate.items():
            result[tense] += count
        return result


def clause_has_que(tokens, index):
    for j in range(index - 1, -1, -1):
        token = tokens[j]
        if token.kind == "punct":
            if token.text != COMMA:
                return False
            continue
        if token.word in ("que", "qu'", "quoique", "quoiqu'"):
            return True
    return False


ABBREVIATIONS = {
    "art", "ch", "cf", "al", "etc", "p", "pp", "chap", "vol", "no", "n", "dir", "env", "min", "max",
    "mio", "mrd", "fr", "chf", "m", "mm", "mme", "st", "ste", "éd", "ann", "sect", "let", "ss",
    "s", "fig", "tab", "réf", "op", "ibid", "av", "apr", "j", "c", "hab", "km", "kg", "env",
}
DIALOG_OPENERS = {"«", "—", "--", "“", '"'}


def sentence_start_before(tokens, index):
    """Whether only ne and object pronouns stand between the word and the start of a sentence. A
    sentence starts with a capital, after a period that does not end an abbreviation ("art."), or
    after an opening quotation mark that itself starts a sentence, so that « concours partiels »
    quoted mid-sentence is not an order."""
    for j in range(index - 1, -1, -1):
        token = tokens[j]
        if token.kind == "punct":
            if token.text not in SENTENCE_BREAKS:
                return False
            if token.text == "." and j > 0 and tokens[j - 1].word in ABBREVIATIONS:
                return False
            if token.text in DIALOG_OPENERS and j > 0 and tokens[j - 1].kind != "punct":
                return False
            return tokens[j + 1].capitalized or token.text in DIALOG_OPENERS
        if token.word in ("ne", "n'", "le", "la", "les", "l'", "lui", "leur", "y", "en", "me", "m'", "te", "t'", "nous", "vous"):
            continue
        return False
    return tokens[0].capitalized


def ends_as_order(tokens, index):
    """Whether the sentence holding the word ends with a period or an exclamation mark, as an order
    does, rather than a question mark or nothing at all, as a heading or a list item does."""
    for j in range(index + 1, len(tokens)):
        if tokens[j].kind == "punct" and tokens[j].text in SENTENCE_ENDS:
            return tokens[j].text != "?"
    return False


def subject_before(tokens, index):
    """The person of the subject pronoun that heads the word's clause, skipping object pronouns."""
    found = None
    for j in range(index - 1, -1, -1):
        token = tokens[j]
        if token.kind != "word" or token.inverted:
            break
        word = token.word
        if word in SUBJECTS and word not in ("nous", "vous"):
            return SUBJECTS[word]
        if word in ("nous", "vous"):
            found = SUBJECTS[word]
            continue
        if word in OBJECTS:
            continue
        break
    return found


def subject_after(tokens, index):
    if index + 1 < len(tokens) and tokens[index + 1].inverted:
        return SUBJECTS.get(tokens[index + 1].word)
    return None


def context_of(tokens, index, span=1):
    start = max(0, index - 6)
    end = min(len(tokens), index + span + 5)
    words = []
    for j in range(start, end):
        text = tokens[j].text
        if start <= j < index or j >= index + span:
            words.append(text)
        elif j == index:
            words.append("[" + " ".join(t.text for t in tokens[index:index + span]) + "]")
    return " ".join(words)


class FolderCount:
    def __init__(self, lexicon):
        self.lexicon = lexicon
        self.simple = Counter3()
        self.participle_alone = Counter3()
        self.compound = Counter3()
        self.aside = Counter()
        self.aside_examples = defaultdict(list)
        self.words = 0
        self.ant_forms = Counter()
        self.as_noun = Counter()
        self.as_verb = Counter()

    def scan_ant(self, tokens):
        for i, token in enumerate(tokens):
            if token.kind != "word":
                continue
            if token.word.endswith(("ant", "ante", "ants", "antes")):
                self.ant_forms[token.word] += 1
            if i > 0 and tokens[i - 1].word in NOUN_MARKERS:
                self.as_noun[token.word] += 1
            elif subject_before(tokens, i) is not None:
                self.as_verb[token.word] += 1

    def is_mostly_noun(self, word):
        """Whether the folder puts an article or a preposition before the word at least as often as
        a subject pronoun: Lutte, Analyse, and Centre opening a heading are nouns, not orders."""
        return self.as_noun[word] >= max(2, self.as_verb[word])

    def is_adjectival_ant(self, word):
        bare = self.ant_forms[word]
        agreed = self.ant_forms[word + "e"] + self.ant_forms[word + "s"] + self.ant_forms[word + "es"]
        return agreed >= max(2, 0.1 * bare)

    def candidates(self, token):
        """The readings a word can have on its own, or None if it is not a verb here."""
        if token.kind != "word" or token.hyphen_object or token.inverted:
            return None
        if token.capitalized and not token.line_start and not token.text.isupper():
            return None
        spelling = self.lexicon.lookup(token.word)
        if spelling is None:
            return None
        return spelling

    def count(self, tokens):
        consumed = set()
        n = len(tokens)
        for i, token in enumerate(tokens):
            if token.kind == "word":
                self.words += 1
        # Compounds first, so that their auxiliaries and participles are not counted alone.
        for i in range(n):
            if i in consumed:
                continue
            spelling = self.candidates(tokens[i])
            if tokens[i].kind == "word" and tokens[i].word in ("avoir", "être"):
                spelling = tokens[i].word
            if spelling is None or spelling not in self.lexicon.aux_readings:
                continue
            self.try_compound(tokens, i, spelling, consumed)
        for i in range(n):
            if i in consumed:
                continue
            spelling = self.candidates(tokens[i])
            if spelling is None:
                continue
            self.count_alone(tokens, i, spelling)

    def next_participle(self, tokens, start, limit=4):
        skipped = 0
        j = start
        while j < len(tokens) and skipped <= limit:
            token = tokens[j]
            if token.kind != "word":
                return None
            # "n'a point de gêne" is not poindre's participle, nor "a plus" plaire's.
            if token.inverted or token.word in BETWEEN:
                j += 1
                skipped += 1
                continue
            if token.word in self.lexicon.participles and not token.hyphen_object:
                return j
            return None
        return None

    def try_compound(self, tokens, i, spelling, consumed):
        aux_readings = self.lexicon.aux_readings[spelling]
        j = self.next_participle(tokens, i + 1)
        if j is None:
            return
        participle = tokens[j].word
        verbs = self.lexicon.participles[participle]
        reflexive = i > 0 and tokens[i - 1].word in REFLEXIVES or (
            i > 1 and tokens[i - 1].word in ("ne", "n'") and tokens[i - 2].word in REFLEXIVES)
        uses_être = any(self.lexicon.auxiliary.get(v) == "e" or v in self.lexicon.pronominal for v in verbs) or reflexive
        auxes = {aux for aux, _, _ in aux_readings}

        if "avoir" in auxes and participle == "eu":
            k = self.next_participle(tokens, j + 1)
            if k is not None and tokens[k].word != "été":
                tenses = {"passéSurcomposé"}
                self.compound.add(tenses, False, context_of(tokens, i, k - i + 1))
                consumed.update(range(i, k + 1))
                return

        if "avoir" in auxes:
            aux = "avoir"
        elif "être" in auxes and uses_être:
            aux = "être"
        elif "être" in auxes:
            self.aside["passive (être + participle of an avoir verb)"] += 1
            self.note_aside("passive", tokens, i, j)
            return
        else:
            return

        readings = {(t, p) for a, t, p in aux_readings if a == aux}
        simple = {t for t, _ in readings}
        if "participePrésent" in simple:
            self.aside["participe composé (ayant or étant + participle)"] += 1
            self.note_aside("participe composé", tokens, i, j)
            consumed.update(range(i, j + 1))
            return
        if "infinitif" in simple:
            self.aside["infinitif passé (avoir or être + participle)"] += 1
            self.note_aside("infinitif passé", tokens, i, j)
            consumed.update(range(i, j + 1))
            return
        tenses = self.resolve_finite(tokens, i, readings)
        if not tenses:
            return
        compound = {COMPOUND_OF[t] for t in tenses if t in COMPOUND_OF}
        if not compound:
            return
        in_que = clause_has_que(tokens, i)
        self.compound.add(compound, in_que, context_of(tokens, i, j - i + 1))
        consumed.update(range(i, j + 1))

    def note_aside(self, kind, tokens, i, j):
        bucket = self.aside_examples[kind]
        if len(bucket) < 400:
            bucket.append(context_of(tokens, i, j - i + 1))

    def resolve_finite(self, tokens, i, readings):
        """Narrows a word's readings by its subject, its place in the sentence, and que."""
        person = subject_before(tokens, i) or subject_after(tokens, i)
        if tokens[i].word in FUNCTION_WORDS and person is None:
            return set()
        if person is not None:
            narrowed = {(t, p) for t, p in readings if p == person and t != "impératif"}
            if person == "thirdSingular" and tokens[i - 1].word in ("c'", "ce", "ça", "cela", "ceci") if i > 0 else False:
                narrowed = {(t, p) for t, p in narrowed}
            if not narrowed:
                return set()
            readings = narrowed
        else:
            finite = {(t, p) for t, p in readings if t not in PARTICIPLES}
            starts = sentence_start_before(tokens, i)
            followed_by_object = i + 1 < len(tokens) and tokens[i + 1].hyphen_object
            imperatives = {(t, p) for t, p in finite if t == "impératif"}
            mostly_noun = len(finite) > len(imperatives) and self.is_mostly_noun(tokens[i].word)
            if imperatives and (followed_by_object or starts and ends_as_order(tokens, i) and not mostly_noun):
                return {"impératif"}
            # Without a subject pronoun the subject is a noun, so the verb is in the third person:
            # "les objectifs définis" is not je définis.
            readings = {(t, p) for t, p in readings if t != "impératif" and p in ("thirdSingular", "thirdPlural", "")}
            if not readings:
                return set()
        tenses = {t for t, _ in readings}
        if not clause_has_que(tokens, i):
            non_subjunctive = {t for t in tenses if not t.startswith("subjonctif")}
            if non_subjunctive:
                tenses = non_subjunctive
        return tenses

    def count_alone(self, tokens, i, spelling):
        token = tokens[i]
        word = token.word
        previous = tokens[i - 1] if i > 0 and tokens[i - 1].kind == "word" else None
        readings = self.lexicon.readings[spelling]
        person = subject_before(tokens, i) or subject_after(tokens, i)
        if word in STOPLIST and person is None:
            return

        if person is None and previous is not None and previous.word in DETERMINERS:
            participle_present = any(t == "participePrésent" for t, _ in readings)
            if previous.word == "en" and participle_present:
                self.participle_alone.add({"participePrésent"}, False, context_of(tokens, i))
            return
        if word in FUNCTION_WORDS and person is None:
            return

        if person is None:
            participles = {t for t, _ in readings if t in PARTICIPLES}
            finite = {(t, p) for t, p in readings if t not in PARTICIPLES}
            if "participePrésent" in participles and not finite:
                if self.is_adjectival_ant(word):
                    return
                self.participle_alone.add({"participePrésent"}, False, context_of(tokens, i))
                return
            if "participePassé" in participles and not finite:
                self.participle_alone.add({"participePassé"}, False, context_of(tokens, i))
                return
            if participles and finite:
                # A word that is a participle or a finite verb, with no subject before it, is a
                # participle when a noun or a comma stands before it ("le texte adopté"), and
                # shared otherwise.
                tenses = self.resolve_finite(tokens, i, finite)
                if not tenses:
                    return
                self.simple.add(tenses | participles, clause_has_que(tokens, i), context_of(tokens, i))
                return

        tenses = self.resolve_finite(tokens, i, readings)
        tenses = {t for t in tenses if t not in PARTICIPLES} or tenses
        if not tenses:
            return
        self.simple.add(tenses, clause_has_que(tokens, i), context_of(tokens, i))


def count_folder(lexicon, folder):
    result = FolderCount(lexicon)
    files = sorted(p for p in (ORIGINALS / folder).glob("*.txt") if p.name not in SKIPPED_FILES)
    tokenized = []
    for path in files:
        for paragraph in paragraphs(path):
            tokens = tokenize(paragraph)
            result.scan_ant(tokens)
            tokenized.append(tokens)
    for tokens in tokenized:
        result.count(tokens)
    return result, files


def shares(counts, keys):
    total = sum(counts.get(k, 0) for k in keys)
    return {k: (counts.get(k, 0) / total if total else 0) for k in keys}, total


def main():
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--examples", help="print sample contexts for this tense key, or 'passive' or 'participe composé'")
    parser.add_argument("--folder", choices=FOLDERS, help="limit --examples to one folder")
    parser.add_argument("--count", type=int, default=25, help="how many examples")
    args = parser.parse_args()

    if not CONJUGATIONS.exists():
        sys.exit(f"{CONJUGATIONS} is missing; run scripts/write_forms_json.sh first.")
    lexicon = Lexicon()

    results = {}
    for folder in FOLDERS:
        if args.folder and folder != args.folder:
            continue
        results[folder] = count_folder(lexicon, folder)

    if args.examples:
        rng = random.Random(42)
        for folder, (count, _) in results.items():
            pool = []
            for counter in (count.simple, count.compound, count.participle_alone):
                pool += [f"{'~' if shared else ' '} {c}" for c, shared in counter.examples.get(args.examples, [])]
            pool += [f"  {c}" for c in count.aside_examples.get(args.examples, [])]
            print(f"## {folder}: {len(pool)} examples kept, {args.count} shown (~ marks a shared word)")
            for line in rng.sample(pool, min(args.count, len(pool))):
                print(line)
            print()
        return

    simple_keys = SIMPLE_TENSES + PARTICIPLES
    tables = {"Simple tenses and participles": simple_keys, "Simple tenses alone": SIMPLE_TENSES, "Compound tenses": COMPOUND_TENSES}
    resolved = {}
    for folder, (count, files) in results.items():
        simple = count.simple.resolve()
        simple.update(count.participle_alone.resolve())
        compound = count.compound.resolve()
        resolved[folder] = (simple, compound, count)

    print("| Folder | Files | Words | Simple and participles | Compound |")
    print("|---|---:|---:|---:|---:|")
    for folder, (simple, compound, count) in resolved.items():
        files = results[folder][1]
        print(f"| {folder} | {len(files)} | {count.words:,} | {round(sum(simple.values())):,} | {round(sum(compound.values())):,} |")
    print()

    for title, keys in tables.items():
        print(f"### {title}\n")
        header = "| Tense | Balanced | " + " | ".join(resolved) + " | Pooled |"
        print(header)
        print("|---|" + "---:|" * (len(resolved) + 2))
        per_folder = {}
        pooled = Counter()
        for folder, (simple, compound, _) in resolved.items():
            source = compound if keys is COMPOUND_TENSES else simple
            per_folder[folder], _ = shares(source, keys)
            for k in keys:
                pooled[k] += source.get(k, 0)
        pooled_shares, _ = shares(pooled, keys)
        balanced = {k: sum(per_folder[f][k] for f in per_folder) / len(per_folder) for k in keys}
        for k in sorted(keys, key=lambda k: -balanced[k]):
            cells = " | ".join(f"{per_folder[f][k] * 100:.1f}" for f in per_folder)
            print(f"| {k} | {balanced[k] * 100:.1f} | {cells} | {pooled_shares[k] * 100:.1f} |")
        print()

    print("### Counted apart\n")
    print("| Construction | " + " | ".join(resolved) + " |")
    print("|---|" + "---:|" * len(resolved))
    kinds = sorted({k for _, _, c in resolved.values() for k in c.aside})
    for kind in kinds:
        print(f"| {kind} | " + " | ".join(f"{c.aside[kind]:,}" for _, _, c in resolved.values()) + " |")
    print()

    print("### Participles counting those inside compounds\n")
    print("| Folder | participePassé alone | inside a compound | participePrésent |")
    print("|---|---:|---:|---:|")
    for folder, (simple, compound, _) in resolved.items():
        print(f"| {folder} | {simple['participePassé']:,.0f} | {sum(compound.values()):,.0f} | {simple['participePrésent']:,.0f} |")


if __name__ == "__main__":
    main()
