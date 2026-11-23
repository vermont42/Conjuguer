//
//  main.swift
//  ConjugationMapTool
//
//  Created by Josh Adams on 11/22/26.
//

// ConjugationMapTool: the build-time writer of the conjugation map, and the writer of the
// corpus pipelines' form dumps.
//
// Consumes: verbs.xml, verbModels.xml, and defectGroups.xml, given as paths.
// Produces: the app's ConjugationMap.lzfse (see Conjuguer/Models/ConjugationMap.swift for the
//           format) and, when asked, the three dumps in corpus/working that the Python
//           pipelines read (FormsJSON.swift).
//
// Run:      ConjugationMapTool --verbs <verbs.xml> --verb-models <verbModels.xml> \
//             --defect-groups <defectGroups.xml> [--map <out.lzfse>] [--forms-json <out.json>] \
//             [--forms-all-json <out.json>] [--conjugations-json <out.json>]
//
// The app target's "Generate Conjugation Map" build phase runs this with --map, writing
// straight into the app bundle. Xcode runs that phase only when one of its declared inputs is
// newer than its output: the three XML files and this tool's executable. The executable stands
// in for every Conjugator source, because Xcode relinks it whenever one of the files it
// compiles changes, and leaves it untouched otherwise.
//
// For the dumps, run scripts/write_forms_json.sh, which builds this target and calls it with
// the right paths. Until 2026-11-22 they came from a disabled test harness,
// CorpusFormsDumpTests, which this tool replaced; its three outputs were confirmed identical.
//
// The tool compiles the app's own conjugation sources (the target membership exceptions in
// project.pbxproj list them), so the map, the app's display, and the dumps all come from one
// Conjugator. If a build of this target fails with "cannot find 'Current'" or "cannot find 'L'",
// a file the tool compiles has started reaching the rest of the app. Move that member to an
// extension in Conjuguer/Models/ConjugationLabels.swift, which the tool does not compile, as was
// done for the pronouns and display names, rather than giving the tool a stand-in World.

import Foundation

private func parseArguments() -> [String: String] {
  var values: [String: String] = [:]
  var remaining = CommandLine.arguments.dropFirst()
  while let flag = remaining.popFirst() {
    guard flag.hasPrefix("--"), let value = remaining.popFirst() else {
      fail("Expected --flag value pairs, got \(flag).")
    }
    values[flag] = value
  }
  return values
}

private func fail(_ message: String) -> Never {
  FileHandle.standardError.write(Data("error: ConjugationMapTool: \(message)\n".utf8))
  exit(1)
}

private func contents(of path: String) -> String {
  guard let text = try? String(contentsOfFile: path, encoding: .utf8) else {
    fail("Could not read \(path).")
  }
  return text
}

let arguments = parseArguments()
guard
  let verbsPath = arguments["--verbs"],
  let verbModelsPath = arguments["--verb-models"],
  let defectGroupsPath = arguments["--defect-groups"]
else {
  fail("--verbs, --verb-models, and --defect-groups are required.")
}
let outputs = (
  map: arguments["--map"],
  formsJSON: arguments["--forms-json"],
  formsAllJSON: arguments["--forms-all-json"],
  conjugationsJSON: arguments["--conjugations-json"]
)
if outputs.map == nil && outputs.formsJSON == nil && outputs.formsAllJSON == nil && outputs.conjugationsJSON == nil {
  fail("Nothing to write. Pass --map, --forms-json, --forms-all-json, --conjugations-json, or a combination.")
}

// As VerbData.publish loads them, less the model passes (irregularity, verb order) that only
// the Models tab reads.
let models = VerbModelParser(xmlString: contents(of: verbModelsPath)).parse()
let parsedVerbs = VerbParser(xmlString: contents(of: verbsPath)).parse(models: models)
VerbModel.models = parsedVerbs.models
Verb.verbs = parsedVerbs.verbs
Verb.rankCount = parsedVerbs.rankCount
DefectGroup.defectGroups = DefectGroupParser(xmlString: contents(of: defectGroupsPath)).parse()
if Verb.verbs.isEmpty || VerbModel.models.isEmpty || DefectGroup.defectGroups.isEmpty {
  fail("Parsed \(Verb.verbs.count) verbs, \(VerbModel.models.count) models, and \(DefectGroup.defectGroups.count) defect groups. Check the paths.")
}

do {
  if let mapPath = outputs.map {
    let map = ConjugationMap.build()
    // Not .atomic: an atomic write creates a temporary file beside the output, and Xcode's
    // script sandbox (ENABLE_USER_SCRIPT_SANDBOXING) permits writing only the declared output.
    let compressed = try map.compressed()
    try compressed.write(to: URL(fileURLWithPath: mapPath))
    print("ConjugationMapTool: \(map.verbsByConjugation.count) conjugations from \(Verb.verbs.count) verbs, \(compressed.count) bytes")
  }
  if let path = outputs.formsJSON {
    try FormsJSON.usageRankedForms().write(to: URL(fileURLWithPath: path))
    print("ConjugationMapTool: wrote \(path)")
  }
  if let path = outputs.formsAllJSON {
    try FormsJSON.allForms().write(to: URL(fileURLWithPath: path))
    print("ConjugationMapTool: wrote \(path)")
  }
  if let path = outputs.conjugationsJSON {
    try FormsJSON.allConjugations().write(to: URL(fileURLWithPath: path))
    print("ConjugationMapTool: wrote \(path)")
  }
} catch {
  fail("Could not write: \(error)")
}
