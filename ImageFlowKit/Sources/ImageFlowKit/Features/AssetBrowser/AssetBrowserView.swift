import Helpers
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

struct AssetBrowserViewDelegate {
    var onDismiss: (AssetBrowserResult) -> ()
    var openFileImporter: () -> ()
    var openPhotoPicker: () -> ()
    var deleteImageAsset: (ImageAsset) -> ()
}

struct AssetBrowserView: View {

    // MARK: - State

    let assetsProvider: any AssetBrowserAssetsProvider
    let type: AssetBrowserType
    let gridImageSize: CGFloat = 146.0
    let delegate: AssetBrowserViewDelegate

    @State var showFileImporter = false
    @State var selected: UUID? = nil
    @State var searchText: String = ""
    @State var showDeleteConfirmationDialog = false
    @State var imageAssetToDelete: ImageAsset? = nil

    @Environment(\.undoManager) var undoManager
    @Environment(\.dismiss) var dismiss

    @Namespace var toolbasNS

    // MARK: - Init

    init(
        type: AssetBrowserType = .browser,
        assetsProvider: any AssetBrowserAssetsProvider,
        delegate: AssetBrowserViewDelegate,
    ) {
        self.type = type
        self.assetsProvider = assetsProvider
        self.delegate = delegate
    }

    // MARK: - Computed vars

    fileprivate var style: Style {
        .default
    }

    var sortedImages: [ImageAsset] {
        self.assetsProvider.fileAssets.sorted(by: { $0.added < $1.added })
    }

    var filteredImages: [ImageAsset] {
        if self.searchText.isEmpty {
            self.sortedImages
        } else {
            self.sortedImages.filter({ $0.source?.filename?.contains(self.searchText) ?? false })
        }
    }

    var selectButtonText: LocalizedStringResource {
        if self.type == .browser {
            LocalizedStringResource("ab:create-node-btn", defaultValue: "Create Node")
        } else {
            LocalizedStringResource("ab:select-btn", defaultValue: "Select")
        }
    }

    var cancelButtonText: LocalizedStringResource {
        switch self.type {
        case .picker:
            LocalizedStringResource("ab:cancel-btn", defaultValue: "Cancel")
        case .browser:
            LocalizedStringResource("ab:close-btn", defaultValue: "Close")
        }
    }

    // MARK: - Methods

    func onTapItem(_ info: ImageAsset) {
        switch info.state {
        case .loaded:
            self.selected = info.id
        case .loading:
            break
        }
    }

    func deleteCommandHandler(_ asset: ImageAsset) {
        self.confirmImageAssetDelete(asset)
    }

    func deleteButtonHandler(_ asset: ImageAsset) {
        self.confirmImageAssetDelete(asset)
    }

    func confirmImageAssetDelete(_ asset: ImageAsset) {
        self.showDeleteConfirmationDialog = true
        self.imageAssetToDelete = asset
    }

    func confirmationDialogTitle(_ asset: ImageAsset) -> String {
        #if os(macOS)
        if let name = asset.source?.filename {
            "Do you want to remove the image \(name)?"
        } else {
            "Do you want to remove this image?"
        }
        #else
        "Do you want to remove this image?"
        #endif
    }

    func delete(_ asset: ImageAsset) {
        if asset.isLoaded {
            if self.selected == asset.id {
                self.selected = nil
            }
            self.delegate.deleteImageAsset(asset)
        }
    }

    // MARK: - Body

    var body: some View {
        #if os(macOS)
        self.content
            .frame(minHeight: 600)
        #else
        self.content
            .ignoresSafeArea(.keyboard)
        #endif
    }

    // MARK: - Content

    @ViewBuilder
    var content: some View {
        VStack {
            self.gridView
                .onTapGesture {
                    self.selected = nil
                }
                .safeAreaBar(edge: .top) { self.toolbarView }
                .safeAreaBar(edge: .bottom) { self.footerView }

        }
        .ignoresSafeArea(.keyboard)
    }

    // MARK: - Toolbar

    #if os(macOS)
    @ViewBuilder
    var toolbarView: some View {

        let buttonSize: CGFloat = 18

        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 14) {
                Button {
                    self.delegate.openFileImporter()
                } label: {
                    Text("\(Image(systemName: "square.and.arrow.down"))")
                        .font(.system(size: buttonSize))
                }
                .buttonStyle(.borderless)

                Button {
                    self.delegate.openPhotoPicker()
                } label: {
                    Text("\(Image(systemName: "photo.badge.plus.fill"))")
                        .font(.system(size: buttonSize))
                        .baselineOffset(-4)
                }
                .buttonStyle(.borderless)
            }
            .frame(height: 42)
            .padding(.horizontal, 14)
            //            .padding(.vertical, 8)
            .glassEffect(.regular, in: Capsule())

            Spacer()

            HStack {
                TextField("Search...", text: self.$searchText)
                    .textFieldStyle(.plain)
                    .frame(width: 150)
                    .padding(.leading, 20)
                    .padding(.trailing, 10)
            }
            .frame(height: 42)
            .glassEffect(.regular, in: Capsule())
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
    }
    #endif

    #if os(iOS)
    @ViewBuilder
    var toolbarView: some View {
        HStack(alignment: style.toolbar.alignment, spacing: style.toolbar.spacing) {
            GlassEffectContainer {
                HStack {
                    Button {
                        self.delegate.openFileImporter()
                    } label: {
                        Text("\(Image(systemName: "square.and.arrow.down"))")
                            .font(.system(size: style.toolbar.buttonSize))
                    }
                    .buttonStyle(.glass)
                    .glassEffectUnion(id: "import", namespace: self.toolbasNS)
                    .help("Import Image File")

                    Button {
                        self.delegate.openPhotoPicker()
                    } label: {
                        Text("\(Image(systemName: "photo.badge.plus.fill"))")
                            .font(.system(size: style.toolbar.buttonSize))
                            .baselineOffset(style.toolbar.photoButtonBaselineOffset)

                    }
                    .buttonStyle(.glass)
                    .glassEffectUnion(id: "import", namespace: self.toolbasNS)
                    .help("Import Photo")
                }
            }

            Spacer()

            TextField("Search...", text: self.$searchText)
                .frame(width: style.toolbar.searchWidth)
                .textFieldStyle(kind: style.toolbar.searchTextFieldStyle)
                .padding(.vertical, 4)
                .padding(.leading, 12)
                .glassEffect()
        }
        .padding(.top, style.toolbar.paddingTop)
        .padding(.horizontal, style.toolbar.horizontalPadding)
        .padding(.bottom, style.toolbar.paddingBottom)
    }
    #endif

    // MARK: - Grid

    @ViewBuilder
    var gridView: some View {
        ScrollView {
            VStack {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(self.gridImageSize)), count: 5),
                    spacing: 16
                ) {
                    ForEach(self.filteredImages) { asset in
                        AssetBrowserGridItemView(
                            asset: asset,
                            thumbProvider: self.assetsProvider,
                            selected: self.selected == asset.id,
                        )
                        .focusable()
                        .focusEffectDisabled()
                        #if os(macOS)
                        .onDeleteCommand {
                            self.deleteButtonHandler(asset)
                        }
                        #endif
                        .onTapGesture {
                            self.onTapItem(asset)
                        }
                        .contextMenu {
                            Button("Delete") { self.deleteButtonHandler(asset) }
                                .disabled(!asset.isLoaded)
                        }
                        .confirmationDialog(
                            self.confirmationDialogTitle(asset),
                            isPresented: self.$showDeleteConfirmationDialog,
                            titleVisibility: .visible,
                            actions: { self.confirmationDialogActions },
                            message: { self.confirmationDialogMessage },
                        )
                    }
                }
                .padding(.horizontal, style.fileArea.horizontalPadding)
            }
        }
        #if os(macOS)
        .scrollEdgeEffectStyle(.soft, for: .top)
        .scrollEdgeEffectStyle(.hard, for: .bottom)
        #else
        .scrollEdgeEffectStyle(.soft, for: .all)
        #endif
    }

    @ViewBuilder
    var confirmationDialogActions: some View {
        Button("Delete", role: .destructive) {
            if let asset = self.imageAssetToDelete {
                self.delete(asset)
            }
        }
        Button("Cancel", role: .cancel) {
            self.imageAssetToDelete = nil
        }
    }

    @ViewBuilder
    var confirmationDialogMessage: some View {
        Text(
            "You can undo this action later. The file will remain in temporary storage until the document is closed."
        )
    }

    // MARK: - Footer

    @ViewBuilder
    var footerView: some View {
        HStack(spacing: style.footer.spacing) {
            Spacer()

            Button(self.cancelButtonText) {
                self.delegate.onDismiss(.cancel)
                self.dismiss()
            }
            .buttonStyle(.glass)

            Button(self.selectButtonText) {
                log("select click")
                if let selected = self.selected {
                    self.delegate.onDismiss(self.type == .browser ? .create(selected) : .pick(selected))
                    self.dismiss()
                }
            }
            .buttonStyle(.glassProminent)
            .disabled(self.selected == nil)
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, style.footer.paddingTop)
    }
}

// MARK: - Style

private struct Style: With {

    var toolbar: Toolbar
    var fileArea: FileArea
    var footer: Footer

    struct FileArea: With {
        var horizontalPadding: CGFloat
    }

    struct Footer: With {
        var spacing: CGFloat
        var paddingTop: CGFloat
    }

    struct Toolbar: With {
        var spacing: CGFloat
        var buttonSize: CGFloat
        var photoButtonBaselineOffset: CGFloat
        var horizontalPadding: CGFloat
        var paddingTop: CGFloat
        var paddingBottom: CGFloat
        var alignment: VerticalAlignment
        var searchWidth: CGFloat
        var searchTextFieldStyle: TextFieldStyleKind
    }

    static var macos: Self {
        self.ipad
            .with(\.footer.paddingTop, 12)
            .with(\.toolbar.buttonSize, 14)
    }

    static var ipad: Self {
        .init(
            toolbar: .init(
                spacing: 10,
                buttonSize: 22,
                photoButtonBaselineOffset: -6,
                horizontalPadding: 22,
                paddingTop: 10,
                paddingBottom: 8,
                alignment: .center,
                searchWidth: 120,
                searchTextFieldStyle: .automatic,
            ),
            fileArea: .init(horizontalPadding: 16),
            footer: .init(spacing: 26, paddingTop: 4)
        )
    }

    static var `default`: Self {
        #if os(macOS)
        return .macos
        #else
        return .ipad
        #endif
    }
}

// MARK: - Previews

@Observable
@MainActor
private class PreviewAssetsProvider: AssetBrowserAssetsProvider {
    var fileAssets: [ImageAsset]

    func removeImage(_ id: UUID, undoManager um: UndoManager?) {

    }

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
            delegate: .init(onDismiss: { _ in }, openFileImporter: {}, openPhotoPicker: {}, deleteImageAsset: { _ in })
        )
    }
}

#Preview("Sheet") {
    @Previewable @State var provider = PreviewAssetsProvider()
    @Previewable @State var isPresented: Bool = false
    ZStack {
        Color.teal
        Button("Show Asset Browser") {
            isPresented = true
        }
    }
    .sheet(
        isPresented: .constant(true),
        content: {
            AssetBrowserView(
                type: .browser,
                assetsProvider: provider,
                delegate: .init(
                    onDismiss: { _ in },
                    openFileImporter: {},
                    openPhotoPicker: {},
                    deleteImageAsset: { _ in }
                )
            )
        }
    )
}
