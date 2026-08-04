import Foundation
import Helpers
import SharedModels

@MainActor
public class SettingsStore {

    @PublishedEx public var appearance: PreferredColorScheme {
        didSet {
            UserDefaults.standard.imageFlowAppearance = self.appearance
        }
    }

    @PublishedEx public var defaultPreviewLocation: DefaultPreviewLocation {
        didSet {
            UserDefaults.standard.imageFlowDefaultPreviewLocation = self.defaultPreviewLocation
        }
    }

    @PublishedEx public var numberDragSensitivity: Double {
        didSet {
            UserDefaults.standard.numberDragSensitivity = self.numberDragSensitivity
        }
    }

    @PublishedEx public var numberFormat: NumberFormat {
        didSet {
            UserDefaults.standard.numberFormat = self.numberFormat
        }
    }

    static let shared = SettingsStore()

    init() {
        let ud = UserDefaults.standard
        self.appearance = ud.imageFlowAppearance
        self.defaultPreviewLocation = ud.imageFlowDefaultPreviewLocation
        self.numberDragSensitivity = ud.numberDragSensitivity
        self.numberFormat = ud.numberFormat
    }
}

extension String {
    static let settingsKeyAppearance: String = "com.dmbfm.imageflow.settings.appearance"
    static let settingsKeyNumberFormat: String = "com.dmbfm.imageflow.settings.number-format"
    static let settingsKeyNumberDragSensitivity: String = "com.dmbfm.imageflow.settings.number-drag-sensitivity"
    static let settingsKeyDefaultPreviewLocation: String = "com.dmbfm.imageflow.settings.default-preview-location"
}

extension UserDefaults {

    func intValue(forKey key: String, defaultValue: Int) -> Int {
        if let value = self.value(forKey: key) as? Int {
            return value
        } else {
            self.set(defaultValue, forKey: key)
            return defaultValue
        }
    }

    func doubleValue(forKey key: String, defaultValue: Double) -> Double {
        if let value = self.value(forKey: key) as? Double {
            return value
        } else {
            self.set(defaultValue, forKey: key)
            return defaultValue
        }
    }

    var imageFlowAppearance: PreferredColorScheme {
        get {
            let v = self.intValue(forKey: .settingsKeyAppearance, defaultValue: PreferredColorScheme.system.rawValue)
            return .init(rawValue: v) ?? .system
        }
        set {
            self.set(newValue.rawValue, forKey: .settingsKeyAppearance)
        }
    }

    var numberFormat: NumberFormat {
        get {
            let v = self.intValue(forKey: .settingsKeyNumberFormat, defaultValue: NumberFormat.system.rawValue)
            return .init(rawValue: v) ?? .system
        }
        set {
            self.set(newValue.rawValue, forKey: .settingsKeyNumberFormat)
        }
    }

    var imageFlowDefaultPreviewLocation: DefaultPreviewLocation {
        get {
            let v = self.intValue(forKey: .settingsKeyDefaultPreviewLocation, defaultValue: DefaultPreviewLocation.br.rawValue)
            return .init(rawValue: v) ?? .br
        }
        set {
            self.set(newValue.rawValue, forKey: .settingsKeyDefaultPreviewLocation)
        }
    }

    var numberDragSensitivity: Double {
        get {
            self.doubleValue(forKey: .settingsKeyNumberDragSensitivity, defaultValue: 5.0)
        }
        set {
            self.set(newValue, forKey: .settingsKeyNumberDragSensitivity)
        }
    }
}
