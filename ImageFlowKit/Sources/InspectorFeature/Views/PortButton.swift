import Combine
import ComponentKit
import Helpers
import XKit

final class PortButton: XView, Rx, WithRef {

    public var connected: Bool = false {
        didSet {
            self.update()
        }
    }

    public var onClick: (() -> ())?

    var cancellables: Set<AnyCancellable> = []

    private var portSymbolName: String {
        if self.connected {
            "arrow.backward.circle"
        } else {
            "circle.dotted"
        }
    }

    lazy var button: Button = {
        Button(
            "",
            systemSymbolName: self.portSymbolName,
            buttonSize: .regular,
            tint: nil,
            onClick: { [weak self] in self?.onClick?() }
        )
        .with(\.contentTintColor, .system.secondaryLabel)
        .with(\.isBordered, false)
        .with(\.translatesAutoresizingMaskIntoConstraints, false)
    }()

    init(_ connected: Bool, onClick: (() -> ())? = nil) {
        self.connected = connected
        self.onClick = onClick

        super.init(frame: .zero)

        self.clipsToBounds = false

        self.addSubview(self.button)
        self.button.constraintToFillSuperview()

        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func update() {
        self.button.image = XImage(systemSymbolName: self.portSymbolName, accessibilityDescription: nil)
        self.button.isEnabled = self.connected
    }
}

#Preview("Port Button") {
    VStack(views: [
        PortButton(true) { print("click!") },
        PortButton(false) { print("click!") },
    ])
}
