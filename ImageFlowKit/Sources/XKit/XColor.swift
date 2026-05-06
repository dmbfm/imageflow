#if canImport(AppKit)
import AppKit
public typealias XColor = NSColor

extension XColor {
    public convenience init(light: NSColor, dark: NSColor) {
        self.init(name: nil) { appearance in
            switch appearance.name {
            case .darkAqua, .vibrantDark: dark
            default: light
            }
        }
    }

    public static let system = System()

    public struct System: Sendable {
        public var label: XColor {
            .labelColor
        }

        public var secondaryLabel: XColor {
            .secondaryLabelColor
        }

        public var tertiaryLabel: XColor {
            .tertiaryLabelColor
        }

        public var quaternaryLabel: XColor {
            .quaternaryLabelColor
        }

        public var fill: XColor {
            .init(
                light: .init(red: 0.471, green: 0.471, blue: 0.502, alpha: 0.2),
                dark: .init(red: 0.471, green: 0.471, blue: 0.502, alpha: 0.36),
            )
        }

        public var secondaryFill: XColor {
            .init(
                light: .init(red: 0.471, green: 0.471, blue: 0.502, alpha: 0.16),
                dark: .init(red: 0.471, green: 0.471, blue: 0.502, alpha: 0.32),
            )
        }

        public var tertiaryFill: XColor {
            .init(
                light: .init(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.12),
                dark: .init(red: 0.463, green: 0.463, blue: 0.502, alpha: 0.24),
            )
        }

        public var quaternaryFill: XColor {
            .init(
                light: .init(red: 0.455, green: 0.455, blue: 0.502, alpha: 0.08),
                dark: .init(red: 0.455, green: 0.455, blue: 0.502, alpha: 0.18),
            )
        }

        public var background: XColor {
            .init(
                light: .init(white: 1.0, alpha: 1.0),
                dark: .init(white: 0.0, alpha: 1.0),
            )
        }

        public var secondaryBackground: XColor {
            .init(
                light: .init(red: 0.949, green: 0.949, blue: 0.969, alpha: 1),
                dark: .init(red: 0.11, green: 0.11, blue: 0.118, alpha: 1),
            )
        }

        public var tertiaryBackground: XColor {
            .init(
                light: .init(white: 1.0, alpha: 1.0),
                dark: .init(red: 0.173, green: 0.173, blue: 0.18, alpha: 1),
            )
        }

        public var groupedBackground: XColor {
            .init(
                light: .init(red: 0.949, green: 0.949, blue: 0.969, alpha: 1),
                dark: .init(white: 0, alpha: 1),
            )
        }

        public var secondaryGroupedBackground: XColor {
            .init(
                light: .init(white: 1, alpha: 0),
                dark: .init(red: 0.11, green: 0.11, blue: 0.118, alpha: 1),
            )
        }

        public var tertiaryGroupedBackground: XColor {
            .init(
                light: .init(red: 0.949, green: 0.949, blue: 0.969, alpha: 1),
                dark: .init(red: 0.173, green: 0.173, blue: 0.18, alpha: 1),
            )
        }
    }
}
#endif

#if canImport(UIKit)
import UIKit
public typealias XColor = UIColor

extension XColor {
    public convenience init(light: UIColor, dark: UIColor) {
        self.init(dynamicProvider: { tc in
            switch tc.userInterfaceStyle {
            case .dark:
                dark
            case .light, .unspecified:
                light
            @unknown default:
                light
            }
        })
    }

    public static let system: System = System()

    public struct System: Sendable {
        public var label: XColor { .label }
        public var secondaryLabel: XColor { .secondaryLabel }
        public var tertiaryLabel: XColor { .tertiaryLabel }
        public var quaternaryLabel: XColor { .quaternaryLabel }
        public var fill: XColor { .systemFill }
        public var secondaryFill: XColor { .secondarySystemFill }
        public var tertiaryFill: XColor { .tertiarySystemFill }
        public var quaternaryFill: XColor { .quaternarySystemFill }
        public var background: XColor { .systemBackground }
        public var secondaryBackground: XColor { .secondarySystemBackground }
        public var tertiaryBackground: XColor { .tertiarySystemBackground }
        public var groupedBackground: XColor { .systemGroupedBackground }
        public var secondaryGroupedBackground: XColor { .secondarySystemGroupedBackground }
        public var tertiaryGroupedBackground: XColor { .tertiarySystemGroupedBackground }
    }
}

#endif
