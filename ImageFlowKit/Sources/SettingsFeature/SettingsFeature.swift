import SwiftUI

public enum PreferredColorScheme: Int, Codable {
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
}

public extension String {
    static let settingsColorSchemeKey = "preferredColorScheme"
}

public struct SettingsFeatureView: View {

    @AppStorage(.settingsColorSchemeKey) public var preferredColorScheme: PreferredColorScheme = .system

    public init() {
    }

    public var body: some View {
        VStack {
            Form {
                Picker("Appearance", selection: self.$preferredColorScheme) {
                    Text("System").tag(PreferredColorScheme.system)
                    Text("Light").tag(PreferredColorScheme.light)
                    Text("Dark").tag(PreferredColorScheme.dark)
                }
                .pickerStyle(.segmented)
            }
            .formStyle(.columns)

        }
        .frame(maxWidth: 400)
        .padding()
    }
}
