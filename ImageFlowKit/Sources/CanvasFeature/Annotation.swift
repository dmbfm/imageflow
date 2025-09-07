import CommonUtils
import Foundation
import PlatformUtils

struct Annotation: Equatable {
    public var title: String
    public var message: String
    public var maxWidth: CGFloat
    public var type: AnnotationType = .regular
}

public enum AnnotationType {
    case regular
    case error

    var style: AnnotationStyle {
        switch self {
        case .regular:
            return .default
        case .error:
            return .error
        }
    }
}

struct AnnotationStyle: Equatable, With {
    public var backgroundStyle: BackgroundStyle
    public var backgroundColor: PlatformColor? = nil
    public var titleColor: PlatformColor
    public var messageColor: PlatformColor
    public var cornerRadius: CGFloat = 10.0

    public enum BackgroundStyle: Equatable {
        case material
        case color
    }

    static var `default`: Self {
        #if os(macOS)
        .init(
            backgroundStyle: .material,
            titleColor:  .labelColor, 
            messageColor: .secondaryLabelColor,
            cornerRadius: 10.0
        )
        #else
        if #available(iOS 26, *) {
            .init(
                backgroundStyle: .material,
                titleColor: .label,
                messageColor: .secondaryLabel,
                cornerRadius: 18.0
            )
        } else {
            .init(
                backgroundStyle: .material,
                titleColor: .label,
                messageColor: .secondaryLabel,
                cornerRadius: 10.0
            )
        }
        #endif
    }

    static var error: Self {
        #if os(macOS)
        .init(
            backgroundStyle: .color,
            backgroundColor: .red,
            titleColor: .white,
            messageColor: .white,
            cornerRadius: 10.0
        )
        #else
        if #available(iOS 26, *) {
            .init(
                backgroundStyle: .material,
                backgroundColor: .red,
                titleColor: .white,
                messageColor: .white,
                cornerRadius: 18.0
            )
        } else {
            .init(
                backgroundStyle: .color,
                backgroundColor: .red,
                titleColor: .white,
                messageColor: .white,
                cornerRadius: 10.0
            )
        }
        #endif
    }
}
