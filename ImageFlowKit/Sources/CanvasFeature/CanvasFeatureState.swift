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

public struct CanvasFeatureState: Sendable, Codable {
    public var viewport: CanvasViewport = .init()
    public var nodePositions: [UUID:CGPoint] = .init()
    
    public init(viewport: CanvasViewport = .init(), nodePositions: [UUID:CGPoint] = .init()) {
        self.viewport = viewport
        self.nodePositions = nodePositions
    }
}

