import CardStage

#if canImport(AppKit)
import AppKit
#endif

class PreviewContextMenuItem: NSMenuItem {

    var itemType: ItemType

    enum ItemType {
        case anchor(CardStageAnchor)
        case dock(CardDockLocation)
        case openWindow
        case copy
        case export

        var title: String {
            switch self {
            case .anchor(.bottomLeft): "Bottom Left"
            case .anchor(.bottomRight): "Bottom Right"
            case .anchor(.topLeft): "Top Left"
            case .anchor(.topRight): "Top Right"
            case .dock(.bottom): "Dock to Bottom"
            case .dock(.top): "Dock to Top"
            case .openWindow: "Open Preview Window"
            case .copy: "Copy to Clipboard"
            case .export: "Export Image"
            }
        }
    }

    init(
        _ type: ItemType,
        action selector: Selector?,
        target: AnyObject?,
        image: String? = nil,
        checked: Bool = false,
        enabled: Bool = true
    ) {
        self.itemType = type
        super.init(title: type.title, action: selector, keyEquivalent: "")
        self.target = target
        self.state = checked ? .on : .off
        self.isEnabled = enabled
        if let name = image {
            self.image = .init(systemSymbolName: name, accessibilityDescription: nil)
        }
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
