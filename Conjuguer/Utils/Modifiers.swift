//
//  Modifiers.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/28/21.
//

import SwiftUI

private let workSans = "Work Sans"

let bodyFont = Font.custom(workSans, size: 20)

func displayFontFamilyNames() {
  for family: String in UIFont.familyNames {
    print("\(family)")
    for names: String in UIFont.fontNames(forFamilyName: family) {
      print("== \(names)")
    }
  }
}

enum Modifiers {
  static func setTitleAttributes() {
    UIFont(name: workSans, size: 36).map {
      UINavigationBar.appearance().largeTitleTextAttributes = [.font: $0]
    }

    UIFont(name: workSans, size: 20).map {
      UINavigationBar.appearance().titleTextAttributes = [.font: $0]
    }
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
        })
  }
}

struct SubheadingLabel: ViewModifier {
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 20))
      .foregroundColor(colorScheme == .dark ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
  }
}

struct TableText: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 18))
  }
}

struct BodyLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 20))
  }
}

struct SmallLabel: ViewModifier {
  @Environment(\.colorScheme) var colorScheme

  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 16))
      .foregroundColor(colorScheme == .dark ? Color(UIColor.lightGray) : Color(UIColor.darkGray))
  }
}

struct ButtonLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 20))
  }
}

struct HeadingLabel: ViewModifier {
  func body(content: Content) -> some View {
    content
      .font(Font.custom(workSans, size: 24))
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

  func bodyLabel() -> some View {
    modifier(BodyLabel())
  }

  func smallLabel() -> some View {
    modifier(SmallLabel())
  }

  func headingLabel() -> some View {
    modifier(HeadingLabel())
  }

  func customNavigationBarItems() -> some View {
    modifier(CustomNavigationBarItems())
  }
}
