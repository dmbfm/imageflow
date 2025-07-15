import CommonUtils
import SwiftUI

public struct DragGestureWithDelta: Gesture {
    public struct Value: Sendable, Equatable {
        public var time: Date
        public var location: CGPoint
        public var startLocation: CGPoint
        public var translation: CGSize
        public var velocity: CGSize
        public var predictedEndLocation: CGPoint
        public var predictedEndTranslation: CGSize
        public var delta: CGSize

        public init(_ value: DragGesture.Value, delta: CGSize) {
            self.time = value.time
            self.location = value.location
            self.startLocation = value.startLocation
            self.translation = value.translation
            self.velocity = value.velocity
            self.predictedEndLocation = value.predictedEndLocation
            self.predictedEndTranslation = value.predictedEndTranslation
            self.delta = delta
        }
    }

    struct State {
        var delta: CGSize = .zero
        var lastLocation: CGPoint?
    }

    @GestureState var state = State()
    let minimumDistance: CGFloat
    let coordinateSpace: CoordinateSpaceProtocol

    public init(minimumDistance: CGFloat = 10, coordinateSpace: some CoordinateSpaceProtocol = .local) {
        self.minimumDistance = minimumDistance
        self.coordinateSpace = coordinateSpace
    }

    public var body: AnyGesture<Value> {
        AnyGesture(
            DragGesture(minimumDistance: self.minimumDistance, coordinateSpace: self.coordinateSpace)
                .updating(self.$state) { value, state, _ in
                    if state.lastLocation == nil {
                        state.lastLocation = value.location
                    }

                    state.delta = (value.location - state.lastLocation!).cgSize
                    state.lastLocation = value.location
                }
                .map { value in .init(value, delta: self.state.delta) }
        )
    }
}
