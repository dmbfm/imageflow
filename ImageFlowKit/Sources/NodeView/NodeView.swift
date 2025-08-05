import CanvasView
import ColorUtils
import Design
import Easing
import EventEmitter
import Models
import PlatformUtils
import SwiftUI

#if canImport(AppKit)
import AppKit
public typealias NodeView = NodeViewAppKit
#endif

#if canImport(UIKit)
import UIKit
public typealias NodeView = NodeViewUIKit
#endif

extension NodeView {
    public enum Event {
        
    }
}

extension NodeView {
    public struct Preview: PlatformViewRepresentable {
        let node: FlowNode
        public func makeView(context: Context) -> some NSView {
            NodeView(node)
        }
        
        public func updateView(_ view: ViewType, context: Context) {
        }
        
        public func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
            view.intrinsicContentSize
        }
    }
}

#Preview("Add") {
    VStack {
        NodeView.Preview(node: .init(kind: .addNode(.float)))
    }
    .frame(width: 500, height: 500)
    .background(Colors.canvasBackground.color)
}

#Preview("Gaussian Blur") {
    VStack {
        NodeView.Preview(node: .init(kind: .coreImageFilterNode(.gaussianBlur)))
    }
    .frame(width: 500, height: 500)
    .background(Colors.canvasBackground.color)
}

//
//public final class NodeView: PlatformView, CanvasNodeView {
//
//    // MARK: - Common
//
//    // MARK: - Public Properties
//
//    public var id: UUID {
//        self.node.id
//    }
//
//    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()
//
//    public var node: FlowNode {
//        didSet {
//
//        }
//    }
//
//    // MARK: - Public Types
//
//    public enum Event {
//        case nodeDidChange(FlowNode)
//    }
//
//    // MARK: - Private Types
//
//    struct Style {
//        var titleLeading: CGFloat = 8
//        var titleTop: CGFloat = 18
//        var titleMinTrailing: CGFloat = 8
//        var bottomPadding: CGFloat = 18
//    }
//
//    // MARK: - Computed variables
//
//    var nodeTitleModel: NodeTitleView.Model {
//        .init(
//            title: self.node.name,
//            subtitle: self.node.kind.displayName,
//            icon: self.node.kind.icon,
//            // TODO: Don't hard-code this
//            color: .systemBlue,
//            // color: self.node.kind.frontendNodeColor
//        )
//    }
//
//    // MARK: - Subviews
//
//    lazy var titleView: NodeTitleView = {
//        let view = NodeTitleView(self.nodeTitleModel)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    lazy var backgroundView: BackgroundView = {
//        let view = BackgroundView(frame: .zero, color: self.nodeTitleModel.color)
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//
//    // MARK: - Initializers
//
//    public init(_ node: FlowNode) {
//        self.node = node
//
//        super.init(frame: .zero)
//
//        self.addSubview(self.backgroundView)
//        self.addSubview(self.stackView)
//
//        self.setupShadow()
//        self.setupAutolayout()
//        self.setupRows()
//    }
//
//    @available(*, unavailable)
//    public required init?(coder: NSCoder) {
//        nil
//    }
//
//    // MARK: - macOS
//
//    #if os(macOS)
//
//    // MARK: - Private Properties
//
//    private var style = Style()
//
//    // MARK: - Subviews
//
//    lazy var stackView: NSStackView = {
//        let view = NSStackView(views: [titleViewContainer, inputGridView, outputStackView])
//        view.orientation = .vertical
//        view.alignment = .leading
//        view.spacing = 2
//        view.translatesAutoresizingMaskIntoConstraints = false
//        //        view.border(.init(.systemTeal), width: 1)
//        return view
//    }()
//
//    lazy var titleViewContainer: NSView = {
//        let view = NSView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(self.titleView)
//        NSLayoutConstraint.activate([
//            self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
//            self.titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
//        ])
//        return view
//    }()
//    
//    
//
//    lazy var outputStackView: NSStackView = {
//        let view = NSStackView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    // MARK: - Setup Rows
//    
//    var inputRowViews: [NodeInputRowView] = []
//    func setupRows() {
//        for input in self.node.inputs {
//            print("input: \(input)")
//            let view = NodeInputRowView(input)
//            view.translatesAutoresizingMaskIntoConstraints = false
//            self.stackView.addView(view, in: .top)
//            self.inputRowViews.append(view)
//        }
//        self.invalidateIntrinsicContentSize()
//    }
//
//    // MARK: - Layout
//
//    func setupAutolayout() {
//        // Background view
//        self.backgroundView.constraintToFill(self)
//
//        // Stack view
//        self.stackView.constraintToFill(self)
//        self.stackView.edgeInsets = .init(top: 0, left: 0, bottom: style.bottomPadding, right: 0)
//    }
//    
//    func calcInputBlockSize() -> CGSize {
//        print("calculating... \(self.inputRowViews.count)")
//        return self.inputRowViews.reduce(.zero, { acc, view in
//                .init(
//                    width: max(acc.width, view.intrinsicContentSize.width),
//                    height: acc.height + view.intrinsicContentSize.height
//                )
//        })
//    }
//
//    public override var intrinsicContentSize: NSSize {
//        let titleSize = self.titleView.intrinsicContentSize
//        let inputBlockSize = self.calcInputBlockSize()
//        print("inputBlockSize: \(inputBlockSize)")
//        let titleWidth = style.titleLeading + titleSize.width + style.titleMinTrailing
//        let width = max(titleWidth, inputBlockSize.width)
//        let height = style.titleTop + titleSize.height + inputBlockSize.height + style.bottomPadding + 2.0 * (1.0 + CGFloat(self.inputRowViews.count) - 1.0)
//        return .init(width: width, height: height)
//
//    }
//
//    // MARK: - Shadow
//
//    func setupShadow() {
//        self.wantsLayer = true
//        self.shadow = .init()
//        self.layer?.shadowColor = .init(gray: 0, alpha: 0.4)
//        self.layer?.shadowOpacity = 1
//        self.layer?.shadowRadius = 4
//        self.layer?.shadowOffset = .zero
//    }
//    #endif
//
//    // MARK: - iOS
//
//    #if os(iOS)
//
//    // MARK: - Private Properties
//
//    private var style = Style()
//
//    // MARK: - Subviews
//
//    lazy var titleViewContainer: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(self.titleView)
//        NSLayoutConstraint.activate([
//            self.titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: style.titleLeading),
//            self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: style.titleTop),
//        ])
//        return view
//    }()
//
//    lazy var stackView: UIStackView = {
//        let view = UIStackView(arrangedSubviews: [self.titleViewContainer])
//        view.translatesAutoresizingMaskIntoConstraints = false
//        view.axis = .vertical
//        return view
//    }()
//
//    // MARK: - Layout
//
//    func setupAutolayout() {
//        // Background view
//        NSLayoutConstraint.activate([
//            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
//            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
//            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
//        ])
//
//        // Main stack view
//        NSLayoutConstraint.activate([
//            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
//            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
//            //            self.nodeStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
//            //            self.nodeStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
//        ])
//    }
//
//    public override var intrinsicContentSize: CGSize {
//        let titleSize = self.titleView.intrinsicContentSize
//        let width = style.titleLeading + titleSize.width + style.titleMinTrailing
//        let height = style.titleTop + titleSize.height + style.bottomPadding
//        return .init(width: width, height: height)
//    }
//
//    // MARK: - Shadow
//
//    func setupShadow() {
//        self.layer.shadowColor = .init(gray: 0, alpha: 0.4)
//        self.layer.shadowRadius = 4
//        self.layer.shadowOffset = .zero
//        self.layer.shadowOpacity = 1.0
//    }
//    #endif
//}
//
//// MARK: - Node Input Row View
//
//// MARK: - Previews
//
//extension NodeView {
//    fileprivate struct Preview: PlatformViewRepresentable {
//        func makeView(context: Context) -> some PlatformView {
//            NodeView(.init(kind: .addNode(.float)))
//        }
//
//        func updateView(_ view: ViewType, context: Context) {
//
//        }
//
//        func sizeThatFits(_ proposal: ProposedViewSize, view: ViewType, context: Context) -> CGSize? {
//            view.intrinsicContentSize
//        }
//    }
//}
//
//#Preview {
//    VStack {
//        NodeView.Preview()
//    }
//    .frame(width: 500, height: 500)
//    .background(.gray.opacity(0.25))
//}
