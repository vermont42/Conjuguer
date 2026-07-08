//
//  LanguageModelServiceReal.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

import Foundation
import FoundationModels
import os
import Synchronization

// The app's deployment target is iOS 26.0, so FoundationModels is always importable and
// every symbol below is unconditionally available — no `@available(iOS 26, *)` guards or
// `#if canImport(FoundationModels)` fences are needed (they could never exclude anything).

nonisolated private let lmsLogger = Logger(subsystem: "software.racecondition.Conjuguer", category: "LanguageModelService")

@MainActor
@Observable
class LanguageModelServiceReal: LanguageModelService {
  private let model = SystemLanguageModel(guardrails: .permissiveContentTransformations)

  private var tutorSession: LanguageModelSession?

  private(set) var isAvailable: Bool
  private(set) var unavailabilityReason: LanguageModelUnavailability?

  init() {
    let snapshot = Self.snapshot(of: model.availability)
    self.isAvailable = snapshot.isAvailable
    self.unavailabilityReason = snapshot.reason
  }

  // Re-read model availability on demand (the app calls this when the scene becomes
  // active) instead of a fixed forever-poll, which woke the process every 5s for the
  // service's whole lifetime even when the tutor was never opened.
  func refreshAvailability() {
    let snapshot = Self.snapshot(of: model.availability)
    if snapshot.isAvailable != isAvailable {
      isAvailable = snapshot.isAvailable
    }
    if snapshot.reason != unavailabilityReason {
      unavailabilityReason = snapshot.reason
    }
  }

  private static func snapshot(of availability: SystemLanguageModel.Availability) -> (isAvailable: Bool, reason: LanguageModelUnavailability?) {
    switch availability {
    case .available:
      return (true, nil)
    case .unavailable(.appleIntelligenceNotEnabled):
      return (false, .appleIntelligenceNotEnabled)
    case .unavailable(.deviceNotEligible):
      return (false, .deviceNotEligible)
    case .unavailable(.modelNotReady):
      return (false, .modelNotReady)
    case .unavailable:
      return (false, .unknown)
    @unknown default:
      return (false, .unknown)
    }
  }

  private static let isFrench = Locale.current.language.languageCode?.identifier == "fr"

  private static var tutorInstructions: String {
    isFrench ? tutorInstructionsFrench : tutorInstructionsEnglish
  }

  private static let tutorInstructionsEnglish = """
    You are a French verb conjugation tutor. \
    For conjugation questions, call conjugateVerb EXACTLY ONCE with the \
    French infinitive and the SINGLE tense the user asked about. Do not \
    call the tool multiple times for different tenses. \
    Present the French conjugations from the tool result directly. \
    NEVER translate conjugations into English. Always show French words \
    like "je parle", never English like "I speak". \
    List ALL persons from the tool result. \
    Tense notes: "présent" = indicatif présent = present indicative. \
    "passé composé" = present perfect. "imparfait" = imperfect. \
    "passé simple" = simple past = preterite. \
    "plus-que-parfait" = pluperfect = past perfect. \
    "passé antérieur" = past anterior. "futur simple" = simple future. \
    "futur antérieur" = future perfect. \
    "conditionnel présent" = the conditional. \
    "conditionnel passé" = past conditional. \
    "subjonctif présent" = present subjunctive. \
    "subjonctif passé" = past subjunctive. \
    "subjonctif imparfait" = imperfect subjunctive. \
    "participe passé" = past participle. \
    "participe présent" = present participle. \
    "impératif" = the imperative = command form. \
    Grammar concept questions are welcome. If the user asks about grammar \
    concepts like the difference between the passé composé and the imparfait, \
    agreement of the participe passé, or the three verb groups, answer directly \
    and helpfully without calling the tool. \
    Only redirect questions that have nothing to do with the French language.
    """

  private static let tutorInstructionsFrench = """
    Tu es un tuteur de conjugaison des verbes français. \
    Pour les questions de conjugaison, appelle conjugateVerb EXACTEMENT UNE FOIS \
    avec l’infinitif français et le SEUL temps demandé par l’utilisateur. N’appelle \
    pas l’outil plusieurs fois pour des temps différents. \
    Présente directement les conjugaisons françaises issues du résultat de l’outil. \
    Réponds toujours en français. Affiche les formes françaises comme « je parle », \
    jamais l’anglais comme « I speak ». \
    Énumère TOUTES les personnes du résultat de l’outil. \
    Remarques sur les temps : « présent » = indicatif présent. \
    Les autres temps sont le « passé composé », l’« imparfait », le « passé simple », \
    le « plus-que-parfait », le « passé antérieur », le « futur simple », \
    le « futur antérieur », le « conditionnel présent », le « conditionnel passé », \
    le « subjonctif présent », le « subjonctif passé », le « subjonctif imparfait », \
    le « participe passé », le « participe présent » et l’« impératif ». \
    Les questions sur des concepts grammaticaux sont les bienvenues. Si l’utilisateur \
    pose une question sur un concept comme la différence entre le passé composé et \
    l’imparfait, l’accord du participe passé ou les trois groupes de verbes, réponds \
    directement et utilement sans appeler l’outil. \
    Ne redirige que les questions qui n’ont rien à voir avec la langue française.
    """

  func sendTutorMessage(_ message: String) async throws -> String {
    let maxRetries = 3
    var lastRefusalResponse: String?
    var lastError: Error?

    for attempt in 0...maxRetries {
      ConjugationTool.resetCallCount()
      if attempt > 0 {
        tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
      } else if tutorSession == nil {
        tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
      }
      guard let session = tutorSession else {
        throw LanguageModelServiceError.sessionUnavailable
      }
      do {
        let response = try await session.respond(to: message)
        let cleaned = Self.stripMarkdown(response.content)
        let trimmed = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty && !Self.isLikelyRefusal(cleaned) {
          return cleaned
        }
        let reason = trimmed.isEmpty ? "empty response" : "likely refusal"
        lmsLogger.info("Detected \(reason) on attempt \(attempt + 1), retrying")
        lastRefusalResponse = cleaned
      } catch {
        lmsLogger.warning("Attempt \(attempt + 1) failed: \(error.localizedDescription)")
        lastError = error
      }
    }

    tutorSession = LanguageModelSession(model: model, tools: [ConjugationTool()], instructions: Self.tutorInstructions)
    if lastRefusalResponse != nil {
      return L.Tutor.unableToAnswer
    }
    throw lastError ?? LanguageModelServiceError.sessionUnavailable
  }

  private static func stripMarkdown(_ text: String) -> String {
    text.replacingOccurrences(of: "**", with: "")
  }

  private static func isLikelyRefusal(_ response: String) -> Bool {
    let lowercased = response.lowercased()
    return lowercased.contains("can't assist")
      || lowercased.contains("cannot assist")
      || lowercased.contains("can't help")
      || lowercased.contains("cannot help")
      || lowercased.contains("ethical guidelines")
      || lowercased.contains("unable to assist")
      || lowercased.contains("unable to provide")
      || lowercased.contains("inappropriate content")
      || lowercased.contains("cannot answer")
      || lowercased.contains("can't answer")
      || lowercased.contains("cannot provide")
      || lowercased.contains("cannot fulfill")
      || lowercased.contains("can't fulfill")
      || lowercased.contains("unable to fulfill")
      || lowercased.contains("outside of the scope")
      || lowercased.contains("outside the scope")
      || lowercased.contains("can't do that")
      || lowercased.contains("cannot do that")
      || lowercased.contains("can't continue")
      || lowercased.contains("cannot continue")
      // French redirects
      || lowercased.contains("je ne peux pas vous aider")
      || lowercased.contains("je ne peux pas répondre")
      || lowercased.contains("je suis une ia")
      || lowercased.contains("je suis un modèle de langage")
      || lowercased.contains("en dehors de mes capacités")
      || lowercased.contains("désolé, je ne peux")
  }

  func resetTutorSession() {
    tutorSession = nil
  }
}

struct ConjugationTool: Tool {
  let name = "conjugateVerb"
  let description = "Look up a French verb conjugation"

  // call(arguments:) is nonisolated and can run off the main actor, while
  // resetCallCount() runs on the main actor, so this counter is mutated across
  // isolation domains — guard it with a Mutex rather than nonisolated(unsafe).
  private static let callCount = Mutex(0)
  private static let maxCallsPerSession = 3

  static func resetCallCount() {
    callCount.withLock { $0 = 0 }
  }

  @Generable(description: "A French verb conjugation lookup")
  struct Arguments {
    @Guide(description: "The verb infinitive")
    var infinitif: String

    @Guide(description: "Tense from the question", .anyOf([
      "Indicatif Présent", "Passé Composé", "Imparfait", "Passé Simple",
      "Plus-que-parfait", "Passé Antérieur", "Futur Simple", "Futur Antérieur",
      "Conditionnel Présent", "Conditionnel Passé", "Subjonctif Présent",
      "Subjonctif Passé", "Subjonctif Imparfait", "Subjonctif Plus-que-parfait",
      "Impératif", "Impératif Passé", "Participe Passé", "Participe Présent",
      "Passé Surcomposé"
    ]))
    var tense: String
  }

  func call(arguments: Arguments) async throws -> String {
    let count = Self.callCount.withLock { count -> Int in
      count += 1
      return count
    }
    if count > Self.maxCallsPerSession {
      lmsLogger.warning("Tool call limit reached (\(Self.maxCallsPerSession))")
      return "Limit reached. Respond with the conjugations you already have."
    }
    lmsLogger.info("Tool call: infinitif=\(arguments.infinitif) tense=\(arguments.tense)")
    let result = await Self.performLookup(infinitif: arguments.infinitif, tenseName: arguments.tense)
    lmsLogger.info("Tool result: \(result)")
    return result
  }

  // Tool.call is nonisolated, but Conjugator.conjugate and the pronoun helpers are
  // @MainActor (via SWIFT_DEFAULT_ACTOR_ISOLATION). This helper bridges the gap.
  @MainActor private static func performLookup(infinitif rawInfinitif: String, tenseName: String) -> String {
    let infinitif = normalizeInfinitif(rawInfinitif)
    guard let verb = Verb.verbs[infinitif] else {
      return "\"\(rawInfinitif)\" is not a recognized French verb."
    }

    if let tense = personlessTense(forName: tenseName) {
      guard let form = safeConjugation(verb: verb, tense: tense) else {
        return "Could not conjugate \(verb.infinitif) for the \(tenseName)."
      }
      return "\(verb.infinitif) — \(tense.titleCaseName): \(form.lowercased())"
    }

    guard let builder = tenseBuilder(forName: tenseName) else {
      return invalidTenseMessage(rawInfinitif: rawInfinitif, tenseName: tenseName)
    }

    let imperatif = isImperatif(name: tenseName)
    let personNumbers = imperatif ? PersonNumber.impératifPersonNumbers : PersonNumber.allCases
    var lines: [String] = []
    for personNumber in personNumbers {
      let tense = builder(personNumber)
      guard let conjugation = safeConjugation(verb: verb, tense: tense) else {
        continue
      }
      if imperatif {
        lines.append(personNumber.impératifAndPossibleReflexivePronoun(conjugation, isReflexive: verb.isReflexive).lowercased())
      } else {
        let preamble = personNumber.preamble(forConjugation: conjugation, isReflexive: verb.isReflexive, hasAspiratedH: verb.hasAspiratedH)
        lines.append((preamble + conjugation).lowercased())
      }
    }

    guard !lines.isEmpty else {
      return "Could not conjugate \(verb.infinitif) for the \(tenseName)."
    }
    let label = builder(personNumbers[0]).titleCaseName
    return "\(verb.infinitif) in the \(label): \(lines.joined(separator: ", "))"
  }

  @MainActor private static func safeConjugation(verb: Verb, tense: Tense) -> String? {
    switch Conjugator.conjugate(infinitif: verb.infinitif, tense: tense, extraLetters: verb.extraLetters) {
    case .success(let conjugation):
      return conjugation
    case .failure:
      return nil
    }
  }

  // Strips the reflexive marker (se / s') a model may prepend, and lowercases for dictionary lookup.
  private static func normalizeInfinitif(_ raw: String) -> String {
    var infinitif = raw.trimmingCharacters(in: .whitespaces).lowercased()
    for prefix in ["se ", "s'", "s\u{2019}"] where infinitif.hasPrefix(prefix) {
      infinitif = String(infinitif.dropFirst(prefix.count))
      break
    }
    return infinitif.trimmingCharacters(in: .whitespaces)
  }

  // Folds accents and hyphens so "Plus-que-parfait" / "présent" match plain ASCII keywords.
  private static func folded(_ name: String) -> String {
    name
      .folding(options: .diacriticInsensitive, locale: Locale(identifier: "en"))
      .lowercased()
      .replacingOccurrences(of: "-", with: " ")
  }

  private static func personlessTense(forName name: String) -> Tense? {
    let folded = folded(name)
    if folded.contains("participe passe") || folded.contains("past participle") {
      return .participePassé
    }
    if folded.contains("participe present") || folded.contains("present participle") || folded.contains("gerondif") || folded.contains("gerund") {
      return .participePrésent
    }
    if folded.contains("radical du futur") || folded.contains("future stem") {
      return .radicalFutur
    }
    return nil
  }

  private static func isImperatif(name: String) -> Bool {
    let folded = folded(name)
    return (folded.contains("imperatif") || folded.contains("imperative") || folded.contains("command")) && !folded.contains("passe")
  }

  // Maps a person-bearing tense name (French or English) to its Tense constructor. Most-specific
  // compound phrases are matched before their shorter substrings.
  private static func tenseBuilder(forName name: String) -> ((PersonNumber) -> Tense)? {
    let folded = folded(name)

    if folded.contains("subjonctif plus que parfait") || folded.contains("pluperfect subjunctive") {
      return Tense.subjonctifPlusQueParfait
    }
    if folded.contains("subjonctif passe") || folded.contains("past subjunctive") || folded.contains("perfect subjunctive") {
      return Tense.subjonctifPassé
    }
    if folded.contains("subjonctif imparfait") || folded.contains("imperfect subjunctive") {
      return Tense.subjonctifImparfait
    }
    if folded.contains("subjonctif") || folded.contains("subjunctive") {
      return Tense.subjonctifPrésent
    }
    if folded.contains("conditionnel passe") || folded.contains("past conditional") || folded.contains("perfect conditional") {
      return Tense.conditionnelPassé
    }
    if folded.contains("conditionnel") || folded.contains("conditional") {
      return Tense.conditionnelPrésent
    }
    if folded.contains("futur anterieur") || folded.contains("future perfect") {
      return Tense.futurAntérieur
    }
    if folded.contains("futur") || folded.contains("future") {
      return Tense.futurSimple
    }
    if folded.contains("passe surcompose") || folded.contains("double compound") {
      return Tense.passéSurcomposé
    }
    if folded.contains("passe compose") || folded.contains("present perfect") || folded.contains("compound past") {
      return Tense.passéComposé
    }
    if folded.contains("plus que parfait") || folded.contains("pluperfect") || folded.contains("past perfect") {
      return Tense.plusQueParfait
    }
    if folded.contains("passe anterieur") || folded.contains("past anterior") {
      return Tense.passéAntérieur
    }
    if folded.contains("passe simple") || folded.contains("simple past") || folded.contains("preterite") || folded.contains("preterit") {
      return Tense.passéSimple
    }
    if folded.contains("imparfait") || folded.contains("imperfect") {
      return Tense.imparfait
    }
    if folded.contains("imperatif passe") || folded.contains("past imperative") {
      return Tense.impératifPassé
    }
    if folded.contains("imperatif") || folded.contains("imperative") || folded.contains("command") {
      return Tense.impératif
    }
    if folded.contains("present") || folded.contains("indicatif") {
      return Tense.indicatifPrésent
    }
    return nil
  }

  @MainActor private static func invalidTenseMessage(rawInfinitif: String, tenseName: String) -> String {
    if Verb.verbs[normalizeInfinitif(rawInfinitif)] == nil {
      return "\"\(rawInfinitif)\" is not a recognized French verb."
    }
    return "Could not parse tense \"\(tenseName)\". Valid names include: "
      + "Indicatif Présent, Passé Composé, Imparfait, Passé Simple, Plus-que-parfait, "
      + "Futur Simple, Conditionnel Présent, Subjonctif Présent, Impératif, "
      + "Participe Passé, Participe Présent."
  }
}
