//
//  BrowseSearchField.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import SwiftUI

extension View {
  /// The search field both browse tabs show, which tells `engagement` when it gains and loses
  /// the focus.
  func browseSearchable(
    text: Binding<String>,
    prompt: String,
    isFocused: FocusState<Bool>.Binding,
    engagement: SearchEngagement
  ) -> some View {
    searchable(text: text, placement: BrowseLayout.searchPlacement, prompt: prompt)
      .searchFocused(isFocused)
      .textInputAutocapitalization(.never)
      .autocorrectionDisabled()
      .onChange(of: isFocused.wrappedValue) { _, isFocused in
        engagement.focusChanged(to: isFocused)
      }
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
