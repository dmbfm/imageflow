import Foundation
import Helpers
import Logging
import NodeView
import SharedModels
import Values

extension CanvasFeatureViewModel {
    func setNodeValue(
        _ id: UUID,
        _ index: Int,
        _ oldValue: Value?,
        _ newValue: Value,
    ) {
        guard let node = self.flow.nodes[id] else {
            log("Node not found: \(id)", level: .error)
            return
        }

        guard node.inputs.indices.contains(index) else {
            log("Node input index out of range: \(index)", level: .error)
            return
        }

        let oldValue = oldValue ?? node.inputs[index].value

        if let view = self.nodeViews[id] {
            let viewValue = view.value(inputIntex: index)!

            if viewValue != newValue {
                view.setValue(inputIntex: index, value: newValue)
            }
        }

        guard oldValue != newValue else {
            log("New value is equal to old value; nothing to do", level: .info)
            return
        }

        self.flow.nodes[id]?.inputs[index].value = newValue

        self.undoManager?.registerUndo(
            withTarget: self,
            handler: { this in
                this.setNodeValue(id, index, newValue, oldValue)
            }
        )
        self.undoManager?.setActionName("\(newValue.type.displayName) Value Change")
    }
}

extension CanvasFeatureViewModel: NodeViewDelegate {
    public func nodeView(
        registerUndoForNode id: UUID,
        inputIndex: Int,
        oldValue: Values.Value,
        newValue: Values.Value
    ) {
        self.setNodeValue(id, inputIndex, oldValue, newValue)
    }

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
        self.assetStore.titleForAsset(id: id)
    }

    public func statusBarMessage(message: String?) {
        self.coordinator.statusBar(message)
    }

    public var emitter: EventEmitter<NodeViewDelegateEvent> {
        self.nodeViewDelegateEmitter
    }
}
