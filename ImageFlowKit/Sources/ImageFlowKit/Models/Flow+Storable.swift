//
//  Flow+Storable.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Foundation

extension Flow: Storable {
    public struct StorableData: Sendable, Codable {
        var nodes: [UUID: FlowNode] = [:]
        var nodePositions: [UUID: CGPoint] = [:]
        var edges: Set<Edge> = []
    }

    public func snapshot() -> StorableData {
        .init(nodes: self.nodes, nodePositions: self.nodePositions, edges: self.edges)
    }

    public func restore(_ snapshot: StorableData) {
        self.nodes = snapshot.nodes
        self.nodePositions = snapshot.nodePositions
        self.edges = snapshot.edges
        self.liveMoveNodesSnapshot = nil
        self.liveSelectSnapshot = nil
    }

    public convenience init(_ data: StorableData) {
        self.init(nodes: data.nodes, nodePositions: data.nodePositions, edges: data.edges)
    }
}
