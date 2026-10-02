# Wiktionary quotation sources (provenance manifest)

Provenance for the **Wiktionary tier** of the verb examples, added by Stage 4 of the verb pass
([`prompts/verb-pass-plan.md`](../prompts/verb-pass-plan.md)) on 2026-10-01. It covers
850 quotations from French Wiktionary (the Wiktionnaire), 8 quotations from English
Wiktionary, and 92 usage examples written by English Wiktionary's editors. Every one ships in
`Conjuguer/Models/literature_examples.json` (and its copy in `corpus/json/`), and its `source`
field carries the attribution.

## The extracts

The quotations come from kaikki.org's machine-readable Wiktionary extracts, not from the live
sites. `corpus/working/build_wiktionary_reference.py` downloads them and keeps the app's verbs:

| Edition | Extract | Dump date | Verbs covered |
|---|---|---|---|
| English Wiktionary | `kaikki.org/dictionary/French/kaikki.org-dictionary-French.jsonl` | 2026-09-02 | 5,560 |
| French Wiktionary | `kaikki.org/dictionary/downloads/fr/fr-extract.jsonl.gz` | 2026-09-01 | 6,321 |

The raw dumps and the per-verb reference files stay under `corpus/working/wiktionary/`, which is
ignored. Re-running the script rebuilds them, though from a later dump.

## The public-domain rule

Decision 2 of the verb pass: a quotation ships only if its **author died before 1931**. That date
satisfies the French term (seventy years after death, with room for the wartime extensions) and
the United States rule (published before 1931) without per-author exceptions. Death years come
from Wikidata through `corpus/working/build_author_table.py`, with hand corrections in
`corpus/working/wiktionary/authors_overrides.json` merged last. An author Wikidata does not
resolve is treated as not public domain.

The rule compares a death year and nothing else, so two kinds of quotation pass it wrongly:

- **Translations.** A French translation of Wilde or Lima Barreto is the translator's text. Stage 3
  screened every quotation printed more than twenty years after its author's death (the
  `late_edition` status in `validate_verb_pass.py`) and two with no year (Tolstoy, Plato). Josh
  rejected the translations of Gotthelf (1999), Wilde (1992) and Lima Barreto (1984). He accepted
  those of Washington Irving (1893), Tolstoy and Plato after review, although the references name
  no translator for any of the three.
- **Namesakes.** Wikidata's Michel Lévy (d. 1875) is the publisher, not the author of a 2010
  Photoshop manual, and its Paul Denis (d. 1918) is not the psychoanalyst of 2017. Both names are
  now unresolved in `authors_overrides.json`, and both quotations were rejected.

The English-Wiktionary candidates needed a second check. `build_candidates.py` kept each
quotation's text and translation but dropped its `ref`, so Stage 2's checkers saw quotations from
Houellebecq, Despentes, Astérix and *Le Monde* as anonymous usage examples, and nothing applied
the public-domain rule to them. `apply_verb_pass.py` looks each English pick up again in the
reference. A pick with no `ref` is an editor's usage example, CC BY-SA, and ships as such. A pick
with a `ref` ships only if it is listed in the script's `PUBLIC_DOMAIN_EN_QUOTATIONS`, the eight
below. The other 37 accepted English picks were left out, so those verbs have no example yet.

## Attribution

The `source` field takes one of three forms, which `ExampleSource` parses:

| `source` | Case | Shown as (English) |
|---|---|---|
| `wiktionnaire\|<author>\|<title>\|<year>` | `.wiktionnaire` | — Honoré de Balzac, « La Cousine Bette » (1846), via French Wiktionary |
| `wiktionary\|<author>\|<title>\|<year>` | `.wiktionaryQuotation` | — Victor Hugo, « Les Misérables » (1862), via Wiktionary |
| `wiktionary` | `.wiktionaryExample` | — Wiktionary (CC BY-SA 4.0) |

Title and year may be empty. The year is the edition's, as Wiktionary gives it, and it is dropped
when it postdates the author's death, since it is then a reprint's (five Daudet stories are cited from an
edition of 1974). A title that already carries guillemets, such as
« Le Serpent qui danse » dans Les Fleurs du mal, is shown as it is. The French sentence is the
candidate's text, verbatim or as one whole sentence excerpted from a longer quotation; the checker's
copy is never used. The credits text names the tier and its license.

## License

The quoted texts are in the public domain. Wiktionary's selection of them, its usage examples, and
the English translations some English-Wiktionary examples keep are Creative Commons
Attribution-ShareAlike 4.0 International (and GFDL). Single sentences are quotation-scale, but the
share-alike term applies to any substantial adaptation, as for the Wikipedia tier
([`wikipedia-corpus-sources.md`](wikipedia-corpus-sources.md)). The English translations of the
French Wiktionary quotations are Claude's (Sonnet 5), as are 38 of the 100 English-Wiktionary ones.

## English-Wiktionary quotations

| Verb | Author | Title | Year |
|---|---|---|---|
| amonceler | Victor Hugo | Les Misérables | 1862 |
| briguer | Pierre Corneille | Horace | 1640 |
| bâter | Miguel de Cervantes, trad. Louis Viardot | L’Ingénieux Hidalgo Don Quichotte de la Manche | 1836 |
| dégréer | Mercure de France | — | 1782 |
| fourmiller | Maurice Rollinat | Dans les brandes | 1877 |
| méprendre | Gustave Flaubert | Madame Bovary | 1857 |
| prêcher | René Boylesve | Leçon d’amour | 1902 |
| ramoner | Jules Verne | L’Île mystérieuse | 1874 |

## French-Wiktionary authors

187 authors, by number of quotations. The death year is the one the public-domain rule used.

| Author | Died | Quotations |
|---|---|---|
| Honoré de Balzac | 1850 | 140 |
| Jules Verne | 1905 | 62 |
| Émile Zola | 1902 | 56 |
| Théophile Gautier | 1872 | 26 |
| Joris-Karl Huysmans | 1907 | 25 |
| Hector Malot | 1907 | 23 |
| Octave Mirbeau | 1917 | 23 |
| Alexandre Dumas | 1870 | 22 |
| George Sand | 1876 | 22 |
| Louis Pergaud | 1915 | 18 |
| Victor Hugo | 1885 | 16 |
| Anatole France | 1924 | 15 |
| Edmond Nivoit | 1920 | 14 |
| Fortuné du Boisgobey | 1891 | 12 |
| Voltaire | 1778 | 11 |
| Stendhal | 1842 | 10 |
| Émile Moselly | 1918 | 10 |
| Alphonse Daudet | 1897 | 9 |
| Eugène Sue | 1857 | 9 |
| François-René de Chateaubriand | 1848 | 9 |
| Aloysius Bertrand | 1841 | 8 |
| Gustave Flaubert | 1880 | 8 |
| Jules Vallès | 1885 | 8 |
| Michel Zévaco | 1918 | 8 |
| Jean-Roch Coignet | 1865 | 7 |
| Pierre Loti | 1923 | 7 |
| Gustave Flaubert et Maxime Du Camp | 1894 | 6 |
| Gérard de Nerval | 1855 | 6 |
| Pierre Louÿs | 1925 | 6 |
| Charles Deulin | 1877 | 5 |
| Eugène Fromentin | 1876 | 5 |
| Georges Sorel | 1922 | 5 |
| Gustave Aimard | 1883 | 5 |
| Guy de Maupassant | 1893 | 5 |
| Henry Murger | 1861 | 5 |
| Marcel Proust | 1922 | 5 |
| Comtesse de Ségur | 1874 | 4 |
| Denis Diderot | 1784 | 4 |
| Edmond Rostand | 1918 | 4 |
| Ernest Renan | 1892 | 4 |
| Hippolyte Taine | 1893 | 4 |
| Isabelle Eberhardt | 1904 | 4 |
| Jules Barbey d’Aurevilly | 1889 | 4 |
| Jules Leclercq | 1928 | 4 |
| Prosper Mérimée | 1870 | 4 |
| René Boylesve | 1926 | 4 |
| Émile Gaboriau | 1873 | 4 |
| Alfred de Musset | 1857 | 3 |
| Alphonse Allais | 1905 | 3 |
| Camille Lemonnier | 1913 | 3 |
| Eugène Chavette | 1902 | 3 |
| Eugène Viollet-le-Duc | 1879 | 3 |
| Georges-Louis Leclerc de Buffon | 1788 | 3 |
| Léon Bloy | 1917 | 3 |
| Abbé Prévost | 1763 | 2 |
| Albert Meyrac | 1922 | 2 |
| Alfred Barbou | 1907 | 2 |
| Amédée Achard | 1875 | 2 |
| Charles Baudelaire | 1867 | 2 |
| Charles Philibert de Lasteyrie | 1849 | 2 |
| Charles-Louis Philippe | 1909 | 2 |
| Claude Tillier | 1844 | 2 |
| Erckmann-Chatrian | 1899 | 2 |
| Eugène Labiche | 1888 | 2 |
| Gustave Fraipont | 1923 | 2 |
| Gustave de Closmadeuc | 1918 | 2 |
| Jean de La Fontaine | 1695 | 2 |
| Jean-Jacques Ampère | 1864 | 2 |
| Leconte de Lisle | 1894 | 2 |
| Marcel Schwob | 1905 | 2 |
| Maxime Du Camp | 1894 | 2 |
| Maximilien de Robespierre | 1794 | 2 |
| Molière | 1673 | 2 |
| Remy de Gourmont | 1915 | 2 |
| Touchatout | 1910 | 2 |
| Abel Dufresne | 1866 | 1 |
| Adalbert-Henri Foucault de Mondion | 1894 | 1 |
| Adolphe Burggraeve | 1902 | 1 |
| Albert Réville | 1906 | 1 |
| Alexandre Balthazar Laurent Grimod de La Reynière | 1837 | 1 |
| Alexandre de Saillet | 1866 | 1 |
| Alfred Delvau | 1867 | 1 |
| Alfred Franklin | 1917 | 1 |
| Alfred Jarry | 1907 | 1 |
| Alfred de Vigny | 1863 | 1 |
| André Guettier | 1894 | 1 |
| André Theuriet | 1907 | 1 |
| Aristide Bruant | 1925 | 1 |
| Arthur Mangin | 1887 | 1 |
| Auguste Barchou de Penhoën | 1855 | 1 |
| Auguste de Villiers de L’Isle-Adam | 1889 | 1 |
| Augustin Berthe | 1907 | 1 |
| Benjamin Pifteau | 1890 | 1 |
| Camille de Rochemonteix | 1923 | 1 |
| Catulle Mendès | 1909 | 1 |
| Charles Le Beau | 1778 | 1 |
| Charles Nodier | 1844 | 1 |
| Charles Péguy | 1914 | 1 |
| Charles Sorel | 1674 | 1 |
| Charles-Victor Garola | 1923 | 1 |
| Claude Ladrey | 1885 | 1 |
| Comte de Sanois | 1799 | 1 |
| Cornélie Chavannes | 1874 | 1 |
| César-Pierre Richelet | 1698 | 1 |
| Dom Bédos de Celles | 1779 | 1 |
| Désiré van Monckhoven | 1882 | 1 |
| Ernest Psichari | 1914 | 1 |
| Eugène Blairat | 1914 | 1 |
| Ferdinand Crolas | 1903 | 1 |
| Georges Clemenceau | 1929 | 1 |
| Georges Courteline | 1929 | 1 |
| Giacomo Casanova | 1798 | 1 |
| Gioacchino Ventura | 1861 | 1 |
| Guillaume Apollinaire | 1918 | 1 |
| Henri Blerzy | 1904 | 1 |
| Henri Rochefort | 1913 | 1 |
| Henri de Parville | 1909 | 1 |
| Henry Le Bret | 1710 | 1 |
| Hippolyte Castille | 1886 | 1 |
| Isaac de Larrey | 1719 | 1 |
| Jacques-Joseph Baudrillart | 1832 | 1 |
| Jacques-Nicolas Paillot de Montabert | 1849 | 1 |
| Jean Chapelain | 1674 | 1 |
| Jean Cruveilhier | 1874 | 1 |
| Jean Desmarets de Saint-Sorlin | 1676 | 1 |
| Jean Richepin | 1926 | 1 |
| Jean-Antoine Chaptal | 1832 | 1 |
| Jean-Baptiste de La Quintinie | 1688 | 1 |
| Jean-Marie Collot d’Herbois |  | 1 |
| Johann Christian Brandes | 1799 | 1 |
| Joseph Delbœuf | 1896 | 1 |
| Joseph Déchelette | 1914 | 1 |
| Joseph Reinach | 1921 | 1 |
| Joseph Turquan | 1928 | 1 |
| Joséphin Peladan | 1918 | 1 |
| Joséphin Péladan | 1918 | 1 |
| Jules Baux | 1890 | 1 |
| Jules Gouffé | 1877 | 1 |
| Jules Laforgue | 1887 | 1 |
| Jules Lermina | 1915 | 1 |
| Jules Michelet | 1874 | 1 |
| Jules de Cuverville | 1912 | 1 |
| Julien Turgan | 1887 | 1 |
| Laurent Tailhade | 1919 | 1 |
| Louis Barron | 1914 | 1 |
| Louis Figuier | 1894 | 1 |
| Louis Hémon | 1913 | 1 |
| Louis Ulbach | 1889 | 1 |
| Louis de Rouvroy de Saint-Simon | 1755 | 1 |
| Louis-Sébastien Lenormand | 1837 | 1 |
| Lucien Duc | 1915 | 1 |
| Léon Tolstoï | 1910 | 1 |
| Léonie d’Aunet | 1879 | 1 |
| Marivaux | 1763 | 1 |
| Maurice Barrès | 1923 | 1 |
| Maximilien Robespierre | 1794 | 1 |
| Maximilien Veydt | 1873 | 1 |
| Montesquieu | 1755 | 1 |
| Noël du Fail | 1591 | 1 |
| Olivier de Serres | 1619 | 1 |
| Paul Adam | 1920 | 1 |
| Paul Arène | 1896 | 1 |
| Paul Féval | 1887 | 1 |
| Paul Lafargue | 1911 | 1 |
| Paul Scarron | 1660 | 1 |
| Paul d’Ivoi | 1915 | 1 |
| Paul-Jean Toulet | 1920 | 1 |
| Peter Dillon | 1847 | 1 |
| Philippe Étienne Lafosse | 1820 | 1 |
| Pierre Alexis de Ponson du Terrail | 1871 | 1 |
| Pierre Choderlos de Laclos | 1803 | 1 |
| Pigault-Lebrun | 1835 | 1 |
| Platon | -348 | 1 |
| Raphaël Viau | 1922 | 1 |
| René Bougard | 1731 | 1 |
| René Maizeroy | 1918 | 1 |
| Robert de Montesquiou | 1921 | 1 |
| Victor Cousin | 1867 | 1 |
| Victor Vermorel | 1927 | 1 |
| Washington Irving | 1859 | 1 |
| Yves Guyot | 1928 | 1 |
| Édouard Chassaignac | 1879 | 1 |
| Émile Jungfleisch | 1916 | 1 |
| Émile de Girardin | 1881 | 1 |
| Étienne Dumont | 1829 | 1 |
| Étienne Dupont | 1928 | 1 |
| Étienne-François de Lantier | 1826 | 1 |
