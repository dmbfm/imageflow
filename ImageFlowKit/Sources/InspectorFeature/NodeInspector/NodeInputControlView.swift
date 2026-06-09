import Values
import XKit

protocol NodeInputControlView: XView {
    var label: String { get set }
    var portIndex: Int { get set }
    var value: Value { get set }
    var connected: Bool { get set }
    var hasChanges: Bool { get set }
    var showPortButton: Bool { get set }
    var delegate: (any NodeInputControlDelegate)? { get set }
}

enum NodeInputControlEvent {
    case valueDidChange(ValueChange)
    case portButtonClicked
    case restoreButtonClicked
    case openAssetPicker
}

struct ValueChange {
    var newValue: Value
    var oldValue: Value?
    var commit: Bool
}

protocol NodeInputControlDelegate: AnyObject {
    func nodeInputControl(_ sender: any NodeInputControlView, valueDidChange: ValueChange)
    func nodeInputControl(_ sender: any NodeInputControlView, displayNameForAsset: UUID) -> String?
    func nodeInputControlPortButtonClicked(_ sender: any NodeInputControlView)
    func nodeInputControlRestoreButtonClicked(_ sender: any NodeInputControlView)
    func nodeInputControlOpenAssetPicker(_ sender: any NodeInputControlView)
}
