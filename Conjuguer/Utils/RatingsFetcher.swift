//
//  RatingsFetcher.swift
//  Conjuguer
//
//  Created by Josh Adams on 12/19/21.
//

import Foundation

enum RatingsFetcher {
  static let iTunesID = "1588624373"
  static let errorMessage = "Fetching failed."

  private static let urlInitializationMessage = " URL could not be initialized."

  static var iTunesURL: URL {
    guard let iTunesURL = URL(string: "https://itunes.apple.com/lookup?id=\(iTunesID)") else {
      fatalError("iTunes" + urlInitializationMessage)
    }
    return iTunesURL
  }

  static var reviewURL: URL {
    guard let reviewURL = URL(string: "https://itunes.apple.com/app/conjuguer/id\(iTunesID)?action=write-review") else {
      fatalError("Rate/review" + urlInitializationMessage)
    }
    return reviewURL
  }

  private struct LookupResponse: Decodable {
    struct Result: Decodable {
      let userRatingCountForCurrentVersion: Int?
    }

    let results: [Result]
  }

  @MainActor static func fetchRatingsDescription() async -> String {
    let request = URLRequest(url: RatingsFetcher.iTunesURL)
    let exhortation = " Ajoutez la vôtre." // Not a bug.

    guard
      let (data, _) = try? await Current.session.data(for: request),
      let response = try? JSONDecoder().decode(LookupResponse.self, from: data),
      response.results.count == 1
    else {
      return errorMessage
    }

    let ratingsCount = response.results[0].userRatingCountForCurrentVersion ?? 0

    switch ratingsCount {
    case 0:
      return L.RatingsFetcher.noRating + exhortation
    default:
      return L.RatingsFetcher.ratings(count: ratingsCount) + exhortation
    }
  }

  static func stubData(ratingsCount: Int) -> Data {
    Data("{ \"resultCount\":1, \"results\": [ { \"userRatingCountForCurrentVersion\": \(ratingsCount) } ] }".utf8)
  }
}
