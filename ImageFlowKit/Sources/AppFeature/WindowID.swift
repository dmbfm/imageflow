enum WindowID: String {
    case welcome
    case document
}

#if canImport(AppKit)
import AppKit

extension WindowID {
    var identifier: NSUserInterfaceItemIdentifier {
        .init(self.rawValue)
    }
}
#endif
