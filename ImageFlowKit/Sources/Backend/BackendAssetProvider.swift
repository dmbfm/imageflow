@preconcurrency import CoreImage
import CubeLutKit
import Foundation
import Values

public protocol BackendAssetProvider {
    func backendAssetProviderGetLut(_ id: UUID) async throws(BackendAssetProviderError) -> CubeLut
    func backendAssetProviderGetImage(_ id: ImageIdentifier) async throws(BackendAssetProviderError) -> CIImage
    func backendAssetProviderAddImage(_ image: CIImage, id: ImageIdentifier) async throws(BackendAssetProviderError)
}

public enum BackendAssetProviderError: Error {
    case tyingToAddImageWithAssetIdentifier(ImageIdentifier)
    case other(any Error)
}

class DummyImageProvider: BackendAssetProvider {
    func backendAssetProviderGetLut(_ id: UUID) async throws(BackendAssetProviderError) -> CubeLut {
        .identityRGBA
    }

    func backendAssetProviderGetImage(_ id: ImageIdentifier) async throws(BackendAssetProviderError) -> CIImage {
        .init()
    }

    func backendAssetProviderAddImage(_ image: CIImage, id: ImageIdentifier) async throws(BackendAssetProviderError) {
    }
}
