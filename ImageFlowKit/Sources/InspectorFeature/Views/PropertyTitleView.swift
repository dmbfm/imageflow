import Combine
import ComponentKit
import Helpers
import XKit

final class PropertyTitleView: XView, Rx, WithRef {

    public var connected: Bool? = false {
        didSet {
            self.updatePortButton()
        }
    }

    public var label: String = "Label" {
        didSet {
            self.updateLabel()
        }
    }

    public var hasChanges: Bool = false {
        didSet {
            self.updateRestoreButton()
        }
    }

    public var type: String? = nil

    public var context: InspectorContext? = nil

    var cancellables: Set<AnyCancellable> = []

    private var _connected: Bool {
        self.connected ?? false
    }

    lazy var portButtonView: PortButton = {
        PortButton(self._connected) { [weak self] in
            self?.context?.onPortClick?()
        }
    }()

    lazy var labelView: Label = {
        Label(self.label)
    }()

    lazy var restoreButton: Button = {
        Button("", systemSymbolName: "arrow.uturn.backward") { [weak self] in
            self?.context?.onRestoreButtonClick?()
        }
        .with(\.isBordered, false)
    }()

    lazy var typePillView: Pill = {
        Pill(self.type ?? "")
    }()

    lazy var stackView: HStack = {
        HStack(
            alignment: .center,
            spacing: 4,
            views: [
                self.portButtonView,
                self.labelTypeStack,
                self.restoreButton,
            ]
        )
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    lazy var labelTypeStack: HStack = {
        HStack(
            alignment: .lastTextBaseline,
            views: [
                self.labelView,
                self.typePillView,
            ]
        )
        .setCustomSpacing(6, after: self.labelView)
    }()

    public init(
        _ label: String,
        connected: Bool? = nil,
        hasChanges: Bool = false,
        type: String? = nil,
        context: InspectorContext? = nil
    ) {
        self.label = label
        self.connected = connected
        self.hasChanges = hasChanges
        self.type = type
        self.context = context

        super.init(frame: .zero)

        self.addSubview(self.stackView)
        self.stackView.constraintToFillSuperview()

        self.updatePortButton()
        self.updateLabel()
        self.updateRestoreButton()
        self.updateTypePill()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updatePortButton() {
        self.portButtonView.connected = self._connected
        self.portButtonView.isHidden = self.connected == nil
    }

    private func updateLabel() {
        self.labelView.text = self.label
    }

    private func updateRestoreButton() {
        self.restoreButton.isHidden = !self.hasChanges
    }

    private func updateTypePill() {
        self.typePillView.text = self.type ?? ""
        self.typePillView.isHidden = self.type == nil || self.type == ""
    }
}

#Preview {
    PropertyTitleView(
        "Value",
        connected: true,
        hasChanges: true,
        type: "Float",
        context: .init(onPortClick: { print("port!") }, onRestoreButtonClick: { print("restore!") })
    )
    .constrainingWidth(toConstant: 320)
}
