import Foundation
import Logging
import SharedModels
import UniformTypeIdentifiers

@Observable
@MainActor
public final class AssetBrowserViewModel {

    let assetsProvider: any AssetStoreService
    var allowedAssetKinds: AssetKindSet
    var allowedImportTypes: [UTType]
    var photoPickerDisabled: Bool

    var searchText: String = ""
    var selected: Asset? = nil
    var showDeleteConfirmationDialog = false
    var assetToDelete: Asset? = nil

    var type: AssetBrowserType = .browser(.init(assetKinds: .all))
    public weak var delegate: Delegate?

    public protocol Delegate: AnyObject {
        func onDismiss(_: AssetBrowserResult)
        func openFileImporter(_: [UTType]) -> ()
        func openPhotoPicker() -> ()
        func deleteAsset(_: Asset) -> ()
    }

    public init(
        assetsProvider: any AssetStoreService,
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

    public func setType(_ type: AssetBrowserType) {
        self.type = type
        self.allowedAssetKinds = type.allowedAssetKinds
        self.allowedImportTypes = type.allowedAssetKinds.types
        self.photoPickerDisabled = !type.allowedAssetKinds.contains(.image)
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

    func selectButtonHandler(_ dismiss: () -> ()) {
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
            dismiss()
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

public enum AssetBrowserType: Equatable {
    case picker(Picker)
    case browser(Browser)

    public struct Picker: Equatable {
        public var assetKind: AssetKind
        public var portLocation: InputPortLocation

        public init(assetKind: AssetKind, portLocation: InputPortLocation) {
            self.assetKind = assetKind
            self.portLocation = portLocation
        }
    }

    public struct Browser: Equatable {
        public var assetKinds: AssetKindSet

        public init(assetKinds: AssetKindSet) {
            self.assetKinds = assetKinds
        }

    }

    public var allowedAssetKinds: AssetKindSet {
        switch self {
        case .browser(let data): data.assetKinds
        case .picker(let data): .assetKind(data.assetKind)
        }
    }

    public var isBrowser: Bool {
        switch self {
        case .browser: true
        default: false
        }
    }
}

public enum AssetBrowserResult {
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

extension AssetStoreService {
    public func assetBrowserAssets(forKinds kinds: Set<AssetKind>) -> [Asset] {
        self.assets.values.filter { kinds.contains($0.kind) }
    }
}
