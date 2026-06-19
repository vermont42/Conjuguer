//
//  QuizWidget.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct QuizEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
  let isAnswered: Bool
  let wasCorrect: Bool
}

struct QuizProvider: TimelineProvider {
  func placeholder(in context: Context) -> QuizEntry {
    QuizEntry(date: Date(), snapshot: SnapshotReader.placeholder, isAnswered: false, wasCorrect: false)
  }

  func getSnapshot(in context: Context, completion: @escaping (QuizEntry) -> Void) {
    completion(makeEntry())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<QuizEntry>) -> Void) {
    let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
    completion(Timeline(entries: [makeEntry()], policy: .after(nextMidnight)))
  }

  private func makeEntry() -> QuizEntry {
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    let (isAnswered, wasCorrect) = readQuizState(snapshot: snapshot)
    return QuizEntry(date: Date(), snapshot: snapshot, isAnswered: isAnswered, wasCorrect: wasCorrect)
  }

  // Answer state only counts if it was recorded for the question currently on display.
  private func readQuizState(snapshot: WidgetSnapshot) -> (isAnswered: Bool, wasCorrect: Bool) {
    guard let defaults = WidgetConstants.sharedDefaults else {
      return (false, false)
    }
    let storedID = defaults.string(forKey: WidgetConstants.quizQuestionIDKey) ?? ""
    guard storedID == snapshot.quizQuestion.questionID else {
      return (false, false)
    }
    let isAnswered = defaults.bool(forKey: WidgetConstants.quizAnsweredKey)
    let wasCorrect = defaults.bool(forKey: WidgetConstants.quizCorrectKey)
    return (isAnswered, wasCorrect)
  }
}

struct QuizWidget: Widget {
  let kind = "QuizWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: QuizProvider()) { entry in
      QuizWidgetView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName(WidgetL.QuizWidget.name)
    .description(WidgetL.QuizWidget.description)
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
