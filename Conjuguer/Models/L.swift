//
//  L.swift
//  Conjuguer
//
//  Created by Joshua Adams on 8/1/21.
//

import Foundation

enum L {
  enum Navigation {
    static var verbs: String {
      NSLocalizedString("Navigation.verbs", comment: "")
    }

    static var models: String {
      NSLocalizedString("Navigation.models", comment: "")
    }

    static var info: String {
      NSLocalizedString("Navigation.info", comment: "")
    }

    static var input: String {
      NSLocalizedString("Navigation.input", comment: "")
    }

    static var back: String {
      NSLocalizedString("Navigation.back", comment: "")
    }
  }

  enum VerbView {
    static var overview: String {
      NSLocalizedString("VerbView.overview", comment: "")
    }

    static var model: String {
      NSLocalizedString("VerbView.model", comment: "")
    }

    static var reflexive: String {
      NSLocalizedString("VerbView.reflexive", comment: "")
    }

    static var aspiratedH: String {
      NSLocalizedString("VerbView.aspiratedH", comment: "")
    }

    static var auxiliaryÊtre: String {
      NSLocalizedString("VerbView.auxiliaryÊtre", comment: "")
    }

    static var auxiliaryAvoir: String {
      NSLocalizedString("VerbView.auxiliaryAvoir", comment: "")
    }

    static var defective: String {
      NSLocalizedString("VerbView.defective", comment: "")
    }

    static var exampleUse: String {
      NSLocalizedString("VerbView.exampleUse", comment: "")
    }

    static var personlessConjugations: String {
      NSLocalizedString("VerbView.personlessConjugations", comment: "")
    }

    static var showCompoundTenses: String {
      NSLocalizedString("VerbView.showCompoundTenses", comment: "")
    }
  }

  enum ModelView {
    static var parent: String {
      NSLocalizedString("ModelView.parent", comment: "")
    }

    static var defective: String {
      NSLocalizedString("ModelView.defective", comment: "")
    }

    static var endings: String {
      NSLocalizedString("ModelView.endings", comment: "")
    }

    static var stemAlterations: String {
      NSLocalizedString("ModelView.stemAlterations", comment: "")
    }

    static var regular: String {
      NSLocalizedString("ModelView.regular", comment: "")
    }

    static var irregular: String {
      NSLocalizedString("ModelView.irregular", comment: "")
    }
  }

  static func displayNameForVerbSort(_ sort: VerbSort) -> String {
    switch sort {
    case .frequency:
      return NSLocalizedString("VerbSort.frequency", comment: "")
    case .alphabetic:
      return NSLocalizedString("VerbSort.alphabetic", comment: "")
    }
  }

  static func displayNameForModelSort(_ sort: ModelSort) -> String {
    switch sort {
    case .irregularity:
      return NSLocalizedString("ModelSort.irregularity", comment: "")
    case .alphabetic:
      return NSLocalizedString("ModelSort.alphabetic", comment: "")
    case .identifier:
      return NSLocalizedString("ModelSort.identifier", comment: "")
    }
  }
}
