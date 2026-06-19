//
//  RandomVerbControl.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct RandomVerbControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "RandomVerbControl") {
      ControlWidgetButton(action: OpenRandomVerbIntent()) {
        Label {
          Text(WidgetL.Controls.randomVerbName)
        } icon: {
          Image(systemName: "shuffle")
        }
      }
    }
    .displayName(WidgetL.Controls.randomVerbName)
    .description(WidgetL.Controls.randomVerbDescription)
  }
}
