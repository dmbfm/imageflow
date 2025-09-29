import SwiftUI
import Synchronization
import UniformTypeIdentifiers

@preconcurrency
final class ImageFlowDocument: ReferenceFileDocument, @unchecked Sendable {

    public let data: Mutex<FlowController.StorableData>

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(_ data: FlowController.StorableData = .init()) {
        self.data = .init(data)
    }

    required init(configuration: ReadConfiguration) throws {
        self.data = .init(.init())
    }

    func snapshot(contentType: UTType) throws -> FlowController.StorableData {
        self.data.withLock { data in
            log("document snapshot: \(data)")
            return data
        }
    }

    func fileWrapper(snapshot: FlowController.StorableData, configuration: WriteConfiguration) throws -> FileWrapper {
        return .init(directoryWithFileWrappers: [:])
    }
}

extension UTType {
    static var imageFlowDocument: UTType {
        .init(exportedAs: "com.dmbfm.imageFlowDocument")
    }
}
