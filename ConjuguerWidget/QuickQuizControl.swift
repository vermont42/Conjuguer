//
//  QuickQuizControl.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct QuickQuizControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "QuickQuizControl") {
      ControlWidgetButton(action: OpenQuizIntent()) {
        Label {
          Text(WidgetL.Controls.quickQuizName)
        } icon: {
          Image(systemName: "pencil.circle.fill")
        }
      }
    }
    .displayName(WidgetL.Controls.quickQuizName)
    .description(WidgetL.Controls.quickQuizDescription)
  }
}
