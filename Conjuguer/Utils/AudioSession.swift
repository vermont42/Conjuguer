//
//  AudioSession.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/15/26.
//

import AVFoundation
import os

enum AudioSession {
  // Activation matters as much as the category. A media-services reset or an interruption
  // (a phone call, Siri, another audio app) leaves the session deactivated and reverted to
  // the system-default .soloAmbient, and nothing re-establishes it on its own. Callers
  // re-invoke this after such an event; see SoundPlayerReal.observeSessionDisruptions.
  static func configure() {
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback, options: .mixWithOthers)
      try AVAudioSession.sharedInstance().setActive(true)
    } catch {
      Log.audio.error("Could not configure audio session: \(error.localizedDescription, privacy: .public)")
    }
  }
}
