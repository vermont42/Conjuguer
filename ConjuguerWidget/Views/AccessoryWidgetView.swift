//
//  AccessoryWidgetView.swift
//  ConjuguerWidget
//
//  Lock Screen accessory presentations.
//

import SwiftUI
import WidgetKit

struct AccessoryRectangularView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 2) {
      Text(snapshot.infinitif)
        .font(.headline)
        .widgetAccentable()
      Text(snapshot.translation)
        .font(.caption)
        .lineLimit(1)
      if let thirdSingular = snapshot.présentParadigm.dropFirst(2).first {
        Text(verbatim: "\(thirdSingular.pronoun) \(thirdSingular.form.lowercased())")
          .font(.caption2)
      }
    }
    .widgetURL(WidgetDeeplink.verb(snapshot.infinitif))
  }
}

struct AccessoryInlineView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    Text(verbatim: "\(snapshot.infinitif) — \(snapshot.translation)")
      .widgetURL(WidgetDeeplink.verb(snapshot.infinitif))
  }
}
