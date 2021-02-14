//
//  VerbParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

class VerbParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let verbTag = "verb"
  private var verbs: [String: Verb] = [:]
  private var currentVerb = ""
  private var currentTranslation = ""
  private var currentModel = ""
  private var currentAuxiliary: String?
  private var currentIsReflexive: Bool = false

  override init() {
    super.init()
    let bundle = Bundle(for: VerbParser.self)
    if let url = bundle.url(forResource: "verbs", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
      parser?.delegate = self
    }
  }

  func parse() -> [String: Verb] {
    parser?.parse()
    return verbs
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == verbTag {
      if let currentVerb = attributeDict["in"] {
        self.currentVerb = currentVerb
      } else {
        fatalError("No infinitif specified.")
      }

      if let translation = attributeDict["tn"] {
        currentTranslation = translation
      } else {
        fatalError("No translation specified.")
      }

      if let model = attributeDict["mo"] {
        currentModel = model
      } else {
        fatalError("No model specified.")
      }

      if let auxiliary = attributeDict["ay"] {
        currentAuxiliary = auxiliary
      }

      if
        let isReflexive = attributeDict["re"],
        isReflexive == "t"
      {
        currentIsReflexive = true
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == verbTag {
      let auxiliary: Auxiliary
      if let currentAuxiliary = currentAuxiliary {
        auxiliary = Auxiliary(rawValue: currentAuxiliary) ?? .avoir
      } else {
        auxiliary = .avoir
      }

      verbs[currentVerb] = Verb(
        infinitif: currentVerb,
        translation: currentTranslation,
        model: currentModel,
        auxiliary: auxiliary,
        isReflexive: currentIsReflexive
      )

      currentVerb = ""
      currentTranslation = ""
      currentModel = ""
      currentAuxiliary = nil
      currentIsReflexive = false
    }
  }
}
