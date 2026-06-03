import Backend
import Helpers
import SwiftUI
import TextInput
import Values
import XKit

final class NodeIntegerOptionInputControlView: XViewEx, NodeInputControlView {

    typealias PickerOption = ValueSemantics.IntegerSemantics.PickerOption

    var value: Values.Value = .int(0) {
        didSet {
            if let option = self.options[tryGetAt: self.intValue] {
                self.popupButtonView.selectItem(withTitle: option.displayName)
            }
        }
    }

    var intValue: Int {
        self.value.maybeInt ?? 0
    }

    let options: [PickerOption]

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
        let view = XStackView(views: [self.titleView, self.popupButtonView])
        view.orientation = .horizontal
        return view
    }()

    lazy var titleView: NodeInputTitleView = {
        let titleView = NodeInputTitleView()
        return titleView
    }()

    lazy var popupButtonView: XPopUpButton = {
        let view = XPopUpButton()
        for option in self.options {
            view.addItem(withTitle: option.displayName)
        }
        if self.options.indices.contains(self.intValue) {
            view.selectItem(withTitle: self.options[self.intValue].displayName)
        }
        view.target = self
        view.action = #selector(Self.popupButtonHandler)
        return view
    }()

    init(label: String, value: Value, connected: Bool = false, options: [PickerOption]) {
        self.value = value
        self.options = options

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

    @objc func popupButtonHandler() {
        if let item = self.popupButtonView.selectedItem,
            let index = self.options.firstIndex(where: { $0.displayName == item.title })
        {
            self.context?.onEvent(
                .valueDidChange(
                    .init(
                        newValue: .int(index),
                        oldValue: self.value,
                        commit: true
                    )
                )
            )
        }
    }
}
