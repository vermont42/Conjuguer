//
//  EngineAuditTests.swift
//  ConjuguerTests
//
//  Created by Claude on 9/20/26.
//

@testable import Conjuguer
import Testing

// Pins the forms corrected in stage A of the verb pass, each verified against Wiktionary's
// conjugation table before it was written here.
//
// These forms need a hand-written home because `VerbModelTests` is generated from the engine's
// own output: it pinned *ils pouvent*, *vous dÎTES* and *suivIS* for years and never objected,
// since a test that records what the conjugator says cannot notice that the conjugator is
// wrong. Every expectation below was read off an external reference first.
@MainActor
struct EngineAuditTests {
  // Model 4-6 altered the stem for the third-person singular but not the plural, so the third
  // plural fell through to the bare stem. vouloir (4-8) had carried the matching rule all along.
  @Test func testPouvoirOpensItsStemInTheThirdPlural() {
    T.testConjugation(infinitif: "pouvoir", tense: .indicatifPrésent(.thirdSingular), expected: "pEUt", extraLetters: nil)
    T.testConjugation(infinitif: "pouvoir", tense: .indicatifPrésent(.firstPlural), expected: "pouvons", extraLetters: nil)
    T.testConjugation(infinitif: "pouvoir", tense: .indicatifPrésent(.thirdPlural), expected: "pEUvent", extraLetters: nil)
  }

  // dire and its inheritors take -tes without a circumflex; the accented vous dîtes belongs to
  // the passé simple, which model 5-8A reaches by a different route.
  @Test(arguments: [
    ("dire", "dITES", "dîtes"),
    ("redire", "redITES", "redîtes")
  ])
  func testDireTakesAPlainTesInThePrésent(infinitif: String, présent: String, passéSimple: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.secondPlural), expected: présent, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .impératif(.secondPlural), expected: présent, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .passéSimple(.secondPlural), expected: passéSimple, extraLetters: nil)
  }

  // 5-8B does not inherit the alteration, so prédire and its family keep the regular -disez.
  @Test func testPrédireFamilyIsUntouched() {
    T.testConjugation(infinitif: "prédire", tense: .indicatifPrésent(.secondPlural), expected: "prédiSez", extraLetters: nil)
    T.testConjugation(infinitif: "interdire", tense: .indicatifPrésent(.secondPlural), expected: "interdiSez", extraLetters: nil)
  }

  // Model 5-5 carried ep="IS", which is the passé simple's stem, not the participe's.
  @Test(arguments: ["suivre", "poursuivre", "ensuivre"])
  func testSuivreFamilyParticipeHasNoS(infinitif: String) {
    let stem = String(infinitif.dropLast(2))
    T.testConjugation(infinitif: infinitif, tense: .participePassé, expected: stem + "I", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .passéSimple(.firstSingular), expected: stem + "is", extraLetters: nil)
  }

  // The seven verbs that sat on a model whose exemplar they do not actually follow. Each row is
  // présent first singular, présent first plural, futur first singular, participe passé.
  @Test(arguments: [
    ("rejeter", "rejetTe", "rejetons", "rejetTerai", "rejeté"),
    ("mener", "mÈne", "menons", "mÈnerai", "mené"),
    ("changer", "change", "changEons", "changerai", "changé"),
    ("lécher", "lÈche", "léchons", "lécherai", "léché"),
    ("déféquer", "défÈque", "déféquons", "déféquerai", "déféqué"),
    ("empaqueter", "empaquetTe", "empaquetons", "empaquetTerai", "empaqueté"),
    ("assortir", "assortis", "assortissons", "assortirai", "assorti")
  ])
  func testRemodeledVerbs(infinitif: String, singular: String, plural: String, futur: String, participe: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstSingular), expected: singular, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstPlural), expected: plural, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .futurSimple(.firstSingular), expected: futur, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .participePassé, expected: participe, extraLetters: nil)
  }

  // changer's g softens before a and o but not before the endings that begin with e or i, which
  // is what distinguishes manger (1-2B) from the plain 1-1 the verb used to sit on.
  @Test func testChangerSoftensItsGOnlyWhereItMust() {
    T.testConjugation(infinitif: "changer", tense: .imparfait(.firstSingular), expected: "changEais", extraLetters: nil)
    T.testConjugation(infinitif: "changer", tense: .imparfait(.firstPlural), expected: "changions", extraLetters: nil)
    T.testConjugation(infinitif: "changer", tense: .passéSimple(.thirdSingular), expected: "changEa", extraLetters: nil)
    T.testConjugation(infinitif: "changer", tense: .passéSimple(.thirdPlural), expected: "changèrent", extraLetters: nil)
  }

  // The seventeen entries moved to être. The masculine singular is enough to show the auxiliary;
  // the plural additionally shows that the participe agrees, which avoir would not do.
  @Test(arguments: [
    ("advenir", "SUIs advenU"),
    ("apparaître", "SUIs appaRu"),
    ("bienvenir", "SUIs bienvenU"),
    ("demeurer", "SUIs demeuré"),
    ("intervenir", "SUIs intervenU"),
    ("obvenir", "SUIs obvenU"),
    ("passer", "SUIs passé"),
    ("provenir", "SUIs provenU"),
    ("réapparaître", "SUIs réappaRu"),
    ("redescendre", "SUIs redescendu"),
    ("redevenir", "SUIs redevenU"),
    ("remonter", "SUIs remonté"),
    ("renaître", "SUIs reNÉ"),
    ("repartir", "SUIs reparti"),
    ("ressortir", "SUIs ressorti"),
    ("retomber", "SUIs retombé"),
    ("survenir", "SUIs survenU")
  ])
  func testAuxiliaryIsÊtre(infinitif: String, passéComposé: String) {
    T.testConjugation(infinitif: infinitif, tense: .passéComposé(.firstSingular), expected: passéComposé, extraLetters: nil, pronounGender: .masculine)
  }

  @Test func testÊtreVerbsAgreeInTheFeminine() {
    T.testConjugation(infinitif: "intervenir", tense: .passéComposé(.firstSingular), expected: "SUIs intervenUe", extraLetters: nil, pronounGender: .feminine)
    T.testConjugation(infinitif: "retomber", tense: .passéComposé(.thirdPlural), expected: "SOnt retombées", extraLetters: nil, pronounGender: .feminine)
  }

  // Decision 4 of the verb-pass plan: one auxiliary per entry, chosen by the sense the gloss
  // leads with. These four keep avoir on purpose, so a later pass does not "fix" them.
  @Test(arguments: ["paraître", "disparaître", "repasser", "ressusciter"])
  func testEitherAuxiliaryVerbsKeepAvoir(infinitif: String) {
    let form = T.conjugate(infinitif: infinitif, tense: .passéComposé(.firstSingular), extraLetters: nil, pronounGender: .masculine)
    #expect(form.hasPrefix("aI "), "\(infinitif) should still conjugate with avoir, but gave \(form).")
  }
}
