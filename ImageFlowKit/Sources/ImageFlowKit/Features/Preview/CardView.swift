import Logging
import SwiftUI
import Helpers

extension CardView: @preconcurrency Equatable where Background: Equatable, Content: Equatable, Toolbar: Equatable {
    public static func == (
        lhs: CardView<Background, Content, Toolbar>,
        rhs: CardView<Background, Content, Toolbar>
    ) -> Bool {
        lhs.size == rhs.size && lhs.background == rhs.background && lhs.content == rhs.content
            && lhs.toolbar == rhs.toolbar
    }
}

public struct CardView<Background: View, Content: View, Toolbar: View>: View {

    private let background: Background
    private let content: Content
    private let toolbar: Toolbar?
    private var size: CGSize = .init(width: 200, height: 200)

    @Environment(\.cardViewToolbarMode) private var toolbarMode
    @Environment(\.cardViewToobarVisibility) private var toolbarVisibility
    @Environment(\.cardViewShadowRadius) private var shadowRadius
    @Environment(\.cardViewCornerRadius) private var cornerRadius

    @State var hover = false

    public init(
        @ViewBuilder background: () -> Background = { Color.white },
        @ViewBuilder content: () -> Content,
        @ViewBuilder toolbar: () -> Toolbar,
    ) {
        self.background = background()
        self.content = content()
        self.toolbar = toolbar()
    }

    public init(
        background: () -> Background,
        content: () -> Content
    ) where Toolbar == EmptyView {
        self.background = background()
        self.content = content()
        self.toolbar = nil
    }

    var showToolbar: Bool {
        self.toolbar != nil && (self.toolbarMode == .sticky || self.hover) && self.toolbarVisibility == .visible
    }

    public var body: some View {
        ZStack(alignment: .center) {
            background
            content
        }
        .overlay(alignment: .top) {
            VStack {
                HStack(spacing: 2) {
                    if let toolbar = self.toolbar {
                        toolbar
                    }
                }
            }
            .frame(height: 25)
            .frame(maxWidth: .infinity)
            .background(.ultraThickMaterial)
            .offset(y: self.showToolbar ? 0 : -25)
            .allowsHitTesting(self.showToolbar)
            .animation(.linear(duration: 0.1), value: self.hover)
        }
        .frame(width: self.size.width, height: self.size.height)
        .clipShape(RoundedRectangle(cornerRadius: self.cornerRadius))
        .shadow(radius: self.shadowRadius)
        .onHover { value in
            self.hover = value
        }
    }
}

extension CardView {
    public func cardViewSize(_ size: CGSize) -> Self {
        var view = self
        view.size = size
        return view
    }

    public func cardViewSize(_ size: CGFloat) -> Self {
        self.cardViewSize(CGSize(width: size, height: size))
    }
}

extension CardView: @preconcurrency Animatable {
    public var animatableData: CGSize.AnimatableData {
        get { self.size.animatableData }
        set { self.size.animatableData = newValue }
    }
}

public enum CardViewToolbarMode: Equatable {
    case sticky
    case hover
}

public enum CardViewToolbarVisibility: Equatable {
    case visible
    case hidden
}

public extension EnvironmentValues {
    @Entry var cardViewToolbarMode: CardViewToolbarMode = .hover
    @Entry var cardViewToobarVisibility: CardViewToolbarVisibility = .visible
    @Entry var cardViewShadowRadius: CGFloat = 4
    @Entry var cardViewCornerRadius: CGFloat = 12
}

public extension View {
    func cardViewToolbarMode(_ mode: CardViewToolbarMode) -> some View {
        self.environment(\.cardViewToolbarMode, mode)
    }

    func cardViewToolbarVisibility(_ value: CardViewToolbarVisibility) -> some View {
        self.environment(\.cardViewToobarVisibility, value)
    }

    func cardViewCornerRadius(_ radius: CGFloat) -> some View {
        self.environment(\.cardViewCornerRadius, radius)
    }

    func cardViewShadowRadius(_ radius: CGFloat) -> some View {
        self.environment(\.cardViewShadowRadius, radius)
    }
}

#Preview {

    @Previewable @State var size: CGFloat = 100

    ZStack(alignment: .bottomTrailing) {
        Color.white
//        Color(nsColor: .windowBackgroundColor)
        CardView {
            Color.white
        } content: {
            Rectangle()
                .fill(Color.teal.gradient)
                .frame(width: 50, height: 50)
        } toolbar: {
            Button("toggle") {
                withAnimation {
                    if size == 100 { size = 200 } else { size = 100 }
                }
            }

            Button("Other button") {}
        }
        .cardViewSize(size)
        .padding([.bottom, .trailing], 10)
        .onTapGesture {
        }
    }
    .frame(width: 500, height: 500)
}
