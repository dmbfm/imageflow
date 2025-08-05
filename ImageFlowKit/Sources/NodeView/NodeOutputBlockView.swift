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

    private var style = Style()

    struct Style {
        var stackSpacing: CGFloat = 2
    }

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stack)
        self.stack.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
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
        self.stack.removeView(self.rows[index])
        self.rows.remove(at: index)
        self.invalidateIntrinsicContentSize()
    }

    func clearRows() {
        for row in self.rows {
            self.stack.removeView(row)
        }
        self.rows = []
        self.invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: NSSize {
        let blockSize: CGSize = self.rows.reduce(.zero) { acc, view in
            .init(
                width: max(acc.width, view.intrinsicContentSize.width),
                height: acc.height + view.intrinsicContentSize.height
            )
        }

        return blockSize + .init(width: 0, height: self.style.stackSpacing * (max(0.0, CGFloat(self.rows.count))))
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
}

extension NodeOutputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeOutputBlockView()
            view.addRow(.init(.init(label: "First Output", index: 0, type: .float, connected: false)))
            view.addRow(.init(.init(label: "Second Output", index: 1, type: .float, connected: true)))
            return view
        }

        func updateView(_ view: ViewType, context: Context) {
        
        }

        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview {
    VStack {
        NodeOutputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .padding(200)
}
