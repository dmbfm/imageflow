@preconcurrency import CoreImage
import Foundation

public protocol FlowImageProvider {
    func getImage(_ id: ImageIdentifier) async throws(FlowImageProviderError) -> CIImage
    func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(FlowImageProviderError) -> ImageIdentifier
}

public enum FlowImageProviderError: Error {
    case invalidID
    case invalidImage
    case other(any Error)
}

class DummyImageProvider: FlowImageProvider {
    func getImage(_ id: ImageIdentifier) async throws(FlowImageProviderError) -> CIImage {
        .init()
    }

    func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(FlowImageProviderError) -> ImageIdentifier {
        .asset(.init())
    }
}
