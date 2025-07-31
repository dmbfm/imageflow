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
    @State var showInspector: Bool = false
    
    var body: some View {
        VStack {
            CanvasView(self.$viewport)
                .border(.gray.opacity(0.25))
            Text("viewport: \(self.viewport)")
        }
        .padding(10)
    }
}

#Preview {
    ContentView()
}
