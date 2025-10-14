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
    var fileAssets: [ImageAsset]

    let gradientImage: CGImage = .verticalGradientImage(
        width: 256,
        height: 256,
        topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
        bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
    )!

    @ObservationIgnored
    var ids: [UUID]

    @ObservationIgnored
    var delays: [UUID: Int]

    static let filenames: [String] = [
        "",  // empty
        "a.txt",
        "b",
        "notes.md",
        "data.json",
        "config.yml",
        "archive.tar.gz",
        "image.png",
        "video.mov",
        "document.pdf",
        "presentation.key",
        "spreadsheet.xlsx",
        "backup_2025_10_13.zip",
        "report_final_v2.docx",
        "swift_testing_example.swift",
        "My Great App.app",
        "very_long_filename_that_keeps_going_and_going.txt",
        "🎨_emoji_filename_😀.png",
        "spaces in name.txt",
        "UPPERCASEFILE.MP3",
        "mixed_Case_Name.DAT",
        "filename-with-dashes-and_numbers-12345.csv",
        "file_with_underscores_and_long_extension.template.backup",
        "超長いファイル名テスト用の文字列です.txt",
        "another_really_really_long_filename_that_is_probably_too_long_but_still_valid_in_most_file_systems_because_why_not_really_there_is_no_reason_not_to_make_it_long.json",
        "z_last.txt",
    ]

    init() {
        let ids = (0...25).map { _ in UUID() }
        self.fileAssets = ids.enumerated().map { (idx, id) in
            .init(id: id, state: .loaded(.file(Self.filenames[idx])), added: .now)
        }
        self.ids = ids
        self.delays = .init(uniqueKeysWithValues: ids.map { id in (id, .random(in: 1...8)) })
    }

    func getThumb(forImageAsset id: UUID) async throws -> CGImage? {
        try await Task.sleep(for: .seconds(self.delays[id]!))
        return gradientImage
    }

    func reload() {
        let ids = (0...25).map { _ in UUID() }
        self.fileAssets = ids.map { id in .init(id: id, state: .loaded(.file("")), added: .now) }
        self.ids = ids
        self.delays = .init(uniqueKeysWithValues: ids.map { id in (id, .random(in: 1...8)) })
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

        Divider()
    }
}
