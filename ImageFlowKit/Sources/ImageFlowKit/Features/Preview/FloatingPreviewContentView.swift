import CIImageView
import Controls
import CoreImage
import CoreImage.CIFilterBuiltins
import Helpers
import SwiftUI

enum PreviewContent {
    case unavailable
    case image(CIImage)
    case loading
}

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

        var action: PreviewContentViewAction {
            switch self {
            case .lock: .toggleLock
            case .export: .export
            case .dockDown: .dockDown
            case .dockUp: .dockUp
            }
        }
    }

    private var showControls: Bool {
        self.width > self.widthToHideControls
    }

    private var toolbar: [ToolbarElement<Name>] {
        [
            .item(
                .init(id: .lock, icon: self.vm.isLocked ? "lock.fill" : "lock"),
            ),
            .spacer,
            .pair(
                id: "middle",
                .init(id: .dockDown, icon: "inset.filled.bottomhalf.rectangle"),
                .init(id: .dockUp, icon: "inset.filled.tophalf.rectangle")
            ),
            .spacer,
            .item(.init(id: .export, icon: "square.and.arrow.down")),
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
                ControlsView(elements: self.toolbar, visible: self.controlsVisible) { self.dispatch?($0.action) }
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
        switch self.vm.content {
        case .image(let image):
            CIImageView(image: image)
                .placement(.fit)
        case .unavailable:
            ContentUnavailableView("No Image!", systemImage: "photo.badge.exclamationmark.fill")
        case .loading:
            ContentUnavailableView("Loading...", systemImage: "timelapse")
        }
    }
}

private struct ControlsView<ID: Sendable & Hashable>: View {

    let elements: [ToolbarElement<ID>]
    var visible: Bool = true
    var handler: (ID) -> ()
    private let buttonSize: CGFloat = .when(macos: 28.0, ios: 36.0)
    private let pairSpacing: CGFloat? = .when(macos: 0.0, ios: nil)

    @Namespace var ns

    var body: some View {
        let els = elements.enumerated()
        ZStack(alignment: .topLeading) {
            Color.clear
            HStack {
                ForEach(els, id: \.offset) { _, el in
                    self.viewForElement(el)
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 8)
            .circleGlassButtonSize(self.buttonSize)
        }
    }

    @ViewBuilder
    func viewForElement(_ el: ToolbarElement<ID>) -> some View {
        switch el {
        case .spacer: Spacer()
        case .item(let item):
            GlassEffectContainer {
                HStack {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(item.icon) { self.handler(item.id) }
                        #else
                        Button {
                            self.handler(item.id)
                        } label: {
                            Image(systemName: item.icon)
                        }
                        .buttonStyle(.glass)
                        #endif
                    }
                }
            }
        case .pair(let id, let a, let b):
            GlassEffectContainer {
                HStack(spacing: self.pairSpacing) {
                    if self.visible {
                        #if os(iOS)
                        CircleGlassIconButton(a.icon) { self.handler(a.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)

                        CircleGlassIconButton(b.icon) { self.handler(b.id) }
                            .glassEffectUnion(id: id, namespace: self.ns)
                        #else
                        Button {
                            self.handler(a.id)
                        } label: {
                            Image(systemName: a.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)

                        Button {
                            self.handler(b.id)
                        } label: {
                            Image(systemName: b.icon)
                        }
                        .buttonStyle(.glass)
                        .glassEffectUnion(id: id, namespace: self.ns)
                        #endif
                    }
                }
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
    let vm = PreviewContentViewModel(content: .image(previewImage), isLocked: false, lockButtonDisabled: false)
    FloatingPreviewContentView.Preview(vm: vm)
}

#Preview("Loading") {
    let vm = PreviewContentViewModel(content: .loading, isLocked: false, lockButtonDisabled: false)
    FloatingPreviewContentView.Preview(vm: vm)
}

#Preview("Unavailable") {
    let vm = PreviewContentViewModel(content: .unavailable, isLocked: false, lockButtonDisabled: false)
    FloatingPreviewContentView.Preview(vm: vm)
}
