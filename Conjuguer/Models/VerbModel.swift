//
//  VerbModel.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

struct VerbModel {
  static var models: [String: VerbModel] = [:]

  let id: String
  let exemplar: String
  let parentId: String?
  let imparfaitStem: String?
  let participePasséStem: String?
  let subjonctifStem: String?
  let futurStem: String?
  let participePrésentStem: String?
  let passéSimpleStem: String?
  let participeEnding: String?

  let usesParticipePasséStemForPasséSimple: Bool
  let usesSubjonctifStemForImpératif: Bool
  let indicatifPrésentGroup: IndicatifPrésentGroup?
  let passéSimpleGroup: PasséSimpleGroup?
  let subjonctifPrésentGroup: SubjonctifPrésentGroup?
  let stemAlterations: [StemAlteration]?

  static func model(id: String) -> VerbModel {
    if let model = models[id] {
      return model
    } else {
      fatalError("No verb model for \(id) found.")
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

  func participePasséStem(verb: Verb) -> String {
    if let participePasséStem = participePasséStem {
      return participePasséStem
    } else {
      return verb.infinitifStem
    }
  }

  var participeEndingRecursive: String {
    if let participeEnding = participeEnding {
      return participeEnding
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).participeEndingRecursive
    } else {
      fatalError("participeEnding _and_ parentId are nil.")
    }
  }

  var passéSimpleGroupRecursive: PasséSimpleGroup {
    if let passéSimpleGroup = passéSimpleGroup {
      return passéSimpleGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).passéSimpleGroupRecursive
    } else {
      fatalError("passéSimpleGroup _and_ parentId are nil.")
    }
  }

  var indicatifPrésentGroupRecursive: IndicatifPrésentGroup {
    if let indicatifPrésentGroup = indicatifPrésentGroup {
      return indicatifPrésentGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).indicatifPrésentGroupRecursive
    } else {
      fatalError("indicatifPrésentGroup _and_ parentId are nil.")
    }
  }

  var subjonctifPrésentGroupRecursive: SubjonctifPrésentGroup {
    if let subjonctifPrésentGroup = subjonctifPrésentGroup {
      return subjonctifPrésentGroup
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).subjonctifPrésentGroupRecursive
    } else {
      fatalError("subjonctifPrésentGroup _and_ parentId are nil.")
    }
  }

  func futurStemsRecursive(infinitif: String) -> [String] {
    if let futurStem = futurStem {
      return [futurStem]
    }

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
}
