//
//  AddedVerbsTests.swift
//  ConjuguerTests
//
//  Created by Claude on 8/28/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct AddedVerbsTests {
  @Test func testAlléger() {
    T.testConjugation(infinitif: "alléger", tense: .indicatifPrésent(.firstSingular), expected: "allÈge", extraLetters: nil)
    T.testConjugation(infinitif: "alléger", tense: .indicatifPrésent(.firstPlural), expected: "allégEons", extraLetters: nil)
    T.testConjugation(infinitif: "alléger", tense: .passéSimple(.thirdSingular), expected: "allégEa", extraLetters: nil)
    T.testConjugation(infinitif: "alléger", tense: .futurSimple(.firstSingular), expected: "allégerai", extraLetters: nil)
    T.testConjugation(infinitif: "alléger", tense: .participePassé, expected: "allégé", extraLetters: nil)
  }

  @Test func testÉgorger() {
    T.testConjugation(infinitif: "égorger", tense: .indicatifPrésent(.firstPlural), expected: "égorgEons", extraLetters: nil)
    T.testConjugation(infinitif: "égorger", tense: .passéSimple(.thirdSingular), expected: "égorgEa", extraLetters: nil)
    T.testConjugation(infinitif: "égorger", tense: .participePassé, expected: "égorgé", extraLetters: nil)
  }

  @Test func testPerpétuer() {
    T.testConjugation(infinitif: "perpétuer", tense: .indicatifPrésent(.firstSingular), expected: "perpétue", extraLetters: nil)
    T.testConjugation(infinitif: "perpétuer", tense: .indicatifPrésent(.firstPlural), expected: "perpétuons", extraLetters: nil)
    T.testConjugation(infinitif: "perpétuer", tense: .participePassé, expected: "perpétué", extraLetters: nil)
  }

  @Test func testEncaisser() {
    T.testConjugation(infinitif: "encaisser", tense: .indicatifPrésent(.firstSingular), expected: "encaisse", extraLetters: nil)
    T.testConjugation(infinitif: "encaisser", tense: .participePassé, expected: "encaissé", extraLetters: nil)
  }

  @Test func testÉduquer() {
    T.testConjugation(infinitif: "éduquer", tense: .indicatifPrésent(.firstPlural), expected: "éduquons", extraLetters: nil)
    T.testConjugation(infinitif: "éduquer", tense: .participePassé, expected: "éduqué", extraLetters: nil)
  }

  @Test func testRenamedRareVerbs() {
    T.testConjugation(infinitif: "récidiver", tense: .indicatifPrésent(.thirdSingular), expected: "récidive", extraLetters: nil)
    T.testConjugation(infinitif: "révolvériser", tense: .indicatifPrésent(.thirdSingular), expected: "révolvérise", extraLetters: nil)
    T.testConjugation(infinitif: "transvaser", tense: .indicatifPrésent(.thirdSingular), expected: "transvase", extraLetters: nil)
    T.testConjugation(infinitif: "désenvaser", tense: .indicatifPrésent(.thirdSingular), expected: "désenvase", extraLetters: nil)
  }

  // The nine misspellings are gone, so the conjugator must no longer know them. The last two
  // shipped as doubled-n duplicates alongside the standard spelling — every corpus knows
  // `ahaner` and `haubaner`, none has ever seen `ahanner` or `haubanner`.
  @Test func testMisspellingsNoLongerConjugate() {
    let misspellings = [
      "préenir", "récidier", "réolvériser", "transaser", "désenaser", "eduquer", "egorger",
      "ahanner", "haubanner"
    ]
    for misspelling in misspellings {
      #expect(Conjugator.conjugatedString(infinitif: misspelling, tense: .participePassé, extraLetters: nil) == nil)
    }
  }

  @Test func testStandardSpellingsOfTheFormerDuplicatesSurvive() {
    T.testConjugation(infinitif: "ahaner", tense: .indicatifPrésent(.thirdSingular), expected: "ahane", extraLetters: nil)
    T.testConjugation(infinitif: "ahaner", tense: .participePassé, expected: "ahané", extraLetters: nil)
    T.testConjugation(infinitif: "haubaner", tense: .indicatifPrésent(.thirdSingular), expected: "haubane", extraLetters: nil)
    T.testConjugation(infinitif: "haubaner", tense: .participePassé, expected: "haubané", extraLetters: nil)
  }

  // dépourvoir follows pourvoir (passé simple dépourvut), not voir (which would give dépourvit).
  @Test func testDépourvoir() {
    T.testConjugation(infinitif: "dépourvoir", tense: .participePassé, expected: "dépourvU", extraLetters: nil)
    T.testConjugation(infinitif: "dépourvoir", tense: .passéSimple(.thirdSingular), expected: "dépourvut", extraLetters: nil)
  }

  // The TLFi restricts dépourvoir to the infinitif and the compound tenses; defect group 27
  // encodes that by striking every simple tense except the participe passé the compounds need.
  @Test func testDépourvoirIsDefective() throws {
    #expect(DefectGroup.defectGroups["27"] != nil, "dépourvoir's group must parse.")
    let verb = try #require(Verb.verbs["dépourvoir"])
    #expect(verb.defectGroupId == "27")

    func isDefective(_ tense: Tense) -> Bool {
      VerbConjugations.isDefective(verb: verb, tense: tense)
    }

    #expect(isDefective(.indicatifPrésent(.firstSingular)))
    #expect(isDefective(.passéSimple(.thirdSingular)))
    #expect(isDefective(.imparfait(.thirdSingular)))
    #expect(isDefective(.futurSimple(.firstSingular)))
    #expect(isDefective(.impératif(.secondSingular)))
    #expect(isDefective(.participePrésent))
    #expect(!isDefective(.participePassé))
    #expect(!isDefective(.passéComposé(.firstSingular)))
    #expect(!isDefective(.plusQueParfait(.thirdPlural)))
    #expect(!isDefective(.futurAntérieur(.firstSingular)))
  }

  @Test func testRéinvestir() {
    T.testConjugation(infinitif: "réinvestir", tense: .indicatifPrésent(.firstPlural), expected: "réinvestissons", extraLetters: nil)
    T.testConjugation(infinitif: "réinvestir", tense: .participePassé, expected: "réinvesti", extraLetters: nil)
  }

  @Test func testRediriger() {
    T.testConjugation(infinitif: "rediriger", tense: .indicatifPrésent(.firstPlural), expected: "redirigEons", extraLetters: nil)
    T.testConjugation(infinitif: "rediriger", tense: .passéSimple(.thirdSingular), expected: "redirigEa", extraLetters: nil)
  }

  @Test func testBloguer() {
    T.testConjugation(infinitif: "bloguer", tense: .indicatifPrésent(.firstPlural), expected: "bloguons", extraLetters: nil)
    T.testConjugation(infinitif: "bloguer", tense: .participePassé, expected: "blogué", extraLetters: nil)
  }

  @Test func testCartographier() {
    T.testConjugation(infinitif: "cartographier", tense: .indicatifPrésent(.firstPlural), expected: "cartographions", extraLetters: nil)
    T.testConjugation(infinitif: "cartographier", tense: .participePassé, expected: "cartographié", extraLetters: nil)
  }

  @Test(arguments: [
    ("acter", "acte", "acté"),
    ("impacter", "impacte", "impacté"),
    ("recadrer", "recadre", "recadré"),
    ("redessiner", "redessine", "redessiné"),
    ("redimensionner", "redimensionne", "redimensionné")
  ])
  func testRegularAdditions(infinitif: String, présent: String, participePassé: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.thirdSingular), expected: présent, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .participePassé, expected: participePassé, extraLetters: nil)
  }
}
