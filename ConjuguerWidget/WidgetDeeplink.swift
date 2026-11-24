//
//  WidgetDeeplink.swift
//  ConjuguerWidget
//

import Foundation

enum WidgetDeeplink {
  static func verb(_ snapshot: WidgetSnapshot) -> URL? {
    let key = snapshot.verbKey ?? snapshot.infinitif
    let encoded = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? key
    return URL(string: "conjuguer://verb/\(encoded)?source=widget")
  }

  /// The quiz widget's question is the first of today's challenge at the learner's level, so a
  /// tap beside the answers opens the challenge.
  static let challenge = URL(string: "conjuguer://quiz/challenge?source=challengeWidget")
}
