#if canImport(AppKit)

import AppKit
import Backend
import AssetBrowserFeature
import SharedModels
import UniformTypeIdentifiers
import Values

extension MainViewController: AssetBrowserSheetController.Delegate {
    func assetBrowserSheetPickAsset(kind: SharedModels.AssetKind, assetId: UUID, port: SharedModels.InputPortLocation) {
        if let value: Value = Value(assetKind: kind, assetId: .asset(assetId)) {
            assert(
                self.flow.nodes[port.node]![valueAt: .input(port.index)].type == kind.valueType
            )
            self.flow.setNodeValue(
                id: port.node,
                index: port.index,
                oldValue: nil,
                newValue: value,
                undoManager: self.undoManager
            )
        } else {
            logger.error("Failed to create value for asset: kind: \("\(kind)"), id: \(assetId)")
        }
    }

    func assetBrowserSheetCreateNode(kind: SharedModels.AssetKind, assetId: UUID) {
        if let value: Value = .init(assetKind: kind, assetId: .asset(assetId)),
            let nodeKind = kind.nodeKind,
            let inputIndex = kind.nodeInputIndex
        {
            var node = FlowNode(id: .init(), kind: nodeKind)
            assert(node.inputs[inputIndex].value.type == kind.valueType)
            node.inputs[inputIndex].value = value
            self.perform(userAction: .newNode(node, at: nil, connectingToExistingPort: nil))
        } else {
            logger.error("Failed to create value for asset: kind: \("\(kind)"), id: \(assetId)")
        }
    }

    func assetBrowserSheetImportAssets(_ sender: AssetBrowserSheetController, urls: [URL]) {
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

    func assetBrowserDeleteAsset(_ sender: AssetBrowserSheetController, asset: SharedModels.Asset) {
        self.undoManager?.beginUndoGrouping()

        for (_, node) in self.flow.nodes {
            for input in node.inputs {
                let id: UUID? = input.value.assetIdentifier?.id

                if id == asset.id {
                    self.flow.setNodeValue(
                        id: node.id,
                        index: input.index,
                        newValue: input.value.type.defaultValue,
                        undoManager: self.undoManager,
                        dontSetActionName: true
                    )
                }
            }
        }

        self.assetStore.removeAsset(asset.id, undoManager: self.undoManager)
        self.undoManager?.setActionName("Remove Asset")
        self.undoManager?.endUndoGrouping()
    }
}

extension MainViewController {
    private func doImport(_ urls: [URL]) async -> [Result<UUID, any Error>] {
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

        return await withTaskGroup(
            of: Result<UUID, any Error>.self,
            returning: [Result<UUID, any Error>].self
        ) { group in
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

extension Value {
    fileprivate init?(assetKind: AssetKind, assetId: AssetIdentifier) {
        self =
            switch assetKind {
            case .image: .image(assetId)
            case .lut: .lut(assetId)
            }
    }
}

extension AssetKind {
    fileprivate var nodeKind: NodeKind? {
        switch self {
        case .image: .valueNode(.image)
        case .lut: .valueNode(.lut)
        }
    }

    fileprivate var nodeInputIndex: Int? {
        switch self {
        case .image: 0
        case .lut: 0
        }
    }
}

#endif
