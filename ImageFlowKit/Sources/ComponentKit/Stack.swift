import Combine
import Helpers
import XKit

public final class VStack: BaseStack<HorizontalAlignment>, Rx, WithRef {
    public var cancellables: Set<AnyCancellable> = []
}
public final class HStack: BaseStack<VerticalAlignment>, Rx, WithRef {
    public var cancellables: Set<AnyCancellable> = []
}

public class BaseStack<A: StackAlignment>: XViewEx {

    public var alignment: A {
        didSet {
            if self.alignment != oldValue {
                self.stackView.alignment = alignment.attribute
                self.updateEdgeConstraints()
            }
        }
    }

    public var arrangedViews: [XView] {
        self.stackView.arrangedSubviews
    }

    public var stackView: XStackView!

    public var distribution: XStackView.Distribution {
        get { self.stackView.distribution }
        set { self.stackView.distribution = newValue }
    }

    public var spacing: CGFloat {
        get { self.stackView.spacing }
        set { self.stackView.spacing = newValue }
    }

    private var edgeConstraints: [NSLayoutConstraint] = []

    public init(alignment: A = A.default, spacing: CGFloat? = nil, views: [XView]) {
        self.alignment = alignment

        super.init(frame: .zero)

        self.stackView = XStackView(views: views)
        self.stackView.orientation = A.orientation
        self.stackView.alignment = self.alignment.attribute
        self.stackView.translatesAutoresizingMaskIntoConstraints = false

        if let spacing {
            self.stackView.spacing = spacing
        }

        self.addSubview(self.stackView)
        NSLayoutConstraint.activateConstraint(self.stackView, toFill: self)

        self.updateEdgeConstraints()
    }

    public func addView(_ view: XView) {
        self.stackView.addArrangedSubview(view)
        self.updateEdgeConstraints()
    }

    public func insertView(_ view: XView, at index: Int) {
        self.stackView.insertArrangedSubview(view, at: index)
        self.updateEdgeConstraints()
    }

    public func removeView(_ view: XView) {
        self.stackView.removeView(view)
        self.updateEdgeConstraints()
    }

    public func removeAllViews() {
        for view in self.stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        self.updateEdgeConstraints()
    }

    public func withDistribution(_ distribution: XStackView.Distribution) -> Self {
        self.distribution = distribution
        return self
    }

    public func withSpacing(_ spacing: CGFloat) -> Self {
        self.spacing = spacing
        return self
    }

    func updateEdgeConstraints() {
        self.edgeConstraints.forEach({ $0.isActive = false })
        self.edgeConstraints = []

        if !self.alignment.isFill { return }

        self.edgeConstraints = A.constraintEdges(self.stackView)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public protocol StackAlignment: Equatable {
    @MainActor static func constraintEdges(_ stackView: XStackView) -> [NSLayoutConstraint]
    var attribute: NSLayoutConstraint.Attribute { get }
    var isFill: Bool { get }
    static var orientation: NSUserInterfaceLayoutOrientation { get }
    static var `default`: Self { get }
}

public enum HorizontalAlignment: StackAlignment {
    case leading
    case trailing
    case center
    case fill

    public static var `default`: HorizontalAlignment { .leading }

    public static var orientation: NSUserInterfaceLayoutOrientation {
        .vertical
    }

    public var attribute: NSLayoutConstraint.Attribute {
        switch self {
        case .leading: .leading
        case .trailing: .trailing
        case .center: .centerX
        case .fill: .leading
        }
    }
    public var isFill: Bool {
        self == .fill
    }

    @MainActor
    public static func constraintEdges(_ stackView: XStackView) -> [NSLayoutConstraint] {
        var edgeConstraints: [NSLayoutConstraint] = []

        for view in stackView.arrangedSubviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            let cs = [
                view.leadingAnchor.constraint(equalTo: stackView.leadingAnchor),
                view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor),
            ]
            NSLayoutConstraint.activate(cs)
            edgeConstraints.append(contentsOf: cs)
        }

        return edgeConstraints
    }
}

public enum VerticalAlignment: StackAlignment {
    case top
    case bottom
    case center
    case firstTextBaseline
    case lastTextBaseline
    case fill

    public static var `default`: VerticalAlignment { .center }

    public static var orientation: NSUserInterfaceLayoutOrientation {
        .horizontal
    }
    public var attribute: NSLayoutConstraint.Attribute {
        switch self {
        case .bottom: .bottom
        case .top: .top
        case .center: .centerY
        case .firstTextBaseline: .firstBaseline
        case .lastTextBaseline: .lastBaseline
        case .fill: .centerY
        }
    }

    public var isFill: Bool { self == .fill }

    public static func constraintEdges(_ stackView: XStackView) -> [NSLayoutConstraint] {
        var edgeConstraints: [NSLayoutConstraint] = []

        for view in stackView.arrangedSubviews {
            view.translatesAutoresizingMaskIntoConstraints = false
            let cs = [
                view.topAnchor.constraint(equalTo: stackView.topAnchor),
                view.bottomAnchor.constraint(equalTo: stackView.bottomAnchor),
            ]
            NSLayoutConstraint.activate(cs)
            edgeConstraints.append(contentsOf: cs)
        }

        return edgeConstraints
    }
}

#Preview {
    VStack(
        alignment: .fill,
        views: [
            Label("Hello"),
            Label("World"),
            Button("Ok"),
            HStack(
                alignment: .center,
                views: [
                    Label("Some stuff").withContentHuggingPriority(.defaultLow - 10, for: .horizontal),
                    HStack(
                        alignment: .center,
                        views: [
                            Button("Done"),
                            Label("Some stuff"),
                        ]
                    ),
                ]
            ),
        ]
    )
    .constrainingWidth(toConstant: 400)
}
