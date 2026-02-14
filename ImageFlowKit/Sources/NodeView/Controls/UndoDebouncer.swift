import Foundation
import Values

@MainActor
class UndoDebouncer {

    let time: Double

    init(_ time: Double) {
        self.time = time
    }

    struct State {
        var task: Task<Void, any Error>
        var oldValue: Value
    }

    var state: State?

    func debounce(oldValue: Value, _ action: @escaping @MainActor (Value) -> ()) {
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
            oldValue: self.state?.oldValue ?? oldValue
        )
    }
}
