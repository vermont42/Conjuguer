//
//  QuizWidgetView.swift
//  ConjuguerWidget
//

import AppIntents
import SwiftUI
import WidgetKit

struct QuizWidgetView: View {
  let entry: QuizEntry

  private var quiz: WidgetQuizQuestion {
    entry.snapshot.quizQuestion
  }

  var body: some View {
    if entry.isAnswered {
      answeredView
    } else {
      questionView
    }
  }

  private var questionView: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(quiz.tenseDisplay)
        .font(.system(size: 9))
        .foregroundStyle(.secondary)
        .lineLimit(1)

      HStack(spacing: 3) {
        Text(quiz.infinitif)
          .font(.caption)
          .fontWeight(.bold)
        if let pronoun = quiz.pronoun {
          Text(verbatim: "(\(pronoun))")
            .font(.system(size: 10))
            .foregroundStyle(.secondary)
        }
      }
      .lineLimit(1)
      .minimumScaleFactor(0.4)

      Spacer(minLength: 0)

      VStack(spacing: 2) {
        ForEach(shuffledAnswers, id: \.self) { answer in
          answerButton(answer: answer)
        }
      }
    }
    .widgetURL(WidgetDeeplink.verb(quiz.infinitif))
  }

  private var answeredView: some View {
    VStack(spacing: 8) {
      Image(systemName: entry.wasCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.largeTitle)
        .foregroundStyle(entry.wasCorrect ? .green : .red)

      Text(entry.wasCorrect ? WidgetL.QuizWidget.correct : WidgetL.QuizWidget.incorrect)
        .font(.headline)

      if !entry.wasCorrect {
        Text(mixedCase: quiz.correctAnswer)
          .font(.subheadline)
          .fontWeight(.semibold)
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .widgetURL(WidgetDeeplink.verb(quiz.infinitif))
  }

  private func answerButton(answer: String) -> some View {
    Button(intent: AnswerQuizIntent(selectedAnswer: answer, questionID: quiz.questionID)) {
      Text(mixedCase: answer)
        .font(.caption2)
        .fontWeight(.medium)
        .lineLimit(1)
        .minimumScaleFactor(0.4)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(.fill.quaternary, in: Capsule())
    }
    .buttonStyle(.plain)
  }

  // Deterministic shuffle keyed on the question ID so the layout is stable across reloads.
  private var shuffledAnswers: [String] {
    var answers = quiz.wrongAnswers
    answers.append(quiz.correctAnswer)
    var hasher = Hasher()
    hasher.combine(quiz.questionID)
    let seed = hasher.finalize()
    var rng = SeededRNG(seed: UInt64(bitPattern: Int64(seed)))
    answers.shuffle(using: &rng)
    return answers
  }
}

private struct SeededRNG: RandomNumberGenerator {
  var state: UInt64

  init(seed: UInt64) {
    state = seed
  }

  mutating func next() -> UInt64 {
    state &+= 0x9E37_79B9_7F4A_7C15
    var z = state
    z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
    z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
    return z ^ (z >> 31)
  }
}
