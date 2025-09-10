#if canImport(AppKit)

import AppKit
import CommonUtils
import Models
import CanvasView
import EventEmitter
import PlatformUtils

public final class NodeNSView: NSView, CanvasNodeView, NodeViewProtocol {

    public var node: FlowNode {
        didSet {
            if self.node != oldValue {
                self.update(oldValue)
            }
        }
    }

    public var isSelected: Bool {
        didSet {
            if self.isSelected != oldValue {
                self.updateBorder()
            }
        }
    }

    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

    public var id: UUID { self.node.id }

    var titleModel: NodeTitleView.ViewModel {
        .init(
            title: self.node.name,
            subtitle: self.node.kind.displayName,
            icon: self.node.kind.icon,
            color: self.node.kind.frontendNodeColor
        )
    }

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(frame: .zero, color: self.node.kind.frontendNodeColor)
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .tap:
                self.emitter.emit(.click)
            case .drag(let drag):
                self.emitter.emit(.dragGesture(drag))
            }
        }
        view.shadow(
            .init(
                radius: Design.default.shadowRadius,
                opacity: CGFloat(Design.default.shadowOpacity),
                offset: Design.default.shadowOffset
            )
        )
        return view
    }()

    lazy var titleView: NodeTitleView = {
        let titleView = NodeTitleView(self.titleModel)
        return titleView
    }()

    lazy var inputBlockView: NodeInputBlockView = {
        let view = NodeInputBlockView(self.node.inputs)
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.updateSize()
            case let .dragPort(index, data):
                self.emitter.emit(.other(.dragPort(.init(node: self.id, port: .input(index)), data)))
            case let .valueDidChange(index, value):
                self.emitter.emit(.other(.valueDidChange(index, value)))
            }
        }
        return view
    }()

    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView(self.node.outputs)
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.updateSize()
            case let .dragPort(index, data):
                self.emitter.emit(.other(.dragPort(.init(node: self.id, port: .output(index)), data)))
            }
        }
        return view
    }()

    public init(_ node: FlowNode, _ isSelected: Bool = false) {
        self.node = node
        self.isSelected = isSelected

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.addSubview(self.backgroundView)
        self.addSubview(self.titleView)
        self.addSubview(self.inputBlockView)
        self.addSubview(self.outputBlockView)
    }

    required init?(coder: NSCoder) {
        nil
    }

    func update(_ oldValue: FlowNode) {
        self.titleView.vm = self.titleModel
        self.inputBlockView.inputs = self.node.inputs
        self.outputBlockView.outputs = self.node.outputs
    }

    func updateSize() {
        //self.onEvent?()
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.emitter.emit(.sizeChanged)
    }

    func updateBorder() {
        if self.isSelected {
            self.backgroundView.showBorder(self.node.kind.frontendNodeColor.cgColor, Design.default.selectedBorderWidth)
        } else {
            self.backgroundView.hideBorder()
        }
    }

    public override var isFlipped: Bool { true }

    public override var intrinsicContentSize: NSSize {
        let titleSize = self.titleView.intrinsicContentSize
        let titleContainerSize =
            titleSize
            + .init(
                width: Design.default.titleLeft + Design.default.portSize + Design.default.titleRight,
                height: Design.default.titleTop
            )
        let inputBlockSize: CGSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize: CGSize = self.outputBlockView.intrinsicContentSize

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

    public override func layout() {
        let portSize = Design.default.portSize
        let titleSize = self.titleView.intrinsicContentSize
        let inputBlockSize: CGSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize: CGSize = self.outputBlockView.intrinsicContentSize

        // self.backgroundView.frame = self.bounds.insetted(
        //     by: .init(top: 0, left: portSize * 0.5, bottom: 0, right: portSize * 0.5)
        // )

        self.backgroundView.frame = .init(
            x: portSize * 0.5,
            y: 0,
            width: self.bounds.width - portSize,
            height: self.bounds.height
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
}

#endif
