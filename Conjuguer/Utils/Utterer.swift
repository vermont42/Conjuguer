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
  private static let rate: Float = 0.5
  private static let pitchMultiplier: Float = 0.8
  static let defaultLocaleString = "en-US"
  static let englishLocaleString = "en-US"
  static let frenchLocaleString = "fr-FR"

  static func setup() {
    let session = AVAudioSession.sharedInstance()
    do {
      try session.setCategory(.playback, options: .mixWithOthers)
    } catch let error as NSError {
      print("\(error.localizedDescription)")
    }
    utter("", localeString: defaultLocaleString)
  }

  static func utter(_ thingToUtter: String, localeString: String) {
    let utterance = AVSpeechUtterance(string: thingToUtter)
    utterance.rate = Utterer.rate
    utterance.voice = AVSpeechSynthesisVoice(language: localeString)
    utterance.pitchMultiplier = Utterer.pitchMultiplier
    synth.speak(utterance)
    SoundPlayer.play(.silence) // https://forums.developer.apple.com/thread/23160
  }
}
