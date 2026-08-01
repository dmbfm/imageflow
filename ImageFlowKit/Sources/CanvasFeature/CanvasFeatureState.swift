import Backend
import CanvasView
import Helpers
import SharedModels
import SwiftUI

// @Observable
@MainActor
public final class CanvasFeatureState {

    public var viewport: CanvasView.Viewport = .init() {
        didSet {
            self.delegate?.canvas(viewportDidChange: self.viewport)
        }
    }

    @PublishedEx public var bookmarks: CanvasBookmarks = .init()

    public weak var delegate: CanvasFeatureStateDelegate? = nil

    public init(
        viewport: CanvasView.Viewport = .init(),
        bookmarks: CanvasBookmarks = .init(),
    ) {
        self.viewport = viewport
        self.bookmarks = bookmarks
    }
}

public protocol CanvasFeatureStateDelegate: AnyObject {
    func canvas(viewportDidChange viewporp: CanvasView.Viewport)
}

extension CanvasFeatureState: Storable {

    public enum StorableData: Sendable, Codable, Equatable {
        case v0(V0)
        case v1(V1)

        public struct V0: Sendable, Codable, Equatable {
            public var viewport: CanvasView.Viewport
            public var bookmarks: CanvasBookmarks?

            public init(viewport: CanvasView.Viewport = .init(), bookmarks: CanvasBookmarks? = nil) {
                self.viewport = viewport
                self.bookmarks = bookmarks
            }
        }

        public struct V1: Sendable, Codable, Equatable {
            public var viewport: CanvasView.Viewport
            public var bookmarks: CanvasBookmarks

            public init(viewport: CanvasView.Viewport = .init(), bookmarks: CanvasBookmarks = .init()) {
                self.viewport = viewport
                self.bookmarks = bookmarks
            }
        }
    }

    public convenience init(_ store: StorableData) {
        switch store {
        case .v0(let store):
            self.init(viewport: store.viewport, bookmarks: store.bookmarks ?? .init())
        case .v1(let store):
            self.init(viewport: store.viewport, bookmarks: store.bookmarks)
        }
    }

    public func snapshot() -> StorableData {
        .v0(.init(viewport: self.viewport, bookmarks: self.bookmarks))
    }

    public func restore(_ snapshot: StorableData) {
        switch snapshot {
        case .v0(let snapshot):
            self.viewport = snapshot.viewport
            self.bookmarks = snapshot.bookmarks ?? .init()
        case .v1(let snapshot):
            self.viewport = snapshot.viewport
            self.bookmarks = snapshot.bookmarks
        }
    }
}
