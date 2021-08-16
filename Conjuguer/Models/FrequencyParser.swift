//
//  FrequencyParser.swift
//  Conjuguer
//
//  Created by Joshua Adams on 8/15/21.
//

import Foundation

class FrequencyParser: NSObject, XMLParserDelegate {
  static let maxFrequency = 981
  private var parser: XMLParser?
  private let strTag = "str"
  private var currentStr = ""
  private var currentFrequency = 1
  private var isParsingStr = false

  override init() {
    super.init()
    let bundle = Bundle(for: FrequencyParser.self)
    if let url = bundle.url(forResource: "frequencies", withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
      if parser == nil {
        return
      }
      parser?.delegate = self
    }
  }

  func parse() {
    parser?.parse()
  }

  func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String: String]) {
    if elementName == strTag {
      isParsingStr = true
    } else {
      isParsingStr = false
    }
  }

  func parser(_ parser: XMLParser, foundCharacters string: String) {
    if isParsingStr {
      let cleansedString = string.trimmingCharacters(in: .whitespacesAndNewlines)
      if !cleansedString.isEmpty {
        currentStr += cleansedString
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == strTag {
      isParsingStr = false
      let suffix = currentStr.suffix(2)
      if ["er", "ir", "re"].contains(suffix) {
        if currentStr == "sortir" {
          print("sortir frequency: \(currentFrequency)")
          currentFrequency += 1
        } else if var verb = Verb.verbs[currentStr] {
          verb.frequency = currentFrequency
          Verb.verbs[currentStr] = verb
          currentFrequency += 1
        } else {
          print("\(currentStr) was not in verbs.xml.")
        }
      }
      currentStr = ""
    }
  }
}
