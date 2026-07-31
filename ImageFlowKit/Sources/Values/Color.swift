@preconcurrency import CoreImage
import Foundation

public struct Color4: Sendable, Hashable, Codable {
    public var red: Double
    public var green: Double
    public var blue: Double
    public var alpha: Double

    public static let white: Self = .init(red: 1, green: 1, blue: 1, alpha: 1)
    public static let red: Self = .init(red: 1, green: 0, blue: 0, alpha: 1)
    public static let black: Self = .init(red: 0, green: 0, blue: 0, alpha: 1)
    public static let clear: Self = .init(red: 0, green: 0, blue: 0, alpha: 0)

    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    public static func + (lhs: Color4, rhs: Color4) -> Color4 {
        Color4(
            red: lhs.red + rhs.red,
            green: lhs.green + rhs.green,
            blue: lhs.blue + rhs.blue,
            alpha: lhs.alpha + rhs.alpha
        )
    }

    public static func - (lhs: Color4, rhs: Color4) -> Color4 {
        Color4(
            red: lhs.red - rhs.red,
            green: lhs.green - rhs.green,
            blue: lhs.blue - rhs.blue,
            alpha: lhs.alpha - rhs.alpha
        )
    }

    public static func * (lhs: Color4, rhs: Color4) -> Color4 {
        Color4(
            red: lhs.red * rhs.red,
            green: lhs.green * rhs.green,
            blue: lhs.blue * rhs.blue,
            alpha: lhs.alpha * rhs.alpha
        )
    }

    public static func / (lhs: Color4, rhs: Color4) -> Color4 {
        Color4(
            red: lhs.red / rhs.red,
            green: lhs.green / rhs.green,
            blue: lhs.blue / rhs.blue,
            alpha: lhs.alpha / rhs.alpha
        )
    }

    public var ciColor: CIColor {
        .init(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}

#if canImport(UIKit)
import UIKit
extension Color4 {
    public init?(uiColor: UIColor) {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        if uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            self.init(red: red, green: green, blue: blue, alpha: alpha)
        } else {
            return nil
        }
    }
    public var uiColor: UIColor {
        .init(red: self.red, green: self.green, blue: self.blue, alpha: self.alpha)
    }
}
#endif

#if canImport(AppKit)

import AppKit
import SwiftUI

extension Color4 {
    public init?(nsColor: NSColor) {
        guard let converted = nsColor.usingColorSpace(.sRGB) else {
            return nil
        }

        self.init(
            red: converted.redComponent,
            green: converted.greenComponent,
            blue: converted.blueComponent,
            alpha: converted.alphaComponent
        )
    }

    public var nsColor: NSColor {
        return NSColor(
            red: CGFloat(self.red),
            green: CGFloat(self.green),
            blue: CGFloat(self.blue),
            alpha: CGFloat(self.alpha)
        )
    }

    public var color: Color {
        return Color(red: self.red, green: self.green, blue: self.blue, opacity: self.alpha)
    }

    public init?(color: Color) {
        let nsColor = NSColor(color)
        self.init(
            red: nsColor.redComponent,
            green: nsColor.greenComponent,
            blue: nsColor.blueComponent,
            alpha: nsColor.alphaComponent
        )
    }

    public mutating func set(color: Color) {
        let nsColor = NSColor(color)
        self.red = nsColor.redComponent
        self.green = nsColor.greenComponent
        self.blue = nsColor.blueComponent
        self.alpha = nsColor.alphaComponent
    }
}

extension Binding<Color4?> {
    public var colorBinding: Binding<Color> {
        Binding<Color>(
            get: { self.wrappedValue?.color ?? .clear },
            set: { newValue in
                if let color = Color4(color: newValue) {
                    self.wrappedValue = color
                } else {
                    self.wrappedValue = nil
                }
            }
        )
    }
}

#endif
