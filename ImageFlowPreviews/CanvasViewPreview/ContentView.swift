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
        CanvasView(viewport: self.$viewport) {
           PinkNodeView()
                .onTapGesture {
                    print("tap!!!!!!")
                }
                .offset(x: 50, y: 50)
        }
            .border(.gray.opacity(25))
            .padding(40)
    }
}

#Preview {
    ContentView()
}
