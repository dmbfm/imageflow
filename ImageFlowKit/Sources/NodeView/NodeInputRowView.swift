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
import NodeControls
import PlatformUtils
import SwiftUI
import Values

#if canImport(AppKit)
import AppKit
typealias NodeInputRowView = NodeInputRowAppKitView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeInputRowView = NodeInputRowUIKitView
#endif

// MARK: - macOS
#if os(macOS)
final class NodeInputRowAppKitView: NSView {

    // MARK: - Public Properties

    public var input: FlowNode.Input {
        didSet {
            self.portView.connected = input.connected
            self.labelView.stringValue = input.label
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

    class DummyControl: NSView, NodeControl {
        var tintColor: PlatformUtils.PlatformColor = .blue

        var value: Values.Value {
            didSet {
                if self.value != oldValue {
                    self.slider.doubleValue = self.value.float
                }
            }
        }

        var valueDidChange: ((Values.Value) -> ())?

        var slider: NSSlider!

        init(_ value: Value) {
            self.value = value
            super.init(frame: .zero)

            self.slider = NSSlider(target: self, action: #selector(Self.onSliderChange))
            self.slider.doubleValue = value.float
            self.slider.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(self.slider)
            self.slider.constraintToFill(self, edgeInsets: .init(top: 0, left: 2, bottom: 0, right: 2))
        }

        @objc
        func onSliderChange() {
            self.value = .float(self.slider.doubleValue)
            self.valueDidChange?(self.value)
        }

        required init?(coder: NSCoder) {
            nil
        }

        override var intrinsicContentSize: NSSize {
            .init(width: 100, height: self.slider.intrinsicContentSize.height + 2)
        }

    }

    // MARK: - Subviews

    lazy var portView: PortView = {
        let view = PortView()
        view.connected = self.input.connected
        view.widthAnchor.constraint(equalToConstant: style.portSize).isActive = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var labelView: NSTextField = {
        let view = NSTextField(labelWithString: self.input.label)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.textColor = .secondaryLabelColor
        view.font = .systemFont(ofSize: style.labelFontSize)
        return view
    }()

    lazy var controlView: NSView = {
        let view: any NodeControl = switch self.input.value.type {
            case .float:
                DummyControl(self.input.value)
            default: 
                StaticLabelNodeControl(self.input.value, "<\(self.input.value.type)>")
        }
        view.valueDidChange = { newValue in
            print("new value: \(newValue)")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: NSStackView = {
        let view = NSStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 0
        view.orientation = .horizontal
        view.alignment = .centerY
        view.addView(self.portView, in: .leading)
        view.addView(self.labelView, in: .leading)
        view.addView(self.controlView, in: .trailing)
        view.setCustomSpacing(style.labelControlSpacing, after: self.labelView)
        view.edgeInsets = .init(top: 0, left: 0, bottom: 0, right: style.trailingPadding)
        return view
    }()

    // MARK: - Initializers

    init(_ input: FlowNode.Input) {
        self.input = input

        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFill(self)
        self.stackView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Layout
    override var intrinsicContentSize: NSSize {
        let portSize = style.portSize
        let labelSize = self.labelView.intrinsicContentSize
        let controlSize = self.controlView.intrinsicContentSize
        let result = CGSize(
            width: portSize + labelSize.width + style.labelControlSpacing + controlSize.width + style.trailingPadding,
            height: style.height  //max(portSize, labelSize.height, controlSize.height)
        )
        return result
    }

}
#endif

// MARK: - iOS

#if os(iOS)
class NodeInputRowUIKitView: UIView {

    public var input: FlowNode.Input {
        didSet {

        }
    }

    // MARK: - Subviews
    lazy var labelView: UILabel = {
        let view = UILabel()
        view.text = self.input.label
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .secondaryLabel
        view.translatesAutoresizingMaskIntoConstraints = false
        //        view.layer.borderColor = .blue
        //        view.layer.borderWidth = 2
        return view
    }()

    lazy var portView: PortView = {
        let view = PortView(connected: self.input.connected)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 16).isActive = true
        view.heightAnchor.constraint(equalToConstant: 16).isActive = true
        return view
    }()

    lazy var controlView: UIView = {
        let view = UISlider()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 150).isActive = true
        return view
    }()

    lazy var stackView: UIView = {
        let view = UIStackView(arrangedSubviews: [self.portView, self.labelView, self.controlView])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.distribution = .fill
        view.spacing = 4
        view.setCustomSpacing(16, after: self.labelView)
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 8)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
        return view
    }()

    init(_ input: FlowNode.Input) {
        self.input = input

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
        let labelSize = self.labelView.systemLayoutSizeFitting(UIView.layoutFittingExpandedSize)
        let width = 16.0 + 4 + labelSize.width + 16 + 158
        let height = 32.0
        return .init(width: width, height: height)
    }

}
#endif

extension NodeInputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        var input: FlowNode.Input = .init(label: "Something", index: 0, value: .float(0.5), semantics: .default, connected: false) 
        func makeView(context: Context) -> NodeInputRowView {
            NodeInputRowView(
                self.input
            )
        }

        func updateView(_ view: NodeInputRowView, context: Context) {

        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))

        NodeInputRowView.Preview(input: .init(label: "Other", index: 1, value: .bool(true), semantics: .default, connected: true))
            .border(.gray.opacity(0.12))
    }
    .padding(200)
    .background(.white)
}
