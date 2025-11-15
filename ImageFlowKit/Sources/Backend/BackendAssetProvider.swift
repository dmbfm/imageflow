@preconcurrency import CoreImage
import CubeLutKit
import Foundation
import Values

public protocol BackendAssetProvider {
    func backendAssetProviderGetLut(_ id: AssetIdentifier) async throws -> CubeLut
    func backendAssetProviderGetImage(_ id: AssetIdentifier) async throws -> CIImage
    func backendAssetProviderAddImage(_ image: CIImage?, node: UUID, port: Int) async throws
}

class DummyImageProvider: BackendAssetProvider {
    func backendAssetProviderGetLut(_ id: AssetIdentifier) async throws -> CubeLut {
        .identityRGBA
    }

    func backendAssetProviderGetImage(_ id: AssetIdentifier) async throws -> CIImage {
        .init()
    }

    func backendAssetProviderAddImage(_ image: CIImage?, node: UUID, port: Int) async throws {
    }
}
