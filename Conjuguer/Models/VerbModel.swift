//
//  VerbModel.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

struct VerbModel: Hashable {
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

  var description: String {
    switch id {
    case "1-1":
      return "Regular -er"
    case "2-1":
      return "Regular -er"
    case "5-1A":
      return "Regular -re"
    default:
      return "\(irregularity)% Irregular"
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
    if let passéSimpleGroup = passéSimpleGroup {
      return passéSimpleGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).passéSimpleGroupRecursive
    } else {
      fatalError("passéSimpleGroup" + andParentIdAreNil)
    }
  }

  var indicatifPrésentGroupRecursive: IndicatifPrésentGroup {
    if let indicatifPrésentGroup = indicatifPrésentGroup {
      return indicatifPrésentGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).indicatifPrésentGroupRecursive
    } else {
      fatalError("indicatifPrésentGroup" + andParentIdAreNil)
    }
  }

  var subjonctifPrésentGroupRecursive: SubjonctifPrésentGroup {
    if let subjonctifPrésentGroup = subjonctifPrésentGroup {
      return subjonctifPrésentGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).subjonctifPrésentGroupRecursive
    } else {
      fatalError("subjonctifPrésentGroup" + andParentIdAreNil)
    }
  }

  func futurStemsRecursive(infinitif: String) -> [String] {
    var stems = [infinitif]
    var recursiveStemAlterations: [StemAlteration] = []

    if
      let parentId = parentId,
      let parentStemAlterations = VerbModel.models[parentId]?.stemAlterations
    {
      recursiveStemAlterations = parentStemAlterations.filter { $0.isInherited }
    }

    if let stemAlterations = stemAlterations {
      recursiveStemAlterations += stemAlterations
    }

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

    stems.forEach {
      if $0.last == "e" {
        stems[0] = String(stems[0].dropLast())
      }
    }

    return stems
  }

  static func == (lhs: VerbModel, rhs: VerbModel) -> Bool {
    lhs.id == rhs.id
  }
}
