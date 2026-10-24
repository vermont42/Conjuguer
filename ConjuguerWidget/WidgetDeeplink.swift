//
//  WidgetDeeplink.swift
//  ConjuguerWidget
//

import Foundation

enum WidgetDeeplink {
  static func verb(_ snapshot: WidgetSnapshot) -> URL? {
    let key = snapshot.verbKey ?? snapshot.infinitif
    let encoded = key.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? key
    return URL(string: "conjuguer://verb/\(encoded)")
  }
}
