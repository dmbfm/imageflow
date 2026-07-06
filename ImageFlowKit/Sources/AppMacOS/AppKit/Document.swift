#if os(macOS)
import AppKit
import SharedModels
import Synchronization
import Helpers
import CanvasFeature
import UniformTypeIdentifiers
import AssetSystem

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
        super.init()
    }

    public override nonisolated static var autosavesInPlace: Bool {
        return true
    }

    public override func makeWindowControllers() {
        let documentInfo = DocumentInfo(id: self.id, url: self.fileURL)
        self.assetStore.setDocumentInfo(documentInfo)
        self.addWindowController(
            MainWindowController(self.flow, self.assetStore, self.canvas, undoManager: self.undoManager)
        )

        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeWelcomeWindow()
        }
    }

    public override func canAsynchronouslyWrite(
        to url: URL,
        ofType typeName: String,
        for saveOperation: NSDocument.SaveOperationType
    ) -> Bool {
        true
    }

    public override static func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        false
    }

    public override nonisolated func write(to url: URL, ofType typeName: String) throws {
        let existing: FileWrapper? =
            if let url = self.fileURL {
                {
                    _ = url.startAccessingSecurityScopedResource()
                    return try? FileWrapper(url: url)
                }()
            } else {
                nil
            }
        let fw = try self.fileWrapper(ofType: typeName, existingFile: existing)
        try fw.write(to: url, options: [.atomic], originalContentsURL: url)
    }

    public nonisolated func fileWrapper(
        ofType typeName: String,
        existingFile: FileWrapper?
    ) throws -> FileWrapper {
        let (snapshot, pathManager) = MainActor.unsafeAssumeIsolated { (self.snapshot(), self.assetStore.pathManager) }
        var assetsFws = existingFile?.fileWrappers?["Assets"]?.fileWrappers ?? [String: FileWrapper]()
        var urls = [URL]()
        // do {
        for (_, asset) in snapshot.assets.assets {
            switch asset.state {
            case .loaded(let filename, _):
                if let url: URL = try? pathManager.url(temporaryAssetFileURL: asset),
                    FileManager.default.fileExists(atPath: url.path)
                {
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

        return .init(directoryWithFileWrappers: fws)
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
