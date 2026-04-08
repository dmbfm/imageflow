import Controls
import SwiftUI

extension NumberInputView {
    func inspectorNumberInput() -> some View {
        self
            .multilineTextAlignment(.trailing)
            .betterTextFieldBorderShapeStyle(.secondaryFill)
    }
}
