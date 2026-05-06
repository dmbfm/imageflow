import Helpers
import XKit

extension CanvasView {
    public struct EdgeLayer: Equatable {
        public var color: XColor
        public var edges: [Edge]

        public init(color: XColor, edges: [Edge]) {
            self.color = color
            self.edges = edges
        }
    }
}
