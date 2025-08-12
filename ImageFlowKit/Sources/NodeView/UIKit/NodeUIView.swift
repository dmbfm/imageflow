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

public final class NodeUIView: UIView, CanvasNodeView {

    // MARK: - Properties
    
    public var node: FlowNode {
        didSet {
            if self.node != oldValue {
                self.update(oldValue)
            }
        }
    }

    public var id: UUID { self.node.id }

    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

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
        view.onEvent = { [weak self] event in
            switch event {
            case .drag(let drag):
                self?.emitter.emit(.dragGesture(drag))
            case .tap:
                self?.emitter.emit(.click)
            }
        }
        return view
    }()

    lazy var titleView: NodeTitleView = {
        let view = NodeTitleView(.init(self.node))
        view.isUserInteractionEnabled = false
        return view
    }()

    lazy var titleContainerView: UIView = {
        let view = UIView()
        view.addSubview(self.titleView)
        return view
    }()

    lazy var inputBlockView: NodeInputBlockView = {
        let view = NodeInputBlockView(self.node.inputs)
        view.onEvent = { [weak self] event in
            switch event {
            case let .valueDidChange(index, value):
                self?.emitter.emit(.other(.valueDidChange(index, value)))
            case .sizeDidChange:
                self?.invalidateIntrinsicContentSize()
                self?.setNeedsLayout()
                self?.emitter.emit(.sizeChanged)
            }
        }
        return view
    }()

    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView(self.node.outputs)
        return view
    }()
    
    
    // MARK: - Initializers

    init(_ node: FlowNode) {
        self.node = node

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.titleView)
        self.addSubview(self.inputBlockView)
        self.addSubview(self.outputBlockView)
    }

    public required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: Layout

    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.intrinsicContentSize
        let titleContainerSize =
            titleSize
            + .init(
                width: Design.default.titleLeft + Design.default.portSize + Design.default.titleRight,
                height: Design.default.titleTop
            )
        let inputBlockSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize = self.outputBlockView.intrinsicContentSize

        let height =
            titleContainerSize.height
            + Design.default.titleBottom
            + inputBlockSize.height
            + Design.default.inputBlockBottomPadding
            + outputBlockSize.height
            + Design.default.outputBlockBottomPadding

        let width = max(
            inputBlockSize.width + Design.default.portSize + Design.default.portLabelSpacing,
            titleContainerSize.width,
            outputBlockSize.width
        )

        return .init(width: width, height: height)
    }

    public override func layoutSubviews() {
        let portSize = Design.default.portSize
        let titleSize = self.titleView.intrinsicContentSize
        let inputBlockSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize = self.outputBlockView.intrinsicContentSize

        self.backgroundView.frame = self.bounds.inset(
            by: .init(top: 0, left: portSize * 0.5, bottom: 0, right: portSize * 0.5)
        )
        self.titleView.frame = .init(
            x: Design.default.titleLeft,
            y: Design.default.titleTop,
            width: titleSize.width,
            height: titleSize.height
        )

        self.inputBlockView.frame = .init(
            x: 0,
            y: self.titleView.frame.maxY + Design.default.titleBottom,
            width: self.bounds.width - portSize - Design.default.portLabelSpacing,
            height: inputBlockSize.height
        )

        self.outputBlockView.frame = .init(
            x: portSize * 0.5,
            y: self.inputBlockView.frame.maxY + Design.default.inputBlockBottomPadding,
            width: self.bounds.width - portSize * 0.5,
            height: outputBlockSize.height
        )
    }
    
    // MARK: - Updates
    
    func update(_ oldValue: FlowNode) {
        for diff in self.node.diff(oldValue) {
            switch diff {
            case .kind:
                self.titleView.vm = .init(self.node)
                self.backgroundView.color = self.node.kind.frontendNodeColor
            case .name:
                self.titleView.vm.title = self.node.name
            case .inputs(let diff):
                switch diff {
                case .count:
                    // TODO: Reload all input rows
                    fatalError("Changing number of inputs not supported yet!")
                case .value(let index):
                    self.inputBlockView.rows[index].controlView?.value = self.node.inputs[index].value
                case .connected(let index):
                    self.inputBlockView.rows[index].portView.connected = self.node.inputs[index].connected
                }
            case .outputs(let diff):
                switch diff {
                case .count:
                    // TODO: Reload all output rows
                    fatalError("Changing number of outputs not supported yet!")
                case .connected(let index):
                    self.outputBlockView.rows[index].portView.connected = self.node.outputs[index].connected
                }
            }
        }
    }
}

#endif
