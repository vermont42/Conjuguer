//
//  CustomQuiz.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/23/26.
//

import Foundation

/// A quiz the learner puts together on the Quiz tab: tenses, a set of verbs, or both. A part left
/// unchosen is the learner's level's, so a choice of verbs alone asks the level's tenses, and a
/// choice of tenses alone asks the level's band, mixed as the default quiz's verbs are. Any tense
/// may be chosen, above the learner's level or not.
struct CustomQuiz: Equatable {
  /// Empty asks the level's tenses.
  var tenses: Set<QuizTenseSlot> = []
  /// Nil asks the level's verbs.
  var verbSet: QuizVerbSet?

  var isEmpty: Bool {
    tenses.isEmpty && verbSet == nil
  }

  /// The chosen tenses in the order the levels add them.
  var orderedTenses: [QuizTenseSlot] {
    QuizTenseSlot.allCases.filter(tenses.contains)
  }

  func slots(at level: QuizLevel) -> [QuizTenseSlot] {
    tenses.isEmpty ? level.slots : orderedTenses
  }

  /// What `quizStart` says the learner chose, without saying what.
  var choiceParameter: String {
    switch (tenses.isEmpty, verbSet == nil) {
    case (false, false):
      return "both"
    case (false, true):
      return "tenses"
    case (true, _):
      return "verbs"
    }
  }

  /// Whether some verb of the choice has some cell of the chosen tenses. A list can lack them all:
  /// falloir's model has no impératif, and My Verbs can empty after the choice was kept.
  @MainActor func canBeAsked(at level: QuizLevel, myVerbs: [Verb]) -> Bool {
    guard let verbs = verbSet?.listedVerbs(myVerbs: myVerbs) else {
      return !isEmpty
    }
    let cells = slots(at: level).flatMap(\.cells)
    return verbs.contains { verb in
      cells.contains(where: verb.hasCell)
    }
  }

  static let tensesQueryName = "tenses"
  static let verbsQueryName = "verbs"
}

/// Stored as `tenses=indicatif_present,imperatif&verbs=etre`. The keys are permanent, since the
/// choice is kept between launches and can travel in a link. A key that no longer names anything
/// is dropped rather than failing the whole choice.
extension CustomQuiz: RawRepresentable {
  init?(rawValue: String) {
    var components = URLComponents()
    components.percentEncodedQuery = rawValue
    let items = components.queryItems ?? []
    let tenseKeys = items.first { $0.name == Self.tensesQueryName }?.value?.split(separator: ",").map(String.init) ?? []
    tenses = Set(tenseKeys.compactMap(QuizTenseSlot.init(key:)))
    verbSet = items.first { $0.name == Self.verbsQueryName }?.value.flatMap(QuizVerbSet.init(key:))
  }

  var rawValue: String {
    var items: [URLQueryItem] = []
    if !tenses.isEmpty {
      items.append(URLQueryItem(name: Self.tensesQueryName, value: orderedTenses.map(\.key).joined(separator: ",")))
    }
    if let verbSet {
      items.append(URLQueryItem(name: Self.verbsQueryName, value: verbSet.key))
    }
    var components = URLComponents()
    components.queryItems = items
    return components.percentEncodedQuery ?? ""
  }
}

extension QuizTenseSlot {
  /// The `Info.stableKey` of the tense's article, which no reordering of the slots changes.
  var key: String {
    cells.first?.articleKey ?? ""
  }

  init?(key: String) {
    guard let slot = Self.allCases.first(where: { $0.key == key }) else {
      return nil
    }
    self = slot
  }

  var name: String {
    cells.first?.titleCaseName ?? ""
  }

  var secondName: String? {
    cells.first?.secondName
  }
}

enum QuizVerbSet: Hashable {
  case all
  case band(FrequencyBand)
  case collection(VerbCollection)
  case myVerbs

  /// The bands and every verb are chosen for their size, not their verbs, so their questions are
  /// mixed as the default quiz's are. A collection and My Verbs are lists, asked as they are.
  var mixesVerbs: Bool {
    switch self {
    case .all, .band:
      return true
    case .collection, .myVerbs:
      return false
    }
  }

  /// The band a mixed set draws from, nil for every verb. Only meaningful when `mixesVerbs`.
  var band: FrequencyBand? {
    if case .band(let band) = self {
      return band
    }
    return nil
  }

  var collection: VerbCollection? {
    if case .collection(let collection) = self {
      return collection
    }
    return nil
  }

  var isModel: Bool {
    if case .collection(.model) = self {
      return true
    }
    return false
  }

  var key: String {
    switch self {
    case .all:
      return Self.allKey
    case .band(let band):
      return Self.bandKey(band)
    case .collection(let collection):
      return collection.key
    case .myVerbs:
      return Self.myVerbsKey
    }
  }

  /// The top-100 collection and the top-100 band hold the same verbs under the same key, which
  /// reads back as the band. A model's ID is not checked, since settings load before the models
  /// are parsed; a model that names nothing holds no verbs, so its quiz cannot start.
  @MainActor init?(key: String) {
    if let band = FrequencyBand.allCases.first(where: { Self.bandKey($0) == key }) {
      self = .band(band)
      return
    }
    switch key {
    case Self.allKey:
      self = .all
    case Self.myVerbsKey:
      self = .myVerbs
    default:
      if let collection = VerbCollection(featuredKey: key) {
        self = .collection(collection)
      } else if key.hasPrefix(Self.modelKeyPrefix), key.count > Self.modelKeyPrefix.count {
        self = .collection(.model(String(key.dropFirst(Self.modelKeyPrefix.count))))
      } else {
        return nil
      }
    }
  }

  /// The verbs of a list, which a quiz asks as they are. Nil for a set whose questions are mixed.
  @MainActor func listedVerbs(myVerbs: [Verb]) -> [Verb]? {
    switch self {
    case .all, .band:
      return nil
    case .collection(let collection):
      return collection.verbs
    case .myVerbs:
      return myVerbs
    }
  }

  @MainActor var title: String {
    switch self {
    case .all:
      return L.CustomQuiz.everyVerb(Verb.rankCount.formatted())
    case .band(.top100):
      return L.VerbCollection.top100Title
    case .band(let band):
      return L.CustomQuiz.band(band.rankLimit.formatted())
    case .collection(let collection):
      return collection.title
    case .myVerbs:
      return L.MyVerbs.title
    }
  }

  // Semantic ordering: the narrowest band first, then every verb, then the lists.
  static func editorChoices(showsMyVerbs: Bool) -> [QuizVerbSet] {
    FrequencyBand.allCases.map(QuizVerbSet.band)
      + [.all]
      + (showsMyVerbs ? [.myVerbs] : [])
      + VerbCollection.featured.filter { $0 != .top100 }.map(QuizVerbSet.collection)
  }

  private static let allKey = "all"
  private static let myVerbsKey = "myVerbs"
  private static let modelKeyPrefix = "model-"

  private static func bandKey(_ band: FrequencyBand) -> String {
    "top\(band.rankLimit)"
  }
}

extension QuizScope {
  /// A custom quiz from the Quiz tab: ten questions, then Ten More, never ranked.
  @MainActor static func custom(_ custom: CustomQuiz, myVerbs: [Verb]) -> QuizScope {
    QuizScope(
      verbs: custom.verbSet?.listedVerbs(myVerbs: myVerbs),
      questionCount: Quiz.questionCount,
      source: .custom,
      custom: custom
    )
  }
}
