import Backend
import Logging
import SwiftUI

@Observable
@MainActor
final class CanvasFeatureState {

    var viewport: CanvasView.Viewport = .init() {
        didSet {
            self.delegate?.viewportDidChange(self.viewport)
        }
    }

    var delegate: CanvasFeatureStateDelegate? = nil

    public init(
        viewport: CanvasView.Viewport = .init(),
    ) {
        self.viewport = viewport
    }
}

struct CanvasFeatureStateDelegate {
    var viewportDidChange: (CanvasView.Viewport) -> ()
}

extension CanvasFeatureState: Storable {
    public struct StorableData: Sendable, Codable, Equatable {
        public var viewport: CanvasView.Viewport

        public init(viewport: CanvasView.Viewport = .init()) {
            self.viewport = viewport
        }
    }

    public convenience init(_ store: StorableData) {
        self.init(viewport: store.viewport)
    }

    public func snapshot() -> StorableData {
        .init(viewport: self.viewport)
    }

    public func restore(_ snapshot: StorableData) {
        self.viewport = snapshot.viewport
    }
}
