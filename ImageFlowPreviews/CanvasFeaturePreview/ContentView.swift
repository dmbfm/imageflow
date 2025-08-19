//
//  ContentView.swift
//  CanvasFeaturePreview
//
//  Created by Daniel Fortes on 26/07/25.
//

import CanvasFeature
import NodeDataStore
import SwiftUI

struct ContentView: View {

  @State var state: CanvasFeatureState = .init()
  @State var nodeDataStore: NodeDataStore = .init()

  init() {
    let id = UUID()
    self._state = .init(wrappedValue: .init(nodePositions: [id: .zero]))
    self._nodeDataStore = .init(wrappedValue: .init([id: .init(id: id, kind: .addNode(.float))]))
  }

  var body: some View {
    ZStack {
      CanvasFeatureView(self.$state, self.$nodeDataStore)
    }
  }
}

#Preview {
  ContentView()
}
