#if canImport(AppKit)

import AppKit
import Models
import Values

// MARK: - NodeInputBlockNSView

final class NodeInputBlockNSView: NSView {

    public var inputs: [FlowNode.Input] {
        didSet {
            if self.inputs != oldValue {
                self.update()
            }
        }
    }

    public private(set) var rows: [NodeInputRowView] = []

    public var onEvent: ((Event) -> ())?

    public enum Event {
        case sizeDidChange
        case valueDidChange(Value)
    }

    init(_ inputs: [FlowNode.Input]) {
        self.inputs = inputs

        super.init(frame: .zero)

        self.populateRows()
    }

    required init?(coder: NSCoder) {
        nil
    }

    private func update() {
        assert(self.inputs.count == self.rows.count, "Changing the number of inputs is not supported")

        for (idx, input) in self.inputs.enumerated() {
            if input != self.rows[idx].input {
                self.rows[idx].input = input
            }
        }
    }

    private func populateRows() {
        assert(self.rows.isEmpty)

        for input in self.inputs {
            let row = NodeInputRowView(input)
            row.onEvent = { [weak self] event in
                guard let self else { return }
                switch event {
                case .sizeDidChange:
                    self.needsLayout = true
                    self.invalidateIntrinsicContentSize()
                    self.onEvent?(.sizeDidChange)
                case .valueDidChange(let value):
                    self.onEvent?(.valueDidChange(value))
                }
            }
            self.addSubview(row)
            self.rows.append(row)
        }

        self.needsLayout = true
        self.invalidateIntrinsicContentSize()
        self.onEvent?(.sizeDidChange)
    }
}

// MARK: - Layout

extension NodeInputBlockNSView {

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
}

#endif
