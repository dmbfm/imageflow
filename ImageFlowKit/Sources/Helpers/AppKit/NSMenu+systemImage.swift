#if os(macOS)
import AppKit

extension NSMenuItem {
    public convenience init(
        title: String,
        action: Selector?,
        keyEquivalent: String,
        systemSymbolName: String,
        accessibilityDescription: String?
    ) {
        self.init(title: title, action: action, keyEquivalent: keyEquivalent)
        self.image = .init(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
    }
}

extension NSMenu {
    public func addItem(
        withTitle title: String,
        action: Selector?,
        keyEquivalent: String,
        systemSymbolName: String,
        accessibilityDescription: String?
    ) {
        self.addItem(
            .init(
                title: title,
                action: action,
                keyEquivalent: keyEquivalent,
                systemSymbolName: systemSymbolName,
                accessibilityDescription: accessibilityDescription
            )
        )
    }
}

#endif
