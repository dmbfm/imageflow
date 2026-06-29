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
    public struct StorableData: Sendable, Codable, Equatable {
        public var viewport: CanvasView.Viewport
        public var bookmarks: CanvasBookmarks?

        public init(viewport: CanvasView.Viewport = .init(), bookmarks: CanvasBookmarks? = nil) {
            self.viewport = viewport
            self.bookmarks = bookmarks
        }
    }

    public convenience init(_ store: StorableData) {
        self.init(viewport: store.viewport, bookmarks: store.bookmarks ?? .init())
    }

    public func snapshot() -> StorableData {
        StorableData(viewport: self.viewport, bookmarks: self.bookmarks)
    }

    public func restore(_ snapshot: StorableData) {
        self.viewport = snapshot.viewport
        self.bookmarks = snapshot.bookmarks ?? .init()
    }
}
