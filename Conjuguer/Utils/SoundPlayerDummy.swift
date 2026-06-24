//
//  SoundPlayerDummy.swift
//  Conjuguer
//

class SoundPlayerDummy: SoundPlayer {
  func setup() {}
  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {}
  func startMusic() {}
  func stopMusic() {}
}
