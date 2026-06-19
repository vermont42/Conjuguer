//
//  VerbDuJourWidget.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct VerbDuJourEntry: TimelineEntry {
  let date: Date
  let snapshot: WidgetSnapshot
}

struct VerbDuJourProvider: TimelineProvider {
  func placeholder(in context: Context) -> VerbDuJourEntry {
    VerbDuJourEntry(date: Date(), snapshot: SnapshotReader.placeholder)
  }

  func getSnapshot(in context: Context, completion: @escaping (VerbDuJourEntry) -> Void) {
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    completion(VerbDuJourEntry(date: Date(), snapshot: snapshot))
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<VerbDuJourEntry>) -> Void) {
    let snapshot = SnapshotReader.read() ?? SnapshotReader.placeholder
    let entry = VerbDuJourEntry(date: Date(), snapshot: snapshot)
    let nextMidnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
    completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
  }
}

struct VerbDuJourWidget: Widget {
  let kind = "VerbDuJourWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: VerbDuJourProvider()) { entry in
      VerbDuJourEntryView(entry: entry)
        .containerBackground(.fill.tertiary, for: .widget)
    }
    .configurationDisplayName(WidgetL.VerbWidget.name)
    .description(WidgetL.VerbWidget.description)
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .accessoryRectangular, .accessoryInline])
  }
}

struct VerbDuJourEntryView: View {
  var entry: VerbDuJourEntry
  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .systemSmall:
      SmallWidgetView(snapshot: entry.snapshot)
    case .systemMedium:
      MediumWidgetView(snapshot: entry.snapshot)
    case .systemLarge:
      LargeWidgetView(snapshot: entry.snapshot)
    case .accessoryRectangular:
      AccessoryRectangularView(snapshot: entry.snapshot)
    case .accessoryInline:
      AccessoryInlineView(snapshot: entry.snapshot)
    default:
      SmallWidgetView(snapshot: entry.snapshot)
    }
  }
}
