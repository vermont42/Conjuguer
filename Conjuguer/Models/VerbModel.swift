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
  let présentEndings: [String?]
  let passéSimpleEndings: [String?]
  let participeEnding: String?

  let partialAlterations: [PartialAlteration]?
  let completeAlterations: [CompleteAlteration]?

  static func model(id: String) -> VerbModel {
    if let model = models[id] {
      return model
    } else {
      fatalError("No verb model for \(id) found.")
    }
  }

  func présentEnding(personNumber: PersonNumber) -> String {
    if let présentEnding = présentEndings[personNumber.index] {
      return présentEnding
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).présentEnding(personNumber: personNumber)
    } else {
      fatalError("présentEnding for \(personNumber.shortDisplayName) _and_ parentId are nil.")
    }
  }

  func passéSimpleEnding(personNumber: PersonNumber) -> String {
    if let passéSimpleEnding = passéSimpleEndings[personNumber.index] {
      return passéSimpleEnding
    } else if let parentId = parentId {
      return VerbModel.model(id: parentId).passéSimpleEnding(personNumber: personNumber)
    } else {
      fatalError("passéSimpleEnding for \(personNumber.shortDisplayName) _and_ parentId are nil.")
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
}
