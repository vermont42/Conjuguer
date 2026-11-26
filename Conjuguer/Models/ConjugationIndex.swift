//
//  ConjugationIndex.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/22/26.
//

import Foundation

/// The conjugation map, indexed for search: by folded spelling, so that etait finds était and
/// manoeuvre finds manœuvre, and by length, so that a guess compares a misspelling only with
/// conjugations of about its length.
nonisolated struct ConjugationIndex: Sendable {
  let map: ConjugationMap

  // Only the keys that folding changes, which are 107,000 of 243,000. A folded spelling's
  // conjugations are these plus the key spelled as the fold itself, if there is one.
  private let accentedKeysByFold: [String: [String]]

  // Every distinct fold, its UTF-8 bytes packed end to end in one array per byte length, for
  // the guess, which compares a misspelling with each of them as the learner types. Folds are
  // ASCII, since folding strips every accent and spells out œ and æ.
  private let foldBytesByLength: [Int: [UInt8]]

  init(map: ConjugationMap) {
    self.map = map
    var accentedKeysByFold: [String: [String]] = [:]
    var foldBytesByLength: [Int: [UInt8]] = [:]
    for key in map.verbsByConjugation.keys {
      guard !Self.isASCII(key) else {
        foldBytesByLength[key.utf8.count, default: []].append(contentsOf: key.utf8)
        continue
      }
      let fold = VerbSearch.fold(key)
      let isNewFold = accentedKeysByFold[fold] == nil && map.verbsByConjugation[fold] == nil
      accentedKeysByFold[fold, default: []].append(key)
      if isNewFold {
        foldBytesByLength[fold.utf8.count, default: []].append(contentsOf: fold.utf8)
      }
    }
    self.accentedKeysByFold = accentedKeysByFold
    self.foldBytesByLength = foldBytesByLength
  }

  /// Built on first use from `ConjugationMap.bundled`. Loading the map and folding its 243,000
  /// conjugations takes about two seconds in a Debug build, so the verb list touches this from
  /// a background task before the learner types.
  static let bundled = ConjugationIndex(map: .bundled)

  struct Spelling: Equatable, Sendable {
    let conjugation: String
    let isFolded: Bool
  }

  /// The conjugations that `word` spells: itself, if it is one, then those equal to it after
  /// folding, in UTF-8 order.
  func spellings(of word: String) -> [Spelling] {
    let key = ConjugationMap.key(word)
    let literal = map.verbsByConjugation[key] == nil ? [] : [Spelling(conjugation: key, isFolded: false)]
    return literal + conjugations(folding: VerbSearch.fold(key))
      .filter { $0 != key }
      .map { Spelling(conjugation: $0, isFolded: true) }
  }

  /// The conjugations that fold to `fold`, in UTF-8 order.
  func conjugations(folding fold: String) -> [String] {
    let plain = map.verbsByConjugation[fold] == nil ? [] : [fold]
    return (plain + (accentedKeysByFold[fold] ?? [])).sorted(by: ConjugationMap.precedes)
  }

  /// The folds fewest edits from `fold`, none more than `limit`, with that distance. Lengths
  /// nearest the query's are measured first, and each find tightens the limit, so that a word
  /// one edit from a conjugation is never compared at length with every conjugation three edits
  /// away. Nil, too, once the task running it is cancelled.
  func nearestFolds(to fold: String, within limit: Int) -> (folds: [String], distance: Int)? {
    var distance = BoundedEditDistance(query: Array(fold.utf8))
    let queryLength = distance.queryLength
    var best: (folds: [String], distance: Int)?
    let lengths = (0...limit).flatMap { offset in offset == 0 ? [queryLength] : [queryLength - offset, queryLength + offset] }
    for length in lengths where length > 0 {
      if Task.isCancelled {
        return nil
      }
      let currentLimit = best?.distance ?? limit
      guard abs(length - queryLength) <= currentLimit, let bytes = foldBytesByLength[length] else {
        continue
      }
      bytes.withUnsafeBufferPointer { buffer in
        for start in stride(from: 0, to: buffer.count, by: length) {
          let candidate = UnsafeBufferPointer(rebasing: buffer[start..<(start + length)])
          guard let candidateDistance = distance.measure(candidate, atMost: best?.distance ?? limit) else {
            continue
          }
          guard let found = String(bytes: candidate, encoding: .utf8) else {
            continue
          }
          if let current = best, current.distance == candidateDistance {
            best = (current.folds + [found], candidateDistance)
          } else {
            best = ([found], candidateDistance)
          }
        }
      }
    }
    return best
  }

  private static func isASCII(_ text: String) -> Bool {
    text.utf8.allSatisfy { $0 < 0x80 }
  }
}

/// `VerbSearch.editDistance` from one query to many candidates, over bytes, giving up on a
/// candidate once its distance must exceed the limit. In a Debug build, this is what lets the
/// guess compare a misspelling with every conjugation of about its length between keystrokes:
/// most candidates fail the letter count, which costs a pass over each, and never reach the
/// full comparison.
nonisolated struct BoundedEditDistance {
  private let query: [UInt8]
  private var unmatchedQueryBytes: [Int]
  private var twoRowsBack: [Int]
  private var previousRow: [Int]
  private var currentRow: [Int]

  init(query: [UInt8]) {
    self.query = query
    unmatchedQueryBytes = [Int](repeating: 0, count: 256)
    for byte in query {
      unmatchedQueryBytes[Int(byte)] += 1
    }
    twoRowsBack = [Int](repeating: 0, count: query.count + 1)
    previousRow = twoRowsBack
    currentRow = twoRowsBack
  }

  var queryLength: Int {
    query.count
  }

  mutating func measure(_ candidate: UnsafeBufferPointer<UInt8>, atMost limit: Int) -> Int? {
    guard abs(query.count - candidate.count) <= limit, lettersAllow(candidate, within: limit) else {
      return nil
    }
    guard !query.isEmpty, !candidate.isEmpty else {
      return max(query.count, candidate.count)
    }
    let columns = query.count
    for column in 0...columns {
      previousRow[column] = column
    }
    var previousMinimum = 0
    for row in 1...candidate.count {
      currentRow[0] = row
      var rowMinimum = row
      let letter = candidate[row - 1]
      for column in 1...columns {
        let substitutionCost = letter == query[column - 1] ? 0 : 1
        var cost = min(previousRow[column] + 1, currentRow[column - 1] + 1, previousRow[column - 1] + substitutionCost)
        if row > 1, column > 1, letter == query[column - 2], candidate[row - 2] == query[column - 1] {
          cost = min(cost, twoRowsBack[column - 2] + 1)
        }
        currentRow[column] = cost
        rowMinimum = min(rowMinimum, cost)
      }
      // A swap reaches back two rows, so both rows must exceed the limit before giving up.
      if rowMinimum > limit, previousMinimum > limit {
        return nil
      }
      previousMinimum = rowMinimum
      swap(&twoRowsBack, &previousRow)
      swap(&previousRow, &currentRow)
    }
    let distance = previousRow[columns]
    return distance <= limit ? distance : nil
  }

  // An insertion or deletion changes the count of one letter, a substitution of two, and a
  // swap of none, so half the letters the two do not share is a floor on their distance.
  private mutating func lettersAllow(_ candidate: UnsafeBufferPointer<UInt8>, within limit: Int) -> Bool {
    var shared = 0
    for byte in candidate {
      let index = Int(byte)
      if unmatchedQueryBytes[index] > 0 {
        shared += 1
      }
      unmatchedQueryBytes[index] -= 1
    }
    for byte in candidate {
      unmatchedQueryBytes[Int(byte)] += 1
    }
    let unshared = query.count + candidate.count - 2 * shared
    return (unshared + 1) / 2 <= limit
  }
}
