import Foundation

enum AssetManagerError: Error {

    case missingDocumentInfo

    case assestLoadingError(AssetLoadingError)

    case thumbnailLoadingError(ThumbnailLoadingError)

    case ciImageLoadingError(CIImageLoadingError)


    enum ThumbnailLoadingError {
        case assetNotFound(UUID)
        case assetStillLoading(UUID)
        case fileNotFound(document: URL?, temp: URL)
        case cgImageSourceCreateWithURLError
        case cgImageSourceCreateThumbnailError
        case other(any Error)
    }

    enum AssetLoadingError {
        case missingPHAssetResource
        case cgImageCreationFailed
        case URLAccessError
        case other(any Error)
    }

    enum CIImageLoadingError {}

}
