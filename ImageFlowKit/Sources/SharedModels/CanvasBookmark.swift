import Foundation

public struct CanvasBookmark: Sendable, Codable, Equatable, Identifiable {
    public var id: UUID
    public var name: String
    public var viewport: CanvasViewportModel

    public init(id: UUID = .init(), name: String, viewport: CanvasViewportModel) {
        self.id = id
        self.name = name
        self.viewport = viewport
    }
}

public struct CanvasBookmarks: Sendable, Codable, Equatable {
    public var bookmarks: [CanvasBookmark]

    public var count: Int {
        self.bookmarks.count
    }

    public init(_ bookmarks: [CanvasBookmark] = []) {
        self.bookmarks = bookmarks
    }

    public func get(withID id: UUID) -> CanvasBookmark? {
        if let index = self.bookmarks.firstIndex(where: { $0.id == id }) {
            self.bookmarks[index]
        } else {
            nil
        }
    }

    public mutating func add(_ bookmark: CanvasBookmark) {
        self.bookmarks.append(bookmark)
    }

    public mutating func remove(_ id: UUID) -> CanvasBookmark? {
        if let index = self.bookmarks.firstIndex(where: { $0.id == id }) {
            self.bookmarks.remove(at: index)
        } else {
            nil
        }
    }

    public mutating func rename(_ id: UUID, _ name: String) {
        if let index = self.bookmarks.firstIndex(where: { $0.id == id }) {
            self.bookmarks[index].name = name
        }
    }
}
