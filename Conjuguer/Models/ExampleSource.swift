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
  case swissPublic // ch-… and ch-ncsc-… — Swiss public documents, PD (Art. 5 URG).
  case frenchGov // fr-… — French agencies, Licence Ouverte / Etalab 2.0.
  case wikipedia(article: String) // wp-… — French Wikipedia, CC BY-SA 4.0.
  case claude // AI-authored tail.
  case other(String)

  init(rawSource: String) {
    if rawSource.hasPrefix("proust") {
      self = .proust
    } else if rawSource.hasPrefix("zola") {
      self = .zola
    } else if rawSource.hasPrefix("flaubert") {
      self = .flaubert
    } else if rawSource.hasPrefix("fr-") {
      self = .frenchGov
    } else if rawSource.hasPrefix("ch-") {
      self = .swissPublic
    } else if rawSource.hasPrefix("wp-") {
      self = .wikipedia(article: Self.wikipediaArticles[rawSource] ?? Self.cleanedFilename(rawSource))
    } else if rawSource.hasPrefix("Claude") {
      self = .claude
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
    case .swissPublic:
      return L.VerbView.sourceSwissPublic
    case .frenchGov:
      return L.VerbView.sourceFrenchGov
    case .wikipedia(let article):
      return L.VerbView.sourceWikipedia(article)
    case .claude:
      return L.VerbView.sourceClaude
    case .other(let raw):
      return "— " + raw
    }
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
