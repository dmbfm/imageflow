#if os(macOS)
import AppKit

public typealias XTextField = NSTextField

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

#if os(iOS)
import UIKit
public typealias XTextField = UITextField
#endif
