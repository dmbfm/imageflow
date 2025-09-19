import Backend
import CanvasView
import CommonUtils
import Design
import Logging
import Models
import NodeDataStore
import NodeView
import SwiftUI
import SwiftUIUtils

public struct CanvasFeatureState: Sendable, Codable, Equatable {
    public var viewport: CanvasViewport = .init()
    public var nodePositions: [UUID: CGPoint] = .init()

    public init(viewport: CanvasViewport = .init(), nodePositions: [UUID: CGPoint] = .init()) {
        self.viewport = viewport
        self.nodePositions = nodePositions
    }
}

extension CanvasFeatureState: Storable {
    public init(_ data: CanvasFeatureState) {
        self = data
    }

    public func snapshot() async throws -> CanvasFeatureState {
        self
    }
}
