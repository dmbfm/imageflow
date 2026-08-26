import Combine
import ComponentKit
import Helpers
import XKit

final class CanvasTabView: XView {
    var vm: CanvasTabViewModel

    lazy var stackView: VScrollView = {
        VScrollView(views: [self.titleView], spacing: 6)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
            .setCustomSpacing(10, after: self.titleView)
    }()

    lazy var contentView: RXView = {
        let view = RXView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleView: Padded<Label> = {
        Padded(
            Label(
                "Canvas",
                font: .preferredFont(forTextStyle: .headline),
                alignment: .left
            )
            .with(\.translatesAutoresizingMaskIntoConstraints, false),
            insets: .init(top: 0, left: 6, bottom: 0, right: 0)
        )
    }()

    lazy var bookmarksTitleView: Padded<Label> = {
        Padded(
            Label(
                "Bookmarks",
                font: .preferredFont(forTextStyle: .headline),
                alignment: .left
            )
            .with(\.translatesAutoresizingMaskIntoConstraints, false),
            insets: .init(top: 0, left: 6, bottom: 0, right: 0)
        )
    }()

    lazy var nodeCountView: PropertyControlView<StaticLabelControl> = {
        let view = PropertyControlView(
            StaticLabelControl("12"),
            configuration: .compact
        )
        .with(\.connected, nil)
        .with(\.label, "Node Count")
        .rx(self.vm.$nodeCount.map({ "\($0)" }), kp: \.value)
        return view
    }()

    lazy var edgeCountView: PropertyControlView<StaticLabelControl> = {
        let view = PropertyControlView(
            StaticLabelControl("12"),
            configuration: .compact
        )
        .with(\.connected, nil)
        .with(\.label, "Edge Count")
        .rx(self.vm.$edgeCount.map({ "\($0)" }), kp: \.value)
        return view
    }()

    lazy var viewportPositionView: PropertyControlView<VectorControl> = {
        return PropertyControlView(
            VectorControl(
                [0.0, 0.0, 0.0],
                configuration: .init(
                    formatter: .number.precision(.significantDigits(2)),
                    labels: ["x", "y", "zoom"]
                )
            )
            .setDragConfiguration(for: 2, .range(.closed(.init(range: 0.1...4.0, fractionalDigits: 2)))),
            configuration: .regular
        )
        .with(\.connected, nil)
        .with(\.label, "Viewport")
        .rx(self.vm.$viewportValues, kp: \.value)
        .rx(self.vm.$viewportValues.map({ $0[0] != 0 || $0[1] != 0 || $0[2] != 0 }), kp: \.hasChanges)
    }()

    lazy var nodeSnappingEnabledView: PropertyControlView<BoolControl> = {
        return .init(.init(self.vm.nodeSnappingEnabled), configuration: .compact)
            .with(\.connected, nil)
            .with(\.label, "Node Snapping")
            .rx(self.vm.$nodeSnappingEnabled, kp: \.value)
    }()

    lazy var addBookmarkButton: Button = {
        Button("Add Bookmark") { [weak self] in self?.vm.receive(event: .createBookmark) }
    }()

    lazy var bookmarkListView: BookmarkListView = {
        .init(.init(self.vm.context))
    }()

    lazy var fitAllButton: Button = {
        Button("Zoom to Fit Content") { [unowned self] in
            self.vm.receive(event: .zoomToFitContent)
        }
        .rx(self.vm.$canZoomToFitContent, kp: \.isEnabled)
    }()

    lazy var fitSelectionButton: Button = {
        Button("Zoom to Fit Selection") { [unowned self] in
            self.vm.receive(event: .zoomToFitSelection)
        }
        .rx(self.vm.$canZoomToFitSelection, kp: \.isEnabled)
    }()

    private var cancellables: Set<AnyCancellable> = []

    init(_ vm: CanvasTabViewModel) {
        self.vm = vm

        super.init(frame: .zero)

        self.addSubview(self.contentView)
        self.contentView.constraintToFillSuperview()

        self.contentView.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview(insets: .init(top: 0, left: 0, bottom: 12, right: 0))

        self.stackView.addView(self.nodeCountView)
        self.stackView.addView(self.edgeCountView)
        self.stackView.addView(self.viewportPositionView)
        self.stackView.addView(self.nodeSnappingEnabledView)
        self.stackView.addView(self.fitAllButton)
        self.stackView.addView(self.fitSelectionButton)
        self.stackView.addView(self.bookmarksTitleView)
        self.stackView.addView(self.addBookmarkButton)
        self.stackView.addView(self.bookmarkListView)

        self.stackView.setCustomSpacing(16, after: self.fitSelectionButton)
        self.stackView.setCustomSpacing(10, after: self.bookmarksTitleView)

        self.viewportPositionView.control.$value.sink { [weak self] v in
            self?.onControlValuesChanged(values: v)
        }.store(in: &self.cancellables)

        self.nodeSnappingEnabledView.control.$value.sink { [weak self] value in
            self?.vm.receive(event: .setNodeSnappingEnabled(value))
        }.store(in: &self.cancellables)

        self.viewportPositionView.restoreButtonPublisher.map({ .viewportRestore }).sendEvents(to: self.vm)
    }

    func onControlValuesChanged(values v: [Double]) {
        let values = self.vm.viewportValues

        if v[2] != values[2] {
            self.vm.receive(event: .viewportScale(v[2]))
        } else if v[0] != values[0] || v[1] != values[1] {
            self.vm.receive(event: .viewportOrigin(v[0], v[1]))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
