#if os(iOS)

import Helpers
import Logging
import SwiftUI
import PhotosUI
import SharedModels
import CanvasFeature
import AssetManager
import PreviewFeature
import NodePaletteFeature
import AssetBrowserFeature
import InspectorFeature

struct MainContentViewIPadOS: View {

    @FocusState var focus: Focus?

    @ObservableState var vm: MainContentViewModel

    @ActiveViewObject(PreviewFeatureState.self)
    var previewState: PreviewFeatureState?

    @Environment(\.undoManager) var undoManager

    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
        coordinator: GlobalCoordinator,
    ) {
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
        ZStack(alignment: .top) {
            self.content
            ScrollView {}
                .scrollEdgeEffectStyle(.soft, for: .top)
                .ignoresSafeArea()
                .scrollDisabled(true)
                .allowsHitTesting(false)
        }
        .toolbar { self.toolbarContent }
        .sheet(isPresented: self.$vm.nodePaletteState.isPresented) {
            NodePaletteSheetView(port: self.vm.nodePaletteState.typedPortLocation, focus: self.$focus) {
                self.vm.onNodePaletteSheetTapItem($0)
            }
        }
        .sheet(isPresented: self.$vm.renameNodeModalState.isPresented) {
            RenameNodeSheetView(vm: self.vm, nodeId: self.vm.renameNodeModalState.node)
        }
        .sheet(isPresented: self.$vm.showAssetBrowser) {
            AssetBrowserView(self.vm.assetBrowserViewModel)
                .errorAlert(self.$vm.assetBrowserError)
        }
        .fileImporter(
            isPresented: self.$vm.showFileImporter,
            allowedContentTypes: self.vm.fileImporterConfiguration.allowedContentTypes,
            allowsMultipleSelection: true,
            onCompletion: self.vm.fileImporterCompletionHandler(_:)
        )
        .photosPicker(
            isPresented: self.$vm.showPhotoPicker,
            selection: self.$vm.selectedPhotoPickerItems,
            matching: .images,
            photoLibrary: .shared(),
        )
        .imageExporter(
            isPresented: self.$vm.imageExporterState.isPresented,
            image: self.vm.imageExporterState.image,
            defaultFilename: self.vm.imageExporterState.defaultFilename,
            errorMessage: self.$vm.error,
        )
        .errorAlert(self.$vm.error)
        .onChange(of: self.undoManager, initial: true) { self.vm.undoManager = self.undoManager }
        .onChange(of: self.focus, initial: true, { self.vm.focusDidChange(self.$focus) })
        .onChange(of: self.vm.showFileImporter, initial: false, self.vm.onChangeOfShowFileImporter)
        .onChange(of: self.vm.showPhotoPicker, initial: false, self.vm.onChangeOfShowPhotoPicker)
        .onChange(of: self.vm.selectedPhotoPickerItems, initial: false, self.vm.onChangeOfPhotoPickerItems)
        .onReceive(NotificationCenter.default.publisher(for: .NSUndoManagerCheckpoint)) { _ in
            self.vm.onUndoCheckpoint()
        }
        .defaultFocus(self.$focus, .global)
        .activeViewObject(self.vm)
    }

    @ViewBuilder
    var content: some View {
        CanvasFeatureView(
            self.vm.canvas,
            self.vm.flow,
            self.vm.assetStore,
            self.$focus,
            coordinator: self.vm.coordinator,
        )
        .inspectorFeatureViewBar(
            self.$vm.showInspector,
            flow: self.vm.flow,
            assetStore: self.vm.assetStore,
            coordinator: self.vm.coordinator
        )
    }

    let zoomValues: [CGFloat] = [
        0.1,
        0.25,
        0.5,
        0.75,
        1,
    ]
}
#endif
