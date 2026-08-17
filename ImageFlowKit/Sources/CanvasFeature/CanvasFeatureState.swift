import Backend
import CanvasView
import Combine
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

    public var nodeSnapping: NodeSnappingConfig = .init() {
        didSet {
            if self.nodeSnapping.enabled != oldValue.enabled {
                self.nodeSnappingPublisher.send(self.nodeSnapping.enabled)
            }
        }
    }

    public lazy var nodeSnappingPublisher: CurrentValueSubject<Bool, Never> = {
        .init(self.nodeSnapping.enabled)
    }()

    @PublishedEx public var bookmarks: CanvasBookmarks = .init()

    public weak var delegate: CanvasFeatureStateDelegate? = nil

    public struct NodeSnappingConfig: Sendable, Codable, Equatable {
        public var enabled: Bool
        public var size: CGFloat

        public init(enabled: Bool = false, size: CGFloat = 25.0) {
            self.enabled = enabled
            self.size = size
        }
    }

    public init(
        viewport: CanvasView.Viewport = .init(),
        bookmarks: CanvasBookmarks = .init(),
        nodeSnapping: NodeSnappingConfig = .init(),
    ) {
        self.viewport = viewport
        self.bookmarks = bookmarks
        self.nodeSnapping = nodeSnapping
    }
}

public protocol CanvasFeatureStateDelegate: AnyObject {
    func canvas(viewportDidChange viewporp: CanvasView.Viewport)
}

extension CanvasFeatureState: Storable {

    public enum StorableData: Sendable, Codable, Equatable {
        case v0(V0)
        case v1(V1)
        case v2(V2)

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

        public struct V2: Sendable, Codable, Equatable {
            public var viewport: CanvasView.Viewport
            public var bookmarks: CanvasBookmarks
            public var nodeSnapping: NodeSnappingConfig

            public init(
                viewport: CanvasView.Viewport = .init(),
                bookmarks: CanvasBookmarks = .init(),
                nodeSnapping: NodeSnappingConfig = .init()
            ) {
                self.viewport = viewport
                self.bookmarks = bookmarks
                self.nodeSnapping = nodeSnapping
            }
        }
    }

    public convenience init(_ store: StorableData) {
        switch store {
        case .v0(let store):
            self.init(viewport: store.viewport, bookmarks: store.bookmarks ?? .init())
        case .v1(let store):
            self.init(viewport: store.viewport, bookmarks: store.bookmarks)
        case .v2(let store):
            self.init(viewport: store.viewport, bookmarks: store.bookmarks, nodeSnapping: store.nodeSnapping)
        }
    }

    public func snapshot() -> StorableData {
        .v2(.init(viewport: self.viewport, bookmarks: self.bookmarks, nodeSnapping: self.nodeSnapping))
    }

    public func restore(_ snapshot: StorableData) {
        switch snapshot {
        case .v0(let snapshot):
            self.viewport = snapshot.viewport
            self.bookmarks = snapshot.bookmarks ?? .init()
            self.nodeSnapping = .init()
        case .v1(let snapshot):
            self.viewport = snapshot.viewport
            self.bookmarks = snapshot.bookmarks
            self.nodeSnapping = .init()
        case .v2(let snapshot):
            self.viewport = snapshot.viewport
            self.bookmarks = snapshot.bookmarks
            self.nodeSnapping = snapshot.nodeSnapping
        }
    }
}
