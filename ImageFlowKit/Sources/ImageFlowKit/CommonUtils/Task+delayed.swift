extension Task {
    @discardableResult
    public static func delayed<C>(
        by duration: C.Instant.Duration,
        operation: @escaping @Sendable () async -> (),
        clock: C = ContinuousClock()
    ) -> Self where C: Clock, Success == Void, Failure == Never {
        Task {
            do {
                try await Task<Never, Never>.sleep(for: duration, clock: clock)
                await operation()
            } catch {
                return
            }
        }
    }

}
