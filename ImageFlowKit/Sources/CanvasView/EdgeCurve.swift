import CommonUtils
import CoreGraphics
import Foundation

struct EdgeCurve {
    var start: CGPoint
    var controlStart1: CGPoint
    var controlStart2: CGPoint
    var middle: CGPoint
    var controlEnd1: CGPoint
    var controlEnd2: CGPoint
    var end: CGPoint

    init(start: CGPoint, end: CGPoint, withViewport viewport: CanvasViewport) {

        let startScreen = viewport.convert(start, from: .canvas, to: .screen)
        let endScreen = viewport.convert(end, from: .canvas, to: .screen)

        let dist1 = min(30.0, abs(start.x - end.x) * 0.32 + abs(start.y - end.y) * 0.1)

        let start2 = viewport.convert(start + CGPoint(x: dist1, y: 0.0), from: .canvas, to: .screen)
        let start22 = viewport.convert(start + CGPoint(x: dist1 * 0.95, y: 0.0), from: .canvas, to: .screen)
        let end2 = viewport.convert(end - CGPoint(x: dist1, y: 0.0), from: .canvas, to: .screen)
        let end22 = viewport.convert(end - CGPoint(x: dist1 * 0.95, y: 0.0), from: .canvas, to: .screen)

        let middlePoint = start2 * 0.5 + end2 * 0.5

        self.start = startScreen
        self.controlStart1 = start22
        self.controlStart2 = start2
        self.middle = middlePoint
        self.controlEnd1 = end22
        self.controlEnd2 = end2
        self.end = endScreen
    }

    var path: CGPath {
        let path = CGMutablePath()
        self.addToPath(path)
        return path
    }

    func addToPath(_ path: CGMutablePath) {
        path.move(to: self.start)
        path.addCurve(to: self.middle, control1: self.controlStart1, control2: self.controlStart2)
        path.move(to: self.end)
        path.addCurve(to: self.middle, control1: self.controlEnd1, control2: self.controlEnd2)
    }
}
