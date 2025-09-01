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
        self.document.addNode(
            fromPaletteItem: item,
            at: self.viewport.convert(self.canvasCenter.value, from: .screen, to: .canvas)
        )
        self.showNodePaletteModal = false
    }
    
    func onAppear() {
        if #unavailable(iOS 26) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundEffect = .init(style: .systemChromeMaterial)
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
    
    var isIOS26: Bool {
        if #available(iOS 26, *) { true } else { false }
    }
    
    var canvasView: some View {
        ZStack {
            CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
                .onGeometryChange(for: CGPoint.self) { proxy in
                    proxy.frame(in: .local).center
                } action: { newValue in
                    self.canvasCenter.value = newValue
                }
        }
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
    
    var body: some View {
        self.content
        .sheet(isPresented: self.$showNodePaletteModal) {
            NodePaletteSheetView() { self.onNodePaletteTapItem($0) }
        }
        .onAppear { self.onAppear() }
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
            
            //                ToolbarSpacer(.fixed, placement: .secondaryAction)
            
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
