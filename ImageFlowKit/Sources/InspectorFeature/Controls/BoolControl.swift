import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class BoolControl: Control<Bool, ()> {

    var context: ()

    @Published var value: Bool

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
}

extension BoolControl {
    fileprivate class PreviewController: XViewController {
        var _control: MappedControl<Bool, Values::Value, (), BoolControl>!
        override func loadView() {
            self._control = BoolControl(false).map(
                .init(
                    to: {
                        Values::Value.bool($0)
                    },
                    from: { $0.maybeBool ?? false }
                )
            )
            self._control.onChange = { change in
                print("-> change: \(change)")
            }
            self.view = self._control.view
        }
    }
}

#Preview {
    BoolControl.PreviewController()
}
