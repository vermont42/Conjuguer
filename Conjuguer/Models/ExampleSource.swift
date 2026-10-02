//
//  ExampleSource.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/16/26.
//

import Foundation

enum ExampleSource: Hashable {
  case proust
  case zola
  case flaubert
  case laFontaine // lafontaine-… — La Fontaine, Fables, PD (classical tier).
  case moliere // moliere-… — Molière, Œuvres complètes, PD (classical tier).
  case swissPublic // ch-… and ch-ncsc-… — Swiss public documents, PD (Art. 5 URG).
  case frenchGov // fr-… — French agencies, Licence Ouverte / Etalab 2.0.
  case wikipedia(article: String) // wp-… — French Wikipedia, CC BY-SA 4.0.
  case wiktionnaire(author: String, title: String?, year: String?) // wiktionnaire|author|title|year — PD quotation via French Wiktionary.
  case wiktionaryQuotation(author: String, title: String?, year: String?) // wiktionary|author|title|year — PD quotation via English Wiktionary.
  case wiktionaryExample // wiktionary — usage example written by English Wiktionary's editors, CC BY-SA 4.0.
  case claude(model: String) // AI-authored tail; model is the raw source string, e.g. "Claude (Opus 5)".
  case other(String)

  init(rawSource: String) {
    if rawSource.hasPrefix("wiktionnaire|") {
      let (author, title, year) = Self.citationFields(rawSource)
      self = .wiktionnaire(author: author, title: title, year: year)
    } else if rawSource.hasPrefix("wiktionary|") {
      let (author, title, year) = Self.citationFields(rawSource)
      self = .wiktionaryQuotation(author: author, title: title, year: year)
    } else if rawSource == "wiktionary" {
      self = .wiktionaryExample
    } else if rawSource.hasPrefix("proust") {
      self = .proust
    } else if rawSource.hasPrefix("zola") {
      self = .zola
    } else if rawSource.hasPrefix("flaubert") {
      self = .flaubert
    } else if rawSource.hasPrefix("lafontaine") {
      self = .laFontaine
    } else if rawSource.hasPrefix("moliere") {
      self = .moliere
    } else if rawSource.hasPrefix("fr-") {
      self = .frenchGov
    } else if rawSource.hasPrefix("ch-") {
      self = .swissPublic
    } else if rawSource.hasPrefix("wp-") {
      self = .wikipedia(article: Self.wikipediaArticles[rawSource] ?? Self.cleanedFilename(rawSource))
    } else if rawSource.hasPrefix("Claude") {
      self = .claude(model: rawSource)
    } else {
      self = .other(rawSource)
    }
  }

  var attribution: String {
    switch self {
    case .proust:
      return "— Marcel Proust, « Du côté de chez Swann » (1913)"
    case .zola:
      return "— Émile Zola, « L’Assommoir » (1877)"
    case .flaubert:
      return "— Gustave Flaubert, « Madame Bovary » (1857)"
    case .laFontaine:
      return "— Jean de La Fontaine, « Fables » (1668–1694)"
    case .moliere:
      return "— Molière, « Œuvres complètes » (1659–1673)"
    case .swissPublic:
      return L.VerbView.sourceSwissPublic
    case .frenchGov:
      return L.VerbView.sourceFrenchGov
    case .wikipedia(let article):
      return L.VerbView.sourceWikipedia(article)
    case let .wiktionnaire(author, title, year):
      return L.VerbView.sourceWiktionnaire(Self.citation(author: author, title: title, year: year))
    case let .wiktionaryQuotation(author, title, year):
      return L.VerbView.sourceWiktionary(Self.citation(author: author, title: title, year: year))
    case .wiktionaryExample:
      return L.VerbView.sourceWiktionaryExample
    case .claude(let model):
      return L.VerbView.sourceClaude(model)
    case .other(let raw):
      return "— " + raw
    }
  }

  private static func citationFields(_ source: String) -> (author: String, title: String?, year: String?) {
    let fields = source.split(separator: "|", omittingEmptySubsequences: false).dropFirst().map(String.init)
    func field(_ index: Int) -> String? {
      index < fields.count && !fields[index].isEmpty ? fields[index] : nil
    }
    return (field(0) ?? "", field(1), field(2))
  }

  // A title that already carries guillemets, such as "« Le Serpent qui danse » dans Les Fleurs du mal", is shown as is.
  private static func citation(author: String, title: String?, year: String?) -> String {
    var parts = [author]
    if let title {
      parts.append(title.contains("«") ? title : "« \(title) »")
    }
    let citation = parts.joined(separator: ", ")
    guard let year else {
      return citation
    }
    return "\(citation) (\(year))"
  }

  private static func cleanedFilename(_ source: String) -> String {
    source
      .replacingOccurrences(of: "wp-", with: "")
      .replacingOccurrences(of: ".txt", with: "")
      .replacingOccurrences(of: "-", with: " ")
      .capitalized
  }

  private static let wikipediaArticles: [String: String] = [
    "wp-academie-francaise.txt": "Académie française",
    "wp-action-finance.txt": "Action (finance)",
    "wp-bicyclette.txt": "Bicyclette",
    "wp-bourse-economie.txt": "Bourse (économie)",
    "wp-confiture.txt": "Confiture",
    "wp-course-hippique.txt": "Course hippique",
    "wp-diplome.txt": "Diplôme",
    "wp-dissolution-de-lassemblee-nationale-france.txt": "Dissolution de l’Assemblée nationale (France)",
    "wp-esclavage.txt": "Esclavage",
    "wp-fortification.txt": "Fortification",
    "wp-gymnastique-artistique.txt": "Gymnastique artistique",
    "wp-le-havre.txt": "Le Havre",
    "wp-medecine.txt": "Médecine",
    "wp-napoleon-ier.txt": "Napoléon Ier",
    "wp-orfevrerie.txt": "Orfèvrerie",
    "wp-paris.txt": "Paris",
    "wp-patisserie.txt": "Pâtisserie",
    "wp-referencement-naturel.txt": "Référencement naturel",
    "wp-reseau-social.txt": "Réseau social",
    "wp-salaison.txt": "Salaison",
    "wp-serpent.txt": "Serpent",
    "wp-sucre.txt": "Sucre",
    "wp-taille-de-la-vigne.txt": "Taille de la vigne",
    "wp-television.txt": "Télévision",
    "wp-voile-sport.txt": "Voile (sport)"
  ]
}
