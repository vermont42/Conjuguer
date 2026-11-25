//
//  InfoView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/6/21.
//

import SwiftUI

/// An article. Its links to other articles and to verbs push onto the stack that shows it, which
/// is the Info tab's or an `ArticleSheet`'s.
struct InfoView: View {
  @Environment(\.verbPagePush) private var verbPagePush
  let info: Info

  var body: some View {
    ScrollView {
      VStack {
        if let imageInfo = info.imageInfo {
          Image(imageInfo.filename)
            .resizable()
            .scaledToFit()
            .frame(width: 270)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.customForeground.opacity(0.2), radius: 8, y: 4)
            .accessibilityLabel(imageInfo.accessibilityLabel)
        }

        // The heading lives in the scrolling content, never in a navigation title: headings
        // like "Subjonctif Plus-que-parfait" truncate as a large title on narrow screens or
        // at large Dynamic Type sizes, whereas a Text here wraps.
        Text(info.heading)
          .headingForegroundLabel()
          .frenchPronunciation(forReal: info.alwaysUsesFrenchPronunciation)
          .padding(.bottom, Layout.defaultSpacing)

        RichTextView(blocks: info.richTextBlocks)
          .frame(minWidth: 0, maxWidth: 680)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
    }
    .recordsAppearance(as: "\(InfoView.self)")
    .screenBackground()
    .environment(\.openURL, OpenURLAction { url in
      guard let link = LinkTarget(url: url) else {
        return .systemAction
      }
      switch link {
      case .article(let info):
        verbPagePush?(info)
      case .verb(let verb):
        verbPagePush?(VerbDestination(verb: verb, source: .infoLink))
      }
      return .handled
    })
  }

  /// What a link in an article's rich text names: another article, by its heading, or a verb.
  /// Any other URL, such as a web page's, is left to the system.
  enum LinkTarget: Equatable {
    case article(Info)
    case verb(Verb)

    init?(url: URL) {
      let name = Self.firstLetterLowercased(Self.parenless(url.absoluteString.removingPercentEncoding ?? ""))
      if let index = Info.headingToIndex(heading: name) {
        self = .article(Info.infos[index])
      } else if let verb = Verb.verbs[name] {
        self = .verb(verb)
      } else {
        return nil
      }
    }

    private static func parenless(_ input: String) -> String {
      input
        .replacingOccurrences(of: "(", with: "")
        .replacingOccurrences(of: ")", with: "")
    }

    private static func firstLetterLowercased(_ input: String) -> String {
      input.prefix(1).lowercased() + input.dropFirst()
    }
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return InfoView(info: PreviewSupport.sampleInfo)
    .environment(Current)
}
#endif
