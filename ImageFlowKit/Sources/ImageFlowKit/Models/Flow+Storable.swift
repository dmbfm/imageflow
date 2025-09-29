//
//  Flow+Storable.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import   Foundation

extension Flow: Storable {
    public struct StorableData: Sendable, Codable {
        var nodes: [UUID:FlowNode] = [:]
        var edges: Set<Edge> = []
    }
    
    public func snapshot() -> StorableData {
        .init(nodes: self.nodes, edges: self.edges)
    }
    
    public func restore(_ snapshot: StorableData) {
        self.nodes = snapshot.nodes
        self.edges = snapshot.edges
    }
    
    public convenience init(_ data: StorableData) {
        self.init(nodes: data.nodes, edges: data.edges)
    }
}

