import SwiftUI

#if os(iOS)
import GameController
#endif

extension CanvasFeatureViewModel {
    public func statusBarShow(_ text: String) {
        if self.hasKeyboard {
            if !self.statusBarState.visible {
                withAnimation(.easeInOut(duration: 0.2)) {
                    self.statusBarState.text = text
                    self.statusBarState.visible = true
                }
            } else if self.statusBarState.text != text {
                self.statusBarState.text = text
            }
        }
    }

    public func statusBarHide() {
        if self.statusBarState.visible {
            withAnimation(.easeInOut(duration: 0.2)) {
                self.statusBarState.visible = false
            }
        }
    }

    private var hasKeyboard: Bool {
        #if os(iOS)
        GCKeyboard.coalesced != nil
        #else
        true
        #endif
    }
}
