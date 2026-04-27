import AppKit
import SharedModels
import Synchronization

@MainActor

@objc(FlowDocument)
public class FlowDocument: NSDocument {

    var flow: Flow

    override init() {
        self.flow = .init()
        super.init()
    }

    public override nonisolated class var autosavesInPlace: Bool {
        return true
    }

    static var cascadingPoint: CGPoint = CGPoint(x: 200, y: 1400)
    static var lastContentSize: CGSize? = nil

    public override func makeWindowControllers() {

        let vc = MainViewController()
        let window = NSWindow(contentViewController: vc)

        if let screen = window.screen {
            Swift.print("HAS SCREEN!")
            let width = screen.frame.width * 0.8
            let height = screen.frame.height * 0.8
            window.setContentSize(.init(width: width, height: height))
        } else {
            window.setContentSize(.init(width: 1000, height: 700))
        }

        let wc = NSWindowController(window: window)
        wc.contentViewController = vc
        self.addWindowController(wc)
        // UserDefaults

        window.delegate = self
        window.setFrameAutosaveName("com.dmbfm.imageflow.macos.main-window")
        window.makeKeyAndOrderFront(nil)

        // Swift.print("#  \(NSDocumentController.shared.documents.count)")
        if NSDocumentController.shared.documents.count > 1 {
            Self.cascadingPoint = window.cascadeTopLeft(from: Self.cascadingPoint)
        } else {
            Self.cascadingPoint = window.frame.origin
        }

        if let size = Self.lastContentSize {
            window.setContentSize(size)
        }

        Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size

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

    public override func fileWrapper(ofType typeName: String) throws -> FileWrapper {
        .init()
        // fatalError("TODO")
    }

    public override nonisolated func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
    }
}

extension FlowDocument: NSWindowDelegate {
    public func windowWillClose(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size
        }
    }

    public func windowDidEndLiveResize(_ notification: Notification) {

    }

    public func windowDidResize(_ notification: Notification) {
        if let window = notification.object as? NSWindow {
            Self.lastContentSize = window.contentRect(forFrameRect: window.frame).size
        }
    }
}
