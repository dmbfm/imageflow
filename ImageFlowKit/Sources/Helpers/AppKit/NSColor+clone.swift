#if os(macOS)
import AppKit

extension NSColor {
    // swiftlint:disable force_cast
    public func clone() -> NSColor {
        self.copy() as! NSColor
    }
}
#endif
