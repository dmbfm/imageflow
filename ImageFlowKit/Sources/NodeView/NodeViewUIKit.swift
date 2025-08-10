//
//  NodeViewUIKit.swift
//  ImageFlowKit
//
//  Created by Daniel Fortes on 06/08/25.
//
//

#if canImport(UIKit)
import UIKit
import CanvasView
import Models
import EventEmitter
import CommonUtils
import NodeControls

public final class NodeViewUIKit: UIView, CanvasNodeView {
    // MARK: - Public
    
    public var node: FlowNode
    
    public var id: UUID { self.node.id }
    
    public var emitter: EventEmitter<CanvasNodeEvent<()>> = .init()
    
    // MARK: - Internal / Private
    
    // MARK: - Subviews
    
    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.color = self.node.kind.frontendNodeColor
        view.clipsToBounds = false
        view.layer.shadowColor = Design.default.shadowColor
        view.layer.shadowRadius = Design.default.shadowRadius
        view.layer.shadowOffset = Design.default.shadowOffset
        view.layer.shadowOpacity = Design.default.shadowOpacity
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .leading
        view.addArrangedSubview(self.titleContainerView)
        view.addArrangedSubview(self.inputBlockView)
        view.addArrangedSubview(self.outputBlockView)
        view.addArrangedSubview(self.bottomPaddingView)
        
        view.setCustomSpacing(Design.default.inputBlockBottomPadding, after: self.inputBlockView)
        view.setCustomSpacing(Design.default.titleBottom, after: self.titleContainerView)
//        view.setCustomSpacing(Design.default.outputBlockBottomPadding, after: self.outputBlockView)
//        view.layer.borderColor = .pink
//        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var titleView: NodeTitleView = {
        let view = NodeTitleView(.init(self.node))
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var titleContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.titleView)
        self.titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Design.default.titleLeft + Design.default.portSize * 0.5).isActive = true
        self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: Design.default.titleTop).isActive = true
//        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var inputBlockView: NodeInputBlockView = {
        let  view = NodeInputBlockView(self.node.inputs)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        for row in view.rows {
            row.layer.borderWidth = 1
            if let v = row.control as? NodeNumberInput {
                v.sizeDidChange = {[weak self] in
                    row.invalidateIntrinsicContentSize()
                    self?.invalidateIntrinsicContentSize()
                    view.reloadRowWidths()
                }
            }
        }
//        view.layer.borderColor = UIColor.systemBrown.cgColor
//        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView(self.node.outputs)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        view.layer.borderColor = UIColor.systemBrown.cgColor
//        view.layer.borderWidth = 1
        return view
    }()
    
    lazy var bottomPaddingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: Design.default.outputBlockBottomPadding).isActive = true
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
//        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
//    lazy var inputBlockView: InputBlockView = {
//        let view = InputBlockView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.layer.borderWidth = 1
//        for input in self.node.inputs {
//            view.addRow(forInput: input)
//        }
//        return view
//    }()
    
    
    init(_ node: FlowNode) {
        self.node = node
        
        super.init(frame: .zero)
        
        self.addSubview(self.backgroundView)
        self.backgroundView.constraintToFill(self, edgeInsets: .init(top: 0, left: Design.default.portSize * 0.5, bottom: 0, right: Design.default.portSize * 0.5))
        
        self.addSubview(self.stackView)
        self.stackView.constraintToFill(self)
        
        NSLayoutConstraint.activate([
            self.inputBlockView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Design.default.portSize - Design.default.portLabelSpacing),
            self.outputBlockView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
        ])
        
        
//        NSLayoutConstraint.activate([
//            self.inputBlockView.leadingAnchor.constraint(equalTo: self.stackView.leadingAnchor),
//            self.inputBlockView.trailingAnchor.constraint(equalTo: self.stackView.trailingAnchor, constant: -Design.default.portSize * 0.5),
//        ])
        
    }
   
    public required init?(coder: NSCoder) {
        nil
    }
    
    public override func didMoveToSuperview() {
        self.inputBlockView.reloadRowWidths()
    }
    
    // MARK: Size Calculation
   
    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.intrinsicContentSize
        let titleContainerSize = titleSize + .init(width: Design.default.titleLeft + Design.default.portSize + Design.default.titleRight, height: Design.default.titleTop)
        let inputBlockSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize = self.outputBlockView.intrinsicContentSize
        
        let height =
            titleContainerSize.height
        + Design.default.titleBottom
        + inputBlockSize.height
        + Design.default.inputBlockBottomPadding
        + outputBlockSize.height
        + Design.default.outputBlockBottomPadding
        
        let width = max(inputBlockSize.width, titleContainerSize.width, outputBlockSize.width)
//        let width = 200.0
        
        return .init(width: width, height: height)
//        return titleContainerSize + .init(width: 50, height: 180)
    }
    
    
}

//
//final class InputBlockView: UIView {
//    
//    struct Row {
//        var port: PortView
//        var label: UILabel
//        var control: UIView
//        var stack: UIStackView
//        
//        @MainActor
//        var instrinsicContentSize: CGSize {
//            let width = port.intrinsicContentSize.width + label.intrinsicContentSize.width + control.intrinsicContentSize.width
//            let height = max(port.intrinsicContentSize.height, label.intrinsicContentSize.height, control.intrinsicContentSize.height)
//            return .init(width: width, height: height)
//        }
//    }
//    
//    var rows: [Row] = []
//    
//    lazy var stackView: UIStackView = {
//        let view = UIStackView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.axis = .vertical
//        view.alignment = .leading
//        return view
//    }()
//    
//    init() {
//        super.init(frame: .zero)
//        
//        self.addSubview(self.stackView)
//        self.stackView.constraintToFill(self)
//    }
//    
//    required init?(coder: NSCoder) {
//        nil
//    }
//    
//    func addRow(forInput input: FlowNode.Input) {
//        
//    }
//    
//    func updateRowSizes() {
//        self.invalidateIntrinsicContentSize()
//        let width = self.intrinsicContentSize.width
//        for row in rows {
//            row.stack.widthAnchor.constraint(equalToConstant: width).isActive = true
//        }
//    }
//    
//    override var intrinsicContentSize: CGSize {
//        let height: CGFloat = CGFloat(self.rows.count) * Design.default.nodeRowHeight
//        let width: CGFloat = self.rows.reduce(0, { acc, row in
//            max(acc, row.instrinsicContentSize.width)
//        })
//        return .init(width: width, height: height)
//    }
//}

#endif
