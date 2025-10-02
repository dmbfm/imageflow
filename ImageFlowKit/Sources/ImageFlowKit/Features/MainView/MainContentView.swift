import Helpers
import SwiftUI

#if os(macOS)
typealias MainContentView = MainContentViewMacOS
#endif

#if os(iOS)
typealias MainContentView = MainContentViewIPadOS
#endif

protocol MainContentViewProtocol: View {
    init(flow: Flow, canvas: CanvasFeatureState)
}

extension MainContentView: MainContentViewProtocol {}

extension MainContentView {
    func createNodeAtCanvasCenter(fromPaletteItem item: NodePaletteItem) {
        var node = FlowNode(kind: item.nodeKind)
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
}
