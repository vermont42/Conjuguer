//
//  InfoView.swift
//  Conjuguer
//
//  Created by Josh Adams on 8/6/21.
//

import SwiftUI

struct InfoView: View {
  @Environment(World.self) private var world
  let info: Info
  let shouldShowInfoHeading: Bool

  init(info: Info, shouldShowInfoHeading: Bool = false) {
    self.info = info
    self.shouldShowInfoHeading = shouldShowInfoHeading
  }

  var body: some View {
    ScrollView {
      VStack {
        if let imageInfo = info.imageInfo {
          Image(imageInfo.filename)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 270)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .shadow(color: Color.customForeground.opacity(0.2), radius: 8, y: 4)
            .accessibilityLabel(imageInfo.accessibilityLabel)
        }

        if shouldShowInfoHeading {
          Text(info.heading)
            .headingForegroundLabel()
            .padding(.bottom, Layout.defaultSpacing)
        }

        RichTextView(blocks: info.richTextBlocks)
          .frame(minWidth: 0, maxWidth: 680)
          .frame(maxWidth: .infinity, alignment: .leading)
      }
      .padding(.leading, Layout.doubleDefaultSpacing)
      .padding(.trailing, Layout.doubleDefaultSpacing)
    }
    .navigationTitle(shouldShowInfoHeading ? "" : info.heading)
    .recordsAppearance(as: "\(InfoView.self)")
    .screenBackground()
    .environment(\.openURL, OpenURLAction { url in
      handleInfoLink(url)
    })
  }

  private func handleInfoLink(_ url: URL) -> OpenURLAction.Result {
    let cleansedUrlString = firstLetterLowercased(parenless(url.absoluteString.removingPercentEncoding ?? ""))

    if let infoIndex = Info.headingToIndex(heading: cleansedUrlString) {
      URL(string: URL.conjuguerUrlPrefix + "\(URL.infoHost)/\(infoIndex)").map {
        world.handleInAppURL($0)
      }
      return .handled
    } else if Verb.verbs[cleansedUrlString] != nil {
      URL(string: URL.conjuguerUrlPrefix + "\(URL.verbHost)/\(parenless(firstLetterLowercased(url.absoluteString)))").map {
        world.handleInAppURL($0)
      }
      return .handled
    } else {
      return .systemAction
    }
  }

  private func parenless(_ input: String) -> String {
    input
      .replacingOccurrences(of: "(", with: "")
      .replacingOccurrences(of: ")", with: "")
  }

  private func firstLetterLowercased(_ input: String) -> String {
    input.prefix(1).lowercased() + input.dropFirst()
  }
}

#if DEBUG
#Preview {
  PreviewSupport.bootstrap()
  return InfoView(info: PreviewSupport.sampleInfo, shouldShowInfoHeading: true)
    .environment(Current)
}
#endif
