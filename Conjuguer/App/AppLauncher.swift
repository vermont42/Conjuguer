//
//  AppLauncher.swift
//  Conjuguer
//
//  Created by Joshua Adams on 5/7/22.
//

import SwiftUI

@main
enum AppLauncher {
  static func main() throws {
    if NSClassFromString("XCTestCase") == nil {
      ConjuguerApp.main()
    } else {
      VerbData.loadSynchronously()
      TestApp.main()
    }
  }
}
