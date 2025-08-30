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
        log("nodes: \(self.nodeDataStore.nodes)")
        log("positions: \(self.state.nodePositions)")
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
            .onChange(of: self.nodeDataStore) {
                log("onChangeOfNodes: \(self.nodeDataStore.nodes)")
            }
            .onChange(of: self.state) {
                log("onChangeOfState")
            }
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
