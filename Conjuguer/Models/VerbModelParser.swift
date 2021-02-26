//
//  VerbModelParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/4/21.
//

import Foundation

class VerbModelParser: NSObject, XMLParserDelegate {
  static let xmlSeparator = ","
  static let startIndexOfAlterationsInXml = 3

  private var parser: XMLParser?
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

  override init() {
    super.init()
    let bundle = Bundle(for: VerbModelParser.self)
    if let url = bundle.url(forResource: "verbModels", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
      parser?.delegate = self
    }
  }

  func parse() -> [String: VerbModel] {
    parser?.parse()
    return models
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == modelTag {
      if let currentId = attributeDict["id"] {
        self.currentId = currentId
      } else {
        fatalError("No model ID specified.")
      }

      if let currentParentId = attributeDict["pa"] {
        self.currentParentId = currentParentId
      }

      if let participeEnding = attributeDict["ep"] {
        currentParticipeEnding = participeEnding
      }

      if let exemplar = attributeDict["mo"] {
        currentExemplar = exemplar
      } else {
        fatalError("No exemplar specified.")
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
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == modelTag {
      let model = VerbModel(
        id: currentId,
        exemplar: currentExemplar,
        parentId: currentParentId,
        participeEnding: currentParticipeEnding,
        indicatifPrésentGroup: currentIndicatifPrésentGroup,
        passéSimpleGroup: currentPasséSimpleGroup,
        subjonctifPrésentGroup: currentSubjonctifPrésentGroup,
        stemAlterations: currentStemAlterations.isEmpty ? nil : currentStemAlterations,
        position: currentPosition
      )

      models[currentId] = model

      currentId = ""
      currentExemplar = ""
      currentParentId = nil
      currentParticipeEnding = nil
      currentIndicatifPrésentGroup = nil
      currentPasséSimpleGroup = nil
      currentSubjonctifPrésentGroup = nil
      currentStemAlterations = []
      currentPosition += 1
    }
  }
}
