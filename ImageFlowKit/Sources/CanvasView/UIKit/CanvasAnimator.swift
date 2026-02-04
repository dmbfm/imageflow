#if os(iOS)

import UIKit
import Helpers

@MainActor
class CanvasAnimator: DisplayLinkHelper.Delegate {
    weak var canvasView: CanvasUIView!
    var link: DisplayLinkHelper?

    var viewportOriginInitial: CGPoint?
    var viewportOriginTarget: CGPoint?
    var duration: CGFloat = 1.0
    var curve: EasingCurve?

    init(_ canvasView: CanvasUIView) {
        self.canvasView = canvasView
    }

    func animate(
        toViewportOrigin origin: CGPoint,
        duration: CGFloat,
    ) {
        if self.link != nil {
            self.link?.stop()
            self.link = nil
        }

        let link = DisplayLinkHelper()
        link.delegate = self

        self.duration = duration
        self.viewportOriginInitial = self.canvasView.viewport.origin
        self.viewportOriginTarget = origin
        self.curve = .quintic
        self.link = link

        link.start()
    }

    func step(ellapsed: Double) -> Bool {
        guard let initial = self.viewportOriginInitial,
            let target = self.viewportOriginTarget
        else {
            self.link = nil
            return false
        }

        let current = canvasView.viewport.origin

        let s =
            if let curve = self.curve {
                curve.easeOut(ellapsed / self.duration)
            } else {
                ellapsed / self.duration
            }

        if s > 1.0 {
            canvasView.viewport.origin = target
            self.link = nil
            return false
        }

        let x = initial.x * (1.0 - s) + target.x * s
        let y = initial.y * (1.0 - s) + target.y * s

        self.canvasView.viewport.origin = .init(x: x, y: y)

        if abs(current.distance(to: target)) < 0.1 {
            canvasView.viewport.origin = target
            self.link = nil
            return false
        }

        return true
    }
}

class DisplayLinkHelper {
    var link: CADisplayLink?
    weak var delegate: Delegate?

    var startTime: Double = 0

    protocol Delegate: AnyObject {
        func step(ellapsed: Double) -> Bool
    }

    func start() {
        if self.link != nil {
            self.stop()
        }

        let link = CADisplayLink(target: self, selector: #selector(Self.step(_:)))
        link.preferredFrameRateRange = .init(minimum: 60, maximum: 120, preferred: 120)
        link.add(to: .main, forMode: .default)
        self.link = link

        self.startTime = CACurrentMediaTime()
    }

    func stop() {
        self.link?.invalidate()
        self.link = nil
    }

    @objc
    func step(_ link: CADisplayLink) {
        let current = CACurrentMediaTime()
        let ellapsed = current - self.startTime

        if self.delegate?.step(ellapsed: ellapsed) != true {
            self.stop()
        }
    }
}

#endif
