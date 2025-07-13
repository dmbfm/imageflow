//
//  ContentView.swift
//  ImageFlowIPad
//
//  Created by Daniel Fortes on 11/07/25.
//

import SwiftUI
import NodeView


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
