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
    @State var assetBrowserType: AssetBrowserType = .browser
    @State var showFileImporter: Bool = false
    @State var showPhotoPicker: Bool = false
    @State var selectedPhotoPickerItems: [PhotosPickerItem] = []

    @Environment(\.undoManager) var undoManager

    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore) {
        self.flow = flow
        self.canvas = canvas
        self.assetStore = assetStore
    }

    func onNodePaletteTapItem(_ item: NodePaletteItem) {
        log("item: \(item)", level: .trace)
        self.showNodePaletteModal = false
        self.createNodeAtCanvasCenter(fromPaletteItem: item)
    }

    func onAppear() {
        if #unavailable(iOS 26) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = .init(style: .systemChromeMaterial)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        self.content
            .sheet(isPresented: self.$showNodePaletteModal) {
                NodePaletteSheetView() { self.onNodePaletteTapItem($0) }
            }
            .sheet(isPresented: self.$showAssetBrowser) {
                AssetBrowserView(
                    type: self.assetBrowserType,
                    assetStore: self.assetStore,
                    delegate: self.assetBrowserDelegate,
                )
            }
            .fileImporter(
                isPresented: self.$showFileImporter,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true,
                onCompletion: self.fileImporterCompletionHandler(_:)
            )
            .photosPicker(
                isPresented: self.$showPhotoPicker,
                selection: self.$selectedPhotoPickerItems,
                matching: .images,
                photoLibrary: .shared(),
            )
            .onAppear {
                self.onAppear()
            }
            .onChange(of: self.showFileImporter, initial: false, self.onChangeOfShowFileImporter)
            .onChange(of: self.showPhotoPicker, initial: false, self.onChangeOfShowPhotoPicker)
            .onChange(of: self.selectedPhotoPickerItems, initial: false, self.onChangeOfPhotoPickerItems)
    }

    @ViewBuilder
    var content: some View {
        Group {
            if #available(iOS 26, *) {
                self.contentIOS26
            } else {
                self.contentIOS18
            }
        }
    }

    @ViewBuilder
    @available(iOS 26, *)
    var contentIOS26: some View {
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
    var contentIOS18: some View {
        self.canvasView
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { self.toolbarContent }
            .toolbarRole(.editor)

    }

    @ViewBuilder
    var canvasView: some View {
        ZStack {
            CanvasFeatureView(self.canvas, self.flow, self.$focus)
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
            Button {
                self.showAssetBrowser = true
            } label: {
                Image(systemName: "square.and.arrow.down.fill")
            }
        }
    }
}

#endif
