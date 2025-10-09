import Helpers
import Logging
import SwiftUI

#if os(macOS)
typealias MainContentView = MainContentViewMacOS
#endif

#if os(iOS)
typealias MainContentView = MainContentViewIPadOS
#endif

protocol MainContentViewProtocol: View {
    init(flow: Flow, canvas: CanvasFeatureState, assetStore: AssetStore)
}

extension MainContentView: MainContentViewProtocol {}

extension MainContentView {
    func createNodeAtCanvasCenter(fromPaletteItem item: NodePaletteItem) {
        let node = FlowNode(kind: item.nodeKind)
        self.createNodeAtCanvasCenter(node)
    }

    func createNodeAtCanvasCenter(_ node: FlowNode) {
        var node = node
        let pos: CGPoint = {
            let view = NodeView(node)
            let size = view.intrinsicContentSize
            let pos = self.canvasCenter.value - (size * 0.5).cgPoint
            return self.canvas.viewport.convert(pos, from: .screen, to: .canvas)
        }()
        node.position = pos
        self.flow.newNodeAction(node, undoManager: self.undoManager)
        self.flow.select([node.id])
    }

    func onAssetBrowserDismiss(_ result: AssetBrowserResult) {
        log("asset browser result: \(result), type: \(self.assetBrowserType)")

        switch result {
        case .create(let id):
            var node = FlowNode(id: .init(), kind: .valueNode(.image))
            node.inputs[0].value = .image(.asset(id))
            self.createNodeAtCanvasCenter(node)
        default:
            break
        }
    }
}
