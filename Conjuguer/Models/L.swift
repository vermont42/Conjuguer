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

    static var done: String {
      String(localized: "Navigation.done")
    }
  }

  enum BrowseView {
    static var sortOrder: String {
      String(localized: "BrowseView.sortOrder")
    }
  }

  enum VerbBrowseView {
    static var searchPrompt: String {
      String(localized: "VerbBrowseView.searchPrompt")
    }
  }

  enum ModelBrowseView {
    static var searchPrompt: String {
      String(localized: "ModelBrowseView.searchPrompt")
    }
  }

  enum InfoBrowseView {
    static var sectionAbout: String {
      String(localized: "InfoBrowseView.sectionAbout")
    }

    static var sectionConcepts: String {
      String(localized: "InfoBrowseView.sectionConcepts")
    }

    static var sectionTenses: String {
      String(localized: "InfoBrowseView.sectionTenses")
    }
  }

  enum VerbView {
    static var overview: String {
      String(localized: "VerbView.overview")
    }

    static var modelWithColon: String {
      String(localized: "VerbView.modelWithColon")
    }

    static var reflexive: String {
      String(localized: "VerbView.reflexive")
    }

    static var aspiratedH: String {
      String(localized: "VerbView.aspiratedH")
    }

    static var auxiliaryWithColon: String {
      String(localized: "VerbView.auxiliaryWithColon")
    }

    static var frequencyWithColon: String {
      String(localized: "VerbView.frequencyWithColon")
    }

    static var defective: String {
      String(localized: "VerbView.defective")
    }

    static var exampleUse: String {
      String(localized: "VerbView.exampleUse")
    }

    static var exampleUses: String {
      String(localized: "VerbView.exampleUses")
    }

    static var personlessConjugations: String {
      String(localized: "VerbView.personlessConjugations")
    }

    static var showCompoundTenses: String {
      String(localized: "VerbView.showCompoundTenses")
    }

    static var modelButtonHint: String {
      String(localized: "VerbView.modelButtonHint")
    }

    static var colorKeyTitle: String {
      String(localized: "VerbView.colorKeyTitle")
    }

    static var colorKeyRegular: String {
      String(localized: "VerbView.colorKeyRegular")
    }

    static var colorKeyIrregular: String {
      String(localized: "VerbView.colorKeyIrregular")
    }

    static var colorKeyExplanation: String {
      String(localized: "VerbView.colorKeyExplanation")
    }

    static var dismissColorKey: String {
      String(localized: "VerbView.dismissColorKey")
    }

    static var etymologyHeading: String {
      String(localized: "VerbView.etymologyHeading")
    }

    static var sourceSwissPublic: String {
      String(localized: "VerbView.sourceSwissPublic")
    }

    static var sourceFrenchGov: String {
      String(localized: "VerbView.sourceFrenchGov")
    }

    static var sourceClaude: String {
      String(localized: "VerbView.sourceClaude")
    }

    static func sourceWikipedia(_ article: String) -> String {
      String(localized: "VerbView.sourceWikipedia", defaultValue: "— Wikipédia, « \(article) » (CC BY-SA 4.0)")
    }

    static var chansonHeading: String {
      String(localized: "VerbView.chansonHeading")
    }

    static var chansonNextExample: String {
      String(localized: "VerbView.chansonNextExample")
    }

    static func chansonReference(laisse: String, line: Int?) -> String {
      if let line {
        return String(localized: "VerbView.chansonReference", defaultValue: "Laisse \(laisse), Line \(String(line))")
      } else {
        return String(localized: "VerbView.chansonReferenceNoLine", defaultValue: "Laisse \(laisse)")
      }
    }
  }

  enum ResultsView {
    static var correctWithColon: String {
      String(localized: "ResultsView.correctWithColon")
    }

    static var yourAnswerWithColon: String {
      String(localized: "ResultsView.yourAnswerWithColon")
    }

    static func correct(_ score: String, of total: Int) -> String {
      String(localized: "ResultsView.correctCount", defaultValue: "Correct: \(score) / \(total)")
    }

    static func time(_ timeString: String) -> String {
      String(localized: "ResultsView.time", defaultValue: "Time: \(timeString)")
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

    static func verbsUsing(count: Int) -> String {
      count > 1
        ? String(localized: "ModelView.verbsUsing")
        : String(localized: "ModelView.verbUsing")
    }

    static var infoButtonHint: String {
      String(localized: "ModelView.infoButtonHint")
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

    static var lastAnswer: String {
      String(localized: "QuizView.lastAnswer")
    }

    static var correctAnswer: String {
      String(localized: "QuizView.correctAnswer")
    }

    static var briefing: String {
      String(localized: "QuizView.briefing")
    }

    static var questionCount: String {
      String(localized: "QuizView.questionCount")
    }

    static func score(_ value: Int) -> String {
      String(localized: "QuizView.score", defaultValue: "Score: \(value)")
    }

    static func bestScore(_ value: Int) -> String {
      String(localized: "QuizView.bestScore", defaultValue: "Best score: \(value)")
    }

    static func elapsed(seconds: Int) -> String {
      String(localized: "QuizView.elapsed", defaultValue: "Elapsed: \(seconds) seconds")
    }

    static func progress(_ current: Int, of total: Int) -> String {
      String(localized: "QuizView.progressCount", defaultValue: "\(current) out of \(total)")
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

    static var ratingsAndReviews: String {
      String(localized: "Settings.ratingsAndReviews")
    }

    static var rateOrReview: String {
      String(localized: "Settings.rateOrReview")
    }

    static var appIcon: String {
      String(localized: "Settings.appIcon")
    }
  }

  enum AppIcon {
    static var arcDeTriomphe: String {
      String(localized: "AppIcon.arcDeTriomphe")
    }

    static var rooster: String {
      String(localized: "AppIcon.rooster")
    }

    static var croissant: String {
      String(localized: "AppIcon.croissant")
    }

    static var beret: String {
      String(localized: "AppIcon.beret")
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

  enum RatingsFetcher {
    static var noRating: String {
      String(localized: "RatingsFetcher.noRating")
    }

    static func ratings(count: Int) -> String {
      String(localized: "RatingsFetcher.ratings", defaultValue: "\(count)")
    }
  }

  enum ImageInfo {
    static var davidCompton: String {
      String(localized: "ImageInfo.davidCompton")
    }

    static var joshAdams: String {
      String(localized: "ImageInfo.joshAdams")
    }
  }

  enum VerbSort {
    static var frequency: String {
      String(localized: "VerbSort.frequency")
    }

    static var alphabetical: String {
      String(localized: "VerbSort.alphabetical")
    }
  }

  enum ModelSort {
    static var irregularity: String {
      String(localized: "ModelSort.irregularity")
    }

    static var alphabetical: String {
      String(localized: "ModelSort.alphabetical")
    }

    static var identifier: String {
      String(localized: "ModelSort.identifier")
    }
  }

  enum Onboarding {
    static var skip: String {
      String(localized: "Onboarding.skip")
    }

    static var dismiss: String {
      String(localized: "Onboarding.dismiss")
    }

    static var getStarted: String {
      String(localized: "Onboarding.getStarted")
    }

    static var onboarding: String {
      String(localized: "Onboarding.onboarding")
    }

    static var showOnboarding: String {
      String(localized: "Onboarding.showOnboarding")
    }

    static var showOnboardingDescription: String {
      String(localized: "Onboarding.showOnboardingDescription")
    }

    static var welcomeTitle: String {
      String(localized: "Onboarding.welcomeTitle")
    }

    static var welcomeBody: String {
      String(localized: "Onboarding.welcomeBody")
    }

    static var browseTitle: String {
      String(localized: "Onboarding.browseTitle")
    }

    static var browseBody: String {
      String(localized: "Onboarding.browseBody")
    }

    static var browseVerbsButton: String {
      String(localized: "Onboarding.browseVerbsButton")
    }

    static var modelsTitle: String {
      String(localized: "Onboarding.modelsTitle")
    }

    static var modelsBody: String {
      String(localized: "Onboarding.modelsBody")
    }

    static var exploreModelsButton: String {
      String(localized: "Onboarding.exploreModelsButton")
    }

    static var quizTitle: String {
      String(localized: "Onboarding.quizTitle")
    }

    static var quizBody: String {
      String(localized: "Onboarding.quizBody")
    }

    static var startQuizButton: String {
      String(localized: "Onboarding.startQuizButton")
    }

    static var learnTitle: String {
      String(localized: "Onboarding.learnTitle")
    }

    static var learnBody: String {
      String(localized: "Onboarding.learnBody")
    }

    static var readArticlesButton: String {
      String(localized: "Onboarding.readArticlesButton")
    }
  }
}
