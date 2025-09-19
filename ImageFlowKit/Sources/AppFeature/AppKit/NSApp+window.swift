#if canImport(AppKit)

import AppKit

extension NSApplication {
    func findWindow(_ id: String) -> NSWindow? {
        self.windows.first { $0.identifier?.rawValue == id }
    }

    @discardableResult
    func closeWindow(_ id: String) -> Bool {
        if let window = self.findWindow(id) {
            window.close()
            return true
        }

        return false
    }

    @discardableResult
    func closeWindow(_ id: WindowID) -> Bool {
        self.closeWindow(id.rawValue)
    }

}

#endif
