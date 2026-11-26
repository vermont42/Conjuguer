//
//  VerbListContentTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Testing

@MainActor
struct VerbListContentTests {
  struct Case: Sendable {
    let isSearching: Bool
    let hasFailed: Bool
    let isEngaged: Bool
    let hasRecents: Bool
    let mode: VerbListMode
    let expected: VerbListContent
  }

  @Test(arguments: [
    Case(isSearching: true, hasFailed: true, isEngaged: true, hasRecents: true, mode: .myVerbs, expected: .noResults),
    Case(isSearching: true, hasFailed: false, isEngaged: true, hasRecents: true, mode: .myVerbs, expected: .results),
    Case(isSearching: false, hasFailed: false, isEngaged: true, hasRecents: true, mode: .myVerbs, expected: .recents),
    Case(isSearching: false, hasFailed: false, isEngaged: true, hasRecents: false, mode: .myVerbs, expected: .myVerbs),
    Case(isSearching: false, hasFailed: false, isEngaged: false, hasRecents: true, mode: .myVerbs, expected: .myVerbs),
    Case(isSearching: false, hasFailed: false, isEngaged: true, hasRecents: false, mode: .sorted(.frequency), expected: .all),
    Case(isSearching: false, hasFailed: false, isEngaged: false, hasRecents: true, mode: .sorted(.alphabetical), expected: .all)
  ])
  func aSearchOutranksTheRecentsAndTheRecentsTheMode(_ row: Case) {
    let content = VerbListContent(isSearching: row.isSearching, hasFailed: row.hasFailed, isEngaged: row.isEngaged, hasRecents: row.hasRecents, mode: row.mode)
    #expect(content == row.expected)
  }

  @Test func onlyEveryVerbShowsTheReviewCard() {
    let contents: [VerbListContent] = [.all, .results, .noResults, .recents, .myVerbs]
    #expect(contents.filter(\.showsReviewCard) == [.all])
  }
}
