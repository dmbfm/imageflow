import Foundation
import Helpers
import NodeView
import SharedModels
import Values

extension CanvasFeatureViewModel: NodeViewDelegate {
    public func nodeView(willShowContextMenuForNode node: UUID) {
        // self.flow.select([node])
    }

    public func nodeView(contextMenuForNode node: UUID, at point: CGPoint?) -> PlatformMenu? {
        if self.nodeContextMenuProvider == nil {
            self.nodeContextMenuProvider = .init(coordinator: self.coordinator)
        }

        return self.nodeContextMenuProvider?.makeMenu(forNode: node, at: point ?? .zero)
    }

    public func nodeViewSelectedNodesCount() -> Int {
        self.flow.selection.count
    }

    public func openAssetPicker(node: UUID, portIndex: Int, kind: AssetKind) {
        self.coordinator.perform(userAction: .openAssetPicker(node: node, portIndex: portIndex, kind: kind))
    }

    public func titleForAsset(id: AssetIdentifier) -> String? {
        return if case let .asset(id) = id {
            self.assetStore.assets[id]?.filename
        } else {
            nil
        }
    }
}
