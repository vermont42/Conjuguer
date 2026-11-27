//
//  TenseCards.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// One tense's card on the verb page: its heading and its six cells, or four for the impératif.
struct TenseSectionView: View {
  let section: VerbConjugations.Section
  let marks: MarkedConjugations?
  let openArticle: (Tense) -> (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      TenseHeading(tense: section.table.representative, openArticle: openArticle(section.table.representative))

      Grid(alignment: .leading, horizontalSpacing: Layout.doubleDefaultSpacing, verticalSpacing: 8) {
        ForEach(section.cells) { cell in
          GridRow(alignment: .firstTextBaseline) {
            Text(cell.pronoun)
              .smallLabel()
              .frenchPronunciation()
              .gridColumnAlignment(.leading)
              .accessibilityHidden(true)

            MarkableConjugation(cell: cell, isMarked: marks?.contains(cell.tense) == true)
              .gridColumnAlignment(.leading)
          }
        }
      }
    }
  }
}

/// The card of the participes and the radical du futur, each cell under a heading of its own.
struct PersonlessCard: View {
  let cells: [VerbConjugations.Cell]
  let marks: MarkedConjugations?
  let openArticle: (Tense) -> (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      ForEach(cells) { cell in
        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          TenseHeading(tense: cell.tense, openArticle: openArticle(cell.tense))

          MarkableConjugation(cell: cell, isMarked: marks?.contains(cell.tense) == true)
            .leftAligned()
        }
      }
    }
  }
}

/// A tense's name, the name a textbook also uses, and a button that opens the tense's article.
struct TenseHeading: View {
  let tense: Tense
  let openArticle: (() -> Void)?

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(tense.titleCaseName)
          .subheadingLabel()
          .frenchPronunciation()
          .accessibilityAddTraits(.isHeader)

        if let openArticle {
          ArticleButton(hint: L.VerbView.articleButtonHint, action: openArticle)
        }

        Spacer(minLength: 0)
      }

      if let secondName = tense.secondName {
        Text(L.VerbView.secondName(secondName))
          .smallLabel()
      }
    }
  }
}

struct MarkableConjugation: View {
  let cell: VerbConjugations.Cell
  let isMarked: Bool

  var body: some View {
    Text(cell.display)
      .font(bodyFont)
      .frenchPronunciation()
      .accessibilityLabel(cell.accessibility)
      .accessibilityValue(Text(isMarked ? L.VerbView.matchesSearch : ""))
      .background {
        if isMarked {
          RoundedRectangle(cornerRadius: 6)
            .fill(Color.markedConjugation)
            .padding(-4)
        }
      }
      .copyOnLongPress(cell.copyText)
  }
}
