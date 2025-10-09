import Logging
import SwiftUI
import UniformTypeIdentifiers

public enum AssetBrowserType: Equatable {
    case picker(PortLocation)
    case browser
}

public enum AssetBrowserResult {
    case cancel
    case pick(UUID)
    case create(UUID)
}

struct AssetBrowserView: View {
    let assetStore: AssetStore
    let type: AssetBrowserType
    let gridImageSize: CGFloat = 146.0
    let onDismiss: (AssetBrowserResult) -> ()

    @State var showFileImporter = false
    @State var selected: UUID? = nil
    @State var createNodeOnSelect: Bool = false

    @Environment(\.dismiss) var dismiss

    init(
        type: AssetBrowserType = .browser,
        assetStore: AssetStore,
        showFileImporter: Bool = false,
        selected: UUID? = nil,
        onDismiss: @escaping (AssetBrowserResult) -> Void,
    ) {
        self.type = type
        self.assetStore = assetStore
        self.showFileImporter = showFileImporter
        self.selected = selected
        self.onDismiss = onDismiss
    }

    var body: some View {
        self.content
            .frame(width: 800, height: 600)
            .fileImporter(
                isPresented: self.$showFileImporter,
                allowedContentTypes: [.image],
                allowsMultipleSelection: true,
                onCompletion: self.fileImporterHandler(_:)
            )
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
        .onModifierKeysChanged({ old, new in
            if self.type == .browser {
                self.createNodeOnSelect = new == .command
            }
        })
    }

    @ViewBuilder
    var toolbarView: some View {
        HStack {
            Button {
                self.showFileImporter = true
            } label: {
                Image(systemName: "square.and.arrow.down")
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

    var sortedImages: [ImageAssetInfo] {
        self.assetStore.images.values.filter { $0.source.isFile }.compactMap { asset in
            let state: ImageAssetInfo.State =
                switch asset.res.thumb {
                case .loaded: .loaded
                case .loading, .notLoaded: .loading
                case .failed: .failed
                }
            return .init(id: asset.id, name: asset.source.filename!, added: asset.added, state: state)
        }
    }

    @ViewBuilder
    var scrollabeImageGridView: some View {
        ScrollView {
            VStack {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(self.gridImageSize)), count: 5),
                    spacing: 16
                ) {
                    ForEach(self.sortedImages) { info in
                        GridItemView(
                            assetStore: self.assetStore,
                            selected: self.selected == info.id,
                            info: info
                        )
                        .onTapGesture {
                            self.onTapItem(info)
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
            LocalizedStringResource("close", defaultValue: "Cloce")
        }
    }

    @ViewBuilder
    var footerView: some View {

        Divider()
        HStack {
            Spacer()

            Button(self.cancelButtonText) {
                self.onDismiss(.cancel)
                self.dismiss()
            }

            Button(self.selectButtonText) {
                log("select click")
                if let selected = self.selected {
                    self.onDismiss(self.createNodeOnSelect ? .create(selected) : .pick(selected))
                    self.dismiss()
                }
            }
            .disabled(self.selected == nil)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 4)
    }

    func addImages(_ urls: [URL]) {
        Task {
            for url in urls {
                do {
                    try await self.assetStore.addImage(fromURL: url)
                } catch {
                    log("Failed to add image at \(url): \(error)", level: .error)
                }
            }
        }
    }

    func fileImporterHandler(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            self.addImages(urls)
        case .failure(let error):
            log("Error: \(error)", level: .error)
            break
        }
    }

    func onTapItem(_ info: ImageAssetInfo) {
        log("info: \(info)")
        if info.state == .loaded {
            self.selected = info.id
        }
    }
}

// #Preview {
//     let ids = (0..<10).map { _ in UUID() }
//     VStack {
//         AssetBrowserView(
//             assetProvider: AssetBrowserView.PreviewAssetProvider(ids: ids),
//             onChooseAsset: { _ in }
//         )
//     }
// }
