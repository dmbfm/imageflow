import Foundation

public protocol StateMachineImpl {
    associatedtype State
    associatedtype Output
    associatedtype Input

    static var initialState: State { get }

    static func step(state: State, input: Input) -> State?
    static func output(state: State) -> Output
}

public struct StateMachineStore<S: StateMachineImpl> {
    public var state: S.State

    public var output: S.Output {
        S.output(state: self.state)
    }

    public init(state: S.State = S.initialState) {
        self.state = state
    }

    public func input(_ input: S.Input, onTransition: ((S.State) -> Void)? = nil) {
        if let nextState = S.step(state: self.state, input: input) {
            onTransition?(nextState)
        }
    }
}
