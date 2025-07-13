import Foundation

public actor Throttler {
    private var task: Task<(), Never>? = nil
    private var lastTime: ContinuousClock.Instant
    private var duration: Duration
    private var clock: ContinuousClock

    public init(duration: Duration) {
        self.clock = ContinuousClock()
        self.duration = duration
        self.lastTime = self.clock.now - self.duration
    }

    public func execute(_ operation: @escaping @Sendable () async -> ()) {
        self.task?.cancel()

        let ellapsed = self.lastTime.duration(to: self.clock.now)
        let delay: Duration =
            if ellapsed > self.duration {
                .seconds(0)
            } else {
                self.duration - ellapsed
            }

        self.task = Task {
            do {
                try await Task.sleep(for: delay)
                await operation()
                self.lastTime = self.clock.now
            } catch {
                return
            }
        }
    }
}
