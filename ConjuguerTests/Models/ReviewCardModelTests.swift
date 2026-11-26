//
//  ReviewCardModelTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/26/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct ReviewCardModelTests {
  private final class Clock {
    var date: Date

    init(_ date: Date) {
      self.date = date
    }
  }

  private static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "UTC") ?? .gmt
    return calendar
  }()

  private let practice = PracticeStore(getterSetter: GetterSetterFake(), calendar: Self.calendar)
  private let analytics = AnalyticsSpy()
  private let clock = Clock(.distantPast)

  /// Day `day` of 2026-11, at noon UTC.
  private func date(_ day: Int) -> Date {
    Self.calendar.date(from: DateComponents(year: 2026, month: 11, day: day, hour: 12)) ?? .distantPast
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  /// venir looked up on the 1st and prendre on the 2nd, so on the 3rd venir is the longer overdue.
  private func model(on day: Int = 3) throws -> ReviewCardModel {
    practice.recordLookup(try verb("venir"), source: .search, at: date(1))
    practice.recordLookup(try verb("prendre"), source: .search, at: date(2))
    clock.date = date(day)
    let clock = clock
    return ReviewCardModel(practice: practice, analytics: analytics, gameCenter: GameCenterSpy()) {
      clock.date
    }
  }

  private func count(_ name: AnalyticsName) -> Int {
    analytics.signalNames.filter { $0 == name }.count
  }

  @Test func theListsFirstAppearanceChoosesTheLongestOverdueVerb() throws {
    let card = try model()
    #expect(card.card == nil)

    card.listAppeared(isSuppressed: false)
    #expect(card.card?.offer.verb == (try verb("venir")))
    #expect(card.card?.isRevealed == false)
    #expect(card.open() == VerbDestination(verb: try verb("venir"), source: .reviewCard))
  }

  @Test func aDismissalBeforeTheRevealSnoozesTheVerbToTomorrow() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)
    let items = try #require(card.card?.offer.items)
    let boxes = items.map { practice.record.entry(for: $0)?.schedule.box }

    card.dismiss()

    #expect(card.card == nil)
    #expect(items.map { practice.record.entry(for: $0)?.schedule.box } == boxes)
    #expect(Set(items).isDisjoint(with: practice.dueItems(at: date(3))))
    #expect(Set(items).isSubset(of: practice.dueItems(at: date(4))))
  }

  @Test func aDismissalAfterTheRevealChangesNothing() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)
    card.reveal()
    let record = practice.record

    card.dismiss()

    #expect(card.card == nil)
    #expect(practice.record == record)
  }

  @Test func aRevealAppliesOnce() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)

    card.reveal()
    let record = practice.record
    card.reveal()

    #expect(card.card?.isRevealed == true)
    #expect(practice.record == record)
    #expect(practice.cardOffer(at: date(3))?.verb == (try verb("prendre")))
    #expect(count(.tapRevealReviewCard) == 1)
  }

  @Test func theCardIsChosenOncePerOpening() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)
    card.reveal()

    card.listAppeared(isSuppressed: false)
    card.appBecameActive(isSuppressed: false)
    #expect(card.card?.offer.verb == (try verb("venir")))
    #expect(card.card?.isRevealed == true)

    card.appEnteredBackground()
    card.appBecameActive(isSuppressed: false)
    #expect(card.card?.offer.verb == (try verb("prendre")))
    #expect(card.card?.isRevealed == false)
  }

  @Test func theCardIsSignalledOncePerOffer() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)

    card.shown()
    card.shown()
    #expect(count(.viewReviewCard) == 1)

    card.appEnteredBackground()
    card.appBecameActive(isSuppressed: false)
    card.shown()
    #expect(count(.viewReviewCard) == 2)
  }

  @Test func anOfferEndedByALookupIsNeitherSignalledNorRevealed() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)
    practice.recordLookup(try verb("venir"), source: .search, at: date(3))
    let record = practice.record

    card.shown()
    card.reveal()

    #expect(card.card == nil)
    #expect(practice.record == record)
    #expect(analytics.signalNames.isEmpty)
  }

  @Test func anOfferEndedByAResetLeavesWhenTheRecordChanges() throws {
    let card = try model()
    card.listAppeared(isSuppressed: false)

    practice.reset()
    card.recordChanged()

    #expect(card.card == nil)
  }

  /// An open from the card records a lookup that does not reschedule, so the card waits for its
  /// reveal. A revealed card is no longer due, and stays as it is.
  @Test func theCardOutlivesItsOwnOpenAndItsOwnReveal() throws {
    let card = try model()
    let venir = try verb("venir")
    card.listAppeared(isSuppressed: false)

    practice.recordLookup(venir, source: .reviewCard, at: date(3))
    card.recordChanged()
    #expect(card.card?.offer.verb == venir)

    card.reveal()
    card.recordChanged()
    #expect(card.card?.isRevealed == true)
  }

  @Test func suppressionHidesTheCardAndLiftingItChoosesOne() throws {
    let card = try model()
    card.listAppeared(isSuppressed: true)
    #expect(card.card == nil)

    card.suppressionChanged(isSuppressed: false)
    #expect(card.card?.offer.verb == (try verb("venir")))

    card.suppressionChanged(isSuppressed: true)
    #expect(card.card == nil)
  }
}
