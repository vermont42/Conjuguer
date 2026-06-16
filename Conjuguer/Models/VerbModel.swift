//
//  VerbModel.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

struct VerbModel: Identifiable, Hashable {
  static var models: [String: VerbModel] = [:]

  let id: String
  let exemplar: String
  let parentId: String?
  let participeEnding: String?
  let indicatifPrésentGroup: IndicatifPrésentGroup?
  let passéSimpleGroup: PasséSimpleGroup?
  let subjonctifPrésentGroup: SubjonctifPrésentGroup?
  let stemAlterations: [StemAlteration]?
  let position: Int
  var irregularity = 0
  let extraLetters: String?
  let defectGroupId: String?
  var verbs: [String] = []

  nonisolated init(
    id: String,
    exemplar: String,
    parentId: String?,
    participeEnding: String?,
    indicatifPrésentGroup: IndicatifPrésentGroup?,
    passéSimpleGroup: PasséSimpleGroup?,
    subjonctifPrésentGroup: SubjonctifPrésentGroup?,
    stemAlterations: [StemAlteration]?,
    position: Int,
    extraLetters: String?,
    defectGroupId: String?
  ) {
    self.id = id
    self.exemplar = exemplar
    self.parentId = parentId
    self.participeEnding = participeEnding
    self.indicatifPrésentGroup = indicatifPrésentGroup
    self.passéSimpleGroup = passéSimpleGroup
    self.subjonctifPrésentGroup = subjonctifPrésentGroup
    self.stemAlterations = stemAlterations
    self.position = position
    self.extraLetters = extraLetters
    self.defectGroupId = defectGroupId
  }

  var description: String {
    switch id {
    case "1-1":
      return "\(L.ModelView.regular) -er"
    case "2-1":
      return "\(L.ModelView.regular) -ir"
    case "5-1A":
      return "\(L.ModelView.regular) -re"
    default:
      return "\(irregularity)% \(L.ModelView.irregular)"
    }
  }

  func verbsWithDeepLinks() -> AttributedString {
    do {
      return try AttributedString(markdown: verbs.map {
        let encodedVerb = $0.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? ""
        return "[\($0)](\(URL.conjuguerUrlPrefix + URL.verbHost)/\(encodedVerb))"
      }
        .joined(separator: ", ")
      )
    } catch {
      print("Could not build deep-linked verb list for model \(id): \(error.localizedDescription)")
      return AttributedString("")
    }
  }

  static func model(id: String) -> VerbModel {
    if let model = models[id] {
      return model
    } else {
      fatalError("No verb model for \(id) found.")
    }
  }

  static func computeIrregularities() {
    for model in models {
      var irregularityCount = 0
      if model.value.participeEndingRecursive == model.value.participeEndingRecursive.localizedUppercase {
        irregularityCount += 1
      }
      if let stemAlterations = model.value.stemAlterationsRecursive {
        for alteration in stemAlterations {
          irregularityCount += alteration.appliesTo.count
          if alteration.charsToUse.contains(Tense.irregularEndingMarker) {
            irregularityCount += alteration.appliesTo.count
          }
        }
      }
      let maxIrregularityCount = 41
      models[model.value.id]?.irregularity = Int((Double(irregularityCount) / Double(maxIrregularityCount)) * 100.0)
    }
  }

  static func sortVerbs() {
    for model in models {
      let sortedVerbs = model.value.verbs.sorted()
      models[model.value.id]?.verbs = sortedVerbs
    }
  }

  var stemAlterationsRecursive: [StemAlteration]? {
    var allStemAlterations: [StemAlteration] = []
    if
      let parentId = parentId,
      let parentStemAlterations = VerbModel.model(id: parentId).stemAlterationsRecursive
    {
      allStemAlterations += parentStemAlterations.filter { $0.isInherited }
    }
    if let localStemAlterations = stemAlterations {
      allStemAlterations += localStemAlterations
    }
    if allStemAlterations.isEmpty {
      return nil
    } else {
      return allStemAlterations
    }
  }

  private let andParentIdAreNil = " _and_ parentId are nil."

  // Resolves a group property that is inherited verbatim from the nearest ancestor that
  // defines it (no merging), trapping at the root if none does. Only the three uniform
  // local-else-parent-else-fatalError walks fold into this; participeEndingRecursive falls
  // back to "" and stemAlterationsRecursive merges the chain, so they stay bespoke.
  private func inheritedGroup<T>(_ keyPath: KeyPath<VerbModel, T?>, name: String) -> T {
    if let value = self[keyPath: keyPath] {
      return value
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).inheritedGroup(keyPath, name: name)
    } else {
      fatalError(name + andParentIdAreNil)
    }
  }

  var participeEndingRecursive: String {
    if let participeEnding = participeEnding {
      return participeEnding
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).participeEndingRecursive
    } else {
      return ""
    }
  }

  var passéSimpleGroupRecursive: PasséSimpleGroup {
    inheritedGroup(\.passéSimpleGroup, name: "passéSimpleGroup")
  }

  var indicatifPrésentGroupRecursive: IndicatifPrésentGroup {
    inheritedGroup(\.indicatifPrésentGroup, name: "indicatifPrésentGroup")
  }

  var subjonctifPrésentGroupRecursive: SubjonctifPrésentGroup {
    inheritedGroup(\.subjonctifPrésentGroup, name: "subjonctifPrésentGroup")
  }

  var exemplarWithPossibleExtraLetters: String {
    if let extraLetters = extraLetters {
      return exemplar + " (" + extraLetters + ")"
    } else {
      return exemplar
    }
  }

  func futurStemsRecursive(infinitif: String) -> [String] {
    var stems = [infinitif]
    let recursiveStemAlterations = stemAlterationsRecursive ?? []

    for alteration in recursiveStemAlterations {
      if alteration.appliesTo.contains(.radicalFutur) {
        if alteration.isAdditive {
          stems.append(infinitif)
          stems[1].modifyStem(alteration: alteration)
        } else {
          stems[0].modifyStem(alteration: alteration)
        }
      }
    }

    for i in stems.indices where stems[i].last == "e" {
      stems[i] = String(stems[i].dropLast())
    }

    return stems
  }

  static func == (lhs: VerbModel, rhs: VerbModel) -> Bool {
    lhs.id == rhs.id
  }
}
