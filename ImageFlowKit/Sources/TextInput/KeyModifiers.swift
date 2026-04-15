#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

public struct KeyModifiers: Sendable, OptionSet {
    public var rawValue: Int

    public static let shift: Self = .init(rawValue: 1 << 0)
    public static let option: Self = .init(rawValue: 1 << 1)
    public static let command: Self = .init(rawValue: 1 << 2)
    public static let control: Self = .init(rawValue: 1 << 3)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    #if os(macOS)
    public init(flags: NSEvent.ModifierFlags) {
        self = []
        if flags.contains(.shift) {
            self.insert(.shift)
        }

        if flags.contains(.option) {
            self.insert(.option)
        }

        if flags.contains(.command) {
            self.insert(.command)
        }

        if flags.contains(.control) {
            self.insert(.control)
        }
    }
    #endif

    #if os(iOS)
    public init(flags: UIKeyModifierFlags) {
        self = []
        if flags.contains(.shift) {
            self.insert(.shift)
        }

        if flags.contains(.alternate) {
            self.insert(.option)
        }

        if flags.contains(.command) {
            self.insert(.command)
        }

        if flags.contains(.control) {
            self.insert(.control)
        }
    }
    #endif
}
