//
//  MainViewMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 28/08/25.
//

#if canImport(AppKit)

import CanvasFeature
import SidebarFeature
import SwiftUI

struct MainViewMac: View {
    @Binding var document: ImageFlowDocument
    @State var showNodePalettePopover: Bool = false

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
            ZStack {
                CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
            }
        }
    }
}

#endif
