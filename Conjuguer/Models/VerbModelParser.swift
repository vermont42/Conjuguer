//
//  VerbModelParser.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/4/21.
//

import Foundation

class VerbModelParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let modelTag = "model"
  private var models: [String: VerbModel] = [:]
  private var currentId = ""
  private var currentExemplar = ""
  private var currentParentId: String?
  private var currentImparfaitStem: String?
  private var currentParticipeStem: String?
  private var currentUsesParticipeStemForPasséSimple = true
  private var currentParticipeEnding: String?
  private var currentIndicatifPrésentGroup: IndicatifPrésentGroup?
  private var currentPasséSimpleGroup: PasséSimpleGroup?
  private var currentPartialAlterations: [PartialAlteration] = []
  private var currentCompleteAlterations: [CompleteAlteration] = []

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

      if let imparfaitStem = attributeDict["ii"] {
        currentImparfaitStem = imparfaitStem
      }

      if let participeStem = attributeDict["ps"] {
        currentParticipeStem = participeStem
      }

      if let usesParticipeStemForPasséSimple = attributeDict["up"] {
        currentUsesParticipeStemForPasséSimple = usesParticipeStemForPasséSimple == "f" ? false : true
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

      if let partialAlterations = attributeDict["p"] {
        currentPartialAlterations = PartialAlteration.alterationsFor(xmlString: partialAlterations)
      }

      if let completeAlteration = attributeDict["cr"] {
        currentCompleteAlterations = CompleteAlteration.alterationsFromXmlString(completeAlteration)
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == modelTag {
      let model = VerbModel(
        id: currentId,
        exemplar: currentExemplar,
        parentId: currentParentId,
        imparfaitStem: currentImparfaitStem,
        participeStem: currentParticipeStem,
        participeEnding: currentParticipeEnding,
        usesParticipeStemForPasséSimple: currentUsesParticipeStemForPasséSimple,
        indicatifPrésentGroup: currentIndicatifPrésentGroup,
        passéSimpleGroup: currentPasséSimpleGroup,
        partialAlterations: currentPartialAlterations,
        completeAlterations: currentCompleteAlterations
      )

      models[currentId] = model

      currentId = ""
      currentExemplar = ""
      currentParentId = nil
      currentImparfaitStem = nil
      currentParticipeStem = nil
      currentParticipeEnding = nil
      currentUsesParticipeStemForPasséSimple = true
      currentIndicatifPrésentGroup = nil
      currentPasséSimpleGroup = nil
      currentPartialAlterations = []
      currentCompleteAlterations = []
    }
  }
}
