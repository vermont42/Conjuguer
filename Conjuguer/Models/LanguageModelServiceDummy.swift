//
//  LanguageModelServiceDummy.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

@MainActor
class LanguageModelServiceDummy: LanguageModelService {
  var isAvailable: Bool { false }
  var unavailabilityReason: LanguageModelUnavailability? { .deviceNotEligible }

  func refreshAvailability() {}

  func sendTutorMessage(_ message: String) async throws -> String {
    ""
  }

  func resetTutorSession() {}
}
