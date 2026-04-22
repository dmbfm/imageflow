import Helpers
import Logging
import SharedModels
import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
import AppKit
#endif

extension CanvasFeatureViewModel {
    var dropTypes: [UTType] {
        [
            .imageFlowNodeKindDragItem,
            .image,
        ]
    }
}

extension CanvasFeatureViewModel: DropDelegate {
    public func performDrop(info: DropInfo) -> Bool {

        var result: Bool = false

        for p in info.itemProviders(for: [.imageFlowNodeKindDragItem]) {
            self.handleNodeKindDrop(p, info.location)
            result = true
        }

        for p in info.itemProviders(for: [.fileURL]) {
            self.handleFileURLDrop(p, info.location)
            result = true
        }

        return result
    }
}

extension CanvasFeatureViewModel {
    fileprivate func handleFileURLDrop(_ p: NSItemProvider, _ location: CGPoint) {
        _ = p.loadObject(
            ofClass: URL.self
        ) { (url: URL?, err: (any Error)?) in
            if let err {
                log("\(err)", level: .error)
                #if os(macOS)
                self.handleFileURLDropUsingPasteboard(location)
                #endif
                return
            }

            guard let url else {
                log("Failed to coerce to URL!", level: .error)
                #if os(macOS)
                self.handleFileURLDropUsingPasteboard(location)
                #endif
                return
            }

            Task { @MainActor in
                do {
                    let id = try await self.assetStore.addAsset(
                        fromURL: url,
                        kind: .image,
                        undoManager: self.undoManager
                    )
                    self.addNodeForAsset(id, location)
                } catch {
                    log("\(error)", level: .error)
                    self.coordinator.perform(
                        internalAction: .errorAlert(SimpleMessageLocalizedError("Error import image: \(error)"))
                    )
                }
            }
        }
    }

    #if os(macOS)
    fileprivate nonisolated func handleFileURLDropUsingPasteboard(_ location: CGPoint) {
        let pb = NSPasteboard(name: .drag)
        for item in (pb.pasteboardItems ?? []) {
            guard let str = item.string(forType: .URL), let url = URL(string: str) else {
                log("missing URL!", level: .error)
                continue
            }

            guard let data = item.data(forType: .tiff) else {
                log("missing tiff data!", level: .error)
                Task { @MainActor in
                    self.coordinator.perform(
                        internalAction: .errorAlert(
                            SimpleMessageLocalizedError("Error import image: missing image data!")
                        )
                    )
                }
                continue
            }

            let filename = url.lastPathComponent

            Task { @MainActor in
                do {
                    let id = try await self.assetStore.addAsset(
                        data: data,
                        filename: filename,
                        kind: .image,
                        undoManager: self.undoManager
                    )
                    self.addNodeForAsset(id, location)
                } catch {
                    log("\(error)", level: .error)
                    self.coordinator.perform(
                        internalAction: .errorAlert(SimpleMessageLocalizedError("Error import image: \(error)"))
                    )
                }
            }
        }
    }
    #endif

    fileprivate func addNodeForAsset(_ id: UUID, _ location: CGPoint) {
        self.undoManager?.setActionName("Import Asset")
        self.undoManager?.endUndoGrouping()

        if self.undoManager?.groupingLevel == 0 {
            self.undoManager?.beginUndoGrouping()
        }

        var node = FlowNode(id: id, kind: .valueNode(.image))
        node.inputs[0].value = .image(.asset(id))
        self.flow.newNodeAction(node, at: self.dropCanvasPosition(location), undoManager: self.undoManager)
    }

    fileprivate func handleNodeKindDrop(_ p: NSItemProvider, _ location: CGPoint) {
        p.loadObject(
            ofClass: NodeKindDragItem.self
        ) { (object: (any NSItemProviderReading)?, err: (any Error)?) in
            if let item = object as? NodeKindDragItem {
                Task { @MainActor in
                    let id = UUID()
                    self.flow.newNodeAction(
                        .init(id: id, kind: item.kind),
                        at: self.dropCanvasPosition(location),
                        undoManager: self.undoManager
                    )
                    self.flow.select([id])
                }
            }
        }
    }

    fileprivate func dropCanvasPosition(_ location: CGPoint) -> CGPoint {
        let offset = self.canvasPlatformView?.safeAreaRect.origin ?? .zero
        return self.state.viewport.convert(location + offset, from: .screen, to: .canvas)
    }
}
