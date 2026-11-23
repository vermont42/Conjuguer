//
//  VerbSearchGuessTests.swift
//  ConjuguerTests
//
//  Created by Josh Adams on 11/22/26.
//

@testable import Conjuguer
import Foundation
import Testing

@MainActor
struct VerbSearchGuessTests {
  private static let verbs = Verb.verbs.values.sorted { ($0.frequency, $0.id) < ($1.frequency, $1.id) }

  private func guess(_ query: String) -> String? {
    VerbSearch.guess(for: query, in: Self.verbs)?.verb.infinitif
  }

  @Test(arguments: [
    ("venier", "venir"),
    ("assoir", "asseoir"),
    ("manjer", "manger"),
    ("vneir", "venir"),
    ("parlé", "parler"),
    ("Venier", "venir"),
    ("se souvnir", "souvenir"),
    ("s'assoir", "asseoir"),
    ("etree", "être"),
    ("finnir", "finir")
  ])
  func testMisspellingGuessesItsVerb(query: String, expected: String) {
    #expect(guess(query) == expected)
  }

  @Test(arguments: ["xyzzyq", "qwrtpz", "zzzz", "   "])
  func testNonsenseGuessesNothing(query: String) {
    #expect(guess(query) == nil)
  }

  @Test func testEveryMisspellingFindsNothingBeforeGuessing() {
    for query in ["venier", "assoir", "manjer", "xyzzyq"] {
      #expect(VerbSearch.matches(for: query, in: Self.verbs, includeGlosses: true).isEmpty, "\(query) matched a verb")
    }
  }

  @Test func testTieGoesToTheMoreFrequentVerb() throws {
    let manger = try #require(Verb.verbs["manger"])
    let manier = try #require(Verb.verbs["manier"])
    #expect(manger.frequency < manier.frequency)
    #expect(VerbSearch.editDistance(Array("manjer"), Array("manier")) == 1)
    #expect(guess("manjer") == "manger")
  }

  @Test(arguments: [
    ("venir", "venir", 0),
    ("venier", "venir", 1),
    ("vneir", "venir", 1),
    ("", "venir", 5),
    ("venir", "", 5),
    ("abc", "cba", 2),
    ("ca", "abc", 3)
  ])
  func testEditDistance(lhs: String, rhs: String, expected: Int) {
    #expect(VerbSearch.editDistance(Array(lhs), Array(rhs)) == expected)
  }

  @Test(arguments: [(1, 1), (3, 1), (5, 1), (6, 2), (9, 3), (20, 3)])
  func testMaxGuessDistance(length: Int, expected: Int) {
    #expect(VerbSearch.maxGuessDistance(forQueryLength: length) == expected)
  }

  @Test(arguments: [
    (nil, 1, 5, 0),
    (nil, -1, 5, nil),
    (0, 1, 5, 1),
    (4, 1, 5, 4),
    (0, -1, 5, 0),
    (2, -1, 5, 1),
    (nil, 1, 0, nil),
    (3, 1, 1, 0)
  ] as [(Int?, Int, Int, Int?)])
  func testKeyboardSelection(current: Int?, offset: Int, count: Int, expected: Int?) {
    #expect(VerbBrowseView.keyboardSelection(after: current, moving: offset, count: count) == expected)
  }

  @Test func testMailtoEncodesEverythingOutsideTheUnreservedSet() {
    let url = URL.mailto("someone@example.com", subject: "x & y", body: "été=#1")
    #expect(url?.absoluteString == "mailto:someone@example.com?subject=x%20%26%20y&body=%C3%A9t%C3%A9%3D%231")
  }

  @Test func testMailtoRoundTripsTheQuery() throws {
    let subject = L.VerbBrowseView.verbRequestSubject(query: "venier")
    let url = try #require(URL.mailto(URL.developerEmail, subject: subject, body: "b"))
    let components = try #require(URLComponents(url: url, resolvingAgainstBaseURL: false))
    #expect(components.scheme == "mailto")
    #expect(components.path == URL.developerEmail)
    #expect(components.queryItems?.first { $0.name == "subject" }?.value == subject)
    #expect(subject.contains("venier"))
  }

  @Test func testVerbRequestNamesQueryAndAddress() {
    let text = L.VerbBrowseView.verbRequest(query: "venier", address: URL.developerEmail)
    #expect(text.contains("venier"))
    #expect(text.hasSuffix("\(URL.developerEmail)."))
  }
}
