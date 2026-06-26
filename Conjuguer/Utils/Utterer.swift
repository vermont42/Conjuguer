//
//  Utterer.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/18/15.
//  Copyright © 2015 Josh Adams. All rights reserved.
//

import AVFoundation

enum Utterer {
  private static let synth = AVSpeechSynthesizer()
  // nonisolated so the off-main speech warm-up (warmUpSpeech) can read them; they
  // are immutable Sendable constants, so this is safe.
  private nonisolated static let rate: Float = 0.5
  private nonisolated static let pitchMultiplier: Float = 0.8
  nonisolated static let englishLocaleString = "en-US"
  nonisolated static let frenchLocaleString = "fr-FR"

  static func setup() {
    AudioSession.configure()
    // The first AVSpeechSynthesisVoice lookup loads voice assets and is slow on a
    // cold launch. setup() runs synchronously from ConjuguerApp.init(), so this
    // previously contributed to the launch freeze. Warm the speech stack off the
    // main thread (mirrors SoundPlayerReal.setup()); the shared `synth` and the
    // runtime utter(_:localeString:) path stay on the main actor, untouched.
    Task.detached(priority: .userInitiated) {
      warmUpSpeech()
    }
  }

  // Process-wide speech warm-up. The voice-asset cache it primes is shared, so a
  // throwaway synthesizer here speeds the real synth's first utterance. Touches
  // only AVFoundation locals + Sendable constants (no shared app state), so it is
  // nonisolated and safe to run off the main actor.
  nonisolated private static func warmUpSpeech() {
    let warmUpSynth = AVSpeechSynthesizer()
    let utterance = AVSpeechUtterance(string: " ")
    utterance.rate = rate
    utterance.voice = AVSpeechSynthesisVoice(language: englishLocaleString)
    utterance.pitchMultiplier = pitchMultiplier
    warmUpSynth.speak(utterance)
  }

  static func utter(_ thingToUtter: String, localeString: String) {
    let utterance = AVSpeechUtterance(string: thingToUtter)
    utterance.rate = Utterer.rate
    utterance.voice = AVSpeechSynthesisVoice(language: localeString)
    utterance.pitchMultiplier = Utterer.pitchMultiplier
    synth.speak(utterance)
    Current.soundPlayer.play(.silence) // https://forums.developer.apple.com/thread/23160
  }
}
