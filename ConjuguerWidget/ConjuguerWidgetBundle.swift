//
//  ConjuguerWidgetBundle.swift
//  ConjuguerWidget
//

import SwiftUI
import WidgetKit

@main
struct ConjuguerWidgetBundle: WidgetBundle {
  var body: some Widget {
    VerbDuJourWidget()
    QuizWidget()
    QuickQuizControl()
    RandomVerbControl()
    QuizLiveActivity()
  }
}
