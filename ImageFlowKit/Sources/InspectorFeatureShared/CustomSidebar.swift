import Helpers
import SwiftUI

public struct CustomSidebarModifier<V: View>: ViewModifier {

    let content: () -> V

    @State var width: CGFloat = 200
    @State var widthAtDragStart: CGFloat? = nil

    @Binding var isPresented: Bool
    @Environment(\.customSidebarRadius) var radius
    @Environment(\.customSidebarWidth) var widthConfiguration
    @Environment(\.customSidebarInsets) var insets

    public init(
        _ isPresented: Binding<Bool>,
        content: @escaping () -> V
    ) {
        self._isPresented = isPresented
        self.content = content
    }

    var isResizable: Bool {
        switch self.widthConfiguration {
        case .fixed: false
        case .range: true
        }
    }

    #if os(macOS)
    var resizePointer: PointerStyle? {
        self.isResizable ? .columnResize : nil
    }
    #endif

    func onChangeOfWidthConfiguration() {
        switch self.widthConfiguration {
        case .fixed(let value): self.width = value
        case .range(range: let range, ideal: let ideal): self.width = ideal.clamped(to: range)
        }
    }

    func onResizeHandleDrag(_ value: DragGesture.Value, ended: Bool = false) {

        guard self.isResizable else { return }

        if !ended {
            if self.widthAtDragStart == nil {
                self.widthAtDragStart = self.width
            }
        }

        if let widthAtDragStart = self.widthAtDragStart {
            let newWidth = widthAtDragStart - value.translation.width
            self.width = self.widthConfiguration.range.maybeReduce(
                newWidth,
                { width, range in width.clamped(to: range) }
            )
        }

        if ended {
            self.widthAtDragStart = nil
        }
    }

    public func body(content: Content) -> some View {
        content
            .safeAreaInset(edge: .trailing) {
                if self.isPresented {
                    ZStack {
                        Color.clear
                        self.content()

                        HStack {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 8)
                                .contentShape(Rectangle())
                                .gesture(
                                    DragGesture(coordinateSpace: .global)
                                        .onChanged({ self.onResizeHandleDrag($0) })
                                        .onEnded({ self.onResizeHandleDrag($0, ended: true) })
                                )
                                #if os(macOS)
                                .pointerStyle(self.resizePointer)
                                #endif
                            Spacer()
                        }

                    }
                    .frame(width: self.width)
                    .glassEffect(.regular, in: RoundedRectangle(cornerRadius: self.radius, style: .continuous))
                    // .padding(.trailing, 12)
                    .safeAreaPadding(self.insets)
                    .transition(.move(edge: .trailing))
                }
            }
            .animation(.easeInOut(duration: 0.2), value: self.isPresented)
            .onChange(of: self.widthConfiguration, initial: true, self.onChangeOfWidthConfiguration)
    }
}

public enum CustomSidebarWidthConfiguration: Equatable {
    case fixed(CGFloat)
    case range(range: ClosedRange<CGFloat>, ideal: CGFloat)

    var range: ClosedRange<CGFloat>? {
        switch self {
        case .fixed: nil
        case .range(let range, _): range
        }
    }
}

extension View {
    public func customSidebar<V: View>(
        _ isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> V
    ) -> some View {
        self.modifier(CustomSidebarModifier(isPresented, content: content))
    }
}

extension EnvironmentValues {
    @Entry public var customSidebarRadius: CGFloat = 32
    @Entry public var customSidebarWidth: CustomSidebarWidthConfiguration = .fixed(340)
    @Entry public var customSidebarInsets: SwiftUI.EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 12)
}

extension View {
    public func customSidebarRadius(_ value: CGFloat) -> some View {
        self.environment(\.customSidebarRadius, value)
    }

    public func customSidebarWidth(_ value: CustomSidebarWidthConfiguration) -> some View {
        self.environment(\.customSidebarWidth, value)
    }

    public func customSidebarInsets(_ value: SwiftUI.EdgeInsets) -> some View {
        self.environment(\.customSidebarInsets, value)
    }
}

private struct PreviewCommon: View {

    @State var presented = true

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Color.teal
                .ignoresSafeArea()

            ZStack {
                Button("Toggle") {
                    presented.toggle()
                }
                Color.clear
            }

            RoundedRectangle(cornerRadius: 8)
                .fill(.purple)
                .frame(width: 50, height: 50)
                .padding(.bottom, 20)
        }
        .customSidebar($presented) {
            ContentUnavailableView("Custom Sidebar!", systemImage: "sidebar.right")
        }
        .customSidebarRadius(14)
        .customSidebarInsets(.init(top: 12, leading: 0, bottom: 12, trailing: 12))
    }

}

#Preview("Fixed") {
    PreviewCommon()
        .customSidebarWidth(.fixed(200))
}

#Preview("Resizable") {
    PreviewCommon()
        .customSidebarWidth(.range(range: 100...400, ideal: 200))
}
