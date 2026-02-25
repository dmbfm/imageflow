import Foundation

/// A debouncer that remembers the *first* value in a sequence, performing a
/// given action when the debouncing period is over. Useful for coalescing
/// a sequence of changes that will be registered as a single undo item.
@MainActor
public class FirstValueDebouncer<Value> {

    let time: Double
    var state: State?

    struct State {
        var task: Task<Void, any Error>
        var oldValue: Value
    }

    /// Creates a debounces with the given period.
    /// - Parameter time: The debouncing period, in seconds.
    public init(_ time: Double) {
        self.time = time
    }

    /// Either starts a debouncing sequence (if is in progress), in which case `value` is
    /// dicarded, or starts a new sequence, storing the given `value`, which will be passed
    /// to the `action` closure when the debounce period ends.
    /// - Parameters:
    ///   - value: The value to be stored
    ///   - action: The closure to be called when the debounce period ends
    ///
    public func debounce(value: Value, _ action: @escaping @MainActor (Value) -> ()) {
        if self.state != nil {
            self.state?.task.cancel()
        }

        self.state = .init(
            task: Task { [weak self] in
                guard let self else { return }
                try await Task.sleep(for: .seconds(self.time))
                if let state = self.state {
                    action(state.oldValue)
                    self.state = nil
                }
            },
            oldValue: self.state?.oldValue ?? value
        )
    }
}
