#if os(macOS)
import AppKit
#endif

#if os(iOS)
import UIKit
#endif

public struct XMouseButton: OptionSet, Sendable, Equatable {
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public let rawValue: Int

    #if os(macOS)
    public static let primary = XMouseButton(rawValue: 1 << 0)
    public static let secondary = XMouseButton(rawValue: 1 << 1)
    public static let other = XMouseButton(rawValue: 1 << 2)
    #endif

    #if os(iOS)
    public static let primary = XMouseButton(rawValue: UIEvent.ButtonMask.primary.rawValue)
    public static let secondary = XMouseButton(rawValue: UIEvent.ButtonMask.secondary.rawValue)
    public static let other = XMouseButton(rawValue: UIEvent.ButtonMask.secondary.union(.primary).rawValue)

    public var uiEventButtonMask: UIEvent.ButtonMask {
        .init(rawValue: self.rawValue)
    }
    #endif
}

public struct XModifierFlags: OptionSet, Sendable, Equatable {
    public let rawValue: UInt

    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

    #if os(macOS)
    public static let command = XModifierFlags(rawValue: NSEvent.ModifierFlags.command.rawValue)
    public static let option = XModifierFlags(rawValue: NSEvent.ModifierFlags.option.rawValue)
    public static let shift = XModifierFlags(rawValue: NSEvent.ModifierFlags.shift.rawValue)
    public static let control = XModifierFlags(rawValue: NSEvent.ModifierFlags.control.rawValue)

    public var nsEventModifierFlags: NSEvent.ModifierFlags {
        .init(rawValue: self.rawValue)
    }
    #endif

    #if os(iOS)
    public static let command = XMouseButton(rawValue: UIKeyModifierFlags.command.rawValue)
    public static let option = XMouseButton(rawValue: UIKeyModifierFlags.alternate.rawValue)
    public static let shift = XMouseButton(rawValue: UIKeyModifierFlags.shift.rawValue)
    public static let control = XMouseButton(rawValue: UIKeyModifierFlags.control.rawValue)

    public var uiKeyModifierFlags: UIKeyModifierFlags {
        UIKeyModifierFlags(rawValue: Int(self.rawValue))
    }
    #endif
}
