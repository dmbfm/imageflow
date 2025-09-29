
#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

public struct HSL: Hashable, Sendable {
    public var hue: CGFloat
    public var saturation: CGFloat
    public var lightness: CGFloat
    public var alpha: CGFloat

    public var cgColor: CGColor {
        let t = self.saturation * (self.lightness < 0.5 ? self.lightness : 1 - self.lightness)
        let b = self.lightness + t
        let s = self.lightness > 0 ? 2 * t / b : 0

        #if canImport(UIKit)
        return UIColor(hue: self.hue, saturation: s, brightness: b, alpha: self.alpha).cgColor
        #else
        return NSColor(hue: self.hue, saturation: s, brightness: b, alpha: self.alpha).cgColor
        #endif
    }

    public init(hue: CGFloat, saturation: CGFloat, lightness: CGFloat, alpha: CGFloat) {
        self.hue = hue
        self.saturation = saturation
        self.lightness = lightness
        self.alpha = alpha
    }

    public init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        // Convert brightess to lightness
        let lightness = ((2.0 - saturation) * brightness) / 2.0

        switch lightness {
        case 0.0, 1.0:
            self.saturation = 0.0
        case 0.0..<0.5:
            self.saturation = (saturation * brightness) / (lightness * 2.0)
        default:
            self.saturation = (saturation * brightness) / (2.0 - lightness * 2.0)
        }

        self.hue = hue
        self.lightness = lightness
        self.saturation = saturation
        self.alpha = alpha
    }

    /// Interpolates the lightness chanell of this color with the target
    /// `lightness`. Useful to fade a color to black or white.
    /// - Parameters:
    ///   - lightness: The lightness value we want to interpolate to.
    ///   - t: The interpolation parameter in the [0, 1] range.
    /// - Returns: The interpolated color.
    public func lerp(lightness: CGFloat, t: CGFloat) -> HSL {
        let s = self.saturation  // * (1.0 - t) + other.saturation * t
        let l = self.lightness * (1.0 - t) + lightness * t

        return HSL(hue: self.hue, saturation: s, lightness: l, alpha: self.alpha)
    }

    public func lerp(to: HSL, channelMask: ChannelMask, t: CGFloat) -> HSL {
        let hue =
            if channelMask.contains(.hue) {
                self.hue.lerp(to: to.hue, t: t)
            } else {
                self.hue
            }

        let saturation =
            if channelMask.contains(.saturation) {
                self.saturation.lerp(to: to.saturation, t: t)
            } else {
                self.saturation
            }

        let lightness =
            if channelMask.contains(.lightness) {
                self.lightness.lerp(to: to.lightness, t: t)
            } else {
                self.lightness
            }

        return HSL(hue: hue, saturation: saturation, lightness: lightness, alpha: self.alpha)
    }

    public func gradientColors(to color: HSL, channelMask: ChannelMask, curve: EasingCurve, stops: Int) -> [HSL] {
        var colors = [HSL]()

        for t in stride(from: 0.0, through: 1.0, by: 1.0 / Double(stops)) {
            let t = curve.easeOut(t)
            colors.append(self.lerp(to: color, channelMask: channelMask, t: t))
        }

        return colors
    }

    public init?(cgColor: CGColor) {
        #if canImport(UIKit)
        self.init(uiColor: UIColor(cgColor: cgColor))
        #else
        if let nsColor = NSColor(cgColor: cgColor) {
            self.init(nsColor: nsColor)
        } else {
            return nil
        }
        #endif
    }

    #if canImport(AppKit)
    public init?(nsColor: NSColor) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        nsColor.usingColorSpace(.deviceRGB)?.getHue(
            &hue,
            saturation: &saturation,
            brightness: &brightness,
            alpha: &alpha
        )
        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    #endif

    #if canImport(UIKit)
    public init(uiColor: UIColor) {
        var hue: CGFloat = 0.0
        var saturation: CGFloat = 0.0
        var brightness: CGFloat = 0.0
        var alpha: CGFloat = 0.0

        uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        self.init(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    #endif
}

extension HSL {
    public struct ChannelMask: OptionSet, Sendable {
        public let rawValue: Int

        public init(rawValue: Int) {
            self.rawValue = rawValue
        }

        public static let hue = ChannelMask(rawValue: 1 << 0)
        public static let saturation = ChannelMask(rawValue: 1 << 1)
        public static let lightness = ChannelMask(rawValue: 1 << 2)
    }
}
