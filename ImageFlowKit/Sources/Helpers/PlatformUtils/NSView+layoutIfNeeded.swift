#if canImport(AppKit)
import AppKit

extension NSView {
    public func layoutIfNeeded() {
        self.layoutSubtreeIfNeeded()
    }
}

#endif
