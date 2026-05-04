import Foundation
import Helpers

public enum CardStageState: Sendable, Equatable {
    case floating(Floating)
    case docked(Docked, Floating)

    public struct Floating: Sendable, Equatable, With {
        public var anchor: CardStageAnchor
        public var dockedHeight: CGFloat? = nil
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

    public struct Docked: Sendable, Equatable, With {
        public var location: CardDockLocation
        public var height: CGFloat
        public var state: State

        public enum State: Sendable, Equatable {
            case idle
            case resizing(Resizing)
        }

        public struct Resizing: With, Sendable, Equatable {
            public var initialSize: CGFloat
            public var translation: CGFloat
        }
    }

    public static let `default`: Self = .floating(.init(anchor: .bottomRight, hidden: false, state: .idle, size: 250))

    public static let dockedDefault: Self = .docked(
        .init(location: .bottom, height: 250, state: .idle),
        .init(anchor: .bottomRight, hidden: false, state: .idle, size: 250)
    )

    public var isFloating: Bool {
        switch self {
        case .floating: true
        case .docked: false
        }
    }

    public var floating: Floating {
        get {
            switch self {
            case .floating(let floating): floating
            case .docked(_, let floating): floating
            }
        }
        set {
            switch self {
            case .floating: self = .floating(newValue)
            case .docked(let docked, _): self = .docked(docked, newValue)
            }
        }
    }

    public var anchor: CardStageAnchor {
        get { self.floating.anchor }
        set { self.floating.anchor = newValue }
    }

    public var hidden: Bool {
        get { self.floating.hidden }
        set { self.floating.hidden = newValue }
    }

    public var dockLocation: CardDockLocation? {
        switch self {
        case .docked(let docked, _): docked.location
        case .floating: nil
        }
    }

    public func docked(_ location: CardDockLocation) -> Self {
        switch self {
        case .floating(let floating):
            .docked(.init(location: location, height: floating.dockedHeight ?? 250, state: .idle), floating)
        case let .docked(docked, floating):
            .docked(docked.with(\.location, location), floating)
        }
    }

    public func undocked() -> Self {
        switch self {
        case .floating(_): self
        case .docked(let docked, let floating): .floating(floating.with(\.dockedHeight, docked.height))
        }
    }
}

public struct CardStageConfiguration: Sendable, Equatable {
    public var insets: CardStageInsets
    public var cardSizeRange: ClosedRange<CGFloat>
    public var dockedHeightRange: ClosedRange<CGFloat>
    public var cardRadius: CGFloat

    static let `default`: Self = .init(
        insets: .init(10),
        cardSizeRange: 50...500,
        cardRadius: 10,
        dockedHeightRange: 100...400
    )

    init(
        insets: CardStageInsets,
        cardSizeRange: ClosedRange<CGFloat>,
        cardRadius: CGFloat,
        dockedHeightRange: ClosedRange<CGFloat>
    ) {
        self.insets = insets
        self.cardSizeRange = cardSizeRange
        self.cardRadius = cardRadius
        self.dockedHeightRange = dockedHeightRange
    }
}

public enum CardDockLocation: Sendable, Equatable {
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

public enum CardStageAnchor: String, Sendable, Equatable, Identifiable, CaseIterable {
    public var id: Self { self }
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}
