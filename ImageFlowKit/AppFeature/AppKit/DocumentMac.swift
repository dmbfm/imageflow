//
//  DocumentMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

#if canImport(AppKit)

@preconcurrency import AppKit
import Logging
@preconcurrency import SwiftUI
import Models
import UniformTypeIdentifiers

extension UTType {
    static var imageFlowDocument: UTType {
        .init(exportedAs: "com.dmbfm.imageFlowDocument")
    }
}

@objc(FlowDocument)
final class FlowDocument: NSDocument {

    var state: DocumentState = .init()

    override init() {
        super.init()
        self.hasUndoManager = true
    }

    override nonisolated class var autosavesInPlace: Bool {
        false
    }

    override func canAsynchronouslyWrite(
        to url: URL,
        ofType typeName: String,
        for saveOperation: NSDocument.SaveOperationType
    ) -> Bool {
        false
    }

    override class func canConcurrentlyReadDocuments(ofType typeName: String) -> Bool {
        false
    }

    override func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
        guard let index = fileWrapper.fileWrappers?["flow.json"], let indexData = index.regularFileContents else {
            fatalError()
        }

        Task { @MainActor in
            let snapshot = try JSONDecoder().decode(DocumentState.Snapshot.self, from: indexData)
            self.state.restore(snapshot)
        }
    }

    @preconcurrency
    override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        let fw = FileWrapper(directoryWithFileWrappers: [:])
        let snapshot = self.state.snapshot()
        let data = try JSONEncoder().encode(snapshot)
        fw.addRegularFile(withContents: data, preferredFilename: "flow.json")
        return fw
    }

    override func makeWindowControllers() {
        log("", level: .trace)

        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .resizable, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.setFrameAutosaveName("imageflowMainWindow")
        window.contentView = NSHostingView(
            rootView: DocumentView(self.state).environment(\._undoManager, self.undoManager)
        )
        window.center()
        window.toolbar = NSToolbar()
        window.toolbarStyle = .unified

        let wc = NSWindowController(window: window)
        self.addWindowController(wc)
    }

    @objc
    func copy(_ sender: AnyObject) {
    }
    @objc
    func cut(_ sender: AnyObject) {
    }
    @objc
    func paste(_ sender: AnyObject) {
    }

    @objc
    func selectAllNodes(_ sender: AnyObject) {

    }

    @objc
    func deselectAllNodes(_ sender: AnyObject) {

    }

    override func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.action {
        case #selector(copy(_:)):
            return false
        case #selector(cut(_:)):
            return false
        case #selector(paste(_:)):
            return false
        default:
            return true
        }
    }

}

extension NSDocument.SaveOperationType {
    public var name: String {
        switch self {
        case .autosaveAsOperation: "autosaveAsOperation"
        case .autosaveElsewhereOperation: "autosaveElsewhereOperation"
        case .autosaveInPlaceOperation: "autosaveInPlaceOperation"
        case .saveAsOperation: "saveAsOperation"
        case .saveOperation: "saveOperation"
        case .saveToOperation: "saveToOperation"
        @unknown default: "\(self.rawValue)"
        }
    }
}

#endif
