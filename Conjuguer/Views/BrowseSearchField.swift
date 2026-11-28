//
//  BrowseSearchField.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

extension View {
  /// The search field both browse tabs show, which tells `engagement` when it gains and loses
  /// the focus. Its prompt is the longest of `prompts` that fits the field.
  func browseSearchable(
    text: Binding<String>,
    prompts: [String],
    isFocused: FocusState<Bool>.Binding,
    engagement: SearchEngagement
  ) -> some View {
    modifier(BrowseSearchable(text: text, prompts: prompts, isFocused: isFocused, engagement: engagement))
  }
}

private struct BrowseSearchable: ViewModifier {
  let text: Binding<String>
  let prompts: [String]
  let isFocused: FocusState<Bool>.Binding
  let engagement: SearchEngagement
  @Environment(\.dynamicTypeSize) private var dynamicTypeSize
  @Environment(\.horizontalSizeClass) private var horizontalSizeClass
  @State private var width: CGFloat = 0

  func body(content: Content) -> some View {
    content
      .onGeometryChange(for: CGFloat.self) { $0.size.width } action: { width = $0 }
      .searchable(text: text, placement: BrowseLayout.searchPlacement, prompt: prompt)
      .searchFocused(isFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .onChange(of: isFocused.wrappedValue) { _, isFocused in
        engagement.focusChanged(to: isFocused)
      }
  }

  private var prompt: String {
    SearchPrompt.longestFitting(prompts, containerWidth: width, dynamicTypeSize: dynamicTypeSize, sizeClass: horizontalSizeClass)
  }
}

// A keyboard toolbar never appears for the navigation bar's search field (iOS 26.3), so the
// accent row takes the sort picker's place while the field is engaged. Search ranks its results
// whatever the sort order, so the picker has nothing to do then, and it is disabled while the
// field holds text and the keyboard is down.
struct SortPickerOrKeyRow<SortPicker: View>: View {
  let engagement: SearchEngagement
  let isSearching: Bool
  let insert: (String) -> Void
  @ViewBuilder let sortPicker: SortPicker

  var body: some View {
    if engagement.isEngaged {
      FrenchLetterKeyRow(insert: insert)
    } else {
      sortPicker
        .disabled(isSearching)
    }
  }
}
