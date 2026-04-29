#if os(macOS)
import AppKit

extension NSMenuItem {
    public convenience init(
        title: String,
        action: Selector?,
        target: AnyObject? = nil,
        keyEquivalent: String,
        keyEquivalentModifierMask: NSEvent.ModifierFlags? = nil,
        systemSymbolName: String?,
        accessibilityDescription: String?
    ) {
        self.init(title: title, action: action, keyEquivalent: keyEquivalent)
        if let systemSymbolName {
            self.image = .init(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
        }
        self.target = target
        if let keyEquivalentModifierMask {
            self.keyEquivalentModifierMask = keyEquivalentModifierMask
        }
    }
}

extension NSMenu {
    public func addItem(
        withTitle title: String,
        action: Selector?,
        target: AnyObject? = nil,
        keyEquivalent: String,
        systemSymbolName: String?,
        accessibilityDescription: String?
    ) {
        self.addItem(
            .init(
                title: title,
                action: action,
                target: target,
                keyEquivalent: keyEquivalent,
                systemSymbolName: systemSymbolName,
                accessibilityDescription: accessibilityDescription
            )
        )
    }
}

#endif
