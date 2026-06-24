//
//  TutorTestView.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

#if DEBUG
import SwiftUI

private struct TutorTestResult: Identifiable {
  let id = UUID()
  let index: Int
  let query: String
  let response: String
  let isError: Bool
}

struct TutorTestView: View {
  @State private var results: [TutorTestResult] = []
  @State private var currentIndex = 0
  @State private var isRunning = false

  @Environment(\.dismiss) private var dismiss

  private static let englishQueries = [
    "How do you conjugate parler in the passé composé?",
    "What is the imparfait of aller?",
    "Conjugate avoir in the présent.",
    "What is the subjonctif présent of être?",
    "What is the participe passé of prendre?",
    "Conjugate finir in the futur simple.",
    "How is faire conjugated in the present indicative?",
    "What is the passé simple of venir?",
    "Conjugate pouvoir in the présent.",
    "What is the participe présent of manger?",
    "What is the imperative of savoir?",
    "How do you say \"I would have spoken\" in French?",
    "What is the difference between the passé composé and the imparfait?",
    "How do you conjugate pizza?",
    "Tell me about the weather.",
    "What is the conditionnel présent of vouloir?",
    "Conjugate écrire in the plus-que-parfait.",
    "What is the futur antérieur of partir?",
    "What is the conditionnel passé of devoir?",
    "What is the subjonctif imparfait of dire?",
    "How do you conjugate porter in the past?",
    "Conjugate manger in the présent.",
    "What is the passé composé of naître?",
    "What is the conditionnel présent of pouvoir?",
    "What is the participe passé of lire?",
    "What is the imperative of venir?",
    "Conjugate se laver in the passé composé.",
    "What is the participe présent of dormir?",
    "Conjugate devoir in the futur simple.",
    "What does the agreement of the participe passé mean?"
  ]

  private static let frenchQueries = [
    "Comment conjugue-t-on parler au passé composé ?",
    "Quel est l’imparfait d’aller ?",
    "Conjugue avoir au présent.",
    "Quel est le subjonctif présent d’être ?",
    "Quel est le participe passé de prendre ?",
    "Conjugue finir au futur simple.",
    "Comment conjugue-t-on faire à l’indicatif présent ?",
    "Quel est le passé simple de venir ?",
    "Conjugue pouvoir au présent.",
    "Quel est le participe présent de manger ?",
    "Quel est l’impératif de savoir ?",
    "Quelle est la forme « je » de parler au conditionnel passé ?",
    "Quelle est la différence entre le passé composé et l’imparfait ?",
    "Comment conjugue-t-on pizza ?",
    "Parle-moi de la météo.",
    "Quel est le conditionnel présent de vouloir ?",
    "Conjugue écrire au plus-que-parfait.",
    "Quel est le futur antérieur de partir ?",
    "Quel est le conditionnel passé de devoir ?",
    "Quel est le subjonctif imparfait de dire ?",
    "Comment conjugue-t-on porter au passé ?",
    "Conjugue manger au présent.",
    "Quel est le passé composé de naître ?",
    "Quel est le conditionnel présent de pouvoir ?",
    "Quel est le participe passé de lire ?",
    "Quel est l’impératif de venir ?",
    "Conjugue se laver au passé composé.",
    "Quel est le participe présent de dormir ?",
    "Conjugue devoir au futur simple.",
    "Que signifie l’accord du participe passé ?"
  ]

  private static var queries: [String] {
    Locale.current.language.languageCode?.identifier == "fr" ? frenchQueries : englishQueries
  }

  private static var totalTestCount: Int {
    queries.count
  }

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
          statusBanner

          ForEach(results) { result in
            resultCard(result)
          }
        }
        .padding(Layout.doubleDefaultSpacing)
      }
      .background(Color.customBackground)
      .navigationTitle("Tutor Tests")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.done) {
            dismiss()
          }
        }
        if !isRunning && results.count == Self.totalTestCount {
          ToolbarItem(placement: .primaryAction) {
            ShareLink(item: shareReport)
          }
        }
      }
      .task {
        await runAllTests()
      }
    }
  }

  @ViewBuilder
  private var statusBanner: some View {
    if isRunning {
      HStack(spacing: Layout.defaultSpacing) {
        ProgressView()
        Text("Running test \(currentIndex) of \(Self.totalTestCount)…")
          .foregroundStyle(Color.customForeground)
          .font(.subheadline)
      }
    } else if results.count == Self.totalTestCount {
      let errorCount = results.filter(\.isError).count
      Text(errorCount == 0
        ? "All \(Self.totalTestCount) tests complete."
        : "Done. \(errorCount) of \(Self.totalTestCount) returned errors.")
        .foregroundStyle(Color.customBlue)
        .font(.subheadline.weight(.semibold))
    }
  }

  private func resultCard(_ result: TutorTestResult) -> some View {
    VStack(alignment: .leading, spacing: Layout.defaultSpacing) {
      Text("#\(result.index)")
        .font(.caption.weight(.bold))
        .foregroundStyle(Color.customBlue)

      Text(result.query)
        .font(.subheadline.weight(.medium))
        .foregroundStyle(Color.customForeground)

      Text(result.response)
        .font(.caption)
        .foregroundStyle(result.isError ? Color.customRed : Color.customForeground)
        .fixedSize(horizontal: false, vertical: true)
    }
    .padding(Layout.defaultSpacing + 4)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(
      RoundedRectangle(cornerRadius: 12)
        .fill(Color.customSurface)
        .shadow(radius: 1)
    )
  }

  private var shareReport: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    let date = dateFormatter.string(from: Date())
    var lines = ["Tutor Test Results — \(date)", ""]
    for result in results {
      lines.append("#\(result.index) \(result.query)")
      lines.append("Response: \(result.response)")
      lines.append("")
    }
    return lines.joined(separator: "\n")
  }

  private func runAllTests() async {
    guard Current.languageModelService.isAvailable else {
      results.append(TutorTestResult(
        index: 0,
        query: "Availability check",
        response: "Language model is not available.",
        isError: true
      ))
      SoundPlayer.play(.chirp)
      return
    }

    isRunning = true
    for (index, query) in Self.queries.enumerated() {
      currentIndex = index + 1
      Current.languageModelService.resetTutorSession()
      do {
        let response = try await Current.languageModelService.sendTutorMessage(query)
        results.append(TutorTestResult(
          index: index + 1,
          query: query,
          response: response,
          isError: false
        ))
        SoundPlayer.play(.chirp)
      } catch {
        results.append(TutorTestResult(
          index: index + 1,
          query: query,
          response: "Error: \(error.localizedDescription)",
          isError: true
        ))
        SoundPlayer.play(.chirp)
      }
    }

    isRunning = false
  }
}
#endif
