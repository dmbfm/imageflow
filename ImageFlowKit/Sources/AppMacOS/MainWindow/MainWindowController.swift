import AppKit

class MainWindowController: NSWindowController {
    override init(window: NSWindow?) {
        super.init(window: window)
        // self.shouldCascadeWindows = true
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func close() {
        print("close!!")
        super.close()
    }
}
