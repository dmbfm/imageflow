//
//  NodeInputRowView.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 03/08/25.
//

import CanvasView
import ColorUtils
import Design
import Easing
import EventEmitter
import Models
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
typealias NodeOutputRowView = NodeOutputRowAppKitView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeOutputRowView = NodeOutputRowUIKitView
#endif

#if os(macOS)
final class NodeOutputRowAppKitView: NSView {

    public var output: FlowNode.Output {
        didSet {

        }
    }

    // MARK: - Private Properties

    var style = Style()

    // MARK: - Private Types

    struct Style {
        var portSize: CGFloat = 16
        var labelFontSize: CGFloat = 10
        var labelControlSpacing: CGFloat = 8
        var trailingPadding: CGFloat = 8
        var height: CGFloat = 22
    }

    // MARK: - Subviews

    lazy var stackView: NSStackView = {
        let v = NSStackView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.orientation = .horizontal
        v.alignment = .centerY
        v.spacing = 0
        v.addView(self.labelView, in: .trailing)
        v.addView(self.portView, in: .trailing)
        return v
    }()

    lazy var portView: PortView = {
        let view = PortView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.connected = self.output.connected
        view.widthAnchor.constraint(equalToConstant: style.portSize).isActive = true
        return view
    }()

    lazy var labelView: NSTextField = {
        let view = NSTextField(labelWithString: self.output.label)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .secondaryLabelColor
        view.font = .systemFont(ofSize: style.labelFontSize)
        return view
    }()

    // MARK: - Initializers

    init(_ output: FlowNode.Output) {
        self.output = output

        super.init(frame: .zero)

        self.setupLayout()
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Layout
    func setupLayout() {
        self.addSubview(self.stackView)
        self.stackView.constraintToFill(self)
    }

    override var intrinsicContentSize: NSSize {
        let portSize = style.portSize
        let labelSize = self.labelView.intrinsicContentSize
        let result = CGSize(
            width: portSize + labelSize.width + style.labelControlSpacing + style.trailingPadding,
            height: style.height  //max(portSize, labelSize.height, controlSize.height)
        )
        return result
    }
}
#endif

//
//final class NodeInputRowView: PlatformView {
//
//    class DummyControlView: NSView {
//        override init(frame frameRect: NSRect) {
//            super.init(frame: frameRect)
//            self.wantsLayer = true
//            self.layer?.backgroundColor = .blue
//        }
//        required init?(coder: NSCoder) {
//            nil
//        }
//
//        override var intrinsicContentSize: NSSize {
//            .init(width: 50, height: 50)
//        }
//    }
//
//    var input: FlowNode.Input {
//        didSet {
//        }
//    }
//
//    #if os(macOS)
//    lazy var stackView: NSStackView = {
//        let view = NSStackView(views: [])
//        view.orientation = .horizontal
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.wantsLayer = true
//        view.layer?.borderColor = .black
//        view.layer?.borderWidth = 1
//
//        view.setContentCompressionResistancePriority(.fittingSizeCompression, for: .vertical)
//        view.setContentHuggingPriority(.fittingSizeCompression, for: .vertical)
//
//        view.addView(self.labelView, in: .top)
//        view.addView(self.controlView, in: .bottom)
//
//        return view
//    }()
//
//    lazy var portView: NSView = {
//        fatalError("TODO")
//    }()
//
//
//    lazy var labelView: NSTextField = {
//        let view = NSTextField(labelWithString: input.label)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var controlView: NSView = {
//        let container = NSView()
//        container.translatesAutoresizingMaskIntoConstraints = false
//        let view = DummyControlView(frame: .zero)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    #endif
//
//    init(_ input: FlowNode.Input) {
//        self.input = input
//        super.init(frame: .zero)
//
//        self.addSubview(self.stackView)
//
//        NSLayoutConstraint.activate([
//            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//        ])
//    }
//
//    required init?(coder: NSCoder) {
//        nil
//    }
//}
//

// MARK: - iOS

#if os(iOS)
class NodeOutputRowUIKitView: UIView {

    public var output: FlowNode.Output {
        didSet {

        }
    }

    // MARK: - Subviews
    lazy var labelView: UILabel = {
        let view = UILabel()
        view.text = self.output.label
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .secondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.layer.borderColor = .blue
        //        view.layer.borderWidth = 2
        return view
    }()

    lazy var portView: PortView = {
        let view = PortView(connected: self.output.connected)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()

    lazy var stackView: UIView = {
        let view = UIStackView(arrangedSubviews: [UIView(), self.labelView, self.portView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.setCustomSpacing(4, after: self.labelView)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()

    init(_ output: FlowNode.Output) {
        self.output = output

        super.init(frame: .zero)

        self.addSubview(self.stackView)

        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        nil
    }

    override var intrinsicContentSize: CGSize {
        .init(width: 0, height: 32)
    }

}
#endif

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

#Preview {
    VStack {
        NodeOutputRowView.Preview()
            .border(.gray.opacity(0.2))
        // .border(.red)
    }
    .padding(50)
    .background(.white)
}
