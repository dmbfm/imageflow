import SharedModels
import Values
import XKit

class DummyInputControlView: XViewEx, NodeInputControlView {

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

    var value: Value
    var type: ValueType { self.value.type }
    var context: NodeInputControlContext? {
        didSet {
            self.titleView.context = self.context
        }
    }

    lazy var blockView: BlockView = {
        let view = BlockView(self.titleView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let view = NodeInputTitleView()
        return view
    }()

    init(label: String, value: Value, connected: Bool = false) {
        self.value = value

        super.init(frame: .zero)

        self.addSubview(self.blockView)
        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)

        self.titleView.name = label
        self.titleView.connected = connected
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
