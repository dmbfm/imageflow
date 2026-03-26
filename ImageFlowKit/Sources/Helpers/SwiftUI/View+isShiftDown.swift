import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

extension View {
    public var isShiftDown: Bool {
        Self.isShiftDown
    }

    public var isControlDown: Bool {
        Self.isControlDown
    }

    public static var isShiftDown: Bool {
        #if os(macOS)
        NSEvent.modifierFlags.contains(.shift)
        #else
        false
        #endif
    }

    public static var isControlDown: Bool {
        #if os(macOS)
        NSEvent.modifierFlags.contains(.control)
        #else
        false
        #endif
    }
}
