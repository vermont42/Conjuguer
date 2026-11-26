//
//  MyVerbsList.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

/// The starred verbs, then the recent ones not starred. Search ignores this choice, as it ignores
/// the sort order. A swipe deletes a verb, star and opens alike, so it leaves the list; a starred
/// verb asks first, since its star was put there on purpose. It is a `List` of its own, because
/// only a `List`'s rows can be swiped to delete.
struct MyVerbsList: View {
  let open: (VerbDestination) -> Void

  @Environment(World.self) private var world
  @State private var verbToUnstar: Verb?

  var body: some View {
    let starred = world.learnerVerbs.starredVerbs
    let recent = world.learnerVerbs.recentUnstarredVerbs
    if starred.isEmpty, recent.isEmpty {
      ContentUnavailableView(L.MyVerbs.emptyTitle, systemImage: "star", description: Text(L.MyVerbs.emptyDescription))
        .frame(maxHeight: .infinity)
        .accessibilityIdentifier("my_verbs_empty")
    } else {
      List {
        if !starred.isEmpty {
          Section {
            ForEach(starred) { verb in
              row(verb)
                .swipeActions(edge: .trailing) {
                  // Not .destructive: that role removes the row at once, before the learner answers.
                  Button {
                    verbToUnstar = verb
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "star.slash")
                  }
                  .tint(.customRed)
                }
            }
          } header: {
            heading(L.MyVerbs.starred)
              .accessibilityIdentifier("my_verbs_starred_heading")
          }
        }

        if !recent.isEmpty {
          Section {
            ForEach(recent) { verb in
              row(verb)
                .swipeActions(edge: .trailing) {
                  Button(role: .destructive) {
                    withAnimation {
                      world.learnerVerbs.remove(verb)
                    }
                  } label: {
                    Label(L.MyVerbs.delete, systemImage: "trash")
                  }
                }
            }
          } header: {
            HStack(alignment: .firstTextBaseline) {
              heading(L.MyVerbs.recent)
                .accessibilityIdentifier("my_verbs_recent_heading")

              Spacer()

              Button(L.MyVerbs.clearRecent) {
                withAnimation {
                  world.learnerVerbs.clearRecents()
                }
              }
              .buttonStyle(.borderless)
              .tint(.customRed)
              .accessibilityIdentifier("my_verbs_clear_recent")
            }
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
      .accessibilityIdentifier("my_verbs_list")
      .alert(
        L.MyVerbs.unstarTitle(verbToUnstar?.infinitifWithPossibleExtraLetters ?? ""),
        isPresented: Binding(
          get: { verbToUnstar != nil },
          set: { isPresented in
            if !isPresented {
              verbToUnstar = nil
            }
          }
        ),
        presenting: verbToUnstar
      ) { verb in
        Button(L.MyVerbs.unstarConfirm, role: .destructive) {
          withAnimation {
            world.learnerVerbs.remove(verb)
          }
        }
        Button(role: .cancel) {}
      } message: { _ in
        Text(L.MyVerbs.unstarMessage)
      }
    }
  }

  private func heading(_ text: String) -> some View {
    Text(text)
      .subheadingLabel()
      .accessibilityAddTraits(.isHeader)
  }

  private func row(_ verb: Verb) -> some View {
    Button {
      open(VerbDestination(verb: verb, source: .myVerbs))
    } label: {
      BrowseRow(verb: verb)
    }
    .buttonStyle(.plain)
    .accessibilityIdentifier(VerbBrowseView.rowIdentifier(verb))
    .listRowBackground(Color.customBackground)
  }
}
