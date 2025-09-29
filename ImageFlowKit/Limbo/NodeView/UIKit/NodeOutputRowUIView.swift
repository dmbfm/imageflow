//
//
//  NodeOutputRowUIView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if canImport(UIKit)

import CanvasView
import ColorUtils
import CommonUtils
import Design
import Easing
import EventEmitter
import Models
import PlatformUtils
import SwiftUI

final class NodeOutputRowUIView: UIView, NodeOutputRowViewProtocol {

    var output: FlowNode.Output {
        didSet {
            self.update()
        }
    }

    public var drawPortAsConnected: Bool = false {
        didSet {
            self.portView.connected = self.drawPortAsConnected || self.output.connected
        }
    }

    var onEvent: ((Event) -> ())?

    var label: UILabel

    var portView: PortView

    init(_ output: FlowNode.Output) {

        self.output = output
        self.label = UILabel(nodeRowLabelWithString: output.label)
        self.portView = PortView(connected: output.connected)
        self.portView.frame = .init(
            origin: .zero,
            size: .init(width: Design.default.portSize, height: Design.default.portSize)
        )

        super.init(frame: .zero)

        self.portView.onEvent = { [weak self] event in
            switch event {
            case .drag(let data):
                self?.onEvent?(.dragPort(data))
            }
        }

        self.addSubview(self.label)
        self.addSubview(self.portView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update() {
        self.portView.connected = self.drawPortAsConnected || self.output.connected
        self.label.text = self.output.label
        self.onEvent?(.sizeDidChange)
    }

    override var intrinsicContentSize: CGSize {
        let width =
            self.label.intrinsicContentSize.width
            + Design.default.portLabelSpacing
            + Design.default.portSize
        let height = Design.default.nodeRowHeight
        return .init(width: width, height: height)

    }

    override func layoutSubviews() {
        let labelSize = self.label.intrinsicContentSize
        self.portView.frame = .init(
            x: self.bounds.maxX - Design.default.portSize,
            y: 0,
            width: Design.default.portSize,
            height: Design.default.portSize
        )
        self.label.frame = .init(
            x: self.portView.frame.minX - labelSize.width - Design.default.portLabelSpacing,
            y: 0,
            width: labelSize.width,
            height: labelSize.height
        )
        Layout.align(
            views: [self.portView, self.label],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }
}

#endif
