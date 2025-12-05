import CIImageView
import Logging
import SwiftUI

struct TouchImagePreviewFeatureView: View {

    let flow: Flow
    let assetStore: AssetStore

    @State var vm: ImagePreviewFeatureViewModel

    var state: ImagePreviewView.PreviewState {
        self.vm.previewState
    }

    @State var size: CGSize = .init(width: 300, height: 300)
    @State var toolbarVisible: Bool = true

    @Namespace var ns

    internal init(flow: Flow, assetStore: AssetStore) {
        self.flow = flow
        self.assetStore = assetStore
        self._vm = .init(wrappedValue: .init(flow: flow, assetStore: assetStore))
    }

    func toggleToolbar() {
        withAnimation {
            self.toolbarVisible.toggle()
        }
    }

    var image: CIImage? {
        switch self.state {
        case .loaded(let image): image
        default: nil
        }
    }

    var showToolbarMiddle: Bool {
        self.size.width > 250
    }

    private func controlsAction(_ name: ControlsView.ControlName) {
        switch name {
        case .lock:
            self.vm.isLocked.toggle()
        case .close:
            withAnimation {
                self.vm.hide()
            }
        default:
            break
        }
    }

    func onSizeChange(_ size: CGSize) -> CGSize {
        let range: ClosedRange<CGFloat> = 150.0...400.0
        return .init(width: size.width.clamped(to: range), height: size.height.clamped(to: range))
    }

    var body: some View {
        if let image = self.image, self.vm.isVisible {
            TouchCardViewContainer(padding: .init(width: 40, height: 40)) {
                TouchCardView(size: self.$size) {
                    ZStack {
                        Rectangle()
                            .fill(.gray.gradient)

                        CIImageView(image: image)
                            .placement(.fit)

                        ControlsView(
                            isLocked: self.vm.isLocked,
                            visible: self.toolbarVisible,
                            showToolbarMiddle: self.showToolbarMiddle,
                            action: self.controlsAction(_:)
                        )
                    }
                    .onTapGesture {
                        self.toggleToolbar()
                    }
                } onSizeChange: { size in
                    self.onSizeChange(size)
                }
            }
        }
    }
}

private struct ControlsView: View, @MainActor Equatable {
    static func == (lhs: ControlsView, rhs: ControlsView) -> Bool {
        lhs.isLocked == rhs.isLocked && lhs.visible == rhs.visible && lhs.showToolbarMiddle == rhs.showToolbarMiddle
    }

    var isLocked: Bool
    var visible: Bool
    var showToolbarMiddle: Bool
    var size: CGFloat = 36
    var action: (ControlName) -> ()

    @Namespace var ns

    enum ControlName {
        case lock
        case export
        case dockDown
        case dockUp
        case close
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.clear

            VStack(spacing: 0) {

                self.topView
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background {
                        Color.clear
                            .contentShape(Rectangle())
                    }
            }
        }
    }

    @ViewBuilder
    var topView: some View {
        HStack {
            self.topLeftView
            Spacer()
            self.topMiddleView
            Spacer()
            self.topRightView
        }
    }

    @ViewBuilder
    var topLeftView: some View {
        GlassEffectContainer {
            HStack {
                if self.visible {
                    CircleGlassIconButton(self.isLocked ? "lock.fill" : "lock", size: size) { self.action(.lock) }
                        .glassEffectUnion(id: "left", namespace: self.ns)
                    CircleGlassIconButton("square.and.arrow.down", size: size) { self.action(.export) }
                        .glassEffectUnion(id: "left", namespace: self.ns)
                }
            }
        }
    }

    @ViewBuilder
    var topMiddleView: some View {
        GlassEffectContainer {
            HStack {
                if self.visible && self.showToolbarMiddle {
                    CircleGlassIconButton("inset.filled.bottomhalf.rectangle", size: size) { self.action(.dockDown) }
                        .glassEffectUnion(id: "middle", namespace: self.ns)
                    CircleGlassIconButton("inset.filled.tophalf.rectangle", size: size) { self.action(.dockUp) }
                        .glassEffectUnion(id: "middle", namespace: self.ns)
                }
            }
        }
    }

    @ViewBuilder
    var topRightView: some View {
        GlassEffectContainer {
            HStack {
                if self.visible {
                    CircleGlassIconButton("xmark", size: size) {
                        self.action(.close)
                    }
                }
            }
        }
    }

}

extension Previews {
    public struct TouchCardPreviewPreview: View {
        public var body: some View {}
        // @State var image: CIImage?
        // @State var isLocked: Bool = false

        // var state: ImagePreviewView.PreviewState {
        //     if let image = self.image {
        //         .loaded(image)
        //     } else {
        //         .loading
        //     }
        // }

        // public init() {}

        // func toggleImage() {
        //     if self.image != nil {
        //         self.image = nil
        //     } else {
        //         self.image = .blue.cropped(to: .init(origin: .zero, size: .init(width: 256, height: 256)))
        //     }
        // }

        // public var body: some View {
        //     VStack {
        //         ZStack {
        //             Color.clear
        //             TouchImagePreviewView(state: self.state, isLocked: self.$isLocked)
        //         }
        //         Button(self.image == nil ? "Load" : "Unload") {
        //             self.toggleImage()
        //         }
        //         .onAppear { self.toggleImage() }
        //     }
        // }
    }
}

#Preview {
    Previews.TouchCardPreviewPreview()
}
