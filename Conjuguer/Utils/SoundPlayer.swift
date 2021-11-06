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
  private static var instantOfLastPlay: TimeInterval = 0.0

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
    let instantOfCurrentPlay = Date().timeIntervalSince1970
    let minSoundInterval: TimeInterval = 1.0
    if instantOfCurrentPlay - instantOfLastPlay > minSoundInterval {
      soundPlayer.sounds[sound.rawValue]?.play()
      instantOfLastPlay = instantOfCurrentPlay
    }
  }

  static func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch {}

    play(.silence) // https://forums.developer.apple.com/thread/23160
  }
}
