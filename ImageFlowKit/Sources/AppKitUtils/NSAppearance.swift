import AppKit

public extension NSAppearance {
    var isDarkMode: Bool {
        switch self.name {
        case .aqua, .vibrantLight, .accessibilityHighContrastAqua, .accessibilityHighContrastVibrantLight:
            return false
        case .darkAqua, .vibrantDark, .accessibilityHighContrastDarkAqua, .accessibilityHighContrastVibrantDark:
            return true
        default:
            preconditionFailure("Unknown appearance")
        }
    }
}
