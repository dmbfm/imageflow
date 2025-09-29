//
//  NodeInputBlockUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if canImport(UIKit)

import SwiftUI

final class NodeInputBlockUIView: UIView, NodeInputBlockViewProtocol {

    public var inputs: [FlowNode.Input] {
        didSet {
            if self.inputs != oldValue {
                self.update()
            }
        }
    }

    public private(set) var rows: [NodeInputRowView] = []

    public var onEvent: ((Event) -> ())?

    init(_ inputs: [FlowNode.Input]) {
        self.inputs = inputs

        super.init(frame: .zero)

        self.popluateRows()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update() {
        assert(self.inputs.count == self.rows.count, "Changing the number of inputs is not supported")

        for (idx, input) in self.inputs.enumerated() {
            if input != self.rows[idx].input {
                self.rows[idx].input = input
            }
        }
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    func popluateRows() {
        for input in inputs {
            let row = NodeInputRowView(input)
            row.onEvent = { [weak self] event in
                switch event {
                case .valueDidChange(let value):
                    self?.onEvent?(.valueDidChange(input.index, value))
                case .dragPort(let data):
                    self?.onEvent?(.dragPort(input.index, data))
                case .sizeDidChange:
                    self?.updateSize()
                }
            }
            self.rows.append(row)
            self.addSubview(row)
        }

        self.updateSize()
    }

    override var intrinsicContentSize: CGSize {
        let width = self.rows.reduce(0.0, { max($0, $1.intrinsicContentSize.width) })
        let height = Design.default.nodeRowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layoutSubviews() {
        for (idx, row) in self.rows.enumerated() {
            row.frame = .init(
                x: 0,
                y: Design.default.nodeRowHeight * CGFloat(idx),
                width: self.bounds.width,
                height: Design.default.nodeRowHeight
            )
        }
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let p = self.convert(point, to: nil)
        for row in rows {
            if let view = row.portView.hitTest(row.portView.convert(p, from: nil), with: event) {
                return view
            }

            if let controlView = row.controlView,
                let view = controlView.hitTest(controlView.convert(p, from: nil), with: event)
            {
                return view
            }
        }
        return nil
    }
}
#endif
