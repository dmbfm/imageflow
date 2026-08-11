#if os(macOS)
import Backend
import AppKit

public class NSMenuItemForNode: NSMenuItem {
    public var node: UUID

    public init(
        node: UUID,
        title: String,
        systemSymbolName: String?,
        accessibilityDescription: String? = nil,
        action selector: Selector?,
        keyEquivalent charCode: String,
        keyEquivatletModifierMask mask: NSEvent.ModifierFlags? = nil
    ) {
        self.node = node

        super.init(title: title, action: selector, keyEquivalent: charCode)

        if let mask {
            self.keyEquivalentModifierMask = mask
        }

        if let systemSymbolName {
            self.image = .init(systemSymbolName: systemSymbolName, accessibilityDescription: accessibilityDescription)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@objc
public protocol ImageFlowResponding {
    func duplicate(_: Any?)
    func rename(_: Any?)
    func openNodeDocumentation(_: Any?)
}

#endif
