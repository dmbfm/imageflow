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

    public override func makeWindowControllers() {
        self.addWindowController(MainWindowController())

        if let appDelegate = NSApp.delegate as? AppDelegate {
            appDelegate.closeWelcomeWindow()
        }
    }

    public override func restoreState(with coder: NSCoder) {
        logger.debug("restoreState")
    }

    public override func encodeRestorableState(with coder: NSCoder, backgroundQueue queue: OperationQueue) {
        logger.debug("encodeRestorableState")
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
    }

    public override nonisolated func read(from fileWrapper: FileWrapper, ofType typeName: String) throws {
    }
}
