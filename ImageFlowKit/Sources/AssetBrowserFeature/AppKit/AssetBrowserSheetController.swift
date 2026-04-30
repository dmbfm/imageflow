#if canImport(AppKit)

import AppKit
import SwiftUI
import SharedModels
import UniformTypeIdentifiers

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
    }
}

extension AssetBrowserSheetController: AssetBrowserViewModel.Delegate {
    public func onDismiss(_ result: AssetBrowserResult) {
        logger.warning("TODO: onDismiss:\("\(result)")")
        switch result {
        case .cancel:
            break
        case let .create(assetKind, id):
            self.delegate?.assetBrowserSheetCreateNode(kind: assetKind, assetId: id)
        case let .pick(assetKind, assetId, portLocation):
            self.delegate?.assetBrowserSheetPickAsset(kind: assetKind, assetId: assetId, port: portLocation)
            break
        }
        self.dismiss(nil)
    }

    public func openFileImporter(_ fileTypes: [UTType]) {
        logger.warning("TODO: openFileImporter:\("\(fileTypes)")")

        let panel = NSOpenPanel.init()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        panel.allowedContentTypes = self.vm.allowedImportTypes
        panel.allowsOtherFileTypes = false

        let res = panel.runModal()
        logger.info("res: \("\(res)")")
        let urls = panel.urls

        if !urls.isEmpty {
            self.delegate?.assetBrowserSheetImportAssets(self, urls: urls)
        }
    }

    public func openPhotoPicker() {
        logger.warning("TODO: openPhotoPicker")
    }

    public func deleteAsset(_ asset: SharedModels.Asset) {
        logger.warning("TODO: deleteAsset: \("\(asset)")")
    }
}

#endif
