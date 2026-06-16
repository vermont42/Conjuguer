//
//  ParserTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import XCTest

@MainActor
class ParserTests: XCTestCase {
  func testVerbParserParsesValidVerb() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    XCTAssertEqual(verbs.count, 1)
    XCTAssertEqual(verbs["parler"]?.translation, "to speak")
  }

  func testVerbParserSkipsVerbMissingRequiredAttributeAndKeepsValidSibling() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler"/>
      <verb in="finir" mo="finir"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    XCTAssertEqual(verbs.count, 1)
    XCTAssertNotNil(verbs["parler"])
    XCTAssertNil(verbs["finir"])
  }

  func testVerbParserResetsStateBetweenElements() {
    let xml = """
    <verbs>
      <verb in="aller" tn="to go" mo="aller" re="t"/>
      <verb in="parler" tn="to speak" mo="parler"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    XCTAssertTrue(verbs["aller"]?.isReflexive ?? false)
    XCTAssertFalse(verbs["parler"]?.isReflexive ?? true)
  }

  func testModelParserSkipsModelMissingExemplar() {
    let xml = """
    <models>
      <model id="parler" mo="parler"/>
      <model id="broken"/>
    </models>
    """
    let models = VerbModelParser(xmlString: xml).parse()
    XCTAssertNotNil(models["parler"])
    XCTAssertNil(models["broken"])
  }

  func testModelParserDropsMalformedStemAlterations() {
    let xml = """
    <models>
      <model id="test" mo="test" p="é,È,r1s|1,2|x,y,zzz"/>
    </models>
    """
    let models = VerbModelParser(xmlString: xml).parse()
    XCTAssertEqual(models["test"]?.stemAlterations?.count, 1)
  }

  func testDefectGroupParserSkipsGroupMissingRequiredAttribute() {
    let xml = """
    <defectGroups>
      <defectGroup id="1" en="english" fr="french" du="fA"/>
      <defectGroup id="2" en="english"/>
    </defectGroups>
    """
    let defectGroups = DefectGroupParser(xmlString: xml).parse()
    XCTAssertNotNil(defectGroups["1"])
    XCTAssertNil(defectGroups["2"])
  }

  func testDefectGroupParserSkipsGroupWithBothUsesOnlyAndDoesntUse() {
    let xml = """
    <defectGroups>
      <defectGroup id="1" en="english" fr="french" uo="h2p" du="h1p"/>
    </defectGroups>
    """
    let defectGroups = DefectGroupParser(xmlString: xml).parse()
    XCTAssertNil(defectGroups["1"])
  }
}
