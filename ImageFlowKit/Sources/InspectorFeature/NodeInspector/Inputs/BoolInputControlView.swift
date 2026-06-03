import Backend
import Helpers
import SwiftUI
import TextInput
import Values
import XKit

final class NodeBoolInputControlView: BaseNodeInputControlView {

    var boolValue: Bool {
        self.value.maybeBool ?? false
    }

    lazy var stackView: XStackView = {
        let view = XStackView(views: [self.titleView, self.checkboxView])
        view.orientation = .horizontal
        return view
    }()

    lazy var checkboxView: XButton = {
        let view = XButton()
        view.setButtonType(.switch)
        view.title = ""
        view.target = self
        view.action = #selector(Self.checkboxHandler)
        return view
    }()

    override init(label: String, value: Value, connected: Bool = false) {
        super.init(label: label, value: value, connected: connected)
        self.blockView.content = self.stackView
    }

    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        self.checkboxView.state = self.boolValue ? .on : .off
    }

    @objc func checkboxHandler() {
        let value = self.checkboxView.state == .on ? true : false
        self.setValue(newValue: .bool(value), oldValue: self.value, commit: true)
    }
}
