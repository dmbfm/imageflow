import SwiftUI

extension View {
    public func randomColorDebugBorder(_ width: CGFloat = 1) -> some View {
        self
            .border(Color.random(), width: width)
    }
}
