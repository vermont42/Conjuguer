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
      NSLocalizedString("Navigation.verbs", comment: "")
    }

    static var models: String {
      NSLocalizedString("Navigation.models", comment: "")
    }

    static var quiz: String {
      NSLocalizedString("Navigation.quiz", comment: "")
    }

    static var results: String {
      NSLocalizedString("Navigation.results", comment: "")
    }

    static var info: String {
      NSLocalizedString("Navigation.info", comment: "")
    }

    static var settings: String {
      NSLocalizedString("Navigation.settings", comment: "")
    }

    static var input: String {
      NSLocalizedString("Navigation.input", comment: "")
    }

    static var back: String {
      NSLocalizedString("Navigation.back", comment: "")
    }
  }

  enum VerbView {
    static var overview: String {
      NSLocalizedString("VerbView.overview", comment: "")
    }

    static var model: String {
      NSLocalizedString("VerbView.model", comment: "")
    }

    static var reflexive: String {
      NSLocalizedString("VerbView.reflexive", comment: "")
    }

    static var aspiratedH: String {
      NSLocalizedString("VerbView.aspiratedH", comment: "")
    }

    static var auxiliaryÊtre: String {
      NSLocalizedString("VerbView.auxiliaryÊtre", comment: "")
    }

    static var auxiliaryAvoir: String {
      NSLocalizedString("VerbView.auxiliaryAvoir", comment: "")
    }

    static var frequency: String {
      NSLocalizedString("VerbView.frequency", comment: "")
    }

    static var defective: String {
      NSLocalizedString("VerbView.defective", comment: "")
    }

    static var exampleUse: String {
      NSLocalizedString("VerbView.exampleUse", comment: "")
    }

    static var personlessConjugations: String {
      NSLocalizedString("VerbView.personlessConjugations", comment: "")
    }

    static var showCompoundTenses: String {
      NSLocalizedString("VerbView.showCompoundTenses", comment: "")
    }
  }

  enum ResultsView {
    static var correctWithColon: String {
      NSLocalizedString("ResultsView.correctWithColon", comment: "")
    }

    static var timeWithColon: String {
      NSLocalizedString("ResultsView.timeWithColon", comment: "")
    }
  }

  enum ModelView {
    static var parent: String {
      NSLocalizedString("ModelView.parent", comment: "")
    }

    static var defective: String {
      NSLocalizedString("ModelView.defective", comment: "")
    }

    static var endings: String {
      NSLocalizedString("ModelView.endings", comment: "")
    }

    static var stemAlterations: String {
      NSLocalizedString("ModelView.stemAlterations", comment: "")
    }

    static var regular: String {
      NSLocalizedString("ModelView.regular", comment: "")
    }

    static var irregular: String {
      NSLocalizedString("ModelView.irregular", comment: "")
    }

    static var verbsUsing: String {
      NSLocalizedString("ModelView.verbsUsing", comment: "")
    }

    static var verbUsing: String {
      NSLocalizedString("ModelView.verbUsing", comment: "")
    }
  }

  enum QuizView {
    static var start: String {
      NSLocalizedString("QuizView.start", comment: "")
    }

    static var verbWithColon: String {
      NSLocalizedString("QuizView.verbWithColon", comment: "")
    }

    static var translationWithColon: String {
      NSLocalizedString("QuizView.translationWithColon", comment: "")
    }

    static var pronounWithColon: String {
      NSLocalizedString("QuizView.pronounWithColon", comment: "")
    }

    static var tenseWithColon: String {
      NSLocalizedString("QuizView.tenseWithColon", comment: "")
    }

    static var progressWithColon: String {
      NSLocalizedString("QuizView.progressWithColon", comment: "")
    }

    static var scoreWithColon: String {
      NSLocalizedString("QuizView.scoreWithColon", comment: "")
    }

    static var elapsedWithColon: String {
      NSLocalizedString("QuizView.elapsedWithColon", comment: "")
    }

    static var conjugation: String {
      NSLocalizedString("QuizView.conjugation", comment: "")
    }

    static var quit: String {
      NSLocalizedString("QuizView.quit", comment: "")
    }

    static var gameCenterFailure: String {
      NSLocalizedString("QuizView.gameCenterFailure", comment: "")
    }

    static var none: String {
      NSLocalizedString("QuizView.none", comment: "")
    }

    static var quizComplete: String {
      NSLocalizedString("QuizView.quizComplete", comment: "")
    }

    static var cool: String {
      NSLocalizedString("QuizView.cool", comment: "")
    }
  }

  enum Info {
    static var dedicationHeading: String {
      NSLocalizedString("Info.dedicationHeading", comment: "")
    }

    static var dedicationText: String {
      NSLocalizedString("Info.dedicationText", comment: "")
    }

    static var purposeAndUseHeading: String {
      NSLocalizedString("Info.purposeAndUseHeading", comment: "")
    }

    static var purposeAndUseText: String {
      NSLocalizedString("Info.purposeAndUseText", comment: "")
    }

    static var terminologyHeading: String {
      NSLocalizedString("Info.terminologyHeading", comment: "")
    }

    static var terminologyText: String {
      NSLocalizedString("Info.terminologyText", comment: "")
    }

    static var defectivenessHeading: String {
      NSLocalizedString("Info.defectivenessHeading", comment: "")
    }

    static var defectivenessText: String {
      NSLocalizedString("Info.defectivenessText", comment: "")
    }

    static var participePasséHeading: String {
      NSLocalizedString("Info.participePasséHeading", comment: "")
    }

    static var participePasséText: String {
      NSLocalizedString("Info.participePasséText", comment: "")
    }

    static var participePrésentHeading: String {
      NSLocalizedString("Info.participePrésentHeading", comment: "")
    }

    static var participePrésentText: String {
      NSLocalizedString("Info.participePrésentText", comment: "")
    }

    static var radicalFuturHeading: String {
      NSLocalizedString("Info.radicalFuturHeading", comment: "")
    }

    static var radicalFuturText: String {
      NSLocalizedString("Info.radicalFuturText", comment: "")
    }

    static var indicatifPrésentHeading: String {
      NSLocalizedString("Info.indicatifPrésentHeading", comment: "")
    }

    static var indicatifPrésentText: String {
      NSLocalizedString("Info.indicatifPrésentText", comment: "")
    }

    static var passéSimpleHeading: String {
      NSLocalizedString("Info.passéSimpleHeading", comment: "")
    }

    static var passéSimpleText: String {
      NSLocalizedString("Info.passéSimpleText", comment: "")
    }

    static var imparfaitHeading: String {
      NSLocalizedString("Info.imparfaitHeading", comment: "")
    }

    static var imparfaitText: String {
      NSLocalizedString("Info.imparfaitText", comment: "")
    }

    static var futurSimpleHeading: String {
      NSLocalizedString("Info.futurSimpleHeading", comment: "")
    }

    static var futurSimpleText: String {
      NSLocalizedString("Info.futurSimpleText", comment: "")
    }

    static var conditionnelPrésentHeading: String {
      NSLocalizedString("Info.conditionnelPrésentHeading", comment: "")
    }

    static var conditionnelPrésentText: String {
      NSLocalizedString("Info.conditionnelPrésentText", comment: "")
    }

    static var subjonctifPrésentHeading: String {
      NSLocalizedString("Info.subjonctifPrésentHeading", comment: "")
    }

    static var subjonctifPrésentText: String {
      NSLocalizedString("Info.subjonctifPrésentText", comment: "")
    }

    static var subjonctifImparfaitHeading: String {
      NSLocalizedString("Info.subjonctifImparfaitHeading", comment: "")
    }

    static var subjonctifImparfaitText: String {
      NSLocalizedString("Info.subjonctifImparfaitText", comment: "")
    }

    static var impératifHeading: String {
      NSLocalizedString("Info.impératifHeading", comment: "")
    }

    static var impératifText: String {
      NSLocalizedString("Info.impératifText", comment: "")
    }

    static var passéComposéHeading: String {
      NSLocalizedString("Info.passéComposéHeading", comment: "")
    }

    static var passéComposéText: String {
      NSLocalizedString("Info.passéComposéText", comment: "")
    }

    static var plusQueParfaitHeading: String {
      NSLocalizedString("Info.plusQueParfaitHeading", comment: "")
    }

    static var plusQueParfaitText: String {
      NSLocalizedString("Info.plusQueParfaitText", comment: "")
    }

    static var passéAntérieurHeading: String {
      NSLocalizedString("Info.passéAntérieurHeading", comment: "")
    }

    static var passéAntérieurText: String {
      NSLocalizedString("Info.passéAntérieurText", comment: "")
    }

    static var passéSurcomposéHeading: String {
      NSLocalizedString("Info.passéSurcomposéHeading", comment: "")
    }

    static var passéSurcomposéText: String {
      NSLocalizedString("Info.passéSurcomposéText", comment: "")
    }

    static var futurAntérieurHeading: String {
      NSLocalizedString("Info.futurAntérieurHeading", comment: "")
    }

    static var futurAntérieurText: String {
      NSLocalizedString("Info.futurAntérieurText", comment: "")
    }

    static var conditionnelPasséHeading: String {
      NSLocalizedString("Info.conditionnelPasséHeading", comment: "")
    }

    static var conditionnelPasséText: String {
      NSLocalizedString("Info.conditionnelPasséText", comment: "")
    }

    static var subjonctifPasséHeading: String {
      NSLocalizedString("Info.subjonctifPasséHeading", comment: "")
    }

    static var subjonctifPasséText: String {
      NSLocalizedString("Info.subjonctifPasséText", comment: "")
    }

    static var subjonctifPlusQueParfaitHeading: String {
      NSLocalizedString("Info.subjonctifPlusQueParfaitHeading", comment: "")
    }

    static var subjonctifPlusQueParfaitText: String {
      NSLocalizedString("Info.subjonctifPlusQueParfaitText", comment: "")
    }

    static var impératifPasséHeading: String {
      NSLocalizedString("Info.impératifPasséHeading", comment: "")
    }

    static var impératifPasséText: String {
      NSLocalizedString("Info.impératifPasséText", comment: "")
    }

    static var questionsAndResponsesHeading: String {
      NSLocalizedString("Info.questionsAndResponsesHeading", comment: "")
    }

    static var questionsAndResponsesText: String {
      NSLocalizedString("Info.questionsAndResponsesText", comment: "")
    }

    static var creditsHeading: String {
      NSLocalizedString("Info.creditsHeading", comment: "")
    }

    static var creditsText: String {
      NSLocalizedString("Info.creditsText", comment: "")
    }
  }

  enum Settings {
    static var quizDifficulty: String {
      NSLocalizedString("Settings.quizDifficulty", comment: "")
    }

    static var quizDifficultyDescription: String {
      NSLocalizedString("Settings.quizDifficultyDescription", comment: "")
    }

    static var pronounGender: String {
      NSLocalizedString("Settings.pronounGender", comment: "")
    }

    static var pronounGenderDescription: String {
      NSLocalizedString("Settings.pronounGenderDescription", comment: "")
    }
  }

  enum QuizDifficulty {
    static var regular: String {
      NSLocalizedString("QuizDifficulty.regular", comment: "")
    }

    static var ridiculous: String {
      NSLocalizedString("QuizDifficulty.ridiculous", comment: "")
    }

    static var regularDifficulty: String {
      NSLocalizedString("QuizDifficulty.regularDifficulty", comment: "")
    }

    static var ridiculousDifficulty: String {
      NSLocalizedString("QuizDifficulty.ridiculousDifficulty", comment: "")
    }
  }

  enum PronounGender {
    static var feminine: String {
      NSLocalizedString("PronounGender.feminine", comment: "")
    }

    static var masculine: String {
      NSLocalizedString("PronounGender.masculine", comment: "")
    }

    static var both: String {
      NSLocalizedString("PronounGender.both", comment: "")
    }

    static var feminineAbbreviation: String {
      NSLocalizedString("PronounGender.feminineAbbreviation", comment: "")
    }

    static var masculineAbbreviation: String {
      NSLocalizedString("PronounGender.masculineAbbreviation", comment: "")
    }
  }

  static func displayNameForVerbSort(_ sort: VerbSort) -> String {
    switch sort {
    case .frequency:
      return NSLocalizedString("VerbSort.frequency", comment: "")
    case .alphabetic:
      return NSLocalizedString("VerbSort.alphabetic", comment: "")
    }
  }

  static func displayNameForModelSort(_ sort: ModelSort) -> String {
    switch sort {
    case .irregularity:
      return NSLocalizedString("ModelSort.irregularity", comment: "")
    case .alphabetic:
      return NSLocalizedString("ModelSort.alphabetic", comment: "")
    case .identifier:
      return NSLocalizedString("ModelSort.identifier", comment: "")
    }
  }
}
