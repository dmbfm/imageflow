import Combine
import ComponentKit
import Helpers
import XKit

/// A container view that displays a `PropertyTitleView` along side an arbitrary
/// view in a stack, either in a single row (`.compact` `Configuration`), or in
/// vertical, separate rows.
final class PropertyView: XView, Rx, WithRef {
    public var view: XView {
        didSet {
            self.updateView(oldValue)
        }
    }

    public var auxiliaryView: XView? {
        didSet {
            self.updateAuxiliaryView(oldValue)
        }
    }

    public var connected: Bool? {
        get { self.titleView.connected }
        set { self.titleView.connected = newValue }
    }

    public var label: String {
        get { self.titleView.label }
        set { self.titleView.label = newValue }
    }

    public var hasChanges: Bool {
        get { self.titleView.hasChanges }
        set { self.titleView.hasChanges = newValue }
    }

    public var type: String? {
        get { self.titleView.type }
        set { self.titleView.type = newValue }
    }

    public var restoreButtonPublisher: PassthroughSubject<(), Never> {
        self.titleView.restoreButton.publisher
    }

    public var portButtonPublisher: PassthroughSubject<(), Never> {
        self.titleView.portButtonView.publisher
    }

    public var configuration: Configuration = .regular {
        didSet {
            self.updateConfiguration()
        }
    }

    var cancellables: Set<AnyCancellable> = []

    public enum Configuration {
        case compact
        case regular
    }

    lazy var boxView: ComponentKit::Box = {
        Box(inspectorBlockWithView: self.stackView)
            .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var stackView: XView = {
        switch self.configuration {
        case .compact:
            HStack(views: [
                self.titleView,
                Spacer(),
                self.view,
            ])
        case .regular:
            VStack(
                alignment: .fill,
                views: [
                    HStack(
                        views: [
                            self.titleView,
                            Spacer(),
                        ] + (self.auxiliaryView.map({ [$0] }) ?? [])
                    ),
                    self.view,
                ]
            )
        }
    }()

    lazy var titleView: PropertyTitleView = {
        PropertyTitleView("Property", connected: false)
    }()

    init(_ view: XView, _ auxiliaryView: XView? = nil, configuration: Configuration = .regular) {
        self.view = view
        self.auxiliaryView = auxiliaryView
        self.configuration = configuration

        super.init(frame: .zero)

        self.addSubview(self.boxView)
        self.boxView.constraintToFillSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updateConfiguration() {
        self.removeStackViews()
        switch self.configuration {
        case .compact:
            self.stackView = HStack(views: [
                self.titleView,
                Spacer(),
                self.view,
            ])
        case .regular:
            self.stackView = VStack(
                alignment: .fill,
                views: [self.titleView, self.view]
            )
        }
        self.boxView.view = self.stackView
    }

    private func updateView(_ oldValue: XView) {
        oldValue.removeFromSuperview()
        if let view = self.stackView as? HStack {
            view.addView(self.view)
        } else if let view = self.stackView as? VStack {
            view.addView(self.view)
        }
    }

    private func updateAuxiliaryView(_ oldValue: XView?) {
    }

    private func removeStackViews() {
        if let view = self.stackView as? VStack {
            view.removeAllViews()
        } else if let view = self.stackView as? HStack {
            view.removeAllViews()
        }
    }
}

#Preview {
    VStack(
        alignment: .fill,
        views: [
            PropertyView(Label("Control View"))
                .with(\.connected, false)
                .with(\.hasChanges, true)
                .with(\.configuration, .compact),

            PropertyView(Label("Control View"), configuration: .compact)
                .with(\.connected, false)
                .with(\.hasChanges, true)
                .with(\.configuration, .regular)
                .with(\.view, Label("Another Control View")),
        ]
    )
    .constrainingWidth(toConstant: 320)
}
