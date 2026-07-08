//
//  Log.swift
//  Conjuguer
//
//  Created by Josh Adams on 7/8/26.
//

import os

// Per-category `Logger`s for the app's diagnostic sites. `print()` is unfilterable and
// lost in release builds; these route through the unified logging system so the messages
// survive to Console.app and `log` and can be filtered by category. The type is
// `nonisolated` so parse-time helpers (which run off the main actor) can log too.
nonisolated enum Log {
  private static let subsystem = "software.racecondition.Conjuguer"

  static let parsing = Logger(subsystem: subsystem, category: "Parsing")
  static let settings = Logger(subsystem: subsystem, category: "Settings")
  static let audio = Logger(subsystem: subsystem, category: "Audio")
  static let verbModel = Logger(subsystem: subsystem, category: "VerbModel")
}
