#if os(iOS)

import Helpers
import Logging
import SwiftUI
import PhotosUI

struct MainContentViewIPadOS: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    let assetStore: AssetStore
    @FocusState var focus: Focus?

    @State var showNodePaletteModal: Bool = false
    @State var canvasCenter: Box<CGPoint> = .init(.zero)
    @State var showAssetBrowser: Bool = false
    @State var assetBrowserCoordinator: AssetBrowserCoordinator = .init(type: .browser(.init(assetKinds: .all)))
    @State var showFileImporter: Bool = false
    @State var fileImporterConfiguration: Box<FileImporterConfiguration> = .init(.init(allowedContentTypes: []))
    @State var showPhotoPicker: Bool = false
    @State var selectedPhotoPickerItems: [PhotosPickerItem] = []
    @State var error: LocalizedAlertError? = nil
    @State var assetBrowserError: LocalizedAlertError? = nil
    
    @FocusedValue(PreviewFeatureState.self)
    var previewState: PreviewFeatureState?

    @Environment(\.undoManager) var undoManager

    init(
        flow: Flow,
        canvas: CanvasFeatureState,
        assetStore: AssetStore,
    ) {
        self.flow = flow
        self.canvas = canvas
        self.assetStore = assetStore
    }

    func onNodePaletteTapItem(_ item: NodePaletteItem) {
        log("item: \(item)", level: .trace)
        self.showNodePaletteModal = false
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    var body: some View {
        self.content
            .sheet(isPresented: self.$showNodePaletteModal) {
                NodePaletteSheetView() { self.onNodePaletteTapItem($0) }
            }
            .sheet(isPresented: self.$showAssetBrowser) {
                AssetBrowserView(
                    coordinator: self.assetBrowserCoordinator,
                    assetsProvider: self.assetStore,
                    delegate: self.assetBrowserDelegate,
                )
                .errorAlert(self.$assetBrowserError)
            }
            .fileImporter(
                isPresented: self.$showFileImporter,
                allowedContentTypes: self.fileImporterConfiguration.value.allowedContentTypes,
                allowsMultipleSelection: true,
                onCompletion: self.fileImporterCompletionHandler(_:)
            )
            .photosPicker(
                isPresented: self.$showPhotoPicker,
                selection: self.$selectedPhotoPickerItems,
                matching: .images,
                photoLibrary: .shared(),
            )
            .errorAlert(self.$error)
            .onChange(of: self.showFileImporter, initial: false, self.onChangeOfShowFileImporter)
            .onChange(of: self.showPhotoPicker, initial: false, self.onChangeOfShowPhotoPicker)
            .onChange(of: self.selectedPhotoPickerItems, initial: false, self.onChangeOfPhotoPickerItems)
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
                self.canvas,
                self.flow,
                self.assetStore,
                self.$focus,
                self.canvasFeatureViewDelegate
            )
            .onGeometryChange(for: CGPoint.self) { proxy in
                proxy.frame(in: .local).center
            } action: { newValue in
                self.canvasCenter.value = newValue
            }
        }

    }

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .secondaryAction) {
            Button {
                self.showNodePaletteModal = true
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
                self.openAssetBrowser()
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
            }
        }
    }
}

#endif
