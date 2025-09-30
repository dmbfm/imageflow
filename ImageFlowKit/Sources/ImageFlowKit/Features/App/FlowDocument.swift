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

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(_ data: Flow.StorableData = .init(), _ canvas: CanvasFeatureState.StorableData = .init()) {
        self.flow = .init(data)
        self.canvas = .init(canvas)
    }

    required init(configuration: ReadConfiguration) throws {
        self.flow = .init(.init())
        self.canvas = .init(.init())
    }

    func snapshot(contentType: UTType) throws -> StorableData {
        .init(flow: self.flow.withLock({ $0 }), canvas: self.canvas.withLock({ $0 }))
    }

    func fileWrapper(snapshot: StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(directoryWithFileWrappers: [:])
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
