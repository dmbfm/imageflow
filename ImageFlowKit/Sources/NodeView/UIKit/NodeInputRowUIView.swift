//
//  NodeInputRowUView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 11/08/25.
//

#if canImport(UIKit)

import CanvasView
import ColorUtils
import Design
import Easing
import EventEmitter
import Models
import NodeControls
import PlatformUtils
import SwiftUI
import Values

class NodeInputRowUIView: UIView {

    lazy var portView: PortView = {
        let view = PortView()
        return view
    }()

    lazy var labelView: UILabel = {
        let view = UILabel(nodeRowLabelWithString: "")
        return view
    }()

    let xPaddings: [CGFloat] = [
        Design.default.portLabelSpacing,
        Design.default.labelControlSpacing,
    ]

    var controlView: (any NodeControl)?

    var onEvent: ((Event) -> ())?

    enum Event {
        case valueDidChange(Value)
        case sizeDidChange
    }

    init(_ input: FlowNode.Input) {
        super.init(frame: .zero)

        self.addSubview(self.portView)
        self.portView.connected = input.connected

        self.addSubview(self.labelView)
        self.labelView.text = input.label

        self.controlView =
            switch input.value.type {
            case .float:
                NodeNumberInput(input.value)
            default:
                StaticLabelNodeControl(input.value, "<\(input.value.type)>")
            }
        self.controlView!.onEvent = { [weak self] event in
            switch event {
            case .valueDidChange(let value):
                self?.onEvent?(.valueDidChange(value))
                break
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.setNeedsLayout()
                self?.onEvent?(.sizeDidChange)
            }
        }
        self.addSubview(self.controlView!)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        let portSize = self.portView.intrinsicContentSize
        let labelSize = self.labelView.intrinsicContentSize
        let controlSize = self.controlView?.intrinsicContentSize ?? .zero

        let width = portSize.width + labelSize.width + controlSize.width + self.xPaddings.reduce(0.0, +)
        let height = max(portSize.height, labelSize.height, controlSize.height)

        return .init(width: width, height: height)
    }

    override func layoutSubviews() {
        self.portView.frame = .init(origin: .zero, size: self.portView.intrinsicContentSize)
        self.labelView.frame = .init(
            origin: .init(x: self.portView.frame.maxX + self.xPaddings[0], y: 0),
            size: self.labelView.intrinsicContentSize
        )

        if let controlView = self.controlView {
            controlView.frame = CGRect(
                origin: .init(x: self.bounds.maxX - controlView.intrinsicContentSize.width, y: 0),
                size: controlView.intrinsicContentSize
            )  //.init(center: CGRect(x: 0, y: 0), size: controlView.intrinsicContentSize)
            Layout.align(
                views: [self.portView, self.labelView, controlView],
                alignment: .verticalCenter,
                guide: .constant(self.bounds.midY)
            )
        } else {
            Layout.align(
                views: [self.portView, self.labelView],
                alignment: .verticalCenter,
                guide: .constant(self.bounds.midY)
            )
        }

    }
}

#endif
