import Logging
import SwiftUI
import UniformTypeIdentifiers

protocol AssetBrowserAssetsProvider: AssetBrowserThumbProvider {
    @MainActor var fileAssets: [ImageAsset] { get }
}

extension AssetStore: AssetBrowserAssetsProvider {}

enum AssetBrowserType: Equatable {
    case picker(PortLocation)
    case browser
}

enum AssetBrowserResult {
    case cancel
    case pick(UUID)
    case create(UUID)
}

struct AssetBrowserView: View {
    let assetsProvider: any AssetBrowserAssetsProvider
    let type: AssetBrowserType
    let gridImageSize: CGFloat = 146.0
    let delegate: Delegate

    struct Delegate {
        var onDismiss: (AssetBrowserResult) -> ()
        var openFileImporter: () -> ()
        var openPhotoPicker: () -> ()
    }

    @State var showFileImporter = false
    @State var selected: UUID? = nil
    @State var createNodeOnSelect: Bool = false

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    init(
        type: AssetBrowserType = .browser,
        assetsProvider: any AssetBrowserAssetsProvider,
        delegate: Delegate,
    ) {
        self.type = type
        self.assetsProvider = assetsProvider
        self.delegate = delegate
    }

    var sortedImages: [ImageAsset] {
        self.assetsProvider.fileAssets.sorted(by: { $0.added < $1.added })
    }

    func onTapItem(_ info: ImageAsset) {
        switch info.state {
        case .loaded:
            self.selected = info.id
        case .loading:
            break
        }
    }

    var body: some View {
        self.content
            .frame(width: 800, height: 600)
    }

    @ViewBuilder
    var content: some View {
        VStack {

            self.toolbarView

            self.scrollabeImageGridView
                .onTapGesture {
                    self.selected = nil
                }

            Spacer()

            self.footerView

        }
        #if os(macOS)
        .onModifierKeysChanged({ old, new in
            if self.type == .browser {
                self.createNodeOnSelect = new == .command
            }
        })
        #endif
    }

    @ViewBuilder
    var toolbarView: some View {
        HStack(alignment: .center) {
            Button {
                self.delegate.openFileImporter()
            } label: {
                Image(systemName: "square.and.arrow.down")
            }
            .buttonStyle(.borderless)

            Button {
                self.delegate.openPhotoPicker()
            } label: {
                Image(systemName: "photo.badge.plus.fill")
            }
            .buttonStyle(.borderless)

            Spacer()
            TextField("", text: .constant("search"))
                .frame(width: 120)
                .textFieldStyle(.roundedBorder)
        }
        .padding(.top, 6)
        .padding(.horizontal, 14)

        Divider()
    }

    @ViewBuilder
    var scrollabeImageGridView: some View {
        ScrollView {
            VStack {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(self.gridImageSize)), count: 5),
                    spacing: 16
                ) {
                    ForEach(self.sortedImages) { asset in
                        GridItemView(
                            asset: asset,
                            thumbProvider: self.assetsProvider,
                            selected: self.selected == asset.id,
                        )
                        .onTapGesture {
                            self.onTapItem(asset)
                        }
                    }
                }
            }
        }
    }

    var selectButtonText: String {
        if self.createNodeOnSelect {
            "Select and Create Node"
        } else {
            "Select"
        }
    }

    var cancelButtonText: LocalizedStringResource {
        switch self.type {
        case .picker:
            LocalizedStringResource("cancel", defaultValue: "Cancel")
        case .browser:
            LocalizedStringResource("close", defaultValue: "Close")
        }
    }

    @ViewBuilder
    var footerView: some View {

        Divider()
        HStack {
            Spacer()

            Button(self.cancelButtonText) {
                self.delegate.onDismiss(.cancel)
                self.dismiss()
            }

            Button(self.selectButtonText) {
                log("select click")
                if let selected = self.selected {
                    self.delegate.onDismiss(self.createNodeOnSelect ? .create(selected) : .pick(selected))
                    self.dismiss()
                }
            }
            .disabled(self.selected == nil)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 4)
    }
}

@Observable
@MainActor
private class PreviewAssetsProvider: AssetBrowserAssetsProvider {
    var fileAssets: [ImageAsset] = (0...25).map { _ in
        .init(id: .init(), state: .loaded(.file("")), added: .now)
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage? {
        nil
    }
}

#Preview {
    @Previewable @State var provider = PreviewAssetsProvider()
    VStack {
        AssetBrowserView(
            type: .browser,
            assetsProvider: provider,
            delegate: .init(onDismiss: { _ in }, openFileImporter: {}, openPhotoPicker: {})
        )
    }
}
