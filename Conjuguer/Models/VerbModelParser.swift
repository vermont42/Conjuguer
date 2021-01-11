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
  private var currentSubjonctifStem: String?
  private var currentFuturStem: String?
  private var currentPasséSimpleStem: String?
  private var currentUsesParticipeStemForPasséSimple = true
  private var currentParticipeEnding: String?
  private var currentIndicatifPrésentGroup: IndicatifPrésentGroup?
  private var currentPasséSimpleGroup: PasséSimpleGroup?
  private var currentSubjonctifPrésentGroup: SubjonctifPrésentGroup?
  private var currentStemAlterations: [StemAlteration] = []
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

      if let subjonctifStem = attributeDict["sb"] {
        currentSubjonctifStem = subjonctifStem
      }

      if let futurStem = attributeDict["ff"] {
        currentFuturStem = futurStem
      }

      if let passéSimpleStem = attributeDict["uf"] {
        currentPasséSimpleStem = passéSimpleStem
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

      if let subjonctifPrésentGroup = attributeDict["bb"] {
        currentSubjonctifPrésentGroup = SubjonctifPrésentGroup.groupForXmlString(subjonctifPrésentGroup)
      }

      if let stemAlterations = attributeDict["p"] {
        currentStemAlterations = StemAlteration.alterationsFor(xmlString: stemAlterations)
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
        subjonctifStem: currentSubjonctifStem,
        futurStem: currentFuturStem,
        passéSimpleStem: currentPasséSimpleStem,
        participeEnding: currentParticipeEnding,
        usesParticipeStemForPasséSimple: currentUsesParticipeStemForPasséSimple,
        indicatifPrésentGroup: currentIndicatifPrésentGroup,
        passéSimpleGroup: currentPasséSimpleGroup,
        subjonctifPrésentGroup: currentSubjonctifPrésentGroup,
        stemAlterations: currentStemAlterations,
        completeAlterations: currentCompleteAlterations
      )

      models[currentId] = model

      currentId = ""
      currentExemplar = ""
      currentParentId = nil
      currentImparfaitStem = nil
      currentParticipeStem = nil
      currentSubjonctifStem = nil
      currentFuturStem = nil
      currentPasséSimpleStem = nil
      currentParticipeEnding = nil
      currentUsesParticipeStemForPasséSimple = true
      currentIndicatifPrésentGroup = nil
      currentPasséSimpleGroup = nil
      currentSubjonctifPrésentGroup = nil
      currentStemAlterations = []
      currentCompleteAlterations = []
    }
  }
}
