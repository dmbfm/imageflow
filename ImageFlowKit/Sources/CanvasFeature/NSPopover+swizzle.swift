#if os(macOS)

import AppKit

extension NSPopover {

    static var swizzled: Bool = false

    static func swizzle() {
        if !Self.swizzled {
            let mold = class_getInstanceMethod(NSPopover.self, #selector(getter: NSPopover.animates))
            let mnew = class_getInstanceMethod(NSPopover.self, #selector(getter: NSPopover._animates))

            method_exchangeImplementations(mold!, mnew!)

            Self.swizzled = true
        }
    }

    @objc
    var _animates: Bool {
        false
    }
}

#endif
