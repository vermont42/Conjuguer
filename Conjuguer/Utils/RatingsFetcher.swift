//
//  RatingsFetcher.swift
//  Conjuguer
//
//  Created by Joshua Adams on 12/19/21.
//

import Foundation

enum RatingsFetcher {
  static let iTunesID = "1588624373"
  static let errorMessage = "Fetching failed."

  private static let urlInitializationMessage = " URL could not be initializaed."

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

  static func fetchRatingsDescription(completion: @escaping (String) -> Void) {
    let request = URLRequest(url: RatingsFetcher.iTunesURL)

    let task = Current.session.dataTask(with: request) { (responseData, _, error) in
      if error != nil {
        completion(errorMessage)
        return
      } else if let responseData = responseData {
        guard
          let json = try? JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any],
          let results = json["results"] as? [[String: Any]],
          results.count == 1
          else {
            completion(errorMessage)
            return
        }

        let ratingsCount = (results[0])["userRatingCountForCurrentVersion"] as? Int ?? 0

        let description: String
        let exhortation = " Ajoutez la vôtre !"

        switch ratingsCount {
        case 0:
          description = L.RatingsFetcher.noRating + exhortation
        case 1:
          description = L.RatingsFetcher.oneRating + exhortation
        default:
          description = (NSString(format: L.RatingsFetcher.multipleRatings as NSString, ratingsCount) as String) + exhortation
        }
        completion(description)
      }
    }

    task.resume()
  }

  static func stubData(ratingsCount: Int) -> Data {
    return Data("{ \"resultCount\":1, \"results\": [ { \"userRatingCountForCurrentVersion\": \(ratingsCount) } ] }".utf8)
  }
}
