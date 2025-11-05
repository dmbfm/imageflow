import Helpers
import Logging
import SwiftUI
import Values

final class NodeInputBlockView: PlatformCommonView {

    // MARK: - Exposed Properties

    var inputs: [FlowNode.Input] {
        didSet {
            if self.inputs != oldValue {
                self.update()
            }
        }
    }

    var onEvent: ((Event) -> ())?

    private(set) var rows: [NodeInputRowView] = []

    // MARK: - Exposed Types

    struct Delegate {
        var openAssetBrowser: (Int, AssetBrowserConfiguration) -> ()
        var titleForAsset: (UUID) -> String?
    }

    // MARK: - Private properties

    private var delegate: Delegate?

    private var style: NodeInputRowView.Style

    // MARK: - Init

    init(
        _ inputs: [FlowNode.Input],
        delegate: Delegate? = nil,
        style: NodeInputRowView.Style = .default,
    ) {
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

        for (idx, input) in self.inputs.enumerated() {
            if input != self.rows[idx].input {
                self.rows[idx].input = input
            }
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
        self.populateRows()
        self.onEvent?(.didRepopulateRows)
    }

    func populateRows() {
        for (idx, input) in inputs.enumerated() {
            let delegate = NodeInputRowView.Delegate(
                openAssetBrowser: { configuration in
                    self.delegate?.openAssetBrowser(idx, configuration)
                },
                titleForAsset: { id in
                    self.delegate?.titleForAsset(id)
                }
            )
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
                }
            }
            self.rows.append(row)
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

    override func doLayout() {
        super.doLayout()

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
    }
}

extension NodeInputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> NodeInputBlockView {
            let view = NodeInputBlockView([
                .init(label: "Some number", index: 0, value: .float(0.5), semantics: .default, connected: false),
                .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
                .init(label: "Other", index: 0, value: .float(0.1234), semantics: .default, connected: false),
            ])
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
