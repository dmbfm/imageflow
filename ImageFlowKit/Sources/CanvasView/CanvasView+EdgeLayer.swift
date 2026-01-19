import Helpers

extension CanvasView {
    public struct EdgeLayer: Equatable {
        public var color: PlatformColor
        public var edges: [Edge]

        public init(color: PlatformColor, edges: [Edge]) {
            self.color = color
            self.edges = edges
        }
    }
}
