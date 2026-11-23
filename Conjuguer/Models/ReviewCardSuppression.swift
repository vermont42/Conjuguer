//
//  ReviewCardSuppression.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

enum ReviewCardSuppression: String, CaseIterable {
  case off
  case on

  var localizedReviewCardSuppression: String {
    switch self {
    case .off:
      return L.ReviewCardSuppression.off
    case .on:
      return L.ReviewCardSuppression.on
    }
  }
}
