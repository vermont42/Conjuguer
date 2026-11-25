//
//  VerbPageNavigation.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// Pushes a value onto whichever navigation stack shows the verb page, the model page, a
/// collection's page, or an article: a tab's or a sheet's. A page that finds none in its
/// environment presents a sheet instead.
struct VerbPagePush {
  let push: (any Hashable) -> Void

  func callAsFunction(_ value: some Hashable) {
    push(value)
  }
}

extension EnvironmentValues {
  @Entry var verbPagePush: VerbPagePush?
  /// Whether a verb page on this stack pushes its tenses' articles rather than presenting them.
  /// Each stack sets it, so a sheet presented from inside an article sheet does not inherit it.
  @Entry var pushesTenseArticles = false
}

struct ModelDestination: Hashable {
  let model: VerbModel
  var verbOrder: VerbSort = .alphabetical
}

/// Every verb built on one root, which a verb page's short list leads to.
struct RelatedVerbListDestination: Hashable {
  let root: String
  let verbs: [Verb]
}

extension View {
  /// Gives a navigation stack the pages a verb page, a model page, or an article can push, and
  /// the push action that reaches them. Apply it to the stack's root content. In a sheet, `done`
  /// puts a Done button on every pushed page, as on the sheet's first. A stack that is about
  /// articles, the Info tab's or an article sheet's, passes `pushesTenseArticles`, so that a verb
  /// page there pushes a tense's article too, and the learner reads on in the same stack.
  func verbPageNavigation(
    path: Binding<NavigationPath>,
    pushesTenseArticles: Bool = false,
    done: (() -> Void)? = nil
  ) -> some View {
    modifier(VerbPageNavigation(path: path, pushesTenseArticles: pushesTenseArticles, done: done))
  }
}

private struct VerbPageNavigation: ViewModifier {
  @Binding var path: NavigationPath
  let pushesTenseArticles: Bool
  let done: (() -> Void)?

  func body(content: Content) -> some View {
    content
      .navigationDestination(for: VerbDestination.self) { destination in
        page(VerbView(verb: destination.verb, source: destination.source, marks: destination.marks))
      }
      .navigationDestination(for: ModelDestination.self) { destination in
        page(ModelView(model: destination.model, verbOrder: destination.verbOrder))
      }
      .navigationDestination(for: RelatedVerbListDestination.self) { destination in
        page(RelatedVerbListView(destination: destination))
      }
      .navigationDestination(for: VerbCollectionDestination.self) { destination in
        page(VerbCollectionView(destination: destination))
      }
      .navigationDestination(for: Info.self) { info in
        page(InfoView(info: info))
      }
      .environment(\.verbPagePush, VerbPagePush { path.append($0) })
      .environment(\.pushesTenseArticles, pushesTenseArticles)
  }

  @ViewBuilder
  private func page(_ content: some View) -> some View {
    if let done {
      content
        .environment(\.verbPagePush, VerbPagePush { path.append($0) })
        .environment(\.pushesTenseArticles, pushesTenseArticles)
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button(L.Navigation.done, action: done)
          }
        }
    } else {
      content
        .environment(\.verbPagePush, VerbPagePush { path.append($0) })
        .environment(\.pushesTenseArticles, pushesTenseArticles)
    }
  }
}
