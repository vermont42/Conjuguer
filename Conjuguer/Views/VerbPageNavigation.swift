//
//  VerbPageNavigation.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import SwiftUI

/// Pushes a value onto whichever navigation stack shows the verb page or the model page: the
/// Verbs tab's, the Models tab's, or a sheet's. A page that finds none in its environment presents
/// a sheet instead.
struct VerbPagePush {
  let push: (any Hashable) -> Void

  func callAsFunction(_ value: some Hashable) {
    push(value)
  }
}

extension EnvironmentValues {
  @Entry var verbPagePush: VerbPagePush?
}

/// A model page to push, in the order its verbs list opens with.
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
  /// Gives a navigation stack the pages a verb page or a model page can push, and the push action
  /// that reaches them. Apply it to the stack's root content. In a sheet, `done` puts a Done
  /// button on every pushed page, as on the sheet's first.
  func verbPageNavigation(path: Binding<NavigationPath>, done: (() -> Void)? = nil) -> some View {
    modifier(VerbPageNavigation(path: path, done: done))
  }
}

private struct VerbPageNavigation: ViewModifier {
  @Binding var path: NavigationPath
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
      .environment(\.verbPagePush, VerbPagePush { path.append($0) })
  }

  @ViewBuilder
  private func page(_ content: some View) -> some View {
    if let done {
      content
        .environment(\.verbPagePush, VerbPagePush { path.append($0) })
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button(L.Navigation.done, action: done)
          }
        }
    } else {
      content
        .environment(\.verbPagePush, VerbPagePush { path.append($0) })
    }
  }
}
