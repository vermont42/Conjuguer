#!/usr/bin/env bash
#
# Writes the three dumps in corpus/working that the Python pipelines read:
#
#   forms.json         { "<form>": ["<verb id>", …] }, the 1,000 most frequent verbs
#                      (build_corpus_index.py, build_tail_index.py)
#   forms_all.json     the same over every verb (build_classical_index.py and the smoke tests)
#   conjugations.json  { "<verb id>": { "<tense key>": "<conjugation>" } }
#                      (audit_conjugations.py and the verb-pass scripts)
#
# It builds ConjugationMapTool, the macOS target that also writes the app's bundled
# ConjugationMap.lzfse, and runs it. One tool, one Conjugator, so the pipelines and the app
# cannot disagree about what a conjugation is. ConjugationMapTool/FormsJSON.swift gives each
# dump's rules.
#
# Run from anywhere:   scripts/write_forms_json.sh [output directory]
# The default directory is corpus/working, whose dumps are gitignored.
#
# Until 2026-11-22 these files came from ConjuguerTests/Models/CorpusFormsDumpTests, a test
# harness disabled by a trait that had to be removed by hand for each run. Its last outputs
# and this script's first were byte-identical.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
output="${1:-$repo/corpus/working}"
models="$repo/Conjuguer/Models"

# A bare `xcodebuild -target` build writes ./build into the repository unless SYMROOT and
# OBJROOT point elsewhere. A scratch directory under TMPDIR keeps the tree clean, and reusing it
# across runs keeps rebuilds incremental. Its name says Conjuguer because Konjugieren's tool has
# the same name, and two apps building into one directory would overwrite each other's products.
build_root="${TMPDIR:-/tmp}/ConjuguerConjugationMapTool-build"

xcodebuild -project "$repo/Conjuguer.xcodeproj" -target ConjugationMapTool -configuration Release \
  SYMROOT="$build_root/Products" OBJROOT="$build_root/Intermediates" -quiet build

"$build_root/Products/Release/ConjugationMapTool" \
  --verbs "$models/verbs.xml" \
  --verb-models "$models/verbModels.xml" \
  --defect-groups "$models/defectGroups.xml" \
  --forms-json "$output/forms.json" \
  --forms-all-json "$output/forms_all.json" \
  --conjugations-json "$output/conjugations.json"
