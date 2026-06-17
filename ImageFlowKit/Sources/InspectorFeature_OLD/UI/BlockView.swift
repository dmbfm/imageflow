import ComponentKit
import SwiftUI
import XKit

@MainActor
func block(_ view: XView) -> Box {
    .inspector(view: view)
}

extension Box {
    static func inspector(view: XView) -> Box {
        Box(view: view)
            .with(\.cornerRadius, 10)
            .with(\.cornerCurve, .continuous)
            .with(\.insets, .init(10))
            .with(\.borderColor, nil)
    }
}

#Preview {
    VStack {
        XSimpleViewRepresentable(
            block(XTextField(labelWithString: "Hello Block!"))
        )
        .padding()
    }
}
