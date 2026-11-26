//
//  PreviewSupport.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/2/26.
//

#if DEBUG
import SwiftUI

// Makes SwiftUI previews self-contained. Previews don't run AppLauncher.main(), so the verb /
// model / defect-group data is never parsed and the global Current keeps an unseeded world, leaving
// the previewed views empty. bootstrap() parses that data once and points Current at the in-memory
// unitTest world so previews render real content without touching UserDefaults.
enum PreviewSupport {
  @MainActor static func bootstrap() {
    if Verb.verbs.isEmpty {
      VerbData.loadSynchronously()
    }
    Current = .unitTest
  }

  // Sample entities for detail-view previews. Call bootstrap() first so the dictionaries are loaded.
  @MainActor static var sampleVerb: Verb {
    Verb.verbs["avoir"] ?? Verb.verbs.values.first!
  }

  @MainActor static var sampleModel: VerbModel {
    VerbModel.models["1-1"] ?? VerbModel.models.values.first!
  }

  @MainActor static var sampleInfo: Info {
    Info.infos[0]
  }
}

/// A stack with the pages a previewed verb page, model page, or article can push, as every stack
/// in the app has.
struct PreviewStack<Content: View>: View {
  @ViewBuilder let content: () -> Content
  @State private var path = NavigationPath()

  var body: some View {
    NavigationStack(path: $path) {
      content()
        .verbPageNavigation(path: $path)
    }
    .environment(Current)
  }
}
#endif
