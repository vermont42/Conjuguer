//
//  AnswerDiagnosisTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/23/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
@Suite(.serialized)
struct AnswerDiagnosisTests {
  private func diagnosis(_ key: String, _ tense: Tense, _ answer: String, gender: PronounGender = .feminine) throws -> AnswerDiagnosis? {
    let verb = try #require(Verb.verbs[key])
    let correctAnswers = try #require(Conjugator.conjugatedString(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters, pronounGender: gender))
    return AnswerDiagnosis.diagnose(proposedAnswer: answer, correctAnswers: correctAnswers, verb: verb, tense: tense, pronounGender: gender)
  }

  @Test(arguments: [
    ("aller", Tense.passéComposé(.firstSingular), "suis allé", AnswerDiagnosis.agreement(isFeminine: true, isPlural: false)),
    ("aller", .passéComposé(.firstPlural), "nous sommes allés", .agreement(isFeminine: true, isPlural: true)),
    ("souvenir", .passéComposé(.firstSingular), "je me suis souvenu", .agreement(isFeminine: true, isPlural: false)),
    ("partir", .plusQueParfait(.thirdPlural), "étaient partis", .agreement(isFeminine: true, isPlural: true)),
    ("parler", .passéComposé(.firstSingular), "j'ai parlée", .agreementWithAvoir),
    ("passer", .passéComposé(.firstSingular), "j'ai passée", .agreementWithAvoir),
    ("aller", .passéComposé(.firstSingular), "j'ai allé", .wrongAuxiliary(infinitif: "aller", expected: .être)),
    ("venir", .futurAntérieur(.thirdSingular), "aura venue", .wrongAuxiliary(infinitif: "venir", expected: .être)),
    ("manger", .passéComposé(.thirdSingular), "elle est mangée", .wrongAuxiliary(infinitif: "manger", expected: .avoir)),
    ("souvenir", .passéComposé(.firstSingular), "je m'ai souvenu", .pronominalAuxiliary),
    ("monter", .passéComposé(.thirdSingular), "a monté", .auxiliaryWithoutObject(infinitif: "monter")),
    ("sortir exit", .passéComposé(.firstSingular), "j'ai sorti", .auxiliaryWithoutObject(infinitif: "sortir")),
    ("aller", .passéComposé(.firstSingular), "allée", .missingAuxiliary),
    ("prendre", .passéComposé(.firstPlural), "pris", .missingAuxiliary),
    ("sortir exit", .indicatifPrésent(.thirdPlural), "sortissent", .otherEntry(given: "sortir (obtain)", asked: "sortir (exit)")),
    ("manger", .indicatifPrésent(.firstPlural), "nous mangons", .spellingChange(infinitif: "manger", .softG)),
    ("commencer", .imparfait(.thirdSingular), "commencait", .spellingChange(infinitif: "commencer", .cedilla)),
    ("appeler", .indicatifPrésent(.firstSingular), "j'appele", .spellingChange(infinitif: "appeler", .doubledConsonant("l"))),
    ("appeler", .futurSimple(.firstSingular), "appelerai", .spellingChange(infinitif: "appeler", .doubledConsonant("l"))),
    ("jeter", .subjonctifPrésent(.thirdPlural), "jetent", .spellingChange(infinitif: "jeter", .doubledConsonant("t"))),
    ("acheter", .indicatifPrésent(.firstSingular), "achete", .spellingChange(infinitif: "acheter", .graveForE)),
    ("céder", .indicatifPrésent(.thirdPlural), "cédent", .spellingChange(infinitif: "céder", .graveForEAcute)),
    ("employer", .indicatifPrésent(.firstSingular), "employe", .spellingChange(infinitif: "employer", .yToI)),
    ("venir", .futurSimple(.firstSingular), "je venirai", .futurStem(infinitif: "venir")),
    ("envoyer", .futurSimple(.firstSingular), "envoyerai", .futurStem(infinitif: "envoyer")),
    ("voir", .conditionnelPrésent(.firstPlural), "voirions", .futurStem(infinitif: "voir")),
    ("aller", .futurSimple(.thirdPlural), "alleront", .futurStem(infinitif: "aller")),
    ("faire", .indicatifPrésent(.secondPlural), "vous faisez", .vousTes(infinitif: "faire")),
    ("dire", .indicatifPrésent(.secondPlural), "disez", .vousTes(infinitif: "dire")),
    ("finir", .indicatifPrésent(.secondPlural), "finissons", .otherPerson(pronouns: ["nous"])),
    ("finir", .indicatifPrésent(.thirdSingular), "finis", .otherPerson(pronouns: ["je", "tu"])),
    ("venir", .passéSimple(.thirdSingular), "venait", .otherTense(.imparfait(.thirdSingular), pronouns: [])),
    ("venir", .passéSimple(.firstPlural), "venait", .otherTense(.imparfait(.thirdSingular), pronouns: ["elle"])),
    ("parler", .passéComposé(.firstSingular), "j'avais parlé", .otherTense(.plusQueParfait(.firstSingular), pronouns: [])),
    ("parler", .participePassé, "parle", .otherTense(.indicatifPrésent(.firstSingular), pronouns: ["je", "elle"])),
    ("prendre", .participePassé, "prendu", .regularForm(infinitif: "prendre", exemplar: "rendre")),
    ("prendre", .indicatifPrésent(.thirdPlural), "ils prendent", .regularForm(infinitif: "prendre", exemplar: "rendre")),
    ("ouvrir", .passéComposé(.thirdSingular), "a ouvri", .regularForm(infinitif: "ouvrir", exemplar: "finir")),
    ("aller", .indicatifPrésent(.thirdPlural), "allent", .regularForm(infinitif: "aller", exemplar: "parler")),
    ("finir", .indicatifPrésent(.thirdPlural), "finent", .otherGroup(infinitif: "finir", exemplar: "parler")),
    ("rendre", .passéSimple(.firstPlural), "rendâmes", .otherGroup(infinitif: "rendre", exemplar: "parler")),
    ("mettre", .passéComposé(.thirdSingular), "a metté", .otherGroup(infinitif: "mettre", exemplar: "parler"))
  ])
  func namesTheError(key: String, tense: Tense, answer: String, expected: AnswerDiagnosis) throws {
    #expect(try diagnosis(key, tense, answer) == expected)
  }

  @Test func theAgreementFollowsTheGenderSetting() throws {
    #expect(try diagnosis("aller", .passéComposé(.firstSingular), "suis allée", gender: .masculine) == .agreement(isFeminine: false, isPlural: false))
    #expect(try diagnosis("aller", .passéComposé(.firstPlural), "sommes allées", gender: .masculine) == .agreement(isFeminine: false, isPlural: true))
    #expect(try diagnosis("aller", .passéComposé(.firstPlural), "sommes allées", gender: .both) == .agreement(isFeminine: false, isPlural: true))
  }

  // Right answers, a slip, nonsense, and errors for which no line would be certain: demeurer
  // and accourir take either auxiliary in some sense, and il prena belongs to no construction.
  @Test(arguments: [
    ("parler", Tense.indicatifPrésent(.firstSingular), "je parle"),
    ("passer", .passéComposé(.firstSingular), "j'ai passé"),
    ("connaître", .indicatifPrésent(.thirdSingular), "il connait"),
    ("aller", .passéComposé(.firstSingular), "je suis allée"),
    ("parler", .indicatifPrésent(.firstSingular), "parlle"),
    ("être", .indicatifPrésent(.secondPlural), "etes"),
    ("parler", .indicatifPrésent(.firstSingular), "xyz"),
    ("parler", .indicatifPrésent(.firstSingular), ""),
    ("demeurer", .passéComposé(.thirdSingular), "a demeuré"),
    ("accourir", .passéComposé(.thirdSingular), "est accourue"),
    ("prendre", .passéSimple(.thirdSingular), "prena")
  ])
  func saysNothingUncertain(key: String, tense: Tense, answer: String) throws {
    #expect(try diagnosis(key, tense, answer) == nil)
  }

  @Test func theLinesReadInEnglish() {
    #expect(AnswerDiagnosis.agreement(isFeminine: true, isPlural: true).line == "With être, the participle agrees with the subject, here feminine plural.")
    #expect(AnswerDiagnosis.agreementWithAvoir.line == "With avoir, the participle does not agree with the subject.")
    #expect(AnswerDiagnosis.wrongAuxiliary(infinitif: "aller", expected: .être).line == "Aller takes être, not avoir, in its compound tenses.")
    #expect(AnswerDiagnosis.wrongAuxiliary(infinitif: "manger", expected: .avoir).line == "Manger takes avoir, not être, in its compound tenses.")
    #expect(AnswerDiagnosis.auxiliaryWithoutObject(infinitif: "monter").line == "Without a direct object, monter takes être, not avoir.")
    #expect(AnswerDiagnosis.otherEntry(given: "sortir (obtain)", asked: "sortir (exit)").line == "That is sortir (obtain). The question asks sortir (exit).")
    #expect(AnswerDiagnosis.spellingChange(infinitif: "appeler", .doubledConsonant("l")).line == "Before a silent e, appeler doubles its l.")
    #expect(AnswerDiagnosis.spellingChange(infinitif: "céder", .graveForEAcute).line == "Before a silent e, céder changes é to è.")
    #expect(AnswerDiagnosis.futurStem(infinitif: "envoyer").line == "Envoyer has an irregular futur stem, shared by the conditionnel.")
    #expect(AnswerDiagnosis.vousTes(infinitif: "faire").line == "With vous, faire ends in -tes in the présent.")
    #expect(AnswerDiagnosis.otherPerson(pronouns: ["je", "tu"]).line == "That is the conjugation for je and tu.")
    #expect(AnswerDiagnosis.otherTense(.imparfait(.thirdSingular), pronouns: []).line == "That is the imparfait.")
    #expect(AnswerDiagnosis.otherTense(.passéSimple(.thirdSingular), pronouns: ["il"]).line == "That is the passé simple, for il.")
    #expect(AnswerDiagnosis.regularForm(infinitif: "prendre", exemplar: "rendre").line == "That is the regular form, as rendre has it. Prendre is irregular here.")
    #expect(AnswerDiagnosis.otherGroup(infinitif: "finir", exemplar: "parler").line == "That is how verbs like parler are conjugated, and finir is not one.")
  }

  private func startedQuiz() -> Quiz {
    Current.settings.quizLevel = .elementary
    let quiz = Quiz(gameCenter: GameCenterSpy(), seed: 1)
    quiz.start()
    return quiz
  }

  private func correctAnswer(for question: QuizQuestion) -> String {
    let conjugated = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
    return (conjugated.components(separatedBy: Tense.alternateConjugationSeparator).first ?? conjugated).lowercased()
  }

  private func diagnosis(of answer: String, for question: QuizQuestion) -> AnswerDiagnosis? {
    let correctAnswers = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: question.tense, extraLetters: question.verb.extraLetters) ?? ""
    return AnswerDiagnosis.diagnose(proposedAnswer: answer, correctAnswers: correctAnswers, verb: question.verb, tense: question.tense, pronounGender: Current.settings.pronounGender)
  }

  private func diagnosableAnswer(for question: QuizQuestion) throws -> String {
    for tense in TenseTable.allTenses {
      let conjugation = Conjugator.conjugatedString(infinitif: question.verb.infinitif, tense: tense, extraLetters: question.verb.extraLetters) ?? ""
      let answer = (conjugation.components(separatedBy: Tense.alternateConjugationSeparator).first ?? "").lowercased()
      if !answer.isEmpty, diagnosis(of: answer, for: question) != nil {
        return answer
      }
    }
    throw NoDiagnosableAnswer()
  }

  private struct NoDiagnosableAnswer: Error {}

  @Test func aDiagnosedErrorWaitsOnItsQuestion() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.currentQuestion)
    let answer = try diagnosableAnswer(for: question)
    let expected = try #require(diagnosis(of: answer, for: question))
    quiz.process(proposedAnswer: answer)

    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.firstAttemptDiagnosis == expected)
    #expect(quiz.secondAttemptPrompt == expected.line + " " + L.QuizView.tryOnceMore)
    #expect(quiz.correction == nil)
    #expect(quiz.quizResults.isEmpty)
    #expect(quiz.currentQuestionIndex == 0)
    quiz.quit()
  }

  @Test func aRightRepairEarnsHalfPoints() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.currentQuestion)
    quiz.process(proposedAnswer: try diagnosableAnswer(for: question))
    quiz.process(proposedAnswer: correctAnswer(for: question))

    #expect(quiz.score == ConjugationResult.secondAttemptMatch.score)
    #expect(quiz.secondAttemptCount == 1)
    #expect(quiz.quizResults.last?.conjugationResult == .secondAttemptMatch)
    #expect(quiz.firstAttemptDiagnosis == nil)
    #expect(quiz.currentQuestionIndex == 1)
    quiz.quit()
  }

  @Test func aWrongRepairShowsTheCorrectionWithItsOwnDiagnosis() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.currentQuestion)
    quiz.process(proposedAnswer: try diagnosableAnswer(for: question))
    quiz.process(proposedAnswer: "x")

    let correction = try #require(quiz.correction)
    #expect(correction.difference.given == "x")
    #expect(correction.diagnosis == nil)
    #expect(!quiz.isAwaitingSecondAttempt)
    #expect(quiz.quizResults.last?.conjugationResult == .noMatch)
    quiz.quit()
  }

  @Test func aDiagnosedErrorOnTheLastAttemptIsShownInTheCorrection() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.currentQuestion)
    let answer = try diagnosableAnswer(for: question)
    quiz.process(proposedAnswer: answer)
    quiz.process(proposedAnswer: answer)

    let correction = try #require(quiz.correction)
    #expect(correction.diagnosis == diagnosis(of: answer, for: question))
    #expect(correction.diagnosis != nil)
    quiz.quit()
  }

  /// One more attempt at most, whatever earned it: a slip after a diagnosis is not given a third.
  @Test func aSlipAfterADiagnosisGoesToTheCorrection() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.currentQuestion)
    quiz.process(proposedAnswer: try diagnosableAnswer(for: question))
    quiz.process(proposedAnswer: correctAnswer(for: question) + "q")

    #expect(quiz.correction != nil)
    #expect(quiz.quizResults.last?.conjugationResult == .noMatch)
    quiz.quit()
  }

  @Test func aSlipSaysAlmost() throws {
    let quiz = startedQuiz()
    let question = try #require(quiz.questions.first { $0.choice == nil && correctAnswer(for: $0).filter(\.isLetter).count >= AnswerSlip.minimumLetterCount })
    while quiz.currentQuestion.map({ correctAnswer(for: $0) }) != correctAnswer(for: question) {
      if quiz.currentQuestion?.choice != nil {
        quiz.skipChoice()
        continue
      }
      quiz.process(proposedAnswer: correctAnswer(for: try #require(quiz.currentQuestion)))
    }
    quiz.process(proposedAnswer: correctAnswer(for: question) + "q")

    #expect(quiz.isAwaitingSecondAttempt)
    #expect(quiz.firstAttemptDiagnosis == nil)
    #expect(quiz.secondAttemptPrompt == L.QuizView.almost)
    quiz.quit()
  }
}
