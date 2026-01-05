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

    @FocusState var focus: Focus?

    @State var vm: MainContentViewModel

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
    ) {
        self._vm = .init(wrappedValue: .init(flow: flow, canvas: canvas, assetStore: assetStore))
    }

    var body: some View {
        NavigationSplitView {
            SidebarFeatureView(self.$focus, self.vm.onDoubleClick(nodePaletteItem:))
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
                .scrollEdgeEffectStyle(.hard, for: .top)
        } detail: {
            DetailView(
                vm: self.vm,
                focus: self.$focus,
            )
        }
        .toolbar { self.toolbarContent }
        .toolbarRole(.editor)
        .sheet(
            isPresented: self.$vm.showAssetBrowser,
            content: {
                AssetBrowserView(
                    assetsProvider: self.vm.assetStore,
                    allowedAssetKinds: self.vm.type.allowedAssetKinds,
                    allowedImportTypes: self.vm.type.allowedAssetKinds.types,
                    photoPickerDisabled: !self.vm.type.allowedAssetKinds.contains(.image)
                )
            }
        )
        .photosPicker(
            isPresented: self.$vm.showPhotoPicker,
            selection: self.$vm.selectedPhotoPickerItems,
            matching: .images,
            photoLibrary: .shared(),
        )
        .fileImporter(
            isPresented: self.$vm.showFileImporter,
            allowedContentTypes: self.vm.fileImporterConfiguration.allowedContentTypes,
            allowsMultipleSelection: true,
            onCompletion: self.vm.fileImporterCompletionHandler(_:)
        )
        .errorAlert(self.$vm.error)
        .onChange(of: self.undoManager, initial: true) { self.vm.undoManager = self.undoManager }
        .onChange(of: self.vm.showFileImporter, initial: false, self.vm.onChangeOfShowFileImporter)
        .onChange(of: self.vm.showPhotoPicker, initial: false, self.vm.onChangeOfShowPhotoPicker)
        .onChange(of: self.vm.selectedPhotoPickerItems, initial: false, self.vm.onChangeOfPhotoPickerItems)
    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItemGroup {
            Button {
                self.vm.openAssetBrowser()
            } label: {
                Image(systemName: "photo.badge.plus")
            }
        }
    }
}

fileprivate struct DetailView: View {

    let vm: MainContentViewModel
    let focus: FocusState<Focus?>.Binding

    @Environment(\.colorScheme) var cs

    var body: some View {
        ZStack(alignment: .top) {
            CanvasFeatureView(self.vm.canvas, self.vm.flow, self.vm.assetStore, self.focus, self.vm)
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.vm.canvasCenter = newValue
                }

            // NOTE: `Color.white.opacity(0.0001)` + backgroundExtensionEffect() creates a blur
            // effect on the toolbar! This does not work if we use `Color.clear` instead.
            Rectangle()
                .fill(Color.white.opacity(0.0001))
                .frame(height: 60)
                .ignoresSafeArea(.all, edges: [.top])
                .backgroundExtensionEffect()
        }
    }
}

#endif
