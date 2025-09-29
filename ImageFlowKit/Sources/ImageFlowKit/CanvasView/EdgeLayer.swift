
public struct EdgeLayer: Equatable {
    public var color: PlatformColor
    public var edges: [CanvasViewportEdge]

    public init(color: PlatformColor, edges: [CanvasViewportEdge]) {
        self.color = color
        self.edges = edges
    }
}
