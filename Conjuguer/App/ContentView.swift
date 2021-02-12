//
//  ContentView.swift
//  Conjuguer
//
//  Created by Josh Adams on 1/1/21.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    ZStack {
      Color.black
      VStack {
        Text(mixedCaseString: "promEuvE")
        Text(mixedCaseString: "faILlENT")
        Text(mixedCaseString: "dOIt")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
