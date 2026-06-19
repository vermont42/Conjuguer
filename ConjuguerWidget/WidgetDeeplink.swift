//
//  WidgetDeeplink.swift
//  ConjuguerWidget
//

import Foundation

enum WidgetDeeplink {
  static func verb(_ infinitif: String) -> URL? {
    let encoded = infinitif.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? infinitif
    return URL(string: "conjuguer://verb/\(encoded)")
  }
}
