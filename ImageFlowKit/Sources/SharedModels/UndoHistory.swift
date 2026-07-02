public struct UndoHistory {

    public private(set) var items: [UndoHistoryItem] = [
        .init(id: 0, name: "Initial", icon: "0.square.fill")
    ]

    public private(set) var cursor: Int

    public var canUndo: Bool {
        self.cursor >= 1
    }

    public var canRedo: Bool {
        self.cursor < (self.items.count - 1)
    }

    public init() {
        self.cursor = 0
    }

    public mutating func register(_ item: UndoHistoryItem) {
        self.items.remove(atOffsets: .init(integersIn: (self.cursor + 1)...self.items.count))
        self.items.append(item)
        self.cursor = self.items.count - 1
    }

    public mutating func undo() {
        if self.canUndo {
            self.cursor -= 1
        }
    }

    public mutating func redo() {
        if self.canRedo {
            self.cursor += 1
        }
    }
}

public struct UndoHistoryItem: Sendable, Equatable, Identifiable {
    public var id: Int
    public var name: String
    public var icon: String?

    public init(id: Int, name: String = "", icon: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}
