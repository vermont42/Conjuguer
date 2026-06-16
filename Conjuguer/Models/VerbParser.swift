//
//  VerbParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/31/20.
//

import Foundation

nonisolated class VerbParser: XMLDataParser {
  private let verbTag = "verb"
  private var verbs: [String: Verb] = [:]
  private var models: [String: VerbModel] = [:]
  private var currentVerb = ""
  private var currentTranslation = ""
  private var currentModel = ""
  private var currentAuxiliary: String?
  private var currentIsReflexive = false
  private var currentHasAspiratedH = false
  private var currentFrequency: Int?
  private var currentExtraLetters: String?
  private var currentDefectGroupId: String?

  init() {
    super.init(resource: "verbs")
  }

  init(xmlString: String) {
    super.init(data: Data(xmlString.utf8))
  }

  func parse(models: [String: VerbModel]) -> (verbs: [String: Verb], models: [String: VerbModel]) {
    self.models = models
    parser?.parse()
    return (verbs, self.models)
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == verbTag {
      currentElementIsValid = true

      guard
        let infinitif = require("in", from: attributeDict, element: verbTag),
        let translation = require("tn", from: attributeDict, element: verbTag),
        let model = require("mo", from: attributeDict, element: verbTag)
      else {
        return
      }
      currentVerb = infinitif
      currentTranslation = translation
      currentModel = model

      if let auxiliary = attributeDict["ay"] {
        currentAuxiliary = auxiliary
      }

      if
        let isReflexive = attributeDict["re"],
        isReflexive == "t"
      {
        currentIsReflexive = true
      }

      if
        let hasAspiratedH = attributeDict["ah"],
        hasAspiratedH == "t"
      {
        currentHasAspiratedH = true
      }

      if
        let frequency = attributeDict["fr"],
        let frequencyInt = Int(frequency)
      {
        currentFrequency = frequencyInt
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
    if elementName == verbTag {
      defer {
        resetCurrent()
      }

      guard currentElementIsValid else {
        return
      }

      let auxiliary: Auxiliary

      if currentIsReflexive {
        auxiliary = .être
      } else if let currentAuxiliary = currentAuxiliary {
        auxiliary = Auxiliary(rawValue: currentAuxiliary) ?? .avoir
      } else {
        auxiliary = .avoir
      }

      let currentVerbWithPossibleExtraLetters: String
      if let currentExtraLetters = currentExtraLetters {
        currentVerbWithPossibleExtraLetters = currentVerb + " " + currentExtraLetters // haïr Canada
      } else {
        currentVerbWithPossibleExtraLetters = currentVerb
      }

      verbs[currentVerbWithPossibleExtraLetters] = Verb(
        infinitif: currentVerb,
        translation: currentTranslation,
        model: currentModel,
        auxiliary: auxiliary,
        isReflexive: currentIsReflexive,
        hasAspiratedH: currentHasAspiratedH,
        frequency: currentFrequency,
        extraLetters: currentExtraLetters,
        defectGroupId: currentDefectGroupId
      )

      if let model = models[currentModel] {
        var verbs = model.verbs
        verbs.append(currentVerbWithPossibleExtraLetters)
        models[currentModel]?.verbs = verbs
      }
    }
  }

  private func resetCurrent() {
    currentVerb = ""
    currentTranslation = ""
    currentModel = ""
    currentAuxiliary = nil
    currentIsReflexive = false
    currentHasAspiratedH = false
    currentFrequency = nil
    currentExtraLetters = nil
    currentDefectGroupId = nil
  }
}
