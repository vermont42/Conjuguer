//
//  InfoBrowseView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/3/21.
//

import SwiftUI

struct InfoBrowseView: View {
  @Environment(World.self) private var world
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var navigationPath = NavigationPath()

  private static let tutorRoute = "tutor"

  var body: some View {
    @Bindable var world = world

    NavigationStack(path: $navigationPath) {
      ZStack {
        Color.customBackground

        infoCollection
      }
      .navigationTitle(L.Navigation.info)
      .navigationDestination(for: Info.self) { info in
        InfoView(info: info)
      }
      .navigationDestination(for: String.self) { destination in
        if destination == Self.tutorRoute {
          TutorView()
        }
      }
      .task(id: world.shouldNavigateToTutor) {
        guard world.shouldNavigateToTutor else {
          return
        }
        try? await Task.sleep(for: .milliseconds(500))
        world.shouldNavigateToTutor = false
        navigationPath.append(Self.tutorRoute)
      }
    }
    .screenBackground()
    .sheet(item: $world.info) { info in
      InfoView(info: info, shouldShowInfoHeading: true)
        .sheetDismissable()
    }
    .sheet(item: $world.verb) { verb in
      VerbView(verb: verb)
        .sheetDismissable()
    }
    .recordsAppearance(as: "\(InfoBrowseView.self)")
  }

  @ViewBuilder
  private var infoCollection: some View {
    if horizontalSizeClass == .regular {
      ScrollView {
        LazyVStack(alignment: .leading, spacing: Layout.tripleDefaultSpacing) {
          ForEach(Info.sections, id: \.category) { section in
            VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
              Text(section.category.title)
                .subheadingLabel()

              LazyVGrid(columns: BrowseLayout.columns, spacing: Layout.doubleDefaultSpacing) {
                ForEach(section.infos) { info in
                  NavigationLink(value: info) {
                    infoCell(info)
                      .card()
                  }
                  .buttonStyle(.plain)
                }

                if section.category == .concepts {
                  tutorGridCell
                }
              }
            }
          }
        }
        .padding()
      }
      .scrollContentBackground(.hidden)
    } else {
      List {
        ForEach(Info.sections, id: \.category) { section in
          Section {
            ForEach(section.infos) { info in
              NavigationLink(value: info) {
                infoCell(info)
              }
              .listRowBackground(Color.customBackground)
            }

            if section.category == .concepts {
              tutorListRow
                .listRowBackground(Color.customBackground)
            }
          } header: {
            Text(section.category.title)
              .subheadingLabel()
          }
        }
      }
      .listStyle(.plain)
      .scrollContentBackground(.hidden)
    }
  }

  private func infoCell(_ info: Info) -> some View {
    Text(info.heading)
      .tableText()
      .frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)
  }

  @ViewBuilder
  private var tutorListRow: some View {
    if world.languageModelService.isAvailable {
      NavigationLink(value: Self.tutorRoute) {
        tutorCell
      }
    } else if let reason = world.languageModelService.unavailabilityReason {
      tutorUnavailableCell(reason: reason)
    }
  }

  @ViewBuilder
  private var tutorGridCell: some View {
    if world.languageModelService.isAvailable {
      NavigationLink(value: Self.tutorRoute) {
        tutorCell
          .card()
      }
      .buttonStyle(.plain)
    } else if let reason = world.languageModelService.unavailabilityReason {
      tutorUnavailableCell(reason: reason)
        .card()
    }
  }

  private var tutorCell: some View {
    HStack(spacing: Layout.defaultSpacing) {
      Text(L.Tutor.heading)
        .tableText()

      Image(systemName: "brain.head.profile.fill")
        .font(.title3)
        .foregroundStyle(Color.customBlue)
        .symbolEffect(.pulse, options: .repeating)
        .accessibilityHidden(true)

      Spacer(minLength: 0)
    }
    .contentShape(Rectangle())
  }

  private func tutorUnavailableCell(reason: LanguageModelUnavailability) -> some View {
    HStack(alignment: .top, spacing: Layout.defaultSpacing) {
      VStack(alignment: .leading, spacing: 4) {
        Text(L.Tutor.heading)
          .tableText()

        Text(reasonText(reason))
          .font(.subheadline)
          .foregroundStyle(Color.customGray)
          .fixedSize(horizontal: false, vertical: true)
      }

      Spacer(minLength: 0)

      Image(systemName: unavailableIcon(reason))
        .font(.title3)
        .foregroundStyle(Color.customBlue.opacity(0.5))
        .accessibilityHidden(true)
    }
    .contentShape(Rectangle())
    .onTapGesture {
      guard reason == .appleIntelligenceNotEnabled, let url = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      UIApplication.shared.open(url)
    }
  }

  private func reasonText(_ reason: LanguageModelUnavailability) -> String {
    switch reason {
    case .appleIntelligenceNotEnabled:
      return L.Tutor.reasonAppleIntelligenceOff
    case .deviceNotEligible:
      return L.Tutor.reasonDeviceNotEligible
    case .modelNotReady:
      return L.Tutor.reasonModelNotReady
    case .unknown:
      return L.Tutor.reasonUnknown
    }
  }

  private func unavailableIcon(_ reason: LanguageModelUnavailability) -> String {
    switch reason {
    case .appleIntelligenceNotEnabled:
      return "gear.badge.questionmark"
    case .deviceNotEligible:
      return "exclamationmark.circle"
    case .modelNotReady:
      return "arrow.down.circle.dotted"
    case .unknown:
      return "questionmark.circle"
    }
  }
}
