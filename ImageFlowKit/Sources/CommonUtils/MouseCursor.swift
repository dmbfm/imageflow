#if canImport(AppKit)
import AppKit
#endif

public class MouseCursor {

    public enum Name {
        case `default`
        case dragLink

        #if os(macOS)
        var cursor: NSCursor {
            switch self {
            case .default: .arrow
            case .dragLink: .dragLink
            }
        }
        #endif
    }

    public static func push(_ name: Name) {
        #if os(macOS)
        if NSCursor.current != name.cursor {
            name.cursor.push()
        }
        #endif
    }

    public static func pop(_ name: Name?) {
        #if os(macOS)
        if let name {
            if NSCursor.current == name.cursor {
                NSCursor.pop()
            }
        } else {
            NSCursor.pop()
        }
        #endif
    }
}
