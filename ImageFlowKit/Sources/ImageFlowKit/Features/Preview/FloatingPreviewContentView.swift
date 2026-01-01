import CIImageView
import Controls
import CoreImage
import CoreImage.CIFilterBuiltins
import Helpers
import SwiftUI

protocol PlatformConditional {
    static func when(macos: Self, ios: Self) -> Self
}

extension PlatformConditional {
    static func when(macos: Self, ios: Self) -> Self {
        #if os(macOS)
        macos
        #else
        ios
        #endif
    }
}

extension CGFloat: PlatformConditional {}
extension Optional: PlatformConditional {}

public struct FloatingPreviewContentView: View {
    let vm: PreviewContentViewModel
    let dispatch: ((PreviewContentViewAction) -> ())?

    @State private var width: CGFloat = 0
    @State private var controlsVisible = false

    @Environment(\.colorScheme) private var cs

    private let widthToHideControls: CGFloat = .when(macos: 200, ios: 200)

    init(vm: PreviewContentViewModel, dispatch: @escaping (PreviewContentViewAction) -> ()) {
        self.vm = vm
        self.dispatch = dispatch
    }

    enum Name: Hashable {
        case lock
        case export
        case dockDown
        case dockUp
        case openWindow

        var action: PreviewContentViewAction {
            switch self {
            case .lock: .toggleLock
            case .export: .export
            case .dockDown: .dockDown
            case .dockUp: .dockUp
            case .openWindow: .openWindow
            }
        }
    }

    private var showControls: Bool {
        self.width > self.widthToHideControls
    }

    #if os(macOS)
    private var middleItems: PreviewToolbarElement<Name> {
        .trio(
            id: "middle",
            .init(id: .dockDown, icon: "inset.filled.bottomhalf.rectangle"),
            .init(id: .dockUp, icon: "inset.filled.tophalf.rectangle"),
            .init(id: .openWindow, icon: "macwindow.on.rectangle"),
        )
    }
    #endif

    #if os(iOS)
    private var middleItems: PreviewToolbarElement<Name> {
        .pair(
            id: "middle",
            .init(id: .dockDown, icon: "inset.filled.bottomhalf.rectangle"),
            .init(id: .dockUp, icon: "inset.filled.tophalf.rectangle"),
        )
    }
    #endif

    private var toolbar: [PreviewToolbarElement<Name>] {
        [
            .item(
                .init(id: .lock, icon: self.vm.locked ? "lock.fill" : "lock"),
            ),
            .spacer,
            self.middleItems,
            .spacer,
            .item(
                .init(id: .export, icon: "square.and.arrow.down"),
            ),
        ]
    }

    func onHover(_ value: Bool) {
        if self.controlsVisible != value {
            withAnimation(.default.speed(2)) {
                self.controlsVisible = value
            }
        }
    }

    func onTap() {
        withAnimation {
            self.controlsVisible.toggle()
        }
    }

    public var body: some View {
        ZStack(alignment: .center) {
            Rectangle()
                .fill(cs == .light ? Color(white: 0.94) : Color(white: 0.06))
            self.contentView

            if self.showControls {
                ControlsView(vm: self.vm, elements: self.toolbar, visible: self.controlsVisible) {
                    self.dispatch?($0.action)
                } pick: {
                    self.dispatch?(.pick($0))
                }
            }
        }
        .onGeometryChange(for: CGFloat.self, of: { $0.size.width }) { value in self.width = value }
        #if os(macOS)
        .onHover(perform: self.onHover(_:))
        #else
        .onTapGesture(perform: self.onTap)
        #endif
    }

    @ViewBuilder
    var contentView: some View {
        switch self.vm.state {
        case .loaded(_, _, let image), .loading(_, _, .some(let image)):
            CIImageView(image: image)
                .placement(.fit)
        case .nothing:
            ContentUnavailableView("No Image!", systemImage: "photo.badge.exclamationmark.fill")
        default:
            ContentUnavailableView("Loading...", systemImage: "timelapse")
        }
    }
}

private struct ControlsView<ID: PreviewToolbarElementID>: View {

    let vm: PreviewContentViewModel
    let elements: [PreviewToolbarElement<ID>]
    var visible: Bool = true
    var handler: (ID) -> ()
    var pick: (OutputPortLocation) -> ()

    @State var current: OutputPortLocation? = nil
    @Namespace var ns

    var body: some View {
        ZStack {
            PreviewToolbarView(elements: self.elements, visible: self.visible, handler: self.handler)

            ZStack(alignment: .bottom) {
                Color.clear
                GlassEffectContainer {
                    VStack {
                        if self.visible && self.vm.available.count >= 2 {
                            #if os(macOS)
                            HStack(spacing: 2) {
                                Image(systemName: "photo.stack.fill")

                                Picker(
                                    "",
                                    selection: self.$current,
                                ) {
                                    ForEach(Array(self.vm.available), id: \.self) { item in
                                        Text("\(item.name)")
                                            .tag(item.location)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                            .padding(.trailing, 4)
                            .padding(.leading, 6)
                            .glassEffect(.regular.interactive(), in: RoundedRectangle(cornerRadius: 8))
                            .glassEffectUnion(id: "picker", namespace: self.ns)
                            #else
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
                            .glassEffectUnion(id: "picker", namespace: self.ns)
                            #endif
                        }
                    }
                    .frame(width: 200)
                    .padding(.bottom, 12)
                }
            }
        }
        .onChange(of: self.vm.currentLocation, initial: true) {
            self.current = self.vm.currentLocation
        }
        .onChange(of: self.current) {
            if let current = self.current, current != self.vm.currentLocation {
                self.pick(current)
            }
        }
    }
}

private enum ToolbarElement<ID: Equatable> {
    case spacer
    case item(Item)
    case pair(id: String, Item, Item)

    struct Item: Equatable {
        var id: ID
        var icon: String

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
}

// MARK: - Previews

private let previewImage: CIImage = {
    let gaussianGradient = CIFilter.gaussianGradient()
    gaussianGradient.center = CGPoint(x: 200, y: 150)
    gaussianGradient.color0 = CIColor(red: 88 / 255, green: 201 / 255, blue: 175 / 255)
    gaussianGradient.color1 = CIColor(red: 153 / 255, green: 153 / 255, blue: 204 / 255)
    gaussianGradient.radius = 150
    let bg = gaussianGradient.outputImage!.cropped(to: .init(x: 0, y: 0, width: 400, height: 300))
    let attributedTextImageFilter = CIFilter.attributedTextImageGenerator()
    attributedTextImageFilter.text = NSAttributedString(string: "Hello world! 👋")
    attributedTextImageFilter.scaleFactor = 3
    attributedTextImageFilter.padding = 5
    return attributedTextImageFilter.outputImage!.transformed(by: .init(translationX: 0, y: 200)).composited(over: bg)
}()

extension FloatingPreviewContentView {
    struct Preview: View {

        let vm: PreviewContentViewModel

        var body: some View {
            FloatingPreviewContentView(vm: vm) { print($0) }
                .frame(width: 300, height: 300)
                .clipShape(RoundedRectangle(cornerRadius: CardStageCardStyle.default.cornerRadius))
                .shadow(radius: 4)
                .padding(80)
                .background {
                    Colors.canvasBackground.color
                }
        }
    }
}

#Preview("Image") {
    let loc = OutputPortLocation(node: .init(), index: 0)
    let vm = PreviewContentViewModel(
        available: [.init(location: loc, name: "Name")],
        state: .loaded(false, loc, previewImage)
    )!
    FloatingPreviewContentView.Preview(vm: vm)
}

#Preview("Loading") {
    let loc = OutputPortLocation(node: .init(), index: 0)
    let vm = PreviewContentViewModel(
        available: [.init(location: loc, name: "Name")],
        state: .loading(false, loc, previewImage)
    )!
    FloatingPreviewContentView.Preview(vm: vm)
}

#Preview("Unavailable") {
    let vm = PreviewContentViewModel(
        available: [],
        state: .nothing,
    )!
    FloatingPreviewContentView.Preview(vm: vm)
}
