//
//  LearnerVerbsTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct LearnerVerbsTests {
  private let day: TimeInterval = 86_400

  private func date(_ days: Double) -> Date {
    Date(timeIntervalSinceReferenceDate: days * day)
  }

  private func verb(_ key: String) throws -> Verb {
    try #require(Verb.verbs[key])
  }

  @Test func recordOpenKeepsFirstAndLastDatesAndCount() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("aller", at: date(3))

    let entry = record.entries["aller"]
    #expect(entry?.firstOpened == date(1))
    #expect(entry?.lastOpened == date(3))
    #expect(entry?.openCount == 2)
    #expect(entry?.isStarred == false)
  }

  @Test func hasOpenedCountsOpensNotStars() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))

    #expect(record.hasOpened("aller"))
    #expect(!record.hasOpened("être"))
    #expect(!record.hasOpened("avoir"))
  }

  @Test func recentIsNewestFirst() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.recordOpen("avoir", at: date(3))
    record.recordOpen("aller", at: date(4))

    #expect(record.recent == ["aller", "avoir", "être"])
  }

  @Test func recentStopsAtItsLimit() {
    var record = LearnerVerbs()
    for index in 0..<(LearnerVerbs.recentLimit + 5) {
      record.recordOpen("verbe\(index)", at: date(Double(index)))
    }

    let recent = record.recent
    #expect(recent.count == LearnerVerbs.recentLimit)
    #expect(recent.first == "verbe\(LearnerVerbs.recentLimit + 4)")
  }

  @Test func equalDatesFallBackToTheKey() {
    var record = LearnerVerbs()
    record.recordOpen("être", at: date(1))
    record.recordOpen("aller", at: date(1))

    #expect(record.recent == ["aller", "être"])
  }

  @Test func starringAndUnstarring() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))
    #expect(record.isStarred("aller"))
    #expect(record.starred == ["être", "aller"])

    record.setStarred(false, key: "aller", at: date(3))
    #expect(!record.isStarred("aller"))
    #expect(record.starred == ["être"])
  }

  @Test func starringAgainKeepsTheFirstDate() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(5))

    #expect(record.entries["aller"]?.starred == date(1))
  }

  @Test func unstarringAVerbNeverOpenedForgetsIt() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))
    record.setStarred(false, key: "aller", at: date(2))

    #expect(record.entries.isEmpty)
  }

  @Test func unstarringAnOpenedVerbKeepsItsOpens() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(2))
    record.setStarred(false, key: "aller", at: date(3))

    #expect(record.recent == ["aller"])
    #expect(record.entries["aller"]?.openCount == 1)
  }

  @Test func myVerbsListsStarredThenRecentWithoutRepeats() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.setStarred(true, key: "être", at: date(3))
    record.setStarred(true, key: "pouvoir", at: date(4))

    #expect(record.myVerbs == ["pouvoir", "être", "aller"])
  }

  @Test func clearRecentsKeepsStarsAndProgress() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.setStarred(true, key: "être", at: date(3))

    record.clearRecents()

    #expect(record.recent.isEmpty)
    #expect(record.starred == ["être"])
    #expect(record.myVerbs == ["être"])
    #expect(record.hasOpened("aller"))
    #expect(record.hasOpened("être"))
    #expect(record.entries["aller"]?.firstOpened == date(1))
    #expect(record.entries["aller"]?.openCount == 1)
  }

  @Test func removingAStarredVerbTakesItOutOfMyVerbsAndKeepsItsProgress() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "aller", at: date(2))
    record.recordOpen("être", at: date(3))

    record.remove("aller")

    #expect(record.starred.isEmpty)
    #expect(record.myVerbs == ["être"])
    #expect(record.hasOpened("aller"))
    #expect(record.entries["aller"]?.openCount == 1)
  }

  @Test func removingAVerbNeverOpenedForgetsIt() {
    var record = LearnerVerbs()
    record.setStarred(true, key: "aller", at: date(1))

    record.remove("aller")

    #expect(record.entries.isEmpty)
  }

  /// Clear and the swipe leave such entries behind.
  @Test func anEntryWithOnlyAFirstOpenIsInNeitherList() throws {
    let opened = date(1).timeIntervalSinceReferenceDate
    let json = #"{"entries":{"aller":{"dictionaryKey":"aller","firstOpened":\#(opened),"openCount":1}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.starred.isEmpty)
    #expect(record.recent.isEmpty)
    #expect(record.myVerbs.isEmpty)
    #expect(record.hasOpened("aller"))
  }

  /// Reset Practice leaves this shape for a recent verb, and counting it would undo the reset.
  /// No earlier build wrote it: every open has set both dates since the record began.
  @Test func anEntryWithALastOpenButNoFirstOpenIsRecentButNotOpened() throws {
    let opened = date(1).timeIntervalSinceReferenceDate
    let json = #"{"entries":{"aller":{"dictionaryKey":"aller","lastOpened":\#(opened),"openCount":0}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.recent == ["aller"])
    #expect(!record.hasOpened("aller"))
  }

  /// What the build before collection progress counted on `firstOpened` wrote, with a starred,
  /// opened verb.
  @Test func anEntryFromTheEarlierBuildDecodesAndCountsAsOpened() throws {
    let opened = date(1).timeIntervalSinceReferenceDate
    let json = #"{"entries":{"venir":{"dictionaryKey":"venir","firstOpened":\#(opened),"lastOpened":\#(opened),"openCount":2,"starred":\#(opened)}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.hasOpened("venir"))
    #expect(record.starred == ["venir"])
    #expect(record.recent == ["venir"])
    #expect(record.entries["venir"]?.openCount == 2)
  }

  @Test func forgettingFirstOpensKeepsStarsAndRecent() {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("être", at: date(2))
    record.setStarred(true, key: "être", at: date(3))
    record.clearRecents()
    record.recordOpen("avoir", at: date(4))
    #expect(record.hasFirstOpens)

    record.forgetFirstOpens()

    #expect(!record.hasFirstOpens)
    #expect(!record.hasOpened("aller"))
    #expect(!record.hasOpened("être"))
    #expect(!record.hasOpened("avoir"))
    #expect(record.entries["aller"] == nil)
    #expect(record.starred == ["être"])
    #expect(record.recent == ["avoir"])
    #expect(record.entries["avoir"]?.openCount == 0)
  }

  /// B16: a learner who starred twelve of the last twenty opens still sees twenty under Recent.
  @Test func recentUnstarredLeavesOutTheStarredBeforeTheLimit() {
    var record = LearnerVerbs()
    let count = LearnerVerbs.recentLimit + 12
    for index in 0 ..< count {
      record.recordOpen("verbe\(index)", at: date(Double(index)))
    }
    for index in (count - 12) ..< count {
      record.setStarred(true, key: "verbe\(index)", at: date(Double(count)))
    }

    #expect(record.recentUnstarred.count == LearnerVerbs.recentLimit)
    #expect(record.recentUnstarred.first == "verbe\(count - 13)")
    #expect(record.myVerbs.count == 12 + LearnerVerbs.recentLimit)
    #expect(record.recent.count == LearnerVerbs.recentLimit)
  }

  @Test func removingAVerbNotInTheRecordChangesNothing() {
    var record = LearnerVerbs()
    record.recordOpen("être", at: date(1))
    let before = record

    record.remove("aller")

    #expect(record == before)
  }

  @Test func jsonRoundTrips() throws {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.setStarred(true, key: "être", at: date(2))

    let json = try #require(record.json)
    #expect(LearnerVerbs(json: json) == record)
  }

  /// A field added later, such as a due date, must stay optional, so that what an older build
  /// wrote still decodes. This pins the decoding of an entry that carries only its key and count.
  @Test func anEntryWithoutItsOptionalFieldsDecodes() throws {
    let json = #"{"entries":{"aller":{"dictionaryKey":"aller","openCount":0}}}"#

    let record = try #require(LearnerVerbs(json: json))
    #expect(record.entries["aller"]?.lastOpened == nil)
    #expect(record.entries["aller"]?.isStarred == false)
  }

  @Test func garbageDoesNotDecode() {
    #expect(LearnerVerbs(json: "not json") == nil)
  }

  /// Every learner before this record existed starts with nothing stored.
  @Test func theStoreStartsEmptyWithNothingStored() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())

    #expect(store.record == LearnerVerbs())
    #expect(store.myVerbs.isEmpty)
  }

  @Test func theStoreStartsEmptyFromAnUnreadableRecord() {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake(dictionary: [LearnerVerbs.storageKey: "{"]))

    #expect(store.myVerbs.isEmpty)
  }

  @Test func theStoreSavesAndReloads() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let aller = try verb("aller")
    let être = try verb("être")

    store.recordOpen(aller, at: date(1))
    #expect(store.toggleStar(être, at: date(2)))

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.recentVerbs.map(\.infinitif) == ["aller"])
    #expect(reloaded.starredVerbs.map(\.infinitif) == ["être"])
    #expect(reloaded.myVerbs.map(\.infinitif) == ["être", "aller"])
    #expect(reloaded.isStarred(être))

    #expect(!reloaded.toggleStar(être, at: date(3)))
    #expect(!LearnerVerbStore(getterSetter: getterSetter).isStarred(être))
  }

  @Test func theStoreSavesARemoval() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let aller = try verb("aller")
    store.recordOpen(aller, at: date(1))
    store.toggleStar(aller, at: date(2))

    store.remove(aller)

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.myVerbs.isEmpty)
    #expect(!reloaded.isStarred(aller))
  }

  @Test func theStoreSavesAClear() throws {
    let getterSetter = GetterSetterFake()
    let store = LearnerVerbStore(getterSetter: getterSetter)
    let aller = try verb("aller")
    store.recordOpen(aller, at: date(1))
    store.toggleStar(try verb("être"), at: date(2))

    store.clearRecents()

    let reloaded = LearnerVerbStore(getterSetter: getterSetter)
    #expect(reloaded.recentVerbs.isEmpty)
    #expect(reloaded.starredVerbs.map(\.infinitif) == ["être"])
    #expect(reloaded.hasOpened(aller))
  }

  /// The top 100's count, after the swipe and Clear that tidy My Verbs.
  @Test func tidyingMyVerbsKeepsACollectionsCount() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let top100 = Verb.verbs(in: .top100)
    let first = try #require(top100.first)
    let second = try #require(top100.dropFirst().first)
    store.recordOpen(first, at: date(1))
    store.recordOpen(second, at: date(2))
    store.toggleStar(second, at: date(3))
    #expect(store.openedCount(of: top100) == 2)

    store.remove(first)
    #expect(store.openedCount(of: top100) == 2)
    store.clearRecents()
    #expect(store.openedCount(of: top100) == 2)
    #expect(store.myVerbs == [second])

    store.forgetFirstOpens()
    #expect(store.openedCount(of: top100) == 0)
    #expect(store.myVerbs == [second])
  }

  /// The lists are kept between changes, so each change must refresh them.
  @Test func theStoresListsFollowEachChange() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let aller = try verb("aller")
    let être = try verb("être")

    store.recordOpen(aller, at: date(1))
    #expect(store.recentVerbs == [aller])
    store.recordOpen(être, at: date(2))
    #expect(store.recentVerbs == [être, aller])
    store.toggleStar(aller, at: date(3))
    #expect(store.starredVerbs == [aller])
    #expect(store.recentUnstarredVerbs == [être])
    #expect(store.myVerbs == [aller, être])
    store.remove(aller)
    #expect(store.starredVerbs.isEmpty)
    #expect(store.myVerbs == [être])
    store.clearRecents()
    #expect(store.myVerbs.isEmpty)
  }

  @Test func theStoreSkipsAVerbNoLongerInTheList() throws {
    var record = LearnerVerbs()
    record.recordOpen("aller", at: date(1))
    record.recordOpen("pasunverbe", at: date(2))
    let getterSetter = GetterSetterFake(dictionary: [LearnerVerbs.storageKey: try #require(record.json)])

    let store = LearnerVerbStore(getterSetter: getterSetter)
    #expect(store.recentVerbs.map(\.infinitif) == ["aller"])
  }

  @Test func recentUnstarredLeavesOutStarredVerbs() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let aller = try verb("aller")
    let être = try verb("être")
    store.recordOpen(aller, at: date(1))
    store.recordOpen(être, at: date(2))
    store.toggleStar(être, at: date(3))

    #expect(store.recentVerbs.map(\.infinitif) == ["être", "aller"])
    #expect(store.recentUnstarredVerbs.map(\.infinitif) == ["aller"])
  }

  private func world() -> World {
    let getterSetter = GetterSetterFake()
    let gameCenter = GameCenterSpy()
    return World(
      settings: Settings(getterSetter: getterSetter),
      gameCenter: gameCenter,
      quiz: Quiz(gameCenter: gameCenter),
      analytics: AnalyticsSpy(),
      reviewPrompter: ReviewPrompterDummy(),
      getterSetter: getterSetter,
      languageModelService: LanguageModelServiceDummy(),
      soundPlayer: SoundPlayerDummy(),
      learnerVerbs: LearnerVerbStore(getterSetter: GetterSetterFake()),
      practice: PracticeStore(getterSetter: GetterSetterFake()),
      liveActivities: LiveActivitiesSpy(),
      reminderScheduler: ReminderSchedulerSpy(),
      session: URLSession.stubSession(ratingsCount: 1)
    )
  }

  /// Reset Practice is the full forget: progress goes, and stars and Recent stay.
  @Test func resetPracticeForgetsWhichVerbsWereOpened() throws {
    let world = world()
    let aller = try verb("aller")
    let être = try verb("être")
    #expect(!world.hasPracticeToReset)

    world.learnerVerbs.toggleStar(être, at: date(1))
    #expect(!world.hasPracticeToReset, "A star alone is not Reset Practice's to forget.")
    world.learnerVerbs.recordOpen(aller, at: date(2))
    world.learnerVerbs.clearRecents()
    #expect(world.practice.isEmpty)
    #expect(world.hasPracticeToReset, "A verb once opened counts toward progress.")

    world.learnerVerbs.recordOpen(être, at: date(3))
    world.resetPractice()

    #expect(!world.hasPracticeToReset)
    #expect(!world.learnerVerbs.hasOpened(aller))
    #expect(!world.learnerVerbs.hasOpened(être))
    #expect(world.learnerVerbs.starredVerbs == [être])
    #expect(world.learnerVerbs.recentVerbs == [être])
  }

  @Test func theDoubledEntriesStayApart() throws {
    let store = LearnerVerbStore(getterSetter: GetterSetterFake())
    let france = try verb("haïr France")
    let québec = try verb("haïr Québec")

    store.recordOpen(france, at: date(1))
    store.toggleStar(québec, at: date(2))

    #expect(store.hasOpened(france))
    #expect(!store.hasOpened(québec))
    #expect(store.isStarred(québec))
    #expect(!store.isStarred(france))
    #expect(store.myVerbs.map(\.dictionaryKey) == ["haïr Québec", "haïr France"])
  }

  @Test func theListModesAreTheSortOrdersAndThenMyVerbs() {
    #expect(VerbListMode.allCases == [.sorted(.frequency), .sorted(.alphabetical), .myVerbs])
    #expect(VerbListMode.sorted(.alphabetical).displayName == VerbSort.alphabetical.displayName)
  }
}
