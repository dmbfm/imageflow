//
//  NodeViewUIKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//
//
//import CanvasView
//import EventEmitter
//import Models
//import UIKit
//import SwiftUI
//
//public final class NodeViewUIKit: UIView, CanvasNodeView {
//
//    public var node: FlowNode {
//        didSet {
//
//        }
//    }
//
//    public var id: UUID {
//        self.node.id
//    }
//
//    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()
//
//     struct Style {
//        var titlePadding: EdgeInsets = .init(top: 18, leading: 8, bottom: 18, trailing: 8)
//        var bottomPadding: CGFloat = 8
//    }
//
//    var style = Style()
//
//     lazy var backgroundView: BackgroundView = {
//        let view = BackgroundView()
//        view.color = self.node.kind.frontendNodeColor
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
////    lazy var titleView: NodeTitleView = {
////        let view = NodeTitleView(self.titleModel)
////    }()
////
//    init(_ node: FlowNode) {
//        self.node = node
//        super.init(frame: .zero)
//
//        self.addSubview(self.backgroundView)
//        self.backgroundView.constraintToFill(self)
//
//        self.layer.shadowColor = .init(gray: 0, alpha: 1)
//        self.layer.shadowOffset = .zero
//        self.layer.shadowOpacity = 0.4
//        self.layer.shadowRadius = 4
//    }
//
//    public required init?(coder: NSCoder) {
//        nil
//    }
//
//    // MARK: - Layout
//
//    public override var intrinsicContentSize: CGSize {
//        .init(width: 200, height: 300)
//    }
//}
