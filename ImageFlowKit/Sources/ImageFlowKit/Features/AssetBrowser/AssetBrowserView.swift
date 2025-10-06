import Logging
import SwiftUI
import UniformTypeIdentifiers

public enum AssetBrowserType {
    case picker
    case browser
}

struct AssetBrowserView: View {
    let assetProvider: any AssetProvider
    var onChooseAsset: (UUID) -> ()
    var addImageFiles: (([URL]) -> Void)?
    let type: AssetBrowserType
    let gridImageSize: CGFloat = 146.0

    @State var showFileImporter = false
    @State var selected: UUID? = nil
    @State var createNodeOnSelect: Bool = false

    @Environment(\.dismiss) var dismiss

    init(
        type: AssetBrowserType = .picker,
        assetProvider: any AssetProvider,
        showFileImporter: Bool = false,
        selected: UUID? = nil,
        onChooseAsset: @escaping (UUID) -> Void,
        addImageFiles: (([URL]) -> Void)? = nil
    ) {
        self.type = type
        self.assetProvider = assetProvider
        self.showFileImporter = showFileImporter
        self.selected = selected
        self.onChooseAsset = onChooseAsset
        self.addImageFiles = addImageFiles
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
            self.createNodeOnSelect = new == .command
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
        self.assetProvider.images.sorted(by: { $0.added < $1.added }).map { $0 }
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
                            assetProvider: self.assetProvider,
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

    @ViewBuilder
    var footerView: some View {

        Divider()
        HStack {
            Spacer()

            switch self.type {
            case .picker:
                Button("Cancel") {
                    self.dismiss()
                }

                Button(self.selectButtonText) {
                    log("select click")
                    if let selected = self.selected {
                        self.onChooseAsset(selected)
                        self.dismiss()
                    }
                }
                .disabled(self.selected == nil)

            case .browser:
                Button("Close") {
                    self.dismiss()
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 4)
    }

    func fileImporterHandler(_ result: Result<[URL], any Error>) {
        switch result {
        case .success(let urls):
            self.addImageFiles?(urls)
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

#Preview {
    let ids = (0..<10).map { _ in UUID() }
    VStack {
        AssetBrowserView(
            assetProvider: AssetBrowserView.PreviewAssetProvider(ids: ids),
            onChooseAsset: { _ in }
        )
    }
}
