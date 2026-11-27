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
  @State private var hasSignaledView = false

  private var collection: VerbCollection {
    destination.collection
  }

  var body: some View {
    VerbListPage(verbs: collection.verbs, source: .list, identifierPrefix: "collection", checksOpenedVerbs: true) {
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
    }
    .onAppear {
      // A return from one of the list's verb pages is not another opening of the list.
      guard !hasSignaledView else {
        return
      }
      hasSignaledView = true
      world.analytics.signal(name: .viewCollection, parameters: collection.viewParameters(source: destination.source))
    }
    .recordsAppearance(as: "\(VerbCollectionView.self)")
  }
}

/// How many of a collection's verbs have been looked up, with a quiz on them and a share button.
struct VerbCollectionBar: View {
  let collection: VerbCollection
  @Environment(World.self) private var world
  @Environment(\.isBeneathQuiz) private var isBeneathQuiz
  @State private var isQuizzing = false

  var body: some View {
    let verbs = collection.verbs
    let openedCount = world.learnerVerbs.openedCount(of: verbs)
    let quizLength = QuizScope.collection(collection).askableCellCount(at: world.settings.quizLevel, limit: Quiz.questionCount)

    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      HStack(spacing: Layout.defaultSpacing) {
        Text(L.VerbCollection.progress(opened: openedCount, total: verbs.count))
          .smallLabel()
          .numericText()
          .accessibilityIdentifier("collection_progress")

        Spacer()

        if !isBeneathQuiz, quizLength >= QuizScope.minimumCellCount {
          Button {
            isQuizzing = true
          } label: {
            Label(L.Navigation.quiz, systemImage: "pencil.and.list.clipboard")
          }
          .accessibilityHint(L.VerbCollection.quizHint(questionCount: quizLength))
          .accessibilityIdentifier("collection_quiz_button")
        }

        ShareButton(action: share) {
          Label(L.VerbView.share, systemImage: "square.and.arrow.up")
            .labelStyle(.iconOnly)
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

  private func share(from frame: CGRect?) {
    world.analytics.signal(name: .tapShareCollection, parameters: [
      ParameterKey.collection.rawValue: collection.analyticsValue
    ])
    ShareSheet.present(
      text: collection.shareText(),
      title: collection.title,
      icon: UIImage(named: world.settings.appIcon.previewAssetName),
      anchorLabel: L.VerbView.share,
      anchorRect: frame
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
