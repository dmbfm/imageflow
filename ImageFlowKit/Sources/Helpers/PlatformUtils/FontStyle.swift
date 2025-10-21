import Foundation

public enum FontStyle: Sendable, Hashable {
    case systemFont(size: CGFloat, weight: Weight?)
    case systemMonoFont(size: CGFloat, weight: Weight?)

    public enum Weight: Sendable, Hashable {
        case ultraLight
        case thin
        case light
        case regular
        case medium
        case semibold
        case bold
        case heavy
        case black
    }
}

#if canImport(AppKit)
import AppKit

extension FontStyle.Weight {
    public var platform: NSFont.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}

extension FontStyle {
    public var font: NSFont {
        switch self {
        case let .systemFont(size: size, weight: weight):
            .systemFont(ofSize: size, weight: (weight ?? .regular).platform)
        case let .systemMonoFont(size: size, weight: weight):
            .systemFont(ofSize: size, weight: (weight ?? .regular).platform)
        }
    }
}
#endif

#if canImport(UIKit)
import UIKit

extension FontStyle.Weight {
    public var platform: UIFont.Weight {
        switch self {
        case .ultraLight: .ultraLight
        case .thin: .thin
        case .light: .light
        case .regular: .regular
        case .medium: .medium
        case .semibold: .semibold
        case .bold: .bold
        case .heavy: .heavy
        case .black: .black
        }
    }
}

extension FontStyle {
    public var font: UIFont {
        switch self {
        case let .systemFont(size: size, weight: weight):
            .systemFont(ofSize: size, weight: (weight ?? .regular).platform)
        case let .systemMonoFont(size: size, weight: weight):
            .systemFont(ofSize: size, weight: (weight ?? .regular).platform)
        }
    }
}

#endif
