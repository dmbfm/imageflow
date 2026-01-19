//
//  ContentView2.swift
//  ImageFlowPreviews
//
//  Created by Daniel Fortes on 19/01/26.
//

import SwiftUI

struct ContentView2: View {
    
    @State var position: CGPoint = .zero
    @State var showPopover: Bool = false
    @State var text: String = ""
    
    var body: some View {
        ZStack {
            Color(white: 0.95)
            
            VStack { }
            .frame(width: 10, height: 10)
            .background { Color.blue }
            .popover(isPresented: self.$showPopover, arrowEdge: .bottom) {
                VStack {
                    TextField("", text: self.$text)
                    List {
                        Text("a")
                        Text("b")
                        Text("c")
                        Text("d")
                    }
                }
                .frame(width: SIZE.width, height: SIZE.height)
            }
            .position(self.position)
        }
        .overlay {
            RightDownView(position: self.$position, show: self.$showPopover)
        }
    }
}

private struct RightDownView: NSViewRepresentable {
    
    @Binding var position: CGPoint
    @Binding var show: Bool
    
    func makeNSView(context: Context) -> some NSView {
        Inner(position: self.$position, show: self.$show)
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
    
    class Inner: NSView {
        
        @Binding var position: CGPoint
        @Binding var show: Bool

        init(position: Binding<CGPoint>, show: Binding<Bool>) {
            self._position = position
            self._show = show
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            nil
        }
        
        override func rightMouseDown(with event: NSEvent) {
            print("\(event.locationInWindow)")
            let loc = self.convert(event.locationInWindow, from: nil)
            self.position.x = loc.x
            self.position.y = self.bounds.height - loc.y - 1
            self.show.toggle()
            super.rightMouseDown(with: event)
        }
    }
}
