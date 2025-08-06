import CommonUtils
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
#endif

final class NodeInputBlockView: PlatformView {

    var rows: [NodeInputRowView] = []

    private var style = Style()

    struct Style {
        var stackSpacing: CGFloat = 2
    }

    init() {
        super.init(frame: .zero)

        self.addSubview(self.stack)
        self.stack.constraintToFill(self)

        self.platformInit()
    }

    required init?(coder: NSCoder) {
        nil
    }

    func addRow(_ row: NodeInputRowView) {
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
            #if os(macOS)
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

    #if os(iOS)
    lazy var stack: UIStackView = {
        let view = UIStackView()
        return view
    }()

    func platformInit() {

    }
    #endif
}

extension NodeInputBlockView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            let view = NodeInputBlockView()
            view.addRow(
                .init(.init(label: "Some Number", index: 0, value: .float(0.5), semantics: .default, connected: false))
            )
            view.addRow(
                .init(.init(label: "Other", index: 1, value: .float(0.5), semantics: .default, connected: true))
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

#Preview {
    VStack {
        NodeInputBlockView.Preview()
            .border(.gray.opacity(0.12))
    }
    .padding(200)
}
