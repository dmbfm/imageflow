import SwiftUI

extension CanvasFeatureViewModel {
    public func statusBarShow(_ text: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.statusBarState.visible = true
            self.statusBarState.text = text
        }
    }

    public func statusBarHide() {
        withAnimation(.easeInOut(duration: 0.2)) {
            self.statusBarState.visible = false
        }
    }
}
