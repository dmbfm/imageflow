import CanvasFeature
import NodeDataStore
import SwiftUI
import UniformTypeIdentifiers

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: ImageFlowDocument.sample) { configuration in
            MainView(document: configuration.$document)
        }

        #if os(iOS)
        DocumentGroupLaunchScene {}
        #endif
    }
}

struct ImageFlowDocument: FileDocument, Codable, Equatable {
    init(canvas: CanvasFeatureState = .init(), nodeData: NodeDataStore = .init()) {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!")
        self.canvas = canvas
        self.nodeData = nodeData
    }

    var canvas: CanvasFeatureState = .init()
    var nodeData: NodeDataStore = .init()

    static var readableContentTypes: [UTType] {
        [.imageFlowDocument]
    }

    init() {

    }

    init(configuration: ReadConfiguration) throws {
        self = .sample
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let fw = FileWrapper(directoryWithFileWrappers: [:])
        return fw
    }
}

extension ImageFlowDocument {
    static var sample: Self {
        let id = UUID()
        let doc = ImageFlowDocument(
            canvas: .init(nodePositions: [id: .zero]),
            nodeData: .init([id: .init(id: id, kind: .addNode(.float))])
        )
        print("doc: \(doc)")
        return doc
    }
}

extension UTType {
    static var imageFlowDocument: Self {
        .init(exportedAs: "com.dmbfm.imageFlowDocument")
    }
}
