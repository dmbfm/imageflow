#if canImport(AppKit)

import AppKit
import Models

final class NodeOutputBlockNSView: NSView, NodeOutputBlockViewProtocol {

    public var outputs: [FlowNode.Output] {
        didSet {
            if self.outputs != oldValue {
                self.update()
            }
        }
    }

    public private(set) var rows: [NodeOutputRowView] = []

    public var onEvent: ((Event) -> ())?

    init(_ outputs: [FlowNode.Output]) {
        self.outputs = outputs

        super.init(frame: .zero)

        self.populateRows()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update() {
        assert(self.outputs.count == self.rows.count, "Changing the number of inputs is not supported")

        for (idx, output) in self.outputs.enumerated() {
            if output != self.rows[idx].output {
                self.rows[idx].output = output
            }
        }
    }

    func populateRows() {
        assert(self.rows.isEmpty)

        for output in self.outputs {
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

        updateSize()
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.onEvent?(.sizeDidChange)
    }

    override var isFlipped: Bool {
        true
    }

    override var intrinsicContentSize: NSSize {
        let width = self.rows.reduce(0.0, { max($0, $1.intrinsicContentSize.width) })
        let height = Design.default.nodeRowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layout() {
        for (idx, row) in self.rows.enumerated() {
            row.frame = .init(
                x: 0,
                y: Design.default.nodeRowHeight * CGFloat(idx),
                width: self.bounds.width,
                height: Design.default.nodeRowHeight
            )
        }
    }

    override func hitTest(_ point: NSPoint) -> NSView? {
        for row in self.rows {
            let point = row.convert(point, from: self.superview)
            if let view = row.portView.hitTest(point) {
                return view
            }
        }

        return nil
    }
}

#endif
