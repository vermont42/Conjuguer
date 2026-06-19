//
//  SmallWidgetView.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(snapshot.infinitif)
        .font(.title2)
        .fontWeight(.bold)
        .lineLimit(1)
        .minimumScaleFactor(0.7)

      Text(snapshot.translation)
        .font(.caption)
        .foregroundStyle(.secondary)
        .lineLimit(2)
        .minimumScaleFactor(0.8)

      Spacer()

      if let je = snapshot.présentParadigm.first {
        conjugationRow(je)
      }
      if let elles = snapshot.présentParadigm.last {
        conjugationRow(elles)
      }
    }
    .widgetURL(WidgetDeeplink.verb(snapshot.infinitif))
  }

  private func conjugationRow(_ conjugation: WidgetConjugation) -> some View {
    HStack(spacing: 4) {
      Text(conjugation.pronoun)
        .font(.subheadline)
        .foregroundStyle(.secondary)
      Text(mixedCase: conjugation.form)
        .font(.subheadline)
        .fontWeight(.semibold)
    }
    .lineLimit(1)
    .minimumScaleFactor(0.4)
  }
}
