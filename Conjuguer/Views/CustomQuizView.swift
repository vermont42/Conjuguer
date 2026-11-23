//
//  CustomQuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import SwiftUI

/// The pages a custom quiz's choice pushes onto the Quiz tab.
enum CustomQuizDestination: Hashable {
  case editor
  case models
}

/// Where the learner chooses a custom quiz's tenses and verbs. Each tap is kept at once, so the
/// choice survives leaving the page and relaunching.
struct CustomQuizEditor: View {
  @Environment(World.self) private var world

  private var custom: CustomQuiz {
    world.settings.customQuiz
  }

  private var level: QuizLevel {
    world.settings.quizLevel
  }

  private var myVerbs: [Verb] {
    world.learnerVerbs.myVerbs
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.tripleDefaultSpacing) {
        tensesSection
        verbsSection
      }
      .frame(maxWidth: CustomQuizLayout.maxWidth)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .padding(.vertical, Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity)
    }
    .screenBackground()
    .navigationTitle(L.CustomQuiz.title)
    .navigationBarTitleDisplayMode(.inline)
    .recordsAppearance(as: "\(CustomQuizEditor.self)")
  }

  private var tensesSection: some View {
    CustomQuizSection(title: L.CustomQuiz.tenses, footer: L.CustomQuiz.tensesFooter) {
      CustomQuizChoiceRow(title: L.CustomQuiz.byLevel, detail: level.localizedName, isSelected: custom.tenses.isEmpty) {
        world.settings.customQuiz.tenses = []
      }
      .accessibilityIdentifier("custom_quiz_tenses_by_level")

      ForEach(QuizTenseSlot.allCases, id: \.self) { slot in
        Divider()
        CustomQuizChoiceRow(title: slot.name, titleIsFrench: true, detail: slot.secondName, isSelected: custom.tenses.contains(slot)) {
          world.settings.customQuiz.tenses.formSymmetricDifference([slot])
        }
        .accessibilityIdentifier("custom_quiz_tense_\(slot.key)")
      }
    }
  }

  private var verbsSection: some View {
    CustomQuizSection(title: L.CustomQuiz.verbs) {
      CustomQuizChoiceRow(title: L.CustomQuiz.byLevel, detail: CustomQuiz.levelVerbsDescription(level), isSelected: custom.verbSet == nil) {
        world.settings.customQuiz.verbSet = nil
      }
      .accessibilityIdentifier("custom_quiz_verbs_by_level")

      ForEach(QuizVerbSet.editorChoices(showsMyVerbs: !myVerbs.isEmpty || custom.verbSet == .myVerbs), id: \.self) { verbSet in
        Divider()
        CustomQuizChoiceRow(title: verbSet.title, detail: detail(of: verbSet), isSelected: custom.verbSet == verbSet) {
          world.settings.customQuiz.verbSet = verbSet
        }
        .accessibilityIdentifier("custom_quiz_verbs_\(verbSet.key)")
      }

      Divider()
      NavigationLink(value: CustomQuizDestination.models) {
        HStack {
          VStack(alignment: .leading, spacing: 2) {
            Text(L.CustomQuiz.models)
              .tableText()
            if let verbSet = custom.verbSet, verbSet.isModel {
              Text(verbSet.title)
                .font(captionFont)
                .foregroundStyle(Color.customRed)
                .frenchPronunciation()
            }
          }
          Spacer()
          Image(systemName: "checkmark")
            .fontWeight(.semibold)
            .foregroundStyle(Color.customBlue)
            .opacity(custom.verbSet?.isModel == true ? 1 : 0)
            .accessibilityHidden(true)
          Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.customGray)
            .accessibilityHidden(true)
        }
        .padding(.vertical, Layout.defaultSpacing)
        .contentShape(.rect)
      }
      .buttonStyle(.plain)
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(custom.verbSet?.isModel == true ? [.isButton, .isSelected] : .isButton)
      .accessibilityIdentifier("custom_quiz_verbs_models")
    }
  }

  private func detail(of verbSet: QuizVerbSet) -> String? {
    switch verbSet {
    case .all, .band:
      return nil
    case .myVerbs:
      return L.VerbBrowseView.verbCount(count: myVerbs.count)
    case .collection(let collection):
      return L.VerbBrowseView.verbCount(count: collection.verbs.count)
    }
  }
}

/// The verb models, one of which a custom quiz may ask. Choosing one returns to the choice.
struct CustomQuizModelList: View {
  @Environment(World.self) private var world
  @Environment(\.dismiss) private var dismiss

  private static let collections: [VerbCollection] = VerbModel.models.values
    .sorted { $0.position < $1.position }
    .map { VerbCollection.model($0.id) }
    .filter { !$0.verbs.isEmpty }

  var body: some View {
    ScrollView {
      CustomQuizSection {
        ForEach(Array(Self.collections.enumerated()), id: \.element) { index, collection in
          if index > 0 {
            Divider()
          }
          let verbSet = QuizVerbSet.collection(collection)
          CustomQuizChoiceRow(
            title: collection.title,
            titleIsFrench: true,
            detail: L.VerbBrowseView.verbCount(count: collection.verbs.count),
            isSelected: world.settings.customQuiz.verbSet == verbSet
          ) {
            world.settings.customQuiz.verbSet = verbSet
            dismiss()
          }
          .accessibilityIdentifier("custom_quiz_\(collection.key)")
        }
      }
      .frame(maxWidth: CustomQuizLayout.maxWidth)
      .padding(Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity)
    }
    .screenBackground()
    .navigationTitle(L.CustomQuiz.models)
    .navigationBarTitleDisplayMode(.inline)
  }
}

enum CustomQuizLayout {
  static let maxWidth: CGFloat = 680
}

private struct CustomQuizSection<Content: View>: View {
  var title: String?
  var footer: String?
  @ViewBuilder let content: Content

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      if let title {
        Text(title)
          .subheadingLabel()
          .accessibilityAddTraits(.isHeader)
      }

      VStack(alignment: .leading, spacing: 0) {
        content
      }
      .card()

      if let footer {
        Text(footer)
          .smallLabel()
          .fixedSize(horizontal: false, vertical: true)
      }
    }
  }
}

private struct CustomQuizChoiceRow: View {
  let title: String
  var titleIsFrench = false
  var detail: String?
  let isSelected: Bool
  let action: () -> Void

  var body: some View {
    Button(action: action) {
      HStack {
        VStack(alignment: .leading, spacing: 2) {
          Text(title)
            .tableText()
            .frenchPronunciation(forReal: titleIsFrench)
          if let detail {
            Text(detail)
              .smallLabel()
          }
        }
        Spacer()
        Image(systemName: "checkmark")
          .fontWeight(.semibold)
          .foregroundStyle(Color.customBlue)
          .opacity(isSelected ? 1 : 0)
          .accessibilityHidden(true)
      }
      .padding(.vertical, Layout.defaultSpacing)
      .contentShape(.rect)
    }
    .buttonStyle(.plain)
    .sensoryFeedback(.selection, trigger: isSelected)
    .accessibilityElement(children: .combine)
    .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
  }
}

extension CustomQuiz {
  /// "Elementary · 300 Most Frequent Verbs": the verbs a level's default quiz asks.
  @MainActor static func levelVerbsDescription(_ level: QuizLevel) -> String {
    let verbs = level.band.map { QuizVerbSet.band($0).title } ?? QuizVerbSet.all.title
    return L.CustomQuiz.levelVerbs(level: level.localizedName, verbs: verbs)
  }
}
