//
//  SoundPlayer.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

@MainActor
protocol SoundPlayer {
  func setup()
  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float)
  func warmUpSounds()
  func startMusic()
  func stopMusic()
}

extension SoundPlayer {
  func play(_ sound: Sound) {
    play(sound, shouldDebounce: true, volume: 1.0)
  }

  func play(_ sound: Sound, shouldDebounce: Bool) {
    play(sound, shouldDebounce: shouldDebounce, volume: 1.0)
  }
}
