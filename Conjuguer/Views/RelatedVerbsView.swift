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
    .accessibilityIdentifier("related_\(verb.infinitif)")
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

struct RelatedVerbListView: View {
  let root: String
  let verbs: [Verb]
  @Environment(\.verbPagePush) private var push
  @State private var order = VerbSort.frequency

  private var orderedVerbs: [Verb] {
    switch order {
    case .frequency:
      return verbs.sorted(by: Verb.byFrequency)
    case .alphabetical:
      return verbs.sorted { lhs, rhs in
        lhs.infinitif.compare(rhs.infinitif, locale: Util.french) == .orderedAscending
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        Picker(L.BrowseView.sortOrder, selection: $order) {
          ForEach(VerbSort.allCases, id: \.self) { order in
            Text(order.displayName)
              .tag(order)
          }
        }
        .pickerStyle(.segmented)
        .sensoryFeedback(.selection, trigger: order)
        .accessibilityIdentifier("related_list_sort")

        VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
          ForEach(orderedVerbs) { verb in
            Button {
              push(.verb(VerbDestination(verb: verb, source: .related)))
            } label: {
              BrowseRow(
                title: verb.infinitifWithPossibleExtraLetters,
                subtitle: verb.translation,
                badge: BrowseRow.Badge(text: "#\(verb.frequency)", tint: .customBlue)
              )
              .card()
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("related_list_\(verb.infinitif)")
          }
        }
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .navigationTitle(L.VerbView.builtOn(root))
    .navigationBarTitleDisplayMode(.inline)
    .recordsAppearance(as: "\(RelatedVerbListView.self)")
  }
}

struct FlowLayout: SwiftUI.Layout {
  var spacing: CGFloat = 8

  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let rows = rows(for: subviews, width: proposal.width ?? .infinity)
    let height = rows.map(\.height).reduce(0, +) + spacing * CGFloat(max(rows.count - 1, 0))
    let width = rows.map(\.width).max() ?? 0
    return CGSize(width: proposal.width ?? width, height: height)
  }

  func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
    var y = bounds.minY
    for row in rows(for: subviews, width: bounds.width) {
      var x = bounds.minX
      for index in row.indices {
        let size = subviews[index].sizeThatFits(.unspecified)
        // Centered in its row, so that a sentence's words line up with the field between them.
        subviews[index].place(at: CGPoint(x: x, y: y + (row.height - size.height) / 2), proposal: ProposedViewSize(size))
        x += size.width + spacing
      }
      y += row.height + spacing
    }
  }

  private struct Row {
    var indices: [Int] = []
    var width: CGFloat = 0
    var height: CGFloat = 0
  }

  private func rows(for subviews: Subviews, width: CGFloat) -> [Row] {
    var rows: [Row] = []
    var current = Row()
    for index in subviews.indices {
      let size = subviews[index].sizeThatFits(.unspecified)
      let widthWithChild = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      if widthWithChild > width, !current.indices.isEmpty {
        rows.append(current)
        current = Row()
      }
      current.width = current.indices.isEmpty ? size.width : current.width + spacing + size.width
      current.height = max(current.height, size.height)
      current.indices.append(index)
    }
    if !current.indices.isEmpty {
      rows.append(current)
    }
    return rows
  }
}
