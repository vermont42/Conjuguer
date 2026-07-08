//
//  DefectGroup.swift
//  Conjuguer
//
//  Created by Josh Adams on 7/3/21.
//

import Foundation
import os

struct DefectGroup {
  static var defectGroups: [String: DefectGroup] = [:]

  let id: String
  let descriptionEn: String
  let descriptionFr: String
  private var defects: Set<Tense> = []

  nonisolated init(id: String, descriptionEn: String, descriptionFr: String, usesOnly: String?, doesntUse: String?) {
    guard
      !(usesOnly != nil && doesntUse != nil)
    else {
      fatalError("usesOnly and doesntUse were both non-nil.")
    }

    self.id = id
    self.descriptionEn = descriptionEn
    self.descriptionFr = descriptionFr

    let defectSeparator = ","

    if doesntUse == nil && usesOnly == nil {
      defects = Set(Tense.allConcreteCases)
    } else if let doesntUse = doesntUse {
      for code in doesntUse.components(separatedBy: defectSeparator) {
        applyDefect(code: code, defective: true, mirrorImpératifToPassé: true)
      }
    } else if let usesOnly = usesOnly {
      defects = Set(Tense.allConcreteCases)
      for code in usesOnly.components(separatedBy: defectSeparator) {
        applyDefect(code: code, defective: false, mirrorImpératifToPassé: false)
      }
    }
  }

  func isDefectiveForTense(_ tense: Tense) -> Bool {
    defects.contains(tense)
  }

  func description(preferredLanguage: String? = nil) -> String {
    let languageCode = preferredLanguage ?? Locale.preferredLanguages.first ?? Util.english.language.languageCode?.identifier ?? "en-US"

    if languageCode.contains(Util.french.language.languageCode?.identifier ?? "🥐") {
      return descriptionFr
    } else {
      return descriptionEn
    }
  }

  nonisolated private mutating func applyDefect(code: String, defective: Bool, mirrorImpératifToPassé: Bool) {
    if let personNumber = PersonNumber.byShortDisplayName[code] {
      setDefectivity(Tense.allConcreteCases.filter { $0.personNumber == personNumber }, defective)
      return
    }

    guard var tenses = Tense.tensesForShorthand(code) else {
      // Bind id to a local: the os interpolation's escaping autoclosure can't capture
      // the mutating self of this method.
      let groupId = id
      Log.parsing.error("Skipping unrecognized defect code \(code, privacy: .public) in defect group \(groupId, privacy: .public).")
      return
    }

    if mirrorImpératifToPassé {
      for tense in tenses {
        if case .impératif(let personNumber) = tense {
          tenses.append(.impératifPassé(personNumber))
        }
      }
    }

    setDefectivity(tenses, defective)
  }

  nonisolated private mutating func setDefectivity(_ tenses: [Tense], _ defective: Bool) {
    if defective {
      defects.formUnion(tenses)
    } else {
      defects.subtract(tenses)
    }
  }
}
