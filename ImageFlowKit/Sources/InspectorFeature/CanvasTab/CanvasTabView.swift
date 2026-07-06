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

    lazy var addBookmarkButton: Button = {
        Button("Add Bookmark") { [weak self] in self?.vm.receive(event: .createBookmark) }
    }()

    lazy var bookmarkListView: BookmarkListView = {
        .init(.init(self.vm.context))
    }()

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
        self.stackView.addView(self.bookmarksTitleView)
        self.stackView.addView(self.addBookmarkButton)
        self.stackView.addView(self.bookmarkListView)

        self.stackView.setCustomSpacing(16, after: self.viewportPositionView)
        self.stackView.setCustomSpacing(10, after: self.bookmarksTitleView)

        // View model events
        self.viewportPositionView.control.$value
            .filter({ [weak self] v in
                guard let self else { return false }
                return v[2] == self.vm.viewportValues[2]
                    && (v[0] != self.vm.viewportValues[0] || v[1] != self.vm.viewportValues[1])
            })
            .map({ v in
                .viewportOrigin(v[0], v[1])
            })
            .print("viewport origin")
            .sendEvents(to: self.vm)

        self.viewportPositionView.control.$value
            .filter({ [weak self] v in v[2] != self?.vm.viewportValues[2] })
            .map({ v in
                .viewportScale(v[2].clamped(to: 0.1...4.0))
            })
            .print("viewport scale")
            .sendEvents(to: self.vm)

        self.viewportPositionView.restoreButtonPublisher.map({ .viewportRestore }).sendEvents(to: self.vm)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
