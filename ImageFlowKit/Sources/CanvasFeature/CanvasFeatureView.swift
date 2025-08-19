//
//  CanvasFeatureView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 12/08/25.
//

import CanvasView
import Logging
import NodeDataStore
import NodeView
import SwiftUI

public struct CanvasFeatureView: View {

    @Binding var state: CanvasFeatureState
    @Binding var nodeDataStore: NodeDataStore

    public init(_ state: Binding<CanvasFeatureState>, _ nodeDataStore: Binding<NodeDataStore>) {
        self._state = state
        self._nodeDataStore = nodeDataStore
    }

    func viewForNode(_ id: UUID) -> (any CanvasNodeView)? {
        guard let node = self.nodeDataStore.nodes[id] else {
            log("Node data not found for id: \(id)", level: .warning)
            return nil
        }

        let view = NodeView(node)

        return view
    }

    public var body: some View {
        ZStack {
            CanvasView(
                self.$state.viewport,
                self.$state.nodePositions,
                self.viewForNode
            )
        }
    }
}

enum PreviewData {
    static let id = UUID()
}

#Preview(traits: .sizeThatFitsLayout) {
    @Previewable @State var state: CanvasFeatureState = .init(nodePositions: [PreviewData.id: .zero])
    @Previewable @State var nodeDataStore: NodeDataStore = .init([
        PreviewData.id: .init(id: PreviewData.id, kind: .addNode(.float))
    ])
    VStack {
        CanvasFeatureView($state, $nodeDataStore)
    }
}
