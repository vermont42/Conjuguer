//
//  VerbDestination.swift
//  Conjuguer
//
//  Created by Josh Adams on 11/27/26.
//

import Foundation

/// A verb page to push or present: the verb, how it was reached, and the cells a search marked.
struct VerbDestination: Hashable {
  let verb: Verb
  let source: AnalyticsSource
  var marks: MarkedConjugations?
}
