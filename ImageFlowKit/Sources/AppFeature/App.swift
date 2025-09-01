import CanvasFeature
import CommonUtils
import NodeDataStore
import NodePaletteService
import SwiftUI
import SwiftUIUtils
import UniformTypeIdentifiers

public struct ImageFlowApp: App {

    public init() {}

    public var body: some Scene {
        DocumentGroup(newDocument: ImageFlowDocument.sample) { configuration in
            MainView(document: configuration.$document)
            #if os(macOS)

            #endif
        }

        #if os(iOS)
        DocumentGroupLaunchScene {}
        #endif
    }
}

struct ImageFlowDocument: FileDocument, Codable, Equatable {
    init(canvas: CanvasFeatureState = .init(), nodeData: NodeDataStore = .init()) {
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

    mutating func addNode(fromPaletteItem item: NodePaletteItem, at position: CGPoint = .zero) {
        let id = UUID()
        self.nodeData.addNode(.init(id: id, kind: item.nodeKind))
        self.canvas.nodePositions[id] = position
    }
}

extension ImageFlowDocument {
    static var sample: Self {
        let ids = [UUID(), UUID(), UUID()]
        let offset = CGPoint(x: 200, y: 200)
        let doc = ImageFlowDocument(
            canvas: .init(
                nodePositions: [
                    ids[0]: .zero + offset,
                    ids[1]: .init(x: 0, y: 200) + offset,
                    ids[2]: .init(x: 400, y: 0) + offset,
                ]),
            nodeData: .init(
                [
                    ids[0]: .init(id: ids[0], kind: .valueNode(.float)),
                    ids[1]: .init(id: ids[1], kind: .valueNode(.float)),
                    ids[2]: .init(id: ids[2], kind: .addNode(.float)),
                ],
                edges: .init(
                    [
                        .init(.init(node: ids[0], port: .output(0)), .init(node: ids[2], port: .input(0)))!,
                        .init(.init(node: ids[1], port: .output(0)), .init(node: ids[2], port: .input(1)))!,
                    ])
            )
        )
        print("doc: \(doc)")
        return doc
    }
}

extension UTType {
    static var imageFlowDocument: Self {
        .init(exportedAs: "com.dmbfm.imageFlowDocument", conformingTo: .package)
    }
}
