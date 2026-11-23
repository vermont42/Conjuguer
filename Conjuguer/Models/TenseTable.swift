//
//  TenseTable.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

/// One card of the verb page's conjugations, in the page's order.
///
/// The simple tenses come first and the compound ones after them, each block ordered by how often
/// its tenses occur in the corpus: docs/tense_frequency.md gives the counts, and
/// scripts/count_tenses.py reproduces them, so change the order there before changing it here.
/// The personless card sits between the blocks, where its participe passé introduces the compound
/// tenses built from it.
enum TenseTable: CaseIterable {
  case indicatifPrésent
  case imparfait
  case passéSimple
  case futurSimple
  case conditionnelPrésent
  case subjonctifPrésent
  case impératif
  case subjonctifImparfait
  case personless
  case passéComposé
  case plusQueParfait
  case conditionnelPassé
  case subjonctifPlusQueParfait
  case subjonctifPassé
  case passéAntérieur
  case futurAntérieur
  case passéSurcomposé
  case impératifPassé

  static let simple = allCases.filter { !$0.isCompound && $0 != .personless }
  static let compound = allCases.filter(\.isCompound)

  /// Every cell of the page, in order.
  static let allTenses = allCases.flatMap(\.tenses)

  var tenses: [Tense] {
    switch self {
    case .personless:
      return [.participePassé, .participePrésent, .radicalFutur]
    case .indicatifPrésent:
      return PersonNumber.allCases.map(Tense.indicatifPrésent)
    case .imparfait:
      return PersonNumber.allCases.map(Tense.imparfait)
    case .passéSimple:
      return PersonNumber.allCases.map(Tense.passéSimple)
    case .futurSimple:
      return PersonNumber.allCases.map(Tense.futurSimple)
    case .conditionnelPrésent:
      return PersonNumber.allCases.map(Tense.conditionnelPrésent)
    case .subjonctifPrésent:
      return PersonNumber.allCases.map(Tense.subjonctifPrésent)
    case .impératif:
      return PersonNumber.impératifPersonNumbers.map(Tense.impératif)
    case .subjonctifImparfait:
      return PersonNumber.allCases.map(Tense.subjonctifImparfait)
    case .passéComposé:
      return PersonNumber.allCases.map(Tense.passéComposé)
    case .plusQueParfait:
      return PersonNumber.allCases.map(Tense.plusQueParfait)
    case .conditionnelPassé:
      return PersonNumber.allCases.map(Tense.conditionnelPassé)
    case .subjonctifPlusQueParfait:
      return PersonNumber.allCases.map(Tense.subjonctifPlusQueParfait)
    case .subjonctifPassé:
      return PersonNumber.allCases.map(Tense.subjonctifPassé)
    case .passéAntérieur:
      return PersonNumber.allCases.map(Tense.passéAntérieur)
    case .futurAntérieur:
      return PersonNumber.allCases.map(Tense.futurAntérieur)
    case .passéSurcomposé:
      return PersonNumber.allCases.map(Tense.passéSurcomposé)
    case .impératifPassé:
      return PersonNumber.impératifPersonNumbers.map(Tense.impératifPassé)
    }
  }

  var isCompound: Bool {
    switch self {
    case .indicatifPrésent, .imparfait, .passéSimple, .futurSimple, .conditionnelPrésent, .subjonctifPrésent, .impératif, .subjonctifImparfait, .personless:
      return false
    case .passéComposé, .plusQueParfait, .conditionnelPassé, .subjonctifPlusQueParfait, .subjonctifPassé, .passéAntérieur, .futurAntérieur, .passéSurcomposé, .impératifPassé:
      return true
    }
  }

  var scrollID: String {
    "\(self)"
  }

  /// The tense whose name heads the card. The personless card's rows carry their own names.
  var representative: Tense {
    tenses[0]
  }
}

extension Tense {
  /// The card of the verb page that shows this cell.
  var table: TenseTable {
    switch self {
    case .participePassé, .participePrésent, .radicalFutur:
      return .personless
    case .indicatifPrésent:
      return .indicatifPrésent
    case .passéSimple:
      return .passéSimple
    case .imparfait:
      return .imparfait
    case .futurSimple:
      return .futurSimple
    case .conditionnelPrésent:
      return .conditionnelPrésent
    case .subjonctifPrésent:
      return .subjonctifPrésent
    case .subjonctifImparfait:
      return .subjonctifImparfait
    case .impératif:
      return .impératif
    case .passéComposé:
      return .passéComposé
    case .plusQueParfait:
      return .plusQueParfait
    case .passéAntérieur:
      return .passéAntérieur
    case .passéSurcomposé:
      return .passéSurcomposé
    case .futurAntérieur:
      return .futurAntérieur
    case .conditionnelPassé:
      return .conditionnelPassé
    case .subjonctifPassé:
      return .subjonctifPassé
    case .subjonctifPlusQueParfait:
      return .subjonctifPlusQueParfait
    case .impératifPassé:
      return .impératifPassé
    }
  }

  /// The `Info.stableKey` of the article about this tense.
  var articleKey: String {
    switch self {
    case .participePassé:
      return "participe_passe"
    case .participePrésent:
      return "participe_present"
    case .radicalFutur:
      return "radical_futur"
    case .indicatifPrésent:
      return "indicatif_present"
    case .passéSimple:
      return "passe_simple"
    case .imparfait:
      return "imparfait"
    case .futurSimple:
      return "futur_simple"
    case .conditionnelPrésent:
      return "conditionnel_present"
    case .subjonctifPrésent:
      return "subjonctif_present"
    case .subjonctifImparfait:
      return "subjonctif_imparfait"
    case .impératif:
      return "imperatif"
    case .passéComposé:
      return "passe_compose"
    case .plusQueParfait:
      return "plus_que_parfait"
    case .passéAntérieur:
      return "passe_anterieur"
    case .passéSurcomposé:
      return "passe_surcompose"
    case .futurAntérieur:
      return "futur_anterieur"
    case .conditionnelPassé:
      return "conditionnel_passe"
    case .subjonctifPassé:
      return "subjonctif_passe"
    case .subjonctifPlusQueParfait:
      return "subjonctif_plus_que_parfait"
    case .impératifPassé:
      return "imperatif_passe"
    }
  }

  var article: Info? {
    Info.infos.first { $0.stableKey == articleKey }
  }

  /// The name a textbook also uses, shown under the heading as "also simple past" in English and
  /// "aussi passé défini" in French: each language gets the names its learners' textbooks use.
  /// Nil where French has no alternate name.
  var secondName: String? {
    let name: String
    switch self {
    case .participePassé:
      name = L.TenseSecondName.participePassé
    case .participePrésent:
      name = L.TenseSecondName.participePrésent
    case .radicalFutur:
      name = L.TenseSecondName.radicalFutur
    case .indicatifPrésent:
      name = L.TenseSecondName.indicatifPrésent
    case .passéSimple:
      name = L.TenseSecondName.passéSimple
    case .imparfait:
      name = L.TenseSecondName.imparfait
    case .futurSimple:
      name = L.TenseSecondName.futurSimple
    case .conditionnelPrésent:
      name = L.TenseSecondName.conditionnelPrésent
    case .subjonctifPrésent:
      name = L.TenseSecondName.subjonctifPrésent
    case .subjonctifImparfait:
      name = L.TenseSecondName.subjonctifImparfait
    case .impératif:
      name = L.TenseSecondName.impératif
    case .passéComposé:
      name = L.TenseSecondName.passéComposé
    case .plusQueParfait:
      name = L.TenseSecondName.plusQueParfait
    case .passéAntérieur:
      name = L.TenseSecondName.passéAntérieur
    case .passéSurcomposé:
      name = L.TenseSecondName.passéSurcomposé
    case .futurAntérieur:
      name = L.TenseSecondName.futurAntérieur
    case .conditionnelPassé:
      name = L.TenseSecondName.conditionnelPassé
    case .subjonctifPassé:
      name = L.TenseSecondName.subjonctifPassé
    case .subjonctifPlusQueParfait:
      name = L.TenseSecondName.subjonctifPlusQueParfait
    case .impératifPassé:
      name = L.TenseSecondName.impératifPassé
    }
    // The catalog holds an empty French value where French has no second name.
    return name.isEmpty ? nil : name
  }
}
