import Backend
import Helpers
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

    // MARK: - ViewModel

    struct ViewModel: Equatable {
        var node: UUID
        var inputs: [NodeInputRowView.ViewModel]

        init(node: UUID, inputs: [NodeInputRowView.ViewModel]) {
            self.node = node
            self.inputs = inputs
        }

        init(node: FlowNode) {
            self.node = node.id
            self.inputs = node.inputs(withNodeViewPlacements: [.visible, .hiddenControl]).map({ input in
                .init(
                    input: input,
                    semantics: node.semantics(forInput: input.index) ?? .default,
                    drawPortAsConnected: false,
                    placement: node.schema(forInput: input.index)?.editorPlacement.nodeView ?? .visible  // input.edi
                )
            })
        }

        mutating func setDrawPortAsConnected(index: Int, value: Bool) {
            if let index = self.inputs.firstIndex(where: { $0.input.index == index }) {
                self.inputs[index].drawPortAsConnected = value
            }
        }

        mutating func update(_ node: FlowNode) {
            let visibleInputs = node.inputs(withNodeViewPlacements: [.visible, .hiddenControl])
            let differentNode = node.id != self.node
            let differentInputCount = visibleInputs.count != self.inputs.count
            let needsReload = differentNode || differentInputCount

            if needsReload {
                self = .init(node: node)
            } else {
                self.inputs = zip(self.inputs, visibleInputs).map({ (vmInput, nodeInput) in
                    .init(
                        input: nodeInput,
                        semantics: node.semantics(forInput: nodeInput.index) ?? .default,
                        drawPortAsConnected: vmInput.drawPortAsConnected,
                        placement: node.schema(forInput: nodeInput.index)?.editorPlacement.nodeView ?? .visible
                    )
                })
            }
        }
    }

    // MARK: - Exposed Properties

    var vm: ViewModel {
        didSet {
            if self.vm != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((Event) -> ())?

    var makeNodeControlContext: ((Int) -> (NodeControlContext?))? {
        didSet {
            if let makeNodeControlContext = self.makeNodeControlContext {
                for (idx, row) in self.rows {
                    if let context = makeNodeControlContext(idx) {
                        row.controlView.context = context
                    }
                }
            }
        }
    }

    weak var delegate: (any NodeInputBlockViewDelegate)?

    private(set) var rows: [Int: NodeInputRowView] = [:]

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
        _ vm: ViewModel,
        delegate: NodeInputBlockViewDelegate? = nil,
        style: NodeInputRowView.Style = .default,
    ) {
        self.vm = vm
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
        var needsRepopulateRows: Bool {
            var countChanged: Bool {
                self.vm.inputs.count != self.rows.count
            }
            var anyInputTypeChanged: Bool {
                self.vm.inputs.firstIndex(where: { vm in
                    !(self.rows[vm.input.index]?.vm.sameValueType(as: vm) ?? false)
                }) != nil
            }
            return countChanged || anyInputTypeChanged
        }

        if needsRepopulateRows {
            self.repopulateRows()
        }

        for (index, row) in self.rows {
            row.vm = self.vm.inputs[index]
            row.setNeedsLayout()
        }
    }

    func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    // MARK: - Rows

    func repopulateRows() {
        for (_, row) in self.rows {
            row.removeFromSuperview()
        }
        self.rows.removeAll()
        self.delegates.removeAll()
        self.populateRows()
        self.onEvent?(.didRepopulateRows)
    }

    func populateRows() {
        for vm in self.vm.inputs {
            let index = vm.input.index
            let delegate = RowDelegate(node: self.vm.node, index: index, delegate: self.delegate)
            let row = NodeInputRowView(vm, delegate: delegate, style: self.style)
            row.clipsToBounds = false
            row.onEvent = { [weak self] event in
                switch event {
                case .valueDidChange(let value):
                    self?.onEvent?(.valueDidChange(index, value))
                case .dragPort(let data):
                    self?.onEvent?(.dragPort(index, data))
                case .sizeDidChange:
                    self?.updateSize()
                case .keyboardWillShow(windowVerticalOverlap: let value, let duration):
                    self?.onEvent?(.keyboardWillShow(windowVerticalOverlap: value, duration: duration))
                case .statusBarMessage(let message):
                    self?.delegate?.statusBarMessage(message: message)
                }
            }
            if let makeContext = self.makeNodeControlContext, let context = makeContext(index) {
                row.controlView.context = context
            }
            self.rows[index] = row
            self.delegates.append(delegate)
            self.addSubview(row)
        }

        self.updateSize()
    }

    // MARK: - Layout

    override var intrinsicContentSize: CGSize {
        let width = self.rows.values.reduce(0.0, { max($0, $1.intrinsicContentSize.width) })
        let height = style.rowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layout() {
        super.layout()

        for (idx, row) in self.rows {
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
        for (_, row) in self.rows {
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
                .init(
                    node: .init(),
                    inputs: [
                        .init(
                            input: .init(label: "Some number", index: 0, value: .float(0.5), connected: false),
                            semantics: .default,
                            drawPortAsConnected: false,
                            placement: .visible
                        ),
                        .init(
                            input: .init(label: "Other", index: 1, value: .float(0.1234), connected: false),
                            semantics: .default,
                            drawPortAsConnected: false,
                            placement: .visible
                        ),
                    ]
                )
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
