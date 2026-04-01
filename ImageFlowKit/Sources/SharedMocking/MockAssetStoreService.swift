import CoreImage
import Foundation
import Helpers
import SharedModels
import Values

public class MockAssetProvider: AssetsProvider {
    public func titleForAsset(id: AssetIdentifier) -> String? {
        nil
    }

    public let assets: [UUID: SharedModels.Asset] = [:]

    public init() {}
}

@Observable
@MainActor
public final class MockAssetStore: AssetStoreService {
    public func titleForAsset(id: Values.AssetIdentifier) -> String? {
        nil
    }

    public init() {}

    public var assetManager: any BackendAssetProvider {
        fatalError()
    }

    public var assets: [UUID: SharedModels.Asset] = [:]

    public var delegate: SharedModels.AssetStoreServiceDelegate?

    public func getThumb(forAsset id: UUID) async throws -> CGImage? {
        nil
    }

    public var emitter: EventEmitter<AssetStoreServiceEvent> = .init()

    public func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool {
        false
    }

    var image: CIImage? = nil

    public func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage> {
        throw Errors.generatedAssetNotFound
    }

    enum Errors: Error {
        case generatedAssetNotFound
    }
}
