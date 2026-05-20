import Foundation

enum Resource<R, E: Error> {
    case notLoaded
    case loading(Task<R, any Error>)
    case loaded(R)
    case failed(E)

    var state: ResourceState {
        switch self {
        case .notLoaded: .notLoaded
        case .loading(_): .loading
        case .loaded(_): .loaded
        case .failed(_): .failed
        }
    }
}

typealias Res<T> = Resource<T, AssetSystemError>

enum ResourceState: Sendable, Equatable, Codable {
    case notLoaded
    case loading
    case loaded
    case failed
}

extension Resource: Equatable where R: Equatable, E: Equatable {}
extension Resource: Sendable where R: Sendable, E: Sendable {}
