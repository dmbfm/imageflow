//
//  ContentView.swift
//  NodeSearchPopoverPrototype
//
//  Created by Daniel Fortes on 19/01/26.
//

import SwiftUI
import SharedModels

let SIZE: CGSize = .init(width: 400, height: 200)

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(white: 0.95)
            PopoverView()
        }
    }
}

struct _TextField: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        let view = NSTextField(string: "...")
        view.focusRingType = .none
        return view
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
}

struct PopovewContentView: View {
    
    @State var text: String = ""
    
    let pal = NodePaletteService.shared
    
    var body: some View {
            VStack(spacing: 0) {
//                VStack {
                    TextField("", text: self.$text)
                    .font(.system(size: 12))
                        .textFieldStyle(.plain)
                        .padding(2)
                        .background { Color.white }
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .padding(.horizontal)
                        .padding(.top)
                        .padding(.bottom, 8)
//                }
                List {
                    ForEach(pal.categories, id: \.self) { cat in
                        ForEach(cat.items, id: \.self) { item in
                            if self.text == "" || item.displayName.lowercased().contains(self.text.lowercased()) {
                                HStack(spacing: 4) {
                                    Text(cat.name.rawValue)
                                        .foregroundStyle(.tertiary)
                                    Image(systemName: "chevron.compact.right")
                                        .foregroundStyle(.tertiary)
                                    Image(systemName: item.icon)
                                    Text(item.displayName)
                                }
                                .font(.caption)
                            }
                        }
                    }
                }
                .listStyle(.inset)
        }
        .frame(width: SIZE.width, height: SIZE.height)
    }
}

final class PopoverVC: NSViewController {
    
    lazy var stackView: NSStackView = {
        let view = NSStackView(frame: .init(origin: .zero, size: SIZE))
        view.orientation = .vertical
        return view
    }()
    
    override func viewDidLoad() {
        self.view.setFrameSize(SIZE)
        let hv = NSHostingView(rootView: PopoverView())
        hv.sizingOptions = .intrinsicContentSize
        hv.setFrameSize(SIZE)
        self.view.addSubview(hv)
        self.view.needsDisplay = true
        self.view.needsLayout = true
    }
}

struct PopoverView: NSViewRepresentable {
    func makeNSView(context: Context) -> some NSView {
        Inner()
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
    }
    
    class Inner: NSView {
        
        lazy var popover: NSPopover = {
            let p = NSPopover()
            let controller = NSHostingController(rootView: PopovewContentView())
            controller.sizingOptions = .standardBounds
            p.contentViewController = controller
//            p.contentViewController = PopoverVC()
            p.behavior = .transient
            p.contentSize = SIZE
            p.animates = false
            return p
        }()
        
        override func rightMouseDown(with event: NSEvent) {
            let loc = self.convert(event.locationInWindow, from: nil)
            let rect = CGRect(x: loc.x, y: loc.y, width: 1, height: 1)
            self.popover.show(relativeTo: rect, of: self, preferredEdge: .minY)
        }
    }
}

#Preview {
    ZStack {
        PopovewContentView()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding()
    }
}
