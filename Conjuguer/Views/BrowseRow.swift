//
//  BrowseRow.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/1/26.
//

import SwiftUI

struct BrowseRow: View {
  struct Badge {
    let text: String
    let tint: Color
    var accessibilityLabel: Text?
  }

  let title: String
  var subtitle: String?
  var subtitleIsFrench = false

  /// A French line below the subtitle, in the accent color: what a search matched, as in
  /// "vais: Indicatif Présent (je)".
  var detail: String?
  var badge: Badge?

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .tableText()
          .frenchPronunciation()

        if let subtitle {
          if subtitleIsFrench {
            Text(subtitle)
              .smallLabel()
              .frenchPronunciation()
          } else {
            Text(subtitle)
              .smallLabel()
              .englishPronunciation()
          }
        }

        if let detail {
          Text(detail)
            .font(captionFont)
            .foregroundStyle(Color.customRed)
            .frenchPronunciation()
        }
      }

      if let badge {
        Spacer()
        badgeText(badge)
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(.rect)
  }

  @ViewBuilder
  private func badgeText(_ badge: Badge) -> some View {
    let pill = Text(badge.text)
      .font(browseBadgeFont)
      .foregroundStyle(badge.tint)
      .padding(.horizontal, 10)
      .padding(.vertical, 3)
      .background(Capsule().fill(badge.tint.opacity(0.15)))

    if let accessibilityLabel = badge.accessibilityLabel {
      pill.accessibilityLabel(accessibilityLabel)
    } else {
      pill.accessibilityHidden(true)
    }
  }
}
