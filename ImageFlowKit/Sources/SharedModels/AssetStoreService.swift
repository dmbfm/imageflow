import Backend
import CoreImage
import Foundation
import Helpers
import UniformTypeIdentifiers
import Values

@_exported import protocol Backend.BackendAssetProvider

@MainActor
public protocol AssetStoreService:
    AssetsProvider & AssetObserver & AssetThumbProvider & GeneratedResourceProvider
        & AssetManagerProvider
{
    func addAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager?
    ) async throws -> UUID

    func addAsset(
        data: Data,
        filename: String,
        kind: AssetKind,
        undoManager um: UndoManager?
    ) async throws -> UUID

    init()
}

public enum AssetStoreServiceEvent {
    case modifiedGeneratedAsset(OutputPortLocation)
    case assetsChanged
}

public protocol AssetStoreServiceDelegate: AnyObject {
    func assetsStore(assetsDidChange assets: [UUID: Asset])
}

@MainActor
public protocol AssetObserver: AnyObject {
    var emitter: EventEmitter<AssetStoreServiceEvent> { get }
    var delegate: AssetStoreServiceDelegate? { get set }
}

@MainActor
public protocol AssetThumbProvider: AnyObject {
    func getThumb(forAsset id: UUID) async throws -> CGImage?
}

@MainActor
public protocol AssetsProvider: AnyObject {
    var assets: [UUID: Asset] { get }
    func titleForAsset(id: AssetIdentifier) -> String?
}

@MainActor
public protocol AssetManagerProvider: AnyObject {
    var assetManager: any BackendAssetProvider { get }
}

@MainActor
public protocol GeneratedResourceProvider: AnyObject {
    func getGeneratedResource(ciImageAt port: OutputPortLocation) async throws -> GeneratedResource<CIImage>
    func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool
}
