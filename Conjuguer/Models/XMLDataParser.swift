//
//  XMLDataParser.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import Foundation
import os

nonisolated class XMLDataParser: NSObject, XMLParserDelegate {
  let parser: XMLParser?

  var currentElementIsValid = true

  init(resource: String) {
    if let url = Bundle(for: XMLDataParser.self).url(forResource: resource, withExtension: "xml") {
      parser = XMLParser(contentsOf: url)
    } else {
      parser = nil
    }
    super.init()
    parser?.delegate = self
  }

  init(data: Data) {
    parser = XMLParser(data: data)
    super.init()
    parser?.delegate = self
  }

  func require(_ key: String, from attributes: [String: String], element: String) -> String? {
    guard let value = attributes[key] else {
      Log.parsing.error("Skipping <\(element, privacy: .public)>: required attribute '\(key, privacy: .public)' is missing.")
      currentElementIsValid = false
      return nil
    }
    return value
  }
}
