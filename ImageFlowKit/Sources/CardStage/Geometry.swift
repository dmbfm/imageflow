import Foundation
import Helpers

enum Geometry: Equatable {
    case floating(Floating)
    case docked(Docked)

    var floating: Floating? {
        if case let .floating(value) = self { value } else { nil }
    }

    var docked: Docked? {
        if case let .docked(value) = self { value } else { nil }
    }

    struct Floating: Equatable {
        var square: Square
    }

    struct Docked: Equatable {
        var frame: CGRect

        func resizingRect(forLocation location: CardDockLocation, thickness: CGFloat) -> CGRect {
            switch location {
            case .bottom:
                .init(origin: self.frame.origin, size: .init(width: self.frame.width, height: thickness))
            case .top:
                .init(
                    origin: self.frame.origin + .init(x: 0, y: self.frame.height - thickness),
                    size: .init(width: self.frame.width, height: thickness)
                )
            }
        }
    }

    var square: Square? {
        switch self {
        case .floating(let floating): floating.square
        case .docked: nil
        }
    }

    var dockedFrame: CGRect? {
        switch self {
        case .docked(let docked): docked.frame
        case .floating: nil
        }
    }

    static let zero: Self = .floating(.init(square: .init(origin: .zero, size: 0)))

    static func fromState(
        _ state: CardStageState,
        stageBounds bounds: CGRect,
        configuration config: CardStageConfiguration
    ) -> Self {
        switch state {
        case .docked(let docked, _):

            let rect =
                switch docked.location {
                case .bottom:
                    switch docked.state {
                    case .idle:
                        CGRect(
                            x: bounds.minX,
                            y: bounds.maxY - docked.height,
                            width: bounds.width,
                            height: docked.height
                        )
                    case .resizing(let resizing):
                        CGRect(
                            x: bounds.minX,
                            y: bounds.maxY - docked.height + resizing.translation,
                            width: bounds.width,
                            height: docked.height - resizing.translation
                        )
                    }
                case .top:
                    switch docked.state {
                    case .idle:
                        CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: docked.height)
                    case .resizing(let resizing):
                        CGRect(x: bounds.minX, y: bounds.minY, width: bounds.width, height: docked.height + resizing.translation)
                    }
                }

            return .docked(.init(frame: rect))

        case .floating(let state):
            return .floating(
                .init(
                    square: state.cardSquare(
                        forStageBounds: bounds,
                        insets: config.insets,
                        sizeRange: config.cardSizeRange,
                    )
                )
            )
        }
    }

}

struct Stage {
    var bounds: CGRect
    var insets: CardStageInsets

    func squareCenterPoint(
        forAnchor anchor: CardStageAnchor,
        squreSize: CGFloat,
    ) -> CGPoint {
        let area = self.insets.inset(rect: self.bounds)
        let s = squreSize * 0.5

        switch anchor {
        case .topLeft:
            return .init(
                x: area.minX + s,
                y: area.minY + s
            )
        case .topRight:
            return .init(
                x: area.maxX - s,
                y: area.minY + s,
            )
        case .bottomLeft:
            return .init(
                x: area.minX + s,
                y: area.maxY - s,
            )
        case .bottomRight:
            return .init(
                x: area.maxX - s,
                y: area.maxY - s,
            )
        }
    }

    func closestAnchor(toSquare square: Square) -> CardStageAnchor {
        let center = square.center
        let (anchor, _) = CardStageAnchor.allCases.reduce(
            (CardStageAnchor.topLeft, CGFloat.greatestFiniteMagnitude),
            { acc, anchor in
                let p = self.squareCenterPoint(forAnchor: anchor, squreSize: square.size)
                let d = center.distance(to: p)
                if d < acc.1 {
                    return (anchor, d)
                } else {
                    return acc
                }
            }
        )
        return anchor
    }
}

struct Square: Equatable {
    var origin: CGPoint
    var size: CGFloat

    var rect: CGRect {
        .init(origin: self.origin, size: .init(width: self.size, height: self.size))
    }

    var center: CGPoint {
        .init(x: self.origin.x + self.size * 0.5, y: self.origin.y + self.size * 0.5)
    }

    /// Offsets the square by the given amount.
    /// - Parameter offset:
    /// - Returns: The offsetted square.
    func offsetted(by offset: CGSize) -> Self {
        Square(origin: self.origin + offset.cgPoint, size: self.size)
    }

    /// Returns a new square with the same size but positioned so it is aligned
    /// to the given `CardStageAnchor`.
    /// - Parameters:
    ///   - stage:
    ///   - anchor:
    ///
    /// - Returns: The new aligned square.
    func aligned(stage: CGRect, anchor: CardStageAnchor) -> Self {
        switch anchor {
        case .topLeft:
            Square(origin: stage.origin, size: self.size)
        case .topRight:
            Square(origin: stage.origin + .init(x: stage.width - self.size, y: 0), size: self.size)
        case .bottomLeft:
            Square(origin: stage.origin + .init(x: 0, y: stage.height - self.size), size: self.size)
        case .bottomRight:
            Square(
                origin: stage.origin + .init(x: stage.width - self.size, y: stage.height - self.size),
                size: self.size
            )
        }
    }

    /// Calculates the new square obtained when the user resizes a Card by
    /// dragging one of its `CardResizingHandle`s by the given translation amount.
    ///
    /// The square's origin is also modified as to maintain its alignment with the given `anchor`.
    ///
    /// - Parameters:
    ///   - t:
    ///   - handle:
    ///   - anchor:
    ///   - stage:
    ///   - range:
    ///
    /// - Returns: The resized square.
    func dragResized(
        byTranslation t: CGSize,
        usingHandle handle: CardResizingHandle,
        anchor: CardStageAnchor,
        stage: CGRect,
        sizeRange range: ClosedRange<CGFloat>,
    ) -> Self {

        let localTranslation = anchor.convertToLocal(t)

        let newSize: CGFloat =
            switch handle {
            case .horizontal:
                (self.size + localTranslation.height).clamped(to: range)
            case .vertical:
                (self.size + localTranslation.width).clamped(to: range)
            case .diagonal:
                (self.size + max(localTranslation.width, localTranslation.width)).clamped(to: range)
            }

        return Square(
            origin: self.origin,
            size: newSize
        )
        .aligned(stage: stage, anchor: anchor)
    }

    /// Returns the corner point of the square for the given `Corner`.
    /// - Parameter corner:
    /// - Returns: The corner point.
    func point(forCorner corner: Corner) -> CGPoint {
        switch corner {
        case .topLeft:
            self.origin
        case .topRight:
            self.origin + .init(x: self.size, y: 0)
        case .bottomLeft:
            self.origin + .init(x: 0, y: self.size)
        case .bottomRight:
            self.origin + .init(x: self.size, y: self.size)
        }
    }

    /// The corner points of the square
    var corners: [Corner: CGPoint] {
        .init(uniqueKeysWithValues: Corner.allCases.map({ ($0, self.point(forCorner: $0)) }))
    }

    /// Returns the set of resizing handle rects for the given alinment `anchor`.
    /// - Parameters:
    ///   - anchor:
    ///   - thickness:
    ///
    /// - Returns: The set of resizing handle rects.
    func resizeRects(anchor: CardStageAnchor, thickness: CGFloat) -> CardResizingRects {
        let o = self.origin
        let s = self.size
        let t = thickness

        let horizontal = CGRect(origin: .zero, size: .init(width: s, height: t))
        let vertical = CGRect(origin: .zero, size: .init(width: t, height: s))
        let diag = CGRect(origin: .zero, size: .init(width: 2 * t, height: 2 * t))

        func offset(handle: CardResizingHandle) -> CGPoint {
            switch anchor {
            case .topLeft:
                switch handle {
                case .horizontal:
                    CGPoint(x: 0, y: s - t)
                case .vertical:
                    CGPoint(x: s - t, y: 0)
                case .diagonal:
                    CGPoint(x: s - 2 * t, y: s - 2 * t)
                }
            case .topRight:
                switch handle {
                case .horizontal:
                    CGPoint(x: 0, y: s - t)
                case .vertical:
                    CGPoint(x: 0, y: 0)
                case .diagonal:
                    CGPoint(x: 0, y: s - 2 * t)
                }
            case .bottomLeft:
                switch handle {
                case .horizontal:
                    CGPoint(x: 0, y: 0)
                case .vertical:
                    CGPoint(x: s - t, y: 0)
                case .diagonal:
                    CGPoint(x: s - 2 * t, y: 0)
                }
            case .bottomRight:
                .zero
            }
        }

        return .init(
            horizontal: horizontal.with(\.origin, o + offset(handle: .horizontal)),
            vertical: vertical.with(\.origin, o + offset(handle: .vertical)),
            diagonal: diag.with(\.origin, o + offset(handle: .diagonal))
        )
    }
}

enum Corner: CaseIterable {
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
}

extension CardStageAnchor {
    /// Converts the give `size` to a local coordinate system that is
    /// axis-alined with the anchor.
    ///
    /// For instance, a bottom-right anchor will flip the x and y coordinates,
    /// while a topLeft anchor will not flip any coordinates.
    /// - Parameter size:
    /// - Returns:
    func convertToLocal(_ size: CGSize) -> CGSize {
        switch self {
        case .topLeft:
            size
        case .topRight:
            .init(width: -size.width, height: size.height)
        case .bottomLeft:
            .init(width: size.width, height: -size.height)
        case .bottomRight:
            .init(width: -size.width, height: -size.height)
        }
    }
}

extension CardStageState.Floating {
    /// Returns the card square for the current floating card stage state.
    /// - Parameters:
    ///   - bounds: The bounds of the card stage view.
    ///   - insets: The insets.
    ///   - sizeRange: The range of sizes the card can have.
    ///
    /// - Returns: The card square.
    func cardSquare(
        forStageBounds bounds: CGRect,
        insets: CardStageInsets,
        sizeRange: ClosedRange<CGFloat>,
    ) -> Square {
        let stage = insets.inset(rect: bounds)
        let idleSqure = Square(origin: .zero, size: self.size)
            .aligned(stage: stage, anchor: self.anchor)

        switch self.state {
        case .idle:
            return idleSqure
        case let .dragging(offset):
            return idleSqure.offsetted(by: offset)
        case let .resizing(resizing):
            return idleSqure.dragResized(
                byTranslation: resizing.translation,
                usingHandle: resizing.handle,
                anchor: self.anchor,
                stage: stage,
                sizeRange: sizeRange
            )
        }
    }
}

extension CGRect: With {}
