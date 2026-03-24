import Design
import Helpers
import Logging
import SwiftUI

extension TextFieldEx {
    func inspector(horizontalPadding: CGFloat = 0, style: InspectorTextFieldStyle = .default) -> some View {
        self
            .textFieldExStyle(.plain)
            .textFieldExInteractionMode(.commit)
            .textFieldExForegroudColor(style.foregroundColor)
            .multilineTextAlignment(.center)
            .padding(.vertical, style.verticalPadding)
            .padding(.horizontal, horizontalPadding)
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadiusInner))
            .padding(style.borderWidth)
//            .background(style.borderColor)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadiusOuter))
    }
}

struct InspectorTextFieldStyle {
    var foregroundColor: PlatformColor = Colors.inspectorControlForeground.platformColor
    var backgroundColor: Color = DS.textInputBackground.color
//    var borderColor: Color = Colors.inspectorControlBorder.color
    var verticalPadding: CGFloat = 4
    var borderWidth: CGFloat = 1
    var cornerRadiusInner: CGFloat = 6
    var cornerRadiusOuter: CGFloat = 7

    static let `default`: Self = .init()
}

extension EnvironmentValues {
    @Entry var hoverEffect: Bool = true
}

extension View {
    func hoverEffect(_ value: Bool) -> some View {
        self.environment(\.hoverEffect, value)
    }
}

#Preview {
    @Previewable @State var value: Double = 1
    VStack {
        TextFieldEx(value: $value, format: .number.locale(.init(identifier: "en-US")))
            .inspectorSlider(percentage: value, horizontalPadding: 0) { dragData in
                value = dragData.current.clamped(to: 0...1)
            }
    }
    .padding()
}
