import Foundation
import Helpers
import XKit

public struct CardStageConfiguration: Sendable, Equatable, With {
    /// The edge insets defining the area the flaoting card can occupy.
    public var insets: CardStageInsets
    /// The size-range that the square sides of the floating card can have.
    public var cardSizeRange: SizeRange
    /// The height-range that the docked panel can have.
    public var dockedHeightRange: SizeRange
    /// The corner radius of the floating card.
    public var cardRadius: CGFloat
    /// The shadow of the floating card.
    public var cardShadow: XViewEx.Shadow?
    /// The thickness of the resizing areas of the floating card.
    public var cardResizeHandleThickness: CGFloat = 10
    /// The thickness of the resizing area of the docked panel.
    public var dockedResizeHandleThickness: CGFloat = 10
    /// The distance from the bottom / top edges that will snap a floating card the user is dragging, docking it.
    public var edgeMarginToDockWhileDraggingCard: CGFloat = 12

    static let `default`: Self = .init(
        insets: .init(10),
        cardSizeRange: .init(range: 50...500, ideal: 250),
        cardRadius: 10,
        dockedHeightRange: .init(range: 100...600, ideal: 320),
        cardShadow: .init(color: .init(white: 0, alpha: 0.4), opacity: 1, offset: .zero, radius: 8)
    )

    public struct SizeRange: Sendable, Equatable {
        public var range: ClosedRange<CGFloat>
        public var ideal: CGFloat

        public init(range: ClosedRange<CGFloat>, ideal: CGFloat) {
            self.range = range
            self.ideal = ideal
        }
    }

    init(
        insets: CardStageInsets,
        cardSizeRange: SizeRange,
        cardRadius: CGFloat,
        dockedHeightRange: SizeRange,
        cardShadow: XViewEx.Shadow?
    ) {
        self.insets = insets
        self.cardSizeRange = cardSizeRange
        self.cardRadius = cardRadius
        self.dockedHeightRange = dockedHeightRange
        self.cardShadow = cardShadow
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
