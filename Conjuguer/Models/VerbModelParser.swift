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
  private var currentImparfaitStem: String?
  private var currentParticipePasséStem: String?
  private var currentSubjonctifStem: String?
  private var currentFuturStem: String?
  private var currentPasséSimpleStem: String?
  private var currentUsesParticipePasséStemForPasséSimple = true
  private var currentUsesSubjonctifStemForImpératif = false
  private var currentParticipeEnding: String?
  private var currentParticipePrésentStem: String?
  private var currentIndicatifPrésentGroup: IndicatifPrésentGroup?
  private var currentPasséSimpleGroup: PasséSimpleGroup?
  private var currentSubjonctifPrésentGroup: SubjonctifPrésentGroup?
  private var currentStemAlterations: [StemAlteration] = []

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

      if let participePasséStem = attributeDict["ps"] {
        currentParticipePasséStem = participePasséStem
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

      if let usesParticipePasséStemForPasséSimple = attributeDict["up"] {
        currentUsesParticipePasséStemForPasséSimple = usesParticipePasséStemForPasséSimple == "f" ? false : true
      }

      if let usesSubjonctifStemForImpératif = attributeDict["ys"] {
        currentUsesSubjonctifStemForImpératif = usesSubjonctifStemForImpératif == "t" ? true : false
      }

      if let participeEnding = attributeDict["ep"] {
        currentParticipeEnding = participeEnding
      }

      if let participePrésentStem = attributeDict["rr"] {
        currentParticipePrésentStem = participePrésentStem
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
        imparfaitStem: currentImparfaitStem,
        participePasséStem: currentParticipePasséStem,
        subjonctifStem: currentSubjonctifStem,
        futurStem: currentFuturStem,
        participePrésentStem: currentParticipePrésentStem,
        passéSimpleStem: currentPasséSimpleStem,
        participeEnding: currentParticipeEnding,
        usesParticipePasséStemForPasséSimple: currentUsesParticipePasséStemForPasséSimple,
        usesSubjonctifStemForImpératif: currentUsesSubjonctifStemForImpératif,
        indicatifPrésentGroup: currentIndicatifPrésentGroup,
        passéSimpleGroup: currentPasséSimpleGroup,
        subjonctifPrésentGroup: currentSubjonctifPrésentGroup,
        stemAlterations: currentStemAlterations.isEmpty ? nil : currentStemAlterations
      )

      models[currentId] = model

      currentId = ""
      currentExemplar = ""
      currentParentId = nil
      currentImparfaitStem = nil
      currentParticipePasséStem = nil
      currentSubjonctifStem = nil
      currentFuturStem = nil
      currentParticipePrésentStem = nil
      currentPasséSimpleStem = nil
      currentParticipeEnding = nil
      currentUsesParticipePasséStemForPasséSimple = true
      currentUsesSubjonctifStemForImpératif = false
      currentIndicatifPrésentGroup = nil
      currentPasséSimpleGroup = nil
      currentSubjonctifPrésentGroup = nil
      currentStemAlterations = []
    }
  }
}
