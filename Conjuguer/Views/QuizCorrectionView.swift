//
//  QuizCorrectionView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

extension EnvironmentValues {
  /// True on the pages a quiz pushes over a held correction, which offer no quiz of their own.
  @Entry var isBeneathQuiz = false
}

/// A wrong answer, held: what the learner typed and the right answer, with the letters that differ
/// marked, a sentence completed, what was wrong when the Conjugator can say, links to the verb's
/// page and its model's page, and Continue.
struct QuizCorrectionView: View {
  let question: QuizQuestion
  let correction: QuizCorrection
  /// False in a quiz begun from the verb's own page, where a link back to it would be circular.
  let showsVerbLink: Bool
  var accessibilityIsFocused: AccessibilityFocusState<Bool>.Binding
  let onOpen: (any Hashable) -> Void
  let onContinue: () -> Void

  static let continueButtonID = "quiz_continue_button"

  // As wide as an iPhone's, and no wider on an iPad, where the quiz spans the screen.
  private static let continueMaxWidth: CGFloat = 400
  private static let maxSpokenLetters = 3

  private var difference: AnswerDifference {
    correction.difference
  }

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        if let recognition = question.recognition, let answer = correction.recognitionAnswer {
          answerRow(label: L.QuizView.yourAnswer, text: recognitionGivenText(answer))
          VStack(alignment: .leading, spacing: 2) {
            Text(L.QuizView.correctAnswer)
              .smallLabel()
            ForEach(recognition.answerLines, id: \.self) { line in
              Text(verbatim: line)
                .font(bodyEmphasisFont)
                .foregroundStyle(Color.customBlue)
                .fixedSize(horizontal: false, vertical: true)
                .frenchPronunciation()
            }
          }
        } else {
          answerRow(label: L.QuizView.yourAnswer, text: Self.givenText(difference))
          answerRow(label: L.QuizView.correctAnswer, text: Self.expectedText(difference))
        }

        if let sentence = question.sentence {
          Label {
            Text(verbatim: sentence.completed)
              .italic()
              .frenchPronunciation()
          } icon: {
            Image(systemName: "text.quote")
          }
          .font(bodyFont)
          .foregroundStyle(Color.customForeground)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityIdentifier("quiz_correction_sentence")
        }

        if let diagnosis = correction.diagnosis {
          Label(diagnosis.line, systemImage: "lightbulb.fill")
            .font(bodyFont)
            .foregroundStyle(Color.customForeground)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("quiz_correction_diagnosis")
        }

        if correction.willBeReasked {
          Label(L.QuizView.willBeAskedAgain, systemImage: "arrow.uturn.backward")
            .font(captionFont)
            .foregroundStyle(Color.customGray)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityIdentifier("quiz_correction_will_be_asked_again")
        }
      }
      .accessibilityElement(children: .ignore)
      .accessibilityLabel(spokenCorrection)
      .accessibilityHint(L.QuizView.correctionHint)
      .accessibilityFocused(accessibilityIsFocused)
      .accessibilityIdentifier("quiz_correction")

      HStack(spacing: Layout.defaultSpacing) {
        if showsVerbLink {
          link(Text(verbatim: question.verb.infinitifWithPossibleExtraLetters), systemImage: "book.fill", isFrench: true, identifier: "quiz_correction_verb") {
            onOpen(VerbDestination(
              verb: question.verb,
              source: .quizCorrection,
              marks: MarkedConjugations(tenses: [question.tense])
            ))
          }
        }
        if let model = VerbModel.models[question.verb.model] {
          link(modelText(model), systemImage: "key.fill", isFrench: false, identifier: "quiz_correction_model") {
            onOpen(ModelDestination(model: model))
          }
        }
      }

      Button(action: onContinue) {
        Label(L.QuizView.continueAfterCorrection, systemImage: "arrow.right")
          .buttonLabel()
          .frame(maxWidth: Self.continueMaxWidth)
      }
      .funButton()
      .controlSize(.large)
      .frame(maxWidth: .infinity)
      .accessibilityHint(L.QuizView.continueHint)
      .accessibilityIdentifier(Self.continueButtonID)
      .id(Self.continueButtonID)
    }
    .card(accent: ConjugationResult.noMatch.feedbackColor)
  }

  private func answerRow(label: String, text: Text) -> some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(label)
        .smallLabel()
      text
        .font(bodyEmphasisFont)
        .fixedSize(horizontal: false, vertical: true)
        .frenchPronunciation()
    }
  }

  private func modelText(_ model: VerbModel) -> Text {
    Text(verbatim: "\(L.VerbView.modelWithColon) \(model.exemplar) (\(model.id))")
  }

  private func link(_ text: Text, systemImage: String, isFrench: Bool, identifier: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Label {
        text
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      } icon: {
        Image(systemName: systemImage)
      }
      .font(captionFont)
      .foregroundStyle(Color.customBlue)
      .padding(.horizontal, 10)
      .padding(.vertical, 6)
      .background(Color.customBlue.opacity(0.1), in: Capsule())
    }
    .buttonStyle(.plain)
    .frenchPronunciation(forReal: isFrench)
    .accessibilityHint(L.QuizView.correctionLinkHint)
    .accessibilityIdentifier(identifier)
  }

  /// "Incorrect. Your Answer: parle. Correct Answer: parlé. Letters that differ: é. This question
  /// will come up again.", with the diagnosis, if any, after the letters. The letters are named
  /// only while there are few enough to help.
  private var spokenCorrection: String {
    if let recognition = question.recognition, let answer = correction.recognitionAnswer {
      let expected = recognition.answerLines.map { $0.replacingOccurrences(of: " · ", with: ", ") }.joined(separator: "; ")
      var spoken = "\(L.QuizView.incorrect) \(L.QuizView.yourAnswer) \(answer.summary.replacingOccurrences(of: " · ", with: ", ")). \(L.QuizView.correctAnswer) \(expected)."
      if correction.willBeReasked {
        spoken += " " + L.QuizView.willBeAskedAgain
      }
      return spoken
    }
    let given = difference.given.isEmpty ? L.QuizView.none : difference.given
    var spoken = "\(L.QuizView.incorrect) \(L.QuizView.yourAnswer) \(given). \(L.QuizView.correctAnswer) \(difference.expected.lowercased())."
    let letters = difference.expectedMarkedLetters
    if !letters.isEmpty, letters.count <= Self.maxSpokenLetters {
      spoken += " " + L.QuizView.differingLetters(letters.joined(separator: ", "))
    }
    if let diagnosis = correction.diagnosis {
      spoken += " " + diagnosis.line
    }
    if let sentence = question.sentence {
      spoken += " " + sentence.completed
    }
    if correction.willBeReasked {
      spoken += " " + L.QuizView.willBeAskedAgain
    }
    return spoken
  }

  /// A recognition answer part by part: the infinitive, then the tense and the person, each in red
  /// where the grade found it wrong. A wrong infinitive is red throughout, since one that lacks
  /// letters, as venir lacks revenir's, has nothing of its own to mark.
  private func recognitionGivenText(_ answer: RecognitionAnswer) -> Text {
    let wrong = correction.recognitionGrade?.wrongParts ?? Set(RecognitionPart.allCases)
    var result = AttributedString()
    if wrong.contains(.infinitive) {
      var infinitive = Self.givenAttributedText(difference)
      infinitive.foregroundColor = Color.customRed
      result.append(infinitive)
    } else {
      var infinitive = AttributedString(AnswerSpelling.normalized(answer.infinitif))
      infinitive.foregroundColor = Color.customForeground
      result.append(infinitive)
    }
    let parts: [(String, RecognitionPart)] = [(answer.slot.recognitionName, .tense)]
      + (answer.personNumber.map { [(RecognitionQuestion.personLabel($0), .person)] } ?? [])
    for (text, part) in parts {
      var separator = AttributedString(" · ")
      separator.foregroundColor = Color.customGray
      result.append(separator)
      var piece = AttributedString(text)
      piece.foregroundColor = wrong.contains(part) ? Color.customRed : Color.customForeground
      if wrong.contains(part) {
        piece.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .customRed)
      }
      result.append(piece)
    }
    return Text(result)
  }

  // The red letters of a conjugation mark its irregularity, so a difference is shown another
  // way: a tinted background, struck through in the learner's answer and underlined in the right
  // one.
  static func givenText(_ difference: AnswerDifference) -> Text {
    guard !difference.given.isEmpty else {
      return Text(verbatim: "—").foregroundStyle(Color.customGray)
    }
    return Text(givenAttributedText(difference))
  }

  private static func givenAttributedText(_ difference: AnswerDifference) -> AttributedString {
    var result = AttributedString()
    for (character, isMarked) in zip(Array(difference.given), difference.givenMarks) {
      var part = AttributedString(String(character))
      part.foregroundColor = Color.customForeground
      if isMarked {
        part.foregroundColor = Color.customRed
        part.backgroundColor = Color.customRed.opacity(0.35)
        part.strikethroughStyle = Text.LineStyle(pattern: .solid, color: .customRed)
      }
      result.append(part)
    }
    return result
  }

  static func expectedText(_ difference: AnswerDifference) -> Text {
    var result = AttributedString()
    for (character, isMarked) in zip(Array(difference.expected), difference.expectedMarks) {
      let isIrregular = character.isLetter && !character.isLowercase
      var part = AttributedString(character.lowercased())
      part.foregroundColor = isIrregular ? Color.customRed : Color.customBlue
      if isMarked {
        part.backgroundColor = Color.customGreen.opacity(0.4)
        part.underlineStyle = Text.LineStyle(pattern: .solid, color: .customGreen)
      }
      result.append(part)
    }
    return Text(result)
  }
}
