//
//  MainViewIPad.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 28/08/25.
//

#if canImport(UIKit)

import SwiftUI
import CanvasFeature
import CanvasView
import NodePaletteService

final class Box<T> {
    public var value: T

    public init(_ value: T) {
        self.value = value
    }
}

struct MainViewIPad: View {

    @Binding var document: ImageFlowDocument
    @State var showNodePaletteModal: Bool = false
    @State var canvasCenter: Box<CGPoint> = .init(.zero)

    var viewport: CanvasViewport {
        self.document.canvas.viewport
    }

    func onNodePaletteTapItem(_ item: NodePaletteItem) {
        self.document.addNode(fromPaletteItem: item, at: self.viewport.convert(self.canvasCenter.value, from: .screen, to: .canvas))
        self.showNodePaletteModal = false
    }

    func onAppear() {
        if #unavailable(iOS 26) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = .init(style: .systemThickMaterial)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
                    .onGeometryChange(for: CGPoint.self) { proxy in
                        proxy.frame(in: .local).center
                    } action: { newValue in
                        print("center: \(newValue)")
                        self.canvasCenter.value = newValue
                    }
            }
        
        .ignoresSafeArea()
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { self.toolbarContent }
        .toolbarRole(.editor)
        }
        .sheet(isPresented: self.$showNodePaletteModal) {
            NodePaletteSheetView() { self.onNodePaletteTapItem($0) }
        }
        .onAppear { self.onAppear() }
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
    }
}

#endif
