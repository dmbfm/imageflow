#if os(iOS)

import Helpers
import Logging
import SwiftUI

struct MainContentViewIPadOS: View {

    let flow: Flow
    let canvas: CanvasFeatureState
    @FocusState var focus: Focus?

    @State var showNodePaletteModal: Bool = false
    @State var canvasCenter: Box<CGPoint> = .init(.zero)

    @Environment(\.undoManager) var undoManager

    init(flow: Flow, canvas: CanvasFeatureState) {
        self.flow = flow
        self.canvas = canvas
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
            .onAppear { self.onAppear() }
    }

    @ViewBuilder
    var content: some View {
        if #available(iOS 26, *) {
            self.contentIOS26
        } else {
            self.contentIOS18
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

        if #available(iOS 26, *) {
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
        } else {
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
        }
    }
}

#endif
