import SwiftUI

extension SwiftUI::EdgeInsets {
    public init(value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

    public init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}
