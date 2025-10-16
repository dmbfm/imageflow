import CoreImage
import Foundation

struct ImageAsset: Identifiable, Equatable, Codable {
    var id: UUID
    var state: State
    var added: Date

    /// Describes the current loading state of the asset.
    enum State: Equatable, Codable {
        /// The asset is being loaded, (e.g., copied from a source file on disk, or being imported from the photo library.)
        case loading
        /// The asset is fully loaded into the document in the manner indicated by the `Source` payload.
        case loaded(Source)
    }

    var isFileAsset: Bool {
        switch self.state {
        case .loading: true
        case .loaded(let source):
            switch source {
            case .file: true
            case .generated: false
            }
        }
    }

    var isLoaded: Bool {
        switch self.state {
        case .loaded: true
        case .loading: false
        }
    }

    var source: Source? {
        switch self.state {
        case .loading: nil
        case .loaded(let source): source
        }
    }

    enum Source: Equatable, Codable {
        case generated(node: UUID, port: Int)
        case file(String)

        var filename: String? {
            if case let .file(filename) = self {
                filename
            } else {
                nil
            }
        }
    }
}
