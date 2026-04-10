#if os(iOS)
import UIKit
import SwiftUI

public struct DynamicColor: Sendable, Equatable, Hashable {

    private var uiColor: UIColor

    public var platformColor: UIColor {
        self.uiColor
    }

    public var color: Color {
        .init(uiColor: self.uiColor)
    }

    public var cgColor: CGColor {
        self.uiColor.cgColor
    }

    public init(_ uiColor: UIColor) {
        self.uiColor = uiColor
    }

    public init(light: UIColor, dark: UIColor) {
        self.uiColor = .init(dynamicProvider: { traits in
            switch traits.userInterfaceStyle {
            case .dark:
                dark
            case .light, .unspecified:
                light
            @unknown default:
                light
            }
        })
    }

    public init(lightColor: ColorDesc, darkColor: ColorDesc) {
        self.init(light: .init(colorDesc: lightColor), dark: .init(colorDesc: darkColor))
    }
}

#else
import AppKit
import SwiftUI

public struct DynamicColor: Sendable, Equatable, Hashable {
    private var nsColor: NSColor

    public var platformColor: NSColor {
        self.nsColor
    }

    public var cgColor: CGColor {
        self.nsColor.cgColor
    }

    public var color: Color {
        .init(nsColor: self.nsColor)
    }

    public init(_ nsColor: NSColor) {
        self.nsColor = nsColor
    }

    public init(light: NSColor, dark: NSColor) {
        self.nsColor = .init(
            name: nil,
            dynamicProvider: { appearance in
                switch appearance.name {
                case .darkAqua, .vibrantDark:
                    dark
                default:
                    light
                }
            }
        )
    }

    public init(lightColor: ColorDesc, darkColor: ColorDesc) {
        self.init(light: .init(colorDesc: lightColor), dark: .init(colorDesc: darkColor))
    }
}
#endif

extension DynamicColor {
    public enum ColorDesc: Sendable, Equatable {
        case rbga(Rgba)
        case grayscale(Grayscale)
    }

    public struct Rgba: Sendable, Equatable {
        public var red: Double
        public var green: Double
        public var blue: Double
        public var alpha: Double

        public init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
            self.red = red
            self.green = green
            self.blue = blue
            self.alpha = alpha
        }
    }

    public struct Grayscale: Sendable, Equatable {
        public var white: CGFloat
        public var alpha: CGFloat
        public init(white: CGFloat, alpha: CGFloat = 1.0) {
            self.white = white
            self.alpha = alpha
        }
    }
}

#if os(macOS)
extension NSColor {
    convenience init(colorDesc: DynamicColor.ColorDesc) {
        switch colorDesc {
        case .rbga(let rgba):
            self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        case .grayscale(let value):
            self.init(white: value.white, alpha: value.alpha)
        }
    }
}
#endif

#if os(iOS)
extension UIColor {
    convenience init(colorDesc: DynamicColor.ColorDesc) {
        switch colorDesc {
        case .rbga(let rgba):
            self.init(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
        case .grayscale(let grayscale):
            self.init(white: grayscale.white, alpha: grayscale.alpha)
        }
    }
}
#endif
extension DynamicColor {
    public static let red: Self = .init(.red)
    public static let blue: Self = .init(.systemBlue)
    public static let orange: Self = .init(.systemOrange)
    public static let purple: Self = .init(.systemPurple)
}
