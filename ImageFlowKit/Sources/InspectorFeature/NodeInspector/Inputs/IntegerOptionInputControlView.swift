import Backend
import Helpers
import SwiftUI
import TextInput
import Values
import XKit

final class NodeIntegerOptionInputControlView: BaseNodeInputControlView {
    typealias PickerOption = ValueSemantics.IntegerSemantics.PickerOption

    let options: [PickerOption]

    var intValue: Int {
        self.value.maybeInt ?? 0
    }

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleView, self.popupButtonView])
        view.orientation = .horizontal
        return view
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

    override func update() {
        if let option = self.options[tryGetAt: self.intValue] {
            self.popupButtonView.selectItem(withTitle: option.displayName)
        }
    }

    init(label: String, value: Value, connected: Bool = false, options: [PickerOption]) {
        self.options = options

        super.init(label: label, value: value, connected: connected)

        self.blockView.view = self.stackView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func popupButtonHandler() {
        if let item = self.popupButtonView.selectedItem,
            let index = self.options.firstIndex(where: { $0.displayName == item.title })
        {
            self.setValue(
                newValue: .int(index),
                oldValue: self.value,
                commit: true
            )
        }
    }
}
