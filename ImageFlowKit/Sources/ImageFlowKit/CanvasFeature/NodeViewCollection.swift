import Foundation

class NodeViewCollection {
    private var items: [UUID: NodeView] = [:]
}

extension NodeViewCollection {
    subscript(_ id: UUID) -> NodeView? {
        get {
            self.items[id]
        }
        set {
            self.items[id] = newValue
        }
    }
}

extension NodeViewCollection: Collection {
    typealias Element = (UUID, NodeView)
    typealias Index = [UUID: NodeView].Index

    var startIndex: Index {
        self.items.startIndex
    }

    var endIndex: Index {
        self.items.endIndex
    }

    subscript(_ position: Index) -> Element {
        self.items[position]
    }

    func index(after i: Dictionary<UUID, NodeView>.Index) -> Dictionary<UUID, NodeView>.Index {
        self.items.index(after: i)
    }
}
