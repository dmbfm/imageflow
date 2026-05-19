#if os(macOS)

import AppKit
import SharedModels

final class MainWindow: NSWindow {

    enum Event {
        case spacebarDown(locationInWindow: CGPoint?)
        case escapeDown
    }

    weak var mainWindowDelegate: MainWindowDelegate? = nil

    var shouldAcceptEscapeKeyDown: Bool {
        self.mainWindowDelegate?.mainWindowShouldAcceptEscapeKeyDown() ?? false
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == KeyCode.space {
            self.mainWindowDelegate?.mainWindowEvent(
                .spacebarDown(locationInWindow: self.mouseLocationOutsideOfEventStream)
            )
        } else if event.keyCode == KeyCode.escape && self.shouldAcceptEscapeKeyDown {
            self.mainWindowDelegate?.mainWindowEvent(.escapeDown)
        } else {
            super.keyDown(with: event)
        }
    }
}

protocol MainWindowDelegate: AnyObject {
    func mainWindowEvent(_ event: MainWindow.Event)
    func mainWindowShouldAcceptEscapeKeyDown() -> Bool
}

#endif
