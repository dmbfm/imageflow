import Backend
import CoreImage
import Foundation
import Helpers
import UniformTypeIdentifiers
import Values

@_exported import protocol Backend.BackendAssetProvider

@MainActor
public protocol AssetStoreService {

    var assets: [UUID: Asset] { get }
    var emitter: EventEmitter<AssetStoreServiceEvent> { get }
    var delegate: AssetStoreServiceDelegate? { get set }
    var assetManager: any BackendAssetProvider { get }
    var documentID: UUID? { get }

    init()

    func registerAsset(asset: Asset)

    func importAsset(
        imageItemProvider provider: NSItemProvider,
    ) async throws(AssetStoreServiceError) -> UUID

    func importAsset(
        id: UUID?,
        kind: AssetKind,
        originalFilename: String?,
        importFunc: @Sendable (_ assetsDir: URL, _ id: UUID) async throws -> AssetStoreImportFuncResult
    ) async throws(AssetStoreServiceError) -> UUID
    func addAsset(
        fromURL url: URL,
        kind: AssetKind,
        undoManager um: UndoManager?
    ) async throws(AssetStoreServiceError) -> UUID
    func addAsset(
        data: Data,
        filename: String,
        kind: AssetKind,
        undoManager um: UndoManager?
    ) async throws(AssetStoreServiceError) -> UUID
    func setDocumentInfo(_ info: DocumentInfo)
    func removeAsset(_ id: UUID, undoManager um: UndoManager?)
    func getThumb(forAsset id: UUID) async throws(AssetStoreServiceError) -> CGImage?
    func titleForAsset(id: AssetIdentifier) -> String?
    func getGeneratedResource(
        ciImageAt port: OutputPortLocation
    ) async throws(AssetStoreServiceError) -> GeneratedResource<CIImage>
    func hasGeneratedResource(ciImageAt port: OutputPortLocation) async -> Bool
    func remove(generatedAssetsForNode node: UUID)
}

public enum AssetStoreServiceEvent {
    case modifiedGeneratedAsset(OutputPortLocation)
    case assetsChanged
}

public protocol AssetStoreServiceDelegate: AnyObject {
    func assetsStore(assetsDidChange assets: [UUID: Asset])
}

public struct AssetStoreImportFuncResult {
    public var filename: String
    public var originalFilename: String

    public init(filename: String, originalFilename: String) {
        self.filename = filename
        self.originalFilename = originalFilename
    }
}

public enum AssetStoreServiceError: LocalizedError, Sendable {
    case other(any Error)
    case addGeneratedResource(AddGeneratedResource)
    case getGeneratedResource(GetGeneratedResource)
    case getAssetResource(GetAssetResource)
    case importAsset(ImportAsset)
    case message(String)

    public enum AddGeneratedResource: Error {
        case invalidResourceType
    }

    public enum ImportAsset: Error {
        case missingDocumentInfo
        case photosMissingIdentifier
        case photosDataIsNil
        case photosMissingPHAssetResource
        case URLAccessError
    }

    public enum GetGeneratedResource: Error {
        case resourceNotFound
    }

    public enum GetAssetResource: Error {
        case resourceNotFound
        case assetNotLoaded
        case assetNotFound
        case thumbCGImageSourceCreateWithURLError
        case thumbCGImageSourceCreateThumbnailError
        case ciImageInitError
    }

    public static func from(_ error: any Error) -> AssetStoreServiceError {
        if let err = error as? AssetStoreServiceError {
            err
        } else {
            .other(error)
        }
    }
}
