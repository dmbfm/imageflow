import SwiftUI

public enum PreferredColorScheme: Int, Codable, CaseIterable {
    case light
    case dark
    case system

    public var value: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }

    public var displayName: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }
}

public extension String {
    static let settingsColorSchemeKey = "preferredColorScheme"
}
