//
//  Modifiers.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

enum Modifiers {
  static func modifyAppearances() {
    let navBarAppearance = UINavigationBarAppearance()
    navBarAppearance.configureWithOpaqueBackground()
    navBarAppearance.backgroundColor = UIColor(Color.customBackground)
    navBarAppearance.shadowColor = .clear
    UIFont(name: workSansSemiBold, size: 24).map {
      navBarAppearance.largeTitleTextAttributes = [.font: $0, .foregroundColor: UIColor(Color.customBlue)]
    }
    UIFont(name: workSansSemiBold, size: 18).map {
      navBarAppearance.titleTextAttributes = [.font: $0, .foregroundColor: UIColor(Color.customBlue)]
    }
    UINavigationBar.appearance().standardAppearance = navBarAppearance
    UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
    UINavigationBar.appearance().compactAppearance = navBarAppearance

    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.customBlue)], for: .selected)
    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor(Color.customBlue)], for: .normal)
  }
}

extension View {
  func leftAligned() -> some View {
    modifier(LeftAligned())
  }

  func rightAligned() -> some View {
    modifier(RightAligned())
  }

  func tableText() -> some View {
    modifier(TableText())
  }

  func frenchPronunciation(forReal: Bool = true) -> some View {
    modifier(FrenchPronunciation(forReal: forReal))
  }

  func englishPronunciation() -> some View {
    modifier(EnglishPronunciation())
  }

  func subheadingLabel() -> some View {
    modifier(SubheadingLabel())
  }

  func bodyLabel() -> some View {
    modifier(BodyLabel())
  }

  func smallLabel() -> some View {
    modifier(SmallLabel())
  }

  func translationLabel() -> some View {
    modifier(TranslationLabel())
  }

  func settingsLabel() -> some View {
    modifier(SettingsLabel())
  }

  func headingLabel() -> some View {
    modifier(HeadingLabel())
  }

  func headingForegroundLabel() -> some View {
    modifier(HeadingForegroundLabel())
  }

  func buttonLabel() -> some View {
    modifier(ButtonLabel())
  }

  func funButton(tint: Color = .customBlue) -> some View {
    modifier(FunButton(tint: tint))
  }

  func card(accent: Color? = nil) -> some View {
    modifier(Card(accent: accent))
  }

  func numericText() -> some View {
    modifier(NumericText())
  }

  func scrollFade() -> some View {
    modifier(ScrollFade())
  }

  func sheetDismissable() -> some View {
    modifier(SheetDismissable())
  }

  func screenBackground() -> some View {
    modifier(ScreenBackground())
  }

  func recordsAppearance(as name: String) -> some View {
    modifier(RecordsAppearance(name: name))
  }
}

private struct RecordsAppearance: ViewModifier {
  @Environment(World.self) private var world
  let name: String

  func body(content: Content) -> some View {
    content
      .onAppear {
        world.analytics.recordViewAppeared(name)
      }
  }
}

private struct ScreenBackground: ViewModifier {
  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.customBackground.ignoresSafeArea())
  }
}

private struct SheetDismissable: ViewModifier {
  @Environment(\.dismiss) private var dismiss

  func body(content: Content) -> some View {
    NavigationStack {
      content
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button(L.Navigation.done) {
              dismiss()
            }
          }
        }
    }
  }
}

private struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(buttonFont.smallCaps())
      .tracking(0.5)
      .foregroundStyle(Color.customGray)
  }
}

private struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(tableRowFont)
      .foregroundStyle(Color.customForeground)
  }
}

private struct FrenchPronunciation: ViewModifier {
  let forReal: Bool

  func body(content: Content) -> some View {
    if forReal {
      content
        .environment(\.locale, .init(identifier: "fr-FR"))
    } else {
      content
    }
  }
}

private struct EnglishPronunciation: ViewModifier {
  func body(content: Content) -> some View {
    content
      .environment(\.locale, .init(identifier: "en-US"))
  }
}

private struct BodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(bodyFont)
      .foregroundStyle(Color.customForeground)
  }
}

private struct SmallLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(captionFont)
      .foregroundStyle(Color.customGray)
  }
}

private struct TranslationLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(bodyFont)
      .foregroundStyle(Color.customGray)
  }
}

private struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(captionFont)
      .foregroundStyle(Color.customForeground)
  }
}

private struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(buttonFont)
  }
}

private struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(headingFont)
      .foregroundStyle(Color.customBlue)
      .accessibilityAddTraits(.isHeader)
  }
}

private struct HeadingForegroundLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(headingFont)
      .foregroundStyle(Color.customForeground)
      .accessibilityAddTraits(.isHeader)
  }
}

private struct LeftAligned: ViewModifier {
  func body(content: Content) -> some View {
    HStack {
      content
      Spacer()
    }
  }
}

private struct RightAligned: ViewModifier {
  func body(content: Content) -> some View {
    HStack {
      Spacer()
      content
    }
  }
}

private struct FunButton: ViewModifier {
  var tint: Color = .customBlue

  func body(content: Content) -> some View {
    content
      .buttonStyle(.glass)
      .tint(tint)
  }
}

private struct Card: ViewModifier {
  var accent: Color?
  var cornerRadius: CGFloat = 12

  func body(content: Content) -> some View {
    content
      .frame(maxWidth: .infinity, alignment: .leading)
      .padding(Layout.doubleDefaultSpacing)
      .background(Color.customSurface)
      .overlay(alignment: .leading) {
        if let accent {
          accent.frame(width: 4)
        }
      }
      .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
  }
}

private struct NumericText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .monospacedDigit()
      .contentTransition(.numericText())
  }
}

private struct ScrollFade: ViewModifier {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  func body(content: Content) -> some View {
    let reduceMotion = reduceMotion
    return content.scrollTransition { view, phase in
      view.opacity(reduceMotion ? 1 : 1 - abs(phase.value) * 0.12)
    }
  }
}
