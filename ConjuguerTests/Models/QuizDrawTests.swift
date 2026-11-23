//
//  QuizDrawTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct QuizDrawTests {
  private static let seeds: ClosedRange<UInt64> = 1 ... 120
  private static var quizzesByLevel: [QuizLevel: [[QuizQuestion]]] = [:]

  private func quizzes(at level: QuizLevel) -> [[QuizQuestion]] {
    if let quizzes = Self.quizzesByLevel[level] {
      return quizzes
    }
    Current.settings.quizLevel = level
    defer {
      Current.settings.quizLevel = .elementary
    }
    let quizzes = Self.seeds.map { seed in
      let quiz = Quiz(gameCenter: GameCenterSpy(), seed: seed)
      quiz.start()
      defer {
        quiz.quit()
      }
      return quiz.questions
    }
    Self.quizzesByLevel[level] = quizzes
    return quizzes
  }

  private func verb(_ infinitif: String) throws -> Verb {
    try #require(Verb.verbs[infinitif])
  }

  @Test func eachLevelHasItsBand() {
    #expect(QuizLevel.allCases.map(\.band) == [.top100, .top300, .top1000, nil])
    #expect(QuizLevel.advanced.verbs.count == Verb.verbs.count)
  }

  @Test(arguments: QuizLevel.allCases)
  func theDefaultQuizAsksOnlyTheLevelsBand(level: QuizLevel) {
    let limit = level.band?.rankLimit ?? Int.max
    for quiz in quizzes(at: level) {
      #expect(quiz.count == Quiz.questionCount)
      for question in quiz {
        #expect(question.verb.frequency <= limit, "\(question.verb.infinitif) at \(level)")
      }
    }
  }

  @Test func advancedReachesPastTheMostFrequentVerbs() {
    let ranks = quizzes(at: .advanced).flatMap { $0.map(\.verb.frequency) }
    #expect(ranks.contains { $0 > FrequencyBand.top1000.rankLimit })
  }

  @Test(arguments: QuizLevel.allCases)
  func halfOfEachQuizIsIrregular(level: QuizLevel) {
    for quiz in quizzes(at: level) {
      let irregular = quiz.filter { VerbDraw.isIrregular($0.verb) }.count
      #expect(irregular == quiz.count / QuizDraw.irregularShareDivisor, "\(level): \(irregular)")
    }
  }

  @Test(arguments: QuizLevel.allCases)
  func eachQuizAsksTheCoreVerbs(level: QuizLevel) {
    for quiz in quizzes(at: level) {
      let core = quiz.filter { QuizDraw.isCore($0.verb) }.count
      #expect(core >= QuizDraw.minimumCoreQuestions, "\(level): \(core)")
    }
  }

  @Test(arguments: [QuizLevel.intermediate, .advanced])
  func aLevelReachingPastTheFrequentDerivativesAsksOneToThreeRareOnes(level: QuizLevel) {
    var counts: Set<Int> = []
    for quiz in quizzes(at: level) {
      let rare = quiz.filter { QuizDraw.isRareDerivative($0.verb) }.count
      #expect(QuizDraw.rareDerivativeRange.contains(rare), "\(level): \(rare)")
      counts.insert(rare)
    }
    #expect(counts == Set(QuizDraw.rareDerivativeRange))
  }

  @Test(arguments: [QuizLevel.beginner, .elementary])
  func aLevelWithinTheFrequentDerivativesAsksAtLeastOne(level: QuizLevel) {
    for quiz in quizzes(at: level) {
      #expect(quiz.contains { QuizDraw.isDerivative($0.verb) }, "\(level)")
      #expect(!quiz.contains { QuizDraw.isRareDerivative($0.verb) }, "\(level)")
    }
  }

  // Être, avoir, and aller fill a pool of their own, and the band's few -ir verbs another, so a
  // quiz asks some verbs twice, but most once.
  @Test(arguments: QuizLevel.allCases)
  func aQuizAsksMostVerbsOnce(level: QuizLevel) {
    for quiz in quizzes(at: level) {
      let distinct = Set(quiz.map(\.verb.id)).count
      #expect(distinct >= quiz.count * 2 / 3, "\(level): \(distinct)")
    }
  }

  // A pool that holds only a verb or two for some role and share would ask them in quiz after
  // quiz. The core verbs recur by design, and so do the band's few regular -ir verbs: at Beginner
  // most often, and at Elementary each in about 2% of questions, under the cap of one in forty.
  @Test(arguments: [QuizLevel.elementary, .intermediate, .advanced])
  func noVerbOutsideTheCoreDominatesALevel(level: QuizLevel) {
    let questions = quizzes(at: level).joined().filter { !QuizDraw.isCore($0.verb) }
    let counts = Dictionary(grouping: questions, by: \.verb.id).mapValues(\.count)
    let (id, count) = counts.max { $0.value < $1.value } ?? ("", 0)
    #expect(count * 40 <= questions.count, "\(level): \(id) \(count) of \(questions.count)")
  }

  @Test func thePoolsReadTheData() throws {
    let cases: [(pool: QuizVerbPool, admitted: [String], refused: [String])] = [
      (.regularEr, ["parler", "manger", "appeler", "envoyer"], ["aller", "finir", "rendre"]),
      (.regularIr, ["finir", "choisir"], ["partir", "venir", "parler"]),
      (.regularRe, ["rendre", "attendre", "perdre"], ["prendre", "mettre", "finir"]),
      (.bigThree, ["être", "avoir", "aller"], ["faire"]),
      (.indicatifPrésentStemChanger, ["venir", "partir", "faire", "pouvoir", "appeler", "manger"], ["parler", "finir", "rendre", "être"]),
      (.êtreAuxiliary, ["aller", "venir", "rester", "tomber"], ["parler", "souvenir", "avoir"]),
      (.irregularParticipePassé, ["être", "avoir", "venir", "prendre", "mettre", "voir", "ouvrir"], ["parler", "finir", "vendre", "partir", "sentir", "fiche", "maudire"]),
      (.regularRadicalFutur, ["parler", "finir", "rendre", "prendre"], ["aller", "venir", "appeler", "voir"]),
      (.irregularRadicalFutur, ["aller", "être", "faire", "venir", "appeler", "envoyer"], ["parler", "finir", "dire"])
    ]
    for (pool, admitted, refused) in cases {
      for infinitif in admitted {
        #expect(try pool.admits(verb(infinitif)), "\(pool) should admit \(infinitif)")
      }
      for infinitif in refused {
        #expect(try !pool.admits(verb(infinitif)), "\(pool) should refuse \(infinitif)")
      }
    }
  }

  @Test func theDefaultQuizNeverAsksSortirToObtain() throws {
    let obtain = try #require(Verb.verbs.values.first { $0.dictionaryKey == "sortir obtain" })
    #expect(QuizDraw.excludedEntries.contains(obtain.dictionaryKey))
    #expect(obtain.isIn(.top100))
    for level in QuizLevel.allCases {
      #expect(!quizzes(at: level).joined().contains { $0.verb.dictionaryKey == obtain.dictionaryKey }, "\(level)")
    }
  }

  @Test func theCoreVerbsAreIrregularAndAmongTheMostFrequent() throws {
    for infinitif in QuizDraw.coreInfinitifs {
      let core = try verb(infinitif)
      #expect(VerbDraw.isIrregular(core), "\(infinitif)")
      #expect(core.isIn(.top100), "\(infinitif)")
    }
  }

  @Test func aDerivativeIsRareOutsideTheFrequentBand() throws {
    #expect(try QuizDraw.isDerivative(verb("revenir")))
    #expect(try !QuizDraw.isRareDerivative(verb("revenir")))
    #expect(try !QuizDraw.isDerivative(verb("venir")))
    let redécouvrir = try verb("redécouvrir")
    #expect(!redécouvrir.isIn(QuizDraw.frequentDerivativeBand))
    #expect(QuizDraw.isRareDerivative(redécouvrir))
  }

  @Test func aScopedQuizIgnoresTheBandAndTheShare() throws {
    Current.settings.quizLevel = .beginner
    defer {
      Current.settings.quizLevel = .elementary
    }
    let verbs = try [verb("parler"), verb("redonner")]
    let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 5)
    quiz.start(scope: .myVerbs(verbs))
    defer {
      quiz.quit()
    }
    #expect(quiz.questions.count == Quiz.questionCount)
    #expect(Set(quiz.questions.map(\.verb.infinitif)) == ["parler", "redonner"])
    #expect(!quiz.questions.contains { VerbDraw.isIrregular($0.verb) })
  }
}
