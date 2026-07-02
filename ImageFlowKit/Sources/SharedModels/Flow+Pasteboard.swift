import Helpers
import SwiftUI
import UniformTypeIdentifiers

public struct FlowPasteboardData: Sendable, Codable {
    public var nodes: [UUID: FlowNode]
    public var nodePositions: [UUID: CGPoint]
    public var edges: [Edge]

    public init(nodes: [UUID: FlowNode], nodePositions: [UUID: CGPoint], edges: [Edge]) {
        self.nodes = nodes
        self.nodePositions = nodePositions
        self.edges = edges
    }

    public init?(data: Data) {
        do {
            self = try JSONDecoder().decode(Self.self, from: data)
        } catch {
            return nil
        }
    }

    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
}

#if os(macOS)
extension NSPasteboard.PasteboardType {
    public static let flowNode: Self = .init("com.dmbfm.imageflow-node")
}

public class FlowPasteboardItem: NSObject, NSPasteboardWriting, NSPasteboardReading {
    public var flowPasteboardData: FlowPasteboardData

    @MainActor
    public init?(_ flow: Flow) {
        if let pasteboardData = flow.pasteboardData {
            self.flowPasteboardData = pasteboardData
        } else {
            return nil
        }
    }

    @MainActor
    public init?(nodes: Set<UUID>, _ flow: Flow) {
        if let pasteboardData = flow.pasteboardData(forNodes: nodes) {
            self.flowPasteboardData = pasteboardData
        } else {
            return nil
        }
    }

    public init(_ flowPasteboardData: FlowPasteboardData) {
        self.flowPasteboardData = flowPasteboardData
    }

    public func writableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        [.flowNode]
    }

    public func pasteboardPropertyList(forType type: NSPasteboard.PasteboardType) -> Any? {
        guard type == .flowNode else { return nil }
        return self.flowPasteboardData.jsonData
    }

    public static func readableTypes(for pasteboard: NSPasteboard) -> [NSPasteboard.PasteboardType] {
        [.flowNode]
    }

    required public init?(pasteboardPropertyList propertyList: Any, ofType type: NSPasteboard.PasteboardType) {
        if let data = propertyList as? Data, let pasteboardData = FlowPasteboardData(data: data) {
            self.flowPasteboardData = pasteboardData
        } else {
            return nil
        }
    }
}
#endif

extension FlowPasteboardData: Transferable {
    public static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(for: FlowPasteboardData.self, contentType: .imageFlowNode)
    }
}

extension Flow {

    public func pasteboardData(forNodes ids: Set<UUID>) -> FlowPasteboardData? {
        guard !ids.isEmpty else {
            return nil
        }

        var nodes: [UUID: FlowNode] = [:]
        var nodePositions: [UUID: CGPoint] = [:]
        var edges: [Edge] = []

        for id in ids {
            if let node = self.nodes[id], let pos = self.nodePositions[id] {
                nodes[id] = node.disconnectingAllPorts()
                nodePositions[id] = pos
            }
        }

        for edge in self.edges {
            if ids.contains(edge.from.node) && ids.contains(edge.to.node) {
                edges.append(edge)
            }
        }

        return .init(nodes: nodes, nodePositions: nodePositions, edges: edges)
    }

    public var pasteboardData: FlowPasteboardData? {
        self.pasteboardData(forNodes: self.selection)
    }

    public func paste(pasteboardData data: FlowPasteboardData, at point: CGPoint, undoService: UndoService?) {
        guard let center = Array(data.nodePositions.values).centerPoint else { return }

        undoService?.beginUndoGrouping()
        var ids: [UUID: UUID] = [:]
        for (id, node) in data.nodes {
            guard let nodePos = data.nodePositions[id] else { continue }
            var newNode = node
            newNode.id = UUID()
            ids[node.id] = newNode.id
            self.newNodeAction(newNode, at: nodePos - center + point, undoService: undoService)
        }

        for edge in data.edges {
            if let fromNode = ids[edge.from.node],
                let toNode = ids[edge.to.node],
                let edge = Edge(
                    from: .init(node: fromNode, index: edge.from.index),
                    to: .init(node: toNode, index: edge.to.index)
                )
            {
                self.newEdgeAction(
                    edge,
                    undoService: undoService
                )
            }
        }

        undoService?.endUndoGrouping()
        undoService?.setActionName("Paste Node" + (ids.count > 1 ? "s" : ""), icon: .systemIconMenuPaste)

        self.select(Set(ids.values))
    }
}
