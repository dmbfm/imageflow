import SharedModels

public enum DefaultPreviewLocation: Int, CaseIterable {
    case tl
    case tr
    case bl
    case br
    case top
    case bottom
    case lastUsed

    var displayName: String {
        switch self {
        case .tl: "Top Left"
        case .tr: "Top Right"
        case .bl: "Bottom Left"
        case .br: "Bottom Right"
        case .top: "Top"
        case .bottom: "Bottom"
        case .lastUsed: "Last Used"
        }
    }

    var systemIcon: String {
        switch self {
        case .tl: .systemIconPreviewFloatTl
        case .bl:
            .systemIconPreviewFloatBl
        case .bottom:
            .systemIconDockDown
        case .br:
            .systemIconPreviewFloatBr
        case .lastUsed:
            "clock.arrow.trianglehead.counterclockwise.rotate.90"
        case .top:
            .systemIconDockUp
        case .tr:
            .systemIconPreviewFloatTr
        }
    }

    public var position: PreviewPosition? {
        switch self {
        case .tl: .topLeft
        case .tr: .topRight
        case .bl: .bottomLeft
        case .br: .bottomRight
        case .bottom: .bottomDock
        case .top: .topDock
        case .lastUsed: nil
        }
    }
}
