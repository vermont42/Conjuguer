//
//  Analytics.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/18.
//  Copyright © 2018 Josh Adams. All rights reserved.
//

import Foundation

enum ParameterKey: String {
  case viewName
  case level
  case lastQuestionIndex
  case duration
  case questionCount
  case source
  case outcome
  case queryLength
  case resultCount
  case matchKind
  case resultPosition
  case deepestSection
  case dwell
  case starred
  case collection
  case customChoice
  case method
  case enabled
  case streak
}

enum AnalyticsName: String {
  case viewAppeared
  case quizStart
  case quizQuit
  case quizCompletion
  case quizAbandon
  case gameCenterAuthSucceeded
  case gameCenterAuthFailed
  case tapPlayGame
  case tapShowOnboarding
  case finishSearch
  case leaveVerbView
  case tapTenseArticle
  case tapShareVerb
  case tapStarVerb
  case viewReviewCard
  case tapRevealReviewCard
  case viewCollection
  case tapShareCollection
  case tapSharePracticeSet
  case viewPracticeSet
  case tapKeepPracticeSet
  case tapResetPractice
  case tapViewLeaderboard
  case tapViewAchievements
  case tapDailyReminder
  case tapShareChallenge
}

/// How the learner reached a verb page or began a quiz. One vocabulary serves every signal that
/// carries `source`, so that a page and a quiz reached from the same surface carry the same
/// value, and the names match Konjugieren's and Conjugar's so that the three apps can be read
/// side by side. `docs/feature_architecture.md` § Analytics says which signals send which values.
enum AnalyticsSource: String, CaseIterable {
  case browse
  case challenge
  case challengeLink
  case challengeWidget
  case control
  case custom
  case daily
  case deeplink
  case infoLink
  case list
  case lookup
  case mistakes
  case modelAlone
  case modelMixed
  case modelPage
  case myVerbs
  case qrCode
  case quickAction
  case quizCorrection
  case recent
  case recognition
  case related
  case reminder
  case resume
  case review
  case reviewCard
  case search
  case searchGuess
  case sentences
  case sharedLink
  case shortcut
  case speedRound
  case spotlight
  case tab
  case verbEssentials
  case verbPage
  case widget
}

enum SearchOutcome: String, CaseIterable {
  case abandoned
  case noResult
  case opened
}

enum SearchMatchKind: String, CaseIterable {
  case conjugation
  case exactFoldedInfinitive
  case exactInfinitive
  case foldedConjugation
  case foldedInfinitivePrefix
  case foldedInfinitiveSubstring
  case glossMeaning
  case glossSubstring
  case guess
  case infinitivePrefix
  case infinitiveSubstring
  case none
  case wholeWordGloss
}

// Semantic ordering: top of the verb page to bottom.
enum VerbPageSection: String, CaseIterable, Comparable {
  case header
  case simple
  case compound
  case etymology
  case example
  case related

  nonisolated static func < (lhs: VerbPageSection, rhs: VerbPageSection) -> Bool {
    let order = allCases
    return (order.firstIndex(of: lhs) ?? 0) < (order.firstIndex(of: rhs) ?? 0)
  }
}

/// Coarse bands for counts and durations. The privacy policy promises that nothing typed is
/// sent, and an exact query length or dwell time would come closer to identifying what was
/// typed or read than a band does.
enum AnalyticsBand {
  nonisolated static let noPosition = "none"

  nonisolated static func queryLength(_ length: Int) -> String {
    switch length {
    case ...2:
      return "1-2"
    case 3...5:
      return "3-5"
    case 6...9:
      return "6-9"
    default:
      return "10+"
    }
  }

  nonisolated static func resultCount(_ count: Int) -> String {
    switch count {
    case ...0:
      return "0"
    case 1:
      return "1"
    case 2...10:
      return "2-10"
    default:
      return "11+"
    }
  }

  /// `index` counts from zero, as the list does. The band counts from one, as a reader does.
  nonisolated static func resultPosition(_ index: Int?) -> String {
    guard let index else {
      return noPosition
    }
    switch index {
    case ...0:
      return "1"
    case 1...4:
      return "2-5"
    default:
      return "6+"
    }
  }

  /// The time from a quiz's start to its quit or its results. Under three seconds is exploration,
  /// and over forty a struggle.
  nonisolated static func quizDuration(_ seconds: TimeInterval) -> String {
    switch seconds {
    case ..<3:
      return "0-3s"
    case ..<15:
      return "3-15s"
    case ..<40:
      return "15-40s"
    case ..<120:
      return "40s-2m"
    default:
      return "2m+"
    }
  }

  /// The daily sessions finished on consecutive days, a repair's bridged day not counted.
  nonisolated static func streak(_ length: Int) -> String {
    switch length {
    case ...1:
      return "1"
    case 2...6:
      return "2-6"
    case 7...29:
      return "7-29"
    default:
      return "30+"
    }
  }

  nonisolated static func dwell(_ seconds: TimeInterval) -> String {
    switch seconds {
    case ..<5:
      return "0-5s"
    case ..<15:
      return "5-15s"
    case ..<60:
      return "15-60s"
    default:
      return "60s+"
    }
  }
}

protocol Analytics {
  func initialize(appID: String)
  func signal(name: AnalyticsName, parameters: [String: String])
}

extension Analytics {
  func signal(name: AnalyticsName) {
    signal(name: name, parameters: [:])
  }
}
