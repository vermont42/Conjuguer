//
//  GameModels.swift
//  Conjuguer
//

import CoreGraphics
import Foundation

struct Bullet: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
}

struct Target: Identifiable {
  enum Kind: CaseIterable {
    case rooster
    case croissant
    case beret

    var assetName: String {
      switch self {
      case .rooster:
        return "RoosterIconPreview"
      case .croissant:
        return "CroissantIconPreview"
      case .beret:
        return "BeretIconPreview"
      }
    }
  }

  let id = UUID()
  let kind: Target.Kind
  var x: CGFloat
  var y: CGFloat
}

struct Star: Identifiable {
  let id = UUID()
  var x: CGFloat
  var y: CGFloat
  let size: CGFloat
  let opacity: Double
}
