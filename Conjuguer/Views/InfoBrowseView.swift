//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 8/3/21.
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
            ForEach(Info.infos, id: \.self) { info in
              NavigationLink(destination: InfoView(info: info), label: {
                Text(info.heading)
                  .tableText()
              })
                .buttonStyle(PlainButtonStyle())
            }
              .navigationBarTitle(L.Navigation.info)
          }
        }
      }
        .navigationViewStyle(StackNavigationViewStyle()) // https://stackoverflow.com/a/66024249
        .padding()
    }
  }
}
