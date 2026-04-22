//
//  Document.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 29/09/25.
//

import AssetManager
import CanvasFeature
import Logging
import SharedModels
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

import class SharedModels.Flow

@preconcurrency
public final class FlowDocument: ReferenceFileDocument, @unchecked Sendable {
    public var id: UUID
    public let flow: Mutex<Flow.StorableData>
    public let canvas: Mutex<CanvasFeatureState.StorableData>
    public let assetStore: Mutex<AssetStore.StorableData>

    public static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    public init(
        _ data: Flow.StorableData = .init(),
        _ canvas: CanvasFeatureState.StorableData = .init(),
        _ assets: AssetStore.StorableData = .init(),
    ) {
        self.id = UUID()
        self.flow = .init(data)
        self.canvas = .init(canvas)
        self.assetStore = .init(assets)
    }

    required public init(configuration: ReadConfiguration) throws {
        guard let fws = configuration.file.fileWrappers else {
            throw Errors.missingFileWrappers
        }

        guard let flowFile = fws["flow.json"],
            let flowFileData = flowFile.regularFileContents
        else {
            throw Errors.flowJsonNotFound
        }
        let snapshot = try JSONDecoder().decode(StorableData.self, from: flowFileData)

        self.id = snapshot.id
        self.flow = .init(snapshot.flow)
        self.canvas = .init(snapshot.canvas)
        self.assetStore = .init(snapshot.assets)
    }

    public func snapshot(contentType: UTType) throws -> StorableData {
        let snap = StorableData(
            id: self.id,
            flow: self.flow.withLock({ $0 }),
            canvas: self.canvas.withLock({ $0 }),
            assets: self.assetStore.withLock({ $0 }),
        )
        return snap
    }

    public func fileWrapper(snapshot: StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        var assetsFws = configuration.existingFile?.fileWrappers?["Assets"]?.fileWrappers ?? [String: FileWrapper]()
        var urls = [URL]()
        do {
            for (_, asset) in snapshot.assets.assets {
                switch asset.state {
                case .loaded(let filename, _):
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
            log("error: \(error)", level: .error)
            throw error
        }

        // Exclude any unlisted assets
        assetsFws = assetsFws.filter { asset in
            if !snapshot.assets.assets.contains(where: { e in e.value.filename == asset.key }) {
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

extension FlowDocument {
    public struct StorableData: Sendable, Codable {
        public var id: UUID
        public var flow: Flow.StorableData
        public var canvas: CanvasFeatureState.StorableData
        public var assets: AssetStore.StorableData

        public init(
            id: UUID,
            flow: Flow.StorableData,
            canvas: CanvasFeatureState.StorableData,
            assets: AssetStore.StorableData
        ) {
            self.id = id
            self.flow = flow
            self.canvas = canvas
            self.assets = assets
        }
    }
}
