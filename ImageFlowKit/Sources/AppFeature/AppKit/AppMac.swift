#if canImport(AppKit)

import SwiftUI
import AppKit
import UniformTypeIdentifiers

public struct ImageFlowApp: App {

    // @NSApplicationDelegateAdaptor var appDelegate: AppDelegate

    public init() {}

    public var body: some Scene {

        DocumentGroup(newDocument: { ImageFlowDocument(.sample) }) { configuration in
            MainViewMac(document: configuration.document)
        }
        .defaultWindowPlacement { root, context in
            let screenRect = context.defaultDisplay.visibleRect
            let ratio = 0.7
            return .init(.center, width: ratio * screenRect.width, height: ratio * screenRect.height)
        }
        .defaultLaunchBehavior(.suppressed)

        WelcomeWindow("Image Flow")
            .defaultLaunchBehavior(.presented)
    }
}

// -------

import CanvasFeature
import CommonUtils
import NodeDataStore
import NodeSelectionStore

struct Flow: Sendable, Equatable, Codable {
    var canvas: CanvasFeatureState = .init()
    var nodeData: NodeDataStore = .init()
    var nodeSelection: NodeSelectionStore = .init()
}

extension Flow {
    static var sample: Self {
        let ids = [UUID(), UUID(), UUID()]
        var nodeData = NodeDataStore()
        nodeData.addNode(.init(id: ids[0], kind: .valueNode(.float)))
        nodeData.addNode(.init(id: ids[1], kind: .valueNode(.float)))
        nodeData.addNode(.init(id: ids[2], kind: .addNode(.float)))
        _ = try! nodeData.addEdge(.init(.init(node: ids[0], port: .output(0)), .init(node: ids[2], port: .input(0)))!)
            .get()
        _ = try! nodeData.addEdge(.init(.init(node: ids[1], port: .output(0)), .init(node: ids[2], port: .input(1)))!)
            .get()
        let offset: CGPoint = .init(x: 400, y: 400)
        return .init(
            canvas: .init(
                viewport: .init(),
                nodePositions: [
                    ids[0]: .init(x: 0, y: 0) + offset,
                    ids[1]: .init(x: 0, y: 200) + offset,
                    ids[2]: .init(x: 200, y: 100) + offset,
                ]
            ),
            nodeData: nodeData,
            nodeSelection: .init()
        )
    }
}

class ImageFlowDocument: ReferenceFileDocument, @unchecked Sendable {

    @Published var flow: Flow = .init()

    static var readableContentTypes: [UTType] { [.imageFlowDocument] }

    init(_ flow: Flow = .init()) {
        self.flow = flow
    }

    required init(configuration: ReadConfiguration) throws {
    }

    func snapshot(contentType: UTType) throws -> Flow {
        self.flow
    }

    func fileWrapper(snapshot: Flow, configuration: WriteConfiguration) throws -> FileWrapper {
        fatalError()
    }

}

#endif  // canImport(AppKit)
