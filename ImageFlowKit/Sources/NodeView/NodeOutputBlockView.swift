import Helpers
import SharedModels
import SwiftUI
import XKit

final class NodeOutputBlockView: XViewEx {
    var outputs: [FlowNode.Output] {
        didSet {
            if self.outputs != oldValue {
                self.update()
            }
        }
    }

    private(set) var rows: [NodeOutputRowView] = []

    var onEvent: ((Event) -> ())?

    private var style: NodeOutputRowView.Style

    public init(_ outputs: [FlowNode.Output], style: NodeOutputRowView.Style = .default) {
        self.outputs = outputs
        self.style = style

        super.init(frame: .zero)

        self.populateRows()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    private func populateRows() {
        for output in outputs {
            let row = NodeOutputRowView(output, style: self.style)
            row.onEvent = { [weak self] event in
                switch event {
                case .sizeDidChange:
                    self?.updateSize()
                case .dragPort(let data):
                    self?.onEvent?(.dragPort(output.id, data))
                }
            }
            self.addSubview(row)
            self.rows.append(row)
        }

        self.updateSize()
    }

    private func update() {
        assert(self.outputs.count == self.rows.count, "Changing the number of inputs is not supported")
        for (idx, output) in outputs.enumerated() where output != self.rows[idx].output {
            self.rows[idx].output = output
        }
    }

    private func updateSize() {
        self.invalidateIntrinsicContentSize()
        self.setNeedsLayout()
        self.onEvent?(.sizeDidChange)
    }

    override var intrinsicContentSize: CGSize {
        let width = self.rows.reduce(0.0, { max($0, $1.intrinsicContentSize.width) })
        let height = self.style.rowHeight * CGFloat(self.rows.count)
        return .init(width: width, height: height)
    }

    override func layout() {
        super.layout()
        for (idx, row) in self.rows.enumerated() {
            row.frame = .init(
                x: 0,
                y: self.style.rowHeight * CGFloat(idx),
                width: self.bounds.width,
                height: self.style.rowHeight
            )
        }
    }

    #if os(macOS)
    override func hitTest(_ point: NSPoint) -> NSView? {
        for row in self.rows {
            let point = row.convert(point, from: self.superview)
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
        }
        return nil
    }
    #endif
}

extension NodeOutputBlockView {
    enum Event {
        case sizeDidChange
        case dragPort(Int, PortView.DragData)
    }
}

extension NodeOutputBlockView {
    fileprivate struct Preview: XViewRepresentable {
        func makeView(context: Context) -> some XView {
            let view = NodeOutputBlockView([
                .init(label: "First Output", index: 0, type: .float, connected: false),
                .init(label: "Second Output", index: 1, type: .float, connected: true),
            ])
            view.onEvent = { _ in }
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
        NodeOutputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .frame(minWidth: 300, minHeight: 300)
    .background(.white)
}
