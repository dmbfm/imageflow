import Foundation
import NodeView

public class NodeViewCollection {
    private var items: [UUID: NodeView] = [:]
}

extension NodeViewCollection {
    public subscript(_ id: UUID) -> NodeView? {
        get {
            self.items[id]
        }
        set {
            self.items[id] = newValue
        }
    }
}

extension NodeViewCollection: Collection {
    public typealias Element = (UUID, NodeView)
    public typealias Index = [UUID: NodeView].Index

    public var startIndex: Index {
        self.items.startIndex
    }

    public var endIndex: Index {
        self.items.endIndex
    }

    public subscript(_ position: Index) -> Element {
        self.items[position]
    }

    public func index(after i: Dictionary<UUID, NodeView>.Index) -> Dictionary<UUID, NodeView>.Index {
        self.items.index(after: i)
    }
}
