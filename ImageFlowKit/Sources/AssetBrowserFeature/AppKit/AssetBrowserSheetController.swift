#if canImport(AppKit)

import AppKit
import SwiftUI
import SharedModels
import UniformTypeIdentifiers
import PhotosUI

public final class AssetBrowserSheetController: NSHostingController<AssetBrowserView> {

    let vm: AssetBrowserViewModel
    let assetStore: any AssetStoreService
    weak var delegate: Delegate?

    public init(
        assetStore: any AssetStoreService,
        type: AssetBrowserType,
        delegate: Delegate
    ) {
        self.assetStore = assetStore
        self.vm = .init(
            assetsProvider: assetStore,
            assetBrowserType: type,
        )
        self.delegate = delegate

        super.init(rootView: .init(self.vm))

        self.vm.delegate = self
    }

    @MainActor @preconcurrency required dynamic init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func cancel(_ sender: Any?) {
        self.dismiss(nil)
    }
}

extension AssetBrowserSheetController {
    public protocol Delegate: AnyObject {
        func assetBrowserSheetImportAssets(_ sender: AssetBrowserSheetController, urls: [URL])
        func assetBrowserSheetPickAsset(kind: AssetKind, assetId: UUID, port: InputPortLocation)
        func assetBrowserSheetCreateNode(kind: AssetKind, assetId: UUID)
        func assetBrowserDeleteAsset(_ sender: AssetBrowserSheetController, asset: Asset)
    }
}

extension AssetBrowserSheetController: AssetBrowserViewModel.Delegate {
    public func onDismiss(_ result: AssetBrowserResult) {
        switch result {
        case .cancel:
            break
        case let .create(assetKind, id):
            self.delegate?.assetBrowserSheetCreateNode(kind: assetKind, assetId: id)
        case let .pick(assetKind, assetId, portLocation):
            self.delegate?.assetBrowserSheetPickAsset(kind: assetKind, assetId: assetId, port: portLocation)
        }
        self.dismiss(nil)
    }

    public func openFileImporter(_ fileTypes: [UTType]) {
        let panel = NSOpenPanel.init()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = self.vm.allowedImportTypes
        panel.allowsOtherFileTypes = false

        let res = panel.runModal()
        let urls = panel.urls

        if !urls.isEmpty {
            self.delegate?.assetBrowserSheetImportAssets(self, urls: urls)
        }
    }

    public func openPhotoPicker() {
        var cfg = PHPickerConfiguration(photoLibrary: .shared())
        cfg.selectionLimit = 50
        cfg.filter = .images
        cfg.selection = .ordered

        let pvc = PHPickerViewController(configuration: cfg)
        pvc.view.frame = self.view.frame
        pvc.preferredContentSize = self.view.frame.size
        pvc.delegate = self
        self.presentAsSheet(pvc)
    }

    public func deleteAsset(_ asset: SharedModels.Asset) {
        self.delegate?.assetBrowserDeleteAsset(self, asset: asset)
    }
}

extension AssetBrowserSheetController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(nil)

        for item in results.map({ $0.itemProvider }) {
            Task { @MainActor in
                do {
                    _ = try await self.assetStore.importAsset(imageItemProvider: item)
                } catch {
                    let alert = NSAlert()
                    alert.messageText = "Failed to import image: \(error.localizedDescription)"
                    alert.runModal()
                }
            }
        }
    }
}

#endif
