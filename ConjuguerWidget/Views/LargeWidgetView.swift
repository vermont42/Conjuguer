//
//  LargeWidgetView.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

struct LargeWidgetView: View {
  let snapshot: WidgetSnapshot

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      HStack(alignment: .firstTextBaseline) {
        Text(snapshot.infinitif)
          .font(.title3)
          .fontWeight(.bold)
        Text(verbatim: "— \(snapshot.translation)")
          .font(.caption)
          .foregroundStyle(.secondary)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
        Spacer()
      }

      HStack(spacing: 4) {
        Text(verbatim: "pp :")
        Text(mixedCase: snapshot.participePassé)
          .fontWeight(.medium)
      }
      .font(.caption2)
      .foregroundStyle(.secondary)

      Divider()

      // Guard the fixed [row] / [row + 3] indexing: a short/corrupt/old-format decoded
      // snapshot would otherwise crash the widget process.
      if snapshot.présentParadigm.count >= 6 {
        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 2) {
          ForEach(0 ..< 3, id: \.self) { row in
            GridRow {
              conjugationCell(snapshot.présentParadigm[row])
              conjugationCell(snapshot.présentParadigm[row + 3])
            }
          }
        }
      }

      if let french = snapshot.exampleFrench {
        Divider()
        VStack(alignment: .leading, spacing: 1) {
          Text(french)
            .font(.caption2)
            .italic()
            .lineLimit(4)
          if let source = snapshot.exampleSource {
            // provenance.attribution already carries the "— " lead-in and the real
            // book/author, so render it verbatim rather than re-prefixing a filename.
            Text(verbatim: source)
              .font(.system(size: 9))
              .foregroundStyle(.tertiary)
              .lineLimit(2)
          }
        }
      }

      if let etymology = snapshot.etymologySnippet {
        Divider()
        Text(widgetEtymology: etymology)
          .font(.caption2)
          .foregroundStyle(.secondary)
          .lineLimit(6)
      }

      Spacer(minLength: 0)
    }
    .widgetURL(WidgetDeeplink.verb(snapshot.infinitif))
  }

  private func conjugationCell(_ conjugation: WidgetConjugation) -> some View {
    HStack(spacing: 4) {
      Text(conjugation.pronoun)
        .font(.caption2)
        .foregroundStyle(.secondary)
        .frame(width: 30, alignment: .trailing)
      Text(mixedCase: conjugation.form)
        .font(.caption)
        .fontWeight(.medium)
        .lineLimit(1)
        .minimumScaleFactor(0.7)
    }
  }
}
