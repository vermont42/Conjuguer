//
//  RecognitionChoicesView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// A recognition question's prompt, the conjugation to name, with its irregular letters in red.
struct RecognitionPromptView: View {
  let prompt: String

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing / 2) {
      Text(L.Recognition.promptHeading)
        .font(captionFont)
        .foregroundStyle(Color.customBlue)
        .accessibilityHidden(true)

      Text(AttributedString(mixedCaseString: prompt))
        .font(largeTitleFont)
        .foregroundStyle(Color.customForeground)
        .fixedSize(horizontal: false, vertical: true)
        .frenchPronunciation()
        .accessibilityLabel(Text(verbatim: prompt.lowercased()))
        .accessibilityHint(L.Recognition.promptHeading)
        .accessibilityIdentifier("recognition_prompt")
    }
  }
}

/// The level's tenses and then the chosen tense's persons, as chips. A participle has no person,
/// so its row of persons disappears, and a person that the newly chosen tense lacks, such as je in
/// the impératif, is cleared.
struct RecognitionChoicesView: View {
  let recognition: RecognitionQuestion
  @Binding var slot: QuizTenseSlot?
  @Binding var personNumber: PersonNumber?
  /// True while a correction holds, when the choices stay as answered.
  let isLocked: Bool

  // Advanced offers nineteen tenses, so the chips are compact enough to leave the field in sight.
  private static let chipSpacing: CGFloat = 6

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      heading(L.Recognition.tenseHeading)

      FlowLayout(spacing: Self.chipSpacing) {
        ForEach(recognition.slots, id: \.self) { choice in
          chip(choice.recognitionName, isSelected: slot == choice, identifier: "recognition_tense_\(choice)") {
            slot = choice
            if let personNumber, !RecognitionQuestion.persons(of: choice).contains(personNumber) {
              self.personNumber = nil
            }
          }
        }
      }

      if let slot, !RecognitionQuestion.persons(of: slot).isEmpty {
        heading(L.Recognition.personHeading)
          .padding(.top, Layout.defaultSpacing / 2)

        FlowLayout(spacing: Self.chipSpacing) {
          ForEach(RecognitionQuestion.persons(of: slot), id: \.self) { choice in
            chip(RecognitionQuestion.personLabel(choice), isSelected: personNumber == choice, identifier: "recognition_person_\(choice.rawValue)") {
              personNumber = choice
            }
          }
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .disabled(isLocked)
    .sensoryFeedback(.selection, trigger: slot)
    .sensoryFeedback(.selection, trigger: personNumber)
  }

  private func heading(_ text: String) -> some View {
    Text(text)
      .font(captionFont)
      .foregroundStyle(Color.customBlue)
      .accessibilityAddTraits(.isHeader)
  }

  private func chip(_ text: String, isSelected: Bool, identifier: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(verbatim: text)
        .font(gridEndingFont)
        .foregroundStyle(isSelected ? Color.customBackground : Color.customForeground)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(isSelected ? Color.customBlue : Color.customBlue.opacity(0.08), in: Capsule())
        .overlay {
          Capsule()
            .strokeBorder(Color.customBlue.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
        }
        .contentShape(Capsule())
    }
    .buttonStyle(.plain)
    .frenchPronunciation()
    .accessibilityAddTraits(isSelected ? .isSelected : [])
    .accessibilityIdentifier(identifier)
  }
}
