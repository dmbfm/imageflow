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
        let view: any NodeControl =
            switch self.input.value.type {
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
    
    var portView: PortView!
    var labelView: UILabel!
    var stack: UIStackView!
    var control: (any NodeControl)!
    
    init(_ input: FlowNode.Input) {
        
        super.init(frame: .zero)
        
        self.portView = {
            let view = PortView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.widthAnchor.constraint(equalToConstant: Design.default.portSize).isActive = true
            view.heightAnchor.constraint(equalToConstant: Design.default.portSize).isActive = true
            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
            return view
        }()
        
        self.labelView = {
            let label = UILabel(nodeRowLabelWithString: input.label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            label.setContentCompressionResistancePriority(.required, for: .horizontal)
            return label
        }()
        
        let emptyView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentHuggingPriority(.defaultLow, for: .horizontal)
            view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            return view
        }()
        
        self.control = {
            let view: (any NodeControl) = switch input.value.type {
            case .float:
                NodeNumberInput(input.value)
            default:
                StaticLabelNodeControl(input.value, "...")
            }
            
            if let v = view as? NodeNumberInput {
                v.sizeDidChange = { [weak self] in
                    self?.invalidateIntrinsicContentSize()
                }
            }
            
            view.translatesAutoresizingMaskIntoConstraints = false
            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
            return view
        }()
        
        self.control.valueDidChange = { [weak self] value in
            self?.invalidateIntrinsicContentSize()
        }
        
        self.stack = {
            let view = UIStackView(arrangedSubviews: [self.portView, self.labelView, emptyView, self.control])
            view.translatesAutoresizingMaskIntoConstraints = false
            view.axis = .horizontal
            view.alignment = .center
            
            view.setCustomSpacing(Design.default.portLabelSpacing, after: self.portView)
            view.setCustomSpacing(Design.default.labelControlSpacing, after: self.labelView)
            
            return view
        }()
        
        self.addSubview(self.stack)
        self.stack.constraintToFill(self)
        
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override var intrinsicContentSize: CGSize {
        let width = Design.default.portSize
            + Design.default.portLabelSpacing
        + self.labelView.intrinsicContentSize.width
        + Design.default.labelControlSpacing
        + self.control.intrinsicContentSize.width
        return .init(width: width, height: 50)
    }
    
}
#endif


extension NodeInputRowView {
    fileprivate struct Preview: PlatformViewRepresentable {
        var input: FlowNode.Input = .init(
            label: "Something",
            index: 0,
            value: .float(0.5),
            semantics: .default,
            connected: false
        )
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

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeInputRowView.Preview()
            .border(.gray.opacity(0.12))

        NodeInputRowView.Preview(
            input: .init(label: "Other", index: 1, value: .bool(true), semantics: .default, connected: true)
        )
        .border(.gray.opacity(0.12))
    }
    .padding(200)
    .background(.white)
}
