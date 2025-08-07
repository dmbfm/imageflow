//
//  ContentView.swift
//  NodeControlsPreview
//
//  Created by Daniel Fortes on 07/08/25.
//

import SwiftUI
import NodeControls

struct ContentView: View {
    @State var text: String = "Hello!"
    var body: some View {
        VStack {
            NodeTextField.Preview($text)
            Text("<\(self.text)>")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
