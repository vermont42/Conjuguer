//
//  GetterSetterCodable.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

import Foundation

extension GetterSetter {
  func getCodable<T: Decodable>(key: String) -> T? {
    guard
      let string = get(key: key),
      let data = string.data(using: .utf8)
    else {
      return nil
    }
    return try? JSONDecoder().decode(T.self, from: data)
  }

  func setCodable<T: Encodable>(key: String, value: T) {
    guard
      let data = try? JSONEncoder().encode(value),
      let string = String(data: data, encoding: .utf8)
    else {
      return
    }
    set(key: key, value: string)
  }
}
