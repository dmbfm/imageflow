import CIImageView
import Controls
import CoreImage
import Helpers
import SwiftUI

struct DockedPreviewContentView: View {

    let vm: PreviewContentViewModel
    let style: Style
    var dispatch: ((PreviewContentViewAction) -> ())?

    @State var zoom: CGFloat = 1.0
    @State var action: CIImageScrollView.Action? = nil

    @Environment(\.colorScheme) var cs

    let bgColor: Color = Colors.canvasBackground.color
    let toolbarHeight: CGFloat = 26.0

    enum Action {
        case undock
        case toggleLock
    }

    enum Style {
        case glass
        case classic
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        zoomFormatter.string(for: self.zoom)!
    }

    var body: some View {
        switch self.style {
        case .classic:
            self.classicBody
        case .glass:
            self.glassBody
        }
    }

    @ViewBuilder
    var classicBody: some View {
        VStack(spacing: 0) {
            if self.vm.dockLocation == .up {
                self.contentView
                self.classicToolbarView
            } else {
                self.classicToolbarView
                self.contentView
            }
        }
        .background(Colors.canvasBackground.color)
    }

    var classicToolbarView: some View {
        ClassicToolbarView(
            vm: self.vm,
            zoom: self.$zoom,
            action: self.$action,
            dispatch: self.dispatch
        )
    }

    @ViewBuilder
    var glassBody: some View {
        VStack(spacing: 0) {
            if self.vm.dockLocation == .down {
                ZStack {
                    Color.clear
                    Capsule()
                        .frame(width: 60, height: 6)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 30)

                Divider()

                ZStack(alignment: .bottom) {
                    self.contentView

                    GlassToolbarView(
                        vm: self.vm,
                        zoom: self.$zoom,
                        action: self.$action,
                        dispatch: self.dispatch
                    )
                }
                .background(Colors.canvasBackground.color)
            } else {
                ZStack(alignment: .top) {
                    self.contentView

                    GlassToolbarView(
                        vm: self.vm,
                        zoom: self.$zoom,
                        action: self.$action,
                        dispatch: self.dispatch
                    )
                }
                .background(Colors.canvasBackground.color)
                Divider()
                ZStack {
                    Color.clear
                    Capsule()
                        .frame(width: 60, height: 6)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 30)

            }
        }
    }

    @ViewBuilder
    var contentView: some View {
        switch vm.content {
        case .image(let image):
            CIImageScrollView(
                image: image,
                configuration: .init(),
                zoom: $zoom,
                action: $action
            )
        default:
            ZStack {
                Color.clear
                ContentUnavailableView(
                    "No Image",
                    systemImage: "photo",
                    description: Text("Select a node with an output image to preview!")
                )
            }
        }
    }
}

private struct VDivider: View {
    var body: some View {
        Divider().frame(width: 1, height: 14)
    }
}

enum DockedPreviewToolbarPlacement {
    case zstack
    case vstack
}

struct GlassToolbarView: View {

    var vm: PreviewContentViewModel
    @Binding var zoom: CGFloat
    @Binding var action: CIImageScrollView.Action?
    var dispatch: ((PreviewContentViewAction) -> ())?
    let toolbarHeight: CGFloat = 26.0
    let bgColor: Color = Colors.canvasBackground.color

    static var toolbarPlacement: DockedPreviewToolbarPlacement = .zstack

    init(
        vm: PreviewContentViewModel,
        zoom: Binding<CGFloat>,
        action: Binding<CIImageScrollView.Action?>,
        dispatch: ((PreviewContentViewAction) -> ())? = nil
    ) {
        self.vm = vm
        self._zoom = zoom
        self._action = action
        self.dispatch = dispatch
    }

    enum Name: Hashable {
        case lock
        case export
        case dockSwitch
        case undock
        case zoomIn
        case zoomOut
        case zoomActual
        case zoomFit
    }

    func handle(_ id: Name) {
        switch id {
        case .lock:
            self.dispatch?(.toggleLock)
        case .export:
            self.dispatch?(.export)
        case .dockSwitch:
            self.dispatch?(.dockOpposite)
        case .undock:
            self.dispatch?(.undock)
        case .zoomIn:
            self.action = .zoomIn(animate: true)
        case .zoomOut:
            self.action = .zoomOut(animate: true)
        case .zoomActual:
            self.action = .setZoom(value: 1.0, animate: true)
        case .zoomFit:
            self.action = .zoomToFit(animate: true)
        }
    }

    private var toolbarElements: [PreviewToolbarElement<Name>] {
        [
            .trio(
                id: "left",
                .init(id: .lock, icon: self.vm.isLocked ? "lock.fill" : "lock", disabled: self.vm.lockButtonDisabled),
                .init(
                    id: .dockSwitch,
                    icon: self.vm.dockLocation == .down
                        ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle"
                ),
                .init(id: .undock, icon: "pip.enter"),
            ),
            .spacer,
            .item(.init(id: .export, icon: "square.and.arrow.down")),
        ]
    }

    private var toolbarCenterElements: [PreviewToolbarElement<Name>] {
        [
            .spacer,
            .zoomGroup(
                id: "middle",
                .init(id: .zoomIn, icon: "plus.magnifyingglass"),
                .init(id: .zoomOut, icon: "minus.magnifyingglass"),
                zoomFormatter.string(for: self.zoom)!,
                .init(id: .zoomActual, icon: "1.magnifyingglass"),
                .init(id: .zoomFit, icon: "arrow.up.left.and.down.right.magnifyingglass"),
            ),
            .spacer,
        ]
    }

    var alignment: Alignment {
        if self.vm.dockLocation == .down {
            .top
        } else {
            .bottom
        }
    }

    var paddingAxis: SwiftUI.Edge.Set {
        if self.vm.dockLocation == .down {
            .top
        } else {
            .bottom
        }
    }

    var body: some View {
        ZStack(alignment: self.alignment) {
            let padding: CGFloat = 8

            PreviewToolbarView(
                elements: self.toolbarElements,
                visible: true,
                alignment: self.alignment,
                handler: self.handle(_:)
            )
            .padding(self.paddingAxis, padding)
            .padding(.horizontal, 20)

            PreviewToolbarView(
                elements: self.toolbarCenterElements,
                visible: true,
                alignment: self.alignment,
                handler: self.handle(_:)
            )
            .padding(self.paddingAxis, padding)
        }
    }
}

struct ClassicToolbarView: View {

    var vm: PreviewContentViewModel
    @Binding var zoom: CGFloat
    @Binding var action: CIImageScrollView.Action?
    var dispatch: ((PreviewContentViewAction) -> ())?
    let toolbarHeight: CGFloat = 26.0
    let bgColor: Color = Colors.canvasBackground.color

    @Environment(\.colorScheme) var cs

    static var toolbarPlacement: DockedPreviewToolbarPlacement = .vstack

    init(
        vm: PreviewContentViewModel,
        zoom: Binding<CGFloat>,
        action: Binding<CIImageScrollView.Action?>,
        dispatch: ((PreviewContentViewAction) -> ())? = nil
    ) {
        self.vm = vm
        self._zoom = zoom
        self._action = action
        self.dispatch = dispatch
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        zoomFormatter.string(for: self.zoom)!
    }

    var body: some View {
        VStack(spacing: 0) {
            Divider()
            HStack(spacing: 8) {
                self.toolbarContentView
            }
            .padding(.horizontal, 10)
            .frame(height: self.toolbarHeight)
            .frame(maxWidth: .infinity)
            .background {
                self.bgColor
            }
            Divider()
        }
    }

    var zoomLabel: some View {
        HStack {
            Text("\(self.zoomText)")
                .font(.caption2)
                .padding(.horizontal, 3)
                .padding(.vertical, 3)
        }
        .frame(width: 52)
        .background(self.zoomTextBgColor)
        .clipShape(RoundedRectangle(cornerRadius: 4))

    }

    @ViewBuilder
    var toolbarContentView: some View {
        HStack(spacing: 8) {
            btn(self.vm.isLocked ? "lock.fill" : "lock") {
                self.dispatch?(.toggleLock)
            }
            .disabled(self.vm.lockButtonDisabled)

            VDivider()

            btn(self.vm.dockLocation == .down ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle")
            {
                self.dispatch?(.dockOpposite)
            }

            btn("pip.enter") {
                self.dispatch?(.undock)
            }

            Spacer()

            Spacer()

            btn("square.and.arrow.down") {
            }
        }
        .overlay(alignment: .center) {
            HStack(spacing: 8) {
                Group {
                    btn("plus.magnifyingglass") {
                        self.action = .zoomIn(animate: true)
                    }

                    btn("minus.magnifyingglass") {
                        self.action = .zoomOut(animate: true)
                    }

                    self.zoomLabel

                    btn("1.magnifyingglass") {
                        self.action = .actualSize(animate: true)
                    }

                    btn("arrow.up.left.and.down.right.magnifyingglass") {
                        self.action = .zoomToFit(animate: true)
                    }
                }
            }
        }
    }

    @MainActor
    private func btn(_ icon: String, action: @escaping () -> ()) -> some View {
        Button {
            action()
        } label: {
            Image(systemName: icon)
        }
        .buttonStyle(.plain)
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()
