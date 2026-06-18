//
//  AppIcon.swift
//  Conjuguer
//
//  Copyright © 2026 Josh Adams. All rights reserved.
//

import Foundation

enum AppIcon: String, CaseIterable {
  case arcDeTriomphe
  case rooster
  case croissant
  case beret

  // The name of the alternate-icon set in the asset catalog, or nil for the
  // primary AppIcon. Must match the .appiconset name (exposed as an alternate
  // icon via ASSETCATALOG_COMPILER_INCLUDE_ALL_APPICON_ASSETS = YES).
  var alternateIconName: String? {
    switch self {
    case .arcDeTriomphe:
      return nil
    case .rooster:
      return "RoosterIcon"
    case .croissant:
      return "CroissantIcon"
    case .beret:
      return "BeretIcon"
    }
  }

  // The imageset shown as a tappable thumbnail in the Settings picker. The app
  // icon itself isn't loadable by name at runtime, so each icon ships a separate
  // preview imageset.
  var previewAssetName: String {
    switch self {
    case .arcDeTriomphe:
      return "ArcDeTriompheIconPreview"
    case .rooster:
      return "RoosterIconPreview"
    case .croissant:
      return "CroissantIconPreview"
    case .beret:
      return "BeretIconPreview"
    }
  }

  var localizedName: String {
    switch self {
    case .arcDeTriomphe:
      return L.AppIcon.arcDeTriomphe
    case .rooster:
      return L.AppIcon.rooster
    case .croissant:
      return L.AppIcon.croissant
    case .beret:
      return L.AppIcon.beret
    }
  }
}
