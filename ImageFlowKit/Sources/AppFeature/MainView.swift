import CanvasFeature
import CommonUtils
import Models
import NodeView
import SwiftUI

#if os(macOS)
typealias MainView = MainViewMac
#else
typealias MainView = MainViewIPad
#endif

extension MainView {
    func dispatch(action: Action) {
        switch action {
        case .addNode(let data):
            let node = FlowNode(id: data.id, kind: data.kind)
            var pos: CGPoint {
                switch data.position {
                case .center:
                    if let centerView = self.canvasViewRef.view?.frame.center {
                        let view = NodeView(node)
                        let size = view.intrinsicContentSize
                        let pos = centerView - (size * 0.5).cgPoint
                        return self.document.canvas.viewport.convert(pos, from: .screen, to: .canvas)
                    } else {
                        return .zero
                    }
                case .point(let point):
                    return point
                }
            }
            self.document.addNode(node: .init(id: data.id, kind: data.kind), at: pos)
        }
    }
}
