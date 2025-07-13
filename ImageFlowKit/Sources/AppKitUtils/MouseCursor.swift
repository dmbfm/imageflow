import AppKit

public class MouseCursor {
    public static func push(_ cursor: NSCursor) {
        if NSCursor.current != cursor {
            cursor.push()
        }
    }

    public static func pop(_ cursor: NSCursor?) {
        if let cursor {
            if NSCursor.current == cursor {
                NSCursor.pop()
            }
        } else {
            NSCursor.pop()
        }
    }
}
