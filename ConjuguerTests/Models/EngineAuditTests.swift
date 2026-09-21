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
  // --- Stage A2: the engine errors the Wiktionary conjugation audit found -------------------

  // Model 5-6 built the passé simple and the subjonctif imparfait on the présent stem, so the
  // three verbs of the vivre family conjugated *je vivis* for *je vécus*. The présent singular
  // (vIs) was right all along, which is why this hid: the two tenses are spelled alike in the
  // first person of the -ir verbs, and nothing compared vivre to an outside reference.
  @Test(arguments: ["vivre", "survivre", "revivre"])
  func testVivreFamilyTakesTheVécuStemInThePasséSimple(infinitif: String) {
    let stem = String(infinitif.dropLast(5))
    T.testConjugation(infinitif: infinitif, tense: .passéSimple(.firstSingular), expected: stem + "vÉCus", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .passéSimple(.firstPlural), expected: stem + "vÉCûmes", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .subjonctifImparfait(.firstPlural), expected: stem + "vÉCussions", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstSingular), expected: stem + "vIs", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .participePassé, expected: stem + "vÉCu", extraLetters: nil)
  }

  // 1-4 replaces the character two from the end of the stem, which is the è of *pes-* but the v
  // of *sevr-*. sevrer is the only verb of the family whose stem ends in a consonant cluster, so
  // it got model 1-4A rather than a change to the one 68 other verbs depend on.
  @Test func testSevrerAccentsTheRightVowel() {
    T.testConjugation(infinitif: "sevrer", tense: .indicatifPrésent(.firstSingular), expected: "sÈvre", extraLetters: nil)
    T.testConjugation(infinitif: "sevrer", tense: .futurSimple(.firstSingular), expected: "sÈvrerai", extraLetters: nil)
    T.testConjugation(infinitif: "peser", tense: .indicatifPrésent(.firstSingular), expected: "pÈse", extraLetters: nil)
    T.testConjugation(infinitif: "peser", tense: .futurSimple(.firstSingular), expected: "pÈserai", extraLetters: nil)
  }

  // absoudre and dissoudre take the participe passé *absous*; résoudre takes *résolu*, built on
  // the same -sol- stem its plural and passé simple already used. 5-13 keeps the absous rule and
  // marks it uninherited, so 5-13A can supply its own.
  @Test func testResoudreTakesRésoluAndAbsoudreKeepsAbsous() {
    T.testConjugation(infinitif: "résoudre", tense: .participePassé, expected: "résoLu", extraLetters: nil)
    T.testConjugation(infinitif: "résoudre", tense: .indicatifPrésent(.firstSingular), expected: "résoUs", extraLetters: nil)
    T.testConjugation(infinitif: "résoudre", tense: .passéSimple(.firstSingular), expected: "résoLus", extraLetters: nil)
    T.testConjugation(infinitif: "absoudre", tense: .participePassé, expected: "absouS", extraLetters: nil)
    T.testConjugation(infinitif: "dissoudre", tense: .participePassé, expected: "dissouS", extraLetters: nil)
  }

  // 3-2C rebuilt the infinitive stem for the impératif, undoing the very alteration that gives
  // the indicative its *bous*. The impératif follows the indicative here, so the rule had to go.
  @Test func testBouillirImpératifFollowsTheIndicative() {
    T.testConjugation(infinitif: "bouillir", tense: .impératif(.secondSingular), expected: "bouS", extraLetters: nil)
    T.testConjugation(infinitif: "bouillir", tense: .indicatifPrésent(.secondSingular), expected: "bouS", extraLetters: nil)
    T.testConjugation(infinitif: "bouillir", tense: .impératif(.firstPlural), expected: "bouillOns", extraLetters: nil)
  }

  // *failli* is the participe passé in use; *faillu* is archaic. Model 4-12 keeps the archaic
  // présent (je faux, il faut), which references still give, but not the archaic participe.
  @Test func testFaillirTakesFailli() {
    T.testConjugation(infinitif: "faillir", tense: .participePassé, expected: "failli", extraLetters: nil)
    T.testConjugation(infinitif: "faillir", tense: .passéSimple(.firstSingular), expected: "faillis", extraLetters: nil)
  }

  // *le cas échéant*. The participe présent is built from the nous form, so the é stem has to be
  // restored after the fact; 4-11A (choir) is untouched.
  @Test func testÉchoirTakesÉchéant() {
    T.testConjugation(infinitif: "échoir", tense: .participePrésent, expected: "échÉant", extraLetters: nil)
    T.testConjugation(infinitif: "choir", tense: .participePrésent, expected: "chOYant", extraLetters: nil)
  }

  // seoir and messeoir sat on asseoir's model, which gave them its second paradigm (*s'assoit*)
  // as a bogus alternate and its *asseyent* where the two need *siéent*.
  @Test(arguments: ["s", "mess"])
  func testSeoirFamilySiéent(prefix: String) {
    let infinitif = prefix + "eoir"
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.thirdSingular), expected: prefix + "IED", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.thirdPlural), expected: prefix + "IÉent", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .subjonctifPrésent(.thirdSingular), expected: prefix + "IÉE", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .participePrésent, expected: prefix + "eYant", extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .futurSimple(.thirdSingular), expected: prefix + "IÉra", extraLetters: nil)
  }

  // The participe présent appended its ending once to a stem that can hold two alternates, so
  // asseoir printed "asseY/assOYant" instead of offering both participles.
  @Test func testParticipePrésentEndsBothAlternates() {
    T.testConjugation(infinitif: "asseoir", tense: .participePrésent, expected: "asseYant/assOYant", extraLetters: nil)
    T.testConjugation(infinitif: "rasseoir", tense: .participePrésent, expected: "rasseYant/rassOYant", extraLetters: nil)
  }

  // The eight entries whose model was simply wrong for the verb. Présent first singular, présent
  // first plural, futur first singular, participe passé — the same four columns Stage A used.
  @Test(arguments: [
    ("relever", "relÈve", "relevons", "relÈverai", "relevé"),
    ("parfumer", "parfume", "parfumons", "parfumerai", "parfumé"),
    ("jauger", "jauge", "jaugEons", "jaugerai", "jaugé"),
    ("gamberger", "gamberge", "gambergEons", "gambergerai", "gambergé"),
    ("débriefer", "débriÈfe", "débriefons", "débriÈferai", "débriefé"),
    ("déficeler", "déficÈle", "déficelons", "déficÈlerai", "déficelé"),
    ("briqueter", "briquÈte", "briquetons", "briquÈterai", "briqueté"),
    ("amuïr", "amuïs", "amuïssons", "amuïrai", "amuï")
  ])
  func testRemodeledVerbsOfStageA2(infinitif: String, singular: String, plural: String, futur: String, participe: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstSingular), expected: singular, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.firstPlural), expected: plural, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .futurSimple(.firstSingular), expected: futur, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .participePassé, expected: participe, extraLetters: nil)
  }

  // parfumer was modeled on rendre, which gave it *je parfums* and a second-group passé simple.
  @Test func testParfumerConjugatesAsAnErVerb() {
    T.testConjugation(infinitif: "parfumer", tense: .passéSimple(.thirdSingular), expected: "parfuma", extraLetters: nil)
    T.testConjugation(infinitif: "parfumer", tense: .impératif(.secondSingular), expected: "parfume", extraLetters: nil)
  }

  // amuïr keeps its diaeresis throughout, which is what 2-3B (the Québec haïr) is for; ouïr's
  // modern entry already sits there. On 2-1 the verb lost the ï in all 32 disagreeing forms.
  @Test func testAmuïrKeepsItsDiaeresis() {
    T.testConjugation(infinitif: "amuïr", tense: .imparfait(.firstSingular), expected: "amuïssais", extraLetters: nil)
    T.testConjugation(infinitif: "amuïr", tense: .passéSimple(.firstPlural), expected: "amuïmes", extraLetters: nil)
    T.testConjugation(infinitif: "amuïr", tense: .participePrésent, expected: "amuïssant", extraLetters: nil)
  }

  // Decision 6 of the verb-pass plan: the twelve verbs English Wiktionary spells only with the
  // grave accent move to 1-4 (peser), leaving 1-3A and 1-3B to the verbs it spells only with the
  // doubled consonant. Présent third singular and futur first singular for each.
  @Test(arguments: [
    ("déchiqueter", "déchiquÈte", "déchiquÈterai"),
    ("ruisseler", "ruissÈle", "ruissÈlerai"),
    ("ensorceler", "ensorcÈle", "ensorcÈlerai"),
    ("cacheter", "cachÈte", "cachÈterai"),
    ("niveler", "nivÈle", "nivÈlerai"),
    ("tacheter", "tachÈte", "tachÈterai"),
    ("trompeter", "trompÈte", "trompÈterai"),
    ("déniveler", "dénivÈle", "dénivÈlerai"),
    ("marketer", "markÈte", "markÈterai"),
    ("craqueter", "craquÈte", "craquÈterai"),
    ("dépaqueter", "dépaquÈte", "dépaquÈterai"),
    ("bêcheveter", "bêchevÈte", "bêchevÈterai")
  ])
  func testRectifiedElerEterSpelling(infinitif: String, présent: String, futur: String) {
    T.testConjugation(infinitif: infinitif, tense: .indicatifPrésent(.thirdSingular), expected: présent, extraLetters: nil)
    T.testConjugation(infinitif: infinitif, tense: .futurSimple(.firstSingular), expected: futur, extraLetters: nil)
  }

  // The other side of decision 6: appeler, jeter and their compounds keep the doubled consonant,
  // which is the spelling the 1990 rectifications left them and the only one Wiktionary gives.
  @Test(arguments: ["appeler", "rappeler", "jeter", "rejeter", "projeter", "interjeter"])
  func testAppelerAndJeterKeepTheirDoubledConsonant(infinitif: String) {
    let présent = T.conjugate(infinitif: infinitif, tense: .indicatifPrésent(.thirdSingular), extraLetters: nil)
    #expect(présent.hasSuffix("Le") || présent.hasSuffix("Te"), "\(infinitif) gave \(présent), which is not the doubled spelling.")
  }
}
