//
//  Document.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import Logging
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

@preconcurrency
final class FlowDocument: ReferenceFileDocument, @unchecked Sendable {
    public let id: UUID = UUID()
    public let flow: Mutex<Flow.StorableData>
    public let canvas: Mutex<CanvasFeatureState.StorableData>
    public let assetStore: Mutex<AssetStore.StorableData>

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(
        _ data: Flow.StorableData = .init(),
        _ canvas: CanvasFeatureState.StorableData = .init(),
        _ assets: AssetStore.StorableData = .init()
    ) {
        self.flow = .init(data)
        self.canvas = .init(canvas)
        self.assetStore = .init(assets)
    }

    required init(configuration: ReadConfiguration) throws {
        log("!!!! opening")
        guard let fws = configuration.file.fileWrappers else {
            throw Errors.missingFileWrappers
        }

        guard let flowFile = fws["flow.json"],
            let flowFileData = flowFile.regularFileContents
        else {
            throw Errors.flowJsonNotFound
        }
        let snapshot = try JSONDecoder().decode(StorableData.self, from: flowFileData)

        log("loaded snapshot: \(snapshot)")

        self.flow = .init(snapshot.flow)
        self.canvas = .init(snapshot.canvas)
        self.assetStore = .init(snapshot.assets)
    }

    func snapshot(contentType: UTType) throws -> StorableData {
        let snap = StorableData(
            flow: self.flow.withLock({ $0 }),
            canvas: self.canvas.withLock({ $0 }),
            assets: self.assetStore.withLock({ $0 })
        )
        log("generated snapshot: \(snap)", level: .debug)
        return snap
    }

    func fileWrapper(snapshot: StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        var assetsFws = configuration.existingFile?.fileWrappers?["Assets"]?.fileWrappers ?? [String: FileWrapper]()
        var urls = [URL]()
        do {
            for (_, asset) in snapshot.assets.images {
                switch asset.source {
                case .file(let filename):
                    let url: URL = .tempAssetURL(forDocument: self.id, filename: filename)
                    if FileManager.default.fileExists(atPath: url.path) {
                        let fw = try FileWrapper(
                            url: url
                        )
                        assetsFws[filename] = fw
                        urls.append(url)
                    }
                default:
                    break
                }
            }
        } catch {
            log("error: \(error)")
            throw error
        }

        // Exclude any unlisted assets
        assetsFws = assetsFws.filter { asset in
            if !snapshot.assets.images.contains(where: { e in e.value.source?.filename == asset.key }) {
                false
            } else {
                true
            }
        }

        let flow = FileWrapper(regularFileWithContents: try JSONEncoder().encode(snapshot))
        let fws: [String: FileWrapper] = ["flow.json": flow, "Assets": .init(directoryWithFileWrappers: assetsFws)]
        // log("urls: \(urls)")
        // Task.detached {
        //     try await Task.sleep(for: .seconds(0.1))
        //     for url in urls {
        //         try FileManager.default.removeItem(at: url)
        //     }
        // }
        return .init(directoryWithFileWrappers: fws)
    }
}

extension FlowDocument {
    enum Errors: Error {
        case flowJsonNotFound
        case metadataJsonNotFound
        case missingFileWrappers
    }
}

extension UTType {
    static var imageFlowDocument: UTType {
        .init(exportedAs: "com.dmbfm.imageFlowDocument")
    }
}

extension FlowDocument {
    struct StorableData: Sendable, Codable {
        var flow: Flow.StorableData
        var canvas: CanvasFeatureState.StorableData
        var assets: AssetStore.StorableData
    }
}
