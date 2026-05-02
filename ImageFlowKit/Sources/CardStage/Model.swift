import Foundation

// public struct CardStageModel: Sendable, Equatable {
//     public var anchor: CardStageAnchor
//     public var visible: Bool
// }

enum CardStageState {
    case floating(Floating)
    case docked(Docked)

    struct Floating {
        var anchor: CardStageAnchor
        var hidden: Bool
        var state: State
        var size: CGFloat

        enum State {
            case idle
            case resizing(Resizing)
            case dragging(offset: CGSize)
        }

        struct Resizing {
            var initialSize: CGFloat
            var translation: CGSize
            var handle: CardResizingHandle
        }
    }

    struct Docked {
        var location: CardDockLocation
        var height: CGFloat
    }
}

enum CardDockLocation {
    case top
    case bottom
}

enum CardResizingHandle {
    case horizontal
    case vertical
    case diagonal
}

struct CardResizingRects: Equatable {
    var horizontal: CGRect
    var vertical: CGRect
    var diagonal: CGRect

    subscript(_ handle: CardResizingHandle) -> CGRect {
        switch handle {
        case .horizontal: self.horizontal
        case .vertical: self.vertical
        case .diagonal: self.diagonal
        }
    }
}

public struct CardStageConfiguration: Sendable, Equatable {
    public var insets: CardStageInsets
    public var cardRadius: CGFloat

    public init(insets: CardStageInsets, cardRadius: CGFloat) {
        self.insets = insets
        self.cardRadius = cardRadius
    }
}

public struct CardStageInsets: Sendable, Equatable {
    public var left: CGFloat
    public var right: CGFloat
    public var top: CGFloat
    public var bottom: CGFloat

    public init(left: CGFloat, right: CGFloat, top: CGFloat, bottom: CGFloat) {
        self.left = left
        self.right = right
        self.top = top
        self.bottom = bottom
    }

    public func inset(rect: CGRect) -> CGRect {
        .init(
            x: rect.minX + self.left,
            y: rect.minY + self.top,
            width: rect.width - (self.left + self.right),
            height: rect.height - (self.top - self.bottom)
        )
    }
}

public enum CardStageAnchor: Sendable, Equatable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}
