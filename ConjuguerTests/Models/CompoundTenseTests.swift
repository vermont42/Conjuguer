//
//  CompoundTenseTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 1/1/21.
//

@testable import Conjuguer
import XCTest

@MainActor
class CompoundTenseTests: XCTestCase {
  func testCompoundTenses() {
    // Use feminine pronouns regardless of user preference. Mutate the property in place
    // rather than reassigning `Current.settings`: replacing the @Observable property
    // releases the old Settings inside ObservationRegistrar.withMutation, which invokes its
    // MainActor-isolated deinit and crashes the runtime (swift_task_deinitOnExecutorImpl).
    // Nothing in the app reassigns Current.settings, so mutating in place matches real usage.
    Current.settings.pronounGender = .feminine
    let aller = "aller"
    let avoir = "avoir"

    var personNumbersIndex = 0

    for conjugation in ["SUIs allée", "Es allée", "ESt allée", "SOMMEs allées", "êteS allées", "SOnt allées"] {
      T.testConjugation(infinitif: aller, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU", "As EU", "A EU", "avons EU", "avez EU", "Ont EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéComposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Étais allée", "Étais allée", "Était allée", "Étions allées", "Étiez allées", "Étaient allées"] {
      T.testConjugation(infinitif: aller, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["avais EU", "avais EU", "avait EU", "avions EU", "aviez EU", "avaient EU"] {
      T.testConjugation(infinitif: avoir, tense: .plusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fus allée", "Fus allée", "Fut allée", "Fûmes allées", "Fûtes allées", "Furent allées"] {
      T.testConjugation(infinitif: aller, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eus EU", "Eus EU", "Eut EU", "Eûmes EU", "Eûtes EU", "Eurent EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI ÉtÉ allée", "As ÉtÉ allée", "A ÉtÉ allée", "avons ÉtÉ allées", "avez ÉtÉ allées", "Ont ÉtÉ allées"] {
      T.testConjugation(infinitif: aller, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aI EU EU", "As EU EU", "A EU EU", "avons EU EU", "avez EU EU", "Ont EU EU"] {
      T.testConjugation(infinitif: avoir, tense: .passéSurcomposé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErai allée", "SEras allée", "SEra allée", "SErons allées", "SErez allées", "SEront allées"] {
      T.testConjugation(infinitif: aller, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrai EU", "aUras EU", "aUra EU", "aUrons EU", "aUrez EU", "aUront EU"] {
      T.testConjugation(infinitif: avoir, tense: .futurAntérieur(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SErais allée", "SErais allée", "SErait allée", "SErions allées", "SEriez allées", "SEraient allées"] {
      T.testConjugation(infinitif: aller, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aUrais EU", "aUrais EU", "aUrait EU", "aUrions EU", "aUriez EU", "aUraient EU"] {
      T.testConjugation(infinitif: avoir, tense: .conditionnelPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["SOIS allée", "SOIs allée", "SOIT allée", "SOYons allées", "SOYez allées", "SOIent allées"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["aIE EU", "aIES EU", "aIT EU", "aYons EU", "aYez EU", "aIENT EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPassé(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Fusse allée", "Fusses allée", "Fût allée", "Fussions allées", "Fussiez allées", "Fussent allées"] {
      T.testConjugation(infinitif: aller, tense: .subjonctifPlusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    for conjugation in ["Eusse EU", "Eusses EU", "Eût EU", "Eussions EU", "Eussiez EU", "Eussent EU"] {
      T.testConjugation(infinitif: avoir, tense: .subjonctifPlusQueParfait(PersonNumber.allCases[personNumbersIndex]), expected: conjugation, extraLetters: nil)
      personNumbersIndex += 1
      personNumbersIndex %= PersonNumber.allCases.count
    }

    var impératifPersonNumbersIndex = 0

    for conjugation in ["SOIs allée", "SOYons allées", "SOYez allées"] {
      T.testConjugation(infinitif: aller, tense: .impératifPassé(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }

    for conjugation in ["aIE EU", "aYons EU", "aYez EU"] {
      T.testConjugation(infinitif: avoir, tense: .impératifPassé(PersonNumber.impératifPersonNumbers[impératifPersonNumbersIndex]), expected: conjugation, extraLetters: nil)
      impératifPersonNumbersIndex += 1
      impératifPersonNumbersIndex %= PersonNumber.impératifPersonNumbers.count
    }
  }
}

// Verifies that external deep links switch tabs while in-app links (tapped from within an
// already-presented detail sheet, e.g. ModelView's verb list or InfoView's text) are
// handled in place: no tab switch and no clearing of the sibling entity that drives the
// underlying sheet. Lives here to avoid a project-file change for a new test file.
@MainActor
class DeeplinkTests: XCTestCase {
  private func url(_ string: String) -> URL {
    guard let url = URL(string: string) else {
      fatalError("Invalid test URL: \(string)")
    }
    return url
  }

  override func setUp() {
    super.setUp()
    Current.verb = nil
    Current.verbModel = nil
    Current.info = nil
  }

  // External deep links should activate the relevant tab so its browse view can present.
  func testHandleURLSwitchesTab() {
    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://verb/parler"))
    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.selectedTab, .verbs)

    Current.selectedTab = .settings
    Current.handleURL(url("conjuguer://info/2"))
    XCTAssertEqual(Current.info, Info.infos[2])
    XCTAssertEqual(Current.selectedTab, .info)
  }

  // In-app verb links must not switch tabs (the reported bug: tapping a verb in ModelView's
  // "Verbs Using This Model" then dismissing left the user on the Verbs tab).
  func testHandleInAppURLDoesNotSwitchTab() {
    Current.selectedTab = .models
    Current.handleInAppURL(url("conjuguer://verb/parler"))
    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.selectedTab, .models, "In-app verb link must not change the tab.")

    Current.selectedTab = .info
    Current.handleInAppURL(url("conjuguer://info/3"))
    XCTAssertEqual(Current.info, Info.infos[3])
    XCTAssertEqual(Current.selectedTab, .info, "In-app info link must not change the tab.")
  }

  // In the Models tab, ModelView is driven by Current.verbModel. Handling a verb link from
  // its text in place must not clear verbModel, or the underlying ModelView sheet blanks out.
  func testHandleInAppURLPreservesSiblingEntity() {
    let model = VerbModel.models["4-2B"]
    XCTAssertNotNil(model)
    Current.verbModel = model
    Current.selectedTab = .models

    Current.handleInAppURL(url("conjuguer://verb/parler"))

    XCTAssertEqual(Current.verb?.infinitif, "parler")
    XCTAssertEqual(Current.verbModel?.id, model?.id, "In-app link must not clear the sibling verbModel.")
    XCTAssertEqual(Current.selectedTab, .models)
  }
}
