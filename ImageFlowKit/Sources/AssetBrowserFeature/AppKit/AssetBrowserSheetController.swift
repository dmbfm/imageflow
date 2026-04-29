#if canImport(AppKit)

import AppKit
import SwiftUI
import SharedModels
import UniformTypeIdentifiers

public final class AssetBrowserSheetController: NSHostingController<AssetBrowserView> {

    let vm: AssetBrowserViewModel
    let assetStore: any AssetStoreService

    public init(
        assetStore: any AssetStoreService,
        type: AssetBrowserType,
    ) {
        self.assetStore = assetStore
        self.vm = .init(
            assetsProvider: assetStore,
            assetBrowserType: type,
        )

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

extension AssetBrowserSheetController: AssetBrowserViewModel.Delegate {
    public func onDismiss(_ result: AssetBrowserResult) {
        logger.warning("TODO: onDismiss:\("\(result)")")
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

        _ = Task<(), Never> {
            let result = await self.doImport(urls)
            let errorMessages: [String] = result.compactMap {
                switch $0 {
                case .failure(let err): err.localizedDescription
                case .success: nil
                }
            }

            if !errorMessages.isEmpty {
                let alert = NSAlert()
                alert.messageText = "Failed to import some files!"
                alert.runModal()
            }
        }

    }

    public func openPhotoPicker() {
        logger.warning("TODO: openPhotoPicker")
    }

    public func deleteAsset(_ asset: SharedModels.Asset) {
        logger.warning("TODO: deleteAsset: \("\(asset)")")
    }
}

extension AssetBrowserSheetController {
    func doImport(_ urls: [URL]) async -> [Result<UUID, any Error>] {

        func importItem(_ url: URL) async -> Result<UUID, any Error> {
            logger.info("\(url): start")
            let isSSR = url.startAccessingSecurityScopedResource()
            defer {
                if isSSR {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let resourceValues = try url.resourceValues(forKeys: [.contentTypeKey])
                let utType = resourceValues.contentType

                guard let kind = utType?.assetKind else {
                    throw ImportItemError.missingUTType
                }

                let id = try await self.assetStore.addAsset(fromURL: url, kind: kind, undoManager: self.undoManager)
                self.undoManager!.setActionName("Import Image")
                logger.info("\(url): done!")
                return .success(id)
            } catch {
                return .failure(error)
            }
        }

        enum ImportItemError: Error {
            case missingUTType
        }

        return await withTaskGroup(of: Result<UUID, any Error>.self, returning: [Result<UUID, any Error>].self) {
            group in
            for url in urls {
                group.addTask {
                    await importItem(url)
                }
            }

            var result: [Result<UUID, any Error>] = []
            for await item in group {
                result.append(item)
            }
            return result
        }
    }
}

#endif
