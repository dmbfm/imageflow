import CIImageView
import SwiftUI

struct TouchImagePreviewView: View {

    // var image: CIImage? = nil
    let state: ImagePreviewView.PreviewState

    @Binding var isLocked: Bool

    @State var size: CGSize = .init(width: 300, height: 300)
    @State var toolbarVisible: Bool = true

    @Namespace var ns

    func toggleToolbar() {
        withAnimation(.bouncy.speed(2)) {
            self.toolbarVisible.toggle()
        }
    }

    var image: CIImage? {
        switch self.state {
        case .loaded(let image): image
        default: nil
        }
    }

    var body: some View {
        if let image = self.image {
            TouchCardViewContainer(padding: .init(width: 40, height: 40)) {
                TouchCardView(size: self.$size) {
                    Rectangle()
                        .fill(.gray.gradient)
                } content: {
                    ZStack {
                        Color.clear
                        CIImageView(image: image)
                            .placement(.fit)
                    }
                } toolbar: {
                    if self.toolbarVisible {
                        self.toolbarView
                    }
                } onTap: {
                    self.toggleToolbar()
                } onSizeChange: { size in
                    let range: ClosedRange<CGFloat> = 150.0...400.0
                    return .init(width: size.width.clamped(to: range), height: size.height.clamped(to: range))
                }
            }
        }
    }

    var toolbarView: some View {
        HStack {
            GlassEffectContainer {
                HStack {
                    Button {
                    } label: {
                        Image(systemName: "lock")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .glassEffectUnion(id: "top-left", namespace: self.ns)

                    Button {
                    } label: {
                        Image(systemName: "square.and.arrow.down.fill")
                    }
                    .buttonStyle(ToolbarButtonStyle())
                    .glassEffectUnion(id: "top-left", namespace: self.ns)
                }
            }
            .glassEffect(.regular.interactive())

            Spacer()
            if self.size.width >= 300 {
                GlassEffectContainer {
                    HStack {
                        Button {
                        } label: {
                            Image(systemName: "inset.filled.bottomhalf.rectangle")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .glassEffectUnion(id: "top-left", namespace: self.ns)

                        Button {
                        } label: {
                            Image(systemName: "inset.filled.tophalf.rectangle")
                        }
                        .buttonStyle(ToolbarButtonStyle())
                        .glassEffectUnion(id: "top-left", namespace: self.ns)
                    }
                }
                .glassEffect(.regular.interactive())
            }
            Spacer()

            Button {
            } label: {
                Image(systemName: "xmark")
            }
            .buttonStyle(ToolbarButtonStyle())
            .glassEffect(.regular.interactive(), in: Circle())
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
    }
}

private struct ToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .bold()
            .foregroundStyle(.secondary)
            .padding(10)
    }
}

extension Previews {
    public struct TouchCardPreviewPreview: View {
        @State var image: CIImage?
        @State var isLocked: Bool = false

        var state: ImagePreviewView.PreviewState {
            if let image = self.image {
                .loaded(image)
            } else {
                .loading
            }
        }

        public init() {}

        func toggleImage() {
            if self.image != nil {
                self.image = nil
            } else {
                self.image = .blue.cropped(to: .init(origin: .zero, size: .init(width: 256, height: 256)))
            }
        }

        public var body: some View {
            VStack {
                ZStack {
                    Color.clear
                    TouchImagePreviewView(state: self.state, isLocked: self.$isLocked)
                }
                Button(self.image == nil ? "Load" : "Unload") {
                    self.toggleImage()
                }
                .onAppear { self.toggleImage() }
            }
        }
    }
}

#Preview {
    Previews.TouchCardPreviewPreview()
}
