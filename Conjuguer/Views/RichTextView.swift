//
//  RichTextView.swift
//  Conjuguer
//

import SwiftUI

struct RichTextView: View {
  let blocks: [RichTextBlock]

  var body: some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      ForEach(blocks, id: \.self) { block in
        switch block {
        case .subheading(let text):
          Text(text)
            .font(subheadingFont)
            .foregroundStyle(Color.customForeground)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, alignment: .center)
            .accessibilityAddTraits(.isHeader)
            .padding(.top, Layout.defaultSpacing)

        case .body(let segments):
          BodyTextView(segments: segments)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
      }
    }
  }
}

private struct BodyTextView: View {
  let segments: [TextSegment]

  var body: some View {
    var combined = AttributedString()
    for segment in segments {
      combined.append(attributedString(for: segment))
    }
    return Text(combined)
      .lineSpacing(4)
  }

  private func attributedString(for segment: TextSegment) -> AttributedString {
    switch segment {
    case .plain(let string):
      return styled(string, font: bodyFont)

    case .bold(let string):
      return styled(string, font: bodyEmphasisFont)

    case .link(let text, let url):
      let markdownLink = "[\(text)](\(url.absoluteString))"
      if var attributed = try? AttributedString(markdown: markdownLink) {
        attributed.font = bodyFont
        return attributed
      }
      var attributed = styled(text, font: bodyFont)
      attributed.underlineStyle = .single
      return attributed

    case .conjugation(let parts):
      var result = AttributedString()
      for part in parts {
        switch part {
        case .regular(let string):
          result.append(styled(string, font: bodyFont))
        case .irregular(let string):
          result.append(styled(string, font: bodyFont, color: Color.customRed))
        }
      }
      return result
    }
  }

  private func styled(_ string: String, font: Font, color: Color = .customForeground) -> AttributedString {
    var attributed = AttributedString(string)
    attributed.foregroundColor = color
    attributed.font = font
    return attributed
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return ScrollView {
    RichTextView(blocks: PreviewSupport.sampleInfo.richTextBlocks)
      .padding()
  }
  .environment(Current)
}
#endif
