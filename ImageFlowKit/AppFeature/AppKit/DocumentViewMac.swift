//
//  MainViewMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 28/08/25.
//

#if canImport(AppKit)

import CanvasFeature
import CommonUtils
import SidebarFeature
import Models
import PlatformUtils
import Logging
import SwiftUI

struct DocumentViewMac: View {
    @Bindable var state: DocumentState
    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @State var showNodePalettePopover: Bool = false
    @State var dispatcher = Dispatcher()

    init(_ state: DocumentState) {
        self.state = state
    }

    func windowAutosaveFrameFix(_ window: NSWindow?) {
        guard let window else { return }
        let name = "imageFlowDocumentWindow"
        if !window.setFrameUsingName(name) {
            let screenFrame = window.screen?.frame ?? .init(x: 0, y: 0, width: 1920, height: 1080)
            let margin: CGPoint = .init(x: 0.1, y: 0.1)
            let frame = screenFrame.insetBy(
                dx: margin.x * screenFrame.size.width,
                dy: margin.y * screenFrame.size.height
            )
            window.setFrame(frame, display: false, animate: false)
        }
        window.windowController?.windowFrameAutosaveName = name
        window.isRestorable = true
    }

    var body: some View {
        self.contentView
            //            .toolbar {
            //                ToolbarItem {
            //                    Button {
            //                        self.showNodePalettePopover.toggle()
            //                        print("\(self.showNodePalettePopover)")
            //                    } label: {
            //                        Image(systemName: "plus")
            //                    }
            //                    .popover(isPresented: self.$showNodePalettePopover) {
            //                        NodePaletteListView()
            //                            .presentationCompactAdaptation(.popover)
            //                    }
            //                }
            //            }
            .windowAccessor { self.windowAutosaveFrameFix($0) }
    }

    @ViewBuilder
    var contentView: some View {
        NavigationSplitView {
            SidebarFeatureView()
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            self.canvasView
        }
        .environmentObject(self.dispatcher)
        .onAppear {
            self.dispatcher.listen { self.dispatch(action: $0) }
        }
    }

    var canvasView: some View {
        ZStack {
            CanvasFeatureView(
                self.$state.canvas,
                self.$state.nodeData,
                self.$state.nodeSelection,
            )
            .onGeometryChange(for: CGPoint.self) { proxy in
                proxy.frame(in: .local).center
            } action: { newValue in
                self.canvasCenter.value = newValue
            }
            .onChange(of: self.state.canvas, initial: true) {
                log("xxx canvas: \(self.state.canvas)")
            }
        }
    }
}

#endif
