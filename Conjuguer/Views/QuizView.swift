//
//  QuizView.swift
//  Conjuguer
//
//  Created by Josh Adams on 9/30/21.
//

import SwiftUI

struct QuizView: View {
  @EnvironmentObject var quiz: Quiz
  @State var input = ""
  @FocusState private var conjugationFieldIsFocused: Bool

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(alignment: .leading) {
        HStack {
          Spacer()

          Text(L.Navigation.quiz)
            .headingLabel()
            .foregroundColor(Color.customBlue)

          Spacer()
        }

        if quiz.quizState == .inProgress {
          Group {
            Text("Verb: gésir")
              .bodyLabel()

            Spacer()
              .frame(height: 8)

            Text("Trans.: be located, lie dead, be buried")
              .bodyLabel()
          }

          Spacer()
            .frame(height: 8)

          Group {
            Text("Pronoun: ils")
              .bodyLabel()

            Spacer()
              .frame(height: 8)

            Text("Tense: passé simple")
              .bodyLabel()

            Spacer()
              .frame(height: 8)

            HStack {
              Text("Progress: 1 / 30")
                .bodyLabel()
                .foregroundColor(Color.customBlue)

              Spacer()

              Text("Score: 0")
                .bodyLabel()
                .foregroundColor(Color.customBlue)
            }

            Spacer()
              .frame(height: 8)

            HStack {
              Text("Elapsed: \(quiz.elapsedTime)")
                .bodyLabel()
                .foregroundColor(Color.customBlue)

              Spacer()

              Button("Quit") {
                quit()
              }
              .buttonLabel()
              .foregroundColor(Color.customRed)
            }

            TextField("conjugation", text: $input)
              .focused($conjugationFieldIsFocused)
              .autocapitalization(.none)
          }

          Spacer()
        }

        if quiz.quizState == .notStarted {
          Spacer()

          HStack {
            Spacer()

            Button("Start") {
              start()
            }
            .buttonLabel()
            .foregroundColor(Color.customRed)

            Spacer()
          }

          Spacer()
            .frame(height: 8)
        }
      }
    }
    .padding(.leading, 16)
    .padding(.trailing, 16)
  }

  private func quit() {
    SoundPlayer.play(.sadTrombone)
    conjugationFieldIsFocused = false
    input = ""
    quiz.quit()
  }

  private func start() {
    SoundPlayer.play(.gun)
    quiz.start()
    let delayForFocus: TimeInterval = 0.1 // https://stackoverflow.com/a/69134653
    DispatchQueue.main.asyncAfter(deadline: .now() + delayForFocus) {
      conjugationFieldIsFocused = true
    }
  }
}
