//
//  FindVerbControl.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct FindVerbControl: ControlWidget {
  var body: some ControlWidgetConfiguration {
    StaticControlConfiguration(kind: "FindVerbControl") {
      ControlWidgetButton(action: OpenVerbSearchIntent()) {
        Label {
          Text(WidgetL.Controls.findVerbName)
        } icon: {
          Image(systemName: "magnifyingglass")
        }
      }
    }
    .displayName(WidgetL.Controls.findVerbName)
    .description(WidgetL.Controls.findVerbDescription)
  }
}
