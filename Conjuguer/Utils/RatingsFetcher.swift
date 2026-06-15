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

  static func fetchRatingsDescription(completion: @escaping @MainActor (String) -> Void) {
    let request = URLRequest(url: RatingsFetcher.iTunesURL)

    // Capture main-actor-isolated state before entering the @Sendable closure.
    let errorMessage = RatingsFetcher.errorMessage
    let noRating = L.RatingsFetcher.noRating
    let oneRating = L.RatingsFetcher.oneRating
    let multipleRatings = L.RatingsFetcher.multipleRatings

    let task = Current.session.dataTask(with: request) { (responseData, _, error) in
      let description: String
      let exhortation = " Ajoutez la vôtre."

      if
        error == nil,
        let responseData = responseData,
        let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
        let results = json["results"] as? [[String: Any]],
        results.count == 1
      {
        let ratingsCount = (results[0])["userRatingCountForCurrentVersion"] as? Int ?? 0

        switch ratingsCount {
        case 0:
          description = noRating + exhortation
        case 1:
          description = oneRating + exhortation
        default:
          description = (NSString(format: multipleRatings as NSString, ratingsCount) as String) + exhortation
        }
      } else {
        description = errorMessage
      }

      Task { @MainActor in
        completion(description)
      }
    }

    task.resume()
  }

  static func stubData(ratingsCount: Int) -> Data {
    Data("{ \"resultCount\":1, \"results\": [ { \"userRatingCountForCurrentVersion\": \(ratingsCount) } ] }".utf8)
  }
}
