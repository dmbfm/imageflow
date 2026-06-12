import XKit

public enum ComponentSize: Sendable, Equatable {
    case mini
    case small
    case regular
    case large
    case extraLarge
}

#if canImport(AppKit)
extension ComponentSize {
    var controlSize: NSControl.ControlSize {
        switch self {
        case .mini: .mini
        case .small: .small
        case .regular: .regular
        case .large: .large
        case .extraLarge: .extraLarge
        }
    }
}
#endif
