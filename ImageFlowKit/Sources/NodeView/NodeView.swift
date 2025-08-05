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
#endif

#if canImport(UIKit)
import UIKit
#endif

public final class NodeView: PlatformView, CanvasNodeView {
    
    
    // MARK: - Common

    // MARK: - Public Properties

    public var id: UUID {
        self.node.id
    }

    public var emitter: EventEmitter<CanvasNodeEvent<Event>> = .init()

    public var node: FlowNode {
        didSet {

        }
    }

    // MARK: - Public Types
    
    public enum Event {
        case nodeDidChange(FlowNode)
    }
 
    // MARK: - Private Types
    
    struct Style {
        var titleLeading: CGFloat = 8
        var titleTop: CGFloat = 18
        var titleMinTrailing: CGFloat = 8
        var bottomPadding: CGFloat = 18
    }
    
    // MARK: - Computed variables

    var nodeTitleModel: NodeTitleView.Model {
        .init(
            title: self.node.name,
            subtitle: self.node.kind.displayName,
            icon: self.node.kind.icon,
            // TODO: Don't hard-code this
            color: .systemBlue,
            // color: self.node.kind.frontendNodeColor
        )
    }

    // MARK: - Subviews

    lazy var titleView: NodeTitleView = {
        let view = NodeTitleView(self.nodeTitleModel)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var backgroundView: BackgroundView = {
        let view = BackgroundView(frame: .zero, color: self.nodeTitleModel.color)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    
      public init(_ node: FlowNode) {
        self.node = node

        super.init(frame: .zero)

        self.addSubview(self.backgroundView)
        self.addSubview(self.stackView)

        self.setupShadow()
        self.setupAutolayout()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        nil
    }
    
    // MARK: - macOS
    
    #if os(macOS)
    
    // MARK: - Private Properties

    private var style = Style()

    // MARK: - Subviews
    
    lazy var stackView: NSStackView = {
        let view = NSStackView(views: [titleViewContainer, inputGridView, outputStackView])
        view.orientation = .vertical
        view.alignment = .leading
        view.spacing = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleViewContainer: NSView = {
        let view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.titleView)
        NSLayoutConstraint.activate([
            self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 18),
            self.titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
        ])
        return view
    }()

    lazy var inputGridView: NSGridView = {
        let view = NSGridView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var outputStackView: NSStackView = {
        let view = NSStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Layout
    
    func setupAutolayout() {
        // Background view
        self.backgroundView.constraintToFill(self)
        
        NSLayoutConstraint.activate([
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
        ])
    }
    
    public override var intrinsicContentSize: NSSize {
        .init(width: 200, height: 300)
    }
    
    // MARK: - Shadow
    
    func setupShadow() {
        
    }
    #endif

    // MARK: - iOS

    #if os(iOS)
    
    // MARK: - Private Properties
    
    private var style = Style()
    
    // MARK: - Subviews
    
    lazy var titleViewContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.titleView)
        NSLayoutConstraint.activate([
            self.titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: style.titleLeading),
            self.titleView.topAnchor.constraint(equalTo: view.topAnchor, constant: style.titleTop),
        ])
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [self.titleViewContainer])
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        return view
    }()
    
    // MARK: - Layout

    func setupAutolayout() {
        // Background view
        NSLayoutConstraint.activate([
            self.backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            self.backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])

        // Main stack view
        NSLayoutConstraint.activate([
            self.stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.stackView.topAnchor.constraint(equalTo: self.topAnchor),
            //            self.nodeStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            //            self.nodeStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        ])
    }
   
    public override var intrinsicContentSize: CGSize {
        let titleSize = self.titleView.intrinsicContentSize
        let width = style.titleLeading + titleSize.width + style.titleMinTrailing
        let height = style.titleTop + titleSize.height + style.bottomPadding
        return .init(width: width, height: height)
    }
    
    // MARK: - Shadow
    
    func setupShadow() {
        self.layer.shadowColor = .init(gray: 0, alpha: 0.4)
        self.layer.shadowRadius = 4
        self.layer.shadowOffset = .zero
        self.layer.shadowOpacity = 1.0
    }
    #endif
}

// MARK: - Node Input Row View

// MARK: - Previews

extension NodeView {
    fileprivate struct Preview: PlatformViewRepresentable {
        func makeView(context: Context) -> some PlatformView {
            NodeView(.init(kind: .addNode(.float)))
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
        NodeView.Preview()
//            .border(.gray.opacity(0.25))
    }
    .padding(50)
    .background(.gray.opacity(0.25))
}
