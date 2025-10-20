#if os(macOS)
import AppKit

extension NSTextField {
    public var text: String {
        get {
            self.stringValue
        }

        set {
            self.stringValue = newValue
        }
    }
}

#endif
