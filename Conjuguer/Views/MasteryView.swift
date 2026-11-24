//
//  MasteryView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/24/26.
//

import SwiftUI

struct MasteryDestination: Hashable {}

/// What the practice record has made secure at the learner's level: the regular families'
/// patterns, the spelling-change models' own patterns, and the key conjugations of the band's most
/// used irregular verbs. It only shows. A verb here links to nothing, since opening a verb page is
/// a lookup, which would send the verb's key conjugations back to the first box.
struct MasteryView: View {
  @Environment(World.self) private var world

  var body: some View {
    let mastery = Mastery(level: world.settings.quizLevel, record: world.practice.record)

    ScrollView {
      LazyVStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        Text(L.Mastery.intro(mastery.level.localizedName))
          .smallLabel()
          .fixedSize(horizontal: false, vertical: true)

        legend

        sectionHeader(L.Mastery.regular, cells: mastery.regularCells, description: L.Mastery.regularDescription)
          .padding(.top, Layout.defaultSpacing)

        ForEach(mastery.regular) { table in
          MasteryRegularCard(table: table)
        }

        if !mastery.spellingChanges.isEmpty {
          sectionHeader(L.Mastery.spellingChanges, cells: mastery.spellingChangeCells, description: L.Mastery.spellingChangesDescription)
            .padding(.top, Layout.defaultSpacing)

          ForEach(mastery.spellingChanges) { model in
            MasteryModelCard(model: model)
          }
        }

        sectionHeader(
          L.Mastery.irregular,
          count: L.Mastery.count(mastery.masteredVerbCount, of: mastery.verbs.count),
          description: L.Mastery.irregularDescription(mastery.verbs.count)
        )
        .padding(.top, Layout.defaultSpacing)

        VStack(alignment: .leading, spacing: 0) {
          ForEach(mastery.verbs) { row in
            MasteryVerbRow(row: row)
            if row.id != mastery.verbs.last?.id {
              Divider()
            }
          }
        }
        .card()
      }
      .frame(maxWidth: CustomQuizLayout.maxWidth)
      .padding(Layout.doubleDefaultSpacing)
      .frame(maxWidth: .infinity)
    }
    .screenBackground()
    .navigationTitle(L.Mastery.title)
    .navigationBarTitleDisplayMode(.inline)
    .recordsAppearance(as: "\(MasteryView.self)")
  }

  private var legend: some View {
    FlowLayout(spacing: Layout.doubleDefaultSpacing) {
      ForEach([MasteryState.mastered, .learning, .notPracticed], id: \.self) { state in
        HStack(spacing: 4) {
          MasteryMark(state: state)
            .accessibilityHidden(true)
          Text(state.label)
            .font(captionFont)
            .foregroundStyle(Color.customForeground)
        }
        .accessibilityElement(children: .combine)
      }
    }
    .accessibilityIdentifier("mastery_legend")
  }

  private func sectionHeader(_ title: String, cells: [Mastery.Cell], description: String) -> some View {
    sectionHeader(title, count: L.Mastery.count(cells.filter { $0.state == .mastered }.count, of: cells.count), description: description)
  }

  private func sectionHeader(_ title: String, count: String, description: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(title)
          .font(headingFont)
          .foregroundStyle(Color.customForeground)
        Spacer()
        Text(verbatim: count)
          .font(captionFont.monospacedDigit())
          .foregroundStyle(Color.customGray)
      }
      .accessibilityElement(children: .combine)
      .accessibilityAddTraits(.isHeader)

      Text(description)
        .smallLabel()
        .fixedSize(horizontal: false, vertical: true)
    }
  }
}

private struct MasteryRegularCard: View {
  let table: Mastery.PatternTable

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      MasteryTenseName(slot: table.slot)

      ForEach(table.rows) { row in
        HStack(alignment: .bottom, spacing: Layout.defaultSpacing) {
          Text(verbatim: row.label)
            .font(captionFont)
            .foregroundStyle(Color.customForeground)
            .frame(width: 92, alignment: .leading)
            .accessibilityLabel(row.spokenLabel)

          if row.cells.count == 1, let cell = row.cells.first, cell.person == nil {
            MasteryMark(state: cell.state)
            Spacer(minLength: 0)
          } else {
            HStack(spacing: 0) {
              ForEach(row.cells) { cell in
                VStack(spacing: 2) {
                  if let person = cell.person {
                    Text(verbatim: Mastery.personLabel(person))
                      .font(gridPronounFont)
                      .foregroundStyle(Color.customGray)
                      .lineLimit(1)
                      .frenchPronunciation()
                  }
                  MasteryMark(state: cell.state)
                }
                .frame(maxWidth: .infinity)
              }
            }
          }
        }
      }
    }
    .card()
    .accessibilityIdentifier("mastery_regular_\(table.slot.key)")
  }
}

private struct MasteryModelCard: View {
  let model: Mastery.ModelCard

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(alignment: .firstTextBaseline, spacing: Layout.defaultSpacing) {
        Text(verbatim: VerbModel.models[model.modelID]?.exemplarWithPossibleExtraLetters ?? model.modelID)
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.customRed)
          .frenchPronunciation()

        if let example = model.example {
          Text(mixedCaseString: example)
            .font(captionFont)
            .foregroundStyle(Color.customForeground)
            .frenchPronunciation()
            .accessibilityLabel(Text(verbatim: example.lowercased()))
        }

        Spacer(minLength: 0)
      }

      ForEach(model.tables) { table in
        ForEach(table.rows) { row in
          VStack(alignment: .leading, spacing: 4) {
            Text(verbatim: row.takesÊtre ? "\(table.slot.name) (être)" : table.slot.name)
              .font(gridTenseLabelFont)
              .foregroundStyle(Color.customGray)
              .frenchPronunciation()

            FlowLayout(spacing: Layout.doubleDefaultSpacing) {
              ForEach(row.cells) { cell in
                HStack(spacing: 4) {
                  if let person = cell.person {
                    Text(verbatim: Mastery.personLabel(person))
                      .font(captionFont)
                      .foregroundStyle(Color.customForeground)
                      .frenchPronunciation()
                  }
                  MasteryMark(state: cell.state)
                }
              }
            }
          }
        }
      }
    }
    .card()
    .accessibilityIdentifier("mastery_model_\(model.modelID)")
  }
}

private struct MasteryVerbRow: View {
  let row: Mastery.VerbRow

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline, spacing: Layout.defaultSpacing) {
        Text(verbatim: row.verb.citationInfinitif)
          .font(bodyEmphasisFont)
          .foregroundStyle(Color.customRed)
          .frenchPronunciation()
        Text(verbatim: row.verb.translation)
          .font(captionFont)
          .foregroundStyle(Color.customGray)
          .lineLimit(1)
          .englishPronunciation()
      }

      FlowLayout(spacing: Layout.doubleDefaultSpacing) {
        ForEach(row.keyConjugations) { keyConjugation in
          let conjugation = keyConjugation.conjugation
          HStack(spacing: 4) {
            MasteryMark(state: keyConjugation.state)
            Text(mixedCaseString: conjugation)
              .font(captionFont)
              .foregroundStyle(Color.customForeground)
              .frenchPronunciation()
              .accessibilityLabel(Text(verbatim: conjugation.lowercased()))
          }
        }
      }
    }
    .padding(.vertical, Layout.defaultSpacing)
    .accessibilityIdentifier("mastery_verb_\(row.id)")
  }
}

private struct MasteryTenseName: View {
  let slot: QuizTenseSlot

  var body: some View {
    Text(verbatim: slot.name)
      .font(bodyEmphasisFont)
      .foregroundStyle(Color.customForeground)
      .frenchPronunciation()
      .accessibilityAddTraits(.isHeader)
  }
}

/// ● mastered, ◐ learning, ○ not yet practiced. Each state has its own shape, not only its own
/// color, and VoiceOver reads its name.
private struct MasteryMark: View {
  let state: MasteryState

  var body: some View {
    Image(systemName: state.systemImage)
      .font(.body)
      .foregroundStyle(state == .notPracticed ? Color.customGray : Color.customBlue)
      .accessibilityLabel(state.label)
  }
}

private extension Mastery.PatternRow {
  var ending: String {
    switch modelID {
    case "2-1":
      return "-ir"
    case QuizVerbPool.rendreModelID:
      return "-re"
    default:
      return "-er"
    }
  }

  var label: String {
    takesÊtre ? "\(ending) (être)" : ending
  }

  var spokenLabel: String {
    takesÊtre ? L.Mastery.familyWithÊtre(ending) : L.Mastery.family(ending)
  }
}

extension MasteryState {
  var label: String {
    switch self {
    case .learning:
      return L.Mastery.learning
    case .mastered:
      return L.Mastery.mastered
    case .notPracticed:
      return L.Mastery.notPracticed
    }
  }

  var systemImage: String {
    switch self {
    case .learning:
      return "circle.lefthalf.filled"
    case .mastered:
      return "circle.fill"
    case .notPracticed:
      return "circle"
    }
  }
}
