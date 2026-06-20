import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class StaticLabelControl: Control<String, (), ()> {
    var value: String = "" {
        didSet {
            (self.view as? Label)?.text = value
        }
    }

    var context: () = ()

    var configuration: ()

    lazy var view: XView = {
        Label(self.value)
            .withContentHuggingPriority(.defaultLow - 10, for: .horizontal)
            .withContentHuggingPriority(.required, for: .vertical)
            .withContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            .withContentCompressionResistancePriority(.required, for: .vertical)
    }()

    var onChange: ((Change<String>) -> ())?

    init(_ value: String) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        (self.view as? Label)?.textColor = disabled ? .system.secondaryLabel : .system.label
    }
}
