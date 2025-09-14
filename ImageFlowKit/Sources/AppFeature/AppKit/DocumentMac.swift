//
//  DocumentMac.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 13/09/25.
//

#if canImport(AppKit)

import AppKit
import Logging
import SwiftUI
import Models

@Observable
class DocumentState {
    public var doc: ImageFlowDocument = .sample
}

@objc(FlowDocument)
final class FlowDocument: NSDocument {

    var state: DocumentState = .init()

    override func makeWindowControllers() {
        self.hasUndoManager = true
        //        log("xxx \(self.undoManager)")
        log("", level: .trace)

        let window = NSWindow(
            contentRect: .init(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .resizable, .closable, .miniaturizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.setFrameAutosaveName("imageflowMainWindow")
        window.contentView = NSHostingView(
            rootView: MainView(documentState: self.state).environment(\._undoManager, self.undoManager)
        )
        window.center()
        window.toolbar = NSToolbar()
        window.toolbarStyle = .unified

        let wc = NSWindowController(window: window)
        self.addWindowController(wc)
    }

    override nonisolated class var autosavesInPlace: Bool {
        true
    }

    override nonisolated func read(from data: Data, ofType typeName: String) throws {
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

    override func save(
        to url: URL,
        ofType typeName: String,
        for saveOperation: NSDocument.SaveOperationType
    ) async throws {
    }
}
#endif
