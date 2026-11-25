//
//  VerbCollection.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// A fixed list of verbs offered as a place to go: something a learner can finish and a teacher
/// can assign. Each shows how many of its verbs have been opened, starts a quiz on itself, and is
/// shared as a link. The four featured collections lead the Models tab and are shared as
/// `conjuguer://list/<key>`; every model is a collection too, shown on its own page and shared as
/// its `conjuguer://model/<id>` link.
enum VerbCollection: Hashable, Identifiable {
  case top100
  case être
  case irregularFutur
  case pronominal
  case model(String)

  // Semantic ordering: the order of the Models tab's Collections section.
  static let featured: [VerbCollection] = [.top100, .être, .irregularFutur, .pronominal]

  static let envoyerModelID = "1-8"
  static let shareSampleCount = 6
  private static let modelAnalyticsValue = "model"
  private static let modelKeyPrefix = "model-"

  @MainActor private static var verbsCache: [VerbCollection: [Verb]] = [:]

  var id: String {
    key
  }

  /// The `list/` link's target. A key, once shared, must keep opening the same list.
  var key: String {
    switch self {
    case .top100:
      return "top100"
    case .être:
      return "etre"
    case .irregularFutur:
      return "irregularFutur"
    case .pronominal:
      return "pronominal"
    case .model(let id):
      return Self.modelKeyPrefix + id
    }
  }

  /// A featured collection's key. A model's collection is reached by its `model/` link instead.
  init?(featuredKey: String) {
    guard let collection = Self.featured.first(where: { $0.key == featuredKey }) else {
      return nil
    }
    self = collection
  }

  /// What `viewCollection`, `tapShareCollection`, and `quizStart` send. Every model sends one
  /// value, since some models hold a single verb (aller's 1-9), and naming the model would name
  /// the verb looked up, which the privacy policy promises the app does not send.
  var analyticsValue: String {
    if case .model = self {
      return Self.modelAnalyticsValue
    }
    return key
  }

  /// Any collection's `key`, a model's included.
  init?(key: String) {
    if let featured = Self(featuredKey: key) {
      self = featured
    } else if key.hasPrefix(Self.modelKeyPrefix), VerbModel.models[String(key.dropFirst(Self.modelKeyPrefix.count))] != nil {
      self = .model(String(key.dropFirst(Self.modelKeyPrefix.count)))
    } else {
      return nil
    }
  }

  var isFeatured: Bool {
    Self.featured.contains(self)
  }

  /// The collection's entries, the most frequent first. Each entry of a doubled infinitive
  /// counts, as in the verb list, except in the top 100.
  @MainActor var verbs: [Verb] {
    if let cached = Self.verbsCache[self], !cached.isEmpty {
      return cached
    }
    let verbs: [Verb]
    if self == .top100 {
      // sortir's two entries share a rank. The list keeps the first, sortir "exit", so that the
      // hundred are a hundred.
      var seen: Set<String> = []
      verbs = Verb.verbs(in: .top100).filter { seen.insert($0.infinitif).inserted }
    } else {
      verbs = Verb.verbs.values
        .filter(contains)
        .sorted { ($0.frequency, $0.dictionaryKey) < ($1.frequency, $1.dictionaryKey) }
    }
    Self.verbsCache[self] = verbs
    return verbs
  }

  @MainActor func contains(_ verb: Verb) -> Bool {
    switch self {
    case .top100:
      return verb.isIn(.top100)
    case .être:
      // A pronominal verb takes être too, but the pronominal verbs are a collection of their own.
      return verb.auxiliary == .être && !verb.isReflexive
    case .irregularFutur:
      return Self.hasIrregularFuturStem(verb)
    case .pronominal:
      return verb.isReflexive
    case .model(let id):
      return verb.model == id
    }
  }

  /// Whether the verb's futur builds on a stem other than its infinitive (ser-, ir-, viendr-,
  /// devr-), among the verbs schools call irregular (`VerbDraw.isIrregular`) and envoyer's model.
  /// The spelling changes of the first group (appellerai, emploierai, lèverai) do not count, and
  /// neither do prévoir and pourvoir, whose futur keeps the infinitive.
  @MainActor static func hasIrregularFuturStem(_ verb: Verb) -> Bool {
    guard
      VerbDraw.isIrregular(verb) || verb.model == envoyerModelID,
      verb.hasCell(.futurSimple(.thirdSingular)),
      let stem = Conjugator.conjugatedString(infinitif: verb.infinitif, tense: .radicalFutur, extraLetters: verb.extraLetters, pronounGender: .masculine)
    else {
      return false
    }
    let regularStem = verb.infinitif.hasSuffix("e") ? String(verb.infinitif.dropLast()) : verb.infinitif
    return stem.lowercased() != regularStem
  }

  var title: String {
    switch self {
    case .top100:
      return L.VerbCollection.top100Title
    case .être:
      return L.VerbCollection.êtreTitle
    case .irregularFutur:
      return L.VerbCollection.irregularFuturTitle
    case .pronominal:
      return L.VerbCollection.pronominalTitle
    case .model(let id):
      let exemplar = VerbModel.models[id]?.exemplarWithPossibleExtraLetters ?? id
      return "\(exemplar) (\(id))"
    }
  }

  var shortDescription: String {
    switch self {
    case .top100:
      return L.VerbCollection.top100Description
    case .être:
      return L.VerbCollection.êtreDescription
    case .irregularFutur:
      return L.VerbCollection.irregularFuturDescription
    case .pronominal:
      return L.VerbCollection.pronominalDescription
    case .model(let id):
      return VerbModel.models[id]?.description ?? ""
    }
  }

  var systemImageName: String {
    switch self {
    case .top100:
      return "chart.bar.fill"
    case .être:
      return "figure.walk.motion"
    case .irregularFutur:
      return "forward.fill"
    case .pronominal:
      return "arrow.uturn.backward"
    case .model:
      return "square.grid.3x3.fill"
    }
  }

  /// `conjuguer://list/etre?source=sharedLink`, or a model's `conjuguer://model/6-7?source=sharedLink`.
  var deeplink: URL {
    switch self {
    case .model(let id):
      return Deeplink.model(id, source: .sharedLink).url
    default:
      return Deeplink.list(key, source: .sharedLink).url
    }
  }

  @MainActor func shareText() -> String {
    let verbs = verbs
    let sample = verbs.prefix(Self.shareSampleCount).map(\.citationInfinitif)
    let more = verbs.count > sample.count ? ", …" : ""
    return L.VerbCollection.shareText(
      title: title,
      count: verbs.count,
      sample: sample.joined(separator: ", ") + more,
      link: deeplink.absoluteString,
      appStoreLink: URL.appStore.absoluteString
    )
  }

  /// `viewCollection`, for a featured collection's page. A model's page reports itself through
  /// `viewAppeared` instead.
  @MainActor func signalView(source: AnalyticsSource) {
    Current.analytics.signal(name: .viewCollection, parameters: [
      ParameterKey.collection.rawValue: analyticsValue,
      ParameterKey.source.rawValue: source.rawValue
    ])
  }
}

/// A featured collection's page to push or present, with how it was reached.
struct VerbCollectionDestination: Hashable, Identifiable {
  let collection: VerbCollection
  let source: AnalyticsSource

  var id: String {
    collection.key
  }
}

extension QuizScope {
  /// Ten unranked questions on the collection's verbs, in a sheet over its page.
  @MainActor static func collection(_ collection: VerbCollection) -> QuizScope {
    QuizScope(
      verbs: collection.verbs,
      questionCount: Quiz.questionCount,
      source: .list,
      title: collection.title,
      collection: collection
    )
  }
}
