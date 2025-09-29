#if canImport(UIKit)

import SwiftUI

final class NodeOutputBlockUIView: PlatformView, NodeOutputBlockViewProtocol {

    public var outputs: [FlowNode.Output] {
        didSet {
            if self.outputs != oldValue {
                self.update()
            }
        }
    }

    public private(set) var rows: [NodeOutputRowView] = []

    public var onEvent: ((Event) -> ())?

    public init(_ outputs: [FlowNode.Output]) {
        self.outputs = outputs

        super.init(frame: .zero)

        self.populateRows()
    }

    func populateRows() {
        for output in outputs {
            let row = NodeOutputRowView(output)
            row.onEvent = { [weak self] event in
                switch event {
                case .sizeDidChange:
                    self?.updateSize()
                case .dragPort(let data):
                    self?.onEvent?(.dragPort(output.id, data))
                }
            }
            self.addSubview(row)
            self.rows.append(row)
        }
    }

    func update() {
        assert(self.outputs.count == self.rows.count, "Changing the number of inputs is not supported")
        for (idx, output) in outputs.enumerated() {
            if output != self.rows[idx].output {
                self.rows[idx].output = output
            }
        }
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
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
