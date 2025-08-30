//
//  MainViewMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 28/08/25.
//

import CanvasFeature
import SwiftUI

struct MainViewMac: View {
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
