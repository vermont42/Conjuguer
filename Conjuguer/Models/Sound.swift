//
//  Sound.swift
//  Conjuguer
//
//  Created by Josh Adams on 4/9/16.
//  Copyright © 2016 Josh Adams. All rights reserved.
//

enum Sound: String {
  case applause1
  case applause2
  case applause3
  case buzz
  case chime
  case chirp
  case gun1
  case gun2
  case sadTrombone1
  case sadTrombone2
  case sadTrombone3
  case sadTrombone4
  case silence

  static var randomGun: Sound {
    randomSound(base: "gun", count: 2, defaultSound: .gun1)
  }

  static var randomApplause: Sound {
    randomSound(base: "applause", count: 3, defaultSound: .applause1)
  }

  static var randomSadTrombone: Sound {
    randomSound(base: "sadTrombone", count: 4, defaultSound: .sadTrombone1)
  }

  private static func randomSound(base: String, count: Int, defaultSound: Sound) -> Sound {
    let randomIndex = Int.random(in: 1 ... count)
    return Sound(rawValue: base + "\(randomIndex)") ?? defaultSound
  }
}
