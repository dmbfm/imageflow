import Helpers
import SwiftUI

public struct Block<Content: View>: View {

    struct Style: With {
        var padding: SwiftUI::EdgeInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
        var cornerRadius: CGFloat = 8.0
        var fill: AnyShapeStyle = .init(.tertiaryFill)
        var border: AnyShapeStyle = .init(.clear)

        static var `default`: Self { .init() }

    }

    var style: Style
    var content: () -> Content

    init(style: Style = .default, @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.style = style
    }

    public var body: some View {
        VStack(alignment: .leading) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(self.style.padding)
        .background {
            RoundedRectangle(cornerRadius: self.style.cornerRadius, style: .continuous)
                .fill(self.style.fill)
                .strokeBorder(self.style.border)
        }
    }
}
