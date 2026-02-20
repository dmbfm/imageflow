import Helpers
import Logging
import SwiftUI
import UniformTypeIdentifiers
import Values

public struct AssetBrowserView: View {

    // MARK: - State

    @Bindable var vm: AssetBrowserViewModel

    @Environment(\.dismiss) var dismiss

    @Namespace var toolbasNS

    private let gridImageSize: CGFloat = 146.0
    private let style: Style = .default

    // MARK: - Init

    public init(_ vm: AssetBrowserViewModel) {
        self._vm = .init(wrappedValue: vm)
    }

    // MARK: - Body

    public var body: some View {
        #if os(macOS)
        self.content
            .frame(minHeight: 600)
            .onKeyPress(.escape) {
                self.vm.onDismiss(.cancel)
                self.dismiss()
                return .handled
            }
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
                    self.vm.selected = nil
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
        @Bindable var vm = self.vm

        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 14) {
                Button {
                    self.vm.openFileImporter(self.vm.allowedImportTypes)
                } label: {
                    Text("\(Image(systemName: "square.and.arrow.down"))")
                        .font(.system(size: buttonSize))
                }
                .buttonStyle(.primaryBorderless)

                Button {
                    self.vm.openPhotoPicker()
                } label: {
                    Text("\(Image(systemName: "photo.badge.plus.fill"))")
                        .font(.system(size: buttonSize))
                        .foregroundStyle(self.vm.photoPickerDisabled ? .tertiary : .primary)
                        .baselineOffset(-4)
                }
                .buttonStyle(.primaryBorderless)
                .disabled(self.vm.photoPickerDisabled)
            }
            .frame(height: 42)
            .padding(.horizontal, 14)
            //            .padding(.vertical, 8)
            .glassEffect(.regular, in: Capsule())

            Spacer()

            HStack {
                TextField("Search...", text: $vm.searchText)
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
                        self.vm.delegate?.openFileImporter(self.vm.allowedImportTypes)
                    } label: {
                        Text("\(Image(systemName: "square.and.arrow.down"))")
                            .font(.system(size: style.toolbar.buttonSize))
                    }
                    .buttonStyle(.glass)
                    .glassEffectUnion(id: "import", namespace: self.toolbasNS)
                    .help("Import Assets")

                    Button {
                        self.vm.delegate?.openPhotoPicker()
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

            TextField("Search...", text: self.$vm.searchText)
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

        @Bindable var vm = self.vm

        ScrollView {
            VStack {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.fixed(self.gridImageSize)), count: 5),
                    spacing: 16
                ) {
                    ForEach(self.vm.filteredAssets) { asset in
                        AssetBrowserGridItemView(
                            asset: asset,
                            thumbProvider: self.vm.assetsProvider,
                            selected: self.vm.selected?.id == asset.id,
                        )
                        .focusable()
                        .focusEffectDisabled()
                        #if os(macOS)
                        .onDeleteCommand {
                            self.vm.deleteButtonHandler(asset)
                        }
                        #endif
                        .onTapGesture {
                            self.vm.onTapItem(asset)
                        }
                        .contextMenu {
                            Button("Delete") { self.vm.deleteButtonHandler(asset) }
                                .disabled(!asset.isLoaded)
                        }
                        .confirmationDialog(
                            self.vm.confirmationDialogTitle(asset),
                            isPresented: $vm.showDeleteConfirmationDialog,
                            titleVisibility: .visible,
                            actions: { self.confirmationDialogActions },
                            message: { self.confirmationDialogMessage },
                        )
                    }
                }
                .padding(.horizontal, style.fileArea.horizontalPadding)
            }
        }
        .scrollEdgeEffectStyle(.soft, for: .all)
    }

    @ViewBuilder
    var confirmationDialogActions: some View {
        Button("Delete", role: .destructive) {
            if let asset = self.vm.assetToDelete {
                self.vm.delete(asset)
            }
        }
        Button("Cancel", role: .cancel) {
            self.vm.assetToDelete = nil
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

            Button {
                self.vm.onDismiss(.cancel)
                self.dismiss()
            } label: {
                Text(self.vm.cancelButtonText)
                    #if os(macOS)
                .padding(.vertical, 2)
                    #endif
            }
            .buttonStyle(.glass)
            #if os(macOS)
            .buttonBorderShape(.capsule)
            #endif

            Button {
                self.vm.selectButtonHandler { self.dismiss() }
            } label: {
                Text(self.vm.selectButtonText)
                    #if os(macOS)
                .padding(.vertical, 2)
                    #endif
            }
            .buttonStyle(.glassProminent)
            .disabled(self.vm.selected == nil)
            #if os(macOS)
            .buttonBorderShape(.capsule)
            #endif
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

// @Observable
// @MainActor
// private class PreviewAssetsProvider: AssetBrowserAssetsProvider {
//     var fileAssets: [Asset]

//     func assetBrowserAssets(forKinds kinds: Set<AssetKind>) -> [Asset] {
//         self.fileAssets.filter({ kinds.contains($0.kind) })
//     }

//     func removeImage(_ id: UUID, undoManager um: UndoManager?) {

//     }

//     let gradientImage: CGImage = .verticalGradientImage(
//         width: 256,
//         height: 256,
//         topColor: .init(red: 0.412, green: 0.562, blue: 0.875, alpha: 1.0),
//         bottomColor: .init(red: 0.71, green: 0.784, blue: 0.937, alpha: 1.0)
//     )!

//     @ObservationIgnored
//     var ids: [AssetIdentifier]

//     @ObservationIgnored
//     var delays: [AssetIdentifier: Int]

//     static let filenames: [String] = [
//         "",  // empty
//         "a.txt",
//         "b",
//         "notes.md",
//         "data.json",
//         "config.yml",
//         "archive.tar.gz",
//         "image.png",
//         "video.mov",
//         "document.pdf",
//         "presentation.key",
//         "spreadsheet.xlsx",
//         "backup_2025_10_13.zip",
//         "report_final_v2.docx",
//         "swift_testing_example.swift",
//         "My Great App.app",
//         "very_long_filename_that_keeps_going_and_going.txt",
//         "🎨_emoji_filename_😀.png",
//         "spaces in name.txt",
//         "UPPERCASEFILE.MP3",
//         "mixed_Case_Name.DAT",
//         "filename-with-dashes-and_numbers-12345.csv",
//         "file_with_underscores_and_long_extension.template.backup",
//         "超長いファイル名テスト用の文字列です.txt",
//         "another_really_really_long_filename_that_is_probably_too_long_but_still_valid_in_most_file_systems_because_why_not_really_there_is_no_reason_not_to_make_it_long.json",
//         "z_last.txt",
//     ]

//     init() {
//         let ids = (0...25).map { _ in AssetIdentifier.asset(UUID()) }
//         self.fileAssets = ids.enumerated().map { (idx, id) in
//             .init(id: id, state: .loaded(.file(Self.filenames[idx])), added: .now, kind: .image)
//         }
//         self.ids = ids
//         self.delays = .init(uniqueKeysWithValues: ids.map { id in (id, .random(in: 1...8)) })
//     }

//     func assetBrowserGetThumb(forAsset id: AssetIdentifier) async throws -> CGImage? {
//         try await Task.sleep(for: .seconds(self.delays[id]!))
//         return gradientImage
//     }

//     func reload() {
//         let ids = (0...25).map { _ in AssetIdentifier.asset(UUID()) }
//         self.fileAssets = ids.map { id in .init(id: id, state: .loaded(.file("")), added: .now, kind: .image) }
//         self.ids = ids
//         self.delays = .init(uniqueKeysWithValues: ids.map { id in (id, .random(in: 1...8)) })
//     }
// }

// #Preview {
//     @Previewable @State var provider = PreviewAssetsProvider()
//     VStack {
//         AssetBrowserView(
//             type: .browser(.init(assetKinds: .all)),
//             assetsProvider: provider,
//             delegate: .init(
//                 onDismiss: { _ in },
//                 openFileImporter: { _ in },
//                 openPhotoPicker: {},
//                 deleteAsset: { _ in }
//             )
//         )
//     }
// }

// #Preview("Sheet") {
//     @Previewable @State var provider = PreviewAssetsProvider()
//     @Previewable @State var isPresented: Bool = false
//     ZStack {
//         Color.teal
//         Button("Show Asset Browser") {
//             isPresented = true
//         }
//     }
//     .sheet(
//         isPresented: .constant(true),
//         content: {
//             AssetBrowserView(
//                 type: .browser(.init(assetKinds: [.image])),
//                 assetsProvider: provider,
//                 delegate: .init(
//                     onDismiss: { _ in },
//                     openFileImporter: { _ in },
//                     openPhotoPicker: {},
//                     deleteAsset: { _ in }
//                 )
//             )
//         }
//     )
// }
