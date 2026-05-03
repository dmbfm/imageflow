import Foundation
import Helpers
import SwiftUI

public protocol Animation: AnyObject {
    var label: String? { get }
    func start(prev: (any Animation)?)
    func tick(deltaTime: TimeInterval) -> AnimationTickResult
}

public enum AnimationTickResult {
    case `continue`
    case done
}

struct WeakAnimationRef {
    weak var animation: (any Animation)?

    init(animation: some Animation) {
        self.animation = animation
    }
}

// protocol AnimatableProperty {
//     associatedtype AnimatableData: VectorArithmetic

//     var from: AnimatableData { get }
//     var to: AnimatableData { get }
//     var current: AnimatableData { get set }
// }

// struct KeyPathAnimatableProperty<R: AnyObject, V: VectorArithmetic, KP: WritableKeyPath<R, V>>: AnimatableProperty {

//     typealias AnimatableData = V

//     let from: V
//     let to: V

//     weak var object: R?
//     var kp: KP

//     var current: V {
//         get { self.object?[keyPath: self.kp] ?? .zero }
//         set { self.object?[keyPath: self.kp] = newValue }
//     }

//     init(_ object: R?, keyPath: KP, from: V, to: V) {
//         self.object = object
//         self.kp = keyPath
//         self.from = from
//         self.to = to
//     }
// }

// class PropertyAnimator<P: AnimatableProperty>: Animation {

//     var label: String? = ""

//     var property: P
//     var timingFunction: TimingFunction = .linear
//     var duration: TimeInterval = 1.0
//     var t: TimeInterval = 0.0

//     internal init(
//         label: String? = "",
//         property: P,
//         timingFunction: TimingFunction = .linear,
//         duration: TimeInterval = 1.0
//     ) {
//         self.label = label
//         self.property = property
//         self.timingFunction = timingFunction
//         self.duration = duration
//     }

//     func tick(deltaTime: TimeInterval) -> AnimationTickResult {
//         self.t += deltaTime

//         self.property.current = self.timingFunction(
//             a: self.property.from,
//             b: self.property.to,
//             t: self.t,
//             duration: self.duration
//         )

//         if t > self.duration {
//             return .done
//         } else {
//             return .continue
//         }
//     }
// }
