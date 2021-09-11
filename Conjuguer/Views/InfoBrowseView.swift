//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/3/21.
//

import SwiftUI

struct InfoBrowseView: View {
  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      NavigationView {
        ZStack {
          Color.customBackground

          ScrollView {
            LazyVStack {
              ForEach(Info.infos, id: \.heading) { info in
                NavigationLink(destination: InfoView(info: info)) {
                  ZStack {
                    Color.customBackground
                    Text(info.heading)
                      .tableText()
                  }
                }
                  .buttonStyle(PlainButtonStyle())
              }
            }
              .navigationBarTitle(L.Navigation.info)
          }
        }
      }
    }
  }
}
