import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class BoolControl: Control<Bool, (), ()> {

    var context: ()

    var configuration: ()

    @PublishedEx var value: Bool {
        didSet {
            self.checkbox.value = self.value
        }
    }

    var checkbox: Checkbox

    var view: XView {
        self.checkbox
    }

    var onChange: ((Change<Bool>) -> ())?

    var cancellables: Set<AnyCancellable> = []

    init(_ value: Bool) {
        self.value = value
        self.checkbox = Checkbox("", value: value)
        self.checkbox.onChange = { [weak self] value in
            guard let self else { return }
            let oldValue = self.value
            if value != oldValue {
                self.value = value
                let change = Change(newValue: value, oldValue: oldValue, commit: true)
                self.onChange?(change)
            }
        }
    }

    func setDisabled(_ disabled: Bool) {
        self.checkbox.disabled = disabled
    }
}
