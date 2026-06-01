import Values
import XKit

protocol NodeInputControlView: XView {
    var label: String { get set }
    var type: ValueType { get }
    var value: Value { get set }
    var connected: Bool { get set }
    var valueDidChange: ((ValueChange) -> ())? { get set }
}

struct ValueChange {
    var newValue: Value
    var oldValue: Value?
    var commit: Bool
}
