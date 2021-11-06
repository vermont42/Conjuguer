//
//  SoundPlayer.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import AVFoundation

class SoundPlayer {
  private static let soundPlayer = SoundPlayer()
  private var sounds: [String: AVAudioPlayer]
  private static let soundExtension = "mp3"

  private init () {
    sounds = Dictionary()
    do {
      try AVAudioSession.sharedInstance().setCategory(.playback) // was ambient
    } catch {}
  }

  static func play(_ sound: Sound) {
    if soundPlayer.sounds[sound.rawValue] == nil {
      if let audioUrl = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension) {
        do {
          try soundPlayer.sounds[sound.rawValue] = AVAudioPlayer.init(contentsOf: audioUrl)
        } catch {}
      }
    }
    soundPlayer.sounds[sound.rawValue]?.play()
  }

  static func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {}

    play(.silence) // https://forums.developer.apple.com/thread/23160
  }
}
