public enum StatusBarMessage: String {
    case dragFloat = "⇧ Slower     ⌥ Faster"
    case dragFloatRange = "⇧ Slower"
    case dragFloatSnap = "⇧ Slower     ⌥ Faster     ⌘ Snap"
}

public struct StatusBarMessageBuilder {

    public enum Key: String, Sendable {
        case shift = "⇧"
        case command = "⌘"
        case option = "⌥"
        case rightMouseButton = "RMB "
        // case rightMouseButton = "RMB􀺣 "
    }

    public struct Item: Sendable {
        public var key: Key
        public var label: String

        public static let dragSlower: Self = .init(.shift, label: "Slower")
        public static let dragFaster: Self = .init(.option, label: "Faster")
        public static let dragSnap: Self = .init(.command, label: "Snap")
        public static let cancel: Self = .init(.rightMouseButton, label: "Cancel")

        public static let empty: Self = .init(.shift, label: "")

        public var text: String {
            "\(self.key.rawValue) \(self.label)"
        }

        public init(_ key: Key, label: String) {
            self.key = key
            self.label = label
        }
    }

    public static var standardNumberDrag: String {
        Self.build([
            .dragSlower,
            .dragFaster,
            .cancel,
        ])
    }

    public static func build(_ items: [Item], spacing: Int = 4) -> String {
        let spacer = String(repeating: "  ", count: 3)
        return items.reduce(
            "",
            { acc, item in
                if !item.label.isEmpty {
                    acc + item.text + spacer
                } else {
                    acc
                }
            }
        ).trimmingSuffix(spacer)
    }
}

public extension String {
    static var statusMessageNumberDrag: String {
        StatusBarMessageBuilder.build([
            .dragSlower,
            .dragFaster,
            .cancel,
        ])
    }
    static var statusMessageNumberRangeDrag: String {
        StatusBarMessageBuilder.build([
            .dragSlower,
            .cancel,
        ])
    }
    static var statusMessageNumberSnapDrag: String {
        StatusBarMessageBuilder.build([
            .dragSlower,
            .dragSnap,
            .cancel,
        ])
    }
}
