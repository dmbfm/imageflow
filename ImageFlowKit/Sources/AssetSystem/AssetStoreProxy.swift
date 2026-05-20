import Foundation
import SharedModels

@MainActor
public class AssetStoreProxy {
    private weak var store: AssetStore?
    private(set) var pathManager: PathManager

    public init(_ store: AssetStore, _ pathManager: PathManager) {
        self.store = store
        self.pathManager = pathManager
    }

    private func withStore(_ perform: @MainActor @escaping (AssetStore) -> ()) {
        if let store = self.store {
            Task { @MainActor in
                perform(store)
            }
        }
    }

    public func registerAsset(_ asset: Asset) {
        self.withStore { store in
            store.registerAsset(asset)
        }
    }

    public func removeAsset(_ id: UUID) {
        self.withStore { store in
            store.removeAsset(id)
        }
    }

    public func url(forImportingAssetWithID id: UUID, originalURL url: URL) -> URL {
        self.pathManager.url(forImportingAssetWithID: id, originalURL: url)
    }

    public func url(forImportingAssetWithID id: UUID, originalFilename: String) -> URL {
        self.pathManager.url(forImportingAssetWithID: id, originalFilename: originalFilename)
    }

    public func performStandardAssetLoading(
        id: UUID? = nil,
        kind: AssetKind,
        originalFilename: String,
        perform: @MainActor (URL) async throws -> ()
    ) async throws -> UUID {
        let id = id ?? UUID()
        let asset = Asset(
            id: id,
            kind: kind,
            timestamp: .now,
            state: .loading(originalFilename: originalFilename)
        )
        self.registerAsset(asset)

        let dest = self.url(forImportingAssetWithID: asset.id, originalFilename: originalFilename)

        try await perform(dest)

        self.registerAsset(
            asset.with(\.state, .loaded(filename: dest.lastPathComponent, originalFilename: originalFilename))
        )

        return id
    }
}
