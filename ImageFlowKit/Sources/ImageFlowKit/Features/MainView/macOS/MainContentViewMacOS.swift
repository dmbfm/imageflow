//
//  MainContentViewMacOS.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 02/10/25.
//

#if os(macOS)

import Helpers
import SwiftUI

struct MainContentViewMacOS: View {

    let flow: Flow
    let canvas: CanvasFeatureState

    @FocusState var focus: Focus?

    @State var canvasCenter: Box<CGPoint> = .init(.zero)

    @Environment(\.undoManager) var undoManager

    init(flow: Flow, canvas: CanvasFeatureState) {
        self.flow = flow
        self.canvas = canvas
    }

    func onDoubleClick(nodePaletteItem item: NodePaletteItem) {
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    var body: some View {
        #if os(macOS)
        NavigationSplitView {
            SidebarFeatureView(self.$focus, self.onDoubleClick(nodePaletteItem:))
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            DetailView(flow: self.flow, canvas: self.canvas, focus: self.$focus, canvasCenter: self.canvasCenter)
        }
        #else
        DetailView(flow: self.flow, canvas: self.canvas, focus: self.$focus)
        #endif
    }
}

fileprivate struct DetailView: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    let focus: FocusState<Focus?>.Binding
    let canvasCenter: Box<CGPoint>

    var body: some View {
        ZStack {
            CanvasFeatureView(self.canvas, self.flow, self.focus)
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.canvasCenter.value = newValue
                }
        }
    }
}

#endif
