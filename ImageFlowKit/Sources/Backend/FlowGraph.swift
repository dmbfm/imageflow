import Foundation
import SwiftGraph

public final class FlowGraph {

    private let messageStore: MessageStore
    fileprivate var graph: _FlowGraph

    public init(_ messageStore: MessageStore) {
        self.graph = .init(vertices: [])
        self.messageStore = messageStore
    }

    public func addEdge(_ e: Edge) {
        guard let srcNodeIndex = self.graph.indexOfVertex(e.from.node),
            let dstNodeIndex = self.graph.indexOfVertex(e.to.node)
        else {
            self.messageStore.error(.addInvalidEdge(e), scope: .edge(e))
            return
        }
        self.addEdge(
            .init(
                start: .init(nodeIndex: srcNodeIndex, slot: e.from.index),
                end: .init(nodeIndex: dstNodeIndex, slot: e.to.index)
            )
        )
    }

    func addEdge(_ e: FlowGraphEdge) {
        if self.graph.edgesEndingAt(e.end).isEmpty {
            self.graph.addEdge(e)
        } else {
            let node = self.graph.vertexAtIndex(e.end.nodeIndex)
            self.messageStore.error(.multipleEdgesAtSameInputPort, scope: .input(node, e.end.slot))
        }
    }

    public func addNode(_ id: UUID) {
        _ = self.graph.addVertex(id)
    }

    public func detectCycles() -> DetectCyclesResult {
        let edges = self.graph.detectCyclesAsEdges()

        if edges.isEmpty {
            return .ok
        }

        self.messageStore.messages.append(
            contentsOf: edges.flatMap { edges in
                edges.map { edge in
                    let startNode = self.graph.vertexAtIndex(edge.start.nodeIndex)
                    let endNode = self.graph.vertexAtIndex(edge.end.nodeIndex)
                    return Message(
                        content: .edgeInCycle,
                        scope: .edge(
                            .init(
                                from: .init(node: startNode, slot: edge.start.slot),
                                end: .init(node: endNode, slot: edge.end.slot)
                            )
                        ),
                        level: .error
                    )
                }
            }
        )

        return .hasCycles
    }

    public enum DetectCyclesResult {
        case ok
        case hasCycles
    }

    public func sortedNodes() -> [Int]? {
        self.graph.topologicalSort()?.map { graph.indexOfVertex($0)! }
    }

    var edges: [FlowGraphEdge] {
        self.graph.edgeList()
    }

    func incomingEdges(toNodeAtIndex index: Int) -> [FlowGraphEdge] {
        self.edges.filter { e in
            e.end.nodeIndex == index
        }
    }

    func incomindEdge(toNodeAtIndex nodeIndex: Int, inputPort portIndex: Int) -> FlowGraphEdge? {
        self.edges.first { e in
            e.end.nodeIndex == nodeIndex && e.end.slot == portIndex
        }
    }
}

private final class _FlowGraph: Graph, Codable {
    var vertices: [UUID]
    var edges: [[FlowGraphEdge]]

    func addEdge(_ e: FlowGraphEdge) {
        precondition(e.directed, "FlowGraph must be directed")
        self.edges[e.u].append(e)
    }

    required init(vertices: [UUID]) {
        self.vertices = vertices
        self.edges = []
    }
}

extension _FlowGraph {
    func edgesEndingAt(_ port: FlowGraphEdge.Port) -> [FlowGraphEdge] {
        self.edges.flatMap { edges in
            edges.filter { edge in
                edge.end == port
            }
        }
    }
}

struct FlowGraphEdge: SwiftGraph.Edge, Equatable {

    var start: Port
    var end: Port

    struct Port: Codable, Equatable {
        var nodeIndex: Int
        var slot: Int
    }

    func reversed() -> FlowGraphEdge {
        .init(start: self.end, end: self.start)
    }

    var u: Int {
        get {
            self.start.nodeIndex
        }
        set {
            self.start.nodeIndex = newValue
        }
    }

    var v: Int {
        get {
            self.end.nodeIndex
        }
        set {
            self.end.nodeIndex = newValue
        }
    }

    // swiftlint:disable unused_setter_value
    var directed: Bool {
        get { true }
        set { fatalError("Only directed edges allowed") }
    }

    var description: String {
        "(\(self.start.nodeIndex),\(self.start.slot) -> (\(self.end.nodeIndex),\(self.end.slot))"
    }
}
