import CoreImage
import Foundation
import Helpers
import SharedModels
import Values

@Observable
@MainActor
public final class MockAssetStore: AssetStoreService {

    public var documentID: UUID? { nil }

    public func registerAsset(asset: Asset) {}
    public func importAsset(imageItemProvider provider: NSItemProvider) async throws(AssetStoreServiceError) -> UUID {
        throw .message("Not Implemented")
    }
    public func importAsset(
        id: UUID?,
        kind: AssetKind,
        originalFilename: String?,
        importFunc: nonisolated(nonsending) (URL, UUID) async throws -> AssetStoreImportFuncResult
    ) async throws(AssetStoreServiceError) -> UUID {
        throw .message("Not Implemented")
    }

    public func addAsset(
        fromURL url: URL,
        kind: SharedModels.AssetKind,
        undoManager um: UndoManager?
    ) async throws(SharedModels.AssetStoreServiceError) -> UUID {
        throw .message("Not Implemented")
    }

    public func addAsset(
        data: Data,
        filename: String,
        kind: SharedModels.AssetKind,
        undoManager um: UndoManager?
    ) async throws(SharedModels.AssetStoreServiceError) -> UUID {
        throw .message("Not Implemented")
    }

    public func getThumb(forAsset id: UUID) async throws(SharedModels.AssetStoreServiceError) -> CGImage? {
        throw .message("Not Implemented")
    }

    public func getGeneratedResource(
        ciImageAt port: SharedModels.OutputPortLocation
    ) async throws(SharedModels.AssetStoreServiceError) -> SharedModels.GeneratedResource<CIImage> {
        throw .message("Not Implemented")
    }

    public func setDocumentInfo(_ info: SharedModels.DocumentInfo) {

    }

    public func remove(generatedAssetsForNode node: UUID) {

    }

    public func removeAsset(_ id: UUID, undoManager um: UndoManager?) {

    }

    public func titleForAsset(id: Values.AssetIdentifier) -> String? {
        nil
    }

    public init() {}

    public var assetManager: any BackendAssetProvider {
        fatalError()
    }

    public var assets: [UUID: SharedModels.Asset] = [:]

    public var delegate: SharedModels.AssetStoreServiceDelegate?

    public var emitter: EventEmitter<AssetStoreServiceEvent> = .init()

    public func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool {
        false
    }

    var image: CIImage? = nil
}
