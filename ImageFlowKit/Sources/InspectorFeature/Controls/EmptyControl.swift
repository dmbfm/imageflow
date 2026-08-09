import Combine
import ComponentKit
import Helpers
import Values
import XKit

@MainActor
final class EmptyControl: Control<String, (), ()> {
    var value: String = ""

    var context: () = ()

    var configuration: ()

    lazy var view: XView = {
        .init()
    }()

    var onChange: ((Change<String>) -> ())?

    init(_ value: String) {
        self.value = value
    }

    func setDisabled(_ disabled: Bool) {
        (self.view as? Label)?.textColor = disabled ? .system.secondaryLabel : .system.label
    }
}
