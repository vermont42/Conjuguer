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
    UINavigationBar.appearance().backgroundColor = UIColor(Color.customBackground)
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

  func customNavigationBarItems() -> some View {
    modifier(CustomNavigationBarItems())
  }

  func funButton() -> some View {
    modifier(FunButton())
  }

  func segmentedPicker() -> some View {
    modifier(SegmentedPicker())
  }
}

private struct CustomNavigationBarItems: ViewModifier {
  @Environment(\.presentationMode) var presentationMode

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(
        leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
          HStack {
            Image(systemName: "arrow.left")
            Text(L.Navigation.back + "  ")
              .buttonLabel()
          }
        }
      )
  }
}

private struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
      .foregroundColor(.customGray)
  }
}

private struct SettingsSubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
      .foregroundColor(.customBlue)
  }
}

private struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 18))
      .foregroundColor(.customForeground)
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
      .font(Font.custom(workSansRegular, size: 20))
      .foregroundColor(.customForeground)
  }
}

private struct ConstrainedBodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 20))
      .foregroundColor(.customForeground)
      .dynamicTypeSize(...DynamicTypeSize.xLarge)
  }
}

private struct SmallLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16))
      .foregroundColor(.customGray)
  }
}

private struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16))
      .foregroundColor(.customForeground)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
  }
}

private struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 22))
      .accessibility(addTraits: [.isHeader])
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
      .pickerStyle(SegmentedPickerStyle())
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

private struct FunButton: ViewModifier {
  func body(content: Content) -> some View {
    content
      .foregroundColor(Color.customRed)
      .buttonStyle(.bordered)
      .tint(.customRed)
  }
}
