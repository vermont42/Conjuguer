//
//  ReviewCardView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// An irregular verb looked up or practiced some days ago, offered above the verb list with its
/// key conjugations hidden.
/// A tap anywhere on the card reveals them; after that, a tap opens the verb's page. The ✕
/// dismisses the card. Which verb, and what each tap does to its schedule, is the caller's.
struct ReviewCardView: View {
  let verb: Verb
  /// When the verb was last looked up or practiced.
  let caption: String
  let isRevealed: Bool
  let reveal: () -> Void
  let open: () -> Void
  let dismiss: () -> Void

  private var conjugations: [String] {
    verb.keyConjugations()
  }

  private func tap() {
    if isRevealed {
      open()
    } else {
      reveal()
    }
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(caption)
        .font(captionFont.smallCaps())
        .foregroundStyle(Color.customGray)
        .padding(.trailing, 44)

      Text(verbatim: verb.infinitifWithPossibleExtraLetters)
        .tableText()
        .frenchPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }

      Text(verbatim: verb.translation)
        .smallLabel()
        .englishPronunciation()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }

      if isRevealed {
        revealedConjugations
      } else {
        hiddenConjugations
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .overlay(alignment: .topTrailing) {
      // The button's 44-point frame reaches into the card's padding rather than pushing the
      // infinitive down.
      Button(action: dismiss) {
        Image(systemName: "xmark")
          .font(.footnote.weight(.semibold))
          .foregroundStyle(Color.customGray)
          .frame(width: 44, height: 44)
          .contentShape(.rect)
      }
      .buttonStyle(.plain)
      .offset(x: 14, y: -14)
      .accessibilityLabel(Text(L.ReviewCard.dismiss))
      .accessibilityIdentifier("review_card_dismiss")
    }
    .card(accent: .customBlue)
    .contentShape(.rect)
    .onTapGesture { tap() }
    .accessibilityElement(children: .contain)
    .accessibilityIdentifier("review_card")
  }

  private var spokenConjugations: String {
    conjugations.map { $0.lowercased() }.joined(separator: "; ")
  }

  private var hiddenConjugations: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(verbatim: conjugations.map { $0.lowercased() }.joined(separator: " · "))
        .font(bodyFont)
        .redacted(reason: .placeholder)
        .accessibilityHidden(true)

      Text(L.ReviewCard.prompt)
        .smallLabel()
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }
        .accessibilityIdentifier("review_card_reveal")
    }
    .padding(.top, Layout.defaultSpacing)
  }

  private var revealedConjugations: some View {
    HStack(alignment: .firstTextBaseline) {
      Text(mixedCaseString: conjugations.joined(separator: " · "))
        .font(bodyFont)
        .frenchPronunciation()
        .accessibilityLabel(Text(verbatim: spokenConjugations))
        .accessibilityHint(Text(L.ReviewCard.openHint))
        .accessibilityAddTraits(.isButton)
        .accessibilityAction { tap() }
        .accessibilityIdentifier("review_card_conjugations")

      Spacer(minLength: 0)

      Image(systemName: "chevron.right")
        .font(.footnote.weight(.semibold))
        .foregroundStyle(Color.customGray)
        .accessibilityHidden(true)
    }
    .padding(.top, Layout.defaultSpacing)
    .transition(.opacity)
  }
}
