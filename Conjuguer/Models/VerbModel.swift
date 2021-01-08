//
//  VerbModel.swift
//  Conjuguer
//
//  Created by Joshua Adams on 12/31/20.
//

import Foundation

struct VerbModel {
  static var models: [String: VerbModel] = [:]

  let id: String
  let exemplar: String
  let parentId: String?
  let participeStem: String?
  let participeEnding: String?
  let indicatifPrésentGroup: IndicatifPrésentGroup?
  let passéSimpleGroup: PasséSimpleGroup?
  let partialAlterations: [PartialAlteration]?
  let completeAlterations: [CompleteAlteration]?

  static func model(id: String) -> VerbModel {
    if let model = models[id] {
      return model
    } else {
      fatalError("No verb model for \(id) found.")
    }
  }

  func participeStem(verb: Verb) -> String {
    if let participeStem = participeStem {
      return participeStem.uppercased()
    } else {
      return verb.infinitiveStem
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
}
