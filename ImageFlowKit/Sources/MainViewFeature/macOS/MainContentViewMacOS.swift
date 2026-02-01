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
import SharedModels
import CanvasFeature
import AssetManager
import AssetBrowserFeature
import SidebarFeature

struct MainContentViewMacOS: View {

    @FocusState var focus: Focus?

    @ObservableState var vm: MainContentViewModel

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore, coordinator: GlobalCoordinator) {
        self._vm = .init(
            wrappedValue: .init(
                flow: flow,
                canvas: canvas,
                assetStore: assetStore,
                coordinator: coordinator
            )
        )
    }

    var body: some View {
        NavigationSplitView {
            SidebarFeatureView(self.$focus, self.vm.onDoubleClick(nodePaletteItem:))
                .navigationSplitViewColumnWidth(min: 150, ideal: 220, max: 400)
                .scrollEdgeEffectStyle(.hard, for: .top)
        } detail: {
            DetailView(vm: self.vm, focus: self.$focus)
        }
        .toolbar { self.toolbarContent }
        .toolbarRole(.editor)
        .sheet(
            isPresented: self.$vm.showAssetBrowser,
            content: {
                AssetBrowserView(self.vm.assetBrowserViewModel)
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
        .imageExporter(
            isPresented: self.$vm.imageExporterState.isPresented,
            image: self.vm.imageExporterState.image,
            defaultFilename: self.vm.imageExporterState.defaultFilename,
            errorMessage: self.$vm.error,
        )
        .errorAlert(self.$vm.error)
        .onChange(of: self.undoManager, initial: true) { self.vm.undoManager = self.undoManager }
        .onChange(of: self.focus, initial: false, { self.vm.focusDidChange(self.$focus) })
        .activeViewObject(self.vm)
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
#endif
