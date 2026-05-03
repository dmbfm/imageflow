import Foundation
import Helpers
import Quartz

@MainActor
public final class AnimationController {

    weak var view: PlatformView?
    var link: CADisplayLink?
    var animations: [UUID: any Animation] = [:]

    public init(_ view: PlatformView) {
        self.view = view

        #if os(macOS)
        self.link = view.displayLink(target: self, selector: #selector(Self.tick(_:)))
        #endif

        self.link?.preferredFrameRateRange = .init(minimum: 60, maximum: 240, preferred: 120)
        self.link?.add(to: .current, forMode: .common)
    }

    public var isAnimating: Bool {
        !self.animations.isEmpty
    }

    public func start(id: UUID?, animation: some Animation) -> UUID {
        let id = id ?? UUID()
        animation.start(prev: self.animations[id])
        self.animations[id] = animation
        return id
    }

    public func remove(id: UUID) {
        self.animations.removeValue(forKey: id)
    }

    @objc func tick(_ link: CADisplayLink) {
        for (id, anim) in self.animations {
            switch anim.tick(deltaTime: link.duration) {
            case .continue:
                break
            case .done:
                self.animations.removeValue(forKey: id)
            }
        }
    }
}

extension AnimationController: CustomStringConvertible {
    public var description: String {
        "AnimationController(\(self.link?.timestamp, default: "):\n\t")"
            + self.animations.map({ (id, anim) in "\(id): \(anim.label, default: "[anonymous]")" }).joined(
                separator: "\n\t"
            )
    }
}
