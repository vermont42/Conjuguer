//
//  DefectGroupParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 7/3/21.
//

import Foundation

nonisolated class DefectGroupParser: XMLDataParser {
  private let defectGroupTag = "defectGroup"
  private var defectGroups: [String: DefectGroup] = [:]
  private var currentId = ""
  private var currentDescriptionEn = ""
  private var currentDescriptionFr = ""
  private var currentUsesOnly: String?
  private var currentDoesntUse: String?

  init() {
    super.init(resource: "defectGroups")
  }

  init(xmlString: String) {
    super.init(data: Data(xmlString.utf8))
  }

  func parse() -> [String: DefectGroup] {
    parser?.parse()
    return defectGroups
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == defectGroupTag {
      currentElementIsValid = true

      guard
        let id = require("id", from: attributeDict, element: defectGroupTag),
        let descriptionEn = require("en", from: attributeDict, element: defectGroupTag),
        let descriptionFr = require("fr", from: attributeDict, element: defectGroupTag)
      else {
        return
      }
      currentId = id
      currentDescriptionEn = descriptionEn
      currentDescriptionFr = descriptionFr

      if let usesOnly = attributeDict["uo"] {
        currentUsesOnly = usesOnly
      }

      if let doesntUse = attributeDict["du"] {
        currentDoesntUse = doesntUse
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == defectGroupTag {
      defer {
        resetCurrent()
      }

      guard currentElementIsValid else {
        return
      }

      if
        let currentUsesOnly = currentUsesOnly,
        let currentDoesntUse = currentDoesntUse
      {
        print("Skipping <\(defectGroupTag)> \(currentId): both usesOnly (\(currentUsesOnly)) and doesntUse (\(currentDoesntUse)) were specified.")
        return
      }

      defectGroups[currentId] = DefectGroup(
        id: currentId,
        descriptionEn: currentDescriptionEn,
        descriptionFr: currentDescriptionFr,
        usesOnly: currentUsesOnly,
        doesntUse: currentDoesntUse
      )
    }
  }

  private func resetCurrent() {
    currentId = ""
    currentDescriptionEn = ""
    currentDescriptionFr = ""
    currentUsesOnly = nil
    currentDoesntUse = nil
  }
}
