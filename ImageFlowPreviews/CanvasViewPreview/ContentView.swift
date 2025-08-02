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
            HStack {
                CanvasView(self.$viewport, self.$nodePositions) { id in
                    ColorNodeView(id: id, size: CGSize(width: 200, height: 200), color: .red)
                }
                .border(.gray.opacity(0.25))
                
                List {
                    Section("positions") {
                        ForEach(self.nodePositions.sorted(by: { $0.key.uuidString < $1.key.uuidString }), id: \.key) { item in
                            Text("\(Int(item.value.x)), \(Int(item.value.y))")
                                .font(.caption2)
                        }
                    }
                }
                .frame(width: 150)
            }
            Text("viewport: \(self.viewport)")
        }
        .padding(10)
    }
}

#Preview {
    ContentView()
}
