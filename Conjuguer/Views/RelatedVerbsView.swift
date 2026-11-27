//
//  RelatedVerbsView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// The verb page's ways to other verbs: a few built on the same base, and the most frequent verbs
/// of the other bases that share its model, with a way to all of each.
struct RelatedVerbsView: View {
  let related: RelatedVerbs
  @Environment(\.verbPagePush) private var push

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
      Text(L.VerbView.relatedHeading)
        .subheadingLabel()
        .accessibilityAddTraits(.isHeader)
        .accessibilityIdentifier("verb_related")

      if !related.builtOnRoot.isEmpty {
        relation(label: L.VerbView.builtOnLabel, value: related.root) {
          ForEach(related.builtOnRoot.prefix(RelatedVerbs.shortListLength)) { verb in
            verbChip(verb)
          }
          if related.builtOnRoot.count > RelatedVerbs.shortListLength {
            RelatedChip(text: L.VerbView.allRelated(related.builtOnRoot.count), isFrench: false, isBordered: true) {
              push(.relatedList(root: related.root, verbs: related.builtOnRoot))
            }
            .accessibilityIdentifier("related_all_built_on")
          }
        }
      }

      if let model = related.model, !related.modelRelatives.isEmpty {
        relation(label: L.VerbView.sameModelLabel, value: "\(model.exemplar) (\(model.id))") {
          ForEach(related.modelRelatives) { verb in
            verbChip(verb)
          }
          RelatedChip(text: L.VerbView.allRelated(model.verbs.count), isFrench: false, isBordered: true) {
            push(.model(model, order: .frequency))
          }
          .accessibilityIdentifier("related_all_model")
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .card()
  }

  /// A row's title is an interface label beside a French value, each read in its own voice, as
  /// docs/voiceover.md asks.
  private func relation(label: String, value: String, @ViewBuilder chips: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(alignment: .firstTextBaseline, spacing: 0) {
        Text(label + " ")
          .fixedSize(horizontal: true, vertical: false)
        Text(verbatim: value)
          .frenchPronunciation()
      }
      .smallLabel()
      FlowLayout(spacing: Layout.defaultSpacing) {
        chips()
      }
    }
  }

  private func verbChip(_ verb: Verb) -> some View {
    RelatedChip(text: verb.infinitifWithPossibleExtraLetters, isFrench: true) {
      push(.verb(VerbDestination(verb: verb, source: .related)))
    }
    .accessibilityIdentifier("related_\(verb.dictionaryKey)")
  }
}

/// A chip that opens a page. It is one element read in one language, with the button trait and an
/// action, rather than a `Button`, as docs/voiceover.md asks for tappable text on the verb page.
private struct RelatedChip: View {
  let text: String
  let isFrench: Bool
  var isBordered = false
  let action: () -> Void

  var body: some View {
    Text(verbatim: text)
      .font(bodyFont)
      .foregroundStyle(Color.customBlue)
      .padding(.horizontal, 10)
      .padding(.vertical, 5)
      .background(Capsule().fill(Color.customBlue.opacity(0.1)))
      .overlay {
        Capsule().strokeBorder(Color.customBlue.opacity(isBordered ? 0.5 : 0), lineWidth: 1.5)
      }
      .contentShape(Capsule())
      .frenchPronunciation(forReal: isFrench)
      .accessibilityAddTraits(.isButton)
      .accessibilityAction { action() }
      .onTapGesture(perform: action)
  }
}
