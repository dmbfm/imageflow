//
//  Flow+Storable.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Foundation

extension Flow: Storable {
    public enum StorableData: Sendable, Codable {
        case v0(V0)

        public struct V0: Sendable, Codable {
            public var nodes: [UUID: FlowNode] = [:]
            public var nodePositions: [UUID: CGPoint] = [:]
            public var edges: Set<Edge> = []

            public init(nodes: [UUID: FlowNode] = [:], nodePositions: [UUID: CGPoint] = [:], edges: Set<Edge> = []) {
                self.nodes = nodes
                self.nodePositions = nodePositions
                self.edges = edges
            }
        }
    }

    public func snapshot() -> StorableData {
        .v0(.init(nodes: self.nodes, nodePositions: self.nodePositions, edges: self.edges))
    }

    public func restore(_ snapshot: StorableData) {
        switch snapshot {
        case .v0(let snapshot):
            self.nodes = snapshot.nodes
            self.nodePositions = snapshot.nodePositions
            self.edges = snapshot.edges
            self.liveMoveNodesSnapshot = nil
            self.liveSelectSnapshot = nil
        }
    }

    public convenience init(_ data: StorableData) {
        switch data {
        case .v0(let data):
            self.init(nodes: data.nodes, nodePositions: data.nodePositions, edges: data.edges)
        }
    }
}
