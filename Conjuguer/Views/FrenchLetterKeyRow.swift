//
//  FrenchLetterKeyRow.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// The accented letters French verb forms use, to show above the keyboard. The caller decides
/// where a letter goes, so a field that tracks its selection can insert at the cursor.
struct FrenchLetterKeyRow: View {
  // ï and œ, in fourteen verbs between them, are left out because search folds them (hair
  // finds haïr), and no verb form uses à, ù, or ë.
  static let letters = ["é", "è", "ê", "â", "î", "ô", "û", "ç"]

  let insert: (String) -> Void

  var body: some View {
    HStack(spacing: 6) {
      ForEach(Self.letters, id: \.self) { letter in
        Button {
          insert(letter)
        } label: {
          Text(verbatim: letter)
            .font(.title3)
            .frame(maxWidth: .infinity, minHeight: 32)
        }
        .buttonStyle(.bordered)
        .tint(.customBlue)
        .frenchPronunciation()
        .accessibilityIdentifier("french_letter_key_\(letter)")
      }
    }
  }
}

#Preview {
  FrenchLetterKeyRow { _ in }
    .padding()
}
