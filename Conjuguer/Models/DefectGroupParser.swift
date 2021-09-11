//
//  DefectGroupParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 7/3/21.
//

import Foundation

class DefectGroupParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let defectGroupTag = "defectGroup"
  private var defectGroups: [String: DefectGroup] = [:]
  private var currentId = ""
  private var currentDescriptionEn = ""
  private var currentDescriptionFr = ""
  private var currentUsesOnly: String?
  private var currentDoesntUse: String?

  override init() {
    super.init()
    let bundle = Bundle(for: DefectGroupParser.self)
    if let url = bundle.url(forResource: "defectGroups", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
      parser?.delegate = self
    }
  }

  func parse() -> [String: DefectGroup] {
    parser?.parse()
    return defectGroups
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == defectGroupTag {
      if let id = attributeDict["id"] {
        currentId = id
      } else {
        fatalError("No ID specified.")
      }

      if let descriptionEn = attributeDict["en"] {
        currentDescriptionEn = descriptionEn
      } else {
        fatalError("No English description specified.")
      }

      if let descriptionFr = attributeDict["fr"] {
        currentDescriptionFr = descriptionFr
      } else {
        fatalError("No French description specified.")
      }

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
      if
        let currentUsesOnly = currentUsesOnly,
        let currentDoesntUse = currentDoesntUse
      {
        fatalError("For ID \(currentId), both usesOnly \(currentUsesOnly) and doesntUse \(currentDoesntUse) were non-nil.")
      }

      defectGroups[currentId] = DefectGroup(
        id: currentId,
        descriptionEn: currentDescriptionEn,
        descriptionFr: currentDescriptionFr,
        usesOnly: currentUsesOnly,
        doesntUse: currentDoesntUse
      )

      currentId = ""
      currentDescriptionEn = ""
      currentDescriptionFr = ""
      currentUsesOnly = nil
      currentDoesntUse = nil
    }
  }
}
