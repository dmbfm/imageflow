//
//  NodeInputRowView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import Helpers
import SwiftUI

final class NodeOutputRowView: PlatformCommonView {
    var output: FlowNode.Output {
        didSet {
            if self.output != oldValue {
                self.update()
            }
        }
    }

    var drawPortAsConnected: Bool = false {
        didSet {
            self.portView.connected = self.drawPortAsConnected || self.output.connected
        }
    }

    var onEvent: ((Event) -> ())?

    private var style: Style

    lazy var portView: PortView = {
        let view = PortView(connected: self.output.connected, style: self.style.port)

        view.onEvent = { [weak self] event in
            switch event {
            case .drag(let data):
                self?.onEvent?(.dragPort(data))
            }
        }

        return view
    }()

    #if os(macOS)
    lazy var labelView: NSTextField = {
        .init(nodeRowLabelWithString: self.output.label, font: self.style.labelFont.font, color: self.style.labelColor)
    }()
    #endif

    #if os(iOS)
    lazy var labelView: UILabel = {
        .init(nodeRowLabelWithString: self.output.label, font: self.style.labelFont.font, color: self.style.labelColor)
    }()
    #endif

    init(_ output: FlowNode.Output, style: Style = .default) {
        self.output = output
        self.style = style

        super.init(frame: .zero)

        self.addSubview(self.portView)
        self.addSubview(self.labelView)

        self.update()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func update() {
        self.portView.connected = self.drawPortAsConnected || self.output.connected
        if self.output.label != self.labelView.text {
            self.labelView.text = self.output.label
            self.onEvent?(.sizeDidChange)
        }
        self.portView.setNeedsDisplay()
        self.setNeedsDisplay()
        self.setNeedsLayout()
    }

    var labelSize: CGSize {
        #if os(macOS)
        self.labelView.intrinsicContentSize + .init(width: self.widthFix, height: 0)
        #else
        self.labelView.intrinsicContentSize
        #endif
    }

    #if os(macOS)
    let widthFix: CGFloat = 2.0
    #else
    let widthFix: CGFloat = 0.0
    #endif

    override var intrinsicContentSize: CGSize {
        let width = self.portView.intrinsicContentSize.width + style.portLabelSpacing + labelSize.width - self.widthFix
        let height = style.rowHeight
        return .init(width: width, height: height)
    }

    override func doLayout() {
        let portSize = self.portView.intrinsicContentSize.width
        self.portView.frame = .init(
            x: self.bounds.width - portSize,
            y: 0,
            width: portSize,
            height: portSize
        )
        self.labelView.frame = .init(
            x: self.portView.frame.minX - self.labelSize.width - style.portLabelSpacing,
            y: 0,
            width: self.labelSize.width,
            height: self.labelSize.height
        )
        Layout.align(
            views: [self.portView, self.labelView],
            alignment: .verticalCenter,
            guide: .constant(self.bounds.midY)
        )
    }
}

extension NodeOutputRowView {
    public enum Event {
        case sizeDidChange
        case dragPort(PortView.DragData)
    }
}

extension NodeOutputRowView {
    struct Style: Sendable, Hashable, With {

        var labelFont: FontStyle
        var labelColor: PlatformColor
        var rowHeight: CGFloat
        var portLabelSpacing: CGFloat
        var port: PortView.Style

        static var `default`: Self {
            .init(
                labelFont: .systemFont(size: 14, weight: .regular),
                labelColor: .secondaryLabel,
                rowHeight: 32.0,
                portLabelSpacing: 8.0,
                port: .default,
            )
        }
    }
}

extension NodeOutputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            NodeOutputRowView(.init(label: "Something", index: 0, type: .float, connected: false))
        }

        func updateView(_ view: ViewType, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeOutputRowView.Preview()
            .border(.gray.opacity(0.2))
        // .border(.red)
    }
    .padding(50)
    .background(.white)
}
