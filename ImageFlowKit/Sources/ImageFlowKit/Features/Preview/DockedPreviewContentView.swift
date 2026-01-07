import CIImageView
import Controls
import CoreImage
import Helpers
import Logging
import SwiftUI

struct DockedPreviewContentView: View {

    let vm: PreviewContentViewModel
    let dockLocation: CardDockLocation
    let style: Style
    let cache: (any CIImageScrollViewCache)?
    var dispatch: ((PreviewContentViewAction) -> ())?

    @State var zoom: CGFloat = 1.0
    @State var action: CIImageScrollView.Action? = nil

    @ObservableState var menuCoordinator: DockedPreviewMenuActionCoordinator = .init()

    @Environment(\.colorScheme) var cs

    let bgColor: Color = Colors.canvasBackground.color
    let toolbarHeight: CGFloat = 26.0

    enum Style {
        case glass
        case classic
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        if self.vm.image != nil {
            zoomFormatter.string(for: self.zoom)!
        } else {
            ""
        }
    }

    func menuAction() {
        switch self.menuCoordinator.action {
        case .none:
            break
        case .zoomIn:
            self.action = .zoomIn(animate: true)
        case .zoomOut:
            self.action = .zoomOut(animate: true)
        case .actualSize:
            self.action = .actualSize(animate: true)
        case .zoomToFit:
            self.action = .zoomToFit(animate: true)
        }
        self.menuCoordinator.action = .none
    }

    var body: some View {
        self._body
            .focusedSceneValue(self.menuCoordinator)
            .onChange(
                of: self.menuCoordinator.action,
                initial: false,
                {
                    log("action: \(self.menuCoordinator.action)", level: .debug)
                    Task { @MainActor in
                        self.menuAction()
                    }
                }
            )
    }

    @ViewBuilder
    var _body: some View {
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
            if self.dockLocation == .up {
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
            dockLocation: self.dockLocation,
            zoom: self.$zoom,
            action: self.$action,
            dispatch: self.dispatch
        )
    }

    @ViewBuilder
    var glassBody: some View {
        VStack(spacing: 0) {
            if self.dockLocation == .down {
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
                        dockLocation: self.dockLocation,
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
                        dockLocation: self.dockLocation,
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

    func zoomDidChange(_ value: CGFloat) {
        self.zoom = value
    }

    @ViewBuilder
    var contentView: some View {
        switch vm.state {
        case .loaded(_, let loc, let image), .loading(_, let loc, .some(let image)):
            CIImageScrollView(
                id: "\(loc.node),\(loc.index)",
                image: image,
                configuration: .init(),
                action: self.$action,
                cache: self.cache,
                zoomDidChange: self.zoomDidChange(_:),
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
    var dockLocation: CardDockLocation
    @Binding var zoom: CGFloat
    @Binding var action: CIImageScrollView.Action?
    var dispatch: ((PreviewContentViewAction) -> ())?
    let toolbarHeight: CGFloat = 26.0
    let bgColor: Color = Colors.canvasBackground.color

    static var toolbarPlacement: DockedPreviewToolbarPlacement = .zstack

    init(
        vm: PreviewContentViewModel,
        dockLocation: CardDockLocation,
        zoom: Binding<CGFloat>,
        action: Binding<CIImageScrollView.Action?>,
        dispatch: ((PreviewContentViewAction) -> ())? = nil,
    ) {
        self.vm = vm
        self.dockLocation = dockLocation
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

    var zoomText: String {
        if self.vm.image != nil {
            zoomFormatter.string(for: self.zoom)!
        } else {
            ""
        }
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
                .init(id: .lock, icon: self.vm.locked ? "lock.fill" : "lock", disabled: self.vm.image == nil),
                .init(
                    id: .dockSwitch,
                    icon: self.dockLocation == .down
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
                self.zoomText,
                .init(id: .zoomActual, icon: "1.magnifyingglass"),
                .init(id: .zoomFit, icon: "arrow.up.left.and.down.right.magnifyingglass"),
            ),
            .spacer,
        ]
    }

    var alignment: Alignment {
        if self.dockLocation == .down {
            .top
        } else {
            .bottom
        }
    }

    var paddingAxis: SwiftUI.Edge.Set {
        if self.dockLocation == .down {
            .top
        } else {
            .bottom
        }
    }

    var body: some View {
        ZStack(alignment: self.alignment) {
            let padding: CGFloat = 8

            self.leftToolbarView
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
        .onChange(of: self.vm.currentLocation, initial: true) {
            self.current = self.vm.currentLocation
        }
        .onChange(of: self.current, initial: false) {
            if let current = self.current, self.vm.currentLocation != current {
                self.dispatch?(.pick(current))
            }
        }
    }

    private let buttonSize: CGFloat = .when(macos: 28.0, ios: 36.0)
    private let pairSpacing: CGFloat? = .when(macos: 0.0, ios: nil)
    private let visible: Bool = true
    @Namespace var ns

    @State var current: OutputPortLocation? = nil

    @ViewBuilder
    var leftToolbarView: some View {
        ZStack(alignment: self.alignment) {
            Color.clear
            HStack {
                GlassEffectContainer {
                    HStack(spacing: self.pairSpacing) {
                        if self.visible {
                            CircleGlassIconButton(self.vm.locked ? "lock.fill" : "lock") { self.handle(.lock) }
                                .disabled(self.vm.image == nil)
                                .glassEffectUnion(id: "window-group", namespace: self.ns)

                            CircleGlassIconButton(
                                self.dockLocation == .down
                                    ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle"
                            ) { self.handle(.dockSwitch) }
                            .glassEffectUnion(id: "window-group", namespace: self.ns)

                            CircleGlassIconButton("pip.enter") { self.handle(.undock) }
                                .glassEffectUnion(id: "window-group", namespace: self.ns)

                            Spacer()

                            if self.vm.available.count >= 2 {
                                HStack {
                                    Image(systemName: "photo.stack.fill")
                                        .padding(.leading, 8)

                                    Picker("", systemImage: "photo.stack.fill", selection: self.$current) {
                                        ForEach(Array(self.vm.available), id: \.self) { item in
                                            Text("\(item.name)")
                                                .tag(item.location)
                                        }
                                    }
                                }
                                .glassEffect(.regular.interactive(), in: .capsule)
                                .glassEffectUnion(id: "picker-group", namespace: self.ns)
                            }

                            CircleGlassIconButton("square.and.arrow.down") { self.handle(.export) }
                                .glassEffectUnion(id: "export-group", namespace: self.ns)
                        }
                    }
                }

                Spacer()

                GlassEffectContainer {}

            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            .circleGlassButtonSize(self.buttonSize)
        }
    }
}

struct ClassicToolbarView: View {

    var vm: PreviewContentViewModel
    var dockLocation: CardDockLocation
    @Binding var zoom: CGFloat
    @Binding var action: CIImageScrollView.Action?
    var dispatch: ((PreviewContentViewAction) -> ())?
    let toolbarHeight: CGFloat = 26.0
    let bgColor: Color = Colors.canvasBackground.color

    @Environment(\.colorScheme) var cs

    static var toolbarPlacement: DockedPreviewToolbarPlacement = .vstack

    init(
        vm: PreviewContentViewModel,
        dockLocation: CardDockLocation,
        zoom: Binding<CGFloat>,
        action: Binding<CIImageScrollView.Action?>,
        dispatch: ((PreviewContentViewAction) -> ())? = nil
    ) {
        self.vm = vm
        self._zoom = zoom
        self._action = action
        self.dispatch = dispatch
        self.dockLocation = dockLocation
    }

    var zoomTextBgColor: Color {
        .init(white: cs == .dark ? 0.18 : 0.82)
    }

    var zoomText: String {
        if self.vm.image != nil {
            zoomFormatter.string(for: self.zoom)!
        } else {
            ""
        }
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
        .onChange(of: self.vm.currentLocation, initial: true) {
            self.currentLocation = self.vm.currentLocation
        }
        .onChange(of: self.currentLocation) {
            if let loc = self.currentLocation, loc != self.vm.currentLocation {
                self.dispatch?(.pick(loc))
            }
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

    @State var currentLocation: OutputPortLocation? = nil

    @ViewBuilder
    var toolbarContentView: some View {
        HStack(spacing: 8) {
            btn(self.vm.locked ? "lock.fill" : "lock") {
                self.dispatch?(.toggleLock)
            }
            .disabled(self.vm.image == nil)

            VDivider()

            btn(self.dockLocation == .down ? "inset.filled.tophalf.rectangle" : "inset.filled.bottomhalf.rectangle") {
                self.dispatch?(.dockOpposite)
            }

            btn("macwindow.on.rectangle") {
                self.dispatch?(.openWindow)
            }
            .disabled(self.vm.image == nil)

            btn("pip.enter") {
                self.dispatch?(.undock)
            }

            Spacer()

            Spacer()

            if self.vm.available.count >= 2 {
                Image(systemName: "photo.stack.fill")
                    .padding(.trailing, -6)
                Picker("", selection: self.$currentLocation) {
                    ForEach(Array(self.vm.available), id: \.self) { item in
                        Text("\(item.name)")
                            .tag(item.location)
                    }
                }
            }

            VDivider()

            btn("square.and.arrow.down") {
                self.dispatch?(.export)
            }
            .disabled(self.vm.image == nil)
        }
        .overlay(alignment: .center) {
            HStack(spacing: 8) {
                Group {
                    btn("plus.magnifyingglass") {
                        self.action = .zoomIn(animate: true)
                    }
                    .disabled(self.vm.image == nil)

                    btn("minus.magnifyingglass") {
                        self.action = .zoomOut(animate: true)
                    }
                    .disabled(self.vm.image == nil)

                    self.zoomLabel

                    btn("1.magnifyingglass") {
                        self.action = .actualSize(animate: true)
                    }
                    .disabled(self.vm.image == nil)

                    btn("arrow.up.left.and.down.right.magnifyingglass") {
                        self.action = .zoomToFit(animate: true)
                    }
                    .disabled(self.vm.image == nil)
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

@Observable
class DockedPreviewMenuActionCoordinator {

    var action: MenuAction = .none

    enum MenuAction {
        case none
        case zoomIn
        case zoomOut
        case actualSize
        case zoomToFit
    }
}

private let zoomFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .percent
    return f
}()
