//
//  Modifiers.swift
//  Conjuguer
//
//  Created by Josh Adams on 2/28/21.
//

import SwiftUI

enum Modifiers {
  static func modifyAppearances() {
    UIFont(name: workSansSemiBold, size: 24).map {
      UINavigationBar.appearance().largeTitleTextAttributes = [.font: $0, .foregroundColor: UIColor(Color.customBlue)]
    }
    UIFont(name: workSansSemiBold, size: 18).map {
      UINavigationBar.appearance().titleTextAttributes = [.font: $0, .foregroundColor: UIColor(Color.customBlue)]
    }
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

  func settingsSubheadingLabel() -> some View {
    modifier(SettingsSubheadingLabel())
  }

  func bodyLabel() -> some View {
    modifier(BodyLabel())
  }

  func constrainedBodyLabel() -> some View {
    modifier(ConstrainedBodyLabel())
  }

  func smallLabel() -> some View {
    modifier(SmallLabel())
  }

  func settingsLabel() -> some View {
    modifier(SettingsLabel())
  }

  func headingLabel() -> some View {
    modifier(HeadingLabel())
  }

  func buttonLabel() -> some View {
    modifier(ButtonLabel())
  }

  func funButton() -> some View {
    modifier(FunButton())
  }

  func segmentedPicker() -> some View {
    modifier(SegmentedPicker())
  }

  func sheetDismissable() -> some View {
    modifier(SheetDismissable())
  }

  func screenBackground() -> some View {
    modifier(ScreenBackground())
  }
}

// The full-screen custom background, applied as a `.background(...)` decoration rather than a
// repeated `ZStack { Color.customBackground.ignoresSafeArea() … }` peer (#20). The frame keeps
// the decorated view filling the screen so the background extends into the safe areas, matching
// the old ZStack behavior for both greedy and intrinsically-sized content.
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
      .font(Font.custom(workSansSemiBold, size: 20, relativeTo: .title3))
      .foregroundStyle(Color.customGray)
  }
}

private struct SettingsSubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20, relativeTo: .title3))
      .foregroundStyle(Color.customBlue)
  }
}

private struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 18, relativeTo: .body))
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
      .font(Font.custom(workSansRegular, size: 20, relativeTo: .body))
      .foregroundStyle(Color.customForeground)
  }
}

private struct ConstrainedBodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 20, relativeTo: .body))
      .foregroundStyle(Color.customForeground)
      .dynamicTypeSize(...DynamicTypeSize.xLarge)
  }
}

private struct SmallLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16, relativeTo: .callout))
      .foregroundStyle(Color.customGray)
  }
}

private struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16, relativeTo: .callout))
      .foregroundStyle(Color.customForeground)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20, relativeTo: .title3))
  }
}

private struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 22, relativeTo: .title))
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

private struct SegmentedPicker: ViewModifier {
  func body(content: Content) -> some View {
    content
      .pickerStyle(.segmented)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct FunButton: ViewModifier {
  func body(content: Content) -> some View {
    content
      .buttonStyle(.glass)
      .tint(.customRed)
  }
}
