//
//  SoundPlayerReal.swift
//  Conjuguer
//

import AVFoundation
import Foundation
import os

class SoundPlayerReal: SoundPlayer {
  private var sounds: [String: AVAudioPlayer] = [:]
  private let soundExtension = "mp3"
  // Last-play instant keyed per sound so each sound's debounce window is independent.
  // A single shared clock was bumped by every (even non-debounced) play, so during
  // active play the frequent non-debounced SFX kept it fresh and any debounced sound
  // was almost always dropped.
  private var instantOfLastPlayBySound: [Sound: TimeInterval] = [:]
  private var musicPlayer: AVAudioPlayer?
  private var savedMusicTime: TimeInterval?
  // Tracked rather than read back from musicPlayer.isPlaying, because a player orphaned by a
  // media-services reset reports unreliable state and the rebuild needs to know whether the
  // music was meant to be running.
  private var isMusicActive = false
  private var instantOfLastRebuild: TimeInterval = 0.0
  private static let musicName = "danseMacabre"
  private static let musicVolume: Float = 0.21
  private static let musicFadeDuration: TimeInterval = 2.0
  private static let minRebuildInterval: TimeInterval = 5.0

  // SFX playback is dispatched here: AVAudioPlayer.play() blocks its caller
  // ~20-80ms (an audio-server round trip), which stuttered the main game loop
  // when sound effects fired. The queue is concurrent so rapid SFX don't serialize
  // behind one blocking play().
  private static let playbackQueue = DispatchQueue(
    label: "Conjuguer.soundPlayback",
    qos: .userInitiated,
    attributes: .concurrent
  )

  // AVAudioPlayer isn't Sendable, but play() is documented safe to call off the
  // main thread, and the player is only configured (volume) on the main actor
  // before dispatch, so handing it to the playback queue is safe. `nonisolated`
  // keeps the box (and its member) out of the module's default main-actor
  // isolation so it can be built/read inside the background Sendable closure.
  private nonisolated struct PlayerBox: @unchecked Sendable {
    let player: AVAudioPlayer
  }

  // Carries pre-decoded players from the background warm-up back to the main actor.
  // AVAudioPlayer isn't Sendable; the players are built off-main and only inserted
  // into `sounds` on the main actor, so the hand-off is safe. `nonisolated` as above.
  private nonisolated struct PreparedSoundsBox: @unchecked Sendable {
    let players: [String: AVAudioPlayer]
  }

  func setup() {
    AudioSession.configure()
    observeSessionDisruptions()
    // Instantiating the first AVAudioPlayer cold-starts the process-wide audio
    // stack — measured at ~1.5s on first launch (warm on later launches). Because
    // setup() runs synchronously from ConjuguerApp.init(), doing that here froze
    // app launch. Warm the stack off the main thread instead; the per-sound lazy
    // load in play(_:) is fast once it's warm. (Replaces the old synchronous
    // play(.silence) prime — Apple forum thread/23160 — which caused the freeze.)
    Task.detached(priority: .userInitiated) {
      Self.warmUpAudioStack()
    }
  }

  // Media services reset when `mediaserverd` restarts, which another audio-heavy app on the
  // device can provoke — Konjugieren hit exactly this, traced in its docs/blog_notes.md entry
  // "The quiz went silent, and the audio session was the reason". The reset reverts this app's
  // session to the system-default `.soloAmbient` category and orphans every existing
  // AVAudioPlayer: play() then returns false and the app is silent for the rest of the process,
  // with no error surfaced anywhere. Apple's prescribed recovery is to rebuild every audio
  // object and re-establish the session. Interruptions (a phone call, Siri) leave the players
  // intact but deactivate the session, so those need only reconfiguration.
  //
  // Note that warmUpSounds() cannot recover from this on its own even though GameState calls it
  // at every game start: it skips names already present in `sounds`, so orphaned players are
  // passed over rather than replaced.
  private func observeSessionDisruptions() {
    let center = NotificationCenter.default
    center.addObserver(
      forName: AVAudioSession.mediaServicesWereResetNotification,
      object: nil,
      queue: .main
    ) { [weak self] _ in
      MainActor.assumeIsolated {
        self?.rebuildAudio()
      }
    }
    center.addObserver(
      forName: AVAudioSession.interruptionNotification,
      object: nil,
      queue: .main
    ) { notification in
      // Notification is not Sendable, so the interruption type is read here and only the Bool
      // crosses into the main actor.
      let rawType = notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? UInt
      let didEnd = rawType.flatMap(AVAudioSession.InterruptionType.init(rawValue:)) == .ended
      MainActor.assumeIsolated {
        guard didEnd else {
          return
        }
        AudioSession.configure()
      }
    }
  }

  private func rebuildAudio() {
    Log.audio.error("Rebuilding audio players after an audio-session disruption.")
    sounds.removeAll()
    let shouldResumeMusic = isMusicActive
    savedMusicTime = musicPlayer?.currentTime ?? savedMusicTime
    musicPlayer = nil
    AudioSession.configure()
    warmUpSounds()
    if shouldResumeMusic {
      startMusic()
    }
  }

  // Process-wide audio warm-up. Touches only AVFoundation + Bundle (no shared
  // app state), so it is nonisolated and safe to run off the main actor. The
  // throwaway player's init + prepareToPlay does the expensive cold-start.
  nonisolated private static func warmUpAudioStack() {
    guard let url = Bundle.main.url(forResource: Sound.silence.rawValue, withExtension: "mp3") else {
      return
    }
    let warmUpPlayer = try? AVAudioPlayer(contentsOf: url)
    warmUpPlayer?.volume = 0
    warmUpPlayer?.prepareToPlay()
    warmUpPlayer?.play()
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
    isMusicActive = true
  }

  func stopMusic() {
    if let player = musicPlayer, player.isPlaying {
      savedMusicTime = player.currentTime
    }
    musicPlayer?.stop()
    isMusicActive = false
  }

  func warmUpSounds() {
    // Pre-decode + prepare every effect's AVAudioPlayer off the main thread, then
    // hand them back to the main actor, so the first play of each sound never
    // decodes its mp3 on the game loop. Already-loaded sounds are skipped.
    let names = Sound.allCases.map(\.rawValue).filter { sounds[$0] == nil }
    guard !names.isEmpty else {
      return
    }
    let ext = soundExtension
    Self.playbackQueue.async { [weak self] in
      var prepared: [String: AVAudioPlayer] = [:]
      for name in names {
        guard
          let url = Bundle.main.url(forResource: name, withExtension: ext),
          let player = try? AVAudioPlayer(contentsOf: url)
        else {
          continue
        }
        player.prepareToPlay()
        prepared[name] = player
      }
      let box = PreparedSoundsBox(players: prepared)
      Task { @MainActor in
        self?.mergePreparedSounds(box)
      }
    }
  }

  private func mergePreparedSounds(_ box: PreparedSoundsBox) {
    // Don't replace a player that was lazily created (and may be playing) meanwhile.
    for (name, player) in box.players where sounds[name] == nil {
      sounds[name] = player
    }
  }

  // Normally the player is already prepared by warmUpSounds(); this is the lazy
  // fallback for a sound played before the warm-up reached it (decodes its mp3
  // on the calling thread). It is also how the recovery path gets a player back
  // synchronously, since warmUpSounds repopulates `sounds` asynchronously.
  private func loadedPlayer(for sound: Sound) -> AVAudioPlayer? {
    if let existing = sounds[sound.rawValue] {
      return existing
    }
    guard
      let audioURL = Bundle.main.url(forResource: sound.rawValue, withExtension: soundExtension),
      let player = try? AVAudioPlayer(contentsOf: audioURL)
    else {
      return nil
    }
    player.prepareToPlay()
    sounds[sound.rawValue] = player
    return player
  }

  func play(_ sound: Sound, shouldDebounce: Bool, volume: Float) {
    let preparedPlayer = loadedPlayer(for: sound)

    let instantOfCurrentPlay = Date().timeIntervalSince1970
    let minSoundInterval: TimeInterval = 1.0
    let instantOfLastPlay = instantOfLastPlayBySound[sound] ?? 0.0
    if !shouldDebounce || (instantOfCurrentPlay - instantOfLastPlay > minSoundInterval) {
      guard let player = preparedPlayer else {
        return
      }
      player.volume = volume
      // Dispatch the blocking play() off the main thread so it doesn't stutter the
      // game loop (see playbackQueue). The player is configured above on the main
      // actor; only the play() round trip runs in the background. That Bool is the
      // only in-band signal that a media-services reset has orphaned the players, so
      // a false hops back to the main actor to rebuild rather than being discarded.
      let box = PlayerBox(player: player)
      Self.playbackQueue.async { [weak self] in
        guard !box.player.play() else {
          return
        }
        Task { @MainActor in
          self?.recoverFromFailedPlay(sound, volume: volume)
        }
      }
      instantOfLastPlayBySound[sound] = instantOfCurrentPlay
    }
  }

  // Throttled so that a sound failing to start for some reason other than a reset cannot make a
  // game frame that plays it rebuild every player, every frame.
  private func recoverFromFailedPlay(_ sound: Sound, volume: Float) {
    let now = Date().timeIntervalSince1970
    guard now - instantOfLastRebuild > Self.minRebuildInterval else {
      return
    }
    instantOfLastRebuild = now
    rebuildAudio()
    guard let player = loadedPlayer(for: sound) else {
      return
    }
    player.volume = volume
    let box = PlayerBox(player: player)
    Self.playbackQueue.async {
      box.player.play()
    }
  }
}
