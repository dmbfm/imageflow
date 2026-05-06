import Helpers
import Logging
import SharedModels
import SwiftUI
import Values
import XKit

public protocol NodeInputBlockViewDelegate: AnyObject {
    func openAssetPicker(node: UUID, portIndex: Int, kind: AssetKind)
    func titleForAsset(id: AssetIdentifier) -> String?
    func statusBarMessage(message: String?)
    var emitter: EventEmitter<NodeViewDelegateEvent> { get }
}

final class NodeInputBlockView: XViewEx {

    // MARK: - Exposed Properties

    var node: UUID

    var inputs: [FlowNode.Input] {
        didSet {
            if self.inputs != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((Event) -> ())?

    var makeNodeControlContext: ((Int) -> (NodeControlContext?))? {
        didSet {
            if let makeNodeControlContext = self.makeNodeControlContext {
                for (idx, row) in self.rows.enumerated() {
                    if let context = makeNodeControlContext(idx) {
                        row.controlView.context = context
                    }
                }
            }
        }
    }

    weak var delegate: (any NodeInputBlockViewDelegate)?

    private(set) var rows: [NodeInputRowView] = []

    // MARK: - Private Properties

    private var delegates: [RowDelegate] = []

    // MARK: - Exposed Types

    // MARK: - Private Types

    private final class RowDelegate: NodeInputRowView.Delegate {

        var index: Int = 0
        var node: UUID

        private weak var delegate: NodeInputBlockViewDelegate?

        init(node: UUID, index: Int = 0, delegate: (any NodeInputBlockViewDelegate)?) {
            self.node = node
            self.index = index
            self.delegate = delegate
        }

        func openAssetPicker(kind: AssetKind) {
            self.delegate?.openAssetPicker(node: self.node, portIndex: self.index, kind: kind)
        }

        func titleForAsset(id: Values.AssetIdentifier) -> String? {
            self.delegate?.titleForAsset(id: id)
        }

        var emitter: EventEmitter<NodeViewDelegateEvent> {
            self.delegate?.emitter ?? .init()
        }
    }

    // MARK: - Private properties

    private var style: NodeInputRowView.Style

    // MARK: - Init

    init(
        node: UUID,
        _ inputs: [FlowNode.Input],
        delegate: NodeInputBlockViewDelegate? = nil,
        style: NodeInputRowView.Style = .default,
    ) {
        self.node = node
        self.inputs = inputs
        self.style = style
        self.delegate = delegate

        super.init(frame: .zero)

        self.populateRows()
    }

    required init?(coder: NSCoder) {
        nil
    }

    // MARK: - Updating

    private func update() {
        if self.inputs.count != self.rows.count
            || self.inputs
                .enumerated()
                .first(where: { $0.element.value.type != self.rows[$0.offset].input.value.type }) != nil
        {
            self.repopulateRows()

        }

        for (idx, input) in self.inputs.enumerated() where input != self.rows[idx].input {
            self.rows[idx].input = input
            self.rows[idx].setNeedsLayout()
        }
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - Rows

    func repopulateRows() {
        for row in self.rows {
            row.removeFromSuperview()
        }
        self.rows.removeAll()
        self.delegates.removeAll()
        self.populateRows()
        self.onEvent?(.didRepopulateRows)
    }

    func populateRows() {
        for (idx, input) in inputs.enumerated() {
            let delegate = RowDelegate(node: self.node, index: idx, delegate: self.delegate)
            let row = NodeInputRowView(input, delegate: delegate, style: self.style)
            row.clipsToBounds = false
            row.onEvent = { [weak self] event in
                switch event {
                case .valueDidChange(let value):
                    self?.onEvent?(.valueDidChange(input.index, value))
                case .dragPort(let data):
                    self?.onEvent?(.dragPort(input.index, data))
                case .sizeDidChange:
                    self?.updateSize()
                case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                    self?.onEvent?(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
                case .statusBarMessage(let message):
                    self?.delegate?.statusBarMessage(message: message)
                }
            }
            if let makeContext = self.makeNodeControlContext, let context = makeContext(idx) {
                row.controlView.context = context
            }
            self.rows.append(row)
            self.delegates.append(delegate)
            self.addSubview(row)
        }

        self.updateSize()
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        let width = self.rows.reduce(0.0, { max($0, $1.intrinsicContentSize.width) })
        let height = style.rowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layout() {
        super.layout()

        for (idx, row) in self.rows.enumerated() {
            row.frame = .init(
                x: 0,
                y: style.rowHeight * CGFloat(idx),
                width: self.bounds.width,
                height: style.rowHeight
            )
        }
    }

    // MARK: - Interaction

    #if os(macOS)
    override func hitTest(_ point: NSPoint) -> NSView? {
        for row in self.rows {
            let point = row.convert(point, from: self.superview)
            if let view = row.controlView.hitTest(point) {
                return view
            }
            if let view = row.portView.hitTest(point) {
                return view
            }
        }

        return nil
    }
    #endif

    #if os(iOS)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let p = self.convert(point, to: nil)
        for row in rows {
            if let view = row.portView.hitTest(row.portView.convert(p, from: nil), with: event) {
                return view
            }

            if let view = row.controlView.hitTest(row.controlView.convert(p, from: nil), with: event) {
                return view
            }
        }
        return nil
    }
    #endif
}

extension NodeInputBlockView {
    public enum Event {
        case sizeDidChange
        case valueDidChange(Int, Value)
        case dragPort(Int, PortView.DragData)
        case didRepopulateRows
        case keyboardWillShow(windowVerticalOverlap: CGFloat, duration: CGFloat)
    }
}

extension NodeInputBlockView {
    fileprivate struct Preview: XViewRepresentable {
        func makeView(context: Context) -> NodeInputBlockView {
            let view = NodeInputBlockView(
                node: .init(),
                [
                    .init(label: "Some number", index: 0, value: .float(0.5), semantics: .default, connected: false),
                    .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
                    .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
                ]
            )
            return view
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
        NodeInputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 400, minHeight: 400)
    .background(.white)
}
