import Helpers
import XKit

public final class TabView: XView, WithRef {

    public var spacing: CGFloat = 8 {
        didSet {
            if self.spacing != oldValue {
                self.updateSpacing()
            }
        }
    }

    public var controlSize: NSControl.ControlSize {
        get { self.segmentedControlView.controlSize }
        set { self.segmentedControlView.controlSize = newValue }
    }

    public var selectedIndex: Int {
        get { self.segmentedControlView.selectedSegment }
        set {
            if self.items.indices.contains(newValue) {
                self.segmentedControlView.selectedSegment = newValue
                self.showItem(at: newValue)
            }
        }
    }

    public enum SegmentedControlAlignment {
        case center
        case fill
    }

    public struct Item {
        public var view: XView
        public var label: String
        public var icon: String?
    }

    private lazy var segmentedControlView: NSSegmentedControl = {
        let view = NSSegmentedControl()
        view.trackingMode = .selectOne
        view.target = self
        view.action = #selector(Self.segmentedControlHandler)
        view.controlSize = .large
        view.segmentDistribution = .fillEqually
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var contentView: XView = {
        let view = XView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var items: [Item]

    private var spacingConstraint: NSLayoutConstraint?

    public init(
        _ items: [Item],
        selectedIndex: Int = -1,
        segmentedControlAlignment: SegmentedControlAlignment = .fill
    ) {

        self.items = items

        super.init(frame: .zero)

        self.segmentedControlView.segmentCount = items.count
        for (index, item) in items.enumerated() {
            self.segmentedControlView.setLabel(item.label, forSegment: index)
            if let iconName = item.icon, let image = XImage(systemSymbolName: iconName, accessibilityDescription: nil) {
                self.segmentedControlView.setImage(image, forSegment: index)
            }
        }

        self.addSubview(self.segmentedControlView)
        switch segmentedControlAlignment {
        case .center:
            NSLayoutConstraint.activate([
                self.segmentedControlView.topAnchor.constraint(equalTo: self.topAnchor),
                self.segmentedControlView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ])
        case .fill:
            NSLayoutConstraint.activate([
                self.segmentedControlView.topAnchor.constraint(equalTo: self.topAnchor),
                self.segmentedControlView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                self.segmentedControlView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            ])
        }

        self.addSubview(self.contentView)
        NSLayoutConstraint.activate([
            self.contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        self.spacingConstraint = self.contentView.topAnchor.constraint(
            equalTo: self.segmentedControlView.bottomAnchor,
            constant: self.spacing
        )
        self.spacingConstraint?.isActive = true

        if !self.items.isEmpty {
            self.selectedIndex =
                if selectedIndex < 0 {
                    0
                } else {
                    selectedIndex
                }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func segmentedControlHandler() {
        self.selectedIndex = self.segmentedControlView.selectedSegment
    }

    private func showItem(at index: Int) {
        for view in self.contentView.subviews {
            view.removeFromSuperview()
        }

        guard self.items.indices.contains(self.selectedIndex) else {
            return
        }

        let item = self.items[self.selectedIndex]
        let view = item.view
        view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(view)
        view.constraintToFillSuperview()
    }

    private func updateSpacing() {
        self.spacingConstraint?.isActive = false
        self.spacingConstraint = self.contentView.topAnchor.constraint(
            equalTo: self.segmentedControlView.bottomAnchor,
            constant: self.spacing
        )
        self.spacingConstraint?.isActive = true
    }
}

#Preview {
    TabView(
        [
            .init(
                view: {
                    XView().withLayer({ $0.backgroundColor = .red })
                }(),
                label: "First",
                icon: "fan.circle.fill"
            ),
            .init(
                view: {
                    XView().withLayer({ $0.backgroundColor = .blue })
                }(),
                label: "Second",
                icon: "tree"
            ),
            .init(
                view: {
                    XView().withLayer({ $0.backgroundColor = .teal })
                }(),
                label: "",
                icon: "movieclapper"
            ),
        ],
        selectedIndex: 2
    )
    .constrainingWidth(toConstant: 600)
    // .constrainingHeight(toConstant: 200)
}
