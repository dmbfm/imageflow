public enum PreviewPosition: String, Equatable, CaseIterable {
    case topLeft = "Top Left"
    case bottomLeft = "Bottom Left"
    case topRight = "Top Right"
    case bottomRight = "Bottom Right"
    case bottomDock = "Bottom"
    case topDock = "Top"

    public var isDocked: Bool {
        switch self {
        case .bottomDock, .topDock: true
        default: false
        }
    }
}
