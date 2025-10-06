//
//  MainContentViewMacOS.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 02/10/25.
//

#if os(macOS)

import Helpers
import SwiftUI
import Logging

struct MainContentViewMacOS: View {

    let flow: Flow
    let canvas: CanvasFeatureState

    @FocusState var focus: Focus?

    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @State var showAssetBrowser: Bool = false

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    init(flow: Flow, canvas: CanvasFeatureState) {
        self.flow = flow
        self.canvas = canvas
    }

    func onDoubleClick(nodePaletteItem item: NodePaletteItem) {
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    var body: some View {
        NavigationSplitView {
            SidebarFeatureView(self.$focus, self.onDoubleClick(nodePaletteItem:))
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
        } detail: {
            DetailView(flow: self.flow, canvas: self.canvas, focus: self.$focus, canvasCenter: self.canvasCenter)
        }
        .sheet(
            isPresented: self.$showAssetBrowser,
            content: {
                AssetBrowserView(
                    assetProvider: AssetBrowserView.PreviewAssetProvider(ids: [UUID()]),
                    onChooseAsset: { id in
                        log("id: \(id)", level: .debug)
                    }
                )
            }
        )
        .toolbar { self.toolbarContent }
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                self.showAssetBrowser = true
            } label: {
                Image(systemName: "photo.badge.plus")
            }
        }
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
