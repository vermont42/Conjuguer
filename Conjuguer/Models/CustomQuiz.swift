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

  /// Whether the choice has enough to ask: for a list, three cells of the chosen tenses, as a
  /// collection's quiz and My Verbs need. A list can lack them: falloir's model has no impératif
  /// and one présent, and My Verbs can empty after the choice was kept.
  @MainActor func canBeAsked(at level: QuizLevel, myVerbs: [Verb]) -> Bool {
    guard let count = listedCellCount(at: level, myVerbs: myVerbs) else {
      return !isEmpty
    }
    return count >= QuizScope.minimumCellCount
  }

  /// Whether a list that cannot be asked has some cell of the chosen tenses, only too few, which
  /// the line under a disabled Start tells apart from none.
  @MainActor func hasTooFewCells(at level: QuizLevel, myVerbs: [Verb]) -> Bool {
    guard let count = listedCellCount(at: level, myVerbs: myVerbs) else {
      return false
    }
    return count > 0 && count < QuizScope.minimumCellCount
  }

  /// The cells of the chosen tenses that a list has, counted up to three. Nil for a mixed set.
  @MainActor private func listedCellCount(at level: QuizLevel, myVerbs: [Verb]) -> Int? {
    verbSet?.listedVerbs(myVerbs: myVerbs).map {
      QuizScope.cellCount(of: $0, slots: slots(at: level), limit: QuizScope.minimumCellCount)
    }
  }

  static let tensesQueryName = "tenses"
  static let verbsQueryName = "verbs"
  static let verbListQueryName = "infinitives"
}

/// Stored as `tenses=indicatif_present,imperatif&verbs=etre`. The keys are permanent, since the
/// choice is kept between launches and can travel in a link. A list of verbs, which a shared My
/// Verbs becomes, travels as `infinitives=parler,ha%C3%AFr%20France` in place of `verbs`, each a
/// `Verb.verbs` key. A key that no longer names anything is dropped rather than failing the whole
/// choice.
extension CustomQuiz: RawRepresentable {
  init?(rawValue: String) {
    var components = URLComponents()
    components.percentEncodedQuery = rawValue
    let items = components.queryItems ?? []
    let tenseKeys = items.first { $0.name == Self.tensesQueryName }?.value?.split(separator: ",").map(String.init) ?? []
    tenses = Set(tenseKeys.compactMap(QuizTenseSlot.init(key:)))
    if let key = items.first(where: { $0.name == Self.verbsQueryName })?.value {
      verbSet = QuizVerbSet(key: key)
    } else if let list = items.first(where: { $0.name == Self.verbListQueryName })?.value {
      verbSet = QuizVerbSet(verbKeys: list.split(separator: ",").map(String.init))
    }
  }

  var rawValue: String {
    var items: [URLQueryItem] = []
    if !tenses.isEmpty {
      items.append(URLQueryItem(name: Self.tensesQueryName, value: orderedTenses.map(\.key).joined(separator: ",")))
    }
    if case .list(let verbKeys) = verbSet {
      items.append(URLQueryItem(name: Self.verbListQueryName, value: verbKeys.joined(separator: ",")))
    } else if let verbSet {
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
  /// `Verb.verbs` keys, in the sharer's order, as a practice set carries a shared My Verbs.
  case list([String])
  case myVerbs

  /// The bands and every verb are chosen for their size, not their verbs, so their questions are
  /// mixed as the default quiz's are. A collection and My Verbs are lists, asked as they are.
  var mixesVerbs: Bool {
    switch self {
    case .all, .band:
      return true
    case .collection, .list, .myVerbs:
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
    case .list:
      return Self.listKey
    case .myVerbs:
      return Self.myVerbsKey
    }
  }

  /// Repeats are dropped, and a list left empty is no list. Unknown keys are kept, since settings
  /// load before the verbs are parsed; a key that names no verb asks nothing.
  init?(verbKeys: [String]) {
    var seen = Set<String>()
    let keys = verbKeys.filter { !$0.isEmpty && seen.insert($0).inserted }
    guard !keys.isEmpty else {
      return nil
    }
    self = .list(keys)
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
    case .list(let verbKeys):
      return verbKeys.compactMap { Verb.verbs[$0] }
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
    case .list:
      return L.CustomQuiz.verbList(count: listedVerbs(myVerbs: [])?.count ?? 0)
    case .myVerbs:
      return L.MyVerbs.title
    }
  }

  // Semantic ordering: the narrowest band first, then every verb, then the lists. A kept practice
  // set's list is offered only while it is the choice, since nothing in the editor can build one.
  static func editorChoices(showsMyVerbs: Bool, current: QuizVerbSet? = nil) -> [QuizVerbSet] {
    var keptList: [QuizVerbSet] = []
    if case .list = current, let current {
      keptList = [current]
    }
    return FrequencyBand.allCases.map(QuizVerbSet.band)
      + [.all]
      + (showsMyVerbs ? [.myVerbs] : [])
      + keptList
      + VerbCollection.featured.filter { $0 != .top100 }.map(QuizVerbSet.collection)
  }

  /// What `key` says of a list, whose verbs travel apart from it. It reads back as nothing.
  static let listKey = "list"

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
      kind: .custom(custom)
    )
  }
}
