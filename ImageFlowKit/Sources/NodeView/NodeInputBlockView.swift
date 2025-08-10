import CommonUtils
import Models
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
#endif

#if canImport(UIKit)
import UIKit
typealias NodeInputBlockView = NodeInputBlockUIView
#endif


#if canImport(UIKit)
final class NodeInputBlockUIView: UIView {
    
    var rows: [NodeInputRowView] = []
    
    lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.alignment = .leading
        stack.distribution = .fillEqually
        stack.spacing = 0
        return stack
    }()
    
    init(_ inputs: [FlowNode.Input]) {
        super.init(frame: .zero)
        
        self.addSubview(self.stack)
        self.stack.constraintToFill(self)
        
        for input in inputs {
            let row = NodeInputRowView(input)
            row.layer.borderWidth = 1
            row.translatesAutoresizingMaskIntoConstraints = false
            self.rows.append(row)
            self.stack.addArrangedSubview(row)
            row.widthAnchor.constraint(equalTo: self.stack.widthAnchor).isActive = true
        }
        
        self.reloadRowWidths()
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override var intrinsicContentSize: CGSize {
        let width = self.rows.reduce(0.0, { acc, row in
            max(acc, row.intrinsicContentSize.width)
        })
        let height: CGFloat = CGFloat(self.rows.count) * Design.default.nodeRowHeight
        return .init(width: width, height: height)
    }
    
    func reloadRowWidths() {
        self.invalidateIntrinsicContentSize()
        let size = self.intrinsicContentSize
        for row in rows {
            row.widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
    }
}
#endif


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
    .padding(200)
}
