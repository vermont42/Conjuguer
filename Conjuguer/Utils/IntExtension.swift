//
//  IntExtension.swift
//  Conjuguer
//
//  Created by Joshua Adams on 6/25/17.
//

import Foundation

extension Int {
  var timeString: String {
    var remainingSeconds = self
    let hours = remainingSeconds / 3600
    remainingSeconds -= hours * 3600
    let minutes = remainingSeconds / 60
    remainingSeconds -= minutes * 60
    if hours > 0 {
      return NSString(format: "%d:%02d:%02d", hours, minutes, remainingSeconds) as String
    } else if minutes > 0 {
      return NSString(format: "%d:%02d", minutes, remainingSeconds) as String
    } else {
      return NSString(format: "%d", remainingSeconds) as String
    }
  }
}
