import SharedModels

#if canImport(AppKit)
import AppKit

extension WindowID {
    var identifier: NSUserInterfaceItemIdentifier {
        .init(self.rawValue)
    }
}
#endif
