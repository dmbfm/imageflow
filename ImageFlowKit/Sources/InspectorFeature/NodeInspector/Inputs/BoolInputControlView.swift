import Backend
import Helpers
import SwiftUI
import TextInput
import Values
import XKit

final class NodeBoolinputControlView: XViewEx, NodeInputControlView {

    var value: Values.Value = .bool(false) {
        didSet {
            self.checkboxView.state = self.boolValue ? .on : .off
        }
    }

    var boolValue: Bool {
        self.value.maybeBool ?? false
    }

    var context: NodeInputControlContext? {
        didSet {
            self.titleView.context = self.context
        }
    }

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

    lazy var blockView: BlockView = {
        let view = BlockView(self.stackView)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleView, self.checkboxView])
        view.orientation = .horizontal
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let titleView = NodeInputTitleView()
        return titleView
    }()

    lazy var checkboxView: XButton = {
        let view = XButton()
        view.setButtonType(.switch)
        view.title = ""
        view.target = self
        view.action = #selector(Self.checkboxHandler)
        return view
    }()

    @objc func checkboxHandler() {
        let value = self.checkboxView.state == .on ? true : false
        self.context?.onEvent(
            .valueDidChange(
                .init(
                    newValue: .bool(value),
                    oldValue: self.value,
                    commit: true
                )
            )
        )
    }

    // lazy var

    // lazy var popupButtonView: XPopUpButton = {
    //     let view = XPopUpButton()
    //     for option in self.options {
    //         view.addItem(withTitle: option.displayName)
    //     }
    //     if self.options.indices.contains(self.intValue) {
    //         view.selectItem(withTitle: self.options[self.intValue].displayName)
    //     }
    //     view.target = self
    //     view.action = #selector(Self.popupButtonHandler)
    //     return view
    // }()

    init(label: String, value: Value, connected: Bool = false) {
        self.value = value

        super.init(frame: .zero)

        self.titleView.name = label
        self.titleView.connected = connected

        self.setupView()
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupView() {
        self.addSubview(self.blockView)

        NSLayoutConstraint.activateConstraint(self.blockView, toFill: self)
    }
}
