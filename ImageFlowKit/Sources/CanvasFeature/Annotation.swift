import Foundation
import Helpers
import SharedModels

public struct Annotation: Equatable {
    public var title: String
    public var message: String
    public var maxWidth: CGFloat
    public var type: AnnotationType = .regular

    public init(title: String, message: String, maxWidth: CGFloat, type: AnnotationType = .regular) {
        self.title = title
        self.message = message
        self.maxWidth = maxWidth
        self.type = type
    }

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
            titleColor: .labelColor,
            messageColor: .secondaryLabelColor,
            cornerRadius: 10.0
        )
        #else
        .init(
            backgroundStyle: .material,
            titleColor: .label,
            messageColor: .secondaryLabel,
            cornerRadius: 18.0
        )
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
        .init(
            backgroundStyle: .material,
            backgroundColor: .red,
            titleColor: .white,
            messageColor: .white,
            cornerRadius: 18.0
        )
        #endif
    }
}

extension Flow.CanCreateEdgeError {
    var annotation: Annotation? {
        switch self {
        case .graphCycle:
            .init(
                title: "Graph Cycle",
                message: "Creating this edge would introduce a cycle in the node graph.",
                maxWidth: 200,
            )
        case .destPortAlreadyConnected:
            nil
        case .invalidPort:
            .init(
                title: "Invalid port",
                message: "The port you are trying to connect does not exist.",
                maxWidth: 200,
            )
        case .typeError(.cantFix(from: let a, to: let b)):
            .init(
                title: "Type error",
                message: "Con't connect a '\(a.displayName)' port to a '\(b.displayName)' port.",
                maxWidth: 200,
            )
        case .typeError(_):
            nil
        case .edge(.sameNode):
            nil
        case .edge(.bothInput):
            .init(
                title: "Invalid Port",
                message: "Can't connect an input port to another input port.",
                maxWidth: 200,
            )
        case .edge(.bothOutput):
            .init(
                title: "Invalid Port",
                message: "Can't connect an output port to another output port.",
                maxWidth: 200,
            )
        }
    }
}
