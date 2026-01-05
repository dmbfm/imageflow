import Foundation
import UniformTypeIdentifiers

@Observable
@MainActor
final class AssetBrowserViewModel {

    let assetsProvider: any AssetBrowserAssetsProvider
    let allowedAssetKinds: AssetKindSet
    let allowedImportTypes: [UTType]
    let photoPickerDisabled: Bool

    var searchText: String = ""
    var selected: Asset? = nil
    var showDeleteConfirmationDialog = false
    var assetToDelete: Asset? = nil

    var type: AssetBrowserType = .browser(.init(assetKinds: .all))
    weak var delegate: Delegate?

    protocol Delegate: AnyObject {
        func onDismiss(_: AssetBrowserResult)
        func openFileImporter(_: [UTType]) -> ()
        func openPhotoPicker() -> ()
        func deleteAsset(_: Asset) -> ()
    }

    init(
        assetsProvider: any AssetBrowserAssetsProvider,
        allowedAssetKinds: AssetKindSet,
        allowedImportTypes: [UTType],
        photoPickerDisabled: Bool,
        type: AssetBrowserType = .browser(.init(assetKinds: .all)),
    ) {
        self.assetsProvider = assetsProvider
        self.allowedAssetKinds = allowedAssetKinds
        self.allowedImportTypes = allowedImportTypes
        self.photoPickerDisabled = photoPickerDisabled
        self.type = type
    }

    var sortedAssets: [Asset] {
        self.assetsProvider.assetBrowserAssets(forKinds: self.allowedAssetKinds.kinds)
            .sorted(by: { $0.timestamp < $1.timestamp })
    }

    var filteredAssets: [Asset] {
        if self.searchText.isEmpty {
            self.sortedAssets
        } else {
            self.sortedAssets.filter({ $0.filename?.contains(self.searchText) ?? false })
        }
    }

    var selectButtonText: LocalizedStringResource {
        if case .browser = self.type {
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

    func onTapItem(_ asset: Asset) {
        switch asset.state {
        case .loaded:
            self.selected = asset
        case .loading:
            break
        }
    }

    func deleteCommandHandler(_ asset: Asset) {
        self.confirmAssetDelete(asset)
    }

    func deleteButtonHandler(_ asset: Asset) {
        self.confirmAssetDelete(asset)
    }

    func confirmAssetDelete(_ asset: Asset) {
        self.showDeleteConfirmationDialog = true
        self.assetToDelete = asset
    }

    func confirmationDialogTitle(_ asset: Asset) -> String {
        #if os(macOS)
        if let name = asset.filename {
            "Do you want to remove the asset '\(name)'?"
        } else {
            "Do you want to remove this asset?"
        }
        #else
        "Do you want to remove this asset?"
        #endif
    }

    func selectButtonHandler() {
        if let selected = self.selected {
            switch self.type {
            case .browser(let browser):
                assert(browser.assetKinds.contains(selected.kind))
                self.delegate?.onDismiss(.create(assetKind: selected.kind, assetId: selected.id))
                break
            case .picker(let picker):
                self.delegate?.onDismiss(
                    .pick(assetKind: picker.assetKind, assetId: selected.id, portLocation: picker.portLocation)
                )
                break
            }
            // self.dismiss()
        }
    }

    func delete(_ asset: Asset) {
        if case .loaded(filename: _) = asset.state {
            if self.selected?.id == asset.id {
                self.selected = nil
            }
            self.delegate?.deleteAsset(asset)
        }
    }

    func openFileImporter(_ types: [UTType]) {
        self.delegate?.openFileImporter(types)
    }

    func onDismiss(_ result: AssetBrowserResult) {
        self.delegate?.onDismiss(result)
    }

    func openPhotoPicker() {
        self.delegate?.openPhotoPicker()
    }

    func deleteAsset(_ asset: Asset) {
        self.delegate?.deleteAsset(asset)
    }
}

enum AssetBrowserType: Equatable {
    case picker(Picker)
    case browser(Browser)

    struct Picker: Equatable {
        var assetKind: AssetKind
        var portLocation: InputPortLocation
    }

    struct Browser: Equatable {
        var assetKinds: AssetKindSet
    }

    var allowedAssetKinds: AssetKindSet {
        switch self {
        case .browser(let data): data.assetKinds
        case .picker(let data): .assetKind(data.assetKind)
        }
    }

    var isBrowser: Bool {
        switch self {
        case .browser: true
        default: false
        }
    }
}

enum AssetBrowserResult {
    case cancel
    case pick(
        assetKind: AssetKind,
        assetId: UUID,
        portLocation: InputPortLocation,
    )
    case create(
        assetKind: AssetKind,
        assetId: UUID,
    )
}
