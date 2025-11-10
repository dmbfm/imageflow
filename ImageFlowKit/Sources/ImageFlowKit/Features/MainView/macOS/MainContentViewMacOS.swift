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
    @State var assetBrowserType: AssetBrowserType = .browser(.init(assetKinds: .all))
    @State var showAssetBrowser: Bool = false
    @State var showFileImporter: Bool = false
    @State var fileImporterConfiguration: Box<FileImporterConfiguration> = .init(.init(allowedContentTypes: []))
    @State var showPhotoPicker: Bool = false
    @State var selectedPhotoPickerItems: [PhotosPickerItem] = []
    @State var error: LocalizedAlertError? = nil
    @State var assetBrowserError: LocalizedAlertError? = nil

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
                .scrollEdgeEffectStyle(.hard, for: .top)
        } detail: {
            DetailView(
                flow: self.flow,
                canvas: self.canvas,
                focus: self.$focus,
                canvasCenter: self.canvasCenter,
                delegate: self.canvasFeatureViewDelegate
            )
            .ignoresSafeArea(.all, edges: [.top, .horizontal])
        }
        .toolbar { self.toolbarContent }
        .toolbarRole(.editor)
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
            allowedContentTypes: self.fileImporterConfiguration.value.allowedContentTypes,
            allowsMultipleSelection: true,
            onCompletion: self.fileImporterCompletionHandler(_:)
        )
        .errorAlert(self.$error)
        .onChange(of: self.showFileImporter, initial: false, self.onChangeOfShowFileImporter)
        .onChange(of: self.showPhotoPicker, initial: false, self.onChangeOfShowPhotoPicker)
        .onChange(of: self.selectedPhotoPickerItems, initial: false, self.onChangeOfPhotoPickerItems)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                self.openAssetBrowser()
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
    let delegate: CanvasFeatureView.Delegate

    @Environment(\.colorScheme) var cs

    var topGradientColors: [Color] {
        let c = Colors.canvasBackground.color
        return [
            c.opacity(0.8),
            c.opacity(0.98),
            c.opacity(0.8),
            .clear,
        ]
    }

    var body: some View {
        ZStack(alignment: .top) {
            CanvasFeatureView(self.canvas, self.flow, self.focus, delegate)
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.canvasCenter.value = newValue
                }

            self.topGradient
        }
    }

    var topGradient: some View {
        Rectangle()
            .fill(LinearGradient(colors: topGradientColors, startPoint: .top, endPoint: .bottom))
            .frame(height: 60)
    }
}

#endif
