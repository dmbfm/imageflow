#if os(iOS)

import Helpers
import Logging
import SwiftUI
import PhotosUI

struct MainContentViewIPadOS: View {

    @FocusState var focus: Focus?

    @ObservableState var vm: MainContentViewModel

    @FocusedValue(PreviewFeatureState.self)
    var previewState: PreviewFeatureState?

    @Environment(\.undoManager) var undoManager

    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
    ) {
        self._vm = .init(
            wrappedValue: .init(
                flow: flow,
                canvas: canvas,
                assetStore: assetStore
            )
        )
    }

    func onNodePaletteTapItem(_ item: NodePaletteItem) {
        log("item: \(item)", level: .trace)
        self.vm.showNodePaletteModal = false
        self.vm.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    var body: some View {
        self.content
            .sheet(isPresented: self.$vm.showNodePaletteModal) {
                NodePaletteSheetView() { self.onNodePaletteTapItem($0) }
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
            .errorAlert(self.$vm.error)
            .onChange(of: self.vm.showFileImporter, initial: false, self.vm.onChangeOfShowFileImporter)
            .onChange(of: self.vm.showPhotoPicker, initial: false, self.vm.onChangeOfShowPhotoPicker)
            .onChange(of: self.vm.selectedPhotoPickerItems, initial: false, self.vm.onChangeOfPhotoPickerItems)
    }

    @ViewBuilder
    var content: some View {
        NavigationStack {
            GeometryReader { proxy in
                ScrollView([.vertical]) {
                    self.canvasView
                        .frame(width: proxy.size.width, height: proxy.size.height)
                }
                .scrollEdgeEffectStyle(.soft, for: .vertical)
                .scrollDisabled(true)
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { self.toolbarContent }
            .toolbarRole(.editor)
        }
    }

    @ViewBuilder
    var canvasView: some View {
        ZStack {
            CanvasFeatureView(
                self.vm.canvas,
                self.vm.flow,
                self.vm.assetStore,
                self.$focus,
                self.vm
                // self.vm.canvasFeatureViewDelegate
            )
            .onGeometryChange(for: CGPoint.self) { proxy in
                proxy.frame(in: .local).center
            } action: { newValue in
                self.vm.canvasCenter = newValue
            }
        }

    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Button {
                self.vm.showNodePaletteModal = true
            } label: {
                Image(systemName: "plus")
            }
        }

        ToolbarItem(placement: .secondaryAction) {
            Button {

            } label: {
                Image(systemName: "paperclip")
            }
        }

        ToolbarItem(placement: .primaryAction) {
            if let previewState = self.previewState {
                @Bindable var p = previewState

                Menu("Preview", systemImage: "photo.on.rectangle") {
                    Picker("Preview", selection: $p.previewPosition) {
                        Label("Top Left", systemImage: "inset.filled.topleft.rectangle")
                            .tag(PreviewPosition.topLeft)
                        Label("Top Right", systemImage: "inset.filled.topright.rectangle")
                            .tag(PreviewPosition.topRight)
                        Label("Bottom Left", systemImage: "inset.filled.bottomleft.rectangle")
                            .tag(PreviewPosition.bottomLeft)
                        Label("Bottom Right", systemImage: "inset.filled.bottomright.rectangle")
                            .tag(PreviewPosition.bottomRight)
                        Label("Top", systemImage: "inset.filled.tophalf.rectangle")
                            .tag(PreviewPosition.topDock)
                        Label("Bottom", systemImage: "inset.filled.bottomhalf.rectangle")
                            .tag(PreviewPosition.bottomDock)
                    }
                    .labelsVisibility(.visible)
                }
            }
        }

        ToolbarSpacer(.fixed, placement: .primaryAction)

        ToolbarItem(placement: .primaryAction) {
            Button {
                self.vm.openAssetBrowser()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
            }
        }
    }
}

#endif
