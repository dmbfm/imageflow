@preconcurrency import CoreImage
import Foundation

extension Backend {
    public protocol ImageProvider {
        func getImage(_ id: ImageIdentifier) async throws(ImageProviderError) -> CIImage
        func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(ImageProviderError) -> ImageIdentifier
    }
    
    public enum ImageProviderError: Error {
        case invalidID
        case invalidImage
        case other(any Error)
    }
    
    class DummyImageProvider: ImageProvider {
        func getImage(_ id: ImageIdentifier) async throws(ImageProviderError) -> CIImage {
            .init()
        }
        
        func addImage(_ image: CIImage, id: ImageIdentifier?) async throws(ImageProviderError) -> ImageIdentifier {
            .asset(.init())
        }
    }
}
