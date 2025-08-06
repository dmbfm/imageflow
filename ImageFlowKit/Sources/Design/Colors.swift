import ColorUtils

public enum Colors {
    public static let cardBackground: DynamicColor = .init(
        light: ImageFlowPalette.cardBackgroundLight,
        dark: ImageFlowPalette.cardBackgroundDark
    )

    public static let canvasBackground: DynamicColor = .init(
        light: ImageFlowPalette.canvasBackgroundLight,
        dark: ImageFlowPalette.canvasBackgroundDark
    )

    public static let canvasBackgroundDot: DynamicColor = .init(
        light: ImageFlowPalette.canvasBackgroundDotLight,
        dark: ImageFlowPalette.canvasBackgroundDotDark
    )

    public static let cardPurple: DynamicColor = .init(ImageFlowPalette.cardPurple)

    public static let cardBlue: DynamicColor = .init(ImageFlowPalette.cardBlue)

    public static let portEmpty: DynamicColor = .init(
        light: ImageFlowPalette.portEmptyLight,
        dark: ImageFlowPalette.portEmptyDark
    )

    public static let portConnected: DynamicColor = .init(
        light: ImageFlowPalette.portConnectedLight,
        dark: ImageFlowPalette.portConnectedDark
    )

    public static let numberInputBackground: DynamicColor = .init(
        light: ImageFlowPalette.numberInputBackgroundLight,
        dark: ImageFlowPalette.numberInputBackgroundDark
    )

    public static let numberInputBorder: DynamicColor = .init(
        light: ImageFlowPalette.numberInputBorderLight,
        dark: ImageFlowPalette.numberInputBorderDark
    )

    public static let coverView: DynamicColor = .init(
        light: ImageFlowPalette.coverViewLight,
        dark: ImageFlowPalette.coverViewDark
    )

    public static let edgeWithError: DynamicColor = .init(ImageFlowPalette.edgeWithError)

    public static let edgeWithSuccess: DynamicColor = .init(ImageFlowPalette.edgeWithSuccess)

    public static let imagePreviewBackground: DynamicColor = .init(ImageFlowPalette.imagePreviewBackground)
}

#if os(macOS)
import AppKit
/// Image Flow Palette
/// Created with ColorSlurp
class ImageFlowPalette {

    /// Card Background Light #ffffff
    static var cardBackgroundLight: NSColor {
        return NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    /// Card Background Dark #252525
    static var cardBackgroundDark: NSColor {
        return NSColor(red: 0.145, green: 0.145, blue: 0.145, alpha: 1.0)
    }

    /// Canvas Background Light #e8e8e7
    static var canvasBackgroundLight: NSColor {
        return NSColor(red: 0.91, green: 0.91, blue: 0.906, alpha: 1.0)
    }

    /// Canvas Background Dot Light #d4d4d4
    static var canvasBackgroundDotLight: NSColor {
        return NSColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1.0)
    }

    /// Canvas Background Dark #1b1c1c
    static var canvasBackgroundDark: NSColor {
        return NSColor(red: 0.106, green: 0.11, blue: 0.11, alpha: 1.0)
    }

    /// Canvas Background Dot Dark #292929
    static var canvasBackgroundDotDark: NSColor {
        return NSColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1.0)
    }

    /// Card Purple #af52de
    static var cardPurple: NSColor {
        return NSColor(red: 0.686, green: 0.323, blue: 0.87, alpha: 1.0)
    }

    /// Card Blue #007aff
    static var cardBlue: NSColor {
        return NSColor(red: 0.0, green: 0.478, blue: 0.999, alpha: 1.0)
    }

    /// Port Empty Light #eeeeef
    static var portEmptyLight: NSColor {
        return NSColor(red: 0.935, green: 0.935, blue: 0.939, alpha: 1.0)
    }

    /// Port Connected Light #8e8e93
    static var portConnectedLight: NSColor {
        return NSColor(red: 0.558, green: 0.557, blue: 0.577, alpha: 1.0)
    }

    /// Port Empty Dark #383839
    static var portEmptyDark: NSColor {
        return NSColor(red: 0.219, green: 0.219, blue: 0.224, alpha: 1.0)
    }

    /// Port Connected Dark #98989d
    static var portConnectedDark: NSColor {
        return NSColor(red: 0.596, green: 0.595, blue: 0.615, alpha: 1.0)
    }

    /// Number Input Background Light #e0e0e0
    static var numberInputBackgroundLight: NSColor {
        return NSColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
    }

    /// Number Input Background Dark #383838
    static var numberInputBackgroundDark: NSColor {
        return NSColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
    }

    /// Number Input Border Light #cccccc
    static var numberInputBorderLight: NSColor {
        return NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }

    /// Number Input Border Dark #575757
    static var numberInputBorderDark: NSColor {
        return NSColor(red: 0.341, green: 0.341, blue: 0.341, alpha: 1.0)
    }

    /// Cover View Light #ffffff
    static var coverViewLight: NSColor {
        return NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    /// Cover View Dark #000000
    static var coverViewDark: NSColor {
        return NSColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    /// Edge With Error #ff7878
    static var edgeWithError: NSColor {
        return NSColor(red: 1.0, green: 0.472, blue: 0.472, alpha: 1.0)
    }

    /// Edge With Success #78bfff
    static var edgeWithSuccess: NSColor {
        return NSColor(red: 0.472, green: 0.749, blue: 1.0, alpha: 1.0)
    }

    /// Image Preview Background #969696
    static var imagePreviewBackground: NSColor {
        return NSColor(red: 0.588, green: 0.588, blue: 0.588, alpha: 1.0)
    }

}
#else

import UIKit

/// Image Flow Palette
/// Created with ColorSlurp
class ImageFlowPalette {

    /// Card Background Light #ffffff
    static var cardBackgroundLight: UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }

    /// Card Background Dark #252525
    static var cardBackgroundDark: UIColor {
        return UIColor(red: 0.145, green: 0.145, blue: 0.145, alpha: 1.0)
    }

    /// Canvas Background Light #e8e8e7
    static var canvasBackgroundLight: UIColor {
        return UIColor(red: 0.91, green: 0.91, blue: 0.906, alpha: 1.0)
    }

    /// Canvas Background Dot Light #d4d4d4
    static var canvasBackgroundDotLight: UIColor {
        return UIColor(red: 0.831, green: 0.831, blue: 0.831, alpha: 1.0)
    }

    /// Canvas Background Dark #1b1c1c
    static var canvasBackgroundDark: UIColor {
        return UIColor(red: 0.106, green: 0.11, blue: 0.11, alpha: 1.0)
    }

    /// Canvas Background Dot Dark #292929
    static var canvasBackgroundDotDark: UIColor {
        return UIColor(red: 0.16, green: 0.16, blue: 0.16, alpha: 1.0)
    }

    /// Card Purple #af52de
    static var cardPurple: UIColor {
        return UIColor(red: 0.686, green: 0.323, blue: 0.87, alpha: 1.0)
    }

    /// Card Blue #007aff
    static var cardBlue: UIColor {
        return UIColor(red: 0.0, green: 0.478, blue: 0.999, alpha: 1.0)
    }

    /// Port Empty Light #eeeeef
    static var portEmptyLight: UIColor {
        return UIColor(red: 0.935, green: 0.935, blue: 0.939, alpha: 1.0)
    }

    /// Port Connected Light #8e8e93
    static var portConnectedLight: UIColor {
        return UIColor(red: 0.558, green: 0.557, blue: 0.577, alpha: 1.0)
    }

    /// Port Empty Dark #383839
    static var portEmptyDark: UIColor {
        return UIColor(red: 0.219, green: 0.219, blue: 0.224, alpha: 1.0)
    }

    /// Port Connected Dark #98989d
    static var portConnectedDark: UIColor {
        return UIColor(red: 0.596, green: 0.595, blue: 0.615, alpha: 1.0)
    }

    /// Number Input Background Light #e0e0e0
    static var numberInputBackgroundLight: UIColor {
        return UIColor(red: 0.878, green: 0.878, blue: 0.878, alpha: 1.0)
    }

    /// Number Input Background Dark #383838
    static var numberInputBackgroundDark: UIColor {
        return UIColor(red: 0.22, green: 0.22, blue: 0.22, alpha: 1.0)
    }

    /// Number Input Border Light #cccccc
    static var numberInputBorderLight: UIColor {
        return UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }

    /// Number Input Border Dark #575757
    static var numberInputBorderDark: UIColor {
        return UIColor(red: 0.341, green: 0.341, blue: 0.341, alpha: 1.0)
    }

    /// Cover View Light #ffffff
    static var coverViewLight: UIColor {
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
    }

    /// Cover View Dark #000000
    static var coverViewDark: UIColor {
        return UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
    }

    /// Edge With Error #ff7878
    static var edgeWithError: UIColor {
        return UIColor(red: 1.0, green: 0.472, blue: 0.472, alpha: 1.0)
    }

    /// Edge With Success #78bfff
    static var edgeWithSuccess: UIColor {
        return UIColor(red: 0.472, green: 0.749, blue: 1.0, alpha: 1.0)
    }

    /// Image Preview Background #969696
    static var imagePreviewBackground: UIColor {
        return UIColor(red: 0.588, green: 0.588, blue: 0.588, alpha: 1.0)
    }

}

#endif
