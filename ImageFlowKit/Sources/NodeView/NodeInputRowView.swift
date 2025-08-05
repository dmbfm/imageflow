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
typealias NodeInputRowView = NodeInputRowAppKitView
#endif

#if canImport(UIKit)
import UIKit
typealias NodeInputRowView = NodeInputRowUIKitView
#endif

#if os(macOS)
final class NodeInputRowAppKitView: NSView {
    
    public var input: FlowNode.Input {
        didSet {

        }
    }

    init(_ input: FlowNode.Input) {
        self.input = input
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        nil
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
        func makeView(context: Context) -> NodeInputRowView {
            let a = NodeInputRowView(
                .init(label: "Something", index: 0, value: .float(0.5), semantics: .default, connected: false)
            )
            a.translatesAutoresizingMaskIntoConstraints = false
            a.widthAnchor.constraint(equalToConstant: 400).isActive = true
            return a
        }

        func updateView(_ view: NodeInputRowView, context: Context) {

        }

//        func sizeThatFits(_ proposal: ProposedViewSize, uiView: NodeInputRowView, context: Context) -> CGSize? {
//            return uiView.intrinsicContentSize
//        }
    }
}

#Preview {
    VStack {
        NodeInputRowView.Preview()
            //            .frame(height: 200)
            .border(.red)
    }
    .padding(50)
}
