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

    static var findVerb: String {
      String(localized: "VerbBrowseView.findVerb")
    }

    static var guessIntro: String {
      String(localized: "VerbBrowseView.guessIntro")
    }

    static var addressCopied: String {
      String(localized: "VerbBrowseView.addressCopied")
    }

    static func verbRequest(query: String, address: String) -> String {
      String(localized: "VerbBrowseView.verbRequest", defaultValue: "If you believe that “\(query)” is a French verb, please email \(address).")
    }

    static func verbRequestSubject(query: String) -> String {
      String(localized: "VerbBrowseView.verbRequestSubject", defaultValue: "Conjuguer: please add “\(query)”")
    }

    static func verbRequestBody(query: String) -> String {
      String(localized: "VerbBrowseView.verbRequestBody", defaultValue: "I searched Conjuguer for “\(query)” and believe that it is a French verb.")
    }

    // Separate singular and plural keys rather than a String Catalog plural variation: the
    // rendered count is a locale-formatted string, and a variation can only select on the
    // number it also interpolates. English and French agree that only exactly 1 is singular,
    // and the caller omits the label entirely at 0.
    static func verbCount(count: Int) -> String {
      let formattedCount = count.formatted()

      if count == 1 {
        return String(localized: "VerbBrowseView.verbCountSingular", defaultValue: "\(formattedCount) verb")
      } else {
        return String(localized: "VerbBrowseView.verbCountPlural", defaultValue: "\(formattedCount) verbs")
      }
    }
  }

  enum MyVerbs {
    static var title: String {
      String(localized: "MyVerbs.title")
    }

    static var starred: String {
      String(localized: "MyVerbs.starred")
    }

    static var recent: String {
      String(localized: "MyVerbs.recent")
    }

    static var clearRecent: String {
      String(localized: "MyVerbs.clearRecent")
    }

    static var delete: String {
      String(localized: "MyVerbs.delete")
    }

    static var emptyTitle: String {
      String(localized: "MyVerbs.emptyTitle")
    }

    static var emptyDescription: String {
      String(localized: "MyVerbs.emptyDescription")
    }

    static var unstarConfirm: String {
      String(localized: "MyVerbs.unstarConfirm")
    }

    static var unstarMessage: String {
      String(localized: "MyVerbs.unstarMessage")
    }

    static func unstarTitle(_ infinitif: String) -> String {
      String(localized: "MyVerbs.unstarTitle", defaultValue: "Remove the star from “\(infinitif)”?")
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

    static var matchesSearch: String {
      String(localized: "VerbView.matchesSearch")
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

    static func secondName(_ name: String) -> String {
      String(localized: "VerbView.secondName", defaultValue: "also \(name)")
    }

    static var relatedHeading: String {
      String(localized: "VerbView.relatedHeading")
    }

    static var copy: String {
      String(localized: "VerbView.copy")
    }

    static var share: String {
      String(localized: "VerbView.share")
    }

    static var star: String {
      String(localized: "VerbView.star")
    }

    static var unstar: String {
      String(localized: "VerbView.unstar")
    }

    static var testMe: String {
      String(localized: "VerbView.testMe")
    }

    static func shareGloss(infinitif: String, gloss: String) -> String {
      String(localized: "VerbView.shareGloss", defaultValue: "\(infinitif), “\(gloss)”")
    }

    static func shareInvitation(infinitif: String, link: String) -> String {
      String(localized: "VerbView.shareInvitation", defaultValue: "Every conjugation of \(infinitif) is in Conjuguer:\n\(link)")
    }

    static func builtOn(_ root: String) -> String {
      String(localized: "VerbView.builtOn", defaultValue: "Built on \(root)")
    }

    static var builtOnLabel: String {
      String(localized: "VerbView.builtOnLabel")
    }

    static var sameModelLabel: String {
      String(localized: "VerbView.sameModelLabel")
    }

    static func allRelated(_ count: Int) -> String {
      String(localized: "VerbView.allRelated", defaultValue: "All \(count.formatted())")
    }

    static var articleButtonHint: String {
      String(localized: "VerbView.articleButtonHint")
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

    static func sourceClaude(_ model: String) -> String {
      String(localized: "VerbView.sourceClaude", defaultValue: "— example written by \(model)")
    }

    static func sourceWikipedia(_ article: String) -> String {
      String(localized: "VerbView.sourceWikipedia", defaultValue: "— Wikipédia, « \(article) » (CC BY-SA 4.0)")
    }

    static func sourceWiktionnaire(_ citation: String) -> String {
      String(localized: "VerbView.sourceWiktionnaire", defaultValue: "— \(citation), via French Wiktionary")
    }

    static func sourceWiktionary(_ citation: String) -> String {
      String(localized: "VerbView.sourceWiktionary", defaultValue: "— \(citation), via Wiktionary")
    }

    static var sourceWiktionaryExample: String {
      String(localized: "VerbView.sourceWiktionaryExample")
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
    static var newBest: String {
      String(localized: "ResultsView.newBest")
    }

    static func best(_ best: Int) -> String {
      String(localized: "ResultsView.best", defaultValue: "Your best: \(best)")
    }

    static var exampleHint: String {
      String(localized: "ResultsView.exampleHint")
    }

    static var correctWithColon: String {
      String(localized: "ResultsView.correctWithColon")
    }

    static var yourAnswerWithColon: String {
      String(localized: "ResultsView.yourAnswerWithColon")
    }

    static func correct(_ count: Int, of total: Int) -> String {
      String(localized: "ResultsView.correctCount", defaultValue: "Correct: \(count) / \(total)")
    }

    static func secondTry(_ count: Int) -> String {
      String(localized: "ResultsView.secondTry", defaultValue: "Second Try: \(count)")
    }

    static var firstTryWithColon: String {
      String(localized: "ResultsView.firstTryWithColon")
    }

    static func time(_ timeString: String) -> String {
      String(localized: "ResultsView.time", defaultValue: "Time: \(timeString)")
    }

    static func askedAgain(_ count: Int, of total: Int) -> String {
      String(localized: "ResultsView.askedAgainCount", defaultValue: "Asked Again: \(count) / \(total)")
    }

    static var tenMore: String {
      String(localized: "ResultsView.tenMore")
    }

    static var tenMoreHint: String {
      String(localized: "ResultsView.tenMoreHint")
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

  enum Diagnosis {
    static func agreement(_ agreement: String) -> String {
      String(localized: "Diagnosis.agreement", defaultValue: "With être, the participle agrees with the subject, here \(agreement).")
    }

    static var feminine: String {
      String(localized: "Diagnosis.feminine")
    }

    static var masculine: String {
      String(localized: "Diagnosis.masculine")
    }

    static var femininePlural: String {
      String(localized: "Diagnosis.femininePlural")
    }

    static var masculinePlural: String {
      String(localized: "Diagnosis.masculinePlural")
    }

    static var agreementWithAvoir: String {
      String(localized: "Diagnosis.agreementWithAvoir")
    }

    static func wrongAuxiliary(_ infinitif: String, _ expected: String, _ given: String) -> String {
      String(localized: "Diagnosis.wrongAuxiliary", defaultValue: "\(infinitif) takes \(expected), not \(given), in its compound tenses.")
    }

    static var pronominalAuxiliary: String {
      String(localized: "Diagnosis.pronominalAuxiliary")
    }

    static func auxiliaryWithoutObject(_ infinitif: String) -> String {
      String(localized: "Diagnosis.auxiliaryWithoutObject", defaultValue: "Without a direct object, \(infinitif) takes être, not avoir.")
    }

    static var missingAuxiliary: String {
      String(localized: "Diagnosis.missingAuxiliary")
    }

    static func otherEntry(_ given: String, _ asked: String) -> String {
      String(localized: "Diagnosis.otherEntry", defaultValue: "That is \(given). The question asks \(asked).")
    }

    static func cedilla(_ infinitif: String) -> String {
      String(localized: "Diagnosis.cedilla", defaultValue: "Before a or o, \(infinitif) writes ç, so the c stays soft.")
    }

    static func softG(_ infinitif: String) -> String {
      String(localized: "Diagnosis.softG", defaultValue: "Before a or o, \(infinitif) keeps an e after the g, so the g stays soft.")
    }

    static func doubledConsonant(_ infinitif: String, _ letter: String) -> String {
      String(localized: "Diagnosis.doubledConsonant", defaultValue: "Before a silent e, \(infinitif) doubles its \(letter).")
    }

    static func graveForE(_ infinitif: String) -> String {
      String(localized: "Diagnosis.graveForE", defaultValue: "Before a silent e, \(infinitif) writes è.")
    }

    static func graveForEAcute(_ infinitif: String) -> String {
      String(localized: "Diagnosis.graveForEAcute", defaultValue: "Before a silent e, \(infinitif) changes é to è.")
    }

    static func yToI(_ infinitif: String) -> String {
      String(localized: "Diagnosis.yToI", defaultValue: "Before a silent e, \(infinitif) changes y to i.")
    }

    static func futurStem(_ infinitif: String) -> String {
      String(localized: "Diagnosis.futurStem", defaultValue: "\(infinitif) has an irregular futur stem, shared by the conditionnel.")
    }

    static func vousTes(_ infinitif: String) -> String {
      String(localized: "Diagnosis.vousTes", defaultValue: "With vous, \(infinitif) ends in -tes in the présent.")
    }

    static func otherPerson(_ pronouns: String) -> String {
      String(localized: "Diagnosis.otherPerson", defaultValue: "That is the conjugation for \(pronouns).")
    }

    // French writes "le passé simple" but "l’imparfait", so a tense beginning with a vowel has a
    // key of its own.
    static func otherTense(_ tense: String) -> String {
      String(localized: "Diagnosis.otherTense", defaultValue: "That is the \(tense).")
    }

    static func otherTenseElided(_ tense: String) -> String {
      String(localized: "Diagnosis.otherTenseElided", defaultValue: "That is the \(tense).")
    }

    static func otherTensePersons(_ tense: String, _ pronouns: String) -> String {
      String(localized: "Diagnosis.otherTensePersons", defaultValue: "That is the \(tense), for \(pronouns).")
    }

    static func otherTensePersonsElided(_ tense: String, _ pronouns: String) -> String {
      String(localized: "Diagnosis.otherTensePersonsElided", defaultValue: "That is the \(tense), for \(pronouns).")
    }

    static func regularForm(_ exemplar: String, _ infinitif: String) -> String {
      String(localized: "Diagnosis.regularForm", defaultValue: "That is the regular form, as \(exemplar) has it. \(infinitif) is irregular here.")
    }

    static func otherGroup(_ exemplar: String, _ infinitif: String) -> String {
      String(localized: "Diagnosis.otherGroup", defaultValue: "That is how verbs like \(exemplar) are conjugated, and \(infinitif) is not one.")
    }
  }

  enum QuizView {
    static var start: String {
      String(localized: "QuizView.start")
    }

    static var scope: String {
      String(localized: "QuizView.scope")
    }

    static var allVerbs: String {
      String(localized: "QuizView.allVerbs")
    }

    static var myVerbsEmpty: String {
      String(localized: "QuizView.myVerbsEmpty")
    }

    // Separate singular and plural keys, as `VerbBrowseView.verbCount(count:)` explains.
    static func myVerbsCount(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "QuizView.myVerbsCountSingular", defaultValue: "Questions about \(formattedCount) verb in My Verbs")
      } else {
        return String(localized: "QuizView.myVerbsCountPlural", defaultValue: "Questions about \(formattedCount) verbs in My Verbs")
      }
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

    static var alsoSpelledWithColon: String {
      String(localized: "QuizView.alsoSpelledWithColon")
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

    static var blank: String {
      String(localized: "QuizView.blank")
    }

    static var singular: String {
      String(localized: "QuizView.singular")
    }

    static var plural: String {
      String(localized: "QuizView.plural")
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

    static var yourAnswer: String {
      String(localized: "QuizView.yourAnswer")
    }

    static var correctAnswer: String {
      String(localized: "QuizView.correctAnswer")
    }

    static var continueAfterCorrection: String {
      String(localized: "QuizView.continue")
    }

    static var incorrect: String {
      String(localized: "QuizView.incorrect")
    }

    static var almost: String {
      String(localized: "QuizView.almost")
    }

    static var tryOnceMore: String {
      String(localized: "QuizView.tryOnceMore")
    }

    static var askedAgain: String {
      String(localized: "QuizView.askedAgain")
    }

    static var willBeAskedAgain: String {
      String(localized: "QuizView.willBeAskedAgain")
    }

    static func differingLetters(_ letters: String) -> String {
      String(localized: "QuizView.differingLetters", defaultValue: "Letters that differ: \(letters).")
    }

    static var correctionHint: String {
      String(localized: "QuizView.correctionHint")
    }

    static var continueHint: String {
      String(localized: "QuizView.continueHint")
    }

    static var correctionLinkHint: String {
      String(localized: "QuizView.correctionLinkHint")
    }

    static var briefing: String {
      String(localized: "QuizView.briefing")
    }

    static var questionsLabel: String {
      String(localized: "QuizView.questionsLabel")
    }

    static var sessionMinutes: String {
      String(localized: "QuizView.sessionMinutes")
    }

    static var minutesLabel: String {
      String(localized: "QuizView.minutesLabel")
    }

    static var sessionLength: String {
      String(localized: "QuizView.sessionLength")
    }

    static var levelLabel: String {
      String(localized: "QuizView.levelLabel")
    }

    static var levelMenuHint: String {
      String(localized: "QuizView.levelMenuHint")
    }

    static var lastQuiz: String {
      String(localized: "QuizView.lastQuiz")
    }

    static var exercises: String {
      String(localized: "QuizView.exercises")
    }

    static var viewLeaderboard: String {
      String(localized: "QuizView.viewLeaderboard")
    }

    static var leaderboardHint: String {
      String(localized: "QuizView.leaderboardHint")
    }

    static var viewAchievements: String {
      String(localized: "QuizView.viewAchievements")
    }

    static var achievementsHint: String {
      String(localized: "QuizView.achievementsHint")
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

    static var gameInstructionsHeading: String {
      String(localized: "Info.gameInstructionsHeading")
    }

    static var gameInstructionsText: String {
      String(localized: "Info.gameInstructionsText")
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

    static var verbHistoryHeading: String {
      String(localized: "Info.verbHistoryHeading")
    }

    static var verbHistoryText: String {
      String(localized: "Info.verbHistoryText")
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
    static var quizLevel: String {
      String(localized: "Settings.quizLevel")
    }

    static var quizLevelDescription: String {
      String(localized: "Settings.quizLevelDescription")
    }

    static var quizClock: String {
      String(localized: "Settings.quizClock")
    }

    static var quizClockDescription: String {
      String(localized: "Settings.quizClockDescription")
    }

    static var pronounGender: String {
      String(localized: "Settings.pronounGender")
    }

    static var pronounGenderDescription: String {
      String(localized: "Settings.pronounGenderDescription")
    }

    static var reviewCardSuppression: String {
      String(localized: "Settings.reviewCardSuppression")
    }

    static var reviewCardSuppressionDescription: String {
      String(localized: "Settings.reviewCardSuppressionDescription")
    }

    static var practiceRecord: String {
      String(localized: "Settings.practiceRecord")
    }

    static var resetPractice: String {
      String(localized: "Settings.resetPractice")
    }

    static var resetPracticeDescription: String {
      String(localized: "Settings.resetPracticeDescription")
    }

    static var resetPracticeConfirmTitle: String {
      String(localized: "Settings.resetPracticeConfirmTitle")
    }

    static var resetPracticeConfirmMessage: String {
      String(localized: "Settings.resetPracticeConfirmMessage")
    }

    static var resetPracticeConfirm: String {
      String(localized: "Settings.resetPracticeConfirm")
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

  // Tip title/message are read from the `Tip` protocol's nonisolated requirements, so
  // these accessors are `nonisolated` despite the module's default main-actor isolation.
  enum TenseSecondName {
    static var participePassé: String {
      String(localized: "TenseSecondName.participePassé")
    }

    static var participePrésent: String {
      String(localized: "TenseSecondName.participePrésent")
    }

    static var radicalFutur: String {
      String(localized: "TenseSecondName.radicalFutur")
    }

    static var indicatifPrésent: String {
      String(localized: "TenseSecondName.indicatifPrésent")
    }

    static var passéSimple: String {
      String(localized: "TenseSecondName.passéSimple")
    }

    static var imparfait: String {
      String(localized: "TenseSecondName.imparfait")
    }

    static var futurSimple: String {
      String(localized: "TenseSecondName.futurSimple")
    }

    static var conditionnelPrésent: String {
      String(localized: "TenseSecondName.conditionnelPrésent")
    }

    static var subjonctifPrésent: String {
      String(localized: "TenseSecondName.subjonctifPrésent")
    }

    static var subjonctifImparfait: String {
      String(localized: "TenseSecondName.subjonctifImparfait")
    }

    static var impératif: String {
      String(localized: "TenseSecondName.impératif")
    }

    static var passéComposé: String {
      String(localized: "TenseSecondName.passéComposé")
    }

    static var plusQueParfait: String {
      String(localized: "TenseSecondName.plusQueParfait")
    }

    static var passéAntérieur: String {
      String(localized: "TenseSecondName.passéAntérieur")
    }

    static var passéSurcomposé: String {
      String(localized: "TenseSecondName.passéSurcomposé")
    }

    static var futurAntérieur: String {
      String(localized: "TenseSecondName.futurAntérieur")
    }

    static var conditionnelPassé: String {
      String(localized: "TenseSecondName.conditionnelPassé")
    }

    static var subjonctifPassé: String {
      String(localized: "TenseSecondName.subjonctifPassé")
    }

    static var subjonctifPlusQueParfait: String {
      String(localized: "TenseSecondName.subjonctifPlusQueParfait")
    }

    static var impératifPassé: String {
      String(localized: "TenseSecondName.impératifPassé")
    }
  }

  enum Tips {
    nonisolated static var tryQuizTitle: String {
      String(localized: "Tips.tryQuizTitle")
    }

    nonisolated static var tryQuizMessage: String {
      String(localized: "Tips.tryQuizMessage")
    }

    nonisolated static var exploreModelsTitle: String {
      String(localized: "Tips.exploreModelsTitle")
    }

    nonisolated static var exploreModelsMessage: String {
      String(localized: "Tips.exploreModelsMessage")
    }

    nonisolated static var changeLevelTitle: String {
      String(localized: "Tips.changeLevelTitle")
    }

    nonisolated static var changeLevelMessage: String {
      String(localized: "Tips.changeLevelMessage")
    }

    nonisolated static var playGameTitle: String {
      String(localized: "Tips.playGameTitle")
    }

    nonisolated static var playGameMessage: String {
      String(localized: "Tips.playGameMessage")
    }

    nonisolated static var scrollToBottomTitle: String {
      String(localized: "Tips.scrollToBottomTitle")
    }

    nonisolated static var scrollToBottomMessage: String {
      String(localized: "Tips.scrollToBottomMessage")
    }
  }

  enum Game {
    static var sectionTitle: String {
      String(localized: "Game.sectionTitle")
    }

    static var playGame: String {
      String(localized: "Game.playGame")
    }

    static var playGameDescription: String {
      String(localized: "Game.playGameDescription")
    }

    static var endGame: String {
      String(localized: "Game.endGame")
    }

    static var moveLeft: String {
      String(localized: "Game.moveLeft")
    }

    static var moveRight: String {
      String(localized: "Game.moveRight")
    }

    static func score(_ value: Int) -> String {
      String(localized: "Game.score", defaultValue: "Score: \(value)")
    }

    static func health(_ value: Int) -> String {
      String(localized: "Game.health", defaultValue: "Health: \(value)%")
    }

    static var gameOver: String {
      String(localized: "Game.gameOver")
    }

    static func finalScore(_ value: Int) -> String {
      String(localized: "Game.finalScore", defaultValue: "Final score: \(value)")
    }

    static func highScore(_ value: Int) -> String {
      String(localized: "Game.highScore", defaultValue: "High score: \(value)")
    }

    static var newHighScore: String {
      String(localized: "Game.newHighScore")
    }

    static var playAgain: String {
      String(localized: "Game.playAgain")
    }

    static var quit: String {
      String(localized: "Game.quit")
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

  enum QuizLevel {
    static var beginner: String {
      String(localized: "QuizLevel.beginner")
    }

    static var elementary: String {
      String(localized: "QuizLevel.elementary")
    }

    static var intermediate: String {
      String(localized: "QuizLevel.intermediate")
    }

    static var advanced: String {
      String(localized: "QuizLevel.advanced")
    }

    static func withLabel(_ name: String) -> String {
      String(localized: "QuizLevel.withLabel", defaultValue: "Level: \(name)")
    }
  }

  enum QuizClock {
    static var hide: String {
      String(localized: "QuizClock.hide")
    }

    static var show: String {
      String(localized: "QuizClock.show")
    }
  }

  enum ReviewCardSuppression {
    static var off: String {
      String(localized: "ReviewCardSuppression.off")
    }

    static var on: String {
      String(localized: "ReviewCardSuppression.on")
    }
  }

  enum ReviewCard {
    static var dismiss: String {
      String(localized: "ReviewCard.dismiss")
    }

    // Separate keys for one day and for several, as `VerbBrowseView.verbCount(count:)` explains.
    // English and French agree that two or more days are plural.
    static func caption(daysAgo: Int?, wasLookedUp: Bool) -> String {
      wasLookedUp ? lookedUp(daysAgo: daysAgo) : practiced(daysAgo: daysAgo)
    }

    static func lookedUp(daysAgo: Int?) -> String {
      guard let daysAgo, daysAgo > 0 else {
        return String(localized: "ReviewCard.lookedUpEarlier")
      }
      if daysAgo == 1 {
        return String(localized: "ReviewCard.lookedUpYesterday")
      }
      let formattedDays = daysAgo.formatted()
      return String(localized: "ReviewCard.lookedUpDaysAgo", defaultValue: "Looked up \(formattedDays) days ago")
    }

    static func practiced(daysAgo: Int?) -> String {
      guard let daysAgo, daysAgo > 0 else {
        return String(localized: "ReviewCard.practicedEarlier")
      }
      if daysAgo == 1 {
        return String(localized: "ReviewCard.practicedYesterday")
      }
      let formattedDays = daysAgo.formatted()
      return String(localized: "ReviewCard.practicedDaysAgo", defaultValue: "Practiced \(formattedDays) days ago")
    }

    static var openHint: String {
      String(localized: "ReviewCard.openHint")
    }

    static var prompt: String {
      String(localized: "ReviewCard.prompt")
    }
  }

  enum PracticeSession {
    static var heading: String {
      String(localized: "PracticeSession.heading")
    }

    static var review: String {
      String(localized: "PracticeSession.review")
    }

    static var mistakes: String {
      String(localized: "PracticeSession.mistakes")
    }

    static func reviewCount(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "PracticeSession.reviewCountSingular", defaultValue: "\(formattedCount) question due")
      } else {
        return String(localized: "PracticeSession.reviewCountPlural", defaultValue: "\(formattedCount) questions due")
      }
    }

    static func mistakesCount(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "PracticeSession.mistakesCountSingular", defaultValue: "\(formattedCount) question missed")
      } else {
        return String(localized: "PracticeSession.mistakesCountPlural", defaultValue: "\(formattedCount) questions missed")
      }
    }

    static func reviewNextDue(inDays days: Int) -> String {
      if days <= 1 {
        return String(localized: "PracticeSession.reviewNextDueTomorrow")
      }
      let formattedDays = days.formatted()
      return String(localized: "PracticeSession.reviewNextDueDays", defaultValue: "Nothing is due today. The next review is in \(formattedDays) days.")
    }

    static var reviewEmpty: String {
      String(localized: "PracticeSession.reviewEmpty")
    }

    static var mistakesEmpty: String {
      String(localized: "PracticeSession.mistakesEmpty")
    }

    static var reviewHint: String {
      String(localized: "PracticeSession.reviewHint")
    }

    static var mistakesHint: String {
      String(localized: "PracticeSession.mistakesHint")
    }
  }

  enum Choice {
    static var prompt: String {
      String(localized: "Choice.prompt")
    }

    static var yourChoice: String {
      String(localized: "Choice.yourChoice")
    }

    static var rightChoice: String {
      String(localized: "Choice.rightChoice")
    }

    static var correct: String {
      String(localized: "Choice.correct")
    }

    static func rightChoiceSentence(_ sentence: String) -> String {
      String(localized: "Choice.rightChoiceSentence", defaultValue: "The right choice: \(sentence)")
    }

    static var optionHint: String {
      String(localized: "Choice.optionHint")
    }

    static var reasonCompletedEvent: String {
      String(localized: "Choice.reasonCompletedEvent")
    }

    static var reasonPastDescription: String {
      String(localized: "Choice.reasonPastDescription")
    }

    static var reasonPastHabit: String {
      String(localized: "Choice.reasonPastHabit")
    }

    static var reasonActionInProgress: String {
      String(localized: "Choice.reasonActionInProgress")
    }

    static var reasonSiImparfait: String {
      String(localized: "Choice.reasonSiImparfait")
    }

    static var reasonConditionnelAfterSi: String {
      String(localized: "Choice.reasonConditionnelAfterSi")
    }

    static var reasonFuturAfterSiPresent: String {
      String(localized: "Choice.reasonFuturAfterSiPresent")
    }

    static var reasonPoliteRequest: String {
      String(localized: "Choice.reasonPoliteRequest")
    }

    static var reasonNecessity: String {
      String(localized: "Choice.reasonNecessity")
    }

    static var reasonWish: String {
      String(localized: "Choice.reasonWish")
    }

    static var reasonEmotion: String {
      String(localized: "Choice.reasonEmotion")
    }

    static var reasonConjunction: String {
      String(localized: "Choice.reasonConjunction")
    }

    static var reasonDoubt: String {
      String(localized: "Choice.reasonDoubt")
    }

    static var reasonCertainty: String {
      String(localized: "Choice.reasonCertainty")
    }

    static var reasonHope: String {
      String(localized: "Choice.reasonHope")
    }

    static var reasonSiPlusQueParfait: String {
      String(localized: "Choice.reasonSiPlusQueParfait")
    }

    static var reasonPasseSimpleInWriting: String {
      String(localized: "Choice.reasonPasseSimpleInWriting")
    }

    static var reasonPasseComposeInSpeech: String {
      String(localized: "Choice.reasonPasseComposeInSpeech")
    }
  }

  enum Sentences {
    static var title: String {
      String(localized: "Sentences.title")
    }

    static var description: String {
      String(localized: "Sentences.description")
    }

    static var empty: String {
      String(localized: "Sentences.empty")
    }

    static var startHint: String {
      String(localized: "Sentences.startHint")
    }

    static var draft: String {
      String(localized: "Sentences.draft")
    }

    static var sentenceWithColon: String {
      String(localized: "Sentences.sentenceWithColon")
    }
  }

  enum DailySession {
    static var title: String {
      String(localized: "DailySession.title")
    }

    static var description: String {
      String(localized: "DailySession.description")
    }

    static var startHint: String {
      String(localized: "DailySession.startHint")
    }

    static var another: String {
      String(localized: "DailySession.another")
    }

    static var anotherHint: String {
      String(localized: "DailySession.anotherHint")
    }

    static func streak(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailySession.streakSingular", defaultValue: "Streak: 1 day")
      } else {
        return String(localized: "DailySession.streakPlural", defaultValue: "Streak: \(formattedCount) days")
      }
    }

    static func streakDoneToday(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailySession.streakDoneTodaySingular", defaultValue: "Streak: 1 day. Done for today.")
      } else {
        return String(localized: "DailySession.streakDoneTodayPlural", defaultValue: "Streak: \(formattedCount) days. Done for today.")
      }
    }

    static func streakKeepGoing(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailySession.streakKeepGoingSingular", defaultValue: "Streak: 1 day. Today’s session keeps it going.")
      } else {
        return String(localized: "DailySession.streakKeepGoingPlural", defaultValue: "Streak: \(formattedCount) days. Today’s session keeps it going.")
      }
    }

    static func repairTwo(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailySession.repairTwoSingular", defaultValue: "You missed yesterday. Two sessions today keep your 1-day streak.")
      } else {
        return String(localized: "DailySession.repairTwoPlural", defaultValue: "You missed yesterday. Two sessions today keep your \(formattedCount)-day streak.")
      }
    }

    static func repairOne(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailySession.repairOneSingular", defaultValue: "One more session today keeps your 1-day streak.")
      } else {
        return String(localized: "DailySession.repairOnePlural", defaultValue: "One more session today keeps your \(formattedCount)-day streak.")
      }
    }
  }

  enum DailyChallenge {
    static var title: String {
      String(localized: "DailyChallenge.title")
    }

    static var description: String {
      String(localized: "DailyChallenge.description")
    }

    static func doneToday(_ points: String) -> String {
      String(localized: "DailyChallenge.doneToday", defaultValue: "Done today: \(points)")
    }

    static var share: String {
      String(localized: "DailyChallenge.share")
    }

    static var startHint: String {
      String(localized: "DailyChallenge.startHint")
    }

    static var shareHint: String {
      String(localized: "DailyChallenge.shareHint")
    }

    static func spokenResult(right: Int, secondTry: Int, count: Int, score: Int, maximum: Int) -> String {
      let formattedRight = right.formatted()
      let formattedSecondTry = secondTry.formatted()
      let formattedCount = count.formatted()
      let formattedScore = score.formatted()
      let formattedMaximum = maximum.formatted()
      return String(
        localized: "DailyChallenge.spokenResult",
        defaultValue: "Right on the first try: \(formattedRight) of \(formattedCount). On the second: \(formattedSecondTry). Score: \(formattedScore) of \(formattedMaximum)."
      )
    }

    static func shareText(date: String, level: String, tally: String, link: String, appStoreLink: String) -> String {
      String(
        localized: "DailyChallenge.shareText",
        defaultValue: "Conjuguer · Daily Challenge\n\(date) · \(level)\n\(tally)\n\nTake this challenge in Conjuguer:\n\(link)\n\nGet Conjuguer on the App Store:\n\(appStoreLink)"
      )
    }
  }

  enum DailyReminder {
    static var heading: String {
      String(localized: "DailyReminder.heading")
    }

    static var description: String {
      String(localized: "DailyReminder.description")
    }

    static var off: String {
      String(localized: "DailyReminder.off")
    }

    static var on: String {
      String(localized: "DailyReminder.on")
    }

    static var time: String {
      String(localized: "DailyReminder.time")
    }

    static var denied: String {
      String(localized: "DailyReminder.denied")
    }

    static var openSettings: String {
      String(localized: "DailyReminder.openSettings")
    }

    static var title: String {
      String(localized: "DailyReminder.title")
    }

    static var body: String {
      String(localized: "DailyReminder.body")
    }

    static func bodyDue(_ count: Int) -> String {
      let formattedCount = count.formatted()
      if count == 1 {
        return String(localized: "DailyReminder.bodyDueSingular", defaultValue: "Your daily session is ready, with 1 conjugation due for review.")
      } else {
        return String(localized: "DailyReminder.bodyDuePlural", defaultValue: "Your daily session is ready, with \(formattedCount) conjugations due for review.")
      }
    }
  }

  enum SpeedRound {
    static var title: String {
      String(localized: "SpeedRound.title")
    }

    static var description: String {
      String(localized: "SpeedRound.description")
    }

    static func descriptionWithBest(_ best: Int) -> String {
      String(localized: "SpeedRound.descriptionWithBest", defaultValue: "As many right answers as you can in 60 seconds, on forms you have mastered · Best: \(best)")
    }

    static func locked(needed: Int, mastered: Int) -> String {
      String(localized: "SpeedRound.locked", defaultValue: "Opens once you have mastered \(needed) forms, those whose next review is a week or more away. So far: \(mastered)")
    }

    static var startHint: String {
      String(localized: "SpeedRound.startHint")
    }

    static var again: String {
      String(localized: "SpeedRound.again")
    }

    static var againHint: String {
      String(localized: "SpeedRound.againHint")
    }

    static var resultsHeading: String {
      String(localized: "SpeedRound.resultsHeading")
    }

    static func rightAnswers(_ count: Int) -> String {
      String(localized: "SpeedRound.rightAnswers", defaultValue: "Right answers: \(count)")
    }

    static func timeLeft(_ time: String) -> String {
      String(localized: "SpeedRound.timeLeft", defaultValue: "Time left: \(time)")
    }

    static func secondsLeft(_ seconds: Int) -> String {
      String(localized: "SpeedRound.secondsLeft", defaultValue: "Seconds left: \(seconds)")
    }

    static var missedWithColon: String {
      String(localized: "SpeedRound.missedWithColon")
    }

    static var announceWarning: String {
      String(localized: "SpeedRound.announceWarning")
    }

    static func announceTimeUp(_ count: Int) -> String {
      String(localized: "SpeedRound.announceTimeUp", defaultValue: "Time is up. Right answers: \(count).")
    }

    static func best(_ best: Int) -> String {
      String(localized: "SpeedRound.best", defaultValue: "Your best: \(best)")
    }

    static var newBest: String {
      String(localized: "SpeedRound.newBest")
    }
  }

  enum Recognition {
    static var title: String {
      String(localized: "Recognition.title")
    }

    static var description: String {
      String(localized: "Recognition.description")
    }

    static var startHint: String {
      String(localized: "Recognition.startHint")
    }

    static var promptHeading: String {
      String(localized: "Recognition.promptHeading")
    }

    static var promptWithColon: String {
      String(localized: "Recognition.promptWithColon")
    }

    static var tenseHeading: String {
      String(localized: "Recognition.tenseHeading")
    }

    static var personHeading: String {
      String(localized: "Recognition.personHeading")
    }

    static var infinitive: String {
      String(localized: "Recognition.infinitive")
    }

    static var check: String {
      String(localized: "Recognition.check")
    }

    static var checkHint: String {
      String(localized: "Recognition.checkHint")
    }

    static var fieldHint: String {
      String(localized: "Recognition.fieldHint")
    }

    static var incomplete: String {
      String(localized: "Recognition.incomplete")
    }

    static var checkInfinitive: String {
      String(localized: "Recognition.checkInfinitive")
    }

    static var checkTense: String {
      String(localized: "Recognition.checkTense")
    }

    static var checkPerson: String {
      String(localized: "Recognition.checkPerson")
    }

    static var checkInfinitiveAndTense: String {
      String(localized: "Recognition.checkInfinitiveAndTense")
    }

    static var checkInfinitiveAndPerson: String {
      String(localized: "Recognition.checkInfinitiveAndPerson")
    }

    static var checkTenseAndPerson: String {
      String(localized: "Recognition.checkTenseAndPerson")
    }
  }

  enum VerbEssentials {
    static var title: String {
      String(localized: "VerbEssentials.title")
    }

    static var description: String {
      String(localized: "VerbEssentials.description")
    }

    static var startHint: String {
      String(localized: "VerbEssentials.startHint")
    }

    static var fiveMore: String {
      String(localized: "VerbEssentials.fiveMore")
    }

    static var fiveMoreHint: String {
      String(localized: "VerbEssentials.fiveMoreHint")
    }

    static var notYetAsked: String {
      String(localized: "VerbEssentials.notYetAsked")
    }

    static var right: String {
      String(localized: "VerbEssentials.right")
    }

    static var rightOnSecondTry: String {
      String(localized: "VerbEssentials.rightOnSecondTry")
    }

    static var wrong: String {
      String(localized: "VerbEssentials.wrong")
    }
  }

  enum Mastery {
    static var title: String {
      String(localized: "Mastery.title")
    }

    static func intro(_ level: String) -> String {
      String(localized: "Mastery.intro", defaultValue: "What your practice has made secure at your level, \(level). A form is mastered once its next review is a week or more away. A wrong answer starts it over.")
    }

    static var mastered: String {
      String(localized: "Mastery.mastered")
    }

    static var learning: String {
      String(localized: "Mastery.learning")
    }

    static var notPracticed: String {
      String(localized: "Mastery.notPracticed")
    }

    static var regular: String {
      String(localized: "Mastery.regular")
    }

    static var regularDescription: String {
      String(localized: "Mastery.regularDescription")
    }

    static var spellingChanges: String {
      String(localized: "Mastery.spellingChanges")
    }

    static var spellingChangesDescription: String {
      String(localized: "Mastery.spellingChangesDescription")
    }

    static var irregular: String {
      String(localized: "Mastery.irregular")
    }

    static func irregularDescription(_ count: Int) -> String {
      String(localized: "Mastery.irregularDescription", defaultValue: "The \(count) most used at your level, each with the conjugations your level asks.")
    }

    static func count(_ mastered: Int, of total: Int) -> String {
      String(localized: "Mastery.count", defaultValue: "\(mastered) of \(total)")
    }

    static func family(_ ending: String) -> String {
      String(localized: "Mastery.family", defaultValue: "\(ending) verbs")
    }

    static func familyWithÊtre(_ ending: String) -> String {
      String(localized: "Mastery.familyWithEtre", defaultValue: "\(ending) verbs with être")
    }

    static func hubSummary(masteredPatterns: Int, patterns: Int, masteredVerbs: Int, verbs: Int) -> String {
      String(localized: "Mastery.hubSummary", defaultValue: "Mastered: \(masteredPatterns) of \(patterns) patterns · \(masteredVerbs) of \(verbs) verbs")
    }

    static var hubHint: String {
      String(localized: "Mastery.hubHint")
    }
  }

  enum ModelPractice {
    static var title: String {
      String(localized: "ModelPractice.title")
    }

    static var hubDescription: String {
      String(localized: "ModelPractice.hubDescription")
    }

    static var hubHint: String {
      String(localized: "ModelPractice.hubHint")
    }

    static var listIntro: String {
      String(localized: "ModelPractice.listIntro")
    }

    static var heading: String {
      String(localized: "ModelPractice.heading")
    }

    static var descriptionEssentialsAll: String {
      String(localized: "ModelPractice.descriptionEssentialsAll")
    }

    static var descriptionEssentialsFrequent: String {
      String(localized: "ModelPractice.descriptionEssentialsFrequent")
    }

    static var known: String {
      String(localized: "ModelPractice.known")
    }

    static var alone: String {
      String(localized: "ModelPractice.alone")
    }

    static var mixed: String {
      String(localized: "ModelPractice.mixed")
    }

    static var mixedLocked: String {
      String(localized: "ModelPractice.mixedLocked")
    }

    static var singleVerb: String {
      String(localized: "ModelPractice.singleVerb")
    }

    static var base: String {
      String(localized: "ModelPractice.base")
    }

    static var anotherRound: String {
      String(localized: "ModelPractice.anotherRound")
    }

    static var anotherRoundHint: String {
      String(localized: "ModelPractice.anotherRoundHint")
    }

    static var aloneEssentialsHint: String {
      String(localized: "ModelPractice.aloneEssentialsHint")
    }

    static var aloneCellsHint: String {
      String(localized: "ModelPractice.aloneCellsHint")
    }

    static var mixedHint: String {
      String(localized: "ModelPractice.mixedHint")
    }

    static func descriptionCells(_ base: String) -> String {
      String(localized: "ModelPractice.descriptionCells", defaultValue: "Questions on the conjugations in which this model’s verbs depart from \(base), which their pages mark in red.")
    }

    static func fewMarkedCells(_ base: String) -> String {
      String(localized: "ModelPractice.fewMarkedCells", defaultValue: "This model departs from \(base) in too few conjugations for a practice of its own.")
    }

    static func mixedWith(_ models: String) -> String {
      String(localized: "ModelPractice.mixedWith", defaultValue: "Mixed adds verbs of the models you know: \(models)")
    }

    static func mixedTitle(_ title: String) -> String {
      String(localized: "ModelPractice.mixedTitle", defaultValue: "Mixed: \(title)")
    }
  }

  enum VerbCollection {
    static var heading: String {
      String(localized: "VerbCollection.heading")
    }

    static var lookedUp: String {
      String(localized: "VerbCollection.lookedUp")
    }

    static func progress(opened: Int, total: Int) -> String {
      let formattedOpened = opened.formatted()
      let formattedTotal = total.formatted()
      return String(localized: "VerbCollection.progress", defaultValue: "\(formattedOpened) of \(formattedTotal) looked up")
    }

    static func quizHint(questionCount: Int) -> String {
      let formattedCount = questionCount.formatted()
      return String(localized: "VerbCollection.quizHint", defaultValue: "Starts a \(formattedCount)-question quiz on these verbs.")
    }

    static func shareText(title: String, count: Int, sample: String, link: String, appStoreLink: String) -> String {
      let formattedCount = count.formatted()
      return String(
        localized: "VerbCollection.shareText",
        defaultValue: "\(title) (\(formattedCount)): \(sample)\n\nOpen it in Conjuguer:\n\(link)\n\nGet Conjuguer on the App Store:\n\(appStoreLink)"
      )
    }

    static var top100Title: String {
      String(localized: "VerbCollection.top100Title")
    }

    static var top100Description: String {
      String(localized: "VerbCollection.top100Description")
    }

    static var êtreTitle: String {
      String(localized: "VerbCollection.etreTitle")
    }

    static var êtreDescription: String {
      String(localized: "VerbCollection.etreDescription")
    }

    static var irregularFuturTitle: String {
      String(localized: "VerbCollection.irregularFuturTitle")
    }

    static var irregularFuturDescription: String {
      String(localized: "VerbCollection.irregularFuturDescription")
    }

    static var pronominalTitle: String {
      String(localized: "VerbCollection.pronominalTitle")
    }

    static var pronominalDescription: String {
      String(localized: "VerbCollection.pronominalDescription")
    }
  }

  enum CustomQuiz {
    static var segment: String {
      String(localized: "CustomQuiz.segment")
    }

    static var title: String {
      String(localized: "CustomQuiz.title")
    }

    static var tenses: String {
      String(localized: "CustomQuiz.tenses")
    }

    static var tensesFooter: String {
      String(localized: "CustomQuiz.tensesFooter")
    }

    static var verbs: String {
      String(localized: "CustomQuiz.verbs")
    }

    static var models: String {
      String(localized: "CustomQuiz.models")
    }

    static var byLevel: String {
      String(localized: "CustomQuiz.byLevel")
    }

    static func byLevel(_ value: String) -> String {
      String(localized: "CustomQuiz.byLevelValue", defaultValue: "Set by Your Level: \(value)")
    }

    static func levelVerbs(level: String, verbs: String) -> String {
      String(localized: "CustomQuiz.levelVerbs", defaultValue: "\(level) · \(verbs)")
    }

    static func band(_ count: String) -> String {
      String(localized: "CustomQuiz.band", defaultValue: "\(count) Most Frequent Verbs")
    }

    static func everyVerb(_ count: String) -> String {
      String(localized: "CustomQuiz.everyVerb", defaultValue: "All \(count) Verbs")
    }

    static var choose: String {
      String(localized: "CustomQuiz.choose")
    }

    static var change: String {
      String(localized: "CustomQuiz.change")
    }

    static var chooseHint: String {
      String(localized: "CustomQuiz.chooseHint")
    }

    static var emptyDescription: String {
      String(localized: "CustomQuiz.emptyDescription")
    }

    static var description: String {
      String(localized: "CustomQuiz.description")
    }

    static var nothingToAsk: String {
      String(localized: "CustomQuiz.nothingToAsk")
    }

    static func verbList(count: Int) -> String {
      let verbCount = L.VerbBrowseView.verbCount(count: count)
      return String(localized: "CustomQuiz.verbList", defaultValue: "Verb List · \(verbCount)")
    }
  }

  enum PracticeSet {
    static var title: String {
      String(localized: "PracticeSet.title")
    }

    static var description: String {
      String(localized: "PracticeSet.description")
    }

    static func byLevel(_ value: String) -> String {
      String(localized: "PracticeSet.byLevelValue", defaultValue: "Set by Level: \(value)")
    }

    static func summaryLine(label: String, value: String) -> String {
      String(localized: "PracticeSet.summaryLine", defaultValue: "\(label): \(value)")
    }

    static func moreVerbs(_ count: Int) -> String {
      String(localized: "PracticeSet.moreVerbs", defaultValue: "and \(count) more")
    }

    static var keep: String {
      String(localized: "PracticeSet.keep")
    }

    static var kept: String {
      String(localized: "PracticeSet.kept")
    }

    static var keepFooter: String {
      String(localized: "PracticeSet.keepFooter")
    }

    static var invalidTitle: String {
      String(localized: "PracticeSet.invalidTitle")
    }

    static var invalidDescription: String {
      String(localized: "PracticeSet.invalidDescription")
    }

    static var shareLink: String {
      String(localized: "PracticeSet.shareLink")
    }

    static var showQRCode: String {
      String(localized: "PracticeSet.showQRCode")
    }

    static var scanTitle: String {
      String(localized: "PracticeSet.scanTitle")
    }

    static var scanNote: String {
      String(localized: "PracticeSet.scanNote")
    }

    static var qrCodeLabel: String {
      String(localized: "PracticeSet.qrCodeLabel")
    }

    static var startHint: String {
      String(localized: "PracticeSet.startHint")
    }

    static var shareHint: String {
      String(localized: "PracticeSet.shareHint")
    }

    static func shareText(summary: String, link: String, appStoreLink: String) -> String {
      String(
        localized: "PracticeSet.shareText",
        defaultValue: "A Conjuguer practice set\n\(summary)\n\nOpen it in Conjuguer:\n\(link)\n\nGet Conjuguer on the App Store:\n\(appStoreLink)"
      )
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

    static var aiTitle: String {
      String(localized: "Onboarding.aiTitle")
    }

    static var aiBody: String {
      String(localized: "Onboarding.aiBody")
    }

    static var meetTutorButton: String {
      String(localized: "Onboarding.meetTutorButton")
    }
  }

  enum Tutor {
    static var heading: String {
      String(localized: "Tutor.heading")
    }

    static var description: String {
      String(localized: "Tutor.description")
    }

    static var getSampleQuery: String {
      String(localized: "Tutor.getSampleQuery")
    }

    static var getSampleQueryDescription: String {
      String(localized: "Tutor.getSampleQueryDescription")
    }

    static var poweredBy: String {
      String(localized: "Tutor.poweredBy")
    }

    static var inputPlaceholder: String {
      String(localized: "Tutor.inputPlaceholder")
    }

    static var send: String {
      String(localized: "Tutor.send")
    }

    static var unavailable: String {
      String(localized: "Tutor.unavailable")
    }

    static var unableToAnswer: String {
      String(localized: "Tutor.unableToAnswer")
    }

    static var reasonAppleIntelligenceOff: String {
      String(localized: "Tutor.reasonAppleIntelligenceOff")
    }

    static var reasonDeviceNotEligible: String {
      String(localized: "Tutor.reasonDeviceNotEligible")
    }

    static var reasonModelNotReady: String {
      String(localized: "Tutor.reasonModelNotReady")
    }

    static var reasonUnknown: String {
      String(localized: "Tutor.reasonUnknown")
    }
  }

  enum Lookup {
    static func verbWithGloss(infinitif: String, gloss: String) -> String {
      String(localized: "Lookup.verbWithGloss", defaultValue: "\(infinitif), “\(gloss)”")
    }

    /// "aller, “go”: va · est allé · ira", an infinitive's answer.
    static func keyConjugations(_ heading: String, conjugations: String) -> String {
      String(localized: "Lookup.keyConjugations", defaultValue: "\(heading): \(conjugations)")
    }

    /// `line` is a search row's: "vais : Indicatif Présent (je)".
    static func conjugation(_ line: String, infinitif: String) -> String {
      String(localized: "Lookup.conjugation", defaultValue: "\(line) of \(infinitif)")
    }

    static func otherMatchesOne(_ word: String, verb: String) -> String {
      String(localized: "Lookup.otherMatchesOne", defaultValue: "Conjuguer has no verb or conjugation spelled “\(word)”, but one verb matches: \(verb).")
    }

    static func otherMatchesMany(_ word: String, count: Int, verb: String) -> String {
      String(localized: "Lookup.otherMatchesMany", defaultValue: "Conjuguer has no verb or conjugation spelled “\(word)”, but \(count) verbs match. The first is \(verb).")
    }

    static func guessVerb(_ word: String, infinitif: String) -> String {
      String(localized: "Lookup.guessVerb", defaultValue: "Conjuguer has no verb or conjugation spelled “\(word)”. Perhaps you meant \(infinitif).")
    }

    static func guessConjugation(_ word: String, conjugation: String, infinitif: String) -> String {
      String(localized: "Lookup.guessConjugation", defaultValue: "Conjuguer has no verb or conjugation spelled “\(word)”. Perhaps you meant \(conjugation), of \(infinitif).")
    }

    static func nothing(_ word: String) -> String {
      String(localized: "Lookup.nothing", defaultValue: "Conjuguer has no verb or conjugation spelled “\(word)”.")
    }
  }
}
