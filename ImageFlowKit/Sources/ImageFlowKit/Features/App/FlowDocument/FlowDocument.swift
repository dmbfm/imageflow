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

    public let flow: Mutex<Flow.StorableData>
    public let canvas: Mutex<CanvasFeatureState.StorableData>
    public let assetStore: FlowDocumentAssetStoreContainer

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(
        _ data: Flow.StorableData = .init(),
        _ canvas: CanvasFeatureState.StorableData = .init(),
        _ assets: FlowDocumentAssetStore = .init()
    ) {
        self.flow = .init(data)
        self.canvas = .init(canvas)
        self.assetStore = .init(assets)
    }

    required init(configuration: ReadConfiguration) throws {
        guard let fws = configuration.file.fileWrappers else {
            throw Errors.missingFileWrappers
        }

        for fw in fws {
            log("----------> fw: \(fw.key)")
        }

        guard let flowFile = fws["flow.json"],
            let flowFileData = flowFile.regularFileContents
        else {
            throw Errors.flowJsonNotFound
        }

        guard let metadataFile = fws["metadata.json"],
            let metadataFileData = metadataFile.regularFileContents
        else {
            throw Errors.metadataJsonNotFound
        }

        let metadata = try JSONDecoder().decode(FlowDocumentAssetStore.MetadataMap.self, from: metadataFileData)
        let snapshot = try JSONDecoder().decode(StorableData.self, from: flowFileData)

        var assets = FlowDocumentAssetStore()

        for (id, metadata) in metadata.metadata {
            guard let file = fws[id.uuidString], let fileData = file.regularFileContents else {
                throw Errors.missingFile(metadata)
            }
            assets.assets[id] = .init(metadata: metadata, data: fileData)
        }

        self.flow = .init(snapshot.flow)
        self.canvas = .init(snapshot.canvas)
        self.assetStore = .init(assets)
        log("--> \(assets)")
    }

    func snapshot(contentType: UTType) throws -> StorableData {
        .init(
            flow: self.flow.withLock({ $0 }),
            canvas: self.canvas.withLock({ $0 }),
        )
    }

    func fileWrapper(snapshot: StorableData) throws -> FileWrapper {
        let flow = FileWrapper(regularFileWithContents: try JSONEncoder().encode(snapshot))

        var fws: [String: FileWrapper] = ["flow.json": flow]

        try self.assetStore.store.withLock({ assets in
            for asset in assets.assets {
                fws[asset.key.uuidString] = .init(regularFileWithContents: asset.value.data)
            }
            let metadataMap = assets.metadataMap
            let metadataJson = try JSONEncoder().encode(metadataMap)
            fws["metadata.json"] = .init(regularFileWithContents: metadataJson)
        })

        return .init(directoryWithFileWrappers: fws)
    }

    func fileWrapper(snapshot: StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        try self.fileWrapper(snapshot: snapshot)
    }
}

extension FlowDocument {
    enum Errors: Error {
        case flowJsonNotFound
        case metadataJsonNotFound
        case missingFileWrappers
        case missingFile(FlowDocumentAsset.Metadata)
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
    }
}
