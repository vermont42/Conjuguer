//
//  DefectivityAuditTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 6/17/26.
//

@testable import Conjuguer
import Testing

// Guards the TCAF-audit defectivity fixes: the -traire family must lose its (non-existent in
// modern French) passé simple and subjonctif imparfait, and a few archaic verbs gained/changed
// defect groups. Asserts against the view-facing `VerbConjugations.isDefective` path (the form
// dumps in ConjugationMapTool/FormsJSON.swift deliberately ignore defectivity, so they can't
// validate this).
@MainActor
struct DefectivityAuditTests {
  private func isDefective(_ infinitif: String, _ tense: Tense) -> Bool {
    VerbConjugations.isDefective(verb: Verb.verbs[infinitif]!, tense: tense)
  }

  @Test func testNewDefectGroupsLoaded() {
    #expect(DefectGroup.defectGroups["25"] != nil, "du=xA,qA group must parse.")
    #expect(DefectGroup.defectGroups["26"] != nil, "braire's combined group must parse.")
  }

  // traire / extraire (dg=25): no passé simple, no subjonctif imparfait; everything else kept.
  @Test func testTraireFamilyDropsPasséSimpleAndSubjonctifImparfait() {
    for verb in ["traire", "extraire", "soustraire", "distraire", "abstraire", "raire"] {
      #expect(isDefective(verb, .passéSimple(.thirdSingular)), "\(verb): passé simple must be defective.")
      #expect(isDefective(verb, .subjonctifImparfait(.thirdSingular)), "\(verb): subj. imparfait must be defective.")
      #expect(!isDefective(verb, .imparfait(.firstSingular)), "\(verb): imparfait must survive (je trayais).")
      #expect(!isDefective(verb, .futurSimple(.firstSingular)), "\(verb): futur must survive (je trairai).")
      #expect(!isDefective(verb, .indicatifPrésent(.firstSingular)), "\(verb): présent must survive (je trais).")
      #expect(!isDefective(verb, .participePassé), "\(verb): participe passé must survive (trait).")
    }
  }

  // braire (dg=26): keeps only 3s/3p (+ pp, p. présent), and also drops passé simple + subj. imparfait.
  @Test func testBraireKeeps3s3pButDropsPasséSimple() {
    #expect(!isDefective("braire", .indicatifPrésent(.thirdSingular)), "il brait must survive.")
    #expect(!isDefective("braire", .indicatifPrésent(.thirdPlural)), "ils braient must survive.")
    #expect(isDefective("braire", .indicatifPrésent(.firstSingular)), "je brais must be defective.")
    #expect(isDefective("braire", .passéSimple(.thirdSingular)), "il braya must be defective.")
    #expect(isDefective("braire", .subjonctifImparfait(.thirdSingular)), "subj. imparfait must be defective.")
  }

  // férir (dg=6): only participe passé survives, so "féru" shows where dg=0 had hidden it.
  @Test func testFérirSurfacesParticipePassé() {
    #expect(!isDefective("férir", .participePassé), "féru must survive.")
    #expect(isDefective("férir", .indicatifPrésent(.thirdSingular)), "présent must be defective.")
    #expect(isDefective("férir", .passéSimple(.thirdSingular)), "passé simple must be defective.")
  }

  // poindre (dg=24): 1s/2s/1p/2p drop; 3s/3p and participe passé survive.
  @Test func testPoindreRestrictedToThirdPersons() {
    #expect(isDefective("poindre", .indicatifPrésent(.firstSingular)), "je poins must be defective.")
    #expect(!isDefective("poindre", .indicatifPrésent(.thirdSingular)), "le jour point must survive.")
    #expect(!isDefective("poindre", .indicatifPrésent(.thirdPlural)), "les bourgeons poignent must survive.")
    #expect(!isDefective("poindre", .participePassé), "point (p.p.) must survive.")
  }

  // béer (dg=17): the Académie's 9th edition gives it as "usité surtout à
  // l'indicatif présent et imparfait, au participe présent et à l'infinitif présent", and the
  // app's example is Tolstoy's "Une blessure béait".
  @Test func testBéerKeepsPrésentAndImparfait() {
    #expect(!isDefective("béer", .imparfait(.thirdSingular)), "une blessure béait must survive.")
    #expect(!isDefective("béer", .indicatifPrésent(.thirdPlural)), "les tiroirs béent must survive.")
    #expect(!isDefective("béer", .participePrésent), "béant must survive.")
    #expect(isDefective("béer", .futurSimple(.thirdSingular)), "futur must be defective.")
  }

  // pouvoir (dg=28): no impératif, simple or passé; every other tense kept.
  @Test func testPouvoirHasNoImpératif() {
    #expect(DefectGroup.defectGroups["28"] != nil, "du=hA group must parse.")
    for personNumber in PersonNumber.impératifPersonNumbers {
      #expect(isDefective("pouvoir", .impératif(personNumber)), "\(personNumber): impératif must be defective.")
      #expect(isDefective("pouvoir", .impératifPassé(personNumber)), "\(personNumber): impératif passé must be defective.")
    }
    #expect(!isDefective("pouvoir", .indicatifPrésent(.firstSingular)), "je peux must survive.")
    #expect(!isDefective("pouvoir", .subjonctifPrésent(.thirdSingular)), "qu'il puisse must survive.")
    #expect(!isDefective("pouvoir", .participePassé), "pu must survive.")
  }

  // douer (no group): the TLFi finds it rare outside the infinitive and
  // the compound tenses "sauf chez les écrivains récents", and the app's example is Proust's
  // "Elle les douait".
  @Test func testDouerIsNotDefective() {
    #expect(Verb.verbs["douer"]?.defectGroupId == nil)
    #expect(!isDefective("douer", .imparfait(.thirdSingular)), "elle les douait must survive.")
  }
}
