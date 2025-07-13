import SwiftUI

public extension View {
    /// Apply a modifier to the view only if a condition is met.
    /// - Parameters:
    ///   - condition: The condition to be met.
    ///   - modifier: The modifier to apply.
    @ViewBuilder
    func `if`<Content: View>(
        _ condition: Bool,
        then modifier: (Self) -> Content
    ) -> some View {
        if condition {
            modifier(self)
        } else {
            self
        }
    }
}
