#if os(iOS)
import UIKit
import SwiftUI

public struct PlatformColor: Sendable {

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
}

#else
import AppKit
import SwiftUI

public struct PlatformColor: Sendable {
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
}
#endif
