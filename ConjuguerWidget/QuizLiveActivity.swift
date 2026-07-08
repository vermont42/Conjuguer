//
//  QuizLiveActivity.swift
//  ConjuguerWidget
//

import ActivityKit
import SwiftUI
import WidgetKit

struct QuizLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: QuizActivityAttributes.self) { context in
      QuizLockScreenView(context: context)
    } dynamicIsland: { context in
      DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label {
            Text(verbatim: "\(context.state.currentQuestion)/\(context.attributes.totalQuestions)")
          } icon: {
            Image(systemName: "list.number")
          }
          .font(.headline)
        }
        DynamicIslandExpandedRegion(.trailing) {
          Label {
            Text(verbatim: "\(context.state.score)")
          } icon: {
            Image(systemName: "star.fill")
          }
          .font(.headline)
        }
        DynamicIslandExpandedRegion(.center) {
          QuizElapsedText(state: context.state)
            .font(.title2)
            .monospacedDigit()
        }
        DynamicIslandExpandedRegion(.bottom) {
          ProgressView(
            value: Double(context.state.currentQuestion),
            total: Double(context.attributes.totalQuestions)
          )
          .tint(.blue)
        }
      } compactLeading: {
        Text(verbatim: "\(context.state.currentQuestion)/\(context.attributes.totalQuestions)")
          .font(.caption)
          .monospacedDigit()
      } compactTrailing: {
        Text(verbatim: "\(context.state.score)")
          .font(.caption)
          .monospacedDigit()
      } minimal: {
        Text(verbatim: "\(context.state.currentQuestion)")
          .font(.caption)
          .monospacedDigit()
      }
    }
  }
}

private struct QuizLockScreenView: View {
  let context: ActivityViewContext<QuizActivityAttributes>

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 8) {
        Text(WidgetL.LiveActivity.title)
          .font(.headline)
        Text(verbatim: context.attributes.difficulty)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      }

      Spacer()

      VStack(alignment: .trailing, spacing: 8) {
        HStack(spacing: 4) {
          Image(systemName: "star.fill")
            .foregroundStyle(.yellow)
          Text(verbatim: "\(context.state.score)")
            .font(.title2.bold())
            .monospacedDigit()
        }
        HStack(spacing: 4) {
          Text(verbatim: "\(context.state.currentQuestion) / \(context.attributes.totalQuestions)")
            .monospacedDigit()
          Text(verbatim: "·")
          QuizElapsedText(state: context.state)
            .monospacedDigit()
        }
        .font(.subheadline)
        .foregroundStyle(.secondary)
      }
    }
    .padding()
  }
}

// While the quiz is in progress the OS animates the elapsed time from `startDate`
// (`Text(_, style: .timer)`); once finished, the frozen final time is shown so the
// timer does not keep counting past completion.
private struct QuizElapsedText: View {
  let state: QuizActivityAttributes.ContentState

  var body: some View {
    if state.isFinished {
      Text(verbatim: state.elapsedTime)
    } else {
      Text(state.startDate, style: .timer)
    }
  }
}
