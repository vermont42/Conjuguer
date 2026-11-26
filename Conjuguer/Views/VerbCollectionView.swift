//
//  VerbCollectionView.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// A featured collection's page: its description, how many of its verbs have been looked up, a
/// quiz on it, a share button, and its verbs, the most frequent first. A model's collection shows
/// inside the model's page instead, as `VerbCollectionBar` in its verbs card.
struct VerbCollectionView: View {
  let destination: VerbCollectionDestination
  @Environment(World.self) private var world
  @Environment(\.verbPagePush) private var push
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var order = VerbSort.frequency
  @State private var hasSignaledView = false

  private var collection: VerbCollection {
    destination.collection
  }

  private var orderedVerbs: [Verb] {
    switch order {
    case .frequency:
      return collection.verbs
    case .alphabetical:
      return collection.verbs.sorted { lhs, rhs in
        lhs.infinitifWithPossibleExtraLetters.compare(rhs.infinitifWithPossibleExtraLetters, locale: Util.french) == .orderedAscending
      }
    }
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
        HStack(alignment: .firstTextBaseline) {
          Image(systemName: collection.systemImageName)
            .foregroundStyle(Color.customRed)
          Text(collection.title)
        }
        .headingLabel()
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)

        Text(collection.shortDescription)
          .bodyLabel()
          .card()

        VerbCollectionBar(collection: collection)
          .card()

        Picker(L.BrowseView.sortOrder, selection: $order) {
          ForEach(VerbSort.allCases, id: \.self) { order in
            Text(order.displayName)
              .tag(order)
          }
        }
        .pickerStyle(.segmented)
        .sensoryFeedback(.selection, trigger: order)
        .accessibilityIdentifier("collection_sort_order")

        verbList
      }
      .padding(.horizontal, Layout.doubleDefaultSpacing)
      .padding(.bottom, Layout.doubleDefaultSpacing)
    }
    .screenBackground()
    .navigationBarTitleDisplayMode(.inline)
    .onAppear {
      // A return from one of the list's verb pages is not another opening of the list.
      guard !hasSignaledView else {
        return
      }
      hasSignaledView = true
      collection.signalView(source: destination.source)
    }
    .recordsAppearance(as: "\(VerbCollectionView.self)")
  }

  @ViewBuilder
  private var verbList: some View {
    if horizontalSizeClass == .regular {
      LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
        verbRows
      }
    } else {
      LazyVStack(alignment: .leading, spacing: Layout.defaultSpacing) {
        verbRows
      }
    }
  }

  private var verbRows: some View {
    ForEach(orderedVerbs) { verb in
      Button {
        push(.verb(VerbDestination(verb: verb, source: .list)))
      } label: {
        BrowseRow(
          title: verb.infinitifWithPossibleExtraLetters,
          subtitle: verb.translation,
          isChecked: world.learnerVerbs.hasOpened(verb),
          badge: BrowseRow.Badge(text: "#\(verb.frequency)", tint: .customBlue)
        )
        .card()
      }
      .buttonStyle(.plain)
      .accessibilityIdentifier("collection_verb_\(verb.dictionaryKey)")
    }
  }
}

/// How many of a collection's verbs have been looked up, with a quiz on them and a share button.
struct VerbCollectionBar: View {
  let collection: VerbCollection
  @Environment(World.self) private var world
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @State private var isQuizzing = false
  @State private var shareButtonFrame = CGRect.zero

  var body: some View {
    let verbs = collection.verbs
    let openedCount = world.learnerVerbs.openedCount(of: verbs)

    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(spacing: Layout.defaultSpacing) {
        Text(L.VerbCollection.progress(opened: openedCount, total: verbs.count))
          .smallLabel()
          .numericText()
          .accessibilityIdentifier("collection_progress")

        Spacer()

        if !isBeneathQuiz, verbs.contains(where: { $0.canBeQuizzed(at: world.settings.quizLevel) }) {
          Button {
            isQuizzing = true
          } label: {
            Label(L.Navigation.quiz, systemImage: "pencil.and.list.clipboard")
          }
          .accessibilityHint(L.VerbCollection.quizHint(questionCount: Quiz.questionCount))
          .accessibilityIdentifier("collection_quiz_button")
        }

        Button {
          share()
        } label: {
          Label(L.VerbView.share, systemImage: "square.and.arrow.up")
            .labelStyle(.iconOnly)
        }
        .onGeometryChange(for: CGRect.self) { proxy in
          proxy.frame(in: .global)
        } action: { frame in
          shareButtonFrame = frame
        }
        .accessibilityIdentifier("collection_share_button")
      }
      .buttonStyle(.bordered)
      .tint(.customRed)

      ProgressView(value: Double(openedCount), total: Double(max(verbs.count, 1)))
        .tint(.customRed)
        .accessibilityHidden(true)
    }
    .sheet(isPresented: $isQuizzing) {
      QuizSheet(scope: .collection(collection))
    }
  }

  private func share() {
    world.analytics.signal(name: .tapShareCollection, parameters: [
      ParameterKey.collection.rawValue: collection.analyticsValue
    ])
    ShareSheet.present(
      text: collection.shareText(),
      title: collection.title,
      icon: UIImage(named: world.settings.appIcon.previewAssetName),
      anchorLabel: L.VerbView.share,
      anchorRect: shareButtonFrame == .zero ? nil : shareButtonFrame
    )
  }
}

/// A featured collection in the Models tab: a row on iPhone, a card on iPad.
struct VerbCollectionRow: View {
  let collection: VerbCollection
  @Environment(World.self) private var world

  var body: some View {
    let verbs = collection.verbs
    let openedCount = world.learnerVerbs.openedCount(of: verbs)

    HStack(alignment: .top, spacing: Layout.doubleDefaultSpacing) {
      Image(systemName: collection.systemImageName)
        .font(.title3)
        .foregroundStyle(Color.customRed)
        .frame(width: 28)

      VStack(alignment: .leading, spacing: 2) {
        Text(collection.title)
          .tableText()
        Text(collection.shortDescription)
          .smallLabel()
          .lineLimit(2)
        ProgressView(value: Double(openedCount), total: Double(max(verbs.count, 1)))
          .tint(.customRed)
          .padding(.top, 4)
      }

      Spacer(minLength: 0)

      Text(verbatim: "\(openedCount.formatted())/\(verbs.count.formatted())")
        .font(browseBadgeFont)
        .foregroundStyle(Color.customGray)
        .numericText()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .contentShape(.rect)
    .accessibilityElement(children: .ignore)
    .accessibilityLabel(Text(collection.title))
    .accessibilityValue(Text(L.VerbCollection.progress(opened: openedCount, total: verbs.count)))
  }
}
