#if os(iOS)

import CommonUtils
import Models
import PlatformUtils
import SwiftUI

final class NodeOutputBlockUIView: PlatformView {
    var rows: [NodeOutputRowView] = []

    init(_ outputs: [FlowNode.Output]) {
        super.init(frame: .zero)

        for output in outputs {
            let row = NodeOutputRowView(output)
            self.addSubview(row)
            self.rows.append(row)
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let p = self.convert(point, to: nil)
        for row in rows {
            if let view = row.portView.hitTest(row.portView.convert(p, from: nil), with: event) {
                return view
            }
        }
        return nil
    }
    
    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        let width = self.rows.map { $0.intrinsicContentSize.width }.reduce(-.infinity, { max($0, $1) })
        let height = Design.default.nodeRowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layoutSubviews() {
        for (i, row) in self.rows.enumerated() {
            row.frame = .init(
                x: 0,
                y: Design.default.nodeRowHeight * CGFloat(i),
                width: self.bounds.width,
                height: Design.default.nodeRowHeight
            )
        }
    }
}

#endif
