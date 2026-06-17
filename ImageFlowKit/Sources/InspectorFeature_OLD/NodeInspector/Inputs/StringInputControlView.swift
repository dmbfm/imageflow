import TextInput
import Values
import XKit

class NodeStringInputControlView: BaseNodeInputControlView, MultiRowNodeInputControlView {
    var controlView: XKit.XView {
        self.textInput
    }

    var stringValue: String {
        self.value.maybeString ?? ""
    }

    lazy var textInput: TextInput = {
        let view = TextInput(behaviours: [
            .cancelAbort,
            .cancelBecomeNotEditable,
            .submitBecomeNotEditable,
            .clickBecomeEditableAndFocus,
        ])
        view.placeholder = "Insert text..."
        view.delegate = self
        return view
    }()

    var vstackedMixin: MultiRowNodeInputControlViewMixin!

    override init(label: String, value: Value, connected: Bool = false) {

        super.init(label: label, value: value, connected: connected)

        self.vstackedMixin = .init(self)
        self.update()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func update() {
        self.textInput.text = self.stringValue
    }

    var initialValue: String = ""
}

extension NodeStringInputControlView: TextInputDelegate {
    func textInputDidChange(_ textInput: TextInput) {
        self.setValue(newValue: .string(textInput.text), oldValue: .string(self.stringValue), commit: false)
    }

    // func textInputDidChange(_ textInput: TextInput)
    func textInputDidBeginEditing(_ textInput: TextInput) {
        self.initialValue = self.stringValue

    }
    func textInputDidEndEditing(_ textInput: TextInput) {
        self.setValue(newValue: .string(textInput.text), oldValue: .string(self.initialValue), commit: true)
    }

    func textInputDidCancel(_ textInput: TextInput) {
        self.setValue(newValue: .string(textInput.text), oldValue: .string(self.initialValue), commit: false)
    }
}
