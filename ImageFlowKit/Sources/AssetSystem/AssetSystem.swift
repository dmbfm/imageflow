import OSLog
import Values

let logger = Logger(subsystem: "com.dmbfm.imageflow", category: "asset-system")

public enum AssetSystemEvent: Equatable, Sendable {
    case asssetsDidChange
    case resource(Resource)

    public enum Resource: Equatable, Sendable {
        case didAddImage(AssetIdentifier)
        case didRemoveImage(AssetIdentifier)
    }
}

public enum AssetSystemError: Error {
    case fetch(Fetch)
    case setResource(SetResource)
    case other(any Error)
    case message(String)
    case assetNotLoaded
    case assetFileNotFound
    case assetStoreReferenceNil
    case assetNotFound

    public enum Fetch: Error {
        case resourceNotFound
        case assetNodLoaded
    }

    public enum SetResource: Error {
        case invalidType
    }
}
