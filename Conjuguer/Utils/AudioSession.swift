//
//  AudioSession.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import AVFoundation

enum AudioSession {
  // Single place the shared AVAudioSession category is configured. Was previously set three
  // times (SoundPlayer.init, SoundPlayer.setup, Utterer.setup) with inconsistent options and
  // swallowed errors; setCategory is idempotent, so the two setup() callers can both call this.
  static func configure() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
    } catch {
      print("Could not configure audio session: \(error.localizedDescription)")
    }
  }
}
