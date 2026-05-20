import Foundation
import SharedModels

public protocol AssetImporter {
    @MainActor
    func doImport(_ store: AssetStoreProxy) async throws -> UUID
}

struct SimpleFileImporter: AssetImporter {
    var url: URL
    var kind: AssetKind

    func doImport(_ store: AssetStoreProxy) async throws -> UUID {
        @concurrent func doFileCopy(_ dest: URL) async throws {
            let ss = self.url.startAccessingSecurityScopedResource()
            defer {
                if ss {
                    self.url.stopAccessingSecurityScopedResource()
                }
            }
            try FileManager.default.copyItem(at: self.url, to: dest)
        }

        return try await store.performStandardAssetLoading(
            kind: self.kind,
            originalFilename: self.url.lastPathComponent,
            perform: { dest in
                try await doFileCopy(dest)
            }
        )
    }
}

struct ImageItemProviderImporter: AssetImporter {
    var item: NSItemProvider

    func doImport(_ store: AssetStoreProxy) async throws -> UUID {
        let id = UUID()
        let asset = Asset(id: id, kind: .image, timestamp: .now, state: .loading(originalFilename: nil))
        store.registerAsset(asset)
        let pm = store.pathManager

        do {
            let (originalURL, destURL) = try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<(URL, URL), any Error>) in
                _ = item.loadFileRepresentation(
                    for: .image,
                    completionHandler: { url, _, error in

                        if let error {
                            continuation.resume(throwing: AssetSystemError.other(error))
                            return
                        }

                        guard let url else {
                            continuation.resume(throwing: AssetSystemError.message("Unknown Error"))
                            return
                        }

                        let originalFilename = url.lastPathComponent

                        Task { @MainActor in
                            store.registerAsset(asset.with(\.state, .loading(originalFilename: originalFilename)))
                        }

                        let dest = pm.url(forImportingAssetWithID: id, originalURL: url)
                        do {
                            try FileManager.default.copyItem(at: url, to: dest)
                        } catch {
                            continuation.resume(throwing: error)
                        }

                        continuation.resume(returning: (url, dest))
                    }
                )
            }

            store.registerAsset(
                asset.with(
                    \.state,
                    .loaded(
                        filename: destURL.lastPathComponent,
                        originalFilename: originalURL.lastPathComponent
                    )
                )
            )

            return id
        } catch {
            store.removeAsset(id)
            throw error
        }
    }
}
