//
//  MainViewIPad.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 28/08/25.
//

#if canImport(UIKit)

import SwiftUI
import CanvasFeature

struct MainViewIPad: View {

    @Binding var document: ImageFlowDocument
    @State var showNodePaletteModal: Bool = false

    var body: some View {
        ZStack {
            CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
        }
        .ignoresSafeArea()
        .toolbar { self.toolbarContent }
        .toolbarRole(.editor)
        .sheet(isPresented: self.$showNodePaletteModal) {

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
    }
}

#endif
