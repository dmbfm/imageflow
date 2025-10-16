//
//  MainContentViewMacOS.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 02/10/25.
//

#if os(macOS)

import Helpers
import SwiftUI
import PhotosUI
import Photos
import Logging

struct MainContentViewMacOS: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    let assetStore: AssetStore

    @FocusState var focus: Focus?

    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @State var assetBrowserType: AssetBrowserType = .browser
    @State var showAssetBrowser: Bool = false
    @State var showFileImporter: Bool = false
    @State var showPhotoPicker: Bool = false
    @State var selectedPhotoPickerItems: [PhotosPickerItem] = []

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore) {
        self.flow = flow
        self.canvas = canvas
        self.assetStore = assetStore
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
        .toolbar { self.toolbarContent }
        .sheet(
            isPresented: self.$showAssetBrowser,
            content: {
                AssetBrowserView(
                    type: self.assetBrowserType,
                    assetsProvider: self.assetStore,
                    delegate: self.assetBrowserDelegate,
                )
            }
        )
        .photosPicker(
            isPresented: self.$showPhotoPicker,
            selection: self.$selectedPhotoPickerItems,
            matching: .images,
            photoLibrary: .shared(),
        )
        .fileImporter(
            isPresented: self.$showFileImporter,
            allowedContentTypes: [.image],
            allowsMultipleSelection: true,
            onCompletion: self.fileImporterCompletionHandler(_:)
        )
        .onChange(of: self.showFileImporter, initial: false, self.onChangeOfShowFileImporter)
        .onChange(of: self.showPhotoPicker, initial: false, self.onChangeOfShowPhotoPicker)
        .onChange(of: self.selectedPhotoPickerItems, initial: false, self.onChangeOfPhotoPickerItems)
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
