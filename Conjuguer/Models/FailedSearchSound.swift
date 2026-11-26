//
//  FailedSearchSound.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/26/26.
//

import Foundation

/// The sad trombone sounds once as a search begins to fail, not again for each letter it fails
/// on, and not while what is typed is still only pronouns.
struct FailedSearchSound {
  private var hasSounded = false

  /// Whether to sound the trombone now.
  mutating func searchChanged(hasFailed: Bool, isStillTyping: Bool) -> Bool {
    guard hasFailed else {
      hasSounded = false
      return false
    }
    guard !hasSounded, !isStillTyping else {
      return false
    }
    hasSounded = true
    return true
  }
}
