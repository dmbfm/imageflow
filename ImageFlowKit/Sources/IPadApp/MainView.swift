//
//  MainView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 12/08/25.
//

#if canImport(UIKit)

import CanvasFeature
import SwiftUI

struct MainView: View {
    @Binding var document: ImageFlowDocument

    var body: some View {
        NavigationSplitView {
            List {
                Text("\(self.document.canvas.nodePositions.count)")
            }
            .searchable(text: .constant(""))
        } detail: {
            ZStack {
                CanvasFeatureView(self.$document.canvas, self.$document.nodeData)
            }
        }
    }
}
#endif
