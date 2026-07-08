//
//  AudioSession.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import AVFoundation
import os

enum AudioSession {
  static func configure() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      Log.audio.error("Could not configure audio session: \(error.localizedDescription, privacy: .public)")
    }
  }
}
