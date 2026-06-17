import ComponentKit
import Values
import XKit

class BaseNodeInputControlView: XViewEx, NodeInputControlView {
    var value: Value {
        didSet {
            self.update()
        }
    }

    weak var delegate: (any NodeInputControlDelegate)?

    var portIndex: Int = -1

    var label: String {
        get { self.titleView.name }
        set { self.titleView.name = newValue }
    }

    var connected: Bool {
        get { self.titleView.connected }
        set { self.titleView.connected = newValue }
    }

    var hasChanges: Bool {
        get { self.titleView.hasChanges }
        set { self.titleView.hasChanges = newValue }
    }

    var showPortButton: Bool {
        get { self.titleView.showPortButton }
        set { self.titleView.showPortButton = newValue }
    }

    var blockView: Box

    var titleView: NodeInputTitleView

    init(label: String, value: Value, connected: Bool = false) {
        self.value = value
        self.titleView = .init()
        self.blockView = block(.init())
        self.blockView.translatesAutoresizingMaskIntoConstraints = false

        super.init(frame: .zero)

        self.titleView.name = label
        self.titleView.connected = connected
        self.titleView.onEvent = { [weak self] event in
            guard let self else { return }
            switch event {
            case .portButtonClicked:
                self.delegate?.nodeInputControlPortButtonClicked(self)
            case .restoreButtonClicked:
                self.delegate?.nodeInputControlRestoreButtonClicked(self)
            }
        }

        self.addSubview(self.blockView)
        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setValue(newValue: Value, oldValue: Value?, commit: Bool) {
        self.delegate?.nodeInputControl(
            self,
            valueDidChange: .init(newValue: newValue, oldValue: oldValue, commit: commit)
        )
    }

    func update() {}
}
