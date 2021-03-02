//
//  ModelBrowseView.swift
//  Conjuguer
//
//  Created by Joshua Adams on 2/17/21.
//

import SwiftUI

struct ModelBrowseView: View {
  @EnvironmentObject var current: World
  @ObservedObject var store: ModelStore

  var body: some View {
    NavigationView {
      VStack {
        Picker("", selection: $store.modelSort) {
          ForEach(ModelSort.allCases, id: \.self) { type in
            Text(type.rawValue).tag(type)
          }
        }
        .pickerStyle(SegmentedPickerStyle())

        ScrollView {
          ForEach(store.modelsAndDecorators, id: \.self) { modelAndDecorator in
            NavigationLink(destination: ModelView(model: modelAndDecorator.model), label: {
              Text(modelAndDecorator.model.exemplar + modelAndDecorator.decorator)
                .tableText()
            })
            .buttonStyle(PlainButtonStyle())
          }
          .navigationBarTitle("Verb Models")
        }
      }
    }
    .navigationViewStyle(StackNavigationViewStyle()) // https://stackoverflow.com/a/66024249
    .padding()
  }

  init() {
    //    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    //    UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    //    UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white, .backgroundColor: UIColor.black]
    //    UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white, .backgroundColor: UIColor.black]
    //    UINavigationBar.appearance().backgroundColor = .black
    //    UINavigationBar.appearance().tintColor = .white
    //    UINavigationBar.appearance().barTintColor = .black
    store = ModelStore(world: Current)
  }
}

struct ModelAndDecorator: Hashable {
  let model: VerbModel
  let decorator: String
}

final class ModelStore: ObservableObject {
  @Published var modelsAndDecorators: [ModelAndDecorator]
  private let current: World
  private let irregularityModelsAndDecorators: [ModelAndDecorator]
  private let alphabeticModelsAndDecorators: [ModelAndDecorator]
  private let identifierModelsAndDecorators: [ModelAndDecorator]

  init(world: World) {
    self.current = world
    modelSort = current.settings.modelSort

    irregularityModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.irregularity >= rhs.irregularity
    }
    .map { ModelAndDecorator(model: $0, decorator: " • \($0.irregularity)%") }

    alphabeticModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.exemplar.compare(rhs.exemplar, locale: Util.french) == .orderedAscending
    }
    .map { ModelAndDecorator(model: $0, decorator: "") }

    identifierModelsAndDecorators = VerbModel.models.values.sorted { lhs, rhs in
      lhs.position < rhs.position
    }
    .map { ModelAndDecorator(model: $0, decorator: " (\($0.id))") }

    switch modelSort {
    case .irregularity:
      modelsAndDecorators = irregularityModelsAndDecorators
    case .alphabetic:
      modelsAndDecorators = alphabeticModelsAndDecorators
    case .identifier:
      modelsAndDecorators = identifierModelsAndDecorators
    }
  }

  var modelSort: ModelSort {
    didSet {
      current.settings.modelSort = modelSort

      switch modelSort {
      case .irregularity:
        modelsAndDecorators = irregularityModelsAndDecorators
      case .alphabetic:
        modelsAndDecorators = alphabeticModelsAndDecorators
      case .identifier:
        modelsAndDecorators = identifierModelsAndDecorators
      }
    }
  }
}
