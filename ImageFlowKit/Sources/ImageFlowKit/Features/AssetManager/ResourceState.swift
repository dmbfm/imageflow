
enum ResourceState<R, E> {
    case notLoaded
    case loading
    case loaded(R)
    case failed(E)
}

extension ResourceState: Equatable where R: Equatable, E: Equatable {}
extension ResourceState: Sendable where R: Sendable, E: Sendable {}

