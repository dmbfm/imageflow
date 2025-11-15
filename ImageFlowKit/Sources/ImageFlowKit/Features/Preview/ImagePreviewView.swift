import CIImageView
@preconcurrency import CoreImage
@preconcurrency import CoreImage.CIFilterBuiltins
import Logging
import SwiftUI
import Values

struct ImagePreviewView: View {

    var state: PreviewState = .contentUnavailable(nil)

    @Binding private var isLocked: Bool

    @State private var size: ImagePreviewSizeIter = .init(.medium)
    @State private var hover: Bool = false

    var showFileExporter: Bool {
        self.state.isLoaded
    }

    enum PreviewState: Equatable {
        case contentUnavailable(ContentUnavailable?)
        case loading
        case loaded(CIImage)

        var isLoaded: Bool {
            if case .loaded = self { true } else { false }
        }

        struct ContentUnavailable: Equatable {
            var systemImage: String
            var message: String
        }
    }

    struct Delegate {
        var onTapCard: () -> ()
        var openInNewWindow: () -> ()
        var export: () -> ()
    }

    var delegate: Delegate?

    init(
        _ state: PreviewState = .contentUnavailable(nil),
        initialSize: ImagePreviewSize = .medium,
        isLocked: Binding<Bool>,
    ) {
        self.state = state
        self._size = .init(wrappedValue: .init(initialSize))
        self._isLocked = isLocked
    }

    func tapCardHandler() {
        if self.size.current == .small {
            self.nextSize()
        }
        self.delegate?.onTapCard()
    }

    func toolbarResizeHandler() {
        self.nextSize()
    }

    func toolbarSaveHandler() {
        self.delegate?.export()
    }

    func toolbarOpenInNewWindowHandler() {
        self.delegate?.openInNewWindow()
    }

    func nextSize() {
        withAnimation {
            self.size.step()
        }
    }

    var body: some View {
        self.mainView
    }

    var mainView: some View {
        CardView {
            BackgroundView(hasImage: self.state.isLoaded)
        } content: {
            ContentView(state: self.state, size: self.size.current)
        } toolbar: {
            ToolbarView(
                isLocked: self.$isLocked,
                hasImage: self.state.isLoaded,
                saveButtonAction: {},
                launchWindowButtonAction: {},
                resizeButtonAction: { self.toolbarResizeHandler() }
            )
        }
        .cardViewSize(self.size.current.size)
        .cardViewToolbarVisibility(self.size.current == .small ? .hidden : .visible)
        .onTapGesture { self.tapCardHandler() }
    }
}

extension ImagePreviewView {

    struct BackgroundView: View {

        @Environment(\.colorScheme) var colorScheme

        var noImageBgColor: Color {
            if self.colorScheme == .dark {
                .black
            } else {
                .white
            }
        }
        let hasImage: Bool
        var body: some View {
            self.hasImage ? Colors.imagePreviewBackground.color : self.noImageBgColor
        }
    }
}

extension ImagePreviewView {
    struct ContentView: View {
        let state: PreviewState
        let size: ImagePreviewSize

        var body: some View {
            switch self.state {
            case .contentUnavailable(.some(let data)):
                self.contentUnavailableView(data)
            case .contentUnavailable(.none):
                EmptyView()
            case .loaded(let image):
                CIImageView(image: image, resizeMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .loading:
                self.loadingView
            }
        }

        @ViewBuilder
        func contentUnavailableView(_ data: PreviewState.ContentUnavailable) -> some View {
            if self.size != .small {
                VStack {
                    Spacer()
                    ContentUnavailableView(data.message, systemImage: data.systemImage)
                    Spacer()
                }
            }
        }

        var loadingView: some View {
            Image(systemName: "ellipsis")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .symbolEffect(.breathe, options: .speed(2))
                .padding(30)
        }
    }
}
fileprivate struct ToolbarView: View {
    @Binding var isLocked: Bool

    let hasImage: Bool
    let saveButtonAction: () -> ()
    let launchWindowButtonAction: () -> ()
    let resizeButtonAction: () -> ()

    var body: some View {
        HStack {}.padding(.trailing, 2)

        Button {
            self.isLocked.toggle()
        } label: {
            Image(systemName: self.isLocked ? "lock.fill" : "lock.open")
        }
        .buttonStyle(.accessoryBar)
        .if(!self.hasImage) { view in view.hidden() }

        Button {
            self.saveButtonAction()
        } label: {
            Image(systemName: "square.and.arrow.down")
        }
        .buttonStyle(.accessoryBar)
        .if(!self.hasImage) { view in view.hidden() }

        Spacer()

        Button {
            self.launchWindowButtonAction()
        } label: {
            Image(systemName: "rectangle.on.rectangle")
        }
        .buttonStyle(.accessoryBar)
        .if(!self.hasImage) { view in view.hidden() }

        Button {
            self.resizeButtonAction()
        } label: {
            Image(systemName: "arrow.up.left.and.arrow.down.right.rectangle.fill")
        }
        .buttonStyle(.accessoryBar)

        HStack {}
            .padding(.trailing, 2)
    }
}

fileprivate struct PreviewContainer<Content: View>: View {
    let content: () -> Content
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    self.content()
                }
                .padding(.bottom, 50)
                .padding(.trailing, 50)
            }
        }
        .frame(minWidth: 500, minHeight: 500)
    }
}

#Preview("Default") {
    PreviewContainer {
        ImagePreviewView(isLocked: .constant(false))
    }
}

#Preview("With Image") {
    PreviewContainer {
        ImagePreviewView(.loaded(.blue.cropped(to: .init(x: 0, y: 0, width: 512, height: 512))), initialSize: .medium, isLocked: .constant(false))
    }
}
