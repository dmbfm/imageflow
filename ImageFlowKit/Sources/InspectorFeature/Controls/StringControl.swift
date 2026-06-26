import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class StringControl: Control<String, (), ()> {
    @PublishedEx var value: String {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var configuration: ()

    var context: ()

    var view: XKit.XView { self.inner }

    lazy var inner: TextField = {
        TextField(self.value)
            .with(\.placeholderString, "Insert text...")
            .onEndEditting { [weak self] _, value in
                guard let self else { return }
                let oldValue = self.value
                self.value = value
                self.onChange?(.init(newValue: value, oldValue: oldValue, commit: true))
            }
    }()

    var onChange: ((Change<String>) -> ())?

    init(_ value: String) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        self.inner.isEnabled = !disabled
    }

    func update() {
        if self.inner.text != self.value {
            self.inner.text = self.value
        }
    }
}
