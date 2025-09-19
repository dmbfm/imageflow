import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

extension View {
    public var isShiftDown: Bool {
        #if os(macOS)
        NSEvent.modifierFlags.contains(.shift)
        #else
        false
        #endif
    }
}
