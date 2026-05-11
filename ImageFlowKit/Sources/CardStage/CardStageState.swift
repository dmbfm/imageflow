import Foundation
import Helpers

enum CardStageState: Equatable {
    case floating(Floating)
    case docked(Docked, Floating)

    struct Floating: Equatable, With {
        var anchor: CardStageAnchor
        var dockedHeight: CGFloat? = nil
        var hidden: Bool
        var state: State
        var size: CGFloat

        enum State: Equatable {
            case idle
            case resizing(Resizing)
            case dragging(offset: CGSize)
        }

        struct Resizing: With, Equatable {
            var initialSize: CGFloat
            var translation: CGSize
            var handle: CardResizingHandle
        }
    }

    struct Docked: Equatable, With {
        var location: CardDockLocation
        var height: CGFloat
        var state: State

        enum State: Equatable {
            case idle
            case resizing(Resizing)
        }

        struct Resizing: With, Equatable {
            var initialSize: CGFloat
            var translation: CGFloat
        }
    }

    static func `default`(forConfiguration cfg: CardStageConfiguration) -> Self {
        .floating(
            .init(
                anchor: .bottomRight,
                dockedHeight: cfg.dockedHeightRange.ideal,
                hidden: false,
                state: .idle,
                size: cfg.cardSizeRange.ideal
            )
        )
    }

    static let `default`: Self = .floating(.init(anchor: .bottomRight, hidden: false, state: .idle, size: 250))

    static let dockedDefault: Self = .docked(
        .init(location: .bottom, height: 250, state: .idle),
        .init(anchor: .bottomRight, hidden: false, state: .idle, size: 250)
    )

    var cardVisibility: CardVisibility {
        self.hidden ? .hidden : .visible
    }

    var isFloating: Bool {
        switch self {
        case .floating: true
        case .docked: false
        }
    }

    var floating: Floating {
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

    var anchor: CardStageAnchor {
        get { self.floating.anchor }
        set { self.floating.anchor = newValue }
    }

    var hidden: Bool {
        get { self.floating.hidden }
        set { self.floating.hidden = newValue }
    }

    var dockLocation: CardDockLocation? {
        switch self {
        case .docked(let docked, _): docked.location
        case .floating: nil
        }
    }

    var dockedHeight: CGFloat? {
        switch self {
        case .docked(let docked, _): docked.height
        case .floating(let floating): floating.dockedHeight
        }
    }

    func hidden(_ hidden: Bool) -> Self {
        switch self {
        case .floating(let floating): .floating(floating.with(\.hidden, hidden))
        case .docked(let docked, let floating): .docked(docked, floating.with(\.hidden, hidden))
        }
    }

    func docked(_ location: CardDockLocation) -> Self {
        switch self {
        case .floating(let floating):
            .docked(.init(location: location, height: floating.dockedHeight ?? 250, state: .idle), floating)
        case let .docked(docked, floating):
            .docked(docked.with(\.location, location), floating)
        }
    }

    func undocked() -> Self {
        switch self {
        case .floating(_): self
        case .docked(let docked, let floating): .floating(floating.with(\.dockedHeight, docked.height))
        }
    }

    func settingAnchor(to anchor: CardStageAnchor) -> Self {
        switch self {
        case .floating(let floating): .floating(floating.with(\.anchor, anchor))
        case .docked(let docked, let floating): .docked(docked, floating.with(\.anchor, anchor))
        }
    }

    func settingCardVisibility(to cardVisibility: CardVisibility) -> Self {
        self.hidden(cardVisibility.hidden)
    }

    func settingDockedLocation(to newValue: CardDockLocation?) -> Self {
        if let newValue {
            switch self {
            case .docked(let docked, let floating):
                .docked(docked.with(\.location, newValue), floating)
            case .floating:
                self.docked(newValue)
            }
        } else {
            switch self {
            case .docked:
                self.undocked()
            case .floating:
                self
            }
        }
    }
}

enum CardResizingHandle: Sendable, Equatable {
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

    func handleContaining(point: CGPoint, margin: CGFloat) -> CardResizingHandle? {
        if self.diagonal.insetBy(dx: margin, dy: margin).contains(point) {
            .diagonal
        } else if self.horizontal.insetBy(dx: margin, dy: margin).contains(point) {
            .horizontal
        } else if self.vertical.insetBy(dx: margin, dy: margin).contains(point) {
            .vertical
        } else {
            nil
        }
    }
}
