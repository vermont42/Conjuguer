//
//  FrequencyBandTests.swift
//  ConjuguerTests
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct FrequencyBandTests {
  @Test(arguments: FrequencyBand.allCases)
  func aBandHoldsItsCountOfInfinitives(band: FrequencyBand) {
    let verbs = Verb.verbs(in: band)
    #expect(Set(verbs.map(\.infinitif)).count == band.rankLimit)
    #expect(verbs.allSatisfy { $0.isIn(band) })
    #expect(verbs.map(\.frequency) == verbs.map(\.frequency).sorted())
  }

  @Test func theBandsNest() {
    let top100 = Set(Verb.verbs(in: .top100).map(\.dictionaryKey))
    let top300 = Set(Verb.verbs(in: .top300).map(\.dictionaryKey))
    let top1000 = Set(Verb.verbs(in: .top1000).map(\.dictionaryKey))
    #expect(top100.isSubset(of: top300))
    #expect(top300.isSubset(of: top1000))
  }

  @Test func bothEntriesOfADoubledInfinitiveShareABand() {
    let sortir = Verb.verbs(in: .top1000).filter { $0.infinitif == "sortir" }
    #expect(sortir.count == 2)
    #expect(Verb.verbs(in: .top1000).count == FrequencyBand.top1000.rankLimit + 1)
  }

  @Test func theMostFrequentVerbsLead() {
    #expect(Verb.verbs(in: .top100).prefix(3).map(\.infinitif) == ["être", "avoir", "faire"])
  }

  // `convaincre`'s FrWaC count is a failed join, and the estimate that replaced it was clamped to
  // rank 1,000's count, which left it at #1001 until the clamp was waived for quarantined rows.
  @Test func convaincreIsInTheTop1000() throws {
    let convaincre = try #require(Verb.verbs["convaincre"])
    #expect(convaincre.isIn(.top1000))
  }

  // GLÀFF counted these only where the corpus kept the ligature, so they carried zeros and
  // ranked near the bottom. Their counts now come from Lexique 4's `oe` spellings.
  @Test(arguments: ["manœuvrer", "écœurer", "œuvrer"])
  func aLigatureVerbIsNoLongerRankedAsUnattested(infinitif: String) throws {
    let verb = try #require(Verb.verbs[infinitif])
    #expect((verb.hits ?? 0) > 1_000)
    #expect(verb.hitsAreProvisional)
    #expect(verb.frequency < 2_000)
  }
}
