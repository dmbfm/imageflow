import Foundation
import Helpers
import Testing

@testable import CardStage

@Test
func testSquareOffsetted() {
    let o = CGPoint(x: .random(in: -500...500), y: .random(in: -500...500))
    let s = Square(origin: o, size: 1.0)

    for _ in 0...10 {
        let w = Double.random(in: -1000...1000)
        let h = Double.random(in: -1000...1000)
        let offset = CGSize(width: w, height: h)
        #expect(s.offsetted(by: offset) == Square(origin: o + offset.cgPoint, size: 1.0))
    }
}

@Test
func testSquareAligned() {
    let s = Square(origin: .zero, size: 1.0)
    var r = s.aligned(stage: .init(x: 0, y: 0, width: 100, height: 100), anchor: .bottomRight)
    var e = Square(origin: .init(x: 99, y: 99), size: 1.0)
    #expect(r == e)

    r = s.aligned(stage: .init(x: 0, y: 0, width: 100, height: 100), anchor: .bottomLeft)
    e = Square(origin: .init(x: 0, y: 99), size: 1.0)
    #expect(r == e)

    r = s.aligned(stage: .init(x: 0, y: 0, width: 100, height: 100), anchor: .topLeft)
    e = Square(origin: .init(x: 0, y: 0), size: 1.0)
    #expect(r == e)

    r = s.aligned(stage: .init(x: 0, y: 0, width: 100, height: 100), anchor: .topRight)
    e = Square(origin: .init(x: 99, y: 0), size: 1.0)
    #expect(r == e)
}

@Test
func testSquareDragResized() {
    let stage = CGRect(origin: .zero, size: .init(width: 100, height: 100))
    let range: ClosedRange<CGFloat> = 1.0...1000

    var s = Square(origin: .zero, size: 1.0)
    var r = s.dragResized(
        byTranslation: .init(width: 1, height: 1),
        usingHandle: .horizontal,
        anchor: .topLeft,
        stage: stage,
        sizeRange: range
    )
    var e = Square(origin: .zero, size: 2.0)
    #expect(r == e)

    s = Square(origin: .zero, size: 1.0).aligned(stage: stage, anchor: .bottomRight)
    r = s.dragResized(
        byTranslation: .init(width: -1, height: 1),
        usingHandle: .horizontal,
        anchor: .bottomRight,
        stage: stage,
        sizeRange: range
    )
    e = Square(origin: .init(x: 99, y: 99), size: 1.0)
    #expect(r == e)

    s = Square(origin: .zero, size: 1.0).aligned(stage: stage, anchor: .bottomRight)
    r = s.dragResized(
        byTranslation: .init(width: -1, height: -1),
        usingHandle: .vertical,
        anchor: .bottomRight,
        stage: stage,
        sizeRange: range
    )
    e = Square(origin: .init(x: 98, y: 98), size: 2.0)
    #expect(r == e)
}

@Test
func testSquareCorners() {
    let s = Square(origin: .init(x: 50, y: 50), size: 25)
    let e: [Corner: CGPoint] = [
        .topLeft: .init(x: 50, y: 50),
        .topRight: .init(x: 75, y: 50),
        .bottomRight: .init(x: 75, y: 75),
        .bottomLeft: .init(x: 50, y: 75),
    ]
    #expect(s.corners == e)
}

@Test
func testSquareResizeRects() {
    _ = {
        let s = Square(origin: .init(x: 0, y: 0), size: 10)
        let r = s.resizeRects(anchor: .topLeft, thickness: 1)
        let e = CardResizingRects(
            horizontal: .init(x: 0, y: 9, width: 10, height: 1),
            vertical: .init(x: 9, y: 0, width: 1, height: 10),
            diagonal: .init(x: 8, y: 8, width: 2, height: 2)
        )
        #expect(r == e)
    }()

    _ = {
        let s = Square(origin: .init(x: 0, y: 0), size: 10)
            .aligned(
                stage: .init(origin: .zero, size: .init(width: 100, height: 100)),
                anchor: .bottomRight
            )
        let r = s.resizeRects(anchor: .bottomRight, thickness: 1)
        let e = CardResizingRects(
            horizontal: .init(x: 90, y: 90, width: 10, height: 1),
            vertical: .init(x: 90, y: 90, width: 1, height: 10),
            diagonal: .init(x: 90, y: 90, width: 2, height: 2)
        )
        #expect(r == e)
    }()

    _ = {
        let s = Square(origin: .init(x: 0, y: 0), size: 10)
            .aligned(
                stage: .init(origin: .zero, size: .init(width: 100, height: 100)),
                anchor: .topRight
            )
        let r = s.resizeRects(anchor: .topRight, thickness: 1)
        let e = CardResizingRects(
            horizontal: .init(x: 90, y: 9, width: 10, height: 1),
            vertical: .init(x: 90, y: 0, width: 1, height: 10),
            diagonal: .init(x: 90, y: 8, width: 2, height: 2)
        )
        #expect(r == e)
    }()

    _ = {
        let s = Square(origin: .init(x: 0, y: 0), size: 10)
            .aligned(
                stage: .init(origin: .zero, size: .init(width: 100, height: 100)),
                anchor: .bottomLeft
            )
        let r = s.resizeRects(anchor: .bottomLeft, thickness: 1)
        let e = CardResizingRects(
            horizontal: .init(x: 0, y: 90, width: 10, height: 1),
            vertical: .init(x: 9, y: 90, width: 1, height: 10),
            diagonal: .init(x: 8, y: 90, width: 2, height: 2)
        )
        #expect(r == e)
    }()
}
