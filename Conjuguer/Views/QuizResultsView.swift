//
//  QuizResultsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/7/21.
//

import SwiftUI

struct QuizResultsView: View {
  @Environment(World.self) private var world
  @Environment(Quiz.self) var quiz

  // As wide as an iPhone's, and no wider on an iPad.
  private static let tenMoreMaxWidth: CGFloat = 400

  var body: some View {
    VStack(alignment: .leading) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        Text(L.Navigation.results)
          .headingLabel()

        VStack(alignment: .leading, spacing: 0) {
          Text(isSpeedRound ? L.SpeedRound.resultsHeading : L.QuizView.scoreWithColon)
            .smallLabel()

          Text("\(isSpeedRound ? quiz.correctCount : quiz.score)")
            .font(scoreFont)
            .foregroundStyle(Color.customBlue)
            .numericText()
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .accessibilityIdentifier("results_score")

          if isSpeedRound {
            speedRoundBest
          }
        }
        .padding(.top, Layout.defaultSpacing)

        VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
          Text(L.ResultsView.correct(quiz.correctCount, of: quiz.sessionQuestionCount))

          if quiz.secondAttemptCount > 0 {
            Text(L.ResultsView.secondTry(quiz.secondAttemptCount))
              .foregroundStyle(Color.secondAttempt)
              .accessibilityIdentifier("results_second_try")
          }

          if quiz.reaskCount > 0 {
            Text(L.ResultsView.askedAgain(quiz.reaskCorrectCount, of: quiz.reaskCount))
              .accessibilityIdentifier("results_asked_again")
          }

          if quiz.scope.asksByLevel {
            Text(quiz.level.localizedNameWithLabel)
              .accessibilityIdentifier("results_level")
          }

          if quiz.showsClock, !isSpeedRound {
            Text(L.ResultsView.time(quiz.elapsedTime.timeString))
              .accessibilityIdentifier("results_time")
          }
        }
        .smallLabel()

        if isSpeedRound {
          Button {
            quiz.start(scope: .speedRound)
          } label: {
            Label(L.SpeedRound.again, systemImage: "bolt.fill")
              .buttonLabel()
              .frame(maxWidth: Self.tenMoreMaxWidth)
          }
          .funButton()
          .controlSize(.large)
          .frame(maxWidth: .infinity)
          .padding(.top, Layout.defaultSpacing)
          .accessibilityHint(L.SpeedRound.againHint)
          .accessibilityIdentifier("results_speed_round_again")
        } else if quiz.canContinue {
          Button {
            quiz.continueSession()
          } label: {
            Label(continueTitle, systemImage: "plus")
              .buttonLabel()
              .frame(maxWidth: Self.tenMoreMaxWidth)
          }
          .funButton()
          .controlSize(.large)
          .frame(maxWidth: .infinity)
          .padding(.top, Layout.defaultSpacing)
          .accessibilityHint(continueHint)
          .accessibilityIdentifier("results_ten_more")
        }
      }

      let examples = exampleOffers
      List(quiz.quizResults) { quizResult in
        QuizResultView(quizResult: quizResult, example: examples[quizResult.id])
          .listRowBackground(Color.customBackground)
          .listRowSeparatorTint(.customForeground)
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.leading, Layout.doubleDefaultSpacing)
    .padding(.trailing, Layout.doubleDefaultSpacing)
    .padding(.top, Layout.tripleDefaultSpacing)
    .recordsAppearance(as: "\(QuizResultsView.self)")
    .screenBackground()
  }

  private var isSpeedRound: Bool {
    quiz.scope.isSpeedRound
  }

  /// "New personal best!", or the best this round did not beat.
  @ViewBuilder
  private var speedRoundBest: some View {
    if quiz.isNewSpeedRoundBest {
      Label(L.SpeedRound.newBest, systemImage: "star.fill")
        .font(bodyEmphasisFont)
        .foregroundStyle(Color.customGreen)
        .accessibilityIdentifier("results_speed_round_new_best")
    } else if let best = quiz.speedRoundPreviousBest {
      Text(L.SpeedRound.best(best))
        .smallLabel()
        .accessibilityIdentifier("results_speed_round_best")
    }
  }

  private var exampleOffers: [UUID: Example] {
    var offers: [UUID: Example] = [:]
    for result in QuizResult.firstRightOfEachVerb(in: quiz.quizResults) {
      if let verb = result.verbKey.flatMap({ Verb.verbs[$0] }) {
        offers[result.id] = ExampleData.example(for: verb)
      }
    }
    return offers
  }

  /// A model's practice can ask fewer than five verbs or ten questions a round, so it offers
  /// another round rather than a count.
  private var continueTitle: String {
    if quiz.scope.modelPractice != nil {
      return L.ModelPractice.anotherRound
    }
    return quiz.scope.isVerbEssentials ? L.VerbEssentials.fiveMore : L.ResultsView.tenMore
  }

  private var continueHint: String {
    if quiz.scope.modelPractice != nil {
      return L.ModelPractice.anotherRoundHint
    }
    return quiz.scope.isVerbEssentials ? L.VerbEssentials.fiveMoreHint : L.ResultsView.tenMoreHint
  }
}
