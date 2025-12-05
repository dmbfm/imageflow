import Helpers
import SwiftUI
import Logging

struct TouchCardView<Content: View>: View {
    let content: Content
    let onSizeChange: ((CGSize) -> CGSize)?

    @Binding var size: CGSize

    @State var sizeAtStartOfDrag: CGSize? = nil

    @Environment(\.cardViewStyle) var style

    func magnifyGestureChanged(_ value: MagnifyGesture.Value) {
        if self.sizeAtStartOfDrag == nil {
            self.sizeAtStartOfDrag = self.size
        }

        let newSize = (sizeAtStartOfDrag ?? self.size) * value.magnification
        self.size =
            if let onSizeChange = self.onSizeChange {
                onSizeChange(newSize)
            } else {
                newSize
            }
    }

    func magnifyGestureEnded(_ value: MagnifyGesture.Value) {
        self.sizeAtStartOfDrag = nil
    }

    init(
        size: Binding<CGSize>,
        @ViewBuilder content: () -> Content,
        onSizeChange: ((CGSize) -> CGSize)? = nil
    ) {
        self.content = content()
        self._size = size
        self.onSizeChange = onSizeChange
    }

    var body: some View {
        ZStack(alignment: .center) {
            self.content
        }
        .frame(width: self.size.width, height: self.size.height)
        .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))
        .shadow(color: style.shadow.color, radius: style.shadow.radius, x: style.shadow.x, y: style.shadow.y)
        .gesture(
            MagnifyGesture(minimumScaleDelta: 0)
                .onChanged(self.magnifyGestureChanged(_:))
                .onEnded(self.magnifyGestureEnded(_:))
        )
    }
}

struct CardViewStyle: Sendable, Equatable, With {
    var cornerRadius: CGFloat
    var shadow: Shadow

    static var `default`: Self {
        .init(cornerRadius: 12, shadow: .init(radius: 4))
    }

    struct Shadow: Sendable, Equatable, With {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var radius: CGFloat
        var color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)
    }
}

extension EnvironmentValues {
    @Entry var cardViewStyle: CardViewStyle = .default
}

extension CGSize {
    func padding(forAlignment alignment: Alignment) -> CGSize {
        switch alignment {
        case .bottomTrailing:
            .init(width: -self.width, height: -self.height)
        case .bottomLeading:
            .init(width: self.width, height: -self.height)
        case .topTrailing:
            .init(width: -self.width, height: self.height)
        case .topLeading:
            .init(width: self.width, height: self.height)
        default:
            self
        }
    }
}

struct TouchCardViewContainer<Content: View>: View {
    @State var alignment: Alignment = .bottomTrailing
    @State var position: CGPoint = .zero
    @State var offset: CGPoint = .zero
    @State var size: Box<CGSize> = .init(.zero)
    let padding: CGSize
    let cardView: TouchCardView<Content>

    init(
        padding: CGSize = .zero,
        defaultAlignment alignment: Alignment = .bottomTrailing,
        @ViewBuilder cardView: () -> TouchCardView<Content>
    ) {
        self.cardView = cardView()
        self.padding = padding
        self._alignment = .init(wrappedValue: alignment)
        self._offset = .init(wrappedValue: .zero)
    }

    var finalPosition: CGPoint {
        self.position + self.offset + self.padding.padding(forAlignment: self.alignment).cgPoint
    }

    func dragGestureChanged(_ value: DragGesture.Value) {
        self.offset = value.translation.cgPoint
    }

    func dragGestureEnded(_ value: DragGesture.Value) {
        let r = CGPoint(x: value.location.x / self.size.value.width, y: value.location.y / self.size.value.height)
        let newAlignemnt: Alignment =
            if r.x <= 0.5 && r.y <= 0.5 {
                .topLeading
            } else if r.x <= 0.5 && r.y > 0.5 {
                .bottomLeading
            } else if r.x > 0.5 && r.y <= 0.5 {
                .topTrailing
            } else {
                .bottomTrailing
            }
        withAnimation(.bouncy) {
            self.offset = .zero
            self.alignment = newAlignemnt
        }
    }

    var body: some View {
        ZStack(alignment: self.alignment) {
            Color.clear
            self.cardView
                .offset(self.finalPosition.cgSize)
                .highPriorityGesture(
                    DragGesture(coordinateSpace: .named("container"))
                        .onChanged(self.dragGestureChanged(_:))
                        .onEnded(self.dragGestureEnded(_:))
                )
        }
        .border(.orange)
        .coordinateSpace(name: "container")
        .onGeometryChange(
            for: CGSize.self,
            of: { proxy in proxy.size },
            action: { size in self.size.value = size }
        )
    }
}

extension Previews {
    public struct TouchCardViewPreview: View {

        @State var size: CGSize = .init(width: 200, height: 200)

        public init() {}

        public var body: some View {
            TouchCardViewContainer(padding: .init(width: 20, height: 20)) {
                TouchCardView(size: self.$size) {
                    Color.red
                } onSizeChange: { newSize in
                    let r: ClosedRange<CGFloat> = 100.0...300.0
                    return .init(width: newSize.width.clamped(to: r), height: newSize.height.clamped(to: r))
                }
            }
            .border(.green)
            .padding(50)
        }
    }
}

#Preview {
    Previews.TouchCardViewPreview()
}
