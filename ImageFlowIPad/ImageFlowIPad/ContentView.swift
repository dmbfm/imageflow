//
//  ContentView.swift
//  ImageFlowIPad
//
//  Created by Daniel Fortes on 11/07/25.
//

import NodeView
import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
