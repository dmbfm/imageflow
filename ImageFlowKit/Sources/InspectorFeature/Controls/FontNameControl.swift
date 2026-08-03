import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class FontNameControl: Control<String, (), ()> {
    @PublishedEx var value: String {
        didSet {
            if self.value != oldValue {
                self.update()
            }
        }
    }

    var onChange: ((Change<String>) -> ())?

    var configuration: ()

    var context: ()

    var view: XView {
        self.inner
    }

    lazy var inner: FontPicker = {
        FontPicker(self.value)
            .with(
                \.onChange,
                { [unowned self] newValue in
                    if newValue != self.value {
                        let oldValue = self.value
                        self.value = newValue
                        self.onChange?(.init(newValue: self.value, oldValue: oldValue, commit: true))
                    }
                }
            )
    }()

    init(_ value: String) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        self.inner.isEnabled = !disabled
    }

    private func update() {
        if self.inner.fontName != self.value {
            self.inner.fontName = self.value
        }
    }
}
