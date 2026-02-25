//
//  ContentView.swift
//  InspectorPreview
//
//  Created by Daniel Fortes on 05/03/26.
//

import SwiftUI
import InspectorFeature

struct ContentView: View {
    var body: some View {
        VStack {
            BlockGridLayout.Preview()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
