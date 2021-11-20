//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/3/21.
//

import SwiftUI

struct InfoBrowseView: View {
  @State private var isPresentingInfo = false
  @State private var isPresentingVerb = false

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
    .navigationViewStyle(.stack) // https://stackoverflow.com/a/66024249
    .onReceive(Current.$info) { value in
      if value == nil {
        isPresentingInfo = false
      } else {
        isPresentingInfo = true
      }
    }
    .onReceive(Current.$verb) { value in
      if value == nil {
        isPresentingVerb = false
      } else {
        isPresentingVerb = true
      }
    }
    .sheet(
      isPresented: $isPresentingInfo,
      onDismiss: {
        Current.info = nil
        isPresentingInfo = false
      },
      content: {
        Current.info.map {
          InfoView(info: $0, shouldShowInfoHeading: true)
        }
      }
    )
    .sheet(
      isPresented: $isPresentingVerb,
      onDismiss: {
        Current.verb = nil
        isPresentingVerb = false
      },
      content: {
        Current.verb.map {
          VerbView(verb: $0, shouldShowVerbHeading: true)
        }
      }
    )
    .onAppear {
      Current.analytics.recordViewAppeared("\(InfoBrowseView.self)")
    }
  }
}
