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
            .windowAccessor { self.windowAutosaveFrameFix($0) }
    }

    @ViewBuilder
    var contentView: some View {
        NavigationSplitView {
            SidebarFeatureView()
                .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 400)
        } detail: {
            ZStack {
                CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
            }
        }
    }
}

#endif
