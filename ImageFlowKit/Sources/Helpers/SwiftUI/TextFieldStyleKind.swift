import SwiftUI

public enum TextFieldStyleKind: Sendable {
    case automatic
    case plain
    case roundedBorder
    case squareBorder
}

extension View {
    @ViewBuilder
    public func textFieldStyle(kind: TextFieldStyleKind) -> some View {
        switch kind {
        case .automatic:
            self.textFieldStyle(.automatic)
        case .plain:
            self.textFieldStyle(.plain)
        case .roundedBorder:
            self.textFieldStyle(.roundedBorder)
        case .squareBorder:
            #if os(macOS)
            self.textFieldStyle(.squareBorder)
            #else
            self.textFieldStyle(.automatic)
            #endif

        }
    }
}
