//
//  SearchPrompt.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/28/26.
//

import SwiftUI
import UIKit

/// Picks the longest of a ladder of search prompts that fits the browse tabs' search field. The
/// prompt is a UIKit placeholder, which SwiftUI can neither scale nor swap with `ViewThatFits`.
enum SearchPrompt {
  private static let trailingInset: CGFloat = 7
  // UIKit shrinks the placeholder to fit at accessibility sizes, but no smaller than the field's
  // 14-point minimumFontSize. Below those sizes it truncates.
  private static let accessibilityFloor: CGFloat = 14

  static func longestFitting(
    _ candidates: [String],
    containerWidth: CGFloat,
    dynamicTypeSize: DynamicTypeSize,
    sizeClass: UserInterfaceSizeClass?
  ) -> String {
    let longest = candidates.first ?? ""
    guard containerWidth > 0 else {
      return longest
    }
    let font = dynamicTypeSize.isAccessibilitySize
      ? UIFont.systemFont(ofSize: accessibilityFloor)
      : UIFont.preferredFont(
        forTextStyle: .body,
        compatibleWith: UITraitCollection(preferredContentSizeCategory: UIContentSizeCategory(dynamicTypeSize))
      )
    let fieldMargin: CGFloat = sizeClass == .regular ? 20 : 16
    let available = containerWidth - 2 * fieldMargin - leadingInset(dynamicTypeSize) - trailingInset
    return candidates.first { width(of: $0, in: font) <= available } ?? candidates.last ?? longest
  }

  private static func width(of prompt: String, in font: UIFont) -> CGFloat {
    ceil((prompt as NSString).size(withAttributes: [.font: font]).width)
  }

  // Where UISearchTextField's text begins, past the magnifying glass, as measured on iOS 26.3.
  private static func leadingInset(_ dynamicTypeSize: DynamicTypeSize) -> CGFloat {
    switch dynamicTypeSize {
    case .xSmall:
      return 36
    case .small:
      return 37
    case .medium:
      return 39
    case .large:
      return 40
    case .xLarge:
      return 42
    case .xxLarge:
      return 45
    case .xxxLarge:
      return 47
    case .accessibility1:
      return 52
    case .accessibility2:
      return 58
    case .accessibility3:
      return 57
    case .accessibility4:
      return 63
    case .accessibility5:
      return 69
    @unknown default:
      return 69
    }
  }
}
