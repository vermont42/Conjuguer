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

  // Consider using this code to customize segmentedControl and further customize navBar.
  // May need to rename setTitleAttributes().
  //  UISegmentedControl.appearance().selectedSegmentTintColor = .blue
  //  UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
  //  UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.blue], for: .normal)
  //  UINavigationBar.appearance().backgroundColor = .black
  //  UINavigationBar.appearance().tintColor = .white
  //  UINavigationBar.appearance().barTintColor = .black
}

struct CustomNavigationBarItems: ViewModifier {
  @Environment(\.presentationMode) var presentationMode

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden(true)
      .navigationBarItems(
        leading: Button(action: { presentationMode.wrappedValue.dismiss() }) {
          HStack {
            Image(systemName: "arrow.left")
            Text(L.Navigation.back + "  ")
              .modifier(ButtonLabel())
          }
        }
      )
  }
}

struct SubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
      .foregroundColor(.customGray)
  }
}

struct SettingsSubheadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
      .foregroundColor(.customBlue)
  }
}

struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 18))
      .foregroundColor(.customForeground)
  }
}

struct BodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 20))
      .foregroundColor(.customForeground)
  }
}

struct SmallLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16))
      .foregroundColor(.customGray)
  }
}

struct SettingsLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansRegular, size: 16))
      .foregroundColor(.customForeground)
      .padding(.horizontal, Layout.doubleDefaultSpacing)
  }
}

struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 20))
  }
}

struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSansSemiBold, size: 24))
  }
}

struct LeftAligned: ViewModifier {
  func body(content: Content) -> some View {
    HStack {
      content
      Spacer()
    }
  }
}

struct RightAligned: ViewModifier {
  func body(content: Content) -> some View {
    HStack {
      Spacer()
      content
    }
  }
}

struct SegmentedPicker: ViewModifier {
  func body(content: Content) -> some View {
    content
      .pickerStyle(SegmentedPickerStyle())
      .padding(.horizontal, Layout.doubleDefaultSpacing)
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

  func subheadingLabel() -> some View {
    modifier(SubheadingLabel())
  }

  func settingsSubheadingLabel() -> some View {
    modifier(SettingsSubheadingLabel())
  }

  func bodyLabel() -> some View {
    modifier(BodyLabel())
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
}
