import Backend
import CanvasView
import Logging
import SharedModels
import SwiftUI

@Observable
@MainActor
public final class CanvasFeatureState {

    public var viewport: CanvasView.Viewport = .init() {
        didSet {
            self.delegate?.canvas(viewportDidChange: self.viewport)
        }
    }

    public weak var delegate: CanvasFeatureStateDelegate? = nil

    public init(
        viewport: CanvasView.Viewport = .init(),
    ) {
        self.viewport = viewport
    }
}

public protocol CanvasFeatureStateDelegate: AnyObject {
    func canvas(viewportDidChange viewporp: CanvasView.Viewport) -> ()
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
