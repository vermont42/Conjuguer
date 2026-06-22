//
//  ParserTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/15/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct ParserTests {
  @Test func testVerbParserParsesValidVerb() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs.count == 1)
    #expect(verbs["parler"]?.translation == "to speak")
  }

  @Test func testVerbParserSkipsVerbMissingRequiredAttributeAndKeepsValidSibling() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler"/>
      <verb in="finir" mo="finir"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs.count == 1)
    #expect(verbs["parler"] != nil)
    #expect(verbs["finir"] == nil)
  }

  @Test func testVerbParserResetsStateBetweenElements() {
    let xml = """
    <verbs>
      <verb in="aller" tn="to go" mo="aller" re="t"/>
      <verb in="parler" tn="to speak" mo="parler"/>
    </verbs>
    """
    let (verbs, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["aller"]?.isReflexive ?? false)
    #expect(!(verbs["parler"]?.isReflexive ?? true))
  }

  @Test func testModelParserSkipsModelMissingExemplar() {
    let xml = """
    <models>
      <model id="parler" mo="parler"/>
      <model id="broken"/>
    </models>
    """
    let models = VerbModelParser(xmlString: xml).parse()
    #expect(models["parler"] != nil)
    #expect(models["broken"] == nil)
  }

  @Test func testModelParserDropsMalformedStemAlterations() {
    let xml = """
    <models>
      <model id="test" mo="test" p="é,È,r1s|1,2|x,y,zzz"/>
    </models>
    """
    let models = VerbModelParser(xmlString: xml).parse()
    #expect(models["test"]?.stemAlterations?.count == 1)
  }

  @Test func testDefectGroupParserSkipsGroupMissingRequiredAttribute() {
    let xml = """
    <defectGroups>
      <defectGroup id="1" en="english" fr="french" du="fA"/>
      <defectGroup id="2" en="english"/>
    </defectGroups>
    """
    let defectGroups = DefectGroupParser(xmlString: xml).parse()
    #expect(defectGroups["1"] != nil)
    #expect(defectGroups["2"] == nil)
  }

  @Test func testDefectGroupParserSkipsGroupWithBothUsesOnlyAndDoesntUse() {
    let xml = """
    <defectGroups>
      <defectGroup id="1" en="english" fr="french" uo="h2p" du="h1p"/>
    </defectGroups>
    """
    let defectGroups = DefectGroupParser(xmlString: xml).parse()
    #expect(defectGroups["1"] == nil)
  }
}
