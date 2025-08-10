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
typealias NodeOutputRowView = NodeOutputRowUIView
#endif

#if canImport(UIKit)
final class NodeOutputRowUIView: UIView {
    
    var label: UILabel
    var portView: PortView
    
    lazy var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        return view
    }()
    
    init(_ output: FlowNode.Output) {
        
        self.label = UILabel(nodeRowLabelWithString: output.label)
        self.label.translatesAutoresizingMaskIntoConstraints = false
        
        self.portView = PortView(connected: output.connected)
        self.portView.translatesAutoresizingMaskIntoConstraints = false
        self.portView.widthAnchor.constraint(equalToConstant: Design.default.portSize).isActive = true
        self.portView.heightAnchor.constraint(equalToConstant: Design.default.portSize).isActive = true

        super.init(frame: .zero)
        
        self.addSubview(self.stack)
        self.stack.constraintToFill(self)
        
        self.stack.addArrangedSubview(UIView())
        self.stack.addArrangedSubview(self.label)
        self.stack.addArrangedSubview(self.portView)
        self.stack.setCustomSpacing(Design.default.portLabelSpacing, after: self.label)
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override var intrinsicContentSize: CGSize {
        let width = self.label.intrinsicContentSize.width
        + Design.default.portLabelSpacing
        + Design.default.portSize
        let height: CGFloat = max(self.label.intrinsicContentSize.height, Design.default.portSize)
        return .init(width: width, height: height)
        
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

#Preview(traits: .sizeThatFitsLayout) {
    VStack {
        NodeOutputRowView.Preview()
            .border(.gray.opacity(0.2))
        // .border(.red)
    }
    .padding(50)
    .background(.white)
}
