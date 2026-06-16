//
//  VerbModelParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/4/21.
//

import Foundation

nonisolated class VerbModelParser: XMLDataParser {
  static let xmlSeparator = ","
  static let alterationSeparator = "|"

  private let modelTag = "model"
  private var models: [String: VerbModel] = [:]
  private var currentId = ""
  private var currentExemplar = ""
  private var currentParentId: String?
  private var currentParticipeEnding: String?
  private var currentIndicatifPrésentGroup: IndicatifPrésentGroup?
  private var currentPasséSimpleGroup: PasséSimpleGroup?
  private var currentSubjonctifPrésentGroup: SubjonctifPrésentGroup?
  private var currentStemAlterations: [StemAlteration] = []
  private var currentPosition = 0
  private var currentExtraLetters: String?
  private var currentDefectGroupId: String?

  init() {
    super.init(resource: "verbModels")
  }

  init(xmlString: String) {
    super.init(data: Data(xmlString.utf8))
  }

  func parse() -> [String: VerbModel] {
    parser?.parse()
    return models
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == modelTag {
      currentElementIsValid = true

      guard
        let id = require("id", from: attributeDict, element: modelTag),
        let exemplar = require("mo", from: attributeDict, element: modelTag)
      else {
        return
      }
      currentId = id
      currentExemplar = exemplar

      if let currentParentId = attributeDict["pa"] {
        self.currentParentId = currentParentId
      }

      if let participeEnding = attributeDict["ep"] {
        currentParticipeEnding = participeEnding
      }

      if let indicatifPrésentGroup = attributeDict["si"] {
        currentIndicatifPrésentGroup = IndicatifPrésentGroup.groupForXmlString(indicatifPrésentGroup)
      }

      if let passéSimpleGroup = attributeDict["se"] {
        currentPasséSimpleGroup = PasséSimpleGroup.groupForXmlString(passéSimpleGroup)
      }

      if let subjonctifPrésentGroup = attributeDict["bb"] {
        currentSubjonctifPrésentGroup = SubjonctifPrésentGroup.groupForXmlString(subjonctifPrésentGroup)
      }

      if let stemAlterations = attributeDict["p"] {
        currentStemAlterations = StemAlteration.alterationsFor(xmlString: stemAlterations)
      }

      if let extraLetters = attributeDict["ex"] {
        currentExtraLetters = extraLetters
      }

      if let defectGroupId = attributeDict["dg"] {
        currentDefectGroupId = defectGroupId
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == modelTag {
      defer {
        resetCurrent()
      }

      guard currentElementIsValid else {
        return
      }

      let model = VerbModel(
        id: currentId,
        exemplar: currentExemplar,
        parentId: currentParentId,
        participeEnding: currentParticipeEnding,
        indicatifPrésentGroup: currentIndicatifPrésentGroup,
        passéSimpleGroup: currentPasséSimpleGroup,
        subjonctifPrésentGroup: currentSubjonctifPrésentGroup,
        stemAlterations: currentStemAlterations.isEmpty ? nil : currentStemAlterations,
        position: currentPosition,
        extraLetters: currentExtraLetters,
        defectGroupId: currentDefectGroupId
      )

      models[currentId] = model
    }
  }

  private func resetCurrent() {
    currentId = ""
    currentExemplar = ""
    currentParentId = nil
    currentParticipeEnding = nil
    currentIndicatifPrésentGroup = nil
    currentPasséSimpleGroup = nil
    currentSubjonctifPrésentGroup = nil
    currentStemAlterations = []
    currentPosition += 1
    currentExtraLetters = nil
    currentDefectGroupId = nil
  }
}
