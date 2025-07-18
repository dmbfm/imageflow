//
//  ContentView.swift
//  CanvasViewPreview
//
//  Created by Daniel Fortes on 18/07/25.
//

import SwiftUI
import CanvasView

struct ContentView: View {
    
    @State var viewport: CanvasViewport = .init()
    
    var body: some View {
        VStack {
            GridView(viewport:  self.$viewport)
        }
        .border(.gray)
        .padding()
    }
}

#Preview {
    ContentView()
}
