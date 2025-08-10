//
//  ContentView.swift
//  NodeViewPreview
//
//  Created by Daniel Fortes on 10/08/25.
//

import SwiftUI
import NodeView
import Models

struct ContentView: View {
    @State var node: FlowNode = .init(kind: .addNode(.float))
    var body: some View {
        VStack {
            NodeView.Preview(node: self.node)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
