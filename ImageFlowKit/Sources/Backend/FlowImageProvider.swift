@preconcurrency import CoreImage
import CubeLutKit
import Foundation
import Values

public protocol FlowImageProvider {
    func getLut(_ id: UUID) async throws(FlowImageProviderError) -> CubeLut
    func getImage(_ id: ImageIdentifier) async throws(FlowImageProviderError) -> CIImage
    func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(FlowImageProviderError) -> ImageIdentifier
}

public enum FlowImageProviderError: Error {
    case invalidID
    case invalidImage
    case other(any Error)
}

class DummyImageProvider: FlowImageProvider {
    func getLut(_ id: UUID) async throws(FlowImageProviderError) -> CubeLut {
        .identityRGBA
    }

    func getImage(_ id: ImageIdentifier) async throws(FlowImageProviderError) -> CIImage {
        .init()
    }

    func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(FlowImageProviderError) -> ImageIdentifier {
        .asset(.init())
    }
}
