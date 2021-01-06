//
//  VerbModelParser.swift
//  Conjuguer
//
//  Created by Joshua Adams on 1/4/21.
//

import Foundation

//<?xml version="1.0" encoding="utf-8"?>
//<!DOCTYPE models [
//    <!ELEMENT models (model+)>
//    <!ELEMENT model (verb*)>
//    <!ATTLIST model id CDATA #REQUIRED>
//    <!ATTLIST model mo CDATA #REQUIRED>
//    <!ATTLIST model pa CDATA #IMPLIED>
//    <!ATTLIST model ap1 CDATA #IMPLIED>
//    <!ATTLIST model ap2 CDATA #IMPLIED>
//    <!ATTLIST model ap3 CDATA #IMPLIED>
//    <!ATTLIST model ap4 CDATA #IMPLIED>
//    <!ATTLIST model ap5 CDATA #IMPLIED>
//    <!ATTLIST model ap6 CDATA #IMPLIED>
//]>
//
//<models>
//  <model mo="parler" id="1-1" ep1="e" ep2="es" ep3="e" ep4="ons" ep5="ez" ep6="ent"/>
//  <model mo="lancer" id="1-2a" pa="1-1" ap4="0,0,ç" />
//  <model mo="finir" id="2-1" ep1="is" ep2="is" ep3="it" ep4="issons" ep5="issez" ep6="issent"/>
//</models>

class VerbModelParser: NSObject, XMLParserDelegate {
  private var parser: XMLParser?
  private let modelTag = "model"
  private var models: [String: VerbModel] = [:]
  private var currentId = ""
  private var currentExemplar = ""
  private var currentParentId: String?
  private var currentPrésentEndings: [String?] = [nil, nil, nil, nil, nil, nil]
  private var currentParticipeEnding: String?

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

      for i in 0 ..< PersonNumber.count {
        if let présentEnding = attributeDict["ep\(i + 1)"] {
          currentPrésentEndings[i] = présentEnding
        }
      }

      if let participeEnding = attributeDict["ep"] {
        currentParticipeEnding = participeEnding
      }

      // TODO: Store ap1-6.

      if let exemplar = attributeDict["ex"] {
        currentExemplar = exemplar
      } else {
        fatalError("No exemplar specified.")
      }
    }
  }

  func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    if elementName == modelTag {
      let model = VerbModel(
        id: currentId,
        exemplar: currentExemplar,
        parentId: currentParentId,
        présentEndings: currentPrésentEndings,
        participeEnding: currentParticipeEnding,
        partialAlterations: nil,
        completeAlterations: nil
      )

      models[currentId] = model

      currentId = ""
      currentExemplar = ""
      currentParentId = nil
      currentPrésentEndings = [nil, nil, nil, nil, nil, nil]
      currentParticipeEnding = nil
    }
  }
}
