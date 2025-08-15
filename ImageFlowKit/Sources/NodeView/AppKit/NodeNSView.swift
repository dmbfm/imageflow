#if canImport(AppKit)

import AppKit
import CommonUtils
import Models
import CanvasView
import EventEmitter
import PlatformUtils

public final class NodeNSView: NSView, CanvasNodeView {

    public var node: FlowNode {
        didSet {
            if self.node != oldValue {
                self.update(oldValue)
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
            switch event {
            case .sizeDidChange:
                self?.updateSize()
            case .valueDidChange(let value):
                break
            }
        }
        return view
    }()

    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView(self.node.outputs)
        view.onEvent = { [weak self] event in
            switch event {
            case .sizeDidChange:
                self?.updateSize()
            }
        }
        return view
    }()

    public init(_ node: FlowNode) {
        self.node = node

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

    }

    func updateSize() {
        //self.onEvent?()
        self.invalidateIntrinsicContentSize()
        self.needsLayout = true
        self.emitter.emit(.sizeChanged)
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
