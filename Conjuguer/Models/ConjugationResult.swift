//
//  ConjugationResult.swift
//  Conjuguer
//
//  Created by Joshua Adams on 10/31/21.
//

import Foundation

enum ConjugationResult {
  case totalMatch
  case partialMatch
  case noMatch

  static func compare(lhs: String, rhs: String) -> ConjugationResult {
    let lhsCount = lhs.count
    let rhsCount = rhs.count
    if lhsCount != rhsCount || lhsCount == 0 {
      return .noMatch
    }
    var lhsClean = lhs.lowercased()
    var rhsClean = rhs.lowercased()
    if lhsClean == rhsClean {
      return .totalMatch
    }
    [("â", "a"), ("ê", "e"), ("î", "i"), ("ô", "o"), ("û", "u")].forEach {
      lhsClean = lhsClean.replacingOccurrences(of: $0.0, with: $0.1)
      rhsClean = rhsClean.replacingOccurrences(of: $0.0, with: $0.1)
    }
    if lhsClean == rhsClean {
      return .totalMatch
    }
    [
      ("à", "a"), ("è", "e"), ("ì", "i"), ("ò", "o"), ("ù", "u"),
      ("á", "a"), ("é", "e"), ("í", "i"), ("ó", "o"), ("ú", "u")
    ].forEach {
      lhsClean = lhsClean.replacingOccurrences(of: $0.0, with: $0.1)
      rhsClean = rhsClean.replacingOccurrences(of: $0.0, with: $0.1)
    }
    if lhsClean == rhsClean {
      return .partialMatch
    } else {
      return .noMatch
    }
  }

  var sound: Sound {
    switch self {
    case .totalMatch:
      return .chime
    case .partialMatch:
      return .chirp
    case .noMatch:
      return .buzz
    }
  }

  var score: Int {
    switch self {
    case .totalMatch:
      return 10
    case .partialMatch:
      return 5
    case .noMatch:
      return 0
    }
  }
}
