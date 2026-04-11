import Design
import Helpers
import SwiftUI

public struct BetterTextField: View {

    @Binding private var text: String
    private var progress: Double? = 0.5
    private var onWidthChange: ((CGFloat) -> ())?

    @Environment(\.backgroundStyle) private var backgroundStyle
    @Environment(\.betterTextFieldProgressFillStyle) private var progressFillStyle
    @Environment(\.betterTextFieldInsets) private var insets
    @Environment(\.betterTextFieldCornerRadius) private var radius
    @Environment(\.betterTextFieldBorderShapeStyle) private var borderShapeStyle
    @Environment(\.betterTextFieldBorderStrokeStyle) private var borderStrokeStyle

    var effectiveBackgroundStyle: AnyShapeStyle {
        self.backgroundStyle ?? .init(.secondaryFill)
    }

    public init(text: Binding<String>, progress: Double? = nil, onWidthChange: ((CGFloat) -> ())? = nil) {
        self._text = text
        self.progress = progress
        self.onWidthChange = onWidthChange
    }

    @State var width: CGFloat = 0

    public var body: some View {
        BetterTextFieldBase(text: self.$text)
            .betterTextFieldBaseStyle(.plain)
            .padding(self.insets)
            .background {
                RoundedRectangle(cornerRadius: radius)
                    .fill(self.effectiveBackgroundStyle)
                    .strokeBorder(self.borderShapeStyle, style: self.borderStrokeStyle)
                    .onGeometryChange(
                        for: CGFloat.self,
                        of: { proxy in proxy.size.width },
                        action: {
                            self.width = $0
                            self.onWidthChange?($0)
                        }
                    )
                    .overlay(alignment: .leading) {
                        if let progress = self.progress {
                            Rectangle()
                                .fill(self.progressFillStyle)
                                .frame(width: progress.clamped(to: 0...1) * self.width)
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: self.radius))
            }
            // allow maximum compressability
            .frame(minWidth: 0)
    }
}

extension EnvironmentValues {
    @Entry public var betterTextFieldInsets: SwiftUI::EdgeInsets = .init(horizontal: 12, vertical: 8)
    @Entry public var betterTextFieldBorderShapeStyle: AnyShapeStyle = .init(.clear)
    @Entry public var betterTextFieldBorderStrokeStyle: StrokeStyle = .init()
    @Entry public var betterTextFieldCornerRadius: CGFloat = 6
    @Entry public var betterTextFieldProgressFillStyle: AnyShapeStyle = .init(.primaryFill)
}

extension View {
    public func betterTextFieldInsets(_ insets: SwiftUI::EdgeInsets) -> some View {
        self.environment(\.betterTextFieldInsets, insets)
    }

    public func betterTextFieldCornerRadius(_ radius: CGFloat) -> some View {
        self.environment(\.betterTextFieldCornerRadius, radius)
    }

    public func betterTextFieldBorderShapeStyle<S: ShapeStyle>(_ style: S) -> some View {
        self.environment(\.betterTextFieldBorderShapeStyle, .init(style))
    }

    public func betterTextFieldBorderStrokeStyle(_ style: StrokeStyle) -> some View {
        self.environment(\.betterTextFieldBorderStrokeStyle, style)
    }

    public func betterTextFieldProgressFillStyle<S: ShapeStyle>(_ style: S) -> some View {
        self.environment(\.betterTextFieldProgressFillStyle, .init(style))
    }
}

#Preview {
    @Previewable @State var text: String = "Some text..."
    @Previewable @State var editable: Bool = true
    @Previewable @State var hover: Bool = false
    VStack {
        BetterTextField(text: $text)

        BetterTextField(text: $text, progress: 0.5)
            .betterTextFieldBorderShapeStyle(.primaryFill)
            .betterTextFieldForegroundColor(.secondaryLabel)
            .betterTextFieldBorderStrokeStyle(.init(lineWidth: hover ? 4 : 1))
            #if os(macOS)
        .pointerStyle(hover ? .columnResize : .default)
            #endif
            .onHover { value in
                withAnimation {
                    hover = value
                }
            }
        // .onHover(perform: { hover = $0 })

        TextField("", text: $text)
        Toggle("", isOn: $editable)
    }
    .multilineTextAlignment(.trailing)
    .padding()
}
