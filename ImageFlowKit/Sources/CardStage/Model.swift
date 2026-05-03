import Foundation
import Helpers

public enum CardStageState: Sendable, Equatable {
    case floating(Floating)
    case docked(Docked)

    public struct Floating: Sendable, Equatable, With {
        public var anchor: CardStageAnchor
        public var hidden: Bool
        public var state: State
        public var size: CGFloat

        public enum State: Sendable, Equatable {
            case idle
            case resizing(Resizing)
            case dragging(offset: CGSize)
        }

        public struct Resizing: With, Sendable, Equatable {
            public var initialSize: CGFloat
            public var translation: CGSize
            public var handle: CardResizingHandle
        }
    }

    public struct Docked: Sendable, Equatable {
        var location: CardDockLocation
        var height: CGFloat
    }

    public static let `default`: Self = .floating(.init(anchor: .bottomRight, hidden: false, state: .idle, size: 250))

    public var anchor: CardStageAnchor? {
        if case let .floating(floating) = self {
            floating.anchor
        } else {
            nil
        }
    }
}

public struct CardStageConfiguration: Sendable, Equatable {
    public var insets: CardStageInsets
    public var cardSizeRange: ClosedRange<CGFloat>
    public var cardRadius: CGFloat

    static let `default`: Self = .init(insets: .init(10), cardSizeRange: 50...500, cardRadius: 10)

    init(insets: CardStageInsets, cardSizeRange: ClosedRange<CGFloat>, cardRadius: CGFloat) {
        self.insets = insets
        self.cardSizeRange = cardSizeRange
        self.cardRadius = cardRadius
    }
}

enum CardDockLocation {
    case top
    case bottom
}

public enum CardResizingHandle: Sendable, Equatable {
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

    func handleContaining(point: CGPoint) -> CardResizingHandle? {
        if self.diagonal.contains(point) {
            .diagonal
        } else if self.horizontal.contains(point) {
            .horizontal
        } else if self.vertical.contains(point) {
            .vertical
        } else {
            nil
        }
    }
}

public struct CardStageInsets: Sendable, Equatable {
    public var left: CGFloat
    public var right: CGFloat
    public var top: CGFloat
    public var bottom: CGFloat

    public init(_ value: CGFloat) {
        self.left = value
        self.right = value
        self.top = value
        self.bottom = value
    }

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
            height: rect.height - (self.top + self.bottom)
        )
    }
}

public enum CardStageAnchor: Sendable, Equatable, CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}
