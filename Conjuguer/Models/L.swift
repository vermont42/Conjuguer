//
//  L.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/1/21.
//

import Foundation

enum L {
  enum Navigation {
    static var verbs: String {
      String(localized: "Navigation.verbs")
    }

    static var models: String {
      String(localized: "Navigation.models")
    }

    static var quiz: String {
      String(localized: "Navigation.quiz")
    }

    static var results: String {
      String(localized: "Navigation.results")
    }

    static var info: String {
      String(localized: "Navigation.info")
    }

    static var settings: String {
      String(localized: "Navigation.settings")
    }

    static var input: String {
      String(localized: "Navigation.input")
    }

    static var back: String {
      String(localized: "Navigation.back")
    }
  }

  enum VerbView {
    static var overview: String {
      String(localized: "VerbView.overview")
    }

    static var model: String {
      String(localized: "VerbView.model")
    }

    static var reflexive: String {
      String(localized: "VerbView.reflexive")
    }

    static var aspiratedH: String {
      String(localized: "VerbView.aspiratedH")
    }

    static var auxiliaryÊtre: String {
      String(localized: "VerbView.auxiliaryÊtre")
    }

    static var auxiliaryAvoir: String {
      String(localized: "VerbView.auxiliaryAvoir")
    }

    static var frequency: String {
      String(localized: "VerbView.frequency")
    }

    static var defective: String {
      String(localized: "VerbView.defective")
    }

    static var exampleUse: String {
      String(localized: "VerbView.exampleUse")
    }

    static var personlessConjugations: String {
      String(localized: "VerbView.personlessConjugations")
    }

    static var showCompoundTenses: String {
      String(localized: "VerbView.showCompoundTenses")
    }
  }

  enum ResultsView {
    static var correctWithColon: String {
      String(localized: "ResultsView.correctWithColon")
    }

    static var timeWithColon: String {
      String(localized: "ResultsView.timeWithColon")
    }
  }

  enum ModelView {
    static var parent: String {
      String(localized: "ModelView.parent")
    }

    static var defective: String {
      String(localized: "ModelView.defective")
    }

    static var endings: String {
      String(localized: "ModelView.endings")
    }

    static var stemAlterations: String {
      String(localized: "ModelView.stemAlterations")
    }

    static var regular: String {
      String(localized: "ModelView.regular")
    }

    static var irregular: String {
      String(localized: "ModelView.irregular")
    }

    static var verbsUsing: String {
      String(localized: "ModelView.verbsUsing")
    }

    static var verbUsing: String {
      String(localized: "ModelView.verbUsing")
    }
  }

  enum QuizView {
    static var start: String {
      String(localized: "QuizView.start")
    }

    static var verbWithColon: String {
      String(localized: "QuizView.verbWithColon")
    }

    static var translationWithColon: String {
      String(localized: "QuizView.translationWithColon")
    }

    static var pronounWithColon: String {
      String(localized: "QuizView.pronounWithColon")
    }

    static var tenseWithColon: String {
      String(localized: "QuizView.tenseWithColon")
    }

    static var progressWithColon: String {
      String(localized: "QuizView.progressWithColon")
    }

    static var scoreWithColon: String {
      String(localized: "QuizView.scoreWithColon")
    }

    static var elapsedWithColon: String {
      String(localized: "QuizView.elapsedWithColon")
    }

    static var conjugation: String {
      String(localized: "QuizView.conjugation")
    }

    static var quit: String {
      String(localized: "QuizView.quit")
    }

    static var gameCenterFailure: String {
      String(localized: "QuizView.gameCenterFailure")
    }

    static var none: String {
      String(localized: "QuizView.none")
    }

    static var cool: String {
      String(localized: "QuizView.cool")
    }
  }

  enum Info {
    static var dedicationHeading: String {
      String(localized: "Info.dedicationHeading")
    }

    static var dedicationText: String {
      String(localized: "Info.dedicationText")
    }

    static var valuePropositionHeading: String {
      String(localized: "Info.valuePropositionHeading")
    }

    static var valuePropositionText: String {
      String(localized: "Info.valuePropositionText")
    }

    static var purposeAndUseHeading: String {
      String(localized: "Info.purposeAndUseHeading")
    }

    static var purposeAndUseText: String {
      String(localized: "Info.purposeAndUseText")
    }

    static var terminologyHeading: String {
      String(localized: "Info.terminologyHeading")
    }

    static var terminologyText: String {
      String(localized: "Info.terminologyText")
    }

    static var defectivenessHeading: String {
      String(localized: "Info.defectivenessHeading")
    }

    static var defectivenessText: String {
      String(localized: "Info.defectivenessText")
    }

    static var participePasséHeading: String {
      String(localized: "Info.participePasséHeading")
    }

    static var participePasséText: String {
      String(localized: "Info.participePasséText")
    }

    static var participePrésentHeading: String {
      String(localized: "Info.participePrésentHeading")
    }

    static var participePrésentText: String {
      String(localized: "Info.participePrésentText")
    }

    static var radicalFuturHeading: String {
      String(localized: "Info.radicalFuturHeading")
    }

    static var radicalFuturText: String {
      String(localized: "Info.radicalFuturText")
    }

    static var irregularitiesHeading: String {
      String(localized: "Info.irregularitiesHeading")
    }

    static var irregularitiesText: String {
      String(localized: "Info.irregularitiesText")
    }

    static var indicatifPrésentHeading: String {
      String(localized: "Info.indicatifPrésentHeading")
    }

    static var indicatifPrésentText: String {
      String(localized: "Info.indicatifPrésentText")
    }

    static var passéSimpleHeading: String {
      String(localized: "Info.passéSimpleHeading")
    }

    static var passéSimpleText: String {
      String(localized: "Info.passéSimpleText")
    }

    static var imparfaitHeading: String {
      String(localized: "Info.imparfaitHeading")
    }

    static var imparfaitText: String {
      String(localized: "Info.imparfaitText")
    }

    static var futurSimpleHeading: String {
      String(localized: "Info.futurSimpleHeading")
    }

    static var futurSimpleText: String {
      String(localized: "Info.futurSimpleText")
    }

    static var conditionnelPrésentHeading: String {
      String(localized: "Info.conditionnelPrésentHeading")
    }

    static var conditionnelPrésentText: String {
      String(localized: "Info.conditionnelPrésentText")
    }

    static var subjonctifPrésentHeading: String {
      String(localized: "Info.subjonctifPrésentHeading")
    }

    static var subjonctifPrésentText: String {
      String(localized: "Info.subjonctifPrésentText")
    }

    static var subjonctifImparfaitHeading: String {
      String(localized: "Info.subjonctifImparfaitHeading")
    }

    static var subjonctifImparfaitText: String {
      String(localized: "Info.subjonctifImparfaitText")
    }

    static var impératifHeading: String {
      String(localized: "Info.impératifHeading")
    }

    static var impératifText: String {
      String(localized: "Info.impératifText")
    }

    static var passéComposéHeading: String {
      String(localized: "Info.passéComposéHeading")
    }

    static var passéComposéText: String {
      String(localized: "Info.passéComposéText")
    }

    static var plusQueParfaitHeading: String {
      String(localized: "Info.plusQueParfaitHeading")
    }

    static var plusQueParfaitText: String {
      String(localized: "Info.plusQueParfaitText")
    }

    static var passéAntérieurHeading: String {
      String(localized: "Info.passéAntérieurHeading")
    }

    static var passéAntérieurText: String {
      String(localized: "Info.passéAntérieurText")
    }

    static var passéSurcomposéHeading: String {
      String(localized: "Info.passéSurcomposéHeading")
    }

    static var passéSurcomposéText: String {
      String(localized: "Info.passéSurcomposéText")
    }

    static var futurAntérieurHeading: String {
      String(localized: "Info.futurAntérieurHeading")
    }

    static var futurAntérieurText: String {
      String(localized: "Info.futurAntérieurText")
    }

    static var conditionnelPasséHeading: String {
      String(localized: "Info.conditionnelPasséHeading")
    }

    static var conditionnelPasséText: String {
      String(localized: "Info.conditionnelPasséText")
    }

    static var subjonctifPasséHeading: String {
      String(localized: "Info.subjonctifPasséHeading")
    }

    static var subjonctifPasséText: String {
      String(localized: "Info.subjonctifPasséText")
    }

    static var subjonctifPlusQueParfaitHeading: String {
      String(localized: "Info.subjonctifPlusQueParfaitHeading")
    }

    static var subjonctifPlusQueParfaitText: String {
      String(localized: "Info.subjonctifPlusQueParfaitText")
    }

    static var impératifPasséHeading: String {
      String(localized: "Info.impératifPasséHeading")
    }

    static var impératifPasséText: String {
      String(localized: "Info.impératifPasséText")
    }

    static var questionsAndResponsesHeading: String {
      String(localized: "Info.questionsAndResponsesHeading")
    }

    static var questionsAndResponsesText: String {
      String(localized: "Info.questionsAndResponsesText")
    }

    static var creditsHeading: String {
      String(localized: "Info.creditsHeading")
    }

    static var creditsText: String {
      String(localized: "Info.creditsText")
    }
  }

  enum Settings {
    static var quizDifficulty: String {
      String(localized: "Settings.quizDifficulty")
    }

    static var quizDifficultyDescription: String {
      String(localized: "Settings.quizDifficultyDescription")
    }

    static var pronounGender: String {
      String(localized: "Settings.pronounGender")
    }

    static var pronounGenderDescription: String {
      String(localized: "Settings.pronounGenderDescription")
    }
  }

  enum QuizDifficulty {
    static var regular: String {
      String(localized: "QuizDifficulty.regular")
    }

    static var ridiculous: String {
      String(localized: "QuizDifficulty.ridiculous")
    }

    static var regularDifficulty: String {
      String(localized: "QuizDifficulty.regularDifficulty")
    }

    static var ridiculousDifficulty: String {
      String(localized: "QuizDifficulty.ridiculousDifficulty")
    }
  }

  enum PronounGender {
    static var feminine: String {
      String(localized: "PronounGender.feminine")
    }

    static var masculine: String {
      String(localized: "PronounGender.masculine")
    }

    static var both: String {
      String(localized: "PronounGender.both")
    }

    static var feminineAbbreviation: String {
      String(localized: "PronounGender.feminineAbbreviation")
    }

    static var masculineAbbreviation: String {
      String(localized: "PronounGender.masculineAbbreviation")
    }
  }

  static func displayNameForVerbSort(_ sort: VerbSort) -> String {
    switch sort {
    case .frequency:
      return String(localized: "VerbSort.frequency")
    case .alphabetical:
      return String(localized: "alphabetical")
    }
  }

  static func displayNameForModelSort(_ sort: ModelSort) -> String {
    switch sort {
    case .irregularity:
      return String(localized: "ModelSort.irregularity")
    case .alphabetical:
      return String(localized: "alphabetical")
    case .identifier:
      return String(localized: "ModelSort.identifier")
    }
  }
}
