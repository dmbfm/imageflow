import Helpers
import SwiftUI

public struct CardDockHeights {
    var up: Bounded<CGFloat>
    var down: Bounded<CGFloat>

    public init(up: Bounded<CGFloat>, down: Bounded<CGFloat>) {
        self.up = up
        self.down = down
    }

    func mapUp(_ f: (Bounded<CGFloat>) -> Bounded<CGFloat>) -> Self {
        .init(up: f(self.up), down: self.down)
    }

    func mapDown(_ f: (Bounded<CGFloat>) -> Bounded<CGFloat>) -> Self {
        .init(up: self.up, down: f(self.down))
    }
}

public enum CardDockLocation: String, Equatable, CaseIterable {
    case down
    case up
}

public enum CardAlignment: String, Equatable, CaseIterable {
    case topLeading
    case topTrailing
    case bottomLeading
    case bottomTrailing

    var value: Alignment {
        switch self {
        case .bottomTrailing: .bottomTrailing
        case .bottomLeading: .bottomLeading
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        }
    }

    var transitionAnchor: UnitPoint {
        switch self {
        case .bottomTrailing: .bottomTrailing
        case .bottomLeading: .bottomLeading
        case .topLeading: .topLeading
        case .topTrailing: .topTrailing
        }
    }
}

public enum CardVisibility: String, Equatable, CaseIterable {
    case visible
    case hidden
}

public struct CardStageView<Content: View>: View {

    // MARK: - State

    /// The content view that will be hosted in the card.
    let content: Content
    /// The padding to the edge of the stage view, relative to the current card alignment.
    let padding: CGSize
    /// If true the card is not visible.
    let visibility: CardVisibility
    /// Stores temporary variables in a class-object so they don't update the view.
    @State var scratch = Scratch()
    /// The drag-amount while resizing the docked view.
    @State var dockHeightDragOffset: CGFloat = 0
    /// The offset of the card. This, along with the `alignment` defines the card's position in the stage.
    @State var offset: CGSize = .zero
    /// This size of the card. Since cards are always square we only need one number.
    @Binding var size: Bounded<CGFloat>
    /// The alignment of the card in the stage.
    @Binding var alignment: CardAlignment
    /// When non-`nil` defines where the card is docked (up or down). If `nil`, the card is not docked.
    @Binding var dock: CardDockLocation?
    /// Stores the heights of the docked views.
    @Binding var dockHeights: CardDockHeights

    @Environment(\.cardStageCardStyle) var cardStyle

    @Namespace var transitionNS

    let localCoordinateSpace: NamedCoordinateSpace = .named("CardStageView")

    // MARK: - Internal Types

    class Scratch {
        var sizeAtDragStart: Bounded<CGFloat>? = nil
        var stageSize: CGSize = .zero
    }

    enum Handle: Equatable {
        case left
        case right
        case top
        case bottom
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
    }

    enum DragStage {
        case changed
        case ended
    }

    // MARK: - Init

    public init(
        _ size: Binding<Bounded<CGFloat>>,
        _ alignment: Binding<CardAlignment>,
        _ dock: Binding<CardDockLocation?>,
        _ dockHeights: Binding<CardDockHeights>,
        visibility: CardVisibility = .visible,
        padding: CGSize = .zero,
        @ViewBuilder _ content: () -> Content
    ) {
        self._size = size
        self._alignment = alignment
        self._dock = dock
        self._dockHeights = dockHeights
        self.padding = padding
        self.content = content()
        self.visibility = visibility
    }

    // MARK: - Computed vars

    var isVisible: Bool {
        self.visibility == .visible
    }

    var currentHandles: [Handle] {
        switch self.dock {
        case .up: [.bottom]
        case .down: [.top]
        case .none:
            switch self.alignment {
            case .bottomTrailing: [.left, .top, .topLeft]
            case .bottomLeading: [.right, .top, .topRight]
            case .topLeading: [.right, .bottom, .bottomRight]
            case .topTrailing: [.left, .bottom, .bottomLeft]
            }
        }
    }

    var currentDockHeight: CGFloat {
        switch self.dock {
        case .up: self.dockHeights.up.withValueClamped(self.dockHeights.up.value + self.dockHeightDragOffset).value
        default: self.dockHeights.down.withValueClamped(self.dockHeights.down.value - self.dockHeightDragOffset).value
        }
    }

    var dockDividerDragGesture: some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged() { value in
                self.dockHeightDragOffset = value.translation.height
            }
            .onEnded() { value in
                self.offsetCurrentDockHeight(by: self.dockHeightDragOffset)
                self.dockHeightDragOffset = 0
            }
    }

    var finalOffset: CGSize {
        self.offset + self.padding.offset(forAlignment: self.alignment.value)
    }

    // MARK: - Methods

    func magnifyGestureChanged(_ value: MagnifyGesture.Value) {
        if self.scratch.sizeAtDragStart == nil {
            self.scratch.sizeAtDragStart = self.size
        }

        let newValue = (self.scratch.sizeAtDragStart ?? self.size).value * value.magnification
        self.size = self.size.withValueClamped(newValue)
    }

    func magnifyGestureEnded(_ value: MagnifyGesture.Value) {
        self.scratch.sizeAtDragStart = nil
    }

    func cardDragChanged(_ value: DragGesture.Value) {
        self.offset = value.translation

        let size = self.scratch.stageSize
        let r = CGPoint(x: value.location.x / size.width, y: value.location.y / size.height)

        if r.y >= 0.98 {
            self.offset = .zero
            self.dock = .down
            return
        } else if r.y <= 0.02 {
            self.offset = .zero
            self.dock = .up
            return
        }
    }

    func cardDragEnded(_ value: DragGesture.Value) {
        let size = self.scratch.stageSize
        let r = CGPoint(x: value.location.x / size.width, y: value.location.y / size.height)

        let newAlignemnt: CardAlignment =
            if r.x <= 0.5 && r.y <= 0.5 {
                .topLeading
            } else if r.x <= 0.5 && r.y > 0.5 {
                .bottomLeading
            } else if r.x > 0.5 && r.y <= 0.5 {
                .topTrailing
            } else {
                .bottomTrailing
            }

        if r.y >= 0.98 {
            self.offset = .zero
            self.alignment = newAlignemnt
            self.dock = .down
            return
        } else if r.y <= 0.02 {
            self.offset = .zero
            self.alignment = newAlignemnt
            self.dock = .up
            return
        }

        withAnimation(.bouncy) {
            self.offset = .zero
            self.alignment = newAlignemnt
        }
    }

    func offsetCurrentDockHeight(by amount: CGFloat) {
        switch self.dock {
        case .up:
            self.dockHeights = self.dockHeights.mapUp { value in
                value.withValueClamped(value.value + amount)
            }
        case .down:
            self.dockHeights = self.dockHeights.mapDown { value in
                value.withValueClamped(value.value - amount)
            }
        case .none:
            break
        }
    }

    func dragHandle(_ handle: Handle, _ stage: DragStage, _ value: DragGesture.Value) {
        switch stage {
        case .changed:
            if self.scratch.sizeAtDragStart == nil {
                self.scratch.sizeAtDragStart = self.size
            }
            let sizeAtDragStart: CGFloat = self.scratch.sizeAtDragStart?.value ?? 0
            let t = value.translation
            let delta: CGFloat =
                switch handle {
                case .left:
                    -t.width
                case .top:
                    -t.height
                case .topLeft:
                    -min(t.width, t.height)
                case .right:
                    t.width
                case .bottom:
                    t.height
                case .bottomLeft:
                    max(-t.width, t.height)
                case .topRight:
                    -min(-t.width, t.height)
                case .bottomRight:
                    max(t.width, t.height)
                }
            let newSize = sizeAtDragStart + delta
            self.size = self.size.withValueClamped(newSize)
        case .ended:
            self.scratch.sizeAtDragStart = nil
        }
    }

    // MARK: - Body

    public var body: some View {
        ZStack {
            Color.clear
            switch self.dock {
            case .none:
                self.undockedView
            case .up:
                self.dockedView
            case .down:
                self.dockedView
            }
        }
        .animation(.easeInOut(duration: 0.15), value: self.dock)
        // .animation(.easeInOut(duration: 0.15), value: self.alignment)
        .animation(.easeInOut(duration: 0.25), value: self.visibility)
        .onGeometryChange(for: CGSize.self, of: { $0.size }, action: { self.scratch.stageSize = $0 })
        .coordinateSpace(self.localCoordinateSpace)
    }

    @ViewBuilder
    var undockedView: some View {
        ZStack(alignment: self.alignment.value) {
            Color.clear
            if self.isVisible {
                self.cardView
                    .offset(self.finalOffset)
                    // .transition(.scale(0.01, anchor: self.alignment.transitionAnchor).combined(with: .opacity))
                    .transition(.scale.combined(with: .opacity))
            }
        }
    }

    @ViewBuilder
    var dockedView: some View {
        let alignment: Alignment = self.dock == .up ? .top : .bottom
        let alignment2: Alignment = self.dock == .up ? .bottom : .top
        let guide: Edge.Set = self.dock == .up ? .bottom : .top
        ZStack(alignment: alignment) {
            Color.clear
            if self.isVisible {
                ZStack(alignment: alignment2) {
                    self.content
                        .matchedGeometryEffect(id: "card", in: self.transitionNS)
                        .padding(guide, 6)

                    Color.clear
                        .contentShape(Rectangle())
                        .frame(height: 12)
                        #if os(macOS)
                    .pointerStyle(.rowResize)
                        #endif
                        .gesture(self.dockDividerDragGesture)
                }
                .frame(height: self.currentDockHeight)
                .transition(.move(edge: self.dock == .up ? .top : .bottom))
            }
        }
    }

    #if os(macOS)
    @ViewBuilder
    func handleView(_ handle: Handle, color: Color = .clear) -> some View {
        let size = self.size.value
        let cornerSize = 20.0
        let cornerPadding = 5.0
        let (pos, width, height, ps): (CGPoint, CGFloat?, CGFloat?, PointerStyle) =
            switch handle {
            case .left:
                (.init(x: 0, y: size * 0.5), 10, nil, .columnResize)
            case .right:
                (.init(x: size, y: size * 0.5), 10, nil, .columnResize)
            case .top:
                (.init(x: size * 0.5, y: 0), nil, 10, .rowResize)
            case .bottom:
                (.init(x: size * 0.5, y: size), nil, 10, .rowResize)
            case .topLeft:
                (
                    .init(x: cornerPadding, y: cornerPadding), cornerSize, cornerSize,
                    .frameResize(position: .topLeading, directions: .all)
                )
            case .topRight:
                (
                    .init(x: size - cornerPadding, y: cornerPadding), cornerSize, cornerSize,
                    .frameResize(position: .topTrailing, directions: .all)
                )
            case .bottomLeft:
                (
                    .init(x: cornerPadding, y: size - cornerPadding), cornerSize, cornerSize,
                    .frameResize(position: .bottomLeading)
                )
            case .bottomRight:
                (
                    .init(x: size - cornerPadding, y: size - cornerPadding), cornerSize, cornerSize,
                    .frameResize(position: .bottomTrailing)
                )
            }

        color
            .contentShape(Rectangle())
            .frame(width: width, height: height)
            .position(pos)
            #if os(macOS)
        .pointerStyle(ps)
            #endif
            .gesture(
                DragGesture(coordinateSpace: .global)
                    .onChanged({ self.dragHandle(handle, .changed, $0) })
                    .onEnded({ self.dragHandle(handle, .ended, $0) })
            )

    }
    #endif

    var cardView: some View {
        self.content
            .matchedGeometryEffect(id: "card", in: self.transitionNS)
            .frame(width: self.size.value, height: self.size.value)
            .clipShape(RoundedRectangle(cornerRadius: cardStyle.cornerRadius, style: .continuous))
            .shadow(
                color: cardStyle.shadow.color,
                radius: cardStyle.shadow.radius,
                x: cardStyle.shadow.x,
                y: cardStyle.shadow.y
            )
            .gesture(
                MagnifyGesture(minimumScaleDelta: 0)
                    .onChanged(self.magnifyGestureChanged(_:))
                    .onEnded(self.magnifyGestureEnded(_:))
                    .simultaneously(
                        with: DragGesture(coordinateSpace: self.localCoordinateSpace)
                            .onChanged(self.cardDragChanged(_:))
                            .onEnded(self.cardDragEnded(_:))
                    )
            )
            #if os(macOS)
        .overlay {
            ZStack {
                ForEach(self.currentHandles, id: \.self) { handle in
                    self.handleView(handle)
                }
            }
        }
            #endif
    }
}

extension CardStageView: @MainActor Equatable where Content: Equatable {
    public static func == (lhs: CardStageView<Content>, rhs: CardStageView<Content>) -> Bool {
        lhs.content == rhs.content && lhs.padding == rhs.padding && lhs.visibility == rhs.visibility
    }
}

public struct CardStageCardStyle: Sendable, Equatable, With {

    public var cornerRadius: CGFloat
    public var shadow: Shadow

    public init(cornerRadius: CGFloat, shadow: CardStageCardStyle.Shadow) {
        self.cornerRadius = cornerRadius
        self.shadow = shadow
    }

    public static var `default`: Self {
        .init(cornerRadius: 12, shadow: .init(radius: 4))
    }

    public struct Shadow: Sendable, Equatable, With {
        var x: CGFloat = 0
        var y: CGFloat = 0
        var radius: CGFloat
        var color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)

        public init(
            x: CGFloat = 0,
            y: CGFloat = 0,
            radius: CGFloat,
            color: Color = Color(.sRGBLinear, white: 0, opacity: 0.33)
        ) {
            self.x = x
            self.y = y
            self.radius = radius
            self.color = color
        }
    }
}

extension EnvironmentValues {
    @Entry var cardStageCardStyle: CardStageCardStyle = .default
}

extension View {
    public func cardStageCardStyle(_ style: CardStageCardStyle) -> some View {
        self.environment(\.cardStageCardStyle, style)
    }
}

extension CGSize {
    fileprivate func offset(forAlignment alignment: Alignment) -> CGSize {
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
