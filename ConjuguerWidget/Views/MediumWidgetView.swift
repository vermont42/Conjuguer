//
//  MediumWidgetView.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct MediumWidgetView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      HStack(alignment: .firstTextBaseline, spacing: 6) {
        Text(snapshot.infinitif)
          .font(.title3)
          .fontWeight(.bold)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
          .layoutPriority(1)
        Text(verbatim: "— \(snapshot.translation)")
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }

      Spacer(minLength: 0)

      HStack(alignment: .top, spacing: 12) {
        conjugationColumn(Array(snapshot.présentParadigm.prefix(3)))
        conjugationColumn(Array(snapshot.présentParadigm.suffix(3)))
      }

      Spacer(minLength: 0)

      HStack(spacing: 3) {
        Text(verbatim: "pp :")
          .foregroundStyle(.secondary)
        Text(mixedCase: snapshot.participePassé)
          .fontWeight(.medium)
      }
      .font(.caption)
      .lineLimit(1)
      .minimumScaleFactor(0.7)
    }
    .widgetURL(WidgetDeeplink.verb(snapshot.infinitif))
  }

  private func conjugationColumn(_ conjugations: [WidgetConjugation]) -> some View {
    VStack(alignment: .leading, spacing: 5) {
      ForEach(Array(conjugations.enumerated()), id: \.offset) { _, conjugation in
        HStack(spacing: 6) {
          Text(conjugation.pronoun)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(width: 42, alignment: .trailing)
          Text(mixedCase: conjugation.form)
            .font(.subheadline)
            .fontWeight(.semibold)
            .lineLimit(1)
            .minimumScaleFactor(0.6)
        }
      }
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}
