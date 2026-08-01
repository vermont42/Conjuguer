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
  var badge: Badge?

  var body: some View {
    HStack {
      VStack(alignment: .leading, spacing: 2) {
        Text(title)
          .tableText()
          .frenchPronunciation()

        if let subtitle {
          Text(subtitle)
            .smallLabel()
            .englishPronunciation()
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
