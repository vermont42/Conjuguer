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
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
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
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
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
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
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

  @Test func testVerbParserParsesCountsAndProvisionalFlag() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler" hi="500" hn="40" hl="3" hs="12345"/>
      <verb in="finir" tn="to finish" mo="finir" hi="400" hp="y"/>
    </verbs>
    """
    let (verbs, _, rankCount) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["parler"]?.hits == 500)
    #expect(verbs["parler"]?.newspaperHits == 40)
    #expect(verbs["parler"]?.literatureHits == 3)
    #expect(verbs["parler"]?.subtitleFrequency == 12345)
    #expect(verbs["parler"]?.hitsAreProvisional == false)
    #expect(verbs["finir"]?.hitsAreProvisional == true)
    #expect(verbs["finir"]?.newspaperHits == nil)
    // A provisional count ranks like any other; the flag records provenance, not order.
    #expect(verbs["parler"]?.frequency == 1)
    #expect(verbs["finir"]?.frequency == 2)
    #expect(rankCount == 2)
  }

  @Test func testVerbParserRanksMoreHitsFirst() {
    let xml = """
    <verbs>
      <verb in="finir" tn="to finish" mo="finir" hi="7"/>
      <verb in="parler" tn="to speak" mo="parler" hi="900"/>
      <verb in="vendre" tn="to sell" mo="vendre" hi="42"/>
    </verbs>
    """
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["parler"]?.frequency == 1)
    #expect(verbs["vendre"]?.frequency == 2)
    #expect(verbs["finir"]?.frequency == 3)
  }

  @Test func testVerbParserBreaksTiesThroughEachCountInTurn() {
    let xml = """
    <verbs>
      <verb in="danser" tn="to dance" mo="danser" hi="10" hn="5" hl="1" hs="7"/>
      <verb in="aimer" tn="to love" mo="aimer" hi="10" hn="5" hl="1" hs="9"/>
      <verb in="briser" tn="to break" mo="briser" hi="10" hn="5" hl="4"/>
      <verb in="courir" tn="to run" mo="courir" hi="10" hn="8"/>
    </verbs>
    """
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["courir"]?.frequency == 1)
    #expect(verbs["briser"]?.frequency == 2)
    #expect(verbs["aimer"]?.frequency == 3)
    #expect(verbs["danser"]?.frequency == 4)
  }

  @Test func testVerbParserRanksAbsentCountsBelowMeasuredZeros() {
    let xml = """
    <verbs>
      <verb in="aimer" tn="to love" mo="aimer"/>
      <verb in="zoner" tn="to hang about" mo="zoner" hi="0"/>
    </verbs>
    """
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["zoner"]?.frequency == 1)
    #expect(verbs["aimer"]?.frequency == 2)
  }

  @Test func testVerbParserSettlesRemainingTiesInFrenchCollation() {
    let xml = """
    <verbs>
      <verb in="zoner" tn="to hang about" mo="zoner" hi="4"/>
      <verb in="écouter" tn="to listen" mo="écouter" hi="4"/>
      <verb in="entrer" tn="to enter" mo="entrer" hi="4"/>
    </verbs>
    """
    let (verbs, _, _) = VerbParser(xmlString: xml).parse(models: [:])
    // French collation treats the accent as a secondary difference, so écouter precedes entrer.
    #expect(verbs["écouter"]?.frequency == 1)
    #expect(verbs["entrer"]?.frequency == 2)
    #expect(verbs["zoner"]?.frequency == 3)
  }

  @Test func testVerbParserGivesDoubledInfinitivesOneSharedRank() {
    let xml = """
    <verbs>
      <verb in="parler" tn="to speak" mo="parler" hi="900"/>
      <verb in="sortir" tn="to exit" mo="sortir" hi="500"/>
      <verb in="sortir" tn="to exit" mo="sortir-2" hi="500" ex="Canada"/>
      <verb in="finir" tn="to finish" mo="finir" hi="7"/>
    </verbs>
    """
    let (verbs, _, rankCount) = VerbParser(xmlString: xml).parse(models: [:])
    #expect(verbs["sortir"]?.frequency == 2)
    #expect(verbs["sortir Canada"]?.frequency == 2)
    // The shared rank consumes one place, so the next infinitive is 3 rather than 4.
    #expect(verbs["finir"]?.frequency == 3)
    #expect(rankCount == 3)
  }

  @Test func testShippingVerbDataRanksEveryDistinctInfinitif() {
    let distinctInfinitifs = Set(Verb.verbs.values.map(\.infinitif))
    #expect(Verb.rankCount == distinctInfinitifs.count)
    #expect(Set(Verb.verbs.values.map(\.frequency)).count == Verb.rankCount)
    #expect(Verb.verbs.values.allSatisfy { (1 ... Verb.rankCount).contains($0.frequency) })
    #expect(Verb.verbs["être"]?.frequency == 1)
  }
}
