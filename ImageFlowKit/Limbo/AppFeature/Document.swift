import Logging
import SwiftUI
import Synchronization
import UniformTypeIdentifiers

@preconcurrency
final class ImageFlowDocument: ReferenceFileDocument, @unchecked Sendable {

    public let data: Mutex<Flow.StorableData>
    public let canvas: Mutex<CanvasFeatureState>

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(_ data: Flow.StorableData = .init()) {
        self.data = .init(data)
    }

    required init(configuration: ReadConfiguration) throws {
        self.data = .init(.init())
    }

    func snapshot(contentType: UTType) throws -> Flow.StorableData {
        self.data.withLock { data in
            log("document snapshot: \(data)")
            return data
        }
    }

    func fileWrapper(snapshot: Flow.StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(directoryWithFileWrappers: [:])
    }
}

extension UTType {
    static var imageFlowDocument: UTType {
        .init(exportedAs: "com.dmbfm.imageFlowDocument")
    }
}
