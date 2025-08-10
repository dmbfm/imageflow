import CommonUtils
import Models
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class NodeOutputBlockView: PlatformView {
    var rows: [NodeOutputRowView] = []

    init(_ outputs: [FlowNode.Output]) {
        super.init(frame: .zero)

        self.addSubview(self.stack)
        self.stack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        
        for output in outputs {
            self.addRow(.init(output))
        }
    }

    required init?(coder: NSCoder) {
        nil
    }

    func addRow(_ row: NodeOutputRowView) {
        self.stack.addArrangedSubview(row)
        self.rows.append(row)
        row.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        self.invalidateIntrinsicContentSize()
    }

    func removeRow(_ index: Int) {
        #if os(macOS)
        self.stack.removeView(self.rows[index])
        #else
        self.stack.removeArrangedSubview(self.rows[index])
        #endif
        self.rows.remove(at: index)
        self.invalidateIntrinsicContentSize()
    }

    func clearRows() {
        for row in self.rows {
            #if os(masOS)
            self.stack.removeView(row)
            #else
            self.stack.removeArrangedSubview(row)
            #endif
        }
        self.rows = []
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let blockSize: CGSize = self.rows.reduce(.zero) { acc, view in
            .init(
                width: max(acc.width, view.intrinsicContentSize.width),
                height: acc.height + view.intrinsicContentSize.height
            )
        }

        return blockSize
    }

    #if os(macOS)
    lazy var stack: NSStackView = {
        let view = NSStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.orientation = .vertical
        view.alignment = .width
        view.distribution = .fill
        view.spacing = self.style.stackSpacing
        return view
    }()

    func platformInit() {
        self.clipsToBounds = false
    }
    #endif

    #if os(iOS)
    lazy var stack: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.alignment = .trailing
        view.distribution = .fill
        return view
    }()
    #endif
}

extension NodeOutputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeOutputBlockView([
            .init(label: "First Output", index: 0, type: .float, connected: false),
            .init(label: "Second Output", index: 1, type: .float, connected: true),
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
        NodeOutputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .padding(200)
}
