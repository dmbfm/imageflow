import AnimKit
import Foundation

#if os(macOS)
import AppKit
#endif

@MainActor
class DockAnimation: AnimKit::Animation {

    let label: String? = "Dock Animation"

    var duration: Double = 0.2
    let timingFunc = TimingFunction.easing(.cubic, .easeInOut)
    var started: Bool = false
    var ellapsed: TimeInterval = 0

    struct AnimData {
        var frame: CGRect
        var cornerRadius: CGFloat
    }

    var from: AnimData
    var to: AnimData
    var apply: (AnimData) -> ()
    var didFinnish: (() -> ())?

    init(
        from: DockAnimation.AnimData,
        to: DockAnimation.AnimData,
        apply: @escaping (AnimData) -> (),
        didFinnish: (() -> ())? = nil
    ) {
        self.from = from
        self.to = to
        self.apply = apply
        self.didFinnish = didFinnish

        logger.info("from: \("\(from)"), to: \("\(to)")")
    }

    func start(prev: (any AnimKit.Animation)?) {
        if let prev = prev as? DockAnimation {
            self.duration = prev.ellapsed
        }
    }

    func tick(deltaTime: TimeInterval) -> AnimKit.AnimationTickResult {

        let currentFrame = self.timingFunc(
            a: self.from.frame,
            b: self.to.frame,
            t: self.ellapsed,
            duration: self.duration
        )

        let currentRadius = self.timingFunc(
            a: self.from.cornerRadius,
            b: self.to.cornerRadius,
            t: self.ellapsed,
            duration: self.duration
        )

        self.apply(.init(frame: currentFrame, cornerRadius: currentRadius))

        self.ellapsed += deltaTime
        if self.ellapsed >= self.duration {
            self.apply(self.to)
            self.didFinnish?()
            return .done
        } else {
            return .continue
        }
    }
}
