//
//  WidgetDateHelper.swift
//  Conjuguer
//
//  Shared between the app (snapshot producer) and the widget extension (consumer).
//

import Foundation

// Date helpers shared by the app and the widget extension. A Gregorian calendar keeps day
// indices and date strings stable regardless of the user's calendar/locale (a Buddhist/Japanese
// calendar would otherwise leak era years into the questionID), and the midnight math stays
// DST-correct. It is made on each access, with `Calendar.autoupdatingCurrent`'s time zone,
// because a stored calendar keeps the zone of its launch, and so does one given
// `TimeZone.autoupdatingCurrent` (measured 2026-11-27): a learner who crossed zones would see
// the old zone's day until a relaunch. Making one costs under a microsecond.
enum WidgetDateHelper {
  static var calendar: Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = Calendar.autoupdatingCurrent.timeZone
    return calendar
  }

  // Locale-/calendar-independent yyyy-MM-dd. Used in quiz questionIDs and to match a
  // multi-day snapshot to the day it should display. `String(format:)` with `%d` is
  // locale-independent, so no DateFormatter (and no per-call allocation) is needed.
  static func dateString(for date: Date) -> String {
    let components = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", components.year ?? 0, components.month ?? 0, components.day ?? 0)
  }

  // Parses a `dateString(for:)` value back into that day's midnight, for placing a
  // decoded snapshot onto a timeline at the right instant.
  static func date(fromDateString string: String) -> Date? {
    let parts = string.split(separator: "-").compactMap { Int($0) }
    guard parts.count == 3 else {
      return nil
    }
    return calendar.date(from: DateComponents(year: parts[0], month: parts[1], day: parts[2]))
  }

  static func startOfDay(for date: Date) -> Date {
    calendar.startOfDay(for: date)
  }
}
