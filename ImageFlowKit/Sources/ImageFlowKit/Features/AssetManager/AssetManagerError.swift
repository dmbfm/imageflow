import Foundation

enum AssetManagerError: Error {

    static func fromAny(_ err: any Error) -> Self {
        if let err = err as? Self {
            return err
        } else {
            return .other(err)
        }
    }

    case missingDocumentInfo

    case invalidAssetKind(AssetKind, expected: AssetKind?)

    case assestLoadingError(AssetLoadingError)

    case thumbnailLoadingError(ThumbnailLoadingError)

    case resouceLoadingError(ResourceLoadingError)

    case other(any Error)

    enum ThumbnailLoadingError {
        case assetNotFound(UUID)
        case fileNotFound(document: URL?, temp: URL)
        case cgImageSourceCreateWithURLError
        case cgImageSourceCreateThumbnailError
        case other(any Error)
    }

    enum AssetLoadingError {
        case repeatedID
        case photosMissingIdentifier
        case photosDataIsNil
        case missingPHAssetResource
        case URLAccessError
        case other(any Error)
    }

    enum ResourceLoadingError {
        case isNotFileAsset
        case cubeLutStringDecode
        case ciImageInitError
        case other(any Error)
    }
}
