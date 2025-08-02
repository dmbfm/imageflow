//
//  ContentView.swift
//  CanvasViewPreview
//
//  Created by Daniel Fortes on 18/07/25.
//

import SwiftUI
import CanvasView
import EventEmitter

struct ContentView: View {
    @State var viewport: CanvasViewport = .init()
    @State var nodePositions: [UUID: CGPoint] = [UUID():.zero]
    @State var showInspector: Bool = false
    
    var body: some View {
        VStack {
            CanvasView(self.$viewport, self.$nodePositions) { id in
                ColorNodeView(id: id, size: CGSize(width: 200, height: 200), color: .red)
//                nil
//                print("----------------> !!! <------------------")
//                return CustomHostingView(id: id)
            }
                .border(.gray.opacity(0.25))
            Text("viewport: \(self.viewport)")
        }
        .padding(10)
    }
}

#Preview {
    ContentView()
}
