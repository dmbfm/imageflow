#if os(macOS)
import AppKit
import SharedModels
import Synchronization
import Helpers
import CanvasFeature
import AssetManager
import UniformTypeIdentifiers

@MainActor
@objc(FlowDocument)
public final class FlowDocument: NSDocument {

    var id: UUID
    var flow: Flow
    var canvas: CanvasFeatureState
    var assetStore: AssetStore

    override init() {
        self.id = .init()
        self.flow = .init()
        self.canvas = .init()
        self.assetStore = .init()
        self.flow.addNode(.init(kind: .valueNode(.float)), at: .init(x: 400, y: 400))
        super.init()
    }

    public override nonisolated class var autosavesInPlace: Bool {
        return true
    }

    public override func makeWindowControllers() {
        self.addWindowController(MainWindowController(self.flow))

        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeWelcomeWindow()
        }
    }

    // public override func restoreState(with coder: NSCoder) {
    //     logger.debug("restoreState")
    // }

    // public override func restoreWindow(
    //     withIdentifier identifier: NSUserInterfaceItemIdentifier,
    //     state: NSCoder
    // ) async throws -> NSWindow {
    //     logger.info("restoreWindow: \(identifier.rawValue)")
    //     return .init()
    // }

    // public override func encodeRestorableState(with coder: NSCoder, backgroundQueue queue: OperationQueue) {
    //     logger.debug("encodeRestorableState")
    //     coder.encode("Hello!!".data(using: .utf8)!)
    // }

    public override func canAsynchronouslyWrite(
        to url: URL,
        ofType typeName: String,
        for saveOperation: NSDocument.SaveOperationType
    ) -> Bool {
        true
    }

    public override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        false
    }

    public override nonisolated func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        logger.info("fileWrapper:\(typeName)")

        let snapshot = MainActor.unsafeAssumeIsolated { self.snapshot() }

        logger.info("snapshot: \("\(snapshot)")")

        self.unblockUserInteraction()

        let result = FileWrapper(directoryWithFileWrappers: [
            "flow.json": .init(regularFileWithContents: try JSONEncoder().encode(snapshot))
        ])

        return result
    }

    public override nonisolated func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        logger.info("read:from:ofType:\(typeName)")

        guard typeName.lowercased() == UTType.imageFlowDocument.identifier.lowercased() else {
            logger.critical("Trying to open unsupported file type: \(typeName)")
            throw FlowDocumentError.read(.unsupportedType(typeName))
        }

        guard let children = fileWrapper.fileWrappers else {
            logger.critical("FileWrapper has no children!")
            throw FlowDocumentError.read(.noChildFileWrappers)
        }

        guard let flowJsonFW = children["flow.json"] else {
            logger.critical("flow.json is missing!")
            throw FlowDocumentError.read(.missinFlowJson)
        }

        guard let flowJsonData = flowJsonFW.regularFileContents else {
            logger.critical("Failed to read data for 'flow.json'")
            throw FlowDocumentError.read(.flowJsonReadDataError)
        }

        do {
            let snapshot = try JSONDecoder().decode(FlowDocument.StorableData.self, from: flowJsonData)

            MainActor.unsafeAssumeIsolated {
                self.restore(snapshot)
            }
        } catch {
            logger.critical("error: \(error)")
            throw error
        }
    }
}

enum FlowDocumentError: Error {
    case read(ReadError)

    enum ReadError: Error {
        case unsupportedType(String)
        case noChildFileWrappers
        case missinFlowJson
        case flowJsonReadDataError
    }
}

// See: https://forums.swift.org/t/unsafe-synchronous-access-to-mainactor-isolated-data-in-nsdocument/70049/2
extension MainActor {
    static func unsafeAssumeIsolated<T>(_ operation: @MainActor () throws -> T) rethrows -> T {
        try withoutActuallyEscaping(operation) { fn in
            let rawFn = unsafeBitCast(fn, to: (() throws -> T).self)
            return try rawFn()
        }
    }
}

extension FlowDocument: Storable {
    public struct StorableData: Sendable, Codable {
        public var id: UUID
        public var flow: Flow.StorableData
        public var canvas: CanvasFeatureState.StorableData
        public var assets: AssetStore.StorableData
    }

    public convenience init(_ data: StorableData) {
        fatalError("Not Supported")
    }

    public func restore(_ snapshot: StorableData) {
        self.id = snapshot.id
        self.flow.restore(snapshot.flow)
        self.canvas.restore(snapshot.canvas)
        self.assetStore.restore(snapshot.assets)
    }

    public func snapshot() -> StorableData {
        .init(
            id: self.id,
            flow: self.flow.snapshot(),
            canvas: self.canvas.snapshot(),
            assets: self.assetStore.snapshot()
        )
    }
}

#endif
