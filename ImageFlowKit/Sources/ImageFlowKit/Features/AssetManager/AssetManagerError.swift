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

    case assestLoadingError(AssetLoadingError)

    case thumbnailLoadingError(ThumbnailLoadingError)

    case ciImageLoadingError(CIImageLoadingError)

    case other(any Error)

    enum ThumbnailLoadingError {
        case assetNotFound(UUID)
        case assetStillLoading(UUID)
        case fileNotFound(document: URL?, temp: URL)
        case cgImageSourceCreateWithURLError
        case cgImageSourceCreateThumbnailError
        case other(any Error)
    }

    enum AssetLoadingError {
        case photosMissingIdentifier
        case photosDataIsNil
        case missingPHAssetResource
        case cgImageCreationFailed
        case URLAccessError
        case other(any Error)
    }

    enum CIImageLoadingError {}

}
