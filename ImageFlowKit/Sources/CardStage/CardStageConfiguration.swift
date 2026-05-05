import Foundation
import Helpers

public struct CardStageConfiguration: Sendable, Equatable, With {
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
