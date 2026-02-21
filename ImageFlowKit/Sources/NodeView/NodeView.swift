import CanvasView
import Design
import Helpers
import Logging
import SharedModels
import SwiftUI
import Values

public protocol NodeViewDelegate: NodeInputBlockViewDelegate {
    func nodeView(willShowContextMenuForNode node: UUID)
    func nodeView(contextMenuForNode node: UUID, at point: CGPoint?) -> PlatformMenu?
    func nodeView(registerUndoForNode node: UUID, inputIndex: Int, oldValue: Value, newValue: Value)
    func nodeViewSelectedNodesCount() -> Int
}

public final class NodeView: PlatformCommonView, CanvasNodeView {

    // MARK: - Exposed properties

    public var node: FlowNode {
        didSet {
            if self.node != oldValue {
                self.update()
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

    weak var delegate: NodeViewDelegate?

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

    private lazy var nodeControlContextProvider: NodeControlContextProvider = {
        .init(self)
    }()

    #if os(iOS)
    private var interaction: UIContextMenuInteraction?
    #endif

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
        let view = NodeInputBlockView(
            node: self.node.id,
            self.node.inputs,
            delegate: self.delegate,
            style: self.style.inputRow
        )
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
            case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                self.emitter.emit(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
            }
        }
        view.clipsToBounds = false
        view.makeNodeControlContext = { [weak self] index in
            guard let self else { return nil }
            return self.nodeControlContextProvider.nodeControlContext(self.id, index)
        }
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
        delegate: NodeViewDelegate? = nil,
        style: Style = .default
    ) {
        self.node = node
        self.isSelected = isSelected
        self.style = style
        self.delegate = delegate

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.titleView)
        self.addSubview(self.inputBlockView)
        self.addSubview(self.outputBlockView)

        #if os(iOS)
        self.interaction = .init(delegate: self)
        self.addInteraction(self.interaction!)
        #endif
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

    public func emitDragGesture(_ drag: CanvasNodeDragGesture) {
        self.emitter.emit(.dragGesture(drag))
    }

    public func emitClick() {
        self.emitter.emit(.click)
    }

    #if os(macOS)
    public override func viewDidMoveToSuperview() {
        self.emitter.emit(.sizeChanged)
    }

    public override func viewDidMoveToWindow() {
        self.emitter.emit(.sizeChanged)
    }
    #endif

    #if os(iOS)
    public override func didMoveToSuperview() {
        self.emitter.emit(.sizeChanged)
    }
    public override func didMoveToWindow() {
        self.emitter.emit(.sizeChanged)
    }
    #endif

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

    public override func doLayout() {
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

    #if os(iOS)
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let p = self.convert(point, to: nil)
        for row in self.inputBlockView.rows {
            let v = row.controlView
            let localp = v.convert(p, from: nil)
            if let view = v.hitTest(localp, with: event) {
                return view
            }

            let port = row.portView
            if let view = port.hitTest(port.convert(p, from: nil), with: event) {
                return view
            }
        }
        for row in self.outputBlockView.rows {
            let port = row.portView
            if let view = port.hitTest(port.convert(p, from: nil), with: event) {
                return view
            }
        }

        return nil
    }
    #endif

    // MARK: - Context Menu

    #if os(macOS)
    public override func rightMouseDown(with event: NSEvent) {
        self.delegate?.nodeView(willShowContextMenuForNode: self.node.id)
        if let menu = self.delegate?.nodeView(contextMenuForNode: self.node.id, at: nil) {
            NSMenu.popUpContextMenu(menu, with: event, for: self)
        }
    }
    #endif
}

// MARK: NodeView + UIContextMenuInteractionDelegate

#if os(iOS)
extension NodeView: UIContextMenuInteractionDelegate {
    public func contextMenuInteraction(
        _ interaction: UIContextMenuInteraction,
        configurationForMenuAtLocation location: CGPoint
    ) -> UIContextMenuConfiguration? {

        self.delegate?.nodeView(willShowContextMenuForNode: self.node.id)

        return UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil,
            actionProvider: { [weak self] _ in
                guard let self else { return nil }
                return self.delegate?.nodeView(contextMenuForNode: self.node.id, at: interaction.location(in: nil))
            }
        )
    }
}
#endif

// MARK: - NodeView + Style

extension NodeView {
    public struct Style: Sendable, Hashable, With {
        public var title: NodeTitleView.Style
        public var inputRow: NodeInputRowView.Style
        public var outputRow: NodeOutputRowView.Style
        public var background: BackgroundViewStyle
        public var titleLeft: CGFloat
        public var titleRight: CGFloat
        public var titleTop: CGFloat
        public var titleBottom: CGFloat
        public var inputBlockBottomPadding: CGFloat
        public var outputBlockBottomPadding: CGFloat

        public static var `default`: Self {
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

// MARK: - Input Values

extension NodeView {
    public func value(inputIntex index: Int) -> Value? {
        if self.inputBlockView.rows.indices.contains(index) {
            return self.inputBlockView.rows[index].controlView.value
        } else {
            return nil
        }
    }

    public func setValue(inputIntex index: Int, value: Value) {
        if self.inputBlockView.rows.indices.contains(index) {
            self.inputBlockView.rows[index].controlView.value = value
        }
    }
}

// MARK: - Previews

extension NodeView {
    public struct Preview: PlatformViewRepresentable {
        let node: FlowNode

        @State var cancellable: Set<AnyEventEmitterCancellable> = []

        public init(node: FlowNode) {
            self.node = node
        }
        public func makeView(context: Context) -> some PlatformView {
            let view = NodeView(node)
            view.clipsToBounds = false
            view.emitter.on { event in
                log("event: \(event)")
            }.store(in: &self.cancellable)
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
        NodeView.Preview(node: .init(kind: .math(.addNode(.float))))
    }
    .frame(minWidth: 300, minHeight: 300)
    .background(Colors.canvasBackground.color)
}
