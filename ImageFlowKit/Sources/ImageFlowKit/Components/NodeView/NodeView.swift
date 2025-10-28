import Helpers
import Logging
import SwiftUI
import Values

final class NodeView: PlatformCommonView, CanvasNodeView {

    // MARK: - Exposed properties

    var node: FlowNode {
        didSet {
            if self.node != oldValue {
                self.update()
            }
        }
    }

    var isSelected: Bool {
        didSet {
            if self.isSelected != oldValue {
                self.updateBorder()
            }
        }
    }

    var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

    var id: UUID { self.node.id }

    private var inputBlockDelegate: NodeInputBlockView.Delegate?

    // MARK: - Private properties

    private var titleModel: NodeTitleView.ViewModel {
        .init(
            title: self.node.name,
            subtitle: self.node.kind.displayName,
            icon: self.node.kind.icon,
            color: self.node.kind.frontendNodeColor
        )
    }

    private var style: Style

    // MARK: - Subviews

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(
            style: self.style.background
                .with(\.color, self.node.kind.frontendNodeColor.platformColor)
                .with(\.selectedBorderColor, self.node.kind.frontendNodeColor.platformColor)
        )
        view.clipsToBounds = false
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
        let titleView = NodeTitleView(self.titleModel, style: self.style.title)
        return titleView
    }()

    lazy var inputBlockView: NodeInputBlockView = {
        let view = NodeInputBlockView(self.node.inputs, delegate: self.inputBlockDelegate, style: self.style.inputRow)
        view.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .sizeDidChange:
                self.updateSize()
            case let .dragPort(index, data):
                self.emitter.emit(.other(.dragPort(.init(node: self.id, port: .input(index)), data)))
            case let .valueDidChange(index, value):
                self.emitter.emit(.other(.valueDidChange(index, value)))
            case .didRepopulateRows:
                self.emitter.emit(.other(.didRepopulateInputRows))
            }
        }
        view.clipsToBounds = false
        return view
    }()

    lazy var outputBlockView: NodeOutputBlockView = {
        let view = NodeOutputBlockView(self.node.outputs, style: self.style.outputRow)
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

    // MARK: - Init

    public init(
        _ node: FlowNode,
        _ isSelected: Bool = false,
        inputBlockDelegate: NodeInputBlockView.Delegate? = nil,
        style: Style = .default
    ) {
        self.node = node
        self.isSelected = isSelected
        self.style = style
        self.inputBlockDelegate = inputBlockDelegate

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.titleView)
        self.addSubview(self.inputBlockView)
        self.addSubview(self.outputBlockView)
    }

    public required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updates

    private func update() {
        self.titleView.vm = self.titleModel
        self.inputBlockView.inputs = self.node.inputs
        self.outputBlockView.outputs = self.node.outputs
    }

    private func updateBorder() {
        if self.isSelected {
            self.backgroundView.showBorder()
        } else {
            self.backgroundView.hideBorder()
        }
    }

    private func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.emitter.emit(.sizeChanged)
    }

    // MARK: - Layout

    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.intrinsicContentSize
        let portSize = max(self.style.inputRow.port.size, self.style.outputRow.port.size)
        let titleContainerSize =
            titleSize
            + .init(
                width: self.style.titleLeft + portSize + self.style.titleRight,
                height: self.style.titleTop
            )
        let inputBlockSize: CGSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize: CGSize = self.outputBlockView.intrinsicContentSize

        let height =
            titleContainerSize.height
            + self.style.titleBottom
            + inputBlockSize.height
            + self.style.inputBlockBottomPadding
            + outputBlockSize.height
            + self.style.outputBlockBottomPadding

        let width = max(
            inputBlockSize.width + portSize + self.style.inputRow.portLabelSpacing,
            titleContainerSize.width,
            outputBlockSize.width
        )

        return .init(width: width, height: height)
    }

    override func doLayout() {
        let portSize = max(self.style.inputRow.port.size, self.style.outputRow.port.size)
        let titleSize = self.titleView.intrinsicContentSize
        let inputBlockSize: CGSize = self.inputBlockView.intrinsicContentSize
        let outputBlockSize: CGSize = self.outputBlockView.intrinsicContentSize

        self.backgroundView.frame = .init(
            x: portSize * 0.5,
            y: 0,
            width: self.bounds.width - portSize,
            height: self.bounds.height
        )
        self.titleView.frame = .init(
            x: self.style.titleLeft,
            y: self.style.titleTop,
            width: titleSize.width,
            height: titleSize.height
        )

        self.inputBlockView.frame = .init(
            x: 0,
            y: self.titleView.frame.maxY + self.style.titleBottom,
            width: self.bounds.width - portSize - self.style.inputRow.portLabelSpacing,
            height: inputBlockSize.height
        )

        self.outputBlockView.frame = .init(
            x: portSize * 0.5,
            y: self.inputBlockView.frame.maxY + self.style.inputBlockBottomPadding,
            width: self.bounds.width - portSize * 0.5,
            height: outputBlockSize.height
        )
    }
}

extension NodeView {
    struct Style: Sendable, Hashable, With {
        var title: NodeTitleView.Style
        var inputRow: NodeInputRowView.Style
        var outputRow: NodeOutputRowView.Style
        var background: BackgroundView.Style
        var titleLeft: CGFloat
        var titleRight: CGFloat
        var titleTop: CGFloat
        var titleBottom: CGFloat
        var inputBlockBottomPadding: CGFloat
        var outputBlockBottomPadding: CGFloat

        static var `default`: Self {
            .init(
                title: .default,
                inputRow: .default,
                outputRow: .default,
                background: .default,
                titleLeft: 16,
                titleRight: 26,
                titleTop: 14,
                titleBottom: 10,
                inputBlockBottomPadding: 4,
                outputBlockBottomPadding: 10,
            )
        }
    }
}

extension NodeView {
    public enum Event {
        case valueDidChange(Int, Value)
        case dragPort(PortLocation, PortView.DragData)
        case didRepopulateInputRows
    }

    public var ports: [(PortLocation, PortView)] {
        self.inputBlockView.rows.enumerated().map {
            (.init(node: self.id, port: .input($0.offset)), $0.element.portView)
        }
            + self.outputBlockView.rows.enumerated().map {
                (.init(node: self.id, port: .output($0.offset)), $0.element.portView)
            }
    }

    public func setDrawPortAsConnected(_ slot: PortSlot, _ value: Bool) {
        switch slot {
        case .input(let index):
            self.inputBlockView.rows[index].drawPortAsConnected = value
        case .output(let index):
            self.outputBlockView.rows[index].drawPortAsConnected = value
        }
    }
}

// MARK: - Ports

extension NodeView {
    /// Returns the window-coordinate frame of the port at `location`.
    /// - Parameter slot: The slot we want the frame for.
    /// - Returns: The frame, if the slot is valid.
    public func portFrame(_ slot: PortSlot) -> CGRect? {
        switch slot {
        case .input(let port):
            if port >= self.inputBlockView.rows.count {
                return nil
            }
            let frame = self.inputBlockView.rows[port].portView.frame
            return self.inputBlockView.rows[port].convert(frame, to: nil)
        case .output(let port):
            if port >= self.outputBlockView.rows.count {
                return nil
            }
            let frame = self.outputBlockView.rows[port].portView.frame
            return self.outputBlockView.rows[port].convert(frame, to: nil)
        }
    }

    /// Returns the `PortView` for the given slot.
    /// - Parameter slot:
    /// - Returns:
    public func portView(_ slot: PortSlot) -> PortView? {
        switch slot {
        case .input(let idx):
            if idx < 0 || idx >= self.inputBlockView.rows.count {
                return nil
            }
            return self.inputBlockView.rows[idx].portView
        case .output(let idx):
            if idx < 0 || idx >= self.outputBlockView.rows.count {
                return nil
            }
            return self.outputBlockView.rows[idx].portView
        }
    }
}

// MARK: - Previews

extension NodeView {
    public struct Preview: PlatformViewRepresentable {
        let node: FlowNode

        public init(node: FlowNode) {
            self.node = node
        }
        public func makeView(context: Context) -> some PlatformView {
            let view = NodeView(node)
            view.clipsToBounds = false
            view.emitter.on { event in
                log("event: \(event)")
            }
            return view
        }

        public func updateView(_ view: ViewType, context: Context) {
        }

        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview("Add", traits: .sizeThatFitsLayout) {
    VStack {
        NodeView.Preview(node: .init(kind: .addNode(.float)))
    }
    .frame(minWidth: 300, minHeight: 300)
    .background(Colors.canvasBackground.color)
}

//#Preview("Gaussian Blur", traits: .sizeThatFitsLayout) {
//    VStack {
//        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.gaussianBlur)))
//    }
//    .frame(minWidth: 300, minHeight: 300)
//    .background(Colors.canvasBackground.color)
//}
//
//#Preview("KMeans", traits: .sizeThatFitsLayout) {
//    VStack {
//        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.kMeans)))
//    }
//    .frame(minWidth: 300, minHeight: 300)
//    .background(Colors.canvasBackground.color)
//}
