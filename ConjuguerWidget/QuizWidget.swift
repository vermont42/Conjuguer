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
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    completion(makeEntry(snapshot: snapshot, date: Date()))
  }

  // One entry per precomputed day so the quiz question rotates at midnight without an
  // app relaunch. Only today's stored answer state can match a given day's questionID,
  // so future days render as unanswered questions until their day arrives.
  func getTimeline(in context: Context, completion: @escaping (Timeline<QuizEntry>) -> Void) {
    let snapshots = SnapshotReader.readAll()
    guard !snapshots.isEmpty else {
      completion(Timeline(entries: [makeEntry(snapshot: SnapshotReader.placeholder, date: Date())], policy: .atEnd))
      return
    }
    let entries = snapshots.map { snapshot in
      let date = WidgetDateHelper.date(fromDateString: snapshot.dateString) ?? Date()
      return makeEntry(snapshot: snapshot, date: date)
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  private func makeEntry(snapshot: WidgetSnapshot, date: Date) -> QuizEntry {
    let (isAnswered, wasCorrect) = readQuizState(snapshot: snapshot)
    return QuizEntry(date: date, snapshot: snapshot, isAnswered: isAnswered, wasCorrect: wasCorrect)
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
