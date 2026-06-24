//
//  TutorView.swift
//  Conjuguer
//
//  Created by Josh Adams on 6/23/26.
//

import SwiftUI

struct TutorView: View {
  @State private var messages: [TutorMessage] = []
  @State private var inputText = ""
  @State private var isGenerating = false
  @State private var showingSampleQueries = false
  @State private var showingHint = true
  @State private var hasLoadedHistory = false
#if DEBUG
  @State private var showingTests = false
#endif
  @FocusState private var isInputFocused: Bool

  private static let suggestions = [
    "Conjugate parler in the présent.",
    "What is the passé composé of aller?",
    "What is the participe passé of prendre?",
    "Conjugate finir in the futur simple.",
    "What is the impératif of être?",
    "How do you say \u{2018}I would have spoken\u{2019} in French?",
    "What is the subjonctif présent of faire?",
    "Conjugate venir in the imparfait.",
    "How do you say \u{2018}we had finished\u{2019} in French?",
    "What is the conditionnel présent of pouvoir?",
    "Conjugate prendre in the passé composé.",
    "What are all the présent conjugations of avoir?",
    "How do you conjugate vouloir in the passé simple?",
    "What is the futur simple of voir?",
    "Conjugate mettre in the plus-que-parfait.",
    "How do you say \u{2018}they would sing\u{2019} in French?"
  ]

  var body: some View {
    ZStack {
      Color.customBackground
        .ignoresSafeArea()

      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            VStack(alignment: .leading, spacing: Layout.doubleDefaultSpacing) {
              Button(L.Tutor.getSampleQuery) {
                showingSampleQueries = true
              }
              .funButton()
              .frame(maxWidth: .infinity)

              Text(L.Tutor.getSampleQueryDescription)
                .settingsLabel()

              Text(L.Tutor.poweredBy)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, Layout.defaultSpacing)

              ForEach(messages) { message in
                messageBubble(message)
                  .id(message.id)
                  .transition(.move(edge: .bottom).combined(with: .opacity))
              }

              if isGenerating {
                typingIndicator
                  .id("typing")
              }
            }
            .padding(Layout.doubleDefaultSpacing)
          }
          .safeAreaInset(edge: .bottom) {
            if showingHint {
              Text(L.Tutor.inputPlaceholder)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, Layout.defaultSpacing)
                .background(Color.customBackground.opacity(0.8))
            }
          }
          .onChange(of: messages.count) {
            if hasLoadedHistory, let lastMessage = messages.last {
              withAnimation {
                proxy.scrollTo(lastMessage.id, anchor: .bottom)
              }
            }
          }
        }

        Rectangle()
          .fill(Color.customBlue)
          .frame(height: 1)
          .padding(.horizontal, Layout.doubleDefaultSpacing)

        inputBar
      }
    }
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .principal) {
#if DEBUG
        Text(L.Tutor.heading)
          .font(.headline)
          .onTapGesture(count: 3) {
            showingTests = true
          }
#else
        Text(L.Tutor.heading)
          .font(.headline)
#endif
      }
    }
#if DEBUG
    .sheet(isPresented: $showingTests) {
      TutorTestView()
    }
#endif
    .sheet(isPresented: $showingSampleQueries) {
      sampleQueriesSheet
    }
    .onAppear {
      messages = TutorChatHistory.load(getterSetter: Current.getterSetter)
    }
    .task {
      hasLoadedHistory = true
    }
    .onDisappear {
      Current.languageModelService.resetTutorSession()
    }
    .onChange(of: isInputFocused) {
      if isInputFocused {
        showingHint = false
      }
    }
    .recordsAppearance(as: "\(TutorView.self)")
  }

  private var sampleQueriesSheet: some View {
    TutorSheet(title: L.Tutor.getSampleQuery) {
      VStack(spacing: Layout.defaultSpacing) {
        ForEach(Self.suggestions, id: \.self) { suggestion in
          Button {
            inputText = suggestion
            isInputFocused = true
            showingSampleQueries = false
          } label: {
            Text(suggestion)
              .fixedSize(horizontal: false, vertical: true)
          }
          .font(.subheadline)
          .foregroundStyle(Color.customBlue)
          .padding(.horizontal, Layout.defaultSpacing + 4)
          .padding(.vertical, Layout.defaultSpacing / 2)
          .background(
            Capsule()
              .strokeBorder(Color.customBlue.opacity(0.4))
          )
        }
      }
      .padding(Layout.doubleDefaultSpacing)
    }
  }

  private var typingIndicator: some View {
    HStack {
      HStack(spacing: 4) {
        ForEach(0..<3, id: \.self) { index in
          Circle()
            .fill(Color.secondary)
            .frame(width: 6, height: 6)
            .opacity(0.5)
            .phaseAnimator([false, true], trigger: isGenerating) { content, phase in
              content.offset(y: phase ? -4 : 0)
            } animation: { _ in
              .easeInOut(duration: 0.4).delay(Double(index) * 0.15)
            }
        }
      }
      .padding(Layout.defaultSpacing + 4)
      .background(
        RoundedRectangle(cornerRadius: 12)
          .fill(Color.customSurface)
          .shadow(radius: 1)
      )
      Spacer(minLength: 60)
    }
  }

  private func messageBubble(_ message: TutorMessage) -> some View {
    HStack {
      if message.role == .user {
        Spacer(minLength: 60)
      }

      Text(message.content)
        .foregroundStyle(message.role == .user ? .white : Color.customForeground)
        .padding(Layout.defaultSpacing + 4)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(message.role == .user ? Color.customBlue : Color.customSurface)
            .shadow(radius: 1)
        )
        .fixedSize(horizontal: false, vertical: true)

      if message.role == .assistant {
        Spacer(minLength: 60)
      }
    }
  }

  private var inputBar: some View {
    HStack(spacing: Layout.defaultSpacing) {
      TextField("", text: $inputText, axis: .vertical)
        .textFieldStyle(.roundedBorder)
        .lineLimit(1...4)
        .focused($isInputFocused)
        .submitLabel(.send)
        .onSubmit { sendMessage() }

      Button {
        sendMessage()
      } label: {
        if isGenerating {
          ProgressView()
            .frame(width: 24, height: 24)
        } else {
          Image(systemName: "arrow.up.circle.fill")
            .font(.title2)
            .foregroundStyle(Color.customBlue)
        }
      }
      .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || isGenerating)
      .accessibilityLabel(L.Tutor.send)
    }
    .padding(Layout.doubleDefaultSpacing)
    .background(Color.customBackground)
  }

  private func sendMessage() {
    let trimmed = inputText.trimmingCharacters(in: .whitespaces)
    guard !trimmed.isEmpty, !isGenerating else {
      return
    }

    let userMessage = TutorMessage(role: .user, content: trimmed)
    messages.append(userMessage)
    inputText = ""
    isGenerating = true
    SoundPlayer.play(.chirp)
    saveMessages()

    Task {
      do {
        let response = try await Current.languageModelService.sendTutorMessage(trimmed)
        let assistantMessage = TutorMessage(role: .assistant, content: response)
        messages.append(assistantMessage)
        SoundPlayer.play(.chirp)
      } catch {
        let errorMessage = TutorMessage(role: .assistant, content: L.Tutor.unavailable)
        messages.append(errorMessage)
        SoundPlayer.play(.chirp)
      }
      isGenerating = false
      saveMessages()
    }
  }

  private func saveMessages() {
    var trimmed = messages
    if trimmed.count > TutorChatHistory.maxMessages {
      trimmed = Array(trimmed.suffix(TutorChatHistory.maxMessages))
    }
    TutorChatHistory.save(trimmed, getterSetter: Current.getterSetter)
  }
}

private struct TutorSheet<Content: View>: View {
  let title: String
  @ViewBuilder let content: () -> Content
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    NavigationStack {
      ZStack {
        Color.customBackground
          .ignoresSafeArea()

        ScrollView {
          content()
        }
      }
      .navigationTitle(title)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(L.Navigation.done) {
            dismiss()
          }
        }
      }
    }
  }
}
