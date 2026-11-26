//
//  VerbPageNavigation.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// A page that a verb page, a model page, a collection's page, or an article leads to. Every stack
/// that shows one registers all of them through `verbPageNavigation`, so none can be pushed where
/// it has no page.
enum VerbPageRoute: Hashable {
  case verb(VerbDestination)
  case model(VerbModel, order: VerbSort = .alphabetical)
  /// Every verb built on one root, which a verb page's short list leads to.
  case relatedList(root: String, verbs: [Verb])
  case collection(VerbCollectionDestination)
  case article(Info)
}

/// Pushes a route onto whichever navigation stack shows the page: a tab's or a sheet's.
struct VerbPagePush {
  let push: (VerbPageRoute) -> Void

  func callAsFunction(_ route: VerbPageRoute) {
    push(route)
  }
}

extension EnvironmentValues {
  /// Every page that pushes is inside a stack that sets this, a sheet's included, so the default
  /// is reached only by a view shown with no stack around it.
  @Entry var verbPagePush = VerbPagePush { route in
    assertionFailure("No stack applies verbPageNavigation above the view that pushed \(route).")
  }
  /// Whether a verb page on this stack pushes its tenses' articles rather than presenting them.
  /// Each stack sets it, so a sheet presented from inside an article sheet does not inherit it.
  @Entry var pushesTenseArticles = false
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
      .navigationDestination(for: VerbPageRoute.self) { route in
        page(route)
          .toolbar {
            if let done {
              ToolbarItem(placement: .topBarTrailing) {
                Button(L.Navigation.done, action: done)
              }
            }
          }
          .navigationEnvironment(push: push, pushesTenseArticles: pushesTenseArticles)
      }
      .navigationEnvironment(push: push, pushesTenseArticles: pushesTenseArticles)
  }

  private var push: VerbPagePush {
    VerbPagePush { path.append($0) }
  }

  @ViewBuilder
  private func page(_ route: VerbPageRoute) -> some View {
    switch route {
    case .verb(let destination):
      VerbView(verb: destination.verb, source: destination.source, marks: destination.marks)
    case let .model(model, order):
      ModelView(model: model, verbOrder: order)
    case let .relatedList(root, verbs):
      RelatedVerbListView(root: root, verbs: verbs)
    case .collection(let destination):
      VerbCollectionView(destination: destination)
    case .article(let info):
      InfoView(info: info)
    }
  }
}

private extension View {
  func navigationEnvironment(push: VerbPagePush, pushesTenseArticles: Bool) -> some View {
    environment(\.verbPagePush, push)
      .environment(\.pushesTenseArticles, pushesTenseArticles)
  }
}
