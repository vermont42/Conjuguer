//
//  SoundPlayerReal.swift
//  Conjuguer
//

import AVFoundation
import Foundation

class SoundPlayerReal: SoundPlayer {
  private var sounds: [String: AVAudioPlayer] = [:]
  private let soundExtension = "mp3"
  private var instantOfLastPlay: TimeInterval = 0.0
  private var musicPlayer: AVAudioPlayer?
  private var savedMusicTime: TimeInterval?
  private static let musicName = "danseMacabre"
  private static let musicVolume: Float = 0.21
  private static let musicFadeDuration: TimeInterval = 2.0

  func setup() {
    AudioSession.configure()
    play(.silence) // https://forums.developer.apple.com/thread/23160
  }

  func startMusic() {
    if musicPlayer == nil {
      if let url = Bundle.main.url(forResource: Self.musicName, withExtension: soundExtension) {
        musicPlayer = try? AVAudioPlayer(contentsOf: url)
        musicPlayer?.numberOfLoops = -1
      }
    }
    guard let player = musicPlayer else {
      return
    }
    if let saved = savedMusicTime {
      player.currentTime = saved
      savedMusicTime = nil
    } else {
      player.currentTime = player.duration > 0 ? TimeInterval.random(in: 0 ..< player.duration) : 0
    }
    player.volume = 0
    player.play()
    player.setVolume(Self.musicVolume, fadeDuration: Self.musicFadeDuration)
  }

  func stopMusic() {
    if let player = musicPlayer, player.isPlaying {
      savedMusicTime = player.currentTime
    }
    musicPlayer?.stop()
  }

  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
    if sounds[sound.rawValue] == nil {
      if let audioURL = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension) {
        do {
          sounds[sound.rawValue] = try AVAudioPlayer(contentsOf: audioURL)
        } catch {}
      }
    }

    let instantOfCurrentPlay = Date().timeIntervalSince1970
    let minSoundInterval: TimeInterval = 1.0
    if !shouldDebounce || (instantOfCurrentPlay - instantOfLastPlay > minSoundInterval) {
      sounds[sound.rawValue]?.volume = volume
      sounds[sound.rawValue]?.play()
      instantOfLastPlay = instantOfCurrentPlay
    }
  }
}
