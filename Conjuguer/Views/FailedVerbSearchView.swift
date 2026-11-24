//
//  FailedVerbSearchView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

struct FailedVerbSearchView: View {
  let query: String
  let guess: VerbSearch.Guess?
  let pronounGender: PronounGender
  let guessIsSelected: Bool
  let openGuess: (VerbSearch.Guess) -> Void
  @State private var addressWasCopied = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        ContentUnavailableView.search(text: query)

        if let guess {
          Text(L.VerbBrowseView.guessIntro)
            .subheadingLabel()
            .accessibilityIdentifier("search_guess_intro")

          Button {
            openGuess(guess)
          } label: {
            BrowseRow(
              title: guess.verb.infinitifWithPossibleExtraLetters,
              subtitle: guess.verb.translation,
              detail: guess.conjugation?.line(pronounGender: guess.verb.pronounGender(for: pronounGender)),
              badge: BrowseRow.Badge(text: "#\(guess.verb.frequency)", tint: .customBlue)
            )
            .card(accent: guessIsSelected ? .customRed : nil)
          }
          .buttonStyle(.plain)
          .accessibilityIdentifier("search_guess_row")
        }

        Text(verbRequestText)
          .font(captionFont)
          .foregroundStyle(Color.customGray)
          .tint(.customBlue)
          .accessibilityIdentifier("verb_request_link")
          .environment(\.openURL, OpenURLAction { url in
            Task {
              await openVerbRequest(url)
            }
            return .handled
          })

        if addressWasCopied {
          Text(L.VerbBrowseView.addressCopied)
            .font(captionFont)
            .foregroundStyle(Color.customRed)
            .transition(.opacity)
            .accessibilityIdentifier("address_copied_note")
        }
      }
      .frame(maxWidth: 500)
      .frame(maxWidth: .infinity)
    }
    .scrollContentBackground(.hidden)
  }

  private var verbRequestText: AttributedString {
    let address = URL.developerEmail
    var text = AttributedString(L.VerbBrowseView.verbRequest(query: query, address: address))
    if
      let range = text.range(of: address, options: .backwards),
      let url = URL.mailto(
        address,
        subject: L.VerbBrowseView.verbRequestSubject(query: query),
        body: L.VerbBrowseView.verbRequestBody(query: query)
      ) {
      text[range].link = url
    }
    return text
  }

  // A device with no email app, such as the simulator, cannot open the link, so the address
  // goes to the clipboard instead of nowhere.
  private func openVerbRequest(_ url: URL) async {
    guard !(await UIApplication.shared.open(url)) else {
      return
    }
    UIPasteboard.general.string = URL.developerEmail
    AccessibilityNotification.Announcement(L.VerbBrowseView.addressCopied).post()
    withAnimation {
      addressWasCopied = true
    }
    try? await Task.sleep(for: .seconds(4))
    withAnimation {
      addressWasCopied = false
    }
  }
}
