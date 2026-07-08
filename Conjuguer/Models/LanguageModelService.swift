//
//  LanguageModelService.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

import Foundation

enum LanguageModelUnavailability: Equatable {
  case appleIntelligenceNotEnabled
  case deviceNotEligible
  case modelNotReady
  case unknown
}

struct TutorMessage: Codable, Identifiable, Sendable {
  let id: UUID
  let role: Role
  let content: String
  let timestamp: Date

  enum Role: Codable, Sendable {
    case assistant
    case user
  }

  init(role: Role, content: String) {
    self.id = UUID()
    self.role = role
    self.content = content
    self.timestamp = Date()
  }
}

@MainActor
protocol LanguageModelService {
  var isAvailable: Bool { get }
  var unavailabilityReason: LanguageModelUnavailability? { get }
  func refreshAvailability()
  func sendTutorMessage(_ message: String) async throws -> String
  func resetTutorSession()
}

enum LanguageModelServiceError: Error {
  case sessionUnavailable
}
