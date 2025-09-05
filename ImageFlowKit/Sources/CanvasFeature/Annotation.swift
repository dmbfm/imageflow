import CommonUtils
import Foundation
import PlatformUtils

struct Annotation: Equatable {
    public var title: String
    public var message: String
    public var maxWidth: CGFloat
    public var style: AnnotationStyle = .default
}

struct AnnotationStyle: Equatable, With {
    public var background: Background
    public var titleColor: PlatformColor
    public var messageColor: PlatformColor
    public var cornerRadius: CGFloat = 10.0

    public enum Background: Equatable {
        case material
        case color(PlatformColor)
    }

    static var `default`: Self {
        .init(background: .material, titleColor: .init(white: 0, alpha: 0.8), messageColor: .init(white: 0, alpha: 0.6))
    }

    static var error: Self {
        .init(background: .color(.systemRed), titleColor: .white, messageColor: .white)
    }
}
