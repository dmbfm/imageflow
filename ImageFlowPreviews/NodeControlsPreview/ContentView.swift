//
//  ContentView.swift
//  NodeControlsPreview
//
//  Created by Daniel Fortes on 07/08/25.
//

import NodeControls
import SwiftUI
import Values

struct ContentView: View {
  @State var text: String = "50"
  @State var number: Value = .float(0.5)
  var body: some View {
    VStack(spacing: 20) {
      VStack {
        NodeTextField.Preview($text)
        Text("<\(self.text)>")
      }

      VStack {
        NodeNumberInput.Preview(value: self.$number)
        Text("<\(self.number)>")
      }
    }
    .padding()
  }
}
